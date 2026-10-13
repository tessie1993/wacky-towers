class_name WtBlockMaterials extends RefCounted
## Builds the per-biome block material and exposes the biome look table.
## Data: res://assets/data/biome_looks.json. Shader: spatial_block_biome.gdshader.
## WtStage discovers this class by name (BLOCK_MATERIAL_CLASS) and calls for_biome().

const LOOKS_PATH := "res://assets/data/biome_looks.json"
const SHADER_PATH := "res://src/view/shaders/spatial_block_biome.gdshader"
const GHOST_SHADER_PATH := "res://src/view/shaders/spatial_block_ghost.gdshader"

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
	for key: String in ["cap_depth", "cap_drip", "cap_lip", "body_mix", "glow", "gloss", "rim", "detail", "brightness", "bevel_light", "sculpt", "translucency"]:
		if record.has(key):
			material.set_shader_parameter(StringName(key), float(record[key]))
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
