class_name EarnedSpecialsRule extends RuleBehaviour
## Candy's explicit bomb_at threshold leaves one bomb per connected cleared flavour group.
const PLUGIN_ID := &"earned_specials"
var _cleared: Dictionary = {}
var _last: Array[Vector3i] = []
var _blasted: Dictionary = {}
func subscribed_hooks() -> Array[StringName]:return [&"on_lock",&"on_clear",&"on_resolve_end"]
func handle(hook: StringName,ctx: HookContext,api: RuleApi) -> void:
	if hook==&"on_lock":_last.assign(ctx.data.get("cells",[]));return
	if hook==&"on_clear":
		var c: Vector3i = ctx.data.get("cell",Vector3i.ZERO)
		if int(ctx.data.get("kind",0))==api.kind_of(&"candy_bomb") and not _blasted.has(c):
			_blasted[c]=true
			for x: int in range(c.x-1,c.x+2):
				for y: int in range(c.y-1,c.y+2):
					for z: int in range(c.z-1,c.z+2):
						var target := Vector3i(x,y,z)
						if api.kind_at(target)!=0 and not bool(api.record_at(target).get("status",{}).get("anchored",false)):api.remove_cell(target,BoardState.Cause.DAMAGE)
			api.emit(&"candy_bomb_blast",{"cell":c})
		var hue: int = api.color_at(c)
		if hue>0:_cleared[c]=hue
		return
	var seen: Dictionary = {}
	for first: Variant in _cleared:
		if seen.has(first):continue
		var group: Array[Vector3i] = [first];seen[first]=true;var cursor: int = 0
		while cursor<group.size():
			var c: Vector3i = group[cursor];cursor+=1
			for dir: Vector3i in CandyCells.FACE:
				var next: Vector3i = c+dir
				if _cleared.get(next,-1)==_cleared[first] and not seen.has(next):group.append(next);seen[next]=true
		if int(api.param(&"bomb_at",7))<=0 or group.size()<int(api.param(&"bomb_at",7)):continue
		var choices: Array[Vector3i] = []
		for c: Vector3i in group:
			if api.is_free(c):choices.append(c)
		if choices.is_empty():continue
		var center: Vector3i = _last[0] if not _last.is_empty() else choices[0]
		choices.sort_custom(func(a:Vector3i,b:Vector3i)->bool:return a.distance_squared_to(center)<b.distance_squared_to(center))
		api.set_cell(choices[0],api.kind_of(&"candy_bomb"));api.emit(&"earned_bomb",{"cell":choices[0],"group_size":group.size()})
	_cleared.clear();_blasted.clear()
func snapshot() -> Dictionary:return {"cleared":_cleared.duplicate(),"last":_last.duplicate(),"blasted":_blasted.duplicate()}
