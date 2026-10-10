class_name GameUi
extends CanvasLayer
## Snapshot-only UI. The controller owns profiles, progression and the simulation.
## Adapted from MB-027/028/034 contracts; prototype/staged scenes remain intact.

signal intent(id: StringName, args: Dictionary)

const Diorama := preload("res://src/ui/toy_diorama.gd")
const Glyph := preload("res://src/ui/common/ui_glyph.gd")
const Format := preload("res://src/ui/common/ui_format.gd")
const StoryStage := preload("res://src/ui/wordless_story.tscn")
const CREAM := Color("fff8e7")
const INK := Color("243b4d")
const MUTED := Color("596d77")
const ORANGE := Color("eaa05b")
const MINT := Color("b8ddc7")
const PHYSICS_VARIANTS: Array[Dictionary] = [
	{"id":"tower_race", "name":"Tower Race", "description":"Build an eight-cell-high tower and keep it steady for a second."},
	{"id":"grid_settle", "name":"Grid Settle", "description":"Let each toy settle into place. Full layers break into tumbling chunks."},
	{"id":"balance", "name":"Balance", "description":"Fit as many toys as you can on a tiny island. Catch every piece."},
	{"id":"bridge_builder", "name":"Bridge Builder", "description":"Span the gap with a steady bridge so Pip can walk across."},
	{"id":"seesaw", "name":"Seesaw", "description":"Balance your tower on the rocking plank. Keep its tilt below 25 degrees."},
	{"id":"bowl_fill", "name":"Bowl Fill", "description":"Fit ten pieces in the bowl and fill it to the rim. Keep toys from spilling."},
	{"id":"windy_tower", "name":"Windy Tower", "description":"Reach eight cells high while gusts push the toys around."},
	{"id":"meteor_shower", "name":"Meteor Shower", "description":"Keep your tower standing through a minute of falling meteors."},
	{"id":"tallest_in_time", "name":"Tallest in Time", "description":"You have 90 seconds. Build the tallest steady tower you can."},
	{"id":"gentle_drop", "name":"Gentle Drop", "description":"Set fragile toys down softly. Fast landings break them."},
	{"id":"moving_platform", "name":"Moving Platform", "description":"Reach eight cells high on a moving island. Time every landing."},
	{"id":"domino_chain", "name":"Domino Chain", "description":"Place at least three pieces, then Push to topple them into the bell."},
	{"id":"reach_out", "name":"Reach Out", "description":"Build sideways toward the flag. Sticky anchors hold your reach together."}]

var current_screen: String = ""
var _snapshot: Dictionary = {}
var _root: Control
var _menu: Control
var _hud: Control
var _countdown: Label
var _toast: PanelContainer
var _hud_labels: Dictionary = {}
var _hud_data: Dictionary = {}
var _portrait: bool = false
var _prefs: Dictionary = {}
var _profile_edit: bool = false
var _remap_action: String = ""
var _toast_generation: int = 0
var _focus_default: Button
var _settings_tab: int = 0
var _text_factor: float = 1.0
var _control_factor: float = 1.0
var _requested_control_factor: float = 1.0
var _is_overlay: bool = false
var _story_generation: int = 0

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = Control.new()
	_root.name = "GameUi"
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.theme = _make_theme()
	get_viewport().size_changed.connect(_on_resize)
	_portrait = get_viewport().get_visible_rect().size.x < get_viewport().get_visible_rect().size.y

func _make_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = roundi(18 * _text_factor)
	t.set_color("font_color", "Label", INK)
	t.set_color("font_color", "Button", INK)
	t.set_color("font_hover_color", "Button", INK)
	t.set_color("font_pressed_color", "Button", INK)
	t.set_color("font_focus_color", "Button", INK)
	t.set_color("font_hover_pressed_color", "Button", INK)
	t.set_color("font_disabled_color", "Button", MUTED)
	t.set_color("font_color", "LineEdit", INK)
	t.set_color("font_placeholder_color", "LineEdit", MUTED)
	for type_name in ["TabBar", "TabContainer", "OptionButton", "CheckButton", "SpinBox"]:
		t.set_color("font_color", type_name, INK)
		t.set_color("font_selected_color", type_name, INK)
		t.set_color("font_unselected_color", type_name, MUTED)
		t.set_color("font_hovered_color", type_name, INK)
		t.set_color("font_pressed_color", type_name, INK)
		t.set_color("font_focus_color", type_name, INK)
		t.set_font_size("font_size", type_name, roundi(18 * _text_factor))
	for state in ["tab_selected", "tab_unselected", "tab_hovered", "tab_disabled"]:
		var tab := _style(ORANGE if state == "tab_selected" else CREAM, 8, INK, 1)
		tab.content_margin_left = 14
		tab.content_margin_right = 14
		tab.content_margin_top = 12
		tab.content_margin_bottom = 12
		t.set_stylebox(state, "TabBar", tab)
		t.set_stylebox(state, "TabContainer", tab)
	t.set_stylebox("panel", "TabContainer", _style(CREAM, 14, INK, 2))
	for part in ["slider", "grabber_area", "grabber_area_highlight"]:
		var rail := _style(Color("d7dcd0") if part == "slider" else ORANGE, 5)
		rail.content_margin_top = 4
		rail.content_margin_bottom = 4
		t.set_stylebox(part, "HSlider", rail)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var color := CREAM
		if state == "hover": color = Color("f4e6c9")
		if state == "pressed": color = Color("e4d4b5")
		if state == "disabled": color = Color("e5e4d9")
		var style := _style(color, 14, INK, 2 if state != "focus" else 4)
		style.content_margin_left = 18
		style.content_margin_right = 18
		style.content_margin_top = 11
		style.content_margin_bottom = 11
		if state == "focus": style.bg_color = Color(0, 0, 0, 0)
		t.set_stylebox(state, "Button", style)
	t.set_stylebox("panel", "PanelContainer", _style(CREAM, 22, INK, 2))
	t.set_stylebox("normal", "LineEdit", _style(Color("ffffff"), 12, INK, 2))
	t.set_stylebox("focus", "LineEdit", _style(Color("ffffff"), 12, Color("d58443"), 3))
	t.set_stylebox("background", "ProgressBar", _style(Color("dce2d5"), 7))
	t.set_stylebox("fill", "ProgressBar", _style(ORANGE, 7))
	t.set_constant("separation", "VBoxContainer", 12)
	t.set_constant("separation", "HBoxContainer", 12)
	t.set_constant("h_separation", "HFlowContainer", 12)
	t.set_constant("v_separation", "HFlowContainer", 12)
	return t

func _style(color: Color, radius: int = 12, border: Color = Color.TRANSPARENT, width: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.border_color = border
	s.set_border_width_all(width)
	return s

func _begin(screen: String, data: Dictionary, overlay: bool = false) -> VBoxContainer:
	current_screen = screen
	_story_generation += 1
	_is_overlay = overlay
	_snapshot = data.duplicate(true)
	_focus_default = null
	if is_instance_valid(_menu):
		_root.remove_child(_menu)
		_menu.queue_free()
	_menu = Control.new()
	_menu.name = screen.capitalize().replace(" ", "")
	_menu.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_menu)
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if is_instance_valid(_hud): _hud.hide()
	var bg := ColorRect.new()
	bg.color = Color(INK, .72) if overlay else Color("eaf1de")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu.add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	_menu.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var pad := 18 if _portrait else 28
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, pad)
	var col := _vbox()
	margin.add_child(col)
	return col

func _vbox(parent: Node = null, separation: int = 12) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_PASS
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", separation)
	if parent != null: parent.add_child(col)
	return col

func _hbox(parent: Node = null, separation: int = 12) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", separation)
	if parent != null: parent.add_child(row)
	return row

func _label(text: String, font_size: int = 18, color: Color = INK, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", maxi(12, roundi(font_size * _text_factor)))
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if centered: label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func _button(text: String, id: StringName, args: Dictionary = {}, primary: bool = false, height: float = 50.0) -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = text
	button.add_theme_font_size_override("font_size", maxi(14, roundi(18 * _text_factor)))
	button.custom_minimum_size.y = height
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func() -> void: intent.emit(id, args))
	if primary:
		button.add_theme_stylebox_override("normal", _style(ORANGE, 14, INK, 2))
		button.add_theme_stylebox_override("hover", _style(ORANGE.lightened(.12), 14, INK, 2))
		button.add_theme_stylebox_override("pressed", _style(ORANGE.darkened(.08), 14, INK, 2))
		_focus_default = button
	return button

