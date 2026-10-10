class_name LicoriceLockRule extends RuleBehaviour
## Anchored licorice unties only when a face neighbour actually clears.
const PLUGIN_ID := &"licorice_lock"
func subscribed_hooks() -> Array[StringName]:return [&"on_level_start",&"on_clear"]
func handle(hook: StringName,ctx: HookContext,api: RuleApi) -> void:
	var kind: int = api.kind_of(&"licorice")
	if hook==&"on_level_start":
		for c: Vector3i in CandyCells.cells(api,true):
			if api.kind_at(c)==kind:CandyCells.status(api,c,{"anchored":true,"clear_protected":true})
	else:
		var removed: Vector3i = ctx.data.get("cell",Vector3i(-999,-999,-999))
		for direction: Vector3i in CandyCells.FACE:
			var c: Vector3i = removed+direction
			if api.kind_at(c)==kind:
				api.remove_cell(c,BoardState.Cause.DAMAGE);api.set_cell(c,api.kind_of(&"starter"));api.emit(&"licorice_untied",{"cell":c})
