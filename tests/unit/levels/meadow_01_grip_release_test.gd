extends GdUnitTestSuite
## meadow_01 "Stump Day" (design/levels/meadow/meadow_01.md section 3, Decisions 2026-10-15).
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const PATH := "res://src/levels/meadow/meadow_01/meadow_01.json"
const PROD := "res://production/levels/meadow/data/meadow_01.json"


func _raw() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(PATH))


func _params() -> Dictionary:
	return _raw()["rules"][0]["params"]


func _pit_board() -> BoardState:
	var mask := PackedByteArray()
	for row: String in _raw()["board"]["mask"]:
		for ch: String in row:
			mask.append(0 if ch == "." else 1)
	return BoardState.new(BoardFixtures.spec(8, 8, 8, BoardState.Down.Y_NEG, [], mask), F.types())


func _apply(api: RuleApi, board: BoardState) -> void:
	for r: Dictionary in api.take_requests():
		if r["op"] == &"mask":
			board.set_active(r["x"], r["z"], r["on"])


func _clear_layer(rule: GripReleaseRule, api: RuleApi, board: BoardState, layer: int = 0) -> void:
	rule.handle(&"on_lock", F.context(), api)
	for cell: int in 3:
		rule.handle(&"on_clear", F.context({"layer": layer, "chain_round": 1}), api)
	_apply(api, board)


func _width(board: BoardState) -> int:
	var xs := {}
	for x: int in 8:
		for z: int in 8:
			if board.is_active(board.index(Vector3i(x, 0, z))):
				xs[x] = true
	return xs.size()


func _setup() -> Array:
	var board := _pit_board()
	return [GripReleaseRule.new(), F.api(board, _params()), board]


func test_pit_widths_grow_four_six_eight_then_full_stump() -> void:
	var s := _setup()
	var board: BoardState = s[2]
	var seen: Array[int] = [_width(board)]
	for _g: int in 3:
		_clear_layer(s[0], s[1], board)
		seen.append(_width(board))
	assert_array(seen).is_equal([4, 6, 8, 8])
	assert_int(board.active_in_layer(0)).is_equal(52)


func test_pit_cell_counts_are_16_24_32() -> void:
	var s := _setup()
	var board: BoardState = s[2]
	var counts: Array[int] = [board.active_in_layer(0)]
	for _g: int in 2:
		_clear_layer(s[0], s[1], board)
		counts.append(board.active_in_layer(0))
	assert_array(counts).is_equal([16, 24, 32])


func test_grips_release_left_then_right_then_rim_in_all_layers() -> void:
	var s := _setup()
	var board: BoardState = s[2]
	_clear_layer(s[0], s[1], board)
	for y: int in [0, 5, 11]:
		assert_bool(board.is_active(board.index(Vector3i(0, y, 3)))).is_true()
		assert_bool(board.is_active(board.index(Vector3i(7, y, 3)))).is_false()
	_clear_layer(s[0], s[1], board)
	assert_bool(board.is_active(board.index(Vector3i(7, 9, 3)))).is_true()
	assert_bool(board.is_active(board.index(Vector3i(3, 9, 0)))).is_false()
	_clear_layer(s[0], s[1], board)
	assert_bool(board.is_active(board.index(Vector3i(3, 9, 0)))).is_true()
	assert_bool(board.is_active(board.index(Vector3i(0, 0, 0)))).is_false()


func test_one_grip_per_layer_clear_not_per_cell() -> void:
	var s := _setup()
	var rule: GripReleaseRule = s[0]
	rule.handle(&"on_lock", F.context(), s[1])
	for _c: int in 4:
		rule.handle(&"on_clear", F.context({"layer": 0, "chain_round": 1}), s[1])
	assert_int(rule.snapshot()["released"]).is_equal(1)


func test_speed_multiplies_1_25_per_release() -> void:
	var s := _setup()
	var scales: Array[float] = []
	for _g: int in 3:
		_clear_layer(s[0], s[1], s[2])
	var api: RuleApi = F.api(_pit_board(), _params())
	var rule := GripReleaseRule.new()
	for g: int in 3:
		rule.handle(&"on_clear", F.context({"layer": g, "chain_round": 1}), api)
		for r: Dictionary in api.take_requests():
			if r["op"] == &"modifiers":
				scales.append(float(r["modifiers"][0]["value"]))
	assert_float(scales[0]).is_equal_approx(1.25, 0.0001)
	assert_float(scales[1]).is_equal_approx(1.5625, 0.0001)
	assert_float(scales[2]).is_equal_approx(1.953125, 0.0001)


