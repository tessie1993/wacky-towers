# Board / Grid

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: The Block Is the Constant; Readable Chaos

## Summary

The Board / Grid is the shared 3D arena: a footprint of cells (default an 8 × 8 square platform) stacked to a height limit (default 12 playable layers plus a spawn zone as tall as the longest piece, 4 by default). It stores what every cell holds — empty, block, obstacle or object — answers placement and layer-full questions for every other system, and reports when the stack goes over the limit, leaving the consequence to the mode. Levels can change its size and shape with a cell mask, and twists can change its "down" direction, always through the Rule-Twist Framework.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `None`

## Overview

The Board / Grid is the 3D space every piece lands in: a footprint of cells (width × depth) stacked up to a height limit, where each cell is either empty, inactive (switched off for this level), or holding a block, obstacle or object. It is the single source of truth for "what is where" — movement, dropping, clearing, goals, twists and obstacles all read and change it, and none of them keep their own copy. To the player it is the floating-island platform from the art bible: by default a **square platform**, sized per level type, with the layer-clearing default set to 8 × 8 × 12 (user decision, checked against the board-size math in Formulas). Levels may change the size and shape (an L-shaped island, holes, pillars) through a cell mask. The board also tracks the **height limit** and reports when a block sits above it; what that means is the mode's call, defaulting to a loss. Without this system there is no shared arena — and Pillar 1, *The Block Is the Constant*, needs every mode, twist and minigame to stand on the same kind of board. Like the rest of the design docs, every value here is a starting default.

## Detailed Design

### Core Rules

**Space and coordinates**
1. The board is a 3D grid of unit cells addressed as `(x, y, z)`: `x` = width, `z` = depth (together the **footprint**), `y` = height, with `y = 0` the floor layer.
2. Size is set per level: `board_width × board_depth × board_height`. Each level type has a default; the **layer-clearing default** comes from the board-size math in Formulas. With no level override, the footprint is square (`board_width = board_depth`).
3. "Down" is `-y` by default. The board stores a **down axis** that the Rule-Twist Framework may change (e.g. a gravity-flip twist); "layer" always means a slice perpendicular to the current down axis. The board itself never moves anything — it only reports and stores.

**Cell mask (shape)**
4. Every footprint position is **active** or **inactive**. The default mask is all-active (a square platform). A level may switch positions off to make other shapes (L-shape, holes, ring). Inactive positions are inactive for the full height: nothing can enter them and they are drawn as empty space or island edge.
5. The mask is fixed for the whole level unless a twist or level-specific mechanic explicitly changes it (through the Rule-Twist Framework).

**Cell contents**
6. Each active cell holds exactly one of:
   - **Empty**
   - **Block** — a locked piece cube: piece type ID, owner (player, for versus), and any status effect.
   - **Obstacle** — a non-player block or object placed by the level or a twist (designed in Obstacles).
   - **Object** — a living or interactive thing occupying a cell (designed in Twist Library / Level-Specific Mechanics).
7. Every content carries two flags the board reads: `solid` (blocks movement, default true) and `fills_layer` (counts toward a full layer; true for blocks, set per type for obstacles and objects).
8. The falling (active) piece is **not** stored in the grid until it locks; Movement & Rotation asks the board whether its target cells are free.

**Layers and height limit**
9. A layer is **full** when every active cell in it holds content with `fills_layer = true`. The board reports full layers; Layer Clearing decides what happens to them.
10. The **height limit** is a layer index (default `H_play` = `board_height − spawn_clearance`, see Formulas F4). After every lock, the board reports **over limit** if any solid content sits at or above it. The current mode decides the result; the default is one warning (a rescue wipe), then a loss (Level Goals & Fail States).
11. The **spawn zone** is the space above the height limit where new pieces appear. It is part of the board's coordinate space but blocks never lock there in normal play (see Edge Cases).

**Queries the board answers** (the contract every other system uses)
- `is_free(cell)` — active, empty, inside bounds.
- `can_place(cells[])` — all cells free.
- `get(cell)` / `set(cell, content)` / `clear(cell)`.
- `layer_full(y)`, `full_layers()`, `stack_height()` (highest occupied layer; **−1 on an empty board**), `over_limit()`.
- `active_cells_in_layer(y)` — the number of cells layer `y` needs to be full (layers can differ under a mask or after a down-axis flip).

