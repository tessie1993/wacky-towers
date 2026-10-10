# CH-061 `clear_n` goal evaluator

**MB task:** MB-022 · **Model:** Haiku · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-151, CH-148
**Files:** new `src/mechanics/goal/clear_n_goal.gd`

## API
```gdscript
class_name ClearNGoal extends GoalEvaluator
const PLUGIN_ID := &"clear_n"
func configure(goal: Dictionary) -> void                       ## reads goal["n"] (int >= 1)
func evaluate(state: GoalState, api: RuleApi) -> int           ## WON when state.layers_cleared >= n else RUNNING
func progress(state: GoalState) -> Dictionary                  ## {"done": min(layers_cleared, n), "target": n}
func validate(level: LevelData, catalog: GameCatalog) -> Array[ValidationIssue]   ## n missing or < 1 -> error
```

## Behaviour
- Level Goals rule 2: only layers cleared by Layer Clearing count; rescue wipes never touch `state.layers_cleared` (the sim does that).
- meadow_01 goal is `{type: clear_n, n: 4}`; the HUD reads `progress()`.

## How the integrator sees it working
Editor script eval: `configure({n:4})`; states with layers_cleared 0, 3, 4, 6 -> RUNNING, RUNNING, WON, WON; `progress` prints {done:3,target:4} for 3. `validate` of a level with `goal: {type:"clear_n"}` returns one error.

**Out of scope: height/shape/survive goals (later chunks).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
