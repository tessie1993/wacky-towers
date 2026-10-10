extends GdUnitTestSuite
## ShapeDef.canonical_key: rotation/translation invariant, mirror-sensitive (CH-026).

const I4: Array[Vector3i] = [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(3, 0, 0)]
const O4: Array[Vector3i] = [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(1, 0, 1)]
const T4: Array[Vector3i] = [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(1, 0, 1)]
const TRIPOD: Array[Vector3i] = [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 1, 0), Vector3i(0, 0, 1)]
const SCREW_L: Array[Vector3i] = [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(1, 1, 0), Vector3i(1, 1, 1)]
const SCREW_R: Array[Vector3i] = [Vector3i(0, 0, 0), Vector3i(-1, 0, 0), Vector3i(-1, 1, 0), Vector3i(-1, 1, 1)]
const L4: Array[Vector3i] = [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(2, 1, 0)]
const J4: Array[Vector3i] = [Vector3i(0, 0, 0), Vector3i(-1, 0, 0), Vector3i(-2, 0, 0), Vector3i(-2, 1, 0)]


func _fixtures() -> Array:
	return [I4, O4, T4, TRIPOD, SCREW_L]


func test_i4_key_golden() -> void:
	assert_str(ShapeDef.canonical_key(I4)).is_equal("0,0,0;0,0,1;0,0,2;0,0,3;")


func test_key_invariant_under_all_rotations() -> void:
	for f: Array[Vector3i] in _fixtures():
		var key: String = ShapeDef.canonical_key(f)
		for o: int in range(Orientations.COUNT):
			var rotated: Array[Vector3i] = []
			for v: Vector3i in f:
				rotated.append(Orientations.apply(o, v))
			assert_str(ShapeDef.canonical_key(rotated)).is_equal(key)


func test_key_invariant_under_translation() -> void:
	var shift := Vector3i(5, -3, 2)
	for f: Array[Vector3i] in _fixtures():
		var moved: Array[Vector3i] = []
		for v: Vector3i in f:
			moved.append(v + shift)
		assert_str(ShapeDef.canonical_key(moved)).is_equal(ShapeDef.canonical_key(f))


func test_screw_mirrors_differ() -> void:
	assert_str(ShapeDef.canonical_key(SCREW_L)).is_not_equal(ShapeDef.canonical_key(SCREW_R))


func test_flat_mirrors_equal_in_3d() -> void:
	assert_str(ShapeDef.canonical_key(L4)).is_equal(ShapeDef.canonical_key(J4))


func test_different_shapes_differ() -> void:
	var fs: Array = _fixtures()
	for i: int in range(fs.size()):
		for j: int in range(i + 1, fs.size()):
			assert_str(ShapeDef.canonical_key(fs[i])).is_not_equal(ShapeDef.canonical_key(fs[j]))


func test_empty_is_empty_string() -> void:
	var empty: Array[Vector3i] = []
	assert_str(ShapeDef.canonical_key(empty)).is_equal("")
