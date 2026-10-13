extends SceneTree
const Kit := preload("res://prototypes/style_rnd/style_kit.gd")
func _initialize() -> void: _run()
func _run() -> void:
	var world := Node3D.new(); root.add_child(world)
	var we := WorldEnvironment.new(); world.add_child(we)
	var cam := Camera3D.new(); world.add_child(cam); cam.look_at_from_position(Vector3(10, 10, 10), Vector3.ZERO); cam.current = true
	for mode in ["color", "c_noglow", "c_noadj", "c_linear", "c_bare"]:
		var env: Environment = Kit.make_environment("meadow")
		if mode == "kit_nofog": env.fog_enabled = false
		if mode == "procedural": env.fog_enabled = false; env.sky = Sky.new(); env.sky.sky_material = ProceduralSkyMaterial.new()
		env.background_mode = Environment.BG_COLOR; env.background_color = Color(0.2, 0.4, 0.9)
		if mode == "c_noglow": env.glow_enabled = false
		if mode == "c_noadj": env.adjustment_enabled = false
		if mode == "c_linear": env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
		if mode == "c_bare": env.glow_enabled = false; env.adjustment_enabled = false; env.fog_enabled = false; env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
		we.environment = env
		for i in 4: await process_frame
		await RenderingServer.frame_post_draw
		var img := root.get_texture().get_image()
		print(mode, " top=", img.get_pixel(640, 20), " mid=", img.get_pixel(640, 360), " bottom=", img.get_pixel(640, 700))
	quit()
