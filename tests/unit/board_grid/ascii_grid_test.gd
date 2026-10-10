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
