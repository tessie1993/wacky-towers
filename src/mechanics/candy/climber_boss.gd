class_name ClimberBossRule extends RuleBehaviour
## A protected2×2 topper climbs connected surface terraces; a touching pop tumbles it down.
const PLUGIN_ID := &"climber_boss"
var _anchor := Vector3i(-1,-1,-1)
var _spawned: bool = false
var _bonk_requested: bool = false
var _bonks: int = 0
func subscribed_hooks() -> Array[StringName]:return [&"on_level_start",&"on_clear",&"on_resolve_end"]
func _footprint(at: Vector3i) -> Array[Vector3i]:
	return [at,at+Vector3i.RIGHT,at+Vector3i(0,0,1),at+Vector3i(1,0,1)]
func _candidates(api: RuleApi,own: Array[Vector3i]) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	for anchor: Vector3i in CandyCells.cells(api):
		var okay: bool = true;var supported: bool = false
		for c: Vector3i in _footprint(anchor):
			var below: Vector3i = c+api.down_vector()
			if not api.is_active(c) or api.layer_of(c)>=api.limit_layer() or (api.kind_at(c)!=0 and not own.has(c)):okay=false;break
			if not api.is_active(below) or (api.kind_at(below)!=0 and not own.has(below)):supported=true
		if okay and supported:result.append(anchor)
	return result
func handle(hook: StringName,ctx: HookContext,api: RuleApi) -> void:
	if hook==&"on_resolve_end" and not api.stack_writes_allowed():return
	if hook==&"on_level_start":
		for c: Vector3i in CandyCells.cells(api,true):
			if api.kind_at(c)==api.kind_of(&"sponge"):CandyCells.protect(api,c)
		return
	if hook==&"on_clear":
		if not _spawned:return
		var removed: Vector3i = ctx.data.get("cell",Vector3i(-999,-999,-999))
		for boss: Vector3i in _footprint(_anchor):
			for dir: Vector3i in CandyCells.FACE:
				if removed==boss+dir:_bonk_requested=true
		return
	if String(api.goal_config().get("type",""))=="bake_oven" and api.goal_counter(&"baked")==0:return
	var own: Array[Vector3i] = []
	if _spawned:own.assign(_footprint(_anchor))
	var choices: Array[Vector3i] = _candidates(api,own)
	if choices.is_empty():return
	if not _spawned:
		choices.sort_custom(func(a:Vector3i,b:Vector3i)->bool:return a.y>b.y or (a.y==b.y and (a.x<b.x or (a.x==b.x and a.z<b.z))))
		_anchor=choices[0];_spawned=true
		for c: Vector3i in _footprint(_anchor):api.set_cell(c,api.kind_of(&"climber_boss"));api.set_status(c,{"status_id":41,"anchored":true,"clear_protected":true,"boss":true})
		api.emit(&"climber_spawned",{"anchor":_anchor});return
	if _bonk_requested:
		_bonk_requested=false
		var lower: Array[Vector3i] = []
		for c: Vector3i in choices:
			if abs(c.x-_anchor.x)+abs(c.z-_anchor.z)<=1 and _anchor.y-c.y>=int(api.param(&"bonk_drop_cells",1)):lower.append(c)
		if lower.is_empty():api.emit(&"bonk_blocked",{"anchor":_anchor});return
		lower.sort_custom(func(a:Vector3i,b:Vector3i)->bool:return a.y<b.y or (a.y==b.y and (a.x<b.x or (a.x==b.x and a.z<b.z))))
		var target: Vector3i = lower[0];var fall: int = _anchor.y-target.y
		api.move_cells(own,_footprint(target),true);_anchor=target;_bonks+=1;api.add_goal_counter(&"bonks",1);api.emit(&"boss_bonk",{"anchor":target,"drop_cells":fall,"bonks":_bonks});return
	var reachable: Array[Vector3i] = [_anchor];var cursor: int = 0
	while cursor<reachable.size():
		var from: Vector3i = reachable[cursor];cursor+=1
		for c: Vector3i in choices:
			if not reachable.has(c) and abs(c.x-from.x)+abs(c.z-from.z)==1 and abs(c.y-from.y)<=1:reachable.append(c)
	reachable.sort_custom(func(a:Vector3i,b:Vector3i)->bool:return a.y>b.y or (a.y==b.y and (a.x<b.x or (a.x==b.x and a.z<b.z))))
	if reachable[0]!=_anchor:api.move_cells(own,_footprint(reachable[0]),true);_anchor=reachable[0];api.emit(&"climber_moved",{"anchor":_anchor})
func snapshot() -> Dictionary:return {"anchor":_anchor,"spawned":_spawned,"bonk_requested":_bonk_requested,"bonks":_bonks}
