extends GdUnitTestSuite
## Actual Beehave execution plus authored turn/control/storage semantics.

class Counter extends RefCounted:
	var calls: int = 0
	func increment(amount: int) -> int:
		calls += amount
		return calls

func _catalog() -> GameCatalog:
	return WtContent.new().load_catalog()

func _level(width: int = 2, depth: int = 2) -> LevelData:
	var level := LevelData.new()
	level.id = &"turn_contract"
	var spec := BoardSpec.new()
	spec.size = Vector3i(width, 6, depth)
	spec.h_play = 3
	spec.down = BoardState.Down.Y_NEG
	spec.mask.resize(width * depth)
	spec.mask.fill(1)
	spec.spawn_anchor = Vector2i((width - 1) / 2, (depth - 1) / 2)
	level.boards.append(spec)
	level.pieces = {"shapes": PackedStringArray(["mono"])}
	level.goal = {"type": "clear_n", "n": 99}
	level.knobs = {&"goal.countdown_ms": 0, &"fall.hard_drop_grace_ms": 0, &"fall.entry_delay_ms": 0, &"clear.enabled": false}
	return level

func _kit_level() -> LevelData:
	var level: LevelData = _level()
	level.pieces = {"kit": PackedStringArray(["mono", "mono", "duo"])}
	level.knobs[&"spawn.arrival"] = "kit_box"
	level.knobs[&"goal.top_out"] = "piece_budget"
	level.rules = [{"id": "undo_reset"}]
	return level

func _command(sim: BoardSim, kind: StringName, args: Array = []) -> Array[SimEvent]:
	sim.queue_command(SimCommand.make(kind, args))
	return sim.step()

func test_actual_beehave_manual_tree_runs_action_and_disposes_nodes() -> void:
	var runtime := RuleRuntime.new()
	var counter := Counter.new()
	assert_that(runtime.tree).is_instanceof(BeehaveTree)
	assert_that(runtime.tree.get_child(0)).is_instanceof(ActionLeaf)
	assert_bool(runtime.tree.is_inside_tree()).is_false()
	assert_int(runtime.tree.process_thread).is_equal(BeehaveTree.ProcessThread.MANUAL)
	assert_int(int(runtime.execute(counter, &"increment", [3]))).is_equal(3)
	assert_int(counter.calls).is_equal(3)
	assert_int(runtime.snapshot()["executions"]).is_equal(1)
	assert_int(runtime.snapshot()["failures"]).is_equal(0)
	assert_int(runtime.tree.status).is_equal(BeehaveTree.SUCCESS)
	var owned: Node = runtime.tree
	runtime.dispose()
	assert_bool(is_instance_valid(owned)).is_false()

func test_kit_waits_for_valid_selection_and_consumes_each_copy_once() -> void:
	var sim := BoardSim.new(_kit_level(), 41, _catalog())
	sim.step()
	assert_int(sim.get_phase()).is_equal(BoardSim.Phase.SELECTING)
	assert_that(sim.get_piece()).is_null()
	assert_int(sim.selection_remaining()).is_equal(3)
	_command(sim, SimEvents.CMD_PICK_SHAPE, ["not_a_shape"])
	assert_int(sim.selection_remaining()).is_equal(3)
	_command(sim, SimEvents.CMD_PICK_SHAPE, [{"shape_id": "duo"}])
	assert_str(String(sim.get_piece().shape.shape_id)).is_equal("duo")
	assert_int(sim.selection_remaining()).is_equal(2)
	_command(sim, SimEvents.CMD_HARD_DROP)
	assert_int(sim.goal_state().locks).is_equal(1)
	assert_int(sim.get_phase()).is_equal(BoardSim.Phase.SELECTING)
	_command(sim, SimEvents.CMD_PICK_SHAPE, ["duo"])
	assert_that(sim.get_piece()).is_null()
	assert_int(sim.selection_remaining()).is_equal(2)

