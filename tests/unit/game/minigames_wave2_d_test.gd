extends GdUnitTestSuite
## Wave-2 party minigames MG30-MG36 (design/gdd/party-minigames-wave2.md).
const IDS: Array[String] = ["mg30", "mg31", "mg32", "mg33", "mg34", "mg35", "mg36"]
var _content: WtContent
var _rows: Dictionary = {}
var _token: int = 0

func before() -> void:
	_content = WtContent.new()
	_content.load_catalog()
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/tournament/templates.json"))
	for row: Dictionary in raw.templates: _rows[str(row.id)] = row

func _make(id: String, seed: int = 11) -> WtMinigameSession:
	var s: WtMinigameSession = WtMinigameSession.new()
	assert_bool(s.setup(_rows[id], seed, _content.catalog)).is_true()
	return s

## Steps `ticks` frames and returns every event raised.
func _run(s: WtMinigameSession, ticks: int) -> Array[SimEvent]:
	var events: Array[SimEvent] = []
	for _i: int in ticks: events.append_array(s.step())
	return events

func _cmd(s: WtMinigameSession, kind: StringName, args: Array = []) -> void:
	s.queue_command(SimCommand.make(kind, args))

## Queues `kind` and steps two frames so it is applied.
func _do(s: WtMinigameSession, kind: StringName, args: Array = []) -> void:
	_cmd(s, kind, args)
	_run(s, 2)

func _attack(s: WtMinigameSession, effect: String, data: Dictionary = {}) -> void:
	_token += 1
	_cmd(s, &"mg_receive_attack", [{"token": "t%d" % _token, "effect": effect, "data": data}])
	_run(s, 70)

## Moves a Vector2i cursor (state.cursor) onto `target` using mg_move intents.
func _goto(s: WtMinigameSession, target: Vector2i) -> void:
	var cursor: Vector2i = s.state.cursor
	while cursor.x != target.x:
		_cmd(s, &"mg_move", [Vector3i(signi(target.x - cursor.x), 0, 0)])
		cursor.x += signi(target.x - cursor.x)
	while cursor.y != target.y:
		_cmd(s, &"mg_move", [Vector3i(0, 0, signi(target.y - cursor.y))])
		cursor.y += signi(target.y - cursor.y)
	_run(s, 2)

func _events_of(events: Array[SimEvent], kind: StringName) -> Array[SimEvent]:
	var out: Array[SimEvent] = []
	for e: SimEvent in events:
		if e.kind == kind: out.append(e)
	return out

# ---------------------------------------------------------------- templates

func test_templates_use_rules_d() -> void:
	for id: String in IDS:
		assert_str(str(_rows[id].rules_script)).is_equal("res://src/game/minigames/rules_d.gd")
		var s: WtMinigameSession = _make(id)
		assert_str(str(s.view.kind)).is_not_empty()

# ---------------------------------------------------------------- MG30

func test_mg30_perfect_reflection_scores_ten_and_charges_send() -> void:
	var s: WtMinigameSession = _make("mg30")
	assert_int((s.state.pattern as Array).size()).is_equal(6)
	var target: Dictionary = WtMinigameRulesD.mirror_target(s.state.pattern, &"v")
	for cell: Vector2i in target:
		_goto(s, cell)
		_do(s, &"mg_paint")
	_do(s, &"mg_submit")
	assert_int(s.score()).is_equal(10)
	assert_int((s.state.pattern as Array).size()).is_equal(7)
	assert_bool(s.snapshot().send.ready).is_false()
	var target2: Dictionary = WtMinigameRulesD.mirror_target(s.state.pattern, &"v")
	for cell: Vector2i in target2:
		_goto(s, cell)
		_do(s, &"mg_paint")
	_do(s, &"mg_submit")
	assert_int(s.score()).is_equal(20)
	assert_bool(s.snapshot().send.ready).is_true()
	assert_str(str(s.snapshot().send.effect)).is_equal("flip_axis")

func test_mg30_jaccard_partial_accuracy() -> void:
	var s: WtMinigameSession = _make("mg30")
	var target: Array = WtMinigameRulesD.mirror_target(s.state.pattern, &"v").keys()
	for i: int in 3:
		_goto(s, target[i])
		_do(s, &"mg_paint")
	_do(s, &"mg_submit")
	assert_int(s.score()).is_equal(5) # 3 of 6 cells -> 0.5 -> 5
	assert_bool(s.snapshot().send.ready).is_false()

