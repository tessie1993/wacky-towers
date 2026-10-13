extends SceneTree
## Style R&D prototype (c): the shared warm environment preset + light rig on a meadow
## floating-island diorama (portrait phone framing, ref 15 panel 2), with the nine-patch HUD.
## Run: timeout 240 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3 \
##      --resolution 720x1280 -s res://prototypes/style_rnd/island_demo.gd [-- biome=ice]
const Kit := preload("res://prototypes/style_rnd/style_kit.gd")
const OUT := "res://production/qa/evidence/style-rnd/"
var biome := "meadow"
var rng := RandomNumberGenerator.new()

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("biome="): biome = a.substr(6)
	rng.seed = 1234
	_run()

func _run() -> void:
	DisplayServer.window_set_size(Vector2i(720, 1280))
	var world := Node3D.new(); root.add_child(world)
	var we := WorldEnvironment.new(); we.environment = Kit.make_environment(biome); world.add_child(we)
	Kit.add_backdrop(root, biome)
	var cam := Camera3D.new(); cam.fov = 42.0; world.add_child(cam)
	var cam_pos := Vector3(19.0, 17.5, 19.0)
	cam.look_at_from_position(cam_pos, Vector3(0, -2.2, 0)); cam.current = true
	Kit.add_light_rig(world, biome, rad_to_deg(atan2(cam_pos.x, cam_pos.z)))

	var ice := biome == "ice"
	# ---- island chunk: rim slab with biome cap + 3 painted strata bands, tapering down
	var rim := MeshInstance3D.new(); rim.mesh = Kit.rounded_box(Vector3(10.6, 0.8, 10.6), 0.35, 12)
	rim.position = Vector3(0, -0.4, 0)
	rim.material_override = Kit.painted_material({"half_size": Vector3(5.3, 0.4, 5.3), "edge_width": 0.35, "cap_y": 0.12, "cap_drip": 0.12, "cap_lip": 0.0,
		"pebbles": 0.0, "paint_scale": 1.2, "edge_light": 0.2, "ao_strength": 0.0,
		"cap_color": Color("eef4ff") if ice else Color("5c9e38"), "cap_light": Color("ffffff") if ice else Color("9bd65e"),
		"cap_dark": Color("b9c8e8") if ice else Color("2f6a24")})
	world.add_child(rim)
	var bands := [[5.35, 5.2, -0.75, 1.5], [5.15, 4.7, -2.2, 1.5], [4.7, 2.2, -3.65, 2.4]]
	for i in bands.size():
		var b: Array = bands[i]
		var m := MeshInstance3D.new(); m.mesh = _chunk(b[0], b[1], b[3], 24, 0.07 + i * 0.03)
		m.position = Vector3(0, b[2], 0)
		var c1 := Color("9aa6c4") if ice else Color("a07650").darkened(i * 0.12)
		m.material_override = Kit.prop_material(c1, c1.darkened(0.35), {"strata": 1.0, "paint_scale": 1.5, "edge_light": 0.15, "ao_strength": 0.0})
		world.add_child(m)
	# ---- stone tile board 8x8 (inset slightly into the rim)
	var tile := Kit.rounded_box(Vector3(0.96, 0.3, 0.96), 0.07, 6)
	for x in 8:
		for z in 8:
			var t := MeshInstance3D.new(); t.mesh = tile
			t.position = Vector3(x - 3.5, 0.05, z - 3.5)
			var base := Color("b9cbe2") if ice else Color("bdb2a2")
			var v := rng.randf_range(-0.04, 0.04)
			t.material_override = Kit.prop_material(base.lightened(v), base.darkened(0.25 - v), {"half_size": Vector3(0.48, 0.15, 0.48), "edge_width": 0.07, "paint_scale": 2.0, "edge_light": 0.45, "gloss": 0.2, "seed": float(x * 8 + z)})
			world.add_child(t)
	# ---- rim dressing: flowers, clover, bushes (never on the grid)
	for k in 70:
		var p := _rim_point(4.25, 5.1)
		if rng.randf() < 0.65: _flower(world, p + Vector3(0, 0.02, 0), Color("fff6f0") if rng.randf() < 0.6 else Color("c9a2ff"))
		else: _clover(world, p + Vector3(0, 0.03, 0))
	for k in 9:
		var p := _rim_point(4.6, 5.2)
		var bush := MeshInstance3D.new(); var sm := SphereMesh.new(); sm.radius = 0.5; sm.height = 1.0; bush.mesh = sm
		var s := rng.randf_range(0.5, 0.85); bush.scale = Vector3(s, s * 0.8, s); bush.position = p + Vector3(0, s * 0.3, 0)
		bush.material_override = Kit.prop_material(Color("e8f0ff") if ice else Color("5fa63c"), Color("9fb4dc") if ice else Color("2e6a25"), {"paint_scale": 4.0, "edge_light": 0.4})
		world.add_child(bush)
	# ---- pieces on the board (palette-tinted bodies; green piece gets the grass cap)
	var box := Kit.rounded_box(Vector3.ONE * 0.97, 0.12, 12)
	var pieces := [
		[Color("e86aa0"), [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 1, 0)]],
		[Color("f2c53a"), [Vector3i(1, 0, 1), Vector3i(2, 0, 1), Vector3i(2, 1, 1)]],
		[Color("4aa8e8"), [Vector3i(-1, 0, 1), Vector3i(0, 0, 1), Vector3i(0, 0, 2)]],
		[Color("6cc04a"), [Vector3i(1, 1, 0), Vector3i(1, 2, 0), Vector3i(1, 3, 0)]],
	]
	for pc in pieces:
		var col: Color = pc[0]
		var green := col == Color("6cc04a")
		for cell in pc[1]:
			var mi := MeshInstance3D.new(); mi.mesh = box
			mi.position = Vector3(cell.x - 0.5, 0.2 + 0.5 + cell.y * 0.98, cell.z - 0.5)
			mi.material_override = Kit.painted_material({"body_color": col, "body_dark": col.darkened(0.3),
				"cap_y": 0.15 if green else 2.0, "pebbles": 0.0, "strata": 0.0, "paint_scale": 2.2,
				"seed": mi.position.x * 3.1 + mi.position.y * 7.7, "gloss": 0.45})
			world.add_child(mi)
	# ---- distant islands (fog turns them into the hazy background layer)
	for d in [[Vector3(-26, -4, -34), 4.0], [Vector3(14, 2, -46), 5.5], [Vector3(-46, 4, -20), 6.0], [Vector3(30, -10, -24), 3.5]]:
		var top := MeshInstance3D.new(); top.mesh = _chunk(d[1], d[1] * 0.92, 0.7, 16, 0.12)
		top.position = d[0]; top.material_override = Kit.prop_material(Color("e9f1ff") if ice else Color("6aa84a"), Color("b9c8e8") if ice else Color("3d7a30"), {"haze": 0.55, "haze_color": Color("d6e4f8")})
		world.add_child(top)
		var bot := MeshInstance3D.new(); bot.mesh = _chunk(d[1] * 0.92, d[1] * 0.3, d[1] * 1.2, 16, 0.15)
		bot.position = d[0] + Vector3(0, -d[1] * 1.2, 0); bot.material_override = Kit.prop_material(Color("a07650"), Color("6b4a33"), {"strata": 1.0, "haze": 0.6, "haze_color": Color("d6e4f8")})
		world.add_child(bot)

	_hud()
	for i in 8: await process_frame
	await Kit.snap(root, OUT + "c_island_%s.png" % biome)
	quit()

