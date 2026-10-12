extends GdUnitTestSuite
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")


func test_height_needs_coverage_at_exact_target_layer() -> void:
	var board: BoardState = F.board(5, 5, 12)
	var api: RuleApi = F.api(board)
	var goal := HeightGoal.new()
	goal.configure({"h_target": 10, "coverage": 0.6})
	var state := GoalState.new()
	for x: int in 5:
		for z: int in 3:
			board.place(board.index(Vector3i(x, 9, z)), 1, 0, 1)
	assert_int(goal.evaluate(state, api)).is_equal(GoalEvaluator.WON)
	board.remove(board.index(Vector3i(4, 9, 2)), BoardState.Cause.TRIM)
	board.place(board.index(Vector3i(4, 10, 2)), 1, 0, 1)
	assert_int(goal.evaluate(state, api)).is_equal(GoalEvaluator.RUNNING)
	assert_int(goal.progress(state)["done"]).is_equal(14)
	assert_int(goal.progress(state)["target"]).is_equal(15)


func test_shape_uses_targets_and_counts_living_content() -> void:
	var board: BoardState = F.board()
	var api: RuleApi = F.api(board)
	var goal := ShapeGoal.new()
	goal.configure({"target_shape": {"layers": {"0": ["+...", ".+..", "....", "...."]}}})
	var state := GoalState.new()
	board.place(board.index(Vector3i(0, 0, 0)), 4, 0, 0)
	board.place(board.index(Vector3i(2, 0, 2)), 1, 0, 1)
	assert_int(goal.evaluate(state, api)).is_equal(GoalEvaluator.RUNNING)
	assert_int(goal.progress(state)["done"]).is_equal(1)
	board.place(board.index(Vector3i(1, 0, 1)), 6, 0, 0)
	assert_int(goal.evaluate(state, api)).is_equal(GoalEvaluator.WON)


func test_empty_target_never_auto_wins() -> void:
	var goal := ShapeGoal.new()
	goal.configure({})
	assert_int(goal.evaluate(GoalState.new(), F.api(F.board()))).is_equal(GoalEvaluator.RUNNING)


func test_flavour_targets_reject_smudges_accept_rainbow_and_win_threshold() -> void:
	var board: BoardState = F.board()
	var api: RuleApi = F.api(board)
	var goal := ShapeGoal.new()
	goal.configure({"win_correct": 2, "target_shape": {"colours": true, "layers": {"0": ["PVM."]}}})
	board.place(board.index(Vector3i(0, 0, 0)), 1, 1, 1)
	board.place(board.index(Vector3i(1, 0, 0)), 1, 1, 2)
	board.place(board.index(Vector3i(2, 0, 0)), 1, 2, 3)
	assert_int(goal.evaluate(GoalState.new(), api)).is_equal(GoalEvaluator.RUNNING)
	assert_int(goal.progress(GoalState.new())["done"]).is_equal(1)
	board.set_status(board.index(Vector3i(1, 0, 0)), {"status_id": 27, "rainbow": true})
	assert_int(goal.evaluate(GoalState.new(), api)).is_equal(GoalEvaluator.WON)
	assert_int(goal.progress(GoalState.new())["target"]).is_equal(2)


func test_survive_clock_threshold() -> void:
	var goal := SurviveGoal.new()
	goal.configure({"t_ms": 150000})
	var state := GoalState.new()
	state.level_ms = 149999
	assert_int(goal.evaluate(state, null)).is_equal(GoalEvaluator.RUNNING)
	state.level_ms = 150000
	assert_int(goal.evaluate(state, null)).is_equal(GoalEvaluator.WON)


func test_trim_keeps_legal_cube_and_counts_only_overflow() -> void:
	var board: BoardState = F.board(4, 4, 6)
	F.write(board, [Vector3i(0, 5, 0), Vector3i(0, 6, 0), Vector3i(0, 7, 0)])
	var state := GoalState.new()
	var policy := TrimTopOut.new()
	assert_int(policy.resolve_top_out(board, state, null)).is_equal(TopOutPolicy.CONTINUE)
	assert_int(state.cells_trimmed).is_equal(2)
	assert_int(state.layers_cleared).is_equal(0)
	assert_int(board.get_kind(board.index(Vector3i(0, 5, 0)))).is_equal(1)
	assert_bool(board.over_limit()).is_false()


func test_rescue_spends_warning_without_clear_credit() -> void:
	var board: BoardState = F.board(4, 4, 6)
	F.write(board, [Vector3i(0, 7, 0)])
	var state := GoalState.new()
	state.warnings_left = 1
	var policy := RescueTopOut.new(2)
	assert_int(policy.resolve_top_out(board, state, null)).is_equal(TopOutPolicy.CONTINUE)
	assert_int(state.warnings_left).is_equal(0)
	assert_int(state.layers_cleared).is_equal(0)
	assert_int(board.stack_height()).is_equal(3)


func test_none_detector_disables_full_layer_clears() -> void:
	var board: BoardState = F.board(2, 2, 4)
	F.write(board, [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(1, 0, 1)])
	assert_int(LayerDetector.new().find_clears(board, null).size()).is_equal(1)
	assert_int(NoneDetector.new().find_clears(board, null).size()).is_equal(0)
