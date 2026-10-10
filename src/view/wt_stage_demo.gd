extends Node3D
## Reproducible presentation probe. This scene is never the production entrypoint.

var _stage: WtStage
var _sim: BoardSim
var _tick_enabled: bool = false


func _ready() -> void:
	var catalog := GameCatalog.new()
	catalog.shapes = load("res://assets/data/shapes/shape_bank.tres") as ShapeBank
	catalog.content = ContentTypes.from_entries(JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/content/blocks.json")).get("types", []))
	var tables: Array = []
	for file: String in DirAccess.get_files_at("res://assets/data/knobs"):
		if file.ends_with(".json"):
			tables.append(JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/knobs/" + file)))
	catalog.knob_defs = KnobDefs.from_tables(tables)
	catalog.plugins = PluginRegistry.new(ProjectSettings.get_global_class_list())
	catalog.limits = BoardLimits.new()
	var result: LoadResult = LevelLoader.load_level("res://src/levels/meadow/meadow_01/meadow_01.json", catalog)
	if not result.ok():
		push_error("Presentation probe refused invalid level")
		return
	_sim = BoardSim.new(result.level, 17, catalog)
	for i: int in 180:
		_sim.step()
	var b: BoardState = _sim.board()
	for z: int in 4:
		for x: int in 4:
			if x < 2 and z < 2: continue
			var hue_id: int = 1+(x+4*z)%10 if OS.get_cmdline_user_args().has("--pattern-probe") else 1+(x+z)%5
			b.place(b.index(Vector3i(x,0,z)),1,hue_id,99)
	_stage = WtStage.new()
	add_child(_stage)
	var biome: StringName = &"meadow"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--biome="): biome = StringName(arg.trim_prefix("--biome="))
	_stage.setup(_sim,biome,{"music_volume":0.0})
	var story_level: String=str(biome)+"_01"
	var character: String="cloud"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--story-level="):story_level=arg.trim_prefix("--story-level=")
		if arg.begins_with("--character="):character=arg.trim_prefix("--character=")
	_stage.set_story_context({"level_id":story_level,"character":character})
	if OS.get_cmdline_user_args().has("--cosmetic-probe"):
		_stage.apply_cosmetics({str(biome)+"_board":{"owned":true},str(biome)+"_frame":{"owned":true},str(biome)+"_stickers":{"owned":true},str(biome)+"_outfit":{"owned":true}})
	if OS.get_cmdline_user_args().has("--pattern-probe"):
		_stage.apply_settings({"music_volume":0.0,"colorblind":"high_contrast"})
	_stage.set_goal(result.level.goal)
	if OS.get_cmdline_user_args().has("--key-probe"):
		_stage.set_goal({"type":"wind_keys","keyholes":[{"wall":"+x","y":1,"row":1},{"wall":"+z","y":3,"row":2}]})
		_stage.sync([SimEvent.make(0,&"key_stamp",{"cell":Vector3i.ZERO,"face":Vector3i.RIGHT}),SimEvent.make(0,&"fit_spots",{"spots":[[Vector3i(0,0,0),Vector3i(1,0,0),Vector3i(1,0,1)],[Vector3i(0,1,3),Vector3i(1,1,3),Vector3i(2,1,3)]]})])
	if OS.get_cmdline_user_args().has("--telegraph-probe"):
		_stage.sync([SimEvent.make(0,&"fog_visibility",{"alpha":.6}),
			SimEvent.make(0,&"mushroom_warning",{"cell":Vector3i(0,0,0)}),
			SimEvent.make(0,&"mascot_hint",{"cells":[Vector3i(1,0,1)]}),
			SimEvent.make(0,&"secret_placed",{"id":"probe_gem"})])
	var caption := Label.new()
	caption.text = "WACKY TOWERS  /  presentation probe    ·    Z/C rotate view    ·    Space drop    ·    right drag orbit"
	caption.position = Vector2(24,22)
	caption.size.x = maxf(240.0, get_viewport().get_visible_rect().size.x - 48.0)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_color_override("font_color",Color("#2A4050"))
	var layer := CanvasLayer.new()
	add_child(layer)
	layer.add_child(caption)
	print("STAGE_PROBE: biome=meadow real_cube_mesh=",_stage._art.cube_mesh()!=null," locked=",_stage._locked.filled_count())


func _physics_process(_delta: float) -> void:
	if _tick_enabled and _stage != null:
		_stage.sync(_sim.step())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and _stage != null:
		match event.keycode:
			KEY_Z: _stage.rotate_view(-1)
			KEY_C: _stage.rotate_view(1)
			KEY_SPACE:
				_sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
				_tick_enabled = true
			KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN:
				var dirs: Dictionary={KEY_LEFT:Vector2i(-1,0),KEY_RIGHT:Vector2i(1,0),KEY_UP:Vector2i(0,-1),KEY_DOWN:Vector2i(0,1)}
				_sim.queue_command(SimCommand.make(SimEvents.CMD_MOVE,[_stage.get_move_vector(dirs[event.keycode])]))
				_stage.sync(_sim.step())
