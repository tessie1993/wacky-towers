class_name FpHud
extends CanvasLayer
## Prototype HUD: layers/timer (top-left), next pieces (top-centre),
## win and lose panels. All controls are built in code in bind().

const FONT_SIZE: int = 24
const TITLE_SIZE: int = 36
const STAR_SIZE: int = 56
const MAX_STARS: int = 3
const BUTTON_MIN_SIZE: Vector2 = Vector2(240.0, 72.0)
const EDGE_MARGIN: float = 16.0
const LEGEND_SIZE: int = 16
const LEGEND: String = "Q/E Turn   R/F Flip   Space drop   Shift soft   Z/C view   Bksp restart"

var _game: FpGame
var _layers_label: Label
var _timer_label: Label
var _next_label: Label
var _stars_label: Label
var _win_panel: CenterContainer
var _lose_panel: CenterContainer


## Builds the HUD controls and wires them to the game. Call once per game.
func bind(game: FpGame) -> void:
	_game = game

	var top_left := VBoxContainer.new()
	top_left.position = Vector2(EDGE_MARGIN, EDGE_MARGIN)
	_layers_label = _make_label(FONT_SIZE)
	_timer_label = _make_label(FONT_SIZE)
	top_left.add_child(_layers_label)
	top_left.add_child(_timer_label)
	add_child(top_left)

	_next_label = _make_label(FONT_SIZE)
	_next_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_next_label.offset_top = EDGE_MARGIN
	_next_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_next_label)

	var legend := _make_label(LEGEND_SIZE)
	legend.text = LEGEND
	legend.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	legend.grow_horizontal = Control.GROW_DIRECTION_BOTH
	legend.grow_vertical = Control.GROW_DIRECTION_BEGIN
	legend.offset_bottom = -EDGE_MARGIN
	legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(legend)

	_stars_label = _make_label(STAR_SIZE)
	_stars_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_win_panel = _make_panel("Level complete!", _stars_label, "Restart")
	_lose_panel = _make_panel("Try again", null, "Retry")

	game.changed.connect(_refresh)
	game.finished.connect(_refresh.unbind(2))
	_refresh()


## Creates a font-sized label (text is set by _refresh).
func _make_label(font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	# White text with a dark outline + shadow reads over sky, board and blocks alike.
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.10, 0.16))
	label.add_theme_constant_override("outline_size", 8)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.45))
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label


## Builds a hidden centred panel: title, optional extra label, restart button.
func _make_panel(title: String, extra: Label, button_text: String) -> CenterContainer:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.visible = false
	add_child(center)

	var card := PanelContainer.new()
	center.add_child(card)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	card.add_child(box)

	var title_label := _make_label(TITLE_SIZE)
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title_label)

	if extra != null:
		box.add_child(extra)

	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = BUTTON_MIN_SIZE
	button.add_theme_font_size_override("font_size", FONT_SIZE)
	button.pressed.connect(_on_restart_pressed)
	box.add_child(button)
	return center


## Pulls current game values into the controls and shows the matching panel.
func _refresh() -> void:
	if _game == null:
		return
	_layers_label.text = "Layers %d / %d" % [_game.layers_cleared_total, _game.goal_n]

	var secs: int = _game.elapsed_ms / 1000
	_timer_label.text = "%d:%02d" % [secs / 60, secs % 60]

	var shapes := PackedStringArray()
	for shape: String in _game.next_shapes:
		shapes.append(shape.to_upper())
	_next_label.text = "Next: " + " ".join(shapes)

	var won: bool = _game.state == FpGame.State.WON
	_win_panel.visible = won
	_lose_panel.visible = _game.state == FpGame.State.LOST
	if won:
		var star_count: int = _game.stars()
		_stars_label.text = "★".repeat(star_count) + "☆".repeat(MAX_STARS - star_count)


## Both panels restart the same game.
func _on_restart_pressed() -> void:
	_game.restart()
