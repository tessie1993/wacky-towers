# Test Fix Report -- 2026-10-10

**Story type**: Logic (whole unit suite) | **Output**: `tests/unit/` | **Gate**: BLOCKING
**Runner**: Godot 4.7.2.stable (ed1daf0bf), gdUnit4 6.2.1, headless, `-a res://tests`, reports in `reports/qa-fix/`

## Final result

`Overall Summary: 191 test cases | 0 errors | 1 failures | 0 flaky | 0 skipped | 0 orphans` -- exit 100.
26 of 26 `*_test.gd` suites were discovered and ran. The one failure is the known asset red below.

## Run history

| Run | Result | Cause |
|---|---|---|
| 1 (after `--import`) | 159 cases, 1 failure, exit 100, 23/23 suites | known red only |
| 2 | exit 105, `tests/unit/model/model_containers_test.gd` failed to load (`LevelData`/`GameCatalog` not found) | stale class cache: the CH-034 agent wrote `src/core/model/level_data.gd` and `game_catalog.gd` (05:17) after my import ran. The classes exist. |
| 3 (re-ran `--import`) | 191 cases, 1 failure, exit 100, 26/26 suites | known red only |

## Parse checks

- I ran `--check-only --script` on every `.gd` under `src/` and `tests/` (55 files at the time). 0 errors. First I confirmed the check catches real errors: a probe file using `PackedVector3iArray` was flagged.
- No `.gd` file uses `PackedVector3iArray`. The old `shape_def.gd` / `shape_def_test.gd` errors in `production/qa/editor-check.md` are already fixed on disk (CH-020/CH-026 switched to `Array[Vector3i]`).
- `knob_files_test.gd` (CH-018) passes now that the empty `"choices": []` lines are gone from controls/fall/spawn.json.

## Issues found

| File | Root cause | Fix |
|---|---|---|
| ADR-0003, implementation-plan.md, CH-020, CH-026, CH-027 | Docs still named `PackedVector3iArray`, which does not exist in Godot 4.7.2 | Text edits only. Element arrays changed to `Array[Vector3i]`. `offsets_by_orient` changed to `Array` (of `Array[Vector3i]`), since nested typed arrays are not allowed. `replace_piece` now takes `Array[Array]`, and the `PackedVector3iArray()` and `PackedVector3iArray([...])` fixtures became `[]` and `[...]`. The CH-026 sort note now says "copy to `Array[Vector3i]`, then sort". `.claude/worktrees/` copies were left alone. |
| `tests/unit/model/model_containers_test.gd` | Transient: stale global class cache. The new `class_name` was not registered until `--import` ran | No code change. Re-ran `--import`. |
| `tests/unit/rules/plugin_registry_test.gd` (editor log: `PluginRegistry` not declared, cannot infer `reg`) | CH-022 is still being written (`src/core/rules/plugin_registry.gd`). The test was not on disk during my runs | Not edited (owned by another agent). Re-check after CH-022 lands and `--import` runs. |
| `addons/script-ide/*` (import run 2: `Preload file "uid://..." does not exist`, `"Plugin" is a constant but does not contain a type`) | Transient: the uid cache was out of date during the first scan after new files arrived | Gone on the next `--import`. No change. |
| `addons/godotsteam`: `Nonexistent function 'get_godotsteam_version' in base 'Steam'` (import log) | The addon's editor script calls an API that the installed GodotSteam binary does not have. Third-party addon, not in the test path | Not fixed. Flagged for whoever owns addon setup. |

## Remaining reds

- **`tests/unit/assets/block_set_import_test.gd::test_block_sets_each_set_has_a_cube_file`** -- KNOWN RED (asset gap). The test fails with `neon_voxel: no blk_neon_voxel_cube*.glb` because `assets/models/blocks/neon_voxel/` has no cube model. The test is correct and was not disabled or weakened. It closes when the art pipeline exports `blk_neon_voxel_cube.glb`.

## Not checked

- The godot-ai MCP was not reachable from this agent, so there was no live editor `logs_read`. I used the editor log file (`%APPDATA%/Godot/app_userdata/wacky towers/logs/godot.log`) and headless `--check-only` instead.
- Files that other agents were editing at the time (board_state.gd + tests/unit/board_grid for CH-030/031, plugin_registry for CH-022, shape_bank, src/dev/board_preview, prototypes/) were not changed. Their suites passed in run 3, except plugin_registry_test, which did not exist yet.
