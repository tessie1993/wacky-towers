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

The Board / Grid is the 3D space every piece lands in: a footprint of cells (width × depth) stacked up to a height limit, where each cell is either empty, inactive (switched off for this level), or holding a block, obstacle or object. It is the single source of truth for "what is where" — movement, dropping, clearing, goals, twists and obstacles all read and change it, and none of them keep their own copy. To the player it is the floating-island platform from the art bible: by default a **square platform**, sized per level type, with the layer-clearing default set to 8 × 8 × 12 (user decision, checked against the board-size math in Formulas). Levels may change the size and shape (an L-shaped island, holes, pillars) through a cell mask. The board also tracks the **height limit** and reports when a block sits above it; what that means is the level's `topout_rule` (Level Goals & Fail States). Without this system there is no shared arena — and Pillar 1, *The Block Is the Constant*, needs every mode, twist and minigame to stand on the same kind of board. Like the rest of the design docs, every value here is a starting default.

## Detailed Design

### Core Rules

**Space and coordinates**
1. The board is a 3D grid of unit cells addressed as `(x, y, z)`: `x` = width, `z` = depth (together the **footprint**), `y` = height, with `y = 0` the floor layer.
2. Size is set per level: `board_width × board_depth × board_height`. Each level type has a default; the **layer-clearing default** comes from the board-size math in Formulas. With no level override, the footprint is square (`board_width = board_depth`).
3. "Down" is `-y` by default. The board stores a **down axis**, which may be any of the **6 directions** (±x, ±y, ±z); a level sets it at load (e.g. sideways arrivals, Level-Specific Mechanics M9) and the Rule-Twist Framework may change it (e.g. a gravity-flip twist). "Layer" always means a slice perpendicular to the current down axis, indexed from the floor end; "height" and the height limit are measured along it. The board itself never moves anything — it only reports and stores.

**Cell mask (shape)**
4. Every footprint position is **active** or **inactive**. The default mask is all-active (a square platform). A level may switch positions off to make other shapes (L-shape, holes, ring). Inactive positions are inactive for the full height: nothing can enter them and they are drawn as empty space or island edge. In level data the mask is written as ASCII rows (`#` active, `.` off; row 0 = `z = 0`, character 0 = `x = 0`; Level Data rule 4a).
5. The mask is fixed for the whole level unless a twist or level-specific mechanic explicitly changes it (through the Rule-Twist Framework).

**Cell contents**
6. Each active cell holds exactly one of:
   - **Empty**
   - **Block** — a locked piece cube, stored as the record `{shape_id, piece_instance_id, owner, tags, status}`: the shape it came from, which piece instance (so cubes of one piece can be found together), the owning player (versus), the piece's tags (Piece Set rule 5) and any status effect. **Hue is not stored**: it is derived from `shape_id` plus the level's art set (`design/art/block-art-sets.md`, art bible); colour rules live in the art docs only.
   - **Obstacle** — a non-player block or object placed by the level or a twist (designed in Obstacles).
   - **Object** — a living or interactive thing occupying a cell (designed in Twist Library / Level-Specific Mechanics) — the silly props, critters and biome event pieces that make a level wacky.
7. Every content carries two flags the board reads: `solid` (default true) and `fills_layer` (counts toward a full layer; true for blocks, set per type for obstacles and objects). Content with `solid = false` is one of two kinds, set **per content type** in its own GDD:
   - **Blocking** — the piece cannot enter the cell: for movement, falling and resting it acts exactly like solid content. It differs only in that it never counts for `over_limit()` and its type may react when touched. Example: a soap bubble the piece lands on, which pops a moment later.
   - **Overlay** — the piece can pass through and lock into the cell. When a Block locks into an overlay cell, the overlay is **collected** by default: its effect fires for the locking player and it is removed, and the Block takes the cell. A type may instead be *squashed* (removed, no effect) or *kept* (hidden under the Block and shown again when the Block clears). Example: a coin or flower.
   Solid content always blocks and always supports.
8. The falling (active) piece is **not** stored in the grid until it locks; Movement & Rotation asks the board whether its target cells are free.

