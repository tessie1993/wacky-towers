extends GdUnitTestSuite
## Tests for ShapeDef.canonical_key (CH-026).

const SHIFT: Vector3i = Vector3i(5, -3, 2)


func _p(a: Array) -> Array[Vector3i]:
	var r: Array[Vector3i] = []
	for v: Vector3i in a:
		r.append(v)
	return r


func _fixtures() -> Dictionary:
	return {
		"I4": _p([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(3, 0, 0)]),
		"O4": _p([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(1, 0, 1)]),
		"T4": _p([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(1, 0, 1)]),
		"TRIPOD": _p([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 1, 0), Vector3i(0, 0, 1)]),
		"SCREW_L": _p([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(1, 1, 0), Vector3i(1, 1, 1)]),
	}


func _screw_r() -> Array[Vector3i]:
	return _p([Vector3i(0, 0, 0), Vector3i(-1, 0, 0), Vector3i(-1, 1, 0), Vector3i(-1, 1, 1)])


func test_i4_key_golden() -> void:
	assert_str(ShapeDef.canonical_key(_fixtures()["I4"])).is_equal("0,0,0;0,0,1;0,0,2;0,0,3;")


func test_key_invariant_under_all_rotations() -> void:
	var f: Dictionary = _fixtures()
	for name: String in f:
		var src: Array[Vector3i] = f[name]
		var key: String = ShapeDef.canonical_key(src)
		for o: int in range(Orientations.COUNT):
			var rot: Array[Vector3i] = []
			for v: Vector3i in src:
				rot.append(Orientations.apply(o, v))
			assert_str(ShapeDef.canonical_key(rot)).is_equal(key)


func test_key_invariant_under_translation() -> void:
	var f: Dictionary = _fixtures()
	for name: String in f:
		var src: Array[Vector3i] = f[name]
		var moved: Array[Vector3i] = []
		for v: Vector3i in src:
			moved.append(v + SHIFT)
		assert_str(ShapeDef.canonical_key(moved)).is_equal(ShapeDef.canonical_key(src))


func test_screw_mirrors_differ() -> void:
	var f: Dictionary = _fixtures()
	assert_str(ShapeDef.canonical_key(f["SCREW_L"])).is_not_equal(ShapeDef.canonical_key(_screw_r()))


func test_flat_mirrors_equal_in_3d() -> void:
	var l4: Array[Vector3i] = _p([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(2, 1, 0)])
	var j4: Array[Vector3i] = _p([Vector3i(0, 0, 0), Vector3i(-1, 0, 0), Vector3i(-2, 0, 0), Vector3i(-2, 1, 0)])
	assert_str(ShapeDef.canonical_key(l4)).is_equal(ShapeDef.canonical_key(j4))


func test_different_shapes_differ() -> void:
	var f: Dictionary = _fixtures()
	var keys: Array = f.keys()
	for i: int in range(keys.size()):
		for j: int in range(i + 1, keys.size()):
			assert_str(ShapeDef.canonical_key(f[keys[i]])).is_not_equal(ShapeDef.canonical_key(f[keys[j]]))


func test_empty_is_empty_string() -> void:
	assert_str(ShapeDef.canonical_key(([] as Array[Vector3i]))).is_equal("")