func _header(parent: Node, title: String, subtitle: String = "", back: bool = true) -> void:
	var row := _hbox(parent)
	if back:
		var b := _button("‹", &"back")
		b.custom_minimum_size.x = 52
		b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		b.tooltip_text = "Back"
		row.add_child(b)
	var col := _vbox(row, 2)
	col.add_child(_label(title, 30 if _portrait else 34, CREAM if _is_overlay else INK))
	if not subtitle.is_empty(): col.add_child(_label(subtitle, 16, CREAM if _is_overlay else MUTED))
	var settings := _button("Settings", &"open_settings")
	settings.size_flags_horizontal = Control.SIZE_SHRINK_END
	settings.visible = current_screen != "settings"
	row.add_child(settings)

func _scroll(parent: Node) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 100
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	return _vbox(scroll, 16)

func _card(parent: Node, color: Color = CREAM) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(color, 20, INK, 2))
	parent.add_child(panel)
	var pad := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 20)
	panel.add_child(pad)
	return _vbox(pad)

func _finish() -> void:
	if is_instance_valid(_focus_default): _focus_if_ready.call_deferred(_focus_default)

func _focus_if_ready(button: Variant) -> void:
	if is_instance_valid(button) and button.is_inside_tree() and button.is_visible_in_tree() and not button.is_queued_for_deletion(): button.grab_focus()

func _time_text(value: Variant) -> String:
	if value is String or value is StringName: return str(value)
	return Format.time_ms(int(float(value) * 1000.0))

