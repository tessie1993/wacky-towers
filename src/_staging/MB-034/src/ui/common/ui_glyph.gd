class_name UiGlyph extends Control
## Simple painted icon (tick, cross, bin, badge silhouettes...) so menus need no icon fonts or art yet.
## Placeholder for painted silhouettes (ui-theme.md §7); swap the draw for a texture later.

## Profile colour ids -> swatch colours (profile-select.md colours, art bible §4.2 piece palette).
const COLORS: Dictionary = {
	&"lemon": Color("FFE66D"), &"lime": Color("A8E063"), &"mint": Color("7FE0C0"),
	&"sky": Color("7EC8F0"), &"lavender": Color("C3A6F0"), &"peach": Color("FFB38A"),
}
const DEFAULT_INK := Color("5A4632")
## Colour used when an id is unknown.
const FALLBACK_COLOR := Color("E8DCC0")

@export var glyph: StringName = &"":
	set(v):
		glyph = v
		queue_redraw()
@export var ink: Color = DEFAULT_INK:
	set(v):
		ink = v
		queue_redraw()


func _init(id: StringName = &"", ink_color: Color = DEFAULT_INK) -> void:
	glyph = id
	ink = ink_color
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Swatch colour for a profile colour id.
static func color_of(id: StringName) -> Color:
	return COLORS.get(id, FALLBACK_COLOR)


## A Button of [param side] px square with [param id] painted on it. Tooltip comes from the string key.
static func button(id: StringName, tip_key: String, side: float = 56.0) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(side, side)
	b.tooltip_text = str(TranslationServer.translate(tip_key))
	var g := UiGlyph.new(id)
	b.add_child(g)
	g.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, int(side * 0.18))
	return b


func _draw() -> void:
	var s: float = minf(size.x, size.y)
	var o: Vector2 = (size - Vector2(s, s)) / 2.0
	var w: float = maxf(s * 0.09, 2.0)
	match glyph:
		&"tick":
			draw_polyline(PackedVector2Array([_p(o, s, .2, .55), _p(o, s, .42, .75), _p(o, s, .8, .28)]), ink, w)
		&"cross":
			draw_line(_p(o, s, .25, .25), _p(o, s, .75, .75), ink, w)
			draw_line(_p(o, s, .75, .25), _p(o, s, .25, .75), ink, w)
		&"plus":
			draw_line(_p(o, s, .5, .2), _p(o, s, .5, .8), ink, w)
			draw_line(_p(o, s, .2, .5), _p(o, s, .8, .5), ink, w)
		&"back":
			draw_polyline(PackedVector2Array([_p(o, s, .6, .2), _p(o, s, .3, .5), _p(o, s, .6, .8)]), ink, w)
		&"bin":
			draw_rect(Rect2(_p(o, s, .28, .35), Vector2(.44, .5) * s), ink, false, w)
			draw_line(_p(o, s, .2, .3), _p(o, s, .8, .3), ink, w)
			draw_line(_p(o, s, .4, .2), _p(o, s, .6, .2), ink, w)
		&"pencil":
			draw_line(_p(o, s, .25, .75), _p(o, s, .72, .28), ink, w * 1.6)
			draw_colored_polygon(PackedVector2Array([_p(o, s, .15, .88), _p(o, s, .2, .66), _p(o, s, .34, .8)]), ink)
		&"dice":
			draw_rect(Rect2(_p(o, s, .2, .2), Vector2(.6, .6) * s), ink, false, w)
			for d in [Vector2(.35, .35), Vector2(.65, .35), Vector2(.5, .5), Vector2(.35, .65), Vector2(.65, .65)]:
				draw_circle(_p(o, s, d.x, d.y), s * .05, ink)
		&"lock":
			draw_rect(Rect2(_p(o, s, .3, .5), Vector2(.4, .3) * s), ink)
			draw_arc(_p(o, s, .5, .5), s * .15, PI, TAU, 12, ink, w)
		&"ring":
			draw_arc(_p(o, s, .5, .5), s * .4, 0.0, TAU, 32, ink, w)
		&"acorn":
			draw_circle(_p(o, s, .5, .6), s * .25, ink)
			draw_rect(Rect2(_p(o, s, .25, .28), Vector2(.5, .16) * s), ink)
			draw_line(_p(o, s, .5, .28), _p(o, s, .5, .16), ink, w)
		&"mushroom":
			var cap := PackedVector2Array()
			for i in 13:
				var a: float = PI + PI * i / 12.0
				cap.append(_p(o, s, .5 + cos(a) * .32, .55 + sin(a) * .32))
			draw_colored_polygon(cap, ink)
			draw_rect(Rect2(_p(o, s, .42, .55), Vector2(.16, .27) * s), ink)
		&"snail":
			draw_circle(_p(o, s, .42, .48), s * .22, ink)
			draw_line(_p(o, s, .12, .8), _p(o, s, .85, .8), ink, w * 1.5)
			draw_line(_p(o, s, .82, .8), _p(o, s, .82, .5), ink, w)
		&"bee":
			draw_circle(_p(o, s, .5, .58), s * .24, ink)
			draw_circle(_p(o, s, .38, .28), s * .1, ink)
			draw_circle(_p(o, s, .62, .28), s * .1, ink)
			draw_line(_p(o, s, .36, .52), _p(o, s, .64, .52), Color.WHITE, w * .8)
			draw_line(_p(o, s, .34, .64), _p(o, s, .66, .64), Color.WHITE, w * .8)
		&"daisy":
			for i in 6:
				var a: float = TAU * i / 6.0
				draw_circle(_p(o, s, .5 + cos(a) * .25, .5 + sin(a) * .25), s * .12, ink)
			draw_circle(_p(o, s, .5, .5), s * .1, Color.WHITE)
		&"leaf":
			draw_colored_polygon(PackedVector2Array([_p(o, s, .2, .8), _p(o, s, .25, .4), _p(o, s, .7, .2), _p(o, s, .82, .3), _p(o, s, .6, .75)]), ink)
			draw_line(_p(o, s, .2, .8), _p(o, s, .62, .38), Color.WHITE, w * .6)
		&"cloud":
			draw_circle(_p(o, s, .35, .6), s * .17, ink)
			draw_circle(_p(o, s, .55, .5), s * .2, ink)
			draw_circle(_p(o, s, .72, .62), s * .15, ink)
			draw_rect(Rect2(_p(o, s, .35, .62), Vector2(.4, .15) * s), ink)
		&"wizard_hat":
			draw_colored_polygon(PackedVector2Array([_p(o, s, .5, .15), _p(o, s, .25, .75), _p(o, s, .75, .75)]), ink)
			draw_line(_p(o, s, .15, .8), _p(o, s, .85, .8), ink, w * 1.5)


## Point at unit coords (x, y) inside the square of side [param s] at origin [param o].
static func _p(o: Vector2, s: float, x: float, y: float) -> Vector2:
	return o + Vector2(x, y) * s
