class_name GameUi
extends CanvasLayer
## Snapshot-only UI. The controller owns profiles, progression and the simulation.
## Adapted from MB-027/028/034 contracts; prototype/staged scenes remain intact.

signal intent(id: StringName, args: Dictionary)

const Glyph := preload("res://src/ui/common/ui_glyph.gd")
const Format := preload("res://src/ui/common/ui_format.gd")
const MinigameStage := preload("res://src/ui/minigame_ui.tscn")
const Kit := preload("res://src/ui/common/wt_storybook.gd")
const CREAM := Kit.TEXT
## Lettering on the scene, plum glass and wood: cream with a plum outline; soft for secondary.
const TEXT := Kit.TEXT
const TEXT_SOFT := Kit.TEXT_SOFT
const INK := Kit.PLUM
const MUTED := Kit.PLUM_SOFT
const ORANGE := Kit.GOLD
const MINT := Kit.MINT
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
var _minigame_view: Control
var _round_widgets: Dictionary = {}

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
	# One palette (Kit.apply_palette: "Palette" colours + PlumPanel / PlankRow / HudChip
	# variations). No parchment anywhere: text sits on the painted scene, plum glass, wood or
	# purple pills, so default lettering is cream with a plum outline; gold pills re-ink plum.
	var t := Theme.new()
	Kit.apply_palette(t)
	t.default_font = Kit.font()
	t.default_font_size = roundi(18 * _text_factor)
	var soft_disabled := Color(TEXT_SOFT, 0.7)
	for type_name in ["Label", "Button", "OptionButton", "CheckButton", "LineEdit"]:
		t.set_color("font_outline_color", type_name, Kit.TEXT_OUTLINE)
		t.set_constant("outline_size", type_name, 0 if type_name == "LineEdit" else 4)
	t.set_color("font_color", "Label", TEXT)
	for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		for type_name in ["Button", "OptionButton", "CheckButton"]: t.set_color(key, type_name, TEXT)
	for type_name in ["Button", "OptionButton", "CheckButton"]: t.set_color("font_disabled_color", type_name, soft_disabled)
	t.set_color("font_color", "LineEdit", TEXT)
	t.set_color("font_placeholder_color", "LineEdit", Color(TEXT_SOFT, 0.75))
	t.set_color("caret_color", "LineEdit", Kit.GOLD)
	for type_name in ["TabBar", "TabContainer", "SpinBox"]:
		t.set_color("font_color", type_name, TEXT)
		t.set_color("font_selected_color", type_name, INK)
		t.set_color("font_unselected_color", type_name, TEXT)
		t.set_color("font_hovered_color", type_name, TEXT)
		t.set_color("font_disabled_color", type_name, soft_disabled)
		t.set_color("font_outline_color", type_name, Kit.TEXT_OUTLINE)
		t.set_constant("outline_size", type_name, 0)
	for type_name in ["TabBar", "TabContainer", "OptionButton", "CheckButton", "SpinBox"]:
		t.set_font_size("font_size", type_name, roundi(18 * _text_factor))
	for state in ["tab_selected", "tab_unselected", "tab_hovered", "tab_disabled", "tab_focus"]:
		# Tabs: gold kit pill for the open page, flat purple pills for the rest.
		var tab: StyleBox
		if state == "tab_focus": tab = StyleBoxEmpty.new()
		elif state == "tab_selected":
			tab = _kit("btn_gold", 0.85)
			if tab == null: tab = Kit.pill(Kit.GOLD, Kit.GOLD_DEEP, false, 22)
		else:
			tab = Kit.pill(Kit.WOOD_PURPLE.lightened(0.1) if state == "tab_hovered" else Kit.WOOD_PURPLE, Kit.WOOD_PURPLE_DARK, false, 22)
			if state == "tab_disabled": (tab as StyleBoxFlat).bg_color = Kit.PLUM_SOFT
		_pad(tab, 18, 8, 18, 13)
		t.set_stylebox(state, "TabBar", tab)
		t.set_stylebox(state, "TabContainer", tab)
	t.set_stylebox("panel", "TabContainer", _pad(Kit.glass_box(), 10, 12, 10, 14))
	t.set_stylebox("tabbar_background", "TabContainer", StyleBoxEmpty.new())
	# Settings controls (refs 08, 04): wooden track with a gold star thumb; star-knob toggles.
	var track: StyleBox = _kit("slider_track", 0.8)
	if track == null: track = Kit.plank_box(8)
	t.set_stylebox("slider", "HSlider", _pad(track, 0, 14, 0, 14))
	for part in ["grabber_area", "grabber_area_highlight"]:
		# Sky-blue fill inside the wooden track (ref 04 music bar), slimmer than the track.
		var fill := Kit.pill(Color("4aa8e8"), Color("2a6fb0"), false, 8)
		fill.shadow_size = 0
		fill.set_border_width_all(1)
		fill.border_width_bottom = 2
		t.set_stylebox(part, "HSlider", _pad(fill, 0, 9, 0, 9))
	var thumb := _kit_icon("slider_star_thumb", 0.8 * clampf(_control_factor, 1.0, 1.4))
	if thumb != null:
		for icon_name in ["grabber", "grabber_highlight", "grabber_disabled"]: t.set_icon(icon_name, "HSlider", thumb)
	var toggle_scale := 0.75 * clampf(_control_factor, 1.0, 1.4)
	var on := _kit_icon("toggle_on", toggle_scale)
	var off := _toggle_off_icon(toggle_scale)
	if on != null and off != null:
		for suffix in ["", "_mirrored"]:
			t.set_icon("checked" + suffix, "CheckButton", on)
			t.set_icon("unchecked" + suffix, "CheckButton", off)
			t.set_icon("checked_disabled" + suffix, "CheckButton", on)
			t.set_icon("unchecked_disabled" + suffix, "CheckButton", off)
		for state in ["normal", "hover", "pressed", "disabled", "hover_pressed"]:
			t.set_stylebox(state, "CheckButton", _pad(StyleBoxEmpty.new(), 6, 4, 6, 4))
	# Gold ring outside the control for keyboard / gamepad focus (never invisible).
	var ring := Kit.pill(Color(0, 0, 0, 0), Kit.GOLD, false, 24)
	ring.draw_center = false
	ring.set_border_width_all(3)
	ring.shadow_size = 0
	ring.set_expand_margin_all(3)
	for type_name in ["Button", "OptionButton", "CheckButton"]: t.set_stylebox("focus", type_name, ring)
	t.set_stylebox("panel", "PopupMenu", _pad(Kit.glass_box(0.97, 14), 12, 12, 12, 12))
	t.set_stylebox("hover", "PopupMenu", _style(Kit.GOLD, 10))
	for key in ["font_color", "font_accelerator_color"]: t.set_color(key, "PopupMenu", TEXT)
	t.set_color("font_hover_color", "PopupMenu", INK)
	t.set_color("font_disabled_color", "PopupMenu", Color(TEXT_SOFT, 0.5))
	t.set_font_size("font_size", "PopupMenu", roundi(18 * _text_factor))
	# Secondary buttons and pickers: purple-wood pills (btn_cream is retired).
	for state in ["normal", "hover", "pressed", "disabled"]:
		for type_name in ["Button", "OptionButton"]:
			var face := _purple_pill(state)
			if type_name == "OptionButton": face.content_margin_right = 40
			t.set_stylebox(state, type_name, face)
	t.set_stylebox("panel", "PanelContainer", _pad(Kit.glass_box(), 14, 12, 14, 16))
	var field := _style(Color(Kit.WOOD_PURPLE_DARK.darkened(0.35), 0.92), 12, Kit.WOOD_PURPLE_LIGHT, 2)
	_pad(field, 14, 8, 14, 8)
	t.set_stylebox("normal", "LineEdit", field)
	var field_focus := field.duplicate() as StyleBoxFlat
	field_focus.border_color = Kit.GOLD
	field_focus.set_border_width_all(3)
	t.set_stylebox("focus", "LineEdit", field_focus)
	t.set_stylebox("background", "ProgressBar", _style(Color(Kit.WOOD_PURPLE_DARK, 0.85), 7))
	t.set_stylebox("fill", "ProgressBar", _style(ORANGE, 7))
	# Scrollbars: gold grabber on a dark wood rail (no default grey bar).
	var rail := _style(Color(Kit.PLANK, 0.75), 6)
	rail.content_margin_left = 4
	rail.content_margin_right = 4
	t.set_stylebox("scroll", "VScrollBar", rail)
	for part in ["grabber", "grabber_highlight", "grabber_pressed"]:
		t.set_stylebox(part, "VScrollBar", _style(Kit.GOLD if part == "grabber" else Kit.GOLD_GLINT, 6, Kit.GOLD_DEEP, 1))
	t.set_constant("separation", "VBoxContainer", 12)
	t.set_constant("separation", "HBoxContainer", 12)
	t.set_constant("h_separation", "HFlowContainer", 12)
	t.set_constant("v_separation", "HFlowContainer", 12)
	return t

func _style(color: Color, radius: int = 12, border: Color = Color.TRANSPARENT, width: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	# Storybook frames: ink outlines become painted wood with a heavier bottom edge.
	s.border_color = Kit.WOOD if border == INK else border
	s.set_border_width_all(width + (1 if border == INK else 0))
	if border == INK and width > 0:
		s.border_width_bottom = width + 3
	s.anti_aliasing = true
	return s

## Alpha below this (0-255) is render haze in the Blender kit PNGs, not art. See _clean_texture.
const KIT_ALPHA_FLOOR := 24.0
## Outer pixels faded to zero so a shadow cut by the canvas edge never draws a hard line.
const KIT_EDGE_FADE := 3
## Screens drawn inside the purple-wood frame with a plaque title (refs 05, 06, 04, 08).
## Narrowest menu pill; wider labels grow the pill, nothing stretches it across the screen.
const MENU_BUTTON_MIN_WIDTH := 220.0
const UNFRAMED_SCREENS: Array[String] = ["minigame"]
static var _kit_cache: Dictionary = {}

## Kit PNGs as Blender renders them never reach alpha 0: a soft shadow haze (alpha 1-22,
## near-black) fills the whole canvas, edge pixels included. Stretched as a nine-patch, that
## haze became a hard-edged grey box the size of every button (the "pale rectangle" behind
## PLAY and Pause on the lavender sky). This remaps alpha so the haze is 0, fades the outer
## KIT_EDGE_FADE pixels, and optionally rescales. Cached per texture and scale.
static func _clean_texture(texture: Texture2D, scale: float = 1.0) -> Texture2D:
	if texture == null: return null
	var key := "%s@%.3f" % [texture.resource_path, scale]
	if _kit_cache.has(key): return _kit_cache[key]
	var image: Image = texture.get_image()
	if image == null:
		_kit_cache[key] = texture
		return texture
	image = image.duplicate() as Image
	if image.is_compressed(): image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	if not is_equal_approx(scale, 1.0):
		image.resize(maxi(1, roundi(image.get_width() * scale)), maxi(1, roundi(image.get_height() * scale)), Image.INTERPOLATE_LANCZOS)
	var w := image.get_width()
	var h := image.get_height()
	var data := image.get_data()
	var gain := 255.0 / (255.0 - KIT_ALPHA_FLOOR)
	for y: int in h:
		var edge_y := mini(y, h - 1 - y)
		for x: int in w:
			var i := (y * w + x) * 4 + 3
			var a := clampf((float(data[i]) - KIT_ALPHA_FLOOR) * gain, 0.0, 255.0)
			var edge := mini(edge_y, mini(x, w - 1 - x))
			if edge < KIT_EDGE_FADE: a *= float(edge) / KIT_EDGE_FADE
			data[i] = roundi(a)
	var cleaned := ImageTexture.create_from_image(Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, data))
	_kit_cache[key] = cleaned
	return cleaned

