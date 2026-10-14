extends SceneTree
## UI v2 evidence: level 1 (minimal) and full HUD at 720x1280 and 1280x720, each beside its reference board.
## Run: xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3 \
##   --script res://tools/qa/ui_v2_capture.gd -- --tag=before
## Writes production/qa/evidence/ui-v2/<tag>_<screen>_<width>.png and ..._vs_ref.png. The HUD sits
## over a stage stand-in (meadow sky + the real WtTitleIsland), as in ui_visual_smoke.
const UI := preload("res://src/ui/game_ui.gd")
const Kit := preload("res://src/ui/common/wt_storybook.gd")
const REF := "res://assets/art/reference/style/"
const REFS := {"title": "15_title_and_hud.png", "modes": "05_select_mode_a.jpg", "hud_level1": "15_title_and_hud.png", "hud_full": "15_title_and_hud.png"}
const PIECE_A := [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 1, 0)]
const PIECE_B := [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(1, 1, 0)]
const PIECE_C := [Vector3i(0, 0, 0), Vector3i(1, 0, 0)]
var _stage: CanvasLayer
var _tag := "after"

func _initialize() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--tag="): _tag = a.trim_prefix("--tag=")
	call_deferred("_run")

func _run() -> void:
	var ui := UI.new()
	root.add_child(ui)
	await process_frame
	var output := ProjectSettings.globalize_path("res://production/qa/evidence/ui-v2")
	DirAccess.make_dir_recursive_absolute(output)
	var profile := {"has_profile": true, "profile_name": "Clover", "stars": 42, "wallet": 18, "continue_level_name": "Meadow · First Sprout"}
	var shapes := [{"cells": PIECE_A, "tint": Color("4aa8e8")}, {"cells": PIECE_B, "tint": Color("ee6aa0")}, {"cells": PIECE_C, "tint": Color("f8c840")}]
	for size: Vector2i in [Vector2i(720, 1280), Vector2i(1280, 720)]:
		root.size = size
		await process_frame
		ui.apply_prefs({"reduced_motion": "on", "text_scale": 1.0, "button_scale": 1.0})
		_show_stage(true)
		var level1 := {"level_name": "Meadow · First Sprout", "biome": "meadow", "goal": "Plant the first course", "progress": 1, "target": 2, "score": 1250, "time": "0:42", "next_piece": "O", "next_shapes": shapes, "held_cells": [], "can_tilt": false, "can_roll": false, "capabilities": {},
			"hud": {"show": ["pause", "goal", "next", "meter"], "meter": {"label": "Hearth Hum", "label_key": "HUD_METER_HEARTH_HUM", "source": "goal_progress"}}}
		ui.show_hud(level1)
		await _capture(output, "hud_level1", size.x)
		var full := level1.duplicate(true)
		full.erase("hud")
		full["can_tilt"] = true
		full["can_roll"] = true
		full["skill_charge"] = 400
		full["potion_count"] = 2
		full["selected_potion"] = "slow_time"
		full["held_cells"] = [{"cells": PIECE_C, "tint": Color("6cc04a")}]
		full["capabilities"] = {"kit": true}
		ui.show_hud(full)
		await _capture(output, "hud_full", size.x)
		_show_stage(false)
	ui.queue_free()
	await process_frame
	print("UI_V2_CAPTURE_DONE ", _tag)
	quit(0)

func _show_stage(on: bool) -> void:
	if is_instance_valid(_stage):
		_stage.queue_free()
		_stage = null
	if not on: return
	_stage = CanvasLayer.new()
	_stage.layer = -5
	root.add_child(_stage)
	var sky := Kit.backdrop("meadow", 0.0)
	_stage.add_child(sky)
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var island := WtTitleIsland.new()
	island.turn_speed = 0.0
	_stage.add_child(island)
	island.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	island.anchor_top = 0.22
	island.anchor_bottom = 0.78
	island.anchor_left = 0.18
	island.anchor_right = 0.82

func _capture(output: String, screen: String, width: int) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	shot.save_png("%s/%s_%s_%d.png" % [output, _tag, screen, width])
	var ref := Image.load_from_file(ProjectSettings.globalize_path(REF + String(REFS[screen])))
	if ref == null or ref.is_empty(): return
	shot.convert(Image.FORMAT_RGBA8)
	ref.convert(Image.FORMAT_RGBA8)
	var h := shot.get_height()
	ref.resize(maxi(1, roundi(ref.get_width() * float(h) / ref.get_height())), h, Image.INTERPOLATE_BILINEAR)
	var pair := Image.create_empty(shot.get_width() + 16 + ref.get_width(), h, false, Image.FORMAT_RGBA8)
	pair.fill(Color("1d1228"))
	pair.blit_rect(shot, Rect2i(Vector2i.ZERO, shot.get_size()), Vector2i.ZERO)
	pair.blit_rect(ref, Rect2i(Vector2i.ZERO, ref.get_size()), Vector2i(shot.get_width() + 16, 0))
	pair.save_png("%s/%s_%s_%d_vs_ref.png" % [output, _tag, screen, width])
