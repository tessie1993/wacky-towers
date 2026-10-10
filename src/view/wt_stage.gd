class_name WtStage extends Node3D
## Toy-box diorama. Simulation owns the board; this node only reads and presents it.
## Blocks use the repository's original bevelled GLB cube geometry and MultiMeshes.

signal view_changed(index: int)
signal secret_tapped(id: StringName)

const BIOME_LOOKS := {
	"meadow": ["#CEE5E5", "#85B67B", "#8C7457", "#547549"],
	"candy": ["#EBD8DF", "#DEB6A0", "#AA8584", "#A58CAE"],
	"ice": ["#D5E7F0", "#D6E9EA", "#85AFBF", "#7FA7BC"],
	"underwater": ["#BADADB", "#9DBFC2", "#628F98", "#827DAC"],
	"lava": ["#DFCCC1", "#9B8070", "#705950", "#AD7456"],
	"forest": ["#CADAD0", "#72A273", "#766650", "#456E54"],
	"cave": ["#CCD0DF", "#8C91A8", "#6D6B82", "#927AA8"],
	"clockwork": ["#DFD6C7", "#B5A37E", "#8D7860", "#9B815E"],
	"neon": ["#BCC6DD", "#8692AB", "#5D6681", "#8C79AF"],
	"celestial": ["#D9DBE8", "#CFCAE2", "#A09AB8", "#B5A3CE"],
	"carnival": ["#F3E2E2", "#F1E4CF", "#B98C8F", "#E58FA8"]
}
## Tumble Fair (id `carnival`) candy-stripe set dressing: pink, cream, ticket gold, sky ribbon.
const CARNIVAL_TRIM := {"pink": "#E98AA6", "cream": "#FBF1DE", "gold": "#EDC873", "sky": "#9CC3DE", "mint": "#A9D8C0", "wood": "#B9937A"}
## Optional biome block material, owned by the shader pipeline (class WtBlockMaterials).
const BLOCK_MATERIAL_CLASS: StringName = &"WtBlockMaterials"

var _sim: BoardSim
var _board: BoardState
var _size: Vector3i
var _prefs: Dictionary = {}
var _biome: StringName = &"meadow"
var _palette: PaletteTable
var _art: ArtSet
var _locked: BoardView
var _active: MultiMeshInstance3D
var _ghost: MultiMeshInstance3D
var _landing: MultiMeshInstance3D
var _camera: Camera3D
var _world: Node3D
var _wizard: WtToyActor
var _mascot: WtToyActor
var _boss: WtToyActor
var _character_root: Node3D
var _story_context: Dictionary = {}
var _environment: Environment
var _key_light: DirectionalLight3D
var _syrup_preview: Array[Vector3i] = []
var _syrup_root: Node3D
var _story_props: Node3D
var _cosmetic_root: Node3D
var _owned_cosmetics: Dictionary = {}
var _fit_view: MultiMeshInstance3D
var _key_face: MeshInstance3D
var _key_stamp: Dictionary = {}
var _key_uid: int = -1
var _keyholes: Dictionary = {}
var _content_views: Dictionary = {}
var _content_cells: Dictionary = {}
var _hazard_view: MultiMeshInstance3D
var _hazard_cells: Dictionary = {}
var _status_views: Dictionary = {}
var _status_cells: Dictionary = {}
var _windmill: Node3D
var _audio: WtAudio
var _snap: ViewSnap = ViewSnap.new()
var _yaw: float = 45.0
var _target_yaw: float = 45.0
var _elevation: float = 32.0
var _dragging: bool = false
var _time: float = 0.0
var _danger: MeshInstance3D
var _danger_mat: StandardMaterial3D
var _fx: Array[Dictionary] = []
var _confetti: MultiMeshInstance3D
var _fx_material: StandardMaterial3D
var _last_piece_uid: int = -1
var _last_piece_shape: StringName = &""
var _view_rect: Rect2 = Rect2()
var _goal_overlay: Node3D
var _prediction: ActivePiece
var _ghost_focus: Vector3 = Vector3.ZERO
var _guides: MeshInstance3D
var _guide_quadrant: Vector2i = Vector2i.ZERO
var _telegraphs: MultiMeshInstance3D
var _marks: Dictionary = {}
var _secrets: Dictionary = {}


## Binds one authoritative simulation and constructs a biome's original diorama.
func setup(sim: BoardSim, biome: StringName, settings: Dictionary = {}) -> void:
	_sim = sim
	_board = sim.board()
	_size = _board.size()
	_biome = biome
	_prefs = settings.duplicate()
	_art = ArtSet.new(&"candy_toy")
	var palette_path: String = "res://assets/data/palettes/candy_toy.json" if biome == &"candy" else "res://assets/data/palettes/meadow.json"
	_palette = PaletteTable.from_dict(JSON.parse_string(FileAccess.get_file_as_string(palette_path)))
	_world = Node3D.new()
	_world.name = "OriginalBiomeDiorama"
	add_child(_world)
	_build_light()
	_build_island()
	_build_board()
	_build_characters()
	_build_props()
	_build_camera()
	_build_fx()
	_audio = WtAudio.new()
	add_child(_audio)
	_audio.setup(settings)
	_audio.start_music(biome)
	apply_settings(settings)
	if settings.get("goal") is Dictionary:
		set_goal(settings["goal"])
	_update_piece()
	if is_inside_tree():
		get_viewport().size_changed.connect(_frame_camera)
		_frame_camera()


## Presents the current tick and its visible/audio feedback; never advances simulation.
func sync(events: Array[SimEvent]) -> void:
	_prediction = null
	_syrup_preview.clear()
	var changed: bool = false
	for ev: SimEvent in events:
		match ev.kind:
			&"fit_spots":
				_show_fit_spots(ev.data.get("spots",[]))
			&"key_stamp":
				_key_stamp=ev.data.duplicate(true)
				_key_uid=_sim.get_piece_uid()
			&"key_wound":
				var index: int=int(ev.data.get("index",-1))
				if _keyholes.has(index):(_keyholes[index] as MeshInstance3D).material_override=_mat(Color("#BFE0AF"),true)
			&"syrup_preview":
				_syrup_preview.clear()
				for cell: Variant in ev.data.get("cells",[]):
					if cell is Vector3i:_syrup_preview.append(cell)
			&"syrup_band":
				_syrup_band(ev.data)
			&"syrup_glide":
				_react_toys(&"sparkle")
			&"fog_visibility":
				if ev.data.has("cell_alphas"):
					_locked.set_cell_visibility(ev.data.get("cell_alphas",[]))
				else:
					_locked.set_visibility(float(ev.data.get("alpha",int(ev.data.get("alpha_milli",1000))/1000.0)))
				_refresh_content_visibility()
			&"item_fog_visibility":
				_locked.set_item_hidden(ev.data.get("hidden_cells",[]))
				_refresh_content_visibility()
			&"mushroom_warning":
				_mark_cell("mushroom",ev.data.get("cell",Vector3i.ZERO),Color("#EDAE63"))
			&"mushroom_popup", &"mushroom_cancelled":
				_marks.erase("mushroom")
			&"sprout_bud":
				_mark_cell("sprout",ev.data.get("cell",Vector3i.ZERO),Color("#B7DC8D"),3.0)
			&"mascot_hint":
				for key: Variant in _marks.keys():
					if str(key).begins_with("hint_"): _marks.erase(key)
				var cells: Array = ev.data.get("cells",[])
				for i: int in mini(cells.size(),32):
					_mark_cell("hint_%s"%i,cells[i],Color("#FFE6A0"))
			&"secret_placed":
				_place_secret(ev.data)
			&"secret_collected":
				var id: String = str(ev.data.get("id",""))
				if _secrets.has(id):
					(_secrets[id] as Node3D).queue_free()
					_secrets.erase(id)
				_audio.cue(&"clear")
			SimEvents.CELLS_CHANGED, SimEvents.CELLS_TRIMMED:
				changed = true
			SimEvents.PIECE_LOCKED:
				_react_toys(&"sparkle")
				changed = true
				_audio.cue(&"lock")
				if not _reduced():
					burst(Vector3(0, 0.7, 0), Color("#F2D279"), 12)
			SimEvents.LAYERS_CLEARED:
				_react_toys(&"heart",&"cheer")
				changed = true
				_audio.cue(&"clear")
				if not _reduced():
					burst(Vector3(0, 1.2, 0), Color("#F2D279"), 45)
			SimEvents.PIECE_ROTATED:
				_audio.cue(&"rotate")
			SimEvents.TOP_OUT_WARNING:
				_react_toys(&"exclaim",&"sweat")
				_audio.cue(&"warning")
			SimEvents.LEVEL_FAILED:
				_react_toys(&"gloom",&"dots")
				_audio.cue(&"lose")
			SimEvents.GOAL_REACHED:
				_react_toys(&"heart",&"sparkle")
				_audio.cue(&"win")
				if not _reduced():
					burst(Vector3(0, _board.h_play() * 0.65, 0), Color("#F8DE87"), 70)
			_:
				_hazard_event(ev)
				var kind: String = str(ev.kind)
				if _boss!=null and ("warning" in kind or "windup" in kind):_boss.react(&"exclaim",1.0,_reduced())
				if "wind" in kind or "gust" in kind:
					_audio.cue(&"wind")
				elif "flip" in kind or "gravity_changed" in kind:
					_audio.cue(&"flip")
	if changed:
		_locked.refresh()
		if _fit_view!=null:_fit_view.multimesh.visible_instance_count=0
	if changed:
		_refresh_content_views()
	else:
		for view: MultiMeshInstance3D in _content_views.values():view.material_override=_locked._mmi.material_override
	_update_piece()
	var danger: bool = _board.stack_height() >= _board.h_play() - 2
	_danger.visible = danger


