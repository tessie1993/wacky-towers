extends GdUnitTestSuite
## Runtime contracts exercise loaded levels, real commands, buffered slot writes and locks.


func _catalog() -> GameCatalog:
	var catalog := GameCatalog.new()
	catalog.shapes = ShapeBank.new()
	var shapes: Dictionary = {
		&"mono": [Vector3i.ZERO],
		&"duo": [Vector3i.ZERO, Vector3i.RIGHT],
		&"tri_straight": [Vector3i.ZERO, Vector3i.RIGHT, Vector3i(2, 0, 0)],
		&"tri_corner": [Vector3i.ZERO, Vector3i.RIGHT, Vector3i(0, 0, 1)]}
	for id: StringName in shapes:
		var offsets: Array[Vector3i] = []
		for cell: Vector3i in shapes[id]: offsets.append(cell)
		catalog.shapes.shapes.append(ShapeDef.build(id, offsets))
	catalog.content = ContentTypes.from_entries([
		{"id": "block", "kind_id": 1, "mesh": "", "glyph": "#", "slot": "cell", "solid": true, "fills_layer": true, "hue": 1}])
	catalog.knob_defs = KnobDefs.from_tables(JsonReader.read_dir("res://assets/data/knobs")["files"].values())
	catalog.plugins = PluginRegistry.new(ProjectSettings.get_global_class_list())
	catalog.limits = BoardLimits.new()
	return catalog


func _fixture(catalog: GameCatalog, overrides: Dictionary = {}, starting: Dictionary = {}) -> LevelData:
	var knobs: Dictionary = {"goal.countdown_ms": 0, "fall.entry_delay_ms": 0,
		"fall.hard_drop_grace_ms": 0, "fall.g0": 0.3, "fall.gravity_scale": 1.0,
		"fall.lock_delay_ms": 400, "fall.ramp_per_clear": 0.0,
		"spawn.preview_count": 1, "spawn.queue_lookahead": 3, "spawn.hold_enabled": false}
	knobs.merge(overrides, true)
	var raw: Dictionary = {"schema": 1, "id": "abilities_fixture", "biome": "meadow", "tier": 1,
		"seed": 73, "board": {"width": 4, "depth": 4, "h_play": 20, "spawn_anchor": [2, 2]},
		"pieces": {"shapes": ["mono", "duo", "tri_straight", "tri_corner"], "opening_set": ["mono"], "opening_count": 1},
		"knobs": knobs, "goal": {"type": "clear_n", "n": 100}, "rules": []}
	if not starting.is_empty(): raw.board["starting_contents"] = starting
	var parsed: LoadResult = LevelLoader.parse_level(raw, catalog)
	assert_that(parsed.level).is_not_null()
	return parsed.level


func _session(level: LevelData, catalog: GameCatalog, seed: int = 73) -> Dictionary:
	var sim := BoardSim.new(level, seed, catalog)
	var abilities := WtAbilities.new()
	abilities.setup(level, catalog, sim.get_api(), &"cloud", &"campaign")
	sim.bind_abilities(abilities)
	sim.step()
	assert_that(sim.get_piece()).is_not_null()
	return {"sim": sim, "abilities": abilities}


func _command(sim: BoardSim, kind: StringName, args: Array = []) -> Array[SimEvent]:
	sim.queue_command(SimCommand.make(kind, args))
	return sim.step()


func _event_count(events: Array[SimEvent], kind: StringName) -> int:
	var count: int = 0
	for event: SimEvent in events:
		if event.kind == kind: count += 1
	return count


func _advance_to(sim: BoardSim, deadline: int) -> Array[SimEvent]:
	var events: Array[SimEvent] = []
	while sim.now_ms() < deadline:
		events.append_array(sim.step())
	return events


