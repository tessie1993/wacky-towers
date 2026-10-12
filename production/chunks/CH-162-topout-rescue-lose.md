# CH-162 `rescue` and `lose` top-out policies

**MB task:** MB-022 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-151, CH-050, CH-054, CH-148
**Files:** new `src/mechanics/goal/rescue_top_out.gd`, `src/mechanics/goal/lose_top_out.gd`

## API
```gdscript
class_name RescueTopOut extends TopOutPolicy
const PLUGIN_ID := &"rescue"
func resolve_top_out(board: BoardState, state: GoalState, api: RuleApi) -> int   ## CONTINUE after a wipe, LOST if no warning left
static func wipe_size(stack_h: int, h_play: int, margin: int) -> int             ## F3: max(1, s - (h_play - 1 - margin))
class_name LoseTopOut extends TopOutPolicy
const PLUGIN_ID := &"lose"
func resolve_top_out(board: BoardState, state: GoalState, api: RuleApi) -> int   ## always LOST
```

## Behaviour
- Level Goals rules 8-9, 10c, F3. `RescueTopOut`: if `state.warnings_left <= 0` return LOST. Else k = `wipe_size(board.stack_height(), board.h_play(), margin)` (margin = knob `goal.rescue_margin`, default 2; read from `api` knob read or a constructor arg `margin`), `warnings_left -= 1`, silently remove the bottom k layers (BoardState remove with cause RESCUE, no hooks) and `board.shift_layers(PackedInt32Array([0..k-1]))`. Never changes `layers_cleared`. If the stack still `over_limit()` after the wipe: warning stays used and return LOST.
- The sim (CH-068) owns entering the Warning phase and `t_warning_ms`; this class only mutates board + state.

## How the integrator sees it working
Editor script eval: 4x4 board h_play 8 stacked to layer 9 (s=9), margin 2: `wipe_size(9,8,2) == 4`; resolve with warnings_left 1: CONTINUE, warnings_left 0, `stack_height() == 5`, `layers_cleared` unchanged. Second call: LOST. `LoseTopOut` returns LOST with warnings_left 3.

**Out of scope: trim policy, Warning phase timing.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
