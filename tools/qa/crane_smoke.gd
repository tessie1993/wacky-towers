extends SceneTree
## Native MG5 integration: swinging, true Jolt release/contact, sustained win, warning/dedupe/send.
var failures: Array[String]=[]
var sent: Array[Dictionary]=[]
func _initialize() -> void:_run.call_deferred()
func _assert(ok: bool, message: String) -> void:
	if not ok:failures.append(message);push_error(message)
func _frames(count: int) -> void:
	for i: int in count:await physics_frame
func _game(config: Dictionary) -> WtCraneTower:
	config=config.duplicate(true);config["settings"]={"master_volume":0.0}
	var game:=WtCraneTower.new();game.setup(config);root.add_child(game);return game
func _run() -> void:
	var game: WtCraneTower=_game({"height_target":.8,"seed":917})
	await _frames(8)
	_assert(game._hanging and game._controlled.freeze,"Piece must actually hang frozen on crane")
	var x: float=game._controlled.position.x;await _frames(32)
	_assert(absf(game._controlled.position.x-x)>1.0,"Crane swings physically across x before release")
	_assert(not game.submit(SimCommand.make(&"mg_rotate",[2,1])),"Native crane hides tilt/roll")
	_assert(game.submit(SimCommand.make(&"mg_rotate",[1,1])),"Crane spin uses common minigame command")
	game.set_running(false);var elapsed: float=game._time;await _frames(10)
	_assert(is_equal_approx(game._time,elapsed),"Paused native crane stops behavior clock")
	game.set_running(true)
	# Wait until hook enters the platform footprint, then use the real release command.
	for i: int in 150:
		if absf(game._controlled.position.x)<.15:break
		await physics_frame
	game.submit(SimCommand.make(&"mg_drop"))
	_assert(not game._hanging and not game._controlled.freeze and game._controlled.gravity_scale==1,"Tap releases full native Jolt gravity")
	for i: int in 520:
		if game._done:break
		await physics_frame
	_assert(game._pieces>=1 and game._drops==0,"Released compound shape genuinely contacts and settles")
	_assert(game.result().get("status")=="won" and game._hold>=3.0,"Crane height must stay up for three seconds")
	_assert(game.snapshot().id=="mg05" and game.snapshot().minigame_id=="MG5","Native schema aligns with minigame library")
	game.queue_free();await _frames(3)
	var attacks: WtCraneTower=_game({"height_target":100,"rank":1,"players":4,"player_id":"p1"})
	attacks.attack_requested.connect(func(data: Dictionary)->void:sent.append(data))
	await _frames(8)
	var packet: Dictionary={"token":"unique-gust","effect":"gust","sender":"p2","target":"p1","data":{"duration_ms":8000},"warn_ms":1000}
	_assert(attacks.submit(SimCommand.make(&"mg_receive_attack",[packet])),"Approved incoming Gust accepted")
	_assert(not attacks.submit(SimCommand.make(&"mg_receive_attack",[packet])),"Repeated transport token must not stack the Gust")
	await _frames(55)
	_assert(attacks._gust_until==0 and attacks._crane_warning.visible,"Gust gives a full one-second visible warning")
	await _frames(10)
	_assert(attacks._gust_until>attacks._time and not attacks._crane_warning.visible,"Warned Gust becomes an eight-second speed effect")
	var phase: float=attacks._swing_phase;await _frames(6)
	_assert(absf((attacks._swing_phase-phase)-(.1*TAU/2.4*1.3))<.012,"Active Gust changes real pendulum frequency by thirty percent")
	var cells: Array[Vector3i]=[]
	for y: int in 5:cells.append(Vector3i(0,y,0))
	var fixture: RigidBody3D=attacks._make_body(cells,1);fixture.position=Vector3(0,.5,0);fixture.freeze=true;fixture.set_meta("settled",true)
	await _frames(3)
	_assert(sent.size()==2,"Each new two-cell ribbon emits exactly one Gust")
	if not sent.is_empty():_assert(sent[0].effect=="gust" and int(sent[0].data.duration_ms)==4000,"Three/four-player leader send has half duration")
	await _frames(3);_assert(sent.size()==2,"Existing height ribbons never resend")
	attacks.queue_free();await _frames(3)
	var timeout: WtCraneTower=_game({"time_limit":.2})
	await _frames(20);_assert(timeout.result().get("status")=="time_cap","Native round cap posts an explicit time-cap result")
	timeout.queue_free();await _frames(3)
	print("CRANE_SMOKE: native_jolt=true swing=true release_contact=true hold_3s=true warning=true dedupe=true leader_scale=true time_cap=true failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
