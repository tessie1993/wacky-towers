extends GdUnitTestSuite
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const Lava := preload("res://src/mechanics/lava/lava_rise.gd")
const Lid := preload("res://src/mechanics/lava/lava_lid.gd")
const Quake := preload("res://src/mechanics/lava/quake.gd")
const Rocks := preload("res://src/mechanics/lava/lava_rock_spawn.gd")
const Locked := preload("res://src/mechanics/lava/locked_cube.gd")
const Geometry := preload("res://src/mechanics/lava/rock_obstacle.gd")
const Shelf := preload("res://src/mechanics/forest/anchored_shelf.gd")
const Vines := preload("res://src/mechanics/forest/vines.gd")
const Heist := preload("res://src/mechanics/forest/squirrel_heist.gd")
const Crab := preload("res://src/mechanics/underwater/crab_claw.gd")

func _structures(api: RuleApi, board: BoardState) -> void:
	for request: Dictionary in api.take_requests():
		if request.op == &"floor": board.set_floor(int(request.layer))
		elif request.op == &"height": board.set_height_limit(int(request.height))

func _event(api: RuleApi, name: StringName) -> Dictionary:
	for event: Dictionary in api.take_events():
		if event.kind == name: return event.data
	return {}

func test_lava_warns_then_masks_only_on_resolution_without_collapse() -> void:
	var board: BoardState = F.board(2, 2, 6)
	F.write(board, [Vector3i(0, 0, 0), Vector3i(0, 2, 0)], 7)
	var api: RuleApi = F.api(board, {"first_s": 5, "melt_every_s": 5, "melt_warn_ms": 3000, "melt_max": 1})
	var rule := Lava.new()
	F.handle(rule, &"on_level_start", api)
	api.set_time(2000)
	F.handle(rule, &"on_tick", api)
	assert_int(int(_event(api, &"lava_warning").get("layer", -1))).is_equal(0)
	api.set_time(5000)
	F.handle(rule, &"on_tick", api)
	assert_int(api.kind_at(Vector3i(0, 0, 0))).is_equal(1)
	F.handle(rule, &"on_resolve_end", api)
	_structures(api, board)
	assert_bool(api.is_active(Vector3i(0, 0, 0))).is_false()
	assert_int(api.kind_at(Vector3i(0, 0, 0))).is_equal(0)
	assert_int(api.kind_at(Vector3i(0, 2, 0))).is_equal(1)
	assert_int(board.limit_layer()).is_equal(6)
	assert_bool(rule.snapshot().cooled).is_true()
	api.set_time(999999)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.take_requests().size()).is_equal(0)

func test_quake_caps_highest_fixed_cohort_and_does_not_chain() -> void:
	var board: BoardState = F.board()
	F.write(board, [Vector3i(0, 4, 0), Vector3i(1, 3, 0), Vector3i(2, 2, 0), Vector3i(2, 3, 0)])
	var api: RuleApi = F.api(board, {"first_s": 2, "quake_warn_ms": 1000, "quake_max_cubes": 2})
	var rule := Quake.new()
	F.handle(rule, &"on_level_start", api)
	api.set_time(1000)
	F.handle(rule, &"on_tick", api)
	assert_int(rule.snapshot().targets.size()).is_equal(2)
	api.set_time(2000)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(0, 4, 0))).is_equal(0)
	assert_int(api.kind_at(Vector3i(1, 3, 0))).is_equal(0)
	assert_int(api.kind_at(Vector3i(2, 2, 0))).is_equal(1)
	assert_int(api.kind_at(Vector3i(2, 3, 0))).is_equal(1)

func test_quake_ignores_vines_and_replaced_warning_targets() -> void:
	var board: BoardState = F.board()
	F.write(board, [Vector3i(0, 3, 0), Vector3i(1, 3, 0)], 7)
	board.set_status(board.index(Vector3i(0, 3, 0)), {"vined": true})
	var api: RuleApi = F.api(board, {"first_s": 2, "quake_warn_ms": 1000})
	var rule := Quake.new()
	F.handle(rule, &"on_level_start", api)
	api.set_time(1000)
	F.handle(rule, &"on_tick", api)
	board.place(board.index(Vector3i(1, 3, 0)), 1, 0, 99)
	api.set_time(2000)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(0, 3, 0))).is_equal(1)
	assert_int(api.kind_at(Vector3i(1, 3, 0))).is_equal(1)