func test_undo_restores_board_inventory_uid_and_budget_without_rewinding_time() -> void:
	var sim := BoardSim.new(_kit_level(), 41, _catalog())
	sim.step()
	_command(sim, SimEvents.CMD_PICK_SHAPE, ["duo"])
	_command(sim, SimEvents.CMD_HARD_DROP)
	var elapsed: int = sim.elapsed_ms()
	assert_int(sim.board().stack_height()).is_equal(0)
	_command(sim, SimEvents.CMD_UNDO)
	assert_int(sim.goal_state().locks).is_equal(0)
	assert_int(sim.selection_remaining()).is_equal(3)
	assert_int(sim.board().stack_height()).is_equal(-1)
	assert_int(sim.elapsed_ms()).is_greater_equal(elapsed)
	_command(sim, SimEvents.CMD_PICK_SHAPE, ["duo"])
	_command(sim, SimEvents.CMD_HARD_DROP)
	assert_int(sim.goal_state().locks).is_equal(1)
	assert_int(sim.board().get_record(sim.board().index(Vector3i.ZERO))["piece_instance_id"]).is_equal(1)
	_command(sim, SimEvents.CMD_RESET)
	assert_int(sim.goal_state().locks).is_equal(0)
	assert_int(sim.selection_remaining()).is_equal(3)
	assert_int(sim.elapsed_ms()).is_equal(0)

func test_same_turn_command_log_preserves_hash_through_undo_and_reset() -> void:
	var a := BoardSim.new(_kit_level(), 7, _catalog())
	var b := BoardSim.new(_kit_level(), 7, _catalog())
	a.step(); b.step()
	for command: Dictionary in [{"kind": SimEvents.CMD_PICK_SHAPE, "args": ["mono"]}, {"kind": SimEvents.CMD_HARD_DROP},
		{"kind": SimEvents.CMD_UNDO}, {"kind": SimEvents.CMD_PICK_SHAPE, "args": ["duo"]},
		{"kind": SimEvents.CMD_HARD_DROP}, {"kind": SimEvents.CMD_RESET}]:
		var ae: Array[SimEvent] = _command(a, command["kind"], command.get("args", []))
		var be: Array[SimEvent] = _command(b, command["kind"], command.get("args", []))
		assert_int(ae.size()).is_equal(be.size())
		assert_int(a.state_hash()).is_equal(b.state_hash())

func test_last_kit_piece_goal_wins_before_exhaustion() -> void:
	var level: LevelData = _kit_level()
	level.boards[0].size = Vector3i(1, 6, 1)
	level.boards[0].mask = PackedByteArray([1])
	level.boards[0].spawn_anchor = Vector2i.ZERO
	level.pieces = {"kit": PackedStringArray(["mono", "mono"])}
	level.goal = {"type": "clear_n", "n": 2, "piece_budget": 2}
	level.knobs[&"clear.enabled"] = true
	var sim := BoardSim.new(level, 3, _catalog())
	sim.step()
	for i: int in 2:
		_command(sim, SimEvents.CMD_PICK_SHAPE, ["mono"])
		_command(sim, SimEvents.CMD_HARD_DROP)
		for tick: int in 120:
			if sim.get_phase() in [BoardSim.Phase.SELECTING, BoardSim.Phase.ENDED]: break
			sim.step()
	assert_that(sim.result()).is_not_null()
	assert_bool(sim.result().is_won()).is_true()

func test_curling_flick_stops_at_wall_and_consumes_one_successful_use() -> void:
	var level: LevelData = _level(1, 5)
	level.knobs[&"control.verb"] = "curling_flick"
	level.knobs[&"control.flick_per_piece"] = 1
	level.knobs[&"control.flick_dirs"] = ["+z", "-z"]
	var sim := BoardSim.new(level, 3, _catalog())
	sim.step()
	sim.get_piece().pivot = Vector3i.ZERO
	sim._phase = BoardSim.Phase.RESTING
	sim._lock_deadline = 10000
	_command(sim, SimEvents.CMD_FLICK, [Vector3i(0, 0, 1)])
	assert_that(sim.get_piece().pivot).is_equal(Vector3i(0, 0, 4))
	assert_int(sim.capabilities()["flicks_left"]).is_equal(0)
	_command(sim, SimEvents.CMD_FLICK, [Vector3i(0, 0, -1)])
	assert_that(sim.get_piece().pivot).is_equal(Vector3i(0, 0, 4))

