extends SceneTree
## QA: renders every biome block look as a 3-cube L-stack in a 4x3 grid on a cream background,
## laid out like assets/art/reference/style/13_biome_blocks.png, and saves PNG evidence.
## Uses the production path: WtBlockMesh.cube() + WtBlockMaterials.for_biome() in a MultiMesh
## (instance colour = piece colour, custom.a = cell alpha), toppers via WtBlockToppers.
## Run (Compatibility):
##   timeout 240 xvfb-run -a -s "-screen 0 1600x1280x24" godot --path . --rendering-driver opengl3 \
##       -s res://tools/qa/block_gallery.gd
## Optional user args after `--`: `tints` renders the palette-tint sheet, `ghost` the ghost sheet.

const OUT_DIR := "res://production/qa/evidence/blocks-v2/"
const FONT_PATH := "res://prototypes/style_rnd/fonts/LilitaOne-Regular.ttf"
const CELL := Vector2i(400, 400)
const BG := Color("f6ead3")
const INK := Color("3b2346")

## Sheet order of ref 13. Third value: per-cube piece colours (bottom-left, bottom-right, top);
## empty = the biome body colour (the "natural" look on the sheet).
const SHEET := [
	["meadow", "Meadow", []], ["candy", "Candy", ["#FF5F8F", "#FF9A4A", "#FF6F9C"]],
	["ice", "Ice", []], ["underwater", "Underwater", []],
	["lava", "Lava", []], ["forest", "Forest", []], ["cave", "Crystal Cave", []],
	["clockwork", "Clockwork", []], ["neon", "Neon", []], ["celestial", "Celestial", []],
	["carnival", "Tumble Fair", []], ["dune", "Dune Bazaar", []],
]
## Palette check (ref 15): the same biome with four piece colours from the candy_toy palette.
const TINT_BIOMES := ["meadow", "ice", "celestial", "candy", "lava", "neon"]
const TINT_COLOURS := ["#A8DA52", "#F0708A", "#FFF0C8", "#4E62D6"]

var _font: Font


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH) as Font
	var mode: String = args[0] if args.size() > 0 else "sheet"
	if mode == "tints":
		await _sheet_tints()
	elif mode == "ghost":
		await _sheet_ghost()
	else:
		await _sheet_main()
	quit()


func _sheet_main() -> void:
	root.size = Vector2i(CELL.x * 4, CELL.y * 3)
	var grid := _grid(4)
	for entry: Array in SHEET:
		var colours: Array = entry[2]
		if colours.is_empty():
			var body := Color(String(WtBlockMaterials.look(StringName(entry[0])).get("block", {}).get("body_color", "#ffffff")))
			colours = [body, body, body]
		var cells: Array = [[Vector3(-0.5, 0.5, 0), colours[0]], [Vector3(0.5, 0.5, 0), colours[1]], [Vector3(0.5, 1.5, 0), colours[2]]]
		grid.add_child(_cell(StringName(entry[0]), entry[1], cells, false))
	await _snap("gallery.png")


func _sheet_tints() -> void:
	root.size = Vector2i(CELL.x * 3, CELL.y * 2)
	var grid := _grid(3)
	for biome: String in TINT_BIOMES:
		var cells: Array = [[Vector3(-0.5, 0.5, 0.5), Color(TINT_COLOURS[0])], [Vector3(0.5, 0.5, 0.5), Color(TINT_COLOURS[1])],
			[Vector3(0.5, 1.5, 0.5), Color(TINT_COLOURS[1])], [Vector3(-0.5, 0.5, -0.5), Color(TINT_COLOURS[2])],
			[Vector3(0.5, 0.5, -0.5), Color(TINT_COLOURS[3])], [Vector3(-0.5, 1.5, -0.5), Color(TINT_COLOURS[2])]]
		grid.add_child(_cell(StringName(biome), biome.capitalize() + " tints", cells, false))
	await _snap("gallery_tints.png")


func _sheet_ghost() -> void:
	root.size = Vector2i(CELL.x * 3, CELL.y * 1)
	var grid := _grid(3)
	for biome: String in ["meadow", "ice", "celestial"]:
		var cells: Array = [[Vector3(-0.5, 0.5, 0), Color("#F0708A")], [Vector3(0.5, 0.5, 0), Color("#F0708A")]]
		grid.add_child(_cell(StringName(biome), biome.capitalize() + " + ghost", cells, true))
	await _snap("gallery_ghost.png")


func _grid(columns: int) -> GridContainer:
	var bg := ColorRect.new()
	bg.color = BG
	bg.size = Vector2(root.size)
	root.add_child(bg)
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override(&"h_separation", 0)
	grid.add_theme_constant_override(&"v_separation", 0)
	root.add_child(grid)
	return grid


