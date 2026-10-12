class_name PaletteTable extends RefCounted
## Hue id -> Color for one block set. Usage: PaletteTable.from_dict(d).color(3)

const _FALLBACK_HUE := 0 # neutral starter colour
const PATTERN_NAMES := [&"none",&"h_stripes",&"dots",&"waves",&"checker",&"rings",&"bricks",&"plus",&"diamonds",&"v_stripes",&"grid"]

var _colors: Dictionary = {} # int -> Color
var _outlines: Dictionary = {} # int -> Color (optional "outlines" block)
var _patterns: Dictionary = {} # int -> StringName (optional "patterns" block)
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
	var outlines: Variant = d.get("outlines", {})
	if typeof(outlines) == TYPE_DICTIONARY:
		for k: Variant in (outlines as Dictionary):
			var ov: String = str(outlines[k])
			if str(k).is_valid_int() and Color.html_is_valid(ov):
				t._outlines[str(k).to_int()] = Color.html(ov)
			else:
				t._errors.append("outlines.%s: bad entry '%s'" % [str(k), ov])
	var patterns: Variant = d.get("patterns", {})
	if typeof(patterns) == TYPE_DICTIONARY:
		for k: Variant in (patterns as Dictionary):
			if str(k).is_valid_int():
				t._patterns[str(k).to_int()] = StringName(str(patterns[k]))
			else:
				t._errors.append("patterns.%s: id not an int" % str(k))
	return t


## Colour for a hue id; unknown -> hue 0 colour; empty table -> MAGENTA.
## Usage: sprite.modulate = table.color(2)
func color(hue: int) -> Color:
	if _colors.has(hue):
		return _colors[hue]
	return _colors.get(_FALLBACK_HUE, Color.MAGENTA)


## Outline colour for a hue; unknown -> hue 0 outline; none defined -> BLACK.
## Usage: material.set_shader_parameter("outline", table.outline(2))
func outline(hue: int) -> Color:
	if _outlines.has(hue):
		return _outlines[hue]
	return _outlines.get(_FALLBACK_HUE, Color.BLACK)


## Pattern name for a hue (e.g. &"dots"); unknown or none defined -> &"none".
## Usage: var p: StringName = table.pattern(3)
func pattern(hue: int) -> StringName:
	return _patterns.get(hue, _patterns.get(_FALLBACK_HUE, &"none"))


## Stable shader motif index, preserving the authored palette's ten named patterns.
func pattern_code(hue: int) -> int:
	return maxi(0,PATTERN_NAMES.find(pattern(hue)))


## Number of valid colours.
## Usage: table.size()
func size() -> int:
	return _colors.size()


## Parse errors, e.g. "colors.1: bad hex '#zz'".
## Usage: assert(table.errors().is_empty())
func errors() -> PackedStringArray:
	return _errors