func test_flick_over_gap_drops_and_ends_at_first_gap() -> void:
	var level: LevelData = _level(1, 5)
	level.knobs[&"control.verb"] = "curling_flick"
	level.knobs[&"control.flick_per_piece"] = 1
	var sim := BoardSim.new(level, 3, _catalog())
	sim.step()
	sim.board().place(sim.board().index(Vector3i.ZERO), 1, 1, 99)
	sim.get_piece().pivot = Vector3i(0, 1, 0)
	sim._phase = BoardSim.Phase.RESTING
	sim._lock_deadline = 10000
	_command(sim, SimEvents.CMD_FLICK, [Vector3i(0, 0, 1)])
	assert_that(sim.get_piece().pivot).is_equal(Vector3i(0, 0, 1))

func test_choose_down_changes_piece_travel_without_changing_stack_gravity() -> void:
	var level: LevelData = _level(3, 3)
	level.knobs[&"control.verb"] = "choose_down"
	level.knobs[&"control.travel_dirs"] = ["down", "-x", "+x", "-z", "+z"]
	var sim := BoardSim.new(level, 3, _catalog())
	sim.step()
	sim.get_piece().pivot = Vector3i(1, 1, 1)
	_command(sim, SimEvents.CMD_CHOOSE_DOWN, [Vector3i.LEFT])
	assert_that(sim.ghost_cells()[0]).is_equal(Vector3i(0, 1, 1))
	_command(sim, SimEvents.CMD_HARD_DROP)
	assert_that(sim.board().down_vector()).is_equal(Vector3i.DOWN)
	assert_int(sim.board().get_kind(sim.board().index(Vector3i(0, 1, 1)))).is_greater(0)
	assert_int(sim.board().get_kind(sim.board().index(Vector3i(0, 0, 1)))).is_equal(0)

func test_true_bag_metadata_survives_lookahead_and_injected_helpers() -> void:
	var spawner := Spawner.new({"shapes": PackedStringArray(["mono", "duo"]), "weights": {"mono": 2, "duo": 1}}, 5, 77)
	for i: int in 9:
		if i == 4:
			spawner.inject_front(PackedStringArray(["mono"]))
			spawner.next()
			assert_int(spawner.last_bag_info()["id"]).is_equal(-1)
			assert_bool(spawner.last_bag_info()["injected"]).is_true()
		spawner.next()
		assert_int(spawner.last_bag_info()["id"]).is_equal(i / 3)
		assert_int(spawner.last_bag_info()["index"]).is_equal(i % 3)
		assert_int(spawner.last_bag_info()["size"]).is_equal(3)

func test_fixed_piece_tags_follow_each_dealt_entry_and_restore() -> void:
	var spawner := Spawner.new({"fixed_list": PackedStringArray(["mono", "duo"]), "fixed_tags": [["ember"], []]}, 3, 4)
	var saved: Dictionary = spawner.snapshot().duplicate(true)
	spawner.next()
	assert_bool(spawner.last_bag_info()["tags"].has("ember")).is_true()
	spawner.next()
	assert_bool(spawner.last_bag_info()["tags"].is_empty()).is_true()
	spawner.restore(saved)
	spawner.next()
	assert_bool(spawner.last_bag_info()["tags"].has("ember")).is_true()

func test_static_geometry_keeps_collision_without_blocking_clear_denominator() -> void:
	var sim := BoardSim.new(_level(), 8, _catalog())
	var board: BoardState = sim.board()
	board.place(board.index(Vector3i.ZERO), 1, 0, 0)
	board.set_status(board.index(Vector3i.ZERO), {"fixed": true, "anchored": true, "static_geometry": true, "fills_layer": false})
	for c: Vector3i in [Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(1, 0, 1)]:
		board.place(board.index(c), 1, 1, 1)
	assert_int(board.active_in_layer(0)).is_equal(3)
	assert_bool(board.layer_full(0)).is_true()
	assert_bool(board.is_free(Vector3i.ZERO)).is_false()
	board.remove(board.index(Vector3i.ZERO), BoardState.Cause.CLEAR)
	assert_int(board.get_kind(board.index(Vector3i.ZERO))).is_equal(1)