func _rim_point(r0: float, r1: float) -> Vector3:
	# point in the square ring between the board edge and the island edge
	while true:
		var p := Vector3(rng.randf_range(-r1, r1), 0, rng.randf_range(-r1, r1))
		var m: float = max(abs(p.x), abs(p.z))
		if m > r0 and m < r1: return p
	return Vector3.ZERO

## Faceted rock chunk: a rounded-square prism, jittered, top radius rt, bottom rb, height h.
func _chunk(rt: float, rb: float, h: float, n: int, jit: float) -> ArrayMesh:
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var top := []; var bot := []
	for i in n:
		var a := TAU * i / n + PI / 4.0
		var sq: float = 1.0 / pow(pow(abs(cos(a)), 4.0) + pow(abs(sin(a)), 4.0), 0.25)
		var j1 := 1.0 + rng.randf_range(-jit, jit); var j2 := 1.0 + rng.randf_range(-jit, jit) * 1.6
		top.append(Vector3(cos(a), 0, sin(a)) * rt * sq * j1)
		bot.append(Vector3(cos(a), 0, sin(a)) * rb * sq * j2 + Vector3(0, -h * rng.randf_range(0.85, 1.15), 0))
	var c_top := Vector3.ZERO; var c_bot := Vector3(0, -h * 1.3, 0)
	for i in n:
		var k := (i + 1) % n
		for tri in [[top[i], top[k], bot[k]], [top[i], bot[k], bot[i]], [c_top, top[k], top[i]], [c_bot, bot[i], bot[k]]]:
			# force outward normals and Godot's clockwise front faces
			var cen: Vector3 = (tri[0] + tri[1] + tri[2]) / 3.0
			var outward: Vector3 = cen - Vector3(0, -h * 0.5, 0)
			var cr: Vector3 = (tri[1] - tri[0]).cross(tri[2] - tri[0])
			if cr.dot(outward) > 0.0: tri = [tri[0], tri[2], tri[1]]; cr = -cr
			var nrm: Vector3 = -cr.normalized()
			for v in tri: st.set_normal(nrm); st.add_vertex(v)
	return st.commit()

