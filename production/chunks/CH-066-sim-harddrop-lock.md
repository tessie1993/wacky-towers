# CH-066 BoardSim: hard drop, grace, lock delay, lock write

**MB task:** MB-031 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-166, CH-050, CH-148; GDD fall-drop-lock (Designed)
**Files:** edit `src/core/sim/board_sim.gd`. Same file `src/core/sim/board_sim.gd` as CH-035/064/166/066/167: ONE agent, strictly in that order (MB-031). Integer-only math, deadlines via `now_ms()` (ADR-0001), events only from `SimEvents` consts.

## API
```gdscript
# command: CMD_HARD_DROP (no args). Events: PIECE_MOVED {cause: &"drop"}, PIECE_LOCKED {uid, cells: Array[Vector3i], cause: &"delay"|&"hard_drop"|&"commit", holes_added: int}
```

## Behaviour
- Lock delay (Fall rules 9-13): timer starts at `fall.lock_delay_ms` (500) every time the piece comes to rest; counts down only while resting; at 0 -> lock. A SUCCESSFUL move or rotate while resting restarts it and uses one of `fall.lock_resets_max` (10); at 0 resets left the timer runs on. Falling to a layer lower than ever before restores the resets (rule 11, lowest cube along down). Piece stops resting -> timer cleared, resets kept.
- Hard drop (rules 6-8): ignored unless a piece is active; moves the piece `drop_distance` cells at once (`PIECE_MOVED cause drop`), then phase GRACE for `fall.hard_drop_grace_ms` (150): moves/rotates still allowed and do not extend it; grace end + resting -> lock; unsupported -> back to FALLING; a second hard drop in grace -> lock now (`cause: commit`).
- Lock (rule 14, steps S1 only for now): write each cube with `board.place(...)` (kind = block, colour = shape hue id, piece uid), clear the active piece, phase -> RESOLVING, emit `PIECE_LOCKED` then one `CELLS_CHANGED {delta: board.take_delta()}`. Resolve sequence S2-S10 is CH-068; until then after `fall.entry_delay_ms` (200) phase -> WAITING -> spawn again (so the loop is playable).
- `holes_added`: number of empty cells directly under the locked cubes along down.

## How the integrator sees it working
Editor script eval: spawn, queue `CMD_HARD_DROP`: one `PIECE_MOVED drop`, phase GRACE, 150 ms later `PIECE_LOCKED cause hard_drop`, board has 4 SOLID cells, a new piece spawns ~200 ms after. Let a piece fall and rest with no input: lock at ~500 ms after resting (`cause delay`). Second hard drop in grace locks immediately (`commit`).

**Out of scope: clears, goal, top-out, rule hooks (CH-068).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
