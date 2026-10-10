# CH-043 GoalState + GoalEvaluator + TopOutPolicy bases

**Story:** RUL-001 · **Model:** Sonnet · **Wave:** W2 · **Mode:** direct
**Goal:** the two slot bases goal plugins (`clear_n`, `height`, `shape`, `survive`) and top-out plugins (`rescue`, `trim`, `lose`) extend.
**Depends:** CH-078 (core/model exists) · **Parallel-safe with:** W2
**Files:** new `src/core/model/goal_state.gd`, `src/core/rules/bases/goal_evaluator.gd`, `src/core/rules/bases/top_out_policy.gd`,
`tests/unit/rules/goal_bases_test.gd`, test fixtures `tests/unit/rules/fixtures/fake_goal.gd`, `fake_top_out.gd` (no `class_name`).

## API
```gdscript
class_name GoalState extends RefCounted
## Running goal progress; read by HUD (via events) and StarRater. Plain data.
var progress: int = 0             ## layers cleared / height reached / cells filled / ms survived
var target: int = 0
var reached: bool = false
var failed: bool = false
var layers_cleared: int = 0
var warnings_used: int = 0
var cubes_trimmed: int = 0

@abstract class_name GoalEvaluator extends RefCounted
## Slot base for goal.type plugins (PLUGIN_ID = clear_n | height | shape | survive).
@abstract func setup(goal: Dictionary, board: BoardState) -> GoalState
@abstract func update(state: GoalState, board: BoardState, cleared_now: int, level_ms: int) -> void  ## after each resolve and each tick
func tags() -> PackedStringArray       ## [] default (same as the other bases)

@abstract class_name TopOutPolicy extends RefCounted
## Slot base for goal.top_out plugins (PLUGIN_ID = rescue | trim | lose).
enum Outcome { NONE, RESCUED, TRIMMED, LOST }
@abstract func on_top_out(board: BoardState, state: GoalState, api: RuleApi) -> Outcome  ## may write the board (wipe/trim)
func tags() -> PackedStringArray
```
Style: copy `src/core/rules/bases/clear_detector.gd` (`@abstract` on the line before `class_name`, `##` docs).

## Tests first (`goal_bases_test.gd`)
1. `test_bases_abstract` — `(load(path) as GDScript).is_abstract()` true for both bases (`can_instantiate()` is true for abstract scripts in 4.7.2: do not use it).
2. `test_fixtures_concrete` — fake_goal / fake_top_out `.new()` work; fake_goal.setup returns a GoalState with `target` from `goal["n"]`.
3. `test_goal_state_defaults` — all zero / false.
4. `test_outcome_values` — `TopOutPolicy.Outcome.LOST == 3`.

## Run / Done when
`--import`, `-a res://tests/unit/rules` and `model`. README "Done when"; 4 tests green; CH-022 PluginRegistry tests still green (new kinds discovered).
**Out of scope:** `validate()` on bases (AF-1), the plugins (CH-061, CH-117, CH-122, CH-132).
