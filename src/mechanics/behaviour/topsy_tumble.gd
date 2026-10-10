class_name TopsyTumbleRule extends RuleBehaviour
## Flip requests are structural writes consumed only during Resolving.
const PLUGIN_ID := &"topsy_tumble"
var _next_ms: int = -1
var _next_clear: int = -1
var _warned: bool = false
var _pending: bool = false
var _flips: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_tick", &"on_clear", &"on_resolve_end"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var now: int = api.time_ms()
	var every_ms: int = maxi(0, int(api.param(&"flip_every_ms", 40000)))
	var every_clear: int = maxi(1, int(api.param(&"flip_every_layers", 2)))
	if _next_clear < 0:
		_next_clear = every_clear
	if hook == &"on_spawn" and _next_ms < 0 and every_ms > 0:
		_next_ms = now + every_ms
	if not _pending and _next_ms >= 0 and now >= _next_ms - int(api.param(&"flip_warn_ms", 2000)) and not _warned:
		_warned = true
		api.emit(&"flip_warning", {"due_ms": _next_ms})
	var clear_count: int = int(ctx.data.get("clear_count", 0))
	var by_time: bool = every_ms > 0 and _next_ms >= 0 and now >= _next_ms
	var by_clear: bool = clear_count >= _next_clear
	if not _pending and (by_time or by_clear):
		_pending = true
		_flips += 1
		api.request_stack_flip()
		api.request_settle()
		api.emit(&"topsy_tumble", {"trigger": "layers" if by_clear else "time", "flip": _flips})
	if hook == &"on_resolve_end" and _pending:
		_next_clear = clear_count + every_clear
		_next_ms = now + every_ms if every_ms > 0 else -1
		_pending = false
		_warned = false


func snapshot() -> Dictionary:
	return {"next_ms": _next_ms, "next_clear": _next_clear, "warned": _warned, "pending": _pending, "flips": _flips}