func show_title(data: Dictionary = {}) -> void:
	var col := _begin("title", data)
	var top := _hbox(col)
	var name := str(data.get("profile_name", "Profiles"))
	top.add_child(_button("☁  " + name, &"open_profiles"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(spacer)
	var settings := _button("Settings", &"open_settings")
	settings.size_flags_horizontal = Control.SIZE_SHRINK_END
	top.add_child(settings)
	var body := BoxContainer.new()
	body.vertical = _portrait
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 28)
	col.add_child(body)
	var art := _vbox(body, 0)
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.size_flags_vertical = Control.SIZE_EXPAND_FILL
	art.add_child(_label("WACKY", 54 if _portrait else 72, INK, true))
	art.add_child(_label("TOWERS", 54 if _portrait else 72, INK, true))
	var diorama := Diorama.new()
	diorama.custom_minimum_size = Vector2(0, 160 if _portrait else 260)
	diorama.size_flags_vertical = Control.SIZE_EXPAND_FILL
	art.add_child(diorama)
	art.add_child(_label("A little cloud. A lot of possibilities.", 18, MUTED, true))
	var menu_center := CenterContainer.new()
	menu_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(menu_center)
	var actions := _card(menu_center)
	actions.custom_minimum_size.x = 280 if _portrait else 360
	actions.add_child(_label("Welcome to Meadow", 28, INK, true))
	var has_profile := bool(data.get("has_profile", false))
	if has_profile:
		actions.add_child(_label(str(data.get("continue_level_name", "Your next little adventure")), 16, MUTED, true))
		actions.add_child(_button("Continue  →", &"continue", {}, true, 64))
	else:
		actions.add_child(_label("Build, turn, drop. Make room for wonder.", 16, MUTED, true))
		actions.add_child(_button("Let's play  →", &"play", {}, true, 64))
	var row := _hbox(actions)
	row.add_child(_button("Island map", &"open_map"))
	row.add_child(_button("Arcade", &"open_arcade"))
	row = _hbox(actions)
	row.add_child(_button("Toy shop", &"open_shop"))
	row.add_child(_button("Tournament", &"open_tournament"))
	actions.add_child(_button("Physics toy box", &"open_physics"))
	if has_profile: actions.add_child(_label("★  %d collected    ·    %d in your jar" % [int(data.get("stars", 0)), int(data.get("wallet", 0))], 16, MUTED, true))
	var foot := _hbox(col)
	foot.add_child(_label("THE TOY-BOX COLLECTION  ·  %d BIOMES  ·  %d LEVELS + BONUS" % [int(data.get("biome_count", 10)), int(data.get("level_count", 100))], 13, MUTED))
	var quit := _button("Quit", &"quit")
	quit.pressed.disconnect(quit.pressed.get_connections()[0].callable)
	quit.pressed.connect(confirm_quit)
	quit.size_flags_horizontal = Control.SIZE_SHRINK_END
	foot.add_child(quit)
	_finish()

func confirm_quit() -> void:
	_confirm("Leave the toy box?", "Your saved stars will be here when you return.", &"quit")

func show_profiles(data: Dictionary = {}) -> void:
	var col := _begin("profiles", data)
	_header(col, "Your little corner", "Four profiles. Four adventures.")
	var content := _scroll(col)
	var profiles: Array = data.get("profiles", [])
	var filled := {}
	for slot_index in profiles.size():
		var profile: Variant = profiles[slot_index]
		if profile is Dictionary: filled[int(profile.get("slot", slot_index))] = profile
	for slot in 4:
		var card := _card(content, MINT if slot == int(data.get("active_slot", -1)) else CREAM)
		if filled.has(slot):
			var p: Dictionary = filled[slot]
			var row := _hbox(card)
			var badge := Glyph.new(StringName(str(p.get("badge", "cloud"))), INK)
			badge.custom_minimum_size = Vector2(48, 48)
			row.add_child(badge)
			var b := _button(str(p.get("name", "Clover")) + ("  ✓" if slot == int(data.get("active_slot", -1)) else ""), &"select_profile", {"slot": slot}, true)
			row.add_child(b)
			card.add_child(_label("★  %d  ·  %d islands explored" % [int(p.get("stars", 0)), int(p.get("levels", 0))], 16, MUTED))
			var edit := _hbox(card)
			var rename := _button("Rename", &"noop")
			rename.pressed.disconnect(rename.pressed.get_connections()[0].callable)
			rename.pressed.connect(func() -> void: _profile_form(slot, p))
			edit.add_child(rename)
			var delete := _button("Delete…", &"noop")
			delete.pressed.disconnect(delete.pressed.get_connections()[0].callable)
			delete.pressed.connect(func() -> void: _confirm("Delete " + str(p.get("name", "profile")) + "?", "This removes their saved stars and progress.", &"delete_profile", {"slot": slot}))
			edit.add_child(delete)
		else:
			var b := _button("＋  New profile", &"noop")
			b.pressed.disconnect(b.pressed.get_connections()[0].callable)
			b.pressed.connect(func() -> void: _profile_form(slot, {}))
			card.add_child(b)
	_finish()

func _profile_form(slot: int, profile: Dictionary) -> void:
	var col := _begin("profile_form", _snapshot)
	_header(col, "New friend" if profile.is_empty() else "Edit friend")
	var content := _scroll(col)
	var card := _card(content)
	card.add_child(_label("Name", 20))
	var entry := LineEdit.new()
	entry.text = str(profile.get("name", "Clover"))
	entry.max_length = 12
	entry.custom_minimum_size.y = 56
	entry.placeholder_text = "1–12 characters"
	card.add_child(entry)
	var badges := OptionButton.new()
	badges.custom_minimum_size.y = 52
	for badge in ["Cloud", "Acorn", "Mushroom", "Snail", "Bee", "Daisy", "Leaf", "Wizard hat"]: badges.add_item(badge)
	for i in badges.item_count:
		if badges.get_item_text(i).to_lower().replace(" ", "_") == str(profile.get("badge", "cloud")): badges.select(i)
	card.add_child(_label("Badge", 20))
	card.add_child(badges)
	var colors := OptionButton.new()
	colors.custom_minimum_size.y = 52
	for color in ["Mint", "Sky", "Lemon", "Lime", "Lavender", "Peach"]: colors.add_item(color)
	for i in colors.item_count:
		if colors.get_item_text(i).to_lower() == str(profile.get("color", "mint")): colors.select(i)
	card.add_child(_label("Colour", 20))
	card.add_child(colors)
	var save := _button("Save friend  ✓", &"noop", {}, true, 60)
	save.pressed.disconnect(save.pressed.get_connections()[0].callable)
	save.pressed.connect(func() -> void:
		var cleaned := entry.text.strip_edges()
		if cleaned.is_empty():
			show_toast("Give your friend a name.")
			entry.grab_focus()
			return
		intent.emit(&"create_profile" if profile.is_empty() else &"rename_profile", {"slot": slot, "name": cleaned, "badge": badges.get_item_text(badges.selected).to_lower().replace(" ", "_"), "color": colors.get_item_text(colors.selected).to_lower()})
	)
	card.add_child(save)
	_finish()

func show_map(data: Dictionary = {}) -> void:
	var col := _begin("map", data)
	_header(col, str(data.get("biome_name", "The toy-box islands")), "A fresh surprise around every corner.")
	var info := _hbox(col)
	info.add_child(_button("☁  " + str(data.get("profile_name", "Your profile")), &"open_profiles"))
	info.add_child(_label("★  %d collected   ·   Jar %d" % [int(data.get("stars", 0)), int(data.get("wallet", 0))], 18, MUTED, true))
	var biomes: Array = data.get("biomes", [])
	if not biomes.is_empty():
		var select := OptionButton.new()
		select.custom_minimum_size.y = 52
		for i in biomes.size():
			var biome: Dictionary = biomes[i]
			select.add_item(str(biome.get("name", "Meadow")) + ("  ·  %s ★" % str(biome.get("stars", 0))))
			select.set_item_disabled(i, not bool(biome.get("unlocked", false)))
			if str(biome.get("id", "")) == str(data.get("selected_biome", "meadow")): select.select(i)
		select.item_selected.connect(func(index: int) -> void: intent.emit(&"select_biome", {"biome_id": str(biomes[index].get("id", "meadow"))}))
		col.add_child(select)
	var content := _scroll(col)
	var flow := HFlowContainer.new()
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(flow)
	var levels: Array = data.get("levels", [])
	for i in levels.size():
		var level: Dictionary = levels[i]
		var arc := AspectRatioContainer.new()
		arc.ratio = 1.36
		arc.custom_minimum_size = Vector2(210, 190)
		arc.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		flow.add_child(arc)
		var unlocked := bool(level.get("unlocked", true))
		var id := str(level.get("id", "meadow_%02d" % (i + 1)))
		var number := str(level.get("number", "%02d" % (i + 1)))
		var stars := "Design preview" if bool(level.get("preview", false)) else Format.stars(int(level.get("stars", 0)))
		var label := ("BONUS" if bool(level.get("bonus", false)) else number) + "\n" + str(level.get("name", "Meadow")) + "\n" + (stars if unlocked else "Locked")
		var b := _button(label, &"open_level", {"level_id": id}, id == str(data.get("next_level_id", "")))
		b.disabled = not unlocked
		b.clip_text = true
		b.add_theme_font_size_override("font_size", roundi(18 * _text_factor))
		b.tooltip_text = str(level.get("goal", "")) if unlocked else str(level.get("lock_reason", "Finish the previous island to visit."))
		for state in ["normal", "hover", "pressed", "disabled"]:
			var color := CREAM
			if state == "hover": color = Color("f4e6c9")
			if state == "pressed": color = Color("e4d4b5")
			if state == "disabled": color = Color("e5e4d9")
			if id == str(data.get("next_level_id", "")) and state != "disabled": color = ORANGE
			var plate := _style(color, 14, INK, 2)
			plate.content_margin_top = 78
			plate.content_margin_bottom = 11
			plate.content_margin_left = 14
			plate.content_margin_right = 14
			b.add_theme_stylebox_override(state, plate)
		var island := Glyph.new(&"island", INK)
		b.add_child(island)
		island.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		island.offset_top = 10
		island.offset_bottom = 78
		arc.add_child(b)
	var footer := _hbox(col)
	footer.add_child(_button("Toy shop", &"open_shop"))
	footer.add_child(_button("Arcade", &"open_arcade"))
	footer.add_child(_button("Tournament", &"open_tournament"))
	_finish()

func show_intro(data: Dictionary = {}) -> void:
	var col := _begin("intro", data)
	_header(col, str(data.get("name", "Meadow adventure")), str(data.get("level_id", "Meadow")).replace("_", " ").capitalize())
	var body := _scroll(col)
	var card := _card(body)
	card.add_child(_label("YOUR LITTLE MISSION", 14, MUTED, true))
	if bool(data.get("preview", false)):
		card.add_child(_label("DESIGN PREVIEW · NO STARS AWARDED", 16, MUTED, true))
	card.add_child(_label(str(data.get("goal", "Clear a layer")), 32, INK, true))
	card.add_child(_label(str(data.get("goal_detail", "Fill every square in a layer to make it disappear.")), 18, MUTED, true))
	var twists: Array = data.get("twists", [])
	if not twists.is_empty():
		card.add_child(_label("Today's surprises", 20))
		for twist in twists: card.add_child(_label("•  " + str(twist).replace("_", " ").capitalize(), 18))
	var targets: Array = data.get("star_targets", [])
	if not targets.is_empty() and not bool(data.get("preview", false)):
		var row := _hbox(card)
		for i in targets.size(): row.add_child(_label("★".repeat(i + 1) + "\n" + str(targets[i]), 18, MUTED, true))
	card.add_child(_label("Turn Q/E  ·  Move WASD  ·  Drop Space\nView Z/C  ·  Pause Esc", 16, MUTED, true))
	card.add_child(_button("Let's build  →", &"start_level", {"level_id": str(data.get("level_id", "meadow_01"))}, true, 64))
	_finish()

func show_hud(data: Dictionary = {}) -> void:
	clear_overlay()
	current_screen = "hud"
	_hud_data = data.duplicate(true)
	_build_hud()
	update_hud(data)

func _build_hud() -> void:
	if is_instance_valid(_hud):
		_root.remove_child(_hud)
		_hud.queue_free()
	_hud_labels.clear()
	var cell := maxf(56.0, 56.0 * _control_factor)
	var left_width := maxf(maxf(272.0, 220.0 * _text_factor), cell * 3.0 + 40.0)
	var right_width := maxf(maxf(248.0, 200.0 * _text_factor), cell * 2.0 + 44.0)
	var right_height := _control_height()
	_hud = Control.new()
	_hud.name = "Hud"
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_hud)
	_hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var top := MarginContainer.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(top)
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 18
	top.offset_right = -18
	top.offset_top = 16
	var col := _vbox(top, 8)
	var row := _hbox(col, 10)
	var pause := _play_button("Ⅱ", &"pause", {}, false)
	pause.tooltip_text = "Pause"
	pause.custom_minimum_size = Vector2(52, 52)
	pause.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	row.add_child(pause)
	var goal := _card(row)
	goal.add_theme_constant_override("separation", 2)
	_hud_labels.level = _label("Meadow", 14, MUTED)
	goal.add_child(_hud_labels.level)
	_hud_labels.goal = _label("0 / 1", 26)
	goal.add_child(_hud_labels.goal)
	var next := _card(row)
	next.size_flags_horizontal = Control.SIZE_SHRINK_END
	next.custom_minimum_size.x = 135 if not _portrait else 90
	next.add_child(_label("NEXT", 12, MUTED, true))
	_hud_labels.next = _label("—", 20, INK, true)
	next.add_child(_hud_labels.next)
	_hud_labels.held = _label("Hold: —", 14, MUTED, true)
	next.add_child(_hud_labels.held)
	_hud_labels.rules = _label("", 16, MUTED, true)
	var rules_panel := PanelContainer.new()
	rules_panel.add_theme_stylebox_override("panel", _style(CREAM, 10))
	var rules_margin := MarginContainer.new()
	for side in ["left", "right"]: rules_margin.add_theme_constant_override("margin_" + side, 12)
	for side in ["top", "bottom"]: rules_margin.add_theme_constant_override("margin_" + side, 6)
	rules_panel.add_child(rules_margin)
	rules_margin.add_child(_hud_labels.rules)
	_hud_labels.rules_panel = rules_panel
	col.add_child(rules_panel)
	var left := PanelContainer.new()
	left.name = "MoveControls"
	left.mouse_filter = Control.MOUSE_FILTER_PASS
	_hud.add_child(left)
	left.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	left.offset_left = 18
	left.offset_bottom = -18
	left.offset_right = 18 + left_width
	left.offset_top = -_left_control_height()
	var lpad := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]: lpad.add_theme_constant_override("margin_" + side, 12)
	left.add_child(lpad)
	var lcol := _vbox(lpad, 8)
	lcol.add_child(_label("MOVE", 12, MUTED, true))
	var pad := GridContainer.new()
	pad.columns = 3
	pad.add_theme_constant_override("h_separation", 6)
	pad.add_theme_constant_override("v_separation", 6)
	lcol.add_child(pad)
	for i in 9:
		if i in [1, 3, 5, 7]:
			var delta := Vector3i.ZERO
			var arrow := ""
			match i:
				1: delta = Vector3i(0, 0, -1); arrow = "↑"
				3: delta = Vector3i(-1, 0, 0); arrow = "←"
				5: delta = Vector3i(1, 0, 0); arrow = "→"
				7: delta = Vector3i(0, 0, 1); arrow = "↓"
			var b := _play_button(arrow, &"move", {"delta": delta}, true)
			b.custom_minimum_size = Vector2(cell, cell)
			pad.add_child(b)
		else:
			var blank := Control.new()
			blank.custom_minimum_size = Vector2(cell, cell)
			blank.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pad.add_child(blank)
	_hud_labels.score = _label("0", 18, INK, true)
	lcol.add_child(_hud_labels.score)
	var hold_row := _hbox(lcol, 8)
	hold_row.add_child(_play_button("Hold", &"hold", {}, false))
	_hud_labels.tools = _play_button("Tools", &"open_tools", {}, false)
	hold_row.add_child(_hud_labels.tools)
	var tools := _hbox(lcol, 8)
	_hud_labels.skill = _play_button("Skill", &"use_skill", {}, false)
	_hud_labels.skill.tooltip_text = "Character skill"
	tools.add_child(_hud_labels.skill)
	_hud_labels.potion = _play_button("Potion", &"use_item", {}, false)
	_hud_labels.potion.tooltip_text = "Selected potion"
	tools.add_child(_hud_labels.potion)
	var right := PanelContainer.new()
	right.name = "RotationControls"
	right.mouse_filter = Control.MOUSE_FILTER_PASS
	_hud.add_child(right)
	right.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	right.offset_right = -18
	right.offset_left = -(18 + right_width)
	right.offset_bottom = -18
	right.offset_top = -right_height
	var rpad := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]: rpad.add_theme_constant_override("margin_" + side, 12)
	right.add_child(rpad)
	var rcol := _vbox(rpad, 8)
	var view := _hbox(rcol, 8)
	view.add_child(_play_button("View ‹", &"view", {"direction": -1}, true))
	view.add_child(_play_button("View ›", &"view", {"direction": 1}, true))
	for axis in ["spin", "tilt", "roll"]:
		if axis == "tilt" and not bool(_hud_data.get("can_tilt", true)): continue
		if axis == "roll" and not bool(_hud_data.get("can_roll", true)): continue
		var r := _hbox(rcol, 8)
		var title: String = {"spin": "Turn", "tilt": "Flip", "roll": "Roll"}[axis]
		r.add_child(_play_button(title + " ‹", &"rotate", {"axis": StringName(axis), "direction": -1}, true))
		r.add_child(_play_button(title + " ›", &"rotate", {"axis": StringName(axis), "direction": 1}, true))
	var drop_row := _hbox(rcol, 8)
	var soft := _play_button("Soft", &"noop", {}, false)
	soft.pressed.disconnect(soft.pressed.get_connections()[0].callable)
	soft.button_down.connect(func() -> void: intent.emit(&"soft", {"active": true}))
	soft.button_up.connect(func() -> void: intent.emit(&"soft", {"active": false}))
	drop_row.add_child(soft)
	var drop := _play_button("DROP ↓", &"drop", {}, false)
	drop.custom_minimum_size.y = maxf(64.0, 64.0 * _control_factor)
	drop.add_theme_stylebox_override("normal", _style(ORANGE, 14, INK, 2))
	drop_row.add_child(drop)
	_hud_labels.time = _label("0:00", 18, MUTED, true)
	rcol.add_child(_hud_labels.time)
	var help := _label("WASD move  ·  Q/E turn  ·  Space drop  ·  Z/C view", 13, MUTED, true)
	help.visible = not _portrait
	_hud.add_child(help)
	help.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	help.offset_bottom = -20
	help.offset_top = -46
	help.offset_left = 270
	help.offset_right = -285
	# Portrait uses a broad board above two smaller touch clusters.
	if _portrait:
		var available := get_viewport().get_visible_rect().size.x - 48.0
		var combined := left_width + right_width
		if combined > available:
			left.offset_right = 18.0 + left_width / combined * available
			right.offset_left = -(18.0 + right_width / combined * available)
	if bool(_prefs.get("left_hand", false)):
		left.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		left.offset_left = -(18.0 + left_width)
		left.offset_right = -18
		right.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		right.offset_left = 18
		right.offset_right = 18.0 + right_width
	if is_instance_valid(_menu): _root.move_child(_menu, -1)
	if is_instance_valid(_countdown): _root.move_child(_countdown, -1)

