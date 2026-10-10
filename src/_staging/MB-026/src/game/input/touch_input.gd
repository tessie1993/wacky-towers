class_name TouchInput
extends CanvasLayer
## On-screen touch controls (ADR-0012, design/gdd/touch-controls.md). Each button is a
## GUIDE 0.14 GUIDEVirtualButton: it injects InputEventJoypadButton on a virtual joypad, and the
## play context maps gamepad buttons with joy_index "Any", so touch drives the same GUIDE actions
## as a real gamepad. Buttons with no real-gamepad button (Flip, View) use PADDLE1-4; Roll uses X/Y
## (indices match contexts/play.tres). Layouts are data: assets/data/controls/touch_layouts.json.

## Layout file read at _ready.
const LAYOUT_PATH: String = "res://assets/data/controls/touch_layouts.json"
## Base button radius in dp (80 dp diameter at 100%) so 75% still meets the 56 dp minimum.
const BASE_RADIUS_DP: float = 40.0
## Smallest drawn diameter of an in-play button in dp (ACC-14).
const MIN_DIAMETER_DP: float = 56.0

## [slot id, label, joy button, rotation axis (or &"" when not a rotation button)]
const SLOTS: Array = [
	[&"move_up", "▲", JOY_BUTTON_DPAD_UP, &""],
	[&"move_down", "▼", JOY_BUTTON_DPAD_DOWN, &""],
	[&"move_left", "◀", JOY_BUTTON_DPAD_LEFT, &""],
	[&"move_right", "▶", JOY_BUTTON_DPAD_RIGHT, &""],
	[&"spin_left", "Turn ◀", JOY_BUTTON_LEFT_SHOULDER, &"spin"],
	[&"spin_right", "Turn ▶", JOY_BUTTON_RIGHT_SHOULDER, &"spin"],
	[&"tilt_left", "Flip ◀", JOY_BUTTON_PADDLE1, &"tilt"],
	[&"tilt_right", "Flip ▶", JOY_BUTTON_PADDLE2, &"tilt"],
	[&"roll_left", "Roll ◀", JOY_BUTTON_X, &"roll"],
	[&"roll_right", "Roll ▶", JOY_BUTTON_Y, &"roll"],
	[&"soft", "Soft", JOY_BUTTON_B, &""],
	[&"hard", "Drop", JOY_BUTTON_A, &""],
	[&"view_left", "View ◀", JOY_BUTTON_PADDLE3, &""],
	[&"view_right", "View ▶", JOY_BUTTON_PADDLE4, &""],
	[&"restart", "Restart", JOY_BUTTON_BACK, &""],
	[&"pause", "Pause", JOY_BUTTON_START, &""],
]

## TOUCH for shipping; MOUSE_AND_TOUCH lets desktop mouse clicks drive it too.
@export var input_mode: GUIDEVirtualJoyBase.InputMode = GUIDEVirtualJoyBase.InputMode.MOUSE_AND_TOUCH
## Layout preset: buttons, gestures (the buttons that remain beside gesture zones), one_hand or one_hand_left.
@export var preset: StringName = &"buttons"
## Left-hand mirror: flips layout x. The meaning of each button is unchanged.
@export var mirror: bool = false
## Button size multiplier (settings.controls.button_scale), clamped to the scale limits.
@export_range(0.75, 2.0, 0.05) var button_scale: float = 1.0
# ponytail: limits are exports until control.button_scale_min/max knobs exist (ADR-0012 s5); pass them via configure().
## Lowest allowed button scale.
@export var scale_min: float = 0.75
## Highest allowed button scale.
@export var scale_max: float = 2.0

var _buttons: Dictionary = {}  # slot id -> GUIDEVirtualButton
var _layouts: Dictionary = {}
var _enabled_axes: Array[StringName] = InputAxes.ALL.duplicate()


