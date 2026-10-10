class_name WtCraneTower extends WtPhysicsChallenge
## MG5: independent native Jolt board, shared shapes/contact/settle budget and live Beehave.
## Physics boards share seeds/posted results; they never claim deterministic lockstep hashes.
signal attack_requested(attack: Dictionary)
signal event_emitted(event: Dictionary)
const MINIGAME_ID: String = "mg05"
const AUTHOR_ID: String = "MG5"
var _swing_phase: float = 0.0
var _swing_period: float = 2.4
var _swing_range: float = 3.25
var _hanging: bool = false
var _hanging_y: float = 10.5
var _next_ribbon: int = 1
var _gust_until: float = 0.0
var _attacks: Array[Dictionary] = []
var _rank: int = 1
var _players: int = 2
var _last_result: Dictionary = {}
var _received_tokens: Dictionary = {}
var _player_id: String = "local"
var _target_id: String = ""
var _attack_sequence: int = 0
var _hook: Node3D
var _rope: MeshInstance3D
var _crane_warning: MeshInstance3D
var _running: bool = true
var _paused_freezes: Dictionary = {}

func setup(config: Dictionary = {}) -> void:
	var source: Dictionary=config.duplicate(true)
	source["variant"]="tower_race";source["height_target"]=float(config.get("height_target",8.0))
	source["time_limit"]=float(config.get("time_limit",120.0));source["drops_allowed"]=int(config.get("drops_allowed",3))
	_swing_period=clampf(float(config.get("swing_period",2.4)),1.5,4.0)
	_rank=maxi(1,int(config.get("rank",1)));_players=clampi(int(config.get("players",2)),2,4)
	_running=bool(config.get("running",true))
	_player_id=str(config.get("player_id","local"));_target_id=str(config.get("target_id",""))
	super.setup(source)

func _ready() -> void:
	if _config.is_empty():setup()
	super._ready()
	set_running(_running)

func _build_platform() -> void:
	super._build_platform()
	var wood:=Color("#B69A74");var steel:=Color("#82999B")
	_add_box(self,Vector3(-4.3,8.75,-2.5),Vector3(.35,17.5,.35),wood,false)
	_add_box(self,Vector3(0,17.2,-2.5),Vector3(9.5,.3,.35),wood,false)
	_hook=Node3D.new();_hook.name="SwingingCraneHook";add_child(_hook)
	var ring:=TorusMesh.new();ring.inner_radius=.12;ring.outer_radius=.19;ring.rings=16;ring.ring_segments=6
	var hook_mesh:=_mesh(_hook,ring,Vector3.ZERO,steel);hook_mesh.rotation.x=PI*.5
	var rope_mesh:=CylinderMesh.new();rope_mesh.top_radius=.022;rope_mesh.bottom_radius=.022;rope_mesh.height=1;rope_mesh.radial_segments=7
	_rope=_mesh(self,rope_mesh,Vector3.ZERO,Color("#D6C5A1"));_rope.name="CraneSuspensionRope"
	_crane_warning=_add_box(self,Vector3(0,17.5,-2.5),Vector3(9.5,.06,.4),Color("#E9A569"),false)
	_crane_warning.visible=false
	for i: int in 4:
		_add_box(self,Vector3(-2.8,(i+1)*2,-2.55),Vector3(.45,.05,.045),Color("#DABF7F"),false)

func _spawn_piece() -> void:
	super._spawn_piece()
	_hanging=true;_hanging_y=_controlled.position.y;_controlled.freeze=true
	_controlled.gravity_scale=0;_control_descent(0)
	event_emitted.emit({"kind":"crane_piece","hanging":true})

func _control_descent(delta: float) -> void:
	if not is_instance_valid(_controlled) or not _hanging:return
	var speed: float=1.3 if _time<_gust_until else 1.0
	_swing_phase+=delta*TAU/_swing_period*speed
	_controlled.position=Vector3(sin(_swing_phase)*_swing_range,_hanging_y,0)
	_controlled.linear_velocity=Vector3.ZERO;_controlled.angular_velocity=Vector3.ZERO
	_hook.position=Vector3(_controlled.position.x,_body_top(_controlled)+.65,0)
	var length: float=maxf(.25,17.2-_hook.position.y)
	_rope.position=Vector3(_hook.position.x,_hook.position.y+length*.5,0)
	_rope.scale=Vector3(1,length,1)

func command(action: String, value: Variant = null) -> void:
	if action in ["back","view"]:super.command(action,value);return
	if _done or not _running:return
	if action=="spin" and _hanging and is_instance_valid(_controlled):
		_controlled.rotate_y(deg_to_rad(90*int(value)));_audio.cue(&"rotate")
	elif action in ["tap","release","hard_drop"] and _hanging and is_instance_valid(_controlled):
		_hanging=false;_controlled.freeze=false;_controlled.gravity_scale=1
		_controlled.set_meta("controlled",false);_controlled.linear_velocity=Vector3.ZERO
		_released_time=0;_still_time=0;_audio.cue(&"drop")
		event_emitted.emit({"kind":"crane_released","x":_controlled.position.x})

