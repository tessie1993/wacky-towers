extends GdUnitTestSuite


func test_mask_all_active() -> void:
	var r: Dictionary = AsciiGrid.parse_mask(["####", "####", "####", "####"], 4, 4, "board.mask")
	var mask: PackedByteArray = r["mask"]
	assert_int(mask.size()).is_equal(16)
	for i: int in mask.size():
		assert_int(mask[i]).is_equal(1)
	assert_int((r["errors"] as PackedStringArray).size()).is_equal(0)


func test_mask_index_is_x_plus_w_z() -> void:
	var r: Dictionary = AsciiGrid.parse_mask(["#...", "....", "...#"], 4, 3, "board.mask")
	var mask: PackedByteArray = r["mask"]
	assert_int(mask.size()).is_equal(12)
	for i: int in mask.size():
		assert_int(mask[i]).is_equal(1 if (i == 0 or i == 11) else 0)


func test_mask_wrong_row_count() -> void:
	var r: Dictionary = AsciiGrid.parse_mask(["####", "####", "####"], 4, 4, "board.mask")
	var errors: PackedStringArray = r["errors"]
	assert_int(errors.size()).is_equal(1)
	assert_str(errors[0]).contains("board.mask")
	assert_str(errors[0]).contains("expected 4 rows")
	assert_int((r["mask"] as PackedByteArray).size()).is_equal(0)


func test_mask_wrong_row_length() -> void:
	var r: Dictionary = AsciiGrid.parse_mask(["####", "###", "####", "####"], 4, 4, "board.mask")
	var errors: PackedStringArray = r["errors"]
	assert_int(errors.size()).is_equal(1)
	assert_str(errors[0]).contains("board.mask[1]")
	assert_int((r["mask"] as PackedByteArray).size()).is_equal(0)


func test_mask_bad_char_names_cell() -> void:
	var r: Dictionary = AsciiGrid.parse_mask(["####", "####", "#x#y", "####"], 4, 4, "board.mask")
	var errors: PackedStringArray = r["errors"]
	assert_int(errors.size()).is_equal(1)
	assert_str(errors[0]).contains("board.mask[2][1]")
	assert_str(errors[0]).contains("(x=1, z=2)")


func test_mask_non_string_row() -> void:
	var r: Dictionary = AsciiGrid.parse_mask(["####", 5, "####", "####"], 4, 4, "board.mask")
	var errors: PackedStringArray = r["errors"]
	assert_int(errors.size()).is_equal(1)
	assert_str(errors[0]).contains("board.mask[1]")


const LAYER_SIZE: Vector3i = Vector3i(3, 2, 2)
const LAYER_LEGAL: String = "#m"
const LAYER_FIELD: String = "board.starting_contents"


func test_layers_cells_and_order() -> void:
	var section: Dictionary = {"layers": {"1": ["#..", "..m"], "0": ["...", "#.."]}}
	var r: Dictionary = AsciiGrid.parse_layers(section, LAYER_SIZE, LAYER_LEGAL, LAYER_FIELD)
	var cells: Array = r["cells"]
	assert_int((r["errors"] as PackedStringArray).size()).is_equal(0)
	assert_int(cells.size()).is_equal(3)
	var expected: Array = [[Vector3i(0, 0, 1), "#"], [Vector3i(0, 1, 0), "#"], [Vector3i(2, 1, 1), "m"]]
	for i: int in expected.size():
		assert_that((cells[i] as Dictionary)["cell"]).is_equal(expected[i][0])
		assert_str((cells[i] as Dictionary)["glyph"]).is_equal(expected[i][1])


func test_layers_empty_dict_is_ok() -> void:
	var r: Dictionary = AsciiGrid.parse_layers({"layers": {}}, LAYER_SIZE, LAYER_LEGAL, LAYER_FIELD)
	assert_int((r["cells"] as Array).size()).is_equal(0)
	assert_int((r["errors"] as PackedStringArray).size()).is_equal(0)


func test_layers_bad_keys() -> void:
	var keys: Array[String] = ["2", "-1", "01", "a", "1.0", "99999"]
	var layers: Dictionary = {}
	for k: String in keys:
		layers[k] = []
	var r: Dictionary = AsciiGrid.parse_layers({"layers": layers}, LAYER_SIZE, LAYER_LEGAL, LAYER_FIELD)
	var errors: PackedStringArray = r["errors"]
	assert_int(errors.size()).is_equal(6)
	for i: int in keys.size():
		assert_str(errors[i]).contains('layers["%s"]' % keys[i])


func test_layers_wrong_rows() -> void:
	var r: Dictionary = AsciiGrid.parse_layers({"layers": {"0": ["###"]}}, LAYER_SIZE, LAYER_LEGAL, LAYER_FIELD)
	var errors: PackedStringArray = r["errors"]
	assert_int(errors.size()).is_equal(1)
	assert_str(errors[0]).contains("expected 2 rows")


func test_layers_unknown_glyph_names_cell() -> void:
	var r: Dictionary = AsciiGrid.parse_layers({"layers": {"1": ["#x#", "..."]}}, LAYER_SIZE, LAYER_LEGAL, LAYER_FIELD)
	var errors: PackedStringArray = r["errors"]
	assert_int(errors.size()).is_equal(1)
	assert_str(errors[0]).contains('layers["1"][0][1]')
	assert_str(errors[0]).contains("(1,1,0)")


func test_layers_unknown_section_key_and_missing_layers() -> void:
	var r: Dictionary = AsciiGrid.parse_layers({"layer": {}}, LAYER_SIZE, LAYER_LEGAL, LAYER_FIELD)
	var errors: PackedStringArray = r["errors"]
	assert_int(errors.size()).is_equal(2)
	assert_str(errors[0]).contains("board.starting_contents.layer: unknown key")
	assert_str(errors[1]).contains("board.starting_contents.layers: must be an object")
