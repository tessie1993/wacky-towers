class_name MusicDeck extends Node
## Two-deck equal-power music crossfader plus a jingle player, all on the Music bus (ADR-0015 section 5).
## Loops are native (WAV loop_mode=1 at import); nothing replays on `finished`, so there is no seam gap.
## Ducks and pause/danger low-pass are bus effects (Amplify trim + LowPass), never player volume,
## so the Music slider (bus volume) and the trims never fight. All tweens run while the tree is paused.

var rules: Dictionary = {}
var _decks: Array[AudioStreamPlayer] = []
var _deck_trim_db: Array[float] = [0.0, 0.0]
var _live: int = -1
var _track: StringName = &""
var _fade: Tween = null
var _jingle: AudioStreamPlayer
var _trim: Dictionary = {}
var _trim_tweens: Dictionary = {}
var _filter_state: StringName = &"none"


## Builds the three players. Safe before entering the tree.
func setup(music_rules: Dictionary) -> void:
	rules = music_rules
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i: int in 2:
		var p := AudioStreamPlayer.new()
		p.name = "Deck%d" % i
		p.bus = AudioBuses.MUSIC
		p.volume_db = AudioBuses.SILENT_DB
		add_child(p)
		_decks.append(p)
	_jingle = AudioStreamPlayer.new()
	_jingle.name = "Jingle"
	_jingle.bus = AudioBuses.MUSIC
	add_child(_jingle)


## Id of the track on the live deck.
func current_track() -> StringName:
	return _track


## Crossfades to a catalogue track entry (from MusicResolver.track). Same track: no restart.
func play_track(entry: Dictionary, fade_s: float = -1.0) -> void:
	var id: StringName = StringName(entry.get("id", ""))
	if id == &"" or id == _track:
		return
	var stream: AudioStream = load(String(entry.get("file", ""))) as AudioStream
	if stream == null:
		push_warning("MusicDeck: cannot load %s" % entry.get("file", ""))
		return
	_ensure_loop(stream, bool(entry.get("loop", true)))
	if fade_s < 0.0:
		fade_s = float(rules.get("crossfade_s", 1.0))
	_finish_fade()
	var incoming: int = 1 - _live if _live >= 0 else 0
	var outgoing: int = _live
	_deck_trim_db[incoming] = float(entry.get("volume_db", 0.0))
	_decks[incoming].stream = stream
	_decks[incoming].volume_db = AudioBuses.SILENT_DB
	if is_inside_tree():
		_decks[incoming].play()
	_live = incoming
	_track = id
	_fade = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade.tween_method(_crossfade.bind(incoming, outgoing), 0.0, 1.0, maxf(fade_s, 0.01))
	_fade.finished.connect(_finish_fade)


## Fades the live deck out over `fade_s` and forgets the track.
func stop(fade_s: float = -1.0) -> void:
	if _live < 0:
		return
	if fade_s < 0.0:
		fade_s = float(rules.get("outcome_fade_s", 0.5))
	_finish_fade()
	var old: int = _live
	_live = -1
	_track = &""
	_fade = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade.tween_method(_crossfade.bind(-1, old), 0.0, 1.0, maxf(fade_s, 0.01))
	_fade.finished.connect(_finish_fade)


## Plays a jingle (file, volume_db) on the jingle player and ducks the track under it.
func play_jingle(entry: Dictionary) -> void:
	var stream: AudioStream = load(String(entry.get("file", ""))) as AudioStream
	if stream == null:
		return
	_jingle.stream = stream
	_jingle.volume_db = float(entry.get("volume_db", 0.0))
	if is_inside_tree():
		_jingle.play()
	var duck: Dictionary = rules.get("jingle_duck", {})
	duck_pulse(float(duck.get("db", -12.0)), float(duck.get("down_s", 0.15)), stream.get_length(), float(duck.get("up_s", 0.4)))


