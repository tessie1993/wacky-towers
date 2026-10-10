class_name GustRule extends RuleBehaviour
## Seeded gust schedule; due gusts without a falling piece are dropped.
const PLUGIN_ID := &"gust"
var _due: int = -1
var _warned: bool = false
var _direction := Vector3i(1, 0, 0)


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_spawn", &"on_tick"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_due = -1
		_direction = MechanicsCells.direction(String(api.param(&"wind_dir", "+x")))
	elif hook == &"on_spawn" and _due < 0:
		_schedule(api)
	elif hook == &"on_tick" and _due >= 0:
		var now: int = api.time_ms()
		if not _warned and now >= _due - int(api.param(&"wind_warn_ms", 1000)):
			_warned = true
			if not api.piece_cells().is_empty():
				api.emit(&"gust_warning", {"direction": _direction, "due_ms": _due})
		if now >= _due:
			if not api.piece_cells().is_empty():
				var strength: int = clampi(int(api.param(&"wind_strength", 1)), 1, 3)
				for _step: int in strength:
					api.request_move_piece(_direction)
				api.emit(&"gust", {"direction": _direction, "strength": strength})
			_schedule(api)


func _schedule(api: RuleApi) -> void:
	var jitter: int = maxi(0, int(api.param(&"wind_jitter_ms", 2000)))
	var delta: int = api.rng().randi_range(-jitter, jitter) if jitter > 0 else 0
	_due = api.time_ms() + maxi(1000, int(api.param(&"wind_interval_ms", 8000)) + delta)
	_warned = false
	if String(api.param(&"wind_mode", "fixed")) == "random":
		var dirs: Array[Vector3i] = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i(0, 0, -1), Vector3i(0, 0, 1)]
		_direction = dirs[api.rng().randi_range(0, dirs.size() - 1)]


func snapshot() -> Dictionary:
	return {"due": _due, "warned": _warned, "direction": _direction}