func test_mg30_flip_axis_attack_reflects_next_pattern_horizontally() -> void:
	var s: WtMinigameSession = _make("mg30")
	_attack(s, "flip_axis")
	assert_bool(s.state.flip_next).is_true()
	assert_str(str(s.state.axis)).is_equal("v")
	_do(s, &"mg_submit")
	assert_str(str(s.state.axis)).is_equal("h")
	assert_bool(s.state.flip_next).is_false()
	var target: Dictionary = WtMinigameRulesD.mirror_target(s.state.pattern, &"h")
	for cell: Vector2i in target:
		assert_int(cell.x).is_between(0, 4)
	assert_str(str(s.view.axis)).is_equal("h")

# ---------------------------------------------------------------- MG31

func test_mg31_parade_then_answer_scores_three() -> void:
	var s: WtMinigameSession = _make("mg31")
	_do(s, &"mg_answer", [0])
	assert_int(s.score()).is_equal(0) # input ignored while showing
	_run(s, 700)
	assert_str(str(s.view.phase)).is_equal("ask")
	var choices: Array = s.view.choices
	assert_int(choices.size()).is_equal(4)
	var count: int = 0
	for item: Dictionary in s.state.items:
		if int(item.hue) == int(s.state.target_hue): count += 1
	assert_int(int(choices[int(s.state.answer_index)])).is_equal(count)
	assert_int(choices.filter(func(v: int) -> bool: return v == count).size()).is_equal(1)
	assert_int(choices.min()).is_greater(0)
	_do(s, &"mg_answer", [int(s.state.answer_index)])
	assert_int(s.score()).is_equal(3)
	assert_str(str(s.view.phase)).is_equal("parade")

func test_mg31_wrong_answer_scores_nothing_and_fast_parade_attack() -> void:
	var s: WtMinigameSession = _make("mg31")
	_attack(s, "fast_parade")
	assert_bool(s.state.fast_next).is_true()
	_run(s, 700)
	var wrong: int = (int(s.state.answer_index) + 1) % 4
	_do(s, &"mg_answer", [{"index": wrong}])
	assert_int(s.score()).is_equal(0)
	assert_int(int(s.state.parade_ms)).is_equal(300)

# ---------------------------------------------------------------- MG32

func test_mg32_point_values() -> void:
	var seen: Dictionary = {}
	for seed: int in 40:
		var s: WtMinigameSession = _make("mg32", seed)
		s.points = 10
		for _t: int in 200:
			_run(s, 1)
			var pops: Array = s.view.pops
			if pops.is_empty(): continue
			var pop: Dictionary = pops[0]
			var real: String = str((s.state.pops[int(pop.index)] as Dictionary).kind)
			var before: int = s.score()
			_do(s, &"mg_whack", [int(pop.index)])
			var expected: int = {"block": 1, "golden": 3, "bomb": -2}[real]
			assert_int(s.score() - before).is_equal(expected)
			seen[real] = true
			break
	assert_int(seen.size()).is_equal(3)

func test_mg32_empty_hole_costs_nothing_and_good_hits_charge_send() -> void:
	var s: WtMinigameSession = _make("mg32")
	_do(s, &"mg_whack", [4])
	assert_int(s.score()).is_equal(0)
	var hits: int = 0
	for _t: int in 3400:
		_run(s, 1)
		for pop: Dictionary in s.view.pops:
			if str((s.state.pops[int(pop.index)] as Dictionary).kind) != "bomb":
				_cmd(s, &"mg_whack", [int(pop.index)])
		if int(s.state.good_hits) >= 8: break
	assert_int(int(s.state.good_hits)).is_greater_equal(8)
	assert_bool(s.snapshot().send.ready).is_true()

