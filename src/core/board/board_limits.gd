class_name BoardLimits extends RefCounted
## Hard caps for board data from untrusted levels (ADR-0002 §6). Defaults are tunable; knobs/board.json overrides them later.

const DEFAULT_MIN_SIDE: int = 4                 # ADR-0002 §6: width, depth 4..24
const DEFAULT_MAX_SIDE: int = 24
const DEFAULT_MIN_HEIGHT: int = 7               # ADR-0002 §6: board_height (h_play + clearance) 7..32
const DEFAULT_MAX_HEIGHT: int = 32
const DEFAULT_MAX_CELLS: int = 8192             # ADR-0002 §6: N = W*D*H
const DEFAULT_MAX_ERRORS: int = 50              # ADR-0002 §6
const DEFAULT_MIN_ACTIVE_PER_LAYER: int = 12    # ADR-0002 §6 check 4: A >= 12
const DEFAULT_SPAWN_CLEARANCE: int = 4          # Board GDD F4: C = L_max, default cap 4 (Piece Set rule 3)

var min_side: int = DEFAULT_MIN_SIDE
var max_side: int = DEFAULT_MAX_SIDE
var min_height: int = DEFAULT_MIN_HEIGHT
var max_height: int = DEFAULT_MAX_HEIGHT
var max_cells: int = DEFAULT_MAX_CELLS
var max_errors: int = DEFAULT_MAX_ERRORS
var min_active_per_layer: int = DEFAULT_MIN_ACTIVE_PER_LAYER
var spawn_clearance: int = DEFAULT_SPAWN_CLEARANCE   # board height = h_play + spawn_clearance

const _FIELDS: Array[String] = ["min_side", "max_side", "min_height", "max_height", "max_cells", "max_errors", "min_active_per_layer", "spawn_clearance"]


## Defaults, overridden by any key in d naming a field with an int (or whole float) value; others ignored.
## Usage: BoardLimits.from_dict({"max_side": 16})
static func from_dict(d: Dictionary) -> BoardLimits:
	var l: BoardLimits = BoardLimits.new()
	for f: String in _FIELDS:
		if not d.has(f):
			continue
		var v: Variant = d[f]
		if typeof(v) == TYPE_INT:
			l.set(f, v)
		elif typeof(v) == TYPE_FLOAT and v == floorf(v):
			l.set(f, int(v))
	return l
