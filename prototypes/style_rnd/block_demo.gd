extends SceneTree
## Style R&D prototype (a): painted rounded meadow block with grass cap + sprout, Compatibility.
## Run: timeout 240 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3 \
##      --resolution 1280x720 -s res://prototypes/style_rnd/block_demo.gd
const Kit := preload("res://prototypes/style_rnd/style_kit.gd")
const OUT := "res://production/qa/evidence/style-rnd/"

func _initialize() -> void:
	_run()

func _run() -> void:
	root.size = Vector2i(1000, 760)
	var world := Node3D.new(); root.add_child(world)
	var we := WorldEnvironment.new()
	var env: Environment = Kit.make_environment("meadow")
	# close-up sheet look (ref 13): parchment backdrop instead of sky
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("f3e6c8")
	we.environment = env; world.add_child(we)
	Kit.add_light_rig(world, "meadow", -30.0)

	# ground card that catches the soft coloured shadow
	var ground := MeshInstance3D.new()
	ground.mesh = Kit.rounded_box(Vector3(14, 0.2, 14), 0.05, 4)
	ground.position = Vector3(0, -0.1, 0)
	ground.material_override = Kit.prop_material(Color("e6d4ae"), Color("dcc79c"), {"edge_light": 0.0, "ao_strength": 0.0, "rim_strength": 0.0, "gloss": 0.0, "paint_scale": 0.6})
	world.add_child(ground)

	var box := Kit.rounded_box(Vector3.ONE * 0.98, 0.13, 14)
	var cells := [Vector3(-0.5, 0.49, 0.0), Vector3(0.5, 0.49, 0.0), Vector3(0.5, 1.47, 0.0)]
	for i in cells.size():
		var mi := MeshInstance3D.new(); mi.mesh = box; mi.position = cells[i]
		mi.material_override = Kit.painted_material({"seed": float(i) * 3.7})
		world.add_child(mi)
	_add_sprout(world, Vector3(0.62, 1.98, 0.05))
	_add_flower(world, Vector3(-0.72, 1.0, 0.25))
	_add_clover(world, Vector3(0.25, 1.99, -0.2))

	var cam := Camera3D.new(); cam.fov = 30.0
	world.add_child(cam)
	cam.look_at_from_position(Vector3(-2.6, 3.4, 5.0), Vector3(0.05, 0.85, 0.0))
	cam.current = true

	for i in 8: await process_frame
	await Kit.snap(root, OUT + "a_block_compat.png")
	# tonemapper comparison (same scene)
	var modes := {"linear": Environment.TONE_MAPPER_LINEAR, "filmic": Environment.TONE_MAPPER_FILMIC,
		"aces": Environment.TONE_MAPPER_ACES, "agx": Environment.TONE_MAPPER_AGX}
	for k in modes:
		env.tonemap_mode = modes[k]
		for i in 3: await process_frame
		await Kit.snap(root, OUT + "a_tonemap_%s.png" % k)
	quit()

func _leaf_mat() -> ShaderMaterial:
	return Kit.prop_material(Color("6cc04a"), Color("2f7a2a"), {"gloss": 0.5, "edge_light": 0.5, "paint_scale": 2.0})

func _add_sprout(parent: Node3D, at: Vector3) -> void:
	var stem := MeshInstance3D.new(); var cm := CylinderMesh.new()
	cm.top_radius = 0.025; cm.bottom_radius = 0.035; cm.height = 0.22; stem.mesh = cm
	stem.position = at + Vector3(0, 0.1, 0); stem.material_override = _leaf_mat(); parent.add_child(stem)
	for s in [-1.0, 1.0]:
		var leaf := MeshInstance3D.new(); var sm := SphereMesh.new(); sm.radius = 0.5; sm.height = 1.0
		leaf.mesh = sm; leaf.scale = Vector3(0.2, 0.05, 0.11)
		leaf.position = at + Vector3(s * 0.1, 0.23, 0.0)
		leaf.rotation_degrees = Vector3(0, 0, s * 28.0)
		leaf.material_override = _leaf_mat(); parent.add_child(leaf)

func _add_flower(parent: Node3D, at: Vector3) -> void:
	var petal := Kit.prop_material(Color("fff6f0"), Color("e6dcf0"), {"gloss": 0.4})
	for k in 5:
		var p := MeshInstance3D.new(); var sm := SphereMesh.new(); sm.radius = 0.5; sm.height = 1.0
		p.mesh = sm; p.scale = Vector3(0.09, 0.03, 0.06)
		var a := TAU * k / 5.0
		p.position = at + Vector3(cos(a) * 0.06, 0, sin(a) * 0.06); p.rotation.y = -a
		p.material_override = petal; parent.add_child(p)
	var c := MeshInstance3D.new(); var cs := SphereMesh.new(); cs.radius = 0.035; cs.height = 0.05
	c.mesh = cs; c.position = at + Vector3(0, 0.015, 0)
	c.material_override = Kit.prop_material(Color("ffd34d"), Color("e09a20")); parent.add_child(c)

func _add_clover(parent: Node3D, at: Vector3) -> void:
	for k in 3:
		var l := MeshInstance3D.new(); var sm := SphereMesh.new(); sm.radius = 0.5; sm.height = 1.0
		l.mesh = sm; l.scale = Vector3(0.1, 0.03, 0.1)
		var a := TAU * k / 3.0
		l.position = at + Vector3(cos(a) * 0.055, 0.0, sin(a) * 0.055)
		l.material_override = _leaf_mat(); parent.add_child(l)
