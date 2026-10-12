extends Node3D
## Independent arcade launcher. Owns presentation, input, pause and local bests only.

const ROOT: String = "res://minigames/arcade_pack/"
const MODEL_PATHS: Dictionary = {"stack": "stack_round.gd", "wall": "wall_round.gd", "shadow": "shadow_round.gd"}
const MODES: Array[String] = ["stack", "wall", "shadow"]
const TITLES: Dictionary = {"stack": "Perfect Stack", "wall": "Parcel Gates", "shadow": "Shadow Workshop"}
const VERBS: Dictionary = {"stack": "TIME THE DROP", "wall": "ROTATE TO FIT", "shadow": "BUILD THE LIGHT"}
const PALETTE: Array[Color] = [Color("f5dd6a"), Color("9fd65b"), Color("5dcb9e"), Color("6ea4f0"), Color("a78beb"), Color("ffb48c")]
const INK: Color = Color("2e2433")
const PAPER: Color = Color("fff4de")
const GOLD: Color = Color("ffc83d")
const SAVE_PATH: String = "user://wt_arcade_pack.cfg"

var screen: String = "menu"
var levels: Array[Dictionary] = []
var selected: Dictionary = {}
var round_model: Variant = null
var paused: bool = false
var last_result: Dictionary = {}
var bests: ConfigFile = ConfigFile.new()
var _camera: Camera3D
var _stage: Node3D
var _pool: Array[MeshInstance3D] = []
var _materials: Dictionary = {}
var _cube: Mesh
var _ui: Control
var _content: Control
var _metric: Label
var _status: Label
var _timer: Label
var _progress: ProgressBar
var _level_title: Label
var _pause_panel: Control
var _view_k: int = 0
var _snapshot: Dictionary = {}
var _panel_labels: Array[Label3D] = []
var _camera_target: Vector3 = Vector3(0, 2, 0)
var _last_score: int = 0
var _sparkles: Array[Dictionary] = []
var _audio: AudioStreamPlayer
var _wall_map: Control


func _ready() -> void:
	_load_levels()
	bests.load(SAVE_PATH)
	_build_world()
	_build_ui()
	show_menu()


## Returns to the hub without changing the repository's main scene.
func show_menu() -> void:
	screen = "menu"
	paused = false
	round_model = null
	_hide_blocks()
	_set_stage("meadow")
	_camera.size = 15.0
	_camera.position = Vector3(13, 11, 15)
	_camera.look_at(Vector3(0, 0.5, 0))
	_clear_ui()
	var panel: PanelContainer = _panel()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 32
	panel.offset_top = 28
	panel.offset_right = -32
	panel.offset_bottom = -28
	_content.add_child(panel)
	var column: VBoxContainer = _column(panel, 10)
	column.add_child(_label("WACKY TOWERS  /  ARCADE", 16, Color("795d86")))
	column.add_child(_label("Toy-Box Trials", 34))
	column.add_child(_label("Nine tiny challenges. Three ways to master the blocks.", 19))
	var cards: HBoxContainer = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 18)
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(cards)
	for i: int in MODES.size():
		var mode: String = MODES[i]
		var card: PanelContainer = _panel(PALETTE[i + 2].lightened(0.68))
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cards.add_child(card)
		var contents: VBoxContainer = _column(card, 8)
		contents.add_child(_label("0%d  /  %s" % [i + 1, VERBS[mode]], 14, Color("795d86")))
		contents.add_child(_label(TITLES[mode], 27))
		var summary: String = {"stack": "Catch the rhythm. Trim the overhang. Spend a snap charge when the wind bites.", "wall": "Turn your parcel to match each gate. Read the axis, then pick your moment.", "shadow": "Two silhouettes, one sculpture. Place cubes and discover another solution."}[mode]
		contents.add_child(_label(summary, 16))
		var spacer: Control = Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		contents.add_child(spacer)
		var number: int = 0
		for level: Dictionary in levels:
			if String(level.get("mode", "")) != mode:
				continue
			number += 1
			var stars: int = int(bests.get_value(String(level.id), "stars", 0))
			var title: String = "%d  %s%s" % [number, String(level.name), "  " + "★".repeat(stars) if stars > 0 else ""]
			var button: Button = _button(title, func(): show_briefing(level), number == 1)
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			contents.add_child(button)
	var footer: HBoxContainer = HBoxContainer.new()
	column.add_child(footer)
	var hint: Label = _label("Keyboard + on-screen controls  ·  All chapters are open", 15)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(hint)
	footer.add_child(_button("Original game", _return_original))
	_focus_first()