## Responsive LAN client view. Changes only a duplicate; the next host state clears it.
func predict(command: SimCommand) -> void:
	if _sim == null or _sim.get_piece() == null:
		return
	if _prediction == null:
		_prediction = _sim.get_piece().duplicate_piece()
	match command.kind:
		SimEvents.CMD_MOVE:
			if not command.args.is_empty() and command.args[0] is Vector3i:
				Movement.try_translate(_prediction, _board, command.args[0])
		SimEvents.CMD_ROTATE:
			if command.args.size() >= 2:
				var knobs: KnobRegistry = _sim.knobs()
				Movement.try_rotate(_prediction, _board, int(command.args[0]) as Orientations.Axis, int(command.args[1]), {
					"kick_enabled": knobs.flag(&"control.kick_enabled"), "kick_off_axis": knobs.flag(&"control.kick_off_axis"),
					"max_up_kicks_per_piece": knobs.int_value(&"control.max_up_kicks_per_piece"),
					"kick_wide_min_extent": knobs.int_value(&"control.kick_wide_min_extent"), "kick_order": knobs.value(&"control.kick_order")})
		SimEvents.CMD_HARD_DROP:
			_prediction.pivot += _board.down_vector() * Movement.drop_distance(_prediction, _board)
	_update_piece(_prediction)


## Steps to the adjacent 30 degree camera view, wrapping across all twelve snaps.
func rotate_view(dir: int) -> void:
	_snap.step(-dir if _preference_flag("invert_view",false) else dir)
	_target_yaw = _snap.yaw_deg()
	if _reduced() or not _preference_flag("turn_animation",true):
		_yaw = _target_yaw
	_update_camera()
	view_changed.emit(_snap.k)


## Returns the logical settled camera view (0..11).
func view_index() -> int:
	return _snap.k


## Maps a cardinal screen direction to the board's cardinal x/z direction.
func get_move_vector(screen: Vector2i) -> Vector3i:
	return CameraMath.screen_dir_to_world(_snap.k, screen, 45, 30)


## Maps Turn/Flip/Roll vocabulary to a world axis and right-hand sign.
func rotation_for(axis_id: StringName, dir: int) -> Vector2i:
	var id: StringName = axis_id
	if id == &"turn": id = &"spin"
	if id == &"flip": id = &"tilt"
	return _snap.rotation_for(id, dir)


## World axis for an input pair; rotation_for also supplies its camera-relative sign.
func rotation_axis(axis_id: StringName) -> int:
	return rotation_for(axis_id, 1).x


## A normalized viewport rectangle can reserve space for HUD and touch controls.
func set_board_area(rect: Rect2) -> void:
	_view_rect = rect
	_frame_camera()


## Shows a shape stencil or build-height marker without changing the board.
func set_goal(goal: Dictionary) -> void:
	if _goal_overlay != null:
		remove_child(_goal_overlay)
		_goal_overlay.queue_free()
	_goal_overlay = Node3D.new()
	_goal_overlay.name = "ObjectiveStencil"
	add_child(_goal_overlay)
	_keyholes.clear()
	var kind: String = str(goal.get("type", ""))
	if kind=="wind_keys":
		_build_keyholes(goal.get("keyholes",[]))
	if kind == "height":
		var im := ImmediateMesh.new()
		im.surface_begin(Mesh.PRIMITIVE_LINES)
		var y: float = float(goal.get("h_target", goal.get("height", 8)))
		var w: float = _size.x * .5 + .08
		var d: float = _size.z * .5 + .08
		for v: Vector3 in [Vector3(-w,y,-d),Vector3(w,y,-d),Vector3(w,y,-d),Vector3(w,y,d),Vector3(w,y,d),Vector3(-w,y,d),Vector3(-w,y,d),Vector3(-w,y,-d)]: im.surface_add_vertex(v)
		im.surface_end()
		_mesh(_goal_overlay,im,Vector3.ZERO,_mat(Color("#B89B59"),true))
	elif kind == "shape":
		var target: Dictionary = goal.get("target_shape", {})
		var layers: Dictionary = target.get("layers", {})
		var cells: Array[Vector3i] = []
		var colours: Array[Color] = []
		for y: Variant in layers:
			var rows: Array = layers[y]
			for z: int in rows.size():
				var row: String = str(rows[z])
				for x: int in row.length():
					if row[x] in ["+","#","P","V","M"]:
						cells.append(Vector3i(x,int(y),z))
						colours.append(_palette.color({"P":1,"V":2,"M":3}[row[x]]) if row[x] in ["P","V","M"] else Color("#EAE1BE"))
		if not cells.is_empty():
			var box := BoxMesh.new()
			var node: MultiMeshInstance3D = _multimesh(box,cells.size(),_ghost_material())
			remove_child(node);_goal_overlay.add_child(node)
			for i: int in cells.size():
				node.multimesh.set_instance_transform(i,Transform3D(Basis.from_scale(Vector3.ONE*.98),BoardGeom.cell_center(cells[i],_size)))
				node.multimesh.set_instance_color(i,colours[i])
			node.multimesh.visible_instance_count=cells.size()


## Updates presentation settings without touching game state.
func apply_settings(settings: Dictionary) -> void:
	_prefs = settings.duplicate()
	if _audio != null:
		_audio.apply_settings(settings)
	if _active != null:
		var pattern_value: Variant = settings.get("colorblind", settings.get("colorblind_patterns", false))
		var patterns: bool = pattern_value if pattern_value is bool else str(pattern_value) in ["shapes", "high_contrast", "on", "true"]
		var contrast: bool = str(pattern_value) == "high_contrast"
		(_active.material_override as ShaderMaterial).set_shader_parameter(&"patterns", patterns)
		(_active.material_override as ShaderMaterial).set_shader_parameter(&"high_contrast", contrast)
		_locked.set_patterns(patterns,contrast)
		var ghost_value: Variant = settings.get("ghost", true)
		var ghost_on: bool = ghost_value if ghost_value is bool else str(ghost_value) in ["on", "true", "enabled"]
		_ghost.visible = ghost_on
		_landing.visible = ghost_on
	for status_view: MultiMeshInstance3D in _status_views.values():
		(status_view.material_override as ShaderMaterial).set_shader_parameter(&"reduced",_reduced())
	for actor: WtToyActor in [_wizard,_mascot,_boss]:
		if actor!=null:actor.set_reduced_motion(_reduced())
	set_process(true)


