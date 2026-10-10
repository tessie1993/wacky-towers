# Movement & Rotation

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Readable Chaos; Comeback Energy

## Summary

Movement & Rotation is the one place that decides whether the falling piece can slide or turn. It takes the commands from Touch Controls, checks the target cells against the board, and either moves the piece or says "blocked". Rotations that hit a wall or the stack try a short list of small "kick" nudges before giving up, and the opposite rotation always puts the piece back exactly where it was. By default the piece moves freely while falling and after landing; a level or perk can restrict moves once it has landed.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Board / Grid, Piece Set, Touch Controls, Camera & Rotate-View`

## Overview

The falling piece is a shape (Piece Set) in one of its orientations at a pivot position on the board. Movement & Rotation owns every change to that position and orientation that the player or a rule requests: sliding one cell along the ground axes, turning 90° about a world axis around the pivot cube, and the small "kick" nudge that rescues a rotation that doesn't quite fit. It never decides when the piece falls or locks (Fall, Drop & Lock) and never writes to the board; it only asks the board whether the target cells are free. Every command is resolved instantly and completely: it either succeeds, or it fails and nothing changes, and a failure returns a reason so the game can play a "bonk". Rotation uses a small, ordered, data-driven kick table that prefers pushing the piece toward the board's centre, and remembers any kick so the opposite rotation restores the previous position exactly, which keeps Touch Controls' promise that any move can be undone until lock. This serves *Readable Chaos* (the piece does what the player expects and never jumps unpredictably) and *Comeback Energy* (a trailing player can place accurately and fast). All values are starting defaults.

## Detailed Design

### Core Rules

**The piece**
1. A falling piece has: its shape (Piece Set), an **orientation** `R` (one of the 24 rotations of the cube; the shape lists its distinct ones), and a **pivot position** `p` (the cell of its pivot cube). Its occupied cells are `p + R · offset_i` for each cube offset `i` (Formulas F1).
2. The piece is not stored in the grid. Movement & Rotation asks `can_place(cells[])` on the board; a cell passes if it is inside the board, active, and either empty or holding **overlay** content (Board / Grid rules 7 and `is_free`). Solid and **blocking** content fail the test.
3. Every command is **atomic**: it fully succeeds or leaves the piece exactly as it was. It returns `Ok`, `Ok(kicked, offset)`, `Blocked(reason)` or `Disabled`. Reasons: `out_of_bounds`, `inactive`, `occupied`, `unsupported`.
4. Commands from one player are resolved **in the order received**, including several in the same frame. There is no rate limit here (Touch Controls owns repeat timing).
5. With no falling piece, every command is ignored.

**Move**
6. `move(dir)` shifts `p` by one cell along one of the two **ground axes** (the axes perpendicular to the down axis: default ±x and ±z; with sideways gravity, one of them is ±y). Touch Controls has already turned a screen direction into a world direction using the camera's direction map; this system only sees world directions.
7. A move whose target cells all pass `can_place` succeeds; otherwise it fails with the reason of the first failing cell. There is no wrap-around at board edges unless a twist adds it.
8. `try_translate(delta)` is the general collision primitive. `move` uses it for ground steps; Fall, Drop & Lock uses it for fall steps and drops (including the landing ghost), so there is a single collision authority.

**Rotate**
9. `rotate(axis, sign)` turns the piece 90° about a **world** axis through the pivot cube, using the right-hand rule about +axis (Formulas F1). Which world axis a button or flick maps to is Touch Controls' job, using this **view-relative mapping** (the same at every one of the 12 camera snaps and for every gravity direction, so the controls never change meaning when gravity does):
   - **spin** = the world vertical axis (y), which is always screen-vertical;
   - **tilt** = the horizontal world axis (x or z) whose on-screen projection is closest to screen-horizontal; at the corner snaps, where x and z are equally close, the tie goes to the axis that appears **up-right**;
   - **roll** = the other horizontal world axis.
   If the level has not enabled that axis, the command returns `Disabled`: no change and no bonk.
10. **In place first.** The new orientation is tested at the same pivot. If it passes, the rotation succeeds with no kick.
11. **Kick table.** If the in-place rotation fails, the candidates in Formulas F2 are tried in order; the first that passes is taken, and the rotation returns `Ok(kicked, offset)`. If none passes, it returns `Blocked` with the reason of the in-place test. Kicks are searched in world coordinates, so they do not depend on the camera angle.
12. **Kick limits.** A kick never moves the piece down. Up-kicks (against the down axis) are limited to `max_up_kicks_per_piece` (default 2) per falling piece, so repeated rotation cannot climb out of a hole or stall forever. Wide (2-cell) kicks apply only to pieces with a longest extent of at least `kick_wide_min_extent` (default 4) and only if the 1-cell offset in the same direction also passes, so the piece never leaps across a wall.
13. A shape that is unchanged by the rotation (for example the Big Cube, or the Mono) succeeds with no kick; the orientation is recorded so feedback plays (Piece Set edge case).

**Undo (restore exactly)**
14. After a rotation, the system keeps one **undo record**: the axis, the sign and the kick offset (zero if none). If the next rotation is the exact opposite (same axis, opposite sign), the system first tries the **restore**: the previous orientation at pivot `p − offset`. If it passes, it is taken; if the board has changed so it no longer fits, a normal opposite rotation with kicks is used instead.
15. The undo record survives moves and fall steps (the offset is relative, so the restore still lands where the piece was relative to its current position). It is cleared by any other rotation, by a shape swap, and when the piece locks.
16. Moves are undone by the opposite move (reversible by nature; if it is blocked, the usual blocked rule applies).

**After landing**
17. The piece is **resting** if any of its cubes has solid or blocking content, or the floor, directly below it (one cell along the down axis). Overlay content never supports. Whether the piece is resting is reported to Fall, Drop & Lock, which owns lock timing.
18. `landed_move_rule` (default `free`): moves and rotations behave the same whether the piece is resting or in the air. A level or perk may set it to `supported`: while resting, a move or rotation must also end resting, otherwise it fails with `unsupported`. This stops sliding off the edge into a gap during lock delay.

**Overlap rescue**
19. When a rule outside the player's control leaves the piece overlapping something (a twist filled cells under it, or a twist swapped its shape for one that doesn't fit), the Rule-Twist Framework calls `place_nearest_up()`. The system tries the same position, then 1, 2, 3 … cells up, taking the first that passes `can_place`, up to the board height. If none passes, it reports **spawn blocked** to the board (Board / Grid edge case).

### States and Transitions

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **NoPiece** | Nothing to control; commands ignored | Level start; after lock until the next spawn | A piece spawns (Spawner) |
| **Active** | A piece is falling and accepts commands | Spawn succeeded | Piece locks, level ends, or the piece is replaced by a swap (stays Active with a new piece) |
| **Frozen** | Piece exists but commands are ignored | Pause, level over, or a Resolving board that holds input | Resume |

Resting vs. airborne is a flag on Active, not a state.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Touch Controls | → Movement | `move(world_dir)`, `rotate(world_axis, ±1)`; receives `Ok` / `Ok(kicked)` / `Blocked(reason)` / `Disabled` for feedback |
| Camera & Rotate-View | Camera → Touch → Movement | The direction map is applied by Touch Controls; Movement uses world directions only |
| Board / Grid | ↔ | `can_place(cells[])`; down axis; footprint centre for kick ordering; never writes |
| Piece Set | Piece Set → | Cube offsets, pivot, distinct orientations, spawn orientation, longest extent |
| Piece Spawner & Queue | Spawner → | New piece instance (shape, pivot position, spawn orientation); a blocked spawn is reported by the Spawner |
| Fall, Drop & Lock | ↔ | Uses `try_translate`, the drop target and the resting flag; owns gravity, lock delay and resets |
| Rule-Twist Framework, Twist Library | ↔ | May replace the piece, move it (wind, drift), restrict axes, set `landed_move_rule`, change kick limits; calls `place_nearest_up()` |
| Level Data & Definition | → Movement | Enabled rotation axes, `landed_move_rule`, kick overrides |
| Characters & Perks, Items | → Movement | May set `landed_move_rule` or kick limits for one player |
| HUD, Game Feel & VFX | Movement → | Move / rotate / kick / blocked events for the ghost, gizmo, bonk and sounds |

## Formulas

All values are starting defaults. Coordinates are `(x, y, z)` with `y` up (the default down axis is `−y`).

### F1. Occupied cells and 90° rotations

The occupied_cells formula is defined as:

`cells = { p + R · o_i }` for every cube offset `o_i`; a +90° turn composes the current `R` with `R_axis`, where
`R_x(+90°): (x, y, z) → (x, −z, y)`, `R_y(+90°): (x, y, z) → (z, y, −x)`, `R_z(+90°): (x, y, z) → (−y, x, z)`; −90° applies the inverse (three +90° turns).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p | int[3] | inside the board | calculated | Pivot cell position |
| R | 3×3 int matrix | one of the 24 cube rotations | calculated | Current orientation |
| o_i | int[3] | −3 to +3 per axis | data file (Piece Set) | Offset of cube i from the pivot cube |
| cells | int[3][] | 1–8 cells | calculated | Cells the piece occupies |

**Output Range:** 1–8 cells; four turns about one axis return the original cells. **Example:** T `(0,0,0)(1,0,0)(2,0,0)(1,1,0)` turned +90° about y → `(0,0,0)(0,0,−1)(0,0,−2)(0,1,−1)`, one face-connected group as before.

### F2. Kick candidates and order

The kick_candidates formula is defined as:

`K = [ in-place ] + sort_by_centre(L1) + [ up ] + sort_by_centre(L1 + up) + sort_by_centre(L2)`, where `L1` = the 4 ground offsets of 1 cell, `up` = `(0, +1, 0)` (against the down axis), `L1 + up` = those 4 offsets with +1 up, and `L2` = the 4 ground offsets of 2 cells (used only if `longest_extent ≥ kick_wide_min_extent`). `sort_by_centre` orders candidates by `d² = (px − cx)² + (pz − cz)²` of the resulting pivot against the centre `(cx, cz)` of the active footprint, smallest first; ties use the fixed order +x, −x, +z, −z.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| (cx, cz) | float | within the footprint | calculated (Board) | Centre of the active footprint (3.5, 3.5 on the default 8 × 8) |
| px, pz | int | within the footprint | calculated | Pivot after the candidate offset |
| kick_wide_min_extent | int | 2–8 | data file | Smallest longest-extent for 2-cell kicks; default 4 |
| max_up_kicks_per_piece | int | 0–4 | data file | Up-kick budget per falling piece; default 2 |

**Output Range:** at most 10 tests per rotation for most pieces (1 in place + 4 + 1 + 4), at most 14 for pieces with extent ≥ 4; at most 14 × 8 = 112 cell queries. **Example:** T at pivot `(3, 5, 1)` turned +90° about y needs z = −1 and fails in place. Candidates by `d²`: +z (2.5), +x (6.5), −x (8.5), −z (12.5). +z gives cells `(3,5,2)(3,5,1)(3,5,0)(3,6,1)`, which are free, so the rotation succeeds with offset `(0, 0, +1)`. Rotating −90° restores pivot `(3, 5, 1)` and the original orientation.

### F3. Restore after a kick

The restore formula is defined as:

`p_restored = p_now − offset_kick`, `R_restored = R_axis(−sign) · R_now`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p_now | int[3] | inside the board | calculated | Current pivot (after any later moves or falls) |
| offset_kick | int[3] | each −2 to +2 | calculated | The kick stored in the undo record (0 if none) |
| R_now | 3×3 int matrix | one of 24 | calculated | Current orientation |

**Output Range:** the pre-rotation orientation, and a pivot shifted back by the kick. **Example:** after the F2 example the player moves +x, so the pivot is `(4, 5, 2)`; rotating −90° gives pivot `(4, 5, 1)` and the original orientation.

### F4. Resting test

The resting formula is defined as:

`resting = OR over cubes c of ( floor_below(c) OR supports(content(c + down)) )`, where `supports` is true for solid and blocking content and false for empty and overlay cells

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c | int[3] | a cell of the piece | calculated | One of the piece's cells |
| down | int[3] | unit axis vector | data file (Board) | Down direction, default `(0, −1, 0)` |
| supports() | bool | true / false | data file (Board) | True for solid or blocking content (Board / Grid rule 7) |

**Output Range:** true / false; used for `landed_move_rule = supported` and reported to Fall, Drop & Lock. **Example:** an I lying flat on layer 0 is resting; the same I hovering one layer above the floor with empty cells under all four cubes is not.

## Edge Cases

- **If a move would leave the footprint**: `Blocked(out_of_bounds)`, no change, bonk.
- **If the target cell is inactive (holes in a masked board)**: `Blocked(inactive)`.
- **If the target cell holds a solid block, obstacle or object, or blocking content**: `Blocked(occupied)`. If it holds overlay content, the cell passes (and the overlay's on-lock behaviour runs only if the piece locks there).
- **If the down axis is sideways** (e.g. −x): ground axes are y and z; spin, tilt and roll keep their view-relative meaning (rule 9), not a gravity-relative one.
- **If a rotation fits in place**: it is taken with no kick, even when a "better" kick exists.
- **If a rotation fits only at a kick**: the kick is taken and reported as `Ok(kicked, offset)`; the visuals play rotate and slide in one motion.
- **If no kick fits**: `Blocked` with the in-place reason; the piece and the undo record are unchanged.
- **If the up-kick budget is used up**: further candidates that need an up-kick are skipped; lateral-only candidates are still tried.
- **If a wide kick's 1-cell intermediate offset fails the test**: the wide kick is skipped.
- **If the rotated shape has the same cells** (Big Cube, Mono, symmetric orientation): `Ok` with no kick; the undo record is stored.
- **If the opposite rotation is sent but the restore position is no longer free**: a normal opposite rotation with kicks is used.
- **If any rotation other than the exact opposite comes between**: the undo record is replaced; the restore no longer applies.
- **If a move or fall step happens between a kick and its undo**: the undo still works (the stored offset is relative).
- **If two commands arrive in the same frame**: they resolve in arrival order, each against the result of the previous one.
- **If a rotation axis is disabled by the level**: `Disabled`, no bonk, no change.
- **If `landed_move_rule = supported` and the piece is resting**: a move or rotation that would end unsupported fails with `Blocked(unsupported)`, and a kick that ends unsupported is skipped.
- **If a twist fills a cell under or inside the piece**: `place_nearest_up()` lifts the piece to the nearest free position upward; if none exists, spawn blocked is reported (Board / Grid).
- **If a twist swaps the piece for another shape**: the pivot stays; the new piece starts in its spawn orientation; if it doesn't fit, `place_nearest_up()` is used; the undo record is cleared.
- **If the down axis flips while a piece is active**: the piece keeps its world cells; the ground axes and the "up" of the kick table follow the new down axis.
- **If the piece is partly in the spawn zone**: allowed; moves and rotations work as normal up to the board height.
- **If the piece is frozen by pause or a Resolving board**: commands are ignored and not buffered (Touch Controls buffers only in Waiting).
- **If a rotation is blocked repeatedly**: each attempt is a separate bonk; there is no stacking or penalty.

## Dependencies

**Upstream (this system depends on):**

| System | Hard / soft | Interface |
|---|---|---|
| Board / Grid | Hard | `can_place`, down axis, footprint centre, spawn-blocked report |
| Piece Set | Hard | Cube offsets, pivot, orientations, longest extent |
| Touch Controls | Hard | Source of `move` and `rotate` commands (with world directions and axes) |
| Camera & Rotate-View | Soft | Direction map applied by Touch Controls; Movement itself only uses world directions |

**Downstream (depend on this system):**

| System | Hard / soft | Interface |
|---|---|---|
| Fall, Drop & Lock | Hard | `try_translate`, drop target, resting flag |
| Rule-Twist Framework, Twist Library | Hard | `place_nearest_up()`, rule overrides, piece replacement |
| Level Data & Definition | Hard | Enabled axes, `landed_move_rule`, kick overrides |
| Touch Controls | Hard | Result codes for the bonk |
| HUD, Game Feel & VFX | Soft | Events for ghost, gizmo, bonk |
| Physics Mode | Soft | May replace this system's rules entirely |
| Characters & Perks, Items | Soft | Per-player rule changes |

Board / Grid, Piece Set and Touch Controls already mention Movement & Rotation; each remaining downstream GDD must list it when written.

## Tuning Knobs

| Knob | Range | Default | Source | Affects |
|---|---|---|---|---|
| kick_enabled | true / false | true | data file (level) | Whether the kick table is used at all; false makes rotations in-place only |
| max_up_kicks_per_piece | 0–4 | 2 | data file | How much a piece can climb through rotation; interacts with Fall, Drop & Lock's lock-reset count |
| kick_wide_min_extent | 2–8 | 4 | data file | Which pieces get 2-cell kicks |
| kick_order | centre / fixed | centre | data file | Whether kicks prefer the board centre or follow the fixed order +x, −x, +z, −z |
| landed_move_rule | free / supported | free | data file (level, perk) | Whether landed pieces can slide into gaps |
| rotation_axes_enabled | subset of {spin, tilt, roll} | all (level may reduce) | data file (level) | Progressive disclosure (Touch Controls) |

`kick_enabled = false` makes `max_up_kicks_per_piece`, `kick_wide_min_extent` and `kick_order` inert.

## Visual/Audio Requirements

- **Move**: the piece snaps one cell with a short ease (about 60 ms); the landing ghost updates the same frame.
- **Rotate**: logical instant, drawn as a 120 ms turn about the pivot (Touch Controls); the axis gizmo flashes on the pivot (shape- and colour-coded). With reduced motion, turns are instant cuts.
- **Kick**: drawn as the same turn plus a slide in the same 120 ms, with a small dust puff at the cell the piece slid away from, so the player sees why it moved.
- **Blocked**: a short "bonk" shake of the piece (about 80 ms, translation only, respects reduced motion) with the blocked cubes briefly outlined in the danger red (art bible §4). A `Disabled` rotation shows nothing.
- Audio events (owned by Audio): `piece_moved` (soft click), `piece_rotated` (whoosh), `piece_kicked` (whoosh with a short scrape), `move_blocked` and `rotate_blocked` (dull bonk).

## Game Feel

Movement and rotation should feel immediate and honest: the piece changes cells on the same frame the command arrives, every blocked command says so within one frame, and a kick should feel like the game quietly helping rather than the piece jumping. Targets: command-to-logical-change in the same frame; move ease 60 ms; rotate turn 120 ms; bonk 80 ms; a kick never moves the piece more than 1 cell for most pieces (2 for extent ≥ 4). The restore rule means "undo" always feels exact.

## UI Requirements

None directly. Touch Controls owns the buttons and gestures; the HUD owns the ghost. If playtests show kicks are confusing, a ghost "kick preview" is a possible addition (Open Questions).

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/board-grid.md` Core Rules 2, 3, 6–8; Query contract; Edge Cases | `can_place`, `solid` flag, down axis, push-up rule, spawn blocked, falling piece not stored in the grid |
| `design/gdd/piece-set.md` Core Rules 1, 9, 10; F4; Edge Cases | Cube offsets, pivot, 90° rotation about the pivot, distinct orientations, spawn orientation, symmetric shapes, swaps |
| `design/gdd/touch-controls.md` Core Rules 1, 3, 7, 8; Edge Cases | Commands and result codes, world-axis rotations, undo until lock, bonk, progressive disclosure |
| `design/gdd/camera-rotate-view.md` F3 | Direction map applied by Touch Controls |
| `design/gdd/piece-spawner-queue.md` Core Rules 8, 9 | Spawn position and orientation; spawn blocked |
| `design/art/art-bible.md` §4 | Danger red for blocked cubes |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device. Defaults: 8 × 8 × 16 board, centre (3.5, 3.5), down axis −y, `landed_move_rule = free`.

