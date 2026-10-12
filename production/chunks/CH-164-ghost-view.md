# CH-164 GhostView: landing ghost + landing shadow

**MB task:** MB-025 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-057
**Files:** new `src/view/ghost_view.gd` (`class_name GhostView extends Node3D`)

## API
```gdscript
class_name GhostView extends Node3D
func show_cells(cells: Array[Vector3i], board_size: Vector3i, hue: Color) -> void   ## outline cubes at the drop target + a shadow quad on the surface below
func hide_ghost() -> void
```

## Behaviour
- Fall GDD rule 17: shown at all times while a piece falls, updated on the tick of each move/rotate/fall step; sits at the piece's own position when resting.
- Look (HUD readability): unshaded translucent tint of the piece hue, dark outline and diagonal hatch (a simple hatch texture or stripes shader), PLUS a soft dark square shadow under each column of the piece on the first surface below (derived from `cells` projected down to the highest solid cell: caller passes `shadow_cells`, optional arg).
- Pooled cube nodes (max 27), no per-frame allocation.

## How the integrator sees it working
In the demo: with a piece falling, screenshot shows the hatched outline at the landing cells and a shadow quad on the floor under the piece; ghost updates as the piece moves; at the floor the ghost coincides with the piece.

**Out of scope: ghost opacity setting.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
