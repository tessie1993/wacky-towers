extends GdUnitTestSuite
## Guard for assets/data/knobs/*.json (CH-018, DAT-001). Reads the real files on purpose.

const KNOB_DIR := "res://assets/data/knobs"
const EXPECTED_FILES: Array[StringName] = [&"board", &"clearing", &"controls", &"data", &"fall", &"goals", &"rules", &"spawn", &"view"]
const SLOT_KNOBS: Array[StringName] = [&"clear.detector", &"clear.collapse", &"spawn.arrival", &"goal.type", &"goal.top_out", &"control.verb"]


func _tables(files: Dictionary) -> Array:
	var tables: Array = []
	for k: Variant in files.keys():
		tables.append(files[k])
	return tables


func test_all_knob_files_parse() -> void:
	var r: Dictionary = JsonReader.read_dir(KNOB_DIR)
	var errors: PackedStringArray = r["errors"]
	assert_array(Array(errors)).is_empty()
	var files: Dictionary = r["files"]
	var stems: Array = files.keys()
	stems.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	assert_array(stems).is_equal(EXPECTED_FILES)


func test_knob_tables_build_without_errors() -> void:
	var files: Dictionary = JsonReader.read_dir(KNOB_DIR)["files"]
	var defs: KnobDefs = KnobDefs.from_tables(_tables(files))
	var errors: PackedStringArray = defs.errors()
	if not errors.is_empty():
		print("knob table errors: ", errors)
	assert_array(Array(errors)).is_empty()


func test_every_default_coerces() -> void:
	var files: Dictionary = JsonReader.read_dir(KNOB_DIR)["files"]
	var tables: Array = _tables(files)
	var defs: KnobDefs = KnobDefs.from_tables(tables)
	var checked: int = 0
	for table: Dictionary in tables:
		for entry: Dictionary in table["knobs"]:
			var id: StringName = StringName(entry["id"] as String)
			if not defs.has(id):
				continue # reported by the build test
			var v: Variant = defs.coerce(id, entry["default"])
			assert_bool(v != null).override_failure_message("default of '%s' rejected: %s" % [id, defs.last_error()]).is_true()
			checked += 1
	assert_int(checked).is_greater(0)


func test_meadow_slot_knobs_exist() -> void:
	var files: Dictionary = JsonReader.read_dir(KNOB_DIR)["files"]
	var defs: KnobDefs = KnobDefs.from_tables(_tables(files))
	for id: StringName in SLOT_KNOBS:
		assert_bool(defs.has(id)).override_failure_message("missing knob '%s'" % id).is_true()
		if defs.has(id):
			assert_that(defs.def(id)["type"]).is_equal(KnobDefs.T_SLOT)
