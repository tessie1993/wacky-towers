extends GdUnitTestSuite
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")


func test_sprout_grows_at_four_locks_and_respects_cap() -> void:
	var board: BoardState = F.board()
	board.place(board.index(Vector3i(1, 0, 1)), 4, 0, 0)
	var api: RuleApi = F.api(board, {"grow_locks": 4, "grow_max": 1})
	var rule := SproutsRule.new()
	F.handle(rule, &"on_level_start", api)
	for _lock: int in 3:
		F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(1, 1, 1))).is_equal(0)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(1, 1, 1))).is_equal(4)
	for _lock: int in 8:
		F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(1, 2, 1))).is_equal(0)


func test_uncapped_sprout_survives_clearing_its_original_root() -> void:
	var board: BoardState = F.board()
	board.place(board.index(Vector3i(1, 0, 1)), 4, 0, 0)
	var api: RuleApi = F.api(board, {"grow_locks": 2, "grow_max": 0})
	var rule := SproutsRule.new()
	F.handle(rule, &"on_level_start", api)
	for _lock: int in 2:
		F.handle(rule, &"on_resolve_end", api)
	board.remove(board.index(Vector3i(1, 0, 1)), BoardState.Cause.CLEAR)
	for _lock: int in 2:
		F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(1, 2, 1))).is_equal(4)


func test_capped_sprout_retries_on_next_growth_cycle() -> void:
	var board: BoardState = F.board()
	board.place(board.index(Vector3i(1, 0, 1)), 4, 0, 0)
	board.place(board.index(Vector3i(1, 1, 1)), 1, 0, 1)
	var api: RuleApi = F.api(board, {"grow_locks": 2, "grow_max": 1})
	var rule := SproutsRule.new()
	F.handle(rule, &"on_level_start", api)
	for _lock: int in 2:
		F.handle(rule, &"on_resolve_end", api)
	board.remove(board.index(Vector3i(1, 1, 1)), BoardState.Cause.CLEAR)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(1, 1, 1))).is_equal(0)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(1, 1, 1))).is_equal(4)


func test_egg_hatches_at_six_locks_to_first_lowest_column() -> void:
	var board: BoardState = F.board()
	board.place(board.index(Vector3i(1, 0, 1)), 5, 0, 0)
	var api: RuleApi = F.api(board, {"hatch_locks": 6})
	var rule := HatchingEggsRule.new()
	for _lock: int in 5:
		F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(1, 0, 1))).is_equal(5)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(1, 0, 1))).is_equal(0)
	assert_int(api.kind_at(Vector3i(2, 0, 1))).is_equal(6)


func test_egg_hop_drops_to_lowest_reachable_cell() -> void:
	var board: BoardState = F.board()
	board.place(board.index(Vector3i(1, 3, 1)), 5, 0, 0)
	board.place(board.index(Vector3i(2, 1, 1)), 1, 0, 1)
	var api: RuleApi = F.api(board, {"hatch_locks": 1})
	F.handle(HatchingEggsRule.new(), &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(0, 0, 1))).is_equal(6)


func test_belt_wrap_is_simultaneous_and_preserves_status() -> void:
	var board: BoardState = F.board(3, 2, 5)
	board.place(board.index(Vector3i(0, 0, 0)), 4, 2, 11)
	board.place(board.index(Vector3i(1, 0, 0)), 5, 3, 12)
	board.place(board.index(Vector3i(2, 0, 0)), 6, 4, 13)
	board.set_status(board.index(Vector3i(2, 0, 0)), {"status_id": 21, "counter": 5})
	var api: RuleApi = F.api(board, {"conveyor_every": 2, "conveyor_dir": "+x", "conveyor_wrap": true})
	var rule := MillBeltRule.new()
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(0, 0, 0))).is_equal(4)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(0, 0, 0))).is_equal(6)
	assert_int(api.kind_at(Vector3i(1, 0, 0))).is_equal(4)
	assert_int(api.kind_at(Vector3i(2, 0, 0))).is_equal(5)
	assert_int(api.record_at(Vector3i(0, 0, 0))["status"]["counter"]).is_equal(5)


