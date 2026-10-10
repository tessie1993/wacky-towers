## Exports blk_<set>_cube.res (a plain Mesh for MultiMesh) for every block set with a cube GLB.
## Usage: godot --headless --path . -s res://tools/asset-pipeline/export_cube_mesh.gd
extends SceneTree

const BLOCKS_DIR: String = "res://assets/models/blocks/"


func _init() -> void:
	for set_name: String in DirAccess.get_directories_at(BLOCKS_DIR):
		var base: String = "%s%s/blk_%s_cube" % [BLOCKS_DIR, set_name, set_name]
		if not FileAccess.file_exists(base + ".glb"):
			continue
		var scene: PackedScene = load(base + ".glb") as PackedScene
		var root: Node = scene.instantiate() if scene != null else null
		var mesh: Mesh = null
		if root != null:
			var found: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
			if root is MeshInstance3D:
				mesh = (root as MeshInstance3D).mesh
			elif not found.is_empty():
				mesh = (found[0] as MeshInstance3D).mesh
			root.free()
		if mesh == null:
			push_error("%s: no MeshInstance3D mesh" % base)
			continue
		var err: Error = ResourceSaver.save(mesh, base + ".res")
		print("%s -> err %d, aabb size %s" % [base, err, mesh.get_aabb().size])
	quit()
