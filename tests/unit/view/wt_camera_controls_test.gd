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


# --- Camera turn (WtCameraTurn): data-driven overshoot, parallax, reduced motion ---

func test_turn_values_come_from_camera_controls_json() -> void:
	var turn := WtCameraTurn.new()
	var block: Dictionary = WtCameraControls.load_data().get("turn", {})
	assert_bool(block.is_empty()).is_false()
	for key: String in ["duration_ms", "overshoot", "parallax_ratio"]:
		assert_float(turn.value(key)).is_equal(float(block[key]))


func test_turn_injected_config_overrides_data() -> void:
	var turn := WtCameraTurn.new({"duration_ms": 400.0, "overshoot": 1.2})
	assert_float(turn.duration_s()).is_equal_approx(0.4, 0.0001)
	assert_float(turn.value("overshoot")).is_equal(1.2)


func test_turn_overshoots_slightly_then_settles_on_target() -> void:
	var turn := WtCameraTurn.new({"duration_ms": 200.0, "overshoot": 0.8})
	turn.begin(0.0, 30.0)
	var peak: float = 0.0
	for i: int in 100:
		peak = maxf(peak, turn.step(0.002))
	assert_float(peak).is_greater(30.0)
	assert_float(peak).is_less(30.0 * 1.05)
	assert_float(turn.step(1.0)).is_equal_approx(30.0, 0.001)
	assert_bool(turn.is_active()).is_false()


func test_turn_takes_shortest_way_round() -> void:
	var turn := WtCameraTurn.new()
	assert_float(turn.begin(350.0, 10.0)).is_equal_approx(370.0, 0.001)


func test_reduced_motion_turn_is_instant_by_default_and_never_overshoots() -> void:
	var turn := WtCameraTurn.new()
	turn.set_reduced(true)
	turn.begin(0.0, 30.0)
	assert_bool(turn.is_active()).is_false()
	assert_float(turn.step(0.016)).is_equal_approx(30.0, 0.001)


func test_reduced_motion_short_turn_is_linear_without_overshoot() -> void:
	var turn := WtCameraTurn.new({"reduced_duration_ms": 100.0})
	turn.set_reduced(true)
	turn.begin(0.0, 30.0)
	assert_float(turn.step(0.05)).is_equal_approx(15.0, 0.001)
	assert_float(turn.step(0.2)).is_equal_approx(30.0, 0.001)


func test_parallax_backdrop_trails_then_returns_to_rest() -> void:
	var turn := WtCameraTurn.new({"parallax_ratio": 0.5, "parallax_settle_per_s": 5.0})
	turn.update_drift(0.0, 0.016)
	var d: float = turn.update_drift(10.0, 0.0)
	assert_float(d).is_equal_approx(5.0, 0.001)
	for i: int in 200:
		turn.update_drift(10.0, 0.016)
	assert_float(turn.drift()).is_equal(0.0)


func test_reduced_motion_has_no_parallax() -> void:
	var turn := WtCameraTurn.new({"parallax_ratio": 0.5})
	turn.set_reduced(true)
	turn.update_drift(0.0, 0.016)
	assert_float(turn.update_drift(30.0, 0.016)).is_equal(0.0)
	assert_float(turn.sky_shift()).is_equal(0.0)


func test_overshoot_fraction_matches_curve_peak() -> void:
	var s: float = 0.8
	var peak: float = 0.0
	for i: int in 1001:
		peak = maxf(peak, WtCameraTurn.ease_out_back(float(i) / 1000.0, s) - 1.0)
	assert_float(WtCameraTurn.overshoot_fraction(s)).is_equal_approx(peak, 0.001)
