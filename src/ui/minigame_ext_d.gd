extends RefCounted
## UI extension for wave-2 party minigames MG30-MG36 (read by `WtMinigameUi.ext_for`).
## Display only: it reads the session snapshot's `view` and offers semantic intents.
const IDS: Array[String] = ["mg30", "mg31", "mg32", "mg33", "mg34", "mg35", "mg36"]
const INK := Color("243b4d")
const CREAM := Color("fff8e7")
const MINT := Color("b8ddc7")
const ORANGE := Color("eaa05b")
const ROSE := Color("d87967")
const PAPER := Color("dde4d6")

## True when this extension draws and controls minigame `id`.
static func handles(id: String) -> bool:
	return id in IDS

## Button rows `[label, intent_id, args]` for minigame `id`.
static func actions(id: String) -> Array:
	var arrows: Array = []
	for row: Array in [["←", Vector3i.LEFT], ["↑", Vector3i(0, 0, -1)], ["↓", Vector3i(0, 0, 1)], ["→", Vector3i.RIGHT]]:
		arrows.append([row[0], &"mg_move", {"direction": row[1]}])
	match id:
		"mg30": return arrows + [["Paint ●", &"mg_paint", {}], ["Submit ✓", &"mg_submit", {}]]
		"mg31":
			var rows: Array = []
			for index: int in 4: rows.append(["Answer %d" % (index + 1), &"mg_answer", {"index": index}])
			return rows
		"mg32":
			var rows: Array = []
			for index: int in 9: rows.append(["Hole %d" % (index + 1), &"mg_whack", {"index": index}])
			return rows
		"mg33": return arrows + [["Pull ✋", &"mg_pull", {}]]
		"mg34":
			var rows: Array = []
			for axis: int in 3:
				for dir: int in [-1, 1]: rows.append([["Turn", "Flip", "Roll"][axis] + (" ‹" if dir < 0 else " ›"), &"mg_rotate", {"axis": axis, "dir": dir}])
			rows.append(["Check ✓", &"mg_submit", {}])
			return rows
		"mg35": return [["← Aim", &"mg_aim", {"dir": -1}], ["Aim →", &"mg_aim", {"dir": 1}], ["Drop ↓", &"mg_bowl", {}]]
		"mg36": return arrows + [["Dig ⛏", &"mg_dig", {}]]
	return []

## One-line status text under the arena.
static func note(id: String, view: Dictionary, _snapshot: Dictionary) -> String:
	match id:
		"mg31":
			var choices: Array = view.get("choices", [])
			if choices.is_empty(): return "Watch the parade · count colour %d" % (int(view.get("target_hue", 0)) + 1)
			var parts: PackedStringArray = PackedStringArray()
			for index: int in choices.size(): parts.append("%d: %d" % [index + 1, int(choices[index])])
			return "How many were the target colour?  " + "   ".join(parts)
		"mg33":
			if bool(view.get("rebuilding", false)): return "The tower tumbled · rebuilding…"
			return "Wobble! Gentle pulls only" if bool(view.get("wobbling", false)) else str(view.get("hint", ""))
		"mg34":
			var locked: int = int(view.get("locked_axis", -1))
			return "Turns %d · the %s turn is stuck!" % [int(view.get("turns", 0)), ["Turn", "Flip", "Roll"][locked]] if locked >= 0 else "Turns %d · fewer turns, more points" % int(view.get("turns", 0))
		"mg35":
			return "★ JACKPOT · the 10 bucket is double!" if bool(view.get("jackpot_active", false)) else str(view.get("hint", ""))
		"mg36": return "Misses %d · treasures %d" % [int(view.get("miss_count", 0)), int(view.get("treasures", 0))]
	return str(view.get("hint", ""))

## Draws the arena for `id` inside `area`.
static func draw(arena: Control, id: String, area: Rect2, view: Dictionary, data: Dictionary) -> void:
	match id:
		"mg30": _mirror(arena, area, view)
		"mg31": _tally(arena, area, view)
		"mg32": _whack(arena, area, view, data)
		"mg33": _pull(arena, area, view)
		"mg34": _spin(arena, area, view)
		"mg35": _plinko(arena, area, view, data)
		"mg36": _dig(arena, area, view)
	var attacks: Array = data.get("attacks", [])
	if not attacks.is_empty():
		arena.draw_rect(Rect2(Vector2(4, 4), arena.size - Vector2(8, 8)), Color(str((attacks[0] as Dictionary).get("sender_colour", "d67965"))), false, 5)