func test_quake_gate_uses_cumulative_cleared_layers() -> void:
	var api: RuleApi = F.api(F.board(), {"active_after_clears": 2, "first_s": 2})
	var rule := Quake.new()
	F.handle(rule, &"on_level_start", api)
	assert_int(rule.snapshot().due).is_equal(-1)
	F.handle(rule, &"on_clear", api, {"clear_count": 1})
	assert_int(rule.snapshot().due).is_equal(-1)
	F.handle(rule, &"on_clear", api, {"clear_count": 2})
	assert_int(rule.snapshot().due).is_equal(2000)

func test_vent_warning_never_overwrites_occupied_mark() -> void:
	var board: BoardState = F.board()
	var api: RuleApi = F.api(board, {"every_locks": 2, "object": "SP35", "objects_max": 1})
	var rule := Rocks.new()
	F.handle(rule, &"on_resolve_end", api)
	var target: Vector3i = rule.snapshot().target
	board.place(board.index(target), 1, 0, 4)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(target)).is_equal(1)
	assert_int(MechanicsCells.occupied(api, api.kind_of(&"bounce_pad")).size()).is_equal(0)

func test_vent_spawns_authored_bounce_pad_and_honours_cap() -> void:
	var api: RuleApi = F.api(F.board(), {"every_locks": 2, "object": "SP35", "objects_max": 1})
	var rule := Rocks.new()
	for _lock: int in 8: F.handle(rule, &"on_resolve_end", api)
	assert_int(MechanicsCells.occupied(api, api.kind_of(&"bounce_pad")).size()).is_equal(1)

func test_dynamic_rock_needs_two_distinct_adjacent_clears() -> void:
	var board: BoardState = F.board()
	var api: RuleApi = F.api(board, {"every_locks": 2, "object": "SP19", "objects_max": 1})
	var rule := Rocks.new()
	F.handle(rule, &"on_resolve_end", api)
	var target: Vector3i = rule.snapshot().target
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(target)).is_equal(api.kind_of(&"rock"))
	board.remove(board.index(target), BoardState.Cause.CLEAR)
	assert_int(api.kind_at(target)).is_equal(api.kind_of(&"rock"))
	var origin: Vector3i = target + Vector3i.UP
	F.handle(rule, &"on_clear", api, {"cell": origin, "clear_count": 1})
	F.handle(rule, &"on_clear", api, {"cell": origin, "clear_count": 1})
	assert_int(api.record_at(target).status.hits_left).is_equal(1)
	F.handle(rule, &"on_clear", api, {"cell": origin, "clear_count": 2})
	assert_int(api.kind_at(target)).is_equal(0)

func test_locked_cube_unlocks_only_face_adjacent_and_static_geometry_stays_fixed() -> void:
	var board: BoardState = F.board()
	var api: RuleApi = F.api(board)
	var cell := Vector3i(1, 1, 1)
	board.place(board.index(cell), api.kind_of(&"locked_cube"), 0, 7)
	var rule := Locked.new()
	F.handle(rule, &"on_level_start", api)
	board.remove(board.index(cell), BoardState.Cause.CLEAR)
	assert_int(api.kind_at(cell)).is_equal(api.kind_of(&"locked_cube"))
	F.handle(rule, &"on_clear", api, {"cell": cell + Vector3i(1, 1, 0)})
	assert_bool(api.record_at(cell).status.locked).is_true()
	F.handle(rule, &"on_clear", api, {"cell": cell + Vector3i.UP})
	assert_bool(api.record_at(cell).status.locked).is_false()
	board.remove(board.index(cell), BoardState.Cause.CLEAR)
	assert_int(api.kind_at(cell)).is_equal(0)

func test_static_rock_is_solid_and_excluded_from_active_clear_denominator() -> void:
	var board: BoardState = F.board(2, 2, 5)
	var api: RuleApi = F.api(board)
	var cell := Vector3i(0, 0, 0)
	board.place(board.index(cell), api.kind_of(&"rock"), 0, 0)
	F.handle(Geometry.new(), &"on_level_start", api)
	assert_bool(api.is_active(cell)).is_false()
	assert_bool(api.is_free(cell)).is_false()
	assert_int(board.active_in_layer(0)).is_equal(3)
	for other: Vector3i in [Vector3i(0, 0, 1), Vector3i(1, 0, 0), Vector3i(1, 0, 1)]: board.place(board.index(other), 1, 0, 3)
	assert_bool(board.layer_full(0)).is_true()
	board.remove(board.index(cell), BoardState.Cause.DAMAGE)
	assert_int(api.kind_at(cell)).is_equal(api.kind_of(&"rock"))

