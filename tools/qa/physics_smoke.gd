extends SceneTree
## Native Jolt verification: real contacts/settles, drops, state transitions and all props.
var _failures: Array[String]=[]
func _initialize() -> void:
	_run.call_deferred()
func _assert(value: bool, message: String) -> void:
	if not value:_failures.append(message);push_error(message)
func _frames(count: int) -> void:
	for i: int in count:await physics_frame
func _challenge(variant: String, config: Dictionary = {}) -> WtPhysicsChallenge:
	var game:=WtPhysicsChallenge.new();config=config.duplicate(true)
	config["variant"]=variant;config["settings"]={"master_volume":0.0};game.setup(config);root.add_child(game);return game
func _run() -> void:
	_assert(str(ProjectSettings.get_setting("physics/3d/physics_engine"))=="Jolt Physics","Jolt backend must be selected")
	for variant: String in WtPhysicsChallenge.VARIANTS:
		var game: WtPhysicsChallenge=_challenge(variant)
		await _frames(8)
		_assert(is_instance_valid(game._controlled),variant+" must spawn a real rigid body")
		_assert(game._controlled.mass==game._controlled.get_meta("offsets").size(),variant+" mass is proportional to cube count")
		var colliders: int=0
		for child: Node in game._controlled.get_children():
			if child is CollisionShape3D:colliders+=1
		_assert(colliders==game._controlled.get_meta("offsets").size(),variant+" compound collisions match actual shape")
		if variant=="seesaw":_assert(game.get_node_or_null("ActualSeesawHinge") is HingeJoint3D,"Seesaw must have a real hinge")
		if variant=="domino_chain":_assert(game._bell is Area3D,"Domino bell must detect bodies")
		if variant=="moving_platform":_assert(game._moving is AnimatableBody3D,"Moving platform must move colliders")
		game.queue_free();await _frames(3)
	var race: WtPhysicsChallenge=_challenge("tower_race",{"height_target":.8})
	await _frames(8);race.command("hard_drop")
	for i: int in 480:
		if race._done:break
		await physics_frame
	_assert(race._pieces>=1,"Hard-dropped piece must really contact and settle")
	_assert(race._done and race._drops==0,"Held height target must produce a real race win")
	print("PHYSICS_SMOKE race height=",race._height," elapsed=",race._time)
	race.queue_free();await _frames(3)
	var balance: WtPhysicsChallenge=_challenge("balance")
	await _frames(8);balance._controlled.position.x=12;balance.command("hard_drop")
	await _frames(90)
	_assert(balance._drops==1 and balance._done,"A real off-platform fall ends Balance on the first drop")
	balance.queue_free();await _frames(3)
	var drops: WtPhysicsChallenge=_challenge("tower_race",{"height_target":100.0})
	for i: int in 4:
		await _frames(5);drops._controlled.position=Vector3(12,-4,0);await _frames(5)
	_assert(drops._drops==4 and drops._done,"Fourth physical drop with allowance three loses")
	drops.queue_free();await _frames(3)
	var budget: WtPhysicsChallenge=_challenge("tower_race",{"height_target":100.0})
	await _frames(8)
	for i: int in 55:
		var cells: Array[Vector3i]=[Vector3i.ZERO]
		var body: RigidBody3D=budget._make_body(cells,1);body.position=Vector3((i%8)*1.1,5+(i/8)*.1,0);body.set_meta("settled",true)
	await _frames(3)
	_assert(int(budget.snapshot().active_bodies)<=40,"Active piece bodies respect the forty-body budget")
	budget.queue_free();await _frames(3)
	print("PHYSICS_SMOKE: variants=13 real_contacts=true drop_limit=true freeze_budget=true failures=",_failures.size())
	quit(0 if _failures.is_empty() else 1)