## One sheet cell: a SubViewport with its own world (environment, light rig, cubes) and a label.
func _cell(biome: StringName, title: String, cells: Array, with_ghost: bool) -> Control:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(CELL)
	box.add_theme_constant_override(&"separation", 0)
	var svc := SubViewportContainer.new()
	svc.stretch = true
	svc.custom_minimum_size = Vector2(CELL.x, CELL.y - 56)
	box.add_child(svc)
	var vp := SubViewport.new()
	vp.own_world_3d = true
	vp.transparent_bg = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.size = Vector2i(CELL.x, CELL.y - 56)
	svc.add_child(vp)
	var world := Node3D.new()
	vp.add_child(world)
	_rig(world)
	var mesh: Mesh = WtBlockMesh.cube()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = mesh
	mm.instance_count = cells.size()
	for i: int in cells.size():
		mm.set_instance_transform(i, Transform3D(Basis(), cells[i][0]))
		mm.set_instance_color(i, Color(cells[i][1]))
		mm.set_instance_custom_data(i, Color(0, 0, 0, 1))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = WtBlockMaterials.for_biome(biome)
	world.add_child(mmi)
	# Toppers: the gallery forces one on the top cube so every biome's topper is reviewed.
	var tops: Array[Vector3] = []
	for c: Array in cells:
		tops.append(c[0])
	var topper: Node3D = WtBlockToppers.build_for_cells(biome, _top_cells(tops), 1.0)
	if topper != null:
		world.add_child(topper)
	if with_ghost:
		var gmm := MultiMesh.new()
		gmm.transform_format = MultiMesh.TRANSFORM_3D
		gmm.use_colors = true
		gmm.use_custom_data = true
		gmm.mesh = WtBlockMesh.cube()
		gmm.instance_count = 2
		for i: int in 2:
			gmm.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * 0.93), Vector3(-0.5 + i, 2.6, 0)))
			gmm.set_instance_color(i, Color("#F0708A"))
		var g := MultiMeshInstance3D.new()
		g.multimesh = gmm
		g.material_override = WtBlockMaterials.ghost_material()
		world.add_child(g)
	var cam := Camera3D.new()
	cam.fov = 30.0
	world.add_child(cam)
	var target := Vector3(0.05, 1.0 if not with_ghost else 1.5, 0.0)
	cam.look_at_from_position(target + Vector3(-2.3, 2.5, 5.6) * (1.0 if not with_ghost else 1.25), target)
	cam.current = true
	var label := Label.new()
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(CELL.x, 56)
	var ls := LabelSettings.new()
	if _font != null:
		ls.font = _font
	ls.font_size = 36
	ls.font_color = INK
	label.label_settings = ls
	box.add_child(label)
	return box


## Cells with nothing directly above them (top faces exposed).
func _top_cells(cells: Array[Vector3]) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for c: Vector3 in cells:
		var covered := false
		for o: Vector3 in cells:
			if o.is_equal_approx(c + Vector3.UP):
				covered = true
		if not covered and c.y > 1.0:
			out.append(c)
	return out


## Same light model as WtStage._build_light (key, sky fill, flat ambient, linear tonemap, glow),
## with a neutral sheet sky and a shadow-catcher floor.
func _rig(world: Node3D) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("e9e4ef")
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.glow_enabled = true
	env.glow_normalized = false
	env.glow_intensity = 0.7
	env.glow_strength = 1.0
	env.glow_bloom = 0.0
	env.glow_hdr_threshold = 1.0
	env.glow_hdr_scale = 2.0
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	for level: int in 7:
		env.set_glow_level(level, 1.0 if level in [1, 2, 3] else 0.0)
	var we := WorldEnvironment.new()
	we.environment = env
	world.add_child(we)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-50, -32, 0)
	key.light_color = Color("#FFE7C2")
	key.light_energy = 0.95
	key.shadow_enabled = true
	key.shadow_blur = 1.5
	key.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	key.directional_shadow_max_distance = 20.0
	world.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30, 145, 0)
	fill.light_color = Color("#8EC9F0").lerp(Color.WHITE, 0.35)
	fill.light_energy = 0.28
	fill.light_specular = 0.0
	world.add_child(fill)
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(12, 12)
	var floor_mi := MeshInstance3D.new()
	floor_mi.mesh = floor_mesh
	var sh := Shader.new()
	sh.code = "shader_type spatial;\nrender_mode shadow_to_opacity, unshaded;\nvoid fragment(){ ALBEDO = vec3(0.35, 0.25, 0.2); }\n"
	var floor_mat := ShaderMaterial.new()
	floor_mat.shader = sh
	floor_mi.material_override = floor_mat
	floor_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(floor_mi)


func _snap(file: String) -> void:
	for i: int in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT_DIR + file))
	print("SNAP ", OUT_DIR + file, " ", img.get_size(), " method=", RenderingServer.get_current_rendering_method())
