extends Node
## QA story-campaign playthrough driver. Instances the real main scene and drives it through the same
## intents the UI buttons emit: title -> profile -> map -> biome -> (intro -> pre story -> play -> post story -> results -> next) x10.
## Progress per level: puzzle_proofs.json solver (teleports the piece to the proof pose, then a real hard-drop intent),
## else WtBotPlayer; if neither wins inside the cap the level is FORCED via BoardSim._finish(WON) and reported as such.
## Run (windowed, Xvfb): xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3 \
##   --resolution 1280x720 res://tools/qa/story_playthrough.tscn -- --biome=meadow [--tag=landscape] [--seed-prereqs]
## Isolate the save by exporting XDG_DATA_HOME to a scratch dir. Writes screenshots to
## production/qa/evidence/story-playthrough/<tag-biome>/ and a JSON log to prototypes/_capture/story/.
const STEPS_PER_FRAME := 120
const BOT_CAP_MS := 420000          ## sim-ms cap for the bot on attempt 1
const RETRY_FORCE_LOCKS := 8        ## attempt 2 forces once this many pieces are down
const WALL_CAP_MS := 45000          ## wall clock cap per attempt (bot is weak: see report)
const MAIN_SCENE := "res://src/app/main.tscn"

var _args: Dictionary = {}
var _main: Node
var _biome: String = "meadow"
var _tag: String = ""
var _dir: String = ""
var _rows: Array = []
var _notes: Array = []
var _proofs: Dictionary = {}
var _shot_index: int = 0

func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--"):
			var kv: PackedStringArray = a.substr(2).split("=", true, 1)
			_args[kv[0]] = kv[1] if kv.size() > 1 else "true"
	_biome = String(_args.get("biome", "meadow"))
	_tag = String(_args.get("tag", ""))
	var folder: String = _biome if _tag == "" else _tag + "-" + _biome
	_dir = "res://production/qa/evidence/story-playthrough/" + folder + "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_dir))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prototypes/_capture/story"))
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/campaign/puzzle_proofs.json"))
	if data is Dictionary:
		for p: Dictionary in data.get("proofs", []): _proofs[String(p.id)] = p
	_run.call_deferred()

func _log(msg: String) -> void:
	print("QA_STORY ", msg)

func _frames(n: int) -> void:
	for i: int in n: await get_tree().process_frame

func _wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout

func _shot(name: String) -> String:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	if img.get_width() > 640:
		img.resize(640, int(round(img.get_height() * 640.0 / img.get_width())), Image.INTERPOLATE_BILINEAR)
	var path: String = _dir + "%02d_%s.png" % [_shot_index, name] if name.begins_with("_") else _dir + name + ".png"
	img.save_png(path)
	return path.trim_prefix("res://")

func _ui() -> Node: return _main.get("_ui")
func _screen() -> String: return String(_ui().get("current_screen"))
func _sim() -> BoardSim: return _main.get("_sim") as BoardSim
func _intent(id: StringName, args: Dictionary = {}) -> void: _main.call("_on_intent", id, args)

func _run() -> void:
	var t0: int = Time.get_ticks_msec()
	_main = load(MAIN_SCENE).instantiate()
	add_child(_main)
	_main.set_physics_process(false)   # the driver steps the game loop itself, STEPS_PER_FRAME ticks per rendered frame
	await _frames(20)
	await _wait(0.8)
	await _shot("00_title")
	_intent(&"play")
	await _frames(5)
	await _shot("00_profiles_" + _screen())
	_intent(&"create_profile", {"name": "QA Tester", "color": "sky", "badge": "cloud"})
	await _frames(5)
	if _screen() != "map":
		_notes.append("create_profile intent with 'QA Tester' did not reach map (screen=%s); used _store.create directly" % _screen())
		_main.get("_store").create("QA Tester")
		_intent(&"open_map")
		await _frames(5)
	var store: Object = _main.get("_store")
	var content: Object = _main.get("_content")
	var order: Array = ["meadow","candy","ice","underwater","lava","forest","cave","clockwork","neon","celestial","carnival"]
	if not store.biome_open(_biome):
		# Separate per-biome invocations start from a fresh profile: seed earlier biomes as a save fixture (not a level pass).
		for b: String in order.slice(0, order.find(_biome)):
			for t: int in range(1, 11):
				var id: String = "%s_%02d" % [b, t]
				var lv: LevelData = content.level(StringName(id))
				store.record_result(StringName(id), 3, 100000, 1000, lv.level_hash if lv != null else "")
		_notes.append("SEEDED prerequisite biomes %s with 3-star records (save fixture) so %s opens" % [str(order.slice(0, order.find(_biome))), _biome])
	_intent(&"select_biome", {"biome_id": _biome})
	await _frames(10)
	await _wait(0.5)
	await _shot("00_map_" + _biome)
	var levels: Array = []
	for meta: Dictionary in content.all_levels():
		if String(meta.biome) == _biome and int(meta.get("tier", 1)) <= 10: levels.append(String(meta.id))
	var only: String = String(_args.get("level", ""))
	var max_levels: int = int(_args.get("max", "10"))
	var first: bool = true
	for id: String in levels:
		if only != "" and id != only: continue
		if _rows.size() >= max_levels: break
		var row: Dictionary = await _play_level(id, first)
		first = false
		_rows.append(row)
		_log(JSON.stringify(row))
	# Biome-unlock moment: back to the map, then look at the next island.
	_intent(&"to_map")
	await _frames(8)
	await _shot("99_map_after_" + _biome)
	var idx: int = order.find(_biome)
	var unlock: Dictionary = {}
	if idx >= 0 and idx + 1 < order.size():
		var nxt: String = order[idx + 1]
		unlock = {"next": nxt, "open": store.biome_open(nxt), "biome_stars": store.biome_stars(_biome)}
		_intent(&"select_biome", {"biome_id": nxt})
		await _frames(8)
		await _wait(0.4)
		unlock["shot"] = await _shot("99_unlock_" + nxt)
		unlock["screen"] = _screen()
	var report: Dictionary = {"biome": _biome, "tag": _tag, "resolution": str(get_viewport().get_visible_rect().size),
		"runtime_ms": Time.get_ticks_msec() - t0, "levels": _rows, "notes": _notes, "unlock": unlock}
	var f := FileAccess.open("res://prototypes/_capture/story/%s%s.json" % [(_tag + "-") if _tag != "" else "", _biome], FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "\t")); f.close()
	_log("DONE biome=%s levels=%d runtime=%ds" % [_biome, _rows.size(), report.runtime_ms / 1000])
	get_tree().quit(0)

