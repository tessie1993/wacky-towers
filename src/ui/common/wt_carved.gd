class_name WtCarved extends RefCounted
## Carved purple-wood HUD plaques (ref 15 chips, in purple per the no-beige rule).
## The kit's chip_hud render (bevelled wood rim, leaf and flower vines, parchment face) is
## gradient-mapped at load: wood becomes purple wood, parchment becomes plum glass, vine greens
## and flower petals are kept. Result is cached per (kit piece, tint, scale).

const KIT_2X := "res://assets/art/ui/kit/x2/%s.png"
## Margins in the final (scaled) texture: the x2 master is drawn at SCALE for a chunkier bevel.
const SCALE := 0.75
const KIT_MARGIN := {"chip_hud": 56, "tray_slot": 42}
const ALPHA_FLOOR := 24.0
## Plum face ramp (dark at the rim, lighter in the middle).
const FACE_DARK := Color("2b1a3d")
const FACE_LIGHT := Color("4a3166")
## Purple-wood ramp for the carved rim, dark to lit.
const WOOD_DARK := Color("2f1d45")
const WOOD_LIGHT := Color("a47fc4")

static var _cache: Dictionary = {}


## A nine-patch StyleBoxTexture of the carved purple plaque. `kit_piece` is "chip_hud" or
## "tray_slot"; `rim_tint` shifts the wood toward a biome hue (Color.WHITE keeps pure purple).
## Returns null when the kit art is missing so callers can fall back to WtStorybook.chip_flat.
static func plaque_box(kit_piece: String = "chip_hud", rim_tint: Color = Color.WHITE, lit: bool = false) -> StyleBoxTexture:
	var texture := _texture(kit_piece, rim_tint, lit)
	if texture == null: return null
	var margin := float(KIT_MARGIN.get(kit_piece, 37))
	var box := StyleBoxTexture.new()
	box.texture = texture
	for side: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		box.set_texture_margin(side, float(KIT_MARGIN.get(kit_piece, 37)))
		box.set_content_margin(side, margin * 0.55)
	box.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	box.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	return box


## True for kit paint that is the warm cream face (cream, ivory, sand).
static func _is_face(c: Color) -> bool:
	return c.r > 0.72 and c.g > 0.58 and c.b > 0.36 and c.r - c.b < 0.55 and c.r >= c.g - 0.02


## Greens (vines, leaves) and near-white petals are kept as painted.
static func _is_kept(c: Color) -> bool:
	if c.g > c.r * 1.02 and c.g > c.b * 1.1: return true
	return c.r > 0.9 and c.g > 0.9 and c.b > 0.9


static func _texture(kit_piece: String, rim_tint: Color, lit: bool) -> Texture2D:
	var key := "%s|%s|%s" % [kit_piece, rim_tint.to_html(), lit]
	if _cache.has(key): return _cache[key]
	var path := KIT_2X % kit_piece
	if not ResourceLoader.exists(path):
		_cache[key] = null
		return null
	var source := (load(path) as Texture2D).get_image()
	if source == null: return null
	var image := source.duplicate() as Image
	if image.is_compressed(): image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	image.resize(roundi(image.get_width() * SCALE), roundi(image.get_height() * SCALE), Image.INTERPOLATE_LANCZOS)
	var gain := 255.0 / (255.0 - ALPHA_FLOOR)
	var wood_dark := WOOD_DARK.lerp(rim_tint, 0.18) if rim_tint != Color.WHITE else WOOD_DARK
	var wood_light := WOOD_LIGHT.lerp(rim_tint, 0.25) if rim_tint != Color.WHITE else WOOD_LIGHT
	var face_light := FACE_LIGHT.lightened(0.12) if lit else FACE_LIGHT
	for y: int in image.get_height():
		for x: int in image.get_width():
			var c := image.get_pixel(x, y)
			if c.a <= 0.0: continue
			var a := clampf((c.a * 255.0 - ALPHA_FLOOR) * gain, 0.0, 255.0) / 255.0
			var edge := mini(mini(x, image.get_width() - 1 - x), mini(y, image.get_height() - 1 - y))
			if edge < 3: a *= float(edge) / 3.0
			var lum := c.r * 0.3 + c.g * 0.55 + c.b * 0.15
			var out := c
			if _is_kept(c) and not _is_face(c):
				out = c
			elif _is_face(c):
				out = FACE_DARK.lerp(face_light, clampf((lum - 0.6) / 0.4, 0.0, 1.0))
			else:
				out = wood_dark.lerp(wood_light, clampf((lum - 0.12) / 0.55, 0.0, 1.0))
			out.a = a
			image.set_pixel(x, y, out)
	# Wood grain: faint horizontal streaks on the rim so it reads as carved timber, not a flat slab.
	for y: int in image.get_height():
		for x: int in image.get_width():
			var c2 := image.get_pixel(x, y)
			if c2.a < 0.5 or _is_kept(c2) or c2.is_equal_approx(FACE_DARK): continue
			var streak := sin(float(y) * 1.9 + sin(float(x) * 0.21) * 2.3) * 0.5 + 0.5
			if c2.get_luminance() > 0.3 or c2.b > 0.28:
				image.set_pixel(x, y, c2.lerp(Color.BLACK if streak < 0.35 else Color.WHITE, 0.07 if streak < 0.35 else 0.05))
	var made := ImageTexture.create_from_image(image)
	_cache[key] = made
	return made
