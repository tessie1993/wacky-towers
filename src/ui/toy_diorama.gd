extends Control
## A crisp vector toy-box vignette: no external art dependencies or bitmap scaling.

const INK := Color("243b4d")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var k := minf(size.x / 500.0, size.y / 310.0)
	var origin := Vector2(size.x * 0.5 - 250.0 * k, size.y * 0.5 - 155.0 * k)
	draw_set_transform(origin, 0.0, Vector2.ONE * k)
	draw_circle(Vector2(250, 140), 140, Color("e4f2de"))
	draw_arc(Vector2(250, 140), 140, 0, TAU, 72, Color("cbdcc5"), 2, true)
	draw_circle(Vector2(380, 58), 25, Color("f2c45c"))
	# Floating meadow island.
	draw_colored_polygon(PackedVector2Array([Vector2(85, 210), Vector2(255, 152), Vector2(425, 211), Vector2(255, 278)]), Color("b77f59"))
	draw_colored_polygon(PackedVector2Array([Vector2(85, 200), Vector2(255, 142), Vector2(425, 201), Vector2(255, 259)]), Color("97c688"))
	draw_polyline(PackedVector2Array([Vector2(85, 200), Vector2(255, 142), Vector2(425, 201), Vector2(255, 259), Vector2(85, 200)]), INK, 3, true)
	_cube(Vector2(240, 166), Color("eea163"))
	_cube(Vector2(276, 178), Color("7bcdb8"))
	_cube(Vector2(240, 128), Color("aac0df"))
	_cube(Vector2(204, 177), Color("ecd16d"))
	_cube(Vector2(240, 90), Color("c4abdf"))
	# Cloud wizard and hat.
	for cloud in [Vector3(130, 93, 22), Vector3(158, 79, 30), Vector3(190, 92, 24)]:
		draw_circle(Vector2(cloud.x, cloud.y), cloud.z + 3, INK)
	for cloud in [Vector3(130, 93, 22), Vector3(158, 79, 30), Vector3(190, 92, 24)]:
		draw_circle(Vector2(cloud.x, cloud.y), cloud.z, Color("fff9ea"))
	draw_colored_polygon(PackedVector2Array([Vector2(137, 60), Vector2(174, 58), Vector2(170, 14)]), Color("7591b8"))
	draw_line(Vector2(129, 62), Vector2(181, 60), INK, 5, true)
	draw_circle(Vector2(147, 89), 3, INK)
	draw_circle(Vector2(169, 89), 3, INK)
	draw_arc(Vector2(158, 90), 11, .3, PI-.3, 16, INK, 2, true)
	# Pip and flowers.
	draw_circle(Vector2(345, 178), 18, Color("f6d478"))
	draw_circle(Vector2(339, 174), 2, INK)
	draw_circle(Vector2(350, 174), 2, INK)
	draw_line(Vector2(328, 191), Vector2(358, 191), INK, 3)
	for flower in [Vector2(135, 202), Vector2(360, 220), Vector2(290, 225)]:
		for n in 5:
			draw_circle(flower + Vector2.from_angle(float(n) * TAU / 5.0) * 5, 4, Color("fff9ea"))
		draw_circle(flower, 3, Color("eeb969"))
	draw_set_transform(Vector2.ZERO)

func _cube(at: Vector2, color: Color) -> void:
	var a := at + Vector2(0, -18)
	var b := at + Vector2(36, -6)
	var c := at + Vector2(0, 6)
	var d := at + Vector2(-36, -6)
	draw_colored_polygon(PackedVector2Array([a, b, c, d]), color.lightened(.22))
	draw_colored_polygon(PackedVector2Array([d, c, c + Vector2(0, 34), d + Vector2(0, 34)]), color)
	draw_colored_polygon(PackedVector2Array([c, b, b + Vector2(0, 34), c + Vector2(0, 34)]), color.darkened(.16))
	draw_polyline(PackedVector2Array([a,b,b+Vector2(0,34),c+Vector2(0,34),d+Vector2(0,34),d,a]), INK, 2, true)
	draw_line(c, c + Vector2(0,34), INK, 2, true)
	draw_line(d, c, INK, 2, true)
	draw_line(c, b, INK, 2, true)
