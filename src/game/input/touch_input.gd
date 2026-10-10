## On-screen touch controls. Each button is a GUIDE 0.14 GUIDEVirtualButton,
## which injects InputEventJoypadButton on a *virtual* joypad device. The play
## context maps gamepad buttons with joy_index "Any", and GUIDE's "Any" includes
## virtual pads, so touch drives the exact same GUIDE actions as a real gamepad.
## Buttons with no real-gamepad button (Flip, View) use PADDLE1-4, which the
## context binds for this purpose.
class_name TouchInput
extends CanvasLayer

## Button radius in px (canvas units).
@export var button_radius: float = 44.0
## TOUCH for shipping; MOUSE_AND_TOUCH lets desktop mouse clicks drive it too.
@export var input_mode: GUIDEVirtualJoyBase.InputMode = GUIDEVirtualJoyBase.InputMode.MOUSE_AND_TOUCH

## [label, joy button, position as fraction of the visible viewport]
const LAYOUT: Array = [
	["▲", JOY_BUTTON_DPAD_UP, Vector2(0.10, 0.60)],
	["▼", JOY_BUTTON_DPAD_DOWN, Vector2(0.10, 0.88)],
	["◀", JOY_BUTTON_DPAD_LEFT, Vector2(0.04, 0.74)],
	["▶", JOY_BUTTON_DPAD_RIGHT, Vector2(0.16, 0.74)],
	["Turn ◀", JOY_BUTTON_LEFT_SHOULDER, Vector2(0.66, 0.62)],
	["Turn ▶", JOY_BUTTON_RIGHT_SHOULDER, Vector2(0.76, 0.62)],
	["Flip ◀", JOY_BUTTON_PADDLE1, Vector2(0.66, 0.84)],
	["Flip ▶", JOY_BUTTON_PADDLE2, Vector2(0.76, 0.84)],
	["Soft", JOY_BUTTON_B, Vector2(0.91, 0.62)],
	["Drop", JOY_BUTTON_A, Vector2(0.91, 0.84)],
	["View ◀", JOY_BUTTON_PADDLE3, Vector2(0.42, 0.09)],
	["View ▶", JOY_BUTTON_PADDLE4, Vector2(0.58, 0.09)],
	["Restart", JOY_BUTTON_BACK, Vector2(0.06, 0.09)],
	["Pause", JOY_BUTTON_START, Vector2(0.94, 0.09)],
]

var _buttons: Array[GUIDEVirtualButton] = []


func _ready() -> void:
	for entry: Array in LAYOUT:
		var b := GUIDEVirtualButton.new()
		b.button_index = entry[1]
		b.button_radius = button_radius
		b.input_mode = input_mode
		b.draw_debug = true
		b.set_meta(&"anchor", entry[2])
		var l := Label.new()
		l.text = entry[0]
		l.add_theme_font_size_override(&"font_size", 18)
		l.add_theme_color_override(&"font_color", Color.BLACK)
		b.add_child(l)
		add_child(b)
		_buttons.append(b)
	get_viewport().size_changed.connect(_layout)
	_layout()


func _layout() -> void:
	var size: Vector2 = get_viewport().get_visible_rect().size
	for b in _buttons:
		b.position = size * (b.get_meta(&"anchor") as Vector2)
