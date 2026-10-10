extends GdUnitTestSuite
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")


func test_colour_pop_requires_minimum_separate_piece_ids() -> void:
	var board: BoardState = F.board(4, 4, 6)
	for x: int in 3:
		for z: int in 2:
			board.place(board.index(Vector3i(x, 0, z)), 1, 2, 1 if x < 2 else 2)
	var api: RuleApi = F.api_with_knobs(board)
	var detector := ColourConnectDetector.new()
	var groups: Array[ClearGroup] = detector.find_clears(board, api)
	assert_int(groups.size()).is_equal(1)
	assert_int(groups[0].cells.size()).is_equal(6)
	for x: int in 3:
		for z: int in 2:
			board.place(board.index(Vector3i(x, 0, z)), 1, 2, 1)
	assert_int(detector.find_clears(board, api).size()).is_equal(0)


func test_colour_pop_does_not_join_diagonal_cubes() -> void:
	var board: BoardState = F.board()
	for x: int in 4:
		board.place(board.index(Vector3i(x, 0, x)), 1, 2, x + 1)
	var api: RuleApi = F.api_with_knobs(board, {&"clear.pop_min": 4})
	assert_int(ColourConnectDetector.new().find_clears(board, api).size()).is_equal(0)


func test_mono_layer_includes_next_occupied_layer_only() -> void:
	var board: BoardState = F.board(2, 2, 5)
	for x: int in 2:
		for z: int in 2:
			board.place(board.index(Vector3i(x, 0, z)), 1, 3, 1)
	board.place(board.index(Vector3i(0, 2, 0)), 1, 2, 2)
	board.place(board.index(Vector3i(0, 3, 0)), 1, 2, 3)
	var api: RuleApi = F.api_with_knobs(board)
	var groups: Array[ClearGroup] = MonoLayerDetector.new().find_clears(board, api)
	assert_int(groups.size()).is_equal(2)
	assert_int(board.layer_of(groups[1].cells[0])).is_equal(2)
	board.place(board.index(Vector3i(0, 0, 0)), 1, 4, 1)
	assert_int(MonoLayerDetector.new().find_clears(board, api).size()).is_equal(1)


func test_gummy_chunk_keeps_overhang_but_ordinary_cascade_drops_it() -> void:
	var board: BoardState = F.board(4, 4, 6)
	board.place(board.index(Vector3i(0, 0, 0)), 2, 0, 0)
	board.place(board.index(Vector3i(0, 1, 0)), 1, 2, 1)
	board.place(board.index(Vector3i(1, 1, 0)), 1, 2, 2)
	var api: RuleApi = F.api(board)
	GummyCascadeCollapse.new().collapse(board, [], api)
	assert_int(api.kind_at(Vector3i(1, 1, 0))).is_equal(1)
	assert_int(api.kind_at(Vector3i(1, 0, 0))).is_equal(0)
	CascadeCollapse.new().collapse(board, [], api)
	assert_int(api.kind_at(Vector3i(1, 0, 0))).is_equal(1)
	assert_int(api.kind_at(Vector3i(1, 1, 0))).is_equal(0)


func test_silt_leaves_reachable_gaps_and_lifts_existing_cube() -> void:
	var board: BoardState = F.board()
	board.place(board.index(Vector3i(0, 0, 0)), 1, 2, 7)
	var api: RuleApi = F.api(board, {"silt_every_locks": 1, "silt_gaps": 3})
	F.handle(RisingSiltRule.new(), &"on_resolve_end", api)
	var holes: int = 0
	for x: int in 4:
		for z: int in 4:
			if api.kind_at(Vector3i(x, 0, z)) == 0:
				holes += 1
	assert_int(holes).is_equal(3)
	assert_int(api.record_at(Vector3i(0, 1, 0))["piece_instance_id"]).is_equal(7)
	assert_int(api.kind_at(Vector3i(0, 0, 0))).is_equal(2)


func test_silt_skips_closed_sky_columns_until_a_clear() -> void:
	var board: BoardState = F.board()
	for x: int in 4:
		for z: int in 4:
			board.place(board.index(Vector3i(x, 1, z)), 1, 1, 1)
	var api: RuleApi = F.api(board, {"silt_every_locks": 1})
	var rule := RisingSiltRule.new()
	F.handle(rule, &"on_resolve_end", api)
	assert_bool(rule.snapshot()["wait_clear"]).is_true()
	assert_int(api.kind_at(Vector3i(0, 0, 0))).is_equal(0)


func test_snowball_roll_grows_and_stops_at_large_step() -> void:
	var board: BoardState = F.board()
	board.place(board.index(Vector3i(3, 0, 1)), 8, 0, 0)
	var api: RuleApi = F.api(board, {"slope_dir": "-x", "roll_locks": 2, "snow_max": 3, "respawn_locks": 0})
	var rule := SnowballRule.new()
	F.handle(rule, &"on_level_start", api)
	for _lock: int in 2:
		F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(2, 0, 1))).is_equal(8)
	assert_int(api.kind_at(Vector3i(2, 1, 1))).is_equal(8)
	assert_int(api.kind_at(Vector3i(3, 0, 1))).is_equal(0)
	board.place(board.index(Vector3i(1, 0, 1)), 1, 0, 2)
	board.place(board.index(Vector3i(1, 1, 1)), 1, 0, 2)
	for _lock: int in 2:
		F.handle(rule, &"on_resolve_end", api)
	assert_bool(api.record_at(Vector3i(2, 0, 1))["status"]["parked"]).is_true()


