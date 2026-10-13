class_name WtStorybook extends RefCounted
## Storybook UI kit: painted-wood frames, parchment panels, gold pills, plum ink.
## Reference: assets/art/reference/style/05, 06, 04, 08, 14, 15. Colours are the art-bible
## tokens (design/art/art-bible.md section 2). Used by GameUi for every screen and the HUD.
##
## Kit v2 pieces (assets/art/ui/kit/x1, built by assets/source/blender/ui/build_ui_kit.py):
## frame_purple, frame_purple_open, panel_parchment, panel_wood, plaque_title, btn_gold,
## btn_cream, btn_close, chip_hud (meadow), chip_hud_ice, chip_hud_celestial, tray_slot,
## toggle_on, toggle_off, slider_track, slider_star_thumb, sign_heading.

const PLUM := Color("3b2346")          # ink
const PLUM_SOFT := Color("6e5578")
const PARCHMENT := Color("f6e7c4")     # parchment
const PARCHMENT_DEEP := Color("e2c995")  # parchment_shade
const WOOD := Color("8a5a34")          # wood_brown
const WOOD_DARK := Color("4e2f1a")     # wood_brown_dark
const WOOD_PURPLE := Color("6b4a8a")
const WOOD_PURPLE_DARK := Color("3f2a55")
const WOOD_PURPLE_LIGHT := Color("9a78b8")
const GOLD := Color("f8c840")
const GOLD_DEEP := Color("c98418")
const GOLD_GLINT := Color("fff3b0")
const VINE_GREEN := Color("4f9a3a")
const LEAF_LIGHT := Color("8fd05a")
const DANGER_RED := Color("e0483c")
const GO_GREEN := Color("4cc04a")
const CREAM_PILL := Color("fff4dc")
const STAR_ON := Color("f8c840")
const STAR_OFF := Color("cdbfa6")
## Multicolour display-title letters, cycled per glyph (orange, cream, blue, green, lilac, pink).
const TITLE_COLORS: Array[Color] = [Color("f08a2c"), Color("f6e2b8"), Color("4aa8e8"), Color("6cc04a"), Color("b48ad8"), Color("ee6aa0")]
## HUD chip piece per biome; other biomes fall back to the meadow chip.
const BIOME_CHIPS := {"meadow": "chip_hud", "ice": "chip_hud_ice", "celestial": "chip_hud_celestial"}
const FONT_PATH := "res://assets/fonts/fredoka/fredoka-600.woff2"
const FONT_BOLD_PATH := "res://assets/fonts/fredoka/fredoka-700.woff2"
const SKY_SHADER := "res://src/view/shaders/canvas_env_sky.gdshader"
const SPRITES := "res://assets/art/ui/"
## Blender-rendered nine-patch kit: 1x copies of the 2x renders, margins in x1 pixels.
const KIT_JSON := "res://assets/art/ui/kit/x1/ninepatch_x1.json"
## 2x masters live in kit/x2; the x1 files are already downscaled, so they draw 1:1.
const KIT_SCALE := 0.5

static var _kit: Dictionary = {}

static var _fonts: Dictionary = {}


## The rounded storybook font (Fredoka, OFL). `bold` picks the 700 weight for titles.
static func font(bold: bool = false) -> Font:
	var path: String = FONT_BOLD_PATH if bold else FONT_PATH
	if not _fonts.has(path):
		var loaded: Font = load(path) as Font if ResourceLoader.exists(path) else null
		if loaded is FontFile:
			# Fredoka ships Latin only; symbols such as stars fall back to the engine font.
			(loaded as FontFile).fallbacks = [ThemeDB.fallback_font]
		_fonts[path] = loaded if loaded != null else ThemeDB.fallback_font
	return _fonts[path]


## Nine-patch StyleBoxTexture for a kit piece (panel_wood, btn_gold_pill...), or null if missing.
static func kit_box(name: String, content: float = 12.0) -> StyleBoxTexture:
	if _kit.is_empty() and FileAccess.file_exists(KIT_JSON):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(KIT_JSON))
		if parsed is Dictionary: _kit = (parsed as Dictionary).get("patches", {})
	var entry: Dictionary = _kit.get(name, {})
	var path: String = String(entry.get("file", "res://assets/art/ui/kit/x1/%s.png" % name))
	if not ResourceLoader.exists(path): return null
	var box := StyleBoxTexture.new()
	box.texture = load(path) as Texture2D
	box.texture_margin_left = float(entry.get("left", 48))
	box.texture_margin_top = float(entry.get("top", 48))
	box.texture_margin_right = float(entry.get("right", 48))
	box.texture_margin_bottom = float(entry.get("bottom", 48))
	box.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	box.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	for side: int in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		box.set_content_margin(side, maxf(content, box.get_texture_margin(side) * 0.8))
	return box


## A kit texture by name (btn_close, toggle_on, slider_star_thumb...), or null.
static func kit_texture(name: String) -> Texture2D:
	for path: String in ["res://assets/art/ui/kit/x1/%s.png" % name, "res://assets/art/ui/kit/%s.png" % name]:
		if ResourceLoader.exists(path): return load(path) as Texture2D
	return null


## Parchment panel (wood=false) or rope-bordered plank panel (wood=true); flat fallback otherwise.
static func panel_box(wood: bool = false) -> StyleBox:
	var box: StyleBoxTexture = kit_box("panel_wood" if wood else "panel_parchment", 16.0)
	return box if box != null else panel()


