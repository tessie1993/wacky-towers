@tool
class_name LevelPlatform
extends Node3D
## Greybox island the board sits on. Top surface is at local y = 0; centred on origin.
## Built from plain BoxMeshes (TileMapLayer3D only paints flat atlas quads, see report).

const GRASS: Material = preload("res://src/levels/_kit/platform/grass_greybox.tres")
const SOIL: Material = preload("res://src/levels/_kit/platform/soil_greybox.tres")
const GRASS_H := 0.3  ## chunky grass cap thickness
const SOIL_H := 1.2
const LIP := 0.12  ## grass overhang past the soil

@export var board_size: Vector2i = Vector2i(4, 4):
	set(v):
		board_size = v
		_rebuild()
@export var margin_cells: int = 1:
	set(v):
		margin_cells = v
		_rebuild()

var _top: MeshInstance3D


func _ready() -> void:
	_rebuild()


## Local-space AABB of the grass top (end.y == 0).
func get_top_aabb() -> AABB:
	return AABB(_top.position - _top.mesh.get_aabb().size / 2.0, _top.mesh.get_aabb().size) if _top else AABB()


func _rebuild() -> void:
	if not is_inside_tree():
		return
	for c in get_children():
		remove_child(c)
		c.queue_free()
	var w: float = board_size.x + 2.0 * margin_cells
	var d: float = board_size.y + 2.0 * margin_cells
	_top = _box("Top", Vector3(w, GRASS_H, d), -GRASS_H / 2.0, GRASS)
	_box("Soil", Vector3(w - 2.0 * LIP, SOIL_H, d - 2.0 * LIP), -GRASS_H - SOIL_H / 2.0, SOIL)


func _box(n: String, size: Vector3, y: float, mat: Material) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	m.name = n
	var b := BoxMesh.new()
	b.size = size
	b.material = mat
	m.mesh = b
	m.position.y = y
	add_child(m)  # not owned: regenerated, never serialized
	return m
