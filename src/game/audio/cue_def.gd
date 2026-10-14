class_name CueDef extends RefCounted
## One row of assets/data/audio/cues.json (ADR-0015 section 3).

var id: StringName = &""
var bus: StringName = AudioBuses.SFX
var files: PackedStringArray = PackedStringArray()
var volume_db: float = 0.0
## Fixed semitone offset.
var pitch_st: float = 0.0
## +/- random semitones per play.
var random_st: float = 0.0
## 1 (highest) .. 5 (lowest).
var priority: int = 3
var max_voices: int = 2
var cooldown_ms: int = 50
var ducks_music_db: float = 0.0
## True when no file exists yet: valid data that plays nothing.
var gap: bool = false
## Longest source length in seconds (used by the voice pool to know when a voice is free).
var length_s: float = 0.5
## AudioStreamRandomizer over `files` (random no repeat); null for gap cues.
var stream: AudioStream = null
