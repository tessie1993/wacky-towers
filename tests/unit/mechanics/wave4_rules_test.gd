extends GdUnitTestSuite
## Wave-4 rules (race_rival, tilt_plate A2, defend_core) against real boards and the real RuleApi.
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const RACE := {"rival_rate": 5.0, "rival_head_start_ms": 0, "rubber_band": 0.0, "rubber_gap_pct": 25, "rival_warn_pct": 80, "progress_emit_ms": 1000}
const TILT := {"slip_threshold": 0.7, "slip_count": 2, "warn_at": 0.7, "slip_after_resolves": 1, "fixed_kinds": ["rock"]}
const DEFEND := {"core": [], "core_hp": 2, "core_damage": 1, "attack_every_ms": 1000, "warn_ms": 200}


func _event(events: Array[Dictionary], kind: StringName) -> Dictionary:
	for e: Dictionary in events:
		if e.kind == kind:
			return e.data
	return {}


func _has_event(events: Array[Dictionary], kind: StringName) -> bool:
	return not _event(events, kind).is_empty() or events.any(func(e: Dictionary) -> bool: return e.kind == kind)


func _request(requests: Array[Dictionary], op: StringName) -> Dictionary:
	for r: Dictionary in requests:
		if r.op == op:
			return r
	return {}


func _race_api(done: int, target: int, params: Dictionary = RACE) -> RuleApi:
	var api: RuleApi = F.api(F.board(), params)
	api.bind_goal_progress(func() -> Dictionary: return {"done": done, "target": target})
	return api


func _tick(rule: RuleBehaviour, api: RuleApi, ms: int) -> void:
	api.set_time(ms)
	F.handle(rule, &"on_tick", api)


# --- race_rival ---------------------------------------------------------------------------------

func test_race_rival_finishing_first_fails_the_level_after_warning() -> void:
	var api: RuleApi = _race_api(2, 10)
	var rule := RaceRivalRule.new()
	F.handle(rule, &"on_level_start", api)
	api.take_events()
	_tick(rule, api, 17000)
	var events: Array[Dictionary] = api.take_events()
	assert_bool(_has_event(events, &"race_rival_warning")).is_true()
	assert_int(int(_event(events, &"race_progress").rival)).is_equal(85)
	assert_int(int(_event(events, &"race_progress").player)).is_equal(20)
	assert_dict(_request(api.take_requests(), &"fail")).is_empty()
	_tick(rule, api, 20000)
	assert_bool(_has_event(api.take_events(), &"race_rival_finished")).is_true()
	assert_that(_request(api.take_requests(), &"fail").get("reason")).is_equal(&"rival_finished")


func test_race_player_finishing_first_never_fails() -> void:
	var api: RuleApi = _race_api(10, 10)
	var rule := RaceRivalRule.new()
	F.handle(rule, &"on_level_start", api)
	_tick(rule, api, 30000)
	assert_bool(_has_event(api.take_events(), &"race_won")).is_true()
	assert_dict(_request(api.take_requests(), &"fail")).is_empty()


func test_race_head_start_and_full_rubber_band_stall_a_leading_rival() -> void:
	var params: Dictionary = RACE.duplicate()
	params["rival_head_start_ms"] = 6000
	params["rubber_band"] = 1.0
	var api: RuleApi = _race_api(0, 10, params)
	var rule := RaceRivalRule.new()
	F.handle(rule, &"on_level_start", api)
	api.take_events()
	_tick(rule, api, 10000)
	assert_int(int(_event(api.take_events(), &"race_progress").rival)).is_equal(30)


# --- tilt_plate ---------------------------------------------------------------------------------

func test_tilt_matches_gdd_worked_example_and_empty_board() -> void:
	var board: BoardState = F.board(5, 1, 8)
	var api: RuleApi = F.api(board, TILT)
	assert_int(int(TiltPlateRule.measure(api.board_size(), MechanicsCells.occupied(api)).tau)).is_equal(0)
	F.write(board, [Vector3i(0, 0, 0), Vector3i(3, 0, 0), Vector3i(4, 0, 0), Vector3i(4, 1, 0)])
	assert_int(int(TiltPlateRule.measure(api.board_size(), MechanicsCells.occupied(api)).tau)).is_equal(375)
	F.write(board, [Vector3i(4, 2, 0), Vector3i(4, 3, 0)])
	assert_int(int(TiltPlateRule.measure(api.board_size(), MechanicsCells.occupied(api)).tau)).is_equal(583)
	F.write(board, [Vector3i(4, 4, 0), Vector3i(4, 5, 0), Vector3i(4, 6, 0)])
	var tilt: Dictionary = TiltPlateRule.measure(api.board_size(), MechanicsCells.occupied(api))
	assert_int(int(tilt.tau)).is_equal(722)
	assert_that(tilt.dir).is_equal(Vector3i(1, 0, 0))


