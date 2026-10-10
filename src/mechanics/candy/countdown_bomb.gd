class_name CountdownBombRule extends RuleBehaviour
## Thrown bombs count owner locks, defuse next to a clear, and request one junk layer at zero.
const PLUGIN_ID := &"countdown_bomb"
var _locks: int = 0
var _defused: Dictionary = {}
func subscribed_hooks() -> Array[StringName]:return [&"on_clear",&"on_resolve_end"]
func handle(hook: StringName,ctx: HookContext,api: RuleApi) -> void:
	var kind: int = api.kind_of(&"countdown_bomb")
	if hook==&"on_clear":
		var center: Vector3i = ctx.data.get("cell",Vector3i.ZERO)
		var around: Array[Vector3i] = [center]
		for dir: Vector3i in CandyCells.FACE:around.append(center+dir)
		for c: Vector3i in around:
			if api.kind_at(c)==kind and not _defused.has(c):_defused[c]=true;api.remove_cell(c,BoardState.Cause.CLEAR);api.emit(&"countdown_defused",{"cell":c})
		return
	_locks+=1;_defused.clear()
	for c: Vector3i in CandyCells.cells(api,true):
		if api.kind_at(c)!=kind:continue
		var remaining: int = int(api.record_at(c).get("status",{}).get("counter",int(api.param(&"cd_start",8))))-1
		if remaining<=0:api.remove_cell(c,BoardState.Cause.DAMAGE);api.request_junk_layers(maxi(1,int(api.param(&"blast_layers",1))));api.emit(&"countdown_blast",{"cell":c})
		else:CandyCells.status(api,c,{"status_id":32,"counter":remaining});api.emit(&"countdown_tick",{"cell":c,"remaining":remaining})
	if _locks%maxi(1,int(api.param(&"thrown_every_locks",8)))==0:
		var choices: Array[Vector3i] = CandyCells.surface(api)
		if not choices.is_empty():
			var c: Vector3i = MechanicsCells.pick(api,choices);api.set_cell(c,kind);api.set_status(c,{"status_id":32,"counter":int(api.param(&"cd_start",8))});api.emit(&"countdown_thrown",{"cell":c,"remaining":int(api.param(&"cd_start",8))})
func snapshot() -> Dictionary:return {"locks":_locks,"defused":_defused.duplicate()}
