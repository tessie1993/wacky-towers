# ADR-0002: Board Data Model

## Status

Accepted (2026-10-10, accepted by user)

## Date

2026-10-09

## Last Verified

2026-10-09

## Decision Makers

Tessa (user), godot-specialist (architecture lead), engine-programmer (author)

## Summary

Every board needs one source of truth for "what is where". It must handle board sizes that vary per level and come from untrusted player-made JSON, gravity along any of 6 directions, content that either takes a cell or overlays it, and clear rules well beyond whole layers. Decision: `BoardState` is a pure GDScript `RefCounted`. Cells are stored in flat packed arrays at a fixed world index `x + W*(z + D*y)`, with bit flags per cell and sparse dictionaries for rare data. Layers come from a cached per-axis ordering. Changes come out as a compact delta. Sizes are validated before anything is allocated.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core / Scripting |
| **Layer** | Foundation |
| **Knowledge Risk** | LOW. Packed arrays, `RefCounted`, `Dictionary` and `JSON` are stable since 4.0. One 4.x change applies: assigning a packed-array element no longer calls the property setter (`breaking-changes.md`). |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md`, `deprecated-apis.md` (typed containers), `current-best-practices.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | (1) On 4.7.2, `JSON.parse_string` returns every JSON number as `float`, including `8`. The validator assumes this; a unit test pins it. (2) Packed arrays held in `var` members are not copied on element write. They are copy-on-write values, so a write through a local alias must not split the array silently; a unit test pins this too. |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (sim purity, event list, travel direction) |
| **Enables** | Movement & Rotation with ADR-0003 offsets (uses `cast`, `can_place`), ADR-0004 (rule-twist runtime: clear and collapse strategies run on these queries), ADR-0005 (data format: level JSON `board` block validated here), ADR-0007 (rendering consumes the delta) |
| **Blocks** | Board / Grid epic; every Fall/Drop/Lock, Layer Clearing and Goals story |
| **Ordering Note** | `BoardSpec` validation and `BoardState` are the first code written. ADR-0005 decides the file layout and the location of the limits file; this ADR decides what is checked. |

## Context

### Problem Statement

Every system in the game reads or writes the board: movement, lock, clears, goals, twists, statuses, the view and the network. Since the 2026-10-09 rounds the board must support:
- level-chosen sizes (4×4 up to large boards; the GDD sets no maximum);
- gravity along ±x, ±y or ±z;
- pieces that travel in their own direction (side arrivals);
- content that is either cell-blocking or an overlay, set per content type;
- clear rules beyond whole layers: rows, colour clears, colour-connect, slice and cascade collapse;
- boards loaded from player-made JSON that cannot be trusted.

If the storage choice is wrong, every one of those systems pays for it.

### Current State

No board code exists. The GDDs (`board-grid.md`, `layer-clearing.md`) define the query contract for ±y only.

### Constraints

- GDScript only (ADR-0008). The API must be coarse and packed-array based so a C++ twin can replace it without callers changing.
- Pure sim: no nodes, signals, `await`, `Time` or global RNG (ADR-0001).
- Android mid-range phones. GDScript runs roughly 3–5× slower there than on the dev PC (estimate).
- Untrusted input: level JSON from other players (user decision, round 2).

### Requirements

- O(1) `is_free`, `get`, `layer_full`. `can_place` costs O(cells in the piece).
- Queries for rows, colour groups, connected groups, columns and casts, all bounded by the cells a change touched rather than the whole board.
- Gravity in 6 directions, set by level data and changeable by twists during Resolving.
- A per-content-type `slot` (CELL or OVERLAY), plus `solid` and `fills_layer` flags.
- One change record per resolve step, which the view, audio and network consume.
- The board validates sizes and limits before it allocates anything. Errors name the field or cell.
- Memory under 0.1 MB per board at the largest allowed size.

## Decision

### 1. Indexing: fixed world index, abstract layers

