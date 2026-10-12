extends GdUnitTestSuite
## Wave-3 rules (design/gdd/mechanics-wave3.md W1-W15) against real boards and the real RuleApi.
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const WAVE3_IDS: Array[StringName] = [&"magnet_pull", &"crumble_tiles", &"chameleon_paint", &"anvil_drop", &"jumbled_queue",
	&"mystery_piece", &"pressure_cooker", &"star_coins", &"echo_drop", &"rusty_hinge", &"storm_bolt", &"confetti_fill",
	&"quicksand", &"fever_rush", &"golden_row"]


func _mono() -> ShapeDef:
	return ShapeDef.build(&"mono", [Vector3i.ZERO])


func _piece_at(api: RuleApi, c: Vector3i) -> void:
	api.bind_piece(ActivePiece.new(_mono(), c))


func _event(events: Array[Dictionary], kind: StringName) -> Dictionary:
	for e: Dictionary in events:
		if e.kind == kind:
			return e.data
	return {}


func _has_event(events: Array[Dictionary], kind: StringName) -> bool:
	for e: Dictionary in events:
		if e.kind == kind:
			return true
	return false


func _request(requests: Array[Dictionary], op: StringName) -> Dictionary:
	for r: Dictionary in requests:
		if r.op == op:
			return r
	return {}


func _uid_at(api: RuleApi, c: Vector3i) -> int:
	return int(api.record_at(c).get("piece_instance_id", -1))


# --- W1 magnet_pull -----------------------------------------------------------------------------

func test_magnet_pull_moves_piece_one_cell_toward_magnet_after_warning() -> void:
	var api: RuleApi = F.api(F.board(), {"magnet_col": [3, 1], "pull_interval_ms": 1000, "pull_warn_ms": 200})
	_piece_at(api, Vector3i(0, 4, 1))
	var rule := MagnetPullRule.new()
	F.handle(rule, &"on_spawn", api)
	api.set_time(800)
	F.handle(rule, &"on_tick", api)
	var events: Array[Dictionary] = api.take_events()
	assert_bool(_has_event(events, &"magnet_warning")).is_true()
	assert_int(api.piece_cells()[0].x).is_equal(0)
	api.set_time(1000)
	F.handle(rule, &"on_tick", api)
	assert_int(api.piece_cells()[0].x).is_equal(1)
	assert_that(_event(api.take_events(), &"magnet_pull").dir).is_equal(Vector3i(1, 0, 0))


func test_magnet_pull_ignores_aligned_piece() -> void:
	var api: RuleApi = F.api(F.board(), {"magnet_col": [2, 1], "pull_interval_ms": 1000})
	_piece_at(api, Vector3i(2, 4, 3))
	var rule := MagnetPullRule.new()
	F.handle(rule, &"on_spawn", api)
	api.set_time(1000)
	F.handle(rule, &"on_tick", api)
	assert_int(api.piece_cells()[0].x).is_equal(2)
	assert_bool(_has_event(api.take_events(), &"magnet_pull")).is_false()


func test_magnet_pull_blocked_move_is_ignored_until_next_interval() -> void:
	var api: RuleApi = F.api(F.board(), {"magnet_col": [3, 1], "pull_interval_ms": 1000})
	_piece_at(api, Vector3i(0, 4, 1))
	F.write(api._board, [Vector3i(1, 4, 1)])
	var rule := MagnetPullRule.new()
	F.handle(rule, &"on_spawn", api)
	api.set_time(1000)
	F.handle(rule, &"on_tick", api)
	assert_int(api.piece_cells()[0].x).is_equal(0)
	assert_int(rule.snapshot().due).is_equal(2000)


# --- W2 crumble_tiles ----------------------------------------------------------------------------

func test_crumble_tiles_break_after_touching_locks_and_drop_column() -> void:
	var api: RuleApi = F.api(F.board(), {"tiles": [[1, 1]], "crumble_after": 2})
	F.write(api._board, [Vector3i(1, 0, 1)], 1)
	F.write(api._board, [Vector3i(1, 1, 1)], 2)
	var rule := CrumbleTilesRule.new()
	F.handle(rule, &"on_level_start", api)
	api.take_events()
	F.handle(rule, &"on_lock", api, {"cells": [Vector3i(1, 0, 1)]})
	assert_bool(_has_event(api.take_events(), &"tile_cracking")).is_true()
	assert_int(_uid_at(api, Vector3i(1, 0, 1))).is_equal(1)
	F.handle(rule, &"on_lock", api, {"cells": [Vector3i(1, 0, 1)]})
	assert_bool(_has_event(api.take_events(), &"tile_crumbled")).is_true()
	assert_int(_uid_at(api, Vector3i(1, 0, 1))).is_equal(2)
	assert_int(api.kind_at(Vector3i(1, 1, 1))).is_equal(0)


