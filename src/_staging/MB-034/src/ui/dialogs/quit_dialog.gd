class_name QuitDialog extends UiScreen
## Quit confirm: tick = quit, cross = stay (default focus). Intents: BACK (stay), QUIT (confirm).

const DIM := Color(0, 0, 0, 0.45)
const BUTTON_SIDE := 88.0

var _keep: Button


func _ready() -> void:
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
	margin.add_child(col)
	var msg := Label.new()
	msg.text = tr("UI_QUIT_PROMPT")
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(msg)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 32)
	col.add_child(row)
	_keep = UiGlyph.button(&"cross", "UI_QUIT_KEEP", BUTTON_SIDE)
	_keep.pressed.connect(func() -> void: intent.emit(UiIntents.BACK, {}))
	row.add_child(_keep)
	var quit := UiGlyph.button(&"tick", "UI_QUIT", BUTTON_SIDE)
	quit.pressed.connect(func() -> void: intent.emit(UiIntents.QUIT, {}))
	row.add_child(quit)


func default_focus() -> Control:
	return _keep
