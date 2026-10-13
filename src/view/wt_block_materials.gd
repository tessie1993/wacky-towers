class_name WtBlockMaterials extends RefCounted
## Builds the per-biome block material and exposes the biome look table.
## Data: res://assets/data/biome_looks.json. Shader: spatial_block_biome.gdshader.
## WtStage discovers this class by name (BLOCK_MATERIAL_CLASS) and calls for_biome().

const LOOKS_PATH := "res://assets/data/biome_looks.json"
const SHADER_PATH := "res://src/view/shaders/spatial_block_biome.gdshader"

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
	for key: String in ["cap_depth", "cap_drip", "body_mix", "glow", "gloss", "rim", "detail", "brightness"]:
		if record.has(key):
			material.set_shader_parameter(StringName(key), float(record[key]))
	return material


static func _table() -> Dictionary:
	if _looks.is_empty() and FileAccess.file_exists(LOOKS_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LOOKS_PATH))
		if parsed is Dictionary:
			_looks = parsed
	return _looks
