# MB-011 (CH-050 + CH-054)
- src/core/board/board_state.gd -> REPLACE (adds Op/Cause enums, place/remove/move, touched/take_delta, shift_layers)
- Check in editor: no parse errors in logs_read; scratch script: place a cell, take_delta() == [0,i,0]; fill layer 0 & 2,
  shift_layers([0,2]) -> layers above drop, counters (layer_full/stack_height) consistent.
- Not included (no ticket file exists; ADR-0002 beyond scope): set_status/set_overlay/set_down/set_active/get_record.

## Review (godot-specialist, 2026-10-10)
- Added the ADR-0002 §5 mutators the next tasks need: `set_status`, `set_overlay`, `set_down`, `set_active`, `get_record`
  (+ sparse `_status`/`_overlay`). Status moves with the block in `move`/`shift_layers`, is dropped on `remove`;
  overlays stay with the cell and go on `remove(.., CLEAR)`. `set_active` off removes content with `MASKED`.
- `get_record` has no per-piece table yet: shape_id/owner/tags are defaults (ponytail note in code).
- Added `Cause.RESCUE` (ADR-0002 §5 table lists it). LAYOUT delta entries no longer mark cell 0 as touched.
- Checked: shift_layers target cells are always empty (ascending order), counters stay consistent; no Node/RNG/time use.