- **Cell index:** `i = x + W*(z + D*y)`, with `N = W*D*H`. The index never changes when gravity changes; data is never moved or re-laid out for a flip.
- **Down axis:** one of 6 values, `Down { X_NEG, X_POS, Y_NEG, Y_POS, Z_NEG, Z_POS }`. The default is `Y_NEG`.
- **Layers** are slices perpendicular to the down axis. Layer `0` is the "floor" end.

  | down | layer of cell | layer count (extent) |
  |---|---|---|
  | −y / +y | `y` / `H−1−y` | H |
  | −x / +x | `x` / `W−1−x` | W |
  | −z / +z | `z` / `D−1−z` | D |

- **The helper is abstract.** On every layout change (load, down-axis change, mask change) the board builds one cached ordering, `_layer_order: PackedInt32Array`. It holds all N indices sorted by layer, plus `_layer_start: PackedInt32Array` with `extent + 1` offsets. `layer_cells(k)` returns `_layer_order.slice(start[k], start[k+1])`, and `layer_of(i)` is a small `match`. **No code outside `BoardState` may compute `y*W*D` or walk a layer by hand.** This is the one rule that keeps 6-direction gravity cheap to support.
- **What strided layers cost.** For ±y a layer is one contiguous run of W·D cells. For ±z it is H runs of W cells; for ±x every cell is W apart. With the cached ordering, all layer walks become index-list walks in every direction, so query cost is the same. The real costs are:
  1. **Slice shift.** For ±y this could be a single block move per layer. For x/z it is a per-cell copy through the ordering. Both are O(cells moved). The y-only fast path is skipped (`ponytail:` add it if profiling shows `shift_layers` > 1 ms on device). Estimate: 1–3 ms in GDScript on a mid-range phone for a 1024-cell board, once per clear, not per frame.
  2. **Layout rebuild.** O(N) on each down-axis change (≤ 8192 cells, about 1–2 ms), and only during Resolving.
  3. **Cache locality.** Irrelevant at these sizes: the largest board's arrays total under 64 KB.
- **Pieces carry their own travel direction** (ADR-0001). The board never assumes "down" for movement: `cast(cells, dir)` takes any of the 6 unit directions. Side arrivals, conveyors and pushes use the same call.

### 2. Storage

Each array has N entries, indexed by `i`:

| Array | Type | Content |
|---|---|---|
| `flags` | `PackedByteArray` | bit 0 `ACTIVE` (mask), 1 `OCCUPIED` (CELL slot holds content), 2 `SOLID`, 3 `FILLS_LAYER`, 4 `HAS_STATUS`, 5 `HAS_OVERLAY`, 6 `HAS_EXTRA`, 7 reserved |
| `kind` | `PackedByteArray` | content type id in the CELL slot (0 = empty, 1 = block, 2–255 = types from the content table) |
| `color` | `PackedByteArray` | hue id from the art palette (0 = none); read by colour clears and colour-connect |
| `piece` | `PackedInt32Array` | piece instance uid (0 = none); read by chunk collapse and grouping |

Sparse dictionaries, keyed by cell index `i`; each entry exists only when the matching flag bit is set:
- `status[i]` → `{status_id, counter, rule_id}`. Block Status Effects: at most one status per block.
- `overlay[i]` → `{type_id, data}`. One overlay per cell (default; see Open Items).
- `extra[i]` → per-instance data for obstacles and objects, such as hit points.

Keyed by uid:
- `pieces[uid]` → `{shape_id, owner, tags}`. Owner and tags are stored **once per piece**, not per cell.

`get_record(i)` assembles the agreed block record `{shape_id, piece_instance_id, owner, tags, status}` on demand. Callers never see the arrays directly.

The flags cache the content type's `SOLID` and `FILLS_LAYER` values when content is written, so hot queries never look up the type table.