func test_calm_quarters_gravity_and_restores_prior_gravity_and_lock_delay() -> void:
	var catalog: GameCatalog = _catalog()
	for gravity: float in [1.0, 0.8]:
		var session: Dictionary = _session(_fixture(catalog, {"fall.gravity_scale": gravity, "fall.lock_delay_ms": 450}), catalog)
		var sim: BoardSim = session.sim
		var abilities: WtAbilities = session.abilities
		abilities.charge = WtAbilities.FULL
		var events: Array[SimEvent] = _command(sim, SimEvents.CMD_USE_SKILL)
		assert_int(_event_count(events, &"skill_used")).is_equal(1)
		assert_int(abilities.charge).is_equal(0)
		assert_bool(abilities.ready()).is_false()
		assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(roundi(gravity * 250))
		assert_int(sim.knobs().int_value(&"fall.lock_delay_ms")).is_equal(675)
		var deadline: int = int(abilities.snapshot().active)
		_advance_to(sim, deadline - 17)
		assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(roundi(gravity * 250))
		var expiry: Array[SimEvent] = _advance_to(sim, deadline)
		assert_int(_event_count(expiry, &"skill_ended")).is_equal(1)
		assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(roundi(gravity * 1000))
		assert_int(sim.knobs().int_value(&"fall.lock_delay_ms")).is_equal(450)


func test_helper_drop_injects_three_without_consuming_bag_and_has_its_own_seed_stream() -> void:
	var catalog: GameCatalog = _catalog()
	var level: LevelData = _fixture(catalog)
	var a: Dictionary = _session(level, catalog, 111)
	var b: Dictionary = _session(level, catalog, 222)
	var sim_a: BoardSim = a.sim
	var sim_b: BoardSim = b.sim
	# Advance only B's bag stream; helper draws must remain identical.
	for i: int in 7: sim_b._spawner.next()
	var before: Dictionary = sim_a._spawner.snapshot().duplicate(true)
	var events: Array[SimEvent] = _command(sim_a, SimEvents.CMD_USE_ITEM, ["potion_helper_drop"])
	_command(sim_b, SimEvents.CMD_USE_ITEM, ["potion_helper_drop"])
	var after: Dictionary = sim_a._spawner.snapshot()
	assert_int(_event_count(events, &"item_used")).is_equal(1)
	assert_int((after.queue as Array).size()).is_equal((before.queue as Array).size() + 3)
	assert_that((after.queue as Array).slice(3)).is_equal(before.queue)
	for field: String in ["bag", "bag_index", "drawn", "fixed_index", "opening_left", "open_part", "open_buf"]:
		assert_that(after[field]).is_equal(before[field])
	assert_that(sim_a._spawner.peek(3)).is_equal(sim_b._spawner.peek(3))
	for helper: String in sim_a._spawner.peek(3):
		assert_bool(helper in ["mono", "duo", "tri_straight", "tri_corner"]).is_true()


func test_preview_peek_enables_extra_lookahead_and_hold_then_restores_them() -> void:
	var catalog: GameCatalog = _catalog()
	var session: Dictionary = _session(_fixture(catalog), catalog)
	var sim: BoardSim = session.sim
	var abilities: WtAbilities = session.abilities
	var events: Array[SimEvent] = _command(sim, SimEvents.CMD_USE_ITEM, ["potion_preview_peek"])
	assert_int(_event_count(events, &"item_used")).is_equal(1)
	assert_int(sim.knobs().int_value(&"spawn.preview_count")).is_equal(3)
	assert_bool(sim.knobs().flag(&"spawn.hold_enabled")).is_true()
	assert_int(sim.preview(3).size()).is_equal(3)
	var repeated: Array[SimEvent] = _command(sim, SimEvents.CMD_USE_ITEM, ["potion_preview_peek"])
	assert_int(_event_count(repeated, &"item_used")).is_equal(0)
	assert_int(_event_count(repeated, &"item_no_effect")).is_equal(1)
	var expiry: Array[SimEvent] = _advance_to(sim, int(abilities.snapshot().peek))
	assert_int(_event_count(expiry, &"item_ended")).is_equal(1)
	assert_int(sim.knobs().int_value(&"spawn.preview_count")).is_equal(1)
	assert_bool(sim.knobs().flag(&"spawn.hold_enabled")).is_false()


