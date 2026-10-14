class_name MusicResolver extends RefCounted
## Level `music` key -> catalogue track id (ADR-0015 section 5). Order: level key, biome default_music,
## fallback track. A path-like or unknown key is a warning and falls back; it never blocks play.

const PATH := "res://assets/data/audio/music.json"
const BIOME_DIR := "res://assets/data/biomes/"

var catalogue: Dictionary = {}
var warnings: PackedStringArray = PackedStringArray()
## Injected for tests: biome id -> default_music key.
var biome_default: Callable = Callable(self, "_read_biome_default")


## Reads the default catalogue.
static func load_default() -> MusicResolver:
	var m := MusicResolver.new()
	m.catalogue = JsonReader.read_file(PATH, JsonReader.DEFAULT_MAX_BYTES).get("data", {})
	return m


## Returns the track id for a level key and biome.
func resolve(level_key: String, biome: StringName) -> StringName:
	var track: StringName = _from_key(level_key, true)
	if track == &"":
		track = _from_key(String(biome_default.call(biome)), false)
	if track == &"":
		track = StringName(catalogue.get("fallback_track", "meadow"))
	return track


## Track entry with gap tracks replaced by their fallback; {} when unknown.
func track(track_id: StringName) -> Dictionary:
	var t: Dictionary = catalogue.get("tracks", {}).get(String(track_id), {})
	if t.is_empty():
		return {}
	if String(t.get("file", "")).is_empty():
		return track(StringName(t.get("fallback", catalogue.get("fallback_track", "meadow"))))
	var out: Dictionary = t.duplicate()
	out["id"] = String(track_id)
	return out


func _from_key(key: String, warn: bool) -> StringName:
	if key.is_empty():
		return &""
	if key.contains("/") or key.contains(".") or key.contains(":"):
		warnings.append("music key %s looks like a path; ignored" % key)
		return &""
	var keys: Dictionary = catalogue.get("keys", {})
	if keys.has(key):
		return StringName(keys[key])
	if catalogue.get("tracks", {}).has(key):
		return StringName(key)
	var best: String = ""
	for prefix: Variant in catalogue.get("key_prefixes", {}):
		if key.begins_with(String(prefix)) and String(prefix).length() > best.length():
			best = String(prefix)
	if best != "":
		return StringName(catalogue["key_prefixes"][best])
	if warn:
		warnings.append("unknown music key %s; using the biome default" % key)
	return &""


func _read_biome_default(biome: StringName) -> String:
	var r: Dictionary = JsonReader.read_file(BIOME_DIR + String(biome) + ".json", JsonReader.DEFAULT_MAX_BYTES)
	return String(r.get("data", {}).get("default_music", ""))