### States and Transitions

The board itself has few states; game flow lives in Level Goals & Fail States.

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **Setup** | Size, mask, down axis and starting content (obstacles, pre-placed blocks) are loaded from Level Data | Level starts | Setup finishes → Live |
| **Live** | Pieces can be tested, locked and cleared | Setup done; or after a clear resolves | A lock or clear is resolving → Resolving; the mode ends → Frozen |
| **Resolving** | Contents are changing after a lock (clears, collapses, twist effects); no new piece can lock | A piece locks or a twist changes contents | All changes done → Live |
| **Frozen** | Read-only; nothing changes | The mode ends (win, loss, round over) or the game is paused | Unpause → Live; next level → Setup |

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Level Data & Definition | → Board | Size, mask, down axis, height limit override, starting contents |
| Camera & Rotate-View | Board → | Size and mask, so the camera can frame the board |
| Movement & Rotation | ↔ | Asks `can_place`; never writes |
| Fall, Drop & Lock | → Board | Writes the locked piece's cubes as Block contents |
| Layer Clearing | ↔ | Reads `full_layers()`; clears and collapses cells |
| Level Goals & Fail States | Board → | `stack_height()`, `over_limit()`, layer counts |
| Rule-Twist Framework | ↔ | May change the down axis, mask or contents; all twist changes go through the framework, not direct writes |
| Obstacles, Block Status Effects, Physics Mode | ↔ | Write and read contents and flags (via the framework) |
| HUD, Game Feel & VFX | Board → | Height limit position, stack height, cell changes for effects |

## Formulas

All values are starting defaults to tune by prototype and simulation. Height is the `y` axis (see Core Rules).

**Default layer-clearing board (user decision 2026-10-09): 8 × 8 footprint, 12 playable layers, 4-layer spawn clearance (16 layers drawn).** The board-size math first recommended 4 × 4 × 8 for the fastest clears and largest cubes; the user chose 8 × 8 × 12 so big Special pieces (up to 8 cubes, see Piece Set) fit and play is more strategic. Consequences accepted with that choice: about 21 pieces per layer clear and cubes at about 28 px, right on the readability target. Smaller boards (4 × 4 to 6 × 6) remain per-level overrides for tutorials, fast modes and early tiers.

### F1. Active cells per layer

The active_cells formula is defined as:

`A = |mask|` (equals `W × D` when no cells are masked off)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| W, D | int | 4–8 | data file | Footprint width and depth (bounding box) |
| mask | set of footprint cells | A ≥ 12 | data file | Active footprint cells; default all |
| A | int | 12–64 | calculated | Cells a layer needs to be full |

**Output Range:** 12 to 64 under the safe ranges; default 64.
**Example:** 8 × 8, no mask → A = 64. A 5 × 5 with a 2 × 2 corner removed → A = 21.

### F2. Pieces per layer clear

The pieces_per_clear formula is defined as:

`P = A / c` and `P_eff = P / η`; a perfect clear is possible when `(A × k) mod c = 0` for some small number of layers k.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| A | int | 12–64 | calculated (F1) | Active cells per layer |
| c | float | 1–8 | calculated (Piece Set) | Mean cubes per piece for the level's piece set; ≈ 4 for tetracubes |
| η | float | 0.6–0.9 | constant (tuning) | Packing efficiency — share of placed cubes that end up in completed layers. **Placeholder; measure by bot simulation per footprint and piece set** |
| P_eff | float | 3–30 | calculated | Expected pieces placed per layer clear |

**Output Range:** about 3 (trivial) to 30 (very slow). Default board ≈ 21.
**Example:** A = 64, c = 4, η = 0.75 → P = 16, P_eff ≈ 21.3 pieces per clear. Big Special pieces raise c and lower P_eff (c = 5 → ≈ 17).
**Parity:** with c = 4, footprints of 16, 36 or 64 cells divide cleanly every layer; mixed piece sizes (Helpers, Special) make parity irrelevant.

### F3. Board capacity

The board_capacity formula is defined as:

`K = A × H_play`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| A | int | 12–64 | calculated (F1) | Active cells per layer |
| H_play | int | 6–12 | data file | Playable layers below the height limit |
| K | int | 72–768 | calculated | Total playable cells |

