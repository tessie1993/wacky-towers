class_name WtStorybook extends RefCounted
## Storybook UI kit: open purple-wood frames over a painted scene, translucent plum glass and
## wood-plank content groups, gold / purple / wood pills, cream lettering with a plum outline.
## No parchment fill: the user rejected beige interiors (refs 05 open frame, 04 wood planks).
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
## Lettering on the scene, glass and wood: cream face, plum outline (AA on every kit surface).
const TEXT := Color("fff6e6")
const TEXT_SOFT := Color("e6dcf7")
const TEXT_OUTLINE := Color("2a1838")
## Translucent plum glass for content groups and the soft lilac rim inside it.
const GLASS := Color(0.247, 0.165, 0.333, 0.82)
const GLASS_RIM := Color(0.604, 0.471, 0.722, 0.6)
## Wood plank strip (ref 04 rows): darkened wood so cream text clears 4.5:1.
const PLANK := Color("6e4426")
const PLANK_EDGE := Color("3a2212")
## Plum ramp that replaces parchment pixels in kit pieces (dark end, light end).
const PLUM_RAMP_DARK := Color("2e1d40")
const PLUM_RAMP_LIGHT := Color("5a3f78")
## Purple pill ramp (secondary buttons, unselected tabs).
const PILL_RAMP_DARK := Color("2a1838")
const PILL_RAMP_LIGHT := Color("8a68ad")
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


## Content group: translucent plum glass (wood=false) or the rope-bordered plank panel (wood=true).
static func panel_box(wood: bool = false) -> StyleBox:
	if not wood: return glass_box()
	var box: StyleBoxTexture = kit_box("panel_wood", 16.0)
	return box if box != null else plank_box()


## Main window: thick purple-wood frame with star caps and vines (refs 05/06). The centre is
## open by default so the painted scene shows through; `open = false` fills it with plum glass.
static func frame_box(open: bool = true) -> StyleBox:
	var box: StyleBoxTexture = kit_box("frame_purple_open", 24.0)
	if box == null: return panel(Color(0, 0, 0, 0) if open else GLASS, WOOD_PURPLE, 24, 10)
	box.draw_center = not open
	if not open: box.modulate_color = Color(1, 1, 1, 1)
	return box


## Translucent plum glass panel for content groups on the scene: WOOD_PURPLE_DARK at `alpha`,
## a soft lilac inner rim and a plum drop shadow. Cream text on it is above 7:1.
static func glass_box(alpha: float = GLASS.a, radius: int = 18) -> StyleBoxFlat:
	var s := panel(Color(GLASS, alpha), GLASS_RIM, radius, 2)
	s.border_width_bottom = 2
	s.shadow_color = Color(0.1, 0.04, 0.16, 0.3)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 4)
	return s


## Wood plank strip (ref 04 settings rows): dark wood face, a deeper bottom lip, rounded ends.
static func plank_box(radius: int = 12) -> StyleBoxFlat:
	var s := panel(PLANK, PLANK_EDGE, radius, 2)
	s.border_width_bottom = 5
	s.shadow_size = 3
	s.shadow_offset = Vector2(0, 2)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 8
	s.content_margin_bottom = 10
	return s


## Cream lettering with a plum outline (and soft shadow) for text on the scene, glass or wood.
static func outline(control: Control, font_size: int = 18, color: Color = TEXT) -> void:
	control.add_theme_color_override("font_color", color)
	control.add_theme_color_override("font_outline_color", TEXT_OUTLINE)
	control.add_theme_constant_override("outline_size", clampi(roundi(font_size / 4.0), 4, 12))
	control.add_theme_color_override("font_shadow_color", Color(TEXT_OUTLINE, 0.45))
	control.add_theme_constant_override("shadow_offset_x", 0)
	control.add_theme_constant_override("shadow_offset_y", maxi(2, font_size / 12))


## True for the warm light pixels of the kit's parchment paint (cream, ivory, sand).
static func is_parchment(c: Color) -> bool:
	return c.a > 0.02 and c.r > 0.78 and c.g > 0.62 and c.b > 0.42 and c.r - c.b < 0.5 and c.r >= c.g - 0.02


## Gradient-maps pixels (all, or only parchment ones when `parchment_only`) to `dark`..`light`
## by luminance, keeping each pixel's alpha times `alpha`. `region` (normalised) limits the
## change, e.g. the track of toggle_off but not its knob. Returns a new RGBA8 image.
static func recolor_image(source: Image, dark: Color, light: Color, parchment_only: bool = true, alpha: float = 1.0, region: Rect2 = Rect2(0, 0, 1, 1)) -> Image:
	var image := source.duplicate() as Image
	if image.is_compressed(): image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	var w := image.get_width()
	var h := image.get_height()
	var x0 := floori(region.position.x * w)
	var x1 := ceili(region.end.x * w)
	var y0 := floori(region.position.y * h)
	var y1 := ceili(region.end.y * h)
	var low := 0.7 if parchment_only else 0.25
	for y: int in range(y0, mini(y1, h)):
		for x: int in range(x0, mini(x1, w)):
			var c := image.get_pixel(x, y)
			if c.a <= 0.0 or (parchment_only and not is_parchment(c)): continue
			var lum := c.r * 0.3 + c.g * 0.55 + c.b * 0.15
			var t := clampf((lum - low) / (1.0 - low), 0.0, 1.0)
			var out := dark.lerp(light, t)
			out.a = c.a * alpha
			image.set_pixel(x, y, out)
	return image


