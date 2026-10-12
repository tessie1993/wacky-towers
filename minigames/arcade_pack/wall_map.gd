extends Control
## Exact 2D projection comparison, alongside the 3D gate. Up is screen-up.

var hole: Array = []
var projection: Array = []
var frame_size: int = 5
var title: String = "FRONT GATE"


## Copies the visible current outline and opening; never exposes hidden rotation.
func update_map(opening: Array, current: Array, size: int, axis: String) -> void:
	hole = opening.duplicate()
	projection = current.duplicate()
	frame_size = size
	title = "SIDE GATE" if axis == "x" else "FRONT GATE"
	queue_redraw()


func _draw() -> void:
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(10, 23), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("2e2433"))
	var cell: float = minf(34.0, (size.x - 20) / frame_size)
	for x: int in frame_size:
		for y: int in frame_size:
			var location: Vector2 = Vector2(10 + x * cell, 35 + (frame_size - 1 - y) * cell)
			var rect: Rect2 = Rect2(location, Vector2.ONE * (cell - 2))
			var coordinate: Vector2i = Vector2i(x, y)
			var open: bool = hole.has(coordinate)
			draw_rect(rect, Color("fff4de") if open else Color("9692aa"))
			if open:
				draw_rect(rect.grow(-1), Color("d0ac59"), false, 2)
			if projection.has(coordinate):
				draw_rect(rect.grow(-6), Color("5dcb9e") if open else Color("ff6a13"))
				if not open:
					draw_line(rect.position + Vector2(7, 7), rect.end - Vector2(7, 7), Color("2e2433"), 2)
					draw_line(Vector2(rect.end.x - 7, rect.position.y + 7), Vector2(rect.position.x + 7, rect.end.y - 7), Color("2e2433"), 2)
	draw_string(font, Vector2(10, 35 + frame_size * cell + 22), "Squares = your parcel", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("2e2433"))
	draw_string(font, Vector2(10, 35 + frame_size * cell + 41), "Crosses = blocked", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("2e2433"))
