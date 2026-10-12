extends GdUnitTestSuite
## Executable gameplay contracts from ADR-0001/0004/0011 and Fall/Goals/Clearing GDDs.

class _FillAfterResolve extends RuleBehaviour:
	var calls: int = 0
	func subscribed_hooks() -> Array[StringName]:
		return [&"on_resolve_end"]
	func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
		calls += 1
		api.set_cell(Vector3i.ZERO, api.kind_of(&"block"), 2)
	func snapshot() -> Dictionary:
		return {"calls": calls}


func _catalog() -> GameCatalog:
	var catalog := GameCatalog.new()
	catalog.shapes = ShapeBank.new()
	var offsets: Array[Vector3i] = [Vector3i.ZERO]
	var shape: ShapeDef = ShapeDef.build(&"test_cube", offsets)
	shape.hue_id = 3
	catalog.shapes.shapes.append(shape)
	catalog.content = ContentTypes.from_entries([
		{"id": "block", "kind_id": 1, "mesh": "", "glyph": "#", "slot": "cell", "solid": true, "fills_layer": true, "hue": 1}])
	var tables: Array = JsonReader.read_dir("res://assets/data/knobs")["files"].values()
	catalog.knob_defs = KnobDefs.from_tables(tables)
	catalog.plugins = PluginRegistry.new(ProjectSettings.get_global_class_list())
	return catalog


func _level(clear_enabled: bool = true) -> LevelData:
	var level := LevelData.new()
	level.id = &"test_level"
	var board := BoardSpec.new()
	board.size = Vector3i(1, 5, 1)
	board.h_play = 2
	board.down = BoardState.Down.Y_NEG
	board.mask = PackedByteArray([1])
	level.boards.append(board)
	level.pieces = {"shapes": PackedStringArray(["test_cube"])}
	level.knobs = {&"goal.countdown_ms": 0, &"fall.entry_delay_ms": 0,
		&"fall.hard_drop_grace_ms": 0, &"clear.enabled": clear_enabled}
	level.goal = {"n": 3}
	level.stars = {"t2": 10000, "t3": 5000}
	return level


func _drop(sim: BoardSim) -> Array[SimEvent]:
	sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
	return sim.step()


func _await_spawn(sim: BoardSim) -> void:
	for tick: int in 120:
		if sim.get_piece() != null or sim.get_phase() == BoardSim.Phase.ENDED:
			return
		sim.step()


func test_countdown_excludes_clock_and_hard_drop_locks_on_command_tick() -> void:
	var level: LevelData = _level()
	level.knobs[&"goal.countdown_ms"] = 500
	var sim := BoardSim.new(level, 1, _catalog())
	for tick: int in 29:
		sim.step()
	assert_that(sim.get_piece()).is_null()
	assert_int(sim.elapsed_ms()).is_equal(0)
	sim.step()
	assert_that(sim.get_piece()).is_not_null()
	assert_int(sim.elapsed_ms()).is_equal(0)
	var events: Array[SimEvent] = _drop(sim)
	var locked: bool = false
	for event: SimEvent in events:
		locked = locked or event.kind == SimEvents.PIECE_LOCKED
	assert_bool(locked).is_true()
	assert_int(sim.goal_state().locks).is_equal(1)
	assert_int(sim.goal_state().layers_cleared).is_equal(1)
	assert_that(sim.get_piece()).is_null()


func test_three_locks_clear_goal_and_emit_one_typed_result() -> void:
	var sim := BoardSim.new(_level(), 11, _catalog())
	sim.step()
	for lock_no: int in 3:
		_await_spawn(sim)
		_drop(sim)
	var results: int = 0
	for tick: int in 120:
		for event: SimEvent in sim.step():
			if event.kind == SimEvents.LEVEL_RESULT:
				results += 1
		if sim.result() != null:
			break
	assert_int(results).is_equal(1)
	assert_bool(sim.result().is_won()).is_true()
	assert_int(sim.result().layers_cleared).is_equal(3)
	assert_int(sim.result().pieces_placed).is_equal(3)
	assert_int(sim.result().stars).is_equal(3)
	for tick: int in 3:
		assert_array(sim.step()).is_empty()


func test_goal_wins_before_topout_on_same_lock() -> void:
	var level: LevelData = _level(false)
	level.boards[0].contents = [{"cell": Vector3i(0, 0, 0), "kind": 1}, {"cell": Vector3i(0, 1, 0), "kind": 1}]
	level.knobs[&"goal.type"] = "height"
	level.knobs[&"goal.top_out"] = "lose"
	level.goal = {"h_target": 3, "coverage": 1.0}
	var sim := BoardSim.new(level, 9, _catalog())
	sim.step()
	_drop(sim)
	for tick: int in 4:
		sim.step()
	assert_bool(sim.result().is_won()).is_true()
	assert_int(sim.goal_state().warnings_left).is_equal(1)