func test_damage_hp_vines_and_floor_preserve_distinct_mutation_causes() -> void:
	var sim := BoardSim.new(_level(), 8, _catalog())
	var board: BoardState = sim.board()
	var i: int = board.index(Vector3i.ZERO)
	board.place(i, 1, 1, 1)
	board.set_status(i, {"hits_left": 2, "clear_protected": true, "fills_layer": false})
	board.remove(i, BoardState.Cause.DAMAGE)
	assert_int(board.get_kind(i)).is_equal(1)
	assert_int(board.get_record(i)["status"]["hits_left"]).is_equal(1)
	board.remove(i, BoardState.Cause.DAMAGE)
	assert_int(board.get_kind(i)).is_equal(0)
	board.place(i, 1, 1, 2)
	board.set_status(i, {"vined": true})
	board.remove(i, BoardState.Cause.TRIM)
	assert_int(board.get_kind(i)).is_equal(1)
	board.move(i, board.index(Vector3i(1, 0, 0)))
	assert_int(board.get_kind(i)).is_equal(0)
	board.set_floor(1)
	assert_int(board.floor_layer()).is_equal(1)
	assert_bool(board.is_free(Vector3i(1, 0, 0))).is_false()
	assert_int(board.get_kind(board.index(Vector3i(1, 0, 0)))).is_equal(0)
	assert_int(sim.goal_state().layers_cleared).is_equal(0)

func test_weighted_random_distribution_and_history_repeat_bound_match_gdd() -> void:
	var random := Spawner.new({"shapes": PackedStringArray(["a", "b"]), "weights": {"a": 1, "b": 3}}, 3, 1739, {"randomizer": "random"})
	var b_count: int = 0
	for i: int in 10000:
		if random.next() == &"b": b_count += 1
	assert_int(b_count).is_between(7300, 7700)
	var history := Spawner.new({"shapes": PackedStringArray(["a", "b", "c", "d", "e", "f", "g", "h"])}, 5, 1739, {"randomizer": "history", "history_len": 4, "history_tries": 4})
	var recent: Array[StringName] = []
	var repeats: int = 0
	for i: int in 10000:
		var id: StringName = history.next()
		if recent.has(id): repeats += 1
		recent.append(id)
		if recent.size() > 4: recent.pop_front()
	assert_int(repeats).is_less_equal(700)

func test_history_roll_single_shape_and_snapshot_restore_remain_deterministic() -> void:
	var single := Spawner.new({"shapes": PackedStringArray(["a"])}, 3, 11, {"randomizer": "history", "history_len": 8})
	for i: int in 200:
		assert_str(String(single.next())).is_equal("a")
	var pieces: Dictionary = {"shapes": PackedStringArray(["a", "b", "c"])}
	var a := Spawner.new(pieces, 5, 11, {"randomizer": "history"})
	for i: int in 19: a.next()
	var saved: Dictionary = a.snapshot().duplicate(true)
	var expected: PackedStringArray = PackedStringArray()
	for i: int in 200: expected.append(String(a.next()))
	a.restore(saved)
	for id: String in expected: assert_str(String(a.next())).is_equal(id)

func test_injected_helper_does_not_advance_generated_stream_or_rng() -> void:
	var pieces: Dictionary = {"shapes": PackedStringArray(["a", "b", "c"])}
	var a := Spawner.new(pieces, 3, 21, {"randomizer": "random"})
	var b := Spawner.new(pieces, 3, 21, {"randomizer": "random"})
	var before: Dictionary = a.snapshot().duplicate(true)
	a.inject_front(PackedStringArray(["helper"]))
	assert_str(String(a.next())).is_equal("helper")
	assert_int(a.snapshot()["generated_count"]).is_equal(before["generated_count"])
	assert_int(a.snapshot()["random_rng"]).is_equal(before["random_rng"])
	for i: int in 100:
		assert_str(String(a.next())).is_equal(String(b.next()))
		assert_int(a.last_bag_info()["stream_index"]).is_equal(i)

