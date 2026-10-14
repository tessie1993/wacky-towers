class_name WtMeter extends Control
## Generic named HUD meter: a carved trough with a glossy fill, a caption and an optional value.
## Display only. Callers set `caption` (already localised), `fill` (0..1) and `color` (biome accent).
## Reads cleanly at 44 px tall; the fill tweens unless reduced motion is on.

## Localised caption drawn above the trough.
var caption: String = "":
	set(value):
		caption = value
		queue_redraw()
## Target fill, 0..1.
var fill: float = 0.0:
	set(value):
		fill = clampf(value, 0.0, 1.0)
		_set_shown(fill)
## Fill colour (biome accent).
var color: Color = Color("8fd05a"):
	set(value):
		color = value
		queue_redraw()
## Caption colour and outline.
var text_color: Color = Color("fff6e6")
## Number of equal segments (pips) the trough is divided into; 0 = a smooth bar.
var pips: int = 0:
	set(value):
		pips = maxi(0, value)
		queue_redraw()
## Shows a flame/hearth icon at the left end when true.
var hearth_icon: bool = false:
	set(value):
		hearth_icon = value
		queue_redraw()
## Value text drawn at the right end of the trough (e.g. "1/3"); empty hides it.
var value_text: String = "":
	set(value):
		value_text = value
		queue_redraw()
## When true the fill snaps instead of easing (reduced motion).
var reduced_motion: bool = false

var _shown: float = 0.0
var _tween: Tween


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(220, 64)


func _set_shown(target: float) -> void:
	if _tween != null and _tween.is_valid(): _tween.kill()
	if reduced_motion or not is_inside_tree():
		_shown = target
		queue_redraw()
		return
	_tween = create_tween()
	_tween.tween_method(func(v: float) -> void:
		_shown = v
		queue_redraw(), _shown, target, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var font := WtStorybook.font(true)
	var cap_px := clampi(roundi(size.y * 0.36), 16, 26)
	var trough_h := clampf(size.y - cap_px - 6.0, 28.0, 44.0)
	var icon_w := trough_h * 1.15 if hearth_icon else 0.0
	var trough := Rect2(icon_w * 0.5, size.y - trough_h, size.x - icon_w * 0.5, trough_h)
	var wood := StyleBoxFlat.new()
	wood.bg_color = Color("24143a")
	wood.border_color = WtStorybook.WOOD_PURPLE_LIGHT
	wood.set_border_width_all(4)
	wood.border_width_bottom = 6
	wood.set_corner_radius_all(int(trough_h * 0.5))
	wood.shadow_color = Color(0.1, 0.04, 0.16, 0.45)
	wood.shadow_size = 5
	wood.shadow_offset = Vector2(0, 3)
	wood.anti_aliasing = true
	draw_style_box(wood, trough)
	var inner := trough.grow_individual(-7, -7, -7, -9)
	inner.position.x += icon_w * 0.5
	inner.size.x -= icon_w * 0.5
	if inner.size.x > 4.0:
		if pips > 0:
			var gap := 5.0
			var seg := (inner.size.x - gap * (pips - 1)) / pips
			for i: int in pips:
				var r := Rect2(inner.position.x + i * (seg + gap), inner.position.y, seg, inner.size.y)
				var on := clampf(_shown * pips - i, 0.0, 1.0)
				_segment(r, Color("3a2a58"), 1.0)
				if on > 0.0: _segment(r, color, on)
		elif _shown > 0.0:
			_segment(inner, color, _shown)
	if hearth_icon: _flame(Vector2(icon_w * 0.5, trough.position.y + trough_h * 0.5), trough_h * 0.62, _shown > 0.0)
	if not value_text.is_empty():
		var vpx := clampi(roundi(trough_h * 0.62), 16, 24)
		var vpos := Vector2(trough.end.x - 14.0 - font.get_string_size(value_text, HORIZONTAL_ALIGNMENT_LEFT, -1, vpx).x, trough.position.y + trough_h * 0.5 + vpx * 0.36)
		draw_string_outline(font, vpos, value_text, HORIZONTAL_ALIGNMENT_LEFT, -1, vpx, 6, WtStorybook.TEXT_OUTLINE)
		draw_string(font, vpos, value_text, HORIZONTAL_ALIGNMENT_LEFT, -1, vpx, text_color)
	if not caption.is_empty():
		var pos := Vector2(0, cap_px)
		draw_string_outline(font, pos, caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, cap_px, 6, WtStorybook.TEXT_OUTLINE)
		draw_string(font, pos, caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, cap_px, text_color)


## One glossy fill segment covering `amount` (0..1) of `rect` from the left.
func _segment(rect: Rect2, fill_color: Color, amount: float) -> void:
	var bar := Rect2(rect.position, Vector2(maxf(minf(rect.size.y, rect.size.x), rect.size.x * amount), rect.size.y))
	var face := StyleBoxFlat.new()
	face.bg_color = fill_color
	face.set_corner_radius_all(int(rect.size.y * 0.5))
	face.anti_aliasing = true
	draw_style_box(face, bar)
	if fill_color == color:
		draw_rect(Rect2(bar.position + Vector2(bar.size.y * 0.35, 2), Vector2(maxf(0.0, bar.size.x - bar.size.y * 0.7), maxf(2.0, bar.size.y * 0.28))), Color(1, 1, 1, 0.4))


## Hearth flame: gold outer, light inner, in a dark ring so it reads on any biome.
func _flame(center: Vector2, h: float, lit: bool) -> void:
	draw_circle(center, h * 0.62, Color("2a1838"))
	draw_arc(center, h * 0.62, 0.0, TAU, 24, WtStorybook.GOLD if lit else Color("c08a58"), 3.0, true)
	var outer := PackedVector2Array([center + Vector2(0, -h * 0.5), center + Vector2(h * 0.3, -h * 0.05), center + Vector2(h * 0.24, h * 0.3),
		center + Vector2(0, h * 0.42), center + Vector2(-h * 0.24, h * 0.3), center + Vector2(-h * 0.3, -h * 0.05)])
	draw_colored_polygon(outer, Color("ff9a3c") if lit else Color("c08a58"))
	var inner := PackedVector2Array([center + Vector2(0, -h * 0.12), center + Vector2(h * 0.14, h * 0.16), center + Vector2(0, h * 0.34), center + Vector2(-h * 0.14, h * 0.16)])
	draw_colored_polygon(inner, WtStorybook.GOLD_GLINT if lit else Color("e8c89a"))