func test_survive_clock_is_checked_every_tick() -> void:
	var level: LevelData = _level(false)
	level.knobs[&"goal.type"] = "survive"
	level.goal = {"t_ms": 100}
	var sim := BoardSim.new(level, 8, _catalog())
	for tick: int in 7:
		sim.step()
	assert_bool(sim.result().is_won()).is_true()
	assert_int(sim.result().pieces_placed).is_equal(0)
	assert_int(sim.result().level_ms).is_equal(100)


func test_s4c_clears_hook_write_once_without_repeating_resolve_hook() -> void:
	var catalog: GameCatalog = _catalog()
	var sim := BoardSim.new(_level(), 7, catalog)
	var behaviour := _FillAfterResolve.new()
	var api := RuleApi.new(sim.board(), sim.knobs())
	api.configure(catalog, 7, &"test_fill")
	var definition := RuleDef.new()
	sim._rules.append({"id": &"test_fill", "rank": 2, "def": definition, "api": api, "behaviour": behaviour})
	sim.step()
	_drop(sim)
	assert_int(behaviour.calls).is_equal(1)
	assert_int(sim.goal_state().layers_cleared).is_equal(2)
	assert_int(sim.board().stack_height()).is_equal(-1)


func test_second_clear_tumble_applies_in_same_lock_structural_stage() -> void:
	var catalog: GameCatalog = _catalog()
	var sim := BoardSim.new(_level(), 7, catalog)
	var behaviour := TopsyTumbleRule.new()
	var api := RuleApi.new(sim.board(), sim.knobs(), {"flip_every_ms": 0, "flip_every_layers": 2})
	api.configure(catalog, 7, &"test_tumble")
	sim._rules.append({"id": &"test_tumble", "rank": 3, "def": RuleDef.new(), "api": api, "behaviour": behaviour})
	sim.step()
	_drop(sim)
	assert_int(behaviour.snapshot()["flips"]).is_equal(0)
	_await_spawn(sim)
	var events: Array[SimEvent] = _drop(sim)
	var flips: int = 0
	for event: SimEvent in events:
		if event.kind == &"topsy_tumble":
			flips += 1
	assert_int(flips).is_equal(1)
	assert_int(behaviour.snapshot()["flips"]).is_equal(1)
	assert_array(sim._structural).is_empty()


func test_same_seed_and_command_log_have_identical_events_and_state_hash() -> void:
	var a := BoardSim.new(_level(), 43, _catalog())
	var b := BoardSim.new(_level(), 43, _catalog())
	for tick: int in 180:
		if tick in [3, 45, 90]:
			a.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
			b.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
		var ae: Array[SimEvent] = a.step()
		var be: Array[SimEvent] = b.step()
		assert_int(ae.size()).is_equal(be.size())
		for i: int in ae.size():
			assert_bool(ae[i].equals(be[i])).is_true()
		assert_int(a.state_hash()).is_equal(b.state_hash())


func test_rule_content_writes_are_buffered_and_batch_moves_preserve_status() -> void:
	var sim := BoardSim.new(_level(false), 1, _catalog())
	var api: RuleApi = sim.get_api()
	api.set_cell(Vector3i.ZERO, 1, 2, 99)
	assert_int(api.kind_at(Vector3i.ZERO)).is_equal(0)
	assert_bool(api.flush_writes()).is_true()
	api.set_status(Vector3i.ZERO, {"status_id": 1, "counter": 3})
	api.flush_writes()
	var from: Array[Vector3i] = [Vector3i.ZERO]
	var to: Array[Vector3i] = [Vector3i(0, 1, 0)]
	api.move_cells(from, to)
	api.flush_writes()
	assert_int(api.kind_at(Vector3i.ZERO)).is_equal(0)
	assert_int(api.record_at(to[0])["piece_instance_id"]).is_equal(99)
	assert_int(api.record_at(to[0])["status"]["counter"]).is_equal(3)


func test_rotation_restriction_leaves_piece_unchanged() -> void:
	var level: LevelData = _level(false)
	level.knobs[&"control.rotation_axes_enabled"] = ["spin"]
	var sim := BoardSim.new(level, 1, _catalog())
	sim.step()
	var before: int = sim.get_piece().orient
	sim.queue_command(SimCommand.make(SimEvents.CMD_ROTATE, [Orientations.Axis.X, 1]))
	var events: Array[SimEvent] = sim.step()
	assert_int(sim.get_piece().orient).is_equal(before)
	var disabled: bool = false
	for event: SimEvent in events:
		disabled = disabled or event.data.get("result") == &"disabled"
	assert_bool(disabled).is_true()


