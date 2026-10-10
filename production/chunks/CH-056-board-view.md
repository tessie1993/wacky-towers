# CH-056 BoardView: MultiMesh locked blocks (greybox)

**MB task:** MB-025 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-041 (ArtSet/BoardGeom), CH-050 (delta), CH-080 (SlotMap), CH-081 (BlockViewMath), ADR-0007
**Files:** new `src/view/board_view.gd` (`class_name BoardView extends Node3D`), demo `src/dev/board_view_demo.tscn`

## API
```gdscript
class_name BoardView extends Node3D
func bind(board: BoardState, art_set: ArtSet, palette: PaletteTable) -> void   ## builds the MultiMesh (LAYOUT); positions via BoardGeom.cell_center
func apply_delta(delta: PackedInt32Array) -> void   ## triples [op, a, b]: SET, REMOVE, MOVE, STATUS, OVERLAY, LAYOUT (ADR-0002 §5)
func filled_count() -> int
```

## Behaviour
- ADR-0007 §1 debug version: ONE `MultiMeshInstance3D`, formats set before `instance_count`, `use_colors = true`, `use_custom_data = true`, `instance_count = board.active_cell_count()`, `visible_instance_count = filled`. Per-instance setters (`set_instance_transform`, `set_instance_color`) are fine; packed buffer upload only if profiling asks (`# ponytail:`).
- `SlotMap` maps cell <-> slot; REMOVE swaps the last slot into the hole; MOVE re-points a slot; LAYOUT rebuilds everything. Colour = `palette.color(board.get_color(i))`. Scale cube by `art_set.cube_scale()`.
- No `MeshInstance3D` per cube anywhere. No status/fade/ripple yet.
- Flat `StandardMaterial3D` with `vertex_color_use_as_albedo`.

## How the integrator sees it working
Run `src/dev/board_view_demo.tscn`: a 4x4 board with a few hand-placed coloured cubes; key presses call board writes + `apply_delta` (add / remove / drop a layer). `editor_screenshot` to `production/qa/evidence/MB-025/` shows cubes in the right cells and colours, removals leave no ghosts, `filled_count()` matches. Cube count in the profiler: 1 draw call for blocks.

**Out of scope: shader, outlines, clear ripple (CH-082), status.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
