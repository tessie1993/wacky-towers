extends Control
## Row of drawn stars (no font glyphs): `stars` of `max_stars` filled gold.

@export var max_stars := 3
@export var star_size := 36.0
var stars := 0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	custom_minimum_size = Vector2(max_stars * star_size * 1.15, star_size * 1.1)


## Set filled star count (clamped) and redraw.
func set_stars(n: int) -> void:
	stars = clampi(n, 0, max_stars)
	queue_redraw()


func _draw() -> void:
	var r := star_size * 0.5
	var step := star_size * 1.15
	var x0 := (size.x - step * max_stars) * 0.5 + step * 0.5
	for i in max_stars:
		var c := Vector2(x0 + step * i, size.y * 0.5)
		var pts := PackedVector2Array()
		for k in 10:
			var a := -PI / 2.0 + k * PI / 5.0
			pts.append(c + Vector2(cos(a), sin(a)) * (r if k % 2 == 0 else r * 0.45))
		var on := i < stars
		draw_colored_polygon(pts, Color("FFC83D") if on else Color(0.78, 0.74, 0.7))
		pts.append(pts[0])
		draw_polyline(pts, Color("2E2433") if on else Color(0.55, 0.5, 0.5), 3.0)