func test_crumble_tiles_default_to_two_seeded_floor_cells() -> void:
	var a: RuleApi = F.api(F.board())
	var b: RuleApi = F.api(F.board())
	var first := CrumbleTilesRule.new()
	var second := CrumbleTilesRule.new()
	F.handle(first, &"on_level_start", a)
	F.handle(second, &"on_level_start", b)
	assert_int(first.snapshot().tiles.size()).is_equal(2)
	assert_that(first.snapshot().tiles).is_equal(second.snapshot().tiles)


# --- W3 chameleon_paint --------------------------------------------------------------------------

func test_chameleon_paint_takes_majority_neighbour_colour() -> void:
	var api: RuleApi = F.api(F.board())
	var b: BoardState = api._board
	b.place(b.index(Vector3i(0, 0, 0)), 1, 2, 9)
	b.place(b.index(Vector3i(2, 0, 1)), 1, 2, 9)
	F.write(b, [Vector3i(1, 0, 0), Vector3i(1, 0, 1)], 5)
	var cells: Array[Vector3i] = [Vector3i(1, 0, 0), Vector3i(1, 0, 1)]
	var rule := ChameleonPaintRule.new()
	F.handle(rule, &"on_lock", api, {"cells": cells, "uid": 5})
	assert_int(api.color_at(Vector3i(1, 0, 0))).is_equal(2)
	assert_int(api.color_at(Vector3i(1, 0, 1))).is_equal(2)
	assert_int(_uid_at(api, Vector3i(1, 0, 0))).is_equal(5)
	assert_int(_event(api.take_events(), &"chameleon").hue).is_equal(2)


func test_chameleon_paint_needs_min_neighbours_and_ties_pick_lowest_colour() -> void:
	var api: RuleApi = F.api(F.board())
	var b: BoardState = api._board
	b.place(b.index(Vector3i(0, 0, 0)), 1, 2, 9)
	F.write(b, [Vector3i(1, 0, 0)], 5)
	var rule := ChameleonPaintRule.new()
	var one: Array[Vector3i] = [Vector3i(1, 0, 0)]
	F.handle(rule, &"on_lock", api, {"cells": one})
	assert_int(api.color_at(Vector3i(1, 0, 0))).is_equal(1)
	b.place(b.index(Vector3i(2, 0, 0)), 1, 3, 9)
	var loose: RuleApi = F.api(api._board, {"min_neighbours": 1})
	F.handle(rule, &"on_lock", loose, {"cells": one})
	assert_int(loose.color_at(Vector3i(1, 0, 0))).is_equal(2)


# --- W4 anvil_drop -------------------------------------------------------------------------------

func test_anvil_drop_flags_every_nth_spawn() -> void:
	var api: RuleApi = F.api(F.board(), {"every": 2})
	var rule := AnvilDropRule.new()
	F.handle(rule, &"on_spawn", api, {"uid": 1})
	assert_bool(bool(api.piece_flag(&"anvil", false))).is_false()
	api.bind_piece_flags({})
	F.handle(rule, &"on_spawn", api, {"uid": 2})
	assert_bool(bool(api.piece_flag(&"anvil", false))).is_true()
	assert_bool(_has_event(api.take_events(), &"anvil_spawned")).is_true()
	assert_int(rule.snapshot().spawns).is_equal(2)


func test_anvil_drop_crushes_gap_beneath_lowest_cube_up_to_max() -> void:
	var api: RuleApi = F.api(F.board(), {"max_crush": 2})
	F.write(api._board, [Vector3i(1, 0, 1)], 1)
	F.write(api._board, [Vector3i(1, 4, 1)], 2)
	api.set_piece_flag(&"anvil", true)
	var rule := AnvilDropRule.new()
	var cells: Array[Vector3i] = [Vector3i(1, 4, 1)]
	F.handle(rule, &"on_lock", api, {"cells": cells})
	assert_int(api.kind_at(Vector3i(1, 4, 1))).is_equal(0)
	assert_int(_uid_at(api, Vector3i(1, 2, 1))).is_equal(2)
	assert_int(_event(api.take_events(), &"anvil_crush").cells_moved).is_equal(1)


