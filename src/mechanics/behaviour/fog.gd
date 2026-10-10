class_name FogRule extends RuleBehaviour
## Per-lock fade and deterministic ghost-footprint lantern light; collision remains untouched.
const PLUGIN_ID := &"fog"
var _started: int = -1
var _reveal_until: int = -1
var _alpha_milli: int = 1000
var _locked_at: Dictionary = {}
var _clear_count: int = 0
var _visibility_key: String = ""

func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_tick", &"on_lock", &"on_clear"]

func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var now: int = api.time_ms()
	if hook == &"on_lock":
		_locked_at[int(ctx.data.get("uid", api.get_piece_uid()))] = now
	elif hook == &"on_clear":
		_clear_count = int(ctx.data.get("clear_count", _clear_count + 1))
		_reveal_until = now + maxi(1, int(api.param(&"reveal_ms", 600)))
	if _clear_count < int(api.param(&"active_after_clears", 0)):
		return
	if _started < 0:
		_started = now
	var radius: int = maxi(0, int(api.param(&"lantern_radius", 0)))
	var ghost: Array[Vector3i] = []
	if radius > 0 and not api.piece_cells().is_empty():
		var shift: Vector3i = api.down_vector() * api.cast(api.piece_cells(), api.down_vector())
		for cell: Vector3i in api.piece_cells():
			ghost.append(cell + shift)
		if api.rule_active(&"mirror"):
			var axis: int = 2 if str(api.param(&"mirror_axis", "x")) == "z" else 0
			var size: Vector3i = api.board_size()
			for cell: Vector3i in ghost.duplicate():
				var twin: Vector3i = cell
				twin[axis] = size[axis] - 1 - cell[axis]
				ghost.append(twin)
	var visible_ms: int = maxi(0, int(api.param(&"visible_ms", 5000)))
	var fade_ms: int = maxi(1, int(api.param(&"fade_ms", 1000)))
	var minimum: float = clampf(float(api.param(&"invisible_alpha", 0.1)), 0.0, 1.0)
	var alphas: Array[Dictionary] = []
	var lantern: Array[Vector3i] = []
	var occupied: Array[Vector3i] = MechanicsCells.occupied(api)
	var empty_fade: float = clampf(float(now - _started - visible_ms) / float(fade_ms), 0.0, 1.0)
	var dimmest: float = (1.0 if now < _reveal_until else lerpf(1.0, minimum, empty_fade)) if occupied.is_empty() else 1.0
	for cell: Vector3i in occupied:
		var uid: int = int(api.record_at(cell).get("piece_instance_id", 0))
		var born: int = int(_locked_at.get(uid, _started))
		var fade: float = clampf(float(now - born - visible_ms) / float(fade_ms), 0.0, 1.0)
		var alpha: float = 1.0 if now < _reveal_until else lerpf(1.0, minimum, fade)
		for target: Vector3i in ghost:
			if maxi(absi(cell.x - target.x), absi(cell.z - target.z)) <= radius:
				alpha = 1.0
				lantern.append(cell)
				break
		dimmest = minf(dimmest, alpha)
		alphas.append({"cell": cell, "alpha": alpha})
	_alpha_milli = int(roundf(dimmest * 1000.0))
	var key: String = str(alphas)
	if key != _visibility_key:
		_visibility_key = key
		api.emit(&"fog_visibility", {"alpha_milli": _alpha_milli, "alpha": dimmest, "cell_alphas": alphas, "lantern_cells": lantern})

func snapshot() -> Dictionary:
	return {"started": _started, "reveal_until": _reveal_until, "alpha_milli": _alpha_milli,
		"locked_at": _locked_at.duplicate(true), "clear_count": _clear_count, "visibility_key": _visibility_key}
