# CH-034 LevelData + GameCatalog containers (core/model)

**Story:** DAT-002 (part 1, pulled forward: `BoardSim._init` takes both)
**Goal:** the typed containers the sim is built from (implementation-plan §1.2 `src/core/model/`). Plain typed fields, no parsing.
**Depends:** CH-002, CH-003, CH-007, CH-012, CH-022, CH-028, CH-033 (types it names)
**Parallel-safe with:** CH-026, CH-027, CH-029 … CH-032
**Files (new):** `src/core/model/level_data.gd`, `src/core/model/game_catalog.gd`, `tests/unit/model/model_containers_test.gd`

## API (fields exactly as the plan; `##` doc per field)

```gdscript
class_name LevelData extends RefCounted
## One level, already validated and fixed-point converted (built by data/LevelLoader). Plain data.
const NO_SEED := -1
var id: StringName = &""
var biome: StringName = &""
var tier: int = 0
var schema: int = 1
var name_key: String = ""
var level_hash: String = ""
var layout_kind: StringName = &"single"
var boards: Array[BoardSpec] = []
var pieces: Dictionary = {}          # {shapes: PackedStringArray, weights: Dictionary[StringName,int], opening_set, opening_count, fixed_list, tags}
var knobs: Dictionary[StringName, Variant] = {}
var goal: Dictionary = {}
var rules: Array[Dictionary] = []    # [{id, params, layer}]
var stars: Dictionary = {}
var seed: int = NO_SEED
var story: Dictionary = {}

class_name GameCatalog extends RefCounted
## Everything trusted, loaded once at boot and injected (implementation-plan §2.1). Immutable after boot by convention.
var shapes: ShapeBank
var content: ContentTypes
var knob_defs: KnobDefs
var rule_defs: Dictionary[StringName, RuleDef] = {}
var plugins: PluginRegistry
var palette: PackedColorArray = PackedColorArray()
var limits: BoardLimits
```

Layering note for the coder: `core/model` may name `KnobDefs`, `RuleDef`, `PluginRegistry` (the plan's single whitelisted model -> rules reference). Nothing else from `rules/`.

## Tests to write first (`model_containers_test.gd`)

1. `test_level_defaults` — `LevelData.new()`: `layout_kind == &"single"`, `seed == LevelData.NO_SEED`, `boards.is_empty()`.
2. `test_level_typed_fields` — assign a `BoardSpec.new()` into `boards`; `knobs[&"fall.g0"] = 600`; read back.
3. `test_catalog_holds_parts` — `GameCatalog.new()` with `shapes = ShapeBank.new()`, `limits = BoardLimits.new()`: read back same instances.

## Run
`-a res://tests/unit/model` (README; `--import` first).

## Done when
README "Done when" + 3 tests green.
