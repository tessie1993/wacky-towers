# CH-008 BoardSpec.parse part 2: starting_contents + explicit spawn_anchor

**Story:** BRD-001
**Goal:** finish ADR-0002 §6 checks 6–7: starting contents from ASCII layers through the data-driven glyph legend, and an explicit spawn anchor.
**Depends:** CH-006 (AsciiGrid.parse_layers), CH-007 (BoardSpec.parse part 1)
**Parallel-safe with:** CH-001
**Files:** `src/core/board/board_spec.gd` (edit: add 2 private `_check_*` steps, call them from `parse`),
`tests/unit/board_grid/board_spec_parse_test.gd` (edit: append tests)

## Behaviour — run after part-1 step 4 (mask), only when steps 1–4 produced no errors

- **spawn_anchor** (replaces the part-1 default when present): Array of exactly 2 whole numbers (`_whole_int`) `[x, z]`
  -> else `"P.spawn_anchor: must be [x, z] whole numbers"`; `0 <= x < W`, `0 <= z < D` -> else
  `"P.spawn_anchor: (<x>,<z>) out of bounds (W=<W>, D=<D>)"`; active in mask -> else `"P.spawn_anchor: (<x>,<z>) is masked"`.
  When absent, the part-1 default and its check stay as they are.
- **starting_contents** (optional): `AsciiGrid.parse_layers(section, Vector3i(W, h_play, D), types.glyphs(), P + ".starting_contents")`;
  append its errors via `_add`. For each returned cell: `kind = types.kind_of_glyph(glyph)`; footprint cell `(x, z)` must be active ->
  else `"P.starting_contents: cell (<x>,<y>,<z>) is masked"`. Append `{"cell": cell, "kind": kind}` to `contents` (keep parse_layers order).
  Layer keys are bounded by `h_play` (plan §5), so contents never sit in the spawn clearance.
- Any error -> `spec == null` as before.

## Tests to write first (append)

Base dict `_meadow02()` (implementation-plan §4 example):
`{"width": 6.0, "depth": 6.0, "h_play": 10.0, "down_axis": "-y", "starting_contents": {"layers": {
"0": ["######", "#.###.", "######", "######", "####.#", "######"],
"1": ["######", "#..#..", "#.##.#", "###.##", "###..#", "######"]}}}`
1. `test_meadow02_contents` — no errors; `contents.size() == 60` (33 `#` in layer 0 + 27 in layer 1), and check
   `contents[0] == {"cell": Vector3i(0,0,0), "kind": 2}` and every kind == 2.
2. `test_contents_on_masked_cell` — 6×6 mask row 0 `".#####"` + layer `"0"` row 0 `"######"` -> error containing `"cell (0,0,0) is masked"`.
3. `test_contents_unknown_glyph_passthrough` — layer `"0"` row 0 `"#####x"` -> error containing `layers["0"][0][5]`; spec null.
4. `test_contents_layer_in_clearance_rejected` — layer key `"10"` with h_play 10 -> error containing `layers["10"]`.
5. `test_explicit_anchor` — `"spawn_anchor": [0.0, 5.0]` -> `spawn_anchor == Vector2i(0, 5)`.
6. `test_bad_anchor` — `[6, 0]` -> `"out of bounds"`; `[1]` and `[1.5, 0]` -> `"must be [x, z]"`; anchor on a masked cell -> `"is masked"`.
7. `test_explicit_anchor_overrides_masked_default` — 6×6 row 2 `"##.###"` (centre masked) + `"spawn_anchor": [0, 0]` -> no errors.

## Run
`-a res://tests/unit/board_grid` (README).

## Done when
README "Done when" + all board_spec_parse tests (14 + 7) green; `parse` itself still under 40 lines.

## Out of scope
Hue/status ids in starting contents (not expressible in the ASCII form yet); multi-board `boards[]` (layout, later).
