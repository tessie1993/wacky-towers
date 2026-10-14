extends GdUnitTestSuite
## G8 moving platform sim core: determinism, event timing, arch limit, cargo loss, checkpoints.
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const SAMPLE := "res://assets/data/tracks/meadow_brook_run.json"
const TICK := 50


func _def(events: Array, checkpoints: Array = [], cargo: Dictionary = {}, effects: Dictionary = {}) -> TrackDef:
	var fx: Dictionary = {"bump": {"loose_pct_per_force": 100}, "arch": {}, "crosswind": {"slide_pct": 100},
		"updraft": {"lift_pct": 50, "height_pct_per_layer": 0}}
	fx.merge(effects, true)
	return TrackDef.from_dict({"id": "t", "tick_ms": TICK, "preview_window_mm": 4000,
		"segments": [{"id": "s", "length_mm": 10000, "speed_mm_s": 1000}],
		"events": events, "checkpoints": checkpoints, "cargo": cargo, "effects": fx})


func _board(columns: Dictionary) -> BoardState:
	## columns: Vector2i(x, z) -> height; solid stacks from the floor.
	var board: BoardState = F.board(4, 4, 10)
	for col: Vector2i in columns:
		for y: int in int(columns[col]):
			board.place(board.index(Vector3i(col.x, y, col.y)), 1, 0, 1)
	return board


func _cell_count(board: BoardState) -> int:
	var n: int = 0
	for y: int in 10:
		for z: int in 4:
			for x: int in 4:
				if board.get_kind(board.index(Vector3i(x, y, z))) != 0:
					n += 1
	return n


func _run(runner: TrackRunner, api: RuleApi, ms: int, dt: int = TICK) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for _i: int in ms / dt:
		out.append_array(runner.step(dt, api))
		api.flush_writes()
	return out


func _hanging_board() -> BoardState:
	var board: BoardState = _board({Vector2i(0, 0): 1})
	for y: int in range(3, 8):  # a floating overhang the bump can shake loose
		board.place(board.index(Vector3i(2, y, 2)), 1, 0, 2)
		board.place(board.index(Vector3i(3, y, 2)), 1, 0, 2)
	return board


func test_sample_track_is_valid_and_preview_lists_what_is_ahead() -> void:
	var def: TrackDef = TrackDef.load_file(SAMPLE)
	assert_array(def.errors).is_empty()
	assert_int(def.length_mm()).is_equal(60000)
	var ahead: Array[Dictionary] = def.preview(0, 12000)
	assert_int(ahead.size()).is_equal(2)
	assert_int(int(ahead[0]["ahead_mm"])).is_equal(6000)
	assert_str(String(ahead[1]["kind"])).is_equal("arch")


func test_invalid_track_reports_errors() -> void:
	var def: TrackDef = TrackDef.from_dict({"id": "x", "segments": [], "events": [{"kind": "tornado", "at_mm": 5}]})
	assert_bool(def.is_valid()).is_false()


func test_event_fires_on_the_tick_the_platform_reaches_it() -> void:
	var board: BoardState = _board({Vector2i(0, 0): 1})
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(_def([{"kind": "updraft", "at_mm": 2000, "duration_ms": 500}]), 1)
	var out: Array[Dictionary] = _run(runner, api, 5000)
	assert_int(out.size()).is_equal(1)
	assert_int(int(out[0]["tick"])).is_equal(40)  # 2000 mm at 1000 mm/s with 50 ms ticks
	assert_int(int(out[0]["at_mm"])).is_equal(2000)


func test_updraft_speeds_the_platform_for_its_duration_only() -> void:
	var api: RuleApi = F.api(_board({}))
	var runner := TrackRunner.new(_def([{"kind": "updraft", "at_mm": 1000, "duration_ms": 1000}]), 1)
	_run(runner, api, 1000)
	assert_int(runner.speed_mm_s(api)).is_equal(1500)
	_run(runner, api, 1100)
	assert_int(runner.speed_mm_s(api)).is_equal(1000)


func test_same_seed_same_result_and_chunking_does_not_matter() -> void:
	var events: Array = [{"kind": "bump", "at_mm": 1000, "force": 1}, {"kind": "crosswind", "at_mm": 3000, "dir": "+x"}]
	var results: Array = []
	for dt: int in [50, 50, 10]:
		var board: BoardState = _hanging_board()
		var api: RuleApi = F.api(board)
		var runner := TrackRunner.new(_def(events, [], {}, {"bump": {"loose_pct_per_force": 50}}), 7)
		var out: Array[Dictionary] = _run(runner, api, 6000, dt)
		results.append([_cell_count(board), runner.position_mm(), out.size(), runner.snapshot()["rng_state"]])
	assert_array(results[1]).is_equal(results[0])
	assert_array(results[2]).is_equal(results[0])


func test_bump_shakes_loose_only_unsupported_blocks() -> void:
	var board: BoardState = _hanging_board()
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(_def([{"kind": "bump", "at_mm": 500, "force": 1}]), 3)
	_run(runner, api, 1000)
	assert_int(board.get_kind(board.index(Vector3i(0, 0, 0)))).is_equal(1)  # grounded block stays
	assert_int(board.get_kind(board.index(Vector3i(2, 3, 2)))).is_equal(0)  # the overhang base is gone
	# Above the lowest hanging block the rest were only "supported" by the doomed one in the same instant.
	assert_int(board.get_kind(board.index(Vector3i(2, 4, 2)))).is_equal(1)


