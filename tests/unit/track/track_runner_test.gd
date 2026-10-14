extends GdUnitTestSuite
## G8 moving platform sim core: data, determinism, timing, lean and topple, cargo stages, arch, rings, hearts, stars.
const T := preload("res://tests/unit/track/track_fixture.gd")
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")


func test_shipped_tracks_are_valid() -> void:
	for id: String in ["meadow_brook_run", "meadow_kite_day"]:
		var def: TrackDef = TrackDef.load_file(T.DIR + id + ".json")
		assert_array(def.errors).is_empty()
		assert_int(def.hearts).is_equal(3)
	assert_int(TrackDef.load_file(T.DIR + "meadow_brook_run.json").base_duration_ms()).is_between(120000, 180000)


func test_validation_rejects_bad_data_without_crashing() -> void:
	assert_bool(T.def([{"kind": "arch", "at_mm": 100}]).is_valid()).is_false()  # no gap_layers
	assert_bool(T.def([{"kind": "crosswind", "at_mm": 100, "dir": "up", "strength": 1}]).is_valid()).is_false()
	assert_bool(T.def([{"kind": "tornado", "at_mm": 100}]).is_valid()).is_false()
	assert_bool(T.def([], [], {"tick_ms": 0}).is_valid()).is_false()
	assert_bool(T.def([], [], {"hearts": 0}).is_valid()).is_false()
	assert_bool(T.def([], [], {"effects": 5}).is_valid()).is_false()
	assert_bool(T.def([], [], {"segments": [1, 2]}).is_valid()).is_false()
	assert_bool(T.def([], [], {"lean": {"danger_pm": 900, "limit_pm": 800, "relax_pm_per_s": 1, "dwell_ms": 1, "hysteresis_pm": 1}}).is_valid()).is_false()
	assert_bool(T.def([], [], {"rings": [{"id": "r", "at_mm": 100, "min_pm": 900, "max_pm": 100}]}).is_valid()).is_false()
	var bare: Dictionary = T.dict()
	bare.erase("stars")
	assert_bool(TrackDef.from_dict(bare).is_valid()).is_false()


func test_event_fires_on_the_tick_the_platform_reaches_it() -> void:
	var api: RuleApi = F.api(T.board())
	var runner := TrackRunner.new(T.def([{"kind": "updraft", "at_mm": 2000, "duration_ms": 500}]))
	var ev: Array[Dictionary] = T.of_kind(T.run(runner, api, 5000), TrackRunner.EV_EVENT)
	assert_int(ev.size()).is_equal(1)
	assert_int(int(ev[0]["tick"])).is_equal(40)


func test_same_run_gives_the_same_result_whatever_the_step_size() -> void:
	var events: Array = [{"kind": "bump", "at_mm": 1000, "force": 3, "dir": "+x"}, {"kind": "crosswind", "at_mm": 3000, "dir": "+x", "strength": 2}]
	var results: Array = []
	for dt: int in [50, 10, 40]:
		var board: BoardState = T.board({Vector2i(6, 3): 4})
		var runner := TrackRunner.new(T.def(events))
		var out: Array[Dictionary] = T.run(runner, F.api(board), 8000, dt)
		results.append([T.count(board), runner.position_mm(), T.kinds(out), runner.hearts_left()])
	assert_array(results[1]).is_equal(results[0])
	assert_array(results[2]).is_equal(results[0])


func test_lean_is_centre_of_mass_and_building_on_the_light_side_rights_it() -> void:
	var board: BoardState = T.board({Vector2i(5, 3): 2})
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(T.def())
	T.run(runner, api, 100)
	assert_int(runner.lean_pm()).is_equal(375)  # (2*5+1-8)/8
	for y: int in 2:
		board.place(board.index(Vector3i(2, y, 3)), 1, 0, 2)
	T.run(runner, api, 100)
	assert_int(runner.lean_pm()).is_equal(125)  # x=2 and x=5 cancel; the z=3 row leaves 4 x -1 / 32


func test_a_lopsided_stack_warns_then_topples_after_the_dwell_and_costs_a_heart() -> void:
	var board: BoardState = T.board({Vector2i(7, 3): 3})  # centre of mass 875, past the 800 limit
	var runner := TrackRunner.new(T.def())
	var out: Array[Dictionary] = T.run(runner, F.api(board), 4000)
	var kinds: Array = T.kinds(out)
	assert_array(kinds).contains([TrackRunner.EV_LEAN_WARNING, TrackRunner.EV_TOPPLE_WARNING, TrackRunner.EV_TOPPLE, TrackRunner.EV_HEART_LOST, TrackRunner.EV_RESTART])
	assert_int(int(T.of_kind(out, TrackRunner.EV_TOPPLE)[0]["tick"])).is_greater_equal(50)  # dwell 2500 ms at 50 ms ticks
	assert_int(runner.hearts_left()).is_equal(2)
	assert_int(T.count(board)).is_equal(0)


