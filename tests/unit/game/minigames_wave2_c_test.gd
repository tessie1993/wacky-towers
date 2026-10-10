extends GdUnitTestSuite
## Wave 2 party minigames MG22-MG29 (design/gdd/party-minigames-wave2.md).

const TEMPLATES: String = "res://assets/data/tournament/templates.json"
const IDS: Array[String] = ["mg22", "mg23", "mg24", "mg25", "mg26", "mg27", "mg28", "mg29"]
var _catalog: GameCatalog

func before() -> void:
	_catalog = WtContent.new().load_catalog()

func _row(id: String) -> Dictionary:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(TEMPLATES))
	for row: Dictionary in data.templates:
		if str(row.id) == id: return row
	return {}

func _make(id: String, seed_value: int = 11) -> WtMinigameSession:
	var session: WtMinigameSession = WtMinigameSession.new()
	assert_bool(session.setup(_row(id), seed_value, _catalog)).is_true()
	return session

func _cmd(s: WtMinigameSession, kind: StringName, args: Array = []) -> void:
	s.queue_command(SimCommand.make(kind, args))

func _run(s: WtMinigameSession, steps: int) -> Array[SimEvent]:
	var seen: Array[SimEvent] = []
	for _i: int in steps: seen.append_array(s.step())
	return seen

func _until_ms(s: WtMinigameSession, ms: int) -> void:
	while s.now_ms() < ms and s.get_phase() != &"finished": s.step()

func _attack(s: WtMinigameSession, effect: String, data: Dictionary = {}) -> void:
	_cmd(s, &"mg_receive_attack", [{"token": "t1", "effect": effect, "data": data}])
	_run(s, 75)

func _kinds(events: Array[SimEvent]) -> Array:
	return events.map(func(e: SimEvent) -> StringName: return e.kind)

# ---------------------------------------------------------------- templates

func test_all_templates_use_rules_c_and_boot() -> void:
	for id: String in IDS:
		var row: Dictionary = _row(id)
		assert_str(str(row.get("rules_script", ""))).is_equal("res://src/game/minigames/rules_c.gd")
		var s: WtMinigameSession = _make(id)
		assert_str(str(s.view.get("kind", ""))).is_not_empty()

# ---------------------------------------------------------------- MG22

func test_mg22_strike_scores_twenty_and_charges_send() -> void:
	var s: WtMinigameSession = _make("mg22")
	s.state.pins = [Vector2i(int(s.state.col), 6)]
	_cmd(s, &"mg_bowl")
	_run(s, 90)
	assert_int(s.points).is_equal(20)
	assert_int(int(s.state.frame)).is_equal(1)
	assert_int(int(s._send.charge)).is_equal(1)
	assert_int((s.state.pins as Array).size()).is_equal(10)

func test_mg22_first_ball_scores_per_pin_then_spare() -> void:
	var s: WtMinigameSession = _make("mg22")
	var col: int = int(s.state.col)
	s.state.pins = [Vector2i(col, 6), Vector2i(0 if col > 1 else 4, 9)]
	_cmd(s, &"mg_bowl")
	_run(s, 90)
	assert_int(s.points).is_equal(1)
	assert_int(int(s.state.ball_no)).is_equal(2)
	# Second ball clears the last pin: spare, not +1.
	var remaining: Array = s.state.pins
	assert_int(remaining.size()).is_equal(1)
	var lone: Vector2i = remaining[0]
	s.state.col = clampi(lone.x, 0, 5 - int(s.state.w))
	_cmd(s, &"mg_bowl")
	_run(s, 90)
	assert_int(s.points).is_equal(1 + 15)

func test_mg22_domino_knocks_pin_behind() -> void:
	var s: WtMinigameSession = _make("mg22")
	s.params["curve_row"] = 6
	s.state.col = 2
	s.state.pins = [Vector2i(2, 6), Vector2i(2, 7), Vector2i(0, 9)]
	_cmd(s, &"mg_spin", [1])
	_cmd(s, &"mg_bowl")
	_run(s, 90)
	assert_int(s.points).is_equal(2)

