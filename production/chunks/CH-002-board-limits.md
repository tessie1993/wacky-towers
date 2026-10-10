# CH-002 BoardLimits: hard caps for untrusted boards

**Story:** BRD-001 (BoardSpec, BoardLimits, ContentTypes, ASCII grids)
**Goal:** the tunable hard limits `BoardSpec.parse` checks before any allocation (ADR-0002 §6 table).
**Depends:** none
**Parallel-safe with:** CH-001, CH-003, CH-004, CH-005
**Files:** `src/core/board/board_limits.gd` (new), `tests/unit/board_grid/board_limits_test.gd` (new)

## API (implementation-plan §1.2 + one addition)

```gdscript
class_name BoardLimits extends RefCounted
## Hard caps for board data from untrusted levels (ADR-0002 §6). Defaults are tunable; knobs/board.json overrides them later.

const DEFAULT_MIN_SIDE := 4                 # ADR-0002 §6: width, depth 4..24
const DEFAULT_MAX_SIDE := 24
const DEFAULT_MIN_HEIGHT := 7               # ADR-0002 §6: board_height (h_play + clearance) 7..32
const DEFAULT_MAX_HEIGHT := 32
const DEFAULT_MAX_CELLS := 8192             # ADR-0002 §6: N = W*D*H
const DEFAULT_MAX_ERRORS := 50              # ADR-0002 §6
const DEFAULT_MIN_ACTIVE_PER_LAYER := 12    # ADR-0002 §6 check 4: A >= 12
const DEFAULT_SPAWN_CLEARANCE := 4          # Board GDD F4: C = L_max, default cap 4 (Piece Set rule 3)

var min_side: int = DEFAULT_MIN_SIDE
var max_side: int = DEFAULT_MAX_SIDE
var min_height: int = DEFAULT_MIN_HEIGHT
var max_height: int = DEFAULT_MAX_HEIGHT
var max_cells: int = DEFAULT_MAX_CELLS
var max_errors: int = DEFAULT_MAX_ERRORS
var min_active_per_layer: int = DEFAULT_MIN_ACTIVE_PER_LAYER
var spawn_clearance: int = DEFAULT_SPAWN_CLEARANCE   # board height = h_play + spawn_clearance

static func from_dict(d: Dictionary) -> BoardLimits
	## Defaults, overridden by any key in d whose name matches a field and whose value is int,
	## or a float with no fractional part. Other keys/values are ignored (trusted internal data).
```

> Plan gap (flag to the architecture lead, don't block): the plan's BoardLimits has no
> `spawn_clearance`, but board height = `h_play + C` (Board GDD F4) and `parse` has no other
> source for C. Added here; the level loader later sets it to the piece set's L_max.

## Tests to write first

1. `test_defaults_match_adr` — `BoardLimits.new()`: 4, 24, 7, 32, 8192, 50, 12, 4 for the 8 fields.
2. `test_from_dict_overrides_known_keys` — `from_dict({"max_side": 16.0, "max_errors": 5})` -> `max_side == 16`, `max_errors == 5`, others default.
3. `test_from_dict_ignores_unknown_and_bad_values` — `from_dict({"nope": 3, "min_side": 4.5, "max_cells": "x"})` -> all defaults.

## Run
`-a res://tests/unit/board_grid` (README).

## Done when
README "Done when" + 3 tests green.

## Out of scope
`assets/data/knobs/board.json` (its format belongs to DAT-001's knob tables; added there).