## A kit nine-patch (btn_gold, frame_purple_open, sign_heading...) with cleaned alpha, scaled by `scale`.
## Content margins default to the texture margins; callers trim them with _pad().
func _kit(name: String, scale: float = 1.0) -> StyleBoxTexture:
	var box: StyleBoxTexture = Kit.kit_box(name, 0.0)
	if box == null: return null
	box.texture = _clean_texture(box.texture, scale)
	for side: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		var margin := roundf(box.get_texture_margin(side) * scale)
		box.set_texture_margin(side, margin)
		box.set_content_margin(side, margin)
	return box

## Sets content margins (left, top, right, bottom) on a stylebox and returns it.
func _pad(box: StyleBox, left: float, top: float, right: float, bottom: float) -> StyleBox:
	if box == null: return null
	box.content_margin_left = left
	box.content_margin_top = top
	box.content_margin_right = right
	box.content_margin_bottom = bottom
	return box

## Cleaned kit texture (btn_close, toggle_on, slider_star_thumb...) scaled to `scale`.
func _kit_icon(name: String, scale: float = 1.0) -> Texture2D:
	return _clean_texture(Kit.kit_texture(name), scale)

## Gold (btn_gold), purple (btn_purple) or wood plank (sign_heading) button
## states from the cleaned kit. Falls back to WtStorybook's flat pills if the kit is missing.
func _kit_button(button: Button, kit_name: String = "btn_purple") -> void:
	var gold := kit_name == "btn_gold"
	var wood := kit_name == "sign_heading"
	var normal: StyleBox = _kit(kit_name) if gold or wood else null
	if gold and normal == null:
		Kit.style_button(button, true, 26)
		return
	var states := {}
	if normal is StyleBoxTexture:
		_pad(normal, 24, 8, 24, 14)
		states.normal = normal
		for entry: Array in [["hover", Color(1.08, 1.08, 1.08)], ["pressed", Color(0.88, 0.85, 0.82)], ["disabled", Color(0.7, 0.66, 0.72, 0.85)]]:
			var box := normal.duplicate() as StyleBoxTexture
			box.modulate_color = entry[1]
			if entry[0] == "pressed":
				box.content_margin_top += 3.0
				box.content_margin_bottom -= 3.0
			states[entry[0]] = box
	elif wood:
		for state: String in ["normal", "hover", "pressed", "disabled"]: states[state] = Kit.plank_box(14)
	else:
		# btn_purple (default secondary) and the retired btn_cream / tray_slot names: purple wood.
		for state: String in ["normal", "hover", "pressed", "disabled"]: states[state] = _purple_pill(state)
	for state: String in states: button.add_theme_stylebox_override(state, states[state])
	_focus_ring(button, Kit.GOLD_GLINT if gold else Kit.GOLD)
	# Plum ink on gold; cream lettering with a dark outline on wood and purple.
	# Every key is (re)set so restyling a button never inherits the previous piece's ink.
	var ink: Color = INK if gold else TEXT
	for key: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(key, ink)
	button.add_theme_color_override("font_disabled_color", MUTED if gold else Color(TEXT_SOFT, 0.7))
	button.add_theme_color_override("font_outline_color", Kit.WOOD_DARK if wood else Kit.TEXT_OUTLINE)
	button.add_theme_constant_override("outline_size", 0 if gold else (6 if wood else 4))

## Visible keyboard / gamepad focus: a ring drawn just outside the button.
func _focus_ring(button: Control, color: Color = Kit.GOLD, radius: int = 24) -> void:
	var ring := Kit.pill(Color(0, 0, 0, 0), color, false, radius)
	ring.draw_center = false
	ring.set_border_width_all(3)
	ring.shadow_size = 0
	ring.set_expand_margin_all(3)
	button.add_theme_stylebox_override("focus", ring)

## Purple-wood pill (secondary buttons, pickers) for a button state; replaces btn_cream.
func _purple_pill(state: String = "normal") -> StyleBoxFlat:
	var fill := Kit.WOOD_PURPLE
	if state == "hover": fill = fill.lightened(0.12)
	elif state == "pressed": fill = fill.darkened(0.12)
	elif state == "disabled": fill = fill.lerp(Kit.PLUM_SOFT, 0.6).darkened(0.25)
	var box := Kit.pill(fill, Kit.WOOD_PURPLE_DARK, state == "pressed", 24)
	box.border_color = Kit.WOOD_PURPLE_DARK.darkened(0.2)
	box.border_width_top = 2
	box.border_width_left = 2
	box.border_width_right = 2
	_pad(box, 22, 8 + (3 if state == "pressed" else 0), 22, 11)
	return box

## Round (or lozenge) gem button for the HUD icon bar and clusters: purple wood, gold rim.
func _gem_button(button: Button, round: bool = true, fill: Color = Kit.WOOD_PURPLE) -> void:
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, Kit.gem(state, round, fill))
	_focus_ring(button, Kit.GOLD_GLINT, 999 if round else 20)
	for key: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(key, TEXT)
	button.add_theme_color_override("font_disabled_color", Color(TEXT_SOFT, 0.6))
	button.add_theme_color_override("font_outline_color", Kit.TEXT_OUTLINE)
	button.add_theme_constant_override("outline_size", 4)
	button.add_theme_font_override("font", Kit.font(true))

## toggle_off with its cream track gradient-mapped to plum (the knob keeps its star).
func _toggle_off_icon(scale: float) -> Texture2D:
	var key := "toggle_off_plum@%.3f" % scale
	if _kit_cache.has(key): return _kit_cache[key]
	var base := _kit_icon("toggle_off", scale)
	if base == null: return null
	var image := Kit.recolor_image(base.get_image(), Kit.WOOD_PURPLE_DARK, Kit.WOOD_PURPLE, true, 1.0, Rect2(0.4, 0, 0.6, 1))
	var tinted := ImageTexture.create_from_image(image)
	_kit_cache[key] = tinted
	return tinted

## Narrows the side padding of every state of a kit button (dense HUD rows).
func _tighten(button: Button, side: float) -> void:
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		var box := button.get_theme_stylebox(state)
		if box != null and button.has_theme_stylebox_override(state):
			box.content_margin_left = side
			box.content_margin_right = side

