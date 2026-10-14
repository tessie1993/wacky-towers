extends Node
## QA core-loop playtest capture (2026-10-14). Instances the real main scene and, per level:
## 3x _start_level to sample the spawn sequence (randomness check), then plays the 4th attempt:
## scripted move/rotate on piece 1 then natural gravity (measures gravity step + lock delay),
## WtBotPlayer afterwards; on cap it stops placing well and hard-drops at spawn to reach a real fail.
## Shots (720x1280): <level>_start, _mid, _clear, _win|_fail -> production/qa/evidence/playtest-2026-10-14/
## Run: XDG_DATA_HOME=<scratch> timeout 900 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . \
##   --rendering-driver opengl3 --resolution 720x1280 res://tools/qa/playtest/core_loop_capture.tscn [-- --levels=a,b] [--fail=id]
const OUT := "res://production/qa/evidence/playtest-2026-10-14/"
const LEVELS := ["meadow_02", "ice_04", "lava_05", "underwater_03", "pirate_01", "pirate_h1", "carnival_03", "meadow_h3"]
const STEPS_PER_FRAME := 6
const BOT_CAP_MS := 300000
const WALL_CAP_MS := 60000
var _main: Node
var _log: Array = []

func _ready() -> void: _run.call_deferred()
func _frames(n: int) -> void:
	for i: int in n: await get_tree().process_frame
func _sim() -> BoardSim: return _main.get("_sim") as BoardSim
func _shot(name: String) -> String:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	img.save_png(OUT + name + ".png")
	print("PT_SHOT ", name, " ", img.get_size())
	return name + ".png"
func _tick() -> void: _main.call("_physics_process", 1.0 / 60.0)

func _run() -> void:
	var levels: Array = LEVELS
	var force_fail: Array = ["meadow_h3"]
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--levels="): levels = Array(a.trim_prefix("--levels=").split(","))
		if a.begins_with("--fail="): force_fail = Array(a.trim_prefix("--fail=").split(","))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	_main = load("res://src/app/main.tscn").instantiate()
	add_child(_main)
	await _frames(20)
	var store: Object = _main.get("_store")
	if store.call("active_profile") == null: store.call("create", "QA Playtest")
	for id: String in levels:
		var row: Dictionary = await _play(id, force_fail.has(id))
		_log.append(row)
		print("PT_ROW ", JSON.stringify(row))
	var f := FileAccess.open("res://prototypes/_capture/playtest-2026-10-14.json", FileAccess.WRITE)
	if f == null:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prototypes/_capture"))
		f = FileAccess.open("res://prototypes/_capture/playtest-2026-10-14.json", FileAccess.WRITE)
	f.store_string(JSON.stringify({"levels": _log}, "\t")); f.close()
	get_tree().quit(0)

func _start(id: String) -> void:
	_main.set("_smoke", true)        # bypass unlock gate only for this call
	_main.call("_start_level", StringName(id))
	_main.set("_smoke", false)
	_main.set_physics_process(false)

func _sequence(sim: BoardSim) -> Array:
	# Advance past countdown to the first spawn, then read current + preview.
	var guard: int = 0
	while sim.get_piece() == null and guard < 600 and sim.get_phase() != BoardSim.Phase.SELECTING:
		_tick(); guard += 1
	var seq: Array = []
	if sim.get_piece() != null: seq.append(String(sim.get_piece().shape.shape_id))
	for s: StringName in sim.preview(5): seq.append(String(s))
	return seq