func _play_button(text: String, id: StringName, args: Dictionary, repeats: bool) -> Button:
	var b := _button(text, id, args, false, maxf(56.0, 56.0 * _control_factor))
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	b.focus_mode = Control.FOCUS_NONE
	if repeats:
		var timer := Timer.new()
		timer.wait_time = .24
		timer.one_shot = false
		b.add_child(timer)
		b.button_down.connect(func() -> void: timer.start(.24))
		b.button_up.connect(timer.stop)
		timer.timeout.connect(func() -> void:
			if not b.is_pressed() or current_screen != "hud":
				timer.stop()
				return
			intent.emit(id, args)
			timer.start(.09)
		)
	return b

## Preferences accept canonical fractions or percent snapshots for both scales.
func apply_prefs(prefs: Dictionary) -> void:
	var previous_text_factor := _text_factor
	_prefs = prefs.duplicate(true)
	_text_factor = float(prefs.get("text_scale", 1.0))
	if _text_factor > 3.0: _text_factor *= .01
	_text_factor = clampf(_text_factor, 1.0, 1.5)
	_control_factor = float(prefs.get("button_scale", 1.0))
	if _control_factor > 3.0: _control_factor *= .01
	_control_factor = clampf(_control_factor, .75, 2.0)
	_requested_control_factor = _control_factor
	_fit_controls()
	_root.theme = _make_theme()
	if current_screen == "settings" and not is_equal_approx(previous_text_factor, _text_factor):
		_scale_live_labels(_menu, _text_factor / previous_text_factor)
	if current_screen == "hud":
		_build_hud()
		update_hud(_hud_data)
	elif not current_screen.is_empty() and current_screen not in ["profile_form", "confirm", "settings"]:
		_restore_screen(current_screen, _snapshot)

func _scale_live_labels(node: Node, ratio: float) -> void:
	if node is Label or node is Button:
		var control := node as Control
		if control.has_theme_font_size_override("font_size"):
			control.add_theme_font_size_override("font_size", maxi(12, roundi(control.get_theme_font_size("font_size") * ratio)))
	for child in node.get_children(): _scale_live_labels(child, ratio)

## The 3D stage should reserve this normalized region for the puzzle board.
func board_area() -> Rect2:
	var viewport_size := get_viewport().get_visible_rect().size
	if _portrait:
		var bottom := minf(.71, 1.0 - (_control_height() + 28.0) / viewport_size.y)
		return Rect2(.02, .22, .96, maxf(.15, bottom - .22))
	var cell := maxf(56.0, 56.0 * _control_factor)
	var left := (maxf(maxf(272.0, 220.0 * _text_factor), cell * 3.0 + 40.0) + 28.0) / viewport_size.x
	var right := (maxf(maxf(248.0, 200.0 * _text_factor), cell * 2.0 + 44.0) + 28.0) / viewport_size.x
	var top := maxf(.24, (150.0 * _text_factor + 16.0) / viewport_size.y)
	return Rect2(left, top, maxf(.20, 1.0 - left - right), maxf(.20, .89 - top))

func _control_height() -> float:
	var rows := 2
	if bool(_hud_data.get("can_tilt", true)): rows += 1
	if bool(_hud_data.get("can_roll", true)): rows += 1
	var cell := maxf(56.0, 56.0 * _control_factor)
	return maxf(cell * rows + maxf(64.0, 64.0 * _control_factor) + 86.0, _left_control_height())

func _left_control_height() -> float:
	return maxf(56.0, 56.0 * _control_factor) * 5.0 + 120.0 + (_text_factor - 1.0) * 110.0

func _fit_controls() -> void:
	var height := get_viewport().get_visible_rect().size.y
	var room := height - (150.0 * _text_factor + 48.0)
	var fit := maxf(1.0, (room - 120.0 - (_text_factor - 1.0) * 110.0) / 280.0)
	_control_factor = minf(_requested_control_factor, fit)

