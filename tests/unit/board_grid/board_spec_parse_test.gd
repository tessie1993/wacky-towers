extends GdUnitTestSuite


func _limits() -> BoardLimits:
	return BoardLimits.new()


func _types() -> ContentTypes:
	return ContentTypes.from_entries([
		{"id": "block", "kind_id": 1.0, "glyph": "", "slot": "cell", "solid": true, "fills_layer": true, "hue": 0.0, "mesh": ""},
		{"id": "starter", "kind_id": 2.0, "glyph": "#", "slot": "cell", "solid": true, "fills_layer": true, "hue": 0.0, "mesh": ""},
	])


func _parse(d: Dictionary, limits: BoardLimits = null, prefix: String = "board") -> BoardSpecResult:
	var l: BoardLimits = limits if limits != null else _limits()
	return BoardSpec.parse(d, l, _types(), prefix)


func _ok(d: Dictionary) -> BoardSpecResult:
	var r: BoardSpecResult = _parse(d)
	assert_array(Array(r.errors)).is_empty()
	return r


func _has(r: BoardSpecResult, needle: String) -> bool:
	for e: String in r.errors:
		if needle in e:
			return true
	return false


func _dims(w: Variant, d: Variant, h: Variant) -> Dictionary:
	return {"width": w, "depth": d, "h_play": h}


func test_minimal_valid_board() -> void:
	var r: BoardSpecResult = _ok(_dims(6.0, 6.0, 10.0))
	assert_that(r.spec).is_not_null()
	assert_that(r.spec.size).is_equal(Vector3i(6, 14, 6))
	assert_int(r.spec.h_play).is_equal(10)
	assert_int(r.spec.down).is_equal(BoardState.Down.Y_NEG)
	assert_int(r.spec.mask.size()).is_equal(36)
	var sum: int = 0
	for b: int in r.spec.mask:
		sum += b
	assert_int(sum).is_equal(36)
	assert_that(r.spec.spawn_anchor).is_equal(Vector2i(2, 2))


func test_int_values_also_accepted() -> void:
	var r: BoardSpecResult = _ok(_dims(6, 6, 10))
	assert_that(r.spec.size).is_equal(Vector3i(6, 14, 6))


func test_json_numbers_are_floats_pinned() -> void:
	var d: Dictionary = JSON.parse_string('{"width": 8}')
	assert_int(typeof(d["width"])).is_equal(TYPE_FLOAT)
	d["depth"] = 8.0
	d["h_play"] = 10.0
	var r: BoardSpecResult = _ok(d)
	assert_that(r.spec.size).is_equal(Vector3i(8, 14, 8))


func test_non_whole_numbers_rejected() -> void:
	for bad: Variant in [6.5, "6", true, NAN, INF, 1e12]:
		var r: BoardSpecResult = _parse(_dims(bad, 6, 10))
		assert_bool(_has(r, "board.width")).is_true()
		assert_that(r.spec).is_null()


func test_unknown_and_missing_keys() -> void:
	var r: BoardSpecResult = _parse({"widht": 6, "depth": 6, "h_play": 10})
	assert_bool(_has(r, "board.widht: unknown key")).is_true()
	assert_bool(_has(r, "board.width: required")).is_true()
	assert_that(r.spec).is_null()


func test_size_limits() -> void:
	for w: int in [3, 25]:
		assert_bool(_has(_parse(_dims(w, 6, 10)), "board.width")).is_true()
	for h: int in [2, 29]:
		assert_bool(_has(_parse(_dims(6, 6, h)), "board.h_play")).is_true()
	assert_bool(_has(_parse(_dims(24, 24, 11)), "over the limit")).is_true()


func test_down_axis() -> void:
	var d: Dictionary = _dims(6, 6, 10)
	d["down_axis"] = "+x"
	assert_int(_ok(d).spec.down).is_equal(BoardState.Down.X_POS)
	d["down_axis"] = "down"
	assert_bool(_has(_parse(d), "board.down_axis")).is_true()


func test_mask_hole_ok() -> void:
	var d: Dictionary = _dims(6, 6, 10)
	d["mask"] = ["#####.", "######", "######", "######", "######", "######"]
	var r: BoardSpecResult = _ok(d)
	var sum: int = 0
	for b: int in r.spec.mask:
		sum += b
	assert_int(sum).is_equal(35)


func test_mask_all_masked() -> void:
	var d: Dictionary = _dims(4, 4, 3)
	d["mask"] = ["....", "....", "....", "...."]
	assert_bool(_has(_parse(d), "no active cell")).is_true()


func test_min_active_y_axis() -> void:
	var d: Dictionary = _dims(4, 4, 3)
	d["mask"] = ["####", "####", "###.", "...."]
	assert_bool(_has(_parse(d), "needs >= 12")).is_true()


func test_min_active_depends_on_axis() -> void:
	var d: Dictionary = _dims(4, 4, 3)
	d["mask"] = ["####", ".###", ".###", ".###"]
	_ok(d)
	d["down_axis"] = "-x"
	assert_bool(_has(_parse(d), "x=0")).is_true()


func test_default_anchor_masked() -> void:
	var d: Dictionary = _dims(6, 6, 10)
	d["mask"] = ["######", "######", "##.###", "######", "######", "######"]
	assert_bool(_has(_parse(d), "board.spawn_anchor")).is_true()


func test_field_prefix_used() -> void:
	var r: BoardSpecResult = _parse(_dims(3, 6, 10), null, "boards[1]")
	assert_bool(r.errors.size() > 0 and r.errors[0].begins_with("boards[1].width")).is_true()


func test_error_cap() -> void:
	var l: BoardLimits = _limits()
	l.max_errors = 3
	var d: Dictionary = _dims(6, 6, 10)
	for i: int in 10:
		d["bogus%d" % i] = 1
	assert_int(_parse(d, l).errors.size()).is_equal(3)