func test_anvil_drop_does_nothing_for_plain_piece() -> void:
	var api: RuleApi = F.api(F.board())
	F.write(api._board, [Vector3i(1, 4, 1)], 2)
	var rule := AnvilDropRule.new()
	var cells: Array[Vector3i] = [Vector3i(1, 4, 1)]
	F.handle(rule, &"on_lock", api, {"cells": cells})
	assert_int(api.kind_at(Vector3i(1, 4, 1))).is_not_equal(0)


# --- W5 jumbled_queue ----------------------------------------------------------------------------

func _spawner_api(params: Dictionary) -> RuleApi:
	var api: RuleApi = F.api(F.board(), params)
	api.bind_spawner(Spawner.new({"fixed_list": PackedStringArray(["a", "b", "c", "d"]), "shapes": PackedStringArray(["a"])}, 4, 3))
	return api


func test_jumbled_queue_warns_then_shuffles_preview_keeping_ids() -> void:
	var api: RuleApi = _spawner_api({"every": 2})
	var before: PackedStringArray = api.preview_ids(16)
	var rule := JumbledQueueRule.new()
	F.handle(rule, &"on_lock", api)
	assert_bool(_has_event(api.take_events(), &"queue_jumble_warning")).is_true()
	F.handle(rule, &"on_lock", api)
	var request: Dictionary = _request(api.take_requests(), &"replace_preview")
	var ids: PackedStringArray = request.ids
	assert_bool(ids != before).is_true()
	var sorted_ids: Array = Array(ids)
	sorted_ids.sort()
	assert_that(sorted_ids).is_equal(["a", "b", "c", "d"])
	assert_int(rule.snapshot().locks).is_equal(0)


func test_jumbled_queue_without_two_ids_does_nothing() -> void:
	var api: RuleApi = F.api(F.board(), {"every": 2})
	var rule := JumbledQueueRule.new()
	F.handle(rule, &"on_lock", api)
	F.handle(rule, &"on_lock", api)
	assert_bool(api.take_events().is_empty()).is_true()
	assert_bool(api.take_requests().is_empty()).is_true()


# --- W6 mystery_piece ----------------------------------------------------------------------------

func test_mystery_piece_reveals_different_shape_on_nth_spawn() -> void:
	var api: RuleApi = F.api(F.board(), {"every": 2, "pool": ["mono", "duo"]})
	var bank := ShapeBank.new()
	bank.shapes.append(_mono())
	bank.shapes.append(ShapeDef.build(&"duo", [Vector3i.ZERO, Vector3i.RIGHT]))
	api._catalog.shapes = bank
	_piece_at(api, Vector3i(1, 4, 1))
	var rule := MysteryPieceRule.new()
	F.handle(rule, &"on_spawn", api, {"shape_id": &"mono"})
	assert_bool(_has_event(api.take_events(), &"mystery_reveal")).is_false()
	F.handle(rule, &"on_spawn", api, {"shape_id": &"mono"})
	assert_that(_event(api.take_events(), &"mystery_reveal").shape_id).is_equal(&"duo")
	assert_that(api.get_piece_shape().shape_id).is_equal(&"duo")


func test_mystery_piece_announces_preview_index_of_next_mystery() -> void:
	var api: RuleApi = _spawner_api({"every": 3})
	var rule := MysteryPieceRule.new()
	F.handle(rule, &"on_spawn", api, {"shape_id": &"a"})
	assert_int(_event(api.take_events(), &"mystery_preview").index).is_equal(1)


# --- W7 pressure_cooker --------------------------------------------------------------------------

func _modifier_value(requests: Array[Dictionary]) -> float:
	var r: Dictionary = _request(requests, &"modifiers")
	return float(r.modifiers[0].value) if not r.is_empty() and not r.modifiers.is_empty() else -1.0


