class_name StickyLandingRule extends RuleBehaviour
const PLUGIN_ID := &"sticky_landing"


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_spawn", &"on_land"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		api.request_slot(&"fall.gravity_scale", int(roundf(float(api.param(&"sticky_gravity_scale", 0.7)) * 1000.0)))
	elif hook == &"on_spawn":
		api.set_piece_flag(&"sticky", true)
	else:
		api.set_piece_flag(&"lock_now", true)
		api.emit(&"sticky_landing", {})
