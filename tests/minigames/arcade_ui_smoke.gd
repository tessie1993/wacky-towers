extends SceneTree
## Story type: Integration / UI. Evidence: production/qa/evidence/arcade_pack.
## BLOCKING graphical smoke; requires a real display, not --headless.
## Solvers use only reachable semantic actions and the public simulation clock.

const HUB = preload("res://minigames/arcade_pack/arcade_hub.tscn")
const WALL = preload("res://minigames/arcade_pack/models/wall_round.gd")
const EVIDENCE: String = "res://production/qa/evidence/arcade_pack/"

var hub: Node3D
var failures: Array[String] = []
var original_save: PackedByteArray = PackedByteArray()
var save_existed: bool = false
var capture_count: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Arcade UI smoke needs a graphical display; headless is not visual evidence.")
		quit(2)
		return
	save_existed = FileAccess.file_exists("user://wt_arcade_pack.cfg")
	if save_existed:
		original_save = FileAccess.get_file_as_bytes("user://wt_arcade_pack.cfg")
	hub = HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await _draw_frames()
	_expect(hub.levels.size() == 9, "Hub must expose all nine stages")
	await _capture("hub")
	_check_controls_fit("hub")
	hub.show_briefing(hub.levels[0])
	await _capture("briefing")
	_check_controls_fit("briefing")
	hub.start_selected()
	await _draw_frames()
	await _key(KEY_P)
	_expect(hub.paused and hub._pause_panel.visible, "P must open pause panel")
	await _key(KEY_P, true)
	_expect(hub.paused, "Pause-key repeat must not resume the round")
	var stopped_at: float = hub.round_model.elapsed
	var paused_score: int = hub.round_model.score
	hub.send_action("primary")
	await _draw_frames()
	_expect(is_equal_approx(stopped_at, hub.round_model.elapsed)
		and paused_score == hub.round_model.score, "Pause freezes time and gameplay actions")
	await _capture("pause")
	_check_controls_fit("pause")
	await _key(KEY_P)
	_expect(not hub.paused, "P must resume from pause")
	var old_round = hub.round_model
	await _key(KEY_R)
	_expect(hub.round_model != old_round and hub.round_model.score == 0,
		"R must create a fresh active model")
	await _key(KEY_SPACE)
	_expect(hub.round_model.score == 1 and hub.round_model.slide_axis == 2,
		"Actual Space key must lock one slab and alternate the next slide")
	hub.set_process(false)
	for level: Dictionary in hub.levels:
		hub.show_briefing(level)
		await _draw_frames()
		_check_controls_fit("briefing_" + String(level.id))
		if String(level.id) == "stack_celestial":
			await _capture("briefing_stack_celestial")
		hub.start_selected()
		match String(level.mode):
			"stack":
				await _play_stack(level)
			"wall":
				await _play_wall(level)
			"shadow":
				await _play_shadow(level)
		_expect(hub.screen == "result" and bool(hub.last_result.get("won", false)),
			"Public gameplay path must win " + String(level.id))
		_expect(String(hub.last_result.get("level_id", "")) == String(level.id),
			"Result keeps the stable level ID: " + String(level.id))
		if String(level.id) == "wall_gear_courier":
			_expect(int(hub.last_result.get("stars", 0)) == 3
				and int(hub.last_result.get("score", 0)) == int(level.pass_target) * 3,
				"Clockwork can earn every manual beat bonus together with three stars")
		var terminal: Dictionary = hub.last_result.duplicate(true)
		hub.send_action("primary")
		hub.send_action("undo")
		_expect(hub.last_result == terminal and hub.screen == "result",
			"Finished hub rejects semantic gameplay: " + String(level.id))
		if String(level.id) == "stack_meadow":
			await _capture("result_win")
			_check_controls_fit("result_win")
		await _draw_frames()
	hub.show_briefing(hub.levels[0])
	await _draw_frames()
	hub.start_selected()
	# Immediate edge locks naturally narrow X, then Z; the third slab misses.
	for _attempt in range(4):
		if hub.screen != "play":
			break
		hub.send_action("primary")
	_expect(hub.screen == "result" and not bool(hub.last_result.get("won", true)),
		"An actual unsupported stack lock must display a failure")
	await _capture("result_fail")
	_check_controls_fit("result_fail")
	await _key(KEY_R)
	_expect(hub.screen == "play" and hub.round_model.score == 0,
		"Actual R input must restart a failed round")
	_restore_save()
	for failure: String in failures:
		push_error(failure)
	print("ARCADE GRAPHICAL SMOKE: ", "PASS" if failures.is_empty() else "FAIL",
		" (", failures.size(), " failures, ", capture_count, " retained captures)")
	quit(0 if failures.is_empty() else 1)