func test_leaning_back_inside_the_dwell_saves_the_run() -> void:
	var board: BoardState = T.board({Vector2i(7, 3): 3})
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(T.def())
	T.run(runner, api, 1500)
	for y: int in 3:
		for x: int in [0, 1]:
			board.place(board.index(Vector3i(x, y, 3)), 1, 0, 2)
	var out: Array[Dictionary] = T.run(runner, api, 3000)
	assert_bool(T.kinds(out).has(TrackRunner.EV_TOPPLE)).is_false()
	assert_int(runner.hearts_left()).is_equal(3)


func test_a_centred_plateau_never_topples_from_a_capped_bump() -> void:
	var runner := TrackRunner.new(T.def([{"kind": "bump", "at_mm": 500, "force": 3, "dir": "+x"}]))
	var out: Array[Dictionary] = T.run(runner, F.api(T.board(T.plateau(2))), 4000)
	assert_bool(T.kinds(out).has(TrackRunner.EV_TOPPLE_WARNING)).is_false()


func test_crosswind_scales_with_stack_height_and_is_capped() -> void:
	var impulses: Array = []
	for layers: int in [1, 4, 10]:
		var runner := TrackRunner.new(T.def([{"kind": "crosswind", "at_mm": 100, "dir": "+x", "strength": 2}]))
		var out: Array[Dictionary] = T.run(runner, F.api(T.board(T.plateau(layers))), 300)
		impulses.append((T.of_kind(out, TrackRunner.EV_EVENT)[0]["impulse"] as Vector2i).x)
	assert_array(impulses).is_equal([50, 200, 450])  # the last hits impulse_cap_pm


func test_gust_punishes_tall_heavy_builds_and_updraft_lifts_light_ones() -> void:
	var light: Dictionary = T.plateau(1, 2)  # 4 cells
	var heavy: Dictionary = T.plateau(6, 6)  # 216 cells
	var gusts: Array = []
	var lifts: Array = []
	for cols: Dictionary in [light, heavy]:
		var g := TrackRunner.new(T.def([{"kind": "gust", "at_mm": 100, "dir": "+z", "strength": 1}]))
		gusts.append((T.of_kind(T.run(g, F.api(T.board(cols)), 300), TrackRunner.EV_EVENT)[0]["impulse"] as Vector2i).y)
		var u := TrackRunner.new(T.def([{"kind": "updraft", "at_mm": 100, "duration_ms": 1000}]))
		lifts.append(int(T.of_kind(T.run(u, F.api(T.board(cols)), 300), TrackRunner.EV_EVENT)[0]["lift_pm_per_s"]))
	assert_int(gusts[1]).is_greater(gusts[0])
	assert_int(lifts[0]).is_greater(lifts[1])
	assert_int(lifts[1]).is_equal(0)  # 216 cells is past heavy_cells


func test_the_arch_is_a_height_gate_that_costs_a_heart_when_the_stack_is_too_tall() -> void:
	for pair: Array in [[2, false], [3, true]]:
		var runner := TrackRunner.new(T.def([{"kind": "arch", "at_mm": 500, "gap_layers": 3}]))
		var out: Array[Dictionary] = T.run(runner, F.api(T.board(T.plateau(int(pair[0])))), 1000)
		assert_bool(T.kinds(out).has(TrackRunner.EV_HEART_LOST)).is_equal(bool(pair[1]))
		if bool(pair[1]):
			assert_str(String(T.of_kind(out, TrackRunner.EV_HEART_LOST)[0]["cause"])).is_equal("arch")


func test_an_unstable_seat_warns_wobble_then_slip_before_the_cargo_falls() -> void:
	var runner := TrackRunner.new(T.def())
	var out: Array[Dictionary] = T.run(runner, F.api(T.board({Vector2i(3, 3): 4})), 9000)  # a lone tower
	var names: Array = T.of_kind(out, TrackRunner.EV_CARGO_STATE).map(func(r: Dictionary) -> StringName: return r["name"])
	assert_array(names.slice(0, 2)).is_equal([&"wobble", &"slip"])
	assert_str(String(T.of_kind(out, TrackRunner.EV_CARGO_STATE)[0]["cause"])).is_equal("seat")
	var order: Array = T.kinds(out)
	assert_bool(order.find(TrackRunner.EV_CARGO_STATE) < order.find(TrackRunner.EV_CARGO_LOST)).is_true()


