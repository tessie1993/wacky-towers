class_name WtPiecePreview extends Control
## Draws a piece as glossy isometric toy cubes (NEXT plaque and the bottom tray).
## Display only: cells and colour come from the HUD snapshot.

## Cube offsets of the piece in its spawn orientation.
var cells: Array = []:
	set(value):
		cells = value
		queue_redraw()
## Body colour of the cubes.
var tint: Color = Color("6e9cf0"):
	set(value):
		tint = value
		queue_redraw()

const COS30 := 0.8660254


func _draw() -> void:
	if cells.is_empty():
		return
	var lo := Vector3(INF, INF, INF)
	var hi := Vector3(-INF, -INF, -INF)
	for c: Variant in cells:
		var v: Vector3 = Vector3(c)
		lo = lo.min(v)
		hi = hi.max(v)
	var span: Vector3 = hi - lo + Vector3.ONE
	# Projected footprint in cube units, then fit the drawing to this control.
	var width_units: float = (span.x + span.z) * COS30
	var height_units: float = (span.x + span.z) * 0.5 + span.y
	var unit: float = minf(size.x / maxf(width_units, 0.1), size.y / maxf(height_units, 0.1)) * 0.92
	var origin := Vector2(size.x * 0.5 + (span.z - span.x) * 0.5 * COS30 * unit, size.y * 0.5 - (height_units * 0.5 - span.y) * unit)
	var order: Array = cells.duplicate()
	order.sort_custom(func(a: Variant, b: Variant) -> bool:
		var va: Vector3 = Vector3(a) - lo
		var vb: Vector3 = Vector3(b) - lo
		return va.x + va.z - va.y * 0.01 < vb.x + vb.z - vb.y * 0.01 if absf(va.y - vb.y) < 0.5 else va.y < vb.y)
	for c: Variant in order:
		_cube(origin, Vector3(c) - lo - span * 0.5 + Vector3(0.5, 0.5, 0.5) * 0.0, unit)


func _project(origin: Vector2, p: Vector3, unit: float) -> Vector2:
	return origin + Vector2((p.x - p.z) * COS30, (p.x + p.z) * 0.5 - p.y) * unit


func _cube(origin: Vector2, p: Vector3, unit: float) -> void:
	var o := p
	var top := PackedVector2Array([_project(origin, o + Vector3(0, 1, 0), unit), _project(origin, o + Vector3(1, 1, 0), unit),
		_project(origin, o + Vector3(1, 1, 1), unit), _project(origin, o + Vector3(0, 1, 1), unit)])
	var left := PackedVector2Array([_project(origin, o + Vector3(0, 1, 1), unit), _project(origin, o + Vector3(1, 1, 1), unit),
		_project(origin, o + Vector3(1, 0, 1), unit), _project(origin, o + Vector3(0, 0, 1), unit)])
	var right := PackedVector2Array([_project(origin, o + Vector3(1, 1, 0), unit), _project(origin, o + Vector3(1, 1, 1), unit),
		_project(origin, o + Vector3(1, 0, 1), unit), _project(origin, o + Vector3(1, 0, 0), unit)])
	var edge: Color = tint.darkened(0.55)
	draw_colored_polygon(left, tint.darkened(0.12))
	draw_colored_polygon(right, tint.darkened(0.3))
	draw_colored_polygon(top, tint.lightened(0.22))
	for face: PackedVector2Array in [left, right, top]:
		var loop := face.duplicate()
		loop.append(face[0])
		draw_polyline(loop, edge, maxf(1.0, unit * 0.05), true)
	# A small gloss dot keeps the toy feel at any size.
	var glint: Vector2 = (top[0] + top[2]) * 0.5 + (top[3] - top[1]) * 0.18
	draw_circle(glint, maxf(1.0, unit * 0.08), Color(1, 1, 1, 0.65))