func submit(command_data: Variant) -> bool:
	var cmd_dict: Dictionary={}
	if command_data is SimCommand:
		cmd_dict={"kind":String(command_data.kind),"args":command_data.args}
	elif command_data is Dictionary:
		cmd_dict=command_data
	else:return false
	var kind: String=str(cmd_dict.get("kind",cmd_dict.get("action","")))
	var args: Array=cmd_dict.get("args",[])
	match kind:
		"spin","rotate","mg_rotate":
			var axis: int=int(args[0]) if args.size()>=2 else int(cmd_dict.get("axis",1))
			if kind=="mg_rotate" and axis!=1:return false
			command("spin",int(args[1]) if args.size()>=2 else int(cmd_dict.get("direction",1)));return true
		"tap","release","hard_drop","drop","mg_drop":command("tap");return true
		"view":command("view",int(cmd_dict.get("direction",1)));return true
		"mg_receive_attack","attack":return apply_attack(args[0] if not args.is_empty() else cmd_dict.get("attack",command))
		"mg_target":_target_id=str(args[0]) if not args.is_empty() else str(cmd_dict.get("target",""));return true
		"mg_send":return false # Height ribbons automatically send their earned Gust.
		"standing":
			_rank=maxi(1,int(cmd_dict.get("rank",1)));_players=clampi(int(cmd_dict.get("players",2)),2,4);return true
		"pause":set_running(not bool(cmd_dict.get("paused",true)));return true
	return false

func queue_command(cmd: SimCommand) -> void:
	submit(cmd)

func apply_attack(attack: Dictionary) -> bool:
	if _done or str(attack.get("effect",attack.get("id",attack.get("kind","gust")))) not in ["gust","Gust"]:return false
	var token: String=str(attack.get("token",""))
	if not token.is_empty() and _received_tokens.has(token):return false
	if not token.is_empty():_received_tokens[token]=true
	var data: Dictionary=attack.get("data",{})
	var duration: float=clampf(float(data.get("duration_ms",attack.get("duration_ms",8000)))/1000.0,0.1,8.0)
	_attacks.append({"starts":_time+1.0,"duration":duration,"token":token,"sender":str(attack.get("sender",""))})
	_crane_warning.visible=true;_audio.cue(&"warning");_mascot.react(&"exclaim",1)
	event_emitted.emit({"kind":"gust_warning","warning_ms":1000,"duration_ms":int(duration*1000),"token":token})
	return true

func _world_rules(delta: float) -> void:
	super._world_rules(delta)
	if _done:return
	for i: int in range(_attacks.size()-1,-1,-1):
		if _time>=float(_attacks[i].starts):
			_gust_until=maxf(_gust_until,_time+float(_attacks[i].duration));_attacks.remove_at(i)
			_audio.cue(&"wind");event_emitted.emit({"kind":"gust_active","speed_multiplier":1.3})
	_crane_warning.visible=not _attacks.is_empty()
	if _time>=_limit:_finish(false)

func _measure_height() -> void:
	super._measure_height()
	while _height>=_next_ribbon*2.0 and not _done:
		var duration_ms: int=4000 if _rank==1 and _players>=3 else 8000
		var attack: Dictionary={"token":_player_id+"_crane_"+str(_attack_sequence),"effect":"gust","data":{"duration_ms":duration_ms},"sender":_player_id,"target":_target_id,"warn_ms":1000,"ribbon":_next_ribbon,"height":_next_ribbon*2.0}
		_attack_sequence+=1
		_next_ribbon+=1;attack_requested.emit(attack)
		event_emitted.emit({"kind":"height_ribbon","height":attack.height})

func _check_goal(delta: float) -> void:
	if _done:return
	_hold=_hold+delta if _height>=_target else 0.0
	if _hold>=float(_config.get("hold_seconds",3.0)):_finish(true)

func _finish(won: bool) -> void:
	if _done:return
	_done=true;_last_result={"status":"won" if won else ("time_cap" if _time>=_limit else "lost"),"score":_height,"progress_milli":int(get_progress()*1000),"standing":get_progress(),"elapsed_ms":int(_time*1000),"ghost":false,"id":MINIGAME_ID,"variant":MINIGAME_ID,"won":won,"progress":get_progress(),"height":snappedf(_height,.01),"pieces":_pieces,"drops":_drops,"elapsed":_time,"ms":int(_time*1000)}
	_audio.cue(&"win" if won else &"lose");_mascot.react(&"heart" if won else &"gloom",3)
	_hud.text=("Tower complete" if won else "Round complete")+"  ·  Crane Tower  ·  Height %.1f  ·  Pieces %s"%[_height,_pieces]
	finished.emit(_last_result.duplicate(true));event_emitted.emit({"kind":"result","result":_last_result.duplicate(true)})
	print("CRANE_RESULT: ",JSON.stringify(_last_result))