## Displays story, objective and controls before starting a level.
func show_briefing(level: Dictionary) -> void:
	selected = level.duplicate(true)
	screen = "briefing"
	paused = false
	round_model = null
	_hide_blocks()
	_set_stage(String(selected.get("biome", "meadow")))
	_clear_ui()
	var panel: PanelContainer = _center_panel(760, 490)
	var column: VBoxContainer = _column(panel, 16)
	column.add_child(_label("%s  /  %s" % [String(selected.get("biome", "meadow")).to_upper(), VERBS.get(selected.mode, "PLAY")], 15, Color("795d86")))
	column.add_child(_label(String(selected.name), 34))
	column.add_child(_label(String(selected.get("rule", "")), 20))
	column.add_child(_label(String(selected.get("objective", selected.get("rule", ""))), 19))
	column.add_child(_label("Twist: " + String(selected.get("twist", selected.get("rule", ""))), 17))
	column.add_child(_label(String(selected.get("controls", "Space to play")), 17, Color("795d86")))
	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	var actions: HBoxContainer = HBoxContainer.new()
	column.add_child(actions)
	actions.add_child(_button("← All challenges", show_menu))
	var play: Button = _button("Let's play  →", start_selected, true)
	actions.add_child(play)
	_focus_if_ready.call_deferred(play)


## Creates a fresh model instance so retry never keeps stale state or signals.
func start_selected() -> void:
	if selected.is_empty():
		return
	var script: Script = load(ROOT + "models/" + String(MODEL_PATHS[selected.mode]))
	round_model = script.new()
	round_model.round_finished.connect(_round_finished)
	round_model.start(selected, int(selected.get("seed", 1)))
	screen = "play"
	paused = false
	_view_k = 0
	last_result = {}
	_last_score = 0
	_camera_target = Vector3(0, 2, 0)
	_set_stage(String(selected.get("biome", "meadow")))
	_build_hud()
	_refresh_world()


## Sends semantic input only while the active round is playing and unpaused.
func send_action(action: String) -> void:
	if screen == "play" and not paused and round_model != null:
		round_model.act(action)
		_refresh_world()


## Pauses model time and prevents actions; restarting remains available.
func toggle_pause() -> void:
	if screen != "play":
		return
	paused = not paused
	if is_instance_valid(_pause_panel):
		_pause_panel.visible = paused
	if paused:
		_pause_panel.get_node("Margin/Column/Resume").grab_focus()


func _process(delta: float) -> void:
	_tick_sparkles(delta)
	if screen == "play" and round_model != null:
		if not paused:
			round_model.advance(delta)
		_refresh_world()


