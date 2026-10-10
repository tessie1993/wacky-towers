# CH-088 ScoreKeeper (clear F2, combo, drop and place points)

**MB task:** MB-023 · **Model:** Haiku · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-148, GDD points-system (Designed)
**Files:** new `src/core/sim/score_keeper.gd`

## API
```gdscript
class_name ScoreKeeper extends RefCounted
func _init(knobs: Dictionary) -> void        ## goal.clear_base, goal.combo_bonus, goal.chain_bonus, goal.drop_points, goal.place_points (milli/ints)
func on_place() -> int                       ## points added
func on_drop(cells: int, hard: bool) -> int
func on_clear(layers: int, chain_round: int) -> int
func total() -> int
func combo() -> int
func reset_combo() -> void                   ## called on a lock that clears nothing
```

## Behaviour
- Formulas F2/F3 of `design/gdd/points-system.md` (read it; values are the `goal.*` knobs, integer math, no float). Rescue wipes never score. A lock with no clear resets the combo.
- Pure; `BoardSim` calls it (CH-068).

## How the integrator sees it working
Editor script eval: new keeper with the default knobs: `on_clear(1,0)` then `on_clear(2,0)` totals match the GDD example values (compute from points-system F2 and write them in the log); `reset_combo()` then `combo() == 0`.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