func _play_level(id: String, first: bool) -> Dictionary:
	var lt: int = Time.get_ticks_msec()
	var n: String = id.get_slice("_", 1)
	var row: Dictionary = {"id": id, "method": "", "attempts": [], "pre_story": false, "post_story": false, "stars": 0,
		"won": false, "issues": [], "shots": []}
	if _screen() != "intro" or String(_main.get("_level_id")) != id:
		if not first: row.issues.append("expected intro of %s after 'next' but screen=%s level=%s" % [id, _screen(), String(_main.get("_level_id"))])
		_intent(&"open_level", {"level_id": id})
		await _frames(5)
	await _wait(0.3)
	row.shots.append(await _shot("%s_%s_intro" % [n, id]))
	if _screen() != "intro": row.issues.append("open_level did not show intro (screen=%s)" % _screen())
	_intent(&"start_level", {"level_id": id})
	await _frames(3)
	if _sim() == null:
		row.issues.append("start_level produced no sim (screen=%s) — SOFTLOCK/LOAD FAIL" % _screen())
		row.method = "CRASHED"
		return row
	for attempt: int in 2:
		if _screen() == "story":
			row.pre_story = true
			if attempt == 1: row.issues.append("pre-level story replays on Retry")
			if attempt == 0: await _story(row, "%s_%s_story_pre" % [n, id])
			else: await _skip_story(row)
		var a: Dictionary = await _drive(id, row, attempt)
		row.attempts.append(a)
		if a.outcome == "won" or a.outcome == "forced_won": break
		# Lost: look at the loss results, then Retry like a player.
		await _post(row, id, n, "lost")
		_intent(&"retry")
		await _frames(3)
	if row.attempts.back().outcome in ["won", "forced_won"]:
		row.won = true
		var r: LevelResult = _sim().result() if _sim() != null else null
		row.stars = r.stars if r != null else 0
		row.level_ms = r.level_ms if r != null else 0
		await _post(row, id, n, "results")
	row.method = row.attempts.back().get("method", "")
	if row.attempts.back().outcome == "forced_won": row.method = "FORCED"
	row.wall_ms = Time.get_ticks_msec() - lt
	if _screen() == "results" and bool(row.won):
		var pend: Dictionary = _main.get("_pending_results")
		row.next_available = bool(pend.get("next_available", false))
		if row.next_available: _intent(&"next")
		await _frames(4)
	return row

