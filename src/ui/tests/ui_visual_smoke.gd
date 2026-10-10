extends SceneTree
## Reproducible rendering evidence, invoked under tools/visual_qa.py.
const UI := preload("res://src/ui/game_ui.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ui := UI.new()
	root.add_child(ui)
	await process_frame
	var output := ProjectSettings.globalize_path("res://production/qa/evidence/full-build/ui")
	DirAccess.make_dir_recursive_absolute(output)
	for viewport_size: Vector2i in [Vector2i(1280, 720), Vector2i(720, 1280)]:
		root.size = viewport_size
		await process_frame
		ui.apply_prefs({"reduced_motion": "off", "text_scale": 1.0, "button_scale": 1.0})
		ui.show_title({"has_profile":true,"profile_name":"Clover","stars":42,"wallet":18,"continue_level_name":"Meadow · First Sprout"})
		await _capture(output + "/title_%d.png" % viewport_size.x)
		ui.show_physics({"selected_variant":"domino_chain"})
		await _capture(output + "/physics_%d.png" % viewport_size.x)
		ui.show_tournament({"profile_name":"Clover", "character":"c4", "network_status":"hosting", "host":true,"address":"192.168.1.20:24680", "network_players":[{"name":"Clover","character":"c1","perks":["breeze_brake"]},{"name":"LanaFan","character":"c2","perks":["gentle_landing"]},{"name":"Rock","character":"c3","perks":[]},{"name":"Star","character":"c4","perks":["long_look"]}]})
		await _capture(output + "/lobby_%d.png" % viewport_size.x)
		ui.show_story({"story_key": "finale", "phase": "post", "beats": [{"left": "cloud", "right": "mizzle", "emote_left": "heart", "emote_right": "blush", "symbol": "invite", "pose_left": "give", "pose_right": "approach", "duration": 8, "props": ["chair", "star", "basket"], "guests": ["miller", "meringue", "sniffles", "crab", "smolder", "oak", "geode", "cuckoo", "mirrorball", "moon"]}]})
		await _capture(output + "/story_%d.png" % viewport_size.x)
		ui.show_tools({"capabilities": {"kit": true, "undo": true, "reset": true, "choose_down": true, "ice_flick": true, "flicks_left": 1}, "kit_choices": [{"shape_id": "mono", "remaining": 2}, {"shape_id": "tri_corner", "remaining": 1}, {"shape_id": "duo", "remaining": 0}], "selection_remaining": 3, "allowed_down": [Vector3i(0,-1,0), Vector3i(-1,0,0), Vector3i(1,0,0)], "allowed_flick": [Vector3i(0,0,-1), Vector3i(0,0,1)]})
		await _capture(output + "/tools_%d.png" % viewport_size.x)
		ui.show_hud({"level_name": "Candy Box", "goal": "Fill the toy box", "progress": 2, "target": 4, "score": 280, "time": "0:42", "next_piece": "Tri corner", "held_shape": "Duo", "can_tilt": true, "can_roll": true, "warning": "The next gust comes from the left", "skill_ready": true, "selected_potion": "potion_preview_peek", "potion_count": 2, "capabilities": {"kit": true}})
		await _capture(output + "/hud_%d.png" % viewport_size.x)
	ui.queue_free()
	await process_frame
	print("UI_VISUAL_CAPTURE_PASS: title, physics, lobby, story, tools and HUD at 1280x720 and 720x1280")
	quit(0)

func _capture(path: String) -> void:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(path)
	assert(error == OK, "Screenshot failed: " + path)
