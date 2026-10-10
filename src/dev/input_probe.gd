## Dev probe: shows + prints the last GameInput signal.
extends Node

@onready var _label: Label = $Label
@onready var _input: GameInput = $GameInput


func _ready() -> void:
	_input.move.connect(func(d: Vector2i) -> void: _show("move %s" % d))
	_input.rotate_piece.connect(func(a: StringName, d: int) -> void: _show("rotate_piece %s %d" % [a, d]))
	_input.soft_drop.connect(func(on: bool) -> void: _show("soft_drop %s" % on))
	_input.hard_drop.connect(func() -> void: _show("hard_drop"))
	_input.view_rotate.connect(func(d: int) -> void: _show("view_rotate %d" % d))
	_input.pause_pressed.connect(func() -> void: _show("pause_pressed"))
	_input.restart_pressed.connect(func() -> void: _show("restart_pressed"))


func _show(s: String) -> void:
	_label.text = "last: " + s
	print("[input_probe] ", s)