**Layers and height limit**
9. A layer is **full** when every active cell in it holds content with `fills_layer = true`. The board reports full layers; Layer Clearing decides what happens to them.
10. The **height limit** is a layer index (default `H_play` = `board_height − spawn_clearance`, see Formulas F4). `over_limit()` is true if any solid content sits at or above it. It is read once per lock, **after clears have finished** (Fall, Drop & Lock rule 15, step 6), so a clear can save the player. What a top-out does is the level's `topout_rule` (`rescue`, `trim` or `lose`; Level Goals & Fail States rule 10a); the board never decides.
11. The **spawn zone** is the space above the height limit where new pieces appear. It is part of the board's coordinate space but blocks never lock there in normal play (see Edge Cases).
11a. **Spawn anchor.** A level may set `spawn_anchor` `{x, z}`, the footprint cell new pieces are centred on (default: the footprint centre, lower cell on ties). Masked boards whose centre is inactive (a ring) must set one; validation checks that the anchor is active and that every shape's spawn cells around it are active.

**Queries the board answers** (the contract every other system uses)
- `is_free(cell)` — active, inside bounds, and empty or holding overlay content (rule 7).
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

**Default layer-clearing board (board-size math, user delegated the choice 2026-10-09): 6 × 6 footprint, 10 playable layers, 4-layer spawn clearance (14 layers drawn).** It gives one layer clear about every 96 s (F6), cubes of about 35 px in landscape and 58 px in portrait (F5), and about 40% of the surface hidden from one view (F7). The earlier 8 × 8 × 12 default gave one clear every ~170 s, too slow a heartbeat for casual phone play. 8 × 8 stays available per level: for row and colour clears (fast heartbeat on any footprint), shape fills, and masked finales (see "Recommended board per level type"). Pacing is set by the time between clears, not by a fixed number of clears per level.

### F1. Active cells per layer

The active_cells formula is defined as:

`A = |mask|` (equals `W × D` when no cells are masked off)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| W, D | int | 4+ (no max; default 6) | data file | Footprint width and depth (bounding box) |
| mask | set of footprint cells | A ≥ 12 | data file | Active footprint cells; default all |
| A | int | 12–64 typical | calculated | Cells a layer needs to be full |

**Output Range:** 12 upward (no hard maximum; 64 on an unmasked 8 × 8); default 36.
**Example:** 6 × 6, no mask → A = 36. 8 × 8 → 64. A 5 × 5 with a 2 × 2 corner removed → A = 21.

### F2. Pieces per layer clear

The pieces_per_clear formula is defined as:

`P = A / c` and `P_eff = P / η`; a perfect clear is possible when `(A × k) mod c = 0` for some small number of layers k.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| A | int | 12–64 | calculated (F1) | Active cells per layer |
| c | float | 1–8 | calculated (Piece Set) | Mean cubes per piece for the level's piece set; ≈ 4 for tetracubes |
| η | float | 0.6–0.9 | constant (tuning) | Packing efficiency for layer clears (= η_layer in F6) — share of placed cubes that end up in completed layers. **Placeholder 0.75; measure by bot simulation per footprint and piece set** |
| P_eff | float | 3–30 | calculated | Expected pieces placed per layer clear |

**Output Range:** about 3 (trivial) to 30 (very slow). Default board = 12.
**Example:** A = 36, c = 4, η = 0.75 → P = 9, P_eff = 12 pieces per clear. 8 × 8: P = 16, P_eff ≈ 21.3. Big Special pieces raise c and lower P_eff (8 × 8, c = 5 → ≈ 17), but also slow t_piece and lower η (see F6).
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

**Output Range:** 72 upward (768 on 8 × 8 × 12); default 360.
**Example:** 36 × 10 = 360 cells ≈ 90 tetracubes of room before topping out. 64 × 12 = 768 ≈ 192.

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

**Output Range:** 7 to 20 layers drawn; default 14.
**Example:** H_play = 10, L_max = 4 → C = 4, board_height = 14; a block locking at y = 10 reports over limit. H_play = 12 → 16 drawn.

**Any down axis (Core Rule 3).** `H_play_axis = E_down − C`, where `E_down` is the board's extent along the current down axis (W for ±x, board_height for ±y, D for ±z). The height limit is layer index `H_play_axis` counted from the floor end, and the spawn zone is the last C layers at the far end. Cells per layer become the product of the other two extents (masked cells removed), so F2, F3 and F6 use that `A_axis`.