func test_lucky_bag_initial_generation_respects_higher_mechanic_choice() -> void:
	var catalog: GameCatalog = _catalog()
	var perk := RuleDef.new()
	perk.id = &"test_bag_perk"; perk.layer = &"perk"
	perk.modifiers = [{"knob": "spawn.randomizer", "op": "set", "value": "bag"}]
	catalog.rule_defs[perk.id] = perk
	var mechanic := RuleDef.new()
	mechanic.id = &"test_random_mechanic"; mechanic.layer = &"mechanic"
	mechanic.modifiers = [{"knob": "spawn.randomizer", "op": "set", "value": "random"}]
	catalog.rule_defs[mechanic.id] = mechanic
	var level: LevelData = _level()
	level.knobs[&"spawn.randomizer"] = "random"
	level.rules = [{"id": perk.id}]
	var a := BoardSim.new(level, 5, catalog)
	assert_str(String(a._spawner.snapshot()["mode"])).is_equal("bag")
	level.rules.append({"id": mechanic.id})
	var b := BoardSim.new(level, 5, catalog)
	assert_str(String(b._spawner.snapshot()["mode"])).is_equal("random")

func test_runtime_twists_replace_at_tick_boundary_and_discard_old_requests() -> void:
	var level: LevelData = _level()
	level.rules = [{"id": "gust", "params": {"wind_interval_ms": 100000}}, {"id": "undo_reset"}]
	var sim := BoardSim.new(level, 9, _catalog())
	sim.step()
	var old_api: RuleApi
	var retained_api: RuleApi
	for rule: Dictionary in sim._rules:
		if rule["id"] == &"gust": old_api = rule["api"]
		if rule["id"] == &"undo_reset": retained_api = rule["api"]
	old_api.request_height_limit(1)
	old_api.set_cell(Vector3i.ZERO, 1, 2, 2)
	sim._collect_api(old_api, false, 3)
	sim.set_rule_definitions([{"id": "wobble"}])
	assert_bool(sim.get_api().rule_active(&"gust")).is_true()
	var events: Array[SimEvent] = sim.step()
	assert_bool(sim.get_api().rule_active(&"gust")).is_false()
	assert_bool(sim.get_api().rule_active(&"wobble")).is_true()
	assert_bool(sim.get_api().rule_active(&"undo_reset")).is_true()
	for rule: Dictionary in sim._rules:
		if rule["id"] == &"undo_reset": assert_that(rule["api"]).is_same(retained_api)
	assert_int(sim.board().h_play()).is_equal(3)
	assert_int(sim.board().get_kind(sim.board().index(Vector3i.ZERO))).is_equal(0)
	var lifecycle: PackedStringArray = PackedStringArray()
	for event: SimEvent in events:
		if event.kind in [SimEvents.RULE_STARTED, SimEvents.RULE_ENDED]: lifecycle.append(String(event.data["id"]))
	assert_bool(lifecycle.has("gust")).is_true()
	assert_bool(lifecycle.has("wobble")).is_true()

func test_stage_goal_change_does_not_mutate_cached_source_level() -> void:
	var level: LevelData = _level()
	level.goal = {"type": "height", "height": 99}
	level.knobs[&"goal.type"] = "height"
	var catalog: GameCatalog = _catalog()
	var a := BoardSim.new(level, 7, catalog)
	a.step()
	a.get_api().request_goal({"type": "clear_n", "n": 5})
	a._collect_api(a.get_api(), true)
	a._apply_structural()
	assert_str(String(a.get_api().goal_config()["type"])).is_equal("clear_n")
	assert_str(String(level.goal["type"])).is_equal("height")
	var b := BoardSim.new(level, 7, catalog)
	assert_str(String(b.get_api().goal_config()["type"])).is_equal("height")
	assert_str(String(b.knobs().value(&"goal.type"))).is_equal("height")