func _drive(id: String, row: Dictionary, attempt: int) -> Dictionary:
	var sim: BoardSim = _sim()
	var proof: Dictionary = _proofs.get(id, {})
	var use_solver: bool = not proof.is_empty() and attempt == 0
	var bot := WtBotPlayer.new()
	var placed: int = 0
	var placing_lock: int = -1
	var mid_done: bool = false
	var t0: int = Time.get_ticks_msec()
	var out: Dictionary = {"attempt": attempt + 1, "method": "solver" if use_solver else "bot", "outcome": "timeout"}
	var n: String = id.get_slice("_", 1)
	while true:
		sim = _sim()
		if sim == null: out.outcome = "sim_vanished"; row.issues.append("sim became null mid-play (screen=%s)" % _screen()); return out
		if bool(_main.get("_result_shown")) or sim.get_phase() == BoardSim.Phase.ENDED: break
		if _screen() == "story" or bool(_main.get("_paused")):
			if _screen() == "pause" or _screen() == "story": pass
			await _frames(1)
			if Time.get_ticks_msec() - t0 > 20000 and bool(_main.get("_paused")) and not bool(_main.get("_result_shown")):
				row.issues.append("game stayed paused during play (screen=%s) — SOFTLOCK" % _screen()); out.outcome = "softlock"; return out
			continue
		for s: int in STEPS_PER_FRAME:
			sim = _sim()
			if sim == null or sim.get_phase() == BoardSim.Phase.ENDED or bool(_main.get("_paused")): break
			if sim.get_phase() == BoardSim.Phase.SELECTING:
				var choices: Array[Dictionary] = sim.kit_choices()
				var want: String = ""
				if use_solver and placed < proof.placements.size(): want = String(proof.placements[placed].shape)
				if want == "" and not choices.is_empty(): want = String(choices[0].shape_id)
				if want != "": _intent(&"pick_shape", {"shape_id": want})
			elif use_solver:
				var piece: ActivePiece = sim.get_piece()
				var locks: int = sim.goal_state().locks
				if piece != null and sim.get_phase() == BoardSim.Phase.FALLING and placing_lock != locks and placed < proof.placements.size():
					var pl: Dictionary = proof.placements[placed]
					if String(piece.shape.shape_id) != String(pl.shape):
						row.issues.append("solver: expected shape %s got %s at placement %d; bot takes over" % [pl.shape, piece.shape.shape_id, placed])
						use_solver = false; out.method = "solver+bot"
					else:
						piece.orient = int(pl.orient)
						piece.pivot = Vector3i(int(pl.pivot[0]), int(pl.pivot[1]), int(pl.pivot[2]))
						var bottom: int = 999
						for c: Vector3i in piece.cells(): bottom = mini(bottom, c.y)
						piece.pivot.y += sim.board().limit_layer() - bottom
						_intent(&"drop")
						placing_lock = locks
						placed += 1
			else:
				bot.update(sim)
			_main.call("_physics_process", 1.0 / 60.0)
		sim = _sim()
		if sim == null: continue
		var locks_now: int = sim.goal_state().locks
		if not mid_done and locks_now >= 8:
			mid_done = true
			await _frames(1)
			row.shots.append(await _shot("%s_%s_play_mid%s" % [n, id, "" if attempt == 0 else "_retry"]))
		var over_cap: bool = sim.goal_state().level_ms > BOT_CAP_MS or Time.get_ticks_msec() - t0 > WALL_CAP_MS
		if attempt == 1 and locks_now >= RETRY_FORCE_LOCKS: over_cap = true
		if over_cap and sim.get_phase() != BoardSim.Phase.ENDED:
			if not mid_done:
				mid_done = true
				row.shots.append(await _shot("%s_%s_play_mid" % [n, id]))
			out.forced_at = {"level_ms": sim.goal_state().level_ms, "locks": locks_now, "progress": str(sim.progress_snapshot())}
			sim.call("_finish", GoalState.RESULT_WON, &"qa_forced")
			_main.call("_physics_process", 1.0 / 60.0)
			out.outcome = "forced_won"
			break
		await _frames(1)
	sim = _sim()
	out.wall_ms = Time.get_ticks_msec() - t0
	if sim != null:
		out.locks = sim.goal_state().locks
		out.level_ms = sim.goal_state().level_ms
		if out.outcome != "forced_won":
			var r: LevelResult = sim.result()
			out.outcome = "won" if r != null and r.is_won() else "lost"
	if not mid_done: row.issues.append("level ended before 8 pieces (attempt %d, locks=%s)" % [attempt + 1, str(out.get("locks", "?"))])
	await _frames(2)
	return out

func _post(row: Dictionary, id: String, n: String, label: String) -> void:
	await _frames(2)
	if _screen() == "story":
		row.post_story = true
		await _story(row, "%s_%s_story_post" % [n, id])
	var t: int = Time.get_ticks_msec()
	while _screen() != "results" and Time.get_ticks_msec() - t < 15000: await _frames(2)
	await _wait(0.6)
	row.shots.append(await _shot("%s_%s_%s" % [n, id, label]))
	if _screen() != "results": row.issues.append("expected results screen after %s, got %s — SOFTLOCK" % [label, _screen()])

func _story(row: Dictionary, base: String) -> void:
	await _wait(0.7)
	row.shots.append(await _shot(base + "_a"))
	await _wait(1.6)
	row.shots.append(await _shot(base + "_b"))
	await _skip_story(row)

func _skip_story(row: Dictionary) -> void:
	var btn: Button = _find_skip(_ui())
	if btn != null and btn.visible: btn.pressed.emit()
	else: row.issues.append("story skip button missing/hidden; waited for story to finish")
	var t: int = Time.get_ticks_msec()
	while _screen() == "story" and Time.get_ticks_msec() - t < 45000: await _frames(2)
	if _screen() == "story": row.issues.append("story never finished — SOFTLOCK")
	await _frames(3)

func _find_skip(node: Node) -> Button:
	for c: Node in node.get_children():
		if c is Button and (c as Button).text.strip_edges() == "→" and (c as Button).is_visible_in_tree(): return c
		var f: Button = _find_skip(c)
		if f != null: return f
	return null
