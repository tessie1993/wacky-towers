extends GdUnitTestSuite
## Tests for Gestures (CH-042). Rotation uses two axis pairs: horizontal / vertical.

const TAP_MS: int = 150
const FLICK_MS: int = 200
const FLICK_MIN: float = 40.0
const DEAD: float = 10.0
const CONE: float = 30.0


func _c(ms: int, travel: Vector2) -> Dictionary:
	return Gestures.classify(ms, travel, TAP_MS, FLICK_MS, FLICK_MIN, DEAD, CONE)


func test_tap_and_hold() -> void:
	assert_int(_c(100, Vector2(3, 2)).kind).is_equal(Gestures.Kind.TAP)
	assert_int(_c(300, Vector2(3, 2)).kind).is_equal(Gestures.Kind.HOLD)


func test_flick_dirs() -> void:
	var r: Dictionary = _c(120, Vector2(80, 5))
	assert_int(r.kind).is_equal(Gestures.Kind.FLICK)
	assert_vector(r.dir).is_equal(Vector2i(1, 0))
	var u: Dictionary = _c(120, Vector2(-2, -90))
	assert_int(u.kind).is_equal(Gestures.Kind.FLICK)
	assert_vector(u.dir).is_equal(Vector2i(0, -1))


func test_flick_rotation_axis_pairs() -> void:
	var r: Dictionary = _c(120, Vector2(80, 5))
	assert_that(r.axis).is_equal(&"horizontal")
	assert_int(r.rot).is_equal(1)
	var l: Dictionary = _c(120, Vector2(-80, 5))
	assert_that(l.axis).is_equal(&"horizontal")
	assert_int(l.rot).is_equal(-1)
	var u: Dictionary = _c(120, Vector2(-2, -90))
	assert_that(u.axis).is_equal(&"vertical")
	assert_int(u.rot).is_equal(1)
	var d: Dictionary = _c(120, Vector2(2, 90))
	assert_that(d.axis).is_equal(&"vertical")
	assert_int(d.rot).is_equal(-1)
	assert_that(_c(100, Vector2(1, 1)).axis).is_equal(&"")


func test_diagonal_flick_ignored() -> void:
	assert_int(_c(120, Vector2(60, 60)).kind).is_equal(Gestures.Kind.NONE)


func test_slow_long_is_drag() -> void:
	assert_int(_c(400, Vector2(90, 0)).kind).is_equal(Gestures.Kind.DRAG)


func test_drag_cells() -> void:
	assert_int(Gestures.drag_cells(130.0, 48.0)).is_equal(2)
	assert_int(Gestures.drag_cells(-50.0, 48.0)).is_equal(-1)
	assert_int(Gestures.drag_cells(10.0, 0.0)).is_equal(0)


func test_is_hold() -> void:
	assert_bool(Gestures.is_hold(149, 150)).is_false()
	assert_bool(Gestures.is_hold(150, 150)).is_true()
