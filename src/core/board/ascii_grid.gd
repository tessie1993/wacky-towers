class_name AsciiGrid extends RefCounted
## Pure parsers for ASCII grids in level data (implementation-plan §5). Row r = z, char c = x.

const ACTIVE_CHAR: String = "#"  # ADR-0002 §6 check 4
const MASKED_CHAR: String = "."


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
