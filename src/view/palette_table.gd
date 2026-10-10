class_name PaletteTable extends RefCounted
## Hue id -> Color for one block set. Usage: PaletteTable.from_dict(d).color(3)

const _FALLBACK_HUE := 0 # neutral starter colour

var _colors: Dictionary = {} # int -> Color
var _errors := PackedStringArray()


## Builds a table from {"colors": {"<id>": "#rrggbb"}}; bad entries are skipped and listed in errors().
## Usage: var t: PaletteTable = PaletteTable.from_dict(data)
static func from_dict(d: Dictionary) -> PaletteTable:
	var t := PaletteTable.new()
	var colors: Variant = d.get("colors", {})
	if typeof(colors) != TYPE_DICTIONARY:
		t._errors.append("colors: not an object")
		return t
	for k: Variant in (colors as Dictionary):
		var key: String = str(k)
		if not key.is_valid_int():
			t._errors.append("colors.%s: id not an int" % key)
			continue
		var v: String = str(colors[k])
		if not Color.html_is_valid(v):
			t._errors.append("colors.%s: bad hex '%s'" % [key, v])
			continue
		t._colors[key.to_int()] = Color.html(v)
	return t


## Colour for a hue id; unknown -> hue 0 colour; empty table -> MAGENTA.
## Usage: sprite.modulate = table.color(2)
func color(hue: int) -> Color:
	if _colors.has(hue):
		return _colors[hue]
	return _colors.get(_FALLBACK_HUE, Color.MAGENTA)


## Number of valid colours.
## Usage: table.size()
func size() -> int:
	return _colors.size()


## Parse errors, e.g. "colors.1: bad hex '#zz'".
## Usage: assert(table.errors().is_empty())
func errors() -> PackedStringArray:
	return _errors