func _notification(what: int) -> void:
	# The host main scene disables auto-accept quit; this separate scene owns it.
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	if event.echo and key in [KEY_ESCAPE, KEY_P, KEY_R, KEY_Z, KEY_C, KEY_ENTER]:
		return
	if key == KEY_ESCAPE or key == KEY_P:
		if screen == "play":
			toggle_pause()
		else:
			show_menu()
	elif key == KEY_ENTER and screen == "briefing":
		start_selected()
	elif key == KEY_R and (screen == "play" or screen == "result"):
		start_selected()
	elif screen == "play" and not paused:
		var actions: Dictionary = {KEY_SPACE: "primary", KEY_LEFT: "left", KEY_A: "left", KEY_RIGHT: "right", KEY_D: "right", KEY_UP: "up", KEY_W: "up", KEY_DOWN: "down", KEY_S: "down", KEY_E: "rotate_y", KEY_Q: "rotate_x", KEY_U: "undo"}
		if actions.has(key) and (not event.echo or String(actions[key]) in ["left", "right", "up", "down"]):
			send_action(String(actions[key]))
		elif (key == KEY_C or key == KEY_Z) and String(selected.mode) != "shadow":
			_view_k = posmod(_view_k + (1 if key == KEY_C else -1), 4)
	get_viewport().set_input_as_handled()


func _load_levels() -> void:
	var directory: DirAccess = DirAccess.open(ROOT + "levels")
	if directory == null:
		push_error("Arcade level directory is missing")
		return
	var paths: PackedStringArray = directory.get_files()
	paths.sort()
	for path: String in paths:
		if path.ends_with(".json"):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "levels/" + path))
			if parsed is Dictionary:
				levels.append(parsed)
	var biome_order: Dictionary = {"meadow": 0, "clockwork": 1, "celestial": 2}
	levels.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var mode_a: int = MODES.find(String(a.mode))
		var mode_b: int = MODES.find(String(b.mode))
		return mode_a < mode_b if mode_a != mode_b else int(biome_order.get(a.biome, 9)) < int(biome_order.get(b.biome, 9)))


func _build_world() -> void:
	var world: WorldEnvironment = WorldEnvironment.new()
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("b7bddb")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("d4dff3")
	environment.ambient_light_energy = 0.38
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = environment
	add_child(world)
	var key: DirectionalLight3D = DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-55, -35, 0)
	key.light_color = Color("fff1d9")
	key.light_energy = 0.75
	key.shadow_enabled = true
	add_child(key)
	_audio = AudioStreamPlayer.new()
	_audio.volume_db = -16.0
	add_child(_audio)
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.current = true
	add_child(_camera)
	for title: String in ["FRONT", "SIDE"]:
		var label: Label3D = Label3D.new()
		label.text = title
		label.font_size = 44
		label.pixel_size = 0.011
		label.modulate = INK
		label.outline_modulate = PAPER
		label.outline_size = 8
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		add_child(label)
		_panel_labels.append(label)
	var source: PackedScene = load("res://assets/models/blocks/candy_toy/blk_candy_toy_cube.glb")
	if source != null:
		var instance: Node = source.instantiate()
		_cube = _find_mesh(instance)
		instance.free()
	if _cube == null:
		_cube = BoxMesh.new()


func _find_mesh(node: Node) -> Mesh:
	if node is MeshInstance3D:
		return node.mesh
	for child: Node in node.get_children():
		var found: Mesh = _find_mesh(child)
		if found != null:
			return found
	return null


func _set_stage(biome: String) -> void:
	if is_instance_valid(_stage):
		_stage.queue_free()
	var path: String = "res://assets/models/arcade_pack/env_%s_arcade.glb" % biome
	if ResourceLoader.exists(path):
		_stage = (load(path) as PackedScene).instantiate()
		# Keep the stage quieter than the toys under the game renderer's key light.
		for node: Node in _stage.find_children("*", "MeshInstance3D", true, false):
			var mesh_node: MeshInstance3D = node as MeshInstance3D
			for surface: int in mesh_node.mesh.get_surface_count():
				var original: Material = mesh_node.mesh.surface_get_material(surface)
				if original is StandardMaterial3D:
					var matte: StandardMaterial3D = original.duplicate()
					matte.albedo_color *= Color(0.70, 0.70, 0.70, 1.0)
					matte.metallic_specular = 0.15
					mesh_node.set_surface_override_material(surface, matte)
	else:
		_stage = Node3D.new()
		var base: MeshInstance3D = MeshInstance3D.new()
		var shape: CylinderMesh = CylinderMesh.new()
		shape.top_radius = 4.1
		shape.bottom_radius = 3.5
		shape.height = 0.6
		base.mesh = shape
		base.position.y = -0.3
		base.material_override = _material(2, "wall")
		_stage.add_child(base)
	add_child(_stage)


