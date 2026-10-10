class_name MemorySaveIO extends SaveIO
## Dictionary-backed [SaveIO] for screens and tests. Nothing touches the disk.

var _files: Dictionary[String, String] = {}


func read_text(path: String) -> String:
	return _files.get(path, "")


func write_text(path: String, text: String) -> Error:
	_files[path] = text
	return OK


func delete(path: String) -> Error:
	_files.erase(path)
	var prefix := path + "/"
	for k in _files.keys():
		if k.begins_with(prefix):
			_files.erase(k)
	return OK


func exists(path: String) -> bool:
	return _files.has(path)
