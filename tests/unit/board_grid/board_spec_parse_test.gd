extends GdUnitTestSuite
## BoardSpec.parse part 1 (CH-007): types, limits, down axis, mask, default anchor.


func _limits() -> BoardLimits:
	return BoardLimits.new()


func _types() -> ContentTypes:
	return ContentTypes.from_entries([
		{"kind_id": 1, "id": "block", "glyph": "#", "slot": "cell", "solid": true, "fills_layer": true, "mesh": "m", "hue": 0},
		{"kind_id": 2, "id": "starter", "glyph": "S", "slot": "cell", "solid": true, "fills_layer": false, "mesh": "m", "hue": 1},
	])


func _ok(d: Dictionary, prefix: String = "board") -> BoardSpecResult:
	return BoardSpec.parse(d, _limits(), _types(), prefix)


func _joined(r: BoardSpecResult) -> String:
	return "\n".join(r.errors)


func test_minimal_valid_board() -> void:
	var r: BoardSpecResult = _ok({"width": 6.0, "depth": 6.0, "h_play": 10.0})
	assert_array(r.errors).is_empty()
	assert_object(r.spec).is_not_null()
	assert_that(r.spec.size).is_equal(Vector3i(6, 14, 6))
	assert_int(r.spec.h_play).is_equal(10)
	assert_int(r.spec.down).is_equal(BoardState.Down.Y_NEG)
	assert_int(r.spec.mask.size()).is_equal(36)
	for v: int in r.spec.mask:
		assert_int(v).is_equal(1)
	assert_that(r.spec.spawn_anchor).is_equal(Vector2i(2, 2))


func test_int_values_also_accepted() -> void:
	var r: BoardSpecResult = _ok({"width": 6, "depth": 6, "h_play": 10})
	assert_array(r.errors).is_empty()
	assert_that(r.spec.size).is_equal(Vector3i(6, 14, 6))
	assert_that(r.spec.spawn_anchor).is_equal(Vector2i(2, 2))


func test_json_numbers_are_floats_pinned() -> void:
	var d: Dictionary = JSON.parse_string('{"width": 8}')
	assert_int(typeof(d["width"])).is_equal(TYPE_FLOAT)
	d["depth"] = 8
	d["h_play"] = 10
	var r: BoardSpecResult = _ok(d)
	assert_array(r.errors).is_empty()
	assert_that(r.spec.size).is_equal(Vector3i(8, 14, 8))


func test_non_whole_numbers_rejected() -> void:
	for bad: Variant in [6.5, "6", true, NAN, INF, 1e12]:
		var r: BoardSpecResult = _ok({"width": bad, "depth": 6, "h_play": 10})
		assert_str(_joined(r)).contains("board.width")
		assert_object(r.spec).is_null()


func test_unknown_and_missing_keys() -> void:
	var r: BoardSpecResult = _ok({"widht": 6, "depth": 6, "h_play": 10})
	assert_str(_joined(r)).contains("board.widht: unknown key")
	assert_str(_joined(r)).contains("board.width: required")
	assert_object(r.spec).is_null()


func test_size_limits() -> void:
	for w: int in [3, 25]:
		var r: BoardSpecResult = _ok({"width": w, "depth": 6, "h_play": 10})
		assert_str(_joined(r)).contains("board.width")
		assert_object(r.spec).is_null()
	for h: int in [2, 29]:
		var r: BoardSpecResult = _ok({"width": 6, "depth": 6, "h_play": h})
		assert_str(_joined(r)).contains("board.h_play")
	var r2: BoardSpecResult = _ok({"width": 24, "depth": 24, "h_play": 11})
	assert_str(_joined(r2)).contains("over the limit")


func test_down_axis() -> void:
	var r: BoardSpecResult = _ok({"width": 6, "depth": 6, "h_play": 10, "down_axis": "+x"})
	assert_array(r.errors).is_empty()
	assert_int(r.spec.down).is_equal(BoardState.Down.X_POS)
	var bad: BoardSpecResult = _ok({"width": 6, "depth": 6, "h_play": 10, "down_axis": "down"})
	assert_str(_joined(bad)).contains("board.down_axis")


func test_mask_hole_ok() -> void:
	var rows: Array = ["#####.", "######", "######", "######", "######", "######"]
	var r: BoardSpecResult = _ok({"width": 6, "depth": 6, "h_play": 10, "mask": rows})
	assert_array(r.errors).is_empty()
	var active: int = 0
	for v: int in r.spec.mask:
		active += v
	assert_int(active).is_equal(35)


func test_mask_all_masked() -> void:
	var rows: Array = ["....", "....", "....", "...."]
	var r: BoardSpecResult = _ok({"width": 4, "depth": 4, "h_play": 3, "mask": rows})
	assert_str(_joined(r)).contains("no active cell")
	assert_object(r.spec).is_null()


func test_min_active_y_axis() -> void:
	var rows: Array = ["####", "####", "###.", "...."]
	var r: BoardSpecResult = _ok({"width": 4, "depth": 4, "h_play": 3, "mask": rows})
	assert_str(_joined(r)).contains("needs >= 12")
	assert_object(r.spec).is_null()


