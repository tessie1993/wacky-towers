@tool
extends EditorScenePostImport
## Post-import script for block-set GLBs, set project-wide through
## [importer_defaults] in project.godot so newly exported sets pick it up.
##
## Godot wraps every glTF scene in an extra Node3D root. For files under
## [constant BLOCKS_DIR] this drops that wrapper, so the scene root IS the piece
## empty (pivot cube, glTF extras kept as meta "extras") and its children are
## the cubes - or, for blk_<set>_cube*.glb, the root is the cube MeshInstance3D.
## Every other scene passes through unchanged.

const BLOCKS_DIR := "res://assets/models/blocks/"


func _post_import(scene: Node) -> Object:
	if not get_source_file().begins_with(BLOCKS_DIR) or scene.get_child_count() != 1:
		return scene
	var piece: Node = scene.get_child(0)
	scene.remove_child(piece)
	scene.free()
	for node: Node in piece.find_children("*", "", true, false):
		node.owner = piece
	return piece