func test_pressure_cooker_raises_gravity_per_clearless_lock_and_caps() -> void:
	var api: RuleApi = F.api(F.board(), {"step": 0.15, "max_scale": 1.4})
	var rule := PressureCookerRule.new()
	F.handle(rule, &"on_lock", api)
	F.handle(rule, &"on_resolve_end", api, {"cleared": 0})
	assert_float(_modifier_value(api.take_requests())).is_equal_approx(1.15, 0.0001)
	F.handle(rule, &"on_lock", api)
	F.handle(rule, &"on_resolve_end", api, {"cleared": 0})
	api.take_requests()
	F.handle(rule, &"on_lock", api)
	F.handle(rule, &"on_resolve_end", api, {"cleared": 0})
	assert_float(_modifier_value(api.take_requests())).is_equal_approx(1.4, 0.0001)
	assert_int(rule.snapshot().pressure).is_equal(3)


func test_pressure_cooker_clear_resets_pressure_and_modifier() -> void:
	var api: RuleApi = F.api(F.board())
	var rule := PressureCookerRule.new()
	F.handle(rule, &"on_lock", api)
	F.handle(rule, &"on_resolve_end", api, {"cleared": 0})
	api.take_requests()
	F.handle(rule, &"on_lock", api)
	F.handle(rule, &"on_clear", api, {"clear_count": 1})
	F.handle(rule, &"on_resolve_end", api, {"cleared": 1})
	assert_int(rule.snapshot().pressure).is_equal(0)
	assert_bool(_request(api.take_requests(), &"modifiers").modifiers.is_empty()).is_true()
	assert_bool(_has_event(api.take_events(), &"pressure_release")).is_true()


# --- W8 star_coins -------------------------------------------------------------------------------

func _coin_api(params: Dictionary) -> RuleApi:
	var api: RuleApi = F.api(F.board(), params)
	api.bind_goal(GoalState.new(), {})
	return api


func test_star_coins_place_seeded_coins_in_allowed_layers() -> void:
	var api: RuleApi = _coin_api({"coins": 3, "min_layer": 1})
	var rule := StarCoinsRule.new()
	F.handle(rule, &"on_level_start", api)
	var coins: Array = rule.snapshot().coins
	assert_int(coins.size()).is_equal(3)
	for coin: Vector3i in coins:
		assert_bool(coin.y >= 1 and coin.y <= api.limit_layer() - 2).is_true()
	assert_int(_event(api.take_events(), &"coins_state").cells.size()).is_equal(3)


func test_star_coins_lock_collects_coin_for_score_and_goal_counter() -> void:
	var api: RuleApi = _coin_api({"coins": 2, "score": 50})
	var rule := StarCoinsRule.new()
	F.handle(rule, &"on_level_start", api)
	api.take_events()
	var coin: Vector3i = rule.snapshot().coins[0]
	var cells: Array[Vector3i] = [coin]
	F.handle(rule, &"on_lock", api, {"cells": cells})
	assert_int(rule.snapshot().coins.size()).is_equal(1)
	assert_int(api.goal_counter(&"coins")).is_equal(1)
	assert_int(_request(api.take_requests(), &"score").points).is_equal(50)
	assert_int(_event(api.take_events(), &"coin_collected").remaining).is_equal(1)


func test_star_coins_shift_down_with_cleared_layers_and_collect_cleared_ones() -> void:
	var api: RuleApi = _coin_api({})
	var rule := StarCoinsRule.new()
	rule._coins = [Vector3i(0, 3, 0), Vector3i(0, 1, 0)]
	F.handle(rule, &"on_clear", api, {"layer": 1, "clear_count": 1})
	F.handle(rule, &"on_lock", api, {"cells": []})
	assert_that(rule.snapshot().coins).is_equal([Vector3i(0, 2, 0)])
	assert_int(api.goal_counter(&"coins")).is_equal(1)


# --- W9 echo_drop --------------------------------------------------------------------------------

func test_echo_drop_injects_last_shape_every_nth_lock() -> void:
	var api: RuleApi = F.api(F.board(), {"every": 2})
	var rule := EchoDropRule.new()
	F.handle(rule, &"on_lock", api, {"shape_id": &"duo"})
	assert_bool(_request(api.take_requests(), &"queue").is_empty()).is_true()
	F.handle(rule, &"on_lock", api, {"shape_id": &"tri"})
	assert_that(_request(api.take_requests(), &"queue").ids).is_equal(PackedStringArray(["tri"]))
	assert_that(_event(api.take_events(), &"echo").shape_id).is_equal(&"tri")
	assert_int(rule.snapshot().locks).is_equal(0)


# --- W10 rusty_hinge -----------------------------------------------------------------------------