func test_shelf_preserves_authored_openings_and_cannot_clear_or_move() -> void:
	var board: BoardState = F.board(2, 2, 5)
	var api: RuleApi = F.api(board, {"cells": [[0, 2, 0], [1, 2, 0]]})
	F.handle(Shelf.new(), &"on_level_start", api)
	var cell := Vector3i(0, 2, 0)
	assert_int(api.kind_at(cell)).is_equal(api.kind_of(&"shelf"))
	assert_bool(api.is_free(Vector3i(0, 2, 1))).is_true()
	api.move_cell(cell, Vector3i(0, 3, 0))
	api.remove_cell(cell, BoardState.Cause.CLEAR)
	api.flush_writes()
	assert_int(api.kind_at(cell)).is_equal(api.kind_of(&"shelf"))
	assert_int(api.kind_at(Vector3i(0, 3, 0))).is_equal(0)

func test_vines_choose_exact_seeded_quota_in_each_real_bag_and_ignore_opening() -> void:
	var api: RuleApi = F.api(F.board(), {"vine_per_bag": 1})
	var rule := Vines.new()
	F.handle(rule, &"on_spawn", api, {"bag_id": -1, "bag_size": 0, "bag_pos": -1})
	assert_bool(rule.snapshot().special).is_false()
	for bag: int in 3:
		var chosen: int = 0
		for position: int in 9:
			F.handle(rule, &"on_spawn", api, {"bag_id": bag, "bag_size": 9, "bag_pos": position})
			if bool(rule.snapshot().special): chosen += 1
		assert_int(chosen).is_equal(1)

func test_vines_protect_only_piece_and_face_neighbours_but_allow_normal_clear() -> void:
	var board: BoardState = F.board()
	var cells: Array[Vector3i] = [Vector3i(1, 1, 1), Vector3i(2, 1, 1), Vector3i(2, 2, 1)]
	F.write(board, cells)
	var api: RuleApi = F.api(board, {"vine_per_bag": 1})
	var rule := Vines.new()
	F.handle(rule, &"on_spawn", api, {"bag_id": 0, "bag_size": 1, "bag_pos": 0})
	F.handle(rule, &"on_lock", api, {"cells": [cells[0]]})
	assert_bool(api.record_at(cells[0]).status.vined).is_true()
	assert_bool(api.record_at(cells[1]).status.vined).is_true()
	assert_bool(api.record_at(cells[2]).status.get("vined", false)).is_false()
	board.remove(board.index(cells[0]), BoardState.Cause.TRIM)
	assert_int(api.kind_at(cells[0])).is_equal(1)
	board.remove(board.index(cells[0]), BoardState.Cause.CLEAR)
	assert_int(api.kind_at(cells[0])).is_equal(0)

func _heist_board() -> BoardState:
	var board: BoardState = F.board(2, 2, 6)
	F.write(board, [Vector3i(0, 1, 0), Vector3i(1, 1, 0), Vector3i(0, 2, 1), Vector3i(1, 2, 1)], 7)
	return board

func test_heist_ties_choose_lowest_layer_and_wait_one_lock() -> void:
	var api: RuleApi = F.api(_heist_board(), {"heist_every_locks": 3, "heist_warn_locks": 1})
	var rule := Heist.new()
	F.handle(rule, &"on_resolve_end", api)
	F.handle(rule, &"on_resolve_end", api)
	var target: Vector3i = rule.snapshot().target
	assert_int(api.layer_of(target)).is_equal(1)
	assert_int(api.kind_at(target)).is_equal(1)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(target)).is_equal(0)

func test_heist_cover_or_target_layer_clear_cancels_warning() -> void:
	for cover: bool in [true, false]:
		var board: BoardState = _heist_board()
		var api: RuleApi = F.api(board, {"heist_every_locks": 3})
		var rule := Heist.new()
		for _lock: int in 2: F.handle(rule, &"on_resolve_end", api)
		var target: Vector3i = rule.snapshot().target
		if cover: board.place(board.index(target + Vector3i.UP), 1, 0, 99)
		else: F.handle(rule, &"on_clear", api, {"layer": api.layer_of(target)})
		F.handle(rule, &"on_resolve_end", api)
		assert_int(api.kind_at(target)).is_equal(1)
		assert_bool(rule.snapshot().marked).is_false()