## HUD chip (SCORE, NEXT) in the biome's frame: meadow vines, ice frost, celestial gold.
static func chip_box(biome: String = "meadow") -> StyleBox:
	var box: StyleBoxTexture = kit_box(String(BIOME_CHIPS.get(biome, "chip_hud")), 10.0)
	return box if box != null else panel(GLASS, biome_frame(biome), 14, 6)


## Carved brown signboard for section headings ("AUDIO", card labels).
static func sign_box() -> StyleBox:
	var box: StyleBoxTexture = kit_box("sign_heading", 8.0)
	return box if box != null else pill(WOOD, WOOD_DARK, false, 12)


## Purple-wood title plaque with gold trim and curls ("SELECT MODE").
static func plaque_box() -> StyleBox:
	var box: StyleBoxTexture = kit_box("plaque_title", 12.0)
	return box if box != null else panel(WOOD_PURPLE, GOLD, 40, 6)


## Flat panel (plum glass by default) inside a painted-wood frame, with a soft drop shadow.
static func panel(fill: Color = GLASS, frame: Color = WOOD, radius: int = 20, frame_width: int = 5) -> StyleBoxFlat:
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


## Applies gold (primary) or purple (secondary) pill styles to a button (flat fallback when the
## kit's btn_cream piece is missing it is used unchanged only as a gold pill).
static func style_button(button: Button, primary: bool, radius: int = 40) -> void:
	var normal: StyleBoxTexture = kit_box("btn_gold", 10.0) if primary else null
	if normal != null:
		var pressed: StyleBoxTexture = kit_box("btn_gold", 10.0)
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
	var fill: Color = GOLD if primary else WOOD_PURPLE
	var lip: Color = GOLD_DEEP if primary else WOOD_PURPLE_DARK
	button.add_theme_stylebox_override("normal", pill(fill, lip, false, radius))
	button.add_theme_stylebox_override("hover", pill(fill.lightened(0.08), lip, false, radius))
	button.add_theme_stylebox_override("pressed", pill(fill, lip, true, radius))
	button.add_theme_stylebox_override("disabled", pill(fill.lerp(Color("d9d0c3"), 0.6), lip.lerp(Color("a89a8a"), 0.6), false, radius))
	var focus := pill(Color(0, 0, 0, 0), Color("ffffff"), false, radius)
	focus.draw_center = false
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_color_override("font_color", PLUM if primary else TEXT)
	button.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.55) if primary else TEXT_OUTLINE)
	button.add_theme_constant_override("outline_size", 2 if primary else 4)


## Painted scene for a biome (sky gradient, sun haze, cloud wisps, rounded mesas with
## waterfalls, cloud sea): the in-game sky shader with the biome's `env.sky` spec from
## biome_looks.json, so menus and mode cards share the level art. `motion` 0 freezes clouds.
static func backdrop(biome: String = "meadow", motion: float = 1.0) -> ColorRect:
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var record: Dictionary = WtBlockMaterials.look(StringName(biome))
	var sky: Array = record.get("sky", ["#4F94E6", "#CFE6FB", "#FFF4E6"])
	var spec: Dictionary = (record.get("env", {}) as Dictionary).get("sky", {})
	var material := ShaderMaterial.new()
	material.shader = load(SKY_SHADER) as Shader
	material.set_shader_parameter(&"top", Color(String(sky[0])))
	material.set_shader_parameter(&"horizon", Color(String(sky[mini(1, sky.size() - 1)])))
	material.set_shader_parameter(&"low", Color(String(sky[sky.size() - 1])))
	for key: String in ["cloud", "cloud_shade", "mountains", "nebula_a", "nebula_b", "mesa_top", "mesa_rock", "peak_rock", "peak_snow", "castle_color", "castle_roof"]:
		if spec.has(key): material.set_shader_parameter(StringName(key), Color(String(spec[key])))
	for key: String in ["cloud_amount", "mountain_amount", "stars", "nebula", "sun", "sea_line", "mesa_amount", "mesa_falls", "cloud_bank", "mesa_round", "peaks", "castle"]:
		if spec.has(key): material.set_shader_parameter(StringName(key), float(spec[key]))
	if spec.has("castle_pos"):
		var cp: Array = spec["castle_pos"]
		material.set_shader_parameter(&"castle_pos", Vector2(float(cp[0]), float(cp[1])))
	material.set_shader_parameter(&"motion", motion)
	rect.material = material
	return rect


## A transparent PNG sprite from assets/art/ui (logo, wizard poses), or null if missing.
static func sprite(name: String) -> Texture2D:
	var path: String = SPRITES + name + ".png"
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


## Frame colour for a biome's HUD tray (vines green for meadow, frost blue for ice...).
static func biome_frame(biome: String) -> Color:
	return Color(String(WtBlockMaterials.look(StringName(biome)).get("frame", "#8a5a34")))
