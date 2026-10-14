extends GdUnitTestSuite
## G8 rule glue: plugin registration, hook wiring, rule restore, the race goal and the wipe regression.
const T := preload("res://tests/unit/track/track_fixture.gd")
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")


func test_plugins_are_registered() -> void:
	var reg := PluginRegistry.new(ProjectSettings.get_global_class_list())
	assert_object(reg.create(&"RuleBehaviour", &"moving_platform")).is_instanceof(MovingPlatformRule)
	assert_object(reg.create(&"GoalEvaluator", &"track_race")).is_instanceof(TrackRaceGoal)
	assert_bool(FileAccess.file_exists("res://assets/data/rules/moving_platform.json")).is_true()


func test_rule_starts_the_track_steps_on_ticks_and_restores() -> void:
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
	var copy := MovingPlatformRule.new()
	copy.restore(rule.snapshot())
	assert_dict(copy.runner().snapshot()).is_equal(rule.runner().snapshot())


func test_rule_with_a_bad_track_stays_idle() -> void:
	var api: RuleApi = F.api(T.board(), {"track": "no_such_track"})
	var rule := MovingPlatformRule.new()
	rule.handle(&"on_level_start", HookContext.new(), api)
	assert_object(rule.runner()).is_null()


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
	var board: BoardState = T.board(T.flat(4))
	board.place(board.index(Vector3i(3, 0, 3)), 1, 0, 1)
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(T.def([{"kind": "arch", "at_mm": 500, "gap_layers": 3}]))
	T.run(runner, api, 450)
	api.move_cell(Vector3i(3, 0, 3), Vector3i(2, 3, 3))  # still queued when the loss and restart happen
	runner.step(100, api)
	api.flush_writes()
	assert_int(runner.attempts()).is_equal(2)
	assert_int(T.count(board)).is_equal(0)