## Visible celebratory particles, pooled in one MultiMesh (reduced motion disables them).
func burst(origin: Vector3, tint: Color, count: int = 30) -> void:
	for i: int in mini(count, 120 - _fx.size()):
		var angle: float = float(i) * 2.399963
		var speed: float = 1.4 + float(i % 7) * 0.23
		_fx.append({"p": origin, "v": Vector3(cos(angle) * speed, 1.5 + (i % 5) * 0.45, sin(angle) * speed), "t": 0.0,
			"color": tint if i % 3 == 0 else _palette.color(1 + i % 5)})


func _process(delta: float) -> void:
	_time += delta
	if not _dragging:
		var d: float = angle_difference(deg_to_rad(_yaw), deg_to_rad(_target_yaw))
		_yaw += rad_to_deg(d) * minf(1.0, delta * 10.0)
		_update_camera()
	if _windmill != null and not _reduced():
		_windmill.rotation.z += delta * 0.35
	if _danger.visible:
		_danger_mat.albedo_color.a = 0.8 if _reduced() else 0.55 + 0.25 * sin(_time * 4.0)
	_update_fx(delta)
	_update_marks()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not _secrets.is_empty():
		var origin: Vector3 = _camera.project_ray_origin(event.position)
		var query := PhysicsRayQueryParameters3D.create(origin,origin+_camera.project_ray_normal(event.position)*1000.0,128)
		var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty() and hit["collider"].has_meta("secret_id"):
			secret_tapped.emit(StringName(hit["collider"].get_meta("secret_id")))
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]:
		_dragging = event.pressed
		if not _dragging:
			_snap.settle(_yaw)
			_target_yaw = _snap.yaw_deg()
			if _reduced() or not _preference_flag("turn_animation",true): _yaw = _target_yaw
			view_changed.emit(_snap.k)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _dragging:
		_yaw -= event.relative.x * 0.35
		_elevation = clampf(_elevation + event.relative.y * 0.12, 24.0, 50.0)
		_update_camera()
		get_viewport().set_input_as_handled()


func _reduced() -> bool:
	var value: Variant = _prefs.get("reduced_motion", false)
	return value if value is bool else str(value) in ["on", "true", "enabled"]


func _preference_flag(key: String, fallback: bool) -> bool:
	var value: Variant = _prefs.get(key,fallback)
	return value if value is bool else str(value) in ["on","true","enabled"]


func _occlusion_mode() -> String:
	var mode: String = str(_prefs.get("occlusion","default"))
	return str(_sim.knobs().value(&"view.occlusion_mode")) if mode == "default" else mode


func _build_light() -> void:
	var look: Array = BIOME_LOOKS.get(str(_biome), BIOME_LOOKS["meadow"])
	var env := Environment.new()
	_environment=env
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(look[0])
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#DDE8FF")
	env.ambient_light_energy = 0.32
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var key := DirectionalLight3D.new()
	_key_light=key
	key.rotation_degrees = Vector3(-52, -32, 0)
	key.light_color = Color("#FFF4DA")
	key.light_energy = 0.65
	key.shadow_enabled = true
	key.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	key.directional_shadow_max_distance = 45.0
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30, 145, 0)
	fill.light_color = Color("#DCE6FF")
	fill.light_energy = 0.12
	fill.shadow_enabled = false
	fill.light_specular = 0.0
	add_child(fill)


func _build_island() -> void:
	var look: Array = BIOME_LOOKS.get(str(_biome), BIOME_LOOKS["meadow"])
	var rim: float = maxf(_size.x, _size.z) * 0.65 + 0.8
	_cylinder(_world, Vector3(0, -0.21, 0), rim, rim * 0.96, 0.42, Color(look[1]), 12, Vector3(1.0, 1.0, 0.92))
	_cylinder(_world, Vector3(0, -0.87, 0), rim * 0.95, rim * 0.85, 0.9, Color(look[2]), 11, Vector3(1.0, 1.0, 0.92))
	_cylinder(_world, Vector3(0, -1.85, 0), rim * 0.85, 0.2, 1.15, Color(look[2]).darkened(0.16), 9, Vector3(1.0, 1.0, 0.92))
	for i: int in 7:
		var a: float = TAU * i / 7.0
		var p: Vector3 = Vector3(cos(a) * rim * 0.7, -1.2, sin(a) * rim * 0.61)
		if _biome in [&"ice", &"cave", &"celestial"]:
			_cylinder(_world, p, 0.2, 0.03, 1.3 + (i % 3) * 0.2, Color(look[3]).lightened(0.25), 5)
		else:
			_cylinder(_world, p, 0.1, 0.05, 1.0, Color(look[3]), 5)


func _build_board() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z: int in _size.z:
		for x: int in _size.x:
			if not _board.is_active(_board.index(Vector3i(x, 0, z))): continue
			var p: Vector3 = BoardGeom.cell_center(Vector3i(x, 0, z), _size)
			var col: Color = Color("#56787B") if (x + z) % 2 == 0 else Color("#63888A")
			st.set_color(col)
			st.set_normal(Vector3.UP)
			for v: Vector3 in [Vector3(-.485, .012, -.485), Vector3(-.485, .012, .485), Vector3(.485, .012, .485),
				Vector3(-.485, .012, -.485), Vector3(.485, .012, .485), Vector3(.485, .012, -.485)]:
				st.add_vertex(Vector3(p.x, 0, p.z) + v)
	var mat := _mat(Color.WHITE)
	mat.vertex_color_use_as_albedo = true
	_mesh(_world, st.commit(), Vector3.ZERO, mat)
	var edge: Color = Color("#687B6C")
	_box(_world, Vector3(0, -0.06, -_size.z * 0.5 - .08), Vector3(_size.x + .4, .15, .16), edge)
	_box(_world, Vector3(0, -0.06, _size.z * 0.5 + .08), Vector3(_size.x + .4, .15, .16), edge)
	_box(_world, Vector3(-_size.x * .5 - .08, -.06, 0), Vector3(.16, .15, _size.z + .4), edge)
	_box(_world, Vector3(_size.x * .5 + .08, -.06, 0), Vector3(.16, .15, _size.z + .4), edge)
	_locked = BoardView.new()
	_locked.outline_grow = 0.012
	add_child(_locked)
	_locked.bind(_board, _art, _palette)
	_locked.set_custom_content(true)
	_refresh_content_views()
	var cube: Mesh = _art.cube_mesh()
	if cube == null: cube = BoxMesh.new()
	_active = _multimesh(cube, 64, _block_material())
	_ghost = _multimesh(BoxMesh.new(), 64, _ghost_material())
	var plane := PlaneMesh.new()
	plane.size = Vector2(0.88, 0.88)
	_landing = _multimesh(plane, 64, _mat(Color("#F3D784"), true))
	_danger_mat = _mat(Color("#D27E64"), true)
	_danger_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	var y: float = _board.h_play()
	var w: float = _size.x * .5
	var d: float = _size.z * .5
	for v: Vector3 in [Vector3(-w,y,-d),Vector3(w,y,-d),Vector3(w,y,-d),Vector3(w,y,d),Vector3(w,y,d),Vector3(-w,y,d),Vector3(-w,y,d),Vector3(-w,y,-d)]: im.surface_add_vertex(v)
	im.surface_end()
	_danger = _mesh(self, im, Vector3.ZERO, _danger_mat)
	_danger.visible = false
	_build_guides()


