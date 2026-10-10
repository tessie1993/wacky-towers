extends Control
## Title screen. Display only: emits signals, the integrator navigates.

const Kit := preload("res://src/ui/theme/ui_kit.gd")

signal play_pressed
signal settings_pressed
signal quit_pressed

var play_button: Button
var settings_button: Button
var quit_button: Button


func _ready() -> void:
	Kit.backdrop(self, Color("BFE8FF"))
	var col := Kit.column(self, false, 420)
	col.add_theme_constant_override("separation", 20)
	col.add_child(Kit.label("UI_TITLE_LOGO", "Wacky Towers", &"LogoLabel"))
	play_button = Kit.button("UI_PLAY", "Play", Vector2(420, 112), true)
	settings_button = Kit.button("UI_SETTINGS", "Settings", Vector2(420, 96))
	quit_button = Kit.button("UI_QUIT", "Quit", Vector2(420, 96))
	for b in [play_button, settings_button, quit_button]:
		col.add_child(b)
	play_button.pressed.connect(func() -> void: play_pressed.emit())
	settings_button.pressed.connect(func() -> void: settings_pressed.emit())
	quit_button.pressed.connect(func() -> void: quit_pressed.emit())
