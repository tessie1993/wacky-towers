class_name FillShapeRule extends RuleBehaviour
const PLUGIN_ID := &"fill_shape"


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	api.request_slot(&"clear.detector", &"none")
	api.request_slot(&"goal.top_out", StringName(String(api.param(&"topout_rule", "trim"))))