func test_mg22_aim_and_spin_clamp() -> void:
	var s: WtMinigameSession = _make("mg22")
	for _i: int in 6: _cmd(s, &"mg_aim", [{"dir": -1}])
	for _i: int in 3: _cmd(s, &"mg_spin", [{"dir": 1}])
	_run(s, 3)
	assert_int(int(s.state.col)).is_equal(0)
	assert_int(int(s.state.curve)).is_equal(1)

func test_mg22_greased_lane_forces_curve() -> void:
	var s: WtMinigameSession = _make("mg22")
	_attack(s, "greased_lane", {"duration_ms": 8000})
	assert_int(int(s.state.greased_until)).is_greater(s.now_ms())
	_cmd(s, &"mg_bowl")
	_run(s, 2)
	assert_int(int(s.state.roll.curve)).is_equal(1)

# ---------------------------------------------------------------- MG23

func _simon_wait_input(s: WtMinigameSession) -> void:
	var guard: int = 0
	while bool(s.state.showing) and guard < 3000:
		s.step()
		guard += 1

func test_mg23_input_locked_while_showing_then_scores_length() -> void:
	var s: WtMinigameSession = _make("mg23")
	var seq: Array = (s.state.seq as Array).duplicate()
	_cmd(s, &"mg_pad", [int(seq[0])])
	_run(s, 3)
	assert_int(int(s.state.input_idx)).is_equal(0)
	_simon_wait_input(s)
	for pad: Variant in seq: _cmd(s, &"mg_pad", [{"pad": int(pad)}])
	_run(s, 2)
	assert_int(s.points).is_equal(3)
	assert_int((s.state.seq as Array).size()).is_equal(4)
	assert_bool(bool(s.view.showing)).is_true()

func test_mg23_wrong_pad_scores_nothing_and_restarts_at_start_len() -> void:
	var s: WtMinigameSession = _make("mg23")
	var seq: Array = s.state.seq
	_simon_wait_input(s)
	_cmd(s, &"mg_pad", [(int(seq[0]) + 1) % 4])
	_run(s, 2)
	assert_int(s.points).is_equal(0)
	assert_int((s.state.seq as Array).size()).is_equal(3)

func test_mg23_scramble_applies_to_next_sequence() -> void:
	var s: WtMinigameSession = _make("mg23")
	_attack(s, "scramble")
	assert_bool(bool(s.state.scramble_next)).is_true()
	assert_bool(bool(s.view.swapped)).is_false()
	_simon_wait_input(s)
	for pad: Variant in (s.state.seq as Array).duplicate(): _cmd(s, &"mg_pad", [int(pad)])
	_run(s, 2)
	assert_bool(bool(s.view.swapped)).is_true()
	assert_array(s.view.positions).is_not_equal([0, 1, 2, 3])

# ---------------------------------------------------------------- MG24

func test_mg24_reaction_scores_and_requests_shared_claim() -> void:
	var s: WtMinigameSession = _make("mg24")
	var guard: int = 0
	while str(s.view.signal) != "green" and guard < 1000:
		s.step()
		guard += 1
	_cmd(s, &"mg_tap")
	var events: Array[SimEvent] = _run(s, 1)
	assert_int(s.points).is_equal(10 - int(s.state.last_reaction) / 50)
	assert_int(s.points).is_greater(7)
	var claim: Array = events.filter(func(e: SimEvent) -> bool: return e.kind == &"mg_shared_request")
	assert_int(claim.size()).is_equal(1)
	assert_str(str(claim[0].data.kind)).is_equal("quick_drop_claim")

func test_mg24_false_start_costs_two_and_floors_at_zero() -> void:
	var s: WtMinigameSession = _make("mg24")
	_cmd(s, &"mg_tap")
	_run(s, 2)
	assert_int(s.points).is_equal(0)
	assert_str(str(s.view.signal)).is_equal("gap")
	s.points = 6
	s.state.phase = "wait"
	_cmd(s, &"mg_tap")
	_run(s, 1)
	assert_int(s.points).is_equal(4)

func test_mg24_authority_award_adds_shared_bonus() -> void:
	var s: WtMinigameSession = _make("mg24")
	_cmd(s, &"mg_authority", [{"kind": "quick_drop_awarded", "winner": 0, "leader": 1, "serial": 1}])
	_cmd(s, &"mg_authority", [{"kind": "quick_drop_awarded", "winner": 3, "leader": 1, "serial": 2}])
	_run(s, 2)
	assert_int(s.points).is_equal(3)

