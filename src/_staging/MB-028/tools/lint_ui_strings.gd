@tool
extends EditorScript
## Editor menu: File > Run. Prints every `text = "..."` in src/ui/**/*.tscn that is not a key in assets/i18n/strings.csv (ADR-0016 §9).

const UI_ROOT := "res://src/ui"
const CSV_PATH := "res://assets/i18n/strings.csv"


func _run() -> void:
	var keys := _load_keys()
	var re := RegEx.new()
	re.compile("(?m)^text = \"([^\"]*)\"")
	var bad := 0
	for path in _find_scenes(UI_ROOT):
		for m in re.search_all(FileAccess.get_file_as_string(path)):
			var txt := m.get_string(1)
			if txt != "" and not keys.has(txt):
				print("LINT %s: text not a string key: \"%s\"" % [path, txt])
				bad += 1
	print("lint_ui_strings: %d offender(s), %d keys known" % [bad, keys.size()])


func _load_keys() -> Dictionary:
	var keys := {}
	var f := FileAccess.open(CSV_PATH, FileAccess.READ)
	if f == null:
		push_error("lint_ui_strings: cannot open " + CSV_PATH)
		return keys
	f.get_csv_line()  # header
	while not f.eof_reached():
		var row := f.get_csv_line()
		if row.size() > 0 and row[0] != "":
			keys[row[0]] = true
	return keys


func _find_scenes(dir_path: String) -> PackedStringArray:
	var out := PackedStringArray()
	for d in DirAccess.get_directories_at(dir_path):
		out.append_array(_find_scenes(dir_path.path_join(d)))
	for f in DirAccess.get_files_at(dir_path):
		if f.ends_with(".tscn"):
			out.append(dir_path.path_join(f))
	return out
