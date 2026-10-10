# CH-167 BoardSim: rotate command, lock-reset hookup

**MB task:** MB-031 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-066, CH-053
**Files:** edit `src/core/sim/board_sim.gd`. Same file `src/core/sim/board_sim.gd` as CH-035/064/166/066/167: ONE agent, strictly in that order (MB-031). Integer-only math, deadlines via `now_ms()` (ADR-0001), events only from `SimEvents` consts.

## API
```gdscript
# CMD_ROTATE args [axis: int (Orientations.Axis, world), sign: int (+1/-1)]
# Events: PIECE_ROTATED {uid, orient, origin, kicked: bool, offset: Vector3i}; PIECE_BLOCKED {kind: &"rotate", reason}; COMMAND_APPLIED {result: &"disabled"} when the axis is off
```

## Behaviour
- Calls `Movement.try_rotate` with opts from knobs: `control.rotation_axes_enabled` (strings "spin"/"tilt"/"roll" are view-level; the sim list is world axes - the loader/controller maps; for MVP the sim accepts all 3 world axes when `rotation_axes_enabled` is non-empty and rejects with DISABLED otherwise), `control.max_up_kicks_per_piece`, `control.kick_off_axis`, `control.kick_wide_min_extent`, `control.kick_enabled`, footprint centre from the board.
- OK -> `PIECE_ROTATED`; success while resting uses a lock reset (same code path as CH-066); BLOCKED -> `PIECE_BLOCKED`; DISABLED -> `COMMAND_APPLIED disabled` (no bonk).
- `up_kicks_used` resets on spawn.

## How the integrator sees it working
Editor script eval: spawn `i`, queue `CMD_ROTATE (Y,+1)` four times: orient returns to the start, 4 `PIECE_ROTATED` events. Put the piece against a wall: a rotate emits `PIECE_ROTATED kicked=true`. Level with axes disabled: `command_applied disabled`, orient unchanged.

**Out of scope: undo/restore (CH-094).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
