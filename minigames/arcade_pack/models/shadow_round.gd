extends "res://minigames/arcade_pack/models/round_base.gd"
## MG10 practice: repair a story object by matching BOTH orthographic shadows.
## There is deliberately no exact-build comparison: depth ambiguities are puzzles.

var puzzles: Array = []
var puzzle_index: int = 0
var completed_puzzles: int = 0
var grid_size: int = 3
var cube_budget: int = 6
var cursor: Vector3i = Vector3i.ZERO
var cubes: Dictionary = {}
var forbidden_cells: Dictionary = {}
var target_front: Dictionary = {}
var target_side: Dictionary = {}
var undo_history: Array[Dictionary] = []
var edits: int = 0
var current_puzzle: Dictionary = {}


func _reset() -> void:
	puzzles = config.get("puzzles", []).duplicate(true)
	if puzzles.is_empty():
		puzzles = [config.duplicate(true)]
	puzzle_index = 0
	completed_puzzles = 0
	edits = 0
	_load_puzzle()


func _load_puzzle() -> void:
	current_puzzle = puzzles[puzzle_index]
	grid_size = clampi(int(current_puzzle.get("grid_size", config.get("grid_size", 3))), 2, 4)
	cube_budget = clampi(int(current_puzzle.get("cube_budget", grid_size * grid_size)), 1, grid_size * grid_size * grid_size)
	cursor = Vector3i.ZERO
	cubes.clear()
	forbidden_cells.clear()
	undo_history.clear()
	target_front = _read_shadow(current_puzzle.get("front", []))
	target_side = _read_shadow(current_puzzle.get("side", []))
	for raw_cell in current_puzzle.get("blocked_cells", []):
		var cell: Vector3i = _cell(raw_cell)
		if _inside(cell):
			forbidden_cells[cell] = true
	if target_front.is_empty() or target_side.is_empty():
		complete(false, "This blueprint has no silhouettes. Pick another level.")
		return
	message = str(current_puzzle.get("name", "Shadow blueprint")) + ". Match BOTH raised silhouettes; E/Q changes height."


func act(action: String) -> void:
	if finished:
		return
	match action:
		"left":
			cursor.x = maxi(0, cursor.x - 1)
		"right":
			cursor.x = mini(grid_size - 1, cursor.x + 1)
		"up":
			cursor.z = maxi(0, cursor.z - 1)
		"down":
			cursor.z = mini(grid_size - 1, cursor.z + 1)
		"rotate_y":
			cursor.y = mini(grid_size - 1, cursor.y + 1)
		"rotate_x":
			cursor.y = maxi(0, cursor.y - 1)
		"primary":
			_toggle_cube()
		"undo":
			_undo()


func _toggle_cube() -> void:
	if cubes.has(cursor):
		cubes.erase(cursor)
		undo_history.append({"cell": cursor, "added": false})
		message = "Cube returned to the tray. Keep only the shadows you need."
	elif forbidden_cells.has(cursor):
		message = "A crossed socket cannot hold a cube. Try another depth."
		return
	elif cubes.size() >= cube_budget:
		message = "The tray is empty. Space on a cube removes it; U undoes an edit."
		return
	else:
		cubes[cursor] = true
		undo_history.append({"cell": cursor, "added": true})
		message = "Match both raised silhouettes. Extra shadow tiles must go."
	edits += 1
	_check_match()


func _undo() -> void:
	if undo_history.is_empty():
		message = "No edits to undo in this blueprint."
		return
	var edit: Dictionary = undo_history.pop_back()
	var cell: Vector3i = edit["cell"]
	if bool(edit["added"]):
		cubes.erase(cell)
	else:
		cubes[cell] = true
	cursor = cell
	edits += 1
	message = "Edit undone. The returned cube and its shadows are restored."
	_check_match()


func _check_match() -> void:
	if not projections_match():
		return
	completed_puzzles += 1
	score = completed_puzzles * 100
	# A future tournament adapter can route this request. No network send occurs.
	interaction_requested.emit({"type": "flicker_requested", "mode": "shadow",
		"puzzle_id": str(current_puzzle.get("id", puzzle_index)), "duration": 3.0})
	if completed_puzzles >= puzzles.size():
		complete(true, "%d blueprints restored! Both shadows fit." % puzzles.size())
		return
	puzzle_index += 1
	_load_puzzle()
	message = "Blueprint complete! " + message


func projections_match() -> bool:
	return _same_cells(_project(true), target_front) and _same_cells(_project(false), target_side)


func projection_progress() -> float:
	var correct: int = 0
	var extra: int = 0
	var total: int = target_front.size() + target_side.size()
	for axis in [true, false]:
		var projection: Dictionary = _project(axis)
		var target: Dictionary = target_front if axis else target_side
		for cell in projection:
			if target.has(cell):
				correct += 1
			else:
				extra += 1
	return clampf(float(correct - extra) / float(maxi(1, total)), 0.0, 1.0)


