class_name ProfileSelect extends UiScreen
## Profile list: 4 slot cards (2x2 portrait, 1x4 landscape), Edit toggle, back. profile-select.md.
## Intents: SELECT_PROFILE {slot}, CREATE_PROFILE {}, RENAME_PROFILE {slot} (opens the panel), DELETE_PROFILE {slot}
## (opens the confirm), BACK, and SET_PREF {key: "profile_edit_mode", value: bool} for the Edit toggle.

const BACKDROP := Color("F4EAD0")
const CARD_MIN_P := Vector2(150, 150)
const CARD_MIN_L := Vector2(150, 180)
const CHIP_SIDE := 56.0
const BADGE_TILE := 64.0
const RING_COLOR := Color("F2B33D")
const EDIT_MODE_KEY := "profile_edit_mode"

var _grid: GridContainer
var _edit: Button
var _back: Button
var _cells: Array[Control] = []
var _snap: ProfileSelectSnapshot
var _landscape: bool = false
var _layout: OrientationLayout


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = BACKDROP
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var safe := Control.new()
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(safe)
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var frame := VBoxContainer.new()
	safe.add_child(frame)
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var top := HBoxContainer.new()
	frame.add_child(top)
	_back = UiGlyph.button(&"back", "UI_BACK", CHIP_SIDE)
	_back.pressed.connect(func() -> void: intent.emit(UiIntents.BACK, {}))
	top.add_child(_back)
	var title := Label.new()
	title.text = tr("UI_PROFILE_WHO")
	title.theme_type_variation = &"HeaderLabel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	_edit = Button.new()
	_edit.custom_minimum_size = Vector2(CHIP_SIDE * 1.5, CHIP_SIDE)
	_edit.pressed.connect(func() -> void:
		intent.emit(UiIntents.SET_PREF, {"key": EDIT_MODE_KEY, "value": not (_snap != null and _snap.edit_mode)}))
	top.add_child(_edit)

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(center)
	_grid = GridContainer.new()
	_grid.add_theme_constant_override("h_separation", 16)
	_grid.add_theme_constant_override("v_separation", 16)
	center.add_child(_grid)

	_layout = OrientationLayout.new()
	_layout.safe_target = safe
	_layout.changed.connect(_on_orientation)
	add_child(_layout)


## Renders a [ProfileSelectSnapshot]. Rebuilds the cards (4 at most); idempotent.
func bind(snapshot: RefCounted) -> void:
	var s := snapshot as ProfileSelectSnapshot
	if s == null:
		return
	var had_focus: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	var focus_idx: int = _cells.find(had_focus.get_parent() if had_focus != null else null)
	_snap = s
	_edit.text = tr("UI_DONE") if s.edit_mode else tr("UI_EDIT")
	for c in _cells:
		_grid.remove_child(c)
		c.queue_free()
	_cells.clear()
	var first_empty: int = s.slots.find(null)
	for i in ProfileStore.MAX_SLOTS:
		var cell := _make_cell(i, s, first_empty)
		_grid.add_child(cell)
		_cells.append(cell)
	_on_orientation(_landscape)
	if focus_idx >= 0 and had_focus != null:
		_focus_cell(focus_idx)


func default_focus() -> Control:
	if _snap != null and _snap.active_slot >= 0 and _snap.active_slot < _cells.size():
		return _card_button(_cells[_snap.active_slot])
	return _card_button(_cells[0]) if not _cells.is_empty() and _card_button(_cells[0]) != null else _back


func _focus_cell(idx: int) -> void:
	var b: Control = _card_button(_cells[idx]) if idx < _cells.size() else null
	if b != null:
		b.grab_focus.call_deferred()


## First child of a cell is the card button (null for inert empty cards).
func _card_button(cell: Control) -> Control:
	var c: Node = cell.get_child(0)
	return c as Control if c is BaseButton else null


