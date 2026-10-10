# CH-060 `layer` and `none` clear detectors

**MB task:** MB-022 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-151 (bases), CH-050 (BoardState writes, for later use)
**Files:** new `src/mechanics/clear/layer_detector.gd`, `src/mechanics/clear/none_detector.gd`

## API
```gdscript
class_name LayerDetector extends ClearDetector
const PLUGIN_ID := &"layer"
func find_clears(board: BoardState, api: RuleApi) -> Array[ClearGroup]
class_name NoneDetector extends ClearDetector
const PLUGIN_ID := &"none"
func find_clears(board: BoardState, api: RuleApi) -> Array[ClearGroup]   ## always []
```

## Behaviour
- Layer Clearing rule 4: ask `board.full_layers()` (a layer with no active cells is never full), sort bottom-up along the down axis (ascending layer index), return ONE `ClearGroup` per full layer: `cells = board.layer_cells(k)` filtered to occupied cells, `counts_as_layers = 1`.
- `none` is used by height/shape levels (clear off). Neither plugin writes the board.

## How the integrator sees it working
Editor script eval: 4x4 board, fill layers 0 and 2 completely: `LayerDetector.new().find_clears(board, null)` returns 2 groups, cell counts 16 each, group 0 is layer 0. Empty board returns []. `NoneDetector` returns [] on the full board.

**Out of scope: row/colour detectors, the clear routine (BoardSim).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
