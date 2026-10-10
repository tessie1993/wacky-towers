class_name Gestures extends RefCounted
## Pure touch-gesture maths. Thresholds come from control.* knobs (passed in, never read here).
## Flick axes use the ADR-0012 ids: horizontal flick = spin (Turn), vertical flick = tilt (Flip).
## Roll has no gesture; it uses the two roll buttons. A FLICK result carries axis + rot (+1 / -1).

enum Kind { NONE, TAP, HOLD, DRAG, FLICK }

const AXIS_SPIN: StringName = InputAxes.SPIN
const AXIS_TILT: StringName = InputAxes.TILT
const AXIS_NONE: StringName = &""


## Classifies a finished touch. Returns {kind, dir: Vector2i, axis: StringName, rot: int}.
## FLICK: dir is a unit axis step (screen-up = (0,-1)); right/up flick = rot +1, left/down = -1;
## horizontal flicks -> axis &"spin", vertical flicks -> &"tilt". Else dir ZERO, axis "", rot 0.
## Usage: Gestures.classify(ms, travel_px, tap_ms, flick_ms, flick_min_px, dead_px, cone_deg)
static func classify(duration_ms: int, travel: Vector2, tap_ms: int, flick_ms: int,
		flick_min_px: float, dead_zone_px: float, cone_deg: float) -> Dictionary:
	var length: float = travel.length()
	if length <= dead_zone_px:
		return _result(Kind.TAP if duration_ms < tap_ms else Kind.HOLD)
	if duration_ms <= flick_ms and length >= flick_min_px:
		var horizontal: bool = absf(travel.x) >= absf(travel.y)
		var main: float = absf(travel.x) if horizontal else absf(travel.y)
		var off: float = absf(travel.y) if horizontal else absf(travel.x)
		if rad_to_deg(atan2(off, main)) > cone_deg:
			return _result(Kind.NONE)
		if horizontal:
			var sx: int = 1 if travel.x > 0.0 else -1
			return _result(Kind.FLICK, Vector2i(sx, 0), AXIS_SPIN, sx)
		var sy: int = 1 if travel.y > 0.0 else -1
		return _result(Kind.FLICK, Vector2i(0, sy), AXIS_TILT, -sy)
	return _result(Kind.DRAG)


## True once a press has lasted tap_ms or more (drop button: soft drop on).
## Usage: Gestures.is_hold(elapsed_ms, tap_ms)
static func is_hold(elapsed_ms: int, tap_ms: int) -> bool:
	return elapsed_ms >= tap_ms


## Whole cells covered by a drag, truncated toward zero; px_per_cell <= 0 gives 0.
## Usage: Gestures.drag_cells(projected_px, px_per_cell)
static func drag_cells(projected_px: float, px_per_cell: float) -> int:
	if px_per_cell <= 0.0:
		return 0
	return int(projected_px / px_per_cell)


static func _result(kind: Kind, dir: Vector2i = Vector2i.ZERO,
		axis: StringName = AXIS_NONE, rot: int = 0) -> Dictionary:
	return {"kind": kind, "dir": dir, "axis": axis, "rot": rot}