## Back inside a local form or confirmation is handled before the controller pops.
func handle_back() -> bool:
	if current_screen == "story":
		if bool(_snapshot.get("skippable", str(_snapshot.get("phase", "post")) != "pre")): _finish_story(_snapshot)
		return true
	if not _remap_action.is_empty():
		_remap_action = ""
		show_settings(_snapshot)
		return true
	if current_screen == "confirm":
		_restore_screen(str(_snapshot.get("return_screen", "title")), _snapshot.get("return_data", {}))
		return true
	if current_screen == "profile_form":
		show_profiles(_snapshot)
		return true
	return false

func update_hud(data: Dictionary) -> void:
	_hud_data.merge(data, true)
	if _hud_labels.is_empty(): return
	var capabilities: Dictionary = _hud_data.get("capabilities", {})
	_hud_labels.tools.visible = bool(capabilities.get("kit", false)) or bool(capabilities.get("choose_down", false)) or bool(capabilities.get("ice_flick", false)) or bool(capabilities.get("undo", false)) or bool(capabilities.get("reset", false))
	_hud_labels.tools.text = "Kit" if bool(capabilities.get("kit", false)) else ("Direction" if bool(capabilities.get("choose_down", false)) or bool(capabilities.get("ice_flick", false)) else "Puzzle")
	_hud_labels.level.text = str(_hud_data.get("level_name", "Meadow"))
	_hud_labels.goal.text = "%s  %s / %s" % [str(_hud_data.get("goal", "Layers")), str(_hud_data.get("progress", 0)), str(_hud_data.get("target", 1))]
	_hud_labels.next.text = str(_hud_data.get("next_piece", "—")).capitalize()
	_hud_labels.held.text = "Hold: " + str(_hud_data.get("held_shape", "—")).capitalize()
	var ready := bool(_hud_data.get("skill_ready", false))
	var charge := float(_hud_data.get("skill_charge", 0))
	_hud_labels.skill.disabled = not ready
	_hud_labels.skill.text = "Skill ✓" if ready else "%d%%" % clampi(roundi(charge / 10.0), 0, 100)
	_hud_labels.skill.tooltip_text = str(_hud_data.get("skill_name", "Character skill")) + (" · ready" if ready else " · charging")
	var potion_count := int(_hud_data.get("potion_count", 0))
	_hud_labels.potion.disabled = potion_count <= 0 or str(_hud_data.get("selected_potion", "")).is_empty()
	_hud_labels.potion.text = "Potion %d" % potion_count
	_hud_labels.potion.tooltip_text = str(_hud_data.get("selected_potion", "No potion selected")).replace("_", " ").capitalize()
	_hud_labels.score.text = "Score  %d" % int(_hud_data.get("score", 0))
	_hud_labels.time.text = _time_text(_hud_data.get("time", 0.0))
	_hud_labels.time.visible = bool(_prefs.get("show_clock", true))
	var twist_names := PackedStringArray()
	for twist in _hud_data.get("twists", []): twist_names.append(str(twist).replace("_", " ").capitalize())
	_hud_labels.rules.text = "  ·  ".join(twist_names)
	if _hud_data.has("wobble") and _hud_data.wobble is Dictionary and not _hud_data.wobble.is_empty():
		var wobble: Dictionary = _hud_data.wobble
		_hud_labels.rules.text += "  ·  Wobble %s / %s" % [str(wobble.get("value", 0)), str(wobble.get("target", 100))]
	if not str(_hud_data.get("warning", "")).is_empty(): _hud_labels.rules.text = "!  " + str(_hud_data.warning)
	elif not str(_hud_data.get("hint", "")).is_empty(): _hud_labels.rules.text += "  ·  " + str(_hud_data.hint)
	if bool(_hud_data.get("danger", false)):
		_hud_labels.rules.text = "!  Stack is getting tall  !"
		_hud_labels.rules.add_theme_color_override("font_color", Color("aa412c"))
	else: _hud_labels.rules.add_theme_color_override("font_color", MUTED)
	_hud_labels.rules_panel.visible = not _hud_labels.rules.text.strip_edges().is_empty()
	if int(_hud_data.get("round", 0)) > 0: _hud_labels.level.text += "  ·  Round %s" % str(_hud_data.round)

func show_countdown(value: String) -> void:
	if not is_instance_valid(_countdown):
		_countdown = _label(value, 100, INK, true)
		_countdown.name = "Countdown"
		_countdown.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_countdown.mouse_filter = Control.MOUSE_FILTER_STOP
		_root.add_child(_countdown)
		_countdown.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_countdown.text = value
	_countdown.show()
	_root.move_child(_countdown, -1)

func hide_countdown() -> void:
	if is_instance_valid(_countdown): _countdown.hide()

## Core capabilities gate every puzzle action; absent capabilities expose no controls.
func show_tools(data: Dictionary = {}) -> void:
	var col := _begin("tools", data, true)
	_header(col, "Puzzle tools", "Choose your next little move.")
	var content := _scroll(col)
	var capabilities: Dictionary = data.get("capabilities", {})
	if bool(capabilities.get("kit", false)):
		var kit := _card(content)
		kit.add_child(_label("YOUR KIT  ·  %d LEFT" % int(data.get("selection_remaining", 0)), 24))
		for choice: Dictionary in data.get("kit_choices", []):
			var id := str(choice.get("shape_id", ""))
			var remaining := int(choice.get("remaining", 0))
			var button := _button(id.replace("_", " ").capitalize() + "  ×%d" % remaining, &"pick_shape", {"shape_id": id})
			button.disabled = remaining <= 0
			kit.add_child(button)
	if bool(capabilities.get("choose_down", false)):
		var directions := _card(content)
		directions.add_child(_label("TRAVEL DIRECTION", 24))
		_direction_buttons(directions, data.get("allowed_down", []), &"choose_down")
	if bool(capabilities.get("ice_flick", false)):
		var flick := _card(content)
		flick.add_child(_label("ICE FLICK  ·  %d LEFT" % int(capabilities.get("flicks_left", 0)), 24))
		_direction_buttons(flick, data.get("allowed_flick", []), &"flick", int(capabilities.get("flicks_left", 0)) > 0)
	if bool(capabilities.get("undo", false)) or bool(capabilities.get("reset", false)):
		var turns := _card(content)
		if bool(capabilities.get("undo", false)): turns.add_child(_button("Undo last turn  ↶", &"undo"))
		if bool(capabilities.get("reset", false)): turns.add_child(_button("Reset this puzzle  ↻", &"reset"))
	col.add_child(_button("Keep building  →", &"resume", {}, true, 56))
	_finish()

func _direction_buttons(parent: Node, allowed: Array, id: StringName, enabled: bool = true) -> void:
	for raw: Variant in allowed:
		var direction := Vector3i.ZERO
		if raw is Vector3i: direction = raw
		elif raw is Array and raw.size() == 3: direction = Vector3i(int(raw[0]), int(raw[1]), int(raw[2]))
		if direction == Vector3i.ZERO: continue
		var label := "↓  Down"
		if direction.x < 0: label = "←  Left"
		elif direction.x > 0: label = "→  Right"
		elif direction.z < 0: label = "↑  Away"
		elif direction.z > 0: label = "↓  Closer"
		elif direction.y > 0: label = "↑  Up"
		var button := _button(label, id, {"direction": direction})
		button.disabled = not enabled
		parent.add_child(button)

## The story is a timed sequence of portraits, emotes and props: no premise captions.
func show_story(data: Dictionary = {}) -> void:
	var col := _begin("story", data, true)
	hide_countdown()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(CREAM, 28, INK, 2))
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(panel)
	var theatre := StoryStage.instantiate()
	theatre.custom_minimum_size.y = 260
	panel.add_child(theatre)
	var skip := _button("→", &"noop", {}, true, 56)
	skip.tooltip_text = "Continue"
	skip.pressed.disconnect(skip.pressed.get_connections()[0].callable)
	skip.pressed.connect(func() -> void: _finish_story(data))
	skip.visible = bool(data.get("skippable", str(data.get("phase", "post")) != "pre"))
	col.add_child(skip)
	_finish()
	_play_story(theatre, data, _story_generation)