func _refresh_content_views() -> void:
	var records: Dictionary={}
	for cell: int in _size.x*_size.y*_size.z:
		var kind: int=_board.get_kind(cell)
		if kind<3:continue
		if not records.has(kind):records[kind]=[]
		records[kind].append(_board.cell(cell))
	for kind: int in records:
		if not _content_views.has(kind):
			var view: MultiMeshInstance3D=_multimesh(WtContentGeometry.mesh(kind),_size.x*_size.y*_size.z,_locked._mmi.material_override)
			view.name="PooledContentKind_%s"%kind;_content_views[kind]=view
		var view: MultiMeshInstance3D=_content_views[kind]
		view.material_override=_locked._mmi.material_override
		for i: int in records[kind].size():
			view.multimesh.set_instance_transform(i,Transform3D(Basis.IDENTITY,BoardGeom.cell_center(records[kind][i],_size)))
			view.multimesh.set_instance_color(i,Color.WHITE)
			view.multimesh.set_instance_custom_data(i,Color(0,0,0,_locked.visibility_at(_board.index(records[kind][i]))))
		view.multimesh.visible_instance_count=records[kind].size()
	for kind: int in _content_views:
		if not records.has(kind):(_content_views[kind] as MultiMeshInstance3D).multimesh.visible_instance_count=0
	_content_cells=records
	_refresh_status_views()


func _refresh_content_visibility() -> void:
	# Coverage changes do not recreate mesh pools or mutate gameplay timestamps.
	for kind: int in _content_cells:
		var view: MultiMeshInstance3D=_content_views[kind]
		view.material_override=_locked._mmi.material_override
		var cells: Array=_content_cells[kind]
		for i: int in cells.size():
			view.multimesh.set_instance_custom_data(i,Color(0,0,0,_locked.visibility_at(_board.index(cells[i]))))


func _refresh_status_views() -> void:
	var statuses: Dictionary={}
	for index: int in _size.x*_size.y*_size.z:
		if _board.get_kind(index)==0:continue
		var status: Dictionary=_board.get_record(index).get("status",{})
		var code: int=-1
		if status.has("hits_left"):code=clampi(int(status.hits_left),0,9)
		elif _board.get_kind(index)==18 and status.has("counter"):code=clampi(int(status.counter),0,9)
		elif bool(status.get("vined",false)):code=10
		elif bool(status.get("locked",false)):code=11
		elif bool(status.get("fixed",false)) or bool(status.get("anchored",false)):code=12
		if code<0:continue
		if not statuses.has(code):statuses[code]=[]
		statuses[code].append(_board.cell(index))
	for code: int in statuses:
		if not _status_views.has(code):
			var shader:=Shader.new();shader.code="""shader_type spatial;
render_mode unshaded,cull_disabled;
uniform bool reduced=false;
void fragment(){ALBEDO=COLOR.rgb*(reduced?1.0:(.86+.14*sin(TIME*4.0)));}"""
			var material:=ShaderMaterial.new();material.shader=shader;material.set_shader_parameter(&"reduced",_reduced())
			var view: MultiMeshInstance3D=_multimesh(WtContentGeometry.icon(code),_size.x*_size.y*_size.z,material)
			view.name="PooledStatusIcon_%s"%code;_status_views[code]=view
		var view: MultiMeshInstance3D=_status_views[code]
		for i: int in statuses[code].size():
			var toward: Vector3=_camera.basis.z if _camera!=null else Vector3(1,.5,1).normalized()
			var basis: Basis=_camera.basis if _camera!=null else Basis.IDENTITY
			view.multimesh.set_instance_transform(i,Transform3D(basis,BoardGeom.cell_center(statuses[code][i],_size)+toward*.55))
			view.multimesh.set_instance_color(i,Color("#98CBCB") if code==10 else (Color("#DAA4BF") if code==11 else Color("#F1D08A")))
		view.multimesh.visible_instance_count=statuses[code].size()
	for code: int in _status_views:
		if not statuses.has(code):(_status_views[code] as MultiMeshInstance3D).multimesh.visible_instance_count=0
	_status_cells=statuses
	_update_status_orientation()


func _update_status_orientation() -> void:
	if _camera==null:return
	for code: int in _status_cells:
		var view: MultiMeshInstance3D=_status_views[code]
		for i: int in _status_cells[code].size():
			view.multimesh.set_instance_transform(i,Transform3D(_camera.basis,BoardGeom.cell_center(_status_cells[code][i],_size)+_camera.basis.z*.55))


func _hazard_event(event: SimEvent) -> void:
	var kind: String=str(event.kind)
	var prefix: String=kind.trim_suffix("_warning")
	if kind.ends_with("_warning"):
		var cells: Array=event.data.get("cells",[]).duplicate()
		if event.data.get("cell") is Vector3i:cells.append(event.data.cell)
		if event.data.has("layer") or event.data.has("height"):
			var y: int=clampi(int(event.data.get("layer",event.data.get("height",0))),0,_board.h_play()-1)
			for z: int in _size.z:
				for x: int in _size.x:cells.append(Vector3i(x,y,z))
		if event.data.get("column") is Vector2i:
			var column: Vector2i=event.data.column
			for y: int in _board.h_play():cells.append(Vector3i(column.x,y,column.y))
		_hazard_cells[prefix]=cells;_update_hazards();_react_toys(&"exclaim",&"sweat");_audio.cue(&"warning")
	else:
		var remove: String={"lava_rise":"lava","lava_cooled":"lava","quake":"quake","geyser_pop":"geyser","heist_cancelled":"heist","squirrel_heist":"heist","claw_cancelled":"claw","crab_claw":"claw","lid_lowered":"lid","lid_lifted":"lid","woodpecker_peck":"woodpecker"}.get(kind,"")
		if remove!="":_hazard_cells.erase(remove);_update_hazards()


func _update_hazards() -> void:
	if _hazard_view==null:
		var box:=BoxMesh.new();box.size=Vector3(.92,.018,.92)
		var shader:=Shader.new();shader.code="""shader_type spatial;
render_mode unshaded,cull_disabled;
varying vec3 local;
void vertex(){local=VERTEX;}
void fragment(){
 float rim=step(.36,max(abs(local.x),abs(local.z)));
 if(rim<.5)discard;
 float stripes=step(.5,fract((local.x+local.z)*7.0));
 ALBEDO=mix(vec3(.20,.18,.14),vec3(1.0,.42,.07),stripes);
}"""
		var material:=ShaderMaterial.new();material.shader=shader
		_hazard_view=_multimesh(box,256,material);_hazard_view.name="StripedHazardCellBorders"
	var count: int=0
	var seen: Dictionary={}
	for cells: Array in _hazard_cells.values():
		for cell: Variant in cells:
			if not cell is Vector3i or seen.has(cell) or count>=256:continue
			seen[cell]=true
			_hazard_view.multimesh.set_instance_transform(count,Transform3D(Basis.IDENTITY,BoardGeom.cell_center(cell,_size)+Vector3.UP*.51));count+=1
	_hazard_view.multimesh.visible_instance_count=count


func _build_guides() -> void:
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	var h: float = _board.h_play()
	var w: float = _size.x * .5
	var d: float = _size.z * .5
	var sx: int = -1 if sin(deg_to_rad(_yaw)) >= 0 else 1
	var sz: int = -1 if cos(deg_to_rad(_yaw)) >= 0 else 1
	_guide_quadrant = Vector2i(sx,sz)
	for y: int in range(0, _board.h_play() + 1):
		for v: Vector3 in [Vector3(-w,y,sz*d),Vector3(w,y,sz*d),Vector3(sx*w,y,-d),Vector3(sx*w,y,d)]: im.surface_add_vertex(v)
	for x: int in range(_size.x + 1):
		im.surface_add_vertex(Vector3(x-w,0,sz*d)); im.surface_add_vertex(Vector3(x-w,h,sz*d))
	for z: int in range(_size.z + 1):
		im.surface_add_vertex(Vector3(sx*w,0,z-d)); im.surface_add_vertex(Vector3(sx*w,h,z-d))
	im.surface_end()
	var m := _mat(Color(0.29, 0.44, 0.47, 0.19), true)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if _guides == null:
		_guides = _mesh(self, im, Vector3.ZERO, m)
	else:
		_guides.mesh = im