func test_rusty_hinge_vetoes_rotation_after_max_turns() -> void:
	var api: RuleApi = F.api(F.board(), {"max_turns": 2})
	var rule := RustyHingeRule.new()
	var ctx: HookContext = F.context()
	F.handle(rule, &"on_spawn", api)
	assert_bool(rule.veto(SimEvents.CMD_ROTATE, ctx, api)).is_false()
	assert_bool(rule.veto(SimEvents.CMD_ROTATE, ctx, api)).is_false()
	assert_bool(rule.veto(SimEvents.CMD_ROTATE, ctx, api)).is_true()
	assert_bool(_has_event(api.take_events(), &"hinge_stuck")).is_true()
	assert_bool(rule.veto(SimEvents.CMD_MOVE, ctx, api)).is_false()
	assert_int(rule.snapshot().turns_left).is_equal(0)


func test_rusty_hinge_held_piece_keeps_remaining_turns() -> void:
	var api: RuleApi = F.api(F.board(), {"max_turns": 3})
	api.bind_piece_flags({"hinge_turns_left": 1})
	var rule := RustyHingeRule.new()
	F.handle(rule, &"on_spawn", api)
	assert_int(rule.snapshot().turns_left).is_equal(1)


# --- W11 storm_bolt ------------------------------------------------------------------------------

func _bolt_api() -> RuleApi:
	var api: RuleApi = F.api(F.board(), {"bolt_interval_ms": 1000, "bolt_warn_ms": 500, "bolt_jitter_ms": 0})
	F.write(api._board, [Vector3i(1, 0, 1)], 1)
	F.write(api._board, [Vector3i(1, 1, 1)], 2)
	return api


func test_storm_bolt_warns_then_strikes_top_cube_of_column() -> void:
	var api: RuleApi = _bolt_api()
	var rule := StormBoltRule.new()
	F.handle(rule, &"on_level_start", api)
	api.set_time(500)
	F.handle(rule, &"on_tick", api)
	assert_that(_event(api.take_events(), &"bolt_warning").column).is_equal(Vector3i(1, 0, 1))
	api.set_time(1000)
	F.handle(rule, &"on_tick", api)
	assert_that(_event(api.take_events(), &"bolt_strike").cell).is_equal(Vector3i(1, 1, 1))
	assert_int(api.kind_at(Vector3i(1, 1, 1))).is_equal(0)
	assert_int(api.kind_at(Vector3i(1, 0, 1))).is_not_equal(0)


func test_storm_bolt_fizzles_when_column_emptied_before_due() -> void:
	var api: RuleApi = _bolt_api()
	var rule := StormBoltRule.new()
	F.handle(rule, &"on_level_start", api)
	api.set_time(500)
	F.handle(rule, &"on_tick", api)
	api._board.remove(api._board.index(Vector3i(1, 0, 1)), BoardState.Cause.CLEAR)
	api._board.remove(api._board.index(Vector3i(1, 1, 1)), BoardState.Cause.CLEAR)
	api.take_events()
	api.set_time(1000)
	F.handle(rule, &"on_tick", api)
	assert_bool(_has_event(api.take_events(), &"bolt_fizzle")).is_true()


func test_storm_bolt_skips_bolt_on_empty_board() -> void:
	var api: RuleApi = F.api(F.board(), {"bolt_interval_ms": 1000, "bolt_warn_ms": 500, "bolt_jitter_ms": 0})
	var rule := StormBoltRule.new()
	F.handle(rule, &"on_level_start", api)
	api.set_time(500)
	F.handle(rule, &"on_tick", api)
	assert_bool(api.take_events().is_empty()).is_true()
	assert_int(rule.snapshot().due).is_equal(1500)


# --- W12 confetti_fill ---------------------------------------------------------------------------

func _confetti_api(params: Dictionary) -> RuleApi:
	var api: RuleApi = F.api(F.board(), params)
	F.write(api._board, [Vector3i(1, 3, 1)], 4)
	return api


func test_confetti_fill_covers_lowest_holes_up_to_max_after_multi_clear() -> void:
	var api: RuleApi = _confetti_api({"max_fill": 2})
	var rule := ConfettiFillRule.new()
	F.handle(rule, &"on_lock", api, {"clear_count": 0})
	F.handle(rule, &"on_clear", api, {"clear_count": 2})
	F.handle(rule, &"on_resolve_end", api, {"cleared": 2})
	assert_that(_event(api.take_events(), &"confetti").cells).is_equal([Vector3i(1, 0, 1), Vector3i(1, 1, 1)])
	assert_bool(bool(api.record_at(Vector3i(1, 0, 1)).status.get("confetti", false))).is_true()
	assert_int(api.kind_at(Vector3i(1, 2, 1))).is_equal(0)