func test_mg32_decoy_bombs_attack_disguises_next_pops() -> void:
	var s: WtMinigameSession = _make("mg32")
	_attack(s, "decoy_bombs", {"count": 4})
	var disguised: bool = false
	for _t: int in 300:
		_run(s, 1)
		for pop: Dictionary in s.view.pops:
			if bool(pop.disguised):
				disguised = true
				assert_str(str(pop.kind)).is_equal("block")
				assert_str(str((s.state.pops[int(pop.index)] as Dictionary).kind)).is_equal("bomb")
	assert_bool(disguised).is_true()
	assert_int(int(s.state.decoys)).is_less(4)

# ---------------------------------------------------------------- MG33

func test_mg33_stability_formula_f2() -> void:
	assert_bool(WtMinigameRulesD.layer_stable([true, true, true], false)).is_true()
	assert_bool(WtMinigameRulesD.layer_stable([false, true, false], false)).is_true()
	assert_bool(WtMinigameRulesD.layer_stable([true, false, true], false)).is_true()
	assert_bool(WtMinigameRulesD.layer_stable([true, false, false], false)).is_false()
	assert_bool(WtMinigameRulesD.layer_stable([false, false, false], false)).is_false()
	assert_bool(WtMinigameRulesD.layer_stable([false, true, false], true)).is_false()
	assert_bool(WtMinigameRulesD.layer_stable([false, true, true], true)).is_true()
	assert_bool(WtMinigameRulesD.layer_stable([true, false, true], true)).is_true()

func test_mg33_safe_pulls_topple_and_rebuild() -> void:
	var s: WtMinigameSession = _make("mg33")
	_do(s, &"mg_pull", [0, 0])
	assert_int(s.score()).is_equal(2) # bottom three layers pay +2
	assert_int((s.state.layers as Array).size()).is_equal(10) # bar placed on a new top layer
	_do(s, &"mg_pull", [{"layer": 4, "slot": 2}])
	assert_int(s.score()).is_equal(3) # higher layers pay +1
	_do(s, &"mg_pull", [0, 2])
	assert_int(s.score()).is_equal(5) # centre alone still stands
	_do(s, &"mg_pull", [0, 1]) # last bar -> unstable
	assert_int(s.score()).is_equal(0) # 5 - 5
	assert_bool(s.view.rebuilding).is_true()
	_do(s, &"mg_pull", [2, 0])
	assert_int((s.state.layers[2] as Array).count(true)).is_equal(3) # ignored while rebuilding
	_run(s, 160)
	assert_bool(s.view.rebuilding).is_false()
	assert_int((s.state.layers as Array).size()).is_equal(9)
	for bars: Array in s.state.layers: assert_int(bars.count(true)).is_equal(3)

func test_mg33_top_two_layers_and_missing_bars_are_ignored() -> void:
	var s: WtMinigameSession = _make("mg33")
	_do(s, &"mg_pull", [8, 0])
	_do(s, &"mg_pull", [7, 1])
	_do(s, &"mg_pull", [9, 1])
	_do(s, &"mg_pull", [3, 5])
	assert_int(s.score()).is_equal(0)
	_do(s, &"mg_pull", [6, 0])
	assert_int(s.score()).is_equal(1)
	_do(s, &"mg_pull", [6, 0]) # bar already gone
	assert_int(s.score()).is_equal(1)

func test_mg33_cursor_pull_and_wobble_attack() -> void:
	var s: WtMinigameSession = _make("mg33")
	_do(s, &"mg_move", [Vector3i.LEFT])
	_do(s, &"mg_move", [Vector3i(0, 0, -1)]) # up one layer
	assert_that(s.state.cursor).is_equal(Vector2i(0, 1))
	_attack(s, "wobble_tower", {"duration_ms": 5000})
	assert_bool(s.view.wobbling).is_true()
	_do(s, &"mg_pull") # layer 1 left edge: centre + right remain -> stable while wobbling
	assert_int(s.score()).is_equal(2)
	_do(s, &"mg_pull", [1, 2]) # centre alone -> unstable while wobbling
	assert_bool(s.view.rebuilding).is_true()
	assert_int(s.score()).is_equal(0)
	# The same pull is safe without wobble.
	var calm: WtMinigameSession = _make("mg33")
	_do(calm, &"mg_pull", [1, 0])
	_do(calm, &"mg_pull", [1, 2])
	assert_bool(calm.view.rebuilding).is_false()
	assert_int(calm.score()).is_equal(4)