func _update_piece(predicted: ActivePiece = null) -> void:
	var p: ActivePiece = predicted if predicted != null else _sim.get_piece()
	if p == null:
		_active.multimesh.visible_instance_count = 0
		_ghost.multimesh.visible_instance_count = 0
		_landing.multimesh.visible_instance_count = 0
		if _key_face!=null:_key_face.visible=false
		return
	_update_key_face(p)
	var piece_hue: int = p.hue_id
	var hue: Color = _palette.color(piece_hue)
	var cells: Array[Vector3i] = p.cells()
	var scale_cube: float = _art.cube_scale() * 0.97
	for i: int in mini(64, cells.size()):
		_active.multimesh.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * scale_cube), BoardGeom.cell_center(cells[i], _size)))
		_active.multimesh.set_instance_color(i, hue)
		_active.multimesh.set_instance_custom_data(i, Color(float(_palette.pattern_code(piece_hue))/16.0, 0, 0, 0))
	_active.multimesh.visible_instance_count = mini(64, cells.size())
	var ghost: Array[Vector3i] = _syrup_preview if not _syrup_preview.is_empty() else _sim.ghost_cells()
	if predicted != null:
		ghost = p.cells_at(p.orient, p.pivot + _board.down_vector() * Movement.drop_distance(p, _board))
	var columns: Dictionary = {}
	for i: int in mini(64, ghost.size()):
		_ghost.multimesh.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * .93), BoardGeom.cell_center(ghost[i], _size)))
		_ghost.multimesh.set_instance_color(i, hue)
		var c: Vector3i = ghost[i]
		var key: Vector2i = Vector2i(c.x, c.z)
		if not columns.has(key) or c.y < columns[key]: columns[key] = c.y
	_ghost.multimesh.visible_instance_count = mini(64, ghost.size())
	var slot: int = 0
	for c: Vector2i in columns:
		var pos: Vector3 = BoardGeom.cell_center(Vector3i(c.x, int(columns[c]), c.y), _size)
		pos.y = float(columns[c]) + .025
		_landing.multimesh.set_instance_transform(slot, Transform3D(Basis.IDENTITY, pos))
		slot += 1
	_landing.multimesh.visible_instance_count = slot
	if not ghost.is_empty():
		_ghost_focus = BoardGeom.cell_center(ghost[0],_size)
		_locked.set_occlusion(_occlusion_mode(),_ghost_focus,_camera.position)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_camera.current = true
	_camera.far = 150.0
	add_child(_camera)
	_update_camera()
	_refresh_status_views()


func _frame_camera() -> void:
	if _camera == null or not is_inside_tree(): return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var aspect: float = viewport_size.x / maxf(1, viewport_size.y)
	var usable: float = .88 if aspect > 1 else .62
	if _view_rect.size.y > 0:
		usable = _view_rect.size.y
		aspect *= _view_rect.size.x / _view_rect.size.y
	# Frame the visible danger height and island, rather than unused spawn-buffer rows.
	var extent: Vector3i = Vector3i(_size.x + 3, _board.h_play() + 2, _size.z + 2)
	_camera.size = CameraMath.ortho_size(extent, _elevation, aspect, .75) / usable
	_update_camera()


func _update_camera() -> void:
	if _camera == null: return
	var target := Vector3(0, _board.h_play() * .43, 0)
	var yaw: float = deg_to_rad(_yaw)
	var elev: float = deg_to_rad(_elevation)
	_camera.position = target + Vector3(sin(yaw) * cos(elev), sin(elev), cos(yaw) * cos(elev)) * 35.0
	_camera.look_at(target, Vector3.UP)
	_update_status_orientation()
	var quadrant := Vector2i(-1 if sin(yaw)>=0 else 1,-1 if cos(yaw)>=0 else 1)
	if quadrant != _guide_quadrant:
		_build_guides()
	if _locked != null:
		_locked.set_occlusion(_occlusion_mode(),_ghost_focus,_camera.position)
	if _view_rect.size.y > 0 and is_inside_tree():
		var center: Vector2 = _view_rect.position + _view_rect.size * .5
		_camera.v_offset = (center.y - .5) * _camera.size
		_camera.h_offset = (.5 - center.x) * _camera.size * get_viewport().get_visible_rect().size.aspect()


## Selects the visible playable toy and authored day/night lighting, never changing rules.
func set_story_context(context: Dictionary) -> void:
	_story_context=context.duplicate(true)
	_build_characters()
	_build_story_props()
	var lighting: Dictionary=WtStoryData.lighting(StringName(context.get("level_id","")))
	if not lighting.is_empty():
		_environment.background_color=Color(lighting.sky)
		_environment.ambient_light_energy=float(lighting.ambient)
		_key_light.light_color=Color(lighting.key)
		_key_light.light_energy=float(lighting.key_energy)
		set_meta("authored_time_of_day",lighting.time)


## Auto applies a deterministic owned theme per category; purchases remain profile owned.
func apply_cosmetics(owned: Dictionary) -> void:
	_owned_cosmetics=owned.duplicate(true)
	if _wizard!=null:
		for child: Node in _wizard.get_children():
			if child.has_meta("cosmetic_outfit"):child.queue_free()
	if _cosmetic_root!=null:_cosmetic_root.queue_free()
	_cosmetic_root=Node3D.new();_cosmetic_root.name="OwnedCosmeticLooks";add_child(_cosmetic_root)
	var stickers: String=_cosmetic_theme("stickers")
	var code: int=BIOME_LOOKS.keys().find(stickers)+1 if stickers!="party" else 11
	code=maxi(0,code)
	_locked.set_stickers(code);(_active.material_override as ShaderMaterial).set_shader_parameter(&"stickers",code)
	for category: String in ["frame","board","outfit"]:
		var theme: String=_cosmetic_theme(category)
		if theme=="":continue
		var color:=Color("#B6A397") if theme=="party" else Color(BIOME_LOOKS[theme][3]).lightened(.15)
		if category=="frame":
			for side: float in [-1,1]:
				_box(_cosmetic_root,Vector3(side*(_size.x*.5+.2),.055,0),Vector3(.11,.07,_size.z+.55),color)
				_box(_cosmetic_root,Vector3(0,.055,side*(_size.z*.5+.2)),Vector3(_size.x+.55,.07,.11),color)
				for z: float in [-1,1]:_sphere(_cosmetic_root,Vector3(side*(_size.x*.5+.2),.1,z*(_size.z*.5+.2)),.12,color)
		elif category=="board":
			var box:=BoxMesh.new();box.size=Vector3(.88,.008,.88)
			var view: MultiMeshInstance3D=_multimesh(box,_size.x*_size.z,_mat(Color.WHITE))
			(view.material_override as StandardMaterial3D).vertex_color_use_as_albedo=true
			remove_child(view);_cosmetic_root.add_child(view)
			var slot: int=0
			for z: int in _size.z:
				for x: int in _size.x:
					if not _board.is_active(_board.index(Vector3i(x,0,z))):continue
					var center: Vector3=BoardGeom.cell_center(Vector3i(x,0,z),_size);center.y=.025
					view.multimesh.set_instance_transform(slot,Transform3D(Basis.IDENTITY,center))
					view.multimesh.set_instance_color(slot,color.darkened(.12) if (x+z)%2 else color.lightened(.16));slot+=1
			view.multimesh.visible_instance_count=slot
		elif category=="outfit" and _wizard!=null:
			# Actual wardrobe geometry follows the selected character without covering the face.
			var outfit:=Node3D.new();outfit.name="OwnedOutfit_"+theme;_wizard.add_child(outfit)
			outfit.set_meta("cosmetic_outfit",true)
			_cylinder(outfit,Vector3(0,.6,.02),.35,.35,.14,color,12,Vector3(1,1,.9))
			_box(outfit,Vector3(.29,.5,.25),Vector3(.15,.24,.07),color.lightened(.2))
			_sphere(outfit,Vector3(.30,.55,.30),.04,Color("#E8D8AD"))


func _cosmetic_theme(category: String) -> String:
	var candidates: Array[String]=[str(_biome),"party"]
	for biome: String in BIOME_LOOKS.keys():
		if biome not in candidates:candidates.append(biome)
	for theme: String in candidates:
		var record: Variant=_owned_cosmetics.get(theme+"_"+category,{})
		if (record is Dictionary and bool(record.get("owned",false))) or (record is bool and record):return theme
	return ""


