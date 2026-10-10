# CH-014 KnobRegistry: base values (defaults + level overrides)

**Story:** DAT-001
**Goal:** effective knob values before any rule runs: level override beats default (ADR-0004 §3, Rule-Twist GDD F1 base step). Rule modifiers (`recompute`) come in RUL-003.
**Depends:** CH-013
**Parallel-safe with:** every batch-2 ticket except CH-012, CH-013, CH-018
**Files:** `src/core/rules/knob_registry.gd` (new), `tests/unit/rules/knob_registry_base_test.gd` (new)

## API

```gdscript
class_name KnobRegistry extends RefCounted
## Effective knob values for one board (ADR-0004 §3). Reads are dictionary lookups.

func _init(defs: KnobDefs, level_overrides: Dictionary[StringName, Variant]) -> void
func value(id: StringName) -> Variant      ## effective value; null if the id is unknown
func int_value(id: StringName) -> int      ## value as int (scalars are milli-units); 0 if unknown or not a number
func flag(id: StringName) -> bool          ## false if unknown or not a bool
func errors() -> PackedStringArray         ## rejected overrides from _init
```

`recompute(active: Array[RuleInstance])` is **not** in this ticket (RuleInstance does not exist yet; RUL-003 adds it).

## Behaviour

- `_init`: `_base[id] = defs.def(id).default` for every `defs.ids()`; then for each override:
  unknown id -> error `"level knob '<id>': unknown knob"`; `defs.coerce` null -> error `"level knob '<id>': <defs.last_error()>"` and the default stays;
  otherwise `_base[id] = coerced`. `_effective = _base.duplicate()` (RUL-003 will rebuild it from rules).
- Overrides are applied in sorted id order (deterministic error order).

## Tests to write first

Use CH-012's table (copy the factory into this test file — tests must not depend on each other).
1. `test_defaults_without_overrides` — `value(&"fall.g0") == 600`, `int_value(&"fall.lock_delay_ms") == 500`, `flag(&"fall.hard_drop") == true`, `value(&"goal.top_out") == &"rescue"`.
2. `test_level_override_beats_default` — overrides `{&"fall.g0": 0.9, &"goal.top_out": "trim"}` -> 900 and `&"trim"`, no errors.
3. `test_bad_override_keeps_default` — `{&"fall.g0": 9.0}` -> value 600, 1 error containing `"fall.g0"` and `"outside"`.
4. `test_unknown_override_is_error` — `{&"fall.nope": 1}` -> error containing `"unknown knob"`.
5. `test_unknown_reads_are_neutral` — `value(&"x") == null`, `int_value(&"x") == 0`, `flag(&"x") == false`.

## Run
`-a res://tests/unit/rules` (README).

## Done when
README "Done when" + 5 tests green.