func test_pest_only_eats_blocks_and_clears_old_cell() -> void:
	var board: BoardState = F.board()
	board.place(board.index(Vector3i(1, 0, 1)), 10, 0, 0)
	board.place(board.index(Vector3i(2, 0, 1)), 1, 2, 1)
	board.place(board.index(Vector3i(0, 0, 1)), 3, 0, 0)
	var api: RuleApi = F.api(board, {"ant_every_locks": 1})
	F.handle(PestRule.new(), &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(1, 0, 1))).is_equal(0)
	assert_int(api.kind_at(Vector3i(2, 0, 1))).is_equal(10)
	assert_int(api.kind_at(Vector3i(0, 0, 1))).is_equal(3)


func test_goo_clear_cancels_one_spread() -> void:
	var board: BoardState = F.board()
	board.place(board.index(Vector3i(1, 0, 1)), 9, 0, 0)
	var api: RuleApi = F.api(board, {"per_lock": 1, "cancel_on_clear": true})
	var rule := GooSpreadRule.new()
	F.handle(rule, &"on_clear", api)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(MechanicsCells.occupied(api, 9).size()).is_equal(1)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(MechanicsCells.occupied(api, 9).size()).is_equal(2)


func test_flip_max_one_prevents_second_axis_change() -> void:
	var api: RuleApi = F.api(F.board(), {"flip_every_layers": 2, "flip_every_ms": 0, "flip_max": 1, "flip_mode": "axis", "flip_to_axis": "-x"})
	var rule := FlipRule.new()
	F.handle(rule, &"on_clear", api, {"clear_count": 2})
	assert_int(api.take_requests().size()).is_equal(2)
	F.handle(rule, &"on_resolve_end", api, {"clear_count": 2})
	F.handle(rule, &"on_clear", api, {"clear_count": 4})
	assert_int(api.take_requests().size()).is_equal(0)


func test_top_arrival_honours_anchor_and_spawn_layer_in_six_axes() -> void:
	var shape: ShapeDef = ShapeDef.build(&"o", [Vector3i.ZERO, Vector3i.RIGHT, Vector3i(0, 0, 1), Vector3i(1, 0, 1)])
	for down: int in 6:
		var spec: BoardSpec = BoardFixtures.spec(12, 12, 8, down)
		spec.spawn_anchor = Vector2i(5, 5)
		var board := BoardState.new(spec, F.types())
		var api: RuleApi = F.api(board)
		var plan: ArrivalPlan = TopArrival.new().plan_arrival(shape, board, api)
		assert_bool(plan.blocked).is_false()
		var lowest: int = board.layer_count()
		for offset: Vector3i in shape.offsets(plan.orient):
			lowest = mini(lowest, api.layer_of(plan.origin + offset))
		assert_int(lowest).is_equal(board.limit_layer())


func test_angle_secret_only_collects_explicit_matching_tap() -> void:
	var api: RuleApi = F.api(F.board(), {"secret_id": "duck"})
	var rule := AngleGemRule.new()
	F.handle(rule, &"on_command", api, {"kind": SimEvents.CMD_TAP, "args": {"secret_id": "other"}})
	assert_bool(rule.snapshot()["collected"]).is_false()
	F.handle(rule, &"on_command", api, {"kind": SimEvents.CMD_TAP, "args": {"secret_id": "duck"}})
	assert_bool(rule.snapshot()["collected"]).is_true()
	assert_int(api.take_events().size()).is_equal(1)


func test_piston_pushes_prefix_from_all_four_walls() -> void:
	for wall: String in ["-x", "+x", "-z", "+z"]:
		var board: BoardState = F.board(4, 4, 4)
		var edge: Vector3i
		var inward: Vector3i
		match wall:
			"-x":
				edge = Vector3i(0, 0, 1)
				inward = Vector3i.RIGHT
			"+x":
				edge = Vector3i(3, 0, 1)
				inward = Vector3i.LEFT
			"-z":
				edge = Vector3i(1, 0, 0)
				inward = Vector3i(0, 0, 1)
			_:
				edge = Vector3i(1, 0, 3)
				inward = Vector3i(0, 0, -1)
		F.write(board, [edge, edge + inward], 77)
		var api: RuleApi = F.api(board, {"piston_locks": 2, "pistons": [{"wall": wall, "row": 1, "y": 0}]})
		var rule := PistonPunchRule.new()
		F.handle(rule, &"on_resolve_end", api)
		F.handle(rule, &"on_resolve_end", api)
		assert_int(api.kind_at(edge)).is_equal(0)
		assert_int(api.record_at(edge + inward * 2)["piece_instance_id"]).is_equal(77)
