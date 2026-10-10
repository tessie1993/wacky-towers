class_name DeleteProfileDialog extends UiScreen
## Delete confirm (profile-select.md "Delete safety"). Names what is lost. Keep (cross) is the default focus;
## the bin button is inactive for `delete_arm_ms` after the dialog opens, with a filling ring.
## Intents: BACK (keep), DELETE_PROFILE {slot}.

const UI_CONFIG_PATH := "res://assets/data/ui/ui.json"
const DIM := Color(0, 0, 0, 0.45)
const BUTTON_SIDE := 88.0
## Used only if ui.json is missing (matches the shipped value).
const FALLBACK_ARM_MS := 600

## Set by the game from user prefs: the ring just appears at arm time instead of filling.
var reduced_motion: bool = false

var _slot: int = -1
var _keep: Button
var _bin: Button
var _ring: UiGlyph
var _fill: Control
var _title: Label
var _loss: Label
var _tile: PanelContainer
var _tile_badge: UiGlyph
var _box: BoxContainer
var _arm_ms: int = FALLBACK_ARM_MS
var _opened_ms: int = 0
var _arming: bool = false
var _layout: OrientationLayout


func _ready() -> void:
	_arm_ms = _load_arm_ms()
	var dim := ColorRect.new()
	dim.color = DIM
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"DialogPanel"
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	col.custom_minimum_size.x = 300
	margin.add_child(col)
	_tile = PanelContainer.new()
	_tile.custom_minimum_size = Vector2(64, 64)
	_tile.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_tile_badge = UiGlyph.new()
	_tile.add_child(_tile_badge)
	col.add_child(_tile)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_title)
	_loss = Label.new()
	_loss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_loss.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_loss)
	# Portrait: keep above bin. Landscape: keep left, bin right.
	_box = BoxContainer.new()
	_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_box.add_theme_constant_override("separation", 24)
	col.add_child(_box)
	_keep = UiGlyph.button(&"cross", "UI_PROFILE_KEEP", BUTTON_SIDE)
	_keep.pressed.connect(func() -> void: intent.emit(UiIntents.BACK, {}))
	_box.add_child(_keep)
	_bin = UiGlyph.button(&"bin", "UI_PROFILE_DELETE", BUTTON_SIDE)
	_bin.pressed.connect(func() -> void: intent.emit(UiIntents.DELETE_PROFILE, {"slot": _slot}))
	_box.add_child(_bin)
	_ring = UiGlyph.new(&"ring", Color("C0392B"))
	_ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bin.add_child(_ring)
	_ring.draw.connect(_draw_progress)
	_layout = OrientationLayout.new()
	_layout.changed.connect(func(land: bool) -> void: _box.vertical = not land)
	add_child(_layout)
	set_process(false)


## Renders a [DeleteProfileSnapshot] and (re)starts the arming delay.
func bind(snapshot: RefCounted) -> void:
	var s := snapshot as DeleteProfileSnapshot
	if s == null:
		return
	if s.slot != _slot or not _arming:
		_start_arming()
	_slot = s.slot
	_title.text = tr("UI_PROFILE_DELETE_TITLE") % s.profile_name
	_loss.text = tr("UI_PROFILE_DELETE_LOSS") % [s.profile_name, s.stars, s.levels]
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiGlyph.color_of(s.color)
	sb.set_corner_radius_all(12)
	_tile.add_theme_stylebox_override("panel", sb)
	_tile_badge.glyph = s.badge


func enter(is_resume: bool) -> void:
	_start_arming()
	super.enter(is_resume)


func default_focus() -> Control:
	return _keep


func _process(_delta: float) -> void:
	var done: bool = Time.get_ticks_msec() - _opened_ms >= _arm_ms
	if done:
		_arming = false
		_bin.disabled = false
		set_process(false)
	_ring.queue_redraw()


func _start_arming() -> void:
	_opened_ms = Time.get_ticks_msec()
	_arming = true
	_bin.disabled = true
	set_process(true)


## Ring fills while arming (static, shown only at the end, with reduced motion).
func _draw_progress() -> void:
	var t: float = clampf(float(Time.get_ticks_msec() - _opened_ms) / maxf(_arm_ms, 1), 0.0, 1.0)
	if reduced_motion:
		t = 0.0 if _arming else 1.0
	if t <= 0.0:
		return
	var s: float = minf(_ring.size.x, _ring.size.y)
	_ring.draw_arc(_ring.size / 2.0, s * 0.46, -PI / 2.0, -PI / 2.0 + TAU * t, 32, Color("C0392B"), 4.0)


func _load_arm_ms() -> int:
	var f := FileAccess.open(UI_CONFIG_PATH, FileAccess.READ)
	if f == null:
		return FALLBACK_ARM_MS
	var d: Variant = JSON.parse_string(f.get_as_text())
	return int((d as Dictionary).get("delete_arm_ms", FALLBACK_ARM_MS)) if d is Dictionary else FALLBACK_ARM_MS
