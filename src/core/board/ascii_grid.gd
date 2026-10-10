class_name AsciiGrid extends RefCounted
## Pure parsers for ASCII grids in level data (implementation-plan §5). Row r = z, char c = x.

const ACTIVE_CHAR: String = "#"  # ADR-0002 §6 check 4
const MASKED_CHAR: String = "."
const LAYERS_KEY: String = "layers"
const MAX_LAYER_KEY_LEN: int = 4  # longer keys are rejected before int() (hostile input)


## Parses a footprint mask. Returns {"mask": PackedByteArray (index x + w*z, 1 = active),
## "errors": PackedStringArray}; "mask" is empty on any error.
## Usage: AsciiGrid.parse_mask(rows, 4, 4, "board.mask")
static func parse_mask(rows: Array, w: int, d: int, field: String) -> Dictionary:
	var errors: PackedStringArray = PackedStringArray()
	if rows.size() != d:
		errors.append("%s: expected %d rows, got %d" % [field, d, rows.size()])
		return {"mask": PackedByteArray(), "errors": errors}
	var mask: PackedByteArray = PackedByteArray()
	mask.resize(w * d)
	for r: int in d:
		var row: Variant = rows[r]
		if not row is String:
			errors.append("%s[%d]: row must be a string" % [field, r])
			continue
		var s: String = row
		if s.length() != w:
			errors.append("%s[%d]: expected %d chars, got %d" % [field, r, w, s.length()])
			continue
		for c: int in w:
			var ch: String = s[c]
			if ch == ACTIVE_CHAR:
				mask[c + w * r] = 1
			elif ch != MASKED_CHAR:
				errors.append("%s[%d][%d]: bad char '%s' at (x=%d, z=%d)" % [field, r, c, ch, c, r])
				break
	if not errors.is_empty():
		mask = PackedByteArray()
	return {"mask": mask, "errors": errors}


## Parses {"layers": {"<y>": [D rows of W chars]}} into cells. Returns {"cells": Array[Dictionary]
## of {"cell": Vector3i, "glyph": String}, "errors": PackedStringArray}. size = (W, layer_count, D);
## '.' is empty and never returned; legal = allowed non-empty glyphs. Cells are returned even when
## errors exist. Output is ordered by y, then z (row), then x (char).
## Usage: AsciiGrid.parse_layers(section, Vector3i(4, 6, 4), "#m", "board.starting_contents")
static func parse_layers(section: Dictionary, size: Vector3i, legal: String, field: String) -> Dictionary:
	var errors: PackedStringArray = PackedStringArray()
	var cells: Array[Dictionary] = []
	for key: Variant in section.keys():
		if str(key) != LAYERS_KEY:
			errors.append("%s.%s: unknown key" % [field, str(key)])
	if not section.has(LAYERS_KEY) or not section[LAYERS_KEY] is Dictionary:
		errors.append("%s.%s: must be an object" % [field, LAYERS_KEY])
		return {"cells": cells, "errors": errors}
	var layers: Dictionary = section[LAYERS_KEY]
	var ys: Array[int] = []
	var by_y: Dictionary = {}
	for key: Variant in layers.keys():
		var k: String = str(key)
		var y: int = _layer_index(key, size.y)
		if y < 0:
			errors.append('%s.layers["%s"]: layer must be a whole number 0..%d' % [field, k, size.y - 1])
			continue
		ys.append(y)
		by_y[y] = key
	ys.sort()
	for y: int in ys:
		var key: Variant = by_y[y]
		_parse_layer(layers[key], y, str(key), size, legal, field, cells, errors)
	return {"cells": cells, "errors": errors}


## Returns the layer index for a key, or -1 when the key is not a valid layer number.
static func _layer_index(key: Variant, layer_count: int) -> int:
	if not key is String:
		return -1
	var k: String = key
	if k.length() > MAX_LAYER_KEY_LEN or not k.is_valid_int() or str(int(k)) != k:
		return -1
	var y: int = int(k)
	if y < 0 or y >= layer_count:
		return -1
	return y


static func _parse_layer(value: Variant, y: int, k: String, size: Vector3i, legal: String, field: String,
		cells: Array[Dictionary], errors: PackedStringArray) -> void:
	var prefix: String = '%s.layers["%s"]' % [field, k]
	if not value is Array:
		errors.append("%s: expected %d rows, got 0" % [prefix, size.z])
		return
	var rows: Array = value
	if rows.size() != size.z:
		errors.append("%s: expected %d rows, got %d" % [prefix, size.z, rows.size()])
		return
	for r: int in size.z:
		if not rows[r] is String:
			errors.append("%s[%d]: row must be a string" % [prefix, r])
			continue
		var s: String = rows[r]
		if s.length() != size.x:
			errors.append("%s[%d]: expected %d chars, got %d" % [prefix, r, size.x, s.length()])
			continue
		var row_bad: bool = false
		for c: int in size.x:
			var ch: String = s[c]
			if ch == MASKED_CHAR:
				continue
			if legal.contains(ch):
				cells.append({"cell": Vector3i(c, y, r), "glyph": ch})
			elif not row_bad:
				row_bad = true
				errors.append("%s[%d][%d]: unknown glyph '%s' at cell (%d,%d,%d)" % [prefix, r, c, ch, c, y, r])
