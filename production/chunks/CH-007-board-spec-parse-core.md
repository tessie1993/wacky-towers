# CH-007 BoardSpec + BoardSpecResult: parse part 1 (types, limits, down axis, mask, default anchor)

**Story:** BRD-001
**Goal:** validate an untrusted `board` dictionary before any allocation (ADR-0002 §6 checks 1–5, 7-default). Part 2 (CH-008) adds starting contents and an explicit spawn anchor.
**Depends:** CH-002 (BoardLimits), CH-003 (ContentTypes, for the signature), CH-004 (BoardState.Down), CH-005 (AsciiGrid.parse_mask)
**Parallel-safe with:** CH-001, CH-006
**Files:** `src/core/board/board_spec.gd` (new), `src/core/board/board_spec_result.gd` (new),
`tests/unit/board_grid/board_spec_parse_test.gd` (new)

## API (implementation-plan §1.2)

```gdscript
class_name BoardSpecResult extends RefCounted
## Result of BoardSpec.parse: spec is null whenever errors is not empty.
var spec: BoardSpec = null
var errors: PackedStringArray = PackedStringArray()

class_name BoardSpec extends RefCounted
## A validated board description; BoardState is only ever built from one (ADR-0002 §6).
const KEYS_REQUIRED: Array[String] = ["width", "depth", "h_play"]
const KEYS_OPTIONAL: Array[String] = ["down_axis", "mask", "spawn_anchor", "starting_contents"]
const DEFAULT_DOWN_TOKEN := "-y"                 # ADR-0002 §1 default
const MAX_SAFE_INT := 2147483647                 # whole-number guard before int(): reject anything larger in magnitude

var size: Vector3i            # (W, h_play + limits.spawn_clearance, D)
var h_play: int
var down: int                 # BoardState.Down
var mask: PackedByteArray     # W*D footprint, index x + W*z, 1 = active
var spawn_anchor: Vector2i    # (x, z)
var contents: Array[Dictionary] = []   # [{cell: Vector3i, kind: int}] (filled in CH-008)

static func parse(data: Dictionary, limits: BoardLimits, types: ContentTypes, field_prefix: String = "board") -> BoardSpecResult
static func _whole_int(v: Variant) -> Variant    ## int, or null if v is not a whole number (bool -> null)
static func _add(errors: PackedStringArray, limits: BoardLimits, msg: String) -> void   ## no-op once errors.size() >= limits.max_errors
```

`types` is unused in part 1 (CH-008 uses it). Keep `parse` under 40 lines by splitting each step into a private static `_check_*`.

## Behaviour — steps in order; `P` = `field_prefix`. After steps 1 and 2, return at once if there are errors.

1. **Keys and types.** Key not in either list -> `"P.<key>: unknown key"`. Missing required -> `"P.<key>: required"`.
   width/depth/h_play must pass `_whole_int` -> else `"P.<key>: must be a whole number"`.
   `_whole_int`: `int` -> itself; `float` -> null unless finite, `v == floorf(v)` and `absf(v) <= MAX_SAFE_INT`, then `int(v)`; anything else (bool, String, null…) -> null.
   Optional types: down_axis String, mask Array, spawn_anchor Array, starting_contents Dictionary -> else `"P.<key>: must be a <string|array|object>"`.
2. **Hard limits** (ADR-0002 §6 table, values from `limits`): `min_side <= W, D <= max_side` -> `"P.width: <v> outside <min>..<max>"`;
   `h_play >= 1` and `min_height <= h_play + spawn_clearance <= max_height` -> `"P.h_play: board height <H> outside <min>..<max>"`;
   `W*D*H <= max_cells` -> `"P: <N> cells over the limit <max>"`. Check sides before multiplying.
