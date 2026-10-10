class_name ProfileEdit extends UiScreen
## Create / rename panel (profile-select.md). Bottom sheet in portrait, right panel (55%) with a live preview on the
## left in landscape. Intents: SET_PREF {key: "name"|"color"|"badge", value}, RANDOM_NAME, CREATE_PROFILE or
## RENAME_PROFILE {slot, name, color, badge} (the tick), BACK. The glue validates and re-binds with error_key.

## Not in UiIntents yet: add there when integrating.
const RANDOM_NAME: StringName = &"random_name"
const DIM := Color(0, 0, 0, 0.35)
const CHIP := 56.0
const TICK_H := 64.0
const SELECT_BORDER := Color("3B2F20")
const ERROR_COLOR := Color("C0392B")
## Shake: peak rotation (rad) and one-way time (s). Motion timings are placeholders until ux-designer specs them.
const SHAKE_ANGLE := 0.03
const SHAKE_STEP := 0.05
const SHAKE_REPEAT := 3

## Set by the game from user prefs: no shake, outline only.
var reduced_motion: bool = false

var _snap: ProfileEditSnapshot
var _sheet: PanelContainer
var _preview: PanelContainer
var _preview_tile: PanelContainer
var _preview_badge: UiGlyph
var _title: Label
var _name: LineEdit
var _error: Label
var _tick: Button
var _color_btns: Dictionary = {}
var _badge_btns: Dictionary = {}
var _last_nonce: int = 0
var _layout: OrientationLayout


func _ready() -> void:
	var dim := ColorRect.new()
	dim.color = DIM
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var safe := Control.new()
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(safe)
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_preview = PanelContainer.new() # live card preview, landscape only
	_preview.visible = false
	safe.add_child(_preview)
	_preview_tile = PanelContainer.new()
	_preview_tile.custom_minimum_size = Vector2(96, 96)
	_preview_tile.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_preview_tile.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_preview_badge = UiGlyph.new()
	_preview_tile.add_child(_preview_badge)
	_preview.add_child(_preview_tile)

	_sheet = PanelContainer.new()
	_sheet.theme_type_variation = &"PanelSheet"
	safe.add_child(_sheet)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	_sheet.add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	margin.add_child(col)

	_title = Label.new()
	_title.theme_type_variation = &"HeaderLabel"
	col.add_child(_title)
	var name_row := HBoxContainer.new()
	col.add_child(name_row)
	_name = LineEdit.new()
	_name.max_length = ProfileStore.NAME_MAX
	_name.placeholder_text = tr("UI_PROFILE_NAME_LABEL")
	_name.custom_minimum_size.y = CHIP
	_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name.text_changed.connect(func(t: String) -> void: intent.emit(UiIntents.SET_PREF, {"key": "name", "value": t}))
	_name.text_submitted.connect(func(_t: String) -> void: _on_tick())
	name_row.add_child(_name)
	var dice := UiGlyph.button(&"dice", "UI_PROFILE_DICE", CHIP)
	dice.pressed.connect(func() -> void: intent.emit(RANDOM_NAME, {}))
	name_row.add_child(dice)
	_error = Label.new()
	_error.add_theme_color_override("font_color", ERROR_COLOR)
	_error.visible = false
	col.add_child(_error)

	col.add_child(_section(tr("UI_PROFILE_COLOR")))
	var colors := HBoxContainer.new()
	colors.add_theme_constant_override("separation", 8)
	col.add_child(colors)
	for id in ProfileStore.COLORS:
		var b := _chip_button("UI_COLOR_" + id.to_upper())
		b.set_meta("fill", UiGlyph.color_of(StringName(id)))
		b.pressed.connect(func() -> void: intent.emit(UiIntents.SET_PREF, {"key": "color", "value": id}))
		colors.add_child(b)
		_color_btns[id] = b
	col.add_child(_section(tr("UI_PROFILE_BADGE")))
	var badges := GridContainer.new()
	badges.columns = 4
	badges.add_theme_constant_override("h_separation", 8)
	badges.add_theme_constant_override("v_separation", 8)
	col.add_child(badges)
	for id in ProfileStore.BADGES:
		var b := _chip_button("UI_BADGE_" + id.to_upper())
		b.set_meta("fill", Color("FFF8E6"))
		b.add_child(UiGlyph.new(StringName(id)))
		(b.get_child(0) as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 8)
		b.pressed.connect(func() -> void: intent.emit(UiIntents.SET_PREF, {"key": "badge", "value": id}))
		badges.add_child(b)
		_badge_btns[id] = b

	_tick = UiGlyph.button(&"tick", "UI_PROFILE_SAVE", TICK_H)
	_tick.custom_minimum_size = Vector2(0, TICK_H)
	_tick.size_flags_horizontal = Control.SIZE_FILL
	_tick.pressed.connect(_on_tick)
	col.add_child(_tick)

	_layout = OrientationLayout.new()
	_layout.safe_target = safe
	_layout.changed.connect(_on_orientation)
	add_child(_layout)