func _make_cell(i: int, s: ProfileSelectSnapshot, first_empty: int) -> Control:
	var cell := VBoxContainer.new()
	cell.name = "Slot%d" % i
	cell.add_theme_constant_override("separation", 6)
	var d: Variant = s.slots[i]
	if d == null:
		cell.add_child(_make_empty(i, i == first_empty and not s.read_only))
		return cell
	var info: Dictionary = d
	var card := Button.new()
	card.name = "Card"
	card.set_meta("slot", i)
	card.pressed.connect(func() -> void: intent.emit(UiIntents.SELECT_PROFILE, {"slot": i}))
	cell.add_child(card)
	var active: bool = i == s.active_slot
	if active:
		var ring := StyleBoxFlat.new()
		ring.bg_color = Color("FFF8E6")
		ring.set_border_width_all(6)
		ring.border_color = RING_COLOR
		ring.set_corner_radius_all(16)
		for st in ["normal", "hover", "pressed"]:
			card.add_theme_stylebox_override(st, ring)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(col)
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 8)
	var tile := PanelContainer.new()
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.custom_minimum_size = Vector2(BADGE_TILE, BADGE_TILE)
	tile.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiGlyph.color_of(StringName(info.get("color", "")))
	sb.set_corner_radius_all(12)
	tile.add_theme_stylebox_override("panel", sb)
	tile.add_child(UiGlyph.new(StringName(info.get("badge", ""))))
	col.add_child(tile)
	col.add_child(_label(str(info.get("name", "")), HORIZONTAL_ALIGNMENT_CENTER))
	col.add_child(_label("★ " + tr("UI_PROFILE_STARS") % int(info.get("stars", 0)), HORIZONTAL_ALIGNMENT_CENTER))
	col.add_child(_label(tr("UI_PROFILE_FURTHEST") % int(info.get("furthest", 0)), HORIZONTAL_ALIGNMENT_CENTER))
	if active:
		var tick := UiGlyph.new(&"tick", RING_COLOR)
		tick.custom_minimum_size = Vector2(28, 28)
		tick.tooltip_text = tr("UI_PROFILE_ACTIVE")
		col.add_child(tick)
	if s.edit_mode:
		var chips := HBoxContainer.new()
		chips.alignment = BoxContainer.ALIGNMENT_CENTER
		cell.add_child(chips)
		var rename := UiGlyph.button(&"pencil", "UI_PROFILE_RENAME", CHIP_SIDE)
		rename.disabled = s.read_only
		rename.pressed.connect(func() -> void: intent.emit(UiIntents.RENAME_PROFILE, {"slot": i}))
		chips.add_child(rename)
		var bin := UiGlyph.button(&"bin", "UI_PROFILE_DELETE", CHIP_SIDE)
		bin.disabled = s.read_only
		bin.pressed.connect(func() -> void: intent.emit(UiIntents.DELETE_PROFILE, {"slot": i}))
		chips.add_child(bin)
	return cell


## "+" button for the lowest empty slot, a faint inert outline for the rest.
func _make_empty(i: int, is_lowest: bool) -> Control:
	if is_lowest:
		var b := UiGlyph.button(&"plus", "UI_PROFILE_NEW", CARD_MIN_P.x)
		b.name = "Card"
		b.pressed.connect(func() -> void: intent.emit(UiIntents.CREATE_PROFILE, {}))
		return b
	var p := Panel.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.15)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.35, 0.28, 0.2, 0.35)
	sb.set_corner_radius_all(16)
	p.add_theme_stylebox_override("panel", sb)
	return p


func _label(text: String, align: HorizontalAlignment) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _on_orientation(is_landscape: bool) -> void:
	_landscape = is_landscape
	_grid.columns = 4 if is_landscape else 2
	var m: Vector2 = CARD_MIN_L if is_landscape else CARD_MIN_P
	for c in _cells:
		var first: Control = c.get_child(0)
		first.custom_minimum_size = m
		first.size_flags_vertical = Control.SIZE_EXPAND_FILL
