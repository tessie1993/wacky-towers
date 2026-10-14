extends GdUnitTestSuite
## G8 moving platform sim core: data, determinism, timing, lean and topple, cargo states, arch, clock, restart.
const T := preload("res://tests/unit/track/track_fixture.gd")
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")


func test_shipped_tracks_are_valid_and_winnable() -> void:
	for id: String in ["meadow_brook_run", "meadow_kite_day"]:
		var def: TrackDef = TrackDef.load_file("res://assets/data/tracks/%s.json" % id)
		assert_array(def.errors).is_empty()
		assert_bool(def.base_duration_ms() <= def.time_limit_ms).is_true()
	assert_int(TrackDef.load_file("res://assets/data/tracks/meadow_brook_run.json").base_duration_ms()).is_between(120000, 180000)


func test_preview_rows_carry_time_and_safe_height() -> void:
	var def: TrackDef = T.def([{"kind": "arch", "at_mm": 3000, "gap_layers": 6}, {"kind": "bump", "at_mm": 2000, "force": 2, "dir": "+x"}],
		[{"id": "p", "at_mm": 2500}])
	var rows: Array[Dictionary] = def.preview(1000)
	assert_array(T.kinds(rows)).is_equal([&"bump", &"checkpoint", &"arch"])
	assert_int(int(rows[0]["ahead_ms"])).is_equal(1000)
	assert_int(int(rows[0]["impulse_pm"])).is_equal(240)
	assert_int(int(rows[2]["safe_height_layers"])).is_equal(5)


func test_validation_rejects_missing_and_bad_params() -> void:
	assert_bool(T.def([{"kind": "arch", "at_mm": 100}]).is_valid()).is_false()  # no gap_layers
	assert_bool(T.def([{"kind": "crosswind", "at_mm": 100, "dir": "up", "strength": 1}]).is_valid()).is_false()
	assert_bool(T.def([{"kind": "tornado", "at_mm": 100}]).is_valid()).is_false()
	assert_bool(T.def([], [], {"time_limit_ms": 5000}).is_valid()).is_false()  # shorter than the drive
	assert_bool(T.def([], [], {"cargo": {"height_layers": 1}}).is_valid()).is_false()  # merge keeps keys, so test a bare dict
	var bare: Dictionary = T.dict()
	bare["cargo"] = {"height_layers": 1}
	assert_bool(TrackDef.from_dict(bare).is_valid()).is_false()


func test_event_fires_on_the_tick_the_platform_reaches_it() -> void:
	var api: RuleApi = F.api(T.board())
	var runner := TrackRunner.new(T.def([{"kind": "updraft", "at_mm": 2000, "duration_ms": 500}]))
	var out: Array[Dictionary] = T.run(runner, api, 5000)
	var ev: Array[Dictionary] = out.filter(func(r: Dictionary) -> bool: return r["kind"] == TrackRunner.EV_EVENT)
	assert_int(ev.size()).is_equal(1)
	assert_int(int(ev[0]["tick"])).is_equal(40)


func test_same_run_gives_the_same_result_whatever_the_step_size() -> void:
	var events: Array = [{"kind": "bump", "at_mm": 1000, "force": 2, "dir": "+x"}, {"kind": "crosswind", "at_mm": 3000, "dir": "+x", "strength": 2}]
	var results: Array = []
	for dt: int in [50, 10, 33]:
		var board: BoardState = T.board({Vector2i(3, 1): 4})
		var api: RuleApi = F.api(board)
		var runner := TrackRunner.new(T.def(events))
		var out: Array[Dictionary] = T.run(runner, api, 6600, dt)
		results.append([T.count(board), runner.position_mm(), T.kinds(out), runner.lean_pm()])
	assert_array(results[1]).is_equal(results[0])
	assert_array(results[2]).is_equal(results[0])


func test_lean_is_centre_of_mass_and_building_on_the_light_side_rights_it() -> void:
	var board: BoardState = T.board({Vector2i(3, 1): 2})
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(T.def())
	T.run(runner, api, 100)
	assert_int(runner.lean_pm()).is_equal(750)  # 3/4 of the way to the +x edge
	for y: int in 2:
		board.place(board.index(Vector3i(0, y, 1)), 1, 0, 2)
	T.run(runner, api, 100)
	assert_int(runner.lean_pm()).is_less(750)
	assert_int(runner.lean_pm()).is_equal(250)  # (3 + 3 - 3 - 3... cells at x=3 and x=0) -> 0 shifted by two cells


