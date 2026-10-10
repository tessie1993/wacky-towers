extends GdUnitTestSuite

const DELAY: float = 0.17
const INTERVAL: float = 0.05
const RIGHT: Vector2i = Vector2i(1, 0)
const DOWN: Vector2i = Vector2i(0, 1)


func _timer() -> RepeatTimer:
	return RepeatTimer.new(DELAY, INTERVAL)


func test_press_fires_once_immediately() -> void:
	assert_int(_timer().update(RIGHT, 0.016)).is_equal(1)


func test_no_input_never_fires() -> void:
	var t := _timer()
	for i in 20:
		assert_int(t.update(Vector2i.ZERO, 0.05)).is_equal(0)


func test_no_repeat_before_delay() -> void:
	var t := _timer()
	t.update(RIGHT, 0.0)
	assert_int(t.update(RIGHT, DELAY - 0.01)).is_equal(0)


func test_repeat_at_delay_then_every_interval() -> void:
	var t := _timer()
	t.update(RIGHT, 0.0)
	assert_int(t.update(RIGHT, DELAY)).is_equal(1)
	assert_int(t.update(RIGHT, INTERVAL - 0.01)).is_equal(0)
	assert_int(t.update(RIGHT, 0.01)).is_equal(1)


func test_long_frame_fires_multiple() -> void:
	var t := _timer()
	t.update(RIGHT, 0.0)
	# delay + 2 full intervals in one frame -> 3 repeats
	assert_int(t.update(RIGHT, DELAY + 2.0 * INTERVAL)).is_equal(3)


func test_release_resets() -> void:
	var t := _timer()
	t.update(RIGHT, 0.0)
	t.update(RIGHT, DELAY)
	assert_int(t.update(Vector2i.ZERO, 0.016)).is_equal(0)
	assert_int(t.update(RIGHT, 0.016)).is_equal(1)
	assert_int(t.update(RIGHT, DELAY - 0.05)).is_equal(0)


func test_direction_change_is_new_press() -> void:
	var t := _timer()
	t.update(RIGHT, 0.0)
	t.update(RIGHT, DELAY + INTERVAL)
	assert_int(t.update(DOWN, 0.016)).is_equal(1)
	assert_int(t.update(DOWN, DELAY - 0.05)).is_equal(0)
