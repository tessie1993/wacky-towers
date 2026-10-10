# CH-049 LevelLoader + LoadResult

**MB task:** MB-017 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-084 (knob additions), CH-037 (JsonNum), CH-034 (LevelData)
**Files:** new `src/data/level_loader.gd`, `src/data/load_result.gd`

## API
```gdscript
class_name LoadResult extends RefCounted
var level: LevelData = null            ## null when any error issue exists
var issues: Array[ValidationIssue] = []
func ok() -> bool                      ## level != null and no error-severity issue

class_name LevelLoader extends RefCounted
static func load_level(path: String, catalog: GameCatalog) -> LoadResult   ## JsonReader.read_file then parse_level
static func parse_level(raw: Dictionary, catalog: GameCatalog) -> LoadResult
```

## Behaviour
- Reads the schema of `src/levels/meadow/meadow_01/meadow_01.json`: `schema, id, biome, tier, name, board{width,depth,h_play,down_axis,mask?}, pieces{shapes,weights?,opening_set,opening_count}, knobs{}, goal{}, rules[], stars{t2,t3}, story{}`.
- `board` -> `BoardSpec.parse` with `catalog.limits`; its errors become `ValidationIssue.error(id, field, rule, msg)`. Set `BoardLimits.spawn_clearance` = longest extent over `pieces.shapes` (gap 1) before parsing.
- `pieces.weights`: float weights -> int copies (G3): smallest non-zero weight = 1 copy, others rounded, total capped at `spawn.bag_max_size`; missing = 1; 0 = never. Write ints into `level.pieces["weights"]` (the Spawner CH-044 contract).
- `knobs`: each key must exist in `catalog.knob_defs`; unknown = error `unknown_knob`; values via `KnobDefs.coerce`; whole numbers via `JsonNum.whole_int`.
- Unknown top-level key = warning. Missing `id`/`board`/`goal` = error. A shape id not in `catalog.shapes` = error.
- Do NOT run the F3 rule budget or plugin `validate()` (later LevelValidator).

## How the integrator sees it working
Editor script eval: `LevelLoader.load_level('res://src/levels/meadow/meadow_01/meadow_01.json', catalog)`; print `ok()`, `level.id`, `level.boards[0].size()`, `level.pieces`. Expect true, `meadow_01`, (4,4,12), no weights or all 1. Feed a dictionary with `knobs: {nope: 1}`: `ok() == false` and one `unknown_knob` issue printed.

**Out of scope: LevelValidator, migrations, rule validation, CatalogLoader (CH-055).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
