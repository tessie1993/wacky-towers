# CH-161 `slice` collapse policy

**MB task:** MB-022 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-054 (`BoardState.shift_layers`), CH-060
**Files:** new `src/mechanics/clear/slice_collapse.gd`

## API
```gdscript
class_name SliceCollapse extends CollapsePolicy
const PLUGIN_ID := &"slice"
func collapse(board: BoardState, cleared: Array[ClearGroup], api: RuleApi) -> void
```

## Behaviour
- Layer Clearing rules 7-8 / F1: remove every cell of every cleared group (BoardState remove with cause CLEAR), then call `board.shift_layers(cleared_layer_indices)` so each remaining layer drops by the number of cleared layers below it, order preserved. Never creates a new full layer, never chains.
- Cleared layer indices come from the groups (`board.layer_of(cells[0])`).
- One `CELLS_CHANGED` delta is produced by BoardState itself; this class emits nothing.

## How the integrator sees it working
Editor script eval: 4x4 board, layers 0 and 2 full, one marker block on layer 1 and one on layer 3. After `collapse`: marker 1 is at layer 0, marker 3 is at layer 1, the board has no full layer, `take_delta()` is non-empty.

**Out of scope: cascade, chunks, silent rescue wipe (CH-162).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
