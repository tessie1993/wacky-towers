extends Control
## Meadow island map. Node layout from MAP_PATH; locked/stars pushed in via show_progress().

const Kit := preload("res://src/ui/theme/ui_kit.gd")
const StarRowScript := preload("res://src/ui/widgets/star_row.gd")
const MAP_PATH := "res://assets/data/campaign/meadow_map.json"
const NODE_SIZE := 96.0

signal level_chosen(level_id: StringName)
signal back_pressed

var back_button: Button
## level_id (StringName) -> Button
var node_buttons: Dictionary = {}
var _star_rows: Dictionary = {}
var _order: Array[StringName] = []
var _map_area: Control
var _path: Line2D
var _points: Array[Vector2] = []


func _ready() -> void:
	Kit.backdrop(self, Color("BFE8FF"))
	var map := _load_map()
	var root := VBoxContainer.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var head := HBoxContainer.new()
	head.custom_minimum_size.y = 104
	root.add_child(head)
	back_button = Kit.button("UI_BACK", "Back", Vector2(160, 88))
	back_button.pressed.connect(func() -> void: back_pressed.emit())
	head.add_child(back_button)
	var title := PanelContainer.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_child(Kit.label("UI_BIOME_MEADOW", str(map.get("biome", "Meadow")), &"HeaderLabel"))
	head.add_child(title)
	_map_area = Control.new()
	_map_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_map_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_map_area)
	_path = Line2D.new()
	_path.width = 12.0
	_path.default_color = Color("E7C58A")
	_path.joint_mode = Line2D.LINE_JOINT_ROUND
	_map_area.add_child(_path)
	for n: Dictionary in map.get("nodes", []):
		_add_node(n)
	_map_area.resized.connect(_update_path)
	_update_path()
	show_progress({})


## Push progress: { level_id: { "unlocked": bool, "stars": int 0-3 } }.
## Missing entry = locked, except the first node which is always open.
func show_progress(progress: Dictionary) -> void:
	for i in _order.size():
		var id := _order[i]
		var p: Dictionary = progress.get(id, progress.get(str(id), {}))
		var open: bool = i == 0 or bool(p.get("unlocked", false))
		var stars := clampi(int(p.get("stars", 0)), 0, 3) if open else 0
		var b: Button = node_buttons[id]
		b.disabled = not open
		b.text = _label_of(id) if open else "?"
		(_star_rows[id] as Control).call("set_stars", stars)


## Whether the node button for `level_id` is locked.
func is_locked(level_id: StringName) -> bool:
	return node_buttons.has(level_id) and (node_buttons[level_id] as Button).disabled


func _label_of(id: StringName) -> String:
	return "+" if id.ends_with("bonus") else str(_order.find(id) + 1)


func _add_node(n: Dictionary) -> void:
	var id := StringName(str(n.get("id", "")))
	var pos: Array = n.get("pos", [0.5, 0.5])
	var slot := VBoxContainer.new()
	slot.alignment = BoxContainer.ALIGNMENT_BEGIN
	slot.anchor_left = float(pos[0])
	slot.anchor_right = float(pos[0])
	slot.anchor_top = float(pos[1])
	slot.anchor_bottom = float(pos[1])
	slot.offset_left = -60.0
	slot.offset_right = 60.0
	slot.offset_top = -NODE_SIZE * 0.5
	slot.offset_bottom = NODE_SIZE * 0.5 + 44.0
	_map_area.add_child(slot)
	var b := Kit.button("", str(n.get("name", id)), Vector2(NODE_SIZE, NODE_SIZE), bool(n.get("bonus", false)))
	b.tooltip_text = Kit.t("UI_LEVEL_" + str(id).to_upper(), str(n.get("name", id)))
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	slot.add_child(b)
	var sr: Control = StarRowScript.new()
	sr.set("star_size", 28.0)
	slot.add_child(sr)
	b.pressed.connect(func() -> void:
		if not b.disabled:
			level_chosen.emit(id))
	node_buttons[id] = b
	_star_rows[id] = sr
	_order.append(id)
	_points.append(Vector2(float(pos[0]), float(pos[1])))


func _update_path() -> void:
	var pts := PackedVector2Array()
	for p in _points:
		pts.append(p * _map_area.size)
	_path.points = pts


func _load_map() -> Dictionary:
	var f := FileAccess.open(MAP_PATH, FileAccess.READ)
	if f == null:
		push_warning("campaign_map: missing %s" % MAP_PATH)
		return {}
	var d: Variant = JSON.parse_string(f.get_as_text())
	return d if d is Dictionary else {}