func _refresh_world() -> void:
	if round_model == null:
		return
	_snapshot = round_model.snapshot()
	var objects: Array = []
	objects.append_array(_snapshot.get("blocks", []))
	objects.append_array(_snapshot.get("markers", []))
	while _pool.size() < objects.size():
		var block: MeshInstance3D = MeshInstance3D.new()
		block.mesh = _cube
		add_child(block)
		_pool.append(block)
	for i: int in _pool.size():
		var block: MeshInstance3D = _pool[i]
		block.visible = i < objects.size()
		if not block.visible:
			continue
		var item: Dictionary = objects[i]
		block.position = item.get("position", Vector3.ZERO)
		block.scale = item.get("size", Vector3.ONE) * 0.97
		block.material_override = _material(int(item.get("colour", 0)), String(item.get("kind", "solid")))
	var target: Vector3 = _snapshot.get("camera_target", Vector3(0, 2, 0))
	target.y -= 0.75
	var camera_size: float = float(_snapshot.get("camera_size", 13.0))
	_camera.size = maxf(camera_size, 13.5)
	var angle: float = PI / 4.0 + float(_view_k) * PI / 2.0
	_camera_target = _camera_target.lerp(target, 0.16)
	_camera.position = _camera_target + Vector3(sin(angle) * 16, 12, cos(angle) * 16)
	_camera.look_at(_camera_target)
	if int(round_model.score) > _last_score:
		_last_score = int(round_model.score)
		_pop(target, false)
	for label: Label3D in _panel_labels:
		label.visible = String(selected.get("mode", "")) == "shadow" and screen == "play"
	if not _panel_labels.is_empty() and String(selected.get("mode", "")) == "shadow":
		var grid: float = float(round_model.grid_size)
		var distance: float = -(grid * 0.5 + 1.5)
		_panel_labels[0].position = Vector3(0, grid + 0.5, distance)
		_panel_labels[1].position = Vector3(distance, grid + 0.5, 0)
	if screen == "play" and is_instance_valid(_status):
		_status.text = String(_snapshot.get("status", ""))
		_metric.text = String(_snapshot.get("metric", str(round_model.score)))
		var remaining: float = maxf(0.0, float(selected.get("time_limit", 90)) - float(round_model.elapsed))
		var whole_seconds: int = int(ceilf(remaining))
		_timer.text = "%02d:%02d" % [whole_seconds / 60, whole_seconds % 60]
		_progress.value = clampf(float(_snapshot.get("progress", 0.0)), 0, 1) * 100.0
		if String(selected.mode) == "wall" and is_instance_valid(_wall_map):
			_wall_map.update_map(round_model.hole, round_model.project_cells(round_model.piece, round_model.axis, round_model.offset), int(selected.get("frame_size", 5)), round_model.axis)


func _material(index: int, kind: String) -> StandardMaterial3D:
	var key: String = "%d:%s" % [index, kind]
	if _materials.has(key):
		return _materials[key]
	var material: StandardMaterial3D = StandardMaterial3D.new()
	var colour: Color = PALETTE[posmod(index, PALETTE.size())]
	material.roughness = 0.27
	if kind == "active":
		material.emission_enabled = true
		material.emission = colour * 0.15
	if kind == "wall":
		colour = colour.lerp(Color("7b7893"), 0.70)
		material.roughness = 0.85
	elif kind == "hazard":
		colour = Color("ff6a13")
	elif kind == "cursor":
		colour = Color("1fd3e6")
		colour.a = 0.48
	elif kind == "ghost" or kind == "target":
		colour.a = 0.24 if kind == "ghost" else 0.65
		material.roughness = 0.65
	if colour.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = colour
	if kind in ["solid", "active", "wall"]:
		var outline: StandardMaterial3D = StandardMaterial3D.new()
		outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		outline.cull_mode = BaseMaterial3D.CULL_FRONT
		outline.grow = true
		outline.grow_amount = 0.025
		outline.albedo_color = colour.darkened(0.57)
		material.next_pass = outline
	_materials[key] = material
	return material