## Dips the music bus trim by `db`, holds, then restores (flip hit, jingles).
func duck_pulse(db: float, down_s: float, hold_s: float, up_s: float) -> void:
	_kill_trim("duck")
	var t: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_trim_tweens["duck"] = t
	t.tween_method(_set_trim.bind("duck"), float(_trim.get("duck", 0.0)), db, maxf(down_s, 0.001))
	t.tween_interval(maxf(hold_s, 0.0))
	t.tween_method(_set_trim.bind("duck"), db, 0.0, maxf(up_s, 0.001))


## &"none", &"pause" or &"danger": low-pass plus trim, animated per music_rules.json.
func set_filter(state: StringName) -> void:
	if state == _filter_state:
		return
	_filter_state = state
	var lp := AudioBuses.find_effect(AudioBuses.MUSIC, "AudioEffectLowPassFilter") as AudioEffectLowPassFilter
	var open_hz: float = float(rules.get("open_cutoff_hz", 20500.0))
	var cfg: Dictionary = rules.get(String(state), {})
	var closing: bool = state != &"none"
	var seconds: float = float(cfg.get("in_s", 0.2)) if closing else float(rules.get(String(&"pause"), {}).get("out_s", 0.2))
	if closing:
		AudioBuses.enable_effect(AudioBuses.MUSIC, "AudioEffectLowPassFilter", true)
	for key: String in ["pause", "danger"]:
		_kill_trim(key)
		var target: float = float(cfg.get("trim_db", 0.0)) if key == String(state) else 0.0
		var t: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		_trim_tweens[key] = t
		t.tween_method(_set_trim.bind(key), float(_trim.get(key, 0.0)), target, maxf(seconds, 0.001))
	if lp != null:
		var f: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		f.tween_property(lp, "cutoff_hz", float(cfg.get("cutoff_hz", open_hz)) if closing else open_hz, maxf(seconds, 0.001))
		if not closing:
			f.finished.connect(func() -> void:
				if _filter_state == &"none":
					AudioBuses.enable_effect(AudioBuses.MUSIC, "AudioEffectLowPassFilter", false))


## Current filter state.
func filter_state() -> StringName:
	return _filter_state


## Sum of all bus trims in dB (for tests and the amplify effect).
func trim_db() -> float:
	var total: float = 0.0
	for v: Variant in _trim.values():
		total += float(v)
	return total


## Equal-power crossfade step: t 0..1.
func _crossfade(t: float, incoming: int, outgoing: int) -> void:
	if incoming >= 0:
		_decks[incoming].volume_db = _deck_trim_db[incoming] + linear_to_db(maxf(sin(t * PI * 0.5), 0.0001))
	if outgoing >= 0 and outgoing != incoming:
		_decks[outgoing].volume_db = _deck_trim_db[outgoing] + linear_to_db(maxf(cos(t * PI * 0.5), 0.0001))


func _finish_fade() -> void:
	if _fade != null and _fade.is_valid():
		_fade.kill()
	_fade = null
	for i: int in _decks.size():
		if i != _live:
			_decks[i].stop()
			_decks[i].volume_db = AudioBuses.SILENT_DB
		elif _live >= 0:
			_decks[i].volume_db = _deck_trim_db[i]


func _kill_trim(key: String) -> void:
	var t: Tween = _trim_tweens.get(key)
	if t != null and t.is_valid():
		t.kill()


func _set_trim(db: float, key: String) -> void:
	_trim[key] = db
	var amp := AudioBuses.find_effect(AudioBuses.MUSIC, "AudioEffectAmplify") as AudioEffectAmplify
	if amp != null:
		amp.volume_db = trim_db()


## Native seamless loop. The import sets loop_mode=1; this repairs a stream that was imported without it.
func _ensure_loop(stream: AudioStream, loop: bool) -> void:
	var wav := stream as AudioStreamWAV
	if wav != null and loop and wav.loop_mode == AudioStreamWAV.LOOP_DISABLED:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
		push_warning("MusicDeck: stream had no native loop; set at runtime (fix the .import)")