static func _hue(index: int) -> Color:
	return [Color("ed9d72"), Color("8dbeb5"), Color("adb1d5"), Color("e6c875")][posmod(index, 4)]

## Rect of a square cell in a `dims` grid fitted in `box`; row 0 is the top.
static func _cell(box: Rect2, dims: Vector2i, cell: Vector2i) -> Rect2:
	var unit: float = minf(box.size.x / dims.x, box.size.y / dims.y)
	var origin: Vector2 = box.get_center() - Vector2(dims) * unit * 0.5
	return Rect2(origin + Vector2(cell) * unit, Vector2.ONE * (unit - 3.0))

static func _board(arena: Control, box: Rect2, dims: Vector2i, filled: Array, color: Color, ghost: Array = [], cursor: Vector2i = Vector2i(-1, -1)) -> void:
	for y: int in dims.y:
		for x: int in dims.x:
			var rect: Rect2 = _cell(box, dims, Vector2i(x, y))
			var here: Vector2i = Vector2i(x, y)
			arena.draw_rect(rect, color if filled.has(here) else (MINT.lightened(0.3) if ghost.has(here) else PAPER))
			arena.draw_rect(rect, Color("80968d"), false, 1.5)
	if cursor.x >= 0:
		arena.draw_rect(_cell(box, dims, cursor).grow(1.0), INK, false, 4)

static func _mirror(arena: Control, area: Rect2, view: Dictionary) -> void:
	var dims: Vector2i = Vector2i(5, 5)
	var left: Rect2 = Rect2(area.position, Vector2(area.size.x * 0.47, area.size.y))
	var right: Rect2 = Rect2(area.position + Vector2(area.size.x * 0.53, 0), Vector2(area.size.x * 0.47, area.size.y))
	_board(arena, left, dims, view.get("pattern", []), ORANGE)
	_board(arena, right, dims, view.get("painted", []), MINT, [], view.get("cursor", Vector2i.ZERO))
	var mid_x: float = area.position.x + area.size.x * 0.5
	if str(view.get("axis", "v")) == "v":
		arena.draw_dashed_line(Vector2(mid_x, area.position.y), Vector2(mid_x, area.end.y), INK, 3.0, 8.0)
	else:
		arena.draw_dashed_line(Vector2(right.position.x, right.get_center().y), Vector2(right.end.x, right.get_center().y), ROSE, 3.0, 8.0)
	arena._caption("PATTERN", Vector2(20, 27))
	arena._caption("YOUR MIRROR", Vector2(arena.size.x * 0.53 + 20, 27))

static func _tally(arena: Control, area: Rect2, view: Dictionary) -> void:
	arena._caption("TARGET COLOUR", Vector2(20, 27))
	arena.draw_circle(Vector2(arena.size.x - 40, 22), 14, _hue(int(view.get("target_hue", 0))))
	arena.draw_arc(Vector2(arena.size.x - 40, 22), 14, 0, TAU, 20, INK, 2.5, true)
	var current: Dictionary = view.get("current", {})
	var total: int = maxi(1, int(view.get("total", 1)))
	var belt: Rect2 = Rect2(area.position + Vector2(0, area.size.y * 0.62), Vector2(area.size.x, area.size.y * 0.12))
	arena.draw_rect(belt, PAPER)
	if not current.is_empty():
		var phase: float = float(int(view.get("shown", 0)) + 1) / total
		var centre: Vector2 = Vector2(lerpf(area.position.x + 24, area.end.x - 24, phase), area.get_center().y)
		arena.draw_rect(Rect2(centre - Vector2(28, 28), Vector2(56, 56)), _hue(int(current.get("hue", 0))))
		arena.draw_rect(Rect2(centre - Vector2(28, 28), Vector2(56, 56)), INK, false, 3)
		arena._caption(str(current.get("shape", "")).replace("_", " ").capitalize(), centre + Vector2(-32, 52))
	else:
		var choices: Array = view.get("choices", [])
		var unit: float = area.size.x / maxf(1.0, choices.size())
		for index: int in choices.size():
			var rect: Rect2 = Rect2(area.position + Vector2(index * unit + 8, area.size.y * 0.25), Vector2(unit - 16, area.size.y * 0.4))
			arena.draw_rect(rect, MINT)
			arena.draw_rect(rect, INK, false, 3)
			arena._caption(str(int(choices[index])), rect.get_center() + Vector2(-8, 6))
	arena.draw_rect(Rect2(area.position + Vector2(0, area.size.y - 10), Vector2(area.size.x * clampf(float(int(view.get("shown", 0))) / total, 0, 1), 6)), ORANGE)