**Masks.** The level gives a footprint mask (W×D, ASCII in level data, per ADR-0005). It is expanded into the per-cell `ACTIVE` bit for the full height, as Board GDD rule 4 requires. Because `ACTIVE` is stored per cell, a true 3D mask later only needs a data-format change, not a model change.

**Counters.** `_layer_active[k]` and `_layer_filled[k]` count, per layer on the current axis, the active cells and the cells holding `FILLS_LAYER` content. Every write updates them, so `layer_full(k)` is `active > 0 and filled == active`. They are rebuilt in O(N) on a layout change.

**Memory.** 7 bytes per cell plus counters. At the 8192-cell hard cap that is about 60 KB, plus the sparse dictionaries.

### 3. Content types: CELL vs OVERLAY

Content types come from a data table loaded through ADR-0005 (`ContentTypes`). Each type sets:

| Field | Values | Meaning |
|---|---|---|
| `slot` | `CELL` / `OVERLAY` | CELL takes the cell's single content slot. OVERLAY sits on top and can share the cell with CELL content. |
| `solid` | bool | Blocks piece movement and placement. **OVERLAY types are never solid** (the validator rejects a solid overlay). |
| `fills_layer` | bool | Counts toward a full layer (CELL types only). |

Rules:
- `can_place` checks only `ACTIVE` and `SOLID`.
- A piece may move through non-solid CELL content (for example a coin occupying a cell). When it **locks** into such a cell, the board writes `REMOVE(i, cause=DISPLACED)` before `SET(i)`; the rule runtime's `on_enter` hook (ADR-0004) fires first and may react, for example by collecting the coin.
- Overlays stay when a block locks into their cell. They are removed when their cell is cleared, unless a hook says otherwise.

### 4. Queries (all read-only, pure)

All of them are bounded by the change, never "scan the whole board every tick":
- **Basics:** `is_free(c)`, `can_place(cells)`, `get_kind(i)`, `get_color(i)`, `get_record(i)`, `in_bounds(c)`, `index(c)`, `cell(i)`.
- **Layers:** `layer_full(k)`, `full_layers()`, `active_in_layer(k)`, `filled_in_layer(k)`, `layer_cells(k)`, `stack_height()` (the highest layer with solid content along the down axis, −1 when empty; O(extent) over the counters), `over_limit()`.
- **Lines (rows):** `line_cells(i, axis)` and `line_full(i, axis)`. A row clear checks the rows through the touched cells. With the default 8×8 board and a 4-cube piece that is at most 8 rows × 8 cells = 64 reads.
- **Groups:** `connected(seeds, by)`, with `by ∈ {COLOR, PIECE, SOLID}` and 6-neighbour connectivity. Breadth-first from the seed cells, at most N visits. A reused `_visit_stamp: PackedInt32Array` plus a generation counter avoids clearing or allocating per call. This covers colour-connect (`COLOR`), chunks (`SOLID`) and piece grouping (`PIECE`). It is enum-driven, not a `Callable` predicate, because a call per cell in GDScript is the slow part.
- **Colour clear:** `cells_of_color(hue)` scans N cells. It runs only when a colour-clear rule fires; at most 1024 reads on a default board.
- **Movement:** `cast(cells, dir) -> int` returns the free steps before contact. It drives the landing ghost, hard drop and side arrival.
- **Columns:** `column_cells(i, dir)`, used by cascade collapse.
- **Touched:** `touched() -> PackedInt32Array` lists the cells written since the last `take_delta()`. Rules start their search from these.

### 5. Mutations and the delta (events for the view)

- Mutators are called only by `BoardSim` (ADR-0001): the lock write, the resolve step, and rule writes buffered through `RuleApi` and applied at end of tick (ADR-0004, Rule-Twist GDD rule 14). **Layout mutators** (`set_down`, `set_active`) run only in Resolving or Setup; requests made while Live are queued by ADR-0004.
  - `place(i, kind, color, piece_uid)`
  - `remove(i, cause)`
  - `move(from, to)`
  - `set_status(i, rec)`
  - `set_overlay(i, rec)`
  - `shift_layers(cleared: PackedInt32Array)` (the slice-collapse primitive, Layer Clearing F1)
  - `set_down(dir)`
  - `set_active(x, z, on)`
