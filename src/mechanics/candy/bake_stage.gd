class_name BakeStageRule extends RuleBehaviour
## A two-second oven warning transforms locked batter, then swaps into the bonk objective.
const PLUGIN_ID := &"bake_stage"
var _baked: bool = false
var _due: int = -1
var _height: int = 4
var _coverage: int = 600
var _frost := FrostingRule.new()
func subscribed_hooks() -> Array[StringName]:return [&"on_level_start",&"on_clear",&"on_resolve_end",&"on_tick"]
func handle(hook: StringName,ctx: HookContext,api: RuleApi) -> void:
	if hook==&"on_level_start":
		_height=int(api.goal_config().get("h_target",4));_coverage=roundi(float(api.goal_config().get("height_coverage",0.6))*1000)
		api.request_slot(&"clear.enabled",false);api.request_slot(&"clear.detector",&"none");api.request_slot(&"goal.top_out",&"trim")
		_frost.handle(hook,ctx,api);return
	if _baked:
		if hook in [&"on_clear",&"on_resolve_end"]:_frost.handle(hook,ctx,api)
		return
	if hook==&"on_resolve_end" and _due<0:
		var active: int = 0;var filled: int = 0
		for c: Vector3i in CandyCells.cells(api):
			if api.layer_of(c)==_height-1:active+=1;filled+=1 if api.fills_layer_at(c) else 0
		if active>0 and filled*1000>=active*_coverage:
			_due=api.time_ms()+maxi(0,int(api.param(&"bake_warn_ms",2000)));api.emit(&"bake_warning",{"due_ms":_due,"height":_height})
	if hook==&"on_tick" and _due>=0 and api.time_ms()>=_due:
		_baked=true
		for c: Vector3i in CandyCells.cells(api,true):
			var icing: bool = api.kind_at(c)==api.kind_of(&"icing_dollop")
			var uid: int = int(api.record_at(c).get("piece_instance_id",0))
			api.set_cell(c,api.kind_of(&"frosting") if icing else api.kind_of(&"sponge"),0,uid)
			api.set_status(c,{"status_id":29 if icing else 21,"frosting_layers":int(api.param(&"frost_layers",2)) if icing else 0,"anchored":not icing,"fixed":not icing,"clear_protected":true})
		var stage: Dictionary = api.param(&"stage2",{})
		api.goal_metric(&"baked",1);api.request_goal(stage.get("goal",{"type":"bonk_boss","bonks_needed":3}))
		api.request_slot(&"clear.enabled",true)
		for key: String in ["clear.detector","clear.collapse","goal.top_out","goal.warnings_max"]:
			if stage.has(key):api.request_slot(StringName(key),StringName(stage[key]) if stage[key] is String else int(stage[key]))
		api.emit(&"bake",{"stage":2})
func snapshot() -> Dictionary:return {"baked":_baked,"due":_due,"height":_height,"coverage":_coverage,"frost":_frost.snapshot()}