func _play_story(theatre: Control, data: Dictionary, generation: int) -> void:
	var beats: Array = data.get("beats", [])
	var motion: Variant = _prefs.get("reduced_motion", "system")
	var reduced: bool = motion if motion is bool else str(motion) == "on"
	for index in beats.size():
		if generation != _story_generation or not is_instance_valid(theatre): return
		var beat: Dictionary = beats[index].duplicate(true)
		if index == beats.size()-1 and data.has("guests") and not beat.has("guests"): beat.guests = data.guests
		theatre.set_beat(beat, index, beats.size(), reduced)
		await get_tree().create_timer(clampf(float(beat.get("duration", 1.0)), .15, 8.0)).timeout
		if generation != _story_generation: return
	_finish_story(data)

func _finish_story(data: Dictionary) -> void:
	if current_screen != "story": return
	_story_generation += 1
	current_screen = "story_done"
	intent.emit(&"story_done", {"story_key": str(data.get("story_key", "")), "phase": str(data.get("phase", "post"))})

func show_pause(data: Dictionary = {}) -> void:
	var col := _begin("pause", data, true)
	_header(col, "A little breather", str(data.get("level_name", "Everything waits for you.")))
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(center)
	var card := _card(center)
	card.custom_minimum_size.x = 300 if _portrait else 400
	card.add_child(_label("Ⅱ", 64, INK, true))
	card.add_child(_button("Keep building  →", &"resume", {}, true, 64))
	var retry := _button("Restart…", &"noop")
	retry.pressed.disconnect(retry.pressed.get_connections()[0].callable)
	retry.pressed.connect(func() -> void: _confirm("Start over?", "This run's progress will be lost.", &"retry"))
	card.add_child(retry)
	card.add_child(_button("Settings", &"open_settings"))
	var map := _button("Leave level…", &"noop")
	map.pressed.disconnect(map.pressed.get_connections()[0].callable)
	map.pressed.connect(func() -> void: _confirm("Back to the islands?", "This run's progress will be lost.", &"to_map"))
	card.add_child(map)
	_finish()

func show_results(data: Dictionary = {}) -> void:
	var col := _begin("results", data, true)
	_header(col, "Beautifully built!" if bool(data.get("won", false)) else "One more little try?", str(data.get("level_name", "Meadow adventure")))
	var content := _scroll(col)
	var card := _card(content, MINT if bool(data.get("won", false)) else CREAM)
	card.add_child(_label(Format.stars(int(data.get("stars", 0))), 64, INK, true))
	card.add_child(_label(str(data.get("message", "Every tower teaches you something.")), 22, INK, true))
	var row := _hbox(card)
	row.add_child(_label("SCORE\n%d" % int(data.get("score", 0)), 24, INK, true))
	row.add_child(_label("TIME\n" + _time_text(data.get("time", 0)), 24, INK, true))
	for player in data.get("standings", []):
		card.add_child(_label("%s   ·   %s wins" % [str(player.get("name", "Player")), str(player.get("wins", 0))], 20))
	if bool(data.get("next_available", false)): card.add_child(_button("Next adventure  →", &"next", {}, true, 64))
	else: card.add_child(_button("Try again  ↻", &"retry", {}, true, 64))
	if bool(data.get("next_available", false)): card.add_child(_button("Play again", &"retry"))
	card.add_child(_button("Island map", &"to_map"))
	_finish()

func _confirm(title: String, detail: String, id: StringName, args: Dictionary = {}) -> void:
	var previous := current_screen
	var previous_data := _snapshot.duplicate(true)
	var overlay := _is_overlay
	var col := _begin("confirm", {"return_screen": previous, "return_data": previous_data}, overlay)
	_header(col, title, "", false)
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(center)
	var card := _card(center)
	card.custom_minimum_size.x = 280 if _portrait else 420
	card.add_child(_label(detail, 20, MUTED, true))
	var cancel := _button("Keep it  ✕", &"noop", {}, true)
	cancel.pressed.disconnect(cancel.pressed.get_connections()[0].callable)
	cancel.pressed.connect(func() -> void: _restore_screen(previous, previous_data))
	card.add_child(cancel)
	card.add_child(_button("Yes, continue  ✓", id, args))
	_finish()

func clear_overlay() -> void:
	if is_instance_valid(_menu):
		_root.remove_child(_menu)
		_menu.queue_free()
	_menu = null
	if is_instance_valid(_hud): _hud.show()
	current_screen = "hud"

func show_toast(message: String) -> void:
	_toast_generation += 1
	var generation := _toast_generation
	if is_instance_valid(_toast):
		_root.remove_child(_toast)
		_toast.queue_free()
	_toast = PanelContainer.new()
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.add_theme_stylebox_override("panel", _style(INK, 14))
	_root.add_child(_toast)
	_toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_toast.offset_left = -240
	_toast.offset_right = 240
	_toast.offset_top = -84
	_toast.offset_bottom = -26
	var text := _label(message, 18, CREAM, true)
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast.add_child(text)
	await get_tree().create_timer(3.5).timeout
	if generation == _toast_generation and is_instance_valid(_toast): _toast.hide()

func show_settings(data: Dictionary = {}) -> void:
	_prefs = data.get("prefs", {}).duplicate(true)
	for key in ["music_volume", "sfx_volume", "ui_volume", "button_scale", "text_scale"]:
		if _prefs.has(key) and float(_prefs[key]) <= 3.0: _prefs[key] = float(_prefs[key]) * 100.0
	if _prefs.get("reduced_motion") is bool: _prefs.reduced_motion = "on" if _prefs.reduced_motion else "off"
	var col := _begin("settings", data, bool(data.get("in_play", false)))
	_header(col, "Make yourself at home", "Changes save as you go.")
	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(tabs)
	var sound := _settings_page(tabs, "Sound")
	_slider_setting(sound, "Music", "music_volume", 80, 0, 100, 10, "%")
	_slider_setting(sound, "Sound effects", "sfx_volume", 80, 0, 100, 10, "%")
	_slider_setting(sound, "UI clicks", "ui_volume", 70, 0, 100, 10, "%")
	_choice_setting(sound, "Haptics", "haptics", ["Off", "Light", "Strong"], ["off", "light", "strong"], "light")
	var screen := _settings_page(tabs, "Screen")
	_choice_setting(screen, "Window", "window_mode", ["Windowed", "Fullscreen"], ["windowed", "fullscreen"], "windowed")
	_toggle_setting(screen, "V-sync", "vsync", true)
	_choice_setting(screen, "Frame cap", "frame_cap", ["Uncapped", "30", "60", "120", "144"], [0, 30, 60, 120, 144], 60)
	var controls := _settings_page(tabs, "Controls")
	_toggle_setting(controls, "Left-hand mirror", "left_hand", false)
	_slider_setting(controls, "Button size", "button_scale", 100, 75, 200, 25, "%")
	controls.add_child(_label("Keyboard · choose an action, then press its new key.", 16, MUTED))
	for binding in [{"id": "move_left", "name": "Move left", "key": "A"}, {"id": "move_right", "name": "Move right", "key": "D"}, {"id": "move_up", "name": "Move away", "key": "W"}, {"id": "move_down", "name": "Move closer", "key": "S"}, {"id": "rot_spin_left", "name": "Turn left", "key": "Q"}, {"id": "rot_spin_right", "name": "Turn right", "key": "E"}, {"id": "rot_tilt_left", "name": "Flip left", "key": "R"}, {"id": "rot_tilt_right", "name": "Flip right", "key": "F"}, {"id": "rot_roll_left", "name": "Roll left", "key": "T"}, {"id": "rot_roll_right", "name": "Roll right", "key": "G"}, {"id": "hard_drop", "name": "Drop", "key": "Space"}, {"id": "soft_drop", "name": "Soft drop", "key": "Shift"}, {"id": "hold", "name": "Hold", "key": "H"}, {"id": "skill", "name": "Character skill", "key": "X"}, {"id": "item", "name": "Potion", "key": "V"}, {"id": "view_l", "name": "View left", "key": "Z"}, {"id": "view_r", "name": "View right", "key": "C"}, {"id": "pause", "name": "Pause", "key": "Escape"}]:
		var action := str(binding.id)
		var row := _hbox(controls)
		row.add_child(_label(str(binding.name), 18))
		var button := _button(str(_prefs.get("key_" + action, binding.key)), &"noop")
		button.pressed.disconnect(button.pressed.get_connections()[0].callable)
		button.pressed.connect(func() -> void:
			_remap_action = action
			button.text = "Press a key…"
			button.release_focus()
		)
		row.add_child(button)
	var camera := _settings_page(tabs, "Camera")
	_toggle_setting(camera, "Invert view", "invert_view", false)
	_toggle_setting(camera, "Animated turn", "turn_animation", true)
	_choice_setting(camera, "Occlusion help", "occlusion", ["Level default", "Fade", "Cutaway"], ["default", "fade", "cutaway"], "default")
	var access := _settings_page(tabs, "Access")
	_choice_setting(access, "Text size", "text_scale", ["100%", "125%", "150%"], [100, 125, 150], 100)
	_choice_setting(access, "Colourblind aid", "colorblind", ["Off", "Shapes", "Shapes + contrast"], ["off", "shapes", "high_contrast"], "shapes")
	_choice_setting(access, "Reduced motion", "reduced_motion", ["Follow system", "Off", "On"], ["system", "off", "on"], "system")
	_toggle_setting(access, "Relaxed timing", "relaxed_timing", false)
	_toggle_setting(access, "Button labels", "button_labels", true)
	_toggle_setting(access, "Show clock", "show_clock", true)
	var info := _settings_page(tabs, "Info")
	info.add_child(_label("Wacky Towers", 32))
	info.add_child(_label("A cosy 3D puzzle game by Tessa and collaborators.\nBuilt with the open-source Godot Engine.", 20, MUTED))
	info.add_child(_label("Local profiles stay on this device. No account is required.\nLAN play connects directly to another device on your network.", 18, MUTED))
	info.add_child(_label("Version " + str(data.get("version", "0.1.0")), 16, MUTED))
	for credit in data.get("credits", []): info.add_child(_label(str(credit), 16, MUTED))
	tabs.current_tab = clampi(_settings_tab, 0, tabs.get_tab_count() - 1)
	tabs.tab_changed.connect(func(index: int) -> void: _settings_tab = index)
	col.add_child(_button("All done  ✓", &"back", {}, true, 56))
	_finish()

