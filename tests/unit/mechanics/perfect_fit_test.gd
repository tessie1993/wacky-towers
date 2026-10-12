extends GdUnitTestSuite
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const PerfectFit := preload("res://src/game/abilities/perfect_fit.gd")


func test_clear_placement_wins_and_search_never_consumes_rng() -> void:
	var board: BoardState = F.board(3, 2, 4)
	var gap := Vector3i(2, 0, 1)
	for x: int in 3:
		for z: int in 2:
			if Vector3i(x, 0, z) != gap:
				board.place(board.index(Vector3i(x, 0, z)), 1, 1, 1)
	var api: RuleApi = F.api_with_knobs(board)
	var shape: ShapeDef = ShapeDef.build(&"test_cube", [Vector3i.ZERO])
	var before: int = api.rng().state
	var marks: Array = PerfectFit.suggestions(api, shape, 2)
	assert_int(marks.size()).is_equal(2)
	assert_array(marks[0]).is_equal([gap])
	assert_array(PerfectFit.suggestions(api, shape, 2)).is_equal(marks)
	assert_int(api.rng().state).is_equal(before)


func test_supported_beam_with_a_covered_hole_is_excluded() -> void:
	var board: BoardState = F.board(2, 1, 4)
	board.place(board.index(Vector3i.ZERO), 1, 1, 1)
	var api: RuleApi = F.api_with_knobs(board)
	var beam: ShapeDef = ShapeDef.build(&"test_beam", [Vector3i.ZERO, Vector3i.RIGHT])
	var unsafe: Array[Vector3i] = [Vector3i(0, 1, 0), Vector3i(1, 1, 0)]
	assert_int(api.new_covered_holes(unsafe)).is_equal(1)
	var marks: Array = PerfectFit.suggestions(api, beam, 3)
	assert_int(marks.size()).is_equal(2)
	for mark: Array[Vector3i] in marks:
		assert_int(api.new_covered_holes(mark)).is_equal(0)
		assert_int(mark[0].x).is_equal(mark[1].x)
		assert_bool(api.can_place(mark)).is_true()


func test_drop_search_works_under_all_six_gravity_directions() -> void:
	var shape: ShapeDef = ShapeDef.build(&"test_corner", [Vector3i.ZERO, Vector3i.RIGHT, Vector3i.UP])
	for down: int in 6:
		var api: RuleApi = F.api_with_knobs(F.board(8, 8, 4, down))
		var marks: Array = PerfectFit.suggestions(api, shape, 3)
		assert_int(marks.size()).is_equal(3)
		for mark: Array[Vector3i] in marks:
			assert_bool(api.can_place(mark)).is_true()
			assert_int(api.new_covered_holes(mark)).is_equal(0)
			assert_int(api.cast(mark, api.down_vector())).is_equal(0)


func test_no_mark_for_impossible_footprint_or_disabled_marks() -> void:
	var api: RuleApi = F.api_with_knobs(F.board(1, 1, 4))
	var shape: ShapeDef = ShapeDef.build(&"test_corner", [Vector3i.ZERO, Vector3i.RIGHT, Vector3i.UP])
	assert_array(PerfectFit.suggestions(api, shape, 3)).is_empty()
	assert_array(PerfectFit.suggestions(api, shape, 0)).is_empty()
	assert_array(PerfectFit.suggestions(api, null, 2)).is_empty()
