extends GdUnitTestSuite
## Tests for JsonReader (CH-010). Reads fixture files on purpose.

const FIX := "res://tests/unit/data/fixtures/"


func test_whole_int() -> void:
	assert_that(JsonReader.whole_int(8.0)).is_equal(8)
	assert_that(JsonReader.whole_int(8)).is_equal(8)
	assert_that(JsonReader.whole_int(-3.0)).is_equal(-3)
	var bad: Array = [6.5, NAN, INF, 1e12, "8", true, null]
	for v: Variant in bad:
		assert_that(JsonReader.whole_int(v)).is_null()


func test_json_numbers_are_floats_pinned() -> void:
	var d: Dictionary = JSON.parse_string('{"a": 8}')
	assert_int(typeof(d["a"])).is_equal(TYPE_FLOAT)


func test_read_ok() -> void:
	var r: Dictionary = JsonReader.read_file(FIX + "ok.json", 1024)
	assert_bool(r["ok"]).is_true()
	assert_that(JsonReader.whole_int(r["data"]["a"])).is_equal(8)


func test_read_missing() -> void:
	var r: Dictionary = JsonReader.read_file(FIX + "nope.json", 1024)
	assert_bool(r["ok"]).is_false()
	assert_str(r["error"]).contains("not found")


func test_read_over_cap() -> void:
	var r: Dictionary = JsonReader.read_file(FIX + "ok.json", 4)
	assert_bool(r["ok"]).is_false()
	assert_str(r["error"]).contains("over the cap")


func test_read_parse_error_has_line() -> void:
	var r: Dictionary = JsonReader.read_file(FIX + "bad.json", 1024)
	assert_bool(r["ok"]).is_false()
	assert_str(r["error"]).contains("line")


func test_read_array_root() -> void:
	var r: Dictionary = JsonReader.read_file(FIX + "array_root.json", 1024)
	assert_bool(r["ok"]).is_false()
	assert_str(r["error"]).contains("root must be an object")