func test_tilt_over_threshold_slides_top_heavy_side_cubes_off() -> void:
	var board: BoardState = F.board(5, 1, 8)
	F.write(board, [Vector3i(0, 0, 0), Vector3i(3, 0, 0)])
	for y: int in 7:
		F.write(board, [Vector3i(4, y, 0)])
	var api: RuleApi = F.api(board, TILT)
	F.handle(TiltPlateRule.new(), &"on_resolve_end", api)
	var events: Array[Dictionary] = api.take_events()
	assert_int(int(_event(events, &"balance").tilt_permille)).is_equal(722)
	assert_bool(_has_event(events, &"balance_warning")).is_true()
	assert_int((_event(events, &"tilt_popoff").cells as Array).size()).is_equal(2)
	assert_int(api.kind_at(Vector3i(4, 6, 0))).is_equal(0)
	assert_int(api.kind_at(Vector3i(4, 5, 0))).is_equal(0)
	assert_int(api.kind_at(Vector3i(4, 4, 0))).is_not_equal(0)
	assert_int(api.kind_at(Vector3i(0, 0, 0))).is_not_equal(0)


func test_tilt_balanced_board_never_slips() -> void:
	var board: BoardState = F.board(5, 1, 8)
	F.write(board, [Vector3i(0, 0, 0), Vector3i(4, 0, 0), Vector3i(0, 1, 0), Vector3i(4, 1, 0)])
	var api: RuleApi = F.api(board, TILT)
	F.handle(TiltPlateRule.new(), &"on_resolve_end", api)
	var events: Array[Dictionary] = api.take_events()
	assert_int(int(_event(events, &"balance").tilt_permille)).is_equal(0)
	assert_bool(_has_event(events, &"tilt_popoff")).is_false()
	assert_int(MechanicsCells.occupied(api).size()).is_equal(4)


# --- defend_core --------------------------------------------------------------------------------

func test_defend_exposed_core_takes_damage_and_fails_at_zero_hp() -> void:
	var api: RuleApi = F.api(F.board(2, 2, 6), DEFEND)
	var rule := DefendCoreRule.new()
	F.handle(rule, &"on_level_start", api)
	api.take_events()
	_tick(rule, api, 799)
	assert_bool(_has_event(api.take_events(), &"defend_warning")).is_false()
	_tick(rule, api, 800)
	assert_bool(_has_event(api.take_events(), &"defend_warning")).is_true()
	_tick(rule, api, 1000)
	var events: Array[Dictionary] = api.take_events()
	assert_that(_event(events, &"defend_hit").result).is_equal(&"core")
	assert_int(int(_event(events, &"defend").hp)).is_equal(1)
	assert_dict(_request(api.take_requests(), &"fail")).is_empty()
	_tick(rule, api, 2000)
	assert_bool(_has_event(api.take_events(), &"defend_core_lost")).is_true()
	assert_that(_request(api.take_requests(), &"fail").get("reason")).is_equal(&"core_destroyed")


func test_defend_armour_absorbs_the_shot_top_cube_first() -> void:
	var board: BoardState = F.board(2, 2, 6)
	for x: int in 2:
		for z: int in 2:
			F.write(board, [Vector3i(x, 0, z), Vector3i(x, 1, z)])
	var api: RuleApi = F.api(board, DEFEND)
	var rule := DefendCoreRule.new()
	F.handle(rule, &"on_level_start", api)
	_tick(rule, api, 1000)
	var hit: Dictionary = _event(api.take_events(), &"defend_hit")
	assert_that(hit.result).is_equal(&"armour")
	assert_int((hit.cell as Vector3i).y).is_equal(1)
	assert_int(int(hit.hp)).is_equal(2)
	assert_int(MechanicsCells.occupied(api).size()).is_equal(7)


func test_defend_default_core_and_seeded_edge_column() -> void:
	var a: RuleApi = F.api(F.board(4, 4, 6), DEFEND, 7)
	var b: RuleApi = F.api(F.board(4, 4, 6), DEFEND, 7)
	var core: Array[Vector2i] = DefendCoreRule.core_tiles(a)
	assert_int(core.size()).is_equal(4)
	assert_bool(core.has(Vector2i(1, 1)) and core.has(Vector2i(2, 2))).is_true()
	var ra := DefendCoreRule.new()
	var rb := DefendCoreRule.new()
	F.handle(ra, &"on_level_start", a)
	F.handle(rb, &"on_level_start", b)
	var column: Vector2i = ra.snapshot()["column"]
	assert_that(column).is_equal(rb.snapshot()["column"])
	assert_bool(column.x == 0 or column.x == 3 or column.y == 0 or column.y == 3).is_true()
