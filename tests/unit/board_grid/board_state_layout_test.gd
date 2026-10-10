extends GdUnitTestSuite


func test_size_and_count() -> void:
	var b: BoardState = BoardFixtures.board(4, 5, 3)
	assert_vector(b.size()).is_equal(Vector3i(4, 7, 5))
	assert_int(b.h_play()).is_equal(3)
	assert_int(b.active_cell_count()).is_equal(140)


func test_index_formula() -> void:
	var b: BoardState = BoardFixtures.board(4, 4, 3)
	assert_int(b.index(Vector3i(1, 2, 3))).is_equal(45)
	assert_vector(b.cell(45)).is_equal(Vector3i(1, 2, 3))
	for i: int in 4 * 7 * 4:
		assert_int(b.index(b.cell(i))).is_equal(i)


func test_in_bounds() -> void:
	var b: BoardState = BoardFixtures.board(4, 4, 3)
	for c: Vector3i in [Vector3i(0, 0, 0), Vector3i(3, 6, 3)]:
		assert_bool(b.in_bounds(c)).is_true()
	for c: Vector3i in [Vector3i(-1, 0, 0), Vector3i(4, 0, 0), Vector3i(0, 7, 0), Vector3i(0, 0, 4)]:
		assert_bool(b.in_bounds(c)).is_false()


func test_mask_expands_full_height() -> void:
	var m: PackedByteArray = PackedByteArray()
	m.resize(16)
	m.fill(1)
	m[0] = 0
	var b: BoardState = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_NEG, [] as Array[Dictionary], m)
	for y: int in 7:
		assert_bool(b.is_active(b.index(Vector3i(0, y, 0)))).is_false()
		assert_bool(b.is_active(b.index(Vector3i(1, y, 0)))).is_true()
	assert_int(b.active_cell_count()).is_equal(15 * 7)


func test_starting_contents_written() -> void:
	var contents: Array[Dictionary] = [{"cell": Vector3i(1, 0, 2), "kind": 2}]
	var b: BoardState = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_NEG, contents)
	var i: int = b.index(Vector3i(1, 0, 2))
	assert_int(b.get_kind(i)).is_equal(2)
	assert_int(b.get_color(i)).is_equal(BoardFixtures.types().hue(2))
	assert_int(b.get_kind(b.index(Vector3i(0, 0, 2)))).is_equal(0)
	assert_int(b.get_kind(b.index(Vector3i(1, 1, 2)))).is_equal(0)


func test_empty_cells_are_zero() -> void:
	var b: BoardState = BoardFixtures.board(4, 4, 3)
	for i: int in 4 * 7 * 4:
		assert_int(b.get_kind(i)).is_equal(0)
		assert_int(b.get_color(i)).is_equal(0)


# --- CH-030 layers ---

func _contents_of(b: BoardState, k: int) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for i: int in b.layer_cells(k):
		out.append({"kind": 2, "cell": b.cell(i)})
	return out


func test_layer_count_6_axes() -> void:
	for d: int in BoardState.Down.values():
		var b: BoardState = BoardFixtures.board(4, 4, 3, d)
		var want: int = 7 if d == BoardState.Down.Y_NEG or d == BoardState.Down.Y_POS else 4
		assert_int(b.layer_count()).is_equal(want)
		assert_int(b.get_down()).is_equal(d)
		assert_vector(b.down_vector()).is_equal(BoardState.down_vector_of(d))


func test_layer_cells_goldens() -> void:
	var yneg: PackedInt32Array = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_NEG).layer_cells(0)
	var want: PackedInt32Array = PackedInt32Array()
	for i: int in 16:
		want.append(i)
	assert_array(yneg).is_equal(want)
	var ypos: PackedInt32Array = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_POS).layer_cells(0)
	for i: int in 16:
		want[i] = 96 + i
	assert_array(ypos).is_equal(want)
	var xneg: PackedInt32Array = BoardFixtures.board(4, 4, 3, BoardState.Down.X_NEG).layer_cells(0)
	var want_x: PackedInt32Array = PackedInt32Array()
	var want_z: PackedInt32Array = PackedInt32Array()
	for i: int in 112:
		if i % 4 == 0:
			want_x.append(i)
		if (i / 4) % 4 == 3:
			want_z.append(i)
	assert_int(xneg.size()).is_equal(28)
	assert_array(xneg).is_equal(want_x)
	assert_array(BoardFixtures.board(4, 4, 3, BoardState.Down.Z_POS).layer_cells(0)).is_equal(want_z)


func test_order_is_permutation_6_axes() -> void:
	for d: int in BoardState.Down.values():
		var b: BoardState = BoardFixtures.board(4, 4, 3, d)
		var seen: PackedByteArray = PackedByteArray()
		seen.resize(112)
		var total: int = 0
		for k: int in b.layer_count():
			for i: int in b.layer_cells(k):
				seen[i] += 1
				total += 1
				assert_int(b.layer_of(i)).is_equal(k)
		assert_int(total).is_equal(112)
		for i: int in 112:
			assert_int(seen[i]).is_equal(1)


func test_stepping_down_lowers_layer_6_axes() -> void:
	for d: int in BoardState.Down.values():
		var b: BoardState = BoardFixtures.board(4, 4, 3, d)
		for i: int in 112:
			var c: Vector3i = b.cell(i)
			var n: Vector3i = c + b.down_vector()
			if b.in_bounds(n):
				assert_int(b.layer_of(b.index(n))).is_equal(b.layer_of(i) - 1)


func test_layer_full_from_contents_6_axes() -> void:
	for d: int in BoardState.Down.values():
		var first: BoardState = BoardFixtures.board(4, 4, 3, d)
		var b: BoardState = BoardFixtures.board(4, 4, 3, d, _contents_of(first, 0))
		assert_bool(b.layer_full(0)).is_true()
		assert_array(b.full_layers()).is_equal(PackedInt32Array([0]))
		assert_int(b.filled_in_layer(0)).is_equal(b.active_in_layer(0))
		assert_bool(b.layer_full(1)).is_false()


func test_masked_cells_do_not_block_full() -> void:
	var mask: PackedByteArray = PackedByteArray()
	mask.resize(16)
	mask.fill(1)
	mask[0] = 0
	var contents: Array[Dictionary] = []
	for i: int in range(1, 16):
		contents.append({"kind": 2, "cell": Vector3i(i % 4, 0, i / 4)})
	var b: BoardState = BoardFixtures.board(4, 4, 3, BoardState.Down.Y_NEG, contents, mask)
	assert_bool(b.layer_full(0)).is_true()
	assert_int(b.active_in_layer(0)).is_equal(15)


func test_empty_layer_not_full() -> void:
	assert_bool(BoardFixtures.board(4, 4, 3).full_layers().is_empty()).is_true()