## Radius in px for a scale: scaled base radius, never under half the 56 dp minimum diameter.
## Usage: TouchInput.radius_px(0.75, 0.75, 2.0, 1.0) returns 30.0 (1 dp = 1 px)
static func radius_px(scale: float, lo: float, hi: float, dp_to_px: float) -> float:
	var s: float = clampf(scale, lo, hi)
	return maxf(BASE_RADIUS_DP * s, MIN_DIAMETER_DP * 0.5) * dp_to_px


## True when the viewport is at least as wide as tall (picks the landscape layout block).
static func is_landscape(viewport_size: Vector2) -> bool:
	return viewport_size.x >= viewport_size.y


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # virtual buttons only work under pause this way (ADR-0012 V6)
	_layouts = _load_layouts()
	for entry: Array in SLOTS:
		var b := GUIDEVirtualButton.new()
		b.button_index = entry[2]
		b.input_mode = input_mode
		b.draw_debug = true
		var l := Label.new()
		l.text = entry[1]
		l.add_theme_font_size_override(&"font_size", 18)
		l.add_theme_color_override(&"font_color", Color.BLACK)
		b.add_child(l)
		add_child(b)
		_buttons[entry[0]] = b
	get_viewport().size_changed.connect(_layout)
	_layout()


## Applies player settings and re-lays out. [param new_preset] is buttons, gestures, one_hand or
## one_hand_left (= one_hand + mirror). Scale is clamped to [param lo]..[param hi].
func configure(new_preset: StringName, new_mirror: bool, new_scale: float,
		lo: float = 0.75, hi: float = 2.0) -> void:
	preset = new_preset
	mirror = new_mirror
	scale_min = lo
	scale_max = hi
	button_scale = clampf(new_scale, lo, hi)
	if is_node_ready():
		_layout()


## Hides (and stops input on) rotation buttons whose axis is not in [param axes] (rule 9: hidden, not greyed).
func set_enabled_axes(axes: Array[StringName]) -> void:
	_enabled_axes = axes.duplicate()
	if is_node_ready():
		_layout()


## Releases every held virtual button and forgets touches (pause, screen change; ADR-0012 s7.5).
func cancel_all() -> void:
	for b: GUIDEVirtualButton in _buttons.values():
		_release(b)


func _release(b: GUIDEVirtualButton) -> void:
	# GUIDE 0.14 has no public release; these are its own members.
	b._finger_positions.clear()
	b._release()


func _layout() -> void:
	var size: Vector2 = get_viewport().get_visible_rect().size
	var preset_id: String = String(preset)
	var flip: bool = mirror
	if preset_id == "one_hand_left":
		preset_id = "one_hand"
		flip = true
	var block: Dictionary = {}
	var presets: Dictionary = _layouts.get("presets", {})
	if presets.has(preset_id):
		block = (presets[preset_id] as Dictionary).get("landscape" if is_landscape(size) else "portrait", {})
	var dp: float = DisplayServer.screen_get_dpi() / 160.0 if OS.has_feature("android") else 1.0
	var radius: float = radius_px(button_scale, scale_min, scale_max, dp)
	for entry: Array in SLOTS:
		var b: GUIDEVirtualButton = _buttons[entry[0]]
		var axis: StringName = entry[3]
		var shown: bool = block.has(entry[0]) and (axis == &"" or axis in _enabled_axes)
		b.visible = shown
		# Disabled nodes get no _input, so hidden buttons cannot be pressed.
		b.process_mode = Node.PROCESS_MODE_INHERIT if shown else Node.PROCESS_MODE_DISABLED
		if not shown:
			_release(b)
			continue
		var f: Array = block[entry[0]]
		var fx: float = (1.0 - float(f[0])) if flip else float(f[0])
		b.button_radius = radius
		b.position = size * Vector2(fx, float(f[1]))


func _load_layouts() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH))
	if parsed is Dictionary:
		return parsed
	push_error("TouchInput: cannot read %s" % LAYOUT_PATH)
	return {}
