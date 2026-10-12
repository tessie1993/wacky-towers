# CH-053 Movement: rotate X/Y/Z with kicks and up-kick budget

**MB task:** MB-021 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-051, CH-160, CH-001 (Orientations)
**Files:** edit `src/core/sim/movement.gd` (same agent as CH-051, after it); edit `src/core/model/`-side `ActivePiece` file only to add `up_kicks_used: int`

## API
```gdscript
static func try_rotate(p: ActivePiece, board: BoardState, axis: Orientations.Axis, sign: int, opts: Dictionary) -> Dictionary
## returns {result: Result, reason: StringName, kicked: bool, offset: Vector3i}; opts also holds max_up_kicks_per_piece and enabled_axes (Array[int])
```

## Behaviour
- Axis not in `opts.enabled_axes` -> `{DISABLED}`, no change (no bonk).
- New orientation `Orientations.turn(p.orient, axis, sign)`; test in place first; if it fits take it, `kicked=false`.
- Else walk `KickTable.candidates`; first whose cells pass `can_place` wins -> origin += offset, `kicked=true`. An up-kick (`is_up_kick`) is skipped once `p.up_kicks_used >= max_up_kicks_per_piece` (default 2); a taken up-kick increments it. Lateral candidates are still tried when the budget is spent.
- A wide (2-cell) candidate applies only if the 1-cell offset in the same direction also passes.
- None fits -> `{BLOCKED, reason of the in-place test}`, piece unchanged.
- A rotation that leaves the cells unchanged (big cube, mono) returns OK with the orientation recorded.
- World axes only; the camera mapping happens before (ViewSnap).

## How the integrator sees it working
Editor script eval: the GDD F2 example (T at pivot (3,5,1) against the -z wall): rotate +90 about Y returns OK, kicked=true, offset (0,0,1). Rotate -90 afterwards is a normal rotation here (undo restore is CH-094). Spam rotate in a 1-wide pit: after two up-kicks the third attempt returns BLOCKED. Disabled axis returns DISABLED. Print and read via `logs_read`.

**Out of scope: undo/restore record (CH-094), landed_move_rule=supported, place_nearest_up.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
