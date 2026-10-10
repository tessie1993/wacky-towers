extends GdUnitTestSuite

const SCENE: PackedScene = preload("res://src/levels/_kit/platform/meadow_platform.tscn")


func _platform() -> LevelPlatform:
	var p: LevelPlatform = auto_free(SCENE.instantiate())
	add_child(p)
	return p

func test_default_top_spans_board_plus_margin() -> void:
	var a: AABB = _platform().get_top_aabb()
	assert_float(a.position.x).is_equal_approx(-3.0, 0.001)
	assert_float(a.end.x).is_equal_approx(3.0, 0.001)
	assert_float(a.position.z).is_equal_approx(-3.0, 0.001)
	assert_float(a.end.z).is_equal_approx(3.0, 0.001)

func test_top_surface_is_y_zero() -> void:
	assert_float(_platform().get_top_aabb().end.y).is_equal_approx(0.0, 0.0001)

func test_board_size_change_rebuilds() -> void:
	var p := _platform()
	p.board_size = Vector2i(6, 4)
	var a: AABB = p.get_top_aabb()
	assert_float(a.size.x).is_equal_approx(8.0, 0.001)
	assert_float(a.size.z).is_equal_approx(6.0, 0.001)
	assert_float(a.end.y).is_equal_approx(0.0, 0.0001)

func test_margin_change_rebuilds() -> void:
	var p := _platform()
	p.margin_cells = 2
	assert_float(p.get_top_aabb().size.x).is_equal_approx(8.0, 0.001)
