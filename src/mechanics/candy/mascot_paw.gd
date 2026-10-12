class_name MascotPawRule extends RuleBehaviour
## The paw telegraphs and eats the most recently placed piece containing a wrong-flavour target.
const PLUGIN_ID := &"mascot_paw"
var _due: int = 0
var _warned: bool = false
var _target_uid: int = -1
var _eaten: int = 0
func subscribed_hooks() -> Array[StringName]:return [&"on_level_start",&"on_tick"]
func handle(hook: StringName,_ctx: HookContext,api: RuleApi) -> void:
	if hook==&"on_level_start":_due=api.time_ms()+int(api.param(&"every_s",15))*1000;return
	if api.time_ms()>=_due-int(api.param(&"warn_ms",2000)) and not _warned:
		_warned=true;_target_uid=-1
		for c: Vector3i in CandyCells.cells(api,true):
			if CandyCells.wrong_target(api,c):_target_uid=maxi(_target_uid,int(api.record_at(c).get("piece_instance_id",-1)))
		if _target_uid>=0:api.emit(&"paw_warning",{"piece_uid":_target_uid,"due_ms":_due})
	if api.time_ms()>=_due:
		var ate: bool = false
		for c: Vector3i in CandyCells.cells(api,true):
			if _target_uid>=0 and int(api.record_at(c).get("piece_instance_id",-2))==_target_uid:api.remove_cell(c,BoardState.Cause.DAMAGE);ate=true
		if ate:_eaten+=1;api.goal_metric(&"paw_eaten",_eaten);api.emit(&"paw_ate",{"piece_uid":_target_uid})
		_due=api.time_ms()+maxi(1000,int(api.param(&"every_s",15))*1000);_warned=false
func snapshot() -> Dictionary:return {"due":_due,"warned":_warned,"target_uid":_target_uid,"eaten":_eaten}
