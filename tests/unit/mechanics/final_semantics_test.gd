extends GdUnitTestSuite
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const Items := preload("res://src/mechanics/behaviour/items.gd")

func _fog_event(api: RuleApi) -> Dictionary:
	var last: Dictionary = {}
	for event: Dictionary in api.take_events():
		if event.kind == &"fog_visibility": last = event.data
	return last

func test_fog_fades_each_locked_piece_from_its_own_lock() -> void:
	var api: RuleApi = F.api(F.board(), {"visible_ms": 100, "fade_ms": 100, "invisible_alpha": 0.1})
	F.write(api._board, [Vector3i(0, 0, 0)], 1)
	F.write(api._board, [Vector3i(3, 0, 3)], 2)
	var rule := FogRule.new()
	F.handle(rule, &"on_spawn", api)
	F.handle(rule, &"on_lock", api, {"uid": 1})
	api.set_time(175)
	F.handle(rule, &"on_lock", api, {"uid": 2})
	api.set_time(200)
	F.handle(rule, &"on_tick", api)
	var data: Dictionary = _fog_event(api)
	var alphas: Dictionary = {}
	for row: Dictionary in data.cell_alphas: alphas[row.cell] = row.alpha
	assert_float(float(alphas[Vector3i(0, 0, 0)])).is_equal_approx(0.1, 0.001)
	assert_float(float(alphas[Vector3i(3, 0, 3)])).is_equal_approx(1.0, 0.001)

func test_lantern_lights_all_heights_near_ghost_and_both_z_mirror_footprints() -> void:
	var api: RuleApi = F.api(F.board(6, 6, 6), {"visible_ms": 0, "fade_ms": 1, "lantern_radius": 1, "mirror_axis": "z"})
	api.bind_modifier_probe(Callable(), PackedStringArray(["mirror"]))
	api.bind_piece(ActivePiece.new(ShapeDef.build(&"mono", [Vector3i.ZERO]), Vector3i(1, 4, 1)))
	F.write(api._board, [Vector3i(1, 0, 1), Vector3i(2, 3, 1), Vector3i(1, 2, 4), Vector3i(5, 0, 3)])
	var rule := FogRule.new()
	F.handle(rule, &"on_spawn", api)
	api.set_time(10)
	F.handle(rule, &"on_tick", api)
	var data: Dictionary = _fog_event(api)
	assert_bool(data.lantern_cells.has(Vector3i(2, 3, 1))).is_true()
	assert_bool(data.lantern_cells.has(Vector3i(1, 2, 4))).is_true()
	assert_bool(data.lantern_cells.has(Vector3i(5, 0, 3))).is_false()

func test_fog_phase_waits_for_required_clear_and_reveal_is_global() -> void:
	var api: RuleApi = F.api(F.board(), {"visible_ms": 0, "fade_ms": 1, "active_after_clears": 2, "reveal_ms": 30})
	F.write(api._board, [Vector3i.ZERO])
	var rule := FogRule.new()
	F.handle(rule, &"on_spawn", api)
	F.handle(rule, &"on_clear", api, {"clear_count": 1})
	assert_int(rule.snapshot().started).is_equal(-1)
	assert_bool(_fog_event(api).is_empty()).is_true()
	api.set_time(50)
	F.handle(rule, &"on_clear", api, {"clear_count": 2})
	assert_int(rule.snapshot().started).is_equal(50)
	assert_int(rule.snapshot().alpha_milli).is_equal(1000)
	api.set_time(80)
	F.handle(rule, &"on_tick", api)
	assert_int(rule.snapshot().alpha_milli).is_equal(100)