func test_bomb_waits_for_lock_and_damage_prevents_clear_credit() -> void:
	var catalog: GameCatalog = _catalog()
	var level: LevelData = _fixture(catalog, {}, {"layers": {"0": ["####", "####", "##.#", "####"]}})
	var session: Dictionary = _session(level, catalog)
	var sim: BoardSim = session.sim
	var abilities: WtAbilities = session.abilities
	var armed: Array[SimEvent] = _command(sim, SimEvents.CMD_USE_ITEM, ["potion_bomb"])
	assert_bool(bool(abilities.snapshot().bomb)).is_true()
	assert_int(_event_count(armed, &"item_armed")).is_equal(1)
	assert_int(_event_count(armed, &"item_used")).is_equal(0)
	assert_int(sim.board().filled_in_layer(0)).is_equal(15)
	var locked: Array[SimEvent] = _command(sim, SimEvents.CMD_HARD_DROP)
	assert_int(_event_count(locked, SimEvents.PIECE_LOCKED)).is_equal(1)
	assert_int(_event_count(locked, &"item_used")).is_equal(1)
	assert_int(_event_count(locked, SimEvents.LAYERS_CLEARED)).is_equal(0)
	assert_bool(bool(abilities.snapshot().bomb)).is_false()
	assert_int(sim.board().filled_in_layer(0)).is_equal(7)
	assert_int(sim.goal_state().layers_cleared).is_equal(0)
	assert_int(abilities.charge).is_equal(0)
	# The identical hole-filling lock without the bomb really would clear a layer.
	var control: BoardSim = _session(level, catalog).sim
	var normal: Array[SimEvent] = _command(control, SimEvents.CMD_HARD_DROP)
	assert_int(_event_count(normal, SimEvents.LAYERS_CLEARED)).is_equal(1)
	assert_int(control.goal_state().layers_cleared).is_equal(1)


func test_skill_charge_uses_layer_equivalents_and_resets_combo_after_empty_lock() -> void:
	var catalog: GameCatalog = _catalog()
	var session: Dictionary = _session(_fixture(catalog), catalog)
	var abilities: WtAbilities = session.abilities
	var two_layers: Array[SimEvent] = [SimEvent.make(2, SimEvents.PIECE_LOCKED),
		SimEvent.make(2, SimEvents.LAYERS_CLEARED, {"n_layers": 2, "layers": [0]})]
	abilities.observe(two_layers)
	assert_int(abilities.charge).is_equal(250)
	var next_clear: Array[SimEvent] = [SimEvent.make(3, SimEvents.PIECE_LOCKED),
		SimEvent.make(3, SimEvents.LAYERS_CLEARED, {"n_layers": 1, "layers": [0]})]
	abilities.observe(next_clear)
	assert_int(abilities.charge).is_equal(405)
	var empty_lock: Array[SimEvent] = [SimEvent.make(4, SimEvents.PIECE_LOCKED)]
	abilities.observe(empty_lock)
	var after_gap: Array[SimEvent] = [SimEvent.make(5, SimEvents.PIECE_LOCKED),
		SimEvent.make(5, SimEvents.LAYERS_CLEARED, {"n_layers": 1, "layers": [0]})]
	abilities.observe(after_gap)
	assert_int(abilities.charge).is_equal(530)
	assert_int(int(abilities.snapshot().combo)).is_equal(1)