## `earned` of `total` gold bevelled stars; unearned ones are greyed and dimmed (ref 02).
func _star_row(earned: int, total: int = 3, px: float = 64.0) -> HBoxContainer:
	var row := _hbox(null, 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon := _star_icon(px)
	for i: int in total:
		if icon == null:
			row.add_child(_label("★" if i < earned else "☆", roundi(px * 0.8), Kit.STAR_ON if i < earned else Kit.STAR_DIM, true))
			continue
		var star := TextureRect.new()
		star.texture = icon
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		star.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		star.custom_minimum_size = Vector2(px, px)
		if i >= earned: star.modulate = Color(0.55, 0.5, 0.5, 0.55)
		row.add_child(star)
	row.set("accessibility_name", "%d of %d stars" % [earned, total])
	return row

## Small plum chip in a biome rim: caption over a big value (SCORE 1,250 / TIME 0:42).
func _stat_chip(caption: String, value: String) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	chip.custom_minimum_size.x = 160
	chip.add_theme_stylebox_override("panel", _chip_style("meadow"))
	var col := _vbox(chip, 0)
	var top := _label(caption, 14, Kit.GOLD, true)
	top.add_theme_font_override("font", Kit.font(true))
	col.add_child(top)
	var big := _label(value, 28, INK, true)
	big.autowrap_mode = TextServer.AUTOWRAP_OFF
	big.add_theme_font_override("font", Kit.font(true))
	col.add_child(big)
	return chip

## One standings line on a plum chip: place sign, name, wins as gold stars (leader in gold frame).
func _standing_row(place: int, player_name: String, wins: int, top_wins: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.custom_minimum_size.x = 420
	panel.add_theme_stylebox_override("panel", _chip_style("celestial" if wins == top_wins and wins > 0 else "meadow"))
	var row := _hbox(panel, 14)
	row.add_child(_sign(str(place), 20))
	var who := _label(player_name, 24, INK)
	who.add_theme_font_override("font", Kit.font(true))
	who.autowrap_mode = TextServer.AUTOWRAP_OFF
	row.add_child(who)
	row.add_child(_star_row(mini(wins, 5), mini(maxi(top_wins, 1), 5), 32.0))
	var count := _label("%d wins" % wins, 18, MUTED)
	count.autowrap_mode = TextServer.AUTOWRAP_OFF
	count.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(count)
	return panel

## Gold bevelled star icon (the slider thumb render) sized for a `px`-tall button face.
func _star_icon(px: float) -> Texture2D:
	return _kit_icon("slider_star_thumb", clampf(px / 56.0, 0.3, 1.5))

## Wooden signboard heading ("AUDIO", "PLAY WITH FRIENDS"): cream text, brown outline.
func _sign(text: String, font_size: int = 20) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var box: StyleBox = _kit("sign_heading")
	panel.add_theme_stylebox_override("panel", _pad(box, 26, 6, 26, 10) if box != null else Kit.sign_box())
	var label := _label(text, font_size, TEXT, true)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.add_theme_font_override("font", Kit.font(true))
	label.add_theme_color_override("font_outline_color", Kit.WOOD_DARK)
	label.add_theme_constant_override("outline_size", 6)
	panel.add_child(label)
	return panel

## Multicolour display title (refs 05/06/08): one candy colour per glyph cycling TITLE_COLORS,
## thick dark-brown outline and a plum drop shadow. One RichTextLabel, so screen readers read
## the whole word; the source text is translated first, then split into coloured glyphs.
func _rainbow(text: String, font_size: int = 34) -> RichTextLabel:
	var px := roundi(font_size * _text_factor)
	var rich := RichTextLabel.new()
	rich.name = "Title"
	rich.bbcode_enabled = true
	rich.fit_content = true
	rich.scroll_active = false
	rich.autowrap_mode = TextServer.AUTOWRAP_OFF
	rich.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rich.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	rich.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var bb := "[center]"
	var glyph := 0
	for ch: String in tr(text).to_upper():
		if ch.strip_edges().is_empty():
			bb += ch
			continue
		var tint: Color = Kit.TITLE_COLORS[glyph % Kit.TITLE_COLORS.size()]
		bb += "[color=#%s]%s[/color]" % [tint.to_html(false), "[lb]" if ch == "[" else ch]
		glyph += 1
	rich.text = bb + "[/center]"
	rich.add_theme_font_override("normal_font", Kit.font(true))
	rich.add_theme_font_size_override("normal_font_size", px)
	# Chunky display lettering (refs 05, 04): thick dark-brown outline, deep plum drop shadow.
	rich.add_theme_color_override("font_outline_color", Kit.WOOD_DARK)
	rich.add_theme_constant_override("outline_size", maxi(9, roundi(px / 3.6)))
	rich.add_theme_color_override("font_shadow_color", Color(0.12, 0.04, 0.16, 0.75))
	rich.add_theme_constant_override("shadow_offset_x", 0)
	rich.add_theme_constant_override("shadow_offset_y", maxi(4, px / 8))
	rich.add_theme_constant_override("shadow_outline_size", maxi(10, roundi(px / 3.2)))
	return rich

## Red gem close button (btn_close) that emits `back`. Icon-only, so it carries a tooltip and
## an accessibility name.
func _close_button() -> Button:
	var b := Button.new()
	b.name = "Close"
	b.tooltip_text = "Back"
	b.set("accessibility_name", "Back")
	var side := maxf(56.0, 56.0 * minf(_control_factor, 1.4))
	b.custom_minimum_size = Vector2(side, side)
	var face: StyleBoxTexture = _kit("btn_close")
	if face == null:
		b.text = "✕"
		_kit_button(b, "btn_purple")
	else:
		_pad(face, 0, 0, 0, 0)
		var hover := face.duplicate() as StyleBoxTexture
		hover.modulate_color = Color(1.1, 1.1, 1.1)
		var pressed := face.duplicate() as StyleBoxTexture
		pressed.modulate_color = Color(0.85, 0.82, 0.82)
		b.add_theme_stylebox_override("normal", face)
		b.add_theme_stylebox_override("hover", hover)
		b.add_theme_stylebox_override("pressed", pressed)
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.pressed.connect(func() -> void: intent.emit(&"back", {}))
	return b

## Frame scale: the 1x purple frame (118 px corners) is too heavy for a 720 px screen.
func _frame_scale() -> float:
	return 0.8 if _portrait else 0.9

func _begin(screen: String, data: Dictionary, overlay: bool = false) -> VBoxContainer:
	current_screen = screen
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
	# Painted meadow scene (sky, clouds, floating mesas, cloud sea) behind every menu (ref 05).
	var bg: ColorRect = ColorRect.new() if overlay else Kit.backdrop("meadow", 0.0 if _reduced_motion() else 1.0)
	if overlay: bg.color = Color(INK, .72)
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
	if screen in UNFRAMED_SCREENS:
		margin.add_child(col)
		return col
	# Purple-wood frame with an OPEN centre (ref 05): the painted scene shows through and
	# content groups sit on plum glass. The plaque from _header() overlaps its top rail.
	var frame := PanelContainer.new()
	frame.name = "Frame"
	frame.mouse_filter = Control.MOUSE_FILTER_PASS
	var scale := _frame_scale()
	var box: StyleBoxTexture = _kit("frame_purple_open", scale)
	if box != null: box.draw_center = false
	var side_pad := 66.0 * scale
	var top_pad := side_pad if screen == "title" else maxf(side_pad, _plaque_bottom(pad) - pad + 6.0)
	frame.add_theme_stylebox_override("panel", _pad(box, side_pad, top_pad, side_pad, side_pad) if box != null else Kit.frame_box())
	margin.add_child(frame)
	frame.add_child(col)
	return col

## Plaque height scales with the title font; it hangs from just above the frame's top rail.
func _plaque_top(pad: int) -> float:
	return pad - (16.0 if _portrait else 22.0)

func _plaque_bottom(pad: int) -> float:
	return _plaque_top(pad) + 50.0 + _title_px() * _text_factor + 14.0

## Display-title size: big chunky letters (ref plaque ~40% of the frame width).
func _title_px() -> float:
	return 36.0 if _portrait else 44.0

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
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	if parent != null: parent.add_child(row)
	return row

func _label(text: String, font_size: int = 18, color: Color = INK, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", maxi(12, roundi(font_size * _text_factor)))
	# Plum ink was for parchment. On the scene, glass and wood, ink becomes cream and muted ink
	# soft lavender; every label carries the plum outline + shadow for AA contrast.
	if color == INK: color = TEXT
	elif color == MUTED: color = TEXT_SOFT
	Kit.outline(label, maxi(12, roundi(font_size * _text_factor)), color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if centered: label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func _button(text: String, id: StringName, args: Dictionary = {}, primary: bool = false, height: float = 50.0) -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = text
	button.add_theme_font_size_override("font_size", maxi(14, roundi(18 * _text_factor)))
	button.custom_minimum_size = Vector2(MENU_BUTTON_MIN_WIDTH, maxf(height, 48.0))
	# Pills keep their painted proportions: sized to content and centred, never stretched
	# edge to edge (the user rejected long light-yellow bars). HUD buttons opt back in to fill.
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(func() -> void: intent.emit(id, args))
	if primary:
		_kit_button(button, "btn_gold")
		button.add_theme_font_override("font", Kit.font(true))
		# Call-to-action pills carry the bevelled gold star on the left (refs 05, 06, 15).
		if height >= 56.0: button.icon = _star_icon(minf(height * 0.5, 44.0))
		_focus_default = button
	return button

## Screen chrome: multicolour title on the purple plaque over the frame's top rail, the red gem
## close (emits `back`) on the top-right corner, then a subtitle + Settings row inside the frame.
func _header(parent: Node, title: String, subtitle: String = "", back: bool = true) -> void:
	var pad := 18 if _portrait else 28
	var hang := CenterContainer.new()
	hang.name = "Plaque"
	hang.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu.add_child(hang)
	hang.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	hang.offset_top = _plaque_top(pad)
	hang.offset_bottom = _plaque_bottom(pad)
	hang.offset_left = pad + 70
	hang.offset_right = -(pad + 70)
	var plaque := PanelContainer.new()
	plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box: StyleBox = _kit("plaque_title", 1.0)
	plaque.add_theme_stylebox_override("panel", _pad(box, 70, 10, 70, 16) if box != null else Kit.plaque_box())
	plaque.custom_minimum_size.y = _plaque_bottom(pad) - _plaque_top(pad)
	hang.add_child(plaque)
	# Fit long titles to the plaque: shrink the letters, never let the plaque overflow.
	var width := get_viewport().get_visible_rect().size.x - 2.0 * (pad + 70) - 150.0
	var glyphs := maxf(1.0, tr(title).length())
	var px := minf(_title_px(), width / (glyphs * 0.66 * _text_factor))
	var word := _rainbow(title, roundi(px))
	word.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	plaque.add_child(word)
	if back:
		var close := _close_button()
		_menu.add_child(close)
		close.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		close.offset_right = -(pad - 6)
		close.offset_left = close.offset_right - close.custom_minimum_size.x
		close.offset_top = pad - 12
		close.offset_bottom = close.offset_top + close.custom_minimum_size.y
	var row := _hbox(parent)
	var sub := _label(subtitle, 17, MUTED, true)
	sub.visible = not subtitle.is_empty()
	row.add_child(sub)
	# Settings is a gear gem on sub-screens (no beige pill).
	var settings := _button("⚙", &"open_settings")
	settings.tooltip_text = "Settings"
	settings.set("accessibility_name", "Settings")
	settings.size_flags_horizontal = Control.SIZE_SHRINK_END
	settings.custom_minimum_size = Vector2(52, 52)
	settings.add_theme_font_size_override("font_size", 26)
	_gem_button(settings)
	settings.visible = current_screen != "settings"
	row.add_child(settings)
	row.visible = sub.visible or settings.visible

func _scroll(parent: Node) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 100
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	return _vbox(scroll, 16)

## Content group: translucent plum glass (PlumPanel theme variation). Any `color` other than
## CREAM marks it highlighted (active profile) with a gold rim instead of a tinted fill.
func _card(parent: Node, color: Color = CREAM) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.theme_type_variation = &"PlumPanel"
	if color != CREAM:
		var lit := Kit.glass_box()
		lit.border_color = Kit.GOLD
		lit.set_border_width_all(4)
		panel.add_theme_stylebox_override("panel", lit)
	parent.add_child(panel)
	var pad := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 16)
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
	var vh: float = get_viewport().get_visible_rect().size.y
	var vw: float = get_viewport().get_visible_rect().size.x
	var top := _hbox(col)
	var name := str(data.get("profile_name", "Profiles"))
	var profile := _button("☁  " + name, &"open_profiles")
	profile.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	profile.custom_minimum_size.x = 0
	top.add_child(profile)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(spacer)
	var settings := _button("⚙", &"open_settings")
	settings.tooltip_text = "Settings"
	settings.set("accessibility_name", "Settings")
	settings.custom_minimum_size = Vector2(60, 60)
	settings.add_theme_font_size_override("font_size", 30)
	settings.size_flags_horizontal = Control.SIZE_SHRINK_END
	_gem_button(settings)
	top.add_child(settings)
	# Portrait: logo, diorama, buttons stacked (ref 15). Landscape: art column on the left
	# (logo over the island and wizard), button column on the right.
	var art_col: VBoxContainer = col
	var button_col: VBoxContainer = col
	if not _portrait:
		var split := _hbox(col, 24)
		split.size_flags_vertical = Control.SIZE_EXPAND_FILL
		art_col = _vbox(split, 4)
		art_col.size_flags_stretch_ratio = 1.25
		button_col = _vbox(split, 14)
		button_col.alignment = BoxContainer.ALIGNMENT_CENTER
	var logo := TextureRect.new()
	logo.texture = Kit.sprite("logo_wacky_towers")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size.y = vh * (0.19 if _portrait else 0.26)
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_col.add_child(logo)
	var stage := Control.new()
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.custom_minimum_size.y = vh * (0.34 if _portrait else 0.3)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_col.add_child(stage)
	var island := WtTitleIsland.new()
	island.turn_speed = 0.0 if _reduced_motion() else 6.0
	stage.add_child(island)
	island.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	island.anchor_top = 0.18 if _portrait else 0.1
	# The wizard sprite is optional art: without it the island stands alone. His cloud sits on
	# the island's top-left shoulder so the two read as one diorama (ref 15).
	var wizard_art: Texture2D = _ui_sprite("wizard_cheer")
	var wizard := TextureRect.new()
	wizard.texture = wizard_art
	wizard.visible = wizard_art != null
	wizard.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	wizard.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	wizard.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(wizard)
	wizard.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wizard.anchor_left = 0.02 if _portrait else 0.0
	wizard.anchor_right = 0.5 if _portrait else 0.42
	wizard.anchor_top = -0.05 if _portrait else -0.08
	wizard.anchor_bottom = 0.55 if _portrait else 0.6
	if wizard_art != null and not _reduced_motion():
		var bob := wizard.create_tween().set_loops()
		bob.tween_property(wizard, "position:y", -10.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(wizard, "position:y", 6.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var has_profile := bool(data.get("has_profile", false))
	var buttons := _vbox(button_col, 14)
	buttons.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	buttons.custom_minimum_size.x = minf(vw * (0.78 if _portrait else 0.36), 520)
	var play := _button("★  PLAY", &"continue" if has_profile else &"play", {}, true, 92 if _portrait else 88)
	play.add_theme_font_size_override("font_size", roundi(46 * _text_factor))
	# Hero pill (ref 15): the star is the bevelled gold icon, so the label text drops its glyph.
	if play.icon != null: play.text = "PLAY"
	play.icon = _star_icon(60)
	play.tooltip_text = str(data.get("continue_level_name", "Play"))
	play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(play)
	# BIOMES and MODES are wooden signboards (ref 15): only PLAY is gold.
	var biomes := _button("BIOMES", &"open_map", {}, false, 62)
	var modes := _button("MODES", &"noop", {}, false, 62)
	modes.pressed.disconnect(modes.pressed.get_connections()[0].callable)
	modes.pressed.connect(func() -> void: show_modes(_snapshot))
	for sign: Button in [biomes, modes]:
		_kit_button(sign, "sign_heading")
		sign.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		sign.custom_minimum_size.x = 300
		sign.add_theme_font_override("font", Kit.font(true))
		sign.add_theme_font_size_override("font_size", roundi(30 * _text_factor))
		buttons.add_child(sign)
	_focus_default = play
	var foot := _hbox(button_col)
	# Tally in a small plum chip with the gold star (no loose text on the sky).
	var chip := PanelContainer.new()
	chip.theme_type_variation = &"PlumPanel"
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var chip_row := _hbox(chip, 8)
	var star := TextureRect.new()
	star.texture = _star_icon(28)
	star.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	star.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star.visible = has_profile and star.texture != null
	chip_row.add_child(star)
	var tally := "%d collected    ·    %d in your jar" % [int(data.get("stars", 0)), int(data.get("wallet", 0))] if has_profile else "Build, turn, drop. Make room for wonder."
	var tally_label := _label(tally, 16, INK, true)
	tally_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	chip_row.add_child(tally_label)
	foot.add_child(chip)
	var quit := _button("Quit", &"quit")
	quit.pressed.disconnect(quit.pressed.get_connections()[0].callable)
	quit.pressed.connect(confirm_quit)
	quit.size_flags_horizontal = Control.SIZE_SHRINK_END
	quit.custom_minimum_size.x = 0
	quit.visible = not OS.has_feature("mobile")
	foot.add_child(quit)
	_finish()

## Mode cards for the Select Mode screen (refs 05, 06; art bible 5d): label, one-line hint,
## intent, hero render(s) and the biome whose sky tints the illustration. `intent` empty = disabled.
const MODE_CARDS: Array[Dictionary] = [
	{"key": "campaign", "label": "CAMPAIGN", "hint": "Follow the island path, one tower at a time.", "intent": &"open_map", "art": ["wizard_point"], "biome": "meadow", "island": true},
	{"key": "tournament", "label": "TOURNAMENT", "hint": "Party rounds for up to four builders.", "intent": &"open_tournament", "art": ["knight_cheer", "dwarf_cheer"], "biome": "candy"},
	{"key": "biomes", "label": "BIOMES", "hint": "Hop to any island you've unlocked.", "intent": &"open_map", "art": ["elf_idle"], "biome": "ice"},
	{"key": "arcade", "label": "ARCADE", "hint": "Endless stacking against the clock.", "intent": &"open_arcade", "art": [], "pieces": true, "biome": "candy"},
	{"key": "story", "label": "STORY", "hint": "The wizard's tale is still being written.", "intent": &"", "art": ["wizard_idle"], "biome": "celestial", "badge": "Coming soon"},
]

## Select Mode: purple frame, "SELECT MODE" plaque, five picture cards, Shop / Toy box pills and
## a gold BACK. Opened from the title's MODES pill; `data` is the title snapshot so BACK restores it.
## Portrait: big Campaign card, then two rows of two. Landscape: Campaign + Tournament, then three.
func show_modes(data: Dictionary = {}) -> void:
	var col := _begin("modes", data)
	_header(col, "SELECT MODE")
	# The subtitle/Settings row _header adds is not part of the reference layout.
	col.get_child(col.get_child_count() - 1).visible = false
	var vh: float = get_viewport().get_visible_rect().size.y
	var cards: Dictionary = {}
	for entry: Dictionary in MODE_CARDS: cards[entry.key] = entry
	var ribbon := str(data.get("continue_level_name", ""))
	# Gold-framed picture cards straight on the painted scene (no interior panel, ref 05).
	var grid := _vbox(col, 14)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var made: Dictionary = {}
	if _portrait:
		var hero := _mode_card(cards.campaign, vh * 0.2, true, ribbon)
		hero.size_flags_stretch_ratio = 1.5
		grid.add_child(hero)
		made.campaign = hero
		for pair: Array in [["tournament", "biomes"], ["arcade", "story"]]:
			var row := _hbox(grid, 14)
			row.size_flags_vertical = Control.SIZE_EXPAND_FILL
			for key: String in pair:
				made[key] = _mode_card(cards[key], vh * 0.15, false, ribbon)
				row.add_child(made[key])
	else:
		# Ref 05 landscape: big Campaign over Biomes on the left; Tournament over
		# Arcade + Story on the right.
		var split := _hbox(grid, 16)
		split.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var left := _vbox(split, 14)
		left.size_flags_stretch_ratio = 1.15
		var right := _vbox(split, 14)
		made.campaign = _mode_card(cards.campaign, vh * 0.26, true, ribbon)
		made.campaign.size_flags_stretch_ratio = 1.9
		left.add_child(made.campaign)
		made.biomes = _mode_card(cards.biomes, vh * 0.15, false, ribbon)
		left.add_child(made.biomes)
		made.tournament = _mode_card(cards.tournament, vh * 0.2, false, ribbon)
		made.tournament.size_flags_stretch_ratio = 1.1
		right.add_child(made.tournament)
		var pair := _hbox(right, 14)
		pair.size_flags_vertical = Control.SIZE_EXPAND_FILL
		for key: String in ["arcade", "story"]:
			made[key] = _mode_card(cards[key], vh * 0.2, false, ribbon)
			pair.add_child(made[key])
	_focus_default = made.campaign
	var foot := _hbox(col, 16)
	for entry: Array in [["Shop", &"open_shop"], ["Toy box", &"open_physics"]]:
		var b := _button(entry[0], entry[1], {}, false, 52)
		b.custom_minimum_size.x = 170
		b.add_theme_font_override("font", Kit.font(true))
		_kit_button(b, "sign_heading")
		foot.add_child(b)
	var campaign_focus := _focus_default
	var back := _button("BACK", &"noop", {}, true, 64)
	back.pressed.disconnect(back.pressed.get_connections()[0].callable)
	back.pressed.connect(func() -> void: show_title(_snapshot))
	back.custom_minimum_size.x = 280
	back.add_theme_font_size_override("font_size", roundi(28 * _text_factor))
	if _portrait: col.add_child(back)
	else: foot.add_child(back)
	_focus_default = campaign_focus
	_finish()

## One picture card: a focusable Button whose face is the rope-bordered wood panel, holding a
## biome-sky illustration with hero renders, a wooden label sign and a one-line hint below.
func _mode_card(entry: Dictionary, height: float, featured: bool, ribbon: String) -> Button:
	var card := Button.new()
	card.name = "Card_" + str(entry.key).capitalize()
	var label := str(entry.label)
	var hint := str(entry.hint)
	card.tooltip_text = hint
	card.set("accessibility_name", label.capitalize() + ". " + hint)
	card.custom_minimum_size = Vector2(0, maxf(height, 120.0))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var intent_id: StringName = entry.intent
	card.disabled = intent_id == &""
	if not card.disabled:
		card.pressed.connect(func() -> void: intent.emit(intent_id, {}))
	# Gold frame (ref 05): the button face is the frame; the illustration is inset inside it.
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		var fill := Kit.GOLD
		if state == "hover": fill = Kit.GOLD_GLINT
		elif state == "pressed": fill = Kit.GOLD_DEEP
		elif state == "disabled": fill = Kit.GOLD.darkened(0.25)
		var frame := Kit.pill(fill, Kit.GOLD_DEEP.darkened(0.2), state == "pressed", 22)
		frame.set_border_width_all(3)
		frame.border_width_bottom = 3 if state == "pressed" else 7
		frame.shadow_size = 8
		frame.shadow_color = Color(0.1, 0.04, 0.16, 0.4)
		card.add_theme_stylebox_override(state, frame)
	var ring := Kit.pill(Color(0, 0, 0, 0), Color.WHITE, false, 26)
	ring.draw_center = false
	ring.set_border_width_all(4)
	ring.shadow_size = 0
	ring.set_expand_margin_all(5)
	card.add_theme_stylebox_override("focus", ring)
	# Full-bleed illustration: the biome's painted scene, clipped to a rounded window.
	var art := Panel.new()
	art.name = "Art"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var window := StyleBoxFlat.new()
	window.bg_color = Kit.WOOD_PURPLE_DARK
	window.set_corner_radius_all(15)
	window.anti_aliasing = true
	art.add_theme_stylebox_override("panel", window)
	art.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	card.add_child(art)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.offset_left = 7
	art.offset_top = 7
	art.offset_right = -7
	art.offset_bottom = -10
	var scene := Kit.backdrop(str(entry.biome), 0.0 if _reduced_motion() else 1.0)
	art.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var sign_room := (34.0 if featured else 26.0) * _text_factor + 18.0
	if bool(entry.get("island", false)):
		var island := WtTitleIsland.new()
		island.turn_speed = 0.0
		art.add_child(island)
		island.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		island.anchor_left = 0.08
		island.anchor_right = 0.62
		island.anchor_top = 0.12
		island.offset_bottom = -sign_room * 0.4
	if bool(entry.get("pieces", false)):
		# Arcade: a tumble of glossy toy pieces (WtPiecePreview), rainbow like ref 05.
		var pile := HBoxContainer.new()
		pile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pile.alignment = BoxContainer.ALIGNMENT_CENTER
		art.add_child(pile)
		pile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		pile.offset_top = 10
		pile.offset_bottom = -sign_room
		for spec: Array in [[[Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 1, 0)], Color("4aa8e8")], [[Vector3i(0, 0, 0), Vector3i(0, 1, 0), Vector3i(0, 2, 0), Vector3i(1, 0, 0)], Color("ee6aa0")], [[Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(1, 1, 0)], Color("6cc04a")]]:
			var piece := WtPiecePreview.new()
			piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
			piece.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			piece.cells = spec[0]
			piece.tint = spec[1]
			pile.add_child(piece)
	var heroes := HBoxContainer.new()
	heroes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	heroes.alignment = BoxContainer.ALIGNMENT_END if bool(entry.get("island", false)) else BoxContainer.ALIGNMENT_CENTER
	heroes.add_theme_constant_override("separation", 0)
	art.add_child(heroes)
	heroes.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	heroes.offset_top = 6
	heroes.offset_bottom = -sign_room * 0.7
	for sprite_name: String in entry.art:
		var texture: Texture2D = _ui_sprite(sprite_name)
		if texture == null: continue
		var hero := TextureRect.new()
		hero.texture = texture
		hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hero.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hero.size_flags_stretch_ratio = 0.8 if bool(entry.get("island", false)) else 1.0
		hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		heroes.add_child(hero)
	if card.disabled: art.modulate = Color(0.78, 0.74, 0.86)
	# Thin gold-glint bevel inside the frame, over the illustration's edge.
	var bevel := Panel.new()
	bevel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var line := StyleBoxFlat.new()
	line.draw_center = false
	line.border_color = Color(Kit.GOLD_GLINT, 0.8)
	line.set_border_width_all(2)
	line.set_corner_radius_all(15)
	line.anti_aliasing = true
	bevel.add_theme_stylebox_override("panel", line)
	card.add_child(bevel)
	bevel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bevel.offset_left = 7
	bevel.offset_top = 7
	bevel.offset_right = -7
	bevel.offset_bottom = -10
	# Big wooden name sign hanging over the bottom of the illustration (ref 05). No caption strip.
	var sign_holder := CenterContainer.new()
	sign_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(sign_holder)
	sign_holder.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	sign_holder.offset_top = -sign_room - 6
	sign_holder.offset_bottom = -2
	sign_holder.add_child(_sign(label, 34 if featured else 26))
	if featured and not ribbon.is_empty():
		var chip := _sign(ribbon, 15)
		chip.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		chip.position = Vector2(16, 14)
		card.add_child(chip)
	if entry.has("badge"):
		var badge := PanelContainer.new()
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var pill := Kit.pill(Kit.DANGER_RED, Color("8e2a22"), false, 18)
		_pad(pill, 12, 4, 12, 6)
		badge.add_theme_stylebox_override("panel", pill)
		var text := _label(str(entry.badge), 15, TEXT, true)
		text.autowrap_mode = TextServer.AUTOWRAP_OFF
		text.add_theme_font_override("font", Kit.font(true))
		badge.add_child(text)
		card.add_child(badge)
		badge.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		badge.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		badge.offset_right = -14
		badge.offset_top = 14
	return card

## 12345 -> "12,345" for the score plaque.
func _grouped(value: int) -> String:
	var digits := str(absi(value))
	var out := ""
	while digits.length() > 3:
		out = "," + digits.substr(digits.length() - 3) + out
		digits = digits.substr(0, digits.length() - 3)
	return ("-" if value < 0 else "") + digits + out

## True when the player asked for reduced motion (setting is "on", or a legacy bool).
func _reduced_motion() -> bool:
	var motion: Variant = _prefs.get("reduced_motion", "system")
	return motion if motion is bool else str(motion) == "on"

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
			var badge := Glyph.new(StringName(str(p.get("badge", "cloud"))), Kit.GOLD_GLINT)
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
	var badge := _button("☁  " + str(data.get("profile_name", "Your profile")), &"open_profiles")
	badge.custom_minimum_size.x = 0
	_kit_button(badge, "btn_purple")
	info.add_child(badge)
	var tally := _label("★  %d collected   ·   Jar %d" % [int(data.get("stars", 0)), int(data.get("wallet", 0))], 18, MUTED, true)
	tally.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tally.autowrap_mode = TextServer.AUTOWRAP_OFF
	info.add_child(tally)
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
		# Biome picker reads as a wooden heading sign, centred over the level tiles.
		_kit_button(select, "sign_heading")
		select.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		select.custom_minimum_size.x = 260
		select.add_theme_font_override("font", Kit.font(true))
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
			# Plum island tiles in the biome rim; the next island is lit in gold.
			var plate := Kit.slot_flat(str(data.get("selected_biome", "meadow")), id == str(data.get("next_level_id", "")) and state != "disabled")
			if state == "hover": plate.bg_color = plate.bg_color.lightened(0.1)
			if state == "pressed": plate.bg_color = plate.bg_color.darkened(0.15)
			if state == "disabled": plate.bg_color = Color(Kit.WOOD_PURPLE_DARK, 0.6)
			plate.content_margin_top = 78
			plate.content_margin_bottom = 11
			plate.content_margin_left = 14
			plate.content_margin_right = 14
			b.add_theme_stylebox_override(state, plate)
		var island := Glyph.new(&"island", Kit.GOLD_GLINT)
		b.add_child(island)
		island.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		island.offset_top = 10
		island.offset_bottom = 78
		arc.add_child(b)
	var footer := _hbox(col, 16)
	for entry: Array in [["Toy shop", &"open_shop"], ["Arcade", &"open_arcade"], ["Tournament", &"open_tournament"]]:
		var sign := _button(entry[0], entry[1], {}, false, 56)
		sign.custom_minimum_size.x = 180
		sign.add_theme_font_override("font", Kit.font(true))
		_kit_button(sign, "sign_heading")
		footer.add_child(sign)
	_finish()

func show_intro(data: Dictionary = {}) -> void:
	var col := _begin("intro", data)
	_header(col, str(data.get("name", "Meadow adventure")), str(data.get("level_id", "Meadow")).replace("_", " ").capitalize())
	var body := _scroll(col)
	var card := _card(body)
	card.add_child(_sign("YOUR LITTLE MISSION", 16))
	if bool(data.get("preview", false)):
		card.add_child(_label("DESIGN PREVIEW · NO STARS AWARDED", 16, MUTED, true))
	card.add_child(_label(str(data.get("goal", "Clear a layer")), 32, INK, true))
	card.add_child(_label(str(data.get("goal_detail", "Fill every square in a layer to make it disappear.")), 18, MUTED, true))
	var twists: Array = data.get("twists", [])
	if not twists.is_empty():
		card.add_child(_sign("TODAY'S SURPRISES", 16))
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
	_fit_controls()
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
	var biome := str(_hud_data.get("biome", "meadow"))
	_hud = Control.new()
	_hud.name = "Hud"
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_hud)
	_hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Biome-tinted screen frame (ref 15, bible 4): vine green, frost blue, celestial violet...
	# A rounded rail around the screen; centre not drawn, input ignored, board stays clear.
	var screen_frame := Panel.new()
	screen_frame.name = "BiomeFrame"
	screen_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_frame.add_theme_stylebox_override("panel", Kit.hud_frame(biome))
	_hud.add_child(screen_frame)
	screen_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var top := MarginContainer.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(top)
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 18
	top.offset_right = -18
	top.offset_top = 16
	_hud_labels.top = top
	# The party item bar hangs below the header: re-place it whenever the header grows.
	top.resized.connect(_on_hud_header_resized)
	var col := _vbox(top, 8)
	var row := _hbox(col, 10)
	var pause := _play_button("Ⅱ", &"pause", {}, false)
	pause.tooltip_text = "Pause"
	pause.custom_minimum_size = Vector2(64, 64)
	pause.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	pause.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	# Round purple gem with a gold rim (ref 15 pause).
	_gem_button(pause, true)
	pause.add_theme_font_size_override("font_size", 26)
	row.add_child(pause)
	# Goal lozenge: level name and progress on dark plum glass.
	var ribbon := PanelContainer.new()
	ribbon.name = "GoalChip"
	ribbon.add_theme_stylebox_override("panel", _pad(Kit.glass_box(0.88, 22), 16, 8, 16, 10))
	ribbon.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	ribbon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var goal := _hbox(ribbon, 10)
	_hud_labels.level = _label("Meadow", 15, MUTED)
	_hud_labels.goal = _label("0 / 1", 19, INK, true)
	_hud_labels.goal.add_theme_font_override("font", Kit.font(true))
	for l: Label in [_hud_labels.level, _hud_labels.goal]:
		l.autowrap_mode = TextServer.AUTOWRAP_OFF
		l.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		goal.add_child(l)
	# Timer: dark plum lozenge with gold numerals, top centre, inside the safe area (bible 5b).
	var clock := PanelContainer.new()
	clock.name = "Clock"
	var clock_face := Kit.chip_flat(biome)
	clock_face.set_corner_radius_all(22)
	clock.add_theme_stylebox_override("panel", _pad(clock_face, 16, 4, 16, 8))
	clock.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	clock.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	clock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_labels.time = _label("0:00", 20, Kit.GOLD_GLINT, true)
	_hud_labels.time.autowrap_mode = TextServer.AUTOWRAP_OFF
	_hud_labels.time.add_theme_font_override("font", Kit.font(true))
	clock.add_child(_hud_labels.time)
	_hud_labels.clock = clock
	if _portrait:
		var goal_row := _hbox(col, 10)
		goal_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ribbon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		goal_row.add_child(ribbon)
		goal_row.add_child(clock)
	else:
		row.add_child(ribbon)
		row.add_child(clock)
	var spacer := Control.new()
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	# SCORE chip in the level's biome rim (ref 15): gold caption, big number, three pace stars.
	var score_panel := PanelContainer.new()
	score_panel.name = "ScoreChip"
	score_panel.add_theme_stylebox_override("panel", _chip_style(biome))
	score_panel.custom_minimum_size.x = 168
	score_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(score_panel)
	var score_col := _vbox(score_panel, 0)
	var score_caption := _label("SCORE", 14, Kit.GOLD, true)
	score_caption.add_theme_font_override("font", Kit.font(true))
	score_col.add_child(score_caption)
	_hud_labels.score = _label("0", 28, INK, true)
	_hud_labels.score.autowrap_mode = TextServer.AUTOWRAP_OFF
	_hud_labels.score.add_theme_font_override("font", Kit.font(true))
	score_col.add_child(_hud_labels.score)
	var star_row := _hbox(score_col, 2)
	star_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_hud_labels.stars = []
	for i: int in 3:
		var star := _label("★", 24, Kit.STAR_ON, true)
		star.autowrap_mode = TextServer.AUTOWRAP_OFF
		star.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		star.add_theme_color_override("font_outline_color", Kit.GOLD_DEEP)
		star.add_theme_constant_override("outline_size", 4)
		star_row.add_child(star)
		_hud_labels.stars.append(star)
	# NEXT chip: same rim, the upcoming piece drawn as isometric toy cubes.
	var next_panel := PanelContainer.new()
	next_panel.name = "NextChip"
	next_panel.add_theme_stylebox_override("panel", _chip_style(biome))
	next_panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	next_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	next_panel.custom_minimum_size.x = 118
	row.add_child(next_panel)
	var next := _vbox(next_panel, 0)
	var next_caption := _label("NEXT", 14, Kit.GOLD, true)
	next_caption.add_theme_font_override("font", Kit.font(true))
	next.add_child(next_caption)
	_hud_labels.next_preview = WtPiecePreview.new()
	_hud_labels.next_preview.custom_minimum_size = Vector2(84, 64)
	_hud_labels.next_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	next.add_child(_hud_labels.next_preview)
	_hud_labels.next = _label("—", 12, MUTED, true)
	_hud_labels.next.autowrap_mode = TextServer.AUTOWRAP_OFF
	next.add_child(_hud_labels.next)
	_hud_labels.held = _label("Hold: —", 12, MUTED, true)
	_hud_labels.held.visible = false
	next.add_child(_hud_labels.held)
	_hud_labels.rules = _label("", 16, MUTED, true)
	_hud_labels.rules.autowrap_mode = TextServer.AUTOWRAP_OFF
	var rules_panel := PanelContainer.new()
	rules_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rules_panel.add_theme_stylebox_override("panel", _pad(Kit.glass_box(0.85, 20), 10, 6, 10, 8))
	var rules_margin := MarginContainer.new()
	for side in ["left", "right"]: rules_margin.add_theme_constant_override("margin_" + side, 12)
	for side in ["top", "bottom"]: rules_margin.add_theme_constant_override("margin_" + side, 2)
	rules_panel.add_child(rules_margin)
	rules_margin.add_child(_hud_labels.rules)
	_hud_labels.rules_panel = rules_panel
	col.add_child(rules_panel)
	_build_item_bar(left_width, right_width)
	var pad_layer := WtGesturePad.new()
	pad_layer.name = "GesturePad"
	pad_layer.step_px = 46.0 * _control_factor
	pad_layer.gesture.connect(func(id: StringName, args: Dictionary) -> void: intent.emit(id, args))
	_hud.add_child(pad_layer)
	_hud.move_child(pad_layer, 0)
	_hud_labels.gesture_pad = pad_layer
	if _storybook_dock():
		_build_dock()
		_place_gesture_pad()
		if is_instance_valid(_menu): _root.move_child(_menu, -1)
		if is_instance_valid(_countdown): _root.move_child(_countdown, -1)
		return
	# Landscape / classic: floating gem clusters at the screen edges, no backing panel.
	var left := PanelContainer.new()
	left.name = "MoveControls"
	left.mouse_filter = Control.MOUSE_FILTER_PASS
	left.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
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
	lcol.alignment = BoxContainer.ALIGNMENT_END
	var move_caption := _label("MOVE", 13, Kit.GOLD, true)
	move_caption.add_theme_font_override("font", Kit.font(true))
	lcol.add_child(move_caption)
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
			_gem_button(b, true)
			b.add_theme_font_size_override("font_size", 24)
			pad.add_child(b)
		else:
			var blank := Control.new()
			blank.custom_minimum_size = Vector2(cell, cell)
			blank.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pad.add_child(blank)
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
	right.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
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
	rcol.alignment = BoxContainer.ALIGNMENT_END
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
	_kit_button(drop, "btn_gold")
	drop.add_theme_font_override("font", Kit.font(true))
	drop_row.add_child(drop)
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
	_place_gesture_pad()
	if is_instance_valid(_menu): _root.move_child(_menu, -1)
	if is_instance_valid(_countdown): _root.move_child(_countdown, -1)

## Header laid out (or resized by text scale): move the party item bar below it, re-fit the pad.
func _on_hud_header_resized() -> void:
	if not _hud_labels.has("items_panel"): return
	_update_item_bar()
	_place_gesture_pad()

## Kit.sprite(), plus a fallback for art dropped into assets/art/ui before the editor has
## imported it (no .import yet): the PNG is decoded directly. Null when the file is absent.
func _ui_sprite(sprite_name: String) -> Texture2D:
	var art: Texture2D = Kit.sprite(sprite_name)
	if art != null: return art
	var path := Kit.SPRITES + sprite_name + ".png"
	if not FileAccess.file_exists(path): return null
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	return ImageTexture.create_from_image(image) if image != null and not image.is_empty() else null

## Biome HUD chip (meadow vines, ice frost, celestial gold) with trimmed content margins.
## HUD chip: plum glass in the biome rim (no parchment PNG; chip_hud* are retired).
func _chip_style(biome: String) -> StyleBox:
	return _pad(Kit.chip_flat(biome), 18, 12, 18, 12)

## Parchment tray slot (ref 15 bottom shelf); `lit` marks the hold / selected slot in gold.
func _slot_style(lit: bool = false) -> StyleBox:
	return _pad(Kit.slot_flat(str(_hud_data.get("biome", "meadow")), lit), 12, 8, 12, 10)

## Portrait phones use the storybook tray and gestures unless classic controls are on.
func _storybook_dock() -> bool:
	return _portrait and not bool(_prefs.get("classic_controls", false))

## Bottom dock: small action pills, then the tray (hold slot + upcoming pieces)
## between a round Turn button and a round Drop button.
func _build_dock() -> void:
	var dock := VBoxContainer.new()
	dock.name = "StorybookDock"
	dock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dock.add_theme_constant_override("separation", 8)
	_hud.add_child(dock)
	dock.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	dock.offset_left = 14
	dock.offset_right = -14
	dock.offset_bottom = -14
	dock.offset_top = -_dock_height()
	_hud_labels.dock = dock
	# One gem icon bar on plum glass replaces the rows of wooden planks: view, flip, roll, soft,
	# tools, skill and potion as compact purple gems (two rows only at large text sizes).
	var bar := PanelContainer.new()
	bar.name = "GemBar"
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("panel", _pad(Kit.glass_box(0.78, 30), 8, 6, 8, 6))
	dock.add_child(bar)
	var bar_col := _vbox(bar, 6)
	var rows: Array[HBoxContainer] = [_hbox(bar_col, 5)]
	if _text_factor > 1.15: rows.append(_hbox(bar_col, 5))
	var gems: Array[Button] = []
	gems.append(_play_button("⟲ View", &"view", {"direction": -1}, false))
	gems.append(_play_button("View ⟳", &"view", {"direction": 1}, false))
	for axis: String in ["tilt", "roll"]:
		if not bool(_hud_data.get("can_" + axis, false)): continue
		var title: String = {"tilt": "Flip", "roll": "Roll"}[axis]
		for dir: int in [-1, 1]:
			gems.append(_play_button(title + (" ‹" if dir < 0 else " ›"), &"rotate", {"axis": StringName(axis), "direction": dir}, true))
	var soft := _play_button("Soft", &"noop", {}, false)
	soft.pressed.disconnect(soft.pressed.get_connections()[0].callable)
	soft.button_down.connect(func() -> void: intent.emit(&"soft", {"active": true}))
	soft.button_up.connect(func() -> void: intent.emit(&"soft", {"active": false}))
	gems.append(soft)
	_hud_labels.tools = _play_button("Tools", &"open_tools", {}, false)
	_hud_labels.skill = _play_button("Skill", &"use_skill", {}, false)
	_hud_labels.skill.tooltip_text = "Character skill"
	_hud_labels.potion = _play_button("Potion", &"use_item", {}, false)
	_hud_labels.potion.tooltip_text = "Selected potion"
	gems.append_array([_hud_labels.tools, _hud_labels.skill, _hud_labels.potion])
	for i: int in gems.size():
		var b: Button = gems[i]
		b.custom_minimum_size = Vector2(0, 52)
		b.add_theme_font_size_override("font_size", roundi(13 * _text_factor))
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_gem_button(b, false)
		_tighten(b, 3.0)
		rows[mini(i * rows.size() / gems.size(), rows.size() - 1)].add_child(b)
	var tray_row := _hbox(dock, 8)
	tray_row.alignment = BoxContainer.ALIGNMENT_CENTER
	var turn := _play_button("⟳\nTurn", &"rotate", {"axis": &"spin", "direction": 1}, true)
	turn.custom_minimum_size = Vector2(84, 84) * _control_factor
	turn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	turn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_gem_button(turn, true)
	turn.add_theme_font_size_override("font_size", roundi(18 * _text_factor))
	tray_row.add_child(turn)
	var tray := PanelContainer.new()
	tray.name = "Tray"
	tray.add_theme_stylebox_override("panel", _pad(Kit.chip_flat(str(_hud_data.get("biome", "meadow"))), 10, 8, 10, 10))
	tray.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tray_row.add_child(tray)
	var slots := _hbox(tray, 6)
	_hud_labels.tray = []
	for i: int in 3:
		var slot := Button.new()
		slot.focus_mode = Control.FOCUS_NONE
		slot.custom_minimum_size = Vector2(0, 92) * _control_factor
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var face := _slot_style(i == 0)
		for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
			slot.add_theme_stylebox_override(state, face)
		var preview := WtPiecePreview.new()
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(preview)
		preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		preview.offset_top = 28
		preview.offset_bottom = -10
		preview.offset_left = 10
		preview.offset_right = -10
		var caption := _label("HOLD" if i == 0 else "THEN", 12, Kit.GOLD, true)
		caption.add_theme_font_override("font", Kit.font(true))
		slot.add_child(caption)
		caption.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		caption.offset_top = 8
		caption.offset_bottom = 28
		if i == 0:
			slot.tooltip_text = "Hold"
			slot.pressed.connect(func() -> void: intent.emit(&"hold", {}))
		else:
			slot.disabled = true
		slots.add_child(slot)
		_hud_labels.tray.append(preview)
	var drop := _play_button("DROP\n↓", &"drop", {}, false)
	drop.custom_minimum_size = Vector2(84, 84) * _control_factor
	drop.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	drop.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_kit_button(drop, "btn_gold")
	drop.add_theme_font_size_override("font_size", roundi(18 * _text_factor))
	drop.add_theme_font_override("font", Kit.font(true))
	tray_row.add_child(drop)

func _dock_height() -> float:
	var bar_rows := 2.0 if _text_factor > 1.15 else 1.0
	return bar_rows * 58.0 + 12.0 + 8.0 + (92.0 + 34.0) * _control_factor + 24.0

## Keeps the gesture pad over the board area only, below every HUD control.
func _place_gesture_pad() -> void:
	var pad: Control = _hud_labels.get("gesture_pad")
	if not is_instance_valid(pad): return
	var area := board_area()
	pad.anchor_left = area.position.x
	pad.anchor_top = area.position.y
	pad.anchor_right = area.end.x
	pad.anchor_bottom = area.end.y
	pad.offset_left = 0
	pad.offset_top = 0
	pad.offset_right = 0
	pad.offset_bottom = 0

func _build_item_bar(left_width: float, right_width: float) -> void:
	var panel := PanelContainer.new()
	panel.name = "PartyItems"
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	_hud.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	var mirrored := bool(_prefs.get("left_hand", false))
	panel.offset_left = 18 if _portrait else (right_width if mirrored else left_width) + 28
	panel.offset_right = -18 if _portrait else -((left_width if mirrored else right_width) + 28)
	panel.offset_top = _party_bar_top()
	panel.offset_bottom = panel.offset_top + _party_bar_height()
	panel.add_theme_stylebox_override("panel", _pad(_chip_style(str(_hud_data.get("biome", "meadow"))), 12, 8, 12, 10))
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 2)
	panel.add_child(margin)
	var col := _vbox(margin, 4)
	var row := _hbox(col, 6)
	var buttons: Array[Button] = []
	for slot: int in 3:
		var button := _play_button("%d · Empty" % (slot + 1), &"select_item_slot", {"slot":slot}, false)
		button.clip_text = true
		button.add_theme_font_size_override("font_size", roundi(14 * _text_factor))
		button.custom_minimum_size.y = maxf(76, 56 * _control_factor)
		button.pressed.connect(func() -> void:
			_hud_data["selected_item_slot"] = slot
			update_hud({})
		)
		row.add_child(button)
		buttons.append(button)
	var use := _play_button("Use →", &"noop", {}, false)
	use.pressed.disconnect(use.pressed.get_connections()[0].callable)
	use.pressed.connect(func() -> void: intent.emit(&"use_item", {"slot":int(_hud_data.get("selected_item_slot", 0))}))
	use.custom_minimum_size.y = maxf(76, 56 * _control_factor)
	row.add_child(use)
	var effects := _label("", 14, MUTED, true)
	effects.autowrap_mode = TextServer.AUTOWRAP_OFF
	effects.clip_text = true
	col.add_child(effects)
	_hud_labels.items_panel = panel
	_hud_labels.item_buttons = buttons
	_hud_labels.item_use = use
	_hud_labels.item_effects = effects

func _party_bar_top() -> float:
	var top := maxf(150 * _text_factor + 16, 166)
	var header: Control = _hud_labels.get("top")
	if is_instance_valid(header) and header.size.y > 0: top = maxf(top, header.get_global_rect().end.y + 10)
	return top

func _party_bar_height() -> float:
	return maxf(76, 56 * _control_factor) + 42

func _party_items_enabled() -> bool:
	var items: Dictionary = _hud_data.get("items", {})
	return bool(items.get("enabled", false))

func _item_name(id: String) -> String:
	return {"slow_time":"Slow time", "bomb":"Bomb", "helper_drop":"Helper drop", "preview_peek":"Preview peek", "junk_rain":"Junk rain", "fog":"Fog", "speed_up":"Speed up", "spin_lock":"Spin lock"}.get(id, id.replace("_", " ").capitalize())

func _play_button(text: String, id: StringName, args: Dictionary, repeats: bool) -> Button:
	var b := _button(text, id, args, false, maxf(56.0, 56.0 * _control_factor))
	b.custom_minimum_size.x = 0
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# In-level controls are purple gem lozenges with gold rims (ref 15 pause gem).
	_gem_button(b, false)
	b.add_theme_font_size_override("font_size", roundi(16 * _text_factor))
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
	if _storybook_dock():
		var dock_top := 1.0 - (_dock_height() + 20.0) / viewport_size.y
		var bar_top := (16.0 + 64.0 + 40.0 + 72.0 * _text_factor) / viewport_size.y
		if _party_items_enabled(): bar_top = maxf(bar_top, (_party_bar_top() + _party_bar_height() + 12) / viewport_size.y)
		return Rect2(0.0, bar_top, 1.0, maxf(.2, dock_top - bar_top))
	if _portrait:
		var bottom := minf(.71, 1.0 - (_control_height() + 28.0) / viewport_size.y)
		var top := maxf(.22, (_party_bar_top() + _party_bar_height() + 12) / viewport_size.y) if _party_items_enabled() else .22
		return Rect2(.02, top, .96, maxf(.15, bottom - top))
	var cell := maxf(56.0, 56.0 * _control_factor)
	var left := (maxf(maxf(272.0, 220.0 * _text_factor), cell * 3.0 + 40.0) + 28.0) / viewport_size.x
	var right := (maxf(maxf(248.0, 200.0 * _text_factor), cell * 2.0 + 44.0) + 28.0) / viewport_size.x
	if bool(_prefs.get("left_hand", false)):
		var swap := left
		left = right
		right = swap
	var top := maxf(.24, (150.0 * _text_factor + 16.0) / viewport_size.y)
	if _party_items_enabled(): top = maxf(top, (_party_bar_top() + _party_bar_height() + 12) / viewport_size.y)
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
	if _portrait and _party_items_enabled():
		var board_top := _party_bar_top() + _party_bar_height() + 12
		var max_cell := (height - board_top - 200 - 28 - 120 - (_text_factor - 1) * 110) / 5
		_control_factor = minf(_control_factor, maxf(1, max_cell / 56))

## Back inside a local form or confirmation is handled before the controller pops.
func handle_back() -> bool:
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
	if current_screen == "modes":
		show_title(_snapshot)
		return true
	return false

func update_hud(data: Dictionary) -> void:
	_hud_data.merge(data, true)
	if _hud_labels.is_empty(): return
	_update_item_bar()
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
	_hud_labels.score.text = _grouped(int(_hud_data.get("score", 0)))
	var pace: int = int(_hud_data.get("star_pace", 3))
	for i: int in _hud_labels.get("stars", []).size():
		(_hud_labels.stars[i] as Label).add_theme_color_override("font_color", Kit.STAR_ON if i < pace else Kit.STAR_DIM)
	var shapes: Array = _hud_data.get("next_shapes", [])
	if _hud_labels.has("next_preview"):
		var first: Dictionary = shapes[0] if not shapes.is_empty() else {}
		_hud_labels.next_preview.cells = first.get("cells", [])
		_hud_labels.next_preview.tint = first.get("tint", Kit.GOLD)
		# The render is the NEXT piece; its name stays as the chip tooltip, not a caption.
		_hud_labels.next.visible = (first.get("cells", []) as Array).is_empty()
		(_hud_labels.next_preview as Control).get_parent().get_parent().tooltip_text = _hud_labels.next.text
	if _hud_labels.has("tray"):
		var held: Array = _hud_data.get("held_cells", [])
		var tray: Array = _hud_labels.tray
		var hold_entry: Dictionary = held[0] if not held.is_empty() else {}
		tray[0].cells = hold_entry.get("cells", [])
		tray[0].tint = hold_entry.get("tint", Kit.GOLD)
		for i: int in range(1, tray.size()):
			var entry: Dictionary = shapes[i] if i < shapes.size() else {}
			tray[i].cells = entry.get("cells", [])
			tray[i].tint = entry.get("tint", Kit.GOLD)
	_hud_labels.time.text = _time_text(_hud_data.get("time", 0.0))
	_hud_labels.clock.visible = bool(_prefs.get("show_clock", true))
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
		_hud_labels.rules.add_theme_color_override("font_color", Color("ff9a86"))
	else: _hud_labels.rules.add_theme_color_override("font_color", TEXT_SOFT)
	_hud_labels.rules_panel.visible = not _hud_labels.rules.text.strip_edges().is_empty()
	if int(_hud_data.get("round", 0)) > 0: _hud_labels.level.text += "  ·  Round %s" % str(_hud_data.round)

func _update_item_bar() -> void:
	var enabled := _party_items_enabled()
	_hud_labels.items_panel.visible = enabled
	if not enabled: return
	_hud_labels.items_panel.offset_top = _party_bar_top()
	_hud_labels.items_panel.offset_bottom = _party_bar_top() + _party_bar_height()
	var items: Dictionary = _hud_data.get("items", {})
	var slots: Array = items.get("slots", [])
	var count := clampi(slots.size(), 2, 3)
	var selected := clampi(int(_hud_data.get("selected_item_slot", 0)), 0, count - 1)
	_hud_data["selected_item_slot"] = selected
	for slot: int in 3:
		var button: Button = _hud_labels.item_buttons[slot]
		button.visible = slot < count
		var item: Dictionary = slots[slot] if slot < slots.size() and slots[slot] is Dictionary else {}
		var id := str(item.get("id", ""))
		button.text = "%d · %s" % [slot + 1, "Empty" if id.is_empty() else _item_name(id).replace(" ", "\n")]
		if bool(item.get("pending", false)): button.text = "%d · Waiting" % (slot + 1)
		button.tooltip_text = "Empty item slot" if id.is_empty() else _item_name(id) + (" · refunded" if bool(item.get("refunded", false)) else "")
		var face := _slot_style(slot == selected)
		for state: String in ["normal", "hover", "pressed"]: button.add_theme_stylebox_override(state, face)
	var item: Dictionary = slots[selected] if selected < slots.size() and slots[selected] is Dictionary else {}
	var id := str(item.get("id", ""))
	var target_missing := id in ["junk_rain", "fog", "speed_up", "spin_lock"] and not bool(_hud_data.get("item_target_available", false))
	_hud_labels.item_use.disabled = id.is_empty() or bool(item.get("pending", false)) or target_missing
	_hud_labels.item_use.text = "Waiting" if bool(item.get("pending", false)) else "Use →"
	_hud_labels.item_use.tooltip_text = "No active rival to receive this item" if target_missing else ("Waiting for the host" if bool(item.get("pending", false)) else "Use " + _item_name(id))
	var timers: Array[String] = []
	var effects: Dictionary = items.get("effects", {})
	for effect: Variant in effects:
		var state: Dictionary = effects[effect]
		timers.append("%s %ds" % [_item_name(str(effect)), ceili(float(state.get("remaining_ms", 0)) / 1000)])
	_hud_labels.item_effects.text = "  ·  ".join(timers)
	_hud_labels.item_effects.tooltip_text = _hud_labels.item_effects.text
	_hud_labels.item_effects.visible = not timers.is_empty()

func show_countdown(value: String) -> void:
	if not is_instance_valid(_countdown):
		_countdown = _label(value, 100, INK, true)
		_countdown.add_theme_constant_override("outline_size", 18)
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
		kit.add_child(_sign("YOUR KIT  ·  %d LEFT" % int(data.get("selection_remaining", 0))))
		for choice: Dictionary in data.get("kit_choices", []):
			var id := str(choice.get("shape_id", ""))
			var remaining := int(choice.get("remaining", 0))
			var button := _button(id.replace("_", " ").capitalize() + "  ×%d" % remaining, &"pick_shape", {"shape_id": id})
			button.disabled = remaining <= 0
			kit.add_child(button)
	if bool(capabilities.get("choose_down", false)):
		var directions := _card(content)
		directions.add_child(_sign("TRAVEL DIRECTION"))
		_direction_buttons(directions, data.get("allowed_down", []), &"choose_down")
	if bool(capabilities.get("ice_flick", false)):
		var flick := _card(content)
		flick.add_child(_sign("ICE FLICK  ·  %d LEFT" % int(capabilities.get("flicks_left", 0))))
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

func show_pause(data: Dictionary = {}) -> void:
	var col := _begin("pause", data, true)
	_header(col, "A little breather", str(data.get("level_name", "Everything waits for you.")))
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(center)
	var card := _card(center)
	card.custom_minimum_size.x = 300 if _portrait else 400
	card.add_child(_sign("Ⅱ", 40))
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
	var card := _card(content)
	card.add_child(_star_row(int(data.get("stars", 0)), 3, 72.0))
	card.add_child(_label(str(data.get("message", "Every tower teaches you something.")), 22, INK, true))
	var row := _hbox(card, 16)
	row.add_child(_stat_chip("SCORE", _grouped(int(data.get("score", 0)))))
	row.add_child(_stat_chip("TIME", _time_text(data.get("time", 0))))
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
		var row := _hbox(_strip(controls))
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
	var page := _vbox(margin, 18)
	page.add_child(_sign(title.to_upper()))
	return page

func _toggle_setting(parent: Node, title: String, key: String, fallback: bool) -> void:
	parent = _strip(parent)
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
	var row := _hbox(_strip(parent))
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
	var col := _vbox(_strip(parent), 4)
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

## A settings row on a wood plank strip (ref 04; PlankRow theme variation); returns the strip.
func _strip(parent: Node) -> PanelContainer:
	var strip := PanelContainer.new()
	strip.name = "PlankRow"
	strip.theme_type_variation = &"PlankRow"
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(strip)
	return strip

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
		content.add_child(_sign("YOUR FRIENDS"))
		for character in characters:
			var b := _button(str(character.get("name", "Cloud wizard")) + (" ✓" if bool(character.get("selected", false)) else ""), &"select_character", {"character_id": str(character.get("id", "c1"))})
			b.disabled = not bool(character.get("unlocked", true))
			content.add_child(b)
	if bool(data.get("can_undo", false)): content.add_child(_button("Undo last purchase", &"undo_purchase"))
	_finish()

func show_arcade(data: Dictionary = {}) -> void:
	var col := _begin("arcade", data)
	_header(col, "A little arcade adventure", "Toy-Box Trials or endless towers. Pick your next challenge.")
	var content := _scroll(col)
	var trials := _card(content)
	trials.add_child(_sign("TOY-BOX TRIALS", 24))
	trials.add_child(_label("Time a tower, turn parcels through gates,\nand build matching shadows. Three games, nine levels.", 18, MUTED, true))
	trials.add_child(_button("Play Toy-Box Trials  →", &"open_minigames", {}, true, 64))
	var card := _card(content)
	card.add_child(_sign("ARCADE", 28))
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
	var mode_list: Array = data.get("round_cards",data.get("modes",["clear_race","build_race","shape_race","survival"]))
	var mode_ids: Array[String] = []
	var toggles: Array[CheckButton] = []
	var network := _card(content)
	network.add_child(_sign("PLAY WITH FRIENDS"))
	var status := str(data.get("network_status", "offline"))
	var character_picker := OptionButton.new()
	character_picker.custom_minimum_size.y = 56
	var character_ids: Array[String] = ["c1", "c2", "c3", "c4"]
	var character_names: Array[String] = ["Cloud Wizard", "Lana", "Boulder", "Glim"]
	for character_name: String in character_names: character_picker.add_item(character_name)
	character_picker.select(maxi(0, character_ids.find(str(data.get("character", _prefs.get("character", "c1"))))))
	var party_selection: Dictionary = (data.get("party_perk_selection", {}) as Dictionary).duplicate(true)
	for character_id: String in character_ids:
		if not party_selection.has(character_id): party_selection[character_id] = []
	for item: Variant in data.get("party_perks", []):
		if not data.has("party_perk_selection") and item is Dictionary and item.get("owned", true) and item.get("equipped", false) and party_selection.has(str(item.get("character", ""))):
			var selected: Array = party_selection[str(item.character)]
			if str(item.id) not in selected: selected.append(str(item.id))
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
		var perk_controls: Array[Dictionary] = []
		if data.has("party_perks"):
			network.add_child(_label("Your owned party perks · choose up to two", 18))
			var empty := _label("No owned perks for this friend yet.", 16, MUTED)
			network.add_child(empty)
			for item: Variant in data.get("party_perks", []):
				if not item is Dictionary or not item.get("owned", true) or not party_selection.has(str(item.get("character", ""))): continue
				var id := str(item.id)
				var owner := str(item.character)
				var toggle := CheckButton.new()
				toggle.text = "%s  ·  %d%% edge" % [str(item.get("name", item.get("text", id.replace("_", " ").capitalize()))), roundi(float(item.get("edge", 0.0)) * 100)]
				toggle.custom_minimum_size.y = 52
				toggle.button_pressed = (party_selection[owner] as Array).has(id)
				toggle.toggled.connect(func(on: bool) -> void:
					var chosen: Array = party_selection[owner]
					if on:
						if chosen.size() >= 2:
							toggle.set_pressed_no_signal(false)
							show_toast("Choose up to two perks for this friend.")
							return
						if id not in chosen: chosen.append(id)
					else: chosen.erase(id)
					_snapshot["party_perk_selection"] = party_selection.duplicate(true)
				)
				network.add_child(toggle)
				perk_controls.append({"control":toggle,"character":owner})
			var refresh := func() -> void:
				var found: bool = false
				for entry: Dictionary in perk_controls:
					entry.control.visible = entry.character == character_ids[character_picker.selected]
					found = found or entry.control.visible
				empty.visible = not found
			refresh.call()
			character_picker.item_selected.connect(func(_index: int) -> void: refresh.call())
		character_picker.item_selected.connect(func(index: int) -> void: _snapshot["character"] = character_ids[index])
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
		host.pressed.connect(func() -> void:
			var args: Dictionary = {"name": name.text.strip_edges(), "port": int(port.value), "rounds": rounds.get_selected_id(), "character":character_ids[character_picker.selected]}
			if data.has("party_perks"): args["perks"] = (party_selection[character_ids[character_picker.selected]] as Array).duplicate()
			args["modes"] = _party_mode_selection(mode_ids,toggles)
			if args.modes.is_empty():
				show_toast("Pick at least one toy box for the party.")
				return
			intent.emit(&"host_lan", args)
		)
		row.add_child(host)
		var join := _button("Join party", &"noop", {}, false, 56)
		join.pressed.disconnect(join.pressed.get_connections()[0].callable)
		join.pressed.connect(func() -> void:
			if address.text.strip_edges().is_empty():
				show_toast("Enter your friend's host IP first.")
				address.grab_focus()
				return
			var args: Dictionary = {"name": name.text.strip_edges(), "address": address.text.strip_edges(), "port": int(port.value), "character":character_ids[character_picker.selected]}
			if data.has("party_perks"): args["perks"] = (party_selection[character_ids[character_picker.selected]] as Array).duplicate()
			intent.emit(&"join_lan", args)
		)
		row.add_child(join)
	var pool := _card(content)
	pool.add_child(_sign("WHAT GOES IN THE TOY BOX?"))
	pool.add_child(_label("Choose the versus rounds and minigames your party can draw.",16,MUTED))
	var selected_modes: Array = data.get("selected_modes",[])
	var category := ""
	for entry: Variant in mode_list:
		var id := str(entry.get("id",entry.get("mode",""))) if entry is Dictionary else str(entry)
		var name := str(entry.get("name",id.replace("_"," ").capitalize())) if entry is Dictionary else id.replace("_"," ").capitalize()
		var current_category := str(entry.get("category","Versus")) if entry is Dictionary else ("Minigames" if id.begins_with("mg") else "Versus")
		if current_category != category:
			pool.add_child(_sign(current_category.to_upper(), 18))
			category = current_category
		var toggle := CheckButton.new()
		toggle.text = name
		toggle.tooltip_text = str(entry.get("rule",name)) if entry is Dictionary else name
		toggle.button_pressed = selected_modes.is_empty() or id in selected_modes
		toggle.disabled = status != "offline"
		toggle.custom_minimum_size.y = 56
		pool.add_child(toggle)
		mode_ids.append(id)
		toggles.append(toggle)
		toggle.toggled.connect(func(_on: bool)->void: _snapshot["selected_modes"] = _party_mode_selection(mode_ids,toggles))
	if status == "offline":
		var practice := _card(content)
		practice.add_child(_sign("PRACTISE WITH TOY FRIENDS"))
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
		var start := _button("Start practice  →", &"noop", {}, false, 60)
		start.pressed.disconnect(start.pressed.get_connections()[0].callable)
		start.pressed.connect(func() -> void:
			var modes: Array = _party_mode_selection(mode_ids,toggles)
			if modes.is_empty():
				show_toast("Pick at least one party mode.")
				return
			var players: Array = [{"name": str(data.get("profile_name", "You")), "is_bot": false, "character_id": character_ids[character_picker.selected]}]
			if data.has("party_perks"): players[0]["perks"] = (party_selection[character_ids[character_picker.selected]] as Array).duplicate()
			for i in range(1, count.get_selected_id()): players.append({"name": ["Pip", "Miller", "Clover"][i - 1], "is_bot": true, "character_id": "c%d" % (i + 1)})
			intent.emit(&"start_tournament", {"rounds": rounds.get_selected_id(), "players": players, "items": items.button_pressed, "modes": modes})
		)
		practice.add_child(start)
	_finish()

func _party_mode_selection(ids: Array[String],toggles: Array[CheckButton]) -> Array[String]:
	var selected: Array[String] = []
	for index: int in mini(ids.size(),toggles.size()):
		if toggles[index].button_pressed: selected.append(ids[index])
	return selected

func show_minigame(data: Dictionary = {}) -> void:
	var col := _begin("minigame", data)
	_minigame_view = MinigameStage.instantiate()
	_minigame_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_minigame_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_minigame_view.set_prefs(_prefs)
	_minigame_view.set_snapshot(data)
	_minigame_view.intent.connect(func(id: StringName, args: Dictionary) -> void: intent.emit(id,args))
	col.add_child(_minigame_view)

func update_minigame(data: Dictionary) -> void:
	_snapshot = data.duplicate(true)
	if current_screen == "minigame" and is_instance_valid(_minigame_view): _minigame_view.set_snapshot(data)

func show_round_card(data: Dictionary = {}) -> void:
	var col := _begin("round_card", data)
	_round_widgets = {}
	_header(col, "What's in the next toy box?", "Round %d" % int(data.get("round_index",1)), false)
	var content := _scroll(col)
	var card := _card(content, CREAM)
	var icon := TextureRect.new()
	icon.name = "RoundIcon"
	icon.custom_minimum_size = Vector2(140,140)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card.add_child(icon)
	_round_widgets.icon = icon
	var landmark: SubViewportContainer = preload("res://src/ui/minigame_ui.gd").make_art_preview(str((data.get("template",{}) as Dictionary).get("id","mg01")),Vector2i(220,160))
	card.add_child(landmark)
	_round_widgets.landmark = landmark
	_round_widgets.name = _label("",40,INK,true)
	card.add_child(_round_widgets.name)
	_round_widgets.rule = _label("",24,INK,true)
	card.add_child(_round_widgets.rule)
	_round_widgets.phase = _label("",22,MUTED,true)
	card.add_child(_round_widgets.phase)
	var reroll := _button("Another toy box?  ↻", &"noop",{},false,60)
	reroll.pressed.disconnect(reroll.pressed.get_connections()[0].callable)
	reroll.pressed.connect(func() -> void: intent.emit(&"reroll",{"player_id":str(_snapshot.get("local_player_id",""))}))
	card.add_child(reroll)
	_round_widgets.reroll = reroll
	var ready := _button("Ready  ✓", &"round_ready",{},true,60)
	card.add_child(ready)
	_round_widgets.ready = ready
	_round_widgets.standings = _vbox(content)
	update_round_card(data)
	_finish()

func update_round_card(data: Dictionary) -> void:
	_snapshot = data.duplicate(true)
	if current_screen != "round_card" or _round_widgets.is_empty(): return
	var template: Dictionary = data.get("template",{})
	_round_widgets.name.text = str(template.get("name","Opening the toy box…"))
	_round_widgets.rule.text = str(template.get("rule",""))
	var phase := str(data.get("phase","roulette"))
	var seconds := ceili(maxi(0,int(data.get("remaining_ms",0)))/1000.0)
	_round_widgets.phase.text = {"roulette":"Picking a surprise…", "round_show":"A new little challenge", "reroll":"One last chance to swap · %ds"%seconds, "locked":"The toy box is ready", "countdown":"%d"%seconds}.get(phase,"Get ready")
	var local_id := str(data.get("local_player_id",""))
	var eligible: Array = data.get("reroll_eligible",[])
	_round_widgets.reroll.visible = phase in ["reroll","round_show"] and bool(data.get("can_reroll", eligible.has(local_id)))
	_round_widgets.reroll.disabled = seconds <= 0 or bool(data.get("reroll_used",false))
	_round_widgets.ready.visible = phase in ["locked","round_show"]
	_round_widgets.ready.disabled = bool(data.get("ready",false))
	_round_widgets.ready.text = "Ready ✓ · waiting for friends" if bool(data.get("ready",false)) else "Ready  ✓"
	_round_widgets.icon.texture = _minigame_icon(str(template.get("id","")))
	_round_widgets.icon.visible = _round_widgets.icon.texture != null
	_round_widgets.landmark.visible = _round_widgets.icon.texture == null
	var rows: VBoxContainer = _round_widgets.standings
	for child: Node in rows.get_children():
		rows.remove_child(child)
		child.queue_free()
	for player: Dictionary in data.get("standings",[]): rows.add_child(_label("%s   ·   %d wins"%[str(player.get("name",player.get("id","Friend"))),int(player.get("wins",0))],18,INK,true))

func _minigame_icon(id: String) -> Texture2D:
	var path := "res://assets/art/minigames/%s.png" % id
	return load(path) if id.begins_with("mg") and ResourceLoader.exists(path) else null

func show_round_results(data: Dictionary = {}) -> void:
	var col := _begin("round_results",data)
	_header(col,"A round of applause!" if not bool(data.get("tournament_done",false)) else "Our toy-box champion",str(data.get("round_name","")),false)
	var content := _scroll(col)
	var card := _card(content)
	var standings: Array = data.get("standings",[])
	var top_wins := 1
	for player: Dictionary in standings: top_wins = maxi(top_wins, int(player.get("wins",0)))
	for index: int in standings.size():
		var player: Dictionary = standings[index]
		card.add_child(_standing_row(index + 1, str(player.get("name",player.get("id","Friend"))), int(player.get("wins",0)), top_wins))
	for award: Dictionary in data.get("awards",[]): card.add_child(_label("%s · %s"%[str(award.get("name","Little triumph")),str(award.get("player_name",""))],20,INK,true))
	for result: Dictionary in data.get("results",[]):
		card.add_child(_label("%s   %s"%[str(result.get("name",result.get("id","Friend"))),str(result.get("standing_value",result.get("score",0)))],20))
	var history: Array = data.get("history",[])
	if not history.is_empty():
		content.add_child(_sign("OUR LITTLE TOURNAMENT"))
		for index: int in history.size():
			var row: Dictionary = history[index]
			content.add_child(_label("%d · %s · %s"%[index+1,str(row.get("name",row.get("mode","Round"))).replace("_"," ").capitalize(),", ".join(PackedStringArray(row.get("winner_names",row.get("winners",[]))))],18))
	card.add_child(_button("Back to the party" if bool(data.get("tournament_done",false)) else "Next toy box  →",&"to_party" if bool(data.get("tournament_done",false)) else &"next_round",{},true,60))
	_finish()

func show_physics(data: Dictionary = {}) -> void:
	var col := _begin("physics", data)
	_header(col, "The physics toy box", "Weight, wobble and a little bit of mischief.")
	var content := _scroll(col)
	var card := _card(content)
	var variants: Array = data.get("variants", PHYSICS_VARIANTS)
	card.add_child(_sign("PICK A CHALLENGE"))
	var picker := OptionButton.new()
	picker.custom_minimum_size = Vector2(320, 56)
	picker.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
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
		"modes": show_modes(data)
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
		"minigame": show_minigame(data)
		"round_card": show_round_card(data)
		"round_results": show_round_results(data)
		"tools": show_tools(data)
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
