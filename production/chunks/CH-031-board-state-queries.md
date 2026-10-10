# CH-031 BoardState queries: is_free, can_place, cast, stack_height, over_limit

**Story:** BRD-002
**Goal:** the hot-path queries movement, ghost and top-out use (ADR-0002 §4; Board GDD AC 1–9). No allocation in `is_free`, `can_place`, `cast`.
**Depends:** CH-030
**Parallel-safe with:** CH-026, CH-027, CH-028, CH-032 … CH-036
**Files:** `src/core/board/board_state.gd` (edit), `tests/unit/board_grid/board_state_queries_test.gd` (new)

## API (add)

```gdscript
func is_free(c: Vector3i) -> bool                       ## in bounds, active, not solid
func can_place(cells: Array[Vector3i]) -> bool          ## every cell is_free (ADR-0002 §3: only ACTIVE and SOLID matter)
func cast(cells: Array[Vector3i], dir: Vector3i) -> int ## free steps along dir before any cell would leave is_free; 0 if blocked now
func stack_height() -> int                              ## highest layer holding solid content; -1 when empty
func limit_layer() -> int                               ## layer_count() - (size().y - h_play()); = h_play for ±y
func over_limit() -> bool                               ## any solid content at layer >= limit_layer()
```

## Behaviour

- `cast`: s = 0; loop: if every `c + dir * (s + 1)` is_free -> s += 1, else stop. Cap at `max(W, H, D)` steps. If the cells
  are not free at offset 0, return 0. Works for any of the 6 unit dirs (side arrivals, ADR-0001). No arrays created.
- `stack_height`: scan `_layer_solid` from the top layer down (O(extent)).
- `limit_layer` encodes ADR-0002 Open Item 1 default (`extent − C`, C = `size().y − h_play()`); comment the source.

## Tests to write first (`board_state_queries_test.gd`; `BoardFixtures`)

1. `test_is_free` — `board(4,4,3)`: `(0,0,0)` true; after contents at `(0,0,0)` kind 2 -> false; `(-1,0,0)` false; masked cell false.
2. `test_can_place` — I-piece cells `[(0,6,0),(1,6,0),(2,6,0),(3,6,0)]` true on empty board; one cell out of bounds -> false; one on a solid -> false.
3. `test_cast_down_empty_board` — piece `[(1,6,1)]`, dir `(0,-1,0)` -> 6.
4. `test_cast_stops_on_content` — contents `(1,0,1)` kind 2 -> same cast == 5.
5. `test_cast_side_dir` — `[(0,3,0)]`, dir `(1,0,0)` -> 3; dir `(-1,0,0)` -> 0.
6. `test_cast_blocked_now_is_zero` — cell already on a solid -> 0.
7. `test_cast_respects_mask` — mask (2,·,0) masked: `[(0,0,0)]` dir `(1,0,0)` -> 1.
8. `test_stack_height_6_axes` — for each d: empty -> −1; contents at the cell with layer 0 and one at layer 2 (pick cells via `layer_cells`) -> 2.
9. `test_limit_and_over_limit` — `board(4,4,3)` Y_NEG: `limit_layer() == 3`; contents at y 2 -> `over_limit() == false`;
   at y 3 -> true (build contents directly in the fixture spec; the trusted fixture may place above h_play).
   X_NEG same board: `limit_layer() == 4 − 4 == 0` -> document in the test that x/z limits follow Open Item 1 (any solid -> over).
10. `test_no_allocation_smoke` — call `can_place` and `cast` 10 000 times in a loop (sanity only; no timing assert).

## Run
`-a res://tests/unit/board_grid` (README).

## Done when
README "Done when" + 10 tests green; BRD-002 complete.