static func _whack(arena: Control, area: Rect2, view: Dictionary, _data: Dictionary) -> void:
	var dims: Vector2i = Vector2i(3, 3)
	arena._caption("TAP THE BLOCKS · NOT THE BOMBS", Vector2(20, 27))
	var pops: Dictionary = {}
	for pop: Dictionary in view.get("pops", []): pops[int(pop.get("index", -1))] = pop
	for index: int in 9:
		var rect: Rect2 = _cell(area, dims, Vector2i(index % 3, index / 3))
		arena.draw_rect(rect, Color("b7a58a"))
		arena.draw_rect(Rect2(rect.position + Vector2(6, rect.size.y * 0.55), Vector2(rect.size.x - 12, rect.size.y * 0.35)), INK.lightened(0.15))
		arena._caption(str(index + 1), rect.position + Vector2(6, 20), CREAM)
		if pops.has(index):
			var kind: String = str(pops[index].get("kind", "block"))
			var centre: Vector2 = rect.get_center()
			var color: Color = Color("e6c875") if kind == "golden" else (INK if kind == "bomb" else ORANGE)
			arena.draw_rect(Rect2(centre - Vector2.ONE * rect.size.x * 0.25, Vector2.ONE * rect.size.x * 0.5), color)
			if kind == "bomb": arena.draw_circle(centre, rect.size.x * 0.12, ROSE)

static func _pull(arena: Control, area: Rect2, view: Dictionary) -> void:
	var layers: Array = view.get("layers", [])
	arena._caption("PULL A BAR · KEEP EVERY LAYER STANDING", Vector2(20, 27))
	var rows: int = maxi(9, layers.size())
	var unit: float = minf(area.size.y / rows, area.size.x / 8.0)
	var shake: float = (3.0 if int(view.get("pulls", 0)) % 2 == 0 else -3.0) if bool(view.get("wobbling", false)) else 0.0
	var cursor: Vector2i = view.get("cursor", Vector2i(1, 0))
	for l: int in layers.size():
		var bars: Array = layers[l]
		var y: float = area.end.y - (l + 1) * unit
		for slot: int in 3:
			var rect: Rect2 = Rect2(Vector2(area.get_center().x + (slot - 1.5) * unit * 2.0 + shake, y), Vector2(unit * 2.0 - 4, unit - 3))
			if bool(bars[slot]):
				arena.draw_rect(rect, ORANGE if l % 2 == 0 else _hue(1))
				arena.draw_rect(rect, INK, false, 1.5)
			if cursor == Vector2i(slot, l): arena.draw_rect(rect.grow(2.0), ROSE, false, 3)
	if bool(view.get("rebuilding", false)): arena._caption("CRASH! Rebuilding…", area.get_center(), ROSE)

static func _spin(arena: Control, area: Rect2, view: Dictionary) -> void:
	var left: Rect2 = Rect2(area.position, Vector2(area.size.x * 0.47, area.size.y))
	var right: Rect2 = Rect2(area.position + Vector2(area.size.x * 0.53, 0), Vector2(area.size.x * 0.47, area.size.y))
	_voxels(arena, left, view.get("target_cells", []), MINT)
	_voxels(arena, right, view.get("cells", []), ORANGE)
	arena._caption("TARGET", Vector2(20, 27))
	arena._caption("YOUR BLOCK · turns %d" % int(view.get("turns", 0)), Vector2(arena.size.x * 0.53 + 20, 27))
	var locked: int = int(view.get("locked_axis", -1))
	if locked >= 0: arena._caption("%s locked" % ["Turn", "Flip", "Roll"][locked], right.position + Vector2(8, right.size.y - 8), ROSE)

