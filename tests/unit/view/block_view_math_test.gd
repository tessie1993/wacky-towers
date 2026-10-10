extends GdUnitTestSuite


func test_outline_width() -> void:
	assert_float(BlockViewMath.outline_world_width(2.5, 16.87, 1920.0)).is_equal_approx(0.02197, 1e-5)
	assert_float(BlockViewMath.outline_world_width(2.5, 16.87, 0.0)).is_equal(0.0)


func test_custom_clamps() -> void:
	assert_float(BlockViewMath.instance_custom(0, 0, 5000, 1.0).b).is_equal(2048.0)
	assert_float(BlockViewMath.instance_custom(0, 0, 0, -1.0).a).is_equal(0.0)
	assert_float(BlockViewMath.instance_custom(0, 0, 0, 2.0).a).is_equal(1.0)


func test_custom_default() -> void:
	assert_that(BlockViewMath.instance_custom(0, 0, 0, 1.0)).is_equal(Color(0, 0, 0, 1))


func test_ripple_ranks() -> void:
	var input: PackedInt32Array = PackedInt32Array([5, 2, 3])
	var expected: PackedInt32Array = PackedInt32Array([2, 3, 5])
	assert_array(Array(BlockViewMath.ripple_ranks(input))).is_equal(Array(expected))