func test_mg24_fake_flash_is_false_start() -> void:
	var s: WtMinigameSession = _make("mg24")
	s.points = 5
	s.state.phase = "amber"
	s.state.end_at = 100000
	_cmd(s, &"mg_tap")
	_run(s, 1)
	assert_int(s.points).is_equal(3)

# ---------------------------------------------------------------- MG25

func _count_answer_phase(s: WtMinigameSession) -> void:
	while bool(s.state.showing): s.step()

func test_mg25_towers_have_6_to_20_cubes_and_distinct_choices() -> void:
	for seed_value: int in 12:
		var s: WtMinigameSession = _make("mg25", seed_value)
		var total: int = int(s.state.count)
		assert_int(total).is_between(6, 20)
		var choices: Array = s.state.choices
		assert_int(choices.size()).is_equal(4)
		assert_int(int(choices[int(s.state.answer)])).is_equal(total)
		for index: int in 4:
			assert_int(int(choices[index])).is_greater(0)
			assert_int(choices.count(choices[index])).is_equal(1)

func test_mg25_fast_correct_answer_scores_five_and_wrong_zero() -> void:
	var s: WtMinigameSession = _make("mg25")
	_cmd(s, &"mg_answer", [int(s.state.answer)])
	_run(s, 2)
	assert_int(s.points).is_equal(0) # input ignored while showing
	_count_answer_phase(s)
	_cmd(s, &"mg_answer", [{"index": int(s.state.answer)}])
	_run(s, 1)
	assert_int(s.points).is_equal(5)
	_count_answer_phase(s)
	_run(s, 150)
	_cmd(s, &"mg_answer", [(int(s.state.answer) + 1) % 4])
	_run(s, 1)
	assert_int(s.points).is_equal(5)

func test_mg25_slow_correct_scores_three() -> void:
	var s: WtMinigameSession = _make("mg25")
	_count_answer_phase(s)
	_run(s, 150)
	_cmd(s, &"mg_answer", [int(s.state.answer)])
	_run(s, 1)
	assert_int(s.points).is_equal(3)

func test_mg25_short_peek_shortens_next_show() -> void:
	var s: WtMinigameSession = _make("mg25")
	_attack(s, "short_peek")
	_count_answer_phase(s)
	_cmd(s, &"mg_answer", [int(s.state.answer)])
	_run(s, 1)
	assert_int(int(s.state.show_until) - (s.now_ms() + 500)).is_equal(1800)

# ---------------------------------------------------------------- MG26

func _assert_odd_puzzle(s: WtMinigameSession, expected: int) -> void:
	var copies: Array = s.view.copies
	assert_int(copies.size()).is_equal(expected)
	var odd: int = int(s.state.odd)
	for index: int in copies.size():
		var cells: Array[Vector3i] = []
		cells.assign(copies[index].cells)
		for other: int in copies.size():
			if other == index: continue
			var reference: Array[Vector3i] = []
			reference.assign(copies[other].cells)
			var same: bool = WtMinigameRulesC.is_rotation_of(cells, reference)
			assert_bool(same).is_equal(index != odd and other != odd)

func test_mg26_odd_copy_is_a_mirror_not_a_rotation() -> void:
	var s: WtMinigameSession = _make("mg26")
	_assert_odd_puzzle(s, 4)

func test_mg26_correct_scores_two_wrong_locks_and_fifth_has_five() -> void:
	var s: WtMinigameSession = _make("mg26")
	var wrong: int = (int(s.state.odd) + 1) % 4
	_cmd(s, &"mg_pick", [wrong])
	_run(s, 1)
	assert_int(s.points).is_equal(0)
	_cmd(s, &"mg_pick", [int(s.state.odd)])
	_run(s, 2)
	assert_int(s.points).is_equal(0) # locked
	_run(s, 70)
	for _i: int in 4:
		_cmd(s, &"mg_pick", [{"index": int(s.state.odd)}])
		_run(s, 2)
	assert_int(s.points).is_equal(8)
	_assert_odd_puzzle(s, 5)