func test_arch_removes_everything_at_or_above_the_gap() -> void:
	var board: BoardState = _board({Vector2i(0, 0): 5, Vector2i(3, 3): 2})
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(_def([{"kind": "arch", "at_mm": 500, "gap_layers": 3}]), 1)
	var out: Array[Dictionary] = _run(runner, api, 1000)
	assert_int(_cell_count(board)).is_equal(3 + 2)
	assert_int(int(out[0]["removed"])).is_equal(2)
	assert_int(board.get_kind(board.index(Vector3i(0, 2, 0)))).is_equal(1)
	assert_int(board.get_kind(board.index(Vector3i(0, 3, 0)))).is_equal(0)


func test_cargo_survives_an_arch_it_fits_under_and_is_lost_when_too_tall() -> void:
	var cargo: Dictionary = {"x": 1, "z": 1, "height_layers": 1, "max_drop_layers": 5}
	var fits: Array[Dictionary] = _run_arch(2, 3, cargo)
	assert_bool(fits.any(func(r: Dictionary) -> bool: return r["kind"] == TrackRunner.EV_CARGO_LOST)).is_false()
	var lost: Array[Dictionary] = _run_arch(3, 3, cargo)
	assert_bool(lost.any(func(r: Dictionary) -> bool: return r["kind"] == TrackRunner.EV_CARGO_LOST)).is_true()


func _run_arch(column_height: int, gap: int, cargo: Dictionary) -> Array[Dictionary]:
	var api: RuleApi = F.api(_board({Vector2i(1, 1): column_height}))
	var runner := TrackRunner.new(_def([{"kind": "arch", "at_mm": 500, "gap_layers": gap}], [], cargo), 1)
	return _run(runner, api, 1000)


func test_cargo_is_lost_when_a_bump_drops_its_seat_too_far() -> void:
	var board: BoardState = _board({Vector2i(1, 1): 4})
	var api: RuleApi = F.api(board)
	var cargo: Dictionary = {"x": 1, "z": 1, "height_layers": 1, "max_drop_layers": 1}
	var fx: Dictionary = {"bump": {"tall_layer": 1, "tall_pct_per_force": 100}}
	var runner := TrackRunner.new(_def([{"kind": "bump", "at_mm": 500, "force": 1}], [], cargo, fx), 1)
	var out: Array[Dictionary] = _run(runner, api, 1000)
	assert_bool(out.any(func(r: Dictionary) -> bool: return r["kind"] == TrackRunner.EV_CARGO_LOST)).is_true()


func test_cargo_loss_returns_to_the_last_checkpoint_and_clears_the_blocks() -> void:
	var board: BoardState = _board({Vector2i(1, 1): 4})
	var api: RuleApi = F.api(board)
	var cargo: Dictionary = {"x": 1, "z": 1, "height_layers": 1, "max_drop_layers": 5}
	var runner := TrackRunner.new(_def([{"kind": "arch", "at_mm": 6000, "gap_layers": 2}],
		[{"id": "post_a", "at_mm": 3000}], cargo), 1)
	var out: Array[Dictionary] = _run(runner, api, 6500)
	var kinds: Array = out.map(func(r: Dictionary) -> StringName: return r["kind"])
	assert_array(kinds).contains([TrackRunner.EV_CHECKPOINT, TrackRunner.EV_CARGO_LOST, TrackRunner.EV_RESTART])
	assert_int(runner.attempts()).is_equal(2)
	assert_str(String(runner.checkpoint_id())).is_equal("post_a")
	assert_int(_cell_count(board)).is_equal(0)
	assert_int(runner.position_mm()).is_less(6000)
	assert_int(runner.position_mm()).is_greater_equal(3000)


func test_fail_mode_ends_the_run_instead_of_restarting() -> void:
	var api: RuleApi = F.api(_board({Vector2i(1, 1): 4}))
	var def: TrackDef = _def([{"kind": "arch", "at_mm": 500, "gap_layers": 1}], [], {"x": 1, "z": 1})
	def.on_loss = &"fail"
	var runner := TrackRunner.new(def, 1)
	_run(runner, api, 1000)
	assert_bool(runner.is_failed()).is_true()
	assert_int(runner.attempts()).is_equal(1)


func test_platform_finishes_at_the_end_of_the_track() -> void:
	var api: RuleApi = F.api(_board({}))
	var runner := TrackRunner.new(_def([]), 1)
	var out: Array[Dictionary] = _run(runner, api, 11000)
	assert_bool(runner.is_finished()).is_true()
	assert_int(runner.position_mm()).is_equal(10000)
	assert_int(out.size()).is_equal(1)
	assert_str(String(out[0]["kind"])).is_equal(String(TrackRunner.EV_FINISHED))


func test_snapshot_restore_round_trips() -> void:
	var api: RuleApi = F.api(_hanging_board())
	var runner := TrackRunner.new(_def([{"kind": "bump", "at_mm": 4000, "force": 1}]), 5)
	_run(runner, api, 2000)
	var snap: Dictionary = runner.snapshot()
	_run(runner, api, 1000)
	runner.restore(snap)
	assert_dict(runner.snapshot()).is_equal(snap)


func test_path_point_follows_arc_length() -> void:
	var def: TrackDef = TrackDef.from_dict({"id": "p", "segments": [{"id": "s", "length_mm": 1000, "speed_mm_s": 1}],
		"path": [[0, 0, 0], [0, 0, -10], [10, 0, -10]]})
	assert_vector(def.path_point(0)).is_equal(Vector3.ZERO)
	assert_vector(def.path_point(500)).is_equal(Vector3(0, 0, -10))
	assert_vector(def.path_point(1000)).is_equal(Vector3(10, 0, -10))
