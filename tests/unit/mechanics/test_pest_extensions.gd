extends GdUnitTestSuite
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const Pest := preload("res://src/mechanics/behaviour/pest.gd")

func test_tickle_moves_twice_next_lock_then_consumes_bonus() -> void:
	var board: BoardState = F.board(6, 4, 4)
	var api: RuleApi = F.api(board, {"ant_every_locks": 3})
	F.write(board, [Vector3i(1, 0, 1)], 91, api.kind_of(&"pest"))
	F.write(board, [Vector3i(2, 0, 1), Vector3i(3, 0, 1), Vector3i(4, 0, 1)])
	api.set_status(Vector3i(1, 0, 1), {"extra_acts": 1, "custom": 7})
	api.flush_writes()
	var rule := Pest.new()
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(3, 0, 1))).is_equal(api.kind_of(&"pest"))
	assert_int(api.kind_at(Vector3i(2, 0, 1))).is_zero()
	assert_int(int(api.record_at(Vector3i(3, 0, 1))["piece_instance_id"])).is_equal(91)
	assert_bool(api.record_at(Vector3i(3, 0, 1))["status"].has("extra_acts")).is_false()
	assert_int(int(api.record_at(Vector3i(3, 0, 1))["status"]["custom"])).is_equal(7)
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(4, 0, 1))).is_equal(api.kind_of(&"block"))

func test_rim_escape_counts_only_when_worm_reaches_rim_with_food() -> void:
	var board: BoardState = F.board(4, 4, 4)
	var api: RuleApi = F.api(board, {"ant_every_locks": 1, "rim_escape": true})
	var goal := GoalState.new()
	api.bind_goal(goal, {})
	F.write(board, [Vector3i(1, 0, 1)], 91, api.kind_of(&"pest"))
	F.write(board, [Vector3i(0, 0, 1)])
	var rule := Pest.new()
	F.handle(rule, &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(0, 0, 1))).is_zero()
	assert_int(api.kind_at(Vector3i(1, 0, 1))).is_zero()
	assert_int(int(rule.snapshot()["escaped"])).is_equal(1)
	assert_int(api.goal_counter(&"worms_escaped")).is_equal(1)

func test_ordinary_pest_retains_rim_when_escape_disabled() -> void:
	var board: BoardState = F.board(4, 4, 4)
	var api: RuleApi = F.api(board, {"ant_every_locks": 1})
	F.write(board, [Vector3i(1, 0, 1)], 91, api.kind_of(&"pest"))
	F.write(board, [Vector3i(0, 0, 1)])
	F.handle(Pest.new(), &"on_resolve_end", api)
	assert_int(api.kind_at(Vector3i(0, 0, 1))).is_equal(api.kind_of(&"pest"))

func test_tickle_is_deterministic_under_same_seed() -> void:
	var positions: Array[Vector3i] = []
	var states: Array[int] = []
	for _repeat: int in 2:
		var board: BoardState = F.board(6, 5, 4)
		var api: RuleApi = F.api(board, {"ant_every_locks": 1}, 8123)
		F.write(board, [Vector3i(2, 0, 2)], 91, api.kind_of(&"pest"))
		F.write(board, [Vector3i(1, 0, 2), Vector3i(3, 0, 2), Vector3i(1, 0, 1), Vector3i(3, 0, 1)])
		api.set_status(Vector3i(2, 0, 2), {"extra_acts": 1})
		api.flush_writes()
		F.handle(Pest.new(), &"on_resolve_end", api)
		positions.append(MechanicsCells.occupied(api, api.kind_of(&"pest"))[0])
		states.append(api.rng().state)
	assert_vector(positions[0]).is_equal(positions[1])
	assert_int(states[0]).is_equal(states[1])