func test_bump_pushes_the_heavy_side_past_the_limit_and_the_top_spills() -> void:
	var board: BoardState = T.board({Vector2i(3, 1): 4})
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(T.def([{"kind": "bump", "at_mm": 500, "force": 2, "dir": "-x"}]))
	var out: Array[Dictionary] = T.run(runner, api, 1200)
	assert_array(T.kinds(out)).contains([TrackRunner.EV_LEAN_WARNING, TrackRunner.EV_TOPPLE])
	assert_int(T.count(board)).is_equal(2)  # spill_cells = 2 removed, the top ones
	assert_int(board.get_kind(board.index(Vector3i(3, 3, 1)))).is_equal(0)
	assert_int(board.get_kind(board.index(Vector3i(3, 0, 1)))).is_equal(1)


func test_a_centred_flat_stack_never_topples() -> void:
	var board: BoardState = T.board(T.flat(2))
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(T.def([{"kind": "bump", "at_mm": 500, "force": 1, "dir": "+x"}]))
	var out: Array[Dictionary] = T.run(runner, api, 1500)
	assert_bool(T.kinds(out).has(TrackRunner.EV_TOPPLE)).is_false()


func test_crosswind_scales_with_stack_height() -> void:
	var impulses: Array = []
	for layers: int in [1, 4]:
		var api: RuleApi = F.api(T.board(T.flat(layers)))
		var runner := TrackRunner.new(T.def([{"kind": "crosswind", "at_mm": 100, "dir": "+x", "strength": 2}]))
		var out: Array[Dictionary] = T.run(runner, api, 300)
		var ev: Dictionary = out.filter(func(r: Dictionary) -> bool: return r["kind"] == TrackRunner.EV_EVENT)[0]
		impulses.append((ev["impulse"] as Vector2i).x)
	assert_array(impulses).is_equal([60, 240])


func test_updraft_lifts_tall_light_builds_and_gust_punishes_tall_heavy() -> void:
	var tall_light: RuleApi = F.api(T.board({Vector2i(1, 1): 6}))
	var flat_heavy: RuleApi = F.api(T.board(T.flat(6)))
	var lifts: Array = []
	var gusts: Array = []
	for api: RuleApi in [tall_light, flat_heavy]:
		var up := TrackRunner.new(T.def([{"kind": "updraft", "at_mm": 100, "duration_ms": 1000}]))
		var rec: Array[Dictionary] = T.run(up, api, 300)
		lifts.append(int(rec.filter(func(r: Dictionary) -> bool: return r["kind"] == TrackRunner.EV_EVENT)[0]["lift_pct"]))
		var gu := TrackRunner.new(T.def([{"kind": "gust", "at_mm": 100, "dir": "+z", "strength": 1}]))
		var g: Array[Dictionary] = T.run(gu, api, 300)
		gusts.append((g.filter(func(r: Dictionary) -> bool: return r["kind"] == TrackRunner.EV_EVENT)[0]["impulse"] as Vector2i).y)
	assert_int(lifts[0]).is_greater(lifts[1])  # 1 column x6: 10+72-6 = 76; 9 columns x6: 10+72-54 = 28
	assert_int(gusts[1]).is_greater(gusts[0])  # 6*54*60/100 = 194 versus 6*6*60/100 = 21


func test_arch_takes_the_cargo_only_when_the_stack_is_too_tall() -> void:
	for pair: Array in [[2, false], [3, true]]:
		var api: RuleApi = F.api(T.board(T.flat(int(pair[0]))))
		var runner := TrackRunner.new(T.def([{"kind": "arch", "at_mm": 500, "gap_layers": 3}]))
		var out: Array[Dictionary] = T.run(runner, api, 1000)
		assert_bool(T.kinds(out).has(TrackRunner.EV_CARGO_LOST)).is_equal(bool(pair[1]))


func test_unstable_seat_warns_wobble_then_slip_before_the_cargo_falls() -> void:
	var api: RuleApi = F.api(T.board({Vector2i(1, 1): 4}))  # a lone tower: 1 of 9 footprint columns
	var runner := TrackRunner.new(T.def())
	var out: Array[Dictionary] = T.run(runner, api, 9000)
	var names: Array = out.filter(func(r: Dictionary) -> bool: return r["kind"] == TrackRunner.EV_CARGO_STATE).map(func(r: Dictionary) -> StringName: return r["name"])
	assert_array(names.slice(0, 2)).is_equal([&"wobble", &"slip"])
	var order: Array = T.kinds(out)
	assert_bool(order.find(TrackRunner.EV_CARGO_STATE) < order.find(TrackRunner.EV_CARGO_LOST)).is_true()


func test_building_a_level_seat_during_the_warning_saves_the_cargo() -> void:
	var board: BoardState = T.board({Vector2i(1, 1): 4})
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(T.def())
	T.run(runner, api, 3500)
	assert_int(int(runner.cargo_state()["state"])).is_greater_equal(TrackRunner.CARGO_WOBBLE)
	for col: Vector2i in T.flat(4):
		for y: int in 4:
			if board.get_kind(board.index(Vector3i(col.x, y, col.y))) == 0:
				board.place(board.index(Vector3i(col.x, y, col.y)), 1, 0, 3)
	var out: Array[Dictionary] = T.run(runner, api, 4000)
	assert_bool(T.kinds(out).has(TrackRunner.EV_CARGO_LOST)).is_false()
	assert_int(int(runner.cargo_state()["state"])).is_equal(TrackRunner.CARGO_STABLE)