func test_calm_composes_with_item_then_expiry_keeps_the_remaining_effect() -> void:
	var catalog: GameCatalog = _catalog()
	var item := RuleDef.new(); item.id = &"test_item_slow"; item.layer = &"item_buff"
	catalog.rule_defs[item.id] = item
	var level: LevelData = _fixture(catalog, {"fall.gravity_scale": 0.8, "fall.lock_delay_ms": 450})
	level.rules = [{"id": item.id}]
	var session: Dictionary = _session(level, catalog)
	var sim: BoardSim = session.sim
	var abilities: WtAbilities = session.abilities
	abilities.charge = WtAbilities.FULL
	_command(sim, SimEvents.CMD_USE_SKILL)
	assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(200)
	var item_api: RuleApi = sim._rules[0]["api"]
	var slow: Array[Dictionary] = [{"knob": "fall.gravity_scale", "op": "mul", "value": 0.5}]
	item_api.request_modifiers(&"potion", slow)
	sim._collect_api(item_api, true, 2)
	assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(100)
	assert_int(sim.knobs().int_value(&"fall.lock_delay_ms")).is_equal(675)
	_advance_to(sim, int(abilities.snapshot().active))
	assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(400)
	assert_int(sim.knobs().int_value(&"fall.lock_delay_ms")).is_equal(450)
	item_api.clear_modifiers(&"potion")
	sim._collect_api(item_api, true, 2)
	assert_int(sim.knobs().int_value(&"fall.gravity_scale")).is_equal(800)

func test_preview_peek_cannot_override_mechanic_and_expiry_keeps_permanent_hold() -> void:
	var catalog: GameCatalog = _catalog()
	var mechanic := RuleDef.new(); mechanic.id = &"test_hold_mechanic"; mechanic.layer = &"mechanic"
	mechanic.modifiers = [{"knob": "spawn.hold_enabled", "op": "set", "value": false}]
	catalog.rule_defs[mechanic.id] = mechanic
	var level: LevelData = _fixture(catalog); level.rules = [{"id": mechanic.id}]
	var session: Dictionary = _session(level, catalog)
	var sim: BoardSim = session.sim
	var abilities: WtAbilities = session.abilities
	_command(sim, SimEvents.CMD_USE_ITEM, ["potion_preview_peek"])
	assert_int(sim.knobs().int_value(&"spawn.preview_count")).is_equal(3)
	assert_bool(sim.knobs().flag(&"spawn.hold_enabled")).is_false()
	var mechanic_api: RuleApi = sim._rules[0]["api"]
	var hold: Array[Dictionary] = [{"knob": "spawn.hold_enabled", "op": "set", "value": true}]
	mechanic_api.request_modifiers(&"permanent_hold", hold)
	sim._collect_api(mechanic_api, true, 4)
	assert_bool(sim.knobs().flag(&"spawn.hold_enabled")).is_true()
	_advance_to(sim, int(abilities.snapshot().peek))
	assert_int(sim.knobs().int_value(&"spawn.preview_count")).is_equal(1)
	assert_bool(sim.knobs().flag(&"spawn.hold_enabled")).is_true()

func test_preview_peek_no_effect_preserves_charge_when_mechanic_and_cap_cover_both() -> void:
	var catalog: GameCatalog = _catalog()
	var mechanic := RuleDef.new(); mechanic.id = &"test_hold_mechanic"; mechanic.layer = &"mechanic"
	mechanic.modifiers = [{"knob": "spawn.hold_enabled", "op": "set", "value": false}]
	catalog.rule_defs[mechanic.id] = mechanic
	var level: LevelData = _fixture(catalog, {"spawn.preview_count": 3}); level.rules = [{"id": mechanic.id}]
	var session: Dictionary = _session(level, catalog)
	var sim: BoardSim = session.sim
	var abilities: WtAbilities = session.abilities
	abilities.charge = 600
	var events: Array[SimEvent] = _command(sim, SimEvents.CMD_USE_ITEM, ["potion_preview_peek"])
	assert_int(_event_count(events, &"item_used")).is_equal(0)
	assert_int(_event_count(events, &"item_no_effect")).is_equal(1)
	assert_int(int(abilities.snapshot().peek)).is_equal(0)
	assert_int(abilities.charge).is_equal(600)

