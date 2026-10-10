class_name JellyPieceRule extends RuleBehaviour
## A tagged jelly hops once along its last move, then one locked cube may slump down.
const PLUGIN_ID := &"jelly_piece"
var _special: bool = false
var _hopped: bool = false
var _last := Vector3i.ZERO
func subscribed_hooks() -> Array[StringName]:return [&"on_spawn",&"on_command",&"on_land",&"on_lock"]
func handle(hook: StringName,ctx: HookContext,api: RuleApi) -> void:
	if hook==&"on_spawn":
		_special=ctx.data.get("tags",PackedStringArray()).has("jelly")
		_hopped=false;_last=Vector3i.ZERO
	elif hook==&"on_command" and ctx.data.get("kind")==SimEvents.CMD_MOVE:
		var args: Variant = ctx.data.get("args",[])
		var raw: Variant = args[0] if args is Array and not args.is_empty() else args.get("dir",Vector3i.ZERO) if args is Dictionary else Vector3i.ZERO
		if raw is Vector3i:_last=raw
	elif hook==&"on_land" and _special and not _hopped:
		_hopped=true
		var amount: int = clampi(int(api.param(&"jelly_bounce",1))+api.goal_counter(&"jelly_bonus"),0,3)
		api.goal_metric(&"jelly_bonus",0)
		if _last!=Vector3i.ZERO:
			for _step: int in amount:
				if api.try_translate(_last).get("result")!=Movement.Result.OK:break
		api.emit(&"jelly_hop",{"direction":_last,"distance":amount})
	elif hook==&"on_lock" and _special:
		for c: Vector3i in ctx.data.get("cells",[]):
			if api.is_free(c+api.down_vector()):
				api.move_cell(c,c+api.down_vector());api.emit(&"jelly_slump",{"from":c,"to":c+api.down_vector()});break
func snapshot() -> Dictionary:return {"special":_special,"hopped":_hopped,"last":_last}
