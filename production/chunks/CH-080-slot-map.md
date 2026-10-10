# CH-080 SlotMap (pure)

**Story:** VEW-002 (RND-04) · **Model:** Sonnet · **Wave:** W1 · **Mode:** direct
**Goal:** cell index <-> MultiMesh instance slot, dense, swap-last removal, so BoardView updates O(1) per changed cell.
**Depends:** none · **Parallel-safe with:** W1
**Files:** new `src/view/slot_map.gd`, new `tests/unit/view/slot_map_test.gd`.

## API
```gdscript
class_name SlotMap extends RefCounted
## Dense slots for filled cells. Slots 0..filled()-1 are always in use.
func reset(cell_count: int) -> void            ## empty; cell ids 0..cell_count-1 (LAYOUT delta)
func add(cell: int) -> int                     ## new slot (= old filled()); -1 if the cell is already present
func remove(cell: int) -> Vector2i             ## (freed_slot, moved_from_slot): caller copies slot y's data into x, then shrinks;
                                               ## (-1,-1) if absent; x == y when the last slot was removed
func move(from_cell: int, to_cell: int) -> int ## slot keeps its index, re-keyed; -1 if from is absent or to is present
func slot_of(cell: int) -> int                 ## -1 when empty
func cell_at(slot: int) -> int
func filled() -> int
```
Storage: `_cell_to_slot` (PackedInt32Array, -1 filled) and `_slot_to_cell` (PackedInt32Array).

## Tests first (`slot_map_test.gd`)
1. `test_add_dense` — reset(10); add 3, 7, 5 -> slots 0, 1, 2; `filled() == 3`; add 7 again -> -1.
2. `test_remove_swaps_last` — then remove(3) -> (0, 2); `slot_of(5) == 0`; `filled() == 2`.
3. `test_remove_last` — removing the cell in the last slot -> (x, x).
4. `test_remove_absent_noop` — remove(9) -> (-1,-1); filled unchanged.
5. `test_move_rekeys` — move(7, 8): `slot_of(8)` = old slot of 7; `slot_of(7) == -1`.
6. `test_inverse_holds` — a fixed list of 200 add/remove/move ops (no RNG): for every s < filled, `slot_of(cell_at(s)) == s`.
7. `test_reset_clears`.

## Run / Done when
`--import`, `-a res://tests/unit/view`. README "Done when"; 7 tests green.
**Out of scope:** MultiMesh upload (CH-056).
