class_name ConveyorRule extends RuleBehaviour
const PLUGIN_ID := &"conveyor"
var _belt: MillBeltRule = MillBeltRule.new()


func subscribed_hooks() -> Array[StringName]:
	return _belt.subscribed_hooks()


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	_belt.handle(hook, ctx, api)


func snapshot() -> Dictionary:
	return _belt.snapshot()
