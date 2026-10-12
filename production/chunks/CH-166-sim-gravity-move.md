# CH-166 BoardSim: gravity, soft drop, move command

**MB task:** MB-031 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-064, CH-051
**Files:** edit `src/core/sim/board_sim.gd`. Same file `src/core/sim/board_sim.gd` as CH-035/064/166/066/167: ONE agent, strictly in that order (MB-031). Integer-only math, deadlines via `now_ms()` (ADR-0001), events only from `SimEvents` consts.

## API
```gdscript
# commands (SimEvents.CMD_*): CMD_MOVE args [Vector3i world_dir]; CMD_SOFT_DROP_ON / _OFF
```

## Behaviour
- Fall GDD F1/rules 1-5. Speed `g = min(g_max, g0 + ramp_per_clear*layers_cleared + ramp_per_min*minutes) * gravity_scale`, all as milli-units from `KnobRegistry` (`fall.g0`, `fall.g_max`, `fall.ramp_per_clear`, `fall.ramp_per_min`, `fall.gravity_scale`); step interval ms = `1_000_000 / g_milli`. Soft drop: `g_soft = clamp(g*soft_drop_factor, soft_drop_min, soft_drop_max)`.
- A fall step = `Movement.try_translate(piece, board, travel_dir)`. OK -> `PIECE_MOVED {uid, origin, cause: &"fall"}`; BLOCKED -> piece is resting (phase RESTING; lock timer is CH-066). The gravity clock is a deadline in ms; toggling soft drop does not reset it; a successful step does.
- `CMD_MOVE`: `Movement.try_translate` with the world dir; OK -> `PIECE_MOVED {cause: &"move"}`; BLOCKED -> `PIECE_BLOCKED {kind: &"move", reason}`. Commands applied in arrival order, each against the previous result. Ignored when no piece.
- Support removed from a RESTING piece (is_resting false after a move) -> back to FALLING.

## How the integrator sees it working
Editor script eval: spawn a piece, step 1 s at g0 0.6 (interval ~1667 ms): after ~100 ticks one `PIECE_MOVED fall` event, y decreased by 1. Queue `CMD_MOVE (1,0,0)` x6 at the +x wall: first moves emit `PIECE_MOVED move`, the last emits `PIECE_BLOCKED out_of_bounds`. Soft drop on: events come ~10x faster. Piece reaches the floor and phase becomes RESTING.

**Out of scope: rotate (CH-167), hard drop, lock (CH-066).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
