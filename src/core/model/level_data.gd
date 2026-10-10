class_name LevelData extends RefCounted
## One level, already validated and fixed-point converted (built by data/LevelLoader). Plain data.

## Sentinel for "no fixed seed".
const NO_SEED := -1

## Level id.
var id: StringName = &""
## Biome id.
var biome: StringName = &""
## Difficulty tier within the biome.
var tier: int = 0
## Level file schema version.
var schema: int = 1
## Localisation key of the level name.
var name_key: String = ""
## Content hash of the source level file.
var level_hash: String = ""
## Board layout kind (e.g. &"single").
var layout_kind: StringName = &"single"
## Boards of this level.
var boards: Array[BoardSpec] = []
## Piece config: {shapes: PackedStringArray, weights: Dictionary[StringName,int], opening_set, opening_count, fixed_list, tags}.
var pieces: Dictionary = {}
## Knob overrides, id -> fixed-point value.
var knobs: Dictionary[StringName, Variant] = {}
## Goal definition.
var goal: Dictionary = {}
## Active rules: [{id, params, layer}].
var rules: Array[Dictionary] = []
## Star thresholds.
var stars: Dictionary = {}
## Fixed RNG seed, or NO_SEED.
var seed: int = NO_SEED
## Story/flavour data.
var story: Dictionary = {}