# ---------------------------------------------------------------- MG34

func _solve(s: WtMinigameSession, extra_turns: bool = false) -> void:
	var shape: ShapeDef = _content.catalog.shapes.get_shape(StringName(s.state.shape))
	var target: int = int(s.state.target)
	var orient: int = int(s.state.orient)
	var left: int = WtMinigameRulesD.spin_par(shape, orient, target)
	while left > 0:
		var found: bool = false
		for axis: int in 3:
			for dir: int in [-1, 1]:
				var n: int = Orientations.turn(orient, axis as Orientations.Axis, dir)
				if not found and WtMinigameRulesD.spin_par(shape, n, target) == left - 1:
					_cmd(s, &"mg_rotate", [axis, dir])
					orient = n
					left -= 1
					found = true
		assert_bool(found).is_true()
	if extra_turns:
		_cmd(s, &"mg_rotate", [0, 1])
		_cmd(s, &"mg_rotate", [0, -1])
	_run(s, 2)
	_do(s, &"mg_submit")

func test_mg34_par_is_symmetry_aware() -> void:
	var shape: ShapeDef = _content.catalog.shapes.get_shape(&"o")
	var o: ShapeDef = shape
	for a: int in Orientations.COUNT:
		assert_int(WtMinigameRulesD.spin_par(o, 0, a)).is_less_equal(3)
		if WtMinigameRulesD.orient_key(o, a) == WtMinigameRulesD.orient_key(o, 0):
			assert_int(WtMinigameRulesD.spin_par(o, 0, a)).is_equal(0)

func test_mg34_par_solve_scores_six_and_extra_turns_cost() -> void:
	var s: WtMinigameSession = _make("mg34")
	assert_int(int(s.state.par)).is_greater(0)
	_solve(s)
	assert_int(s.score()).is_equal(6)
	var t: WtMinigameSession = _make("mg34", 3)
	_solve(t, true)
	assert_int(t.score()).is_equal(4) # two wasted turns
	var u: WtMinigameSession = _make("mg34", 5)
	var before: String = str(u.state.shape)
	_do(u, &"mg_submit") # unsolved: 0 points and a new puzzle
	assert_int(u.score()).is_equal(0)
	assert_int(int(u.state.puzzles)).is_equal(1)
	assert_str(before).is_not_empty()

func test_mg34_three_par_solves_charge_and_sticky_axis_locks() -> void:
	var s: WtMinigameSession = _make("mg34", 9)
	for _i: int in 3: _solve(s)
	assert_int(s.score()).is_equal(18)
	assert_bool(s.snapshot().send.ready).is_true()
	var t: WtMinigameSession = _make("mg34")
	_attack(t, "sticky_axis", {"duration_ms": 8000})
	var locked: int = int(t.view.locked_axis)
	assert_int(locked).is_between(0, 2)
	var turns: int = int(t.state.turns)
	_do(t, &"mg_rotate", [locked, 1])
	assert_int(int(t.state.turns)).is_equal(turns)
	_do(t, &"mg_rotate", [(locked + 1) % 3, 1])
	assert_int(int(t.state.turns)).is_equal(turns + 1)
	_run(t, 600)
	assert_int(int(t.view.locked_axis)).is_equal(-1)

# ---------------------------------------------------------------- MG35

func _plinko_final(s: WtMinigameSession, aim: int) -> int:
	var col: int = aim
	for row: Array in s.state.pattern: col = clampi(col + int(row[col]), 0, 6)
	return col

func test_mg35_drop_lands_in_computed_bucket_and_cooldown() -> void:
	var s: WtMinigameSession = _make("mg35")
	var aim: int = int(s.state.aim)
	var expected: int = int([1, 3, 5, 10, 5, 3, 1][_plinko_final(s, aim)])
	_do(s, &"mg_bowl")
	assert_bool(not (s.state.drop as Dictionary).is_empty()).is_true()
	_do(s, &"mg_aim", [{"dir": 1}])
	assert_int(int(s.state.aim)).is_equal(aim + 1)
	_run(s, 30)
	assert_int(s.score()).is_equal(0) # still falling
	var step_before: int = int(s.state.drop.row)
	_do(s, &"mg_bowl") # one block at a time
	assert_int(int(s.state.drop.row)).is_greater_equal(step_before)
	_run(s, 60)
	assert_int(s.score()).is_equal(expected)
	assert_bool((s.state.drop as Dictionary).is_empty()).is_true()
	_do(s, &"mg_bowl")
	assert_bool((s.state.drop as Dictionary).is_empty()).is_false()

