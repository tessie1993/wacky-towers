extends Node3D
## Dev preview: lays out every piece of one block set under a single
## DirectionalLight3D. Run windowed:
##   godot --path . res://src/dev/block_set_preview.tscn -- --set=forest_bark --shot=res://production/qa/evidence/block_import_forest_bark.png
## --shot saves a screenshot after a few frames and quits.

const BLOCKS_DIR := "res://assets/models/blocks/"
const COLUMNS := 12
const SPACING := 5.5

@export var set_name := "candy_toy"


func _ready() -> void:
	var shot := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--set="):
			set_name = arg.trim_prefix("--set=")
		elif arg.begins_with("--shot="):
			shot = arg.trim_prefix("--shot=")
	var index := 0
	for file: String in DirAccess.get_files_at(BLOCKS_DIR + set_name):
		if file.get_extension() != "glb":
			continue
		var piece: Node3D = (load(BLOCKS_DIR.path_join(set_name).path_join(file)) as PackedScene).instantiate()
		piece.position = Vector3(index % COLUMNS, 0, index / COLUMNS) * SPACING
		add_child(piece)
		index += 1
	var rows := ceili(index / float(COLUMNS))
	var centre := Vector3(COLUMNS - 1, 0, rows - 1) * SPACING * 0.5
	$Camera3D.look_at_from_position(centre + Vector3(0, 48, 40), centre)
	if shot != "":
		for i in 10:
			await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(shot))
		get_tree().quit()