func _hide_blocks() -> void:
	for block: MeshInstance3D in _pool:
		block.hide()
	for label: Label3D in _panel_labels:
		label.hide()


func _build_ui() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	add_child(canvas)
	_ui = Control.new()
	_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(_ui)
	var theme: Theme = Theme.new()
	theme.default_font_size = 18
	theme.set_color("font_color", "Label", INK)
	theme.set_color("font_color", "Button", INK)
	theme.set_color("font_hover_color", "Button", INK)
	theme.set_color("font_pressed_color", "Button", INK)
	theme.set_color("font_focus_color", "Button", INK)
	theme.set_stylebox("normal", "Button", _style(Color("ede2d2"), 15))
	theme.set_stylebox("hover", "Button", _style(Color("ffe5a3"), 15))
	theme.set_stylebox("pressed", "Button", _style(GOLD, 15))
	var focus: StyleBoxFlat = _style(Color(0, 0, 0, 0), 15)
	focus.border_color = Color("795d86")
	focus.set_border_width_all(3)
	theme.set_stylebox("focus", "Button", focus)
	_ui.theme = theme
	_content = Control.new()
	_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_content)


func _clear_ui() -> void:
	for child: Node in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	_pause_panel = null
	_wall_map = null


func _build_hud() -> void:
	_clear_ui()
	var top: PanelContainer = _panel()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 24
	top.offset_top = 16
	top.offset_right = -24
	_content.add_child(top)
	if String(selected.mode) == "wall":
		var map_panel: PanelContainer = _panel()
		map_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		map_panel.offset_left = -236
		map_panel.offset_right = -24
		map_panel.offset_top = 116
		map_panel.offset_bottom = 392
		_content.add_child(map_panel)
		_wall_map = Control.new()
		_wall_map.set_script(load(ROOT + "wall_map.gd"))
		_wall_map.custom_minimum_size = Vector2(180, 250)
		_wall_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
		map_panel.add_child(_wall_map)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	top.add_child(row)
	row.add_child(_button("← Hub", show_menu))
	_level_title = _label(String(selected.name), 22)
	_level_title.autowrap_mode = TextServer.AUTOWRAP_OFF
	_level_title.clip_text = true
	_level_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_level_title)
	_metric = _label("", 18)
	_metric.autowrap_mode = TextServer.AUTOWRAP_OFF
	_metric.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(_metric)
	# Reserve a separate clock box so long blueprint metrics cannot read into it.
	var clock: PanelContainer = PanelContainer.new()
	clock.custom_minimum_size = Vector2(106, 44)
	clock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var clock_style: StyleBoxFlat = _style(Color("e7e0ef"), 12)
	clock_style.content_margin_left = 12
	clock_style.content_margin_right = 12
	clock_style.content_margin_top = 6
	clock_style.content_margin_bottom = 6
	clock.add_theme_stylebox_override("panel", clock_style)
	row.add_child(clock)
	_timer = _label("00:00", 24)
	_timer.autowrap_mode = TextServer.AUTOWRAP_OFF
	_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_timer.tooltip_text = "Time remaining"
	clock.add_child(_timer)
	row.add_child(_button("Pause", toggle_pause))
	var bottom: PanelContainer = _panel()
	bottom.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 24
	bottom.offset_right = -24
	bottom.offset_top = -156
	bottom.offset_bottom = -16
	_content.add_child(bottom)
	var column: VBoxContainer = _column(bottom, 7)
	_status = _label("", 18)
	column.add_child(_status)
	_progress = ProgressBar.new()
	_progress.show_percentage = false
	_progress.custom_minimum_size.y = 7
	_progress.add_theme_stylebox_override("background", _style(Color("dfd5d0"), 3))
	_progress.add_theme_stylebox_override("fill", _style(GOLD, 3))
	column.add_child(_progress)
	var controls: HBoxContainer = HBoxContainer.new()
	controls.add_theme_constant_override("separation", 9)
	column.add_child(controls)
	var labels: Dictionary
	match String(selected.mode):
		"stack": labels = {"primary": "SPACE · Drop", "undo": "U · Snap"}
		"wall": labels = {"left": "←", "right": "→", "up": "↑", "down": "↓", "rotate_x": "Q · Tip", "rotate_y": "E · Turn", "primary": "SPACE · Send", "undo": "U · Focus"}
		_: labels = {"left": "←", "right": "→", "up": "↑", "down": "↓", "rotate_x": "Q · Lower", "rotate_y": "E · Raise", "primary": "SPACE · Cube", "undo": "U · Undo"}
	for action: String in labels:
		var button: Button = _button(String(labels[action]), func(): send_action(action), action == "primary")
		if String(selected.mode) == "wall" and action == "undo" and int(selected.get("focus_charges", 0)) == 0:
			button.queue_free()
			continue
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Gameplay buttons do not capture Space; keyboard remains the model's input.
		button.focus_mode = Control.FOCUS_NONE
		controls.add_child(button)
	var view_hint: String = "Fixed view · Both shadows stay visible" if String(selected.mode) == "shadow" else "Z / C · Rotate view"
	column.add_child(_label(view_hint + "     R · Restart     Esc / P · Pause", 13, Color("795d86")))
	_pause_panel = _center_panel(440, 320)
	_pause_panel.name = "Pause"
	var pause_column: VBoxContainer = _column(_pause_panel, 14)
	pause_column.name = "Column"
	pause_column.add_child(_label("Take a cloud break.", 28))
	pause_column.add_child(_label("The timer and your pieces are paused.", 18))
	var resume: Button = _button("Resume", toggle_pause, true)
	resume.name = "Resume"
	pause_column.add_child(resume)
	pause_column.add_child(_button("Restart level", start_selected))
	pause_column.add_child(_button("All challenges", show_menu))
	_pause_panel.hide()
	get_viewport().gui_release_focus()


