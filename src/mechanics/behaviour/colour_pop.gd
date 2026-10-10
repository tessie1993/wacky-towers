class_name ColourPopRule extends RuleBehaviour
const PLUGIN_ID := &"colour_pop"


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	api.request_slot(&"clear.detector", &"colour_connect")
	api.request_slot(&"clear.collapse", &"cascade")
	api.request_slot(&"clear.pop_min", int(api.param(&"pop_min", 6)))
	api.request_slot(&"clear.pop_min_pieces", int(api.param(&"pop_min_pieces", 2)))
	api.request_slot(&"clear.layer_clear_too", bool(api.param(&"layer_clear_too", false)))
