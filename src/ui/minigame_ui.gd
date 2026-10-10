class_name WtMinigameUi
extends Control
## Reusable, snapshot-only tournament round view. All commands are semantic intents.
signal intent(id: StringName, args: Dictionary)
const INK := Color("243b4d")
const CREAM := Color("fff8e7")
const MINT := Color("b8ddc7")
const ORANGE := Color("eaa05b")
const Art := preload("res://src/view/wt_minigame_art.gd")
const NAMES := ["Hole in the Wall", "Copycat", "Colour Rush", "Perfect Stack", "Crane Tower", "Mascot Bridge Race", "Box Packers", "Gift Exchange", "Speed Sort", "Shadow Duel", "Memory Tower", "Spin Cycle", "Floor Is Lava", "Hot Block", "Catch Tower", "Rhythm Stack", "Magnet Maze", "Balloon Volley", "Gem Grab", "Paint Dash", "Balance Budget"]
var snapshot: Dictionary = {}
var _prefs: Dictionary = {}
var _built_id := ""
var _portrait := false
var _column: VBoxContainer
var _title: Label
var _metric: Label
var _warning: Label
var _clock: Label
var _arena: Arena
var _controls: HFlowContainer
var _targets: HFlowContainer
var _gifts: HFlowContainer
var _send: Button
var _charge: ProgressBar
var _buttons: Array[Button] = []
var _gift_signature := ""
var _target_signature := ""
var _state_note: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_on_resized)
	_build()

func set_prefs(prefs: Dictionary) -> void:
	_prefs = prefs.duplicate(true)
	if is_inside_tree(): _build()

func set_snapshot(data: Dictionary) -> void:
	snapshot = data.duplicate(true)
	if not is_inside_tree(): return
	var id := str(snapshot.get("id", "mg01")).to_lower()
	if id != _built_id: _build()
	_update()

func _on_resized() -> void:
	var portrait := size.x < size.y
	if portrait != _portrait: _build()

func _text_scale() -> float:
	var value := float(_prefs.get("text_scale", 1.0))
	return clampf(value / 100 if value > 3 else value, 1, 1.5)

func _build() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_buttons.clear()
	_built_id = str(snapshot.get("id", "mg01")).to_lower()
	_portrait = size.x < size.y
	_gift_signature = ""
	_target_signature = ""
	_column = VBoxContainer.new()
	_column.add_theme_constant_override("separation", 8)
	add_child(_column)
	_column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var header := HBoxContainer.new()
	_column.add_child(header)
	var names := VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(names)
	_title = _label("", 26)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	names.add_child(_title)
	_metric = _label("", 17)
	names.add_child(_metric)
	header.add_child(make_art_preview(_built_id,Vector2i(96,80)))
	_clock = _label("", 25)
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(_clock)
	var pause := _button("Ⅱ", &"pause")
	pause.custom_minimum_size.x = 56
	pause.size_flags_horizontal = Control.SIZE_SHRINK_END
	pause.tooltip_text = "Pause the round"
	header.add_child(pause)
	_warning = _label("", 17)
	_warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_column.add_child(_warning)
	_arena = Arena.new()
	_arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_arena.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_arena.custom_minimum_size.y = 220 if not _portrait else 320
	_column.add_child(_arena)
	_state_note = _label("", 16)
	_state_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_column.add_child(_state_note)
	_gifts = _flow()
	_column.add_child(_gifts)
	_targets = _flow()
	_column.add_child(_targets)
	_controls = _flow()
	_column.add_child(_controls)
	_build_actions()
	var send_row := HBoxContainer.new()
	send_row.name = "SendRow"
	_column.add_child(send_row)
	_charge = ProgressBar.new()
	_charge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_charge.custom_minimum_size.y = 18
	_charge.show_percentage = false
	_charge.max_value = 1
	send_row.add_child(_charge)
	_send = _button("Send →", &"mg_send")
	_send.custom_minimum_size.x = 150
	send_row.add_child(_send)
	_update()