3. **down_axis** (default `DEFAULT_DOWN_TOKEN`): `BoardState.down_from_token` == -1 -> `"P.down_axis: '<tok>' is not one of -x +x -y +y -z +z"`.
4. **Mask** (default: all active). `AsciiGrid.parse_mask(rows, W, D, P + ".mask")`, append its errors via `_add`.
   If it parsed: zero active -> `"P.mask: no active cell"`. Then per layer on the start down axis, active count must be `>= min_active_per_layer`:
   Y axes: count of active footprint cells; X axes: for each x, (active cells with that x) * H; Z axes: for each z, (active cells with that z) * H.
   Report only the first failing layer: `"P.mask: layer at <x|y|z>=<k> has <a> active cells, needs >= <min>"` (for Y report `y=*`).
5. **Default spawn anchor** (only when the `spawn_anchor` key is absent): `Vector2i((W - 1) / 2, (D - 1) / 2)` (footprint centre, lower cell on ties). If masked ->
   `"P.spawn_anchor: default centre (<x>,<z>) is masked; set spawn_anchor"`. (Explicit `spawn_anchor` / `starting_contents`: if present, ignore in part 1 — CH-008.)
6. No errors -> `result.spec` is filled; otherwise `spec == null`.

## Tests to write first (`board_spec_parse_test.gd`)

Factories: `_limits() -> BoardLimits.new()`, `_types() -> ContentTypes.from_entries([...block, starter...])` (as CH-003), `_ok(d) -> BoardSpecResult`.
1. `test_minimal_valid_board` — `{"width": 6.0, "depth": 6.0, "h_play": 10.0}` -> size `(6,14,6)`, h_play 10, down `Y_NEG`, mask 36 ones, anchor `(2,2)`, no errors.
2. `test_int_values_also_accepted` — same with ints.
3. `test_json_numbers_are_floats_pinned` — `JSON.parse_string('{"width": 8}')["width"]` is `TYPE_FLOAT`; that dict + depth/h_play parses OK (ADR-0002 Verification 1).
4. `test_non_whole_numbers_rejected` — width `6.5`, `"6"`, `true`, `NAN`, `INF`, `1e12` -> each an error containing `"board.width"`; spec null.
5. `test_unknown_and_missing_keys` — `{"widht": 6, "depth": 6, "h_play": 10}` -> errors contain `"board.widht: unknown key"` and `"board.width: required"`.
6. `test_size_limits` — width 3 and 25 -> `"board.width"`; h_play 2 (H 6) and 29 (H 33) -> `"board.h_play"`; 24×24 with h_play 11 (8640 cells) -> `"over the limit"`.
7. `test_down_axis` — `"+x"` -> `down == BoardState.Down.X_POS`; `"down"` -> error containing `"board.down_axis"`.
8. `test_mask_hole_ok` — 6×6, row 0 `"#####."` -> 35 active, spec OK.
9. `test_mask_all_masked` — 4×4 h_play 3, all `"...."` -> `"no active cell"`.
10. `test_min_active_y_axis` — 4×4 h_play 3, rows `"####","####","###.","...."` (11 active) -> error containing `"needs >= 12"`.
11. `test_min_active_depends_on_axis` — 4×4 h_play 3 (H 7), rows `"####",".###",".###",".###"` (13 active): down `-y` OK;
    down `-x` -> error containing `"x=0"` (1 × 7 = 7 < 12).
12. `test_default_anchor_masked` — 6×6, row 2 `"##.###"` -> error containing `"board.spawn_anchor"`.
13. `test_field_prefix_used` — prefix `"boards[1]"`, width 3 -> error starts with `"boards[1].width"`.
14. `test_error_cap` — `limits.max_errors = 3`, dict with 10 unknown keys -> `errors.size() == 3`.

## Run
`-a res://tests/unit/board_grid` (README).

## Done when
README "Done when" + 14 tests green; no method over 40 lines.

## Out of scope
starting_contents, explicit spawn_anchor (CH-008); fuzz test (CH-009); design-range warnings (ADR-0002 §6 step 3, later).
