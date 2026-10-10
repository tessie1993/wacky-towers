# Import checks for every block set found in res://assets/models/blocks/<set>/.
# New sets are picked up automatically. Run `godot --headless --import` first.
# Piece contract (design/art/block-art-sets.md): a piece scene's root is the
# pivot-cube empty with one MeshInstance3D child per cube, cubes sit on integer
# grid offsets and stay inside their cell (cube ~1.03 of a cell).
extends GdUnitTestSuite

const BLOCKS_DIR := "res://assets/models/blocks/"
## Half the allowed cube size: 1.03 / 2, plus float slack from the import.
const CELL_HALF_EXTENT := 0.515 + 0.005
## Sets whose meshes carry vertex colours on purpose. None yet.
const VERTEX_COLOUR_SETS: Array[String] = []
## Cube count per shape_id, from design/gdd/piece-set.md (Families table and
## Starter library). Families the GDD only gives as a range map to [min, max].
## ponytail: hand-copied; read the exported shape data file once it exists.
const CUBE_COUNTS := {
	"i": 4, "o": 4, "t": 4, "l": 4, "s": 4, "tripod": 4, "screw_left": 4, "screw_right": 4,
	"chair": 5, "twist_left": 5, "twist_right": 5, "staircase": 6, "tall_corner": 6,
	"big_tripod": 7, "big_cube": 8,
	"mono": 1, "duo": 2, "tri_straight": 3, "tri_corner": 3,
	"pento_f": 5, "pento_i": 5, "pento_l": 5, "pento_n": 5, "pento_p": 5, "pento_t": 5,
	"pento_u": 5, "pento_v": 5, "pento_w": 5, "pento_x": 5, "pento_y": 5, "pento_z": 5,
	"nook": 5, "antenna": 5, "signpost": 5, "crank": 5,
	"hook_left": 5, "hook_right": 5, "kink_left": 5, "kink_right": 5,
	"wiggle_left": 5, "wiggle_right": 5, "periscope_left": 5, "periscope_right": 5,
	"claw_left": 5, "claw_right": 5,
	"slab": [6, 8], "plank": [6, 8], "step_block": [6, 8], "stool": [6, 8],
	"dented_cube": [6, 8], "big_zigzag": [6, 8], "jack": [6, 8],
	"ring": [6, 8], "arch": [6, 8], "loop": [6, 8],
	"heart": [6, 8], "mushroom": [6, 8], "rocket": [6, 8], "dog_bone": [6, 8],
	"crown": [6, 8], "snake_left": [6, 8], "snake_right": [6, 8],
	"pole": 6,
	"giant_slab": 9, "giant_fridge": 12, "giant_ring": 12, "giant_mega_cube": 27,
}

## res path -> PackedScene (null if it failed to load); loaded once per suite.
var _scenes: Dictionary = {}


func before() -> void:
	for set_name: String in DirAccess.get_directories_at(BLOCKS_DIR):
		for file: String in DirAccess.get_files_at(BLOCKS_DIR + set_name):
			if file.get_extension() == "glb":
				var path := BLOCKS_DIR.path_join(set_name).path_join(file)
				_scenes[path] = load(path) as PackedScene


func test_block_sets_each_set_has_a_cube_file() -> void:
	var sets := DirAccess.get_directories_at(BLOCKS_DIR)
	assert_int(sets.size()).override_failure_message("no block sets found").is_greater(0)
	var failures: Array[String] = []
	for set_name: String in sets:
		var has_cube := false
		for file: String in DirAccess.get_files_at(BLOCKS_DIR + set_name):
			has_cube = has_cube or (file.begins_with("blk_%s_cube" % set_name) and file.get_extension() == "glb")
		if not has_cube:
			failures.append("%s: no blk_%s_cube*.glb" % [set_name, set_name])
	assert_array(failures).is_empty()


func test_block_glbs_every_file_loads_as_scene() -> void:
	var failures: Array[String] = []
	for path: String in _scenes:
		if _scenes[path] == null:
			failures.append(path)
	assert_array(failures).is_empty()


func test_block_meshes_have_no_vertex_colours() -> void:
	var failures: Array[String] = []
	for path: String in _scenes:
		if _scenes[path] == null or path.get_base_dir().get_file() in VERTEX_COLOUR_SETS:
			continue
		var root: Node = auto_free(_scenes[path].instantiate())
		for entry: Array in _cube_meshes(root):
			var mesh: Mesh = (entry[0] as MeshInstance3D).mesh
			for i in mesh.get_surface_count():
				if mesh.surface_get_format(i) & Mesh.ARRAY_FORMAT_COLOR:
					failures.append("%s: %s surface %d" % [path, entry[0].name, i])
	assert_array(failures).is_empty()


