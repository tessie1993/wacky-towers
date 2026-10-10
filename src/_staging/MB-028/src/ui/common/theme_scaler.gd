class_name ThemeScaler extends RefCounted
## Builds text-scaled copies of a Theme (ADR-0016 §8, ACC-33). Example: ThemeScaler.scaled(base, 1.5).

## Smallest body font size in pt (ui-theme.md §5 floor).
const BODY_FLOOR_PT := 12
## Smallest HUD digit size in pt (ui-theme.md §5 floor).
const DIGITS_FLOOR_PT := 18
## Type names treated as HUD digits for the larger floor.
const DIGIT_TYPES: Array[StringName] = [&"GoalDigits"]


## Returns a copy of [param base] with every font size multiplied by [param factor] (rounded), floored at 12 pt
## (18 pt for [constant DIGIT_TYPES]). Example: a 24 pt label at factor 1.5 -> 36.
static func scaled(base: Theme, factor: float) -> Theme:
	var out: Theme = base.duplicate()
	if out.default_font_size > 0:
		out.default_font_size = maxi(roundi(out.default_font_size * factor), BODY_FLOOR_PT)
	for type_name in out.get_font_size_type_list():
		var floor_pt: int = DIGITS_FLOOR_PT if type_name in DIGIT_TYPES else BODY_FLOOR_PT
		for item in out.get_font_size_list(type_name):
			out.set_font_size(item, type_name, maxi(roundi(out.get_font_size(item, type_name) * factor), floor_pt))
	return out
