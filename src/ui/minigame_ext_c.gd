extends RefCounted
## UI extension for party minigames MG22-MG29: controls, hints and arena drawers.
## Intent args are sent as dict VALUES in insertion order (see WtMinigameRulesC).

const INK := Color("243b4d")
const CREAM := Color("fff8e7")
const MINT := Color("b8ddc7")
const ORANGE := Color("eaa05b")
const PALETTE: Array[Color] = [Color("ed9d72"), Color("8dbeb5"), Color("adb1d5"), Color("e6c875")]

## True for the ids this extension renders.
static func handles(id: String) -> bool:
	return id in ["mg22", "mg23", "mg24", "mg25", "mg26", "mg27", "mg28", "mg29"]

## Control rows `[label, intent_id, args]` for the round.
static func actions(id: String) -> Array:
	var rows: Array = []
	match id:
		"mg22":
			rows = [["‹ Aim", "mg_aim", {"dir": -1}], ["Aim ›", "mg_aim", {"dir": 1}], ["↶ Curve", "mg_spin", {"dir": -1}], ["Curve ↷", "mg_spin", {"dir": 1}], ["Bowl ↓", "mg_bowl", {}]]
		"mg23":
			for pad: int in 4: rows.append(["Pad %d" % (pad + 1), "mg_pad", {"pad": pad}])
		"mg24": rows = [["Tap!", "mg_tap", {}]]
		"mg25":
			for index: int in 4: rows.append(["Answer %d" % (index + 1), "mg_answer", {"index": index}])
		"mg26":
			for index: int in 6: rows.append(["Pick %d" % (index + 1), "mg_pick", {"index": index}])
		"mg27":
			for index: int in 16: rows.append(["Card %d" % (index + 1), "mg_flip", {"index": index}])
		"mg28": rows = [["‹ Step", "mg_step", {"dir": -1}], ["Step ›", "mg_step", {"dir": 1}]]
		"mg29":
			rows = [["Slide ←", "mg_slide", {"dir": Vector2i(-1, 0)}], ["Slide ↑", "mg_slide", {"dir": Vector2i(0, -1)}],
				["Slide ↓", "mg_slide", {"dir": Vector2i(0, 1)}], ["Slide →", "mg_slide", {"dir": Vector2i(1, 0)}]]
	return rows

## One-line hint under the arena.
static func note(id: String, view: Dictionary, snapshot: Dictionary) -> String:
	match id:
		"mg22": return "Frame %d · ball %d · aim, curve, then bowl%s" % [int(view.get("frame", 0)) + 1, int(view.get("ball_no", 1)), " · greased lane!" if int(view.get("greased_until_ms", 0)) > int(snapshot.get("elapsed_ms", 0)) else ""]
		"mg23": return "Watch the pads…" if bool(view.get("showing", true)) else "Your turn · repeat all %d" % int(view.get("length", 0))
		"mg24":
			match str(view.get("signal", "wait")):
				"green": return "NOW!"
				"amber": return "Amber is a fake · hold still"
				"gap": return "Get ready…"
				_: return "Wait for green…"
		"mg25": return "Count every cube, even hidden ones" if bool(view.get("showing", true)) else "How many cubes were there?"
		"mg26": return "Which one is the mirror twin, not a turn?"
		"mg27": return "Find the matching pairs"
		"mg28": return "Hearts %d · step out of the shadows" % int(view.get("hearts", 3))
		"mg29": return "Tiles in place %d/8 · puzzle %d of %d" % [int(view.get("correct", 0)), int(view.get("puzzles", 0)) + 1, int(view.get("target", 2))]
	return ""

## Draws the round into `area` of the arena control.
static func draw(arena: Control, id: String, area: Rect2, view: Dictionary, data: Dictionary) -> void:
	match id:
		"mg22": _bowling(arena, area, view)
		"mg23": _sequence(arena, area, view)
		"mg24": _signal(arena, area, view)
		"mg25": _count(arena, area, view)
		"mg26": _odd(arena, area, view)
		"mg27": _pairs(arena, area, view)
		"mg28": _dodge(arena, area, view, data)
		"mg29": _slide(arena, area, view)
	var attacks: Array = data.get("attacks", [])
	if not attacks.is_empty():
		arena.draw_rect(Rect2(Vector2(4, 4), arena.size - Vector2(8, 8)), Color(str((attacks[0] as Dictionary).get("sender_colour", "d67965"))), false, 5)

