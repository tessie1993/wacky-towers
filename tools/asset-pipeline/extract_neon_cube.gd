extends SceneTree
## Saves the standalone Neon cube mesh derived from its authored one-cube Mono GLB.

func _initialize() -> void:
	var scene: PackedScene = load("res://assets/models/blocks/neon_voxel/blk_neon_voxel_cube.glb")
	if scene == null:
		quit(1)
		return
	var cube: Node = scene.instantiate()
	if not cube is MeshInstance3D:
		cube.free()
		quit(1)
		return
	var error: Error = ResourceSaver.save((cube as MeshInstance3D).mesh, "res://assets/models/blocks/neon_voxel/blk_neon_voxel_cube.res")
	cube.free()
	quit(0 if error == OK else 1)
