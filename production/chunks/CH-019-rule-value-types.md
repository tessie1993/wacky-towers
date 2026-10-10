# CH-019 Rule value types: HookContext, VetoResult, ClearGroup, ArrivalPlan + RuleApi stub

**Story:** RUL-001
**Goal:** the plain data classes the plugin bases pass around, plus an empty `RuleApi` so bases can name the type (ADR-0004 §7; implementation-plan §1.2).
**Depends:** none
**Parallel-safe with:** every batch-2 ticket except CH-021, CH-022
**Files (all new):** `src/core/rules/hook_context.gd`, `src/core/rules/veto_result.gd`, `src/core/rules/bases/clear_group.gd`,
`src/core/rules/bases/arrival_plan.gd`, `src/core/rules/rule_api.gd`, `tests/unit/rules/rule_value_types_test.gd`

## API (fields exactly as the plan; `##` doc on each class and each var)

```gdscript
class_name HookContext extends RefCounted
var hook: StringName = &""
var data: Dictionary = {}
var depth: int = 0                # chain depth (ADR-0004 hook pipeline; limit is a rules.* knob)

class_name VetoResult extends RefCounted
var vetoed: bool = false
var rule_id: StringName = &""     # which rule vetoed; &"" when not vetoed

class_name ClearGroup extends RefCounted
var cells: PackedInt32Array = PackedInt32Array()   # BoardState cell indices
var counts_as_layers: int = 0

class_name ArrivalPlan extends RefCounted
var origin: Vector3i = Vector3i.ZERO
var orient: int = 0               # Orientations index
var travel_dir: Vector3i = Vector3i.ZERO   # any of the 6 unit directions (ADR-0001)
var blocked: bool = false         # true = spawn blocked (top-out)

class_name RuleApi extends RefCounted
## The only object plugins see (ADR-0004 §7). STUB: methods arrive in RUL-002. Do not add any here.
```

No constructors with arguments (keep `new()` simple). No methods besides what is listed.

## Tests to write first

1. `test_defaults` — each class `.new()` has the defaults above.
2. `test_fields_are_typed` — assigning works: `HookContext.new().depth = 3`; `ClearGroup.new().cells = PackedInt32Array([1, 2])`;
   `ArrivalPlan.new().travel_dir = Vector3i(0, -1, 0)` (read back equal).
3. `test_rule_api_stub_instantiates` — `RuleApi.new() != null`.

## Run
`-a res://tests/unit/rules` (README; run `--import` first, five new class names).

## Done when
README "Done when" + 3 tests green.
