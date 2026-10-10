# CH-064 BoardSim: countdown, first spawn, spawn event

**MB task:** MB-031 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-035, CH-044, CH-059, CH-049, CH-148
**Files:** edit `src/core/sim/board_sim.gd`. Same file `src/core/sim/board_sim.gd` as CH-035/064/166/066/167: ONE agent, strictly in that order (MB-031). Integer-only math, deadlines via `now_ms()` (ADR-0001), events only from `SimEvents` consts.

## API
```gdscript
func get_piece() -> ActivePiece        ## null when none
func preview(n: int) -> Array[StringName]   ## Spawner.peek(n)
func ghost_cells() -> Array[Vector3i]  ## cells at the drop target (Movement.drop_distance), [] when no piece
```

## Behaviour
- `_init` builds `Spawner` from `level.pieces` (+ knob `spawn.queue_lookahead`, seed via `Seeds`), the `top` arrival plugin from `catalog.plugins.create(&"ArrivalStyle", knob spawn.arrival)`, and the goal/top-out plugins from knobs `goal.type` / `goal.top_out`.
- Phase `COUNTDOWN` lasts knob `goal.countdown_ms` (3000); the first spawn happens on the tick it ends (ADR-0010 §1). `queue_command(&"countdown_restart")` resets the deadline.
- Spawn: `Spawner.next()` -> `ShapeBank.get_shape` -> `ActivePiece` (uid counter, `orient=spawn_orient`, plan from the arrival style). `plan.blocked` -> top-out path (CH-068; for now emit `LEVEL_FAILED` and go ENDED). Phase -> FALLING, emit `PIECE_SPAWNED {uid, shape_id, orient, origin}` and `PHASE_CHANGED`. Soft drop is cleared on spawn (Fall rule 5). Gravity clock reset to spawn time (rule 1a).
- Commands during COUNTDOWN/WAITING are ignored (no buffering in the sim; the controller buffers).

## How the integrator sees it working
Editor script eval: build a `BoardSim` from meadow_01, step 179 ticks: phase COUNTDOWN, no piece; step to tick 180 (3000 ms): phase FALLING, exactly one `PIECE_SPAWNED` event, first shape is `o` or `i` (opening set), `get_piece().origin.y` in the spawn zone, `ghost_cells()` at the floor. Same seed twice gives the same shape sequence.

**Out of scope: gravity (CH-166), commands (CH-166), locking (CH-066).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