**Output Range:** 72 to 768; default 768.
**Example:** 64 × 12 = 768 cells ≈ 192 tetracubes of room before topping out.

### F4. Height limit and spawn clearance

The board_height formula is defined as:

`board_height = H_play + C`, with `C = L_max` of the level's piece set; height limit = layer index `H_play`; **over limit** when any solid content has `y ≥ H_play`; a spawn is blocked only when the new piece's spawn cells are occupied (see Edge Cases) — over limit and spawn blocked are separate reports.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| H_play | int | 6–12 | data file | Playable layers |
| L_max | int | 1–8 | calculated (Piece Set) | Longest piece extent in the level's piece set; default cap 4 |
| C | int | = L_max | calculated | Spawn clearance, so a new piece fits in any rotation |
| board_height | int | 7–20 | calculated | Layers drawn, including the spawn zone |

**Output Range:** 7 to 20 layers drawn; default 16.
**Example:** H_play = 12, L_max = 4 → C = 4, board_height = 16; a block locking at y = 12 reports over limit.

### F5. On-screen cube size (readability check)

The cube_size formula is defined as:

`a = min( f × S_h / (n + board_height), g × S_w / (2n) )`, where `n = (W + D) / 2`

Projection assumption: fixed 2:1 dimetric camera — a cell's top face is a diamond `2a` wide and `a` tall, the vertical edge is `a`. Rotate-view only swaps W and D.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| S_h, S_w | int | 1170, 2532 | constant | Reference phone screen height and width in px (6.1", landscape) |
| f | float | 0.55–0.60 | constant | Share of screen height the board gets |
| g | float | ~0.45 | constant | Share of screen width the board gets. **Placeholder until HUD layout is set** |
| n | float | 4–8 | calculated | Mean footprint side |
| board_height | int | 7–20 | calculated (F4) | Layers drawn |
| a | float | ≥ 20 | calculated | Cube edge on screen, px |

**Output Range:** about 24–45 px within the safe ranges; must stay ≥ 20 px (art bible). Design target: `n + board_height ≤ 24`, which keeps a ≥ 28 px; the default board sits exactly on it.
**Example:** 8 × 8, board_height 16: 0.575 × 1170 = 670 px; 670 / (8 + 16) ≈ 28 px. Width check: 2 × 28 × 8 = 448 px, inside the ~1140 px width budget. A level using pieces longer than 4 (C = 5+) on the default board drops below 28 px and needs a device check.

### Footprint comparison (source of the default)

| Footprint (12 playable) | P_eff (η = 0.75, c = 4) | Cube size | Notes |
|---|---|---|---|
| 4×4 | 5.3 | ~36 px | Fastest clears; only small Special pieces fit. Good for tutorials and fast modes |
| 5×5 | 8.3 | ~34 px | Parity every 4 layers with tetracubes |
| 6×6 | 12 | ~32 px | Middle ground |
| **8×8** | **21.3** | **~28 px** | **Default (user choice).** Room for big Special pieces; slow, strategic clears; more cells hidden behind the stack, so camera and ghost aids matter |

### Safe ranges for per-level overrides

- Footprint bounding box: 4–8 per side; masked layers need A ≥ 12, and every active region must fit the level's longest piece.
- Playable height: 6–12.
- Readability: `n + board_height ≤ 24` as the target; below 28 px needs a device check, below 20 px is not allowed.
- Spawn clearance: C = L_max of the level's piece set. Only a mode may reduce it.

## Edge Cases

