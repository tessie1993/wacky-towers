# CH-039 meadow_01 JSON into its level folder + biomes/meadow.json

**Story:** DAT-004 · **Model:** Haiku · **Wave:** W1 · **Mode:** direct
**Goal:** layout doc §4.1: one folder per level (scene + JSON). The biome file lists levels and the block set.
**Depends:** none · **Parallel-safe with:** W1
**Files:** new `src/levels/meadow/meadow_01/meadow_01.json` (byte copy of `production/levels/meadow/data/meadow_01.json`),
new `assets/data/biomes/meadow.json`, new `tests/unit/levels/biome_files_test.gd`.

## Data
```json
{ "id": "meadow", "art_set": "candy_toy", "palette": "candy_toy",
  "levels": [ { "id": "meadow_01", "scene": "res://src/levels/meadow/meadow_01/meadow_01.tscn",
                "json": "res://src/levels/meadow/meadow_01/meadow_01.json" } ] }
```
Only meadow_01 is listed; each later level-scene ticket appends its own line. Leave `control.rotation_axes_enabled: ["spin"]` in the
level JSON (per-level knob; systems support all 3 axes).

## Tests first (`biome_files_test.gd`, reads files via `JsonReader.read_file`)
1. `test_meadow_biome_parses` — keys `id, art_set, palette, levels`; `levels` non-empty; ids unique.
2. `test_level_json_exists` — every `levels[i].json` reads OK and its `id` equals `levels[i].id`.
3. `test_art_set_dir_exists` — `DirAccess.dir_exists_absolute("res://assets/models/blocks/" + art_set)`.
(Scene existence is checked by CH-069, not here: the scene does not exist yet.)

## Run / Done when
`-a res://tests/unit/levels`. README "Done when"; 3 tests green.
**Out of scope:** meadow_02..10 (their own tickets), level validation (CH-049/076).
