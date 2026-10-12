class_name MonoLayerRule extends RuleBehaviour
const PLUGIN_ID := &"mono_layer"


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	api.request_slot(&"clear.detector", &"mono_layer")
	api.request_slot(&"clear.mono_extra_layers", int(api.param(&"mono_extra_layers", 1)))
