class_name WtAudio extends Node
## Thin facade the stage and physics modes use. All playback lives in the persistent AudioDirector
## (src/game/audio/, ADR-0015) found through the AudioPort group; this node owns no players, buses or music.
## With no director in the tree (dev scenes, tests) every call is a silent no-op.

var _prefs: Dictionary = {}


## Keeps the prefs and forwards them to the director.
func setup(prefs: Dictionary = {}) -> void:
	apply_settings(prefs)


## Starts the music for the pending level key, else the biome default.
func start_music(biome: StringName) -> void:
	var port: AudioPort = _port()
	if port != null:
		port.play_music(biome)


## Plays a cue id (or legacy file stem). Ignored for board-feed ids while the event feed is on.
func cue(id: StringName) -> void:
	var port: AudioPort = _port()
	if port != null and id != &"":
		port.play_cue(id)


## Mechanic event kind -> cue id from the explicit table (assets/data/audio/event_cues.json).
## Unmapped kinds return `fallback`; the legacy &"warning" fallback is the hazard-warning cue.
static func board_sfx(kind: StringName, fallback: StringName = &"") -> StringName:
	var mapped: StringName = EventCueMap.shared().board_cue(kind, &"")
	if mapped != &"":
		return mapped
	return &"SFX_EV_WARNING" if fallback == &"warning" else fallback


## Plays a music-bus jingle (e.g. &"stage_clear", &"pack_fanfare").
func jingle(id: StringName) -> void:
	var port: AudioPort = _port()
	if port != null:
		port.play_jingle(id)


## Preferences accept 0..1 or 0..100 values.
func apply_settings(prefs: Dictionary) -> void:
	_prefs = prefs.duplicate()
	var port: AudioPort = _port()
	if port != null:
		port.apply_settings(prefs)


func _port() -> AudioPort:
	if not is_inside_tree():
		return null
	return get_tree().get_first_node_in_group(&"wt_audio_director") as AudioPort