func _flower(parent: Node3D, at: Vector3, petal_col: Color) -> void:
	var petal := Kit.prop_material(petal_col, petal_col.darkened(0.15), {"gloss": 0.4})
	for k in 5:
		var p := MeshInstance3D.new(); var sm := SphereMesh.new(); sm.radius = 0.5; sm.height = 1.0; sm.radial_segments = 8; sm.rings = 4
		p.mesh = sm; p.scale = Vector3(0.26, 0.08, 0.17)
		var a := TAU * k / 5.0
		p.position = at + Vector3(cos(a) * 0.16, 0, sin(a) * 0.16); p.rotation.y = -a
		p.material_override = petal; parent.add_child(p)
	var c := MeshInstance3D.new(); var cs := SphereMesh.new(); cs.radius = 0.09; cs.height = 0.12
	c.mesh = cs; c.position = at + Vector3(0, 0.02, 0)
	c.material_override = Kit.prop_material(Color("ffd34d"), Color("e09a20")); parent.add_child(c)

func _clover(parent: Node3D, at: Vector3) -> void:
	var mat := Kit.prop_material(Color("6cc04a"), Color("2f7a2a"), {"gloss": 0.5, "edge_light": 0.5})
	for k in 3:
		var l := MeshInstance3D.new(); var sm := SphereMesh.new(); sm.radius = 0.5; sm.height = 1.0; sm.radial_segments = 8; sm.rings = 4
		l.mesh = sm; l.scale = Vector3(0.28, 0.07, 0.28)
		var a := TAU * k / 3.0
		l.position = at + Vector3(cos(a) * 0.14, 0.0, sin(a) * 0.14); l.material_override = mat; parent.add_child(l)

func _hud() -> void:
	var lilita := Kit.load_font("res://prototypes/style_rnd/fonts/LilitaOne-Regular.ttf")
	var fredoka := Kit.load_font("res://assets/fonts/fredoka/fredoka-700.woff2")
	var layer := CanvasLayer.new(); root.add_child(layer)
	var frame_meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://prototypes/style_rnd/renders/frame_purple_vine.json"))
	var chip_path := "res://prototypes/style_rnd/renders/frame_purple_chip.json"
	var chip_meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(chip_path)) if FileAccess.file_exists(chip_path) else frame_meta
	var chip_tex := Kit.load_tex("res://prototypes/style_rnd/renders/" + str(chip_meta.texture), 256)
	# screen frame: centre NOT drawn, so the 3D board shows through
	var frame := Kit.frame_patch(Kit.load_tex("res://prototypes/style_rnd/renders/frame_purple_screen.png", 384), int(frame_meta.margin_left), 1024, false)
	frame.position = Vector2(-14, -14); frame.size = Vector2(748, 1308); layer.add_child(frame)
	# top chips
	for spec in [[Vector2(235, 62), Vector2(220, 150), "SCORE", "1,250"], [Vector2(475, 62), Vector2(170, 150), "NEXT", ""]]:
		var chip := Kit.frame_patch(chip_tex, int(chip_meta.margin_left), 1024)
		chip.position = spec[0]; chip.size = spec[1]; layer.add_child(chip)
		var l := Kit.label(spec[2], fredoka, 22); l.position = spec[0] + Vector2(spec[1].x / 2 - 30, 28); layer.add_child(l)
		if spec[3] != "":
			var v := Kit.label(spec[3], lilita, 40); v.position = spec[0] + Vector2(spec[1].x / 2 - 48, 55); layer.add_child(v)
	# pause gem
	var pause := Kit.frame_patch(chip_tex, int(chip_meta.margin_left), 1024)
	pause.position = Vector2(80, 80); pause.size = Vector2(110, 110); layer.add_child(pause)
	var pl := Kit.label("II", lilita, 44); pl.position = Vector2(120, 105); layer.add_child(pl)
	# bottom 3-slot tray
	var tray := Kit.frame_patch(chip_tex, int(chip_meta.margin_left), 1024)
	tray.position = Vector2(70, 1010); tray.size = Vector2(580, 200); layer.add_child(tray)
