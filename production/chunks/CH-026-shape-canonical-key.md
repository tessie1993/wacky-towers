# CH-026 ShapeDef.canonical_key (+ private rotate/normalise helpers)

**Story:** SHP-002
**Goal:** a rotation- and translation-invariant key per shape; mirrors differ (ADR-0003 "Canonical form"; Piece Set rule 4).
**Depends:** CH-001 (Orientations), CH-020 (shape_def.gd exists)
**Parallel-safe with:** CH-028 … CH-036 except CH-027
**Files:** `src/core/shapes/shape_def.gd` (edit: add 1 public static + 3 private statics), `tests/unit/shapes/shape_canonical_test.gd` (new)

## API (add to ShapeDef)

```gdscript
static func canonical_key(offsets: Array[Vector3i]) -> String
	## Same string for any rotation or translation of the shape; mirror images differ.
static func _rotated(offsets: Array[Vector3i], o: int) -> Array[Vector3i]     ## Orientations.apply per offset, about the pivot, order kept
static func _normalise(offsets: Array[Vector3i]) -> Array[Vector3i]   ## new array: min corner moved to (0,0,0), sorted (x, then y, then z)
static func _serialise(normalised: Array[Vector3i]) -> String             ## "x,y,z;" per cube, concatenated
```

## Behaviour

- `canonical_key`: smallest (String `<`) of `_serialise(_normalise(_rotated(offsets, o)))` over o in `0 ..< Orientations.COUNT`.
- `_normalise`: subtract the component-wise min, then sort. `Array[Vector3i]` copy, then `sort()` (Vector3i compares x, then y, then z). Never mutates its input.
- Empty offsets -> `""`.

## Tests to write first (`shape_canonical_test.gd`)

Fixtures (`Array[Vector3i]`; Godot 4.7 has no packed Vector3i array):
`I4=[(0,0,0),(1,0,0),(2,0,0),(3,0,0)]`, `O4=[(0,0,0),(1,0,0),(0,0,1),(1,0,1)]`, `T4=[(0,0,0),(1,0,0),(2,0,0),(1,0,1)]`,
`TRIPOD=[(0,0,0),(1,0,0),(0,1,0),(0,0,1)]`, `SCREW_L=[(0,0,0),(1,0,0),(1,1,0),(1,1,1)]`, `SCREW_R=[(0,0,0),(-1,0,0),(-1,1,0),(-1,1,1)]`,
`L4=[(0,0,0),(1,0,0),(2,0,0),(2,1,0)]`, `J4=[(0,0,0),(-1,0,0),(-2,0,0),(-2,1,0)]`.
1. `test_i4_key_golden` — `canonical_key(I4) == "0,0,0;0,0,1;0,0,2;0,0,3;"`.
2. `test_key_invariant_under_all_rotations` — for I4, O4, T4, TRIPOD, SCREW_L and each o: rotate every offset with `Orientations.apply(o, v)` in the test, key unchanged.
3. `test_key_invariant_under_translation` — every fixture shifted by `(5,-3,2)` keeps its key.
4. `test_screw_mirrors_differ` — `SCREW_L` != `SCREW_R`.
5. `test_flat_mirrors_equal_in_3d` — `L4` == `J4` (a flat piece's mirror is a 3D rotation; if a block set ships flat left/right pairs, SHP-003's duplicate check rejects them — report, don't "fix").
6. `test_different_shapes_differ` — I4, O4, T4, TRIPOD, SCREW_L pairwise different.
7. `test_empty_is_empty_string` — `canonical_key([]) == ""`.

## Run
`-a res://tests/unit/shapes` (README).

## Done when
README "Done when" + 7 tests green (and CH-020's tests still green).
