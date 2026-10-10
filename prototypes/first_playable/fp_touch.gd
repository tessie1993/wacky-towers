class_name FpTouch extends CanvasLayer
## On-screen touch buttons that press/release the wt_* input actions.

const BTN: float = 96.0
const GAP: float = 12.0
const MARGIN: float = 24.0

var _pressed: Array[StringName] = []


func _ready() -> void:
	layer = 10
	var root: Control = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Move pad, bottom-left: up on top, left/down/right on the bottom row.
	var col: float = MARGIN + BTN + GAP
	_add_btn(root, "▲", &"wt_move_up", false, col, MARGIN + BTN + GAP)
	_add_btn(root, "◀", &"wt_move_left", false, MARGIN, MARGIN)
	_add_btn(root, "▼", &"wt_move_down", false, col, MARGIN)
	_add_btn(root, "▶", &"wt_move_right", false, col + BTN + GAP, MARGIN)

	# Right cluster, bottom-right (x measured from right edge, y from bottom).
	# Rotation pairs above DROP/SOFT: Turn = horizontal (turntable), Flip = vertical (tips on screen).
	var row2: float = MARGIN + BTN + GAP
	var row3: float = MARGIN + 2.0 * (BTN + GAP)
	_add_btn(root, "Turn\n◀", &"wt_rot_h_left", true, MARGIN + BTN + GAP, row3)
	_add_btn(root, "Turn\n▶", &"wt_rot_h_right", true, MARGIN, row3)
	_add_btn(root, "Flip\n◀", &"wt_rot_v_left", true, MARGIN + BTN + GAP, row2)
	_add_btn(root, "Flip\n▶", &"wt_rot_v_right", true, MARGIN, row2)
	_add_btn(root, "DROP", &"wt_hard_drop", true, MARGIN + BTN + GAP, MARGIN)
	_add_btn(root, "SOFT", &"wt_soft_drop", true, MARGIN, MARGIN)

	# View L/R, top-right.
	var top: Control = root
	_add_top_btn(top, "◁ VIEW", &"wt_view_left", MARGIN + BTN + GAP)
	_add_top_btn(top, "VIEW ▷", &"wt_view_right", MARGIN)


func _exit_tree() -> void:
	for a: StringName in _pressed.duplicate():
		_release(a)


# Bottom-anchored button. right_side=false: x = offset of left edge from left; true: offset of right edge from right.
# y = bottom edge offset from the bottom of the screen.
func _add_btn(parent: Control, text: String, action: StringName, right_side: bool, x: float, y: float) -> void:
	var b: Button = _make_btn(text, action)
	if right_side:
		b.anchor_left = 1.0
		b.anchor_right = 1.0
		b.offset_right = -x
		b.offset_left = -x - BTN
	else:
		b.anchor_left = 0.0
		b.anchor_right = 0.0
		b.offset_left = x
		b.offset_right = x + BTN
	b.anchor_top = 1.0
	b.anchor_bottom = 1.0
	b.offset_bottom = -y
	b.offset_top = -y - BTN
	parent.add_child(b)


func _add_top_btn(parent: Control, text: String, action: StringName, x_from_right: float) -> void:
	var b: Button = _make_btn(text, action)
	b.anchor_left = 1.0
	b.anchor_right = 1.0
	b.offset_right = -x_from_right
	b.offset_left = -x_from_right - BTN
	b.anchor_top = 0.0
	b.anchor_bottom = 0.0
	b.offset_top = MARGIN
	b.offset_bottom = MARGIN + BTN * 0.6
	parent.add_child(b)


func _make_btn(text: String, action: StringName) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.modulate = Color(1, 1, 1, 0.5)
	b.add_theme_font_size_override(&"font_size", 22)
	b.button_down.connect(_press.bind(action))
	b.button_up.connect(_release.bind(action))
	return b


func _press(action: StringName) -> void:
	if InputMap.has_action(action):
		Input.action_press(action)
		if not _pressed.has(action):
			_pressed.append(action)


func _release(action: StringName) -> void:
	if InputMap.has_action(action):
		Input.action_release(action)
	_pressed.erase(action)
