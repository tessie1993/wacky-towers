# CH-037 JsonNum: one whole-number helper

**Story:** DAT-001 · **Model:** Haiku · **Wave:** W1 · **Mode:** direct
**Goal:** plan gap 2 decision: one public helper replaces three copies of the whole-number rule.
**Depends:** none (CH-008 done) · **Parallel-safe with:** W1 (no other W1 ticket touches these files)
**Files:** new `src/core/board/json_num.gd`, `tests/unit/board_grid/json_num_test.gd`;
edit `src/core/board/board_spec.gd` (delete `_whole_int`, `MAX_SAFE_INT`), `src/core/rules/knob_defs.gd` (delete `_whole_int`),
`src/data/json_reader.gd` (delete `whole_int`, `MAX_SAFE_INT`).

## API
```gdscript
class_name JsonNum extends RefCounted
## The one whole-number rule for JSON values (JSON numbers arrive as float). Pure core helper.
const MAX_SAFE_INT := 2147483647      # int32 guard, moved from BoardSpec/JsonReader
static func whole_int(v: Variant) -> Variant
	## int for an int, or a float with no fraction and |v| <= MAX_SAFE_INT; else null. Usage: JsonNum.whole_int(4.0) -> 4
```

## Behaviour
- Copy the behaviour of `BoardSpec._whole_int` exactly (read it first; it is the reference). bool, String, NaN, INF -> null.
- `grep -rn "_whole_int\|whole_int\|MAX_SAFE_INT" src tests` and switch every caller to `JsonNum`. No wrapper left behind.
- `KnobDefs` has `_MAX_WHOLE` (2^53) for its own float check: keep it only if a caller still needs it, else delete. If a knob test needs a
  value above int32, stop: `blocked (knob > int32)`.

## Tests first (`json_num_test.gd`)
1. `test_accepts_whole` — 0, 4, -3, 4.0, -2.0, 2147483647.0 -> ints.
2. `test_rejects` — 4.5, "4", true, null, NAN, INF, 2147483648.0, -2147483649.0 -> null.

## Run / Done when
`--import`, then `-a res://tests/unit/board_grid`, `data`, `rules`. README "Done when"; all three folders green; `grep` above finds only `JsonNum`.
**Out of scope:** any behaviour change in callers.
