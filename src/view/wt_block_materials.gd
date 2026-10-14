class_name WtBlockMaterials extends RefCounted
## Builds the per-biome block material and exposes the biome look table.
## Data: res://assets/data/biome_looks.json. Shader: spatial_block_biome.gdshader.
## WtStage discovers this class by name (BLOCK_MATERIAL_CLASS) and calls for_biome().

const LOOKS_PATH := "res://assets/data/biome_looks.json"
const SHADER_PATH := "res://src/view/shaders/spatial_block_biome.gdshader"
const GHOST_SHADER_PATH := "res://src/view/shaders/spatial_block_ghost.gdshader"

const PALETTE_SLOTS := 8

static var _looks: Dictionary = {}


## Returns the whole look record for a biome (block, sky, island, props). Falls back to meadow.
static func look(biome: StringName) -> Dictionary:
	var biomes: Dictionary = _table().get("biomes", {})
	var key: String = String(biome)
	if not biomes.has(key):
		key = "meadow"
	return biomes.get(key, {})


## Returns a ready ShaderMaterial for a biome's blocks. No outline pass: it would paint
## over the dithered holes BoardView uses to fade foreground cubes.
static func for_biome(biome: StringName) -> ShaderMaterial:
	var record: Dictionary = look(biome).get("block", {})
	var material := ShaderMaterial.new()
	material.shader = load(SHADER_PATH) as Shader
	var styles: Dictionary = _table().get("styles", {})
	material.set_shader_parameter(&"style", int(styles.get(String(record.get("style", "plain")), 0)))
	for key: String in ["cap_color", "body_color", "accent_color", "glow_color"]:
		if record.has(key):
			material.set_shader_parameter(StringName(key), Color(String(record[key])))
	for key: String in ["glyph_strength", "seam_dark", "layer_dark", "cap_tint", "active_boost", "cap_depth", "cap_drip", "cap_lip", "body_mix", "glow", "gloss", "rim", "detail", "brightness", "bevel_light", "sculpt", "translucency",
			"piece_sat", "piece_value", "piece_linear", "cap_hue_min_sat", "stone_value", "stone_sat", "stone_crack", "cap_body_mix", "side_shade", "shade_side_extra"]:
		if record.has(key):
			material.set_shader_parameter(StringName(key), float(record[key]))
	if record.has("piece_hue_range"):
		var hr: Array = record["piece_hue_range"]
		material.set_shader_parameter(&"piece_hue_range", Vector2(float(hr[0]), float(hr[1])))
	# cap_hues: [[lo, hi], ...] HSV hue bands (0..1, authored piece colour) that keep the cap; the shader
	# takes one band. Absent = every piece keeps the cap (other biomes unchanged).
	if record.has("cap_hues"):
		var bands: Array = record["cap_hues"]
		if not bands.is_empty() and bands[0] is Array:
			material.set_shader_parameter(&"cap_hue_range", Vector2(float(bands[0][0]), float(bands[0][1])))
	# Per-piece palette: authored sRGB hexes, padded to the shader's 8 slots. palette_accent is optional
	# (lava veins, neon traces, gems, brass, nebula) and switches accent_vary on.
	if record.has("palette"):
		var pal: Array = record["palette"]
		var n: int = mini(pal.size(), PALETTE_SLOTS)
		material.set_shader_parameter(&"palette_size", n)
		material.set_shader_parameter(&"palette", _color_array(pal, n))
		if record.has("palette_accent"):
			material.set_shader_parameter(&"palette_accent", _color_array(record["palette_accent"], n))
			material.set_shader_parameter(&"accent_vary", 1.0)
	# Sky-tinted rim and fake reflection: the biome's horizon colour, lifted toward white.
	var sky: Array = look(biome).get("sky", [])
	if record.has("rim_color"):
		material.set_shader_parameter(&"rim_color", Color(String(record["rim_color"])))
	elif sky.size() >= 2:
		material.set_shader_parameter(&"rim_color", Color(String(sky[1])).lerp(Color.WHITE, 0.25))
	return material


## Glassy landing-ghost material: translucent body, fresnel sheen and a glowing edge in the
## piece colour (instance COLOR). Usage: mmi.material_override = WtBlockMaterials.ghost_material()
static func ghost_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = load(GHOST_SHADER_PATH) as Shader
	return material


## Opt-in chunky rounded cube (300 tris, rounded bevel) for the board MultiMeshes.
## The block shader reads object-space VERTEX/NORMAL, so it works with this mesh and with the
## GLB cube. Unit size (edge 1.0), so no cube_scale() correction is needed.
## Usage: var cube: Mesh = WtBlockMaterials.cube_mesh()
static func cube_mesh() -> Mesh:
	return WtBlockMesh.cube()


static func _table() -> Dictionary:
	if _looks.is_empty() and FileAccess.file_exists(LOOKS_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LOOKS_PATH))
		if parsed is Dictionary:
			_looks = parsed
	return _looks


static func _color_array(hexes: Array, count: int) -> PackedColorArray:
	var out := PackedColorArray()
	for i: int in PALETTE_SLOTS:
		out.append(Color(String(hexes[mini(i, count - 1)])) if count > 0 else Color.WHITE)
	return out
