class_name SlotMap extends RefCounted
## Dense mapping between board cell indices and MultiMesh instance slots.
## Slots 0..filled()-1 are always in use. Usage: var s: int = slot_map.add(cell).

const EMPTY: int = -1 ## Sentinel for "no slot" / "no cell".

var _cell_to_slot: PackedInt32Array = PackedInt32Array()
var _slot_to_cell: PackedInt32Array = PackedInt32Array()


## Empties the map and sizes it for cell ids 0..cell_count-1. Usage: reset(width * height).
func reset(cell_count: int) -> void:
	_cell_to_slot.resize(cell_count)
	_cell_to_slot.fill(EMPTY)
	_slot_to_cell.clear()


## Assigns the next slot to a cell; returns it, or -1 if the cell is already present.
## Usage: var slot: int = add(cell).
func add(cell: int) -> int:
	if not _in_range(cell) or _cell_to_slot[cell] != EMPTY:
		return EMPTY
	var slot: int = _slot_to_cell.size()
	_slot_to_cell.append(cell)
	_cell_to_slot[cell] = slot
	return slot


## Frees a cell's slot by swapping the last slot into it. Returns (freed_slot, moved_from_slot);
## the caller copies slot y's data into x, then shrinks. (-1,-1) if absent.
## Usage: var r: Vector2i = remove(cell).
func remove(cell: int) -> Vector2i:
	if not _in_range(cell) or _cell_to_slot[cell] == EMPTY:
		return Vector2i(EMPTY, EMPTY)
	var freed: int = _cell_to_slot[cell]
	var last: int = _slot_to_cell.size() - 1
	var last_cell: int = _slot_to_cell[last]
	_slot_to_cell[freed] = last_cell
	_cell_to_slot[last_cell] = freed
	_slot_to_cell.resize(last)
	_cell_to_slot[cell] = EMPTY
	return Vector2i(freed, last)


## Re-keys a slot from one cell to another, keeping its index; returns the slot,
## or -1 if from_cell is absent or to_cell is present. Usage: var s: int = move(a, b).
func move(from_cell: int, to_cell: int) -> int:
	if not _in_range(from_cell) or not _in_range(to_cell):
		return EMPTY
	var slot: int = _cell_to_slot[from_cell]
	if slot == EMPTY or _cell_to_slot[to_cell] != EMPTY:
		return EMPTY
	_cell_to_slot[from_cell] = EMPTY
	_cell_to_slot[to_cell] = slot
	_slot_to_cell[slot] = to_cell
	return slot


## Slot holding the cell, or -1 when empty. Usage: var s: int = slot_of(cell).
func slot_of(cell: int) -> int:
	return _cell_to_slot[cell] if _in_range(cell) else EMPTY


## Cell stored in a slot, or -1 if the slot is unused. Usage: var c: int = cell_at(slot).
func cell_at(slot: int) -> int:
	return _slot_to_cell[slot] if slot >= 0 and slot < _slot_to_cell.size() else EMPTY


## Number of slots in use. Usage: multimesh.visible_instance_count = filled().
func filled() -> int:
	return _slot_to_cell.size()


func _in_range(cell: int) -> bool:
	return cell >= 0 and cell < _cell_to_slot.size()
