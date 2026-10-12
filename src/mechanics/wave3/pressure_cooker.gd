class_name PressureCookerRule extends RuleBehaviour
## W7: gravity rises a step for every lock without a clear and resets on a clear.
const PLUGIN_ID := &"pressure_cooker"
var _pressure: int = 0
var _cleared: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_lock", &"on_clear", &"on_resolve_end"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	match hook:
		&"on_level_start":
			_pressure = 0
			_cleared = false
			api.clear_modifiers(PLUGIN_ID)
		&"on_lock":
			_cleared = false
		&"on_clear":
			_cleared = true
			if _pressure > 0:
				_pressure = 0
				api.clear_modifiers(PLUGIN_ID)
				api.emit(&"pressure_release", {})
		&"on_resolve_end":
			if _cleared:
				return
			_pressure += 1
			var step: float = float(api.param(&"step", 0.15))
			var scale: float = minf(float(api.param(&"max_scale", 2.5)), 1.0 + step * _pressure)
			var modifiers: Array[Dictionary] = [{"knob": "fall.gravity_scale", "op": "mul", "value": scale}]
			api.request_modifiers(PLUGIN_ID, modifiers)
			api.emit(&"pressure", {"level": _pressure})


func snapshot() -> Dictionary:
	return {"pressure": _pressure, "cleared": _cleared}
