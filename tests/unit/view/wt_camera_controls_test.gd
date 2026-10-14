extends GdUnitTestSuite
## Camera controls: input-to-delta math (mouse, touch, wheel, pinch) and the gesture pad's
## two-finger and mouse camera intents (user request 2026-10-14).


func test_drag_orbits_opposite_to_horizontal_motion_and_tilts_with_vertical() -> void:
	var c := WtCameraControls.new()
	var d: Vector2 = c.drag_delta(Vector2(10, 10), &"mouse")
	assert_float(d.x).is_less(0.0)
	assert_float(d.y).is_greater(0.0)


func test_wheel_and_pinch_zoom_directions() -> void:
	var c := WtCameraControls.new()
	assert_float(c.wheel_factor(1)).is_less(1.0)
	assert_float(c.wheel_factor(-1)).is_greater(1.0)
	assert_float(c.pinch_factor(1.5)).is_less(1.0)
	assert_float(c.pinch_factor(0.5)).is_greater(1.0)
	assert_float(c.pinch_factor(0.0)).is_equal(1.0)


func test_limits_clamp_elevation_and_zoom() -> void:
	var c := WtCameraControls.new()
	var limits: Dictionary = WtCameraControls.load_data().get("limits", {})
	assert_float(c.clamp_elevation(-90.0)).is_equal(float(limits.get("elevation_min", 22.0)))
	assert_float(c.clamp_zoom(100.0)).is_equal(float(limits.get("zoom_max", 1.6)))


func test_two_fingers_emit_camera_intents_not_piece_moves() -> void:
	var pad: WtGesturePad = auto_free(WtGesturePad.new())
	var seen: Array[StringName] = []
	pad.gesture.connect(func(id: StringName, _args: Dictionary) -> void: seen.append(id))
	pad._gui_input(_touch(0, Vector2(100, 100), true))
	pad._gui_input(_touch(1, Vector2(200, 100), true))
	var drag := InputEventScreenDrag.new()
	drag.index = 1
	drag.position = Vector2(260, 100)
	drag.relative = Vector2(60, 0)
	pad._gui_input(drag)
	pad._gui_input(_touch(1, Vector2(260, 100), false))
	pad._gui_input(_touch(0, Vector2(100, 100), false))
	assert_array(seen).contains([&"camera_orbit", &"camera_zoom", &"camera_release"])
	assert_array(seen).not_contains([&"move", &"rotate", &"drop"])


func test_right_mouse_drag_and_wheel_emit_camera_intents() -> void:
	var pad: WtGesturePad = auto_free(WtGesturePad.new())
	var seen: Array[StringName] = []
	pad.gesture.connect(func(id: StringName, _args: Dictionary) -> void: seen.append(id))
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_RIGHT
	press.pressed = true
	pad._gui_input(press)
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(12, 0)
	pad._gui_input(motion)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_RIGHT
	release.pressed = false
	pad._gui_input(release)
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	pad._gui_input(wheel)
	assert_array(seen).is_equal([&"camera_orbit", &"camera_release", &"camera_zoom"])


func _touch(index: int, position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.index = index
	e.position = position
	e.pressed = pressed
	return e
