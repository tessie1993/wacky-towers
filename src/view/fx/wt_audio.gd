class_name WtAudio extends Node
## Original music and pooled cues. Sound always accompanies a visible event.

var _music: AudioStreamPlayer
var _players: Array[AudioStreamPlayer] = []
var _prefs: Dictionary = {}
var _next_player: int = 0
var _music_biome: StringName = &""


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
