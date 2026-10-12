extends GdUnitTestSuite
## Covers the actual loader -> catalog -> rules -> spawner -> simulation path.


func test_meadow_authored_levels_spawn_and_resolve_multiple_locks() -> void:
	var content := WtContent.new()
	var catalog: GameCatalog = content.load_catalog()
	assert_array(Array(content.errors)).is_empty()
	var checked: int = 0
	for entry: Dictionary in content.all_levels():
		if String(entry.get("biome", "")) != "meadow":
			continue
		var level: LevelData = content.level(String(entry["id"]))
		assert_that(level).override_failure_message("loader rejected " + String(entry["id"]) + ": " + str(content.last_issues)).is_not_null()
		if level == null:
			continue
		var sim := BoardSim.new(level, 1729, catalog)
		var goal_kind: String = String(level.goal.get("type", "clear_n"))
		assert_str(String(sim.knobs().value(&"goal.type"))).is_equal("clear_n" if goal_kind == "clear" else goal_kind)
		assert_array(Array(sim.knobs().errors())).override_failure_message(String(level.id) + " knob unit mismatch").is_empty()
		for tick: int in 320:
			sim.step()
			if sim.get_piece() != null or sim.result() != null:
				break
		assert_that(sim.get_piece()).override_failure_message(String(level.id) + " failed its first spawn").is_not_null()
		for lock_no: int in 3:
			if sim.result() != null:
				break
			for tick: int in 220:
				if sim.get_piece() != null:
					break
				sim.step()
			sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
			sim.step()
			# Second press commits grace; no lock can be counted twice.
			sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
			sim.step()
			for tick: int in 180:
				if sim.get_piece() != null or sim.result() != null:
					break
				sim.step()
		assert_int(sim.goal_state().locks).override_failure_message(String(level.id) + " never completed a lock").is_greater(0)
		checked += 1
	assert_int(checked).is_greater_equal(11)


func test_official_meadow_fixed_point_gravity_is_not_converted_twice() -> void:
	var content := WtContent.new()
	var catalog: GameCatalog = content.load_catalog()
	var level: LevelData = content.level("meadow_01")
	var sim := BoardSim.new(level, 1, catalog)
	assert_int(level.knobs[&"fall.g0"]).is_equal(600)
	assert_int(sim.knobs().int_value(&"fall.g0")).is_equal(600)
	assert_array(Array(sim.knobs().errors())).is_empty()
	assert_bool(level.pieces.get("fixed_list", PackedStringArray()).is_empty()).is_true()
	for tick: int in 181:
		sim.step()
	assert_that(sim.get_piece()).is_not_null()
	assert_that(sim.result()).is_null()


func test_meadow_four_cell_beam_fits_default_even_width_anchor() -> void:
	var content := WtContent.new()
	var catalog: GameCatalog = content.load_catalog()
	var level: LevelData = content.level("meadow_01")
	level.knobs[&"goal.countdown_ms"] = 0
	level.pieces = {"fixed_list": PackedStringArray(["i"])}
	var sim := BoardSim.new(level, 7, catalog)
	sim.step()
	assert_that(sim.get_piece()).is_not_null()
	if sim.get_piece() == null:
		return
	assert_int(sim.get_piece().cells().size()).is_equal(4)
	assert_bool(sim.board().can_place(sim.get_piece().cells())).is_true()
	var minimum_x: int = 4
	var maximum_x: int = -1
	for cell: Vector3i in sim.get_piece().cells():
		minimum_x = mini(minimum_x, cell.x)
		maximum_x = maxi(maximum_x, cell.x)
	assert_int(minimum_x).is_equal(0)
	assert_int(maximum_x).is_equal(3)


func test_every_official_campaign_entry_loads_and_spawns_a_real_shape() -> void:
	var content := WtContent.new()
	var catalog: GameCatalog = content.load_catalog()
	assert_array(Array(content.errors)).is_empty()
	var checked: int = 0
	for entry: Dictionary in content.all_levels():
		var id: String = String(entry["id"])
		var level: LevelData = content.level(id)
		assert_that(level).override_failure_message("official level rejected: " + id + "; " + str(content.last_issues)).is_not_null()
		if level == null:
			continue
		var sim := BoardSim.new(level, 1729, catalog)
		assert_array(Array(sim.knobs().errors())).override_failure_message(id + " knob conversion: " + str(sim.knobs().errors())).is_empty()
		for tick: int in 340:
			sim.step()
			if sim.get_phase() == BoardSim.Phase.SELECTING and not sim.kit_choices().is_empty():
				sim.queue_command(SimCommand.make(SimEvents.CMD_PICK_SHAPE, [sim.kit_choices()[0]["shape_id"]]))
			if sim.get_piece() != null or sim.result() != null:
				break
		assert_that(sim.get_piece()).override_failure_message(id + " never spawned a piece; goal=" + str(level.goal)).is_not_null()
		if sim.get_piece() != null:
			assert_bool(sim.board().can_place(sim.get_piece().cells())).override_failure_message(id + " spawned illegally").is_true()
		checked += 1
	assert_int(checked).is_greater_equal(100)