func _show_fit_spots(spots: Array) -> void:
	if _fit_view==null:_fit_view=_multimesh(BoxMesh.new(),128,_ghost_material());_fit_view.name="TwoRedrawSuggestions"
	var slot: int=0
	for i: int in mini(2,spots.size()):
		for cell: Variant in spots[i]:
			if cell is Vector3i and slot<128:
				_fit_view.multimesh.set_instance_transform(slot,Transform3D(Basis.from_scale(Vector3.ONE*.985),BoardGeom.cell_center(cell,_size)))
				_fit_view.multimesh.set_instance_color(slot,Color("#E8D6A4") if i==0 else Color("#B8D3D1"));slot+=1
	_fit_view.multimesh.visible_instance_count=slot


func _build_keyholes(holes: Array) -> void:
	for i: int in holes.size():
		var hole: Dictionary=holes[i]
		var wall: String=str(hole.get("wall","-x"))
		var normal: Vector3i={"-x":Vector3i.LEFT,"+x":Vector3i.RIGHT,"-z":Vector3i.FORWARD,"+z":Vector3i.BACK}.get(wall,Vector3i.LEFT)
		var cell:=Vector3i(0,int(hole.get("y",1)),0)
		if normal.x!=0:cell.x=0 if normal.x<0 else _size.x-1;cell.z=int(hole.get("row",0))
		else:cell.z=0 if normal.z<0 else _size.z-1;cell.x=int(hole.get("row",0))
		var ring:=TorusMesh.new();ring.inner_radius=.16;ring.outer_radius=.24;ring.rings=16;ring.ring_segments=6
		var node: MeshInstance3D=_mesh(_goal_overlay,ring,BoardGeom.cell_center(cell,_size)+Vector3(normal)*.52,_mat(Color("#CFB77C"),true))
		node.basis=Basis(Quaternion(Vector3.UP,Vector3(normal)));_keyholes[i]=node
		var slot:=_box(_goal_overlay,node.position-Vector3(0,.2,0),Vector3(.08,.22,.035),Color("#938362"));slot.basis=_face_basis(Vector3(normal))


func _face_basis(normal: Vector3) -> Basis:
	var up: Vector3=Vector3.FORWARD if absf(normal.y)>.9 else Vector3.UP
	return Basis.looking_at(normal,up)


func _update_key_face(piece: ActivePiece) -> void:
	if _key_face==null:
		var mesh:=TorusMesh.new();mesh.inner_radius=.11;mesh.outer_radius=.17;mesh.rings=14;mesh.ring_segments=6
		_key_face=_mesh(self,mesh,Vector3.ZERO,_mat(Color("#F4DEA1"),true));_key_face.name="RotatedStampedKeyFace"
	_key_face.visible=not _key_stamp.is_empty() and _sim.get_piece_uid()==_key_uid
	if not _key_face.visible:return
	var cell: Vector3i=piece.pivot+Orientations.apply(piece.orient,_key_stamp.get("cell",Vector3i.ZERO))
	var face: Vector3i=Orientations.apply(piece.orient,_key_stamp.get("face",Vector3i.LEFT))
	_key_face.position=BoardGeom.cell_center(cell,_size)+Vector3(face)*.51
	# Torus normal is +Y. Rotate it onto the stamped local face after piece orientation.
	_key_face.basis=Basis(Quaternion(Vector3.UP,Vector3(face)))


func _build_story_props() -> void:
	if _story_props!=null:_story_props.queue_free()
	_story_props=Node3D.new();_story_props.name="AuthoredLevelStoryProps";_world.add_child(_story_props)
	var decor: Dictionary=WtStoryData.environment(StringName(_story_context.get("level_id","")))
	if decor.is_empty():return
	var slot: int=int(decor.layout_slot)
	var side: float=-1.0 if slot%2==0 else 1.0
	var hero:=Node3D.new();hero.name="Story_"+str(decor.hero)
	_story_props.add_child(hero)
	# Ten authored slots vary approach-side and depth; always outside the active grid.
	hero.position=Vector3(side*(_size.x*.5+1.05),.02,-_size.z*.5+.18+(slot%3)*.48)
	hero.rotation.y=slot*.24
	_story_prop(hero,str(decor.hero),Color(BIOME_LOOKS[str(_biome)][3]))
	if str(decor.clue)!=str(decor.hero) and str(decor.clue)!="":
		var clue:=Node3D.new();clue.name="QuietInvitationClue";_story_props.add_child(clue)
		clue.position=Vector3(-side*(_size.x*.5+1.0),.02,-_size.z*.5-.35)
		clue.scale=Vector3.ONE*.68
		_story_prop(clue,str(decor.clue),Color("#9D88AA"))
	set_meta("authored_story_prop",decor.hero)
	set_meta("authored_layout_slot",slot)


func _story_prop(parent: Node3D, id: String, accent: Color) -> void:
	var wood:=Color("#B49C7C")
	var linen:=Color("#E9DECA")
	match id:
		"bed":
			_box(parent,Vector3(0,.19,0),Vector3(1.15,.25,.85),wood)
			_box(parent,Vector3(0,.35,0),Vector3(1.04,.14,.78),linen)
			_sphere(parent,Vector3(-.31,.49,0),.22,linen,Vector3(1,.4,1.3))
			_box(parent,Vector3(.15,.46,0),Vector3(.67,.1,.81),accent)
		"chair":
			_box(parent,Vector3(0,.42,0),Vector3(.66,.12,.63),wood)
			_box(parent,Vector3(0,.82,-.27),Vector3(.66,.79,.1),wood)
			for x: float in [-.25,.25]:
				for z: float in [-.23,.23]:_cylinder(parent,Vector3(x,.2,z),.045,.045,.45,wood,6)
		"seed","flower","acorn":
			_cylinder(parent,Vector3(0,.19,0),.3,.24,.36,wood,10)
			_cylinder(parent,Vector3(0,.52,0),.035,.035,.6,accent,7)
			for side: float in [-1,1]:_sphere(parent,Vector3(side*.18,.67,0),.2,accent,Vector3(1.2,.35,.6))
			if id=="flower":
				for i: int in 5:_sphere(parent,Vector3(cos(i*TAU/5)*.2,.92+sin(i*TAU/5)*.2,0),.16,linen,Vector3(1,1,.5))
				_sphere(parent,Vector3(0,.92,.06),.1,wood)
		"mushroom":
			for i: int in 3:
				_cylinder(parent,Vector3((i-1)*.3,.25,0),.085,.13,.48,linen,8)
				_sphere(parent,Vector3((i-1)*.3,.49,0),.27,accent,Vector3(1,.6,1))
		"basket","egg","pearl":
			_cylinder(parent,Vector3(0,.27,0),.43,.37,.53,wood,12)
			for i: int in 3:_sphere(parent,Vector3((i-1)*.23,.48,.05),.21,linen,Vector3(.8,1.15,.8))
		"tower","cube","gift","cake":
			for i: int in (3 if id=="tower" else 1):_box(parent,Vector3((i%2)*.12,.28+i*.5,0),Vector3(.68,.5,.65),accent.lightened(i*.1))
			if id in ["cake","gift"]:
				_box(parent,Vector3(0,.58,0),Vector3(.75,.1,.72),linen)
				_cylinder(parent,Vector3(0,.73,0),.025,.025,.25,wood,6)
		"bridge":
			for i: int in 5:_box(parent,Vector3((i-2)*.21,.29,0),Vector3(.18,.12,.63),wood)
			for z: float in [-.3,.3]:_box(parent,Vector3(0,.65,z),Vector3(1.2,.08,.07),wood)
		"clock","gear","flip":
			var ring:=TorusMesh.new();ring.inner_radius=.22;ring.outer_radius=.45;ring.rings=12;ring.ring_segments=7
			var node:=_mesh(parent,ring,Vector3(0,.53,0),_mat(wood));node.rotation.x=PI*.5
			_box(parent,Vector3(0,.53,.04),Vector3(.035,.55,.035),accent)
			_box(parent,Vector3(.1,.53,.04),Vector3(.3,.035,.035),accent)
		"ice","star","moon":
			for i: int in 3:
				var crystal:=_cylinder(parent,Vector3((i-1)*.23,.42,0),0,.21,.83+(i%2)*.3,accent.lightened(.18),5)
				crystal.rotation.z=(i-1)*.18
		"invite":
			_box(parent,Vector3(0,.55,0),Vector3(.76,.47,.045),linen)
			_box(parent,Vector3(0,.56,.032),Vector3(.46,.055,.025),accent)
			_cylinder(parent,Vector3(-.43,.45,0),.025,.025,.9,wood,7)
		"hat":
			_cylinder(parent,Vector3(0,.22,0),.58,.58,.08,accent,12)
			_cylinder(parent,Vector3(0,.69,0),.04,.43,.9,accent,12)
		"wind","mill","fog","dew","note","ember","lantern":
			_cylinder(parent,Vector3(0,.5,0),.07,.07,1.0,wood,8)
			_sphere(parent,Vector3(0,1.03,0),.22,accent,Vector3(1,.8,.7))
			for i: int in 4:
				var vane:=_box(parent,Vector3(sin(i*PI*.5)*.25,1.03+cos(i*PI*.5)*.25,0),Vector3(.12,.42,.05),linen)
				vane.rotation.z=-i*PI*.5
		_:_sphere(parent,Vector3(0,.25,0),.3,accent)


