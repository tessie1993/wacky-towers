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