func test_mg26_extra_decoy_gives_six_copies() -> void:
	var s: WtMinigameSession = _make("mg26")
	_attack(s, "extra_decoy")
	_cmd(s, &"mg_pick", [int(s.state.odd)])
	_run(s, 1)
	_assert_odd_puzzle(s, 6)

# ---------------------------------------------------------------- MG27

func _pair_indices(s: WtMinigameSession) -> Array:
	var faces: Array = s.state.faces
	var out: Array = []
	for a: int in faces.size():
		if bool(s.state.matched[a]): continue
		for b: int in range(a + 1, faces.size()):
			if faces[a] == faces[b]:
				out.append([a, b])
				break
	return out

func test_mg27_match_scores_two_and_mismatch_flips_back() -> void:
	var s: WtMinigameSession = _make("mg27")
	var pair: Array = _pair_indices(s)[0]
	_cmd(s, &"mg_flip", [pair[0]])
	_cmd(s, &"mg_flip", [pair[1]])
	_run(s, 2)
	assert_int(s.points).is_equal(2)
	var faces: Array = s.state.faces
	var odd_one: int = -1
	for index: int in faces.size():
		if not bool(s.state.matched[index]) and index != -1:
			odd_one = index
			break
	var other: int = -1
	for index: int in faces.size():
		if index != odd_one and not bool(s.state.matched[index]) and faces[index] != faces[odd_one]:
			other = index
			break
	_cmd(s, &"mg_flip", [odd_one])
	_cmd(s, &"mg_flip", [other])
	_run(s, 2)
	assert_int(s.points).is_equal(2)
	assert_bool(bool(s.state.up[odd_one])).is_true()
	_run(s, 60)
	assert_bool(bool(s.state.up[odd_one])).is_false()
	assert_bool(bool(s.state.up[other])).is_false()

func test_mg27_cleared_grid_gives_bonus_and_new_grid() -> void:
	var s: WtMinigameSession = _make("mg27")
	for pair: Array in _pair_indices(s):
		_cmd(s, &"mg_flip", [pair[0]])
		_cmd(s, &"mg_flip", [pair[1]])
	_run(s, 20)
	assert_int(s.points).is_equal(8 * 2 + 5)
	assert_int(int(s.state.grids)).is_equal(2)
	assert_bool((s.state.matched as Array).has(true)).is_false()

func test_mg27_shuffle_pair_swaps_two_face_down_cards() -> void:
	var s: WtMinigameSession = _make("mg27")
	var before: Array = (s.state.faces as Array).duplicate()
	_attack(s, "shuffle_pair")
	var after: Array = s.state.faces
	var changed: int = 0
	for index: int in before.size():
		if before[index] != after[index]: changed += 1
	assert_int(changed).is_between(0, 2)
	var sorted_before: Array = before.duplicate()
	var sorted_after: Array = after.duplicate()
	sorted_before.sort()
	sorted_after.sort()
	assert_array(sorted_after).is_equal(sorted_before)
	assert_int((s.view.swap_cells as Array).size()).is_equal(2)

# ---------------------------------------------------------------- MG28

func test_mg28_hits_cost_hearts_and_zero_hearts_becomes_ghost() -> void:
	var s: WtMinigameSession = _make("mg28")
	s.state.next_spawn = 1000000
	var lane: int = int(s.state.lane)
	for index: int in 3: s.state.drops.append({"lane": lane, "width": 1, "impact": 100 + index * 100, "spawn": 0})
	_run(s, 30)
	assert_int(int(s.state.hearts)).is_equal(0)
	assert_str(String(s.get_phase())).is_equal("ghost")
	assert_bool(bool(s.state.eliminated)).is_true()

func test_mg28_step_dodges_and_survival_scores() -> void:
	var s: WtMinigameSession = _make("mg28")
	s.state.next_spawn = 1000000
	s.state.drops.append({"lane": 2, "width": 1, "impact": 200, "spawn": 0})
	_cmd(s, &"mg_step", [{"dir": -1}])
	_run(s, 30)
	assert_int(int(s.state.hearts)).is_equal(3)
	assert_int(int(s.state.lane)).is_equal(1)
	_until_ms(s, 10100)
	assert_int(s.points).is_equal(1)