| Symbol | Type | Range | Description |
|---|---|---|---|
| E_down | int | 4+ | Board extent along the down axis |
| C | int | = L_max | Spawn clearance (unchanged) |
| H_play_axis | int | must be 6–12 | Playable layers along the down axis |
| A_axis | int | ≥ 12 | Cells per layer perpendicular to the down axis |

**Validity:** `E_down ≥ C + 6`, so x or z gravity needs that side ≥ 10 with C = 4. Otherwise the level fails validation, unless a mode reduces C. Keep `A_axis` inside the level type's F6 band: a sideways board should be a **lane**, long along gravity and shallow across (e.g. 10 × 4 footprint, 8 tall → A_axis = 4 × 8 = 32, t_beat ≈ 85 s).
**Example:** default 6 × 6 × 14 with +x gravity → H_play_axis = 6 − 4 = 2 (invalid) and A_axis = 6 × 14 = 84 (t_beat ≈ 224 s). A 10 × 4 × 8 lane with +x gravity → H_play_axis = 6, valid.

### F5. On-screen cube size (readability check, both orientations, all 12 yaws)

The cube_size formula is defined as:

`a = cos(elev) × min( Sa_h / (Hw + m), Sa_w / (Ww + m) )`, with
`Ww = max over the 12 yaws of ( W × |cos yaw| + D × |sin yaw| )` and `Hw = Ww × sin(elev) + board_height × cos(elev)`

This is Camera & Rotate-View F2 (orthographic, one framing for all 12 yaws) turned into a cube edge; `a` is the vertical cube edge, the same at every yaw. It is computed for **both** orientation profiles; the smaller result is the one checked.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| W, D | int | 4+ | data file | Footprint bounding box |
| board_height | int | 7–20 | calculated (F4) | Layers drawn |
| elev | float | 25–40° | data file (Camera) | Camera elevation; default 30° |
| m | float | 0.3–1.0 cells | data file (Camera) | Framing margin; default 0.5 |
| Sa_w, Sa_h | float | px | constant (profile) | Board screen area. **Landscape** 1139 × 673 (45% × 57.5% of 2532 × 1170). **Portrait** 1076 × 1139 (92% × 45% of 1170 × 2532). **Both placeholders until the HUD layout is set** |
| Ww, Hw | float | world units | calculated | Widest on-screen width over the 12 yaws; on-screen height |
| a | float | ≥ 20 px | calculated | Cube edge on screen, px |

**Output Range:** about 25–45 px in landscape and 45–75 px in portrait within the recommended sizes; must stay ≥ 20 px (art bible), target ≥ 28 px. Landscape is the binding profile for every square board up to n ≈ 17. For a square board (`Ww = 1.414 n`) at elev 30°, m 0.5, the 28 px target becomes **`0.707 n + 0.866 board_height ≤ 20.3`** (20 px floor: ≤ 28.6).
**Example:** 6 × 6, board_height 14: Ww = 8.49, Hw = 4.24 + 12.12 = 16.37. Landscape: 673 / 16.87 = 39.9 px per unit (width 1139 / 8.99 = 127, not binding) → a = 0.866 × 39.9 ≈ **34.5 px**. Portrait: 1139 / 16.87 = 67.5 → a ≈ **58.5 px**. 8 × 8, board_height 16 → 29.1 px landscape, 49.3 px portrait.

### F6. Heartbeat (time between clears)

The heartbeat formula is defined as:

`t_beat = U × t_piece / (c × η_r)`

It replaces the old fixed "N = 3 clears per level" pacing: each level type has a t_beat band (table below), and a level's clear count N is authored per level and checked against it (Level Goals F1).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| U | int | 4–64 | calculated | Cells one clear event needs, by clear rule: **layer** = A; **row** = mean side `(W + D) / 2`; **colour-connect** = `k_min` (default 6); **mono layer** = A (and use η_mono) |
| t_piece | float | 4–12 s | data file (Level Goals) | Average time per piece; default 8 s |
| c | float | 1–8 | calculated (Piece Set F1) | Mean cubes per piece |
| η_r | float | 0.3–0.9 | constant (tuning) | Packing efficiency per clear rule: η_layer 0.75, η_row 0.8, η_colour 0.5, η_mono 0.3. **All placeholders; measure by bot simulation** |
| t_beat | float | about 5–340 s | calculated | Expected seconds between clear events |

