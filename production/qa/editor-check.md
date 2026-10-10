# Editor check - 2026-10-10 04:13

## Editor errors (src/tests)
- src/core/shapes/shape_def.gd:11,12,13,20 - Could not find type "PackedVector3iArray" (does not exist in Godot; use PackedInt32Array/Array[Vector3i])
- src/core/shapes/shape_def.gd:12,13,22 - Function "PackedVector3iArray()" not found
- src/core/shapes/shape_def.gd:0 - Failed to load script (Parse error)
- tests/unit/shapes/shape_def_test.gd:8,16,17,18 - cannot resolve offsets_by_orient / bbox_by_orient / min_by_orient / offsets (cascade)
- tests/unit/shapes/shape_def_test.gd:15,16,17,26,27,28 - PackedVector3iArray() not found
- tests/unit/shapes/shape_def_test.gd:0 - Failed to load script (Parse error)
Noise: addons/guide/editor/class_scanner.gd:18 signal already connected (ignore).

## Suite (headless, tests/unit)
Overall Summary: 74 test cases | 0 errors | 1 failures | 0 flaky | 0 skipped | 0 orphans

## Failures
- tests/unit/assets/block_set_import_test.gd:58 test_block_sets_each_set_has_a_cube_file - "neon_voxel: no blk_neon_voxel_cube*.glb"

Note: shape_def_test is not among the 74 (fails to load). Screenshot skipped (tool has no save path).