func test_confetti_fill_ignores_single_layer_clear() -> void:
	var api: RuleApi = _confetti_api({})
	var rule := ConfettiFillRule.new()
	F.handle(rule, &"on_lock", api, {"clear_count": 0})
	F.handle(rule, &"on_clear", api, {"clear_count": 1})
	F.handle(rule, &"on_resolve_end", api, {"cleared": 1})
	assert_int(api.kind_at(Vector3i(1, 0, 1))).is_equal(0)


# --- W13 quicksand -------------------------------------------------------------------------------

func test_quicksand_swallows_bottom_cube_every_nth_lock_after_warning() -> void:
	var api: RuleApi = F.api(F.board(), {"tiles": [[0, 0]], "sink_every": 2})
	F.write(api._board, [Vector3i(0, 0, 0)], 1)
	F.write(api._board, [Vector3i(0, 1, 0)], 2)
	var rule := QuicksandRule.new()
	F.handle(rule, &"on_level_start", api)
	api.take_events()
	F.handle(rule, &"on_lock", api)
	assert_bool(_has_event(api.take_events(), &"quicksand_warning")).is_true()
	assert_int(_uid_at(api, Vector3i(0, 0, 0))).is_equal(1)
	F.handle(rule, &"on_lock", api)
	assert_int(_uid_at(api, Vector3i(0, 0, 0))).is_equal(2)
	assert_int(api.kind_at(Vector3i(0, 1, 0))).is_equal(0)
	assert_bool(_has_event(api.take_events(), &"quicksand_sink")).is_true()


# --- W14 fever_rush ------------------------------------------------------------------------------

func _fever_params() -> Dictionary:
	return {"window_ms": 1000, "clears_needed": 2, "fever_ms": 2000, "bonus": 10, "gravity_scale": 0.6}


func _clear_at(rule: FeverRushRule, api: RuleApi, ms: int, total: int) -> void:
	api.set_time(ms)
	F.handle(rule, &"on_lock", api, {"clear_count": total - 1})
	F.handle(rule, &"on_clear", api, {"clear_count": total})


func test_fever_rush_starts_fever_on_quick_clears_and_scores_bonus() -> void:
	var api: RuleApi = F.api(F.board(), _fever_params())
	var rule := FeverRushRule.new()
	_clear_at(rule, api, 0, 1)
	assert_int(rule.snapshot().combo).is_equal(1)
	_clear_at(rule, api, 500, 2)
	var requests: Array[Dictionary] = api.take_requests()
	assert_bool(rule.snapshot().fever).is_true()
	assert_float(_modifier_value(requests)).is_equal_approx(0.6, 0.0001)
	assert_int(_request(requests, &"score").points).is_equal(10)
	assert_bool(_has_event(api.take_events(), &"fever_start")).is_true()


func test_fever_rush_slow_clear_restarts_combo() -> void:
	var api: RuleApi = F.api(F.board(), _fever_params())
	var rule := FeverRushRule.new()
	_clear_at(rule, api, 0, 1)
	_clear_at(rule, api, 1500, 2)
	assert_int(rule.snapshot().combo).is_equal(1)
	assert_bool(rule.snapshot().fever).is_false()


func test_fever_rush_ends_after_fever_duration() -> void:
	var api: RuleApi = F.api(F.board(), _fever_params())
	var rule := FeverRushRule.new()
	_clear_at(rule, api, 0, 1)
	_clear_at(rule, api, 500, 2)
	api.take_requests()
	api.take_events()
	api.set_time(2600)
	F.handle(rule, &"on_tick", api)
	assert_bool(rule.snapshot().fever).is_false()
	assert_bool(_request(api.take_requests(), &"modifiers").modifiers.is_empty()).is_true()
	assert_bool(_has_event(api.take_events(), &"fever_end")).is_true()


# --- W15 golden_row ------------------------------------------------------------------------------

