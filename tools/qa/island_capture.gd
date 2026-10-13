extends Node
## QA capture for the in-level environment (islands v2). Instances the real main scene, starts
## <biome>_01 for each biome through main's own _start_level (smoke flag bypasses unlocks),
## freezes the sim (optionally --pieces: a few locked pieces, like the stage demo), and saves in-game shots + side-by-sides with ref 15.
## Run: timeout 240 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3 \
##   --resolution 720x1280 res://tools/qa/island_capture.tscn -- [--biomes=meadow,ice] [--tag=v1]
const OUT := "res://production/qa/evidence/islands-v2/"
const REF := "res://assets/art/reference/style/15_title_and_hud.png"
const PANELS := {"meadow": Rect2i(424, 0, 414, 941), "ice": Rect2i(840, 0, 414, 941), "celestial": Rect2i(1256, 0, 416, 941)}

func _ready() -> void:
	_run.call_deferred()

func _frames(n: int) -> void:
	for i: int in n: await get_tree().process_frame

func _run() -> void:
	var biomes: PackedStringArray = PackedStringArray(["meadow", "ice", "celestial", "candy", "lava"])
	var tag: String = ""
	var pieces: bool = false
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--biomes="): biomes = a.trim_prefix("--biomes=").split(",")
		if a.begins_with("--tag="): tag = "_" + a.trim_prefix("--tag=")
		if a == "--pieces": pieces = true
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var vs: Vector2 = get_viewport().get_visible_rect().size
	var res: String = "%dx%d" % [int(vs.x), int(vs.y)]
	var main: Node = load("res://src/app/main.tscn").instantiate()
	add_child(main)
	await _frames(20)
	if not biomes.has("notitle"):
		await _snap(OUT + "title_%s%s.png" % [res, tag], "")
	var store: Object = main.get("_store")
	if store.call("active_profile") == null: store.call("create", "QA Islands")
	main.set("_smoke", true)
	for b: String in biomes:
		if b == "notitle": continue
		main.call("_start_level", StringName(b + "_01"))
		main.set_physics_process(false)
		if pieces: _place_pieces(main)
		await _frames(30)
		await _snap(OUT + "%s_%s%s.png" % [b, res, tag], b if vs.y > vs.x else "")
	get_tree().quit()

func _snap(path: String, biome: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	img.save_png(path)
	print("ISLAND_SNAP ", path)
	if biome == "": return
	var ref: Image = Image.load_from_file(ProjectSettings.globalize_path(REF))
	ref.convert(Image.FORMAT_RGBA8)
	var panel: Image = ref.get_region(PANELS.get(biome, PANELS.meadow))
	panel.resize(int(panel.get_width() * float(img.get_height()) / panel.get_height()), img.get_height(), Image.INTERPOLATE_LANCZOS)
	var out := Image.create(panel.get_width() + img.get_width() + 16, img.get_height(), false, Image.FORMAT_RGBA8)
	out.fill(Color("#2a1a38"))
	out.blit_rect(panel, Rect2i(Vector2i.ZERO, panel.get_size()), Vector2i.ZERO)
	out.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(panel.get_width() + 16, 0))
	out.save_png(path.replace(".png", "_vs_ref15.png"))

## Locks a small staircase of coloured cells (QA fixture, mirrors wt_stage_demo) and refreshes
## the board view so the biome blocks show on the island.
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
