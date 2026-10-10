# First playable — meadow_01

**Status:** in-progress (playable throwaway slice). Spec: `CONTRACT.md` (deltas listed below).

## Hypothesis
Dropping flat tetromino pieces into a small 3D well and clearing full horizontal layers is
readable and fun from a rotating isometric camera, with full 3D piece rotation (turn + flip),
on keyboard and touch, before any of the real systems exist.

## How to run
Open the project in Godot 4.7.2 and press **F5** (main scene = `fp_main.tscn`).

## Controls
| Action | Keys | Touch |
|---|---|---|
| Move (screen-relative) | Arrows / WASD | ▲ ◀ ▼ ▶ pad |
| Turn (horizontal, around world Y; right = clockwise from above) | Q / E | Turn ◀ / Turn ▶ |
| Flip (vertical, tips the piece left/right on screen: around the view axis snapped to X/Z) | R / F | Flip ◀ / Flip ▶ |
| Soft drop | Shift (hold) | SOFT |
| Hard drop | Space | DROP |
| Rotate view 90° | Z / C | ◁ VIEW / VIEW ▷ |
| Restart | Backspace | panel buttons |

Turn + Flip reach all 24 orientations. Rotation keeps the pivot cube fixed; blocked rotations try
kicks ±x, ±z, then one cell up.

## Files
- `fp_board.gd` FpBoard — voxel grid, lock, layer clear + collapse
- `fp_pieces.gd` FpPieces — shape data, pivot, `rotate(axis, dir)` via `Orientations` (ADR-0003); `fp_bag.gd` FpBag — seeded opening + 7-bag
- `fp_game.gd` FpGame — pure sim: gravity, lock delay, rotation + kicks, clears, win/lose, stars
- `fp_view.gd` FpView — camera (4 corner snaps), slate floor + grid, far-wall column guides, outlined MultiMesh cubes, ghost, landing-column marks
- `fp_input.gd` FpInput, `fp_touch.gd` FpTouch — keyboard + on-screen buttons on the `wt_*` actions
- `fp_hud.gd` FpHud — layers, timer, next, key legend, win/lose panels
- `fp_main.gd` / `fp_main.tscn` — wiring; `fp_platform.tscn` — greybox island (authored 10x10, stretched to board + 1-cell rim; swap for real art)

## Deltas from CONTRACT.md
- Board size comes from the JSON (meadow_01 now 8x8); nothing assumes 4x4.
- Rotation on all three axes (user request): `spin` is now turn about Y; added Flip. The level's spin-only knob is ignored here.
- Restart moved from R to Backspace (R/F are Flip).
- Spin right = clockwise seen from above (the contract's formula was the counter-clockwise one).

## Replaced later by
| Prototype | Real system |
|---|---|
| FpBoard | BoardState (`src/core/board/`) |
| FpGame | BoardSim + rules/knobs (`src/core/rules/`) |
| FpPieces / FpBag | ShapeDef / ShapeBank + Orientations (`src/core/shapes/`) |
| FpView | `src/view/` block rendering (ADR-0007) + camera rig (CameraMath, 12 snaps) |
| FpInput / FpTouch | input + controls GDD (GUIDE remapping) |
| FpHud | real UI / HUD |
| fp_platform.tscn | biome art (meadow island) |

## Known gaps
- No rescue/warnings on top-out (just LOST), no score, no audio, no animation on clear/lock.
- Only 4 corner camera snaps (real camera has 12); movement on a corner view is diagonal on screen.
- No tests (prototype).

## Findings
_To fill in after playtests._