func test_golden_row_pays_bonus_once_per_clear_and_moves_up() -> void:
	var api: RuleApi = _coin_api({"start_layer": 1, "bonus": 200})
	var rule := GoldenRowRule.new()
	F.handle(rule, &"on_level_start", api)
	assert_int(_event(api.take_events(), &"gold_layer").layer).is_equal(1)
	F.handle(rule, &"on_clear", api, {"layer": 0, "clear_count": 1})
	assert_int(rule.snapshot().gold).is_equal(1)
	F.handle(rule, &"on_clear", api, {"layer": 1, "clear_count": 2})
	F.handle(rule, &"on_clear", api, {"layer": 1, "clear_count": 2})
	assert_int(_request(api.take_requests(), &"score").points).is_equal(200)
	assert_int(rule.snapshot().gold).is_equal(2)
	assert_int(api.goal_counter(&"gold")).is_equal(1)
	assert_bool(_has_event(api.take_events(), &"gold_cleared")).is_true()


func test_golden_row_wraps_to_start_layer_past_top() -> void:
	var api: RuleApi = _coin_api({"start_layer": 1})
	var rule := GoldenRowRule.new()
	rule._gold = api.limit_layer() - 2
	F.handle(rule, &"on_clear", api, {"layer": rule._gold, "clear_count": 1})
	assert_int(rule.snapshot().gold).is_equal(1)


# --- registry, catalog and determinism -----------------------------------------------------------

func test_all_wave3_plugins_are_registered_with_rule_json() -> void:
	var registry := PluginRegistry.new(ProjectSettings.get_global_class_list())
	var ids: PackedStringArray = registry.ids(&"RuleBehaviour")
	for id: StringName in WAVE3_IDS:
		assert_bool(ids.has(String(id))).is_true()
		var def: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/rules/%s.json" % id))
		assert_that(def.id).is_equal(String(id))
		assert_that(def.behaviour).is_equal(String(id))
		assert_int(int(def.schema)).is_equal(1)
		assert_bool(def.layer in ["twist", "mechanic"]).is_true()
	assert_bool(registry.errors().is_empty()).is_true()


func _script(rule: RuleBehaviour, api: RuleApi) -> Dictionary:
	var cells: Array[Vector3i] = [Vector3i(0, 0, 0)]
	F.handle(rule, &"on_level_start", api)
	_piece_at(api, Vector3i(0, 4, 0))
	F.handle(rule, &"on_spawn", api, {"uid": 1, "shape_id": &"mono"})
	for step: int in 6:
		api.set_time(step * 1500)
		F.handle(rule, &"on_tick", api)
		F.handle(rule, &"on_lock", api, {"cells": cells, "uid": 1, "shape_id": &"mono", "clear_count": step})
		F.handle(rule, &"on_clear", api, {"layer": step % 3, "clear_count": step + 1})
		F.handle(rule, &"on_resolve_end", api, {"cleared": 1})
	return rule.snapshot()


func _fresh_rule(id: StringName) -> RuleBehaviour:
	return PluginRegistry.new(ProjectSettings.get_global_class_list()).create(&"RuleBehaviour", id) as RuleBehaviour


func test_wave3_snapshots_are_deterministic_for_same_seed() -> void:
	for id: StringName in WAVE3_IDS:
		var board_a: BoardState = F.board()
		var board_b: BoardState = F.board()
		F.write(board_a, [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(1, 1, 0)])
		F.write(board_b, [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(1, 1, 0)])
		var api_a: RuleApi = F.api(board_a, {}, 7)
		var api_b: RuleApi = F.api(board_b, {}, 7)
		api_a.bind_goal(GoalState.new(), {})
		api_b.bind_goal(GoalState.new(), {})
		var first: Dictionary = _script(_fresh_rule(id), api_a)
		var second: Dictionary = _script(_fresh_rule(id), api_b)
		assert_that(var_to_bytes(first)).override_failure_message("snapshot differs for %s" % id).is_equal(var_to_bytes(second))
		assert_that(api_a.rng_state()).is_equal(api_b.rng_state())


func test_wave3_snapshot_changes_when_counter_changes() -> void:
	var api: RuleApi = F.api(F.board(), {"every": 5})
	for id: StringName in [&"jumbled_queue", &"echo_drop", &"mystery_piece", &"anvil_drop"]:
		var rule: RuleBehaviour = _fresh_rule(id)
		var before: Dictionary = rule.snapshot().duplicate(true)
		F.handle(rule, &"on_spawn" if id in [&"mystery_piece", &"anvil_drop"] else &"on_lock", api, {"shape_id": &"mono"})
		assert_bool(rule.snapshot() != before).override_failure_message("snapshot unchanged for %s" % id).is_true()
