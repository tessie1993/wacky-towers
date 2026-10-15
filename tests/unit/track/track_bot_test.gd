extends GdUnitTestSuite
## G8 survival bots and build-rate sanity: a tidy bot must finish both shipped tracks on the hearts rule, a
## careless one must not, and the first arches must be survivable at a realistic build rate.
const T := preload("res://tests/unit/track/track_fixture.gd")
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const PIECE_MS := 3500  # one four-cell piece per 3.5 s at fall_pct 100: a generous player pace


## Cell order for a bot: layer by layer, inside a size x size centred plateau (spiral from the centre), or a
## single far-corner column for the careless bot.
func _order(plateau_size: int, layers: int, corner: bool) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	if corner:
		for y: int in T.H - 1:
			out.append(Vector3i(T.W - 1, y, T.D - 1))
		return out
	var start: int = (T.W - plateau_size) / 2
	for y: int in layers:
		var layer: Array[Vector3i] = []
		for z: int in range(start, start + plateau_size):
			for x: int in range(start, start + plateau_size):
				layer.append(Vector3i(x, y, z))
		# Square rings from the centre outwards, so a half-built layer stays roughly centred.
		layer.sort_custom(func(a: Vector3i, b: Vector3i) -> bool:
			var ra: int = maxi(absi(2 * a.x + 1 - T.W), absi(2 * a.z + 1 - T.D))
			var rb: int = maxi(absi(2 * b.x + 1 - T.W), absi(2 * b.z + 1 - T.D))
			return ra < rb or (ra == rb and (a.z < b.z or (a.z == b.z and a.x < b.x))))
		out.append_array(layer)
	return out


## Plays a whole track: drops a four-cell piece every PIECE_MS (scaled by fall speed) in `order`, restarting the
## fill when the runner wipes the board. Returns {"runner", "records"}.
func _play(track_id: String, order: Array[Vector3i]) -> Dictionary:
	var def: TrackDef = TrackDef.load_file(T.DIR + track_id + ".json")
	var board: BoardState = T.board()
	var api: RuleApi = F.api(board)
	var runner := TrackRunner.new(def)
	var records: Array[Dictionary] = []
	var filled: int = 0
	var attempts: int = 1
	var until_piece: int = PIECE_MS
	var guard: int = 0
	while not runner.is_finished() and not runner.is_failed() and guard < 20000:
		guard += 1
		records.append_array(runner.step(50, api))
		api.flush_writes()
		if runner.attempts() != attempts:
			attempts = runner.attempts()
			filled = 0
		until_piece -= 50 * 100 / def.fall_pct_at(runner.position_mm())
		if until_piece <= 0:
			until_piece = PIECE_MS
			for _c: int in 4:
				if filled < order.size():
					board.place(board.index(order[filled]), 1, 0, 1)
					filled += 1
	return {"runner": runner, "records": records}


func test_tidy_bot_finishes_brook_run_with_hearts_to_spare() -> void:
	var res: Dictionary = _play("meadow_brook_run", _order(4, 4, false))
	var runner: TrackRunner = res["runner"]
	assert_bool(runner.is_finished()).is_true()
	assert_int(runner.hearts_left()).is_greater_equal(2)
	assert_int(runner.stars()).is_greater_equal(2)


func test_tidy_bot_finishes_kite_day_by_staying_light() -> void:
	var res: Dictionary = _play("meadow_kite_day", _order(4, 3, false))
	var runner: TrackRunner = res["runner"]
	var missed: Array[Dictionary] = T.of_kind(res["records"], TrackRunner.EV_RING).filter(func(r: Dictionary) -> bool: return not bool(r["hit"]))
	assert_array(missed).is_empty()
	assert_bool(runner.is_finished()).is_true()


func test_a_heavy_bot_misses_the_kite_rings() -> void:
	var res: Dictionary = _play("meadow_kite_day", _order(8, 6, false))
	var missed: Array[Dictionary] = T.of_kind(res["records"], TrackRunner.EV_RING).filter(func(r: Dictionary) -> bool: return not bool(r["hit"]))
	assert_array(missed).is_not_empty()


func test_a_careless_bot_runs_out_of_hearts_on_both_tracks() -> void:
	for id: String in ["meadow_brook_run", "meadow_kite_day"]:
		var res: Dictionary = _play(id, _order(1, 1, true))
		var runner: TrackRunner = res["runner"]
		assert_bool(runner.is_failed()).is_true()
		assert_str(String(runner.fail_reason())).is_equal("no_hearts")


func test_the_first_arches_are_survivable_at_a_realistic_build_rate() -> void:
	var def: TrackDef = TrackDef.load_file(T.DIR + "meadow_brook_run.json")
	for e: Dictionary in def.events:
		if e["kind"] != TrackDef.KIND_ARCH:
			continue
		var ms: int = def.time_between_ms(0, int(e["at_mm"]))
		var pieces: int = ms / PIECE_MS
		var layers_of_16: int = pieces * 4 / 16  # a 4x4 plateau
		var safe: int = int(e["gap_layers"]) - int(def.cargo["height_layers"])
		assert_bool(layers_of_16 >= 1).is_true()  # there is something on the cart to protect
		assert_bool(pieces * 4 / 64 <= safe).is_true()  # even an 8x8 filler cannot overshoot before the gate