func _settings_page(parent: TabContainer, title: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.custom_minimum_size.y = 120
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 18)
	scroll.add_child(margin)
	return _vbox(margin, 18)

func _toggle_setting(parent: Node, title: String, key: String, fallback: bool) -> void:
	var toggle := CheckButton.new()
	toggle.text = title
	toggle.custom_minimum_size.y = 56
	toggle.button_pressed = bool(_prefs.get(key, fallback))
	toggle.toggled.connect(func(value: bool) -> void:
		_prefs[key] = value
		intent.emit(&"set_pref", {"key": key, "value": value})
	)
	parent.add_child(toggle)

func _choice_setting(parent: Node, title: String, key: String, labels: Array, values: Array, fallback: Variant) -> void:
	var row := _hbox(parent)
	row.add_child(_label(title, 18))
	var option := OptionButton.new()
	option.custom_minimum_size = Vector2(180 if not _portrait else 130, 52)
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for label in labels: option.add_item(str(label))
	var index := values.find(_prefs.get(key, fallback))
	option.select(maxi(index, 0))
	option.item_selected.connect(func(i: int) -> void:
		_prefs[key] = values[i]
		intent.emit(&"set_pref", {"key": key, "value": values[i]})
	)
	row.add_child(option)

func _slider_setting(parent: Node, title: String, key: String, fallback: float, low: float, high: float, step: float, suffix: String) -> void:
	var col := _vbox(parent, 4)
	var value := _label("%s   %d%s" % [title, int(float(_prefs.get(key, fallback))), suffix], 18)
	col.add_child(value)
	var slider := HSlider.new()
	slider.custom_minimum_size.y = 48
	slider.min_value = low
	slider.max_value = high
	slider.step = step
	slider.value = float(_prefs.get(key, fallback))
	slider.value_changed.connect(func(v: float) -> void:
		value.text = "%s   %d%s" % [title, int(v), suffix]
		_prefs[key] = v
		intent.emit(&"set_pref", {"key": key, "value": v})
	)
	col.add_child(slider)

func show_shop(data: Dictionary = {}) -> void:
	var col := _begin("shop", data)
	_header(col, "The little toy shop", "Your earned island stars always stay yours.")
	col.add_child(_label("STAR JAR   ★  %d" % int(data.get("wallet", 0)), 28, INK, true))
	var content := _scroll(col)
	var items: Array = data.get("items", [])
	if items.is_empty(): content.add_child(_label("Finish Meadow 03 to open the toy shop.", 22, MUTED, true))
	for item in items:
		var card := _card(content)
		card.add_child(_label(str(item.get("name", "Little surprise")), 24))
		card.add_child(_label(str(item.get("description", "")), 18, MUTED))
		var price := int(item.get("price", 0))
		var owned := bool(item.get("owned", false))
		var locked := bool(item.get("locked", false))
		var kind := str(item.get("kind", ""))
		if item.has("count"): card.add_child(_label("In your bag: %d" % int(item.count), 16, MUTED))
		var label := "Owned ✓" if owned else ("Locked" if locked else "Buy  ·  ★ %d" % price)
		var buy := _button(label, &"noop", {}, not owned and not locked)
		buy.pressed.disconnect(buy.pressed.get_connections()[0].callable)
		buy.disabled = owned or locked or price > int(data.get("wallet", 0))
		if not owned and not locked and buy.disabled: buy.text = "Need %d more ★" % (price - int(data.get("wallet", 0)))
		buy.pressed.connect(func() -> void: _confirm("Take " + str(item.get("name", "this toy")) + " home?", "★ %d   →   Jar after: %d" % [price, int(data.get("wallet", 0)) - price], &"buy_item", {"item_id": str(item.get("id", ""))}))
		card.add_child(buy)
		if owned and kind == "perk":
			var equipped := bool(item.get("equipped", false))
			card.add_child(_button("Unequip ✓" if equipped else "Equip", &"toggle_perk", {"item_id": str(item.get("id", ""))}, not equipped))
		elif kind == "potion" and int(item.get("count", 0)) > 0:
			var selected := bool(item.get("selected", false))
			card.add_child(_button("Selected ✓" if selected else "Bring this potion", &"select_potion", {"item_id": str(item.get("id", ""))}, not selected))
	var characters: Array = data.get("characters", [])
	if not characters.is_empty():
		content.add_child(_label("Your friends", 26))
		for character in characters:
			var b := _button(str(character.get("name", "Cloud wizard")) + (" ✓" if bool(character.get("selected", false)) else ""), &"select_character", {"character_id": str(character.get("id", "c1"))})
			b.disabled = not bool(character.get("unlocked", true))
			content.add_child(b)
	if bool(data.get("can_undo", false)): content.add_child(_button("Undo last purchase", &"undo_purchase"))
	_finish()

func show_arcade(data: Dictionary = {}) -> void:
	var col := _begin("arcade", data)
	_header(col, "A tower without end", "Clear layers. Chase your best. See how far you grow.")
	var content := _scroll(col)
	var card := _card(content)
	card.add_child(_label("ARCADE", 46, INK, true))
	card.add_child(_label("PERSONAL BEST\n%d" % int(data.get("best", 0)), 28, MUTED, true))
	var skins: Array = data.get("skins", ["meadow"])
	var picker := OptionButton.new()
	picker.custom_minimum_size.y = 56
	for skin in skins: picker.add_item(str(skin).replace("_", " ").capitalize())
	card.add_child(_label("Pick a toy box", 20))
	card.add_child(picker)
	card.add_child(_label("The pace rises with every layer.\nNew surprises arrive as your tower grows.", 18, MUTED, true))
	var start := _button("Let's go  →", &"noop", {}, true, 64)
	start.pressed.disconnect(start.pressed.get_connections()[0].callable)
	start.pressed.connect(func() -> void: intent.emit(&"start_arcade", {"skin": str(skins[picker.selected])}))
	card.add_child(start)
	_finish()

