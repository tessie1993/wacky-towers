extends GdUnitTestSuite

func test_arcade_has_actual_items_and_no_win_goal() -> void:
	var content := WtContent.new()
	content.load_catalog()
	var modes := WtModes.new(content)
	var level: LevelData = modes.arcade_level("meadow", 29)
	assert_object(level).is_not_null()
	assert_str(str(level.goal.type)).is_equal("endless")
	assert_str(str(level.rules[0].id)).is_equal("items")
	assert_int(level.rules[0].params.table.size()).is_equal(8)
	assert_array(content.last_issues).is_empty()

func test_encountered_pool_migrates_completed_levels_and_excludes_mechanics() -> void:
	var content := WtContent.new()
	content.load_catalog()
	var modes := WtModes.new(content)
	var ids: Array = []
	for row: Dictionary in content.all_levels(): ids.append(str(row.id))
	var rows: Array[Dictionary] = modes.encountered_arcade_rules({"encountered_levels":ids})
	assert_int(rows.size()).is_greater(10)
	for row: Dictionary in rows:
		assert_str(str((content.catalog.rule_defs[StringName(row.id)] as RuleDef).layer)).is_equal("twist")
	var one: Array[Dictionary] = modes.encountered_arcade_rules({"levels":{"meadow_04":{"stars":1}}})
	assert_array(one).is_not_empty()
	assert_int(modes.encountered_arcade_specials({"encountered_levels":ids}).size()).is_greater(0)

func test_asymmetric_incompatible_cards_never_share_draw() -> void:
	var content := WtContent.new()
	content.load_catalog()
	var modes := WtModes.new(content)
	(content.catalog.rule_defs[&"gust"] as RuleDef).incompatible_with = PackedStringArray(["flip"])
	(content.catalog.rule_defs[&"flip"] as RuleDef).incompatible_with = PackedStringArray()
	for seed: int in 250:
		var draw: Array = modes.arcade_twists(10, ["gust", "flip"], seed)
		assert_int(draw.size()).is_equal(1)
		assert_array(modes.arcade_twists(10, ["gust", "flip"], seed)).is_equal(draw)

func test_native_beehave_director_announces_then_waits_for_real_resolving() -> void:
	var content := WtContent.new()
	content.load_catalog()
	var modes := WtModes.new(content)
	var level: LevelData = modes.arcade_level("meadow", 31)
	level.pieces = {"shapes":PackedStringArray(["mono"])}
	level.knobs[&"goal.countdown_ms"] = 0
	level.knobs[&"fall.g0"] = 100
	var simulation := BoardSim.new(level, 31, content.catalog)
	var director := WtArcadeDirector.new()
	director.setup(content, modes, {}, 31)
	var announcements: int = 0
	var first_apply_ms: int = -1
	var real_locks: int = 0
	for tick: int in 245:
		if tick == 185 or tick == 220:
			simulation.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
		var events: Array[SimEvent] = simulation.step()
		for event: SimEvent in events:
			if event.kind == SimEvents.PIECE_LOCKED: real_locks += 1
		var output: Dictionary = director.update(simulation)
		if output.has("warning"): announcements += 1
		if output.has("twists_changed") and first_apply_ms < 0:
			first_apply_ms = simulation.now_ms()
			assert_int(simulation.get_phase()).is_equal(BoardSim.Phase.RESOLVING)
		if simulation.now_ms() < 2000: assert_array(director.snapshot().rules).is_empty()
	assert_int(announcements).is_equal(1)
	assert_int(first_apply_ms).is_greater_equal(2000)
	assert_int(real_locks).is_greater(0)
	assert_str(str(director.snapshot().rules[0].id)).is_equal("gust")
	assert_int(director.snapshot().runtime.executions).is_greater(200)
	assert_int(director.snapshot().runtime.failures).is_equal(0)
