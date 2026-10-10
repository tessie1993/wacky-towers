class_name ActivePiece extends RefCounted
## The falling piece: shape, orientation, pivot, rotation undo record and up-kick count (CH-048, ADR-0003).
## Pure data plus cell maths; Movement decides whether a change is legal and applies it.
## Usage: var p := ActivePiece.new(shape, Vector3i(3, 5, 1)); var cells: Array[Vector3i] = p.cells()

## No rotation recorded yet.
const NO_AXIS: int = -1

## The shape being played.
var shape: ShapeDef
## Orientation index 0..23 (Orientations).
var hue_id: int = 0
var orient: int = 0
## World position of the pivot cube.
var pivot: Vector3i = Vector3i.ZERO
## Up-kicks spent on this piece (limit is the max_up_kicks_per_piece knob; GDD movement-rotation rule 12).
var up_kicks_used: int = 0
## Undo record (GDD rule 14): last rotation axis (Orientations.Axis) or NO_AXIS.
var last_axis: int = NO_AXIS
## Undo record: last rotation sign, +1 or -1 (0 = none).
var last_sign: int = 0
## Undo record: kick offset that rotation used (zero if none).
var last_kick: Vector3i = Vector3i.ZERO


## Creates a piece at a pivot in the shape spawn orientation (or p_orient if >= 0).
func _init(p_shape: ShapeDef = null, p_pivot: Vector3i = Vector3i.ZERO, p_orient: int = -1) -> void:
	shape = p_shape
	hue_id = p_shape.hue_id if p_shape != null else 0
	pivot = p_pivot
	orient = p_orient if p_orient >= 0 else (p_shape.spawn_orient if p_shape != null else 0)


## World cells of the piece (pivot + offsets of the current orientation).
func cells() -> Array[Vector3i]:
	return cells_at(orient, pivot)


## World cells the piece would occupy at another orientation and pivot. Usage: p.cells_at(o2, p.pivot + kick)
func cells_at(p_orient: int, p_pivot: Vector3i) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	if shape == null:
		return out
	for off: Vector3i in shape.offsets(p_orient):
		out.append(p_pivot + off)
	return out


## Orientation after turning 90 degrees about a world axis (piece unchanged). dir is +1 or -1.
func rotated_orient(axis: Orientations.Axis, dir: int) -> int:
	return Orientations.turn(orient, axis, dir)


## Applies a rotation result and records it for undo. kick is the offset used (zero if none).
func apply_rotation(axis: Orientations.Axis, dir: int, kick: Vector3i = Vector3i.ZERO) -> void:
	orient = Orientations.turn(orient, axis, dir)
	pivot += kick
	last_axis = axis
	last_sign = dir
	last_kick = kick


## True if axis/dir exactly reverses the last rotation (restore is worth trying; GDD F3).
func is_undo_of_last(axis: Orientations.Axis, dir: int) -> bool:
	return last_axis == axis and last_sign == -dir


## Forgets the undo record.
func clear_undo() -> void:
	last_axis = NO_AXIS
	last_sign = 0
	last_kick = Vector3i.ZERO


## True if another up-kick fits under the budget. Usage: p.can_up_kick(knobs.int_value(&"move.max_up_kicks"))
func can_up_kick(max_up_kicks: int) -> bool:
	return up_kicks_used < max_up_kicks


## Spends one up-kick.
func spend_up_kick() -> void:
	up_kicks_used += 1


## Independent copy (the shape is shared, it is immutable data).
func duplicate_piece() -> ActivePiece:
	var c: ActivePiece = ActivePiece.new(shape, pivot, orient)
	c.hue_id = hue_id
	c.up_kicks_used = up_kicks_used
	c.last_axis = last_axis
	c.last_sign = last_sign
	c.last_kick = last_kick
	return c