## Renders a [ProfileEditSnapshot]. Idempotent; never overwrites the field while it already shows the same text.
func bind(snapshot: RefCounted) -> void:
	var s := snapshot as ProfileEditSnapshot
	if s == null:
		return
	_snap = s
	_title.text = tr("UI_PROFILE_RENAME_TITLE") if s.is_rename else tr("UI_PROFILE_CREATE_TITLE")
	if _name.text != s.name:
		_name.text = s.name
		_name.caret_column = s.name.length()
	for id in _color_btns:
		_style_chip(_color_btns[id], StringName(id) == s.color)
	for id in _badge_btns:
		_style_chip(_badge_btns[id], StringName(id) == s.badge)
	var tile := StyleBoxFlat.new()
	tile.bg_color = UiGlyph.color_of(s.color)
	tile.set_corner_radius_all(16)
	_preview_tile.add_theme_stylebox_override("panel", tile)
	_preview_badge.glyph = s.badge
	_error.visible = s.error_key != ""
	if _error.visible:
		_error.text = "✖ " + tr(s.error_key)
	_mark_error(s.error_key != "")
	if s.error_key != "" and s.error_nonce != _last_nonce:
		_shake()
	_last_nonce = s.error_nonce


func default_focus() -> Control:
	return _tick


func _on_tick() -> void:
	if _snap == null:
		return
	var args := {"name": _name.text, "color": _snap.color, "badge": _snap.badge}
	if _snap.is_rename:
		args["slot"] = _snap.slot
	intent.emit(UiIntents.RENAME_PROFILE if _snap.is_rename else UiIntents.CREATE_PROFILE, args)


func _section(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = &"SmallLabel"
	return l


func _chip_button(tip_key: String) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(CHIP, CHIP)
	b.tooltip_text = tr(tip_key)
	return b


func _style_chip(b: Button, selected: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = b.get_meta("fill")
	sb.set_corner_radius_all(12)
	if selected:
		sb.set_border_width_all(5)
		sb.border_color = SELECT_BORDER
	for st in ["normal", "hover", "pressed"]:
		b.add_theme_stylebox_override(st, sb)


## Red outline on the field while an error shows (the only cue with reduced motion).
func _mark_error(on: bool) -> void:
	if not on:
		_name.remove_theme_stylebox_override("normal")
		return
	var base: StyleBox = _name.get_theme_stylebox("normal")
	var sb: StyleBoxFlat = (base as StyleBoxFlat).duplicate() if base is StyleBoxFlat else StyleBoxFlat.new()
	sb.set_border_width_all(3)
	sb.border_color = ERROR_COLOR
	_name.add_theme_stylebox_override("normal", sb)


func _shake() -> void:
	_name.grab_focus()
	if reduced_motion:
		return
	_name.pivot_offset = _name.size / 2.0
	var tw := create_tween()
	for i in SHAKE_REPEAT:
		tw.tween_property(_name, "rotation", SHAKE_ANGLE, SHAKE_STEP)
		tw.tween_property(_name, "rotation", -SHAKE_ANGLE, SHAKE_STEP)
	tw.tween_property(_name, "rotation", 0.0, SHAKE_STEP)


func _on_orientation(is_landscape: bool) -> void:
	_preview.visible = is_landscape
	if is_landscape:
		_sheet.anchor_left = 0.45
		_sheet.anchor_right = 1.0
		_sheet.anchor_top = 0.0
		_sheet.anchor_bottom = 1.0
		_sheet.grow_vertical = Control.GROW_DIRECTION_BOTH
		_preview.anchor_left = 0.0
		_preview.anchor_right = 0.45
		_preview.anchor_top = 0.2
		_preview.anchor_bottom = 0.8
	else:
		_sheet.anchor_left = 0.0
		_sheet.anchor_right = 1.0
		_sheet.anchor_top = 1.0
		_sheet.anchor_bottom = 1.0
		_sheet.grow_vertical = Control.GROW_DIRECTION_BEGIN
	for c in [_sheet, _preview]:
		c.offset_left = 0
		c.offset_right = 0
		c.offset_top = 0
		c.offset_bottom = 0
