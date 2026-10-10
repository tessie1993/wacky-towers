extends RefCounted
## Boundary tests for MG1's fit math, reachability, clocks and terminal state.

const WallRound = preload("res://minigames/arcade_pack/models/wall_round.gd")


static func run() -> Array[String]:
	var failures: Array[String] = []
	_test_fit(failures)
	_test_rotations(failures)
	_test_generation(failures)
	_test_timers(failures)
	_test_finish_and_restart(failures)
	return failures


static func _expect(condition: bool, description: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(description)


static func _fixture() -> Dictionary:
	return {"id": "wall_test", "mode": "wall", "time_limit": 1000.0,
		"star_times": [30.0, 60.0], "frame_size": 5, "pass_target": 50,
		"miss_limit": 50, "wall_interval": 4.0, "wall_interval_min": 4.0,
		"wall_ramp": 0.0, "axis_intro_interval": 6.0, "wall_axes": ["z", "x"],
		"shape_pool": ["elbow", "corner", "stair", "arch"], "hole_slack": 2,
		"target_turns_x": 3, "target_turns_y": 3, "random_initial_orientation": true,
		"stun_seconds": 1.0, "tight_charge": 3, "focus_charges": 2,
		"focus_seconds": 2.0, "focus_rate": 0.25, "rhythm_window": 0.5, "rhythm_bonus": 1}


static func _test_fit(failures: Array[String]) -> void:
	var elbow: Array = [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(0, 1, 0)]
	var projection: Array = WallRound.project_cells(elbow, "z")
	var core: Array = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1)]
	var opening: Array = core.duplicate()
	opening.append(Vector2i(1, 1))
	opening.append(Vector2i(2, 1))
	var exact: Dictionary = WallRound.fit_projection(projection, opening, core)
	_expect(exact["pass"] and exact["perfect"], "F3: exact core projection is Perfect even when the hole includes slack", failures)
	var extra: Array = projection.duplicate()
	extra.append(Vector2i(4, 4))
	_expect(not WallRound.fit_projection(extra, opening, core)["pass"], "F3: one extra projected cube outside the hole rejects the pass", failures)
	var subset: Array = [Vector2i(0, 0), Vector2i(1, 0)]
	var partial: Dictionary = WallRound.fit_projection(subset, opening, core)
	_expect(partial["pass"] and not partial["perfect"], "F3: a subset fits but does not receive a Perfect", failures)
	var same_size_wrong_core: Array = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)]
	var slack_fit: Dictionary = WallRound.fit_projection(same_size_wrong_core, opening, core)
	_expect(slack_fit["pass"] and not slack_fit["perfect"], "F3: equal cell count with a different slack cell is not Perfect", failures)
	_expect(not WallRound.fit_projection([], opening, core)["pass"], "An empty projection cannot pass", failures)
	var deep: Array = [Vector3i(0, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, 2)]
	_expect(WallRound.project_cells(deep, "z").size() == 1, "Projection deduplicates cubes sharing the same ray", failures)
	_expect(WallRound.project_cells(deep, "x").size() == 3, "Changing wall axis changes the 3D projection", failures)
	_expect(WallRound.project_cells(elbow, "z", Vector2i(1, 2)).has(Vector2i(3, 2)), "Projection applies horizontal and vertical alignment offsets", failures)


static func _test_rotations(failures: Array[String]) -> void:
	var shape: Array = WallRound.SHAPES["elbow"].duplicate()
	var original: String = WallRound.cell_key(shape)
	for rotation_axis in ["x", "y"]:
		var turned: Array = shape.duplicate()
		for _turn in range(4):
			turned = WallRound.rotate_cells(turned, rotation_axis)
		_expect(WallRound.cell_key(turned) == original, "Four %s quarter-turns restore the parcel" % rotation_axis, failures)
	var rotations: Array = WallRound.orientations(shape)
	_expect(rotations.size() == 24, "An asymmetric elbow exposes all 24 proper cube orientations", failures)
	var keys: Dictionary = {}
	for orientation in rotations:
		keys[WallRound.cell_key(orientation)] = true
		_expect(orientation.size() == shape.size(), "Rotation preserves the parcel's cube count", failures)
	for orientation in rotations:
		for rotation_axis in ["x", "y"]:
			_expect(keys.has(WallRound.cell_key(WallRound.rotate_cells(orientation, rotation_axis))), "The 24-orientation set is closed under %s rotations" % rotation_axis, failures)


static func _solve(round_model: RefCounted) -> bool:
	var size: int = int(round_model.config.get("frame_size", 5))
	for orientation in WallRound.orientations(round_model.piece):
		var bounds: Vector2i = WallRound.projection_size(orientation, round_model.axis)
		for u in range(size - bounds.x + 1):
			for v in range(size - bounds.y + 1):
				var translation: Vector2i = Vector2i(u, v)
				var result: Dictionary = WallRound.fit_projection(WallRound.project_cells(orientation, round_model.axis, translation), round_model.hole, round_model.hole_core)
				if result["perfect"]:
					round_model.piece = orientation.duplicate()
					round_model.offset = translation
					return true
	return false


static func _fingerprint(round_model: RefCounted) -> String:
	var cells: Array[String] = []
	for cell in round_model.hole:
		cells.append("%d,%d" % [cell.x, cell.y])
	cells.sort()
	return "%s;%s;%s;%s;%.3f" % [round_model.axis, round_model.shape_id, WallRound.cell_key(round_model.piece), ":".join(cells), round_model.wall_duration]