func test_event_stress_cannot_skip_a_warning_stage() -> void:
	var d: Dictionary = T.dict([{"kind": "cloud_bump", "at_mm": 500, "force": 3, "dir": "+x"}])
	(d["effects"] as Dictionary)["cloud_bump"]["cargo_stress_pm_per_force"] = 5000
	var runner := TrackRunner.new(TrackDef.from_dict(d))
	var out: Array[Dictionary] = T.run(runner, F.api(T.board(T.plateau(2))), 1500)
	var states: Array[Dictionary] = T.of_kind(out, TrackRunner.EV_CARGO_STATE)
	assert_array(states.map(func(r: Dictionary) -> StringName: return r["name"]).slice(0, 2)).is_equal([&"wobble", &"slip"])
	assert_str(String(states[0]["cause"])).is_equal("cloud_bump")
	assert_int(int(states[0]["tick"])).is_less(int(T.of_kind(out, TrackRunner.EV_CARGO_LOST)[0]["tick"]))


func test_building_a_level_seat_during_the_warning_saves_the_cargo() -> void:
	var board: BoardState = T.board({Vector2i(3, 3): 4})
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(T.def())
	T.run(runner, api, 3500)
	assert_int(int(runner.cargo_state()["state"])).is_greater_equal(TrackRunner.CARGO_WOBBLE)
	for col: Vector2i in T.plateau(4):
		for y: int in 4:
			if board.get_kind(board.index(Vector3i(col.x, y, col.y))) == 0:
				board.place(board.index(Vector3i(col.x, y, col.y)), 1, 0, 3)
	var out: Array[Dictionary] = T.run(runner, api, 4000)
	assert_bool(T.kinds(out).has(TrackRunner.EV_CARGO_LOST)).is_false()
	assert_int(int(runner.cargo_state()["state"])).is_equal(TrackRunner.CARGO_STABLE)


func test_a_line_clear_that_drops_the_seat_stresses_the_cargo() -> void:
	var board: BoardState = T.board(T.plateau(4))
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(T.def())
	T.run(runner, api, 200)
	for col: Vector2i in T.plateau(4):
		board.remove(board.index(Vector3i(col.x, 3, col.y)), BoardState.Cause.CLEAR)
	T.run(runner, api, 100)
	assert_int(int(runner.cargo_state()["stress_pm"])).is_greater_equal(150)
	assert_str(String(runner.cargo_state()["cause"])).is_equal("drop")


func test_rings_are_passed_with_altitude_and_missed_without_it() -> void:
	var ring: Array = [{"id": "r", "at_mm": 3000, "min_pm": 800, "max_pm": 1000}]
	var low := TrackRunner.new(T.def([], [], {"rings": ring}))
	var out_low: Array[Dictionary] = T.run(low, F.api(T.board()), 4000)
	assert_bool(bool(T.of_kind(out_low, TrackRunner.EV_RING)[0]["hit"])).is_false()
	assert_str(String(T.of_kind(out_low, TrackRunner.EV_HEART_LOST)[0]["cause"])).is_equal("ring_missed")
	var high := TrackRunner.new(T.def([{"kind": "updraft", "at_mm": 300, "duration_ms": 4000}], [], {"rings": ring}))
	var out_high: Array[Dictionary] = T.run(high, F.api(T.board()), 4000)
	assert_bool(bool(T.of_kind(out_high, TrackRunner.EV_RING)[0]["hit"])).is_true()
	assert_int(high.hearts_left()).is_equal(3)


func test_three_losses_fail_the_run_and_ask_the_session_to_fail() -> void:
	var api: RuleApi = F.api(T.board({Vector2i(7, 3): 3}))
	var runner := TrackRunner.new(T.def())
	var board: BoardState = T.board({Vector2i(7, 3): 3})
	api = F.api(board)
	for _i: int in 3:  # the lopsided stack comes back after every wipe
		T.run(runner, api, 3500)
		for y: int in 3:
			board.place(board.index(Vector3i(7, y, 3)), 1, 0, 1)
	assert_bool(runner.is_failed()).is_true()
	assert_str(String(runner.fail_reason())).is_equal("no_hearts")
	assert_bool(api.take_requests().any(func(r: Dictionary) -> bool: return r["op"] == &"fail")).is_true()


