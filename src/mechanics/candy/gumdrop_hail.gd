class_name GumdropHailRule extends RuleBehaviour
## Forecast a seeded free supported cell, respecting initial pockets; icing becomes peelable after bake.
const PLUGIN_ID := &"gumdrop_hail"
var _locks: int = 0
var _pending := Vector3i(-1,-1,-1)
var _marked: bool = false
var _holes: Dictionary = {}
var _cancelled: bool = false
func subscribed_hooks() -> Array[StringName]:return [&"on_level_start",&"on_clear",&"on_resolve_end"]
func handle(hook: StringName,_ctx: HookContext,api: RuleApi) -> void:
	if hook==&"on_level_start":
		if bool(api.param(&"avoid_start_holes",false)):
			for c: Vector3i in CandyCells.cells(api,true):
				var below: Vector3i = c+api.down_vector()
				while api.is_active(below):
					if api.is_free(below):_holes[below]=true
					below+=api.down_vector()
		return
	var icing: bool = String(api.param(&"object","gumdrop"))=="icing_dollop"
	if hook==&"on_clear":
		if _marked and icing and api.goal_counter(&"baked")>0:_cancelled=true
		return
	_locks+=1
	var every: int = maxi(2,int(api.param(&"spawn_every_locks",4)))
	if _marked and _locks%every==0:
		if not _cancelled and api.is_free(_pending):
			var kind: int = api.kind_of(&"frosting" if icing and api.goal_counter(&"baked")>0 else &"icing_dollop" if icing else &"gumdrop")
			var hue: int = 0 if icing else api.rng().randi_range(1,maxi(1,api.knob_int(&"spawn.colour_count")))
			api.set_cell(_pending,kind,hue)
			if icing and api.goal_counter(&"baked")>0:api.set_status(_pending,{"status_id":29,"frosting_layers":2,"clear_protected":true})
			api.emit(&"gumdrop_hail",{"cell":_pending,"kind":kind,"flavour":hue,"sticky":true})
		else:api.emit(&"hail_cancelled",{"cell":_pending})
		_marked=false
	if _locks<int(api.param(&"hail_after_locks",0)) or _locks%every!=every-1:return
	var objects: int = 0
	for c: Vector3i in CandyCells.cells(api,true):
		if api.kind_at(c) in [api.kind_of(&"gumdrop"),api.kind_of(&"icing_dollop"),api.kind_of(&"frosting")]:objects+=1
	if objects>=int(api.param(&"objects_max",6)):return
	var choices: Array[Vector3i] = []
	for c: Vector3i in CandyCells.surface(api):
		if not _holes.has(c):choices.append(c)
	if not choices.is_empty():_pending=MechanicsCells.pick(api,choices);_marked=true;_cancelled=false;api.emit(&"hail_warning",{"cell":_pending,"locks_left":1})
func snapshot() -> Dictionary:return {"locks":_locks,"pending":_pending,"marked":_marked,"holes":_holes.duplicate(),"cancelled":_cancelled}
