# CH-057 PieceView: falling piece from the shape GLB with interpolation

**MB task:** MB-025 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-041, CH-047, CH-048
**Files:** new `src/view/piece_view.gd` (`class_name PieceView extends Node3D`)

## API
```gdscript
class_name PieceView extends Node3D
func show_piece(shape_id: StringName, orient: int, origin: Vector3i, board_size: Vector3i) -> void   ## loads ArtSet.shape_scene (falls back to cube children from ShapeDef offsets)
func move_to(origin: Vector3i, orient: int, tween_ms: int) -> void   ## eased between ticks; instant when tween_ms == 0
func hide_piece() -> void
```

## Behaviour
- Root transform = `BoardGeom.piece_root_transform(origin, orient, shape.source_pivot, board_size)`. `blk_*_cube` glb has no pivot empty: wrap in a Node3D (ADR-0007 §2).
- Fallback when the GLB is missing: build N small cube `MeshInstance3D`s from `shape.offsets(orient)` with the palette colour (so the loop is playable before the models are fixed).
- Move/rotate ease over `control.rotate_anim_ms` / a fixed 60 ms for moves; lock = hide (BoardView shows the written cubes the same frame).
- Piece material = flat palette colour for now (piece variant of the block shader is later).

## How the integrator sees it working
Demo scene (extend `board_view_demo`): keys spawn each of the 5 shapes, arrow keys move, Q/E rotate. Screenshot shows the piece in the right cells, rotation about the pivot cube, no 1.03 cube overlap. `logs_read` clean when the GLB is missing (fallback used).

**Out of scope: status, fade, colourblind patterns.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