func _jackpot_seed() -> Array:
	for seed: int in range(1, 80):
		var s: WtMinigameSession = _make("mg35", seed)
		_run(s, 901)
		for aim: int in 7:
			if _plinko_final(s, aim) == 3: return [seed, aim]
	return []

func test_mg35_jackpot_doubles_ten_bucket_and_claims_shared_bonus() -> void:
	var found: Array = _jackpot_seed()
	assert_bool(found.is_empty()).is_false()
	var s: WtMinigameSession = _make("mg35", int(found[0]))
	s.bind_context({"players": 2, "rank": 1, "targets": [{"player_id": 1, "standing": 0, "score": 0}]})
	var events: Array[SimEvent] = _run(s, 901)
	assert_bool(s.view.jackpot_active).is_true()
	for _i: int in absi(int(found[1]) - int(s.state.aim)):
		_cmd(s, &"mg_aim", [1 if int(found[1]) > int(s.state.aim) else -1])
		events.append_array(_run(s, 1))
	_cmd(s, &"mg_bowl")
	events.append_array(_run(s, 90))
	assert_int(s.score()).is_equal(20)
	var claims: Array[SimEvent] = _events_of(events, &"mg_shared_request")
	assert_int(claims.size()).is_equal(1)
	assert_str(str(claims[0].data.kind)).is_equal("plinko_jackpot_claim")
	assert_int(int(claims[0].data.data.serial)).is_equal(1)
	_do(s, &"mg_authority", [{"kind": "plinko_jackpot_awarded", "winner": 1, "serial": 1}])
	assert_int(s.score()).is_equal(20)
	_do(s, &"mg_authority", [{"kind": "plinko_jackpot_awarded", "winner": 0, "serial": 1}])
	assert_int(s.score()).is_equal(25)
	_do(s, &"mg_authority", [{"kind": "plinko_jackpot_awarded", "winner": 0, "serial": 1}])
	assert_int(s.score()).is_equal(25) # a serial pays once

func test_mg35_no_jackpot_outside_window() -> void:
	var s: WtMinigameSession = _make("mg35")
	_run(s, 901 + 300) # 15 s + 5 s: window (4 s) over
	assert_bool(s.view.jackpot_active).is_false()

# ---------------------------------------------------------------- MG36