func _play_stack(level: Dictionary) -> void:
	var captured: bool = false
	var max_ticks: int = int(float(level.time_limit) * 120.0) + 1
	for _tick in range(max_ticks):
		if hub.screen != "play":
			break
		hub.round_model.advance(1.0 / 120.0)
		var axis: int = hub.round_model.slide_axis
		if absf(hub.round_model.active_center[axis] - hub.round_model.spawn_origin[axis]) < float(level.perfect_tolerance) * 0.75:
			hub.send_action("primary")
		if not captured and hub.round_model.score >= 3:
			hub._refresh_world()
			await _capture("play_" + String(level.id))
			_check_controls_fit(String(level.id))
			captured = true
	_expect(captured, "Stack screenshot captured during actual play: " + String(level.id))


func _play_wall(level: Dictionary) -> void:
	var captured: bool = false
	var limit: int = int(level.pass_target) + int(level.miss_limit) + 1
	for gate in range(limit):
		if hub.screen != "play":
			break
		var path: Array = _wall_solution_path(hub.round_model)
		_expect(not path.is_empty(), "Wall generated a publicly reachable pose: " + String(level.id))
		if path.is_empty():
			break
		for action: String in path:
			if action != "ready":
				hub.send_action(action)
		if not captured and (gate >= 1 or int(level.pass_target) == 1):
			hub._refresh_world()
			await _capture("play_" + String(level.id))
			_check_controls_fit(String(level.id))
			captured = true
		# Manual on-beat sends exercise the actual bonus boundary and axis changes.
		var window: float = float(level.get("rhythm_window", 0.0))
		if window > 0.0:
			hub.round_model.advance(maxf(0.0, hub.round_model.wall_duration - hub.round_model.wall_age - window * 0.5))
		hub.send_action("primary")
	_expect(captured, "Wall screenshot captured during actual play: " + String(level.id))


func _wall_solution_path(model) -> Array:
	var queue: Array[Dictionary] = [{"piece": model.piece.duplicate(), "offset": model.offset, "path": []}]
	var seen: Dictionary = {}
	var index: int = 0
	var frame: int = int(model.config.frame_size)
	while index < queue.size():
		var state: Dictionary = queue[index]
		index += 1
		var key: String = WALL.cell_key(state.piece) + ":" + str(state.offset)
		if seen.has(key):
			continue
		seen[key] = true
		if WALL.fit_projection(WALL.project_cells(state.piece, model.axis, state.offset), model.hole, model.hole_core).perfect:
			return state.path if not state.path.is_empty() else ["ready"]
		for action: String in ["rotate_x", "rotate_y", "left", "right", "up", "down"]:
			var cells: Array = state.piece
			var translation: Vector2i = state.offset
			match action:
				"rotate_x": cells = WALL.rotate_cells(cells, "x")
				"rotate_y": cells = WALL.rotate_cells(cells, "y")
				"left": translation.x -= 1
				"right": translation.x += 1
				"up": translation.y += 1
				"down": translation.y -= 1
			var bounds: Vector2i = WALL.projection_size(cells, model.axis)
			translation.x = clampi(translation.x, 0, maxi(0, frame - bounds.x))
			translation.y = clampi(translation.y, 0, maxi(0, frame - bounds.y))
			var path: Array = state.path.duplicate()
			path.append(action)
			queue.append({"piece": cells, "offset": translation, "path": path})
	return []


