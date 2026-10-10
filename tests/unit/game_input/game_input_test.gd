extends GdUnitTestSuite

var _input: GameInput
var _got: Array = []


func before_test() -> void:
	_got = []
	_input = auto_free(GameInput.new())
	_input.rotate_piece.connect(func(axis: StringName, dir: int) -> void: _got.append([axis, dir]))


func test_default_axes_both_emit() -> void:
	_input.try_rotate(&"horizontal", 1)
	_input.try_rotate(&"vertical", -1)
	assert_array(_got).is_equal([[&"horizontal", 1], [&"vertical", -1]])


func test_disallowed_axis_emits_nothing() -> void:
	_input.enabled_axes = [&"horizontal"]
	_input.try_rotate(&"vertical", 1)
	_input.try_rotate(&"horizontal", -1)
	assert_array(_got).is_equal([[&"horizontal", -1]])


func test_empty_axes_emit_nothing() -> void:
	_input.enabled_axes = []
	_input.try_rotate(&"horizontal", 1)
	_input.try_rotate(&"vertical", 1)
	assert_array(_got).is_empty()


func test_disabled_emits_nothing() -> void:
	_input.disable()
	_input.try_rotate(&"horizontal", 1)
	assert_array(_got).is_empty()


func test_snap_dir_dominant_axis() -> void:
	assert_that(GameInput.snap_dir(Vector2(0.9, 0.2))).is_equal(Vector2i(1, 0))
	assert_that(GameInput.snap_dir(Vector2(-0.1, -0.8))).is_equal(Vector2i(0, -1))
	assert_that(GameInput.snap_dir(Vector2(1, 1))).is_equal(Vector2i(1, 0))
	assert_that(GameInput.snap_dir(Vector2(0.3, 0.2))).is_equal(Vector2i.ZERO)