func test_dynamic_item_modifiers_compose_and_higher_choice_prevents_effect() -> void:
	var catalog: GameCatalog = _catalog()
	var item := RuleDef.new(); item.id = &"test_item"; item.layer = &"item_buff"
	catalog.rule_defs[item.id] = item
	var mechanic := RuleDef.new(); mechanic.id = &"test_mechanic"; mechanic.layer = &"mechanic"
	mechanic.modifiers = [{"knob": "fall.gravity_scale", "op": "mul", "value": 1.5}, {"knob": "spawn.hold_enabled", "op": "set", "value": false}]
	catalog.rule_defs[mechanic.id] = mechanic
	var level: LevelData = _level(); level.rules = [{"id": item.id}, {"id": mechanic.id}]
	var sim := BoardSim.new(level, 7, catalog)
	var api: RuleApi = sim._rules[0]["api"]
	var slow: Array[Dictionary] = [{"knob": "fall.gravity_scale", "op": "mul", "value": 0.5}]
	var hold: Array[Dictionary] = [{"knob": "spawn.hold_enabled", "op": "set", "value": true}]
	assert_bool(api.modifiers_would_change(slow)).is_true()
	assert_bool(api.modifiers_would_change(hold)).is_false()
	api.request_modifiers(&"slow", slow)
	sim._collect_api(api, true, 2)
	assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(750)
	api.clear_modifiers(&"slow")
	sim._collect_api(api, true, 2)
	assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(1500)

func test_expiring_hold_returns_tagged_hued_piece_ahead_of_unchanged_queue() -> void:
	var level: LevelData = _level(4, 4)
	level.pieces = {"fixed_list": PackedStringArray(["mono", "duo", "mono", "duo"])}
	level.knobs[&"spawn.hold_enabled"] = true
	var sim := BoardSim.new(level, 7, _catalog())
	sim.step()
	sim.get_api().set_piece_flag(&"tags", PackedStringArray(["ember"]))
	sim._collect_api(sim.get_api(), true)
	var hue: int = sim.get_piece().hue_id
	_command(sim, SimEvents.CMD_HOLD)
	assert_str(String(sim.held_shape())).is_equal("mono")
	assert_str(String(sim.get_piece().shape.shape_id)).is_equal("duo")
	sim.get_api().request_slot(&"spawn.hold_enabled", false)
	sim._collect_api(sim.get_api(), true)
	_command(sim, SimEvents.CMD_HARD_DROP)
	assert_str(String(sim.held_shape())).is_equal("")
	assert_str(String(sim.get_piece().shape.shape_id)).is_equal("mono")
	assert_int(sim.get_piece().hue_id).is_equal(hue)
	assert_bool(sim.get_api().piece_flag(&"tags", PackedStringArray()).has("ember")).is_true()
	assert_bool(sim.get_api().piece_flag(&"injected", false)).is_true()
	assert_str(String(sim.preview(1)[0])).is_equal("mono")

func test_post_clear_damage_waits_for_structure_and_never_adds_clear_credit() -> void:
	var sim := BoardSim.new(_level(), 9, _catalog())
	var cell := Vector3i.ZERO
	sim.board().place(sim.board().index(cell), 1, 2, 1)
	sim.board().set_status(sim.board().index(cell), {"hits_left": 2})
	sim.get_api().request_post_clear_damage([cell, Vector3i(-1, -1, -1)], 2)
	sim._collect_api(sim.get_api(), true)
	assert_int(sim.board().get_kind(sim.board().index(cell))).is_equal(1)
	sim._apply_structural()
	assert_int(sim.board().get_kind(sim.board().index(cell))).is_equal(0)
	assert_int(sim.goal_state().layers_cleared).is_equal(0)
	assert_int(sim.score()).is_equal(0)

func test_shape_pool_growth_preserves_preview_metadata_and_incomplete_bag() -> void:
	var spawner := Spawner.new({"shapes": PackedStringArray(["a", "b"])}, 1, 8)
	var before: Dictionary = spawner.snapshot().duplicate(true)
	assert_bool(spawner.set_shape_pool(PackedStringArray(["c", "d"]))).is_true()
	var after: Dictionary = spawner.snapshot().duplicate(true)
	for field: String in ["queue", "queue_info", "bag", "bag_index", "generated_count", "random_rng"]:
		assert_that(after[field]).is_equal(before[field])
	for i: int in 2:
		assert_bool(spawner.next() in [&"a", &"b"]).is_true()
		assert_int(spawner.last_bag_info()["id"]).is_equal(0)
	for i: int in 2:
		assert_bool(spawner.next() in [&"c", &"d"]).is_true()
		assert_int(spawner.last_bag_info()["id"]).is_equal(1)
		assert_int(spawner.last_bag_info()["index"]).is_equal(i)
	spawner.restore(before)
	assert_that(spawner.shape_pool()).is_equal(PackedStringArray(["a", "b"]))

