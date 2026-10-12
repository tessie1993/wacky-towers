extends RefCounted

const ShadowRound = preload("res://minigames/arcade_pack/models/shadow_round.gd")
const LEVEL_PATHS: Array[String] = [
	"res://minigames/arcade_pack/levels/shadow_picnic_lantern.json",
	"res://minigames/arcade_pack/levels/shadow_clockwork_sign.json",
	"res://minigames/arcade_pack/levels/shadow_comets_constellation.json",
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	_test_both_projections_and_equivalence(failures)
	_test_extra_cells_and_budget(failures)
	_test_constraints_undo_and_reset(failures)
	_test_authored_solutions(failures)
	_test_time_and_terminal_guards(failures)
	return failures


static func _fixture() -> Dictionary:
	return {"id": "shadow_fixture", "mode": "shadow", "grid_size": 3,
		"time_limit": 60.0, "star_times": [20.0, 40.0], "cube_budget": 4,
		"front": ["##.", "...", "..."], "side": ["##.", "...", "..."],
		"solution": [[0, 0, 0], [1, 0, 1]]}


static func _expect(condition: bool, description: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(description)


static func _edit(model, cell: Array) -> void:
	_move_to(model, cell)
	model.act("primary")


static func _move_to(model, cell: Array) -> void:
	var target: Vector3i = Vector3i(int(cell[0]), int(cell[1]), int(cell[2]))
	while model.cursor.x != target.x and not model.finished:
		model.act("right" if model.cursor.x < target.x else "left")
	while model.cursor.z != target.z and not model.finished:
		model.act("down" if model.cursor.z < target.z else "up")
	while model.cursor.y != target.y and not model.finished:
		model.act("rotate_y" if model.cursor.y < target.y else "rotate_x")


static func _test_both_projections_and_equivalence(failures: Array[String]) -> void:
	var model = ShadowRound.new()
	model.start(_fixture(), 7)
	_edit(model, [0, 0, 0])
	_edit(model, [1, 0, 0])
	_expect(not model.finished and not model.projections_match(), "Front-only equality must not complete a shadow puzzle.", failures)
	_edit(model, [1, 0, 1])
	_expect(model.won, "Matching both silhouettes should win, including redundant cubes within shadows.", failures)
	model.start(_fixture(), 7)
	_edit(model, [0, 0, 0])
	_edit(model, [0, 0, 1])
	_expect(not model.finished and not model.projections_match(), "Side-only equality must not complete a shadow puzzle.", failures)

	var alternate = ShadowRound.new()
	alternate.start(_fixture(), 7)
	_edit(alternate, [0, 0, 1])
	_edit(alternate, [1, 0, 0])
	_expect(alternate.won, "An alternate-depth build must win even when it differs from the authored witness.", failures)
	_expect(alternate.snapshot()["progress"] == 1.0, "Won projection progress must be exactly one.", failures)


static func _test_extra_cells_and_budget(failures: Array[String]) -> void:
	var model = ShadowRound.new()
	model.start(_fixture(), 4)
	_edit(model, [2, 0, 2])
	_edit(model, [0, 0, 0])
	_edit(model, [1, 0, 1])
	_expect(not model.finished and not model.projections_match(), "Extra silhouette cells must prevent completion even with every target covered.", failures)
	_expect(is_equal_approx(model.projection_progress(), 0.5), "Projection progress must subtract both extra cells per MG10 F5.", failures)
	_edit(model, [2, 0, 2])
	_expect(model.won, "Removing the last extra projection cell should immediately complete the puzzle.", failures)

	var level: Dictionary = _fixture()
	level["cube_budget"] = 2
	model.start(level, 4)
	_edit(model, [2, 0, 2])
	_edit(model, [0, 0, 0])
	_edit(model, [1, 0, 1])
	_expect(model.cubes.size() == 2 and not model.cubes.has(Vector3i(1, 0, 1)), "A full cube tray must reject additions.", failures)
	_edit(model, [2, 0, 2])
	_expect(model.cubes.size() == 1, "Removal at the budget cap must remain possible and refund a cube.", failures)
	_edit(model, [1, 0, 1])
	_expect(model.won, "Budget exhaustion must not create an unrecoverable puzzle.", failures)


static func _test_constraints_undo_and_reset(failures: Array[String]) -> void:
	var level: Dictionary = _fixture()
	level["cube_budget"] = 2
	level["blocked_cells"] = [[0, 0, 0]]
	var model = ShadowRound.new()
	model.start(level, 10)
	model.act("primary")
	_expect(model.cubes.is_empty() and model.undo_history.is_empty(), "Forbidden sockets must reject a cube without creating an undo edit.", failures)
	_edit(model, [0, 0, 1])
	model.act("undo")
	_expect(model.cubes.is_empty() and model.cursor == Vector3i(0, 0, 1), "Undoing a placement must remove it and return the cursor to that cell.", failures)
	model.act("primary")
	model.act("primary")
	_expect(model.cubes.is_empty(), "Toggling an existing cube must remove it.", failures)
	model.act("undo")
	_expect(model.cubes.has(Vector3i(0, 0, 1)), "Undoing removal must restore the cube.", failures)
	model.advance(12.0)
	model.start(level, 10)
	_expect(model.cubes.is_empty() and model.undo_history.is_empty() and model.cursor == Vector3i.ZERO and model.elapsed == 0.0 and model.edits == 0, "Restart must reset cubes, cursor, undo history, edits and elapsed time.", failures)
	model.act("undo")
	_expect(model.cubes.is_empty(), "Undo after reset must not restore cubes from the previous round.", failures)
	for _i in range(12):
		model.act("right")
		model.act("down")
		model.act("rotate_y")
	_expect(model.cursor == Vector3i(2, 2, 2), "Positive cursor movement must clamp at all three grid boundaries.", failures)
	for _i in range(12):
		model.act("left")
		model.act("up")
		model.act("rotate_x")
	_expect(model.cursor == Vector3i.ZERO, "Negative cursor movement must clamp at the origin.", failures)
	var before: Dictionary = model.snapshot()
	model.act("unrecognised")
	_expect(model.snapshot() == before, "Unknown semantic actions must be ignored.", failures)


static func _test_authored_solutions(failures: Array[String]) -> void:
	for path in LEVEL_PATHS:
		var raw = JSON.parse_string(FileAccess.get_file_as_string(path))
		if not raw is Dictionary:
			failures.append("Could not read authored shadow level: " + path)
			continue
		var level: Dictionary = raw
		var model = ShadowRound.new()
		model.start(level, 12345)
		var twin = ShadowRound.new()
		twin.start(level, 12345)
		_expect(model.snapshot() == twin.snapshot(), "A fixed seed must start the same shadow level and cursor: " + path, failures)
		var authored: Array = level.get("puzzles", [])
		_expect(authored.size() == 3, "Each shadow level must have three finite puzzles: " + path, failures)
		for puzzle_number in range(authored.size()):
			var puzzle: Dictionary = authored[puzzle_number]
			var solution: Array = puzzle.get("solution", [])
			_expect(solution.size() <= int(puzzle.get("cube_budget", 0)), "Witness exceeds cube budget in " + str(puzzle.get("id")), failures)
			for cell in solution:
				_expect(not puzzle.get("blocked_cells", []).has(cell), "Witness uses a forbidden cell in " + str(puzzle.get("id")), failures)
				_edit(model, cell)
				_edit(twin, cell)
			_expect(model.completed_puzzles == puzzle_number + 1, "Authored witness must solve puzzle " + str(puzzle.get("id")), failures)
			_expect(model.snapshot() == twin.snapshot(), "Same-seed action sequences must give identical snapshots in " + str(puzzle.get("id")), failures)
			if puzzle_number < authored.size() - 1:
				_expect(model.cubes.is_empty() and model.undo_history.is_empty(), "Next blueprint must clear cubes and undo history.", failures)
		_expect(model.won and model.score == 300, "All authored silhouettes should complete the level with score 300: " + path, failures)


static func _test_time_and_terminal_guards(failures: Array[String]) -> void:
	var level: Dictionary = _fixture()
	level["time_limit"] = 0.25
	var model = ShadowRound.new()
	var results: Array = []
	model.round_finished.connect(func(result: Dictionary): results.append(result))
	model.start(level, 6)
	model.advance(-4.0)
	model.advance(0.0)
	_expect(model.elapsed == 0.0 and not model.finished, "Nonpositive time steps must leave shadow rounds unchanged.", failures)
	model.advance(3.0)
	_expect(model.finished and not model.won and is_equal_approx(model.elapsed, 0.25), "Oversized time step must stop exactly at the deadline.", failures)
	var frozen: Dictionary = model.snapshot()
	model.act("primary")
	model.act("right")
	model.act("undo")
	model.advance(100.0)
	_expect(model.snapshot() == frozen and results.size() == 1, "Timed-out rounds must reject edits, movement, undo and repeat result emission.", failures)
	model.start(level, 6)
	model.advance(0.25)
	_expect(model.finished and not model.won, "The exact timeout boundary must finish an incomplete puzzle.", failures)
	model.start(_fixture(), 6)
	var requests: Array = []
	model.interaction_requested.connect(func(event: Dictionary): requests.append(event))
	_edit(model, [0, 0, 0])
	_edit(model, [1, 0, 1])
	_expect(model.finished and model.won and requests.size() == 1 and requests[0].get("type") == "flicker_requested", "Success must emit one adapter request without claiming a network send.", failures)
	frozen = model.snapshot()
	var results_before: int = results.size()
	model.act("primary")
	model.act("rotate_y")
	model.advance(90.0)
	_expect(model.snapshot() == frozen and results.size() == results_before, "Won rounds must remain terminal and emit only one result.", failures)
