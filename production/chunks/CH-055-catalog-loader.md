# CH-055 CatalogLoader + CatalogResult

**MB task:** MB-024 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-049, CH-038 (palette), CH-047 (shape_bank.tres), CH-022, CH-083
**Files:** new `src/data/catalog_loader.gd`, `src/data/catalog_result.gd`

## API
```gdscript
class_name CatalogResult extends RefCounted
var catalog: GameCatalog = null
var errors: PackedStringArray = PackedStringArray()
func ok() -> bool
class_name CatalogLoader extends RefCounted
static func load_catalog(root: String = "res://assets/data") -> CatalogResult
```

## Behaviour
- Fills `GameCatalog`: `shapes` from `assets/data/shapes/shape_bank.tres` (ShapeBank), `content` from `content/blocks.json` (ContentTypes), `knob_defs` from `assets/data/knobs/*.json` via `JsonReader.read_dir` + `KnobDefs.build`, `rule_defs` from `content/` rule files (empty for now), `plugins` = `PluginRegistry.new(ProjectSettings.get_global_class_list())`, `palette` from `palettes/candy_toy.json` via `PaletteTable`, `limits` = `BoardLimits.from_dict` using the `board.*` knobs with the `board.` prefix stripped (gap 9).
- Any reader/parse error is appended to `errors`; `catalog` is still returned when it is usable, `ok()` = no errors. Never `load()` from `user://`.

## How the integrator sees it working
Editor script eval: `CatalogLoader.load_catalog()`; print `ok()`, `catalog.shapes.ids()`, `catalog.knob_defs` size, `catalog.plugins.ids(&"ClearDetector")`. Expect true, the 5+ meadow shapes, all knob files loaded, `layer`/`none` once CH-060 lands. Then `LevelLoader.load_level(meadow_01, catalog).ok()` is true.

**Out of scope: mechanics catalog (CH-075), biome loading.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
