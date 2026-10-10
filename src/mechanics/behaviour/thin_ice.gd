class_name ThinIceRule extends RuleBehaviour
## Telegraphs one rim strip and removes it only at the next resolution.
const PLUGIN_ID := &"thin_ice"
var _started: int = -1
var _due: int = -1
var _step: int = 0
var _warned: bool = false
var _pending: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_tick", &"on_lock"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var now: int = api.time_ms()
	var interval: int = maxi(1000, int(api.param(&"shrink_every_ms", 35000)))
	if hook == &"on_spawn" and _started < 0:
		_started = now
		_due = now + interval
	if _started < 0 or _step >= int(api.param(&"shrink_steps", 3)):
		return
	if now >= _due - int(api.param(&"shrink_warn_ms", 3000)) and not _warned:
		_warned = true
		api.emit(&"thin_ice_warning", {"step": _step, "due_ms": _due})
	if now >= _due:
		_pending = true
	if hook != &"on_lock" or not _pending:
		return
	var order: Array = api.param(&"shrink_order", ["+z", "+x", "+z"])
	var direction_value: Vector3i = MechanicsCells.direction(String(order[_step % order.size()]))
	var footprint: Array[Vector3i] = []
	var extreme: int = -2147483647 if direction_value.x + direction_value.z > 0 else 2147483647
	var axis: int = 0 if direction_value.x != 0 else 2
	var lo: int = 2147483647
	var hi: int = -2147483647
	var size: Vector3i = api.board_size()
	for x: int in size.x:
		for z: int in size.z:
			var c := Vector3i(x, 0, z)
			if api.is_active(c):
				footprint.append(c)
				lo = mini(lo, c[axis])
				hi = maxi(hi, c[axis])
				extreme = maxi(extreme, c[axis]) if direction_value[axis] > 0 else mini(extreme, c[axis])
	var removed: int = 0
	if hi - lo + 1 > int(api.param(&"min_width", 4)):
		for c: Vector3i in footprint:
			if c[axis] == extreme:
				api.request_mask(c.x, c.z, false)
				removed += 1
	api.emit(&"thin_ice_shrink", {"step": _step, "columns": removed, "direction": direction_value})
	_step += 1
	_due = now + interval
	_warned = false
	_pending = false


func snapshot() -> Dictionary:
	return {"started": _started, "due": _due, "step": _step, "warned": _warned, "pending": _pending}
