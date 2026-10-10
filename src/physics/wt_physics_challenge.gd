class_name WtPhysicsChallenge extends Node3D
## Independent real Jolt challenge. Grid BoardSim is never approximated by physics.
signal return_requested
signal finished(result: Dictionary)
signal snapshot_changed(snapshot: Dictionary)

const VARIANTS := {
	"tower_race":"Tower Race", "grid_settle":"Grid Settle", "balance":"Balance",
	"bridge_builder":"Bridge Builder", "seesaw":"Seesaw", "bowl_fill":"Bowl Fill",
	"windy_tower":"Windy Tower", "meteor_shower":"Meteor Shower", "tallest_in_time":"Tallest in Time",
	"gentle_drop":"Gentle Drop", "moving_platform":"Moving Platform", "domino_chain":"Domino Chain", "reach_out":"Reach Out"}
const SOURCE: String = "res://design/gdd/physics-mode.md"
var variant: String = "tower_race"
var _config: Dictionary = {}
var _built: bool = false
var _bank: ShapeBank
var _choices: Array[ShapeDef] = []
var _rng := RandomNumberGenerator.new()
var _art: ArtSet
var _palette: PaletteTable
var _camera: Camera3D
var _view: int = 0
var _audio: WtAudio
var _bodies: Array[RigidBody3D] = []
var _controlled: RigidBody3D
var _platform: PhysicsBody3D
var _plank: RigidBody3D
var _moving: AnimatableBody3D
var _bell: Area3D
var _mascot: WtToyActor
var _ghost: MultiMeshInstance3D
var _tree: BeehaveTree
var _hud: Label
var _hint: Label
var _time: float = 0.0
var _pieces: int = 0
var _drops: int = 0
var _height: float = 0.0
var _hold: float = 0.0
var _tilt_time: float = 0.0
var _last_meteor: float = -1.0
var _soft: bool = false
var _hard: bool = false
var _move_remaining: float = 0.0
var _move_goal: Vector3
var _released_time: float = 0.0
var _still_time: float = 0.0
var _done: bool = false
var _chain_started: bool = false
var _target: float = 8.0
var _limit: float = 90.0
var _bridge_walking: bool = false
var _ray_mask: int = 1
var _settings: Dictionary = {}
var _wind_flag: Node3D
var _flag_target: Vector3 = Vector3(4.4,2.2,0)
var _probe_auto: bool = false
var _next_probe_drop: float = 1.0


func setup(config: Dictionary = {}) -> void:
	_config=config.duplicate(true)
	variant=str(config.get("variant","tower_race"))
	if not VARIANTS.has(variant):variant="tower_race"
	_settings=config.get("settings",{}).duplicate(true)
	_target=float(config.get("height_target",2.0 if variant=="bowl_fill" else 8.0))
	_limit=float(config.get("time_limit",60.0 if variant=="meteor_shower" else 90.0))
	_rng.seed=int(config.get("seed",917))
	if is_inside_tree():_build()


func _ready() -> void:
	if _config.is_empty():
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--physics-variant="):variant=arg.trim_prefix("--physics-variant=")
		_probe_auto=OS.get_cmdline_user_args().has("--physics-probe")
	_build()


