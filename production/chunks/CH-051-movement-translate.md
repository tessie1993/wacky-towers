# CH-051 Movement: ActivePiece cells, translate, drop distance, resting

**MB task:** MB-021 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-048 (ActivePiece), CH-031 (BoardState queries); GDD movement-rotation (Designed)
**Files:** new `src/core/sim/movement.gd` (`class_name Movement`)

## API
```gdscript
class_name Movement extends RefCounted
## Pure collision authority (Movement & Rotation GDD rules 2-8, 17). Never writes the board.
enum Result { OK, BLOCKED, DISABLED }
const R_NONE := &""; const R_OUT := &"out_of_bounds"; const R_INACTIVE := &"inactive"; const R_OCCUPIED := &"occupied"
static func try_translate(p: ActivePiece, board: BoardState, delta: Vector3i) -> Dictionary   ## {result, reason}; moves p.origin on OK
static func drop_distance(p: ActivePiece, board: BoardState) -> int     ## board.cast(cells, p.travel_dir)
static func is_resting(p: ActivePiece, board: BoardState) -> bool        ## GDD F4: any cube has floor/solid directly below along down
static func blocked_reason(board: BoardState, cell: Vector3i) -> StringName   ## out_of_bounds / inactive / occupied
```

## Behaviour
- `try_translate` is the single collision primitive: cells = `p.cells()` shifted by `delta`; all pass `board.can_place` -> origin moves, `{OK, R_NONE}`; else nothing changes and the reason is that of the FIRST failing cell, in cell order.
- Reason mapping: not `in_bounds` -> out_of_bounds; not active -> inactive; otherwise occupied (solid). Overlay content passes (BoardState.is_free already ignores it).
- `is_resting` uses `board.down_vector()`; below-floor counts as support; overlay never supports.
- 3 axes everywhere; works for all 6 down directions. No rate limit, no state.

## How the integrator sees it working
Editor script eval on the meadow board: place `o` at the centre, `try_translate(+x)` x5 on a 4-wide board: first moves return OK, the move through the wall returns BLOCKED / out_of_bounds and origin is unchanged. `drop_distance` of a piece at the spawn height = spawn y (floor empty). `is_resting` true when dropped, false one layer higher. Print results; read via `logs_read`.

**Out of scope: rotation (CH-053), lock delay, undo.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
