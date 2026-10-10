# CH-006 AsciiGrid.parse_layers

**Story:** BRD-001
**Goal:** parse `{"layers": {"<y>": [D rows of W chars]}}` into cells + glyphs, naming the cell on every error (implementation-plan §5).
**Depends:** CH-005 (ascii_grid.gd exists)
**Parallel-safe with:** CH-001, CH-002, CH-003, CH-004, CH-007
**Files:** `src/core/board/ascii_grid.gd` (edit: add 1 public func + private helpers),
`tests/unit/board_grid/ascii_grid_test.gd` (edit: append tests)

## API (add to AsciiGrid)

```gdscript
const LAYERS_KEY := "layers"
const MAX_LAYER_KEY_LEN := 4     # a layer key longer than this is rejected before int() (hostile input)

static func parse_layers(section: Dictionary, size: Vector3i, legal: String, field: String) -> Dictionary
	## {"cells": Array[Dictionary] of {"cell": Vector3i, "glyph": String}, "errors": PackedStringArray}
	## size = (W, layer_count, D): keys must be 0..size.y-1. '.' is empty and never returned.
	## legal = allowed non-empty glyphs (ContentTypes.glyphs()).
```

## Behaviour (message format is the contract; tests match substrings)

- `section` keys other than `"layers"` -> `"<field>.<key>: unknown key"`. Missing `"layers"` or not a Dictionary ->
  `"<field>.layers: must be an object"`; return.
- Each layer key k (String): valid only if `k.length() <= MAX_LAYER_KEY_LEN`, `k.is_valid_int()`, `str(int(k)) == k`
  (no sign, no leading zero) and `0 <= int(k) < size.y`. Else `"<field>.layers[\"<k>\"]: layer must be a whole number 0..<size.y-1>"`; skip it.
- Layer value: Array of exactly `size.z` Strings, each `size.x` chars; else
  `"<field>.layers[\"<k>\"]: expected <D> rows, got <n>"` / `"<field>.layers[\"<k>\"][r]: expected <W> chars, got <n>"`.
- Each char: `.` -> skip; in `legal` -> cell `Vector3i(c, y, r)`; else (first bad char per row only)
  `"<field>.layers[\"<k>\"][r][c]: unknown glyph '<ch>' at cell (<c>,<y>,<r>)"`.
- Output order: by y ascending (sort the int keys), then r (z), then c (x). Deterministic.
- Cells are returned even when errors exist; the caller decides (BoardSpec discards on any error).

## Tests to write first (append)

Fixture: `S = Vector3i(3, 2, 2)` (W 3, 2 layers, D 2), `legal = "#m"`, `field = "board.starting_contents"`.
1. `test_layers_cells_and_order` — `{"layers": {"1": ["#..", "..m"], "0": ["...", "#.."]}}` -> cells
   `[{(0,0,1),"#"}, {(0,1,0),"#"}, {(2,1,1),"m"}]`, no errors.
2. `test_layers_empty_dict_is_ok` — `{"layers": {}}` -> no cells, no errors.
3. `test_layers_bad_keys` — keys `"2"` (out of range), `"-1"`, `"01"`, `"a"`, `"1.0"`, `"99999"` -> 6 errors, each containing `layers["<key>"]`.
4. `test_layers_wrong_rows` — `{"layers": {"0": ["###"]}}` -> error containing `"expected 2 rows"`.
5. `test_layers_unknown_glyph_names_cell` — `{"layers": {"1": ["#x#", "..."]}}` -> 1 error containing
   `layers["1"][0][1]` and `"(1,1,0)"`.
6. `test_layers_unknown_section_key_and_missing_layers` — `{"layer": {}}` -> 2 errors (`"board.starting_contents.layer: unknown key"`, `"board.starting_contents.layers: must be an object"`).

## Run
`-a res://tests/unit/board_grid` (README).

## Done when
README "Done when" + all ascii_grid tests (CH-005's and these 6) green.

## Out of scope
Turning glyphs into kinds, mask/active checks (BoardSpec, CH-008). Goal target shapes (GO03 plugin, later).
