# CH-013 KnobDefs.coerce + last_error

**Story:** DAT-001
**Goal:** convert one raw JSON value (level override, rule `set`) into the knob's typed value, or reject it with a named error (ADR-0004 §3).
**Depends:** CH-012
**Parallel-safe with:** every batch-2 ticket except CH-012, CH-014, CH-018
**Files:** `src/core/rules/knob_defs.gd` (edit: add 2 funcs), `tests/unit/rules/knob_defs_test.gd` (edit: append)

## API (add)

```gdscript
func coerce(id: StringName, raw: Variant) -> Variant   ## typed value, or null + last_error() set
func last_error() -> String                            ## "" after a successful coerce
```

## Behaviour (`last_error` messages are the contract; tests match substrings)

- Unknown id -> null, `"unknown knob '<id>'"`.
- **scalar**: int or finite float -> `roundi(raw * FIXED_POINT_SCALE)`; else `"knob '<id>': must be a number"`.
- **count**: `_whole_int(raw)`; null -> `"knob '<id>': must be a whole number"`.
- scalar/count range: outside `[min, max]` -> `"knob '<id>': <raw> outside <min>..<max>"` (scalar bounds shown in natural units, `min / 1000.0`);
  `allows_zero == false` and value 0 -> `"knob '<id>': zero not allowed"`.
- **flag**: bool only (`1`, `"true"` rejected) -> `"knob '<id>': must be true or false"`.
- **choice / slot**: String in choices -> `StringName`; else `"knob '<id>': '<raw>' is not one of <choices>"`.
- **structure**: same Variant type as the default (Dictionary or Array) -> `raw.duplicate(true)`; else `"knob '<id>': must be an object|array"`.
- Success sets `last_error` to `""`.

## Tests to write first (append; reuse CH-012's `_table()`)

1. `test_coerce_scalar_fixed_point` — `coerce(&"fall.g0", 0.6) == 600`; `coerce(&"fall.g0", 2) == 2000`; `last_error() == ""`.
2. `test_coerce_scalar_out_of_range` — `coerce(&"fall.g0", 5.0) == null`, last_error contains `"outside 0.1..3"`.
3. `test_coerce_count` — `800.0 -> 800`; `800.5 -> null` (`"whole number"`); `0 -> null` (lock_delay is allows_zero false).
4. `test_coerce_flag` — `false -> false`; `1 -> null`; `"true" -> null`.
5. `test_coerce_slot_and_choice` — `"trim" -> &"trim"`; `"explode" -> null` with `"not one of"`; `view.occlusion` `"ghost" -> &"ghost"`.
6. `test_coerce_unknown_id` — `coerce(&"nope", 1) == null`, last_error contains `"unknown knob"`.
7. `test_coerce_bad_types` — scalar `NAN`, `INF`, `"0.6"`, `null` -> null each.

## Run
`-a res://tests/unit/rules` (README).

## Done when
README "Done when" + all knob_defs tests green.
