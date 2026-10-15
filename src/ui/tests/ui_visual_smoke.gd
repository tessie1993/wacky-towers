extends SceneTree
## Reproducible rendering evidence, invoked under tools/visual_qa.py.
## Writes <screen>_<width>.png and <screen>_<width>_vs_ref.png (capture beside its nearest
## style-board reference, art bible 9.6) to production/qa/evidence/full-build/ui/.
## HUD captures sit over a stage stand-in (the meadow painted sky + the real WtTitleIsland
## diorama), not the live WtStage: this harness exercises GameUi only.
const UI := preload("res://src/ui/game_ui.gd")
const Kit := preload("res://src/ui/common/wt_storybook.gd")
const REF := "res://assets/art/reference/style/"
## Nearest reference board per captured screen.
const REFS := {"title": "15_title_and_hud.png", "modes": "05_select_mode_a.jpg", "physics": "08_settings_options_tall.jpg",
	"lobby": "14_tournament_flow.png", "tools": "08_settings_options_tall.jpg", "hud": "15_title_and_hud.png",
	"items": "15_title_and_hud.png", "settings": "04_settings_wide.jpg", "pause": "16_settings_wizard_peek.jpg",
	"results": "14_tournament_flow.png", "profiles": "06_select_mode_b.jpg", "map": "05_select_mode_a.jpg",
	"shop": "04_settings_wide.jpg", "confirm": "16_settings_wizard_peek.jpg"}
const PIECE_A := [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 1, 0)]
const PIECE_B := [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(1, 1, 0)]
const PIECE_C := [Vector3i(0, 0, 0), Vector3i(1, 0, 0)]