func test_third_release_is_last_and_extra_clears_do_nothing() -> void:
	var s := _setup()
	for _g: int in 5:
		_clear_layer(s[0], s[1], s[2])
	assert_int(s[0].snapshot()["released"]).is_equal(3)


func test_level_data_sets_win_on_third_grip_and_three_rescues() -> void:
	var raw := _raw()
	assert_int(int(raw["goal"]["n"])).is_equal(3)
	assert_str(raw["goal"]["type"]).is_equal("clear_n")
	assert_int(int(raw["knobs"]["goal.warnings_max"])).is_equal(3)
	assert_str(raw["hud"]["objective"]).is_equal("Free the Hearth Stump.")
	assert_str(raw["metadata"]["level_type"]).is_equal("funny")
	assert_array(raw["pieces"]["shapes"]).is_equal(["o", "i", "l"])
	assert_float(float(_params()["ramp_per_release_mult"])).is_equal(1.25)
	assert_bool(_params().has("ramp_per_minute_add")).is_false()


func test_source_and_production_json_agree() -> void:
	assert_dict(JSON.parse_string(FileAccess.get_file_as_string(PROD))).is_equal(_raw())


func test_level_loads_and_wins_on_third_clear_in_sim() -> void:
	var content := WtContent.new()
	var catalog: GameCatalog = content.load_catalog()
	var level: LevelData = content.level("meadow_01")
	assert_that(level).override_failure_message(str(content.last_issues)).is_not_null()
	var sim := BoardSim.new(level, 5, catalog)
	assert_int(sim.knobs().int_value(&"goal.warnings_max")).is_equal(3)
	assert_int(sim.board().active_in_layer(0)).is_equal(16)


# --- edge policies, rule level (the fake hook context mirrors BoardSim._clear_pass data) ---------------------

func _clear_ctx(layer: int, clear_count: int, round_no: int = 1) -> HookContext:
	return F.context({"layer": layer, "chain_round": round_no, "clear_count": clear_count})


func test_same_round_reclear_of_same_layer_index_releases_again() -> void:
	var s := _setup()
	var rule: GripReleaseRule = s[0]
	rule.handle(&"on_lock", F.context(), s[1])
	# Layer 0 clears (round 1), the stack collapses, the NEW layer 0 is full and clears in round 1 of the next pass.
	for cell: int in 3:
		rule.handle(&"on_clear", _clear_ctx(0, 1), s[1])
	for cell: int in 3:
		rule.handle(&"on_clear", _clear_ctx(0, 2), s[1])
	assert_int(rule.snapshot()["released"]).is_equal(2)


func test_two_layers_cleared_in_one_resolve_release_two_grips() -> void:
	var s := _setup()
	var rule: GripReleaseRule = s[0]
	rule.handle(&"on_lock", F.context(), s[1])
	for layer: int in [0, 1]:
		for cell: int in 3:
			rule.handle(&"on_clear", _clear_ctx(layer, 2), s[1])
	_apply(s[1], s[2])
	assert_int(rule.snapshot()["released"]).is_equal(2)
	assert_int(_width(s[2])).is_equal(8)


func test_part_filled_layer_needs_the_new_cells_after_widening() -> void:
	var s := _setup()
	var board: BoardState = s[2]
	var kind: int = F.types().kind_of(&"block")
	for i: int in board.layer_cells(0):
		if board.is_active(i):
			board.place(i, kind, 1, 700 + i)
	assert_bool(board.layer_full(0)).is_true()
	_clear_layer(s[0], s[1], board)
	assert_bool(board.layer_full(0)).override_failure_message("widened layer must not stay full").is_false()
	assert_int(board.active_in_layer(0) - board.filled_in_layer(0)).is_equal(8)
	for i: int in board.layer_cells(0):
		if board.is_active(i) and board.get_kind(i) == 0:
			board.place(i, kind, 1, 800 + i)
	assert_bool(board.layer_full(0)).is_true()