static func make_art_preview(id: String, dimensions: Vector2i = Vector2i(160,140)) -> SubViewportContainer:
	var container := SubViewportContainer.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.custom_minimum_size = Vector2(dimensions)
	container.stretch = true
	var viewport := SubViewport.new()
	viewport.size = dimensions
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	container.add_child(viewport)
	var actor: Node3D = Art.create(id)
	viewport.add_child(actor)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.5
	camera.position = Vector3(3.5,3,4.5)
	viewport.add_child(camera)
	camera.look_at_from_position(Vector3(3.5,3,4.5),Vector3(0,1.1,0))
	camera.current = true
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45,-35,0)
	light.light_color = Color("fff0d1")
	light.light_energy = 1.5
	viewport.add_child(light)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("c7e6e4")
	environment.environment.ambient_light_energy = .7
	viewport.add_child(environment)
	return container

func _label(value: String, pixels: int) -> Label:
	var node := Label.new()
	node.text = value
	node.add_theme_color_override("font_color", INK)
	node.add_theme_font_size_override("font_size", roundi(pixels * _text_scale()))
	return node

func _flow() -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 8)
	return flow

func _button(value: String, id: StringName, args: Dictionary = {}) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size = Vector2(100, 56)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", roundi(16 * _text_scale()))
	button.pressed.connect(func() -> void: intent.emit(id, args.duplicate(true)))
	return button

func _action(label: String, id: StringName, args: Dictionary = {}) -> void:
	var button := _button(label, id, args)
	_controls.add_child(button)
	_buttons.append(button)

func _build_actions() -> void:
	if _built_id == "mg09":
		for bin: int in 3: _action(["← Bin 1", "↓ Bin 2", "Bin 3 →"][bin], &"mg_sort", {"bin":bin})
		return
	if _built_id == "mg04":
		_action("Release ↓", &"mg_drop")
		return
	if _built_id == "mg16":
		for lane: int in 4: _action("♪ %d" % (lane+1), &"mg_rhythm_hit", {"lane":lane})
		return
	if _built_id == "mg18":
		_action("Return ↑", &"mg_volley")
		return
	if _built_id == "mg21":
		_action("Left pan", &"mg_pan", {"side":"left"})
		_action("Right pan", &"mg_pan", {"side":"right"})
		_action("Release ✓", &"mg_release")
		return
	if _built_id == "mg05": return # Native Jolt scene owns crane input.
	for row: Array in [["←", Vector3i.LEFT], ["↑", Vector3i(0,0,-1)], ["↓", Vector3i(0,0,1)], ["→", Vector3i.RIGHT]]:
		if _built_id == "mg17": _action(row[0], &"mg_magnet_move", {"direction":Vector2i(row[1].x,row[1].z)})
		else: _action(row[0], &"mg_move", {"direction":row[1]})
	if _built_id == "mg17":
		_action("Polarity ±", &"mg_polarity")
		_action("Reset ↻", &"mg_reset")
		return
	if _built_id == "mg19":
		_action("Collect ◇", &"mg_collect")
		_action("Deposit ▣", &"mg_deposit")
		return
	if _built_id == "mg20":
		_action("Paint ●", &"mg_paint")
		return
	if _built_id == "mg15": return # Sky pieces fall automatically.
	for axis: int in 3:
		for dir: int in [-1,1]: _action(["Turn", "Flip", "Roll"][axis] + (" ‹" if dir < 0 else " ›"), &"mg_rotate", {"axis":axis,"dir":dir})
	if _built_id != "mg01":
		_action("Drop ↓", &"mg_drop")
		if _built_id in ["mg02", "mg07"]: _action("Hold", &"mg_hold")