func test_mg28_near_miss_charges_and_extra_rain_adds_drops() -> void:
	var s: WtMinigameSession = _make("mg28")
	s.state.next_spawn = 1000000
	s.state.drops.append({"lane": 3, "width": 1, "impact": 100, "spawn": 0})
	_run(s, 10)
	assert_int(int(s._send.charge)).is_equal(1)
	_attack(s, "extra_rain", {"count": 3})
	assert_int((s.state.drops as Array).size()).is_greater_equal(2)
	var total: int = 0
	for drop: Dictionary in s.state.drops: total += 1
	assert_int(total + 0).is_greater(0)

func test_mg28_extra_rain_spawns_count_drops() -> void:
	var s: WtMinigameSession = _make("mg28")
	s.state.next_spawn = 1000000
	var rules: WtMinigameRulesC = WtMinigameRulesC.new()
	rules.attack(s, &"extra_rain", {"count": 3})
	assert_int((s.state.drops as Array).size()).is_equal(3)

# ---------------------------------------------------------------- MG29

func _inversions(tiles: Array) -> int:
	var count: int = 0
	for a: int in tiles.size():
		for b: int in range(a + 1, tiles.size()):
			if int(tiles[a]) != 0 and int(tiles[b]) != 0 and int(tiles[a]) > int(tiles[b]): count += 1
	return count

func _near_solved(s: WtMinigameSession) -> void:
	s.state.tiles = [1, 2, 3, 4, 5, 6, 7, 0, 8]
	s.state.empty = 7
	s.state.prev_empty = -1

func test_mg29_scramble_is_solvable_and_not_solved() -> void:
	for seed_value: int in 10:
		var s: WtMinigameSession = _make("mg29", seed_value)
		assert_int(_inversions(s.state.tiles) % 2).is_equal(0)
		assert_bool(s.state.tiles == WtMinigameRulesC.slide_solved()).is_false()

func test_mg29_progress_and_two_puzzles_win() -> void:
	var s: WtMinigameSession = _make("mg29")
	_near_solved(s)
	_cmd(s, &"mg_slide", [Vector2i(0, -1)]) # no tile below the gap: ignored
	_run(s, 2)
	assert_int(s.progress).is_equal(1000 * 7 / 8)
	_cmd(s, &"mg_slide", [{"dir": Vector2i(-1, 0)}])
	_run(s, 2)
	assert_int(int(s.state.puzzles)).is_equal(1)
	assert_str(String(s.get_phase())).is_equal("playing")
	_near_solved(s)
	_cmd(s, &"mg_slide", [Vector2i(-1, 0)])
	_run(s, 2)
	assert_str(String(s.get_phase())).is_equal("finished")
	assert_str(str(s.result()["status"])).is_equal("won")
	assert_int(s.progress).is_equal(1000)

func test_mg29_nudge_makes_extra_legal_moves() -> void:
	var s: WtMinigameSession = _make("mg29")
	_near_solved(s)
	_attack(s, "nudge", {"count": 3})
	assert_bool(s.state.tiles == WtMinigameRulesC.slide_solved()).is_false()
	assert_int(_inversions(s.state.tiles) % 2).is_equal(0)

func test_mg29_first_time_placements_charge_nudge() -> void:
	var s: WtMinigameSession = _make("mg29")
	s.state.tiles = [1, 2, 3, 4, 0, 5, 7, 8, 6]
	s.state.empty = 4
	s.state.placed = {0: true, 1: true, 2: true, 3: true, 6: true, 7: true}
	_cmd(s, &"mg_slide", [Vector2i(-1, 0)])
	_run(s, 2)
	assert_int(int(s._send.charge)).is_equal(1)

# ---------------------------------------------------------------- shared

func test_every_round_delivers_its_send_after_warning() -> void:
	var effects: Dictionary = {"mg22": "greased_lane", "mg23": "scramble", "mg25": "short_peek", "mg26": "extra_decoy", "mg27": "shuffle_pair", "mg28": "extra_rain", "mg29": "nudge"}
	for id: String in effects:
		var s: WtMinigameSession = _make(id)
		_cmd(s, &"mg_receive_attack", [{"token": "a", "effect": effects[id], "data": {}}])
		var events: Array[SimEvent] = _run(s, 20)
		assert_array(_kinds(events)).contains([&"mg_attack_warning"])
		assert_array(_kinds(events)).not_contains([&"mg_attack_applied"])
		events = _run(s, 60)
		assert_array(_kinds(events)).contains([&"mg_attack_applied"])