- Each mutation appends to `_delta: PackedInt32Array` as triples `[op, a, b]`:

  | op | a | b |
  |---|---|---|
  | `SET` | cell | — |
  | `REMOVE` | cell | cause (`CLEAR`, `DISPLACED`, `DAMAGE`, `MASKED`, `TRIM`) |
  | `MOVE` | from | to |
  | `STATUS` | cell | status id or 0 |
  | `OVERLAY` | cell | type id or 0 |
  | `LAYOUT` | — | — (the view rebuilds everything) |

- `take_delta()` returns and clears the delta. `BoardSim` wraps it in one `SimEvent cells_changed {delta}` per resolve step (ADR-0001). The board itself emits no signals.
- `MOVE` is kept as its own op because the view animates settles from it. Without it, a slice shift would look like vanish-and-reappear.
- A delta is a few hundred ints at most. ADR-0009 may send it as-is.

### 6. Validation of untrusted sizes (before any allocation)

`BoardSpec.parse(data: Dictionary, limits: BoardLimits) -> BoardSpecResult`, where the result is `{spec, errors: PackedStringArray}`. `BoardState.new(spec)` accepts only a validated spec.

Checks, in order. It stops at `limits.max_errors` (default 50), so a hostile file cannot build a huge error list.
1. **Types.** Every number is a finite `float` with no fractional part, checked before `int()`. Strings, arrays and dictionaries are the expected types. Unknown keys are errors (catches typos in shared levels; format changes go through the `schema` version, ADR-0005).
2. **Hard limits** (reject; tunable defaults in `BoardLimits`, file location per ADR-0005):

   | Limit | Default | Why |
   |---|---|---|
   | width, depth | 4–24 | memory and render budget |
   | board_height (H_play + clearance) | 7–32 | memory and render budget |
   | cells N = W·D·H | ≤ 8192 | caps all per-cell work; rendering is capped separately in ADR-0007 |
   | starting_contents entries | ≤ N | |
   | piece uids in starting contents | ≤ 4096 | |

3. **Design ranges** (warn in debug builds and the editor panel, never reject): H_play 6–12, footprint per Board GDD safe ranges, and the readability check of Board F5 / Camera F2. The camera's own validator rejects anything below 20 px.
4. **Mask:** exactly D rows of W chars, only `#` and `.`; A ≥ 12 active cells per layer on the start down axis; at least one active cell.
5. **down_axis** is one of `-y +y -x +x -z +z`.
6. **starting_contents:** authored as ASCII layers `{"layers": {"<y>": [D rows of W chars]}}`; the glyph legend comes from each content type's `glyph` in the content table (`.` = empty, unknown glyph = error naming the cell); parsed into the cell list `[{cell, kind}]` held by `BoardSpec` (implementation plan §5). Each cell is in bounds and active; the type id is in the content table; there is no second CELL content in the same cell and no second overlay; hue ids are in the palette range; status ids are known.
7. **spawn_anchor** is in bounds and active.

Every error names the field and cell, for example `board.starting_contents[3]: cell (9,0,2) out of bounds (W=8)`. The game never builds a board from a spec with errors, as Board GDD AC 17 requires. The same validator runs in unit tests, debug builds and the planned editor panel.

### 7. Several boards per level: islands, lanes, tracks (lead-architect addition, 2026-10-09)