func _round_finished(result: Dictionary) -> void:
	last_result = result.duplicate(true)
	screen = "result"
	paused = false
	var id: String = String(result.get("level_id", ""))
	if bool(result.get("won", false)):
		bests.set_value(id, "stars", maxi(int(result.stars), int(bests.get_value(id, "stars", 0))))
		bests.set_value(id, "score", maxi(int(result.score), int(bests.get_value(id, "score", 0))))
		bests.set_value(id, "time", minf(float(result.elapsed), float(bests.get_value(id, "time", INF))))
		var error: Error = bests.save(SAVE_PATH)
		if error != OK:
			push_warning("Arcade bests could not be saved: " + error_string(error))
	_clear_ui()
	var panel: PanelContainer = _center_panel(600, 360)
	var column: VBoxContainer = _column(panel, 16)
	var success: bool = bool(result.get("won", false))
	if success:
		_pop(_camera_target, true)
	var heading: String = {"stack": "TOWER COMPLETE", "wall": "DELIVERY COMPLETE", "shadow": "SHADOWS RESTORED"}.get(String(selected.mode), "CHALLENGE COMPLETE")
	column.add_child(_label(heading if success else "ANOTHER TRY?", 15, Color("795d86")))
	column.add_child(_label("★".repeat(int(result.get("stars", 0))) if success else "The clouds can wait.", 37, GOLD if success else INK))
	column.add_child(_label(String(selected.name), 23))
	column.add_child(_label(String(round_model.message), 18))
	column.add_child(_label("Score %d  ·  %.1f seconds" % [int(result.score), float(result.elapsed)], 18))
	var row: HBoxContainer = HBoxContainer.new()
	column.add_child(row)
	row.add_child(_button("Try again", start_selected, not success))
	row.add_child(_button("All challenges", show_menu))
	var next: Dictionary = _next_level()
	if success and not next.is_empty():
		row.add_child(_button("Next chapter →", func(): show_briefing(next), true))
	_focus_first()