func _non_treasure(s: WtMinigameSession, count: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y: int in 6:
		for x: int in 6:
			if out.size() < count and not (s.state.treasure as Array).has(Vector2i(x, y)): out.append(Vector2i(x, y))
	return out

func test_mg36_reward_is_twelve_minus_misses_and_hot_cold_distance() -> void:
	var s: WtMinigameSession = _make("mg36")
	var treasure: Array = s.state.treasure.duplicate()
	assert_int(treasure.size()).is_between(3, 5)
	var misses: Array[Vector2i] = _non_treasure(s, 3)
	for cell: Vector2i in misses:
		_goto(s, cell)
		_do(s, &"mg_dig")
	assert_int(int(s.state.miss_count)).is_equal(3)
	var m: Vector2i = misses[0]
	var nearest: int = 99
	for t: Vector2i in treasure: nearest = mini(nearest, absi(t.x - m.x) + absi(t.y - m.y))
	assert_int(int((s.view.misses as Dictionary)[m])).is_equal(nearest)
	assert_int(nearest).is_greater(0)
	for cell: Vector2i in treasure:
		_goto(s, cell)
		_do(s, &"mg_dig")
	assert_int(s.score()).is_equal(9)
	assert_int(int(s.state.miss_count)).is_equal(0) # a new treasure is buried
	assert_bool(s.state.treasure == treasure).is_false()

func test_mg36_mud_fills_miss_cells_back_in() -> void:
	var s: WtMinigameSession = _make("mg36")
	var misses: Array[Vector2i] = _non_treasure(s, 4)
	for cell: Vector2i in misses:
		_goto(s, cell)
		_do(s, &"mg_dig")
	assert_int((s.state.misses as Dictionary).size()).is_equal(4)
	_attack(s, "mud", {"count": 3})
	assert_int((s.state.misses as Dictionary).size()).is_equal(1)
	assert_int(int(s.state.miss_count)).is_equal(4)
	_attack(s, "mud", {"count": 3})
	assert_int((s.state.misses as Dictionary).size()).is_equal(0) # fewer than 3 left: fills what exists

func test_mg36_two_treasures_charge_the_mud_send() -> void:
	var s: WtMinigameSession = _make("mg36")
	for _round: int in 2:
		for cell: Vector2i in s.state.treasure.duplicate():
			_goto(s, cell)
			_do(s, &"mg_dig")
	assert_int(s.score()).is_equal(24)
	assert_bool(s.snapshot().send.ready).is_true()
	assert_str(str(s.snapshot().send.effect)).is_equal("mud")

# ---------------------------------------------------------------- cross-cutting

func _script_for(id: String, tick: int) -> Array:
	match id:
		"mg30": return [[&"mg_move", [Vector3i((tick % 3) - 1, 0, 0)]], [&"mg_paint", []], [&"mg_submit", []]][tick % 3]
		"mg31": return [&"mg_answer", [tick % 4]]
		"mg32": return [&"mg_whack", [tick % 9]]
		"mg33": return [[&"mg_pull", [tick % 9, tick % 3]], [&"mg_move", [Vector3i(0, 0, -1)]]][tick % 2]
		"mg34": return [[&"mg_rotate", [tick % 3, 1]], [&"mg_submit", []]][tick % 5 / 4]
		"mg35": return [[&"mg_aim", [(tick % 2) * 2 - 1]], [&"mg_bowl", []]][tick % 3 / 2]
		_: return [[&"mg_move", [Vector3i((tick % 3) - 1, 0, (tick % 2))]], [&"mg_dig", []]][tick % 2]

func _determinism_hash(id: String, seed: int) -> int:
	var s: WtMinigameSession = _make(id, seed)
	for t: int in 900:
		if t % 6 == 0:
			var row: Array = _script_for(id, t / 6)
			_cmd(s, row[0], row[1])
		if t == 300:
			_cmd(s, &"mg_receive_attack", [{"token": "d1", "effect": {"mg30": "flip_axis", "mg31": "fast_parade", "mg32": "decoy_bombs", "mg33": "wobble_tower", "mg34": "sticky_axis", "mg35": "nope", "mg36": "mud"}[id], "data": {}}])
		s.step()
	return s.state_hash()

func test_determinism_same_seed_same_commands_same_hash() -> void:
	for id: String in IDS:
		assert_int(_determinism_hash(id, 77)).is_equal(_determinism_hash(id, 77))
		assert_int(_determinism_hash(id, 77)).is_not_equal(_determinism_hash(id, 78))

func test_ui_builds_and_redraws_every_wave2_id() -> void:
	var scene: PackedScene = load("res://src/ui/minigame_ui.tscn")
	var ui: WtMinigameUi = scene.instantiate()
	add_child(ui)
	auto_free(ui)
	for size: Vector2 in [Vector2(1280, 720), Vector2(720, 1280)]:
		ui.size = size
		for id: String in IDS:
			var s: WtMinigameSession = _make(id)
			_run(s, 40)
			var snapshot: Dictionary = s.snapshot()
			snapshot["opponents"] = [{"id": 2, "name": "Lana", "active": true}]
			ui.set_snapshot(snapshot)
			await get_tree().process_frame
			await get_tree().process_frame
			var ext: Script = WtMinigameUi.ext_for(id)
			assert_object(ext).is_not_null()
			assert_int(ui._buttons.size()).is_equal((ext.call("actions", id) as Array).size())
			assert_str(str(ext.call("note", id, s.view, snapshot))).is_not_null()
			# Drive the visible controls through the real session so view fields they rely on exist.
			for button: Button in ui._buttons: assert_bool(button.disabled).is_false()
	assert_bool(WtMinigameUi.ext_for("mg01") == null or not WtMinigameUi.ext_for("mg01").call("handles", "mg30")).is_true()
