extends SceneTree
## Drives the real composition root with a disposable profile and a solvable fixture.
var app: Node
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func _run() -> void:
	app = load("res://src/app/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_physics_process(false)
	app._store = WtProfileStore.new(MemorySaveIO.new())
	app._on_intent(&"play", {})
	_check(app._ui.current_screen == "profiles", "New player must choose a profile")
	app._on_intent(&"create_profile", {"name": "Test Builder", "badge": "cloud", "color": "sky"})
	_check(app._store.active_profile() != null, "Profile creation failed")
	_check(app._ui.current_screen == "map", "Profile creation must open map")
	app._on_intent(&"open_level", {"level_id": "meadow_01"})
	_check(app._ui.current_screen == "intro", "Unlocked level must show intro")
	app._on_intent(&"start_level", {"level_id": "meadow_01"})
	_check(app._sim != null and not app._paused, "Start level failed")
	app._on_intent(&"pause", {})
	_check(app._paused and app._ui.current_screen == "pause", "Pause must suspend simulation")
	app._on_intent(&"open_settings", {})
	app._on_intent(&"set_pref", {"key": "sfx_volume", "value": 35.0})
	_check(is_equal_approx(float(app._store.get_setting("sfx_volume", 0)), 0.35), "UI volume must normalize to saved fraction")
	app._on_intent(&"back", {})
	app._on_intent(&"resume", {})
	_check(not app._paused, "Resume must restore play")
	app._on_intent(&"retry", {})
	_check(app._sim.get_tick() == 0, "Retry must create a fresh session")
	var source: Dictionary = app._content.raw_level(&"meadow_01").duplicate(true)
	source.board = {"width": 4, "depth": 4, "h_play": 6}
	source.pieces = {"shapes": ["mono"], "fixed_list": []}
	for i: int in 16: source.pieces.fixed_list.append("mono")
	source.goal = {"type": "clear_n", "n": 1}
	source.rules = []
	source.knobs = {"goal.countdown_ms": 0, "goal.warnings_max": 0, "fall.hard_drop_grace_ms": 0, "fall.g0": 0.3}
	var parsed: LoadResult = LevelLoader.parse_level(source, app._catalog)
	for issue: ValidationIssue in parsed.issues: print(issue.message, " ", issue.path, " ", issue.code)
	_check(parsed.level != null, "Fixture failed schema validation")
	if parsed.level == null:
		quit(1)
		return
	app._begin_session(parsed.level)
	var sim: BoardSim = app._sim
	for z: int in 4:
		for x: int in 4:
			var guard: int = 0
			while sim.get_phase() != BoardSim.Phase.FALLING and guard < 120 and sim.get_phase() != BoardSim.Phase.ENDED:
				sim.step()
				guard += 1
			var piece: ActivePiece = sim.get_piece()
			if piece == null: break
			while piece.pivot.x != x:
				sim.queue_command(SimCommand.make(SimEvents.CMD_MOVE, [Vector3i(signi(x - piece.pivot.x), 0, 0)]))
				sim.step()
			while piece.pivot.z != z:
				sim.queue_command(SimCommand.make(SimEvents.CMD_MOVE, [Vector3i(0, 0, signi(z - piece.pivot.z))]))
				sim.step()
			sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
			for i: int in 3: sim.step()
	for i: int in 60:
		if sim.get_phase() != BoardSim.Phase.ENDED: sim.step()
	_check(sim.result() != null and sim.result().is_won(), "Legal moves and drops must clear fixture and win")
	app._finish_level()
	_check(app._ui.current_screen == "results", "Finished session must show results")
	_check(app._store.progress().levels.has("meadow_01"), "Winning result must save best stars")
	_check(app._store.level_open(app._content.all_levels()[1]), "First win must open next campaign level")
	app._on_intent(&"to_map", {})
	_check(app._sim == null and app._ui.current_screen == "map", "Return to map must release session")
	print("WT_APP_FLOW: ", "PASS" if failures.is_empty() else "FAIL", " failures=", failures.size())
	app.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