func test_angle_secret_accepts_real_array_command_args_once() -> void:
	var api: RuleApi = F.api(F.board(), {"secret_id": "nugget", "cell": [1, 0, 3], "view_snap": 2})
	var rule := AngleGemRule.new()
	F.handle(rule, &"on_level_start", api)
	var placed: Dictionary = api.take_events()[0].data
	assert_int(int(placed.view_snap)).is_equal(2)
	F.handle(rule, &"on_command", api, {"kind": SimEvents.CMD_TAP, "args": [{"secret_id": "nugget"}]})
	F.handle(rule, &"on_command", api, {"kind": SimEvents.CMD_TAP, "args": [{"secret_id": "nugget"}]})
	assert_int(api.take_events().size()).is_equal(1)
	assert_bool(rule.snapshot().collected).is_true()

func test_happy_only_mascot_refuses_bad_existing_stack_then_catches_tidy_stack() -> void:
	var board: BoardState = F.board()
	var api: RuleApi = F.api_with_knobs(board)
	api._params = {"happy_only": true}
	var piece := ActivePiece.new(ShapeDef.build(&"mono", [Vector3i.ZERO]), Vector3i(1, 2, 1))
	api.bind_piece(piece)
	var rule := MascotCatchRule.new()
	F.handle(rule, &"on_level_start", api)
	F.write(board, [Vector3i(0, 2, 0)])
	var ctx: HookContext = F.context({"holes_added": 1})
	assert_bool(rule.veto(&"piece.lock", ctx, api)).is_false()
	assert_int(rule.snapshot().remaining).is_equal(1)
	board.remove(board.index(Vector3i(0, 2, 0)), BoardState.Cause.DISPLACED)
	assert_bool(rule.veto(&"piece.lock", ctx, api)).is_true()
	assert_int(rule.snapshot().remaining).is_equal(0)

func test_held_tag_and_bomb_keep_original_token_without_second_random_roll() -> void:
	var api: RuleApi = F.api(F.board(), {"p_item": 0.5})
	api.bind_piece(ActivePiece.new(ShapeDef.build(&"duo", [Vector3i.ZERO, Vector3i.RIGHT]), Vector3i(1, 4, 1)))
	api.bind_piece_uid(101)
	var rule := Items.new()
	F.handle(rule, &"on_level_start", api)
	for _attempt: int in 20:
		api.bind_piece_flags({})
		F.handle(rule, &"on_spawn", api)
		if int(rule.snapshot().tag_index) >= 0: break
	var original: Dictionary = api.piece_flag(&"item_cube", {}).duplicate(true)
	assert_bool(original.is_empty()).is_false()
	var before: int = api.rng().state
	api.bind_piece_uid(103)
	api.bind_piece_flags({"item_cube": original, "item_checked": true, "injected": true, "bomb": true})
	F.handle(rule, &"on_spawn", api)
	assert_int(api.rng().state).is_equal(before)
	assert_str(str(rule.snapshot().tag_token)).is_equal(str(original.token))
	assert_int(int(rule.snapshot().tag_uid)).is_equal(103)
	assert_int(int(rule.snapshot().bomb_uid)).is_equal(103)

func test_untagged_held_piece_never_rerolls() -> void:
	var api: RuleApi = F.api(F.board(), {"p_item": 0.5})
	api.bind_piece(ActivePiece.new(ShapeDef.build(&"mono", [Vector3i.ZERO]), Vector3i(1, 4, 1)))
	api.bind_piece_flags({"item_checked": true, "item_cube": {}})
	var before: int = api.rng().state
	var rule := Items.new()
	F.handle(rule, &"on_spawn", api)
	assert_int(int(rule.snapshot().tag_index)).is_equal(-1)
	assert_int(api.rng().state).is_equal(before)

func test_custom_data_table_actually_controls_collection_mix() -> void:
	var api: RuleApi = F.api(F.board(), {"table": [{"id": "bomb", "weight": 1.0, "bias": 0.0, "debuff": false}]})
	var rule := Items.new()
	F.handle(rule, &"on_level_start", api)
	F.handle(rule, &"on_clear", api, {"record": {"status": {"item": true, "item_owner": "0", "item_token": "0:1"}}})
	assert_str(str(rule.snapshot().slots[0].id)).is_equal("bomb")