static func _test_generation(failures: Array[String]) -> void:
	var first: RefCounted = WallRound.new()
	var second: RefCounted = WallRound.new()
	var fixture: Dictionary = _fixture()
	first.start(fixture, 873)
	second.start(fixture, 873)
	for gate in range(24):
		_expect(_fingerprint(first) == _fingerprint(second), "Seeded wall sequence is identical at gate %d" % gate, failures)
		_expect(_solve(first), "Generated gate %d has a reachable exact solution" % gate, failures)
		_expect(_solve(second), "Second seeded gate %d also has a reachable solution" % gate, failures)
		var snap: Dictionary = first.snapshot()
		_expect(snap["wall_tiles"].size() == 25 - first.hole.size(), "Rendered gate cells equal the frame minus the real opening", failures)
		_expect(snap["blocks"].size() == first.piece.size(), "Wall snapshot preserves all parcel cubes without a solution ghost", failures)
		first.act("primary")
		second.act("primary")
	_expect(first.passes == 24 and first.misses == 0, "Solving each reachable gate records deliveries without misses", failures)
	var intro: RefCounted = WallRound.new()
	intro.start(fixture, 5)
	_solve(intro)
	intro.act("primary")
	_expect(intro.axis == "x" and is_equal_approx(intro.wall_duration, 6.0), "The first side-axis shutter receives a safe slow arrival", failures)
	_solve(intro)
	intro.act("primary")
	_expect(is_equal_approx(intro.wall_duration, 4.0), "After both axis introductions, the configured regular arrival resumes", failures)


static func _force_miss(round_model: RefCounted) -> void:
	round_model.piece = [Vector3i.ZERO]
	round_model.offset = Vector2i.ZERO
	round_model.hole = [Vector2i(4, 4)]
	round_model.hole_core = [Vector2i(4, 4)]


static func _test_timers(failures: Array[String]) -> void:
	var fixture: Dictionary = _fixture()
	fixture["axis_intro_interval"] = 4.0
	var coarse: RefCounted = WallRound.new()
	var fine: RefCounted = WallRound.new()
	coarse.start(fixture, 77)
	fine.start(fixture, 77)
	_force_miss(coarse)
	_force_miss(fine)
	coarse.advance(17.25)
	for _tick in range(69):
		fine.advance(0.25)
	_expect(coarse.gates == fine.gates and coarse.passes == fine.passes and coarse.misses == fine.misses, "Large updates preserve all automatic gate checks and recovery boundaries", failures)
	_expect(_fingerprint(coarse) == _fingerprint(fine), "Large and small updates leave the same deterministic current gate", failures)
	_expect(is_equal_approx(coarse.wall_age, fine.wall_age) and is_equal_approx(coarse.stun_remaining, fine.stun_remaining), "Gate and stun timers retain delta carry", failures)
	var focus: RefCounted = WallRound.new()
	focus.start(fixture, 4)
	focus.act("undo")
	focus.advance(3.0)
	_expect(focus.focus_charges == 1 and is_equal_approx(focus.wall_age, 1.5), "Focus consumes a charge and splits time exactly at its expiration", failures)
	_solve(focus)
	focus.act("primary")
	_expect(is_zero_approx(focus.focus_remaining), "Focus never carries over to the next wall", failures)
	var rhythm: RefCounted = WallRound.new()
	rhythm.start(fixture, 4)
	_solve(rhythm)
	rhythm.advance(3.75)
	rhythm.act("primary")
	_expect(rhythm.score == 3, "An exact manual send inside the beat window awards Perfect plus beat bonus", failures)
	var auto: RefCounted = WallRound.new()
	auto.start(fixture, 4)
	_solve(auto)
	auto.advance(4.0)
	_expect(auto.score == 2 and auto.passes == 1, "Automatic wall arrival checks fit and awards Perfect without the manual beat bonus", failures)


static func _test_finish_and_restart(failures: Array[String]) -> void:
	var fixture: Dictionary = _fixture()
	fixture["pass_target"] = 1
	fixture["miss_limit"] = 1
	fixture["axis_intro_interval"] = 4.0
	var round_model: RefCounted = WallRound.new()
	var results: Array = []
	round_model.round_finished.connect(func(result: Dictionary) -> void: results.append(result))
	round_model.start(fixture, 3)
	_solve(round_model)
	round_model.act("primary")
	_expect(round_model.finished and round_model.won and results.size() == 1, "Pass target completes a round exactly once", failures)
	var terminal_key: String = _fingerprint(round_model)
	var terminal_score: int = round_model.score
	for action in ["primary", "left", "right", "up", "down", "rotate_x", "rotate_y", "undo"]:
		round_model.act(action)
	round_model.advance(100.0)
	_expect(_fingerprint(round_model) == terminal_key and round_model.score == terminal_score and results.size() == 1, "Finished rounds reject movement, rotations, focus, sends and further clock updates", failures)
	round_model.start(fixture, 3)
	_expect(not round_model.finished and not round_model.won and round_model.score == 0 and round_model.passes == 0 and round_model.focus_charges == 2, "Restart resets results, charge budget and terminal state", failures)
	_force_miss(round_model)
	round_model.advance(100.0)
	_expect(round_model.finished and not round_model.won and round_model.misses == 1 and results.size() == 2, "Miss allowance produces one terminal failure", failures)
	_expect(is_equal_approx(round_model.elapsed, 4.0), "A large update records the actual terminal arrival time instead of its trailing delta", failures)
	var timed: RefCounted = WallRound.new()
	fixture["time_limit"] = 2.0
	timed.start(fixture, 3)
	timed.advance(100.0)
	_expect(timed.finished and not timed.won and is_equal_approx(timed.elapsed, 2.0), "Overall deadline ends a round before an upcoming wall and clamps elapsed", failures)
