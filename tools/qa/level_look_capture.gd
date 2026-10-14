extends Node
## QA capture for the per-level `look` block. Starts <biome>_01 through main, freezes the sim, places a few
## locked pieces, applies each look via WtStage.apply_level_look and saves 720x1280 shots.
## Run: timeout 300 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3 \
##   --resolution 720x1280 res://tools/qa/level_look_capture.tscn -- [--set=meadow|night|all_pieces] [--biome=meadow]
const OUT := "res://production/qa/evidence/level-look-v1/"
const MEADOW: Array[Dictionary] = [
	{"time_of_day": "dawn", "weather": "mist", "set_piece": "meadow_windmill", "set_piece_side": "left", "accent": "#FF8FB0", "camera": "low", "dressing": "lush"},
	{"time_of_day": "day", "weather": "petals", "set_piece": "meadow_castle_gate", "set_piece_side": "right", "accent": "#FF8FB0", "camera": "default", "dressing": "normal"},
	{"time_of_day": "golden", "weather": "clear", "set_piece": "meadow_barn", "set_piece_side": "left", "accent": "#FFB347", "camera": "wide", "dressing": "lush"},
	{"time_of_day": "dusk", "weather": "drizzle", "set_piece": "meadow_well", "set_piece_side": "back", "accent": "#C69BFF", "camera": "high", "dressing": "sparse"},
	{"time_of_day": "night", "weather": "stars", "set_piece": "meadow_giant_sunflower", "set_piece_side": "right", "accent": "#7DE0FF", "camera": "close", "dressing": "normal"},
]

func _ready() -> void:
	_run.call_deferred()

func _frames(n: int) -> void:
	for i: int in n: await get_tree().process_frame

func _run() -> void:
	var which: String = "meadow"
	var biome: String = "meadow"
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--set="): which = a.trim_prefix("--set=")
		if a.begins_with("--biome="): biome = a.trim_prefix("--biome=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var jobs: Array[Dictionary] = []
	if which == "night":
		for b: String in ["neon", "celestial"]:
			jobs.append({"biome": b, "name": b + "_night", "look": {"time_of_day": "night", "weather": "stars", "set_piece": WtSetPieceBuilder.ids_for_biome(b)[0], "set_piece_side": "right", "camera": "default"}})
	elif which == "weather":
		for kind: String in ["mist", "drizzle", "snow", "embers", "bubbles", "petals", "stars", "confetti"]:
			jobs.append({"biome": biome, "name": "weather_" + kind, "look": {"time_of_day": "day", "weather": kind}})
	elif which == "all_pieces":
		for id: String in WtSetPieceBuilder.pieces():
			jobs.append({"biome": String(WtSetPieceBuilder.pieces()[id]["biome"]), "name": "piece_" + id, "look": {"set_piece": id, "set_piece_side": "right", "camera": "wide"}})
	else:
		for i: int in MEADOW.size(): jobs.append({"biome": biome, "name": "%s_%d" % [biome, i + 1], "look": MEADOW[i]})
	var main: Node = load("res://src/app/main.tscn").instantiate()
	add_child(main)
	await _frames(20)
	var store: Object = main.get("_store")
	if store.call("active_profile") == null: store.call("create", "QA Look")
	main.set("_smoke", true)
	var cur_biome: String = ""
	for job: Dictionary in jobs:
		if String(job["biome"]) != cur_biome:
			cur_biome = String(job["biome"])
			main.call("_start_level", StringName(cur_biome + "_01"))
			main.set_physics_process(false)
			_place_pieces(main)
			await _frames(10)
		var stage: Node = main.get("_stage")
		stage.call("apply_level_look", job["look"])
		await _frames(30)
		if OS.get_environment("WXDBG") != "":
			var pp: CPUParticles3D = stage.get_node("LevelLook").get_child(stage.get_node("LevelLook").get_child_count() - 1) as CPUParticles3D
			var mode: String = OS.get_environment("WXDBG")
			if mode.contains("noramp"): pp.color_ramp = null
			var qm: StandardMaterial3D = (pp.mesh as QuadMesh).material as StandardMaterial3D
			if mode.contains("blend"): qm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; qm.render_priority = 127
			if mode.contains("sneg"): pp.sorting_offset = -500.0
			if mode.contains("spos"): pp.sorting_offset = 500.0
			if mode.contains("prio"): qm.render_priority = 60
			if mode.contains("scissor"): qm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			if mode.contains("nodepth"): qm.no_depth_test = true
			if mode.contains("big"): pp.scale_amount_min = 8.0; pp.scale_amount_max = 8.0
			if mode.contains("plain"):
				var m := StandardMaterial3D.new(); m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; m.albedo_color = Color.RED
				(pp.mesh as QuadMesh).material = m
			await _frames(5)
		var wx: Node = stage.get_node_or_null("LevelLook")
		if wx != null:
			for c: Node in wx.get_children():
				if c is CPUParticles3D: print("WX ", c.name, " amount=", (c as CPUParticles3D).amount, " emitting=", (c as CPUParticles3D).emitting, " pos=", (c as CPUParticles3D).global_position, " vis=", (c as CPUParticles3D).is_visible_in_tree())
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		img.convert(Image.FORMAT_RGBA8)
		var path: String = OUT + String(job["name"]) + ".png"
		img.save_png(path)
		print("LOOK_SNAP ", path)
	get_tree().quit()

func _place_pieces(main: Node) -> void:
	var sim: BoardSim = main.get("_sim") as BoardSim
	var stage: Node = main.get("_stage")
	if sim == null or stage == null: return
	var b: BoardState = sim.board()
	var cells: Array = [[2, 0, 3, 1], [3, 0, 3, 1], [3, 1, 3, 1], [3, 0, 4, 2], [4, 0, 4, 2], [4, 0, 5, 2],
		[2, 0, 4, 3], [2, 0, 5, 3], [2, 1, 5, 3], [4, 1, 4, 4], [4, 2, 4, 4], [5, 0, 3, 5], [5, 0, 4, 5]]
	for c: Array in cells:
		var cell := Vector3i(int(c[0]), int(c[1]), int(c[2]))
		if b.in_bounds(cell): b.place(b.index(cell), 1, int(c[3]), 99)
	var view: Object = stage.get("_locked")
	if view != null and view.has_method("refresh"): view.call("refresh")