func _update() -> void:
	if not is_instance_valid(_title): return
	var index := clampi(int(_built_id.trim_prefix("mg")) - 1, 0, NAMES.size()-1)
	_title.text = str(snapshot.get("name", NAMES[index]))
	var metric := str(snapshot.get("standing_metric", "score")).replace("_", " ").capitalize()
	_metric.text = "%s  %s" % [metric, str(snapshot.get("standing", snapshot.get("score",0)))]
	var remaining := maxi(0, int(snapshot.get("duration_ms", 60000)) - int(snapshot.get("elapsed_ms", 0)))
	_clock.text = "%d:%02d" % [remaining / 60000, (remaining / 1000) % 60]
	var phase := str(snapshot.get("phase", "playing"))
	var playing := phase == "playing"
	for button: Button in _buttons: button.disabled = not playing
	var view: Dictionary = snapshot.get("view", {})
	if _built_id == "mg02" and int(view.get("show_until",0)) > int(snapshot.get("elapsed_ms",0)):
		for button: Button in _buttons: button.disabled = true
	if _built_id == "mg09" and int(view.get("jam_until",0)) > int(snapshot.get("elapsed_ms",0)):
		for button: Button in _buttons: button.disabled = true
	if _built_id == "mg18":
		for button: Button in _buttons: button.disabled = not playing or bool(view.get("waiting",false)) or int(snapshot.get("elapsed_ms",0)) < int(view.get("return_start",0)) or int(snapshot.get("elapsed_ms",0)) > int(view.get("return_end",0))
	_arena.data = snapshot
	_arena.queue_redraw()
	_warning.text = _warning_text(view)
	_warning.visible = not _warning.text.is_empty()
	_state_note.text = str(view.get("hint", ""))
	if _built_id=="mg02": _state_note.text = "Look closely · remember every cube" if int(view.get("show_until",0))>int(snapshot.get("elapsed_ms",0)) else "Now rebuild the little model from memory."
	elif _built_id=="mg19": _state_note.text = "Bag %d/%d · bring your gems back to the home tile"%[int(view.get("bag_count",0)),int(view.get("bag_capacity",5))]
	elif _built_id=="mg20": _state_note.text = "Stencil %d%% · accuracy %d%%"%[roundi(float(view.get("coverage",0))*100),roundi(float(view.get("accuracy",0))*100)]
	elif _built_id=="mg21": _state_note.text = "Balance the masses · Left %d / Right %d"%[int(view.get("left_mass",0)),int(view.get("right_mass",0))]
	elif _built_id=="mg17": _state_note.text = "Pull +" if int(view.get("polarity",1))==1 else "Push −"
	elif _built_id=="mg16": _state_note.text = "Tap the matching lane on the mint line · combo %d"%int(view.get("combo",0))
	if phase == "ghost": _state_note.text = "Your tower rests. Send a little surprise when your ghost charge is ready."
	if phase == "finished": _state_note.text = "Round complete · waiting for your friends"
	_state_note.visible = not _state_note.text.is_empty()
	var send: Dictionary = snapshot.get("send", {})
	_send.get_parent().visible = not str(send.get("effect", "")).is_empty() or bool(snapshot.get("ghost", false))
	_send.disabled = not bool(send.get("ready", false)) or phase == "finished"
	_send.text = "Ghost send →" if phase == "ghost" else ("Send →" if bool(send.get("ready", false)) else "Charging…")
	_send.tooltip_text = str(send.get("effect", "")).replace("_", " ").capitalize()
	_charge.value = clampf(float(send.get("charge", 0)) / maxf(1, float(send.get("needed", 1))), 0, 1)
	_update_gifts(view, playing)
	_update_targets(playing or phase == "ghost")

func _warning_text(view: Dictionary) -> String:
	var attacks: Array = snapshot.get("attacks", [])
	if not attacks.is_empty():
		var attack: Dictionary = attacks[0]
		var effect := str(attack.get("effect", "Surprise")).replace("_", " ").capitalize()
		return "!  %s incoming · %s" % [effect, str(attack.get("sender_name", "a friend"))]
	if view.has("warning"): return str(view.warning)
	if bool(view.get("golden", false)): return "★  Golden piece · first correct sort wins the bonus"
	if int(view.get("jam_until", 0)) > int(snapshot.get("elapsed_ms", 0)): return "!  Chute jam · a tiny breather"
	return ""

func _update_gifts(view: Dictionary, playing: bool) -> void:
	var choices: Array = view.get("piece_offers",[]) if _built_id=="mg21" else view.get("gift_offers",view.get("gifts", view.get("gift_choices", view.get("offers", []))))
	var signature := str(choices)
	if signature != _gift_signature:
		_gift_signature = signature
		for child: Node in _gifts.get_children():
			_gifts.remove_child(child)
			child.queue_free()
		for index: int in choices.size():
			var choice: Variant = choices[index]
			var name := str(choice.get("shape_id",choice.get("id", choice.get("name", "Gift")))) if choice is Dictionary else str(choice)
			var title := "%s · %dg"%[name.replace("_"," ").capitalize(),int(choice.get("mass",0))] if _built_id=="mg21" and choice is Dictionary else "Gift %d · %s"%[index+1,name.replace("_"," ").capitalize()]
			var button := _button(title,&"mg_choose" if _built_id=="mg21" else &"mg_choose_gift",{"index":index})
			button.set_meta("choice_index",index)
			_gifts.add_child(button)
	_gifts.visible = not choices.is_empty()
	for button: Node in _gifts.get_children():
		button.disabled = not playing
		if _built_id=="mg21": button.modulate = MINT if int(button.get_meta("choice_index",-1))==int(view.get("selected_offer",0)) else Color.WHITE

