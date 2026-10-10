# CH-001 Orientations: 24 integer rotations, apply, turn

**Story:** SHP-001 (Orientation tables) — `docs/architecture/implementation-plan.md` Wave 1
**Goal:** the 24 proper cube rotations as integer matrices, with a fixed index order and an O(1) turn table (ADR-0003 "Orientation math").
**Depends:** none
**Parallel-safe with:** CH-002, CH-003, CH-004, CH-005
**Files:** `src/core/shapes/orientations.gd` (new), `tests/unit/shapes/orientations_table_test.gd` (new)

## API (implementation-plan §1.2, `src/core/shapes/`)

```gdscript
class_name Orientations extends RefCounted
## The 24 proper rotations of a cube as integer 3x3 matrices (ADR-0003).

const COUNT := 24                  # ADR-0003: proper rotations only (mirrors are different shapes)
enum Axis { X, Y, Z }              # world axis of a turn

static func turn(o: int, axis: Axis, dir: int) -> int     ## dir = +1 (+90 deg) or -1 (-90 deg); world-axis turn
static func apply(o: int, v: Vector3i) -> Vector3i        ## v rotated by orientation o
static func matrix(o: int) -> Array[Vector3i]             ## the 3 rows (copy); tests and tools only
```

+90 deg = counter-clockwise looking from +axis toward the origin.

## Behaviour

- Storage: `static var _rows: Array[Vector3i]` (24 × 3 rows, flat: rows of o at `3*o .. 3*o+2`) and
  `static var _turn: PackedInt32Array` (24 × 3 × 2, index `(o * 3 + axis) * 2 + (0 if dir > 0 else 1)`).
  Built once by `static func _ensure() -> void`, called first in each public method (no-op once built).
- Generators (rows), as named consts:
  - `GEN_X = [Vector3i(1,0,0), Vector3i(0,0,-1), Vector3i(0,1,0)]`  — (x,y,z) -> (x, -z, y)
  - `GEN_Y = [Vector3i(0,0,1), Vector3i(0,1,0), Vector3i(-1,0,0)]`  — (x,y,z) -> (z, y, -x)
  - `GEN_Z = [Vector3i(0,-1,0), Vector3i(1,0,0), Vector3i(0,0,1)]`  — (x,y,z) -> (-y, x, z)
- Build: BFS. List = [identity], `head = 0`. While `head < count`: `M = list[head]`; for `G` in
  `[GEN_X, GEN_Y, GEN_Z]` (this order): `N = G × M`; append `N` if not already present; `head += 1`.
  Result must be exactly 24. **This order is the contract** — indices are stable everywhere.
- `turn(o, axis, +1)` = index of `G_axis × M_o`; `turn(o, axis, -1)` = index of `transpose(G_axis) × M_o`.
  Left-multiplication = turn about the *world* axis (ADR-0003: input is mapped to a world axis first).
- `apply(o, v)`: `x' = r0.x*v.x + r0.y*v.y + r0.z*v.z`, etc. Write it out; no floats, no `Basis`.
- Out-of-range `o` / `dir` is a caller bug: document the precondition, do not validate.
- Private helpers allowed: `_mul(a, b) -> Array[Vector3i]`, `_transpose(m)`, `_index_of(m) -> int`.

## Tests to write first (`orientations_table_test.gd`)

1. `test_count_is_24_and_all_distinct` — `matrix(o)` for o in 0..23 are pairwise different.
2. `test_index_0_is_identity` — `apply(0, Vector3i(1,2,3)) == Vector3i(1,2,3)`.
3. `test_first_bfs_indices_are_generators` — `apply(1, Vector3i(0,1,0)) == Vector3i(0,0,1)`;
   `apply(2, Vector3i(1,0,0)) == Vector3i(0,0,-1)`; `apply(3, Vector3i(1,0,0)) == Vector3i(0,1,0)`.
4. `test_turn_from_identity_hits_generators` — `turn(0, Axis.X, 1) == 1`, `turn(0, Axis.Y, 1) == 2`, `turn(0, Axis.Z, 1) == 3`.
5. `test_matrices_are_signed_permutations_with_det_plus_one` — each row has exactly one non-zero entry, in {-1, 1}; det == 1.
6. `test_four_turns_return_to_start` — for all o, axis, dir in {1, -1}: turning 4 times gives o.
7. `test_pos_then_neg_is_identity` — `turn(turn(o, a, 1), a, -1) == o` for all o, a.
8. `test_apply_matches_matrix_product` — for all o, `v = Vector3i(1,2,3)`: `apply(o, v)` equals the
   product computed in the test from `matrix(o)` rows.
9. `test_turn_is_world_axis_left_multiply` — for all o, a: `apply(turn(o, a, 1), v) == apply(turn(0, a, 1), apply(o, v))`.

## Run
`-a res://tests/unit/shapes` (README).

## Done when
README "Done when" + all 9 tests green.

## Out of scope
ShapeDef, ShapeBank, canonical key (SHP-002, Wave 2). View-relative input mapping (later).
