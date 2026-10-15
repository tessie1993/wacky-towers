extends GdUnitTestSuite
## meadow_01 "Stump Day" (design/levels/meadow/meadow_01.md section 3, Decisions 2026-10-15).
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const PATH := "res://src/levels/meadow/meadow_01/meadow_01.json"
const PROD := "res://production/levels/meadow/data/meadow_01.json"


func _raw() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(PATH))


func _params() -> Dictionary:
	return _raw()["rules"][0]["params"]


func _pit_board() -> BoardState:
	var mask := PackedByteArray()
	for row: String in _raw()["board"]["mask"]:
		for ch: String in row:
			mask.append(0 if ch == "." else 1)
	return BoardState.new(BoardFixtures.spec(8, 8, 8, BoardState.Down.Y_NEG, [], mask), F.types())


func _apply(api: RuleApi, board: BoardState) -> void:
	for r: Dictionary in api.take_requests():
		if r["op"] == &"mask":
			board.set_active(r["x"], r["z"], r["on"])


func _clear_layer(rule: GripReleaseRule, api: RuleApi, board: BoardState, layer: int = 0) -> void:
	rule.handle(&"on_lock", F.context(), api)
	for cell: int in 3:
		rule.handle(&"on_clear", F.context({"layer": layer, "chain_round": 1}), api)
	_apply(api, board)


func _width(board: BoardState) -> int:
	var xs := {}
	for x: int in 8:
		for z: int in 8:
			if board.is_active(board.index(Vector3i(x, 0, z))):
				xs[x] = true
	return xs.size()


func _setup() -> Array:
	var board := _pit_board()
	return [GripReleaseRule.new(), F.api(board, _params()), board]


func test_pit_widths_grow_four_six_eight_then_full_stump() -> void:
	var s := _setup()
	var board: BoardState = s[2]
	var seen: Array[int] = [_width(board)]
	for _g: int in 3:
		_clear_layer(s[0], s[1], board)
		seen.append(_width(board))
	assert_array(seen).is_equal([4, 6, 8, 8])
	assert_int(board.active_in_layer(0)).is_equal(52)


func test_pit_cell_counts_are_16_24_32() -> void:
	var s := _setup()
	var board: BoardState = s[2]
	var counts: Array[int] = [board.active_in_layer(0)]
	for _g: int in 2:
		_clear_layer(s[0], s[1], board)
		counts.append(board.active_in_layer(0))
	assert_array(counts).is_equal([16, 24, 32])


func test_grips_release_left_then_right_then_rim_in_all_layers() -> void:
	var s := _setup()
	var board: BoardState = s[2]
	_clear_layer(s[0], s[1], board)
	for y: int in [0, 5, 11]:
		assert_bool(board.is_active(board.index(Vector3i(0, y, 3)))).is_true()
		assert_bool(board.is_active(board.index(Vector3i(7, y, 3)))).is_false()
	_clear_layer(s[0], s[1], board)
	assert_bool(board.is_active(board.index(Vector3i(7, 9, 3)))).is_true()
	assert_bool(board.is_active(board.index(Vector3i(3, 9, 0)))).is_false()
	_clear_layer(s[0], s[1], board)
	assert_bool(board.is_active(board.index(Vector3i(3, 9, 0)))).is_true()
	assert_bool(board.is_active(board.index(Vector3i(0, 0, 0)))).is_false()


func test_one_grip_per_layer_clear_not_per_cell() -> void:
	var s := _setup()
	var rule: GripReleaseRule = s[0]
	rule.handle(&"on_lock", F.context(), s[1])
	for _c: int in 4:
		rule.handle(&"on_clear", F.context({"layer": 0, "chain_round": 1}), s[1])
	assert_int(rule.snapshot()["released"]).is_equal(1)


func test_speed_multiplies_1_25_per_release() -> void:
	var s := _setup()
	var scales: Array[float] = []
	for _g: int in 3:
		_clear_layer(s[0], s[1], s[2])
	var api: RuleApi = F.api(_pit_board(), _params())
	var rule := GripReleaseRule.new()
	for g: int in 3:
		rule.handle(&"on_clear", F.context({"layer": g, "chain_round": 1}), api)
		for r: Dictionary in api.take_requests():
			if r["op"] == &"modifiers":
				scales.append(float(r["modifiers"][0]["value"]))
	assert_float(scales[0]).is_equal_approx(1.25, 0.0001)
	assert_float(scales[1]).is_equal_approx(1.5625, 0.0001)
	assert_float(scales[2]).is_equal_approx(1.953125, 0.0001)


func test_rescue_without_clear_releases_no_grip() -> void:
	var s := _setup()
	var board: BoardState = s[2]
	s[0].handle(&"on_lock", F.context(), s[1])
	s[0].handle(&"on_resolve_end", F.context(), s[1])
	board.wipe_bottom(3)
	assert_int(s[0].snapshot()["released"]).is_equal(0)
	assert_int(_width(board)).is_equal(4)
	assert_bool(s[1].take_requests().is_empty()).is_true()


func test_third_release_is_last_and_extra_clears_do_nothing() -> void:
	var s := _setup()
	for _g: int in 5:
		_clear_layer(s[0], s[1], s[2])
	assert_int(s[0].snapshot()["released"]).is_equal(3)


func test_level_data_sets_win_on_third_grip_and_three_rescues() -> void:
	var raw := _raw()
	assert_int(int(raw["goal"]["n"])).is_equal(3)
	assert_str(raw["goal"]["type"]).is_equal("clear_n")
	assert_int(int(raw["knobs"]["goal.warnings_max"])).is_equal(3)
	assert_str(raw["hud"]["objective"]).is_equal("Free the Hearth Stump.")
	assert_str(raw["metadata"]["level_type"]).is_equal("funny")
	assert_array(raw["pieces"]["shapes"]).is_equal(["o", "i", "l"])
	assert_float(float(_params()["ramp_per_release_mult"])).is_equal(1.25)
	assert_bool(_params().has("ramp_per_minute_add")).is_false()


func test_source_and_production_json_agree() -> void:
	assert_dict(JSON.parse_string(FileAccess.get_file_as_string(PROD))).is_equal(_raw())


func test_level_loads_and_wins_on_third_clear_in_sim() -> void:
	var content := WtContent.new()
	var catalog: GameCatalog = content.load_catalog()
	var level: LevelData = content.level("meadow_01")
	assert_that(level).override_failure_message(str(content.last_issues)).is_not_null()
	var sim := BoardSim.new(level, 5, catalog)
	assert_int(sim.knobs().int_value(&"goal.warnings_max")).is_equal(3)
	assert_int(sim.board().active_in_layer(0)).is_equal(16)
