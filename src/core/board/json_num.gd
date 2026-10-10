class_name JsonNum extends RefCounted
## The one whole-number rule for JSON values (JSON numbers arrive as float). Pure core helper.
## Usage: JsonNum.whole_int(4.0) -> 4

const MAX_SAFE_INT := 2147483647  # int32 guard, moved from BoardSpec/JsonReader


## int for an int, or a float with no fraction and |v| <= MAX_SAFE_INT; else null (bool, String, NaN, INF -> null).
## Usage: JsonNum.whole_int(4.0) -> 4
static func whole_int(v: Variant) -> Variant:
	if typeof(v) == TYPE_INT:
		return v
	if typeof(v) == TYPE_FLOAT:
		var f: float = v
		if is_finite(f) and f == floorf(f) and absf(f) <= MAX_SAFE_INT:
			return int(f)
	return null
