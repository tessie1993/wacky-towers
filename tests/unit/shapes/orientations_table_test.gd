extends GdUnitTestSuite

const V: Vector3i = Vector3i(1, 2, 3)


func _dot(r: Vector3i, v: Vector3i) -> int:
	return r.x * v.x + r.y * v.y + r.z * v.z


func test_count_is_24_and_all_distinct() -> void:
	var seen: Dictionary = {}
	for o: int in range(Orientations.COUNT):
		seen[Orientations.matrix(o)] = true
	assert_int(Orientations.COUNT).is_equal(24)
	assert_int(seen.size()).is_equal(24)


func test_index_0_is_identity() -> void:
	assert_vector(Orientations.apply(0, V)).is_equal(V)


func test_first_bfs_indices_are_generators() -> void:
	assert_vector(Orientations.apply(1, Vector3i(0, 1, 0))).is_equal(Vector3i(0, 0, 1))
	assert_vector(Orientations.apply(2, Vector3i(1, 0, 0))).is_equal(Vector3i(0, 0, -1))
	assert_vector(Orientations.apply(3, Vector3i(1, 0, 0))).is_equal(Vector3i(0, 1, 0))


func test_turn_from_identity_hits_generators() -> void:
	assert_int(Orientations.turn(0, Orientations.Axis.X, 1)).is_equal(1)
	assert_int(Orientations.turn(0, Orientations.Axis.Y, 1)).is_equal(2)
	assert_int(Orientations.turn(0, Orientations.Axis.Z, 1)).is_equal(3)


func test_matrices_are_signed_permutations_with_det_plus_one() -> void:
	for o: int in range(Orientations.COUNT):
		var m: Array[Vector3i] = Orientations.matrix(o)
		for r: Vector3i in m:
			assert_int(absi(r.x) + absi(r.y) + absi(r.z)).is_equal(1)
		var det: int = m[0].x * (m[1].y * m[2].z - m[1].z * m[2].y) \
			- m[0].y * (m[1].x * m[2].z - m[1].z * m[2].x) \
			+ m[0].z * (m[1].x * m[2].y - m[1].y * m[2].x)
		assert_int(det).is_equal(1)


func test_four_turns_return_to_start() -> void:
	for o: int in range(Orientations.COUNT):
		for a: int in range(3):
			for d: int in [1, -1]:
				var c: int = o
				for i: int in range(4):
					c = Orientations.turn(c, a, d)
				assert_int(c).is_equal(o)


func test_pos_then_neg_is_identity() -> void:
	for o: int in range(Orientations.COUNT):
		for a: int in range(3):
			assert_int(Orientations.turn(Orientations.turn(o, a, 1), a, -1)).is_equal(o)


func test_apply_matches_matrix_product() -> void:
	for o: int in range(Orientations.COUNT):
		var m: Array[Vector3i] = Orientations.matrix(o)
		var expected: Vector3i = Vector3i(_dot(m[0], V), _dot(m[1], V), _dot(m[2], V))
		assert_vector(Orientations.apply(o, V)).is_equal(expected)


func test_turn_is_world_axis_left_multiply() -> void:
	for o: int in range(Orientations.COUNT):
		for a: int in range(3):
			var lhs: Vector3i = Orientations.apply(Orientations.turn(o, a, 1), V)
			var rhs: Vector3i = Orientations.apply(Orientations.turn(0, a, 1), Orientations.apply(o, V))
			assert_vector(lhs).is_equal(rhs)
