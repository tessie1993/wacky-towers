# CH-030 BoardState layers: cached layer ordering + counters, all 6 down axes

**Story:** BRD-002
**Goal:** the abstract layer view (ADR-0002 §1 "the helper is abstract"): one cached index ordering per down axis plus per-layer counters, so no code outside BoardState ever computes `y*W*D`.
**Depends:** CH-029
**Parallel-safe with:** CH-026, CH-027, CH-028, CH-032 … CH-036
**Files:** `src/core/board/board_state.gd` (edit), `tests/unit/board_grid/board_state_layout_test.gd` (edit: append)

## API (add)

```gdscript
func get_down() -> int                      ## BoardState.Down
func down_vector() -> Vector3i
func layer_count() -> int                   ## extent along the down axis: Y -> H, X -> W, Z -> D
func layer_of(i: int) -> int                ## layer 0 = the floor end (table below)
func layer_cells(k: int) -> PackedInt32Array   ## slice of the cached ordering; ascending index inside a layer
func active_in_layer(k: int) -> int
func filled_in_layer(k: int) -> int
func layer_full(k: int) -> bool             ## active > 0 and filled == active
func full_layers() -> PackedInt32Array      ## ascending k
func _rebuild_layout() -> void              ## called at the end of _init; BRD-003's set_down/set_active call it too
```

## Behaviour

- `layer_of` (ADR-0002 §1 table, a `match` on down): Y_NEG `y`, Y_POS `H-1-y`, X_NEG `x`, X_POS `W-1-x`, Z_NEG `z`, Z_POS `D-1-z`.
- `_rebuild_layout`: bucket all i by `layer_of` -> `_layer_order` (concat of buckets 0..extent-1), `_layer_start` (extent + 1 offsets;
  every layer has N / extent cells). Rebuild counters per layer: `_layer_active` (F_ACTIVE), `_layer_filled` (F_FILLS_LAYER **and** active),
  `_layer_solid` (F_SOLID; CH-031 reads it). O(N).
- `layer_cells(k)` = `_layer_order.slice(_layer_start[k], _layer_start[k + 1])`.

## Tests to write first (append). Loop `for d in BoardState.Down.values()` where marked "6 axes".

Fixture `S = board(4, 4, 3)` (W 4, H 7, D 4, N 112) unless stated.
1. `test_layer_count_6_axes` — Y_* 7, X_* 4, Z_* 4.
2. `test_layer_cells_goldens` — Y_NEG `layer_cells(0) == [0..15]`; Y_POS `layer_cells(0) == [96..111]`;
   X_NEG `layer_cells(0)` = every index with `i % 4 == 0` (28 cells, ascending); Z_POS `layer_cells(0)` = indices with `(i / 4) % 4 == 3`.
3. `test_order_is_permutation_6_axes` — concat of all layers == a permutation of 0..N-1; each cell in slice k has `layer_of == k`.
4. `test_stepping_down_lowers_layer_6_axes` — for each cell c with `c + down_vector()` in bounds: `layer_of(index(c + down)) == layer_of(index(c)) - 1`.
5. `test_layer_full_from_contents_6_axes` — contents = every cell of `layer_cells(0)` as kind 2 (build a first board to get the list, then a second board with those contents and the same down): `layer_full(0)`, `full_layers() == [0]`, `filled_in_layer(0) == active_in_layer(0)`, `layer_full(1) == false`.
6. `test_masked_cells_do_not_block_full` — Y_NEG, mask with (0,0) masked, contents fill the other 15 cells of y 0 -> `layer_full(0)`, `active_in_layer(0) == 15`.
7. `test_empty_layer_not_full` — fresh board: `full_layers().is_empty()`.

## Run
`-a res://tests/unit/board_grid` (README).

## Done when
README "Done when" + all board_state tests green.