func test_trick_charge_counts_success_once_and_ignores_refund_no_effect_and_active_skills() -> void:
	var catalog: GameCatalog = _catalog()
	var session: Dictionary = _session(_fixture(catalog), catalog)
	var sim: BoardSim = session.sim
	var abilities: WtAbilities = session.abilities
	abilities.set_charge_perks({"item_charge": 0.1})
	_command(sim, SimEvents.CMD_USE_ITEM, ["potion_helper_drop"])
	assert_int(abilities.charge).is_equal(100)
	var rejected: Array[SimEvent] = [SimEvent.make(1, &"item_refunded"), SimEvent.make(1, &"item_no_effect"), SimEvent.make(1, &"item_armed")]
	abilities.observe(rejected)
	assert_int(abilities.charge).is_equal(100)
	abilities._redraw_locks = 2
	abilities.observe([SimEvent.make(2, &"item_used"), SimEvent.make(2, SimEvents.LAYERS_CLEARED, {"n_layers": 1}), SimEvent.make(2, &"obstacle_broken")])
	assert_int(abilities.charge).is_equal(100)
	abilities._redraw_locks = 0
	abilities._active_until = 1000
	abilities.observe([SimEvent.make(3, &"item_used")])
	assert_int(abilities.charge).is_equal(100)
	abilities._active_until = 0
	abilities.observe([SimEvent.make(4, &"item_used")])
	assert_int(abilities.charge).is_equal(200)
	abilities._mode = &"tournament"
	abilities.observe([SimEvent.make(5, &"item_used")])
	assert_int(abilities.charge).is_equal(200)


func test_redraw_preserves_injected_helpers_and_replaces_only_future_stream_pieces() -> void:
	var catalog: GameCatalog = _catalog()
	var session: Dictionary = _session(_fixture(catalog), catalog)
	var sim: BoardSim = session.sim
	var abilities: WtAbilities = session.abilities
	abilities._character = &"glim"
	_command(sim, SimEvents.CMD_USE_ITEM, ["potion_helper_drop"])
	var before: Dictionary = sim._spawner.snapshot().duplicate(true)
	var helpers: PackedStringArray = sim._spawner.peek(3)
	var old_stream: PackedStringArray = sim._spawner.stream_preview_ids(3)
	var old_hues: PackedInt32Array = sim.preview_hues(3)
	abilities.charge = WtAbilities.FULL
	var events: Array[SimEvent] = _command(sim, SimEvents.CMD_USE_SKILL)
	assert_int(_event_count(events, &"skill_used")).is_equal(1)
	assert_that(sim._spawner.peek(3)).is_equal(helpers)
	assert_that(sim.preview_hues(3)).is_equal(old_hues)
	var stream: PackedStringArray = sim._spawner.stream_preview_ids(3)
	for index: int in old_stream.size(): assert_str(stream[index]).is_not_equal(old_stream[index])
	var after: Dictionary = sim._spawner.snapshot()
	for key: String in ["bag", "bag_index", "queue_info", "generated_count", "random_rng"]:
		assert_that(after[key]).is_equal(before[key])
	assert_int(abilities._redraw_locks).is_equal(4)
	abilities.observe([SimEvent.make(1, SimEvents.PIECE_LOCKED, {"uid": 9999, "injected": true})])
	assert_int(abilities._redraw_locks).is_equal(4)
	abilities.observe([SimEvent.make(2, SimEvents.PIECE_LOCKED, {"uid": sim.get_piece_uid(), "injected": false})])
	assert_int(abilities._redraw_locks).is_equal(3)


func test_empty_stream_preview_request_never_returns_an_extra_piece() -> void:
	var catalog: GameCatalog = _catalog()
	var session: Dictionary = _session(_fixture(catalog), catalog)
	var sim: BoardSim = session.sim
	assert_int(sim._spawner.stream_preview_ids(0).size()).is_equal(0)
	assert_int(sim._spawner.stream_preview_positions(0).size()).is_equal(0)
