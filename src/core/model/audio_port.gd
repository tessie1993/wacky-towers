class_name AudioPort extends Node
## Presentation-only audio interface (ADR-0015). View and app code talk to this port;
## `AudioDirector` (src/game/audio/) implements it. Every method is a safe no-op here,
## so a missing director leaves a silent but fully working game.

## Plays a cue by id (or legacy file stem). Returns a voice handle, or -1 when nothing played.
func play_cue(_cue_id: StringName, _gain_db: float = 0.0, _pitch_st: float = 0.0) -> int:
	return -1


## Plays the cues for a batch of sim events. `ctx` carries last_axis, down, stack_height, h_play, danger_enabled.
func play_sim_events(_events: Array[SimEvent], _ctx: Dictionary = {}) -> void:
	pass


## Starts the level music: pending level key first, then the biome default, then the fallback track.
func play_music(_biome: StringName) -> void:
	pass


## Stores the level's `music` key for the next play_music call.
func set_level_music_key(_key: String) -> void:
	pass


## Starts the shared title and map track (no restart when it is already playing).
func play_menu_music() -> void:
	pass


## Starts the tournament track.
func play_party_music() -> void:
	pass


## Plays a music-bus jingle (e.g. stage_clear, pack_fanfare).
func play_jingle(_id: StringName) -> void:
	pass


## Fades the music out, then plays the win jingle when `won`.
func play_outcome(_won: bool) -> void:
	pass


## Music filter state: &"none", &"pause" or &"danger".
func set_music_filter(_state: StringName) -> void:
	pass


## Applies 0..1 or 0..100 preferences to the buses.
func apply_settings(_prefs: Dictionary) -> void:
	pass


## While true, the board event feed plays lock/clear/rotate/warning/win/lose, and legacy cue calls for them are ignored.
func set_event_feed(_on: bool) -> void:
	pass


## True while the board event feed is active.
func event_feed() -> bool:
	return false


## Plays a party-minigame event or command kind.
func play_minigame(_kind: StringName, _data: Dictionary = {}) -> void:
	pass


## Plays the result-screen star stamps (1..3) with the stepped pitches.
func play_stars(_count: int) -> void:
	pass


## Plays the UI toggle cue with the on or off pitch offset.
func play_toggle(_on: bool) -> void:
	pass


## Maps a board mechanic event kind to a cue id, or the fallback.
func board_cue(_kind: StringName, fallback: StringName = &"") -> StringName:
	return fallback
