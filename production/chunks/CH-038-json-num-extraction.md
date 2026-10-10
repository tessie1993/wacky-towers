# CH-038 JsonNum.whole_int: one whole-number rule (refactor)

**Story:** DAT-001 (gap decision 2, 2026-10-10)
**Goal:** replace every private copy of the "JSON float is a whole number" check with one public helper (implementation-plan §1.2 `JsonNum`).
**Depends:** CH-003, CH-008, CH-011, CH-013 (all files below finished; no one else editing them)
**Parallel-safe with:** CH-037, CH-042 … CH-050, CH-054 (not with anything editing board_spec / knob_defs / json_reader / content_types)
**Files:** `src/core/board/json_num.gd` (new), `tests/unit/board_grid/json_num_test.gd` (new);
edit `src/core/board/board_spec.gd`, `src/core/rules/knob_defs.gd`, `src/data/json_reader.gd`, `src/core/board/content_types.gd`,
`tests/unit/data/json_reader_test.gd`

## API

```gdscript
class_name JsonNum extends RefCounted
## The one whole-number rule for JSON numbers, which arrive as float (ADR-0002 Verification 1).
const MAX_SAFE_INT := 2147483647
static func whole_int(v: Variant) -> Variant
	## int -> itself; float -> int only if finite, v == floorf(v), |v| <= MAX_SAFE_INT; anything else (bool, String, null…) -> null
```

## Steps

1. Write `json_num_test.gd` first: `8.0 -> 8`, `8 -> 8`, `-3.0 -> -3`; `6.5`, `NAN`, `INF`, `1e12`, `"8"`, `true`, `null` -> null;
   pin `typeof(JSON.parse_string('{"a": 8}')["a"]) == TYPE_FLOAT`.
2. Add `JsonNum`. Then in each file delete the private copy and call `JsonNum.whole_int`:
   `BoardSpec._whole_int`, `KnobDefs._whole_int`, `ContentTypes._is_whole` (becomes `JsonNum.whole_int(v) != null`),
   `JsonReader.whole_int` (delete it; move its tests' whole-number cases out of `json_reader_test.gd` — they now live in `json_num_test.gd`).
3. Remove the `ponytail:` note about copies in `knob_defs.gd`. Delete any now-unused `MAX_SAFE_INT` consts.
4. `grep -rn "_whole_int\|_is_whole\|JsonReader.whole_int" src tests` returns nothing.

Behaviour must not change: every existing test stays green unmodified (except the moved json_reader cases).

## Run
`-a res://tests/unit` — the whole unit suite (README).

## Done when
README "Done when" + full unit suite green + the grep in step 4 is empty.
