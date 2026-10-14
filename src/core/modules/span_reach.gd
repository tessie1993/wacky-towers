class_name WtSpanReach extends RefCounted
## A3 `span_goal` reachability (design/gdd/minigame-mechanics-wave4.md §A3; design/gdd/modules-framework.md).
## Pure: a column heightmap in, progress and path out. No board, no clock, no I/O.
## Usage: var r: Dictionary = WtSpanReach.evaluate(heights, 8, 3, Vector2i(0, 1), Vector2i(7, 1), 1, 0)

## Progress scale (HUD reads 0..PROGRESS_MAX).
const PROGRESS_MAX := 1000
## Height of a column with no cube; blocks walking.
const NO_COLUMN := -1
## Canonical BFS neighbour order (+x, -z, +z, -x), the mg06 `bridge_path` order, so the walker is deterministic.
const NEIGHBOURS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0)]


## BFS over the surface graph from `a`. Heights are indexed x + width * z (BoardSpec mask order).
## Returns {"reached": bool, "progress": int 0..1000, "path": Array[Vector2i] from a to the farthest node (b when reached)}.
## Usage: if WtSpanReach.evaluate(h, w, d, a, b, 1, 0)["reached"]: start_walk()
static func evaluate(heights: PackedInt32Array, width: int, depth: int, a: Vector2i, b: Vector2i, step_max: int, walk_layer_min: int) -> Dictionary:
	var path: Array[Vector2i] = []
	var result: Dictionary = {"reached": false, "progress": 0, "path": path}
	if a == b or heights.size() != width * depth or not _walkable(heights, width, depth, a, walk_layer_min):
		return result
	var axis: Vector2i = b - a
	var proj_b: int = axis.x * axis.x + axis.y * axis.y
	var parent: Dictionary = {a: a}
	var queue: Array[Vector2i] = [a]
	var cursor: int = 0
	var best: Vector2i = a
	var best_proj: int = 0
	while cursor < queue.size():
		var at: Vector2i = queue[cursor]
		cursor += 1
		var offset: Vector2i = at - a
		var proj: int = offset.x * axis.x + offset.y * axis.y
		if at == b:
			best = b
			best_proj = proj_b
			result["reached"] = true
			break
		if proj > best_proj:
			best_proj = proj
			best = at
		var h_at: int = heights[at.x + width * at.y]
		for dir: Vector2i in NEIGHBOURS:
			var next: Vector2i = at + dir
			if parent.has(next) or not _walkable(heights, width, depth, next, walk_layer_min):
				continue
			if absi(heights[next.x + width * next.y] - h_at) > step_max:
				continue
			parent[next] = at
			queue.append(next)
	result["progress"] = clampi(PROGRESS_MAX * best_proj / proj_b, 0, PROGRESS_MAX)
	var cursor_cell: Vector2i = best
	while cursor_cell != a:
		path.append(cursor_cell)
		cursor_cell = parent[cursor_cell]
	path.append(a)
	path.reverse()
	return result


## Structural checks for a `span` goal block on a width x depth board (ranges live in the module data).
## Usage: for msg in WtSpanReach.validate(level.goal, 8, 8): report(msg)
static func validate(goal: Dictionary, width: int, depth: int) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	var a: Variant = anchor(goal.get("anchor_a"))
	var b: Variant = anchor(goal.get("anchor_b"))
	for pair: Array in [["anchor_a", a], ["anchor_b", b]]:
		var cell: Variant = pair[1]
		if cell == null:
			out.append("goal.%s: must be [x, z] whole numbers" % pair[0])
		elif cell.x < 0 or cell.y < 0 or cell.x >= width or cell.y >= depth:
			out.append("goal.%s: outside the board" % pair[0])
	if a != null and b != null and a == b:
		out.append("goal.anchor_b: must differ from anchor_a")
	for key: String in ["step_max", "walk_ms"]:
		var v: Variant = JsonNum.whole_int(goal.get(key, 1))
		if v == null or v < 1:
			out.append("goal.%s: must be a positive whole number" % key)
	for key: String in ["walk_layer_min", "hold_ms"]:
		var v: Variant = JsonNum.whole_int(goal.get(key, 0))
		if v == null or v < 0:
			out.append("goal.%s: must be a whole number >= 0" % key)
	return out


## [x, z] -> Vector2i, or null when malformed. Usage: var a: Variant = WtSpanReach.anchor([0, 3])
static func anchor(raw: Variant) -> Variant:
	if not raw is Array or (raw as Array).size() != 2:
		return null
	var x: Variant = JsonNum.whole_int(raw[0])
	var z: Variant = JsonNum.whole_int(raw[1])
	if x == null or z == null:
		return null
	return Vector2i(x, z)


static func _walkable(heights: PackedInt32Array, width: int, depth: int, c: Vector2i, walk_layer_min: int) -> bool:
	if c.x < 0 or c.y < 0 or c.x >= width or c.y >= depth:
		return false
	var h: int = heights[c.x + width * c.y]
	return h != NO_COLUMN and h >= walk_layer_min
