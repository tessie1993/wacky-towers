# CH-079 Cube mesh `.res` + import contract test

**Story:** VEW-002 (RND-01) · **Model:** Sonnet · **Wave:** W1 · **Mode:** direct
**Goal:** BoardView needs a plain `Mesh` for the MultiMesh, not a GLB scene; the import test guards every block set.
**Depends:** none · **Parallel-safe with:** W1
**Files:** new `tools/asset-pipeline/export_cube_mesh.gd` (`extends SceneTree`, `-s`), generated
`assets/models/blocks/candy_toy/blk_candy_toy_cube.res`, edit `tests/unit/assets/block_set_import_test.gd`.

## Tool behaviour
For every set dir under `res://assets/models/blocks/` that has `blk_<set>_cube.glb`: instantiate it, take the first `MeshInstance3D`'s
mesh, `ResourceSaver.save(mesh, "<dir>/blk_<set>_cube.res")`. Print the mesh AABB size (candy_toy is 1.03; CH-041 scales it).

## Tests first (add to `block_set_import_test.gd`)
1. `test_cube_res_for_every_cube_glb` — each set with a cube GLB has `blk_<set>_cube.res`; it loads as `Mesh`.
2. `test_cube_res_matches_glb` — same surface count and vertex count (`surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()`) as the GLB mesh.
3. `test_block_import_flags` — every `blk_*.glb.import` (read with `ConfigFile`) has `meshes/generate_lods=false` and
   `meshes/create_shadow_meshes=false`. If one differs, fix it in the editor Import dock and re-import; never weaken the test.

The existing neon_voxel "no cube GLB" failure stays red (known asset gap; do not skip it).

## Run / Done when
Run the tool, `--import`, `-a res://tests/unit/assets`. New tests green; only the known neon_voxel red remains.
**Out of scope:** neon_voxel cube export (technical-artist), shaders.
