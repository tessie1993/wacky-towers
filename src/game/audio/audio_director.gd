class_name AudioDirector extends AudioPort
## Owns the buses' volumes, the cue registry, three voice pools and the music deck (ADR-0015).
## Implements GDD design/gdd/audio.md and design/gdd/audio/audio-direction.md. Presentation only:
## it never writes to the sim and uses its own RandomNumberGenerator for pitch.
## Usage: var d := AudioDirector.new(); add_child(d); d.play_cue(&"SFX_PIECE_LOCK")

const RULES_PATH := "res://assets/data/audio/music_rules.json"
const GROUP := &"wt_audio_director"

var library: CueLibrary
var events: EventCueMap
var resolver: MusicResolver
var deck: MusicDeck
## Injected clock (ms) so tests are deterministic.
var clock: Callable = Callable(Time, "get_ticks_msec")
var rng := RandomNumberGenerator.new()
var _pools: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer] = []
var _party_size: int = 1
var _prefs: Dictionary = {}
var _feed: bool = false
var _pending: Array[Dictionary] = []
var _level_key: String = ""
var _danger: bool = false
var _paused_filter: bool = false
var _logged_gaps: Dictionary = {}
var _ready_done: bool = false


func _ready() -> void:
	add_to_group(GROUP)
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup()
	get_tree().node_added.connect(_on_node_added)


## Builds registry, pools and deck once. Safe to call before entering the tree.
func setup() -> void:
	if _ready_done:
		return
	_ready_done = true
	rng.randomize()
	library = CueLibrary.load_default()
	for e: String in library.errors:
		push_warning("AudioDirector: " + e)
	events = EventCueMap.shared()
	resolver = MusicResolver.load_default()
	var rules: Dictionary = JsonReader.read_file(RULES_PATH, JsonReader.DEFAULT_MAX_BYTES).get("data", {})
	deck = MusicDeck.new()
	deck.name = "MusicDeck"
	add_child(deck)
	deck.setup(rules)
	_make_pool(&"sfx", AudioBuses.SFX, int(library.pools.get("sfx_party", 16)), Node.PROCESS_MODE_PAUSABLE)
	_make_pool(&"ui", AudioBuses.UI, int(library.pools.get("ui", 4)), Node.PROCESS_MODE_ALWAYS)
	_make_pool(&"ambience", AudioBuses.AMBIENCE, int(library.pools.get("ambience", 2)), Node.PROCESS_MODE_PAUSABLE)
	_apply_sidechain(rules.get("sidechain", {}))
	set_party_size(1)
	apply_settings(_prefs)


## Sets the player count: SFX pool is 12 for one board and 16 for 3-4 players.
func set_party_size(players: int) -> void:
	_party_size = players
	var n: int = int(library.pools.get("sfx_party" if players >= 3 else "sfx", 12))
	var slice: Array[AudioStreamPlayer] = []
	for i: int in mini(n, _sfx_players.size()):
		slice.append(_sfx_players[i])
	_pools[&"sfx"] = VoicePool.new(slice, clock)


func _process(_delta: float) -> void:
	_flush_pending(int(clock.call()))


## Plays due delayed cues. Public for tests.
func _flush_pending(now: int) -> void:
	var i: int = 0
	while i < _pending.size():
		if int(_pending[i]["at"]) <= now:
			var p: Dictionary = _pending[i]
			_pending.remove_at(i)
			play_cue(p["cue"], p["gain_db"], p["pitch_st"])
		else:
			i += 1


func play_cue(cue_id: StringName, gain_db: float = 0.0, pitch_st: float = 0.0) -> int:
	if not _ready_done:
		setup()
	if _feed and events.data.get("stage_legacy_ids", []).has(String(cue_id)):
		return -1
	var idx: int = library.index_of(cue_id)
	if idx < 0:
		return -1
	var def: CueDef = library.cue(idx)
	if def.gap or def.stream == null:
		if not _logged_gaps.has(def.id):
			_logged_gaps[def.id] = true
			if OS.is_debug_build():
				print("AudioDirector: gap cue %s needs a sound file" % def.id)
		return -1
	var pool_key: StringName = &"ui" if def.bus == AudioBuses.UI else (&"ambience" if def.bus == AudioBuses.AMBIENCE else &"sfx")
	var st: float = def.pitch_st + pitch_st + (rng.randf_range(-def.random_st, def.random_st) if def.random_st > 0.0 else 0.0)
	var handle: int = (_pools[pool_key] as VoicePool).play(def, idx, pow(2.0, st / 12.0), def.volume_db + gain_db)
	if handle >= 0 and def.ducks_music_db < 0.0:
		var fd: Dictionary = deck.rules.get("flip_duck", {})
		deck.duck_pulse(def.ducks_music_db, float(fd.get("down_s", 0.05)), float(fd.get("hold_s", 0.3)), float(fd.get("up_s", 0.3)))
	return handle


