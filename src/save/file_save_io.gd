class_name FileSaveIO extends SaveIO
## JSON-only crash-safe storage. Reads main, backup, then interrupted temp; keeps a checksum envelope.

const SCHEMA := 1
var recovered: Dictionary = {}
var read_only: Dictionary = {}

## Returns decoded payload text from the first valid candidate; never loads a user Resource.
func read_text(path: String) -> String:
	for suffix: String in ["", ".bak", ".tmp"]:
		var candidate: String = path + suffix
		if not FileAccess.file_exists(candidate):
			continue
		var raw: Variant = _parse(FileAccess.get_file_as_string(candidate))
		if not raw is Dictionary:
			continue
		if not raw.has("payload"):
			recovered[path] = "legacy" if suffix.is_empty() else suffix
			return JSON.stringify(raw)
		if not raw.payload is Dictionary:
			continue
		var encoded: String = _canonical(raw.payload)
		if not _checksum_valid(raw):
			continue
		read_only[path] = int(raw.get("schema", 0)) > SCHEMA
		recovered[path] = "main" if suffix.is_empty() else suffix
		return encoded
	recovered[path] = "fresh"
	return ""

## Writes a checksum envelope to temp, flushes, retains the last valid main as backup, then renames.
func write_text(path: String, text: String) -> Error:
	if read_only.get(path, false):
		return ERR_UNAUTHORIZED
	var payload: Variant = _parse(text)
	if not payload is Dictionary:
		return ERR_INVALID_DATA
	var folder: String = ProjectSettings.globalize_path(path.get_base_dir())
	var mkdir_error: Error = DirAccess.make_dir_recursive_absolute(folder)
	if mkdir_error != OK:
		return mkdir_error
	var canonical: String = _canonical(payload)
	var envelope: Dictionary = {"schema": SCHEMA, "payload": payload, "checksum": canonical.sha256_text()}
	var file: FileAccess = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(envelope, "\t", true))
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		return write_error
	var verify: Variant = _parse(FileAccess.get_file_as_string(path + ".tmp"))
	if not verify is Dictionary or not verify.get("payload") is Dictionary or not _checksum_valid(verify):
		return ERR_FILE_CORRUPT
	var current: String = ProjectSettings.globalize_path(path)
	var backup: String = current + ".bak"
	if FileAccess.file_exists(path):
		var previous: Variant = _parse(FileAccess.get_file_as_string(path))
		var valid: bool = previous is Dictionary
		if valid and previous.has("payload"):
			valid = previous.payload is Dictionary and _checksum_valid(previous)
		if valid:
			if FileAccess.file_exists(path + ".bak"):
				DirAccess.remove_absolute(backup)
			var backup_error: Error = DirAccess.rename_absolute(current, backup)
			if backup_error != OK:
				return backup_error
		else:
			var corrupt: String = current + ".corrupt-0"
			var prior_corrupt: String = current + ".corrupt-1"
			if FileAccess.file_exists(prior_corrupt): DirAccess.remove_absolute(prior_corrupt)
			if FileAccess.file_exists(corrupt): DirAccess.rename_absolute(corrupt, prior_corrupt)
			DirAccess.rename_absolute(current, corrupt)
	return DirAccess.rename_absolute(current + ".tmp", current)

## Removes a file or directory recursively; reserved for explicitly requested profile deletion.
func delete(path: String) -> Error:
	var absolute: String = ProjectSettings.globalize_path(path)
	if DirAccess.dir_exists_absolute(absolute):
		var dir: DirAccess = DirAccess.open(absolute)
		if dir == null:
			return ERR_CANT_OPEN
		for name: String in dir.get_files():
			DirAccess.remove_absolute(absolute.path_join(name))
		for name: String in dir.get_directories():
			delete(absolute.path_join(name))
		return DirAccess.remove_absolute(absolute)
	if FileAccess.file_exists(path):
		return DirAccess.remove_absolute(absolute)
	return OK

## Tests existence without opening the file.
func exists(path: String) -> bool:
	return FileAccess.file_exists(path)

func _parse(text: String) -> Variant:
	var parser: JSON = JSON.new()
	return parser.data if parser.parse(text) == OK else null

func _canonical(payload: Dictionary) -> String:
	return JSON.stringify(_normalise(payload), "", true)

func _checksum_valid(envelope: Dictionary) -> bool:
	var checksum: String = str(envelope.get("checksum", ""))
	return checksum == _canonical(envelope.payload).sha256_text() or checksum == JSON.stringify(envelope.payload, "", true).sha256_text()

func _normalise(value: Variant) -> Variant:
	if value is float and is_finite(value) and value == floorf(value):
		return int(value)
	if value is Dictionary:
		var out: Dictionary = {}
		for key: Variant in value: out[key] = _normalise(value[key])
		return out
	if value is Array:
		var out: Array = []
		for child: Variant in value: out.append(_normalise(child))
		return out
	return value
