# CH-005 AsciiGrid.parse_mask

**Story:** BRD-001
**Goal:** parse a board footprint mask written as ASCII rows (ADR-0002 §6 check 4).
**Depends:** none
**Parallel-safe with:** CH-001, CH-002, CH-003, CH-004
**Files:** `src/core/board/ascii_grid.gd` (new), `tests/unit/board_grid/ascii_grid_test.gd` (new)

> Path follows the plan's BRD-001 **decision**: `core/board/ascii_grid.gd`, not `src/data/`, so layering stays
> strict. Test lives under `board_grid/` with the code (the plan's `tests/unit/data/ascii_grid_test.gd` predates that decision).

## API

```gdscript
class_name AsciiGrid extends RefCounted
## Pure parsers for ASCII grids in level data (implementation-plan §5). Row r = z, char c = x.

const ACTIVE_CHAR := "#"     # ADR-0002 §6 check 4
const MASKED_CHAR := "."

static func parse_mask(rows: Array, w: int, d: int, field: String) -> Dictionary
	## {"mask": PackedByteArray (w*d, index x + w*z, 1 = active, 0 = masked), "errors": PackedStringArray}
	## On any error "mask" is an empty PackedByteArray.
```

## Behaviour (errors, in this order; message format `"<field>...: <problem>"`)

1. `rows.size() != d` -> `"<field>: expected <d> rows, got <n>"`; return immediately.
2. Per row r: not a String -> `"<field>[r]: row must be a string"`; length != w -> `"<field>[r]: expected <w> chars, got <n>"`.
3. Per char: not `#`/`.` -> `"<field>[r][c]: bad char '<ch>' at (x=c, z=r)"`; at most one char error per row
   (first bad char) so a hostile row cannot flood the list.
- The "at least one active cell" and "A >= min_active_per_layer" checks are **not** here (BoardSpec, CH-007).

## Tests to write first (`ascii_grid_test.gd`)

1. `test_mask_all_active` — `parse_mask(["####","####","####","####"], 4, 4, "board.mask")`: 16 ones, no errors.
2. `test_mask_index_is_x_plus_w_z` — rows `["#...", "....", "...#"]`, w 4, d 3: mask[0] == 1, mask[11] == 1 (x 3, z 2), the other 10 are 0.
3. `test_mask_wrong_row_count` — 3 rows for d 4 -> 1 error containing `"board.mask"` and `"expected 4 rows"`; mask empty.
4. `test_mask_wrong_row_length` — row 1 `"###"` for w 4 -> error containing `"board.mask[1]"`.
5. `test_mask_bad_char_names_cell` — row 2 `"#x#y"` -> exactly 1 error, containing `"board.mask[2][1]"` and `"(x=1, z=2)"`.
6. `test_mask_non_string_row` — rows `["####", 5, "####", "####"]` -> error containing `"board.mask[1]"`.

## Run
`-a res://tests/unit/board_grid` (README).

## Done when
README "Done when" + 6 tests green.

## Out of scope
`parse_layers` (CH-006 adds it to this file next).
