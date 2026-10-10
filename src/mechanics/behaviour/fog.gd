class_name FogRule extends RuleBehaviour
## Emits deterministic visibility state; collision and landing ghosts remain exact.
const PLUGIN_ID := &"fog"
var _started: int = -1
var _reveal_until: int = -1
var _alpha_milli: int = 1000


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_tick", &"on_clear"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var now: int = api.time_ms()
	if hook == &"on_spawn" and _started < 0:
		_started = now
	elif hook == &"on_clear":
		_reveal_until = now + maxi(1, int(api.param(&"reveal_ms", 600)))
	if _started < 0:
		return
	var age: int = now - _started
	var visible_ms: int = maxi(0, int(api.param(&"visible_ms", 5000)))
	var fade_ms: int = maxi(1, int(api.param(&"fade_ms", 1000)))
	var min_alpha: int = clampi(int(roundf(float(api.param(&"invisible_alpha", 0.1)) * 1000.0)), 0, 1000)
	var alpha: int = 1000
	if now >= _reveal_until and age >= visible_ms:
		var elapsed: int = mini(fade_ms, age - visible_ms)
		alpha = 1000 - int(float((1000 - min_alpha) * elapsed) / float(fade_ms))
	if alpha != _alpha_milli:
		_alpha_milli = alpha
		api.emit(&"fog_visibility", {"alpha_milli": alpha, "alpha": float(alpha) / 1000.0})


func snapshot() -> Dictionary:
	return {"started": _started, "reveal_until": _reveal_until, "alpha_milli": _alpha_milli}
