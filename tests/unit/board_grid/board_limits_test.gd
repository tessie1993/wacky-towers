extends GdUnitTestSuite


func test_defaults_match_adr() -> void:
	var l: BoardLimits = BoardLimits.new()
	var got: Array[int] = [l.min_side, l.max_side, l.min_height, l.max_height, l.max_cells, l.max_errors, l.min_active_per_layer, l.spawn_clearance]
	assert_array(got).is_equal([4, 24, 7, 32, 8192, 50, 12, 4])


func test_from_dict_overrides_known_keys() -> void:
	var l: BoardLimits = BoardLimits.from_dict({"max_side": 16.0, "max_errors": 5})
	assert_int(l.max_side).is_equal(16)
	assert_int(l.max_errors).is_equal(5)
	assert_int(l.min_side).is_equal(BoardLimits.DEFAULT_MIN_SIDE)
	assert_int(l.max_cells).is_equal(BoardLimits.DEFAULT_MAX_CELLS)


func test_from_dict_ignores_unknown_and_bad_values() -> void:
	var l: BoardLimits = BoardLimits.from_dict({"nope": 3, "min_side": 4.5, "max_cells": "x"})
	assert_int(l.min_side).is_equal(BoardLimits.DEFAULT_MIN_SIDE)
	assert_int(l.max_cells).is_equal(BoardLimits.DEFAULT_MAX_CELLS)
	assert_int(l.max_side).is_equal(BoardLimits.DEFAULT_MAX_SIDE)
