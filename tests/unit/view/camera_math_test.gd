extends GdUnitTestSuite

const RIGHT: Array[Vector3i] = [Vector3i(1, 0, 0), Vector3i(0, 0, -1), Vector3i(-1, 0, 0), Vector3i(0, 0, 1)]
const UP: Array[Vector3i] = [Vector3i(0, 0, -1), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(1, 0, 0)]
const B: int = 45
const S: int = 30


func _map(k: int, d: Vector2i) -> Vector3i:
	return CameraMath.screen_dir_to_world(k, d, B, S)


func test_yaw_degrees() -> void:
	var cases: Dictionary = {0: 45.0, 4: 165.0, 11: 15.0, 12: 45.0, -1: 15.0}
	for k: int in cases:
		assert_float(CameraMath.yaw_degrees(k, B, S)).is_equal(cases[k])


func test_mapping_all_12_snaps() -> void:
	for k in range(12):
		assert_vector(_map(k, Vector2i(1, 0))).is_equal(RIGHT[k / 3])
		assert_vector(_map(k, Vector2i(0, -1))).is_equal(UP[k / 3])
		assert_vector(_map(k, Vector2i(-1, 0))).is_equal(-RIGHT[k / 3])
		assert_vector(_map(k, Vector2i(0, 1))).is_equal(-UP[k / 3])


func test_yaw_75_right_is_plus_x() -> void:
	assert_vector(_map(1, Vector2i(1, 0))).is_equal(Vector3i(1, 0, 0))


func test_corner_tie_rule_k0() -> void:
	assert_vector(_map(0, Vector2i(1, 0))).is_equal(Vector3i(1, 0, 0))
	assert_vector(_map(0, Vector2i(-1, 0))).is_equal(Vector3i(-1, 0, 0))
	assert_vector(_map(0, Vector2i(0, -1))).is_equal(Vector3i(0, 0, -1))
	assert_vector(_map(0, Vector2i(0, 1))).is_equal(Vector3i(0, 0, 1))


func test_mapping_is_one_to_one() -> void:
	for k in range(12):
		var seen: Array[Vector3i] = []
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var w: Vector3i = _map(k, d)
			assert_bool(w == Vector3i.ZERO).is_false()
			assert_bool(seen.has(w)).is_false()
			seen.append(w)


func test_bad_screen_dir_is_zero() -> void:
	for d: Vector2i in [Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 0)]:
		assert_vector(_map(0, d)).is_equal(Vector3i.ZERO)


func test_view_axes() -> void:
	var a: Dictionary = CameraMath.view_axes(1, B, S)
	assert_vector(a["tilt"]).is_equal(Vector3i(1, 0, 0))
	assert_vector(a["roll"]).is_equal(Vector3i(0, 0, -1))
	a = CameraMath.view_axes(3, B, S)
	assert_vector(a["tilt"]).is_equal(Vector3i(0, 0, -1))
	assert_vector(a["roll"]).is_equal(Vector3i(-1, 0, 0))
