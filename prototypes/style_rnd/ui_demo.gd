extends SceneTree
## Style R&D prototype (b): Blender-rendered purple-wood frame used as a Godot nine-patch at
## three sizes (wide panel, tall panel, HUD chip) + multicolour 3D title text. Compatibility.
## Run: timeout 240 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3 \
##      --resolution 1280x720 -s res://prototypes/style_rnd/ui_demo.gd
const Kit := preload("res://prototypes/style_rnd/style_kit.gd")
const OUT := "res://production/qa/evidence/style-rnd/"
const SRC := "res://prototypes/style_rnd/renders/frame_purple_vine.png"

func _initialize() -> void:
	_run()

func _run() -> void:
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://prototypes/style_rnd/renders/frame_purple_vine.json"))
	var margin: int = int(meta.margin_left)
	var tex512 := Kit.load_tex(SRC, 512)
	var tex256 := Kit.load_tex(SRC, 256)
	var lilita := Kit.load_font("res://prototypes/style_rnd/fonts/LilitaOne-Regular.ttf")
	var fredoka := Kit.load_font("res://assets/fonts/fredoka/fredoka-700.woff2")

	var ui := Control.new(); ui.size = Vector2(1280, 720); root.add_child(ui)
	# painted backdrop stand-in: warm vertical gradient
	var bg := TextureRect.new(); var gt := GradientTexture2D.new(); var g := Gradient.new()
	g.set_color(0, Color("f7c97a")); g.set_color(1, Color("b58ad0"))
	gt.gradient = g; gt.fill_from = Vector2(0, 0); gt.fill_to = Vector2(0, 1); gt.width = 64; gt.height = 64
	bg.texture = gt; bg.size = ui.size; bg.stretch_mode = TextureRect.STRETCH_SCALE; bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ui.add_child(bg)

	# Wide panel (ref 04 proportions)
	var wide := Kit.frame_patch(tex512, margin, 1024)
	wide.position = Vector2(40, 120); wide.size = Vector2(700, 540); ui.add_child(wide)
	var t1 := Kit.title_text("SETTINGS", lilita, 92)
	t1.position = Vector2(390 - t1.size.x / 2, 40); ui.add_child(t1)
	var rows := ["MUSIC", "SOUND FX", "VIBRATION"]
	for i in rows.size():
		var l := Kit.label(rows[i], fredoka, 30)
		l.position = Vector2(200, 260 + i * 90); ui.add_child(l)

	# Tall panel (ref 08 proportions)
	var tall := Kit.frame_patch(tex512, margin, 1024)
	tall.position = Vector2(790, 150); tall.size = Vector2(300, 520); ui.add_child(tall)
	var t2 := Kit.title_text("OPTIONS", lilita, 54, 5)
	t2.position = Vector2(940 - t2.size.x / 2, 90); ui.add_child(t2)

	# HUD chip (ref 15 SCORE chip) from the same render, downscaled
	var chip := Kit.frame_patch(tex256, margin, 1024)
	chip.position = Vector2(1110, 160); chip.size = Vector2(150, 130); ui.add_child(chip)
	var sl := Kit.label("SCORE", fredoka, 18); sl.position = Vector2(1155, 195); ui.add_child(sl)
	var sv := Kit.label("1,250", lilita, 30); sv.position = Vector2(1150, 218); ui.add_child(sv)

	for i in 6: await process_frame
	await Kit.snap(root, OUT + "b_ninepatch_ui.png")
	quit()
