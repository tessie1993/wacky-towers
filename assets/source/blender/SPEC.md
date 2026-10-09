# Wacky Towers — Blender asset project

All values are starting defaults from `design/art/art-bible.md` §8, not fixed rules.

## Brief and deliverables
Game assets for Wacky Towers (Godot 4.7.2, Mobile renderer): block cubes and status
shells, biome islands, props, mascot. Each asset ships as one `.glb` (glTF 2.0).

- Source file: `wacky_towers.blend` (this folder)
- Local exports: `exports/`
- Game import folder: `C:/Users/tessi/Claude/repos/wacky towers/assets/models/`
  (set once in `scripts/export_glb.py` as `GAME_MODELS_DIR`)

## References and assumptions
Art bible: `<game repo>/design/art/art-bible.md`. Put reference images in `refs/`.
Style: painterly toy-box diorama, chunky bevelled cubes, hand-painted textures with baked
light/AO, matte surfaces.

## Spatial contract
- Units: metric, scale 1.0. **1 Blender unit = 1 grid cell = 1 cube edge.**
- Axes: Blender Z-up; the glTF exporter converts to Godot Y-up (+Y up).
- Origin: piece/cube origin at the cell centre so pieces snap to the grid.
- Transforms applied before export.
- Bevel ≈ 15% of cube edge (0.15), seam groove ≈ 1/3 of the bevel.

## Camera and time
Not a render project. `renders/probes/` holds look-check renders only.

## Look and lighting
Toon / hand-painted look is done in Godot shaders; Blender materials only carry the
base colour texture. Textures: PNG, painted at ~2× ship size.

## Ownership and rebuild order
- Collection `EXPORT`: one child collection per asset; its name is the file name
  (e.g. `blk_cube_base` → `blk_cube_base.glb`).
- Collection `REF`: grid reference (1×1×1 cell cube), never exported.
- Naming: `prefix_scope_name_variant` — `blk_`, `shl_<effect>`, `env_<biome>_`,
  `prp_<biome>_`, `chr_`, `vfx_`.

## Acceptance checks
No polygon or texture budgets for now (removed 2026-10-09).

Cube still reads as chunky at ~20 px on screen.

## Decisions and validation
- 2026-10-09: project created (Blender 5.2). Export via `scripts/export_glb.py`.