func test_puff_balanced_cut_and_virtual_half_settlement() -> void:
	var board: BoardState = F.board(4, 2, 6)
	F.write(board, [Vector3i(0, 0, 0), Vector3i(0, 1, 0)], 9)
	var cells: Array[Vector3i] = [Vector3i(0, 2, 0), Vector3i(1, 2, 0), Vector3i(2, 2, 0), Vector3i(3, 2, 0)]
	F.write(board, cells, 10)
	var cut: Dictionary = DandelionPuffRule.choose_cut(cells, Vector3i.DOWN, 77)
	assert_int(cut["plane"]).is_equal(1)
	var api: RuleApi = F.api(board)
	var rule := DandelionPuffRule.new()
	F.handle(rule, &"on_spawn", api, {"tags": PackedStringArray(["dandelion_puff"])})
	F.handle(rule, &"on_lock", api, {"cells": cells, "uid": 10})
	assert_int(api.kind_at(Vector3i(0, 2, 0))).is_equal(1)
	assert_int(api.kind_at(Vector3i(2, 0, 0))).is_equal(1)
	assert_int(api.kind_at(Vector3i(3, 0, 0))).is_equal(1)
	assert_int(api.kind_at(Vector3i(2, 2, 0))).is_equal(0)


func test_wobble_popoff_and_meter_reset() -> void:
	var board: BoardState = F.board(5, 5, 6)
	var cells: Array[Vector3i] = [Vector3i(4, 2, 2), Vector3i(4, 3, 2)]
	F.write(board, cells, 10)
	var api: RuleApi = F.api(board, {"wobble_max": 1})
	var rule := WobbleRule.new()
	F.handle(rule, &"on_lock", api, {"cells": cells, "uid": 10})
	assert_int(rule.snapshot()["meter"]).is_equal(1)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(rule.snapshot()["meter"]).is_equal(0)
	assert_int(MechanicsCells.occupied(api).size()).is_equal(0)
	assert_bool(api.take_events().any(func(event: Dictionary) -> bool: return event["kind"] == &"wobble_popoff")).is_true()


func test_fog_starts_at_spawn_reveals_on_clear_then_fades() -> void:
	var api: RuleApi = F.api(F.board(), {"visible_ms": 5000, "fade_ms": 1000, "invisible_alpha": 0.1, "reveal_ms": 600})
	var rule := FogRule.new()
	api.set_time(3000)
	F.handle(rule, &"on_spawn", api)
	api.set_time(9000)
	F.handle(rule, &"on_tick", api)
	assert_int(rule.snapshot()["alpha_milli"]).is_equal(100)
	F.handle(rule, &"on_clear", api)
	assert_int(rule.snapshot()["alpha_milli"]).is_equal(1000)
	api.set_time(9600)
	F.handle(rule, &"on_tick", api)
	assert_int(rule.snapshot()["alpha_milli"]).is_equal(100)


func test_seeded_gust_schedule_replays_exactly() -> void:
	var a: RuleApi = F.api(F.board(), {}, 123)
	var b: RuleApi = F.api(F.board(), {}, 123)
	var ra := GustRule.new()
	var rb := GustRule.new()
	F.handle(ra, &"on_spawn", a)
	F.handle(rb, &"on_spawn", b)
	assert_that(ra.snapshot()).is_equal(rb.snapshot())
	for ms: int in [10000, 20000, 30000]:
		a.set_time(ms)
		b.set_time(ms)
		F.handle(ra, &"on_tick", a)
		F.handle(rb, &"on_tick", b)
		assert_that(ra.snapshot()).is_equal(rb.snapshot())


func test_layers_only_flip_requests_one_structural_flip() -> void:
	var api: RuleApi = F.api(F.board(), {"flip_every_ms": 0, "flip_every_layers": 2})
	var rule := TopsyTumbleRule.new()
	F.handle(rule, &"on_spawn", api, {"clear_count": 0})
	F.handle(rule, &"on_clear", api, {"clear_count": 2})
	var requests: Array[Dictionary] = api.take_requests()
	assert_int(requests.filter(func(request: Dictionary) -> bool: return request["op"] == &"stack_flip").size()).is_equal(1)
	F.handle(rule, &"on_clear", api, {"clear_count": 2})
	assert_int(api.take_requests().size()).is_equal(0)