func show_tournament(data: Dictionary = {}) -> void:
	var col := _begin("tournament", data)
	_header(col, "A little friendly rivalry", "One device per player · same local network.")
	var content := _scroll(col)
	var network := _card(content)
	network.add_child(_label("PLAY WITH FRIENDS", 24))
	var status := str(data.get("network_status", "offline"))
	var character_picker := OptionButton.new()
	character_picker.custom_minimum_size.y = 56
	var character_ids: Array[String] = ["c1", "c2", "c3", "c4"]
	var character_names: Array[String] = ["Cloud Wizard", "Lana", "Boulder", "Glim"]
	for character_name: String in character_names: character_picker.add_item(character_name)
	character_picker.select(maxi(0, character_ids.find(str(data.get("character", _prefs.get("character", "c1"))))))
	if status != "offline":
		network.add_child(character_picker)
		character_picker.hide()
		network.add_child(_label(status.capitalize(), 20, MUTED))
		if bool(data.get("host", false)): network.add_child(_label("Friends join at " + str(data.get("address", "your local IP")), 18))
		for player in data.get("network_players", []):
			var char_index := character_ids.find(str(player.get("character", "c1")))
			var perk_count := (player.get("perks", []) as Array).size()
			var description := str(player.get("name", "Friend")) + "  ·  " + character_names[maxi(0, char_index)]
			if perk_count > 0: description += "  ·  %d perk%s" % [perk_count, "" if perk_count == 1 else "s"]
			network.add_child(_label(description, 20))
		if bool(data.get("host", false)):
			var start := _button("Everybody ready  →", &"start_lan", {}, true, 60)
			start.disabled = data.get("network_players", []).size() < 2
			network.add_child(start)
		network.add_child(_button("Leave lobby", &"leave_lan"))
	else:
		network.add_child(_label("Your party character", 18))
		network.add_child(character_picker)
		network.add_child(_label("All four friends are available for party play. Owned perks match your chosen character.", 16, MUTED))
		var name := LineEdit.new()
		name.text = str(data.get("profile_name", "Clover"))
		name.max_length = 12
		name.placeholder_text = "Your name"
		name.custom_minimum_size.y = 52
		network.add_child(name)
		var address := LineEdit.new()
		address.placeholder_text = "Host IP, e.g. 192.168.1.20"
		address.custom_minimum_size.y = 52
		network.add_child(address)
		var port := SpinBox.new()
		port.min_value = 1024
		port.max_value = 65535
		port.value = 24680
		port.custom_minimum_size.y = 52
		network.add_child(_label("Port", 16, MUTED))
		network.add_child(port)
		var rounds := OptionButton.new()
		rounds.custom_minimum_size.y = 52
		for n in [3, 5, 7, 13]: rounds.add_item("%d rounds" % n, n)
		network.add_child(rounds)
		var row := _hbox(network)
		var host := _button("Host party", &"noop", {}, true, 56)
		host.pressed.disconnect(host.pressed.get_connections()[0].callable)
		host.pressed.connect(func() -> void: intent.emit(&"host_lan", {"name": name.text.strip_edges(), "port": int(port.value), "rounds": rounds.get_selected_id(), "character":character_ids[character_picker.selected]}))
		row.add_child(host)
		var join := _button("Join party", &"noop", {}, false, 56)
		join.pressed.disconnect(join.pressed.get_connections()[0].callable)
		join.pressed.connect(func() -> void:
			if address.text.strip_edges().is_empty():
				show_toast("Enter your friend's host IP first.")
				address.grab_focus()
				return
			intent.emit(&"join_lan", {"name": name.text.strip_edges(), "address": address.text.strip_edges(), "port": int(port.value), "character":character_ids[character_picker.selected]})
		)
		row.add_child(join)
	if status == "offline":
		var practice := _card(content)
		practice.add_child(_label("PRACTISE WITH TOY FRIENDS", 22))
		practice.add_child(_label("Solo practice against deterministic computer players.", 16, MUTED))
		var count := OptionButton.new()
		count.custom_minimum_size.y = 52
		for n in [2, 3, 4]: count.add_item("%d players · you + %d toy friends" % [n, n - 1], n)
		practice.add_child(count)
		var rounds := OptionButton.new()
		rounds.custom_minimum_size.y = 52
		for n in [3, 5, 7, 13]: rounds.add_item("%d rounds" % n, n)
		practice.add_child(rounds)
		var items := CheckButton.new()
		items.text = "Party items"
		items.button_pressed = bool(data.get("items_supported", false))
		items.visible = bool(data.get("items_supported", false))
		items.custom_minimum_size.y = 52
		practice.add_child(items)
		var mode_list: Array = data.get("modes", ["clear_race", "survive", "score_attack"])
		var toggles: Array[CheckButton] = []
		for mode in mode_list:
			var toggle := CheckButton.new()
			toggle.text = str(mode).replace("_", " ").capitalize()
			toggle.button_pressed = true
			toggle.custom_minimum_size.y = 48
			practice.add_child(toggle)
			toggles.append(toggle)
		var start := _button("Start practice  →", &"noop", {}, false, 60)
		start.pressed.disconnect(start.pressed.get_connections()[0].callable)
		start.pressed.connect(func() -> void:
			var modes: Array = []
			for i in toggles.size():
				if toggles[i].button_pressed: modes.append(mode_list[i])
			if modes.is_empty():
				show_toast("Pick at least one party mode.")
				return
			var players: Array = [{"name": str(data.get("profile_name", "You")), "is_bot": false, "character_id": character_ids[character_picker.selected]}]
			for i in range(1, count.get_selected_id()): players.append({"name": ["Pip", "Miller", "Clover"][i - 1], "is_bot": true, "character_id": "c%d" % (i + 1)})
			intent.emit(&"start_tournament", {"rounds": rounds.get_selected_id(), "players": players, "items": items.button_pressed, "modes": modes})
		)
		practice.add_child(start)
	_finish()

func show_physics(data: Dictionary = {}) -> void:
	var col := _begin("physics", data)
	_header(col, "The physics toy box", "Weight, wobble and a little bit of mischief.")
	var content := _scroll(col)
	var card := _card(content)
	var variants: Array = data.get("variants", PHYSICS_VARIANTS)
	card.add_child(_label("PICK A CHALLENGE", 26))
	var picker := OptionButton.new()
	picker.custom_minimum_size.y = 60
	var selected: int = 0
	for index: int in variants.size():
		picker.add_item(str(variants[index].get("name", "Toy challenge")))
		if str(variants[index].id) == str(data.get("selected_variant", "tower_race")): selected = index
	picker.select(selected)
	card.add_child(picker)
	var description := _label(str(variants[selected].get("description", "")) if not variants.is_empty() else "No challenges are available.", 24, INK, true)
	card.add_child(description)
	card.add_child(_label("Move and turn a toy before letting it go. Watch it settle, then place the next one.", 18, MUTED, true))
	picker.item_selected.connect(func(index: int) -> void:
		description.text = str(variants[index].get("description", ""))
		_snapshot["selected_variant"] = str(variants[index].id)
	)
	var start := _button("Open the toy box  →", &"noop", {}, true, 64)
	start.pressed.disconnect(start.pressed.get_connections()[0].callable)
	start.disabled = variants.is_empty()
	start.pressed.connect(func() -> void: intent.emit(&"start_physics", {"variant":str(variants[picker.selected].id)}))
	card.add_child(start)
	_finish()

func _restore_screen(screen: String, data: Dictionary) -> void:
	match screen:
		"title": show_title(data)
		"profiles": show_profiles(data)
		"map": show_map(data)
		"intro": show_intro(data)
		"pause": show_pause(data)
		"results": show_results(data)
		"settings": show_settings(data)
		"shop": show_shop(data)
		"arcade": show_arcade(data)
		"tournament": show_tournament(data)
		"physics": show_physics(data)
		"tools": show_tools(data)
		"story": show_story(data)
		"confirm": _restore_screen(str(data.get("return_screen", "title")), data.get("return_data", {}))
		_: intent.emit(&"back", {})

func _on_resize() -> void:
	var portrait := get_viewport().get_visible_rect().size.x < get_viewport().get_visible_rect().size.y
	if portrait == _portrait: return
	_portrait = portrait
	_fit_controls()
	if current_screen == "hud":
		_build_hud()
		update_hud(_hud_data)
		intent.emit(&"orientation_changed", {"portrait": _portrait})
	elif current_screen != "profile_form": _restore_screen(current_screen, _snapshot)

func _input(event: InputEvent) -> void:
	if _remap_action.is_empty(): return
	if event is InputEventKey and event.pressed and not event.echo:
		var action := _remap_action
		_remap_action = ""
		if event.keycode != KEY_ESCAPE:
			var key_name := OS.get_keycode_string(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
			_prefs["key_" + action] = key_name
			intent.emit(&"set_pref", {"key": "key_" + action, "value": key_name})
			show_toast("%s → %s" % [action.replace("_", " ").capitalize(), key_name])
		_snapshot["prefs"] = _prefs.duplicate(true)
		show_settings(_snapshot)
		get_viewport().set_input_as_handled()
