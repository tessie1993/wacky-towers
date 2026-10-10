class_name JsonReader extends RefCounted
## Reads JSON from disk with a size cap and never through ResourceLoader (ADR-0005).
## Usage: var r: Dictionary = JsonReader.read_file("res://x.json", 65536)

## Largest whole number accepted; same rule as BoardSpec._whole_int (README plan gap 2).
const MAX_SAFE_INT := 2147483647


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


static func _fail(message: String) -> Dictionary:
	return {"ok": false, "data": {}, "error": message}
