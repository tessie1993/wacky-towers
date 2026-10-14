class_name WtGesturePad extends Control
## Touch/mouse gestures over the board: drag to move a cell at a time, tap to turn,
## quick downward flick to drop. Two fingers orbit/tilt (drag) and zoom (pinch) the camera;
## right/middle mouse drag orbits and the wheel zooms. Emits intents only; never touches game state.

signal gesture(id: StringName, args: Dictionary)

## Drag distance (px, scaled by the control factor) that moves the piece one cell.
@export var step_px: float = 46.0
## Downward speed (px/s) that counts as a drop flick.
@export var flick_speed: float = 1700.0
## Maximum travel (px) and time (ms) for a tap.
@export var tap_px: float = 14.0
@export var tap_ms: int = 260

var _down: bool = false
var _start: Vector2
var _carry: Vector2
var _start_ms: int = 0
var _moved: bool = false
## Active touch points by index, for the two-finger camera gesture.
var _touches: Dictionary = {}
var _camera_gesture: bool = false
var _mouse_orbit: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if _camera_input(event):
		accept_event()
		return
	var pressed: Variant = null
	var position: Vector2
	if event is InputEventScreenTouch:
		if event.index != 0: return
		pressed = event.pressed
		position = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = event.pressed
		position = event.position
	if pressed != null:
		if pressed:
			_down = true
			_start = position
			_carry = Vector2.ZERO
			_start_ms = Time.get_ticks_msec()
			_moved = false
		elif _down:
			_down = false
			var elapsed: int = maxi(1, Time.get_ticks_msec() - _start_ms)
			var travel: Vector2 = position - _start
			if not _moved and travel.length() < tap_px and elapsed < tap_ms:
				gesture.emit(&"rotate", {"axis": &"spin", "direction": 1})
			elif travel.y > 0 and travel.y / (elapsed / 1000.0) > flick_speed and absf(travel.y) > absf(travel.x) * 1.5:
				gesture.emit(&"drop", {})
		accept_event()
		return
	var relative := Vector2.ZERO
	if event is InputEventScreenDrag and event.index == 0:
		relative = event.relative
	elif event is InputEventMouseMotion and _down:
		relative = event.relative
	if relative == Vector2.ZERO or not _down:
		return
	_carry += relative
	while absf(_carry.x) >= step_px or absf(_carry.y) >= step_px:
		var horizontal: bool = absf(_carry.x) >= absf(_carry.y)
		var step := Vector2i(int(signf(_carry.x)), 0) if horizontal else Vector2i(0, int(signf(_carry.y)))
		gesture.emit(&"move", {"screen": step})
		_moved = true
		if horizontal: _carry.x -= signf(_carry.x) * step_px
		else: _carry.y -= signf(_carry.y) * step_px
	accept_event()


## Camera gestures: two-finger drag orbits/tilts, pinch zooms, right/middle mouse drag orbits,
## wheel zooms. Returns true when the event was a camera gesture (the piece gesture is cancelled).
func _camera_input(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		if event.pressed: _touches[event.index] = event.position
		else: _touches.erase(event.index)
		if _touches.size() >= 2:
			_camera_gesture = true
			_down = false
			return true
		if _camera_gesture:
			if _touches.is_empty():
				_camera_gesture = false
				gesture.emit(&"camera_release", {})
			return true
		return false
	if event is InputEventScreenDrag and _camera_gesture:
		if _touches.size() < 2 or not _touches.has(event.index): return true
		var keys: Array = _touches.keys()
		var other: Vector2 = _touches[keys[1] if keys[0] == event.index else keys[0]]
		var before: float = (_touches[event.index] as Vector2).distance_to(other)
		_touches[event.index] = event.position
		var after: float = event.position.distance_to(other)
		# Each finger reports its own drag: half the motion moves the centroid.
		gesture.emit(&"camera_orbit", {"relative": event.relative * 0.5, "source": &"touch"})
		if before > 8.0 and after > 8.0:
			gesture.emit(&"camera_zoom", {"pinch": after / before})
		return true
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			_mouse_orbit = event.pressed
			if not event.pressed: gesture.emit(&"camera_release", {})
			return true
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			gesture.emit(&"camera_zoom", {"wheel": 1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1})
			return true
	if event is InputEventMouseMotion and _mouse_orbit:
		gesture.emit(&"camera_orbit", {"relative": event.relative, "source": &"mouse"})
		return true
	if event is InputEventMagnifyGesture:
		gesture.emit(&"camera_zoom", {"pinch": event.factor})
		return true
	return false