func _next_level() -> Dictionary:
	var found: bool = false
	for level: Dictionary in levels:
		if String(level.mode) != String(selected.mode):
			continue
		if found:
			return level
		found = String(level.id) == String(selected.id)
	return {}


func _return_original() -> void:
	var path: String = String(ProjectSettings.get_setting("application/run/main_scene", "res://prototypes/first_playable/fp_main.tscn"))
	if path == ROOT + "arcade_hub.tscn":
		path = "res://prototypes/first_playable/fp_main.tscn"
	get_tree().change_scene_to_file(path)


func _style(colour: Color, radius: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = colour
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _panel(colour: Color = PAPER) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(colour, 24))
	return panel


func _center_panel(width: float, height: float) -> PanelContainer:
	var panel: PanelContainer = _panel()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -width / 2
	panel.offset_right = width / 2
	panel.offset_top = -height / 2
	panel.offset_bottom = height / 2
	_content.add_child(panel)
	return panel


func _column(parent: Control, separation: int) -> VBoxContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.name = "Margin"
	for edge: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 6)
	parent.add_child(margin)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", separation)
	margin.add_child(column)
	return column


func _label(text: String, size: int, colour: Color = INK) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", colour)
	return label


func _button(text: String, callback: Callable, primary: bool = false) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size.y = 44
	button.add_theme_font_size_override("font_size", 17)
	if primary:
		button.add_theme_stylebox_override("normal", _style(GOLD, 15))
	button.pressed.connect(callback)
	return button


func _focus_first() -> void:
	var buttons: Array[Node] = _content.find_children("*", "Button", true, false)
	if not buttons.is_empty():
		_focus_if_ready.call_deferred(buttons[0])


func _focus_if_ready(button: Button) -> void:
	if is_instance_valid(button) and button.is_inside_tree() and button.is_visible_in_tree():
		button.grab_focus()


func _pop(position: Vector3, celebration: bool) -> void:
	for i: int in (28 if celebration else 8):
		var spark: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.07
		sphere.height = 0.14
		spark.mesh = sphere
		spark.material_override = _material(i % 6, "solid")
		spark.position = position
		add_child(spark)
		var angle: float = float(i) * 2.39996
		_sparkles.append({"node": spark, "velocity": Vector3(cos(angle) * 2, 2.5 + float(i % 3) * 0.4, sin(angle) * 2), "life": 0.0})
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var length: float = 0.28 if celebration else 0.12
	var count: int = int(length * stream.mix_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(count * 2)
	for i: int in count:
		var t: float = float(i) / stream.mix_rate
		var frequency: float = 660.0 + (330.0 if celebration and t > 0.12 else 0.0)
		var amplitude: float = sin(t * TAU * frequency) * pow(1.0 - t / length, 2) * 0.35
		bytes.encode_s16(i * 2, int(amplitude * 32767))
	stream.data = bytes
	_audio.stream = stream
	_audio.play()


func _tick_sparkles(delta: float) -> void:
	for i: int in range(_sparkles.size() - 1, -1, -1):
		var item: Dictionary = _sparkles[i]
		item.life += delta
		item.velocity += Vector3.DOWN * delta * 5.5
		var node: MeshInstance3D = item.node
		node.position += item.velocity * delta
		node.scale = Vector3.ONE * maxf(0.0, 1.0 - float(item.life))
		if float(item.life) >= 1.0:
			node.queue_free()
			_sparkles.remove_at(i)