- **If a layer has zero active cells** (the mask removes a whole level, e.g. a ring footprint seen from a flipped down axis): it can never be full; `layer_full` returns false for it and goals skip it.
- **If a piece locks partly inside the spawn zone** (above the height limit): it locks normally and the board reports **over limit**; the mode decides (default: loss). Pieces are never silently deleted.
- **If a new piece cannot spawn because its spawn cells are occupied**: the board reports **spawn blocked**; this is treated the same as over limit (mode decides; default one warning, then loss).
- **If a twist flips the down axis**: layers are re-indexed along the new axis (for a flip to `+y`: `y' = board_height − 1 − y`), and `over_limit` and the spawn zone are checked against `y'`, so they move to the new "top". Contents do not move by themselves — whether they fall is the twist's rule.
- **If a twist or level mechanic switches off a cell that holds content**: the content is removed first (as a clear, so effects and scoring still fire), then the cell becomes inactive. A twist may instead refuse to switch off occupied cells; the twist's GDD says which.
- **If a twist switches an inactive cell back on**: it becomes active and empty; any layer it belongs to now needs one more cell to be full.
- **If an obstacle has `fills_layer = false`**: a layer containing it can never be full while it is there; this is intended (it's what makes the obstacle an obstacle) and Obstacle Clearing must provide a way to remove it.
- **If two systems try to write the same cell in the same resolve step**: the Rule-Twist Framework's priority order decides; the board applies writes in that order and the last write wins. Direct writes outside the framework are not allowed.
- **If a level's data is invalid** — starting content in an inactive cell or out of bounds, a layer with fewer than 12 active cells (A < 12), or an active region the straight piece cannot fit in — the level fails validation at load time and the error names the cell or rule; the game never starts a level with invalid board data.
- **If the board is resized or re-masked mid-level** (only via a twist or level mechanic): the change happens during Resolving, never while a piece is locking.
- **If the falling piece overlaps a cell that a twist just filled**: Movement & Rotation pushes the piece up to the nearest free position; if none exists, it's treated as spawn blocked.

## Dependencies

**Upstream (this system depends on):** none — Board / Grid is a Foundation system. Its configuration arrives from Level Data & Definition at load time, but the board works with defaults when no level data is given (soft dependency).

**Downstream (depend on this system):**

| System | Hard / soft | Interface |
|---|---|---|
| Camera & Rotate-View | Hard | Size, mask |
| Movement & Rotation | Hard | `can_place`, `is_free` |
| Fall, Drop & Lock | Hard | `set` for locked cubes |
| Layer Clearing | Hard | `full_layers`, `clear` |
| Level Goals & Fail States | Hard | `stack_height`, `over_limit`, spawn blocked |
| Rule-Twist Framework | Hard | Down axis, mask, contents (only writer for twist changes) |
| Level Data & Definition | Hard | Supplies size, mask, starting contents |
| Obstacles, Obstacle Clearing, Block Status Effects | Hard | Contents and flags |
| Physics Mode | Soft | May replace grid-locked placement with physics but still uses the footprint and height limit |
| Tournament Minigames | Soft | Use the board with their own sizes and rules |
| HUD, Game Feel & VFX | Soft | Height limit, stack height, cell change events |

None of these have GDDs yet; each must list Board / Grid as a dependency when written.

## Visual/Audio Requirements

Follows the art bible; nothing here overrides it.
- The board is the top of a floating-island diorama (art bible §6): flat tiles about 1/5 of a cube high with grid lines, matte and painterly, never glossy or block-like (§3).
- Inactive (masked) cells read as island edge or empty air, never as tiles.
- The height limit is drawn as the danger line (art bible §2, §4.3): steady when the stack is low, pulsing danger red as it nears the limit.
- The spawn zone is not drawn as a container; the falling piece and its landing ghost are what mark it (art bible §3 eye order).
- No sound is owned by the board; lock, clear and over-limit sounds belong to Fall/Drop/Lock, Layer Clearing and Goals.

## Game Feel

The board should feel like a solid, tidy toy tray: the player always knows which cells are free. Targets: cube edge at least 28 px on the reference phone (F5); cube edge about 28 px at the default 8 × 8 size, with the landing ghost and rotate-view making every free cell findable; the danger line visible from both rotate-view angles.

## UI Requirements

The board exposes `stack_height()`, the height limit and `over_limit()` for the HUD (danger line, optional height meter). No other UI. Layout is owned by HUD and `/ux-design`.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/art/art-bible.md` §2, §3, §4.3, §6 | Tile look, danger line, readability floor (20 px), island diorama |
| `design/gdd/game-concept.md` | Pillars, mobile target, fixed angled camera with rotate-view |
| `design/gdd/systems-index.md` | Downstream systems listed in Dependencies |
| `design/gdd/piece-set.md` | `c` (mean cubes per piece) and `L_max` (longest piece extent) in F2 and F4 |

## Acceptance Criteria

Defaults unless stated: 8 × 8 footprint, H_play 12, C 4, board_height 16, A = 64. **[U]** = automated unit test (`tests/unit/board_grid/`), **[M]** = manual or device check.

**Core rules**
1. [U] **GIVEN** no level data, **WHEN** a board is created, **THEN** it is 8 × 8 × 16, every footprint cell is active, the down axis is −y, `y = 0` is the floor, and `stack_height()` returns −1.
2. [U] **GIVEN** footprint cell (1,1) is masked off, **WHEN** `is_free(1, y, 1)` is called for y = 0–15, **THEN** every call returns false and `set` on those cells is rejected.
3. [U] **GIVEN** an empty active cell, **WHEN** a Block is set there, **THEN** `get` returns it with piece ID, owner, `solid = true`, `fills_layer = true`, and nothing else in that cell.
4. [U] **GIVEN** 63 of 64 cells in layer 0 hold Blocks, **WHEN** the 64th is filled, **THEN** `layer_full(0)` goes from false to true and `full_layers()` returns [0].
5. [U] **GIVEN** a Block locks at y = 11, **THEN** `over_limit()` is false; **GIVEN** it locks at y = 12, **THEN** `over_limit()` is true.
6. [U] **GIVEN** a lock at y = 13 (spawn zone), **WHEN** it resolves, **THEN** the Block is stored at y = 13 (not deleted) and `over_limit()` is true.
7. [U] **GIVEN** (0,0,0) is occupied, **THEN** `can_place` is false for any cell set containing it or any cell outside x 0–7 / y 0–15 / z 0–7, and true for a set of free active cells.
8. [U] **GIVEN** an obstacle with `fills_layer = false` in layer 0 and the other 63 cells filled, **THEN** `layer_full(0)` is false.

**Formulas**
9. [U] F1: a 5 × 5 board with a 2 × 2 corner masked off gives `active_cells_in_layer(0)` = 21.
10. [U] F2: A = 64, c = 4, η = 0.75 gives P = 16 and P_eff ≈ 21.3. [M] *(provisional)* A bot simulation on 8 × 8 with tetracubes averages 15–28 pieces per clear.
11. [U] F3: the default board gives K = 768.
12. [U] F4: H_play = 12, L_max = 4 gives board_height = 16 and a height limit at layer 12; L_max = 5 gives board_height 17.
13. [U] F5: the default board gives a ≈ 28 px (±1). [M] *(provisional until HUD layout)* On a 6.1" phone in landscape (2532 × 1170), a screenshot shows a cube edge ≥ 27 px and the whole board visible from both rotate-view angles.

**Edge cases**
14. [U] **GIVEN** the spawn cells are occupied, **WHEN** a spawn is attempted, **THEN** spawn blocked is reported once and, in the default mode, the level is lost.
15. [U] **GIVEN** a Block at (0,0,0), **WHEN** the down axis flips to +y, **THEN** the Block stays at (0,0,0), its layer index becomes y' = 15, and the height limit and spawn zone move to the opposite end.
16. [U] **GIVEN** an occupied cell, **WHEN** a twist masks it off, **THEN** a clear event fires for that cell before it becomes inactive.
17. [U] **GIVEN** level data with content at (1,0,1) while (1,1) is masked, or a layer with A < 12, **WHEN** the level loads, **THEN** validation fails, the error names the cell or rule, and the board never reaches Live.
18. [U] *(Rule-Twist Framework Core Rule 9)* **GIVEN** two framework writes to one cell in one resolve step with an injected priority A < B, **THEN** the cell holds B's content.

## Open Questions

- **Piece set**: F2 and F4 take c and L_max from the level's piece set (Piece Set GDD); default cap L_max = 4.
- **Packing efficiency η**: placeholder 0.75; measure by bot simulation per footprint before tuning level sizes.
- **20 px floor**: device pixels or logical points? At 3× scale they differ a lot.
- **Board width share `g`**: depends on HUD plate and thumb-zone widths (UX).
- **Per-piece time ~4 s**: a guess for casual players; measure in the touch-controls prototype.
- **Hidden cells on 8 × 8**: at ~28 px with a deep stack, many cells hide behind others. Is the landing ghost plus rotate-view enough? Prototype early; it is the main risk of the 8 × 8 default.
- **Obstacles and `fills_layer`**: Obstacles GDD decides the default per obstacle type.