func snapshot() -> Dictionary:
	var blocks: Array = []
	var markers: Array = []
	var centre: float = float(grid_size - 1) * 0.5
	for cell in cubes:
		blocks.append({"position": _position(cell), "colour": (cell.y + puzzle_index) % 6, "kind": "solid"})
	for cell in forbidden_cells:
		markers.append({"position": _position(cell), "size": Vector3(0.68, 0.68, 0.68), "colour": 5, "kind": "hazard"})
	for x in range(grid_size):
		for z in range(grid_size):
			markers.append({"position": Vector3(float(x) - centre, 0.035, float(z) - centre),
				"size": Vector3(0.88, 0.035, 0.88), "colour": 2, "kind": "ghost"})
	markers.append({"position": _position(cursor), "size": Vector3(1.04, 1.04, 1.04), "colour": 0, "kind": "cursor"})
	_append_panel(markers, true)
	_append_panel(markers, false)
	var progress: float = 1.0 if won else (float(completed_puzzles) + projection_progress()) / float(maxi(1, puzzles.size()))
	return {"blocks": blocks, "markers": markers, "status": message, "progress": progress,
		"metric": "Blueprint %d/%d | Cubes %d/%d | Height %d/%d" % [mini(puzzle_index + 1, puzzles.size()), puzzles.size(), cubes.size(), cube_budget, cursor.y + 1, grid_size],
		"camera_target": Vector3(-0.4, float(grid_size) * 0.5, -0.4), "camera_size": 11.5 if grid_size == 3 else 14.0,
		"puzzle_name": str(current_puzzle.get("name", "Shadow blueprint")),
		"front_label": "FRONT (x / height)", "side_label": "SIDE (depth / height)",
		"panel_legend": "Raised tiles: targets. Centre pegs: matched. Crosses: extra shadows. Q/E changes height.",
		"cube_count": cubes.size(), "cube_budget": cube_budget, "cursor_cell": [cursor.x, cursor.y, cursor.z],
		"completed_puzzles": completed_puzzles, "edits": edits}


func _append_panel(markers: Array, front: bool) -> void:
	var centre: float = float(grid_size - 1) * 0.5
	var distance: float = -centre - 1.65
	var projection: Dictionary = _project(front)
	var target: Dictionary = target_front if front else target_side
	var backing_size: Vector3 = Vector3(float(grid_size) + 0.18, float(grid_size) + 0.18, 0.08) if front else Vector3(0.08, float(grid_size) + 0.18, float(grid_size) + 0.18)
	var backing_position: Vector3 = Vector3(0.0, float(grid_size) * 0.5, distance - 0.08) if front else Vector3(distance - 0.08, float(grid_size) * 0.5, 0.0)
	markers.append({"position": backing_position, "size": backing_size, "colour": 4, "kind": "wall"})
	for column in range(grid_size):
		for y in range(grid_size):
			var cell: Vector2i = Vector2i(column, y)
			var wanted: bool = target.has(cell)
			var occupied: bool = projection.has(cell)
			var position: Vector3 = Vector3(float(column) - centre, float(y) + 0.5, distance) if front else Vector3(distance, float(y) + 0.5, float(column) - centre)
			var size: Vector3 = Vector3(0.78, 0.78, 0.13) if front else Vector3(0.13, 0.78, 0.78)
			var colour: int = 2 if occupied and wanted else (0 if wanted else 4)
			var kind: String = "target" if wanted else "ghost"
			if not wanted:
				size = Vector3(0.75, 0.75, 0.025) if front else Vector3(0.025, 0.75, 0.75)
			markers.append({"position": position, "size": size, "colour": colour, "kind": kind})
			if wanted and occupied:
				var peg_size: Vector3 = Vector3(0.18, 0.18, 0.2) if front else Vector3(0.2, 0.18, 0.18)
				markers.append({"position": position + (Vector3(0, 0, 0.08) if front else Vector3(0.08, 0, 0)), "size": peg_size, "colour": 2, "kind": "solid"})
			if occupied and not wanted:
				# Two raised cross bars flag an error by shape as well as hue.
				var cross_size: Vector3 = Vector3(0.6, 0.16, 0.17) if front else Vector3(0.17, 0.16, 0.6)
				markers.append({"position": position + (Vector3(0, 0, 0.08) if front else Vector3(0.08, 0, 0)), "size": cross_size, "colour": 5, "kind": "hazard"})
				cross_size = Vector3(0.16, 0.6, 0.17) if front else Vector3(0.17, 0.6, 0.16)
				markers.append({"position": position + (Vector3(0, 0, 0.08) if front else Vector3(0.08, 0, 0)), "size": cross_size, "colour": 5, "kind": "hazard"})


func _project(front: bool) -> Dictionary:
	var result: Dictionary = {}
	for cell in cubes:
		result[Vector2i(cell.x if front else cell.z, cell.y)] = true
	return result


func _read_shadow(rows: Array) -> Dictionary:
	var result: Dictionary = {}
	# Rows are authored bottom-to-top, matching Godot Y-up cell coordinates.
	for y in range(mini(grid_size, rows.size())):
		var row: String = str(rows[y])
		for column in range(mini(grid_size, row.length())):
			if row[column] == "#":
				result[Vector2i(column, y)] = true
	return result


func _same_cells(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for cell in a:
		if not b.has(cell):
			return false
	return true


func _position(cell: Vector3i) -> Vector3:
	var centre: float = float(grid_size - 1) * 0.5
	return Vector3(float(cell.x) - centre, float(cell.y) + 0.5, float(cell.z) - centre)


func _inside(cell: Vector3i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.z >= 0 and cell.x < grid_size and cell.y < grid_size and cell.z < grid_size


func _cell(raw: Array) -> Vector3i:
	return Vector3i(int(raw[0]), int(raw[1]), int(raw[2])) if raw.size() == 3 else Vector3i(-1, -1, -1)