func play_sim_events(sim_events: Array[SimEvent], ctx: Dictionary = {}) -> void:
	if not _ready_done:
		setup()
	var now: int = int(clock.call())
	for ev: SimEvent in sim_events:
		for play: Dictionary in events.resolve(ev.kind, ev.data, ctx):
			var delay: int = int(play["delay_ms"])
			if delay <= 0:
				play_cue(play["cue"], play["gain_db"], play["pitch_st"])
			else:
				_pending.append({"at": now + delay, "cue": play["cue"], "gain_db": play["gain_db"], "pitch_st": play["pitch_st"]})
		if ev.kind == SimEvents.PIECE_LOCKED and ctx.has("h_play"):
			_near_miss(ev, ctx)
	_update_danger(ctx)


func play_music(biome: StringName) -> void:
	if not _ready_done:
		setup()
	var key: String = _level_key
	_level_key = ""
	var id: StringName = resolver.resolve(key, biome)
	_play_track_id(id)


func set_level_music_key(key: String) -> void:
	_level_key = key


func play_menu_music() -> void:
	if not _ready_done:
		setup()
	_play_track_id(StringName(resolver.catalogue.get("menu_track", "title_theme")))


func play_party_music() -> void:
	if not _ready_done:
		setup()
	_play_track_id(StringName(resolver.catalogue.get("party_track", "party_theme")))


func play_jingle(id: StringName) -> void:
	if not _ready_done:
		setup()
	var entry: Dictionary = resolver.catalogue.get("jingles", {}).get(String(id), {})
	if not entry.is_empty() and AudioBuses.slider_to_db(AudioBuses.normalize(float(_prefs.get("music_volume", 0.8)))) > AudioBuses.SILENT_DB:
		deck.play_jingle(entry)


func play_outcome(won: bool) -> void:
	if not _ready_done:
		setup()
	set_music_filter(&"none")
	deck.stop()
	if won:
		var wait: float = float(deck.rules.get("outcome_fade_s", 0.5))
		get_tree().create_timer(wait, true, false, true).timeout.connect(func() -> void: play_jingle(&"stage_clear"))


func set_music_filter(state: StringName) -> void:
	if not _ready_done:
		setup()
	_paused_filter = state == &"pause"
	deck.set_filter(state)


func apply_settings(prefs: Dictionary) -> void:
	_prefs = prefs.duplicate()
	if not _ready_done:
		return
	var master: float = AudioBuses.normalize(float(prefs.get("master_volume", 1.0)))
	if bool(prefs.get("muted", false)):
		master = 0.0
	AudioBuses.set_slider(AudioBuses.MASTER, master)
	AudioBuses.set_slider(AudioBuses.MUSIC, AudioBuses.normalize(float(prefs.get("music_volume", 0.8))))
	var sfx: float = AudioBuses.normalize(float(prefs.get("sfx_volume", 0.8)))
	AudioBuses.set_slider(AudioBuses.SFX, sfx)
	AudioBuses.set_slider(AudioBuses.AMBIENCE, sfx)
	AudioBuses.set_slider(AudioBuses.UI, AudioBuses.normalize(float(prefs.get("ui_volume", 0.7))))


func set_event_feed(on: bool) -> void:
	_feed = on
	if not on:
		_danger = false


func event_feed() -> bool:
	return _feed


func play_minigame(kind: StringName, data: Dictionary = {}) -> void:
	var mg: Dictionary = events.data.get("minigame", {})
	var cue: String = ""
	match String(kind):
		"mg_pad":
			var pad: int = int(data.get("pad", -1))
			var pads: Array = mg.get("simon_pads", [])
			cue = String(pads[pad]) if pad >= 0 and pad < pads.size() else ""
		"mg_plinko_landed":
			cue = String(mg.get("plinko_jackpot" if bool(data.get("jackpot", false)) else "plinko_bucket", ""))
		"mg_flip":
			cue = String(mg.get("card_match" if bool(data.get("matched", false)) else "card_flip", ""))
		"mg_whack_hit":
			cue = String(mg.get("whack", {}).get(String(data.get("pop_kind", "block")), ""))
		_:
			cue = String(mg.get("events", {}).get(String(kind), ""))
	if cue != "":
		play_cue(StringName(cue))