func test_hold_is_disabled_by_default_and_one_swap_when_enabled() -> void:
	var level: LevelData = _level(false)
	var disabled := BoardSim.new(level, 7, _catalog())
	disabled.step()
	disabled.queue_command(SimCommand.make(SimEvents.CMD_HOLD))
	disabled.step()
	assert_str(String(disabled.held_shape())).is_equal("")
	level.knobs[&"spawn.hold_enabled"] = true
	var enabled := BoardSim.new(level, 7, _catalog())
	enabled.step()
	var old_uid: int = enabled._piece_uid
	enabled.queue_command(SimCommand.make(SimEvents.CMD_HOLD))
	enabled.step()
	assert_str(String(enabled.held_shape())).is_equal("test_cube")
	assert_int(enabled._piece_uid).is_equal(old_uid + 1)
	enabled.queue_command(SimCommand.make(SimEvents.CMD_HOLD))
	enabled.step()
	assert_int(enabled._piece_uid).is_equal(old_uid + 1)


func test_fixed_list_deals_exact_order_then_exhausts() -> void:
	var spawner := Spawner.new({"fixed_list": PackedStringArray(["a", "b", "a"]), "shapes": PackedStringArray(["c"])}, 3, 1)
	assert_that(spawner.peek(3)).is_equal(PackedStringArray(["a", "b", "a"]))
	assert_str(String(spawner.next())).is_equal("a")
	assert_str(String(spawner.next())).is_equal("b")
	assert_str(String(spawner.next())).is_equal("a")
	assert_str(String(spawner.next())).is_equal("")
	assert_that(spawner.peek(3)).is_equal(PackedStringArray())


func test_rescue_is_silent_and_does_not_count_as_clear() -> void:
	var level: LevelData = _level(false)
	level.boards[0].contents = [{"cell": Vector3i(0, 0, 0), "kind": 1}, {"cell": Vector3i(0, 1, 0), "kind": 1}]
	var sim := BoardSim.new(level, 2, _catalog())
	sim.step()
	var events: Array[SimEvent] = _drop(sim)
	var warning: bool = false
	var clears: int = 0
	for event: SimEvent in events:
		warning = warning or event.kind == SimEvents.TOP_OUT_WARNING
		if event.kind == SimEvents.LAYERS_CLEARED:
			clears += 1
	assert_bool(warning).is_true()
	assert_int(clears).is_equal(0)
	assert_int(sim.goal_state().layers_cleared).is_equal(0)
	assert_int(sim.goal_state().warnings_used).is_equal(1)
	assert_int(sim.board().stack_height()).is_equal(-1)
	var before: int = sim.elapsed_ms()
	for tick: int in 30:
		sim.step()
	assert_int(sim.elapsed_ms()).is_equal(before)


func test_trim_does_not_clear_or_warn_and_loses_third_star() -> void:
	var level: LevelData = _level(false)
	level.boards[0].contents = [{"cell": Vector3i(0, 0, 0), "kind": 1}, {"cell": Vector3i(0, 1, 0), "kind": 1}]
	level.knobs[&"goal.top_out"] = "trim"
	var sim := BoardSim.new(level, 2, _catalog())
	sim.step()
	_drop(sim)
	assert_int(sim.goal_state().cells_trimmed).is_equal(1)
	assert_int(sim.goal_state().warnings_used).is_equal(0)
	assert_int(sim.goal_state().layers_cleared).is_equal(0)
	var result := LevelResult.new()
	result.outcome = LevelResult.OUTCOME_WON
	result.level_ms = 100
	result.cells_trimmed = 1
	assert_int(StarRater.rate({"t2": 1000, "t3": 500}, result, false)).is_equal(2)


func test_modifier_set_priority_then_multiply_add_and_clamp() -> void:
	var registry := KnobRegistry.new(_catalog().knob_defs, {})
	var modifiers: Array[Dictionary] = [
		{"knob": "fall.gravity_scale", "op": "set", "value": 0.5},
		{"knob": "fall.gravity_scale", "op": "set", "value": 0.8},
		{"knob": "fall.gravity_scale", "op": "mul", "value": 2.0},
		{"knob": "fall.gravity_scale", "op": "add", "value": 0.2}]
	assert_array(registry.apply_modifiers(modifiers)).is_empty()
	assert_int(registry.int_value(&"fall.gravity_scale")).is_equal(1800)
	modifiers.append({"knob": "fall.gravity_scale", "op": "mul", "value": 10.0})
	assert_int(registry.apply_modifiers(modifiers).size()).is_equal(1)
	assert_int(registry.int_value(&"fall.gravity_scale")).is_equal(4000)