func test_finish_records_height_and_stars_with_the_hearts_rule() -> void:
	var def: TrackDef = T.def()
	assert_int(def.stars_for(2, 0)).is_equal(1)
	assert_int(def.stars_for(3, 0)).is_equal(2)
	assert_int(def.stars_for(5, 1)).is_equal(3)
	assert_int(def.stars_for(5, 2)).is_equal(2)  # too many hearts lost caps it at 2
	var runner := TrackRunner.new(def)
	var out: Array[Dictionary] = T.run(runner, F.api(T.board(T.plateau(5))), 11000)
	assert_bool(runner.is_finished()).is_true()
	assert_int(runner.finish_height()).is_equal(5)
	assert_int(runner.stars()).is_equal(3)
	assert_int(int(T.of_kind(out, TrackRunner.EV_FINISHED)[0]["stars"])).is_equal(3)


func test_restart_returns_to_the_post_wipes_blocks_and_replays_later_events() -> void:
	var board: BoardState = T.board(T.plateau(4))
	var api: RuleApi = F.api(board)
	var def: TrackDef = T.def([{"kind": "arch", "at_mm": 6000, "gap_layers": 3}, {"kind": "updraft", "at_mm": 4000, "duration_ms": 100}],
		[{"id": "post_a", "at_mm": 3000}])
	var runner := TrackRunner.new(def)
	var out: Array[Dictionary] = T.run(runner, api, 6500)
	assert_array(T.kinds(out)).contains([TrackRunner.EV_CHECKPOINT, TrackRunner.EV_CARGO_LOST, TrackRunner.EV_HEART_LOST, TrackRunner.EV_RESTART])
	assert_int(runner.hearts_left()).is_equal(2)
	assert_int(T.count(board)).is_equal(0)
	assert_int(runner.snapshot()["best_pm"]).is_greater_equal(590)  # progress never goes backwards
	var again: Array[Dictionary] = T.run(runner, api, 1500)
	assert_bool(again.any(func(r: Dictionary) -> bool: return r.get("event", &"") == TrackDef.KIND_UPDRAFT)).is_true()


func test_preview_is_honest_about_pushes_safe_heights_severity_and_active_lift() -> void:
	var def: TrackDef = T.def([{"kind": "bump", "at_mm": 1000, "force": 1, "dir": "-x"}, {"kind": "crosswind", "at_mm": 1500, "dir": "+z", "strength": 2},
		{"kind": "gust", "at_mm": 2000, "dir": "+x", "strength": 1}, {"kind": "arch", "at_mm": 2500, "gap_layers": 6}], [{"id": "p", "at_mm": 3000}])
	var rows: Array[Dictionary] = def.preview(0, 4000, 64, 32)
	assert_str(String(rows[0]["push"])).is_equal("heavy_side")
	assert_int(int(rows[1]["safe_height_layers"])).is_greater(0)
	assert_bool(rows[2].has("safe_height_layers")).is_true()
	assert_int(int(rows[3]["safe_height_layers"])).is_equal(5)
	for row: Dictionary in rows:
		assert_int(int(row["severity"])).is_between(1, 3)
	var api: RuleApi = F.api(T.board())
	var runner := TrackRunner.new(T.def([{"kind": "updraft", "at_mm": 100, "duration_ms": 2000}]))
	T.run(runner, api, 400)
	assert_str(String(runner.preview(api)[0]["kind"])).is_equal("updraft_active")


func test_a_restored_runner_continues_identically() -> void:
	var events: Array = [{"kind": "updraft", "at_mm": 3000, "duration_ms": 2000}, {"kind": "cloud_bump", "at_mm": 5000, "force": 1, "dir": "+z"}]
	var a := TrackRunner.new(T.def(events))
	var api_a: RuleApi = F.api(T.board())
	T.run(a, api_a, 2000)
	var b := TrackRunner.new(T.def(events))
	b.restore(a.snapshot())
	var out_a: Array[Dictionary] = T.run(a, api_a, 6000)
	var out_b: Array[Dictionary] = T.run(b, F.api(T.board()), 6000)
	assert_array(out_b).is_equal(out_a)
	assert_dict(b.snapshot()).is_equal(a.snapshot())


func test_path_point_follows_arc_length() -> void:
	var def: TrackDef = T.def([], [], {"path": [[0, 0, 0], [0, 0, -10], [10, 0, -10]]})
	assert_vector(def.path_point(5000)).is_equal(Vector3(0, 0, -10))
	assert_vector(def.path_point(10000)).is_equal(Vector3(10, 0, -10))