func play_stars(count: int) -> void:
	var sc: Dictionary = events.data.get("scaling", {})
	var steps: Array = sc.get("star_st", [0, 3, 7])
	var spacing: int = int(sc.get("star_spacing_ms", 300))
	var now: int = int(clock.call())
	for i: int in clampi(count, 0, steps.size()):
		_pending.append({"at": now + i * spacing, "cue": &"SFX_UI_STAR", "gain_db": 0.0, "pitch_st": float(steps[i])})
	_flush_pending(now)


func play_toggle(on: bool) -> void:
	var t: Dictionary = events.data.get("scaling", {}).get("toggle_st", {})
	play_cue(&"SFX_UI_TOGGLE", 0.0, float(t.get("on" if on else "off", 0.0)))


func board_cue(kind: StringName, fallback: StringName = &"") -> StringName:
	return events.board_cue(kind, fallback) if events != null else fallback


## Plays the UI tap for every BaseButton pressed anywhere (ADR-0015: SceneTree.node_added hook).
## Buttons whose name or text marks back/confirm get those cues; toggles get on/off pitch.
func _on_node_added(node: Node) -> void:
	var button := node as BaseButton
	if button == null or button.has_meta(&"wt_audio_hooked"):
		return
	button.set_meta(&"wt_audio_hooked", true)
	button.pressed.connect(_on_button_pressed.bind(button))


func _on_button_pressed(button: BaseButton) -> void:
	var ui: Dictionary = events.data.get("ui", {})
	if button.toggle_mode:
		play_toggle(button.button_pressed)
		return
	var label: String = String(button.name).to_lower() + " " + str(button.get("text")).to_lower()
	for word: Variant in ui.get("back_names", []):
		if label.split(" ", false).has(String(word)) or String(button.name).to_lower().begins_with(String(word)):
			play_cue(StringName(ui.get("back", "SFX_UI_BACK")))
			return
	for word: Variant in ui.get("confirm_names", []):
		if String(button.name).to_lower().begins_with(String(word)) or label.split(" ", false).has(String(word)):
			play_cue(StringName(ui.get("confirm", "SFX_UI_CONFIRM")))
			return
	play_cue(StringName(ui.get("tap", "SFX_UI_TAP")))


func _play_track_id(id: StringName) -> void:
	var entry: Dictionary = resolver.track(id)
	if entry.is_empty():
		entry = resolver.track(StringName(resolver.catalogue.get("fallback_track", "meadow")))
	if AudioBuses.normalize(float(_prefs.get("music_volume", 0.8))) <= 0.0:
		return
	deck.play_track(entry)


func _near_miss(ev: SimEvent, ctx: Dictionary) -> void:
	var cells: Array = ev.data.get("cells", [])
	var h_play: int = int(ctx.get("h_play", 0))
	var top: int = -1
	for c: Variant in cells:
		if c is Vector3i:
			top = maxi(top, (c as Vector3i).y)
	if top == h_play - 1 and h_play > 0:
		play_cue(StringName(events.data.get("scaling", {}).get("nearmiss_cue", "")))


func _update_danger(ctx: Dictionary) -> void:
	if not bool(ctx.get("danger_enabled", false)) or not ctx.has("stack_height"):
		return
	var margin: int = int(events.data.get("scaling", {}).get("danger_margin_cells", 2))
	var on: bool = int(ctx["stack_height"]) >= int(ctx.get("h_play", 0)) - margin
	if on == _danger:
		return
	_danger = on
	if not _paused_filter:
		deck.set_filter(&"danger" if on else &"none")
	if on:
		play_cue(StringName(events.data.get("scaling", {}).get("danger_cue", "")))


func _make_pool(key: StringName, bus: StringName, count: int, mode: Node.ProcessMode) -> void:
	var players: Array[AudioStreamPlayer] = []
	for i: int in count:
		var p := AudioStreamPlayer.new()
		p.name = "%s%d" % [key, i]
		p.bus = bus
		p.process_mode = mode
		add_child(p)
		players.append(p)
	if key == &"sfx":
		_sfx_players = players
	else:
		_pools[key] = VoicePool.new(players, clock)


func _apply_sidechain(cfg: Dictionary) -> void:
	for bus: StringName in [AudioBuses.MUSIC, AudioBuses.AMBIENCE]:
		var c := AudioBuses.find_effect(bus, "AudioEffectCompressor") as AudioEffectCompressor
		if c != null and not cfg.is_empty():
			c.threshold = float(cfg.get("threshold_db", -18.0))
			c.ratio = float(cfg.get("ratio", 3.0))
			c.attack_us = float(cfg.get("attack_us", 10000.0))
			c.release_ms = float(cfg.get("release_ms", 300.0))
			c.sidechain = AudioBuses.SFX