var _stage: CanvasLayer

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ui := UI.new()
	root.add_child(ui)
	await process_frame
	var output := ProjectSettings.globalize_path("res://production/qa/evidence/full-build/ui")
	DirAccess.make_dir_recursive_absolute(output)
	var profile := {"has_profile":true,"profile_name":"Clover","stars":42,"wallet":18,"continue_level_name":"Meadow · Stump Day"}
	var shapes := [{"cells": PIECE_A, "tint": Color("4aa8e8")}, {"cells": PIECE_B, "tint": Color("ee6aa0")}, {"cells": PIECE_C, "tint": Color("f8c840")}]
	for viewport_size: Vector2i in [Vector2i(1280, 720), Vector2i(720, 1280)]:
		root.size = viewport_size
		await process_frame
		var w := viewport_size.x
		ui.apply_prefs({"reduced_motion": "off", "text_scale": 1.0, "button_scale": 1.0})
		ui.show_title(profile)
		await _capture(output, "title", w)
		ui.show_modes(profile)
		await _capture(output, "modes", w)
		ui.show_physics({"selected_variant":"domino_chain"})
		await _capture(output, "physics", w)
		ui.show_tournament({"profile_name":"Clover", "character":"c4", "network_status":"hosting", "host":true,"address":"192.168.1.20:24680", "network_players":[{"name":"Clover","character":"c1","perks":["breeze_brake"]},{"name":"LanaFan","character":"c2","perks":["gentle_landing"]},{"name":"Rock","character":"c3","perks":[]},{"name":"Star","character":"c4","perks":["long_look"]}]})
		await _capture(output, "lobby", w)
		ui.show_settings({"prefs": {"music_volume": 0.8, "sfx_volume": 0.6}})
		await _capture(output, "settings", w)
		ui.show_profiles({"profiles":[{"slot":0,"name":"Clover","stars":42,"levels":7,"badge":"cloud"},{"slot":1,"name":"Pip","stars":3,"levels":1,"badge":"bee"}],"active_slot":0})
		await _capture(output, "profiles", w)
		var levels := []
		for i in 8: levels.append({"id":"meadow_%02d" % (i + 1), "number":"%02d" % (i + 1), "name":"Sprout %d" % (i + 1), "stars":i % 4, "unlocked": i < 5})
		ui.show_map({"biome_name":"Meadow","profile_name":"Clover","stars":42,"wallet":18,"biomes":[{"id":"meadow","name":"Meadow","stars":12,"unlocked":true},{"id":"ice","name":"Ice","stars":0,"unlocked":false}],"selected_biome":"meadow","levels":levels,"next_level_id":"meadow_05"})
		await _capture(output, "map", w)
		ui.show_shop({"wallet":18,"items":[{"id":"breeze","name":"Breeze brake","description":"Slows the next gust.","price":10,"kind":"perk"},{"id":"slow","name":"Slow potion","description":"Time drips like honey.","price":30,"kind":"potion","count":1}]})
		await _capture(output, "shop", w)
		_show_stage(true)
		ui.show_tools({"capabilities": {"kit": true, "undo": true, "reset": true, "choose_down": true, "ice_flick": true, "flicks_left": 1}, "kit_choices": [{"shape_id": "mono", "remaining": 2}, {"shape_id": "tri_corner", "remaining": 1}, {"shape_id": "duo", "remaining": 0}], "selection_remaining": 3, "allowed_down": [Vector3i(0,-1,0), Vector3i(-1,0,0), Vector3i(1,0,0)], "allowed_flick": [Vector3i(0,0,-1), Vector3i(0,0,1)]})
		await _capture(output, "tools", w)
		ui.show_hud({"level_name": "Candy Box", "goal": "Fill the toy box", "progress": 2, "target": 4, "score": 280, "time": "0:42", "next_piece": "Tri corner", "next_shapes": shapes, "held_cells": [{"cells": PIECE_C, "tint": Color("6cc04a")}], "held_shape": "Duo", "can_tilt": true, "can_roll": true, "warning": "The next gust comes from the left", "skill_ready": true, "selected_potion": "potion_preview_peek", "potion_count": 2, "capabilities": {"kit": true}})
		await _capture(output, "hud", w)
		ui.show_pause({"level_name": "Candy Box"})
		await _capture(output, "pause", w)
		ui.show_results({"won": true, "level_name": "Candy Box", "stars": 2, "score": 1250, "time": 42.0, "message": "What a wobbly wonder!", "next_available": true})
		await _capture(output, "results", w)
		ui.show_pause({"level_name": "Candy Box"})
		await process_frame
		ui._confirm("Start over?", "This run's progress will be lost.", &"retry")
		await _capture(output, "confirm", w)
		ui.show_hud({"level_name":"Party toy box","goal":"Clear layers","progress":2,"target":5,"score":280,"time":"0:42","next_piece":"Tri corner","next_shapes": shapes,"can_tilt":true,"can_roll":true,"skill_ready":true,"items":{"enabled":true,"slots":[{"id":"slow_time"},{"id":"fog"},{"id":"preview_peek"}],"effects":{"fog":{"remaining_ms":7100,"duration_ms":10000},"slow_time":{"remaining_ms":9100,"duration_ms":10000}}},"selected_item_slot":1,"item_target_available":true})
		await _capture(output, "items", w)
		_show_stage(false)
	ui.queue_free()
	await process_frame
	print("UI_VISUAL_CAPTURE_PASS: title, modes, physics, lobby, settings, profiles, map, shop, tools, HUD, pause, results, confirm, items at 1280x720 and 720x1280, each with a _vs_ref side-by-side")
	quit(0)

## Stage stand-in under the HUD (CanvasLayer below GameUi): meadow sky + the real island.
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
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	var path := "%s/%s_%d.png" % [output, screen, width]
	var error := shot.save_png(path)
	assert(error == OK, "Screenshot failed: " + path)
	_save_vs_ref(shot, screen, "%s/%s_%d_vs_ref.png" % [output, screen, width])

## Capture on the left, its reference board scaled to the same height on the right.
func _save_vs_ref(shot: Image, screen: String, path: String) -> void:
	var ref_path: String = ProjectSettings.globalize_path(REF + String(REFS.get(screen, "05_select_mode_a.jpg")))
	var ref := Image.load_from_file(ref_path)
	if ref == null or ref.is_empty(): return
	shot.convert(Image.FORMAT_RGBA8)
	ref.convert(Image.FORMAT_RGBA8)
	var h := shot.get_height()
	ref.resize(maxi(1, roundi(ref.get_width() * float(h) / ref.get_height())), h, Image.INTERPOLATE_BILINEAR)
	var gap := 16
	var pair := Image.create_empty(shot.get_width() + gap + ref.get_width(), h, false, Image.FORMAT_RGBA8)
	pair.fill(Color("1d1228"))
	pair.blit_rect(shot, Rect2i(Vector2i.ZERO, shot.get_size()), Vector2i.ZERO)
	pair.blit_rect(ref, Rect2i(Vector2i.ZERO, ref.get_size()), Vector2i(shot.get_width() + gap, 0))
	pair.save_png(path)
