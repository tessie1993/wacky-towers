# CH-033 RuleDef container

**Story:** RUL-002 (pulled forward: `GameCatalog` names `RuleDef`)
**Goal:** the typed holder for one parsed `rules/<id>.json` (ADR-0004; implementation-plan §1.2). Fields only; parsing is DAT-002/RUL-002.
**Depends:** none
**Parallel-safe with:** CH-026 … CH-032, CH-034
**Files (new):** `src/core/rules/rule_def.gd`, `tests/unit/rules/rule_def_test.gd`

## API

```gdscript
class_name RuleDef extends RefCounted
## One rule definition from assets/data/rules/<id>.json (ADR-0004). Plain data.
var id: StringName = &""
var layer: StringName = &""              # twist | mechanic | content | mascot (ADR-0004 F3 budget counts twist/mechanic)
var icon: String = ""
var name_key: String = ""
var params: Dictionary = {}              # param schema
var modifiers: Array[Dictionary] = []
var vetoes: Array[Dictionary] = []
var behaviour: StringName = &""          # RuleBehaviour PLUGIN_ID, &"" for data-only rules
var lifetime: Dictionary = {}
var incompatible_with: PackedStringArray = PackedStringArray()
var tags_requires: PackedStringArray = PackedStringArray()
var tags_provides: PackedStringArray = PackedStringArray()
func counts_toward_budget() -> bool      ## layer is twist or mechanic
```

## Tests to write first

1. `test_defaults` — `RuleDef.new()`: empty id, empty arrays, `behaviour == &""`.
2. `test_budget_layers` — layer `&"twist"` / `&"mechanic"` true; `&"content"` / `&"mascot"` false.

## Run
`-a res://tests/unit/rules` (README).

## Done when
README "Done when" + 2 tests green.
