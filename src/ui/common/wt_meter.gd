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
## When true the fill snaps instead of easing (reduced motion).
var reduced_motion: bool = false

var _shown: float = 0.0
var _tween: Tween


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(160, 44)


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
	var cap_px := clampi(roundi(size.y * 0.34), 12, 22)
	var trough_h := clampf(size.y * 0.42, 14.0, 26.0)
	var trough := Rect2(0, size.y - trough_h, size.x, trough_h)
	var wood := StyleBoxFlat.new()
	wood.bg_color = Color("24143a")
	wood.border_color = WtStorybook.WOOD_PURPLE_LIGHT
	wood.set_border_width_all(3)
	wood.border_width_bottom = 5
	wood.set_corner_radius_all(int(trough_h * 0.5))
	wood.anti_aliasing = true
	draw_style_box(wood, trough)
	var inner := trough.grow_individual(-5, -5, -5, -7)
	if inner.size.x > 4.0 and _shown > 0.0:
		var bar := Rect2(inner.position, Vector2(maxf(inner.size.y, inner.size.x * _shown), inner.size.y))
		var face := StyleBoxFlat.new()
		face.bg_color = color
		face.set_corner_radius_all(int(inner.size.y * 0.5))
		face.anti_aliasing = true
		draw_style_box(face, bar)
		var gloss := Rect2(bar.position + Vector2(bar.size.y * 0.4, 1), Vector2(maxf(0.0, bar.size.x - bar.size.y * 0.8), maxf(2.0, bar.size.y * 0.3)))
		draw_rect(gloss, Color(1, 1, 1, 0.4))
	if not caption.is_empty():
		var pos := Vector2(0, cap_px + 1)
		draw_string_outline(font, pos, caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, cap_px, 5, WtStorybook.TEXT_OUTLINE)
		draw_string(font, pos, caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, cap_px, text_color)
