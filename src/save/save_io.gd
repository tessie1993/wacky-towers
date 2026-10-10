class_name SaveIO extends RefCounted
## Abstract text storage behind the save system (ADR-0013 §3). Subclasses: [MemorySaveIO] now, a disk class in Phase 5.


## File text, or "" if missing.
func read_text(_path: String) -> String:
	return ""


## Writes [param text] to [param path]. Returns OK or an Error.
func write_text(_path: String, _text: String) -> Error:
	return ERR_UNAVAILABLE


## Deletes a file, or a whole folder (every path under [code]path + "/"). Missing is not an error.
func delete(_path: String) -> Error:
	return ERR_UNAVAILABLE


## True if a file exists at [param path].
func exists(_path: String) -> bool:
	return false
