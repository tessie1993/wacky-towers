# CH-029 BoardState storage: packed arrays, index math, mask, starting contents

**Story:** BRD-002
**Goal:** allocate the board from a validated spec and expose cell-level reads (ADR-0002 §1–§3).
**Depends:** CH-004 (board_state.gd stub), CH-007 (BoardSpec fields), CH-003 (ContentTypes)
**Parallel-safe with:** CH-026, CH-027, CH-028, CH-032 … CH-036
**Files:** `src/core/board/board_state.gd` (edit: keep the Down helpers, add storage), `tests/unit/board_grid/board_fixtures.gd` (new),
`tests/unit/board_grid/board_state_layout_test.gd` (new)

## API (add to BoardState; ADR-0002 Key Interfaces + plan §1.2)

```gdscript
const F_ACTIVE := 1        # ADR-0002 §2 flag bits
const F_OCCUPIED := 2
const F_SOLID := 4
const F_FILLS_LAYER := 8
const F_HAS_STATUS := 16
const F_HAS_OVERLAY := 32
const F_HAS_EXTRA := 64

func _init(spec: BoardSpec, types: ContentTypes) -> void
func size() -> Vector3i                    ## (W, H, D) = spec.size
func h_play() -> int
func index(c: Vector3i) -> int             ## c.x + W * (c.z + D * c.y)
func cell(i: int) -> Vector3i              ## x = i % W, z = (i / W) % D, y = i / (W * D)
func in_bounds(c: Vector3i) -> bool
func is_active(i: int) -> bool
func get_kind(i: int) -> int
func get_color(i: int) -> int
func active_cell_count() -> int            ## needed by BoardView (ADR-0007)
```

Private storage: `_flags`, `_kind`, `_color: PackedByteArray`, `_piece: PackedInt32Array` (N each), `_types: ContentTypes`, `_spec_down: int`.

## Behaviour

- `_init`: N = W·H·D, `resize` the four arrays (zero-filled). Mask expansion (Board GDD rule 4): for every y, cell (x, y, z) gets
  `F_ACTIVE` iff `spec.mask[x + W*z] == 1`; an **empty** `spec.mask` means all active.
- Then each `spec.contents` entry `{cell, kind}`: `i = index(cell)`; `_kind[i] = kind`; `_color[i] = types.hue(kind)`;
  flags `F_OCCUPIED`, plus `F_SOLID` if `types.is_solid(kind)`, plus `F_FILLS_LAYER` if `types.fills_layer(kind)` (ADR-0002: flags cache the type).
  Overlay-slot kinds: skip with `# ponytail: overlay contents land with BRD-003 set_overlay; no overlay types in Meadow yet`.
- `active_cell_count` counts once at `_init` (cache it); `CH-030` keeps it right when layout changes.
- Out-of-range `i` in getters is a caller bug (document; no checks — hot path).

## Fixture `board_fixtures.gd` (shared by CH-030/031 tests)

```gdscript
class_name BoardFixtures extends RefCounted
## Test-only factories for BoardState tests.
static func types() -> ContentTypes          # block (kind 1) + starter (kind 2, glyph "#") exactly as assets/data/content/blocks.json
static func spec(w: int, d: int, h_play: int, down: int = BoardState.Down.Y_NEG,
		contents: Array[Dictionary] = [], mask: PackedByteArray = PackedByteArray()) -> BoardSpec
	# builds BoardSpec.new() directly (trusted): size = (w, h_play + BoardLimits.DEFAULT_SPAWN_CLEARANCE, d)
static func board(w: int, d: int, h_play: int, down: int = BoardState.Down.Y_NEG,
		contents: Array[Dictionary] = [], mask: PackedByteArray = PackedByteArray()) -> BoardState
```

## Tests to write first (`board_state_layout_test.gd`)

1. `test_size_and_count` — `board(4, 5, 3)`: `size() == (4, 7, 5)`, `h_play() == 3`, `active_cell_count() == 140`.
2. `test_index_formula` — on `board(4,4,3)` (W 4, D 4): `index((1,2,3)) == 1 + 4*(3 + 4*2) == 45`; `cell(45) == (1,2,3)`; round-trip all i.
3. `test_in_bounds` — `(0,0,0)`, `(3,6,3)` true; `(-1,0,0)`, `(4,0,0)`, `(0,7,0)`, `(0,0,4)` false.
4. `test_mask_expands_full_height` — 4×4 mask with `(x 0, z 0)` masked: `is_active(index((0,y,0)))` false for every y 0..6; `active_cell_count() == 15 * 7`.
5. `test_starting_contents_written` — contents `[{cell:(1,0,2), kind:2}]`: `get_kind == 2`, `get_color == types().hue(2)`; neighbours kind 0.
6. `test_empty_cells_are_zero` — fresh board: every `get_kind(i) == 0`, `get_color(i) == 0`.

## Run
`-a res://tests/unit/board_grid` (README).

## Done when
README "Done when" + 6 tests green; the CH-004 down tests still green.