**Output Range:** about 5 s (row clears, tiny board, fast player) to 340 s (unmasked 8 × 8 mono layer). Unbounded above if η_r is set near 0, which the safe range forbids. Collapse mode does not change t_beat: a cascade adds chain clears to the same event.
**Example:** default 6 × 6, layer, c 4 → 36 × 8 / 3 = **96 s**. 8 × 8 layer → 171 s. 8 × 8 row → 8 × 8 / 3.2 = **20 s**. Colour-connect on any footprint → 6 × 8 / 2 = **24 s**. Special-heavy set on 6 × 6 (c 4.93, t_piece ~10 s, η ~0.65) → ≈ 112 s: bigger pieces speed clears less than c alone suggests.

### F7. Hidden share (occlusion, one view)

The hidden_share formula is defined as:

`h = (1 / n_v) × Σ_{d=0}^{n_v − 1} [ 1 − (1 − p)^{min(d, R)} ]`, with `R = round(Δ × cot(elev))`

A surface cell is hidden from the current view if a column within R cells in front of it (toward the camera) stands at least Δ higher. h is the share of the landing surface the player cannot see without turning (Fade mode still shows the cells under the falling piece).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n_v | int | 4–12 | calculated | View depth in cells, ≈ `(W + D) / 2` |
| p | float | 0.1–0.5 | constant (tuning) | Chance a column in front is ≥ Δ taller. **Placeholder 0.25** |
| Δ | int | 1–3 | constant (tuning) | Typical surface step height. **Placeholder 2** |
| elev | float | 25–40° | data file (Camera) | Elevation; 30° → cot = 1.73 |
| R | int | 1–6 | calculated | Reach of a step's shadow, cells (3 at default) |
| h | float | 0–1 | calculated | Hidden share of the surface in one view |

**Output Range:** 0 to just under 1 − (1 − p)^R (≈ 0.58 at default); rises with n_v and falls with steeper elevation.
**Example:** p 0.25, R 3: terms 0, 0.25, 0.44, then 0.58 for every deeper row. 6 × 6 → 2.42 / 6 ≈ **0.40**. 4 × 4 → 0.32, 5 × 5 → 0.37, 7 × 7 → 0.43, 8 × 8 → 0.45. **Replace with a ray-cast measurement** of random bot stacks at all 12 yaws (deterministic, cheap) before final tuning.

### F8. Footprint from piece size

The footprint_side formula is defined as:

`n = ceil( √(c × P_band) )`, subject to `n ≥ L_max` (Piece Set F3)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c | float | 1–8 | calculated (Piece Set F1) | Mean cubes per piece |
| P_band | float | 4–9 | constant (per level type) | Pieces per perfectly packed layer the level type wants: tutorial / versus 4–6, standard 6–9 |
| L_max | int | 1–8 | calculated (Piece Set F2) | Longest piece extent |
| n | int | 4+ | calculated | Recommended side of a square footprint (or √A for masked boards) |

**Output Range:** 4 (c ≤ 4, small band) to about 8 (c 6+, top of band). Footprint side grows with the square root of piece size.
**Example:** c 4, P_band 9 → √36 = **6**. c 4.93 (Standard + Specials), P_band 9 → √44.4 → **7**. c 6, P_band 6 → √36 → 6.

### F9. Survive pressure

The survive_pressure formula is defined as:

