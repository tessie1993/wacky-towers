extends GdUnitTestSuite
const Items := preload("res://src/mechanics/behaviour/items.gd")

func _level(width: int = 3, depth: int = 3, clear: bool = false) -> LevelData:
	var level := LevelData.new()
	level.id = &"items_integration"
	var spec := BoardSpec.new()
	spec.size = Vector3i(width, 8, depth)
	spec.h_play = 4
	spec.down = BoardState.Down.Y_NEG
	spec.mask.resize(width * depth)
	spec.mask.fill(1)
	spec.spawn_anchor = Vector2i((width - 1) / 2, (depth - 1) / 2)
	level.boards.append(spec)
	level.pieces = {"shapes": PackedStringArray(["mono"])}
	level.goal = {"type": "clear_n", "n": 99}
	level.knobs = {&"goal.countdown_ms": 0, &"fall.hard_drop_grace_ms": 0, &"fall.entry_delay_ms": 0, &"clear.enabled": clear}
	level.rules = [{"id": "items", "params": {"p_item": 0.5}}]
	return level

func _command(sim: BoardSim, kind: StringName, args: Array = []) -> Array[SimEvent]:
	sim.queue_command(SimCommand.make(kind, args))
	return sim.step()

func _count(board: BoardState, layer: int = -1) -> int:
	var count: int = 0
	for index: int in board.size().x * board.size().y * board.size().z:
		if board.get_kind(index) != 0 and (layer < 0 or board.layer_of(index) == layer): count += 1
	return count

func test_junk_rain_raises_exactly_one_real_layer_with_one_gap() -> void:
	var sim := BoardSim.new(_level(), 912, WtContent.new().load_catalog())
	sim.step()
	_command(sim, SimEvents.CMD_RECEIVE_ITEM, [{"effect_id": "junk_rain", "owner": 8, "token": "8:1"}])
	assert_int(_count(sim.board())).is_zero()
	_command(sim, SimEvents.CMD_HARD_DROP)
	assert_int(_count(sim.board(), 0)).is_equal(8)
	assert_int(_count(sim.board(), 1)).is_equal(1)
	assert_int(_count(sim.board())).is_equal(9)
	assert_int(sim.board().stack_height()).is_equal(1)

func test_slow_and_speed_compose_to_point_seventyfive_then_refresh_without_stacking() -> void:
	var sim := BoardSim.new(_level(), 12, WtContent.new().load_catalog())
	sim.step()
	_command(sim, SimEvents.CMD_RECEIVE_ITEM, [{"effect_id": "slow_time"}])
	assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(500)
	_command(sim, SimEvents.CMD_RECEIVE_ITEM, [{"effect_id": "speed_up"}])
	assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(750)
	_command(sim, SimEvents.CMD_RECEIVE_ITEM, [{"effect_id": "slow_time"}])
	assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(750)

func test_actual_clear_collects_one_tagged_real_cube() -> void:
	var catalog: GameCatalog = WtContent.new().load_catalog()
	var found: bool = false
	for seed_value: int in 20:
		var sim := BoardSim.new(_level(1, 1, true), seed_value, catalog)
		sim.step()
		var rule: ItemsRule = sim._rules[0].behaviour as ItemsRule
		if int(rule.snapshot().tag_index) < 0: continue
		found = true
		_command(sim, SimEvents.CMD_HARD_DROP)
		assert_int(sim.goal_state().layers_cleared).is_equal(1)
		assert_bool(rule.snapshot().slots[0].is_empty()).is_false()
		assert_bool(rule.snapshot().slots[1].is_empty()).is_true()
		break
	assert_bool(found).is_true()

func test_receive_effect_during_resolving_waits_until_resolve_finishes() -> void:
	var level: LevelData = _level()
	level.knobs[&"fall.entry_delay_ms"] = 100
	var sim := BoardSim.new(level, 91, WtContent.new().load_catalog())
	sim.step()
	_command(sim, SimEvents.CMD_HARD_DROP)
	assert_int(sim.get_phase()).is_equal(BoardSim.Phase.RESOLVING)
	_command(sim, SimEvents.CMD_RECEIVE_ITEM, [{"effect_id": "slow_time"}])
	assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(1000)
	for _tick: int in 10: sim.step()
	assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(500)

func test_empty_alive_target_list_refuses_attack_without_spending_or_pending() -> void:
	var api: RuleApi = preload("res://tests/unit/mechanics/mechanics_fixture.gd").api(preload("res://tests/unit/mechanics/mechanics_fixture.gd").board())
	api.bind_item_context({"owner": 7, "players": 3, "targets": []})
	var rule := Items.new()
	rule._slots = [{"id": &"fog", "refunded": false}, {}]
	rule.use_slot(0, api)
	assert_str(str(rule.snapshot().slots[0].id)).is_equal("fog")
	assert_bool(rule.snapshot().slots[0].has("pending")).is_false()
	assert_bool(api.take_events().any(func(e: Dictionary) -> bool: return e.kind == &"item_target_unavailable")).is_true()
