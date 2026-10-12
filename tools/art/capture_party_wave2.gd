## Renders every WtMinigameArt party toy in its own SubViewport with the same
## orthographic camera and lights as MinigameUI.make_art_preview, saves one PNG per
## toy and two contact sheets into production/qa/evidence/party_wave2/:
##   party_wave2_contact_sheet.png   - MG22-MG36 (the new toys)
##   party_wave1_regression_sheet.png - MG01-MG21 (unchanged toys, regression check)
##   party_art_gallery_all36.png     - src/view/wt_party_art_gallery.tscn with all 36
## Needs a real renderer: the headless display driver uses a dummy rasteriser and
## produces blank images. Run under X, e.g.
##   xvfb-run -a godot --path . --rendering-driver opengl3 \
##     --rendering-method gl_compatibility -s res://tools/art/capture_party_wave2.gd
extends SceneTree

const Art := preload("res://src/view/wt_minigame_art.gd")
const OUT_DIR: String = "res://production/qa/evidence/party_wave2/"
const CELL: Vector2i = Vector2i(480, 400)
const COLUMNS: int = 5


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	print("PARTY_WAVE2_CAPTURE renderer=", RenderingServer.get_current_rendering_method(), " adapter=", RenderingServer.get_video_adapter_name())
	var wave2: Array[Image] = []
	var wave1: Array[Image] = []
	for n: int in range(1, 37):
		var id: String = "mg%02d" % n
		var image: Image = await _render(id)
		if n >= 22:
			image.save_png(OUT_DIR + "party_%s_%s.png" % [id, Art.THEMES[id].prop])
			wave2.append(image)
		else:
			wave1.append(image)
	_sheet(wave2).save_png(OUT_DIR + "party_wave2_contact_sheet.png")
	_sheet(wave1).save_png(OUT_DIR + "party_wave1_regression_sheet.png")
	var gallery: Image = await _render_gallery()
	gallery.save_png(OUT_DIR + "party_art_gallery_all36.png")
	var blank: int = 1 if _is_flat(gallery) else 0
	for image: Image in wave2:
		if _is_flat(image):
			blank += 1
	print("PARTY_WAVE2_CAPTURE saved=%d flat_images=%d" % [wave2.size(), blank])
	quit(1 if blank > 0 else 0)


func _render(id: String) -> Image:
	var viewport := SubViewport.new()
	viewport.size = CELL
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#E5E5E0")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("c7e6e4")
	environment.ambient_light_energy = .7
	var world := WorldEnvironment.new()
	world.environment = environment
	viewport.add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -35, 0)
	light.light_color = Color("fff0d1")
	light.light_energy = 1.5
	viewport.add_child(light)
	viewport.add_child(Art.create(id))
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.5
	viewport.add_child(camera)
	camera.look_at_from_position(Vector3(3.5, 3, 4.5), Vector3(0, 1.1, 0))
	camera.current = true
	var label := Label.new()
	label.text = "%s  %s  (%s)" % [id.to_upper(), Art.THEMES[id].name, Art.THEMES[id].verb]
	label.position = Vector2(12, 8)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("#304652"))
	viewport.add_child(label)
	for i: int in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = viewport.get_texture().get_image()
	image.convert(Image.FORMAT_RGB8)
	viewport.queue_free()
	return image


func _render_gallery() -> Image:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1800, 1500)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	viewport.add_child((load("res://src/view/wt_party_art_gallery.tscn") as PackedScene).instantiate())
	for i: int in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = viewport.get_texture().get_image()
	image.convert(Image.FORMAT_RGB8)
	viewport.queue_free()
	return image


func _sheet(images: Array[Image]) -> Image:
	var rows: int = ceili(images.size() / float(COLUMNS))
	var sheet := Image.create(CELL.x * COLUMNS, CELL.y * rows, false, Image.FORMAT_RGB8)
	sheet.fill(Color("#B9BDB8"))
	for i: int in images.size():
		var at := Vector2i((i % COLUMNS) * CELL.x, (i / COLUMNS) * CELL.y)
		sheet.blit_rect(images[i], Rect2i(Vector2i(2, 2), CELL - Vector2i(4, 4)), at + Vector2i(2, 2))
	return sheet


func _is_flat(image: Image) -> bool:
	# Skips the label strip so text alone cannot pass as a rendered toy.
	var first: Color = image.get_pixel(0, image.get_height() - 1)
	for y: int in range(48, image.get_height(), 16):
		for x: int in range(0, image.get_width(), 16):
			if not image.get_pixel(x, y).is_equal_approx(first):
				return false
	return true
