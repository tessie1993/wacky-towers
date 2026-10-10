# GP-0 Board preview: evidence

**Date:** 2026-10-10. **Engine:** Godot 4.7.2 (Mobile renderer). **Scene:** `res://src/dev/board_preview.tscn` (script `src/dev/board_preview.gd`)

## What it does

- **Board spec.** An 8x8 Meadow-like board spec is written in the script as ASCII: W 8, D 8, `h_play` 10, the four corners masked, and 3 starting layers.
- **Parsing.** `BoardSpec.parse` checks the size, the mask and the default spawn anchor. `AsciiGrid.parse_layers` turns the starting layers into cells.
- **Floor.** A checkered tile is drawn for every active mask cell. This is one `MultiMeshInstance3D` using a `BoxMesh`.
- **Locked blocks.** All 71 locked blocks are drawn with one `MultiMeshInstance3D` that uses the set's cube mesh, taken from `blk_<set>_cube.glb`.
  - It follows ADR-0007 §1: `transform_format`, `use_colors` and `use_custom_data` are set before `instance_count`.
  - Each block's colour is per instance, set by its content glyph.
  - Custom data is `(0,0,0,1)`, meaning fade = 1.
  - The look is greybox: a `StandardMaterial3D` with `vertex_color_use_as_albedo`. No custom shader.
- **Falling piece.** One falling piece is instanced straight from `assets/models/blocks/candy_toy/blk_candy_toy_l.glb` and placed above the spawn anchor (ADR-0007 §2).
- **Camera.** An orthographic `Camera3D` is aimed at the board centre at snap k=0 (yaw 45°), with 30° elevation.
  - It uses the same yaw convention as `CameraRig`: screen right = (sin yaw, 0, cos yaw).
  - `Camera3D.size` comes from `CameraMath.ortho_size(spec.size, 30, aspect, 1.0)`.
- **Lighting.** A `DirectionalLight3D` with shadows and a `WorldEnvironment` (flat colour background, colour ambient).
- **Block set switch.** The exported `block_set` (`candy_toy` / `neon_voxel`) switches the set. You can also pass `-- --set=neon_voxel` on the command line, and `--shot=res://...png` saves a frame and quits.

## Chunks consumed

`AsciiGrid.parse_layers` (and `parse_mask` through BoardSpec), `BoardSpec.parse` + `BoardSpecResult` (part 1), `BoardLimits.new()`, `ContentTypes.from_entries` / `glyphs()` with `assets/data/content/blocks.json` (read through `JsonReader.read_file`), `BoardState` (indirectly, for the down-axis check), `CameraMath.yaw_degrees` / `ortho_size`.

## Verification

- `script_check` on `board_preview.gd`: valid.
- I ran the scene from the editor with godot-ai `project_run` (custom scene). The game log has no errors. It reports `set=candy_toy size=(8, 14, 8) cells=71`.
- **Screenshot:** `production/qa/evidence/GP-0-board-preview.png` (1152x648, game framebuffer). It shows a green checkered 8x8 floor with clipped corners and a low starting stack: green grass, grey stone towers, orange starter blocks, one pink flower. A blue L piece floats above the centre. The whole board is in frame.
- **neon_voxel:** I switched sets at runtime with `game_eval` (`block_set = "neon_voxel"; build()`), and it rendered the same board with the faceted neon cube. That frame was not kept as evidence; only the candy_toy frame above is.

## Integration findings (for the lead)

1. **The content table has only one glyph.** `blocks.json` has a single glyph, `#` (starter), and `block` has no glyph. To show a colour per glyph, the preview adds dev-only kinds `g`, `s`, `f` (kind_id 10–12) in the script. Real Meadow content glyphs need data entries.
2. **No board-to-colour mapping exists yet.** `ContentTypes.hue()` returns an int, but nothing maps a hue to a colour. The preview uses its own glyph→Color table.
3. **Starting contents are parsed outside BoardSpec.** `BoardSpec.parse` part 1 accepts `starting_contents` but does not parse it, so `spec.contents` stays empty. The preview calls `AsciiGrid.parse_layers` itself and keeps the starting layers out of the spec dict. When CH-008 lands, switch to `spec.contents`, which gives kind ids, not glyphs.
4. **neon_voxel has no cube GLB.** There is no `blk_neon_voxel_cube.glb`. The preview falls back to the single-cube `blk_neon_voxel_mono.glb` and takes its mesh, so there is no fall back to candy_toy and the set still renders. The pipeline should export `blk_neon_voxel_cube.glb` to match candy_toy.
5. **The two sets' cube meshes differ in size.** The candy_toy cube mesh AABB is 1.03 (±0.515), while neon_voxel's is 1.00. Adjacent candy cubes overlap by 0.03, which may z-fight on touching faces under the outline or fade shader. The board view should either accept this or scale per set.
6. **The default frame leaves the top of the screen empty.** `CameraMath.ortho_size` frames the full board height, `h_play` plus spawn clearance (14), at every yaw. So a low stack sits in the lower half with a lot of empty sky. This is correct per Camera GDD F2, but worth a design look.
7. **No camera centre helper outside CameraRig.** `CameraMath` has no helper for the camera position or basis. The preview re-derives the CameraRig yaw convention. Using `CameraRig` directly once CH-025 is stable would remove that duplication.
8. **Editor errors from in-progress work.** During the run the editor log held stale errors from work in progress: `board_spec_result.gd` "Could not find type BoardSpec", and `camera_rig.gd` "File not found" at an earlier moment. They did not affect the run, but CH-008 / CH-025 should be re-checked after they finish.