func _update_targets(enabled: bool) -> void:
	var opponents: Array = snapshot.get("opponents", [])
	var signature := str(opponents.map(func(row: Dictionary) -> String: return str(row.get("id",0))+str(row.get("active",true))))
	if signature != _target_signature:
		_target_signature = signature
		for child: Node in _targets.get_children():
			_targets.remove_child(child)
			child.queue_free()
		for opponent: Dictionary in opponents:
			if not opponent.get("active", true): continue
			var button := _button(str(opponent.get("name", "Friend")), &"mg_target", {"player_id":int(opponent.get("id", 0))})
			button.tooltip_text = "Pick this friend for your next send"
			button.set_meta("opponent_id", int(opponent.get("id",0)))
			_targets.add_child(button)
	_targets.visible = not opponents.is_empty() and _send.get_parent().visible
	var target := int((snapshot.get("send", {}) as Dictionary).get("target", 0))
	for button: Node in _targets.get_children():
		button.disabled = not enabled
		button.modulate = MINT if int(button.get_meta("opponent_id", 0)) == target else Color.WHITE

class Arena extends Control:
	var data: Dictionary = {}
	const PALETTE := [Color("ed9d72"),Color("8dbeb5"),Color("adb1d5"),Color("e6c875")]
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _caption(text: String, point: Vector2, color: Color = Color("243b4d")) -> void:
		draw_string(get_theme_default_font(), point, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, color)
	func _draw() -> void:
		if size.x < 10 or size.y < 10: return
		var panel := StyleBoxFlat.new()
		panel.bg_color = Color("f8efd8")
		panel.set_corner_radius_all(18)
		panel.border_color = Color("b5c8c1")
		panel.set_border_width_all(2)
		draw_style_box(panel, Rect2(Vector2.ZERO,size))
		var view: Dictionary = data.get("view", {})
		var id := str(data.get("id", "mg01"))
		var area := Rect2(Vector2(18,40), Vector2(size.x-36,size.y-54))
		match id:
			"mg01":
				var hole: Array = []
				for cell: Variant in view.get("hole", []): hole.append(Vector2i(cell))
				var projection: Array = []
				var axis := int(view.get("wall_axis", 0))
				for cell: Vector3i in (data.get("piece", {}) as Dictionary).get("cells", []): projection.append(Vector2i(cell.y,cell.z) if axis==0 else Vector2i(cell.x,cell.z) if axis==1 else Vector2i(cell.x,cell.y))
				_grid(area, Vector2i(4,4), projection, hole)
				_caption("THE WALL · turn the toy to fit", Vector2(20,27))
			"mg02":
				var left := Rect2(area.position, Vector2(area.size.x*.48, area.size.y))
				var right := Rect2(area.position+Vector2(area.size.x*.52,0),Vector2(area.size.x*.48,area.size.y))
				if int(view.get("show_until",0)) > int(data.get("elapsed_ms",0)):
					_iso(left, _raw_cells(view.get("model",[])), Vector3i(4,4,4))
				else:
					_caption("Remember…",left.position+Vector2(12,left.size.y*.5))
					for n: int in 3: draw_circle(left.get_center()+Vector2((n-1)*28,22),8,Color("b7c6bb"))
				_iso(right,_board_cells(),_board_size())
				_caption("MODEL",Vector2(20,27)); _caption("YOUR COPY",Vector2(size.x*.52+20,27))
			"mg09": _chutes(area,view)
			"mg10":
				var front: Array = view.get("front_silhouette",view.get("front",view.get("front_target",[])))
				var side: Array = view.get("side_silhouette",view.get("side",view.get("side_target",[])))
				var visible := int(view.get("flicker_until_ms",0)) <= int(data.get("elapsed_ms",0))
				var occupied: Array = _board_cells()
				var f: Array=[]; var s: Array=[]
				for row: Dictionary in occupied:
					var cell: Vector3i=row.cell
					f.append(Vector2i(cell.x,cell.y));s.append(Vector2i(cell.z,cell.y))
				_grid(Rect2(area.position,Vector2(area.size.x*.48,area.size.y)),Vector2i(4,4),f,front if visible else [])
				_grid(Rect2(area.position+Vector2(area.size.x*.52,0),Vector2(area.size.x*.48,area.size.y)),Vector2i(4,4),s,side if visible else [])
				_caption("FRONT",Vector2(20,27));_caption("SIDE",Vector2(size.x*.52+20,27))
			"mg15": _tray(area,view)
			"mg16": _rhythm(area,view)
			"mg17": _magnet(area,view)
			"mg18": _volley(area,view)
			"mg19": _gem(area,view)
			"mg20": _paint(area,view)
			"mg21": _balance(area,view)
			_:
				_iso(area,_board_cells(),_board_size())
				_caption(str(view.get("panel_title","YOUR TOY ISLAND")),Vector2(20,27))
				if id=="mg04": _timing(area,view)
				if id=="mg13": _lava(area,view)
				if id=="mg14": _hot(area,view)
		var attacks: Array=data.get("attacks",[])
		if not attacks.is_empty():
			var color: Color=Color(str((attacks[0] as Dictionary).get("sender_colour","d67965")))
			draw_rect(Rect2(Vector2(4,4),size-Vector2(8,8)),color,false,5)
		var piece: Dictionary=data.get("piece",{})
		if id not in ["mg01","mg02","mg09","mg10","mg15","mg16","mg17","mg18","mg19","mg20","mg21"]:
			var cells: Array=_raw_cells(piece.get("cells",[]),Color("ed9d72"))
			if not cells.is_empty(): _iso(area,cells,_board_size(),true)

	func _board_size() -> Vector3i:
		return (data.get("board",{}) as Dictionary).get("size",Vector3i(5,8,5))
	func _raw_cells(cells: Variant, color: Color=Color("9bbfad")) -> Array:
		var result: Array=[]
		for cell: Variant in cells:
			if cell is Vector3i: result.append({"cell":cell,"color":color})
		return result
	func _board_cells() -> Array:
		var result: Array=[]
		for row: Dictionary in (data.get("board",{}) as Dictionary).get("cells",[]):
			if int(row.get("kind",1))==0: continue
			var cell: Vector3i=row.cell
			var color: Color=PALETTE[posmod(int(row.get("hue",0)),4)]
			if str(row.get("status",""))=="hidden": color=Color("c7d6c4",.25)
			result.append({"cell":cell,"color":color})
		return result
	func _grid(area: Rect2, dims: Vector2i, actual: Array, targets: Array) -> void:
		var unit: float=minf(area.size.x/(dims.x+1),area.size.y/(dims.y+1))
		var origin:=area.get_center()-Vector2(dims)*unit*.5
		var target_keys: Dictionary={};var actual_keys: Dictionary={}
		for p: Variant in targets: target_keys[Vector2i(p)]=true
		for p: Variant in actual: actual_keys[Vector2i(p)]=true
		for y: int in dims.y:
			for x: int in dims.x:
				var cell:=Vector2i(x,y)
				var rect:=Rect2(origin+Vector2(x,dims.y-1-y)*unit,Vector2.ONE*(unit-3))
				var color:=Color("dde4d6")
				if target_keys.has(cell): color=Color("b8ddc7")
				if actual_keys.has(cell): color=Color("eaa05b") if target_keys.is_empty() or target_keys.has(cell) else Color("d87967")
				draw_rect(rect,color)
				draw_rect(rect,Color("80968d"),false,1.5)
	func _iso(area: Rect2, rows: Array, dims: Vector3i, active: bool=false) -> void:
		var height: int=2
		for row: Dictionary in rows: height=maxi(height,(row.cell as Vector3i).y+2)
		var board: Dictionary=data.get("board",{})
		for row: Dictionary in board.get("cells",[]): height=maxi(height,(row.cell as Vector3i).y+2)
		for cell: Vector3i in (data.get("piece",{}) as Dictionary).get("cells",[]): height=maxi(height,cell.y+2)
		var u:=minf(area.size.x/(dims.x+dims.z+2),area.size.y/(height+(dims.x+dims.z)*.25+2))
		var center:=Vector2(area.get_center().x,area.end.y-(dims.x+dims.z)*u*.25-8)
		if not active:
			for x: int in dims.x:
				for z: int in dims.z: _cube(center,Vector3i(x,-1,z),u,dims,Color("b4cdb7"),true)
		var sorted:=rows.duplicate()
		sorted.sort_custom(func(a: Dictionary,b: Dictionary)->bool:
			var p:Vector3i=a.cell;var q:Vector3i=b.cell
			return p.y<q.y or (p.y==q.y and p.x+p.z<q.x+q.z))
		for row: Dictionary in sorted: _cube(center,row.cell,u,dims,row.get("color",Color("9bbfad")),false)
	func _cube(origin: Vector2, cell: Vector3i, u: float, dims: Vector3i, color: Color, floor_tile: bool) -> void:
		var p:=origin+Vector2((cell.x-cell.z-(dims.x-dims.z)*.5)*u,(cell.x+cell.z)*u*.25-cell.y*u*.78)
		var a:=p+Vector2(0,-u*.5);var b:=p+Vector2(u,-u*.25);var c:=p;var d:=p+Vector2(-u,-u*.25)
		if not floor_tile:
			draw_colored_polygon(PackedVector2Array([d,c,c+Vector2(0,u*.72),d+Vector2(0,u*.72)]),color.darkened(.2))
			draw_colored_polygon(PackedVector2Array([c,b,b+Vector2(0,u*.72),c+Vector2(0,u*.72)]),color.darkened(.1))
		draw_colored_polygon(PackedVector2Array([a,b,c,d]),color)
		draw_polyline(PackedVector2Array([a,b,c,d,a]),Color("243b4d",.45),1.4,true)
	func _chutes(area: Rect2, view: Dictionary) -> void:
		_caption("MATCH THE TOY TO ITS COLOUR",Vector2(20,27))
		var bins: Variant=view.get("bins",PackedInt32Array([0,1,2]))
		var unit: float=area.size.x/3
		for index: int in 3:
			var color: Color=PALETTE[posmod(int(bins[index]) if bins.size()>index else index,4)]
			var rect:=Rect2(area.position+Vector2(index*unit+10,area.size.y*.62),Vector2(unit-20,area.size.y*.32))
			draw_rect(rect,color);draw_rect(rect,Color("243b4d"),false,3)
			_caption(str(index+1),rect.position+Vector2(rect.size.x*.5-5,28))
		var hue: int=int(view.get("chute_colour",0))
		var p:=area.get_center()-Vector2(0,area.size.y*.2)
		draw_circle(p,32,PALETTE[posmod(hue,4)])
		draw_rect(Rect2(p-Vector2(30,30),Vector2(60,60)),Color("e2bb54") if view.get("golden",false) else Color("243b4d"),false,4)
		_caption(str(view.get("chute_shape","Toy")).replace("_"," ").capitalize(),p+Vector2(-34,65))
	func _tray(area: Rect2, view: Dictionary) -> void:
		_caption("CATCH THE FALLING TOY",Vector2(20,27))
		var actual: Array=[];var targets: Array=[]
		for cell: Vector3i in view.get("sky_cells",[]): actual.append(Vector2i(cell.x,cell.z))
		for cell: Vector3i in view.get("landing_cells",[]): targets.append(Vector2i(cell.x,cell.z))
		_grid(area,Vector2i(7,7),actual,targets)
		var tray: Vector2i=view.get("tray",Vector2i(2,2))
		var unit: float=minf(area.size.x/8,area.size.y/8)
		var origin:=area.get_center()-Vector2(7,7)*unit*.5
		var rect:=Rect2(origin+Vector2(tray.x,7-tray.y-3)*unit,Vector2.ONE*unit*3)
		draw_rect(rect,Color("243b4d"),false,4)
	func _timing(area: Rect2, view: Dictionary) -> void:
		var rect:=Rect2(area.position+Vector2(10,area.size.y-30),Vector2(area.size.x-20,18))
		draw_rect(rect,Color("ccd9ca"))
		var center:=rect.position+Vector2(rect.size.x*.5,9)
		draw_rect(Rect2(center-Vector2(18,9),Vector2(36,18)),Color("b8ddc7"))
		var p: float=float(view.get("offset",view.get("slide_offset",0)))
		draw_line(center+Vector2(clampf(p,-4,4)*rect.size.x*.1,-12),center+Vector2(clampf(p,-4,4)*rect.size.x*.1,12),Color("eaa05b"),5)
	func _rhythm(area: Rect2, view: Dictionary) -> void:
		_caption("TAP THE NOTE ON THE MINT LINE",Vector2(20,27))
		var lanes: int=maxi(1,int(view.get("lane_count",4)))
		var unit: float=area.size.x/lanes
		var hit_y: float=area.end.y-35
		for lane: int in lanes:
			var rect:=Rect2(area.position+Vector2(lane*unit+8,0),Vector2(unit-16,area.size.y))
			draw_rect(rect,PALETTE[lane%4].lightened(.35))
			_caption(str(lane+1),Vector2(rect.position.x+unit*.4,hit_y+25))
		draw_rect(Rect2(Vector2(area.position.x,hit_y-14),Vector2(area.size.x,28)),Color("b8ddc7",.8))
		var now: int=int(data.get("elapsed_ms",0))
		for note: Dictionary in view.get("notes",[]):
			if note.get("hit",false) or note.get("missed",false): continue
			var y: float=hit_y-float(int(note.get("at",now))-now)/2000.0*(area.size.y-35)
			if y<area.position.y or y>area.end.y: continue
			var x: float=area.position.x+(int(note.get("lane",0))+.5)*unit
			draw_circle(Vector2(x,y),16,Color("eaa05b"))
			draw_circle(Vector2(x,y),7,Color("fff8e7"))
	func _map_point(area: Rect2, cell: Vector2i, dims: Vector2i=Vector2i(7,7)) -> Vector2:
		var unit: float=minf(area.size.x/dims.x,area.size.y/dims.y)
		return area.get_center()-Vector2(dims)*unit*.5+(Vector2(cell)+Vector2(.5,.5))*unit
	func _magnet(area: Rect2, view: Dictionary) -> void:
		_caption("GUIDE THE MAGNET TO THE DOCK",Vector2(20,27))
		var dims:=Vector2i(4,4)
		var unit: float=minf(area.size.x/4,area.size.y/4)
		for edge: Array in view.get("edges",[]):
			draw_line(_map_point(area,edge[0],dims),_map_point(area,edge[1],dims),Color("9db7ae"),unit*.22,true)
		var dock: Vector2i=view.get("dock",Vector2i(3,3))
		draw_circle(_map_point(area,dock,dims),unit*.28,Color("b8ddc7"))
		draw_arc(_map_point(area,dock,dims),unit*.28,0,TAU,24,Color("243b4d"),3,true)
		var block: Vector2i=view.get("block",Vector2i.ZERO)
		draw_rect(Rect2(_map_point(area,block,dims)-Vector2.ONE*unit*.18,Vector2.ONE*unit*.36),Color("eaa05b"))
		var cursor: Vector2i=view.get("cursor",Vector2i.ZERO)
		var point:=_map_point(area,cursor,dims)
		draw_arc(point,unit*.33,.3,PI*1.85,24,Color("d87b68") if int(view.get("polarity",1))<0 else Color("788ec1"),8,true)
	func _volley(area: Rect2, view: Dictionary) -> void:
		_caption("RETURN THE BALLOON IN THE MINT WINDOW",Vector2(20,27))
		var now: int=int(data.get("elapsed_ms",0))
		var start: int=int(view.get("flight_start",0))
		var end: int=int(view.get("return_end",2400))
		var progress: float=clampf(float(now-start)/maxi(1,end-start),0,1)
		var a:=Vector2(area.position.x+35,area.get_center().y)
		var b:=Vector2(area.end.x-35,area.get_center().y)
		draw_line(a,b,Color("b2c8bf"),4,true)
		var from: float=float(int(view.get("return_start",2000))-start)/maxi(1,end-start)
		draw_rect(Rect2(Vector2(lerpf(a.x,b.x,clampf(from,0,1)),a.y-35),Vector2(b.x-lerpf(a.x,b.x,clampf(from,0,1)),70)),Color("b8ddc7"))
		if not view.get("waiting",false):
			var point:=a.lerp(b,progress)
			draw_circle(point,26,Color("eaa05b"));draw_line(point+Vector2(0,26),point+Vector2(4,58),Color("243b4d"),2)
	func _gem(area: Rect2, view: Dictionary) -> void:
		_caption("COLLECT GEMS · BRING THEM HOME",Vector2(20,27))
		_grid(area,Vector2i(7,7),[],[])
		var unit: float=minf(area.size.x/8,area.size.y/8)
		var corrected:=Rect2(area.get_center()-Vector2(7,7)*unit*.5,Vector2.ONE*unit*7)
		for cell: Vector2i in view.get("gem_cells",[]):
			var p:=_map_point(corrected,cell)
			draw_colored_polygon(PackedVector2Array([p+Vector2(0,-12),p+Vector2(10,0),p+Vector2(0,12),p+Vector2(-10,0)]),Color("8a99c4"))
		var gold: Dictionary=view.get("gold_gem",{})
		if gold.get("available",false): draw_circle(_map_point(corrected,gold.get("cell",Vector2i.ZERO)),12,Color("e6c875"))
		var home:=_map_point(corrected,view.get("base",Vector2i.ZERO))
		draw_rect(Rect2(home-Vector2.ONE*14,Vector2.ONE*28),Color("b8ddc7"));_caption("⌂",home+Vector2(-7,6))
		draw_circle(_map_point(corrected,view.get("cursor",Vector2i.ZERO)),10,Color("eaa05b"))
	func _paint(area: Rect2, view: Dictionary) -> void:
		_caption("PAINT ONLY THE STENCIL TILES",Vector2(20,27))
		var target: Array=[];var painted: Array=[]
		for face: Dictionary in view.get("stencil_faces",[]): target.append(Vector2i(face.cell.x,face.cell.z))
		for face: Dictionary in view.get("painted_faces",[]): painted.append(Vector2i(face.cell.x,face.cell.z))
		_grid(area,Vector2i(7,7),painted,target)
		var unit: float=minf(area.size.x/8,area.size.y/8)
		var cursor: Vector2i=view.get("cursor",Vector2i.ZERO)
		var origin:=area.get_center()-Vector2(7,7)*unit*.5
		var point:=origin+(Vector2(cursor.x,6-cursor.y)+Vector2(.5,.5))*unit
		draw_arc(point,unit*.4,0,TAU,24,Color("243b4d"),4,true)
	func _balance(area: Rect2, view: Dictionary) -> void:
		_caption("MATCH THE WEIGHT ON BOTH PANS",Vector2(20,27))
		var left: int=int(view.get("left_mass",0));var right: int=int(view.get("right_mass",0))
		var delta: float=clampf(float(right-left)*6,-45,45)
		var center:=area.get_center()
		var a:=center+Vector2(-area.size.x*.28,-delta);var b:=center+Vector2(area.size.x*.28,delta)
		draw_line(a,b,Color("243b4d"),8,true)
		draw_colored_polygon(PackedVector2Array([center+Vector2(0,-15),center+Vector2(-24,65),center+Vector2(24,65)]),Color("a4b6ce"))
		for entry: Dictionary in [{"point":a,"mass":left,"pieces":view.get("left_pan",[])},{"point":b,"mass":right,"pieces":view.get("right_pan",[])}]:
			var point: Vector2=entry.point
			draw_line(point,point+Vector2(0,55),Color("243b4d"),2)
			draw_rect(Rect2(point+Vector2(-65,55),Vector2(130,15)),Color("b8ddc7"))
			_caption("%dg"%int(entry.mass),point+Vector2(-12,100))
			for i: int in mini(8,(entry.pieces as Array).size()): draw_rect(Rect2(point+Vector2(-50+(i%4)*25,30-(i/4)*25),Vector2(23,23)),PALETTE[i%4])

	func _lava(area: Rect2, view: Dictionary) -> void:
		var level: int=int(view.get("lava_layer",0))
		draw_rect(Rect2(area.position+Vector2(0,area.size.y-14),Vector2(area.size.x,14)),Color("db8064"))
		_caption("Lava %d"%level,area.position+Vector2(8,area.size.y-20),Color("aa412c"))
	func _hot(area: Rect2, view: Dictionary) -> void:
		var fuse: int=maxi(0,int(view.get("hot_fuse_at_ms",0))-int(data.get("elapsed_ms",0)))
		if fuse>0: _caption("● %ds"%ceili(fuse/1000.0),area.position+Vector2(8,32),Color("aa412c"))
