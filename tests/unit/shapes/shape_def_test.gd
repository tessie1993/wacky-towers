extends GdUnitTestSuite
## Tests for ShapeDef fields and per-orientation accessors (CH-020).


func test_new_def_has_empty_defaults() -> void:
	var d: ShapeDef = ShapeDef.new()
	assert_int(d.cube_count).is_equal(0)
	assert_int(d.offsets_by_orient.size()).is_equal(0)
	assert_int(d.spawn_orient).is_equal(0)
	assert_bool(d.shape_id == &"").is_true()


func test_accessors_return_stored_values() -> void:
	var d: ShapeDef = ShapeDef.new()
	d.offsets_by_orient = [typed([Vector3i(0, 0, 0), Vector3i(1, 0, 0)])]
	d.bbox_by_orient = typed([Vector3i(2, 1, 1)])
	d.min_by_orient = typed([Vector3i(0, 0, 0)])
	assert_int(d.offsets(0).size()).is_equal(2)
	assert_bool(d.offsets(0)[1] == Vector3i(1, 0, 0)).is_true()
	assert_bool(d.bbox(0) == Vector3i(2, 1, 1)).is_true()
	assert_bool(d.min_corner(0) == Vector3i.ZERO).is_true()


func test_accessors_out_of_range() -> void:
	var d: ShapeDef = ShapeDef.new()
	d.offsets_by_orient = [typed([Vector3i(0, 0, 0)])]
	d.bbox_by_orient = typed([Vector3i(1, 1, 1)])
	d.min_by_orient = typed([Vector3i(0, 0, 0)])
	for o: int in [-1, 1]:
		assert_int(d.offsets(o).size()).is_equal(0)
	assert_bool(d.bbox(5) == Vector3i.ZERO).is_true()
	assert_bool(d.min_corner(-1) == Vector3i.ZERO).is_true()


func typed(a: Array) -> Array[Vector3i]:
	var r: Array[Vector3i] = []
	r.assign(a)
	return r


# --- ShapeDef.build (CH-027) ---

func _i4() -> Array[Vector3i]:
	return typed([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(3, 0, 0)])


func _i4_up() -> Array[Vector3i]:
	return typed([Vector3i(0, 0, 0), Vector3i(0, 1, 0), Vector3i(0, 2, 0), Vector3i(0, 3, 0)])


func _t4() -> Array[Vector3i]:
	return typed([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1)])


func test_distinct_counts_match_gdd_f4() -> void:
	var big: Array[Vector3i] = []
	for x: int in 2:
		for y: int in 2:
			for z: int in 2:
				big.append(Vector3i(x, y, z))
	var cases: Array = [
		[_i4(), 3],
		[typed([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(1, 0, 1)]), 3],
		[_t4(), 12],
		[typed([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 1, 0), Vector3i(0, 0, 1)]), 8],
		[big, 1],
		[typed([Vector3i(0, 0, 0)]), 1],
		[typed([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(1, 1, 0), Vector3i(1, 1, 1)]), 12],
	]
	for c: Array in cases:
		var offs: Array[Vector3i] = c[0]
		assert_int(ShapeDef.build(&"s", offs).distinct_count).is_equal(c[1])


func test_i4_tables() -> void:
	var d: ShapeDef = ShapeDef.build(&"i", _i4())
	assert_int(d.cube_count).is_equal(4)
	assert_int(d.offsets_by_orient.size()).is_equal(24)
	assert_array(d.offsets(0)).is_equal(_i4())
	assert_bool(d.bbox(0) == Vector3i(4, 1, 1)).is_true()
	assert_int(d.spawn_orient).is_equal(0)


func test_vertical_i_spawns_lying_down() -> void:
	var d: ShapeDef = ShapeDef.build(&"i", _i4_up())
	assert_bool(d.bbox(0) == Vector3i(1, 4, 1)).is_true()
	assert_int(d.spawn_orient).is_equal(1)
	assert_bool(d.bbox(1) == Vector3i(1, 1, 4)).is_true()


func test_pivot_kept_in_every_orientation() -> void:
	var d: ShapeDef = ShapeDef.build(&"t", _t4())
	for o: int in 24:
		assert_bool(d.offsets(o).has(Vector3i.ZERO)).is_true()


func test_min_corner_matches_offsets() -> void:
	var d: ShapeDef = ShapeDef.build(&"t", _t4())
	for o: int in 24:
		var lo: Vector3i = d.offsets(o)[0]
		for v: Vector3i in d.offsets(o):
			lo = Vector3i(mini(lo.x, v.x), mini(lo.y, v.y), mini(lo.z, v.z))
		assert_bool(d.min_corner(o) == lo).is_true()


func test_distinct_of_is_consistent() -> void:
	var d: ShapeDef = ShapeDef.build(&"t", _t4())
	assert_int(d.distinct_of[0]).is_equal(0)
	assert_int(d.distinct_of.size()).is_equal(24)
	var mx: int = 0
	for o: int in 24:
		mx = maxi(mx, d.distinct_of[o])
	assert_int(mx).is_equal(d.distinct_count - 1)
	for a: int in 24:
		for b: int in 24:
			var same: bool = _shifted_key(d.offsets(a)) == _shifted_key(d.offsets(b))
			assert_bool((d.distinct_of[a] == d.distinct_of[b]) == same).is_true()


func _shifted_key(offs: Array[Vector3i]) -> String:
	var lo: Vector3i = offs[0]
	for v: Vector3i in offs:
		lo = Vector3i(mini(lo.x, v.x), mini(lo.y, v.y), mini(lo.z, v.z))
	var parts: PackedStringArray = PackedStringArray()
	for v: Vector3i in offs:
		parts.append(str(v - lo))
	parts.sort()
	return ";".join(parts)