func _build() -> void:
	if _built:return
	_built=true
	_bank=load("res://assets/data/shapes/shape_bank.tres") as ShapeBank
	for shape: ShapeDef in _bank.shapes:
		if shape.cube_count>=3 and shape.cube_count<=5 and shape.family in [&"tetromino",&"flat"]:_choices.append(shape)
	if _choices.is_empty():
		for shape: ShapeDef in _bank.shapes:
			if shape.cube_count==4:_choices.append(shape)
	_art=ArtSet.new(&"candy_toy")
	_palette=PaletteTable.from_dict(JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/palettes/meadow.json")))
	_audio=WtAudio.new();add_child(_audio);_audio.setup(_settings);_audio.start_music(&"meadow")
	_light_world();_build_platform();_build_camera();_build_hud();_build_ghost();_build_behaviour()
	_mascot=WtToyActor.new();_mascot.name="PhysicsPip";add_child(_mascot);_mascot.setup(&"pip")
	_mascot.position=Vector3(-4.6,0,1.1);_mascot.scale=Vector3.ONE*1.25
	print("PHYSICS_CHALLENGE: variant=",variant," backend=",ProjectSettings.get_setting("physics/3d/physics_engine")," compound_body_per_piece=true beehave=true")


func _build_behaviour() -> void:
	_tree=BeehaveTree.new();_tree.name="JoltChallengeBehaviour";_tree.actor=self
	var selector:=SelectorReactiveComposite.new();selector.name="ChallengeState"
	for phase: StringName in [&"finished",&"released",&"controlled",&"spawn"]:
		var sequence:=SequenceComposite.new();sequence.name=str(phase).capitalize()
		var condition:=WtPhysicsCondition.new();condition.phase=phase;condition.name="Is_"+str(phase)
		var action:=WtPhysicsAction.new();action.phase=phase;action.name="Advance_"+str(phase)
		sequence.add_child(condition);sequence.add_child(action);selector.add_child(sequence)
	_tree.add_child(selector);add_child(_tree)


func behaviour_phase() -> StringName:
	if _done:return &"finished"
	if not is_instance_valid(_controlled):return &"spawn"
	return &"controlled" if bool(_controlled.get_meta("controlled",false)) else &"released"


func physics_behaviour(phase: StringName, delta: float) -> void:
	if phase==&"finished":return
	_time+=delta
	_world_rules(delta)
	if _done:return
	if phase==&"spawn":_spawn_piece()
	elif phase==&"controlled":_control_descent(delta)
	elif phase==&"released":_observe_settle(delta)
	_measure_height();_freeze_budget();_update_ghost();_update_hud();_check_goal(delta)
	if _probe_auto and _time>=_next_probe_drop and phase==&"controlled":
		_hard=true;_next_probe_drop=_time+4.5


func _light_world() -> void:
	var environment:=Environment.new();environment.background_mode=Environment.BG_COLOR
	environment.background_color=Color("#CFE1E2");environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color=Color("#E1E8EF");environment.ambient_light_energy=.35
	var world:=WorldEnvironment.new();world.environment=environment;add_child(world)
	var key:=DirectionalLight3D.new();key.rotation_degrees=Vector3(-55,-30,0);key.light_energy=.65
	key.light_color=Color("#FFF1D5");key.shadow_enabled=true;key.directional_shadow_max_distance=65;add_child(key)
	var fill:=DirectionalLight3D.new();fill.rotation_degrees=Vector3(-30,145,0);fill.light_energy=.12;add_child(fill)


func _build_platform() -> void:
	match variant:
		"bridge_builder":
			_platform=_static_box(Vector3(-3.25,-.4,0),Vector3(3,.8,4),Color("#9CAA87"))
			_static_box(Vector3(3.25,-.4,0),Vector3(3,.8,4),Color("#9CAA87"))
		"seesaw":
			var pivot:=StaticBody3D.new();pivot.name="Pivot";add_child(pivot)
			_plank=RigidBody3D.new();_plank.name="PivotingPlank";_plank.mass=6;_plank.position=Vector3(0,-.18,0)
			_plank.angular_damp=.8;_plank.linear_damp=.6;add_child(_plank)
			_add_box(_plank,Vector3.ZERO,Vector3(6,.36,3.5),Color("#BFA987"),true)
			var hinge:=HingeJoint3D.new();hinge.name="ActualSeesawHinge";add_child(hinge)
			hinge.node_a=pivot.get_path();hinge.node_b=_plank.get_path()
			_platform=_plank
		"moving_platform":
			_moving=AnimatableBody3D.new();_moving.name="SlidingPlatform";_moving.position.y=-.25;add_child(_moving)
			_add_box(_moving,Vector3.ZERO,Vector3(5,.5,4),Color("#9CAA87"),true);_platform=_moving
		_:
			var footprint:=Vector3(2.4,.6,2.4) if variant=="balance" else Vector3(5,.6,5)
			if variant in ["domino_chain","bridge_builder"]:footprint=Vector3(8,.6,3)
			_platform=_static_box(Vector3(0,-.3,0),footprint,Color("#9CAA87"))
	if variant=="bowl_fill":
		for x: float in [-2.65,2.65]:_static_box(Vector3(x,.9,0),Vector3(.3,2.4,5.6),Color("#B4B09A"))
		for z: float in [-2.65,2.65]:_static_box(Vector3(0,.9,z),Vector3(5.6,2.4,.3),Color("#B4B09A"))
	if variant=="domino_chain":
		_bell=Area3D.new();_bell.name="RingableBell";_bell.position=Vector3(4.15,.75,0);_bell.collision_mask=1;add_child(_bell)
		var shape:=CollisionShape3D.new();var sphere:=SphereShape3D.new();sphere.radius=.46;shape.shape=sphere;_bell.add_child(shape)
		var mesh:=SphereMesh.new();mesh.radius=.46;mesh.height=.66;_mesh(_bell,mesh,Vector3.ZERO,Color("#C1AA79"))
		_bell.body_entered.connect(_ring_bell)
	if variant=="reach_out":
		_static_box(_flag_target+Vector3(0,-.6,0),Vector3(.08,1.3,.08),Color("#99856C"))
		_add_box(self,_flag_target,Vector3(.7,.4,.05),Color("#AA99B9"),false)
	if variant=="windy_tower":
		_wind_flag=Node3D.new();_wind_flag.position=Vector3(-3.2,.5,0);add_child(_wind_flag)
		_add_box(_wind_flag,Vector3(0,.45,0),Vector3(.05,.9,.05),Color("#99856C"),false)
		_add_box(_wind_flag,Vector3(.32,.77,0),Vector3(.6,.3,.035),Color("#B4A6BC"),false)
	if variant not in ["balance","domino_chain","bridge_builder","tallest_in_time","meteor_shower","reach_out"]:
		var mesh:=ImmediateMesh.new();mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		for v: Vector3 in [Vector3(-3,_target,-2.7),Vector3(3,_target,-2.7),Vector3(3,_target,-2.7),Vector3(3,_target,2.7)]:mesh.surface_add_vertex(v)
		mesh.surface_end();_mesh(self,mesh,Vector3.ZERO,Color("#B39966"))


func _build_camera() -> void:
	_camera=Camera3D.new();_camera.projection=Camera3D.PROJECTION_ORTHOGONAL;_camera.keep_aspect=Camera3D.KEEP_HEIGHT
	_camera.size=21 if get_viewport().get_visible_rect().size.aspect()>1 else 29
	_camera.current=true;_camera.far=140;add_child(_camera);_update_camera()


func _update_camera() -> void:
	var target:=Vector3(0,5,0);var yaw: float=deg_to_rad(45+_view*30)
	_camera.position=target+Vector3(sin(yaw)*.85,.53,cos(yaw)*.85)*40;_camera.look_at(target)


func _build_ghost() -> void:
	var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.instance_count=64;mm.mesh=BoxMesh.new()
	_ghost=MultiMeshInstance3D.new();_ghost.name="RaycastLandingGhost";_ghost.multimesh=mm;add_child(_ghost)
	var mat:=StandardMaterial3D.new();mat.albedo_color=Color(.94,.86,.65,.22);mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;_ghost.material_override=mat;mm.visible_instance_count=0


func _spawn_piece() -> void:
	var offsets: Array[Vector3i]=[]
	var hue: int=1+_pieces%10
	if variant=="domino_chain":
		for y: int in 4:offsets.append(Vector3i(0,y,0))
	else:
		var shape: ShapeDef=_choices[_rng.randi_range(0,_choices.size()-1)]
		offsets=shape.offsets(shape.spawn_orient).duplicate();hue=shape.hue_id
	var body: RigidBody3D=_make_body(offsets,hue)
	body.name="CompoundPiece_%s"%(_pieces+1);body.set_meta("controlled",true);body.gravity_scale=0
	var lo:=Vector3i.ZERO;var hi:=Vector3i.ZERO
	for cell: Vector3i in offsets:lo=lo.min(cell);hi=hi.max(cell)
	body.position=Vector3(-(lo.x+hi.x)*.5,maxf(10.5,_height+4.0)-(lo.y+.5),-(lo.z+hi.z)*.5)
	if variant=="domino_chain":body.position.x=-2.8
	if _moving!=null:body.position.x+=_moving.position.x
	_controlled=body;_hard=false;_released_time=0;_still_time=0;_move_remaining=0
	body.body_entered.connect(_first_contact.bind(body))


func _make_body(offsets: Array[Vector3i], hue: int) -> RigidBody3D:
	var body:=RigidBody3D.new();body.mass=maxf(1,offsets.size());body.linear_damp=.8;body.angular_damp=.9
	body.continuous_cd=true;body.contact_monitor=true;body.max_contacts_reported=16;body.collision_layer=1;body.collision_mask=1
	var material:=PhysicsMaterial.new();material.friction=.8;material.bounce=.05;body.physics_material_override=material
	body.set_meta("offsets",offsets.duplicate());body.set_meta("hue",hue);body.set_meta("settled",false);body.set_meta("dropped",false)
	var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_colors=true;mm.mesh=_art.cube_mesh();mm.instance_count=offsets.size()
	var view:=MultiMeshInstance3D.new();view.multimesh=mm
	var mat:=StandardMaterial3D.new();mat.vertex_color_use_as_albedo=true;mat.roughness=.75;view.material_override=mat;body.add_child(view)
	for i: int in offsets.size():
		mm.set_instance_transform(i,Transform3D(Basis.from_scale(Vector3.ONE*_art.cube_scale()*.98),Vector3(offsets[i])))
		mm.set_instance_color(i,_palette.color(hue))
		var shape:=CollisionShape3D.new();var cube:=BoxShape3D.new();cube.size=Vector3.ONE*.98;shape.shape=cube;shape.position=Vector3(offsets[i]);body.add_child(shape)
	add_child(body);_bodies.append(body);return body


func _control_descent(delta: float) -> void:
	if not is_instance_valid(_controlled):return
	var g: float=float(_config.get("g",1.8))
	var speed: float=g*(12.0 if _hard else (4.0 if _soft else 1.0))
	_controlled.set_meta("impact_speed",speed)
	var velocity:=Vector3(0,-speed,0)
	if _move_remaining>0:
		var remaining: float=maxf(delta,_move_remaining)
		velocity.x=(_move_goal.x-_controlled.position.x)/remaining
		velocity.z=(_move_goal.z-_controlled.position.z)/remaining
		_move_remaining=maxf(0,_move_remaining-delta)
	_controlled.linear_velocity=velocity;_controlled.angular_velocity=Vector3.ZERO


func _first_contact(other: Node, body: RigidBody3D) -> void:
	if not is_instance_valid(body) or not bool(body.get_meta("controlled",false)):return
	body.set_meta("controlled",false);body.gravity_scale=1.0;_move_remaining=0
	_audio.cue(&"lock");_mascot.react(&"exclaim",.7)
	if variant=="gentle_drop" and float(body.get_meta("impact_speed",0.0))>float(_config.get("fragile_speed",6.0)):
		_count_drop(body,"fragile");return
	if variant=="reach_out" and other is PhysicsBody3D:
		var anchored: bool=other==_platform or (other is RigidBody3D and bool(other.get_meta("honey_anchored",false)))
		if anchored:
			body.freeze=true;body.set_meta("honey_anchored",true);body.set_meta("honey_anchor",other.get_instance_id());_settle(body)


func _observe_settle(delta: float) -> void:
	if not is_instance_valid(_controlled):return
	_released_time+=delta
	if _controlled.linear_velocity.length()<.2 and _controlled.angular_velocity.length()<deg_to_rad(10):_still_time+=delta
	else:_still_time=0
	if _still_time>=.4 or _released_time>=3.0:_settle(_controlled)


func _settle(body: RigidBody3D) -> void:
	if not is_instance_valid(body) or bool(body.get_meta("dropped",false)):return
	body.set_meta("settled",true);body.set_meta("controlled",false);_pieces+=1
	if variant=="grid_settle":
		var basis: Basis=body.basis.orthonormalized();var best: int=0;var best_score: float=-10
		for i: int in Orientations.COUNT:
			var candidate: Basis=_orientation_basis(i)
			var score: float=basis.x.dot(candidate.x)+basis.y.dot(candidate.y)+basis.z.dot(candidate.z)
			if score>best_score:best_score=score;best=i
		body.basis=_orientation_basis(best);body.position=Vector3(roundf(body.position.x-.5)+.5,roundf(body.position.y-.5)+.5,roundf(body.position.z-.5)+.5)
		_grid_clear_layers()
	if body==_controlled:_controlled=null
	_audio.cue(&"lock")
	print("PHYSICS_SETTLED: pieces=",_pieces," elapsed=",_released_time," still=",_still_time)


func _count_drop(body: RigidBody3D, reason: String = "fell") -> void:
	if bool(body.get_meta("dropped",false)):return
	body.set_meta("dropped",true);_drops+=1
	if body==_controlled:_controlled=null
	_bodies.erase(body);body.queue_free();_audio.cue(&"lose");_mascot.react(&"dizzy",1)
	print("PHYSICS_DROP: count=",_drops," reason=",reason)
	if _drops>int(_config.get("drops_allowed",0 if variant=="balance" else 3)):_finish(false)


func _world_rules(delta: float) -> void:
	for body: RigidBody3D in _bodies.duplicate():
		if not is_instance_valid(body):_bodies.erase(body);continue
		if body.position.y< -3:_count_drop(body)
		elif variant=="bowl_fill" and body.position.y<2.1 and (absf(body.position.x)>3.1 or absf(body.position.z)>3.1):_count_drop(body,"spill")
	if _moving!=null:_moving.position.x=sin(_time*.43)*1.8
	if _plank!=null:
		var tilt: float=rad_to_deg(acos(clampf(_plank.global_basis.y.dot(Vector3.UP),-1,1)))
		_tilt_time=_tilt_time+delta if tilt>25 else 0.0
		if _tilt_time>=2:_finish(false)
	if variant=="windy_tower":
		var gust: float=sin(_time*2.1)*3.7 if fmod(_time,7.0)>4.5 else 0.0
		_wind_flag.rotation.y=gust*.13
		for body: RigidBody3D in _bodies:
			if not body.freeze and not bool(body.get_meta("controlled",false)):body.apply_central_force(Vector3(gust*body.mass,0,0))
	if variant=="meteor_shower" and _time-_last_meteor>=3:
		_last_meteor=_time;_spawn_meteor()
	if variant=="reach_out" and _pieces>=3:
		for body: RigidBody3D in _bodies:
			if not bool(body.get_meta("honey_anchored",false)):continue
			for cell: Vector3i in body.get_meta("offsets"):
				if (body.global_transform*Vector3(cell)).distance_to(_flag_target)<.9:_finish(true)


func _measure_height() -> void:
	_height=0
	for body: RigidBody3D in _bodies:
		if bool(body.get_meta("settled",false)):_height=maxf(_height,_body_top(body))


func _body_top(body: RigidBody3D) -> float:
	var top: float=-100
	var half: float=(absf(body.basis.x.y)+absf(body.basis.y.y)+absf(body.basis.z.y))*.5
	for cell: Vector3i in body.get_meta("offsets",[]):top=maxf(top,(body.global_transform*Vector3(cell)).y+half)
	return top


func _freeze_budget() -> void:
	var active: Array[RigidBody3D]=[]
	var depth: float=3.0 if Engine.get_frames_per_second()<50 and _time>3 else 4.0
	for body: RigidBody3D in _bodies:
		if not bool(body.get_meta("settled",false)):continue
		if _body_top(body)<_height-depth:body.freeze=true
		elif not body.freeze:active.append(body)
	active.sort_custom(func(a: RigidBody3D,b: RigidBody3D)->bool:return _body_top(a)<_body_top(b))
	while active.size()>39:
		var body: RigidBody3D=active.pop_front();body.freeze=true


func _check_goal(delta: float) -> void:
	if _done:return
	match variant:
		"balance","domino_chain","reach_out":pass
		"bridge_builder":_check_bridge()
		"meteor_shower","tallest_in_time":
			if _time>=_limit:_finish(true)
		"bowl_fill":
			_hold=_hold+delta if _height>=_target and _pieces>=10 else 0.0
			if _hold>=1:_finish(true)
		_:
			_hold=_hold+delta if _height>=_target else 0.0
			if _hold>=1:_finish(true)


func _check_bridge() -> void:
	if _bridge_walking or _pieces<2:return
	var previous: float=-100
	for i: int in 21:
		var x: float=-3.3+i*.33
		var query:=PhysicsRayQueryParameters3D.create(Vector3(x,5,0),Vector3(x,-1,0),1)
		var hit: Dictionary=get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty():return
		if hit.collider is RigidBody3D and not bool(hit.collider.get_meta("settled",false)):return
		if previous> -90 and absf(previous-hit.position.y)>1.05:return
		previous=hit.position.y
	_bridge_walking=true;_mascot.position=Vector3(-3.3,maxf(.02,previous),0)
	var tween:=create_tween();tween.tween_property(_mascot,"position:x",3.3,2.8);tween.tween_callback(_finish.bind(true))


func _spawn_meteor() -> void:
	var meteor:=RigidBody3D.new();meteor.mass=2;meteor.position=Vector3(_rng.randf_range(-2.5,2.5),16,_rng.randf_range(-2.5,2.5))
	meteor.contact_monitor=true;meteor.max_contacts_reported=8;meteor.continuous_cd=true
	var shape:=CollisionShape3D.new();var sphere:=SphereShape3D.new();sphere.radius=.38;shape.shape=sphere;meteor.add_child(shape)
	var mesh:=SphereMesh.new();mesh.radius=.38;mesh.height=.76;_mesh(meteor,mesh,Vector3.ZERO,Color("#A99B92"));add_child(meteor)
	meteor.body_entered.connect(func(body: Node)->void:
		if body is RigidBody3D and body!=meteor:body.freeze=false)
	get_tree().create_timer(12).timeout.connect(func()->void:
		if is_instance_valid(meteor):meteor.queue_free())


func _ring_bell(body: Node) -> void:
	if _chain_started and _pieces>=3 and body is RigidBody3D:_finish(true)


func _grid_clear_layers() -> void:
	# Physical chunks survive a cleared layer. Removed cubes never leave invisible collision.
	var layers: Dictionary={};var world_cells: Dictionary={}
	for body: RigidBody3D in _bodies:
		if not bool(body.get_meta("settled",false)):continue
		var cells: Array[Vector3i]=[]
		for cell: Vector3i in body.get_meta("offsets"):
			var position: Vector3=body.global_transform*Vector3(cell)
			var global_cell:=Vector3i(roundi(position.x-.5),roundi(position.y-.5),roundi(position.z-.5));cells.append(global_cell)
			if global_cell.x>=-2 and global_cell.x<2 and global_cell.z>=-2 and global_cell.z<2:
				if not layers.has(global_cell.y):layers[global_cell.y]={}
				layers[global_cell.y][Vector2i(global_cell.x,global_cell.z)]=true
		world_cells[body]=cells
	var clears: Array[int]=[]
	for y: int in layers:
		if layers[y].size()==16:clears.append(y)
	if clears.is_empty():return
	for body: RigidBody3D in world_cells:
		var remaining: Array[Vector3i]=[]
		for cell: Vector3i in world_cells[body]:
			if cell.y not in clears:remaining.append(cell)
		if remaining.size()==world_cells[body].size():continue
		var hue: int=body.get_meta("hue");_bodies.erase(body);body.queue_free()
		while not remaining.is_empty():
			var connected: Array[Vector3i]=[remaining.pop_front()];var cursor: int=0
			while cursor<connected.size():
				var cell: Vector3i=connected[cursor];cursor+=1
				for dir: Vector3i in [Vector3i.LEFT,Vector3i.RIGHT,Vector3i.UP,Vector3i.DOWN,Vector3i.FORWARD,Vector3i.BACK]:
					if remaining.has(cell+dir):connected.append(cell+dir);remaining.erase(cell+dir)
			var origin: Vector3i=connected[0];var offsets: Array[Vector3i]=[]
			for cell: Vector3i in connected:offsets.append(cell-origin)
			var chunk: RigidBody3D=_make_body(offsets,hue);chunk.position=Vector3(origin)+Vector3.ONE*.5;chunk.set_meta("settled",true)
	_audio.cue(&"clear")


func _update_ghost() -> void:
	if not is_instance_valid(_controlled) or not bool(_controlled.get_meta("controlled",false)):
		_ghost.multimesh.visible_instance_count=0;return
	var cells: Array=_controlled.get_meta("offsets",[]);var shift: float=100
	for cell: Vector3i in cells:
		var p: Vector3=_controlled.global_transform*Vector3(cell)
		var query:=PhysicsRayQueryParameters3D.create(Vector3(p.x,p.y-.51,p.z),Vector3(p.x,-4,p.z),_ray_mask,[_controlled.get_rid()])
		var hit: Dictionary=get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty():shift=minf(shift,p.y-.5-hit.position.y)
	if shift>=99:_ghost.multimesh.visible_instance_count=0;return
	for i: int in mini(64,cells.size()):
		var p: Vector3=_controlled.global_transform*Vector3(cells[i]);p.y-=maxf(0,shift)
		_ghost.multimesh.set_instance_transform(i,Transform3D(_controlled.basis.scaled(Vector3.ONE*.94),p))
	_ghost.multimesh.visible_instance_count=mini(64,cells.size())


func command(action: String, value: Variant = null) -> void:
	if action=="back":return_requested.emit();return
	if action=="restart":get_tree().reload_current_scene();return
	if action=="view":_view=posmod(_view+int(value),12);_update_camera();return
	if action=="push" and variant=="domino_chain" and _pieces>=3:
		_chain_started=true
		for body: RigidBody3D in _bodies:
			if bool(body.get_meta("settled",false)):
				body.freeze=false;body.apply_impulse(Vector3(6,0,0),Vector3(0,1.4,0));break
		return
	if not is_instance_valid(_controlled) or not bool(_controlled.get_meta("controlled",false)) or _done:return
	match action:
		"move":
			var dir: Vector3i=CameraMath.screen_dir_to_world(_view,value,45,30)
			_move_goal=_controlled.position+Vector3(dir);_move_remaining=.08
		"spin","tilt":
			_controlled.rotate(Vector3.UP if action=="spin" else Vector3.RIGHT,deg_to_rad(90*int(value)))
			_audio.cue(&"rotate")
		"hard_drop":_hard=true;_audio.cue(&"drop")
		"soft_drop":_soft=bool(value)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode==KEY_SHIFT:_soft=event.pressed
		if not event.pressed or event.echo:return
		match event.keycode:
			KEY_ESCAPE:command("back")
			KEY_SPACE:command("hard_drop")
			KEY_LEFT,KEY_A:command("move",Vector2i(-1,0))
			KEY_RIGHT,KEY_D:command("move",Vector2i(1,0))
			KEY_UP,KEY_W:command("move",Vector2i(0,-1))
			KEY_DOWN,KEY_S:command("move",Vector2i(0,1))
			KEY_Q:command("spin",-1)
			KEY_E:command("spin",1)
			KEY_R:command("tilt",-1)
			KEY_F:command("tilt",1)
			KEY_Z:command("view",-1)
			KEY_C:command("view",1)
			KEY_P:command("push")
		get_viewport().set_input_as_handled()


func _finish(won: bool) -> void:
	if _done:return
	_done=true
	var result: Dictionary={"won":won,"variant":variant,"height":snappedf(_height,.01),"pieces":_pieces,"drops":_drops,"elapsed":_time}
	_audio.cue(&"win" if won else &"lose");_mascot.react(&"heart" if won else &"gloom",3)
	_hud.text=("Challenge complete" if won else "Tower tumbled")+"  ·  "+VARIANTS[variant]+"  ·  Height %.1f  ·  Pieces %s"%[_height,_pieces]
	finished.emit(result);print("PHYSICS_RESULT: ",JSON.stringify(result))


func snapshot() -> Dictionary:
	var active: int=0;var frozen: int=0
	for body: RigidBody3D in _bodies:
		if body.freeze:frozen+=1
		else:active+=1
	return {"variant":variant,"height":_height,"pieces":_pieces,"drops":_drops,"active_bodies":active,"frozen_bodies":frozen,"elapsed":_time,"done":_done,"backend":ProjectSettings.get_setting("physics/3d/physics_engine")}


func _build_hud() -> void:
	var layer:=CanvasLayer.new();add_child(layer)
	var root:=Control.new();root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);root.mouse_filter=Control.MOUSE_FILTER_IGNORE;layer.add_child(root)
	_hud=Label.new();_hud.position=Vector2(24,20);_hud.size.x=maxf(300,get_viewport().get_visible_rect().size.x-48);_hud.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;_hud.add_theme_font_size_override("font_size",22);_hud.add_theme_color_override("font_color",Color("#334754"));root.add_child(_hud)
	_hint=Label.new();_hint.position=Vector2(24,82);_hint.size.x=maxf(300,get_viewport().get_visible_rect().size.x-48);_hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;_hint.text="Move: arrows/WASD   Turn: Q/E   Flip: R/F   Drop: Space   Soft: Shift   View: Z/C"
	_hint.add_theme_font_size_override("font_size",15);_hint.add_theme_color_override("font_color",Color("#4F6670"));root.add_child(_hint)
	var controls:=HBoxContainer.new();controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);controls.offset_top=-66;controls.offset_left=16;controls.offset_right=-16;controls.add_theme_constant_override("separation",8);root.add_child(controls)
	var actions: Array=[ ["‹","move",Vector2i(-1,0)],["›","move",Vector2i(1,0)],["↑","move",Vector2i(0,-1)],["↓","move",Vector2i(0,1)],["Turn","spin",1],["Flip","tilt",1],["Drop","hard_drop",null],["View","view",1],["Back","back",null] ]
	if variant=="domino_chain":actions.insert(6,["Push","push",null])
	for action: Array in actions:
		var button:=Button.new();button.text=action[0];button.custom_minimum_size=Vector2(48,48);button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		button.pressed.connect(command.bind(action[1],action[2]));controls.add_child(button)