func _script(id: String) -> Array:
	match id:
		"mg22": return [[&"mg_aim", [1]], [&"mg_spin", [1]], [&"mg_bowl", []]]
		"mg23": return [[&"mg_pad", [0]], [&"mg_pad", [1]], [&"mg_pad", [2]]]
		"mg24": return [[&"mg_tap", []]]
		"mg25": return [[&"mg_answer", [1]]]
		"mg26": return [[&"mg_pick", [0]], [&"mg_pick", [1]]]
		"mg27": return [[&"mg_flip", [0]], [&"mg_flip", [5]], [&"mg_flip", [9]]]
		"mg28": return [[&"mg_step", [1]], [&"mg_step", [-1]]]
		_: return [[&"mg_slide", [Vector2i(1, 0)]], [&"mg_slide", [Vector2i(0, 1)]], [&"mg_slide", [Vector2i(-1, 0)]]]

func _drive(id: String, seed_value: int) -> int:
	var s: WtMinigameSession = _make(id, seed_value)
	var script: Array = _script(id)
	for tick: int in 900:
		if tick % 17 == 0:
			var row: Array = script[(tick / 17) % script.size()]
			_cmd(s, row[0], row[1])
		if tick == 300: _cmd(s, &"mg_receive_attack", [{"token": "x", "effect": str(WtMinigameRulesC.EFFECT_OWNER.find_key(StringName(id))), "data": {}}])
		s.step()
	return s.state_hash()

func test_determinism_same_seed_same_script_same_hash() -> void:
	for id: String in IDS:
		assert_int(_drive(id, 5)).is_equal(_drive(id, 5))

func test_different_seed_changes_challenge() -> void:
	assert_int(_drive("mg25", 1)).is_not_equal(_drive("mg25", 2))

# ---------------------------------------------------------------- ui

func test_ui_extension_covers_ids_and_actions() -> void:
	var ext: Script = load("res://src/ui/minigame_ext_c.gd")
	for id: String in IDS:
		assert_bool(ext.call("handles", id)).is_true()
		assert_int((ext.call("actions", id) as Array).size()).is_greater(0)
	assert_bool(ext.call("handles", "mg01")).is_false()

func _snapshot_for(id: String) -> Dictionary:
	var s: WtMinigameSession = _make(id)
	_run(s, 5)
	var snapshot: Dictionary = s.snapshot()
	snapshot["name"] = id
	snapshot["opponents"] = [{"id": 2, "name": "Lana", "active": true}]
	return snapshot

func test_arena_draws_every_wave2_snapshot_at_two_sizes() -> void:
	for id: String in IDS:
		var snapshot: Dictionary = _snapshot_for(id)
		for dims: Vector2 in [Vector2(640, 300), Vector2(340, 420)]:
			var arena: WtMinigameUi.Arena = auto_free(WtMinigameUi.Arena.new())
			arena.size = dims
			arena.custom_minimum_size = dims
			arena.data = snapshot
			add_child(arena)
			await get_tree().process_frame
			arena.queue_redraw()
			await get_tree().process_frame
			remove_child(arena)

func test_ui_builds_controls_for_every_wave2_id() -> void:
	var ui: WtMinigameUi = auto_free(load("res://src/ui/minigame_ui.tscn").instantiate())
	add_child(ui)
	await get_tree().process_frame
	var expected_art: Dictionary = WtMinigameArt.themes()
	for id: String in IDS:
		if not expected_art.has(id): continue # landmark toy is owned by the art task (GDD AC 7)
		ui.set_snapshot(_snapshot_for(id))
		await get_tree().process_frame
		assert_int(ui._buttons.size()).is_equal((load("res://src/ui/minigame_ext_c.gd").call("actions", id) as Array).size())
	assert_object(WtMinigameUi.ext_for("mg22")).is_not_null()