**Move**
1. [U] **GIVEN** a free cell to the right, **WHEN** `move(+x)` is sent, **THEN** the pivot changes by (+1, 0, 0), the result is `Ok`, and the ghost updates in the same frame.
2. [U] **GIVEN** a piece at the +x edge, **WHEN** `move(+x)` is sent, **THEN** `Blocked(out_of_bounds)` and the piece is unchanged.
3. [U] **GIVEN** a block, an inactive cell, a blocking object and an overlay object in four separate targets, **WHEN** moved into, **THEN** the results are `Blocked(occupied)`, `Blocked(inactive)`, `Blocked(occupied)` and `Ok`.
4. [U] **GIVEN** a move then its opposite, **THEN** the piece returns to the starting pivot.

**Rotate**
5. [U] F1: T turned +90° about y gives `(0,0,0)(0,0,−1)(0,0,−2)(0,1,−1)`; four +90° turns about each axis return the original cells; +90° then −90° on any axis is the identity.
6. [U] **GIVEN** the rotation fits in place, **THEN** the result is `Ok` with no kick, even if kick candidates would also fit.
7. [U] F2 example: T at pivot (3, 5, 1) rotated +90° about y → `Ok(kicked)` with offset (0, 0, +1) and cells `(3,5,2)(3,5,1)(3,5,0)(3,6,1)`.
8. [U] **GIVEN** candidates that fit at both +x and −x, **THEN** the one nearer the centre is taken; **GIVEN** `kick_order = fixed`, **THEN** +x comes before −x.
9. [U] **GIVEN** a piece on the floor needing an up-kick, **THEN** the up candidate is taken; **GIVEN** the budget is used (2 up-kicks already), **THEN** further up-kick candidates are skipped and lateral-only ones still tried.
10. [U] **GIVEN** a piece with extent 4 and a 2-cell kick that fits only if the 1-cell offset is also free, **WHEN** the 1-cell offset is blocked, **THEN** the wide kick is not used; **GIVEN** a piece with extent 3, **THEN** wide kicks are never tried.
11. [U] **GIVEN** no candidate fits, **THEN** `Blocked(reason)`, the piece and undo record are unchanged.
12. [U] **GIVEN** a Big Cube or Mono, **WHEN** rotated, **THEN** `Ok`, cells unchanged.
12a. [U] **GIVEN** camera yaw 75° (+x appears 15° off screen-right), **THEN** tilt maps to the x axis and roll to z; **GIVEN** a corner snap (k = 0, 3, 6, 9), **THEN** tilt maps to the axis that appears up-right; **GIVEN** down axis −x, **THEN** the mapping is unchanged.
13. [U] **GIVEN** a level with tilt disabled, **WHEN** a tilt rotation is sent, **THEN** `Disabled`, no change, no bonk event.

