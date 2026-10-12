class_name WtAudio extends Node
## Original music and pooled cues. Sound always accompanies a visible event.

var _music: AudioStreamPlayer
var _players: Array[AudioStreamPlayer] = []
var _prefs: Dictionary = {}
var _next_player: int = 0
var _music_biome: StringName = &""
var _jingle: AudioStreamPlayer


## Initializes a small reusable audio pool; safe before entering the scene tree.
func setup(prefs: Dictionary = {}) -> void:
	if _music == null:
		_music = AudioStreamPlayer.new()
		_music.name = "ToyboxMusic"
		add_child(_music)
		_music.finished.connect(_loop_music)
		for i: int in 8:
			var p := AudioStreamPlayer.new()
			add_child(p)
			_players.append(p)
	apply_settings(prefs)


## Starts the selected biome's loop; muted music does not run.
func start_music(biome: StringName) -> void:
	if _music == null:
		setup()
	var path: String = "res://assets/audio/music/%s.wav" % biome
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/music/meadow.wav"
	_music_biome = biome
	_music.stream = load(path) as AudioStream
	if _music.volume_db > -60.0:
		_music.play()


## Plays a visible interaction's cue through a reusable player.
func cue(id: StringName) -> void:
	if _players.is_empty() or _volume("sfx") <= 0.0:
		return
	var path: String = "res://assets/audio/sfx/%s.wav" % id
	if not ResourceLoader.exists(path):
		return
	var p: AudioStreamPlayer = _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	p.stream = load(path) as AudioStream
	p.volume_db = linear_to_db(_volume("sfx")) - 7.0
	p.play()


## Wave-3 mechanic board events (src/mechanics/wave3/*.gd) -> sfx id.
## State/meter refreshes (coins_state, fever_meter, *_state) are deliberately silent.
const BOARD_SFX: Dictionary = {
	&"magnet_warning": &"w3_magnet_hum", &"magnet_pull": &"w3_magnet_pull",
	&"tile_cracking": &"w3_tile_crack", &"tile_crumbled": &"w3_tile_crumble",
	&"chameleon": &"w3_chameleon",
	&"anvil_spawned": &"w3_anvil_whistle", &"anvil_crush": &"w3_anvil_clang",
	&"queue_jumble_warning": &"w3_jumble_warn", &"queue_jumbled": &"w3_queue_jumble",
	&"mystery_reveal": &"w3_mystery_reveal",
	&"pressure": &"w3_pressure_hiss", &"pressure_release": &"w3_pressure_release",
	&"coin_collected": &"w3_coin",
	&"echo": &"w3_echo",
	&"hinge_stuck": &"w3_hinge_stuck",
	&"bolt_warning": &"w3_bolt_warning", &"bolt_strike": &"w3_bolt_strike", &"bolt_fizzle": &"w3_bolt_fizzle",
	&"confetti": &"w3_confetti",
	&"quicksand_warning": &"w3_quicksand_warn", &"quicksand_sink": &"w3_quicksand_sink",
	&"fever_start": &"w3_fever_start", &"fever_end": &"w3_fever_end",
	&"gold_layer": &"w3_gold_row", &"gold_cleared": &"w3_gold_clear",
}


## Sfx id for a board sim event kind, or `fallback` when it has no dedicated cue.
static func board_sfx(kind: StringName, fallback: StringName = &"") -> StringName:
	return BOARD_SFX.get(kind, fallback)


## Plays a one-shot music-bus stinger (res://assets/audio/music/<id>.wav, e.g.
## &"stage_clear", &"pack_fanfare") at music volume, ducking the loop under it.
func jingle(id: StringName) -> void:
	if _music == null:
		setup()
	var path: String = "res://assets/audio/music/%s.wav" % id
	if _volume("music") <= 0.0 or not ResourceLoader.exists(path):
		return
	if _jingle == null:
		_jingle = AudioStreamPlayer.new()
		_jingle.name = "Jingle"
		add_child(_jingle)
		_jingle.finished.connect(func() -> void: _music.volume_db = linear_to_db(maxf(0.0001, _volume("music"))) - 12.0)
	_jingle.stream = load(path) as AudioStream
	_jingle.volume_db = linear_to_db(_volume("music")) - 6.0
	_music.volume_db = linear_to_db(maxf(0.0001, _volume("music"))) - 24.0
	_jingle.play()


## Preferences accept 0..1 normalized values or 0..100 slider values.
func apply_settings(prefs: Dictionary) -> void:
	_prefs = prefs.duplicate()
	if _music != null:
		_music.volume_db = linear_to_db(maxf(0.0001, _volume("music"))) - 12.0
		if _volume("music") <= 0.0:
			_music.stop()
		elif _music.stream != null and not _music.playing:
			_music.play()


func _volume(channel: String) -> float:
	var v: float = float(_prefs.get(channel + "_volume", _prefs.get(channel, 0.65 if channel == "music" else 0.8)))
	if v > 1.0:
		v /= 100.0
	var master: float = float(_prefs.get("master_volume", 1.0))
	if master > 1.0:
		master /= 100.0
	if bool(_prefs.get("muted", false)):
		return 0.0
	return clampf(v * master, 0.0, 1.0)


func _loop_music() -> void:
	if _volume("music") > 0.0 and _music.stream != null:
		_music.play()