func _update_hud() -> void:
	if _done:return
	var allowed: int=int(_config.get("drops_allowed",0 if variant=="balance" else 3))
	_hud.text=VARIANTS[variant]+"  ·  Height %.1f  ·  Pieces %s  ·  Drops %s/%s  ·  %ss"%[_height,_pieces,_drops,allowed,int(_time)]
	snapshot_changed.emit(snapshot())


func _static_box(position: Vector3,size: Vector3,color: Color) -> StaticBody3D:
	var body:=StaticBody3D.new();body.position=position;add_child(body);_add_box(body,Vector3.ZERO,size,color,true)
	var material:=PhysicsMaterial.new();material.friction=.8;material.bounce=.05;body.physics_material_override=material;return body


func _add_box(parent: Node3D, position: Vector3,size: Vector3,color: Color,collision: bool) -> MeshInstance3D:
	var box:=BoxMesh.new();box.size=size;var view: MeshInstance3D=_mesh(parent,box,position,color)
	if collision:
		var shape:=CollisionShape3D.new();var cube:=BoxShape3D.new();cube.size=size;shape.shape=cube;shape.position=position;parent.add_child(shape)
	return view


func _mesh(parent: Node3D, mesh: Mesh,position: Vector3,color: Color) -> MeshInstance3D:
	var view:=MeshInstance3D.new();view.mesh=mesh;view.position=position
	var material:=StandardMaterial3D.new();material.albedo_color=color;material.roughness=.85;view.material_override=material;parent.add_child(view);return view


func _orientation_basis(index: int) -> Basis:
	return Basis(Vector3(Orientations.apply(index,Vector3i.RIGHT)),Vector3(Orientations.apply(index,Vector3i.UP)),Vector3(Orientations.apply(index,Vector3i.BACK)))