`ρ = (T × c / t_piece_s) / (η × A × H_play)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| T | float | 60–300 s | data file (goal) | Survive time |
| c | float | 1–8 | calculated (Piece Set F1) | Mean cubes per piece |
| t_piece_s | float | 3–8 s | constant (tuning) | Player pace under survive speed. **Placeholder 5 s** |
| η | float | 0.5–0.8 | constant (tuning) | Packing under pressure. **Placeholder 0.6** |
| A × H_play | int | 72+ | calculated (F3) | Capacity K |
| ρ | float | > 0 | calculated | Cubes the level deals ÷ cubes the board can hold messily |

**Output Range:** unbounded above. Target **0.8–1.2**: below 0.8 the player cannot top out even without clearing (no tension); above about 1.5 the board fills before a casual player can clear.
**Example:** 5 × 5, H_play 8, T 150 s: 30 pieces × 4 = 120 cubes / (0.6 × 200) = **1.0**. 8 × 8 plus (A 48), H_play 10: 120 / 288 = 0.42 (too safe).

### Footprint comparison (H_play 10, c 4, t_piece 8 s, η_layer 0.75)

| Footprint | A | t_beat layer (F6) | t_beat row | Hidden h (F7) | Cube landscape / portrait (F5) | Notes |
|---|---|---|---|---|---|---|
| 4×4 | 16 | 43 s | 10 s | 0.32 | 38 / 64 px | Tutorials, versus |
| 5×5 | 25 | 67 s | 13 s | 0.37 | 36 / 61 px | Easy standard, survive |
| **6×6** | **36** | **96 s** | **15 s** | **0.40** | **35 / 59 px** | **Default layer-clear board** |
| 7×7 | 49 | 131 s | 18 s | 0.43 | 33 / 56 px | Special-heavy sets, finale |
| 8×8 | 64 | 171 s | 20 s | 0.45 | 32 / 54 px (29 / 49 at H12) | Row / colour clears, shape fills, masked finale |
| 8×4 lane | 32 | 85 s | 15 s | 0.40 (n_v 6) | — | Directional twists |
| 7×7 ring | 40 | 107 s | — | lower (far band seen over the gap) | — | Spawn anchor needed |
| 8×8 plus | 48 | 128 s | — | 0.45 | — | Big masked board with a layer clear in band |
| 8×6 | 48 | 128 s | 18 s | 0.43 (n_v 7) | 30 px at H12 / — | Finale-size board where masks are not allowed (e.g. Conveyor) |

### Recommended board per level type

| Level type | Footprint | H_play | Pacing target |
|---|---|---|---|
| Tutorial | 4×4–5×5 | 8 | t_beat 25–45 s; h ≤ 0.35 |
| Standard, layer clear | 5×5–6×6 (A 25–40; masks fine) | 10 | t_beat 45–100 s; h ≤ 0.40 |
| Standard, row / colour clear | 6×6–8×8 | 10–12 | t_beat 15–30 s; footprint picked by F5 / F7, not F6 |
| Build race | 4×4–6×6 | 10–12 | 20–40 s per counted layer: `A × coverage × t_piece / c` |
| Shape fill | target bounding box + 1-cell margin, up to 8×8 | 6–8 | — |
| Survive | 5×5–6×6 | 6–8 | ρ 0.8–1.2 (F9) |
| Finale | 6×6–7×7, or 8×8 masked to A ≤ 48 / with starter layers / row clears | 10–12 | t_beat 60–130 s |
| Versus / minigame | 4×4–5×5 layer, or 6×6+ with row clears | 8–10 | t_beat 20–40 s at t_piece 6 s |

The validator **warns** (never fails) when a level's t_beat, h or ρ is outside its type's band.

### Safe ranges for per-level overrides

- Footprint bounding box: at least 4 per side, **no maximum** (user decision 2026-10-09; 6 × 6 is the default, and large boards need the F5 readability check); masked layers need A ≥ 12, and every active region must fit the level's longest piece.
- Playable height: 6–12.
- Readability: F5 ≥ 28 px in **both** profiles as the target (square boards: `0.707 n + 0.866 board_height ≤ 20.3`); below 28 px needs a device check, below 20 px is not allowed.
- Pacing: t_beat (F6), h (F7) and ρ (F9) inside the level type's band, or a warning.
- Spawn clearance: C = L_max of the level's piece set. Only a mode may reduce it.

## Edge Cases

- **If a layer has zero active cells** (the mask removes a whole level, e.g. a ring footprint seen from a flipped down axis): it can never be full; `layer_full` returns false for it and goals skip it.
- **If a piece locks partly inside the spawn zone** (above the height limit): it locks normally; clears run; if `over_limit()` is still true afterwards, the level's `topout_rule` decides (Level Goals rule 10a). Pieces are never silently deleted (a `trim` removes cubes visibly).
- **If a new piece cannot spawn because its spawn cells are occupied**: the Spawner reports **spawn blocked**; it is a top-out and goes through the same `topout_rule` (Fall, Drop & Lock rule 15, step 10).
- **If the down axis changes** (a twist, or a level set to one of the 6 directions): layers are re-indexed along the new axis from its floor end (for `+y`: `y' = board_height − 1 − y`; for a ground axis the board's extent along that axis plays the role of `board_height`), and `over_limit` and the spawn zone are checked against the new index, so they move to the new "top". Contents do not move by themselves — whether they fall is the twist's rule. A change requested during Resolving waits until the board is Live.
- **If a Block locks into an overlay cell**: the overlay's on-lock behaviour runs (default collected, rule 7) before the clear check; a `kept` overlay reappears when that Block is cleared or trimmed.
- **If overlay content would be pushed by a slice shift or cascade into an occupied cell**: it follows its type's on-lock behaviour as if a Block had locked onto it.
- **If a twist or level mechanic switches off a cell that holds content**: the content is removed first (as a clear, so effects and scoring still fire), then the cell becomes inactive. A twist may instead refuse to switch off occupied cells; the twist's GDD says which.
- **If a twist switches an inactive cell back on**: it becomes active and empty; any layer it belongs to now needs one more cell to be full.
- **If an obstacle has `fills_layer = false`**: a layer containing it can never be full while it is there; this is intended (it's what makes the obstacle an obstacle) and Obstacle Clearing must provide a way to remove it.
- **If two systems try to write the same cell in the same resolve step**: the Rule-Twist Framework's priority order decides; the board applies writes in that order and the last write wins. Direct writes outside the framework are not allowed.
- **If a level's data is invalid** — starting content in an inactive cell or out of bounds, a layer with fewer than 12 active cells (A < 12), or an active region the straight piece cannot fit in — the level fails validation at load time and the error names the cell or rule; the game never starts a level with invalid board data.
- **If the board is resized or re-masked mid-level** (only via a twist or level mechanic): the change happens during Resolving, never while a piece is locking.
- **If the falling piece overlaps a cell that a twist just filled**: Movement & Rotation pushes the piece up (against the down axis) to the nearest free position; if none exists, it's treated as spawn blocked.

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

Criteria 2–8 and 14–18 use an explicit **8 × 8 test board** (H_play 12, C 4, board_height 16, A = 64) unless stated; the shipped default is 6 × 6, H_play 10, board_height 14 (criterion 1). **[U]** = automated unit test (`tests/unit/board_grid/`), **[M]** = manual or device check.

**Core rules**
1. [U] **GIVEN** no level data, **WHEN** a board is created, **THEN** it is 6 × 6 × 14 (H_play 10), every footprint cell is active, the down axis is −y, `y = 0` is the floor, and `stack_height()` returns −1.
2. [U] **GIVEN** footprint cell (1,1) is masked off, **WHEN** `is_free(1, y, 1)` is called for y = 0–15, **THEN** every call returns false and `set` on those cells is rejected.
3. [U] **GIVEN** an empty active cell, **WHEN** a Block is set there, **THEN** `get` returns it with piece ID, owner, `solid = true`, `fills_layer = true`, and nothing else in that cell.
4. [U] **GIVEN** 63 of 64 cells in layer 0 hold Blocks, **WHEN** the 64th is filled, **THEN** `layer_full(0)` goes from false to true and `full_layers()` returns [0].
5. [U] **GIVEN** a Block locks at y = 11, **THEN** `over_limit()` is false; **GIVEN** it locks at y = 12, **THEN** `over_limit()` is true.
6. [U] **GIVEN** a lock at y = 13 (spawn zone), **WHEN** it resolves, **THEN** the Block is stored at y = 13 (not deleted) and `over_limit()` is true.
7. [U] **GIVEN** (0,0,0) is occupied, **THEN** `can_place` is false for any cell set containing it or any cell outside x 0–7 / y 0–15 / z 0–7, and true for a set of free active cells.
8. [U] **GIVEN** an obstacle with `fills_layer = false` in layer 0 and the other 63 cells filled, **THEN** `layer_full(0)` is false.

**Formulas**
9. [U] F1: a 5 × 5 board with a 2 × 2 corner masked off gives `active_cells_in_layer(0)` = 21.
10. [U] F2: A = 36, c = 4, η = 0.75 gives P = 9 and P_eff = 12; A = 64 gives P_eff ≈ 21.3. [M] *(provisional)* A bot simulation on 6 × 6 with tetracubes averages 9–16 pieces per clear.
11. [U] F3: the default board gives K = 360; 8 × 8 × 12 gives 768.
12. [U] F4: H_play = 10, L_max = 4 gives board_height = 14 and a height limit at layer 10; H_play 12, L_max = 5 gives board_height 17.
13. [U] F5: the default board gives a ≈ 34.5 px (±1) in the landscape profile and ≈ 58.5 px (±1) in the portrait profile; 8 × 8 × 16 gives ≈ 29.1 px landscape. [M] *(provisional until HUD layout)* On a 6.1" phone (2532 × 1170) in **both** landscape and portrait, screenshots at all 12 yaws show the whole board and a cube edge ≥ 28 px.
13a. [U] F6: A = 36, t_piece 8, c 4, η_layer 0.75 → t_beat = 96 s; row rule on 8 × 8 (U 8, η_row 0.8) → 20 s; colour-connect (k_min 6, η_colour 0.5) → 24 s.
13b. [U] F7: n_v 6, p 0.25, Δ 2, elev 30° → R = 3, h ≈ 0.40 (±0.01); n_v 8 → h ≈ 0.45. [M] *(provisional)* A ray-cast script over 100 seeded bot stacks at all 12 yaws reports the measured h per footprint; F7's p and Δ are refit to it.
13c. [U] F8: c 4, P_band 9 → n = 6; c 4.93 → n = 7; the result is never below L_max.
13d. [U] F9: T 150, c 4, t_piece_s 5, η 0.6, A 25, H_play 8 → ρ = 1.0. [U] The validator warns (does not fail) when t_beat, h or ρ is outside the level type's band.

**Edge cases**
14. [U] **GIVEN** the spawn cells are occupied, **WHEN** a spawn is attempted, **THEN** spawn blocked is reported once and the level's `topout_rule` handles it (Level Goals).
15. [U] **GIVEN** a Block at (0,0,0), **WHEN** the down axis flips to +y, **THEN** the Block stays at (0,0,0), its layer index becomes y' = 15, and the height limit and spawn zone move to the opposite end.
16. [U] **GIVEN** an occupied cell, **WHEN** a twist masks it off, **THEN** a clear event fires for that cell before it becomes inactive.
17. [U] **GIVEN** level data with content at (1,0,1) while (1,1) is masked, or a layer with A < 12, **WHEN** the level loads, **THEN** validation fails, the error names the cell or rule, and the board never reaches Live.
18. [U] *(Rule-Twist Framework Core Rule 9)* **GIVEN** two framework writes to one cell in one resolve step with an injected priority A < B, **THEN** the cell holds B's content.

## Open Questions

- **Piece set**: F2 and F4 take c and L_max from the level's piece set (Piece Set GDD); default cap L_max = 4.
- **Packing efficiency η_r**: placeholders (layer 0.75, row 0.8, colour 0.5, mono 0.3); measure by bot simulation per footprint, clear rule and piece set before final level sizes.
- **20 px floor**: device pixels or logical points? At 3× scale they differ a lot.
- **Board screen areas (F5 profiles)**: landscape 45% × 57.5% and portrait 92% × 45% are placeholders; HUD and thumb zones (UX) set the real values. Landscape is the binding profile.
- **t_piece = 8 s**: a conservative guess for casual players; measure in the touch-controls prototype. At 6 s every t_beat drops 25% and the recommended footprints could grow about one size.
- **Hidden share (F7)**: p and Δ are placeholders; replace with a ray-cast measurement at all 12 yaws. Is Fade plus rotate-view enough at h ≈ 0.45 (8 × 8)? Prototype early.
- **Heartbeat bands**: the per-level-type t_beat bands are design targets from casual-puzzle reward cadence; confirm in playtests.
- **Obstacles and `fills_layer`**: Obstacles GDD decides the default per obstacle type.
- **Overlay default (rule 7), open to playtest**: "collected" (effect fires, overlay removed) is the designer default of 2026-10-09; squashed and kept stay available per type. Check that collecting by locking reads as a reward, not an accident.