func test_simulation_pool_change_waits_for_safe_phase_and_keeps_hues() -> void:
	var sim := BoardSim.new(_level(4, 4), 8, _catalog())
	sim.step()
	var preview: PackedStringArray = sim.get_api().preview_ids(3)
	var hues: PackedInt32Array = sim.preview_hues(3)
	assert_bool(sim.set_shape_pool(PackedStringArray(["mono", "duo"]))).is_true()
	sim.step()
	assert_that(sim.get_api().shape_pool()).is_equal(PackedStringArray(["mono"]))
	assert_that(sim.get_api().preview_ids(3)).is_equal(preview)
	assert_that(sim.preview_hues(3)).is_equal(hues)
	_command(sim, SimEvents.CMD_HARD_DROP)
	assert_that(sim.get_api().shape_pool()).is_equal(PackedStringArray(["mono", "duo"]))

func test_removing_axis_flip_waits_for_resolving_then_restores_gravity_and_settles() -> void:
	var level: LevelData = _level(4, 4)
	level.rules = [{"id": "flip", "params": {"flip_mode": "axis", "flip_every_ms": 100000}}]
	level.knobs[&"fall.entry_delay_ms"] = 500
	var sim := BoardSim.new(level, 8, _catalog())
	sim.step()
	_command(sim, SimEvents.CMD_HARD_DROP)
	sim.board().set_down(BoardState.Down.X_NEG)
	var c := Vector3i(0, 2, 2)
	sim.board().place(sim.board().index(c), 1, 1, 89)
	sim.set_rule_definitions([])
	sim.step()
	assert_that(sim.board().down_vector()).is_equal(Vector3i.DOWN)
	assert_int(sim.board().get_kind(sim.board().index(c))).is_equal(0)
	assert_int(sim.board().get_record(sim.board().index(Vector3i(0, 0, 2)))["piece_instance_id"]).is_equal(89)
	assert_bool(sim.get_api().rule_active(&"flip")).is_false()

func test_junk_layer_gap_uses_only_the_issuing_rule_seed() -> void:
	var a := BoardSim.new(_level(4, 4), 3, _catalog())
	var b := BoardSim.new(_level(4, 4), 99, _catalog())
	var arng: int = a._spawner.snapshot()["random_rng"]
	var brng: int = b._spawner.snapshot()["random_rng"]
	a.get_api().request_junk_layers(1, 887)
	b.get_api().request_junk_layers(1, 887)
	a._collect_api(a.get_api(), true); b._collect_api(b.get_api(), true)
	a._apply_structural(); b._apply_structural()
	assert_that(a.board().snapshot()["kind"]).is_equal(b.board().snapshot()["kind"])
	assert_int(a.board().filled_in_layer(0)).is_equal(15)
	assert_int(a._spawner.snapshot()["random_rng"]).is_equal(arng)
	assert_int(b._spawner.snapshot()["random_rng"]).is_equal(brng)

func test_nested_rule_helpers_restore_and_absolute_deadlines_rebase() -> void:
	var rule := ConveyorRule.new()
	rule._belt._locks = 7
	var state: Dictionary = rule.snapshot().duplicate(true)
	rule._belt._locks = 19
	rule.restore(state)
	assert_int(rule.snapshot()["locks"]).is_equal(7)
	var gust := GustRule.new()
	gust._due = 3000
	gust.restore({"due": 1000, "warned": true, "direction": Vector3i.LEFT})
	gust.rebase_time(600)
	assert_int(gust.snapshot()["due"]).is_equal(1600)
	assert_bool(gust.snapshot()["warned"]).is_true()
