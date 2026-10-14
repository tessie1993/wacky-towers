class_name WtCameraControls extends RefCounted
## Turns mouse, touch and gamepad input into play-camera deltas (orbit, tilt, zoom).
## Pure translation: it never moves a camera itself. WtStage applies the deltas, so the
## same stage API serves the gesture pad (touch, mouse), its own unhandled input, and the
## gamepad right stick. Tuning lives in res://assets/data/camera_controls.json.

const DATA_PATH := "res://assets/data/camera_controls.json"

static var _cache: Dictionary = {}

var _mouse: Dictionary = {}
var _touch: Dictionary = {}
var _pad: Dictionary = {}
var _limits: Dictionary = {}
var _pad_active: bool = false


func _init() -> void:
	var data: Dictionary = load_data()
	_mouse = data.get("mouse", {})
	_touch = data.get("touch", {})
	_pad = data.get("pad", {})
	_limits = data.get("limits", {})


## Parsed camera_controls.json (cached); {} when the file is missing or invalid.
static func load_data() -> Dictionary:
	if _cache.is_empty() and FileAccess.file_exists(DATA_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
		if parsed is Dictionary: _cache = parsed
	return _cache


## Orbit/tilt degrees for a pointer drag of `relative` pixels. `source` is &"mouse" or &"touch".
func drag_delta(relative: Vector2, source: StringName) -> Vector2:
	var table: Dictionary = _touch if source == &"touch" else _mouse
	var orbit: float = float(table.get("orbit_deg_per_px", 0.35))
	var tilt: float = float(table.get("tilt_deg_per_px", 0.12))
	return Vector2(-relative.x * orbit, relative.y * tilt)


## Zoom factor for one mouse-wheel notch: `notch` is +1 (zoom in) or -1 (zoom out).
func wheel_factor(notch: int) -> float:
	var step: float = float(_mouse.get("wheel_zoom_step", 0.08))
	return 1.0 - step if notch > 0 else 1.0 + step


## Zoom factor from a pinch: `ratio` is new finger distance / old distance (>1 = spread = zoom in).
func pinch_factor(ratio: float) -> float:
	if ratio <= 0.0: return 1.0
	var gain: float = float(_touch.get("pinch_gain", 1.0))
	return pow(1.0 / ratio, gain)


## Right-stick orbit/tilt degrees this frame across all connected pads (Vector2.ZERO in the deadzone).
func pad_delta(delta: float) -> Vector2:
	var dead: float = float(_pad.get("deadzone", 0.25))
	var stick := Vector2.ZERO
	for device: int in Input.get_connected_joypads():
		var s := Vector2(Input.get_joy_axis(device, JOY_AXIS_RIGHT_X), Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y))
		if s.length() > stick.length(): stick = s
	if stick.length() < dead:
		return Vector2.ZERO
	return Vector2(-stick.x * float(_pad.get("orbit_deg_per_s", 140.0)), stick.y * float(_pad.get("tilt_deg_per_s", 45.0))) * delta


## True on the frame the stick returns to rest after being used (the stage then settles the view).
func pad_released(delta_now: Vector2) -> bool:
	var was: bool = _pad_active
	_pad_active = delta_now != Vector2.ZERO
	return was and not _pad_active


## Clamps a camera elevation (degrees) to the data limits.
func clamp_elevation(elevation: float) -> float:
	return clampf(elevation, float(_limits.get("elevation_min", 22.0)), float(_limits.get("elevation_max", 55.0)))


## Clamps the player zoom multiplier (1 = framed default; <1 = closer).
func clamp_zoom(zoom: float) -> float:
	return clampf(zoom, float(_limits.get("zoom_min", 0.65)), float(_limits.get("zoom_max", 1.6)))