func _play_shadow(level: Dictionary) -> void:
	var captured: bool = false
	for puzzle: Dictionary in level.puzzles:
		var placed: int = 0
		for cell: Array in puzzle.solution:
			if hub.screen != "play":
				break
			_move_shadow_cursor(Vector3i(int(cell[0]), int(cell[1]), int(cell[2])))
			hub.send_action("primary")
			placed += 1
			if not captured and placed == 2:
				await _key(KEY_C)
				_expect(hub._view_k == 0, "Shadow view key must preserve both target panels")
				await _capture("play_" + String(level.id))
				_check_controls_fit(String(level.id))
				captured = true
	_expect(captured, "Shadow screenshot captured during construction: " + String(level.id))


func _move_shadow_cursor(target: Vector3i) -> void:
	while hub.round_model.cursor.x != target.x:
		hub.send_action("right" if hub.round_model.cursor.x < target.x else "left")
	while hub.round_model.cursor.z != target.z:
		hub.send_action("down" if hub.round_model.cursor.z < target.z else "up")
	while hub.round_model.cursor.y != target.y:
		hub.send_action("rotate_y" if hub.round_model.cursor.y < target.y else "rotate_x")


func _key(keycode: int, repeated: bool = false) -> void:
	var press: InputEventKey = InputEventKey.new()
	press.physical_keycode = keycode
	press.keycode = keycode
	press.pressed = true
	press.echo = repeated
	Input.parse_input_event(press)
	await _draw_frames()
	var release: InputEventKey = InputEventKey.new()
	release.physical_keycode = keycode
	release.keycode = keycode
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame


func _draw_frames() -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw


func _capture(name: String) -> void:
	# The manual simulation clock does not run the host's particle clock.
	# Retain uncluttered play evidence rather than frozen sparks from old gates.
	if name.begins_with("play_"):
		hub._tick_sparkles(1.1)
	await _draw_frames()
	var capture: Image = root.get_texture().get_image()
	_expect(capture != null and capture.get_width() >= 1280 and capture.get_height() >= 720,
		"Graphical viewport has a real full-size image: " + name)
	if capture == null:
		return
	var result: Error = capture.save_png(EVIDENCE + "godot_" + name + ".png")
	_expect(result == OK, "Screenshot saved: " + name)
	capture_count += 1
	print("ARCADE CAPTURE ", name, " ", capture.get_width(), "x", capture.get_height())


func _check_controls_fit(screen_name: String) -> void:
	var extent: Vector2 = root.get_visible_rect().size
	if hub.screen == "play":
		var metric_rect: Rect2 = hub._metric.get_global_rect()
		var clock_rect: Rect2 = hub._timer.get_global_rect()
		_expect(clock_rect.position.x - metric_rect.end.x >= 30.0,
			"Metric and clock have an unmistakable gap on " + screen_name)
	for node: Node in hub._content.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if not control.is_visible_in_tree():
			continue
		var rect: Rect2 = control.get_global_rect()
		if control is Label and control.autowrap_mode == TextServer.AUTOWRAP_OFF and not control.clip_text:
			_expect(control.size.x >= control.get_minimum_size().x - 1.0,
				"Unwrapped label fits its rectangle on %s: %s" % [screen_name, control.name])
		_expect(rect.position.x >= -1.0 and rect.position.y >= -1.0
			and rect.end.x <= extent.x + 1.0 and rect.end.y <= extent.y + 1.0,
			"Visible control fits viewport on %s: %s %s" % [screen_name, control.name, str(rect)])


func _restore_save() -> void:
	if save_existed:
		var file: FileAccess = FileAccess.open("user://wt_arcade_pack.cfg", FileAccess.WRITE)
		if file != null:
			file.store_buffer(original_save)
		else:
			failures.append("Could not restore pre-smoke practice bests")
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://wt_arcade_pack.cfg"))


func _expect(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)