## Main window: thick purple-wood frame with star caps and vines (refs 05/06).
## `open` leaves the centre transparent so a scene shows through; otherwise parchment fills it.
static func frame_box(open: bool = false) -> StyleBox:
	var box: StyleBoxTexture = kit_box("frame_purple_open" if open else "frame_purple", 24.0)
	if box == null: return panel(PARCHMENT, WOOD_PURPLE, 24, 10)
	if open: box.draw_center = false
	return box


## HUD chip (SCORE, NEXT) in the biome's frame: meadow vines, ice frost, celestial gold.
static func chip_box(biome: String = "meadow") -> StyleBox:
	var box: StyleBoxTexture = kit_box(String(BIOME_CHIPS.get(biome, "chip_hud")), 10.0)
	return box if box != null else panel(PARCHMENT, biome_frame(biome), 14, 6)


## Carved brown signboard for section headings ("AUDIO", card labels).
static func sign_box() -> StyleBox:
	var box: StyleBoxTexture = kit_box("sign_heading", 8.0)
	return box if box != null else pill(WOOD, WOOD_DARK, false, 12)


## Purple-wood title plaque with gold trim and curls ("SELECT MODE").
static func plaque_box() -> StyleBox:
	var box: StyleBoxTexture = kit_box("plaque_title", 12.0)
	return box if box != null else panel(WOOD_PURPLE, GOLD, 40, 6)


## Parchment panel inside a painted-wood frame, with a soft drop shadow.
static func panel(fill: Color = PARCHMENT, frame: Color = WOOD, radius: int = 20, frame_width: int = 5) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = frame
	s.set_border_width_all(frame_width)
	s.border_width_bottom = frame_width + 2
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0.15, 0.06, 0.2, 0.28)
	s.shadow_size = 6
	s.shadow_offset = Vector2(0, 4)
	s.anti_aliasing = true
	for side: int in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		s.set_content_margin(side, 14)
	return s


## Chunky pill button: a thick darker lip under the face reads as a pressable toy.
static func pill(fill: Color, lip: Color, pressed: bool = false, radius: int = 40) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill.darkened(0.06) if pressed else fill
	s.border_color = lip
	s.set_border_width_all(3)
	s.border_width_bottom = 3 if pressed else 7
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0.15, 0.06, 0.2, 0.25)
	s.shadow_size = 0 if pressed else 4
	s.shadow_offset = Vector2(0, 3)
	s.anti_aliasing = true
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 10 + (4 if pressed else 0)
	s.content_margin_bottom = 10
	return s


## Applies gold (primary) or cream (secondary) pill styles to a button.
static func style_button(button: Button, primary: bool, radius: int = 40) -> void:
	var kit_name: String = "btn_gold" if primary else "btn_cream"
	var normal: StyleBoxTexture = kit_box(kit_name, 10.0)
	if normal != null:
		var pressed: StyleBoxTexture = kit_box(kit_name, 10.0)
		pressed.modulate_color = Color(0.88, 0.85, 0.82)
		pressed.content_margin_top += 3.0
		var hover: StyleBoxTexture = normal.duplicate()
		hover.modulate_color = Color(1.08, 1.08, 1.08)
		var disabled: StyleBoxTexture = normal.duplicate()
		disabled.modulate_color = Color(0.75, 0.72, 0.7, 0.8)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_stylebox_override("disabled", disabled)
		var ring := StyleBoxEmpty.new()
		button.add_theme_stylebox_override("focus", ring)
		button.add_theme_color_override("font_color", PLUM)
		button.add_theme_color_override("font_pressed_color", PLUM)
		button.add_theme_color_override("font_hover_color", PLUM)
		return
	var fill: Color = GOLD if primary else CREAM_PILL
	var lip: Color = GOLD_DEEP if primary else WOOD
	button.add_theme_stylebox_override("normal", pill(fill, lip, false, radius))
	button.add_theme_stylebox_override("hover", pill(fill.lightened(0.08), lip, false, radius))
	button.add_theme_stylebox_override("pressed", pill(fill, lip, true, radius))
	button.add_theme_stylebox_override("disabled", pill(fill.lerp(Color("d9d0c3"), 0.6), lip.lerp(Color("a89a8a"), 0.6), false, radius))
	var focus := pill(Color(0, 0, 0, 0), Color("ffffff"), false, radius)
	focus.draw_center = false
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_color_override("font_color", PLUM if primary else PLUM)
	button.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.55) if primary else Color(0, 0, 0, 0))
	button.add_theme_constant_override("outline_size", 2 if primary else 0)


## Full-screen painted sky (lavender storybook default, or a biome's sky colours).
static func backdrop(colors: Array = ["#b7a1e6", "#e6dbf6", "#fbefe0"], cloud: String = "#ffffff", far: String = "#c8b8e8") -> ColorRect:
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = load(SKY_SHADER) as Shader
	material.set_shader_parameter(&"top", Color(String(colors[0])))
	material.set_shader_parameter(&"middle", Color(String(colors[1])))
	material.set_shader_parameter(&"bottom", Color(String(colors[2])))
	material.set_shader_parameter(&"cloud", Color(cloud))
	material.set_shader_parameter(&"far_island", Color(far))
	rect.material = material
	return rect


## A transparent PNG sprite from assets/art/ui (logo, wizard poses), or null if missing.
static func sprite(name: String) -> Texture2D:
	var path: String = SPRITES + name + ".png"
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


## Frame colour for a biome's HUD tray (vines green for meadow, frost blue for ice...).
static func biome_frame(biome: String) -> Color:
	return Color(String(WtBlockMaterials.look(StringName(biome)).get("frame", "#8a5a34")))
