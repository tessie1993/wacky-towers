class_name WtCameraTurn extends RefCounted
## Data-driven camera turn: a short ease-out-back yaw move (slight overshoot, then settle) plus the
## backdrop parallax lag. Pure maths: it never touches a node. WtStage and CameraRig drive it.
## Values live in res://assets/data/camera_controls.json under "turn" (see the schema note there).
##   duration_ms          length of one snap turn
##   overshoot            ease-out-back "s": peak overshoot is ~2.3% of the turn at 0.8 (0.7 deg of 30)
##   reduced_duration_ms  turn length under reduced motion (0 = instant); always linear, never overshoots
##   parallax_ratio       backdrop drift as a fraction of the camera's own yaw rate (0 = glued)
##   parallax_settle_per_s how fast the drifted backdrop eases back to rest once the camera stops
##   sky_shift_per_deg    sky shader shift (aspect-scaled screen widths) per degree of backdrop drift
##   max_drift_deg        cap on the backdrop drift
## Camera GDD F4 (snap turn animation) and art review r2 section 4 (turn feel).

const DEFAULTS: Dictionary = {
	"duration_ms": 200.0,
	"overshoot": 0.8,
	"reduced_duration_ms": 0.0,
	"parallax_ratio": 0.45,
	"parallax_settle_per_s": 5.0,
	"sky_shift_per_deg": 0.012,
	"max_drift_deg": 14.0,
}

var _cfg: Dictionary = {}
var _reduced: bool = false
var _from: float = 0.0
var _to: float = 0.0
var _elapsed: float = 0.0
var _duration: float = 0.0
var _active: bool = false
var _drift: float = 0.0
var _last_yaw: float = 0.0
var _has_last: bool = false


## `config` overrides the json "turn" block (tests inject one); empty loads camera_controls.json.
func _init(config: Dictionary = {}) -> void:
	var block: Dictionary = config
	if block.is_empty():
		var data: Dictionary = WtCameraControls.load_data()
		var turn: Variant = data.get("turn", {})
		block = turn if turn is Dictionary else {}
	_cfg = DEFAULTS.duplicate()
	_cfg.merge(block, true)


## One tuned value by key (data first, then DEFAULTS).
func value(key: String) -> float:
	return float(_cfg.get(key, DEFAULTS.get(key, 0.0)))


## Reduced motion switch: no overshoot, no parallax, instant or short linear turn.
func set_reduced(reduced: bool) -> void:
	_reduced = reduced
	if reduced: _drift = 0.0


## True while a turn is in flight.
func is_active() -> bool:
	return _active


## Seconds the next turn takes (0 = instant) for the current reduced-motion state.
func duration_s() -> float:
	return maxf(0.0, value("reduced_duration_ms" if _reduced else "duration_ms")) / 1000.0


## Starts a turn from `from_deg` to `to_deg` (degrees, shortest way round); replaces any running turn.
## Returns the unwrapped target yaw. Instant turns finish at once (is_active() false, yaw() == target).
func begin(from_deg: float, to_deg: float) -> float:
	_from = from_deg
	_to = from_deg + rad_to_deg(angle_difference(deg_to_rad(from_deg), deg_to_rad(to_deg)))
	_elapsed = 0.0
	_duration = duration_s()
	_active = _duration > 0.0 and not is_equal_approx(_from, _to)
	return _to


## Eased yaw (degrees) at progress `t` in 0..1: ease-out-back, or linear when reduced.
func eased(t: float) -> float:
	var p: float = clampf(t, 0.0, 1.0)
	return lerpf(_from, _to, linear(p) if _reduced else ease_out_back(p, value("overshoot")))


## Advances the turn by `delta` seconds and returns the current yaw (degrees).
func step(delta: float) -> float:
	if not _active: return _to
	_elapsed += delta
	if _elapsed >= _duration:
		_active = false
		return _to
	return eased(_elapsed / _duration)


## Final yaw of the last begin().
func target_yaw() -> float:
	return _to


## Advances the backdrop parallax drift for the camera's current yaw; returns the drift in degrees.
## The backdrop moves `parallax_ratio` of every camera yaw change, then eases back to rest.
## Positive drift means the backdrop trails the camera (far root yaw = camera yaw - drift).
func update_drift(yaw_deg: float, delta: float) -> float:
	var moved: float = rad_to_deg(angle_difference(deg_to_rad(_last_yaw), deg_to_rad(yaw_deg))) if _has_last else 0.0
	_has_last = true
	_last_yaw = yaw_deg
	if _reduced:
		_drift = 0.0
		return 0.0
	_drift += moved * value("parallax_ratio")
	_drift *= exp(-value("parallax_settle_per_s") * maxf(delta, 0.0))
	var cap: float = value("max_drift_deg")
	_drift = clampf(_drift, -cap, cap)
	if absf(_drift) < 0.001: _drift = 0.0
	return _drift


## Declares that the camera jumped to `yaw_deg` on purpose (instant cut): no parallax for that move.
func sync_yaw(yaw_deg: float) -> void:
	_last_yaw = yaw_deg
	_has_last = true


## Current backdrop drift in degrees.
func drift() -> float:
	return _drift


## Sky shader shift for the current drift.
func sky_shift() -> float:
	return _drift * value("sky_shift_per_deg")


## Ease-out-back with overshoot constant `s`: 0 at t=0, 1 at t=1, peaks above 1 near the end.
static func ease_out_back(t: float, s: float) -> float:
	var u: float = clampf(t, 0.0, 1.0) - 1.0
	return 1.0 + (s + 1.0) * u * u * u + s * u * u


## Linear ease (reduced motion).
static func linear(t: float) -> float:
	return clampf(t, 0.0, 1.0)


## Peak of ease_out_back(., s) minus 1, as a fraction of the move (for docs and tests).
static func overshoot_fraction(s: float) -> float:
	if s <= 0.0: return 0.0
	var u: float = -2.0 * s / (3.0 * (s + 1.0))
	return (s + 1.0) * u * u * u + s * u * u
