extends GdUnitTestSuite
## G8 rule glue: registration, hook wiring, restore, the race goal, robustness, and the fixture level through the loader.
const T := preload("res://tests/unit/track/track_fixture.gd")
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const LEVEL := "res://tests/fixtures/levels/moving_platform_brook_run.json"


func test_plugins_are_registered() -> void:
	var reg := PluginRegistry.new(ProjectSettings.get_global_class_list())
	assert_object(reg.create(&"RuleBehaviour", &"moving_platform")).is_instanceof(MovingPlatformRule)
	assert_object(reg.create(&"GoalEvaluator", &"track_race")).is_instanceof(TrackRaceGoal)
	assert_bool(FileAccess.file_exists("res://assets/data/rules/moving_platform.json")).is_true()


func test_rule_starts_the_track_steps_on_ticks_and_restores_with_a_reannounce() -> void:
	var api: RuleApi = F.api(T.board(), {"track": "meadow_brook_run"})
	var rule := MovingPlatformRule.new()
	rule.handle(&"on_level_start", HookContext.new(), api)
	assert_object(rule.runner()).is_not_null()
	assert_bool(api.take_events().any(func(e: Dictionary) -> bool: return e["kind"] == TrackRunner.EV_STARTED)).is_true()
	api.set_time(0)
	rule.handle(&"on_tick", HookContext.new(), api)
	api.set_time(3000)
	rule.handle(&"on_tick", HookContext.new(), api)
	assert_int(rule.runner().position_mm()).is_between(2900, 3100)
	api.take_events()
	var copy := MovingPlatformRule.new()
	copy.restore(rule.snapshot())
	assert_dict(copy.runner().snapshot()).is_equal(rule.runner().snapshot())
	copy.handle(&"on_tick", HookContext.new(), api)
	assert_bool(api.take_events().any(func(e: Dictionary) -> bool: return e["kind"] == TrackRunner.EV_STARTED)).is_true()


func test_a_bad_track_reports_lost_instead_of_running_forever() -> void:
	var api: RuleApi = F.api(T.board(), {"track": "no_such_track"})
	var state := GoalState.new()
	api.bind_goal(state, {})
	var rule := MovingPlatformRule.new()
	rule.handle(&"on_level_start", HookContext.new(), api)
	assert_object(rule.runner()).is_null()
	assert_int(TrackRaceGoal.new().evaluate(state, api)).is_equal(GoalEvaluator.LOST)
	assert_bool(api.take_requests().any(func(r: Dictionary) -> bool: return r["op"] == &"fail")).is_true()


func test_goal_reads_the_runner_metrics() -> void:
	var goal := TrackRaceGoal.new()
	var state := GoalState.new()
	assert_int(goal.evaluate(state, null)).is_equal(GoalEvaluator.RUNNING)
	state.metrics[TrackRunner.METRIC_FAILED] = 1
	assert_int(goal.evaluate(state, null)).is_equal(GoalEvaluator.LOST)
	state.metrics[TrackRunner.METRIC_FAILED] = 0
	state.metrics[TrackRunner.METRIC_FINISHED] = 1
	assert_int(goal.evaluate(state, null)).is_equal(GoalEvaluator.WON)


func test_restart_clears_blocks_moved_by_writes_queued_before_it() -> void:
	var board: BoardState = T.board(T.plateau(4))
	board.place(board.index(Vector3i(7, 0, 7)), 1, 0, 1)
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(T.def([{"kind": "arch", "at_mm": 500, "gap_layers": 3}]))
	T.run(runner, api, 450)
	api.move_cell(Vector3i(7, 0, 7), Vector3i(6, 5, 7))  # still queued when the loss and restart happen
	runner.step(100, api)
	api.flush_writes()
	assert_int(runner.hearts_left()).is_equal(2)
	assert_int(T.count(board)).is_equal(0)


func test_the_fixture_level_loads_through_the_level_loader_and_runs() -> void:
	var content: WtContent = WtContent.new()
	content.load_catalog()
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LEVEL)) as Dictionary
	var parsed: LoadResult = LevelLoader.parse_level(raw, content.catalog)
	assert_bool(parsed.ok()).is_true()
	assert_str(String(parsed.level.goal["type"])).is_equal("track_race")
	var sim := BoardSim.new(parsed.level, 1, content.catalog)
	var saw_started: bool = false
	for _i: int in 120:
		for ev: SimEvent in sim.step():
			saw_started = saw_started or ev.kind == TrackRunner.EV_STARTED
	assert_bool(saw_started).is_true()