func _play(id: String, fail_on_purpose: bool) -> Dictionary:
	var row: Dictionary = {"id": id, "sequences": [], "shots": [], "notes": [], "fail_on_purpose": fail_on_purpose}
	for k: int in 3:
		_start(id)
		await _frames(2)
		if _sim() == null: row.notes.append("start_level gave no sim"); return row
		row.sequences.append(_sequence(_sim()))
	_start(id)
	await _frames(25)
	var sim: BoardSim = _sim()
	row.goal = _main.get("_level").goal
	row.screen_at_start = String(_main.get("_ui").get("current_screen"))
	row.countdown_ms = sim.knobs().int_value(&"goal.countdown_ms")
	row.g0 = sim.knobs().int_value(&"fall.g0")
	row.lock_delay_ms = sim.knobs().int_value(&"fall.lock_delay_ms")
	row.limit_layer = sim.board().limit_layer()
	# Run to first spawn (countdown visible in frames along the way).
	var t: int = 0
	while sim.get_piece() == null and t < 900 and sim.get_phase() != BoardSim.Phase.SELECTING:
		_tick(); t += 1
		if t % STEPS_PER_FRAME == 0: await _frames(1)
	row.ticks_to_first_spawn = t
	await _frames(6)
	row.shots.append(await _shot(id + "_start"))
	# Piece 1: scripted move + rotate, then let gravity lock it (measures feel timings).
	var p: ActivePiece = sim.get_piece()
	if p != null:
		var before: Dictionary = {"pivot": p.pivot, "orient": p.orient}
		_main.call("_on_intent", &"move", {"delta": Vector3i(1, 0, 0)})
		_tick()
		_main.call("_on_intent", &"rotate", {"axis": "spin", "direction": 1})
		_tick()
		p = sim.get_piece()
		row.scripted = {"moved": p != null and p.pivot != before.pivot, "rotated": p != null and p.orient != before.orient}
		var ys: Array = []; var last_y: int = p.pivot.y if p != null else 0
		var spawn_tick: int = sim.get_tick(); var last_step_tick: int = spawn_tick
		var locks0: int = sim.goal_state().locks; var lock_tick: int = -1
		var n: int = 0
		while n < 3600:
			_tick(); n += 1
			if n % STEPS_PER_FRAME == 0: await _frames(1)
			if sim.goal_state().locks > locks0: lock_tick = sim.get_tick(); break
			var q: ActivePiece = sim.get_piece()
			if q != null and q.pivot.y != last_y:
				ys.append(sim.get_tick() - last_step_tick); last_step_tick = sim.get_tick(); last_y = q.pivot.y
		row.gravity_ticks_per_row = ys
		row.lock_after_land_ticks = (lock_tick - last_step_tick) if lock_tick > 0 else -1
		row.first_piece_total_ticks = (lock_tick - spawn_tick) if lock_tick > 0 else -1
	# Main loop.
	var bot := WtBotPlayer.new()
	var t0: int = Time.get_ticks_msec()
	var mid_done: bool = false; var clear_done: bool = false
	var cleared: int = sim.goal_state().layers_cleared
	var mode: String = "dump" if fail_on_purpose else "bot"
	var last_uid: int = -1; var spawn_at: int = 0
	var spawns_in_blocked: int = 0
	while true:
		sim = _sim()
		if sim == null: row.notes.append("sim vanished"); break
		if bool(_main.get("_result_shown")) or sim.get_phase() == BoardSim.Phase.ENDED: break
		if bool(_main.get("_paused")):
			row.notes.append("paused during play screen=%s" % String(_main.get("_ui").get("current_screen")))
			_main.set("_paused", false)
		for s: int in STEPS_PER_FRAME:
			if sim.get_phase() == BoardSim.Phase.ENDED: break
			if sim.get_phase() == BoardSim.Phase.SELECTING:
				var ch: Array[Dictionary] = sim.kit_choices()
				if not ch.is_empty(): _main.call("_on_intent", &"pick_shape", {"shape_id": String(ch[0].shape_id)})
			elif mode == "bot": bot.update(sim)
			elif sim.get_piece() != null and sim.get_tick() - spawn_at > 20:
				sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
			_tick()
			if sim.get_piece_uid() != last_uid and sim.get_piece() != null:
				last_uid = sim.get_piece_uid(); spawn_at = sim.get_tick()
		if not mid_done and sim.goal_state().locks >= 5 and sim.get_piece() != null and sim.get_tick() - spawn_at in range(15, 60):
			mid_done = true
			await _frames(1)
			row.shots.append(await _shot(id + "_mid"))
			row.mid_hud = _main.call("_hud_snapshot").get("next_piece", "")
		if sim.goal_state().layers_cleared > cleared:
			cleared = sim.goal_state().layers_cleared
			if not clear_done:
				clear_done = true
				await _frames(4)
				row.shots.append(await _shot(id + "_clear"))
				row.clear_at_lock = sim.goal_state().locks
		var over: bool = sim.goal_state().level_ms > BOT_CAP_MS or Time.get_ticks_msec() - t0 > WALL_CAP_MS
		if over and mode == "bot":
			mode = "dump"; row.notes.append("bot cap hit at %ds/L%d cleared=%d; switching to drop-at-spawn to reach a real fail" % [sim.goal_state().level_ms / 1000, sim.goal_state().locks, cleared])
			t0 = Time.get_ticks_msec()
		elif over and mode == "dump":
			row.notes.append("no fail reached by dumping (top_out=%s); FORCED LOST" % str(sim.knobs().value(&"goal.top_out")))
			sim.call("_finish", GoalState.RESULT_LOST, &"qa_forced"); _tick(); break
		await _frames(1)
	sim = _sim()
	var r: LevelResult = sim.result() if sim != null else null
	row.outcome = ("won" if r.is_won() else "lost") if r != null else "none"
	row.mode_at_end = mode
	if sim != null:
		var gs: GoalState = sim.goal_state()
		row.final = {"level_ms": gs.level_ms, "locks": gs.locks, "layers": gs.layers_cleared, "warnings": gs.warnings_used, "trimmed": gs.cells_trimmed, "stars": r.stars if r != null else 0}
	var w: int = Time.get_ticks_msec()
	while String(_main.get("_ui").get("current_screen")) != "results" and Time.get_ticks_msec() - w < 8000:
		var b: Button = _find_skip(_main.get("_ui"))
		if b != null: b.pressed.emit()
		await _frames(2)
	await get_tree().create_timer(0.8).timeout
	row.end_screen = String(_main.get("_ui").get("current_screen"))
	row.shots.append(await _shot(id + ("_win" if row.outcome == "won" else "_fail")))
	if not clear_done: row.notes.append("no layer clear happened -> no _clear shot")
	if not mid_done: row.notes.append("no mid shot (<5 locks)")
	return row

func _find_skip(node: Node) -> Button:
	for c: Node in node.get_children():
		if c is Button and (c as Button).text.strip_edges() == "→" and (c as Button).is_visible_in_tree(): return c
		var f: Button = _find_skip(c)
		if f != null: return f
	return null
