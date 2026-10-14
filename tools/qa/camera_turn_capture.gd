extends Node
## QA capture for the camera turn polish: starts meadow_01 through main, freezes the sim, places a few
## locked pieces, turns the view one snap and saves an 8-frame contact sheet (frame every 2 process frames,
## run with --fixed-fps 60 so a frame is 16.7 ms).
## Run: timeout 300 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3 \
##   --resolution 720x1280 --fixed-fps 60 res://tools/qa/camera_turn_capture.tscn
const OUT := "res://production/qa/evidence/camera-v2/"
const FRAMES := 8
const EVERY := 2

func _ready() -> void:
	_run.call_deferred()

func _frames(n: int) -> void:
	for i: int in n: await get_tree().process_frame

func _grab() -> Image:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	return img

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var main: Node = load("res://src/app/main.tscn").instantiate()
	add_child(main)
	await _frames(20)
	var store: Object = main.get("_store")
	if store.call("active_profile") == null: store.call("create", "QA Camera")
	main.set("_smoke", true)
	main.call("_start_level", &"meadow_01")
	main.set_physics_process(false)
	await _frames(30)
	var stage: Node = main.get("_stage")
	var size: Vector2i = get_viewport().get_visible_rect().size
	(await _grab()).save_png(OUT + "framing_%dx%d.png" % [size.x, size.y])
	var shots: Array[Image] = []
	stage.call("rotate_view", 1)
	for i: int in FRAMES:
		await _frames(EVERY)
		shots.append(await _grab())
	var tw: int = size.x / 2
	var th: int = size.y / 2
	var sheet: Image = Image.create(tw * 4, th * 2, false, Image.FORMAT_RGBA8)
	for i: int in shots.size():
		var s: Image = shots[i]
		s.resize(tw, th, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(s, Rect2i(0, 0, tw, th), Vector2i((i % 4) * tw, (i / 4) * th))
	sheet.save_png(OUT + "turn_strip_%dx%d.png" % [size.x, size.y])
	print("TURN_STRIP ", OUT)
	get_tree().quit()
