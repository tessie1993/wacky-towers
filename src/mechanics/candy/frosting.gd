class_name FrostingRule extends RuleBehaviour
## A frosting tile peels at most once per resolve, survives its own full layer until empty.
const PLUGIN_ID := &"frosting"
var _peeled: Dictionary = {}
func subscribed_hooks() -> Array[StringName]:return [&"on_level_start",&"on_clear",&"on_resolve_end"]
func handle(hook: StringName,ctx: HookContext,api: RuleApi) -> void:
	if hook==&"on_level_start":
		for c: Vector3i in CandyCells.cells(api,true):
			if api.kind_at(c) in [api.kind_of(&"frosting"),api.kind_of(&"frosting_three")]:
				CandyCells.status(api,c,{"status_id":29,"frosting_layers":3 if api.kind_at(c)==api.kind_of(&"frosting_three") else 2,"clear_protected":true})
			elif api.kind_at(c)==api.kind_of(&"sponge"):CandyCells.protect(api,c)
	elif hook==&"on_resolve_end":_peeled.clear()
	else:
		var removed: Vector3i = ctx.data.get("cell",Vector3i(-999,-999,-999))
		for direction: Vector3i in CandyCells.FACE:
			var c: Vector3i = removed+direction
			if _peeled.has(c) or api.kind_at(c) not in [api.kind_of(&"frosting"),api.kind_of(&"frosting_three")]:continue
			_peeled[c]=true
			var layers: int = int(api.record_at(c).get("status",{}).get("frosting_layers",2))-1
			if layers<=0:api.remove_cell(c,BoardState.Cause.DAMAGE)
			else:CandyCells.status(api,c,{"frosting_layers":layers,"clear_protected":true})
			api.emit(&"frosting_peeled",{"cell":c,"layers_left":maxi(0,layers)})
func snapshot() -> Dictionary:return {"peeled":_peeled.duplicate()}