func _build_characters() -> void:
	if _character_root!=null:
		_character_root.get_parent().remove_child(_character_root)
		_character_root.queue_free()
	_character_root=Node3D.new();_character_root.name="OriginalToyCast";_world.add_child(_character_root)
	var selected: StringName=StringName(_story_context.get("character",_story_context.get("character_id","cloud")))
	if selected not in [&"cloud",&"lana",&"boulder",&"glim"]:selected=&"cloud"
	_wizard=WtToyActor.new();_wizard.name="Playable_"+str(selected)
	_character_root.add_child(_wizard);_wizard.setup(selected);_wizard.set_reduced_motion(_reduced())
	_wizard.position=Vector3(_size.x*.5+1.35,.1,_size.z*.22)
	_wizard.rotation.y=.3
	_mascot=WtToyActor.new();_mascot.name="BiomeMascot"
	_character_root.add_child(_mascot);_mascot.setup(StringName(WtStoryData.MASCOTS.get(str(_biome),"pip")))
	_mascot.set_reduced_motion(_reduced());_mascot.position=Vector3(-_size.x*.5-1.0,.05,_size.z*.18)
	_mascot.rotation.y=.6
	var level_id: String=str(_story_context.get("level_id",""))
	_boss=null
	if level_id.ends_with("_10"):
		_boss=WtToyActor.new();_boss.name="BiomeBoss"
		_character_root.add_child(_boss);_boss.setup(StringName(WtStoryData.BOSSES.get(str(_biome),"miller")))
		_boss.position=Vector3(-_size.x*.5-1.15,0,-_size.z*.5-.65)
		_boss.set_reduced_motion(_reduced());_boss.set_pose(&"peek")
	var keepsakes: Variant=_story_context.get("keepsakes",[])
	var count: int=mini(10,keepsakes.size()) if keepsakes is Array or keepsakes is Dictionary else 0
	for i: int in count:
		_sphere(_wizard,Vector3((i%5-2)*.13,1.45+(i/5)*.14,.35),.048,_palette.color(1+i%10))
	if not _owned_cosmetics.is_empty():apply_cosmetics(_owned_cosmetics)
	if bool(_story_context.get("mizzle_redeemed",false)) and _biome==&"celestial":
		var mizzle:=WtToyActor.new();mizzle.name="RedeemedMizzle";_character_root.add_child(mizzle)
		mizzle.setup(&"mizzle");mizzle.position=Vector3(_size.x*.5+1.4,0,-_size.z*.5-.4);mizzle.set_pose(&"sit")


func _react_toys(emote: StringName, mascot_emote: StringName = &"") -> void:
	if _wizard!=null:_wizard.react(emote,1.0,_reduced())
	if _mascot!=null and mascot_emote!=&"":_mascot.react(mascot_emote,1.0,_reduced())


func _syrup_band(data: Dictionary) -> void:
	if _syrup_root!=null:_syrup_root.queue_free()
	_syrup_root=Node3D.new();_syrup_root.name="SyrupFlowBands";_world.add_child(_syrup_root)
	var rows: Array=data.get("rows",[])
	for row: Variant in rows:
		var z: int=int(row)
		if z<0 or z>=_size.z:continue
		_box(_syrup_root,Vector3(0,.04,z-(_size.z-1)*.5),Vector3(_size.x,.025,.4),Color("#BFA389"))


func _build_props() -> void:
	var look: Array = BIOME_LOOKS.get(str(_biome), BIOME_LOOKS["meadow"])
	var z: float = -_size.z * .5 - .9
	for i: int in 5:
		var x: float = -_size.x * .5 - .5 + i * (_size.x + 1.0) / 4.0
		var p: Vector3 = Vector3(x, .02, z)
		match _biome:
			&"meadow", &"forest":
				_cylinder(_world, p + Vector3(0,.3,0), .07,.1,.65,Color("#8B7455"),7)
				_sphere(_world, p + Vector3(0,.85,0), .53, Color(look[3]), Vector3(.8,1.2,.8))
			&"candy":
				_cylinder(_world,p+Vector3(0,.5,0),.04,.04,1,Color("#E9DECA"),7)
				_sphere(_world,p+Vector3(0,1.1,0),.43,Color(look[3]).lightened(.15),Vector3(1,1,.5))
			&"ice", &"cave", &"neon", &"celestial":
				var crystal := _cylinder(_world,p+Vector3(0,.65,0),0,.32,1.3+(i%2)*.3,Color(look[3]).lightened(.18),5)
				crystal.rotation.z = -.12 + .06 * i
			&"lava":
				_cylinder(_world,p+Vector3(0,.32,0),.22,.5,.7,Color(look[2]),7)
				_sphere(_world,p+Vector3(0,.69,0),.19,Color("#DDA178"),Vector3(1,.3,1))
			&"underwater":
				for branch: int in 3:
					var coral := _cylinder(_world,p+Vector3((branch-1)*.17,.35,0),.07,.1,.7,Color(look[3]).lightened(.2),7)
					coral.rotation.z = (branch-1)*.35
			&"clockwork":
				var gear := TorusMesh.new()
				gear.inner_radius=.23;gear.outer_radius=.5;gear.rings=12;gear.ring_segments=6
				var node: MeshInstance3D = _mesh(_world,gear,p+Vector3(0,.55,0),_mat(Color(look[3])))
				node.rotation.x=PI*.5
	if _biome == &"meadow":
		var mill := Node3D.new()
		mill.position = Vector3(_size.x*.5+1.1,0,-_size.z*.5-.4)
		_world.add_child(mill)
		_cylinder(mill,Vector3(0,.8,0),.4,.55,1.6,Color("#D6C5A2"),10)
		_cylinder(mill,Vector3(0,1.85,0),0,.62,.6,Color("#9E8265"),10)
		_windmill=Node3D.new();_windmill.position=Vector3(0,1.25,.54);mill.add_child(_windmill)
		for i: int in 4:
			var blade := _box(_windmill,Vector3(0,.53,0),Vector3(.19,1.04,.06),Color("#E8D9B6"))
			blade.position=Vector3(sin(i*PI*.5)*.53,cos(i*PI*.5)*.53,0)
			blade.rotation.z=-i*PI*.5
		_sphere(_windmill,Vector3.ZERO,.13,Color("#94795E"))
	# Quiet clouds and pebble clusters are outside the active grid.
	for i: int in 6:
		var a: float = i * 1.04
		_sphere(_world,Vector3(cos(a)*(_size.x*.55+.9),-.14,sin(a)*(_size.z*.55+.9)),.2,Color(look[3]).lightened(.18),Vector3(1.4,.65,1))