Creative direction: islands can be floating dioramas, several islands at once, tracks or lanes, varying by biome and level, all as data.
- **A board stays a box.** `BoardState` is unchanged: one W×D×H box with its own mask and down axis. Odd shapes (rings, plus shapes, lanes) are masks; disconnected or differently oriented pieces of play space are **separate boards**.
- **A level has 1..`layout.max_boards` boards** (knob, default 4; total cells across boards still capped by `max_total_cells`, default 8192). Each has an `id`, its own `BoardSpec`, and a `transform` (position and yaw in the diorama, view only; the sim never reads it).
- **Links are data:** `links: [{from: board_id, face: "+x", to: board_id, face: "-x", offset: [..]}]`. A link says what crosses a board edge: a travelling piece (track/lane hand-off), conveyor content, or nothing. Movement uses `cast()` per board; when a cast reaches a linked face, the sim asks the `LayoutKind` plugin (ADR-0004) to map the piece into the linked board. Unlinked faces are walls (or fall-off, per knob).
- **Which board receives the next piece** is the `spawn.router` slot (ADR-0004): active board (default), player choice, round robin, or following a track.
- **Goals and clears run per board**; a `GoalEvaluator` can aggregate (e.g. "fill all islands"). Deltas carry `board_id` (`SimEvent cells_changed {board_id, delta}`), so views, network and replays stay per board.
- **Validation:** each board through `BoardSpec.parse`; then the `LayoutKind` plugin validates links (faces exist, sizes match along the shared face, no link cycles that trap a piece). Errors name `boards[i].field`.
- One-board levels (all of meadow) use the short `board` form and `layout.kind = single`; no cost when unused.

### Architecture

```
 level JSON (untrusted) ─▶ BoardSpec.parse(limits) ──errors──▶ editor panel / load error
                                  │ valid spec
                                  ▼
 ADR-0004 rules ──mutate──▶ BoardState (RefCounted, pure GDScript)
 ADR-0003 movement ─query─▶   flags/kind/color/piece  (packed, x + W*(z + D*y))
                              status/overlay/extra/pieces (sparse)
                              _layer_order + counters (per down axis)
                                  │ take_delta()  [op,a,b]…
                                  ▼
                          BoardSim ─SimEvent cells_changed─▶ BoardController ─▶ BoardView (ADR-0007), audio, net
```

### Key Interfaces

```gdscript
class_name BoardState extends RefCounted
enum Down { X_NEG, X_POS, Y_NEG, Y_POS, Z_NEG, Z_POS }
enum Op { SET, REMOVE, MOVE, STATUS, OVERLAY, LAYOUT }
enum By { COLOR, PIECE, SOLID }

func _init(spec: BoardSpec, types: ContentTypes) -> void
# layout
func size() -> Vector3i
func index(c: Vector3i) -> int
func cell(i: int) -> Vector3i
func in_bounds(c: Vector3i) -> bool
func get_down() -> Down
func down_vector() -> Vector3i
func layer_count() -> int
func layer_of(i: int) -> int
func layer_cells(k: int) -> PackedInt32Array
# queries
func is_free(c: Vector3i) -> bool
func can_place(cells: Array[Vector3i]) -> bool
func cast(cells: Array[Vector3i], dir: Vector3i) -> int
func get_kind(i: int) -> int
func get_color(i: int) -> int
func get_record(i: int) -> Dictionary  # {shape_id, piece_instance_id, owner, tags, status}
func layer_full(k: int) -> bool
func full_layers() -> PackedInt32Array
func active_in_layer(k: int) -> int
func stack_height() -> int
func over_limit() -> bool
func line_cells(i: int, axis: int) -> PackedInt32Array
func line_full(i: int, axis: int) -> bool
func connected(seeds: PackedInt32Array, by: By) -> PackedInt32Array
func cells_of_color(hue: int) -> PackedInt32Array
func column_cells(i: int, dir: Vector3i) -> PackedInt32Array
func touched() -> PackedInt32Array
# mutations (Setup / Resolving only; called by ADR-0004 runtime)
func place(i: int, kind: int, hue: int, piece_uid: int) -> void
func remove(i: int, cause: int) -> void
func move(from: int, to: int) -> void
func shift_layers(cleared: PackedInt32Array) -> void
func set_status(i: int, rec: Dictionary) -> void
func set_overlay(i: int, rec: Dictionary) -> void
func set_down(d: Down) -> void
func set_active(x: int, z: int, on: bool) -> void
func take_delta() -> PackedInt32Array

class_name BoardSpec extends RefCounted
static func parse(data: Dictionary, limits: BoardLimits) -> BoardSpecResult
```

