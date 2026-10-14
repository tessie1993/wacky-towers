extends Node
## QA minigame capture (2026-10-14). One FRESH main-scene instance per minigame template (mg01..mgNN):
## starts the round through main._start_minigame_round, drives player 0 with the practice bot
## (WtMinigameRound._bot_act), and saves 720x1280 shots <id>_start / _mid / _result.
## Also captures the arcade hub plus two arcade games (each in its own fresh hub instance).
## Run: XDG_DATA_HOME=<scratch> timeout 900 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . \
##   --rendering-driver opengl3 --resolution 720x1280 res://tools/qa/playtest/minigame_capture.tscn [-- --only=mg01,mg02] [--no-arcade]
const OUT := "res://production/qa/evidence/playtest-2026-10-14/minigames/"
const START_TICKS := 70
const MID_TICKS := 700
const TICKS_PER_FRAME := 10
var _main: Node
var _log: Array = []

func _ready() -> void: _run.call_deferred()
func _frames(n: int) -> void:
	for i: int in n: await get_tree().process_frame
func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	img.save_png(OUT + name + ".png")
	print("MG_SHOT ", name, " ", img.get_size())
func _drop(node: Node) -> void:
	if node != null:
		node.queue_free()
		await _frames(3)

func _run() -> void:
	var only: Array = []
	var arcade: bool = true
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--only="): only = Array(a.trim_prefix("--only=").split(","))
		if a == "--no-arcade": arcade = false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var doc: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/tournament/templates.json"))
	var rows: Array = []
	for row: Dictionary in doc.templates:
		if str(row.get("category", "")) == "minigame" and (only.is_empty() or only.has(str(row.id))): rows.append(row)
	var n: int = 0
	for row: Dictionary in rows:
		n += 1
		var res: Dictionary = await _play(row, n)
		_log.append(res)
		print("MG_ROW ", JSON.stringify(res))
	if arcade and only.is_empty():
		await _arcade()
	var f := FileAccess.open(OUT + "capture_log.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(_log, "\t")); f.close()
	get_tree().quit(0)

## Advances the minigame n ticks (player 0 acts via the practice bot), rendering every few ticks.
func _advance(ticks: int) -> void:
	var mg: Object = _main.get("_minigame")
	for t: int in ticks:
		if _main.get("_minigame") == null: return
		if t % 18 == 0: mg.call("_bot_act", 0)
		_main.call("_minigame_tick")
		if t % TICKS_PER_FRAME == 0: await _frames(1)

func _play(row: Dictionary, n: int) -> Dictionary:
	var id: String = str(row.id)
	var res: Dictionary = {"id": id, "name": str(row.get("name", "")), "started": false, "shots": []}
	await _drop(_main)
	_main = load("res://src/app/main.tscn").instantiate()   # fresh instance per minigame
	add_child(_main)
	await _frames(20)
	var store: Object = _main.get("_store")
	if store.call("active_profile") == null: store.call("create", "QA Playtest")
	_main.set_physics_process(false)
	var modes: Object = _main.get("_modes")
	var cfg: Dictionary = modes.call("start_tournament", [{"name": "QA Playtest"}, {"name": "Pip", "is_bot": true}], 3, 4242 + n, [])
	if not cfg.get("ok", false): res.error = "start_tournament failed: " + str(cfg); return res
	_main.set("_mode", &"tournament")
	_main.call("_start_minigame_round", {"template": row, "template_id": id, "round_seed": 9000 + n})
	await _frames(5)
	var mg: Object = _main.get("_minigame")
	if mg == null: res.error = "round refused template (setup returned false / unsupported); fell through to next round"; return res
	if str(mg.get("template").get("id", "")) != id: res.error = "wrong template running: " + str(mg.get("template").get("id", "")); return res
	res.started = true
	res.screen = str(_main.get("_ui").get("current_screen"))
	await _advance(START_TICKS)
	await _frames(8)
	await _shot(id + "_start"); res.shots.append("start")
	await _advance(MID_TICKS - START_TICKS)
	await _frames(8)
	await _shot(id + "_mid"); res.shots.append("mid")
	var local: Dictionary = (mg.call("local_snapshot") as Dictionary)
	res.mid_score = local.get("score", null)
	# Result: end the round now, let main process the finish (results screen).
	mg.call("force_finish")
	_main.call("_minigame_tick")
	await _frames(15)
	res.result_screen = str(_main.get("_ui").get("current_screen"))
	res.result_shown = bool(_main.get("_result_shown"))
	if res.result_shown:
		await _shot(id + "_result"); res.shots.append("result")
	return res

func _arcade() -> void:
	await _drop(_main); _main = null
	var hub: Node = load("res://minigames/arcade_pack/arcade_hub.tscn").instantiate()
	add_child(hub)
	await _frames(25)
	await _shot("arcade_hub_menu")
	await _drop(hub)
	for lvl: String in ["stack_meadow", "wall_basket_gate"]:
		hub = load("res://minigames/arcade_pack/arcade_hub.tscn").instantiate()   # fresh hub per game
		add_child(hub)
		await _frames(10)
		var pick: Dictionary = {}
		for l: Dictionary in hub.get("levels"):
			if str(l.id) == lvl: pick = l
		if pick.is_empty(): _log.append({"id": "arcade_" + lvl, "error": "level not found"}); await _drop(hub); continue
		hub.call("show_briefing", pick)
		await _frames(10)
		await _shot("arcade_%s_briefing" % lvl)
		hub.call("start_selected")
		await _frames(20)
		await _shot("arcade_%s_start" % lvl)
		var acts: Array = ["primary", "rotate_y", "left", "right", "up", "down"] if lvl.begins_with("wall") else ["primary"]
		for i: int in 14:
			for k: int in 25: await get_tree().process_frame
			hub.call("send_action", acts[i % acts.size()])
		await _frames(5)
		await _shot("arcade_%s_mid" % lvl)
		_log.append({"id": "arcade_" + lvl, "started": true})
		await _drop(hub)