**Undo**
14. [U] F3 example: after the kicked rotation, `rotate(y, −)` returns pivot (3, 5, 1) and the original orientation.
15. [U] **GIVEN** a kicked rotation, a `move(+x)` and an opposite rotation, **THEN** the pivot is (4, 5, 1) and the original orientation.
16. [U] **GIVEN** another rotation occurs between, **THEN** the opposite rotation is a normal one (no restore).
17. [U] **GIVEN** the restore cells are now occupied, **THEN** a normal opposite rotation with kicks is used.

**After landing**
18. [U] **GIVEN** `landed_move_rule = free` and a resting piece, **WHEN** it slides to a position over a gap, **THEN** `Ok`.
19. [U] **GIVEN** `supported` and a resting piece, **WHEN** a move would end unsupported, **THEN** `Blocked(unsupported)`; a kick that ends unsupported is skipped.
20. [U] F4: an I lying flat on layer 0 is resting; an I over an empty gap with no support under any cube is not.

**Rules and robustness**
21. [U] **GIVEN** a twist fills a cell under the piece, **WHEN** `place_nearest_up()` is called, **THEN** the piece moves to the nearest free position upward; **GIVEN** no position exists, **THEN** spawn blocked is reported once.
22. [U] **GIVEN** two commands in one frame, **THEN** the second is evaluated against the first's result, in arrival order.
23. [U] **GIVEN** no piece (NoPiece) or Frozen, **THEN** every command is ignored with no result event and nothing buffered.
24. [U] **GIVEN** the down axis flips to +y while a piece is active, **THEN** its cells are unchanged, ground axes are still perpendicular to the down axis, and the up-kick direction is now −y.
25. [U] **GIVEN** any rotation, **THEN** at most 14 placement tests and 112 cell queries are made.
26. [I] **GIVEN** a blocked command, **THEN** Touch Controls receives the reason and plays the bonk; **GIVEN** `Disabled`, **THEN** it plays nothing.
27. [M] **GIVEN** the Touch Controls prototype, **WHEN** testers rotate pieces near walls and the stack, **THEN** fewer than 20% report that "the piece jumped" or did something unexpected.

