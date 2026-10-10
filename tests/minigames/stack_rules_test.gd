extends RefCounted

const MODEL = preload("res://minigames/arcade_pack/models/stack_round.gd")


static func _fixture() -> Dictionary:
	return {"id": "stack_fixture", "time_limit": 600.0, "star_times": [50.0, 100.0],
		"target_height": 8, "base_width": 4.0, "speed_start": 2.0, "speed_max": 4.0,
		"motion_extent": 2.8, "perfect_tolerance": 0.13,
		"magnet_charges": 2, "magnet_range": 0.8,
		"wind_amplitude": 0.35, "wind_period": 3.1,
		"rhythm_amplitude": 0.22, "rhythm_period": 1.8}


static func _expect(condition: bool, text: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(text)


static func _near(a: float, b: float) -> bool:
	return absf(a - b) < 0.0001


static func run() -> Array[String]:
	var failures: Array[String] = []
	var round = MODEL.new()
	round.start(_fixture(), 17)
	var overlap: Dictionary = round._overlap(Vector3(1.0, 1.5, -0.5),
		Vector3(4.0, 1.0, 4.0), Vector3(0.0, 0.5, 0.0), Vector3(4.0, 1.0, 4.0))
	_expect(not overlap.is_empty(), "Stack: supported overlap should exist", failures)
	if not overlap.is_empty():
		_expect(overlap["size"].is_equal_approx(Vector3(3.0, 1.0, 3.5)),
			"Stack: overlap must trim both horizontal axes", failures)
		_expect(overlap["position"].is_equal_approx(Vector3(0.5, 1.5, -0.25)),
			"Stack: overlap must shift retained centre and preserve height", failures)
	_expect(round._overlap(Vector3(4.0, 1.5, 0.0), Vector3(4.0, 1.0, 4.0),
		Vector3(0.0, 0.5, 0.0), Vector3(4.0, 1.0, 4.0)).is_empty(),
		"Stack: touching edge must not count as support", failures)
	_expect(round._overlap(Vector3(0.0, 1.5, 4.01), Vector3(4.0, 1.0, 4.0),
		Vector3(0.0, 0.5, 0.0), Vector3(4.0, 1.0, 4.0)).is_empty(),
		"Stack: a Z-axis miss must have no support", failures)

	round.active_center = Vector3(1.0, 1.5, 0.0)
	round.act("primary")
	_expect(round.score == 1 and round.slabs.size() == 2,
		"Stack: supported slab must lock once", failures)
	_expect(round.slabs.back()["size"].is_equal_approx(Vector3(3.0, 1.0, 4.0)),
		"Stack: one-cell X overhang must shrink the slab width", failures)
	_expect(round.slabs.back()["position"].is_equal_approx(Vector3(0.5, 1.5, 0.0)),
		"Stack: trim centre must move half of the overhang", failures)
	_expect(round.slide_axis == 2 and _near(round.active_size.x, 3.0),
		"Stack: next gate must alternate to Z and inherit the trimmed width", failures)
	_expect(_near(round.last_trim, 1.0) and round.perfect_streak == 0,
		"Stack: trimming must break the perfect streak", failures)

	round.start(_fixture(), 17)
	round.active_center = Vector3(0.1, 1.5, 0.0)
	round.act("primary")
	_expect(round.slabs.back()["size"].is_equal_approx(Vector3(4.0, 1.0, 4.0))
		and round.slabs.back()["position"].is_equal_approx(Vector3(0.0, 1.5, 0.0)),
		"Stack: a perfect lock must snap without shaving the width", failures)
	_expect(round.perfect_streak == 1 and round.perfect_count == 1 and _near(round.last_trim, 0.0),
		"Stack: perfect lock must increase the streak", failures)
	var opportunities: Array = []
	round.interaction_requested.connect(func(event: Dictionary): opportunities.append(event))
	for _index in range(2):
		round.active_center = round.spawn_origin
		round.act("primary")
	_expect(opportunities.size() == 1 and opportunities[0].get("requested_effect") == "steal_slab",
		"Stack: three unassisted perfects must expose one adapter opportunity", failures)

	round.active_center = round.spawn_origin
	round.active_center[round.slide_axis] += 0.7
	round.act("undo")
	_expect(round.magnet_charges == 1 and round.score == 4 and round.last_assisted,
		"Stack: an in-range magnet must spend one charge and lock", failures)
	_expect(round.perfect_streak == 0 and round.perfect_count == 3,
		"Stack: assisted locks must break the unassisted streak", failures)
	round.active_center = round.spawn_origin
	round.active_center[round.slide_axis] += 1.0
	round.act("rotate_y")
	_expect(round.magnet_charges == 1 and round.score == 4,
		"Stack: magnet outside its range must not spend a charge or lock", failures)
	round.active_center = round.spawn_origin
	round.act("rotate_y")
	_expect(round.magnet_charges == 0 and round.score == 5,
		"Stack: E action must also invoke the limited magnet", failures)
	round.act("undo")
	_expect(round.score == 5 and round.magnet_charges == 0,
		"Stack: exhausted magnet must not lock another slab", failures)

	var outcomes: Array = []
	round.round_finished.connect(func(result: Dictionary): outcomes.append(result))
	round.start(_fixture(), 17)
	round.active_center = Vector3(4.0, 1.5, 0.0)
	round.act("primary")
	_expect(round.finished and not round.won and round.score == 0 and round.slabs.size() == 1,
		"Stack: a complete miss must end the round without adding a slab", failures)
	var terminal_snapshot: Dictionary = round.snapshot()
	var terminal_elapsed: float = round.elapsed
	round.act("primary")
	round.act("undo")
	round.act("rotate_y")
	round.advance(80.0)
	_expect(outcomes.size() == 1 and round.snapshot() == terminal_snapshot
		and _near(round.elapsed, terminal_elapsed),
		"Stack: losing terminal state must reject all later actions and time", failures)

	var win_level: Dictionary = _fixture()
	win_level["target_height"] = 2
	round.start(win_level, 7)
	for _index in range(2):
		round.active_center = round.spawn_origin
		round.act("primary")
	_expect(round.finished and round.won and round.score == 2 and round.slabs.size() == 3,
		"Stack: target height above foundation must win exactly once", failures)
	terminal_snapshot = round.snapshot()
	round.act("primary")
	round.advance(10.0)
	_expect(outcomes.size() == 2 and round.snapshot() == terminal_snapshot,
		"Stack: winning terminal state must remain immutable", failures)

	var whole = MODEL.new()
	var split = MODEL.new()
	whole.start(_fixture(), 1234)
	split.start(_fixture(), 1234)
	whole.advance(37.2)
	for _index in range(372):
		split.advance(0.1)
	_expect(whole.active_center.distance_to(split.active_center) < 0.0001,
		"Stack: wind, rhythm and reflections must be frame partition independent", failures)
	_expect(whole.motion_phase == split.motion_phase and whole.rhythm_phase == split.rhythm_phase
		and whole.motion_direction == split.motion_direction,
		"Stack: identical seeds must give identical phases", failures)
	var seed_a = MODEL.new()
	var seed_b = MODEL.new()
	seed_a.start(_fixture(), 77)
	seed_b.start(_fixture(), 77)
	for _index in range(5):
		seed_a.advance(0.413)
		seed_b.advance(0.413)
		_expect(seed_a.snapshot() == seed_b.snapshot(),
			"Stack: identical input and seed must give identical snapshots", failures)
		seed_a.active_center = seed_a.spawn_origin
		seed_b.active_center = seed_b.spawn_origin
		seed_a.act("primary")
		seed_b.act("primary")
	var before: Dictionary = seed_a.snapshot()
	seed_a.advance(0.0)
	seed_a.advance(-1.0)
	seed_a.act("left")
	seed_a.act("rotate_x")
	_expect(seed_a.snapshot() == before, "Stack: zero/negative time and irrelevant actions must be inert", failures)

	var timeout_level: Dictionary = _fixture()
	timeout_level["time_limit"] = 3.0
	round.start(timeout_level, 17)
	round.advance(2.999)
	_expect(not round.finished, "Stack: round must survive immediately before timeout", failures)
	round.advance(20.0)
	_expect(round.finished and not round.won and _near(round.elapsed, 3.0),
		"Stack: a large delta must stop at the timeout boundary", failures)
	_expect(outcomes.size() == 3, "Stack: timeout must publish one result", failures)
	round.start(_fixture(), 17)
	_expect(not round.finished and not round.won and round.score == 0
		and round.slabs.size() == 1 and round.magnet_charges == 2
		and round.perfect_count == 0 and round.perfect_streak == 0 and _near(round.elapsed, 0.0),
		"Stack: restart must fully restore the initial round", failures)
	var copied: Dictionary = round.snapshot()
	copied["blocks"][0]["size"] = Vector3.ZERO
	_expect(round.slabs[0]["size"] == Vector3(4.0, 1.0, 4.0),
		"Stack: renderer snapshot edits must not mutate the model", failures)

	for level_name in ["meadow", "clockwork", "celestial"]:
		var path: String = "res://minigames/arcade_pack/levels/stack_%s.json" % level_name
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if not parsed is Dictionary:
			failures.append("Stack: level JSON must parse: " + level_name)
			continue
		for level_seed in [1, 7, 42]:
			var playable = MODEL.new()
			playable.start(parsed, level_seed)
			var frame_limit: int = int(float(parsed["time_limit"]) * 120.0) + 1
			for _frame in range(frame_limit):
				if playable.finished:
					break
				playable.advance(1.0 / 120.0)
				if absf(playable.active_center[playable.slide_axis]
						- playable.spawn_origin[playable.slide_axis]) < float(parsed["perfect_tolerance"]) * 0.75:
					playable.act("primary")
			_expect(playable.won and playable.score == int(parsed["target_height"]),
				"Stack: authored level must be winnable at 120 Hz: %s seed %d" % [level_name, level_seed], failures)
	return failures
