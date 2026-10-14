class_name CueLibrary extends RefCounted
## Parses assets/data/audio/cues.json once; every stream is loaded at boot (ADR-0015 section 3).

const PATH := "res://assets/data/audio/cues.json"
const BUSES: Array[String] = ["SFX", "UI", "Ambience", "Music"]

var errors: PackedStringArray = PackedStringArray()
var pools: Dictionary = {"sfx": 12, "sfx_party": 16, "ui": 4, "ambience": 2}
var _defs: Array[CueDef] = []
var _index: Dictionary = {}
var _aliases: Dictionary = {}


## Loads the default registry file.
static func load_default(load_streams: bool = true) -> CueLibrary:
	var r: Dictionary = JsonReader.read_file(PATH, JsonReader.DEFAULT_MAX_BYTES)
	var lib := CueLibrary.new()
	if not r["ok"]:
		lib.errors.append(r["error"])
		return lib
	lib.parse(r["data"], load_streams)
	return lib


## Builds the library from a parsed dictionary. Problems are collected in `errors`, never thrown.
func parse(data: Dictionary, load_streams: bool = true) -> void:
	pools.merge(data.get("pools", {}), true)
	_aliases = data.get("aliases", {}).duplicate()
	var defaults: Dictionary = data.get("defaults", {})
	var rows: Dictionary = data.get("cues", {})
	for key: Variant in rows:
		var row: Dictionary = rows[key]
		var def := CueDef.new()
		def.id = StringName(key)
		def.bus = StringName(row.get("bus", "SFX"))
		if not BUSES.has(String(def.bus)):
			errors.append("%s: unknown bus %s" % [key, def.bus])
		for f: Variant in row.get("files", []):
			def.files.append(String(f))
		def.volume_db = float(row.get("volume_db", 0.0))
		def.pitch_st = float(row.get("pitch_st", 0.0))
		def.random_st = float(row.get("random_st", 0.0))
		def.priority = clampi(int(row.get("priority", 3)), 1, 5)
		def.max_voices = maxi(1, int(row.get("max_voices", 2)))
		def.cooldown_ms = int(row.get("cooldown_ms", defaults.get("cooldown_ms", 50)))
		def.ducks_music_db = float(row.get("ducks_music_db", 0.0))
		def.gap = bool(row.get("gap", false))
		if def.files.is_empty() and not def.gap:
			errors.append("%s: no files and gap is false" % key)
		if load_streams and not def.files.is_empty():
			_load_streams(def, float(defaults.get("random_volume_db", 1.0)))
		_index[def.id] = _defs.size()
		_defs.append(def)
	for stem: Variant in _aliases:
		if not _index.has(StringName(_aliases[stem])):
			errors.append("alias %s -> unknown cue %s" % [stem, _aliases[stem]])


## Dense index of a cue id or legacy alias; -1 if unknown.
func index_of(cue_id: StringName) -> int:
	if _index.has(cue_id):
		return _index[cue_id]
	var alias: Variant = _aliases.get(String(cue_id), null)
	return _index.get(StringName(alias), -1) if alias != null else -1


## Cue definition by dense index.
func cue(index: int) -> CueDef:
	return _defs[index]


## Number of cues.
func size() -> int:
	return _defs.size()


## Every file path referenced by any cue.
func referenced_files() -> PackedStringArray:
	var out := PackedStringArray()
	for d: CueDef in _defs:
		out.append_array(d.files)
	return out


func _load_streams(def: CueDef, volume_offset_db: float) -> void:
	var rnd := AudioStreamRandomizer.new()
	rnd.playback_mode = AudioStreamRandomizer.PLAYBACK_RANDOM_NO_REPEATS
	rnd.random_volume_offset_db = volume_offset_db
	var longest: float = 0.0
	for path: String in def.files:
		var s: AudioStream = load(path) as AudioStream
		if s == null:
			errors.append("%s: cannot load %s" % [def.id, path])
			continue
		rnd.add_stream(-1, s)
		longest = maxf(longest, s.get_length())
	if rnd.streams_count > 0:
		def.stream = rnd
		def.length_s = maxf(longest, 0.05)
