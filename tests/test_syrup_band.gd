@tool
extends "res://addons/godot_ai/testing/test_suite.gd"
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const Syrup := preload("res://src/mechanics/behaviour/syrup_band.gd")


func suite_name() -> String:
	return "syrup_band"


func _piece(pivot: Vector3i) -> ActivePiece:
	return ActivePiece.new(ShapeDef.build(&"lab_cube", [Vector3i.ZERO]), pivot)


func test_syrup_slows_only_authored_rows() -> void:
	var api: RuleApi = F.api(F.board(5, 4, 4), {"band_rows": [1, 2], "syrup_slow": 0.5})
	var piece: ActivePiece = _piece(Vector3i(0, 2, 1))
	api.bind_piece(piece)
	var rule := Syrup.new()
	F.handle(rule, &"on_spawn", api)
	assert_eq(rule.snapshot()["gravity_scale"], 500)
	piece.pivot.z = 0
	F.handle(rule, &"on_tick", api)
	assert_eq(rule.snapshot()["gravity_scale"], 1000)


func test_glide_matches_preview_and_runs_once_then_requests_lock() -> void:
	var api: RuleApi = F.api(F.board(5, 4, 4), {"band_rows": [1], "syrup_glide": 2})
	var piece: ActivePiece = _piece(Vector3i(0, 3, 1))
	api.bind_piece(piece)
	var rule := Syrup.new()
	var rng_before: int = api.rng().state
	F.handle(rule, &"on_spawn", api)
	var predicted: Array[Vector3i] = rule._landing(piece.cells(), api)
	piece.pivot += api.down_vector() * api.cast(piece.cells(), api.down_vector())
	F.handle(rule, &"on_land", api)
	assert_eq(piece.cells(), predicted)
	assert_eq(piece.pivot, Vector3i(2, 0, 1))
	F.handle(rule, &"on_land", api)
	assert_eq(piece.pivot, Vector3i(2, 0, 1))
	var lock_requested: bool = false
	for request: Dictionary in api.take_requests():
		if request.get("op") == &"piece_flag" and request.get("flag") == &"lock_now":
			lock_requested = true
	assert_true(lock_requested)
	assert_eq(api.rng().state, rng_before)


func test_blocked_glide_stops_at_first_legal_cell() -> void:
	var board: BoardState = F.board(5, 4, 4)
	F.write(board, [Vector3i(2, 0, 1)])
	var api: RuleApi = F.api(board, {"band_rows": [1], "syrup_glide": 2})
	var piece: ActivePiece = _piece(Vector3i(0, 0, 1))
	api.bind_piece(piece)
	var rule := Syrup.new()
	F.handle(rule, &"on_spawn", api)
	F.handle(rule, &"on_land", api)
	assert_eq(piece.pivot, Vector3i(1, 0, 1))


func test_dry_row_never_glides() -> void:
	var api: RuleApi = F.api(F.board(5, 4, 4), {"band_rows": [1]})
	var piece: ActivePiece = _piece(Vector3i(0, 0, 0))
	api.bind_piece(piece)
	F.handle(Syrup.new(), &"on_land", api)
	assert_eq(piece.pivot, Vector3i(0, 0, 0))