func test_min_active_depends_on_axis() -> void:
	var rows: Array = ["####", ".###", ".###", ".###"]
	var ok: BoardSpecResult = _ok({"width": 4, "depth": 4, "h_play": 3, "mask": rows})
	assert_array(ok.errors).is_empty()
	var bad: BoardSpecResult = _ok({"width": 4, "depth": 4, "h_play": 3, "mask": rows, "down_axis": "-x"})
	assert_str(_joined(bad)).contains("x=0")


func test_default_anchor_masked() -> void:
	var rows: Array = ["######", "######", "##.###", "######", "######", "######"]
	var r: BoardSpecResult = _ok({"width": 6, "depth": 6, "h_play": 10, "mask": rows})
	assert_str(_joined(r)).contains("board.spawn_anchor")
	assert_object(r.spec).is_null()


func test_field_prefix_used() -> void:
	var r: BoardSpecResult = _ok({"width": 3, "depth": 6, "h_play": 10}, "boards[1]")
	assert_bool(r.errors.size() > 0).is_true()
	assert_str(r.errors[0]).starts_with("boards[1].width")


func test_error_cap() -> void:
	var lim: BoardLimits = _limits()
	lim.max_errors = 3
	var d: Dictionary = {}
	for i: int in 10:
		d["bogus%d" % i] = 1
	var r: BoardSpecResult = BoardSpec.parse(d, lim, _types())
	assert_int(r.errors.size()).is_equal(3)


# --- CH-008: starting_contents + explicit spawn_anchor ---


func _contents_types() -> ContentTypes:
	return ContentTypes.from_entries([
		{"kind_id": 2, "id": "block", "glyph": "#", "slot": "cell", "solid": true, "fills_layer": true, "mesh": "m", "hue": 0},
	])


func _meadow02() -> Dictionary:
	return {"width": 6.0, "depth": 6.0, "h_play": 10.0, "down_axis": "-y", "starting_contents": {"layers": {
		"0": ["######", "#.###.", "######", "######", "####.#", "######"],
		"1": ["######", "#..#..", "#.##.#", "###.##", "###..#", "######"]}}}


func _parse_c(d: Dictionary) -> BoardSpecResult:
	return BoardSpec.parse(d, _limits(), _contents_types())


func _blank_rows() -> Array:
	return ["......", "......", "......", "......", "......", "......"]


func test_meadow02_contents() -> void:
	var r: BoardSpecResult = _parse_c(_meadow02())
	assert_array(r.errors).is_empty()
	assert_int(r.spec.contents.size()).is_equal(60)
	assert_that(r.spec.contents[0]).is_equal({"cell": Vector3i(0, 0, 0), "kind": 2})
	for c: Dictionary in r.spec.contents:
		assert_int(c["kind"]).is_equal(2)


func test_contents_on_masked_cell() -> void:
	var d: Dictionary = {"width": 6, "depth": 6, "h_play": 10,
			"mask": [".#####", "######", "######", "######", "######", "######"],
			"starting_contents": {"layers": {"0": ["######", "......", "......", "......", "......", "......"]}}}
	var r: BoardSpecResult = _parse_c(d)
	assert_str(_joined(r)).contains("cell (0,0,0) is masked")
	assert_object(r.spec).is_null()


func test_contents_unknown_glyph_passthrough() -> void:
	var rows: Array = _blank_rows()
	rows[0] = "#####x"
	var r: BoardSpecResult = _parse_c({"width": 6, "depth": 6, "h_play": 10, "starting_contents": {"layers": {"0": rows}}})
	assert_str(_joined(r)).contains('layers["0"][0][5]')
	assert_object(r.spec).is_null()


func test_contents_layer_in_clearance_rejected() -> void:
	var r: BoardSpecResult = _parse_c({"width": 6, "depth": 6, "h_play": 10, "starting_contents": {"layers": {"10": _blank_rows()}}})
	assert_str(_joined(r)).contains('layers["10"]')
	assert_object(r.spec).is_null()


func test_explicit_anchor() -> void:
	var r: BoardSpecResult = _parse_c({"width": 6, "depth": 6, "h_play": 10, "spawn_anchor": [0.0, 5.0]})
	assert_array(r.errors).is_empty()
	assert_that(r.spec.spawn_anchor).is_equal(Vector2i(0, 5))


func test_bad_anchor() -> void:
	var base: Dictionary = {"width": 6, "depth": 6, "h_play": 10}
	var oob: Dictionary = base.duplicate()
	oob["spawn_anchor"] = [6, 0]
	assert_str(_joined(_parse_c(oob))).contains("out of bounds")
	for bad: Array in [[1], [1.5, 0]]:
		var d: Dictionary = base.duplicate()
		d["spawn_anchor"] = bad
		var r: BoardSpecResult = _parse_c(d)
		assert_str(_joined(r)).contains("must be [x, z]")
		assert_object(r.spec).is_null()
	var masked: Dictionary = base.duplicate()
	masked["mask"] = [".#####", "######", "######", "######", "######", "######"]
	masked["spawn_anchor"] = [0, 0]
	assert_str(_joined(_parse_c(masked))).contains("is masked")


func test_explicit_anchor_overrides_masked_default() -> void:
	var rows: Array = ["######", "######", "##.###", "######", "######", "######"]
	var r: BoardSpecResult = _parse_c({"width": 6, "depth": 6, "h_play": 10, "mask": rows, "spawn_anchor": [0, 0]})
	assert_array(r.errors).is_empty()
	assert_that(r.spec.spawn_anchor).is_equal(Vector2i(0, 0))
