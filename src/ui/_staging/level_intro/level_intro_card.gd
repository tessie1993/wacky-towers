extends Control
## Level intro card. Values pushed in with show_level(); no level data lookups.

const Kit := preload("res://src/ui/theme/ui_kit.gd")

signal start_pressed
signal back_pressed

var start_button: Button
var back_button: Button
var name_label: Label
var goal_label: Label
var stars_label: Label


func _ready() -> void:
	Kit.backdrop(self, Color(0, 0, 0, 0.45))
	var col := Kit.column(self)
	name_label = Kit.label("", "", &"HeaderLabel")
	goal_label = Kit.label("", "")
	stars_label = Kit.label("", "", &"SmallLabel")
	goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stars_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	start_button = Kit.button("UI_START", "Start", Vector2(300, 104), true)
	back_button = Kit.button("UI_BACK", "Back", Vector2(300, 88))
	for c in [name_label, goal_label, stars_label, start_button, back_button]:
		col.add_child(c)
	start_button.pressed.connect(func() -> void: start_pressed.emit())
	back_button.pressed.connect(func() -> void: back_pressed.emit())


## info: { name: String, goal_text: String (e.g. "Clear 4 layers"), star_targets: Array of 3 strings }.
func show_level(info: Dictionary) -> void:
	name_label.text = str(info.get("name", ""))
	goal_label.text = str(info.get("goal_text", ""))
	var lines: Array[String] = []
	var i := 1
	for s in info.get("star_targets", []):
		lines.append("%d: %s" % [i, s])
		i += 1
	stars_label.text = "\n".join(lines)
	visible = true