static func _cap(arena: Control, text: String, point: Vector2, size: int = 18, color: Color = INK) -> void:
	arena.draw_string(arena.get_theme_default_font(), point, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

static func _hue(value: Variant) -> Color:
	return PALETTE[posmod(int(value), 4)]

static func _bowling(arena: Control, area: Rect2, view: Dictionary) -> void:
	_cap(arena, "BLOCK BOWLING · knock down the cube pins", Vector2(20, 27))
	var cols: int = int(view.get("cols", 5))
	var rows: int = int(view.get("rows", 9))
	var unit: float = minf(area.size.x / (cols + 1), area.size.y / (rows + 1))
	var origin: Vector2 = area.get_center() - Vector2(cols, rows) * unit * 0.5
	arena.draw_rect(Rect2(origin, Vector2(cols, rows) * unit), Color("e9dcb8"))
	arena.draw_rect(Rect2(origin, Vector2(cols, rows) * unit), INK, false, 2)
	for pin: Vector2i in view.get("pins", []):
		var centre: Vector2 = origin + (Vector2(pin.x, pin.y - 1) + Vector2(0.5, 0.5)) * unit
		arena.draw_rect(Rect2(centre - Vector2.ONE * unit * 0.3, Vector2.ONE * unit * 0.6), CREAM)
		arena.draw_rect(Rect2(centre - Vector2.ONE * unit * 0.3, Vector2.ONE * unit * 0.6), INK, false, 2)
	var ball: Dictionary = view.get("ball", {})
	var width: int = int(ball.get("w", 1))
	var row: int = clampi(int(ball.get("row", 0)), 0, rows - 1)
	var rect: Rect2 = Rect2(origin + Vector2(int(ball.get("col", 2)), row) * unit + Vector2(3, 3), Vector2(width * unit - 6, unit - 6))
	arena.draw_rect(rect, _hue(ball.get("hue", 0)))
	arena.draw_rect(rect, INK, false, 2)
	_cap(arena, "curve %+d" % int(ball.get("curve", 0)), Vector2(origin.x + cols * unit + 8, origin.y + 20), 16)

static func _sequence(arena: Control, area: Rect2, view: Dictionary) -> void:
	_cap(arena, "SIMON STACK · repeat the pads", Vector2(20, 27))
	var positions: Array = view.get("positions", [0, 1, 2, 3])
	var pads: Array = view.get("pads", [])
	var cell: Vector2 = Vector2(minf(area.size.x / 2.0, 220.0), minf(area.size.y / 2.0, 120.0))
	var origin: Vector2 = area.get_center() - cell
	for pad: int in 4:
		var slot: int = int(positions[pad]) if positions.size() > pad else pad
		var rect: Rect2 = Rect2(origin + Vector2(slot % 2, slot / 2) * cell + Vector2(6, 6), cell - Vector2(12, 12))
		var lit: bool = int(view.get("flash", -1)) == pad
		arena.draw_rect(rect, _hue(pad) if lit else _hue(pad).darkened(0.25))
		arena.draw_rect(rect, CREAM if lit else INK, false, 5 if lit else 2)
		_cap(arena, "%d · %s" % [pad + 1, str(pads[pad] if pads.size() > pad else "").replace("_", " ")], rect.position + Vector2(10, 28), 16, CREAM if not lit else INK)
	if bool(view.get("swapped", false)): _cap(arena, "Pads swapped!", Vector2(area.position.x + 6, area.end.y - 4), 16, Color("aa412c"))

static func _signal(arena: Control, area: Rect2, view: Dictionary) -> void:
	_cap(arena, "QUICK DROP · tap on green", Vector2(20, 27))
	var state: String = str(view.get("signal", "wait"))
	var colour: Color = {"green": Color("6fbf7d"), "amber": Color("e6a94f"), "wait": Color("d67965"), "gap": Color("b7c6bb")}.get(state, Color("b7c6bb"))
	var centre: Vector2 = area.get_center()
	var radius: float = minf(area.size.x, area.size.y) * 0.32
	arena.draw_circle(centre, radius, colour)
	arena.draw_arc(centre, radius, 0, TAU, 32, INK, 4, true)
	_cap(arena, state.to_upper(), centre + Vector2(-26, 6), 22, INK)
	if bool(view.get("false_start", false)): _cap(arena, "False start!", centre + Vector2(-48, radius + 28), 20, Color("aa412c"))
	elif int(view.get("last_reaction_ms", -1)) >= 0: _cap(arena, "%d ms" % int(view.get("last_reaction_ms", 0)), centre + Vector2(-30, radius + 28), 18)

static func _count(arena: Control, area: Rect2, view: Dictionary) -> void:
	_cap(arena, "CUBE COUNT", Vector2(20, 27))
	if bool(view.get("showing", true)):
		var rows: Array = []
		var hues: Array = view.get("hues", [])
		var index: int = 0
		for cell: Vector3i in view.get("cells", []):
			rows.append({"cell": cell, "color": _hue(hues[index] if hues.size() > index else 0)})
			index += 1
		arena.call("_iso", area, rows, Vector3i(4, 8, 4))
		return
	var choices: Array = view.get("choices", [])
	var width: float = area.size.x / 4.0
	for index: int in choices.size():
		var rect: Rect2 = Rect2(area.position + Vector2(index * width + 8, area.size.y * 0.3), Vector2(width - 16, area.size.y * 0.4))
		arena.draw_rect(rect, _hue(index).lightened(0.2))
		arena.draw_rect(rect, INK, false, 3)
		_cap(arena, "%d" % int(choices[index]), rect.get_center() + Vector2(-10, 8), 26)

static func _odd(arena: Control, area: Rect2, view: Dictionary) -> void:
	_cap(arena, "ODD BLOCK OUT · find the mirror twin", Vector2(20, 27))
	var copies: Array = view.get("copies", [])
	if copies.is_empty(): return
	var per_row: int = 3 if copies.size() > 4 else 2
	var line_count: int = ceili(float(copies.size()) / per_row)
	var cell: Vector2 = Vector2(area.size.x / per_row, area.size.y / line_count)
	for index: int in copies.size():
		var rect: Rect2 = Rect2(area.position + Vector2(index % per_row, index / per_row) * cell + Vector2(4, 4), cell - Vector2(8, 8))
		arena.draw_rect(rect, Color("f1e7cb"))
		arena.draw_rect(rect, INK, false, 1.5)
		var colour: Color = _hue((copies[index] as Dictionary).get("hue", 0))
		var cells: Array = (copies[index] as Dictionary).get("cells", [])
		var unit: float = minf(rect.size.x, rect.size.y) / 6.0
		for point: Vector3i in cells:
			# Oblique projection so depth stays readable.
			var at: Vector2 = rect.position + Vector2(rect.size.x * 0.5 - 1.5 * unit, rect.size.y * 0.7) + Vector2(point.x * unit + point.z * unit * 0.45, -point.y * unit - point.z * unit * 0.35)
			arena.draw_rect(Rect2(at, Vector2.ONE * unit * 0.9), colour.darkened(0.1 * point.z))
			arena.draw_rect(Rect2(at, Vector2.ONE * unit * 0.9), INK, false, 1)
		_cap(arena, str(index + 1), rect.position + Vector2(6, 20), 16)

static func _pairs(arena: Control, area: Rect2, view: Dictionary) -> void:
	_cap(arena, "TOY PAIRS", Vector2(20, 27))
	var cols: int = int(view.get("cols", 4))
	var rows: int = int(view.get("rows", 4))
	var unit: float = minf(area.size.x / cols, area.size.y / rows)
	var origin: Vector2 = area.get_center() - Vector2(cols, rows) * unit * 0.5
	var faces: Array = view.get("faces", [])
	var matched: Array = view.get("matched", [])
	var info: Array = view.get("face_shapes", [])
	var swaps: Array = view.get("swap_cells", [])
	for index: int in faces.size():
		var hop: float = -6.0 if swaps.has(index) else 0.0
		var rect: Rect2 = Rect2(origin + Vector2(index % cols, index / cols) * unit + Vector2(3, 3 + hop), Vector2.ONE * (unit - 6))
		var face: int = int(faces[index])
		var done: bool = matched.size() > index and bool(matched[index])
		if face < 0:
			arena.draw_rect(rect, Color("a9bfb4"))
		else:
			var entry: Dictionary = info[face] if info.size() > face else {}
			arena.draw_rect(rect, _hue(entry.get("hue", face)).lightened(0.15 if done else 0.0))
			_cap(arena, str(entry.get("shape", "")).left(3).to_upper(), rect.position + Vector2(6, unit * 0.55), 16)
		arena.draw_rect(rect, MINT if done else INK, false, 3 if done else 2)
		_cap(arena, str(index + 1), rect.position + Vector2(4, 16), 12, Color(INK, 0.6))

static func _dodge(arena: Control, area: Rect2, view: Dictionary, data: Dictionary) -> void:
	_cap(arena, "BLOCK DODGE", Vector2(20, 27))
	var lanes: int = int(view.get("lanes", 5))
	var width: float = area.size.x / lanes
	var now: int = int(data.get("elapsed_ms", 0))
	var shadow: int = maxi(1, int(view.get("shadow_ms", 900)))
	var floor_y: float = area.end.y - 40
	for lane: int in lanes:
		arena.draw_rect(Rect2(Vector2(area.position.x + lane * width + 3, area.position.y), Vector2(width - 6, area.size.y)), Color("efe3c5") if lane % 2 == 0 else Color("e8dcbc"))
	for drop: Dictionary in view.get("drops", []):
		var left: float = area.position.x + int(drop.get("lane", 0)) * width + 6
		var span: float = int(drop.get("width", 1)) * width - 12
		var t: float = clampf(1.0 - float(int(drop.get("impact", now)) - now) / shadow, 0.0, 1.0)
		arena.draw_rect(Rect2(Vector2(left, floor_y + 8), Vector2(span, 10)), Color(INK, 0.15 + 0.4 * t))
		var y: float = lerpf(area.position.y, floor_y - 30, t * t)
		arena.draw_rect(Rect2(Vector2(left, y), Vector2(span, 30)), ORANGE)
		arena.draw_rect(Rect2(Vector2(left, y), Vector2(span, 30)), INK, false, 2)
	var me: Vector2 = Vector2(area.position.x + (int(view.get("lane", 2)) + 0.5) * width, floor_y)
	arena.draw_circle(me, minf(width * 0.3, 22.0), MINT)
	arena.draw_arc(me, minf(width * 0.3, 22.0), 0, TAU, 20, INK, 3, true)
	for heart: int in int(view.get("hearts", 3)): arena.draw_circle(Vector2(area.end.x - 18 - heart * 26, area.position.y + 14), 9, Color("d67965"))

static func _slide(arena: Control, area: Rect2, view: Dictionary) -> void:
	_cap(arena, "SLIDE SHUFFLE · tiles 1-8 in order", Vector2(20, 27))
	var size: int = int(view.get("size", 3))
	var unit: float = minf(area.size.x, area.size.y) / size
	var origin: Vector2 = area.get_center() - Vector2.ONE * unit * size * 0.5
	var tiles: Array = view.get("tiles", [])
	for index: int in tiles.size():
		var tile: int = int(tiles[index])
		if tile == 0: continue
		var rect: Rect2 = Rect2(origin + Vector2(index % size, index / size) * unit + Vector2(3, 3), Vector2.ONE * (unit - 6))
		var home: bool = tile == index + 1
		arena.draw_rect(rect, MINT if home else _hue(tile - 1).lightened(0.1))
		arena.draw_rect(rect, INK, false, 3)
		_cap(arena, str(tile), rect.get_center() + Vector2(-8, 9), 26)
