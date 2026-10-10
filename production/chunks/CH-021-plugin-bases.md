# CH-021 Abstract plugin bases: RuleBehaviour, ClearDetector, CollapsePolicy, ArrivalStyle

**Story:** RUL-001
**Goal:** the four extension points whose types already exist (ADR-0004 Key Interfaces; implementation-plan §1.2 `bases/`).
**Depends:** CH-019 (value types, RuleApi stub), CH-020 (ShapeDef), CH-004 (BoardState)
**Parallel-safe with:** every batch-2 ticket except CH-022
**Files (all new):** `src/core/rules/bases/rule_behaviour.gd`, `clear_detector.gd`, `collapse_policy.gd`, `arrival_style.gd`,
`tests/unit/rules/plugin_bases_test.gd`, `tests/unit/rules/fixtures/test_only_detector.gd`

## API

```gdscript
@abstract class_name RuleBehaviour extends RefCounted
## A rule with behaviour: subscribes to hooks, may veto actions (ADR-0004). Plugins declare const PLUGIN_ID: StringName.
func subscribed_hooks() -> Array[StringName]: return []
func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void: pass
func veto(action: StringName, ctx: HookContext, api: RuleApi) -> bool: return false
func tags() -> PackedStringArray: return PackedStringArray()      # compatibility tags (ADR-0004 §atoms)

@abstract class_name ClearDetector extends RefCounted
@abstract func find_clears(board: BoardState, api: RuleApi) -> Array[ClearGroup]
func tags() -> PackedStringArray: return PackedStringArray()

@abstract class_name CollapsePolicy extends RefCounted
@abstract func collapse(board: BoardState, cleared: Array[ClearGroup], api: RuleApi) -> void
func tags() -> PackedStringArray: return PackedStringArray()

@abstract class_name ArrivalStyle extends RefCounted
@abstract func plan_arrival(shape: ShapeDef, board: BoardState, api: RuleApi) -> ArrivalPlan
func tags() -> PackedStringArray: return PackedStringArray()
```

**Not in this ticket:** `validate(level, catalog) -> Array[ValidationIssue]` on these four bases is CH-039; `GoalEvaluator`, `TopOutPolicy` are CH-040; `ControlVerb`, `LayoutKind` are CH-041 (gap decisions 4–5: `ValidationIssue`, `SimCommand`, `SimEvent`, `GoalState` live in `src/core/model/`).

## Fixture `tests/unit/rules/fixtures/test_only_detector.gd`

```gdscript
class_name TestOnlyDetector extends ClearDetector
## Test fixture: proves a detector is found by id with no core edit (ADR-0004 validation item).
const PLUGIN_ID: StringName = &"test_only"
func find_clears(_board: BoardState, _api: RuleApi) -> Array[ClearGroup]:
	var g := ClearGroup.new()
	g.cells = PackedInt32Array([7])
	g.counts_as_layers = 1
	return [g]
```

## Tests to write first

1. `test_bases_are_abstract` — for each of the 4 base scripts (`load("res://src/core/rules/bases/<file>.gd")`):
   `script.can_instantiate() == false`. **Verify on 4.7.2** that `@abstract` makes `can_instantiate()` false; if not, find
   the 4.7.2 API that reports it (`docs/engine-reference/godot/`), use it, and note it in your hand-off.
2. `test_fixture_detector_works` — `TestOnlyDetector.new().find_clears(null, null)[0].cells == PackedInt32Array([7])`.
3. `test_default_tags_empty` — `TestOnlyDetector.new().tags().is_empty()`.
4. `test_rule_behaviour_defaults` — a tiny inner subclass in the test (`class _B extends RuleBehaviour: pass`):
   `subscribed_hooks() == []`, `veto(&"x", HookContext.new(), null) == false`.

## Run
`-a res://tests/unit/rules` (README; `--import` first).

## Done when
README "Done when" + 4 tests green.