func test_protected_rule_write_waits_until_stack_protection_ends() -> void:
	var sim := BoardSim.new(_level(false), 1, _catalog())
	var api: RuleApi = sim.get_api()
	api.set_cell(Vector3i.ZERO, 1, 2, 99)
	api.flush_writes()
	api.remove_cell(Vector3i.ZERO, BoardState.Cause.DAMAGE)
	assert_bool(api.flush_writes(true)).is_false()
	assert_int(api.kind_at(Vector3i.ZERO)).is_equal(1)
	assert_bool(api.flush_writes(false)).is_true()
	assert_int(api.kind_at(Vector3i.ZERO)).is_equal(0)


func test_kicked_rotation_opposite_restores_original_pivot_exactly() -> void:
	var offsets: Array[Vector3i] = [Vector3i(-1, 0, 0), Vector3i.ZERO, Vector3i(1, 0, 0)]
	var shape: ShapeDef = ShapeDef.build(&"line", offsets)
	var spec := BoardSpec.new()
	spec.size = Vector3i(4, 6, 4)
	spec.h_play = 3
	spec.down = BoardState.Down.Y_NEG
	var board := BoardState.new(spec, _catalog().content)
	var orient: int = Orientations.turn(0, Orientations.Axis.Y, 1)
	var piece := ActivePiece.new(shape, Vector3i(0, 2, 1), orient)
	var original: Vector3i = piece.pivot
	var result: Dictionary = Movement.try_rotate(piece, board, Orientations.Axis.Y, -1, {})
	assert_int(result["result"]).is_equal(Movement.Result.OK)
	assert_bool(result["kicked"]).is_true()
	assert_bool(piece.pivot != original).is_true()
	var restored: Dictionary = Movement.try_rotate(piece, board, Orientations.Axis.Y, 1, {})
	assert_int(restored["result"]).is_equal(Movement.Result.OK)
	assert_that(piece.pivot).is_equal(original)
	assert_int(piece.orient).is_equal(orient)


func test_survive_clear_threshold_stars_and_clean_finish_requirement() -> void:
	var result := LevelResult.new()
	result.outcome = LevelResult.OUTCOME_WON
	result.layers_cleared = 2
	assert_int(StarRater.rate({"s2": 1, "s3": 2}, result, false)).is_equal(3)
	result.warnings_used = 1
	assert_int(StarRater.rate({"s2": 1, "s3": 2}, result, false)).is_equal(2)
	result.layers_cleared = 0
	assert_int(StarRater.rate({"s2": 1, "s3": 2}, result, false)).is_equal(1)


func test_replace_preview_preserves_future_bag_and_drawn_count() -> void:
	var pieces: Dictionary = {"shapes": PackedStringArray(["a", "b", "c"])}
	var a := Spawner.new(pieces, 3, 44)
	var b := Spawner.new(pieces, 3, 44)
	a.replace_preview(PackedStringArray(["x", "y", "z"]))
	assert_that(a.peek(3)).is_equal(PackedStringArray(["x", "y", "z"]))
	assert_int(a.drawn_count()).is_equal(0)
	for index: int in 3:
		a.next()
		b.next()
	assert_that(a.peek(3)).is_equal(b.peek(3))


func test_goal_time_limit_fails_without_lock_and_countdown_is_excluded() -> void:
	var level: LevelData = _level(false)
	level.goal["time_limit_ms"] = 100
	level.knobs[&"goal.countdown_ms"] = 500
	var sim := BoardSim.new(level, 1, _catalog())
	for tick: int in 35:
		sim.step()
	assert_that(sim.result()).is_null()
	sim.step()
	assert_bool(sim.result().is_won()).is_false()
	assert_int(sim.result().level_ms).is_equal(100)


func test_fixed_piece_hue_matches_preview_and_locked_cube() -> void:
	var level: LevelData = _level(false)
	level.pieces["fixed_list"] = PackedStringArray(["test_cube", "test_cube"])
	level.pieces["fixed_hues"] = [2, 3]
	var sim := BoardSim.new(level, 1, _catalog())
	assert_that(sim.preview_hues(2)).is_equal(PackedInt32Array([2, 3]))
	sim.step()
	assert_int(sim.get_piece().hue_id).is_equal(2)
	_drop(sim)
	assert_int(sim.board().get_color(sim.board().index(Vector3i.ZERO))).is_equal(2)
