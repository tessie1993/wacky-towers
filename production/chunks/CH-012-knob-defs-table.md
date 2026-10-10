# CH-012 KnobDefs: build + validate the knob tables

**Story:** DAT-001
**Goal:** turn parsed `knobs/*.json` tables into checked, fixed-point knob definitions (ADR-0004 §3).
**Depends:** none (tests feed Dictionaries; no files)
**Parallel-safe with:** every batch-2 ticket except CH-013, CH-014, CH-018
**Files:** `src/core/rules/knob_defs.gd` (new), `tests/unit/rules/knob_defs_test.gd` (new)

## API

```gdscript
class_name KnobDefs extends RefCounted
## Knob definitions from assets/data/knobs/*.json (ADR-0004 §3). Scalars are stored as integer milli-units.

const FIXED_POINT_SCALE := 1000      # ADR-0004 §3: 1000 = 1.0
const T_SCALAR := &"scalar"
const T_COUNT := &"count"
const T_FLAG := &"flag"
const T_CHOICE := &"choice"
const T_STRUCTURE := &"structure"
const T_SLOT := &"slot"
const ENTRY_KEYS: Array[String] = ["id", "type", "default", "min", "max", "allows_zero", "rule_adjustable", "choices", "source", "note"]

static func from_tables(tables: Array) -> KnobDefs   ## each table = {"knobs": [entry, ...]}; problems go to errors()
func errors() -> PackedStringArray
func ids() -> Array[StringName]                      ## sorted
func has(id: StringName) -> bool
func def(id: StringName) -> Dictionary               ## {type, default, min, max, allows_zero, rule_adjustable, choices}; {} if unknown
static func _whole_int(v: Variant) -> Variant        ## same rule as JsonReader.whole_int (core may not import data)
```

`# ponytail: third copy of the 5-line whole-number rule (BoardSpec, JsonReader, here); extract one core helper if a fourth appears.`

## Entry rules (error format `"knob '<id>': <problem>"`, or `"knobs[<t>][<i>]: ..."` before the id is known)

- `id`: String containing a `.` (`fall.lock_delay_ms`); unique across all tables. `type`: one of the 6 constants.
- Unknown entry key -> error (catches typos). `source`/`note` are free strings (GDD link, comment).
- `allows_zero` bool, default `true`; `rule_adjustable` bool, default `false`.
- **scalar**: `default`, `min`, `max` finite numbers; stored as `roundi(x * FIXED_POINT_SCALE)`.
- **count**: `default`, `min`, `max` whole numbers (`_whole_int`).
- For scalar/count: `min <= default <= max`; `allows_zero == false` and default 0 -> error.
- **flag**: `default` bool; no min/max/choices.
- **choice / slot**: `choices` non-empty Array of unique Strings; `default` in choices; stored as `Array[StringName]` and `StringName`.
- **structure**: `default` is Dictionary or Array (stored as deep copy).
- A bad entry is skipped (not added); others still load.

## Tests to write first

Factory `_table()` -> `{"knobs": [`
`{"id":"fall.g0","type":"scalar","default":0.6,"min":0.1,"max":3.0,"rule_adjustable":true},`
`{"id":"fall.lock_delay_ms","type":"count","default":500.0,"min":100.0,"max":2000.0,"allows_zero":false},`
`{"id":"fall.hard_drop","type":"flag","default":true},`
`{"id":"goal.top_out","type":"slot","default":"rescue","choices":["rescue","trim","lose"]},`
`{"id":"view.occlusion","type":"choice","default":"fade","choices":["fade","cutaway","ghost"]} ]}`
1. `test_valid_table_loads` — no errors; `ids()` == the 5 ids sorted; `has(&"fall.g0")`.
2. `test_scalar_is_fixed_point` — `def(&"fall.g0")`: default 600, min 100, max 3000, rule_adjustable true.
3. `test_count_and_defaults` — `def(&"fall.lock_delay_ms")`: default 500 (int), allows_zero false, rule_adjustable false.
4. `test_slot_choices` — `def(&"goal.top_out").choices == [&"rescue", &"trim", &"lose"]`, default `&"rescue"`.
5. `test_bad_entries_rejected` — one table with: duplicate id; type `"float"`; default 5.0 > max 3.0; count default 2.5;
   choice default not in choices; unknown key `"mn"`; allows_zero false with default 0 -> 7 errors, none of those ids loaded.
6. `test_unknown_def_is_empty` — `def(&"nope") == {}`, `has(&"nope") == false`.

## Run
`-a res://tests/unit/rules` (README).

## Done when
README "Done when" + 6 tests green.

## Out of scope
`coerce` (CH-013); reading files (CH-018 / CatalogLoader).
