# CH-003 ContentTypes + content/blocks.json (block, starter)

**Story:** BRD-001
**Goal:** the per-content-type table (slot, solid, fills_layer, glyph, hue) the board and ASCII grids read (ADR-0002 §3, implementation-plan §5).
**Depends:** none
**Parallel-safe with:** CH-001, CH-002, CH-004, CH-005
**Files:** `src/core/board/content_types.gd` (new), `assets/data/content/blocks.json` (new),
`tests/unit/board_grid/content_types_test.gd` (new)

## API (implementation-plan §1.2 + constructor)

```gdscript
class_name ContentTypes extends RefCounted
## Content-type table: what each board kind id means (ADR-0002 §3). Built from assets/data/content/*.json.

const SLOT_CELL := 0                 # ADR-0002 §3
const SLOT_OVERLAY := 1
const KIND_EMPTY := 0                # ADR-0002 §2: kind 0 = empty
const KIND_MAX := 255                # ADR-0002 §2: kind is a PackedByteArray entry
const EMPTY_GLYPH := "."             # implementation-plan §5: '.' is always empty

var errors: PackedStringArray        # filled by from_entries; empty when the table is valid

static func from_entries(entries: Array) -> ContentTypes   ## builds the table; problems go to .errors
func kind_of_glyph(glyph: String) -> int     ## -1 if unknown
func id_of(kind: int) -> StringName          ## &"" if unknown
func kind_of(id: StringName) -> int          ## -1 if unknown
func is_solid(kind: int) -> bool             ## false if unknown
func fills_layer(kind: int) -> bool          ## false if unknown
func slot(kind: int) -> int                  ## SLOT_CELL / SLOT_OVERLAY; -1 if unknown
func hue(kind: int) -> int                   ## default hue for non-piece content; 0 if unknown
func glyphs() -> String                      ## all glyphs concatenated in kind order ("legal" for AsciiGrid)
```

## Entry format (one Dictionary per type; this is the contract for `content/*.json`)

`{"id": "starter", "kind_id": 2, "glyph": "#", "slot": "cell", "solid": true, "fills_layer": true, "hue": 0, "mesh": ""}`
- `kind_id`: whole number 1..255 (JSON gives float: accept a float with no fraction).
- `glyph`: exactly 1 char, not `"."`, or `""` for kinds never written in ASCII (the piece block).
- `slot`: `"cell"` or `"overlay"`. `mesh`: string, stored but unused here (ADR-0007).

`from_entries` errors (format `"content[<index>].<field>: <problem>"`): not a Dictionary; missing/wrong-type field;
`kind_id` out of range or duplicate; duplicate `id`; duplicate non-empty glyph; glyph length/`"."`;
**`slot == "overlay"` with `solid == true`** (ADR-0002 §3: overlays are never solid); overlay with `fills_layer == true`.
A bad entry is skipped; good entries are still added.

## `assets/data/content/blocks.json`

```json
{ "types": [
  { "id": "block",   "kind_id": 1, "glyph": "",  "slot": "cell", "solid": true, "fills_layer": true, "hue": 0, "mesh": "" },
  { "id": "starter", "kind_id": 2, "glyph": "#", "slot": "cell", "solid": true, "fills_layer": true, "hue": 0, "mesh": "" }
] }
```
(kind 1 = block is fixed by ADR-0002 §2. Starter hue 0 = "none" until the palette lands; the art team sets it.)

## Tests to write first (feed Arrays directly; no file I/O)

Fixture factory `_entries()` returns the two entries above as Dictionaries (with float `kind_id` and `hue`, as JSON would give).
1. `test_lookups_for_block_and_starter` — `kind_of_glyph("#") == 2`, `kind_of(&"block") == 1`, `id_of(2) == &"starter"`,
   `is_solid(2)`, `fills_layer(1)`, `slot(2) == SLOT_CELL`, `errors.is_empty()`.
2. `test_unknown_lookups_are_neutral` — `kind_of_glyph("x") == -1`, `kind_of_glyph(".") == -1`, `id_of(99) == &""`,
   `is_solid(99) == false`, `slot(99) == -1`, `kind_of(&"nope") == -1`.
3. `test_glyphs_is_legal_string` — `glyphs() == "#"`.
4. `test_solid_overlay_rejected` — entry `{"id":"moss","kind_id":3,"glyph":"o","slot":"overlay","solid":true,"fills_layer":false,"hue":0,"mesh":""}`
   -> one error containing `"content[2]"` and `"overlay"`; `kind_of(&"moss") == -1`.
5. `test_duplicate_kind_and_glyph_rejected` — a third entry reusing kind_id 2 -> error; another reusing glyph `#` -> error.
6. `test_bad_kind_id_rejected` — kind_id `0`, `256`, `2.5`, `"2"` -> one error each.

## Run
`-a res://tests/unit/board_grid` (README).

## Done when
README "Done when" + 6 tests green; `blocks.json` is valid JSON (`JSON.parse_string` on its text is not null — check once by hand or in a test).

## Out of scope
Loading files from disk (CatalogLoader, DAT-00x). mushroom/sprout/egg/chick entries (their MDW stories).
