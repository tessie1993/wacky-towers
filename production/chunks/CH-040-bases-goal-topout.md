# CH-040 Plugin bases: GoalEvaluator + TopOutPolicy

**Story:** RUL-001
**Goal:** the goal and top-out slot extension points (ADR-0004 table: slots `goal.type`, `goal.top_out`).
**Depends:** CH-021 (pattern), CH-034, CH-037
**Parallel-safe with:** CH-039, CH-041, CH-042 … CH-050, CH-054
**Files (new):** `src/core/rules/bases/goal_evaluator.gd`, `src/core/rules/bases/top_out_policy.gd`, `tests/unit/rules/plugin_bases_goal_test.gd`

## API (implementation-plan §1.2)

```gdscript
@abstract class_name GoalEvaluator extends RefCounted
## Decides win/lose from GoalState; one plugin per goal type (clear_n, height, shape, survive). Plugins declare const PLUGIN_ID.
const RUNNING := GoalState.RESULT_RUNNING
const WON := GoalState.RESULT_WON
const LOST := GoalState.RESULT_LOST
@abstract func configure(goal: Dictionary) -> void            ## the level's goal section (targets, n, …)
@abstract func evaluate(state: GoalState, api: RuleApi) -> int  ## RUNNING / WON / LOST
func progress(state: GoalState) -> Dictionary: return {}       ## HUD data, e.g. {"done": 2, "target": 3}
func tags() -> PackedStringArray: return PackedStringArray()
func validate(level: LevelData, catalog: GameCatalog) -> Array[ValidationIssue]: return []

@abstract class_name TopOutPolicy extends RefCounted
## What happens when the stack is over the limit after clears (Level Goals rule 10a: rescue, trim, lose).
const CONTINUE := GoalState.RESULT_RUNNING
const LOST := GoalState.RESULT_LOST
@abstract func resolve_top_out(board: BoardState, state: GoalState, api: RuleApi) -> int   ## CONTINUE or LOST
func tags() -> PackedStringArray: return PackedStringArray()
func validate(level: LevelData, catalog: GameCatalog) -> Array[ValidationIssue]: return []
```

## Tests to write first

1. `test_bases_are_abstract` — `load(<path>).can_instantiate() == false` for both (same check CH-021 verified on 4.7.2).
2. `test_result_constants_match_goal_state` — `GoalEvaluator.WON == GoalState.RESULT_WON`, `TopOutPolicy.LOST == 2`.
3. `test_defaults` — inner subclass of each implementing the abstract methods trivially: `progress(GoalState.new()) == {}`, `tags().is_empty()`, `validate(...)` empty.
4. `test_registry_still_clean` — `PluginRegistry.new(ProjectSettings.get_global_class_list()).errors().is_empty()` (adding bases must not break the registry).

## Run
`-a res://tests/unit/rules` (README; `--import` first).

## Done when
README "Done when" + 4 tests green.
