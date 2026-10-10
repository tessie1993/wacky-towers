class_name SpeedBumpRule extends RuleBehaviour
## Mood-driven notches telegraph one second ahead; clears calm one notch, baseline ramps by minute.
const PLUGIN_ID := &"speed_bump"
var _base: int = 1000
var _start: int = 0
var _due: int = 0
var _warned: bool = false
var _notches: int = 0
var _cleared: bool = false
var _second: int = -1
func subscribed_hooks() -> Array[StringName]:return [&"on_level_start",&"on_tick",&"on_clear",&"on_resolve_end"]
func handle(hook: StringName,_ctx: HookContext,api: RuleApi) -> void:
	if hook==&"on_level_start":_base=api.knob_int(&"fall.g0");_start=api.time_ms();_due=_start+int(api.param(&"notch_every_s",10))*1000;return
	if hook==&"on_clear":_cleared=true;return
	if hook==&"on_resolve_end":
		if _cleared:_notches=maxi(0,_notches-1);_cleared=false;_second=-1
		return
	var grumpy: bool = CandyCells.tidy(api)<0.7
	if api.time_ms()>=_due-int(api.param(&"warn_ms",1000)) and not _warned:
		_warned=true
		if grumpy and _notches<int(api.param(&"notch_max",3)):api.emit(&"speed_bump_warning",{"notch":_notches+1,"due_ms":_due})
	if api.time_ms()>=_due:
		if grumpy:_notches=mini(int(api.param(&"notch_max",3)),_notches+1)
		elif CandyCells.tidy(api)>=0.9:_notches=maxi(0,_notches-1)
		_due=api.time_ms()+maxi(1000,int(api.param(&"notch_every_s",10))*1000);_warned=false;_second=-1
	var second: int = api.time_ms()/1000
	if second!=_second:
		_second=second
		var ramp: int = roundi(float(api.goal_config().get("ramp_per_min",0.0))*1000.0*(api.time_ms()-_start)/60000.0)
		api.request_slot(&"fall.g0",(_base+ramp)*(100+_notches*int(api.param(&"notch_pct",10)))/100)
		api.emit(&"speed_bump",{"notches":_notches})
func snapshot() -> Dictionary:return {"base":_base,"start":_start,"due":_due,"warned":_warned,"notches":_notches,"cleared":_cleared,"second":_second}