### Implementation Guidelines

- Typed GDScript throughout. No per-call allocation in `is_free`, `can_place` or `cast`. `connected` reuses its stamp array and queue.
- Doc comments with a usage example on every public method (engine code standard).
- Tests go in `tests/unit/board_grid/`, with one fixture factory per board shape. Every layer query runs under all 6 down axes, in a parameterised test.
- Keep the API at its current coarseness (packed arrays in and out) so ADR-0008's C++ twin can drop in. Do not add per-cell callbacks.

## Alternatives Considered

### Alternative 1: `Dictionary` keyed by `Vector3i`
- **Pros**: Sparse by nature; trivial to write.
- **Cons**: Roughly 10–50× slower lookups in GDScript; allocation churn; no cheap layer counters.
- **Rejection Reason**: The hot path (`can_place`, the ghost, fades) needs array speed.

### Alternative 2: One object per cell
- **Rejection Reason**: Over 1000 objects per board, garbage-collection churn, and no packed form for a C++ port.

### Alternative 3: Re-lay storage on a gravity change (keep layers contiguous)
- **Pros**: Every layer is contiguous for every axis.
- **Cons**: Coordinates change meaning after a flip, every cached index (view slots, statuses, network) must be remapped, and a flip costs a full copy.
- **Rejection Reason**: The cached `_layer_order` gives the same query cost without moving data.

### Alternative 4: ±y gravity only
- **Rejection Reason**: The user chose all 6 directions (round 2).

### Alternative 5: C++ GDExtension board now
- **Rejection Reason**: ADR-0008, no native work until a profile asks for it.

## Consequences

### Positive
- One storage scheme serves all 6 gravity directions, masks and every planned clear rule. All queries start from the touched cells.
- Pure and headless-testable; the packed API is ready for a C++ twin.
- Untrusted levels can neither crash the game nor allocate huge boards.

### Negative
- An extra layer of indirection (`layer_cells`) even for the common −y case.
- A per-cell slice shift instead of a block copy (estimated 1–3 ms per clear on a phone).
- The hard limits (24 per side, 8192 cells) add a maximum that Board GDD does not have (Safe ranges: "no maximum"). They are tunable defaults; see Open Items.

### Neutral
- Owner and tags live per piece, not per cell; `get_record` joins them.

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Code outside `BoardState` hard-codes `y` as layer | High | High (breaks x/z gravity) | Review rule; all layer tests run under 6 axes |
| `connected()` on a large board exceeds the tick budget | Low | Medium | Bounded by N ≤ 8192; device benchmark; C++ twin candidate (ADR-0008) |
| Players craft JSON that passes validation but is slow (e.g. max size with many statuses) | Medium | Low | Hard caps; status entries ≤ N; rendering caps (ADR-0007) |
| `JSON` number typing differs in 4.7.2 | Low | Medium | Pinned unit test (Verification Required) |

## Performance Implications

These are estimates for a mid-range Android phone, GDScript, on the default 8×8×16 board (1024 cells). They are measured by the device benchmark below.

