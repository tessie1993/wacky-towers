extends GdUnitTestSuite


func test_parses_hex() -> void:
	var t: PaletteTable = PaletteTable.from_dict({"colors": {"0": "#000000", "2": "#ff0000"}})
	assert_that(t.color(2)).is_equal(Color(1, 0, 0))
	assert_int(t.size()).is_equal(2)


func test_unknown_hue_falls_back() -> void:
	var t: PaletteTable = PaletteTable.from_dict({"colors": {"0": "#102030", "2": "#ff0000"}})
	assert_that(t.color(9)).is_equal(t.color(0))


func test_bad_hex_errors() -> void:
	var t: PaletteTable = PaletteTable.from_dict({"colors": {"1": "#zz"}})
	assert_int(t.errors().size()).is_equal(1)
	assert_str(t.errors()[0]).contains("colors.1")


func test_real_candy_palette() -> void:
	var p: Dictionary = JsonReader.read_file("res://assets/data/palettes/candy_toy.json", JsonReader.DEFAULT_MAX_BYTES)
	assert_bool(p["ok"]).is_true()
	var t: PaletteTable = PaletteTable.from_dict(p["data"])
	assert_int(t.errors().size()).is_equal(0)
	assert_int(t.size()).is_greater_equal(2)
	var f: Dictionary = JsonReader.read_file("res://assets/data/shapes/shape_hand_fields.json", JsonReader.DEFAULT_MAX_BYTES)
	assert_bool(f["ok"]).is_true()
	var fields: Dictionary = f["data"]
	for id: String in fields:
		var hue: int = int(fields[id]["hue"])
		assert_bool((p["data"]["colors"] as Dictionary).has(str(hue))).is_true()
