class_name MascotMoodRule extends RuleBehaviour
## F10 tidiness selects one authored prank card, with a one-second telegraph and seeded targets.
const PLUGIN_ID := &"mascot_mood"
var _locks: int = 0
var _due: int = -1
var _band: String = "happy"
var _smudges: int = 0
var _prank: String = ""
func subscribed_hooks() -> Array[StringName]:return [&"on_level_start",&"on_resolve_end",&"on_tick"]
func handle(hook: StringName,_ctx: HookContext,api: RuleApi) -> void:
	if hook==&"on_level_start":_prank=String(api.param(&"prank",""));return
	if hook==&"on_tick":
		if _due>=0 and api.time_ms()>=_due:_due=-1;_act(api)
		return
	_locks+=1
	var tidy: float = CandyCells.tidy(api)
	_band="happy" if tidy>=float(api.param(&"happy_at",0.9)) else "neutral" if tidy>=float(api.param(&"neutral_at",0.7)) else "grumpy"
	api.goal_metric(&"tidiness_milli",roundi(tidy*1000))
	api.emit(&"mascot_mood",{"mood":_band,"tidiness":tidy})
	if _band=="happy":
		var candidates: Array[Vector3i] = CandyCells.surface(api)
		if not candidates.is_empty():api.emit(&"mascot_hint",{"cell":candidates[0]})
		var every: int = int(api.param(&"happy_lick_every_locks",0))
		if every>0 and _locks%every==0:
			for c: Vector3i in CandyCells.cells(api,true):
				if CandyCells.wrong_target(api,c):api.remove_cell(c,BoardState.Cause.DAMAGE);api.emit(&"mascot_smudge_cleaned",{"cell":c});break
	elif _band=="grumpy" and _due<0 and not _prank.is_empty():
		_due=api.time_ms()+maxi(100,int(api.param(&"prank_warn_ms",1000)))
		api.emit(&"mascot_prank_warning",{"prank":_prank,"due_ms":_due})
func _act(api: RuleApi) -> void:
	match _prank:
		"hop_nudge":
			var dirs: Array[Vector3i] = [Vector3i.LEFT,Vector3i.RIGHT,Vector3i(0,0,-1),Vector3i(0,0,1)]
			api.try_translate(dirs[api.rng().randi_range(0,3)])
		"bridge_jump":api.goal_metric(&"jelly_bonus",1)
		"lick_swap":
			var colours: PackedInt32Array = api.preview_hues(1)
			var old: int = colours[0] if not colours.is_empty() else 1
			var count: int = maxi(2,api.knob_int(&"spawn.colour_count"))
			api.request_preview_hue(0,1+(old+api.rng().randi_range(0,count-2))%count)
		"smudge":
			if _smudges>=int(api.param(&"smudge_cap",2)):return
			var choices: Array[Vector3i] = []
			for c: Vector3i in CandyCells.cells(api,true):
				if CandyCells.target_hue(api,c)>0 and not CandyCells.wrong_target(api,c) and not bool(api.record_at(c).get("status",{}).get("rainbow",false)):choices.append(c)
			if not choices.is_empty():
				var c: Vector3i = MechanicsCells.pick(api,choices)
				var rec: Dictionary = api.record_at(c);var hue: int = CandyCells.target_hue(api,c)%maxi(2,api.knob_int(&"spawn.colour_count"))+1
				api.set_cell(c,api.kind_at(c),hue,int(rec.get("piece_instance_id",0)));api.set_status(c,rec.get("status",{}));_smudges+=1;api.emit(&"mascot_smudge",{"cell":c})
		"tickle_worm":
			var choices: Array[Vector3i] = []
			for c: Vector3i in CandyCells.cells(api,true):
				if api.kind_at(c)==api.kind_of(&"pest"):choices.append(c)
			if not choices.is_empty():CandyCells.status(api,MechanicsCells.pick(api,choices),{"extra_acts":1})
		"splash":
			var choices: Array[Vector3i] = []
			for c: Vector3i in CandyCells.cells(api,true):
				if api.kind_at(c)!=api.kind_of(&"goo"):continue
				for dir: Vector3i in CandyCells.FACE:
					var target: Vector3i = c+dir
					if api.kind_at(target)==api.kind_of(&"block") and not choices.has(target):choices.append(target)
			if not choices.is_empty():api.set_cell(MechanicsCells.pick(api,choices),api.kind_of(&"goo"))
		"tickle_gummy":
			var choices: Array[Vector3i] = []
			for c: Vector3i in CandyCells.cells(api,true):
				if api.kind_at(c)==api.kind_of(&"moody") and not bool(api.record_at(c).get("status",{}).get("grumpy",false)):choices.append(c)
			if not choices.is_empty():CandyCells.status(api,MechanicsCells.pick(api,choices),{"grumpy":true,"forced_grumpy":true,"fills_layer":false,"clear_protected":true})
	api.emit(&"mascot_prank",{"prank":_prank})
func snapshot() -> Dictionary:return {"locks":_locks,"due":_due,"band":_band,"smudges":_smudges,"prank":_prank}
