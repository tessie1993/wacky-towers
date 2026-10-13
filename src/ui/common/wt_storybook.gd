class_name WtStorybook extends RefCounted
## Storybook UI kit: painted-wood frames, parchment panels, gold pills, plum ink.
## Reference: assets/art/reference/title_screen_ref.png, screens_flow_ref.png,
## tournament_flow_ref.png. Used by GameUi for every screen and the HUD.

const PLUM := Color("3b2346")
const PLUM_SOFT := Color("6e5578")
const PARCHMENT := Color("fbf1dc")
const PARCHMENT_DEEP := Color("efdfbd")
const WOOD := Color("8a5a34")
const WOOD_DARK := Color("5b3920")
const GOLD := Color("f7c548")
const GOLD_DEEP := Color("c98a1e")
const CREAM_PILL := Color("fff4dc")
const STAR_ON := Color("f6b92b")
const STAR_OFF := Color("cdbfa6")
const FONT_PATH := "res://assets/fonts/fredoka/fredoka-600.woff2"
const FONT_BOLD_PATH := "res://assets/fonts/fredoka/fredoka-700.woff2"
const SKY_SHADER := "res://src/view/shaders/canvas_env_sky.gdshader"
const SPRITES := "res://assets/art/ui/"

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
