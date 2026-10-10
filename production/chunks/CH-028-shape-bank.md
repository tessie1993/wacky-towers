# CH-028 ShapeBank resource: lookup + ids

**Story:** SHP-002
**Goal:** the container the generated `shape_bank.tres` holds (ADR-0003; implementation-plan §1.2).
**Depends:** CH-020
**Parallel-safe with:** CH-026, CH-027, CH-029 … CH-036
**Files:** `src/core/shapes/shape_bank.gd` (new), `tests/unit/shapes/shape_bank_test.gd` (new)

## API

```gdscript
class_name ShapeBank extends Resource
## All piece shapes, loaded once from res://assets/data/shapes/shape_bank.tres (ADR-0003).
@export var shapes: Array[ShapeDef] = []

func get_shape(id: StringName) -> ShapeDef     ## null if unknown; first match wins
func has_shape(id: StringName) -> bool
func ids() -> PackedStringArray                ## in bank order
```

`get_shape`: linear scan. `# ponytail: linear scan of ~67 shapes at spawn/validate time; add a Dictionary index if a profile shows it.`

## Tests to write first

Factory `_bank(ids: Array[StringName]) -> ShapeBank` (one `ShapeDef.new()` per id with `shape_id` set).
1. `test_empty_bank` — `get_shape(&"i") == null`, `has_shape(&"i") == false`, `ids().is_empty()`.
2. `test_lookup_returns_same_instance` — bank `i, o`: `is_same(get_shape(&"o"), shapes[1])`.
3. `test_unknown_is_null` — `get_shape(&"zz") == null`.
4. `test_duplicate_first_wins` — two `&"i"` defs -> the first.
5. `test_ids_in_bank_order` — bank `t, i, o` -> `ids() == PackedStringArray(["t", "i", "o"])`.

## Run
`-a res://tests/unit/shapes` (README).

## Done when
README "Done when" + 5 tests green.
