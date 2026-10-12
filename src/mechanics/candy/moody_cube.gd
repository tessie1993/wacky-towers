class_name MoodyCubeRule extends RuleBehaviour
## One tagged Mono per bag sulks until a face neighbour shares its flavour.
const PLUGIN_ID := &"moody_cube"
var _special: bool = false
func subscribed_hooks() -> Array[StringName]:return [&"on_spawn",&"on_lock",&"on_resolve_end"]
func handle(hook: StringName,ctx: HookContext,api: RuleApi) -> void:
	if hook==&"on_spawn":
		_special=ctx.data.get("tags",PackedStringArray()).has("moody")
		if _special:api.replace_shape(&"mono")
	elif hook==&"on_lock" and _special:
		for c: Vector3i in ctx.data.get("cells",[]):
			api.set_cell(c,api.kind_of(&"moody"),api.color_at(c),int(ctx.data.get("uid",0)))
			var happy: bool = false
			for dir: Vector3i in CandyCells.FACE:
				if api.color_at(c+dir)==api.color_at(c) and api.color_at(c)>0:happy=true
			api.set_status(c,{"status_id":20,"grumpy":not happy,"fills_layer":happy,"clear_protected":not happy})
		_update(api)
	elif hook==&"on_resolve_end":_update(api)
func _update(api: RuleApi) -> void:
	for c: Vector3i in CandyCells.cells(api,true):
		if api.kind_at(c)!=api.kind_of(&"moody"):continue
		var happy: bool = false
		for dir: Vector3i in CandyCells.FACE:
			if api.color_at(c+dir)==api.color_at(c) and api.color_at(c)>0:happy=true
		if bool(api.record_at(c).get("status",{}).get("forced_grumpy",false)):happy=false
		CandyCells.status(api,c,{"status_id":20,"grumpy":not happy,"forced_grumpy":false,"fills_layer":happy,"clear_protected":not happy})
		api.emit(&"gummy_mood",{"cell":c,"happy":happy})
func snapshot() -> Dictionary:return {"special":_special}
