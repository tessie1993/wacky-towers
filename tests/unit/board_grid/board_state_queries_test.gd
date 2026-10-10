extends GdUnitTestSuite


func _at(cells: Array[Vector3i]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for c: Vector3i in cells:
		out.append({"kind": 2, "cell": c})
	return out


func test_is_free() -> void:
	var mask: PackedByteArray = PackedByteArray([1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
	var b: BoardState = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_NEG, _at([Vector3i(0, 0, 0)]), mask)
	assert_bool(b.is_free(Vector3i(0, 0, 0))).is_false()
	assert_bool(b.is_free(Vector3i(1, 0, 0))).is_true()
	assert_bool(b.is_free(Vector3i(-1, 0, 0))).is_false()
	assert_bool(b.is_free(Vector3i(2, 3, 0))).is_false()
	assert_bool(BoardFixtures.board(4, 4, 3).is_free(Vector3i(0, 0, 0))).is_true()


func test_can_place() -> void:
	var b: BoardState = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_NEG, _at([Vector3i(3, 6, 0)]))
	var cells: Array[Vector3i] = [Vector3i(0, 6, 0), Vector3i(1, 6, 0), Vector3i(2, 6, 0), Vector3i(3, 6, 0)]
	var empty: BoardState = BoardFixtures.board(4, 4, 3)
	assert_bool(empty.can_place(cells)).is_true()
	assert_bool(b.can_place(cells)).is_false()
	cells[3] = Vector3i(4, 6, 0)
	assert_bool(empty.can_place(cells)).is_false()


func test_cast_down_empty_board() -> void:
	var b: BoardState = BoardFixtures.board(4, 4, 3)
	assert_int(b.cast([Vector3i(1, 6, 1)], Vector3i(0, -1, 0))).is_equal(6)


func test_cast_stops_on_content() -> void:
	var b: BoardState = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_NEG, _at([Vector3i(1, 0, 1)]))
	assert_int(b.cast([Vector3i(1, 6, 1)], Vector3i(0, -1, 0))).is_equal(5)


func test_cast_side_dir() -> void:
	var b: BoardState = BoardFixtures.board(4, 4, 3)
	assert_int(b.cast([Vector3i(0, 3, 0)], Vector3i(1, 0, 0))).is_equal(3)
	assert_int(b.cast([Vector3i(0, 3, 0)], Vector3i(-1, 0, 0))).is_equal(0)


func test_cast_all_6_dirs_full_3d_piece() -> void:
	var b: BoardState = BoardFixtures.board(4, 4, 3)
	var piece: Array[Vector3i] = [Vector3i(1, 3, 1), Vector3i(2, 3, 1), Vector3i(1, 3, 2)]
	# extents: x 1..2 -> +x 1, -x 1; y 3 -> +y 3, -y 3; z 1..2 -> +z 1, -z 1
	var want: Dictionary = {Vector3i(1, 0, 0): 1, Vector3i(-1, 0, 0): 1, Vector3i(0, 1, 0): 3,
			Vector3i(0, -1, 0): 3, Vector3i(0, 0, 1): 1, Vector3i(0, 0, -1): 1}
	for d: Vector3i in want:
		assert_int(b.cast(piece, d)).is_equal(want[d])


func test_cast_blocked_now_is_zero() -> void:
	var b: BoardState = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_NEG, _at([Vector3i(1, 2, 1)]))
	assert_int(b.cast([Vector3i(1, 2, 1)], Vector3i(0, -1, 0))).is_equal(0)


func test_cast_respects_mask() -> void:
	var mask: PackedByteArray = PackedByteArray([1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
	var b: BoardState = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_NEG, [], mask)
	assert_int(b.cast([Vector3i(0, 0, 0)], Vector3i(1, 0, 0))).is_equal(1)


func test_stack_height_6_axes() -> void:
	for d: int in BoardState.Down.values():
		var probe: BoardState = BoardFixtures.board(4, 4, 3, d)
		assert_int(probe.stack_height()).is_equal(-1)
		var cells: Array[Vector3i] = [probe.cell(probe.layer_cells(0)[0]), probe.cell(probe.layer_cells(2)[0])]
		var b: BoardState = BoardFixtures.board(4, 4, 3, d, _at(cells))
		assert_int(b.stack_height()).is_equal(2)


func test_limit_and_over_limit() -> void:
	var low: BoardState = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_NEG, _at([Vector3i(0, 2, 0)]))
	assert_int(low.limit_layer()).is_equal(3)
	assert_bool(low.over_limit()).is_false()
	var high: BoardState = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_NEG, _at([Vector3i(0, 3, 0)]))
	assert_bool(high.over_limit()).is_true()
	# x/z limits follow ADR-0002 Open Item 1: extent 4 - C 4 = 0, so any solid is over.
	var x: BoardState = BoardFixtures.board(4, 4, 3, BoardState.Down.X_NEG, _at([Vector3i(0, 0, 0)]))
	assert_int(x.limit_layer()).is_equal(0)
	assert_bool(x.over_limit()).is_true()


func test_no_allocation_smoke() -> void:
	var b: BoardState = BoardFixtures.board(4, 4, 3)
	var piece: Array[Vector3i] = [Vector3i(1, 6, 1), Vector3i(2, 6, 1)]
	var total: int = 0
	for n: int in 10000:
		if b.can_place(piece):
			total += b.cast(piece, Vector3i(0, -1, 0))
	assert_int(total).is_equal(60000)
