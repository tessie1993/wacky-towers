# MB-025 (CH-056 + CH-163 + CH-057 + CH-164)
All NEW (no tests, per user rule). Depends on staged MB-011 (BoardState), MB-010/CH-048 (ActivePiece), MB-018 (ArtSet, BoardGeom, PaletteTable.outline) being integrated first; live SlotMap, BlockViewMath, CameraMath, ShapeBank already in src/.
- src/view/board_view.gd -> NEW. `BoardView` (bind/apply_delta/filled_count) + static `make_material(albedo, outline, grow, use_instance_color)` (flat, inverted-hull dark outline via next_pass).
- src/view/board_stage.gd -> NEW. `BoardStage` (build/set_danger, `reduced_motion` var to feed from MotionPrefs.reduced). 6 nodes.
- src/view/piece_view.gd -> NEW. `PieceView` (setup(bank, art_set, palette) must be called first, then show_piece/move_to/hide_piece). Uses BoardView.make_material.
- src/view/ghost_view.gd -> NEW. `GhostView` (show_cells(cells, size, hue, shadow_cells=[])/hide_ghost). Inline spatial shaders (hatch + outline, soft shadow) as strings; shader specialist may move them to .gdshader.
- src/dev/board_view_demo.gd + .tscn -> NEW.

## How the integrator sees it
Run `res://src/dev/board_view_demo.tscn` (ortho camera, default yaw). On screen:
- Green floor slab with dark grid lines on the 4x4 footprint; faint grid on the two far walls (+x and -z sides); dashed red danger line (ribbons) at y = 8 around the footprint with a red "!" at two opposite corners.
- Locked ring of orange blocks (layer 0 border, 12 cubes) + 2 on layer 1, dark outlines. Console: `filled=14`.
- A falling piece (first shape in the bank) near the top, flat palette colour with outline; a hatched dark-outlined translucent ghost at the landing cells and soft dark shadow squares on the surface under each column; no 1.03 cube overlap (if the GLB has one mesh per cube).
- Keys: 1-5 spawn, arrows x/z, R/F up/down, Q/E rotate Y (eased), Space lock (cubes appear, piece hides/respawns), Z remove top block, X shift_layers([0]) (blocks drop), C add a block, G toggle danger pulse. `filled_count()` is printed after each board write. Take `editor_screenshot` to `production/qa/evidence/MB-025/`.

## Risks / notes
- BoardView needs `BoardState.Op`, `take_delta()`, `place/remove/move` from the MB-011 version; on a MOVE/SET log mismatch it rebuilds from the board (self-healing).
- Outline uses StandardMaterial3D `grow` on a next_pass; if the cube mesh has hard-split normals the outline may show gaps at edges (then switch to a shader). One outline colour for all hues.
- PieceView GLB cube shrink only applies when the GLB has exactly cube_count MeshInstance3Ds; otherwise overlap stays. Fallback cubes use offsets(0) + source_pivot.
- Ghost shadow default (no shadow_cells) shades the floor (y=0); the demo passes landing-column cells instead.
- Greyscale check of dash/grid not run (nothing run).

## Review
- board_stage.gd: _ready() no longer forces set_process(false) (it clobbered a set_danger(true) made before the node entered the tree); it now derives from _danger_on/reduced_motion.
- Rest checked OK vs live/staged APIs (BoardState.Op/take_delta/active_cell_count, SlotMap, ShapeBank.ids/get_shape, ActivePiece, ArtSet/BoardGeom/PaletteTable.color, CameraMath), MultiMesh order (format, use_colors, custom data, mesh, then instance_count), next_pass cull_front+grow outline, inline shaders valid for 4.7.