func test_a_line_clear_that_drops_the_seat_stresses_the_cargo() -> void:
	var board: BoardState = T.board(T.flat(4))
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(T.def())
	T.run(runner, api, 200)
	for col: Vector2i in T.flat(4):
		board.remove(board.index(Vector3i(col.x, 3, col.y)), BoardState.Cause.CLEAR)
	T.run(runner, api, 100)
	assert_int(int(runner.cargo_state()["stress_pm"])).is_greater_equal(150)


func test_platform_finishes_in_time_with_the_cargo() -> void:
	var runner := TrackRunner.new(T.def())
	var out: Array[Dictionary] = T.run(runner, F.api(T.board()), 11000)
	assert_bool(runner.is_finished()).is_true()
	assert_int(runner.time_left_ms()).is_equal(2000)
	assert_array(T.kinds(out)).is_equal([TrackRunner.EV_FINISHED])


func test_running_out_of_time_loses_the_race() -> void:
	var over: Dictionary = {"time_limit_ms": 10000, "restart_penalty_ms": 5000}
	var runner := TrackRunner.new(T.def([], [], over))
	var api: RuleApi = F.api(T.board({Vector2i(1, 1): 4}))  # the tower loses the cargo near 7 s; the penalty ends the clock
	var out: Array[Dictionary] = T.run(runner, api, 12000)
	assert_bool(runner.is_failed()).is_true()
	assert_str(String(runner.fail_reason())).is_equal("time_up")
	assert_bool(T.kinds(out).has(TrackRunner.EV_TIME_UP)).is_true()


func test_restart_returns_to_the_post_wipes_blocks_and_replays_later_events() -> void:
	var board: BoardState = T.board(T.flat(4))
	var api: RuleApi = F.api(board)
	var def: TrackDef = T.def([{"kind": "arch", "at_mm": 6000, "gap_layers": 3}, {"kind": "updraft", "at_mm": 4000, "duration_ms": 100}],
		[{"id": "post_a", "at_mm": 3000}])
	var runner := TrackRunner.new(def)
	var out: Array[Dictionary] = T.run(runner, api, 6500)
	assert_array(T.kinds(out)).contains([TrackRunner.EV_CHECKPOINT, TrackRunner.EV_CARGO_LOST, TrackRunner.EV_RESTART])
	assert_int(runner.attempts()).is_equal(2)
	assert_int(T.count(board)).is_equal(0)
	assert_int(runner.snapshot()["best_pm"]).is_greater_equal(600)  # progress never goes backwards
	var again: Array[Dictionary] = T.run(runner, api, 1500)
	assert_bool(again.any(func(r: Dictionary) -> bool: return r.get("event", &"") == TrackDef.KIND_UPDRAFT)).is_true()


func test_fail_mode_asks_the_session_to_fail() -> void:
	var api: RuleApi = F.api(T.board(T.flat(4)))
	var runner := TrackRunner.new(T.def([{"kind": "arch", "at_mm": 500, "gap_layers": 3}], [], {"on_loss": "fail"}))
	T.run(runner, api, 1000)
	assert_bool(runner.is_failed()).is_true()
	assert_bool(api.take_requests().any(func(r: Dictionary) -> bool: return r["op"] == &"fail")).is_true()


func test_a_restored_runner_continues_identically() -> void:
	var events: Array = [{"kind": "updraft", "at_mm": 3000, "duration_ms": 2000}, {"kind": "cloud_bump", "at_mm": 5000, "force": 1, "dir": "+z"}]
	var a := TrackRunner.new(T.def(events))
	var api_a: RuleApi = F.api(T.board())
	T.run(a, api_a, 2000)
	var snap: Dictionary = a.snapshot()
	var b := TrackRunner.new(T.def(events))
	b.restore(snap)
	var out_a: Array[Dictionary] = T.run(a, api_a, 6000)
	var out_b: Array[Dictionary] = T.run(b, F.api(T.board()), 6000)
	assert_array(out_b).is_equal(out_a)
	assert_dict(b.snapshot()).is_equal(a.snapshot())


func test_path_point_follows_arc_length() -> void:
	var def: TrackDef = T.def([], [], {"path": [[0, 0, 0], [0, 0, -10], [10, 0, -10]]})
	assert_vector(def.path_point(5000)).is_equal(Vector3(0, 0, -10))
	assert_vector(def.path_point(10000)).is_equal(Vector3(10, 0, -10))
