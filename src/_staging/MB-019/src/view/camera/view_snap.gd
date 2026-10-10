class_name ViewSnap extends RefCounted
## Logical camera snap, pure (ADR-0014 §2). The sim never sees it; input reads it.
## Free drag never changes `k`; only settle(), step() and snap_to_corner() do.

const CORNER_SNAPS: Array[int] = [0, 3, 6, 9]  ## Camera GDD F1: corner views at k = 0, 3, 6, 9
const ALL_MASK: int = (1 << CameraMath.STEPS) - 1
const _SCREEN_DIRS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

var k: int = 0  ## settled snap 0..11

var _base_deg: int
var _step_deg: int
var _allowed: int = ALL_MASK


## Knobs view.yaw_offset_deg; step is 30 (12 snaps).
func _init(yaw_offset_deg: int = CameraMath.DEFAULT_BASE_DEG, step_deg: int = CameraMath.DEFAULT_STEP_DEG) -> void:
	_base_deg = yaw_offset_deg
	_step_deg = step_deg


## 12-bit mask of allowed snaps (bit i = snap i). 0 is treated as all allowed. Usage: set_allowed(0b111111110000)
func set_allowed(mask: int) -> void:
	_allowed = mask & ALL_MASK
	if _allowed == 0:
		_allowed = ALL_MASK


## Moves to the next allowed snap in dir (+1/-1, wraps). False if there is none other than k.
func step(dir: int) -> bool:
	var s: int = 1 if dir >= 0 else -1
	for i in range(1, CameraMath.STEPS):
		var cand: int = posmod(k + s * i, CameraMath.STEPS)
		if _is_allowed(cand):
			k = cand
			return true
	return false


## Corner shortcut: c 0..3 -> k = 0, 3, 6, 9, or the nearest allowed snap. False if c is out of range.
func snap_to_corner(c: int) -> bool:
	if c < 0 or c >= CORNER_SNAPS.size():
		return false
	k = nearest_allowed(CameraMath.yaw_degrees(CORNER_SNAPS[c], _base_deg, _step_deg))
	return true


## Nearest allowed snap to a free-orbit yaw in degrees; ties go to the lower k.
func nearest_allowed(yaw_deg_in: float) -> int:
	var best: int = k
	var best_d: float = INF
	for i in range(CameraMath.STEPS):
		if not _is_allowed(i):
			continue
		var d: float = absf(angle_difference(deg_to_rad(yaw_deg_in), deg_to_rad(CameraMath.yaw_degrees(i, _base_deg, _step_deg))))
		if d < best_d - 1e-6:
			best_d = d
			best = i
	return best


## Drag release: k = nearest allowed snap to the free yaw.
func settle(yaw_deg_in: float) -> void:
	k = nearest_allowed(yaw_deg_in)


## Yaw in degrees of the settled snap.
func yaw_deg() -> float:
	return CameraMath.yaw_degrees(k, _base_deg, _step_deg)


## {Vector2i screen_dir: Vector3i world_dir} for the 4 screen directions at the settled snap.
func direction_map() -> Dictionary:
	var m: Dictionary = {}
	for sd in _SCREEN_DIRS:
		m[sd] = CameraMath.screen_dir_to_world(k, sd, _base_deg, _step_deg)
	return m


## InputAxes gesture -> (Orientations.Axis int, sign) for the sim's rotate command (right-hand rule, ADR-0003).
## spin = world Y; tilt = horizontal axis that appears screen-horizontal; roll = the other. dir +1 = spin right / tilt away / roll right.
## Unknown screen_axis returns (-1, 0).
func rotation_for(screen_axis: StringName, dir: int) -> Vector2i:
	var s: int = 1 if dir >= 0 else -1
	var axes: Dictionary = CameraMath.view_axes(k, _base_deg, _step_deg)
	var right: Vector3i = axes["tilt"]  # world dir that appears screen-right
	var up: Vector3i = axes["roll"]     # world dir that appears screen-up (away from viewer)
	match screen_axis:
		&"spin":
			return Vector2i(Orientations.Axis.Y, -s)  # clockwise from above = negative right-hand
		&"tilt":
			# top away from viewer = negative right-hand turn about the screen-right vector
			return Vector2i(_axis_of(right), -s * _sign_of(right))
		&"roll":
			# top to the right = positive right-hand turn about the away-pointing vector
			return Vector2i(_axis_of(up), s * _sign_of(up))
	return Vector2i(-1, 0)


func _is_allowed(i: int) -> bool:
	return (_allowed >> i) & 1 == 1


static func _axis_of(v: Vector3i) -> int:
	return Orientations.Axis.X if v.x != 0 else Orientations.Axis.Z


static func _sign_of(v: Vector3i) -> int:
	return signi(v.x + v.z)
