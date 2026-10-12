import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SOURCE=r'''class_name WtMinigameGeometry extends RefCounted
## Pure geometry shared by the distinctive bridge, packing, shadow and lava rounds.

static func occupied(board: BoardState) -> Array[Vector3i]:
	var cells: Array[Vector3i] = []
	var size: Vector3i = board.size()
	for index: int in size.x * size.y * size.z:
		if board.get_kind(index) != 0: cells.append(board.cell(index))
	return cells

static func front(cells: Array[Vector3i]) -> Array[Vector2i]:
	var keys: Dictionary = {}
	for cell: Vector3i in cells: keys[Vector2i(cell.x, cell.y)] = true
	return _ordered(keys)

static func side(cells: Array[Vector3i]) -> Array[Vector2i]:
	var keys: Dictionary = {}
	for cell: Vector3i in cells: keys[Vector2i(cell.z, cell.y)] = true
	return _ordered(keys)

static func _ordered(keys: Dictionary) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for cell: Vector2i in keys: out.append(cell)
	out.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return out

static func silhouettes(cells: Array[Vector3i], front_target: Array[Vector2i], side_target: Array[Vector2i]) -> Dictionary:
	var f: Array[Vector2i] = front(cells)
	var s: Array[Vector2i] = side(cells)
	var intersection: int = 0
	var extras: int = 0
	for point: Vector2i in f:
		if front_target.has(point): intersection += 1
		else: extras += 1
	for point: Vector2i in s:
		if side_target.has(point): intersection += 1
		else: extras += 1
	var total: int = front_target.size() + side_target.size()
	return {"match": extras == 0 and intersection == total and total > 0,
		"progress": clampf(float(intersection - extras) / maxi(1, total), 0.0, 1.0), "extra": extras}

static func surface(board: BoardState) -> Dictionary:
	var out: Dictionary = {}
	for cell: Vector3i in occupied(board):
		var key := Vector2i(cell.x, cell.z)
		if not out.has(key) or cell.y > (out[key] as Vector3i).y: out[key] = cell
	return out

static func bridge_path(board: BoardState, start: Vector3i) -> Array[Vector3i]:
	var tops: Dictionary = surface(board)
	var start_key := Vector2i(start.x, start.z)
	var result: Array[Vector3i] = []
	if not tops.has(start_key): return result
	var queue: Array[Vector2i] = [start_key]
	var parent: Dictionary = {start_key: start_key}
	var best: Vector2i = start_key
	var cursor: int = 0
	while cursor < queue.size():
		var at: Vector2i = queue[cursor]
		cursor += 1
		if at.x > best.x or (at.x == best.x and at.y < best.y): best = at
		for dir: Vector2i in [Vector2i.RIGHT, Vector2i(0, -1), Vector2i(0, 1), Vector2i.LEFT]:
			var next: Vector2i = at + dir
			if parent.has(next) or not tops.has(next): continue
			if absi((tops[next] as Vector3i).y - (tops[at] as Vector3i).y) > 1: continue
			parent[next] = at
			queue.append(next)
	var back: Array[Vector3i] = []
	while best != start_key:
		back.append(tops[best])
		best = parent[best]
	back.append(tops[start_key])
	back.reverse()
	result.assign(back)
	return result

static func bird_cell(board: BoardState, mascot: Vector3i) -> Dictionary:
	var choices: Array[Vector3i] = []
	for cell: Vector3i in surface(board).values():
		if cell.x <= 0 or cell.x >= board.size().x - 1 or (cell.x == mascot.x and cell.z == mascot.z): continue
		choices.append(cell)
	choices.sort_custom(func(a: Vector3i, b: Vector3i) -> bool: return a.x > b.x or (a.x == b.x and (a.y > b.y or (a.y == b.y and a.z < b.z))))
	return {} if choices.is_empty() else {"cell": choices[0]}

static func safe_layers(board: BoardState, lava_layer: int, coverage: float = 0.5) -> Array[int]:
	var result: Array[int] = []
	for layer: int in board.layer_count():
		if layer <= lava_layer: continue
		var active: int = 0
		var filled: int = 0
		for index: int in board.layer_cells(layer):
			if board.is_active(index):
				active += 1
				if board.fills_layer_at(board.cell(index)): filled += 1
		if active > 0 and float(filled) / active >= coverage: result.append(layer)
	return result

static func lava_interval(rise_index: int, start_ms: int = 12000, minimum_ms: int = 7000, step_ms: int = 500) -> int:
	return maxi(minimum_ms, start_ms - maxi(0, rise_index) * step_ms)

static func box_fill(board: BoardState, rim: int = 3) -> Dictionary:
	var count: int = 0
	var total: int = 0
	var full_layers: Array[int] = []
	for layer: int in mini(rim, board.layer_count()):
		var filled: int = 0
		var active: int = 0
		for index: int in board.layer_cells(layer):
			if board.is_active(index):
				active += 1
				if board.fills_layer_at(board.cell(index)): filled += 1
		count += filled
		total += active
		if active > 0 and active == filled: full_layers.append(layer)
	return {"filled": count, "total": total, "progress": float(count) / maxi(1, total), "layers": full_layers}
'''
actions=[{"tool":"script_create","arguments":{"path":"res://src/game/minigames/mg_geometry.gd","content":SOURCE}}, {"tool":"filesystem_manage","arguments":{"op":"scan","params":{}}}]
p=ROOT/"tools/godot-ai/jobs/minigames-geometry-b-1.json.tmp"
p.write_text(json.dumps({"id":"minigames-geometry-b-1","actions":actions}));p.rename(p.with_suffix(""))