## Open Questions

- **Kick table values**: are 1-cell lateral, 1 up and 2-cell for extent ≥ 4 enough, or is a bigger table needed for the 3D Specials? Validate in the Touch Controls prototype.
- **Kick preview**: should the ghost show where a kick will land before the player commits? Decide after playtests.
- **Pivot feel**: rotating about the pivot cube moves the piece's visual centre for odd shapes; consider a per-shape pivot override if rotations feel off.
- **Lock-delay reset**: answered in Fall, Drop & Lock (successful moves and rotations, kicked ones included, restart the lock timer, up to 10 resets per piece, restored when the piece reaches a lower layer). The up-kick budget is a backstop.
- **Wrap-around boards**: should a twist be allowed to wrap the board edges (move off one side, appear on the other)? Rule-Twist Framework to decide.
- ~~**Non-solid contents**~~: resolved — overlay content passes, blocking content blocks and supports; on-lock behaviour per type (Board / Grid rule 7).
- **Screen-fixed rotation under sideways gravity (rule 9), open to playtest**: designer default 2026-10-09 is that spin, tilt and roll stay screen-fixed whatever the gravity. If players expect "spin" to turn around the fall direction, try a gravity-relative option.
- **Landed restriction as a perk**: `landed_move_rule = supported` is a level or perk property; Characters & Perks and Level Data should decide which levels use it.
- **Smart rotate**: if neither Touch Controls scheme meets the 3D targets, consider an "auto-fit rotate" that chooses the next orientation that fits.