| Operation | When | Estimate |
|---|---|---|
| `can_place` (4–8 cells) | per move/rotate | < 10 µs |
| `cast` for the ghost (≤ 16 steps × 8 cells) | per move/rotate | ~0.1 ms |
| Row checks from touched cells | per lock | < 0.1 ms |
| `connected(COLOR)` over 1024 cells | per lock, colour-connect levels | 2–5 ms |
| `shift_layers` (x/z axis, per cell) | per clear | 1–3 ms |
| Layout rebuild (`set_down`) | per flip | 1–2 ms |

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| CPU (frame time) | 0 | < 0.2 ms on a frame with no lock; ≤ 5 ms on a lock frame | 2 ms sim + rules per tick (ADR-0001); a lock frame may exceed it once |
| Memory | 0 | ~7 KB per default board; ≤ 64 KB at cap | 1 MB per board |
| Load Time | — | validation + allocation < 5 ms | — |

## Migration Plan

None. This is new code.

**Rollback plan**: The API is the contract; the storage behind it can change without callers noticing.

## Validation Criteria

- [ ] Board GDD acceptance criteria 1–9 and 14–18 pass as unit tests. Every layer criterion is repeated for all 6 down axes.
- [ ] Layer Clearing AC 7 (slice shift C = {2, 5}) passes under −y, +x and −z.
- [ ] A fuzz test feeds 1000 random or hostile `board` dictionaries (wrong types, NaN, huge sizes, out-of-range cells). The result is always a clean error list: no crash, and no allocation above the caps.
- [ ] A device benchmark on the reference phone records the table above. Any row more than 2× its estimate is reported to ADR-0008.
- [ ] Unit tests pin the two Verification Required items.

## GDD Requirements Addressed

| GDD Document | System | Requirement | How This ADR Satisfies It |
|-------------|--------|-------------|--------------------------|
| `design/gdd/board-grid.md` | Board / Grid | Size per level; cell mask; down axis; Empty/Block/Obstacle/Object with `solid`/`fills_layer`; query contract; invalid data fails at load naming the cell | Sections 1–4 and 6 |
| `design/gdd/board-grid.md` | Board / Grid | Down-axis flip re-indexes layers; contents do not move | Fixed world index plus re-built `_layer_order` |
| `design/gdd/layer-clearing.md` | Layer Clearing | `full_layers`, slice shift F1, cascade, chunks, `layer_cleared` events with cubes and owners | Counters, `shift_layers`, `column_cells`, `connected(SOLID)`, delta with `REMOVE(cause)` plus per-piece owner |
| `design/gdd/block-status-effects.md` | Block Status Effects | One status per block; moves with the block | Sparse `status[i]`, moved by `move` and `shift_layers` |
| `design/gdd/camera-rotate-view.md` | Camera | Cell contents for occlusion | `get_kind`, `is_free` read by the view |
| `design/gdd/level-data-definition.md` | Level Data | `board` block (width, depth, H_play, mask, down_axis, spawn_anchor, starting_contents); validation names the field | Section 6 |
| User decisions round 2 (`production/session-state/active.md`) | — | 6 gravity directions; overlay vs cell-blocking per type; untrusted shared levels; side arrivals | Sections 1, 3, 6; `cast(dir)` |

## Open Items

1. **Height limit and spawn zone for x/z gravity.** Board GDD defines `H_play` along y only. Proposed default: `limit_layer = extent_along_down − C`. Game-designer and systems-designer to confirm.
2. **Hard size caps vs. "no maximum" in Board GDD.** The caps are tunable defaults for safety with untrusted files. The GDD's Safe ranges need a line about them (owner: game-designer; not edited here).
3. **More than one overlay per cell?** The default is one. Multiple overlays mean the sparse value becomes an array; there is no model change.
4. **Non-solid CELL content when a piece locks** defaults to "displaced" (removed, `on_enter` hook first). ADR-0004 confirms the `on_enter` hook; Twist Library may still add per-type reactions.

## Related

- ADR-0001 (sim, events, travel direction), ADR-0003, ADR-0004, ADR-0005, ADR-0007, ADR-0008, ADR-0009.
- `design/gdd/board-grid.md`, `layer-clearing.md`, `block-status-effects.md`, `level-data-definition.md`.
