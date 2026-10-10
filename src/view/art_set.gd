class_name ArtSet extends RefCounted
## Block-set files for one set id. Usage: ArtSet.new(&"candy_toy").cube_mesh()

const BLOCKS_DIR := "res://assets/models/blocks/"
const PALETTES_DIR := "res://assets/data/palettes/"
const FALLBACK_SET := &"candy_toy"

var _set_id: StringName
var _material: StandardMaterial3D = null


func _init(set_id: StringName) -> void:
	_set_id = set_id


## Stage export -> biome.art_set -> FALLBACK_SET.
## Usage: ArtSet.resolve_set_id(&"", {"art_set": "candy_toy"})
static func resolve_set_id(stage_set: StringName, biome: Dictionary) -> StringName:
	if stage_set != &"":
		return stage_set
	var b: String = str(biome.get("art_set", ""))
	return StringName(b) if b != "" else FALLBACK_SET


## Set dirs that have blk_<set>_cube.res (neon_voxel has none today).
## Usage: for s in ArtSet.available_sets(): ...
static func available_sets() -> PackedStringArray:
	var out := PackedStringArray()
	for d: String in DirAccess.get_directories_at(BLOCKS_DIR):
		if ResourceLoader.exists("%s%s/blk_%s_cube.res" % [BLOCKS_DIR, d, d]):
			out.append(d)
	out.sort()
	return out


## The set id this ArtSet was built with. Usage: art.set_id()
func set_id() -> StringName:
	return _set_id


## res:// path of a shape's scene (may not exist).
func shape_scene_path(shape_id: StringName) -> String:
	return "%s%s/blk_%s_%s.glb" % [BLOCKS_DIR, _set_id, _set_id, shape_id]


## Shape scene, or null if missing.
func shape_scene(shape_id: StringName) -> PackedScene:
	var p: String = shape_scene_path(shape_id)
	if not ResourceLoader.exists(p):
		return null
	return load(p) as PackedScene


## Shared cube mesh, or null if the set has none.
func cube_mesh() -> Mesh:
	var p: String = "%s%s/blk_%s_cube.res" % [BLOCKS_DIR, _set_id, _set_id]
	if not ResourceLoader.exists(p):
		return null
	return load(p) as Mesh


## Scale that makes the cube exactly 1 unit (candy_toy is 1.03 wide; fixes the overlap). 1.0 if no mesh.
func cube_scale() -> float:
	var m: Mesh = cube_mesh()
	if m == null:
		return 1.0
	var longest: float = m.get_aabb().get_longest_axis_size()
	return 1.0 / longest if longest > 0.0 else 1.0


## Palette for this set; falls back to the candy_toy palette. Empty table if neither loads.
func palette() -> PaletteTable:
	for id: StringName in [_set_id, FALLBACK_SET]:
		var p: String = "%s%s.json" % [PALETTES_DIR, id]
		if FileAccess.file_exists(p):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(p))
			if typeof(parsed) == TYPE_DICTIONARY:
				return PaletteTable.from_dict(parsed)
	return PaletteTable.from_dict({})


## Cached material using vertex colour as albedo.
func block_material() -> StandardMaterial3D:
	if _material == null:
		_material = StandardMaterial3D.new()
		_material.vertex_color_use_as_albedo = true
	return _material