func _build_fx() -> void:
	var box := BoxMesh.new()
	box.size = Vector3(.09,.16,.04)
	_fx_material = _mat(Color.WHITE,true)
	_fx_material.vertex_color_use_as_albedo=true
	_confetti=_multimesh(box,120,_fx_material)
	var ring := TorusMesh.new()
	ring.inner_radius=.38;ring.outer_radius=.47;ring.rings=20;ring.ring_segments=6
	var mark_material := _mat(Color.WHITE,true)
	mark_material.vertex_color_use_as_albedo=true
	_telegraphs=_multimesh(ring,64,mark_material)


func _mark_cell(key: String, cell: Vector3i, tint: Color, seconds: float = -1.0) -> void:
	_marks[key]={"cell":cell,"color":tint,"until":_time+seconds if seconds>0.0 else -1.0}
	_update_marks()


func _update_marks() -> void:
	if _telegraphs == null: return
	var count: int = 0
	for key: Variant in _marks.keys():
		var mark: Dictionary = _marks[key]
		if float(mark["until"])>0.0 and _time>float(mark["until"]):
			_marks.erase(key)
			continue
		if count>=64: break
		var pos: Vector3 = BoardGeom.cell_center(mark["cell"],_size)+Vector3.UP*.51
		_telegraphs.multimesh.set_instance_transform(count,Transform3D(Basis.from_scale(Vector3(1,.16,1)),pos))
		_telegraphs.multimesh.set_instance_color(count,mark["color"])
		count += 1
	_telegraphs.multimesh.visible_instance_count=count


func _place_secret(data: Dictionary) -> void:
	var id: String = str(data.get("id","angle_gem"))
	if _secrets.has(id): return
	var gem := Node3D.new()
	gem.name = "DiscoverableGem"
	gem.position = Vector3(-_size.x*.65-.55,-1.0,_size.z*.42)
	_world.add_child(gem)
	_cylinder(gem,Vector3(0,.2,0),0,.32,.4,Color("#B4DCC5"),5)
	_cylinder(gem,Vector3(0,-.16,0),.32,0,.32,Color("#75ADA5"),5)
	var body := StaticBody3D.new()
	body.collision_layer=128;body.collision_mask=0
	body.set_meta("secret_id",id)
	gem.add_child(body)
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius=.42
	collision.shape=sphere
	body.add_child(collision)
	_secrets[id]=gem


func _update_fx(delta: float) -> void:
	for i: int in range(_fx.size()-1,-1,-1):
		_fx[i]["t"] += delta
		if _fx[i]["t"] > 1.25:
			_fx.remove_at(i)
			continue
		_fx[i]["v"].y -= delta*5
		_fx[i]["p"] += _fx[i]["v"]*delta
	for i: int in _fx.size():
		var spin: Basis = Basis.from_euler(Vector3(_fx[i]["t"]*3, i*.6, _fx[i]["t"]*4))
		_confetti.multimesh.set_instance_transform(i,Transform3D(spin,_fx[i]["p"]))
		_confetti.multimesh.set_instance_color(i,_fx[i]["color"])
	_confetti.multimesh.visible_instance_count=_fx.size()


func _block_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """shader_type spatial;
uniform int stickers = 0;
uniform bool patterns = false;
uniform bool high_contrast = false;
varying vec3 local_pos;
varying vec3 local_normal;
varying float motif;
void vertex(){local_pos=VERTEX;local_normal=NORMAL;motif=INSTANCE_CUSTOM.r;}
void fragment(){
 vec3 base=COLOR.rgb;
 float seam = 1.0 - smoothstep(0.40,0.49,max(abs(local_pos.x),max(abs(local_pos.y),abs(local_pos.z))));
 vec2 uv=abs(local_normal.y)>.5?local_pos.xz:(abs(local_normal.x)>.5?local_pos.zy:local_pos.xy);
 int code=int(floor(motif*16.0+.1));
 float stripe=0.0;
 if(code==1)stripe=step(.8,fract(uv.y*5.0));
 if(code==2)stripe=1.0-step(.16,length(fract(uv*4.0)-vec2(.5)));
 if(code==3)stripe=step(.8,fract(uv.y*4.0+sin(uv.x*12.0)*.18));
 if(code==4)stripe=mod(floor(uv.x*4.0)+floor(uv.y*4.0),2.0);
 if(code==5)stripe=step(.8,fract(length(uv)*8.0));
 if(code==6)stripe=max(step(.85,fract(uv.y*4.0)),step(.88,fract(uv.x*4.0+floor(uv.y*4.0)*.5)));
 vec2 st=abs(fract(uv*3.0)-vec2(.5));
 if(code==7)stripe=max((1.0-step(.06,st.x))*(1.0-step(.24,st.y)),(1.0-step(.06,st.y))*(1.0-step(.24,st.x)));
 if(code==8)stripe=1.0-step(.07,abs(st.x+st.y-.34));
 if(code==9)stripe=step(.8,fract(uv.x*5.0));
 if(code==10)stripe=max(step(.85,fract(uv.x*4.0)),step(.85,fract(uv.y*4.0)));
 ALBEDO=base*(0.88+0.12*seam);
 if(patterns)ALBEDO*=1.0-stripe*(high_contrast?.58:.26);
 if(stickers>0){
  vec2 badge=uv-vec2(.23,.23);float mark=0.0;
  if(stickers%3==0)mark=1.0-step(.055,abs(badge.x)+abs(badge.y));
  if(stickers%3==1)mark=1.0-step(.048,length(badge));
  if(stickers%3==2)mark=(1.0-step(.048,abs(badge.x)))*(1.0-step(.025,abs(badge.y)));
  ALBEDO=mix(ALBEDO,vec3(.97,.92,.77),mark*.8);
 }
 ROUGHNESS=0.32;SPECULAR=0.45;
}"""
	var m := ShaderMaterial.new();m.shader=shader
	return m


func _ghost_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
varying vec3 lp;
void vertex(){lp=VERTEX;}
void fragment(){
 vec3 e=abs(abs(lp)-vec3(.5));
 float near=step(e.x,.045)+step(e.y,.045)+step(e.z,.045);
 float edge=step(2.0,near);
 float hatch=step(.7,fract((lp.x+lp.y+lp.z)*5.0));
 ALBEDO=mix(COLOR.rgb*.65,vec3(.12,.22,.24),edge);
 ALPHA=mix(.10+hatch*.21,.72,edge);
}"""
	var m := ShaderMaterial.new();m.shader=shader
	return m


func _multimesh(mesh: Mesh, count: int, mat: Material) -> MultiMeshInstance3D:
	var mm := MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_colors=true;mm.use_custom_data=true
	mm.mesh=mesh;mm.instance_count=count;mm.visible_instance_count=0
	var node := MultiMeshInstance3D.new();node.multimesh=mm;node.material_override=mat
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)
	return node


func _mat(color: Color, unshaded: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new();m.albedo_color=color;m.roughness=.9
	if unshaded: m.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


func _mesh(parent: Node3D, mesh: Mesh, pos: Vector3, mat: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new();node.mesh=mesh;node.material_override=mat;node.position=pos
	parent.add_child(node)
	return node


func _sphere(parent: Node3D, pos: Vector3, radius: float, color: Color, stretch: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mesh := SphereMesh.new();mesh.radius=radius;mesh.height=radius*2;mesh.radial_segments=12;mesh.rings=6
	var node: MeshInstance3D=_mesh(parent,mesh,pos,_mat(color));node.scale=stretch
	return node


func _cylinder(parent: Node3D, pos: Vector3, top: float, bottom: float, height: float, color: Color, sides: int = 10, stretch: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mesh := CylinderMesh.new();mesh.top_radius=top;mesh.bottom_radius=bottom;mesh.height=height;mesh.radial_segments=sides
	var node: MeshInstance3D=_mesh(parent,mesh,pos,_mat(color));node.scale=stretch
	return node


func _box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new();mesh.size=size
	return _mesh(parent,mesh,pos,_mat(color))
