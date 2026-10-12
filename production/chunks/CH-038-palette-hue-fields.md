# CH-038 Palette (sampled from candy_toy) + shape hue fields + PaletteTable

**Story:** VEW-003 (folds RND-02) · **Model:** Sonnet · **Wave:** W1 · **Mode:** direct
**Goal:** a locked cube keeps the colour its piece had (Fall GDD: no change of look). GP-0 found no hue -> colour map.
**Depends:** none · **Parallel-safe with:** W1
**Files:** new `tools/asset-pipeline/sample_block_colours.gd` (`extends SceneTree`, run with `-s`), generated
`assets/data/palettes/candy_toy.json`, generated `assets/data/shapes/shape_hand_fields.json`, new `src/view/palette_table.gd`.

## Data formats
- `palettes/candy_toy.json`: `{ "set": "candy_toy", "colors": { "0": "#9a9a9a", "1": "#e8606c" } }` (hue id string -> hex)
- `shapes/shape_hand_fields.json`: `{ "i": { "hue": 1, "family": "", "motif": "" } }` (one entry per shape id)

## Tool behaviour
- For each `res://assets/models/blocks/candy_toy/blk_candy_toy_<shape>.glb` (sorted by shape id, skip `_cube`): instantiate, take the first
  `MeshInstance3D`, `get_active_material(0)`, read `albedo_color`, round to 8-bit hex.
- Distinct colours get hue ids 1, 2, ... in first-seen order; hue 0 = the `blk_candy_toy_cube.glb` colour (neutral starter).
- `family`/`motif` stay `""` (hand-filled later). Print a WARNING (no fail) if a saturated hue is within 25 deg of 186 or 322 (reserved buff/debuff hues).
- Deterministic and re-runnable; the generated files are kept.

## API
```gdscript
class_name PaletteTable extends RefCounted
## Hue id -> Color for one block set. Usage: PaletteTable.from_dict(d).color(3)
static func from_dict(d: Dictionary) -> PaletteTable
func color(hue: int) -> Color          ## unknown hue -> hue 0 colour; empty table -> Color.MAGENTA (visible bug)
func size() -> int
func errors() -> PackedStringArray     ## "colors.<k>: bad hex '<v>'", "colors.<k>: id not an int"
```

## Expected results (no tests)
User rule 2026-10-10: NO TESTS. Do not write test files. These are the expected results: the integrator checks them in the editor (godot-ai script eval or a scratch script, read with `logs_read`) after moving the file in.
1. `test_parses_hex` — `{"colors":{"0":"#000000","2":"#ff0000"}}`: `color(2) == Color(1,0,0)`, `size() == 2`.
2. `test_unknown_hue_falls_back` — `color(9) == color(0)`.
3. `test_bad_hex_errors` — `{"colors":{"1":"#zz"}}` -> one error naming `colors.1`.
4. `test_real_candy_palette` — read `palettes/candy_toy.json` (JsonReader): no errors, `size() >= 2`; every `hue` in `shape_hand_fields.json` has a colour.

## Run
Integrator: move staged files in, rescan, `logs_read` must show no parse errors or class-name clashes, then check the cases above. No gdUnit run.

**Out of scope:** ArtSet (CH-041), neon_voxel palette (no cube GLB).