func test_rule_restore_mid_level_continues_with_next_stage() -> void:
	var s := _setup()
	_clear_layer(s[0], s[1], s[2])
	var saved: Dictionary = (s[0] as GripReleaseRule).snapshot()
	var board := _pit_board()
	var api: RuleApi = F.api(board, _params())
	var restored := GripReleaseRule.new()
	restored.restore(saved)
	assert_int(restored.snapshot()["released"]).is_equal(1)
	restored.handle(&"on_lock", F.context(), api)
	restored.handle(&"on_clear", _clear_ctx(0, 2), api)
	var scale: float = 0.0
	for r: Dictionary in api.take_requests():
		if r["op"] == &"mask":
			board.set_active(r["x"], r["z"], true)
		elif r["op"] == &"modifiers":
			scale = float(r["modifiers"][0]["value"])
	# Stage index 1 (right stones: x 6..7) opens, not stage 0 again; 1.25 squared, no cap key involved.
	assert_bool(board.is_active(board.index(Vector3i(7, 0, 3)))).is_true()
	assert_bool(board.is_active(board.index(Vector3i(0, 0, 3)))).is_false()
	assert_float(scale).is_equal_approx(1.5625, 0.0001)
	assert_bool(_params().has("ramp_cap_mult")).is_false()


# --- real BoardSim, real meadow_01 ---------------------------------------------------------------------------

var _catalog: GameCatalog
var _kinds: Array[StringName] = []


func _new_sim(seed_value: int) -> BoardSim:
	var content := WtContent.new()
	_catalog = content.load_catalog()
	var level: LevelData = content.level("meadow_01")
	assert_that(level).override_failure_message(str(content.last_issues)).is_not_null()
	var sim := BoardSim.new(level, seed_value, _catalog)
	sim.get_api().inject_front(PackedStringArray(["o"])) # flat 2x2 pieces only, so every landing is one layer thick
	_kinds.clear()
	return sim


func _step(sim: BoardSim) -> void:
	for event: SimEvent in sim.step():
		_kinds.append(event.kind)


func _await_piece(sim: BoardSim) -> void:
	for _t: int in 900:
		if sim.get_piece() != null or sim.result() != null:
			return
		_step(sim)


## Cells the dropped piece will occupy once it rests on the floor (layer 0 for the flat meadow pieces).
func _landing(sim: BoardSim) -> Array[Vector3i]:
	assert_that(sim.get_piece()).is_not_null()
	assert_str(String(sim.get_piece().shape.shape_id)).is_equal("o")
	var cells: Array[Vector3i] = sim.get_piece().cells()
	var low: int = cells[0].y
	for c: Vector3i in cells:
		low = mini(low, c.y)
	var out: Array[Vector3i] = []
	for c: Vector3i in cells:
		out.append(Vector3i(c.x, c.y - low, c.z))
	return out


func _fill_layer(sim: BoardSim, layer: int, skip: Array[Vector3i]) -> void:
	var board := sim.board()
	var kind: int = _catalog.content.kind_of(&"block")
	for i: int in board.layer_cells(layer):
		if board.is_active(i) and board.get_kind(i) == 0 and not skip.has(board.cell(i)):
			board.place(i, kind, 1, 900 + i)


## Column of stacked cubes (y 0..top) on the first active floor cell the piece will not land on.
func _tower(sim: BoardSim, landing: Array[Vector3i], top: int) -> void:
	var board := sim.board()
	var kind: int = _catalog.content.kind_of(&"block")
	for i: int in board.layer_cells(0):
		var c: Vector3i = board.cell(i)
		if board.is_active(i) and not landing.has(c):
			for y: int in range(0, top + 1):
				board.place(board.index(Vector3i(c.x, y, c.z)), kind, 1, 950 + y)
			return


## Hard-drops the current piece; `in_grace` (optional) runs while it hangs in the grace window. Steps until resolved.
func _drop(sim: BoardSim, in_grace: Callable = Callable()) -> void:
	var locks: int = sim.goal_state().locks
	sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
	_step(sim)
	if in_grace.is_valid():
		assert_int(sim.get_phase()).is_equal(BoardSim.Phase.GRACE)
		in_grace.call()
	for _t: int in 600:
		if sim.goal_state().locks > locks:
			break
		_step(sim)
	assert_int(sim.goal_state().locks).is_equal(locks + 1)
	sim.get_api().inject_front(PackedStringArray(["o"]))
	for _t: int in 900:
		if sim.get_piece() != null or sim.result() != null:
			return
		_step(sim)


## One plain clear: floor filled except the landing cells, then the piece completes layer 0.
func _plain_clear(sim: BoardSim) -> void:
	_await_piece(sim)
	_fill_layer(sim, 0, _landing(sim))
	_drop(sim)


func _gravity(sim: BoardSim) -> float:
	return float(sim.knobs().value(&"fall.gravity_scale")) / 1000.0 # knob is stored in milli-units


func _grips(events: Array[StringName]) -> int:
	return events.count(&"grip_released")


