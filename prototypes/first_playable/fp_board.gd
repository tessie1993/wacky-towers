class_name FpBoard
extends RefCounted
## Voxel board for the first-playable prototype: W x H x D cells, colour index per filled cell.

## Board extents (W, H, D).
var size: Vector3i

var _cells: Dictionary = {}  # Vector3i -> int colour


func _init(w: int, d: int, h: int) -> void:
	size = Vector3i(w, h, d)


## True when the cell lies inside the board.
func in_bounds(c: Vector3i) -> bool:
	return c.x >= 0 and c.x < size.x and c.y >= 0 and c.y < size.y and c.z >= 0 and c.z < size.z


## True when the cell is in bounds and empty.
func is_free(c: Vector3i) -> bool:
	return in_bounds(c) and not _cells.has(c)


## True when every cell is free.
func can_place(cells: Array[Vector3i]) -> bool:
	for c: Vector3i in cells:
		if not is_free(c):
			return false
	return true


## Colour index at the cell, -1 when empty.
func get_cell(c: Vector3i) -> int:
	return _cells.get(c, -1)


## Fills the cells with the colour (out-of-bounds cells are ignored).
func lock(cells: Array[Vector3i], colour: int) -> void:
	for c: Vector3i in cells:
		if in_bounds(c):
			_cells[c] = colour


## Removes every full layer, collapses the rest down, returns cleared y values ascending.
func clear_full_layers() -> PackedInt32Array:
	var counts: PackedInt32Array = PackedInt32Array()
	counts.resize(size.y)
	for c: Vector3i in _cells:
		counts[c.y] += 1
	var cleared: PackedInt32Array = PackedInt32Array()
	var full: int = size.x * size.z
	for y: int in size.y:
		if counts[y] >= full:
			cleared.append(y)
	if cleared.is_empty():
		return cleared
	var rebuilt: Dictionary = {}
	for c: Vector3i in _cells:
		if cleared.has(c.y):
			continue
		var drop: int = 0
		for cy: int in cleared:
			if cy < c.y:
				drop += 1
		rebuilt[Vector3i(c.x, c.y - drop, c.z)] = _cells[c]
	_cells = rebuilt
	return cleared


## Copy of all filled cells: Vector3i -> colour.
func filled_cells() -> Dictionary:
	return _cells.duplicate()


## Highest filled y, -1 when the board is empty.
func highest_filled_y() -> int:
	var top: int = -1
	for c: Vector3i in _cells:
		top = maxi(top, c.y)
	return top