func test_heist_never_steals_layer_zero_or_last_cube() -> void:
	var board: BoardState = F.board(2, 2, 6)
	F.write(board, [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 1, 1)])
	var api: RuleApi = F.api(board, {"heist_every_locks": 3, "heist_min_fill": 0.0})
	var rule := Heist.new()
	for _lock: int in 9: F.handle(rule, &"on_resolve_end", api)
	assert_int(MechanicsCells.occupied(api).size()).is_equal(3)

func test_crab_activates_after_two_clears_then_steals_only_top_cube() -> void:
	var board: BoardState = F.board()
	F.write(board, [Vector3i(1, 0, 1), Vector3i(1, 1, 1), Vector3i(1, 2, 1)])
	var api: RuleApi = F.api(board, {"claw_every_ms": 2000, "claw_jitter_ms": 0, "claw_warn_ms": 1000})
	var rule := Crab.new()
	F.handle(rule, &"on_level_start", api)
	assert_int(rule.snapshot().due).is_equal(-1)
	F.handle(rule, &"on_clear", api, {"clear_count": 2})
	api.set_time(1000)
	F.handle(rule, &"on_tick", api)
	assert_bool(rule.snapshot().has_target).is_true()
	api.set_time(2000)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(1, 2, 1))).is_equal(0)
	assert_int(api.kind_at(Vector3i(1, 1, 1))).is_equal(1)

func test_crab_any_warning_time_clear_cancels_and_small_stack_is_ignored() -> void:
	var board: BoardState = F.board()
	F.write(board, [Vector3i(1, 0, 1), Vector3i(1, 1, 1), Vector3i(2, 0, 2)])
	var api: RuleApi = F.api(board, {"claw_every_ms": 2000, "claw_jitter_ms": 0, "claw_warn_ms": 1000})
	var rule := Crab.new()
	F.handle(rule, &"on_clear", api, {"clear_count": 2})
	api.set_time(1000)
	F.handle(rule, &"on_tick", api)
	F.handle(rule, &"on_clear", api, {"clear_count": 3})
	api.set_time(2000)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(MechanicsCells.occupied(api).size()).is_equal(3)
	assert_int(rule.snapshot().due).is_equal(3000)

func test_lid_soft_trim_depth_cap_and_per_layer_clear_relief() -> void:
	var board: BoardState = F.board(2, 2, 6)
	F.write(board, [Vector3i(0, 5, 0), Vector3i(0, 4, 0)])
	var api: RuleApi = F.api(board, {"lid_first_s": 2, "lid_every_s": 2, "lid_warn_ms": 1000, "lid_max": 2, "lid_push_per_clear": 1})
	var rule := Lid.new()
	F.handle(rule, &"on_level_start", api)
	for now: int in [2000, 4000, 6000]:
		api.set_time(now)
		F.handle(rule, &"on_resolve_end", api)
		_structures(api, board)
	assert_int(board.limit_layer()).is_equal(4)
	assert_int(MechanicsCells.occupied(api).size()).is_equal(0)
	F.handle(rule, &"on_clear", api, {"clear_count": 1})
	_structures(api, board)
	assert_int(board.limit_layer()).is_equal(5)
	F.handle(rule, &"on_clear", api, {"clear_count": 1})
	_structures(api, board)
	assert_int(board.limit_layer()).is_equal(5)
	F.handle(rule, &"on_clear", api, {"clear_count": 3})
	_structures(api, board)
	assert_int(board.limit_layer()).is_equal(6)

func test_lid_clear_during_warning_cancels_next_drop() -> void:
	var board: BoardState = F.board(2, 2, 6)
	var api: RuleApi = F.api(board, {"lid_first_s": 2, "lid_every_s": 2, "lid_warn_ms": 1000})
	var rule := Lid.new()
	F.handle(rule, &"on_level_start", api)
	api.set_time(1000)
	F.handle(rule, &"on_tick", api)
	assert_bool(rule.snapshot().warned).is_true()
	F.handle(rule, &"on_clear", api, {"clear_count": 1})
	api.set_time(2000)
	F.handle(rule, &"on_resolve_end", api)
	_structures(api, board)
	assert_int(board.limit_layer()).is_equal(6)
