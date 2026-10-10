# CH-027 ShapeDef.build: per-orientation tables, distinct orientations, spawn orientation

**Story:** SHP-002
**Goal:** fill a ShapeDef's geometry fields from raw pivot-relative offsets (ADR-0003 "Orientation math"; Piece Set rule 9, rule 10, F4). Used by the extractor (SHP-003) and by tests.
**Depends:** CH-026
**Parallel-safe with:** CH-028 … CH-036
**Files:** `src/core/shapes/shape_def.gd` (edit: add 1 public static), `tests/unit/shapes/shape_def_test.gd` (edit: append)

> Deviation note: the plan lists no builder; the extractor needs one and it belongs with the fields it fills.

## API (add)

```gdscript
static func build(id: StringName, offsets: PackedVector3iArray) -> ShapeDef
	## New ShapeDef with shape_id, cube_count and all geometry fields filled; hand fields left default.
	## Precondition: offsets contain the pivot (0,0,0), are face-connected and have no duplicates (SHP-003 checks).
```

## Behaviour

For o in 0..23: `r = _rotated(offsets, o)` (pivot-relative, **not** normalised):
- `offsets_by_orient[o] = r`; `min_by_orient[o]` = component-wise min of r; `bbox_by_orient[o]` = max − min + (1,1,1).
- `distinct_of[o]`: orientations whose `_normalise(r)` are equal share a class; classes numbered 0, 1, 2… in order of first appearance by o. `distinct_count` = number of classes.
- `spawn_orient` = lowest o with the smallest `bbox_by_orient[o].y` (Piece Set rule 10).
- `cube_count = offsets.size()`.

## Tests to write first (append; fixtures as CH-026, plus `BIG = 2×2×2 cube`, `MONO=[(0,0,0)]`, `I4_UP=[(0,0,0),(0,1,0),(0,2,0),(0,3,0)]`)

1. `test_distinct_counts_match_gdd_f4` — I4 3, O4 3, T4 12, TRIPOD 8, BIG 1, MONO 1, SCREW_L 12.
2. `test_i4_tables` — cube_count 4, `offsets_by_orient.size() == 24`, `offsets(0) == I4`, `bbox(0) == (4,1,1)`, `spawn_orient == 0`.
3. `test_vertical_i_spawns_lying_down` — `build(&"i", I4_UP)`: `bbox(0) == (1,4,1)`, `spawn_orient == 1`, `bbox(1) == (1,1,4)` (orientation 1 = +90° about x).
4. `test_pivot_kept_in_every_orientation` — every `offsets(o)` contains `Vector3i.ZERO`.
5. `test_min_corner_matches_offsets` — for T4 and all o: `min_corner(o)` equals the min computed in the test.
6. `test_distinct_of_is_consistent` — for T4: `distinct_of[0] == 0`, max value == `distinct_count − 1`, and `distinct_of[a] == distinct_of[b]` iff the normalised offsets are equal (check all 24×24 pairs via `canonical`-free comparison in the test: sort both shifted arrays).

## Run
`-a res://tests/unit/shapes` (README).

## Done when
README "Done when" + all shapes tests green.
