class_name AsciiGrid extends RefCounted
## Pure parsers for ASCII grids in level data (implementation-plan §5). Row r = z, char c = x.

const ACTIVE_CHAR: String = "#"  # ADR-0002 §6 check 4
const MASKED_CHAR: String = "."
const LAYERS_KEY: String = "layers"
const MAX_LAYER_KEY_LEN: int = 4  # a longer layer key is rejected before int() (hostile input)


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
## '.' is empty and never returned; legal = allowed glyphs. Cells are returned even with errors.
## Usage: AsciiGrid.parse_layers(section, Vector3i(4, 3, 4), "#m", "board.starting_contents")
static func parse_layers(section: Dictionary, size: Vector3i, legal: String, field: String) -> Dictionary:
	var errors: PackedStringArray = PackedStringArray()
	var cells: Array[Dictionary] = []
	for key: Variant in section.keys():
		if str(key) != LAYERS_KEY:
			errors.append("%s.%s: unknown key" % [field, str(key)])
	var layers: Variant = section.get(LAYERS_KEY)
	if not layers is Dictionary:
		errors.append("%s.%s: must be an object" % [field, LAYERS_KEY])
		return {"cells": cells, "errors": errors}
	var layer_dict: Dictionary = layers
	var ys: Array[int] = []
	var ys_keys: Dictionary = {}  # y -> original key
	for key: Variant in layer_dict.keys():
		var k: String = str(key)
		if not _is_layer_key(k, size.y):
			errors.append('%s.layers["%s"]: layer must be a whole number 0..%d' % [field, k, size.y - 1])
			continue
		ys.append(int(k))
		ys_keys[int(k)] = key
	ys.sort()
	for y: int in ys:
		_parse_layer(layer_dict[ys_keys[y]], y, size, legal, field, cells, errors)
	return {"cells": cells, "errors": errors}


static func _is_layer_key(k: String, layer_count: int) -> bool:
	if k.length() > MAX_LAYER_KEY_LEN or not k.is_valid_int() or str(int(k)) != k:
		return false
	return int(k) >= 0 and int(k) < layer_count


static func _parse_layer(value: Variant, y: int, size: Vector3i, legal: String, field: String,
		cells: Array[Dictionary], errors: PackedStringArray) -> void:
	var prefix: String = '%s.layers["%d"]' % [field, y]
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
		var bad_reported: bool = false
		for c: int in size.x:
			var ch: String = s[c]
			if ch == MASKED_CHAR:
				continue
			if legal.contains(ch):
				cells.append({"cell": Vector3i(c, y, r), "glyph": ch})
			elif not bad_reported:
				bad_reported = true
				errors.append("%s[%d][%d]: unknown glyph '%s' at cell (%d,%d,%d)" % [prefix, r, c, ch, c, y, r])
