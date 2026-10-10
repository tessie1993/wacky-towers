class_name JsonReader extends RefCounted
## Reads JSON from disk with a size cap and never through ResourceLoader (ADR-0005).
## Usage: var r: Dictionary = JsonReader.read_file("res://x.json", 65536)

## Default per-file size cap for internal data files; ADR-0005 caps untrusted levels separately.
const DEFAULT_MAX_BYTES := 262144 # 256 KB

const _RES_PREFIX := "res://"
const _JSON_SUFFIX := ".json"


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
## Usage: var files: Dictionary = JsonReader.read_dir("res://data/knobs")["files"]
static func read_dir(res_dir: String, max_bytes: int = DEFAULT_MAX_BYTES) -> Dictionary:
	var files: Dictionary = {}
	var errors := PackedStringArray()
	if not res_dir.begins_with(_RES_PREFIX):
		errors.append(res_dir + ": only res:// folders are read")
		return {"files": files, "errors": errors}
	if not DirAccess.dir_exists_absolute(res_dir):
		errors.append(res_dir + ": not found")
		return {"files": files, "errors": errors}
	var names: PackedStringArray = DirAccess.get_files_at(res_dir)
	names.sort()
	for file_name: String in names:
		if not file_name.ends_with(_JSON_SUFFIX):
			continue
		var r: Dictionary = read_file(res_dir.path_join(file_name), max_bytes)
		if r["ok"]:
			files[StringName(file_name.get_basename())] = r["data"]
		else:
			errors.append(r["error"])
	return {"files": files, "errors": errors}


static func _fail(message: String) -> Dictionary:
	return {"ok": false, "data": {}, "error": message}
