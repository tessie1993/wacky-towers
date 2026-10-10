class_name JsonReader extends RefCounted
## Reads JSON from disk with a size cap and never through ResourceLoader (ADR-0005).
## Usage: var r: Dictionary = JsonReader.read_file("res://x.json", 65536)

## Largest whole number accepted; same rule as BoardSpec._whole_int (README plan gap 2).
const MAX_SAFE_INT := 2147483647
## 256 KB per internal data file; ADR-0005 caps untrusted levels separately.
const DEFAULT_MAX_BYTES := 262144
const RES_PREFIX := "res://"
const JSON_EXT := ".json"


## Returns an int, or null when v is not a whole number. JSON numbers arrive as float.
## Usage: JsonReader.whole_int(8.0) -> 8
static func whole_int(v: Variant) -> Variant:
	if typeof(v) == TYPE_INT:
		return v
	if typeof(v) == TYPE_FLOAT:
		var f: float = v
		if is_finite(f) and f == floorf(f) and absf(f) <= MAX_SAFE_INT:
			return int(f)
	return null


## Reads a JSON object file. Returns {"ok": bool, "data": Dictionary, "error": String}.
## Usage: var r: Dictionary = JsonReader.read_file(path, 65536)
static func read_file(path: String, max_bytes: int) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _fail(path + ": not found")
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return _fail(path + ": cannot open")
	var length: int = f.get_length()
	if length > max_bytes:
		return _fail("%s: %d bytes over the cap %d" % [path, length, max_bytes])
	var text: String = f.get_as_text()
	f.close()
	var json := JSON.new()
	if json.parse(text) != OK:
		return _fail("%s: line %d: %s" % [path, json.get_error_line(), json.get_error_message()])
	if typeof(json.data) != TYPE_DICTIONARY:
		return _fail(path + ": root must be an object")
	return {"ok": true, "data": json.data, "error": ""}


## Reads every *.json in one res:// folder, keyed by file stem.
## Returns {"files": Dictionary (StringName stem -> data), "errors": PackedStringArray}.
## Usage: var files: Dictionary = JsonReader.read_dir("res://content/knobs")["files"]
static func read_dir(res_dir: String, max_bytes: int = DEFAULT_MAX_BYTES) -> Dictionary:
	var files: Dictionary = {}
	var errors := PackedStringArray()
	if not res_dir.begins_with(RES_PREFIX):
		errors.append(res_dir + ": only res:// folders are read")
		return {"files": files, "errors": errors}
	if not DirAccess.dir_exists_absolute(res_dir):
		errors.append(res_dir + ": not found")
		return {"files": files, "errors": errors}
	var names: PackedStringArray = DirAccess.get_files_at(res_dir)
	names.sort()
	var base: String = res_dir.rstrip("/")
	for file_name: String in names:
		if not file_name.ends_with(JSON_EXT):
			continue
		var r: Dictionary = read_file(base + "/" + file_name, max_bytes)
		if r["ok"]:
			files[StringName(file_name.get_basename())] = r["data"]
		else:
			errors.append(r["error"])
	return {"files": files, "errors": errors}


static func _fail(message: String) -> Dictionary:
	return {"ok": false, "data": {}, "error": message}