## Small isometric cube cluster centred in `box`.
static func _voxels(arena: Control, box: Rect2, cells: Array, color: Color) -> void:
	var u: float = minf(box.size.x, box.size.y) / 7.0
	var sorted: Array = cells.duplicate()
	sorted.sort_custom(func(a: Vector3i, b: Vector3i) -> bool: return a.y < b.y or (a.y == b.y and a.x + a.z < b.x + b.z))
	for cell: Vector3i in sorted:
		var p: Vector2 = box.get_center() + Vector2((cell.x - cell.z) * u, (cell.x + cell.z) * u * 0.5 - cell.y * u * 0.9)
		var top: PackedVector2Array = PackedVector2Array([p + Vector2(0, -u * 0.5), p + Vector2(u, 0), p + Vector2(0, u * 0.5), p + Vector2(-u, 0)])
		arena.draw_colored_polygon(PackedVector2Array([top[3], top[2], top[2] + Vector2(0, u * 0.8), top[3] + Vector2(0, u * 0.8)]), color.darkened(0.2))
		arena.draw_colored_polygon(PackedVector2Array([top[2], top[1], top[1] + Vector2(0, u * 0.8), top[2] + Vector2(0, u * 0.8)]), color.darkened(0.1))
		arena.draw_colored_polygon(top, color)
		arena.draw_polyline(PackedVector2Array([top[0], top[1], top[2], top[3], top[0]]), Color(INK, 0.5), 1.4, true)

static func _plinko(arena: Control, area: Rect2, view: Dictionary, data: Dictionary) -> void:
	var cols: int = int(view.get("columns", 7))
	var rows: int = int(view.get("rows", 6))
	var buckets: Array = view.get("buckets", [])
	var pattern: Array = view.get("pattern", [])
	var unit_x: float = area.size.x / cols
	var unit_y: float = area.size.y / (rows + 2)
	arena._caption("PICK A COLUMN · DROP FOR THE 10", Vector2(20, 27))
	for r: int in rows:
		for c: int in cols:
			var p: Vector2 = area.position + Vector2((c + 0.5) * unit_x, (r + 1.5) * unit_y)
			arena.draw_circle(p, 5, INK)
			var lean: int = int((pattern[r] as Array)[c]) if r < pattern.size() else 0
			arena.draw_line(p, p + Vector2(lean * unit_x * 0.25, unit_y * 0.25), ORANGE, 2.5)
	var jackpot: bool = bool(view.get("jackpot_active", false))
	for c: int in mini(cols, buckets.size()):
		var rect: Rect2 = Rect2(area.position + Vector2(c * unit_x + 3, area.size.y - unit_y * 0.8), Vector2(unit_x - 6, unit_y * 0.8))
		var top: bool = int(buckets[c]) == 10
		arena.draw_rect(rect, Color("e6c875") if top and jackpot else (MINT if top else PAPER))
		arena.draw_rect(rect, INK, false, 2)
		arena._caption(str(int(buckets[c]) * (2 if top and jackpot else 1)), rect.position + Vector2(rect.size.x * 0.3, 20))
	var aim: int = int(view.get("aim", 3))
	arena.draw_rect(Rect2(area.position + Vector2(aim * unit_x + 6, 2), Vector2(unit_x - 12, unit_y * 0.6)), ORANGE)
	var drop: Dictionary = view.get("drop", {})
	if not drop.is_empty():
		var row: int = clampi(int(drop.get("row", 0)), 0, rows)
		arena.draw_circle(area.position + Vector2((int(drop.get("col", aim)) + 0.5) * unit_x, (row + 0.9) * unit_y), 10, ROSE)
	if int(data.get("elapsed_ms", 0)) < int(view.get("cooldown_until", 0)):
		arena.draw_rect(Rect2(area.position + Vector2(0, area.size.y - 4), Vector2(area.size.x, 4)), ROSE)

static func _dig(arena: Control, area: Rect2, view: Dictionary) -> void:
	var size: int = int(view.get("size", 6))
	var dims: Vector2i = Vector2i(size, size)
	arena._caption("DIG · HOT-COLD NUMBERS POINT TO THE TREASURE", Vector2(20, 27))
	var revealed: Array = view.get("revealed", [])
	var misses: Dictionary = view.get("misses", {})
	for y: int in size:
		for x: int in size:
			var cell: Vector2i = Vector2i(x, y)
			var rect: Rect2 = _cell(area, dims, cell)
			var color: Color = Color("b79a74")
			if revealed.has(cell): color = Color("e6c875")
			elif misses.has(cell): color = Color("e3d3b4")
			arena.draw_rect(rect, color)
			arena.draw_rect(rect, Color("80968d"), false, 1.5)
			if misses.has(cell): arena._caption(str(int(misses[cell])), rect.position + Vector2(rect.size.x * 0.3, rect.size.y * 0.65))
	arena.draw_rect(_cell(area, dims, view.get("cursor", Vector2i.ZERO)).grow(1.0), INK, false, 4)
