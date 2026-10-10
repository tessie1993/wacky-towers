# CH-020 ShapeDef resource: fields + per-orientation accessors

**Story:** SHP-002 (part 1, pulled forward because RUL-001's `ArrivalStyle` base names `ShapeDef`)
**Goal:** the typed resource the shape bank holds (ADR-0003 Key Interfaces). Data + 3 accessors; the builder and canonical key are SHP-002 part 2.
**Depends:** none
**Parallel-safe with:** every batch-2 ticket except CH-021
**Files:** `src/core/shapes/shape_def.gd` (new), `tests/unit/shapes/shape_def_test.gd` (new)

## API

```gdscript
class_name ShapeDef extends Resource
## One piece shape: cube offsets about the pivot for all 24 orientations (ADR-0003).
@export var shape_id: StringName = &""
@export var display_name: String = ""
@export var family: StringName = &""
@export var hue_id: int = 0                       # palette index; 0 = none
@export var motif: StringName = &""
@export var tags: PackedStringArray = PackedStringArray()
@export var cube_count: int = 0
@export var offsets_by_orient: Array[PackedVector3iArray] = []
@export var bbox_by_orient: PackedVector3iArray = PackedVector3iArray()
@export var min_by_orient: PackedVector3iArray = PackedVector3iArray()   # ADR-0003: spawn centring
@export var distinct_of: PackedInt32Array = PackedInt32Array()
@export var distinct_count: int = 0
@export var spawn_orient: int = 0

func offsets(o: int) -> PackedVector3iArray   ## offsets_by_orient[o]; empty if o out of range
func bbox(o: int) -> Vector3i                 ## bbox_by_orient[o]; Vector3i.ZERO if out of range
func min_corner(o: int) -> Vector3i           ## min_by_orient[o]; Vector3i.ZERO if out of range
```

No `_init` arguments (`.tres` loading needs a no-arg constructor). Do **not** add `canonical_key` or a builder (SHP-002 part 2).

## Tests to write first

1. `test_new_def_has_empty_defaults` — `cube_count == 0`, `offsets_by_orient.size() == 0`, `spawn_orient == 0`, `shape_id == &""`.
2. `test_accessors_return_stored_values` — set `offsets_by_orient = [PackedVector3iArray([Vector3i(0,0,0), Vector3i(1,0,0)])]`,
   `bbox_by_orient = PackedVector3iArray([Vector3i(2,1,1)])`, `min_by_orient = PackedVector3iArray([Vector3i(0,0,0)])`;
   `offsets(0)`, `bbox(0) == Vector3i(2,1,1)`, `min_corner(0) == Vector3i.ZERO`.
3. `test_accessors_out_of_range` — `offsets(-1)` / `offsets(1)` empty; `bbox(5) == Vector3i.ZERO`; `min_corner(-1) == Vector3i.ZERO`.

## Run
`-a res://tests/unit/shapes` (README).

## Done when
README "Done when" + 3 tests green.