func test_block_cubes_stay_inside_their_grid_cell() -> void:
	var failures: Array[String] = []
	for path: String in _scenes:
		if _scenes[path] == null:
			continue
		var worst := 0.0
		var root: Node = auto_free(_scenes[path].instantiate())
		for entry: Array in _cube_meshes(root):
			var xform: Transform3D = entry[1]
			var cell := xform.origin.round()
			if not xform.origin.is_equal_approx(cell):
				failures.append("%s: %s is off-grid at %s" % [path, entry[0].name, xform.origin])
			var box: AABB = xform * (entry[0] as MeshInstance3D).get_aabb()
			var over := ((cell - box.position).max(box.end - cell) - Vector3.ONE * CELL_HALF_EXTENT)
			worst = maxf(worst, maxf(over.x, maxf(over.y, over.z)))
		if worst > 0.0:
			failures.append("%s: mesh pokes %.3f past its cell" % [path, worst])
	assert_array(failures).is_empty()


func test_block_pieces_child_count_matches_shape_bank() -> void:
	var failures: Array[String] = []
	for path: String in _scenes:
		var shape := _shape_of(path)
		if _scenes[path] == null or shape.begins_with("cube"):
			continue
		if not CUBE_COUNTS.has(shape):
			failures.append("%s: '%s' is not a shape in the bank" % [path, shape])
			continue
		var root: Node = auto_free(_scenes[path].instantiate())
		var count := root.get_child_count()
		var expected: Variant = CUBE_COUNTS[shape]
		var lo: int = expected[0] if expected is Array else expected
		var hi: int = expected[1] if expected is Array else expected
		if count < 1 or count < lo or count > hi:
			failures.append("%s: %d cubes, expected %s" % [path, count, expected])
		if root.has_meta("extras") and int(root.get_meta("extras").get("cubes", count)) != count:
			failures.append("%s: extras.cubes %s != %d children" % [path, root.get_meta("extras").cubes, count])
		var has_pivot := false
		for child: Node in root.get_children():
			if not child is MeshInstance3D:
				failures.append("%s: child %s is a %s, not a MeshInstance3D" % [path, child.name, child.get_class()])
			elif (child as Node3D).position.is_zero_approx():
				has_pivot = true
		if not has_pivot:
			failures.append("%s: no cube at the pivot (0,0,0)" % path)
	assert_array(failures).is_empty()


## Set names that have a blk_<set>_cube.glb.
func _sets_with_cube_glb() -> Array[String]:
	var out: Array[String] = []
	for set_name: String in DirAccess.get_directories_at(BLOCKS_DIR):
		if FileAccess.file_exists("%s%s/blk_%s_cube.glb" % [BLOCKS_DIR, set_name, set_name]):
			out.append(set_name)
	return out


func test_cube_res_for_every_cube_glb() -> void:
	var failures: Array[String] = []
	for set_name: String in _sets_with_cube_glb():
		var path := "%s%s/blk_%s_cube.res" % [BLOCKS_DIR, set_name, set_name]
		if not FileAccess.file_exists(path) or not load(path) is Mesh:
			failures.append("%s: missing or not a Mesh" % path)
	assert_array(failures).is_empty()


func test_cube_res_matches_glb() -> void:
	var failures: Array[String] = []
	for set_name: String in _sets_with_cube_glb():
		var base := "%s%s/blk_%s_cube" % [BLOCKS_DIR, set_name, set_name]
		var res := load(base + ".res") as Mesh
		var scene := load(base + ".glb") as PackedScene
		if res == null or scene == null:
			failures.append("%s: cannot load res/glb" % base)
			continue
		var root: Node = auto_free(scene.instantiate())
		var glb_mesh: Mesh = (root as MeshInstance3D).mesh if root is MeshInstance3D else null
		if glb_mesh == null:
			failures.append("%s: glb root is not a MeshInstance3D" % base)
			continue
		if res.get_surface_count() != glb_mesh.get_surface_count():
			failures.append("%s: surface count differs" % base)
		elif res.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size() != glb_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size():
			failures.append("%s: vertex count differs" % base)
	assert_array(failures).is_empty()


func test_block_import_flags() -> void:
	var failures: Array[String] = []
	for set_name: String in DirAccess.get_directories_at(BLOCKS_DIR):
		for file: String in DirAccess.get_files_at(BLOCKS_DIR + set_name):
			if not file.ends_with(".glb.import"):
				continue
			var cfg := ConfigFile.new()
			if cfg.load(BLOCKS_DIR + set_name + "/" + file) != OK:
				failures.append("%s: cannot read" % file)
				continue
			if cfg.get_value("params", "meshes/generate_lods", null) != false:
				failures.append("%s: generate_lods is not false" % file)
			if cfg.get_value("params", "meshes/create_shadow_meshes", null) != false:
				failures.append("%s: create_shadow_meshes is not false" % file)
	assert_array(failures).is_empty()


## shape_id from blk_<set>_<shape>.glb; the whole basename if the prefix is missing.
func _shape_of(path: String) -> String:
	return path.get_file().get_basename().trim_prefix("blk_%s_" % path.get_base_dir().get_file())


## [MeshInstance3D, transform in piece space] per cube. Cube files have the
## mesh as the root; piece files have one mesh per child.
func _cube_meshes(root: Node) -> Array[Array]:
	if root is MeshInstance3D:
		return [[root, Transform3D.IDENTITY]]
	var out: Array[Array] = []
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			out.append([child, (child as Node3D).transform])
	return out