func test_meadow_01_three_clears_in_real_sim_widen_pit_speed_up_and_win() -> void:
	var sim := _new_sim(5)
	var widths: Array[int] = []
	var speeds: Array[float] = [_gravity(sim)]
	for _g: int in 3:
		_plain_clear(sim)
		widths.append(_width(sim.board()))
		speeds.append(_gravity(sim))
	assert_array(widths).is_equal([6, 8, 8])
	assert_float(speeds[0]).is_equal_approx(1.0, 0.0001)
	assert_float(speeds[1]).is_equal_approx(1.25, 0.0001)
	assert_float(speeds[2]).is_equal_approx(1.5625, 0.001) # knob stores milli-units
	assert_int(_grips(_kinds)).is_equal(3)
	assert_that(sim.result()).is_not_null()
	assert_bool(sim.result().is_won()).is_true()
	assert_int(sim.result().layers_cleared).is_equal(3)
	assert_int(sim.result().warnings_used).is_equal(0)
	assert_int(sim.result().stars).is_equal(3)


func test_two_layers_cleared_by_one_lock_release_two_grips_and_win_at_three() -> void:
	var sim := _new_sim(5)
	_plain_clear(sim)
	assert_int(sim.goal_state().layers_cleared).is_equal(1)
	assert_int(_grips(_kinds)).is_equal(1)
	_await_piece(sim)
	_fill_layer(sim, 0, _landing(sim))
	# Layer 1 is filled while the piece hangs in its grace window, so the lock completes layers 0 and 1 together.
	_drop(sim, func() -> void: _fill_layer(sim, 1, []))
	assert_int(sim.goal_state().layers_cleared).is_equal(3)
	assert_int(_grips(_kinds)).is_equal(3)
	assert_bool(sim.result() != null and sim.result().is_won()).is_true()
	assert_int(sim.board().active_in_layer(0)).is_equal(52)


func test_clear_in_same_resolve_as_a_rescue_counts_its_grip() -> void:
	var sim := _new_sim(5)
	_await_piece(sim)
	var landing := _landing(sim)
	var limit: int = sim.board().limit_layer()
	_tower(sim, landing, limit + 1) # still over the red line after the clear drops the stack by one
	_fill_layer(sim, 0, landing)
	_drop(sim)
	assert_int(sim.goal_state().layers_cleared).is_equal(1)
	assert_int(sim.goal_state().warnings_used).is_equal(1)
	assert_int(_grips(_kinds)).is_equal(1)
	assert_int(_width(sim.board())).is_equal(6)


func test_top_out_on_the_release_tick_resolves_the_release_first() -> void:
	var sim := _new_sim(5)
	_await_piece(sim)
	var landing := _landing(sim)
	var limit: int = sim.board().limit_layer()
	_tower(sim, landing, limit) # over the line before the clear, back under it once the clear drops the stack
	_fill_layer(sim, 0, landing)
	_drop(sim)
	assert_int(sim.goal_state().layers_cleared).is_equal(1)
	assert_int(_grips(_kinds)).is_equal(1)
	assert_int(sim.goal_state().warnings_used).override_failure_message("no rescue is spent").is_equal(0)
	assert_bool(sim.board().over_limit()).is_false()


func test_rescue_without_clear_releases_no_grip() -> void:
	var sim := _new_sim(5)
	_await_piece(sim)
	var landing := _landing(sim)
	_tower(sim, landing, sim.board().limit_layer())
	var speed: float = _gravity(sim)
	_drop(sim) # the floor is not full: no clear, the lock tops out and the real rescue rule wipes 3 layers
	assert_int(sim.goal_state().warnings_used).is_equal(1)
	assert_int(sim.goal_state().layers_cleared).is_equal(0)
	assert_int(_grips(_kinds)).is_equal(0)
	assert_int(_width(sim.board())).is_equal(4)
	assert_float(_gravity(sim)).is_equal_approx(speed, 0.0001)
	assert_bool(sim.board().over_limit()).is_false()


func _play_script(seed_value: int) -> Array:
	var sim := _new_sim(seed_value)
	var hashes: Array[int] = [sim.state_hash()]
	for _g: int in 2:
		_plain_clear(sim)
		hashes.append(sim.state_hash())
	return [hashes, _kinds.duplicate(), _width(sim.board())]


func test_replay_with_logged_seed_is_deterministic() -> void:
	var logged_seed: int = 20261015
	var first: Array = _play_script(logged_seed)
	var second: Array = _play_script(logged_seed)
	assert_array(second[0]).is_equal(first[0])
	assert_array(second[1]).is_equal(first[1])
	assert_int(second[2]).is_equal(8)
	assert_bool(first[0][1] != first[0][2]).override_failure_message("grip state must move the hash").is_true()