func result() -> Dictionary:
	return _last_result.duplicate(true)

func get_progress() -> float:
	return clampf(_height/maxf(.1,_target),0.0,1.0)

func snapshot() -> Dictionary:
	var state: Dictionary=super.snapshot()
	state.merge({"minigame_id":AUTHOR_ID,"phase":"finished" if _done else "playing","elapsed_ms":int(_time*1000),"duration_ms":int(_limit*1000),"score":_height,"progress_milli":int(get_progress()*1000),"standing_metric":"race_progress","standing":get_progress(),"board":{"kind":"physics","bodies":_body_snapshot()},"piece":{"hanging":_hanging},"view":_view,"send":{"effect":"gust","automatic":true,"target":_target_id,"ribbons":_next_ribbon-1},"attacks":_attacks.duplicate(true),"result":result(),"id":MINIGAME_ID,"variant":MINIGAME_ID,"progress":get_progress(),"height_target":_target,"hold":_hold,"hold_required":float(_config.get("hold_seconds",3.0)),"drops_allowed":int(_config.get("drops_allowed",3)),"crane_x":_controlled.position.x if _hanging and is_instance_valid(_controlled) else 0.0,"hanging":_hanging,"attack_warning_ms":int(maxf(0.0,float(_attacks[0].starts)-_time)*1000) if not _attacks.is_empty() else 0,"gust_remaining_ms":int(maxf(0.0,_gust_until-_time)*1000),"won":bool(_last_result.get("won",false)),"physics_board":true,"lockstep_deterministic":false,"running":_running},true)
	return state

func _body_snapshot() -> Array[Dictionary]:
	var bodies: Array[Dictionary]=[]
	for body: RigidBody3D in _bodies:
		bodies.append({"position":body.position,"basis":body.basis,"offsets":body.get_meta("offsets",[]).duplicate(),"hue":int(body.get_meta("hue",1)),"settled":bool(body.get_meta("settled",false)),"frozen":body.freeze})
	return bodies

func set_running(value: bool) -> void:
	_running=value
	if _tree==null:return
	_tree.enabled=value
	if not value:
		for body: RigidBody3D in _bodies:
			if not _paused_freezes.has(body.get_instance_id()):_paused_freezes[body.get_instance_id()]=body.freeze
			body.freeze=true
	else:
		for body: RigidBody3D in _bodies:
			if _paused_freezes.has(body.get_instance_id()):body.freeze=bool(_paused_freezes[body.get_instance_id()])
		_paused_freezes.clear()

func _build_hud() -> void:
	var layer:=CanvasLayer.new();add_child(layer)
	var panel:=Control.new();panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);panel.mouse_filter=Control.MOUSE_FILTER_IGNORE;layer.add_child(panel)
	_hud=Label.new();_hud.position=Vector2(20,18);_hud.size.x=maxf(280,get_viewport().get_visible_rect().size.x-40);_hud.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	_hud.add_theme_font_size_override("font_size",22);_hud.add_theme_color_override("font_color",Color("#334754"));panel.add_child(_hud)
	_hint=Label.new();_hint.position=Vector2(20,82);_hint.size.x=_hud.size.x;_hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	_hint.text="Turn Q/E  ·  Tap / Space to release  ·  View Z/C  ·  Hold the height line for 3 seconds"
	_hint.add_theme_font_size_override("font_size",15);_hint.add_theme_color_override("font_color",Color("#4F6670"));panel.add_child(_hint)
	var controls:=HBoxContainer.new();controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);controls.offset_top=-72;controls.offset_left=16;controls.offset_right=-16;controls.add_theme_constant_override("separation",8);panel.add_child(controls)
	for action: Array in [["Turn left","spin",-1],["Turn right","spin",1],["Release","tap",null],["View","view",1],["Back","back",null]]:
		var button:=Button.new();button.text=action[0];button.custom_minimum_size=Vector2(48,56);button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		button.pressed.connect(command.bind(action[1],action[2]));controls.add_child(button)

func _update_hud() -> void:
	if _done:return
	_hud.text="Crane Tower  ·  Height %.1f / %.0f  ·  Hold %.1f / 3s  ·  Drops %s / %s  ·  %ss"%[_height,_target,_hold,_drops,int(_config.get("drops_allowed",3)),maxi(0,int(_limit-_time))]
	if not _attacks.is_empty():_hint.text="Gust incoming  ·  Crane speeds up after 1 second"
	elif _time<_gust_until:_hint.text="Gust  ·  Crane swings 30% faster"
	else:_hint.text="Turn Q/E  ·  Tap / Space to release  ·  View Z/C"
	snapshot_changed.emit(snapshot())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:command("back")
			KEY_Q:command("spin",-1)
			KEY_E:command("spin",1)
			KEY_SPACE,KEY_ENTER:command("tap")
			KEY_Z:command("view",-1)
			KEY_C:command("view",1)
		get_viewport().set_input_as_handled()
