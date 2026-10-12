class_name FlipRule extends RuleBehaviour
## General EV03: invert the stack in place, or change its down axis once.
const PLUGIN_ID := &"flip"
var _next_ms: int = -1
var _next_clear: int = -1
var _pending: bool = false
var _warned: bool = false
var _flips: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_tick", &"on_clear", &"on_resolve_end"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var maximum: int = int(api.param(&"flip_max", 0))
	if maximum > 0 and _flips >= maximum and not _pending:
		return
	var now: int = api.time_ms()
	var every_ms: int = maxi(0, int(api.param(&"flip_every_ms", 40000)))
	var every_clear: int = maxi(1, int(api.param(&"flip_every_layers", 2)))
	if _next_clear < 0:
		_next_clear = every_clear
	if hook == &"on_spawn" and _next_ms < 0 and every_ms > 0:
		_next_ms = now + every_ms
	if not _warned and not _pending and _next_ms >= 0 and now >= _next_ms - int(api.param(&"flip_warn_ms", 2000)):
		_warned = true
		api.emit(&"flip_warning", {"due_ms": _next_ms, "mode": api.param(&"flip_mode", "stack")})
	var clears: int = int(ctx.data.get("clear_count", 0))
	var by_time: bool = every_ms > 0 and _next_ms >= 0 and now >= _next_ms
	if not _pending and (clears >= _next_clear or by_time):
		_pending = true
		_flips += 1
		var mode: String = String(api.param(&"flip_mode", "stack"))
		if mode == "axis":
			var down: int = BoardState.down_from_token(String(api.param(&"flip_to_axis", "-x")))
			if down >= 0:
				api.request_flip(down)
				api.request_settle()
		else:
			api.request_stack_flip()
		api.emit(&"gravity_flip", {"mode": mode, "flip": _flips, "trigger": "time" if by_time else "layers"})
	if hook == &"on_resolve_end" and _pending:
		_next_clear = clears + every_clear
		_next_ms = now + every_ms if every_ms > 0 else -1
		_pending = false
		_warned = false


func snapshot() -> Dictionary:
	return {"next_ms": _next_ms, "next_clear": _next_clear, "pending": _pending, "warned": _warned, "flips": _flips}
