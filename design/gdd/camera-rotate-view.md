# Camera & Rotate-View

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Readable Chaos; The Block Is the Constant

## Summary

The Camera shows the board as an orthographic toy diorama from a fixed angle, with the whole board always in frame at one zoom. The player can turn the view in 12 steps of 30° (the four classic corner views are every third step), and the camera tells Touch Controls which world direction "screen-left" means after every turn. Each level picks an occlusion aid — fade blocks in front of the piece (default), a layer cutaway, or ghost only — so the falling piece, its ghost and the height line are never hidden.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `Board / Grid`

## Overview

The Camera shows the board as a toy diorama from a fixed, angled, **orthographic** view, so every cube is the same size and grid lines stay parallel — the easiest way to judge where a piece will land. The player can turn the view around the board in **12 steps of 30°**; the four classic diagonal "corner" views are every third stop. The framing is fixed: the whole board is always visible at one zoom level for all 12 angles, and the camera never drifts, follows or zooms during play — only rotate-view and short juice (shake, punch) move it. Because the default 8 × 8 board can hide cells behind a tall stack, the camera also runs the **occlusion aid** each level chooses: fade the blocks in front of the falling piece (default), a layer cutaway, or ghost-and-column only. The camera tells Touch Controls which way "screen-left" points in the world after every turn. It serves *Readable Chaos* above all: the playfield must read at a glance, from any angle, on a phone. All values are starting defaults.

## Detailed Design

### Core Rules

**Projection and pose**
1. Orthographic projection. Default elevation (pitch) gives a 2:1 dimetric look (about 30° above the horizon), matching Board / Grid F5.
2. The camera orbits the centre of the board's footprint at a fixed elevation. Its **yaw** takes one of 12 values: `yaw = 45° + 30° × k`, k = 0…11. The default (k = 0, 45°) is a corner view; corner views are k = 0, 3, 6, 9.
3. The camera never changes elevation or zoom during play. A level may set a different default yaw or elevation (within the safe ranges in Formulas), fixed for that level.

**Framing**
4. One orthographic size per level, computed once at load so the whole board — footprint plus all `board_height` layers, including the spawn zone — fits inside the board's screen area (Board / Grid F5: about 57.5% of screen height, about 45% of width) at **every** one of the 12 yaws. Corner views are the widest; framing for them fits all angles. No zoom change happens when the view turns.
5. The board is centred in its screen area; HUD plates and thumb zones never overlap it (art bible §7, Touch Controls rule 4).

**Rotate-view**
6. `rotate_view(+1)` / `rotate_view(−1)` turn the yaw one 30° step clockwise / anticlockwise. The turn animates over `turn_anim_ms`; logically it is instant, so input mapping switches at once.
7. Holding the rotate-view button repeats steps using Touch Controls F3 timings. A half-turn (6 steps = 1 press + 5 repeats) takes about 600 ms of holding (240 + 4 × 90 ms).
8. Optional board-drag orbit (Touch Controls, off by default) moves the yaw continuously while dragging and snaps to the nearest of the 12 steps on release.
9. Turning never moves the piece or the board; only the view changes.

**Screen-to-world mapping (for Touch Controls)**
10. The camera publishes the **current yaw** and, for each of the four screen directions (left, right, up, down), the **world ground direction** (±x or ±z) whose on-screen projection is closest to it. Each screen direction gets a different world direction.
11. At yaws where two world directions are equally close to a screen direction (the corner views, where the axes appear diagonal), the mapping uses a fixed tie rule: screen-right = the world direction that appears up-right, screen-left = down-left, screen-up = up-left, screen-down = down-right. This stays consistent across all four corner views.

**Occlusion aid (per level)**
12. Level Data picks one mode; default **Fade**:
    - **Fade:** any locked block whose cell is crossed by a line from the centre of any cube of the falling piece or its landing ghost toward the camera (along the view direction) becomes see-through (alpha `fade_alpha`) with its outline kept. Blocks return to full opacity when no longer in front.
    - **Cutaway:** every layer above the landing ghost's top layer is hidden (or drawn as outlines only); the falling piece is always drawn.
    - **Ghost only:** no fading or cutaway; the landing ghost plus a highlighted column outline (the footprint cells under the piece) carry the information.
13. Whatever the mode, the falling piece, its landing ghost and the height-limit line are never hidden or faded.

**Juice**
14. Camera shake and punch (for clears, item hits) are short offsets only, never rotations or zooms that change the framing; they respect reduced motion (art bible §7) and are owned by Game Feel & VFX.

### States and Transitions

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **Framing** | Computes the orthographic size and default pose from the board | Level loads (board Setup) | Done → Idle |
| **Idle** | Still at one of the 12 yaws | Framing done; turn finished | `rotate_view` → Turning; drag-orbit → Orbiting |
| **Turning** | Animating one or more 30° steps; mapping already switched | `rotate_view` | Animation ends → Idle |
| **Orbiting** | Optional drag-orbit in progress | Board drag with orbit on | Release → Turning (snap to nearest step) |
| **Frozen** | Pose fixed; rotate-view and orbit input ignored (pause, results, cutscene) | Mode ends or pause | Resume → Idle; next level → Framing |

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Board / Grid | → Camera | Footprint size, mask, `board_height`, height-limit layer, cell contents (for occlusion) |
| Touch Controls | ↔ | `rotate_view(±1)`, drag-orbit; camera returns current yaw and the screen-to-world direction map |
| Movement & Rotation, Fall/Drop/Lock | → Camera | Falling piece and ghost positions (for occlusion) |
| Level Data & Definition | → Camera | Occlusion mode, optional default yaw/elevation |
| HUD | ↔ | Board screen rectangle; HUD stays outside it |
| Game Feel & VFX | → Camera | Shake and punch requests |
| Local Multiplayer Setup | → Camera | Later: one camera per board or split views |

## Formulas

All values are starting defaults to tune in the prototype.

### F1. View yaw

The view_yaw formula is defined as:

`yaw = (yaw_offset + 30° × k) mod 360°`, k = 0…11

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| k | int | 0–11 | calculated | Current view step |
| yaw_offset | float | 0–29° | data file | Offset of step 0; default 45° (mod 30 = 15°) so corner views are k = 0, 3, 6, 9 |
| yaw | float | 0–359° | calculated | Camera yaw around the board centre |

**Output Range:** 12 values, 30° apart. **Example:** k = 4 → 45 + 120 = 165°.

### F2. Orthographic framing size

The ortho_size formula is defined as:

`ortho_h = max( H_screen_world , W_screen_world / aspect_area )`, with
`W_screen_world = max over the 12 yaws of ( W × |cos yaw| + D × |sin yaw| )`,
`H_screen_world = (W_screen_world × sin(elev)) + (board_height × cos(elev))`; `margin` (in cells) is added to both W_screen_world and H_screen_world **before** the aspect comparison. On-screen cube edge = `cos(elev) × S_h × f / ortho_h` (the vertical edge, identical at every yaw in orthographic projection).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| W, D | int | 4–8 | data file (Board) | Footprint width and depth in cells |
| board_height | int | 7–20 | calculated (Board F4) | Layers drawn, including the spawn zone |
| elev | float | 25–40° | data file | Camera elevation above horizontal; default 30° (2:1 dimetric) |
| aspect_area | float | ~1.7 | calculated | Width / height of the board's screen area (≈ 0.45 × 2532 / 0.575 × 1170) |
| margin | float | 0.3–1.0 cells | data file | Breathing room around the board; default 0.5 |
| ortho_h | float | world units | calculated | Orthographic view height that fits the board at every yaw |

**Output Range:** depends on board size; the result must keep the cube edge ≥ 20 px (target ≥ 28 px, Board F5).
**Example:** 8 × 8 × 16, elev 30°: W_screen = 8 × (cos 45° + sin 45°) ≈ 11.3; H_screen ≈ 11.3 × 0.5 + 16 × 0.87 ≈ 19.5 → plus margin ≈ 20.0–20.5 world units tall; 670 px / 20.5 ≈ 32.7 px per world unit, so the vertical cube edge = 0.87 × 32.7 ≈ 28 px, consistent with Board F5.

### F3. Direction mapping

The direction_map formula is defined as:

For each screen direction `s` in {left, right, up, down}: `world(s) = argmin over g in {+x, −x, +z, −z} of angle( project(g, yaw), s )`; ties (within 0.5° of exactly 45°) use Core Rule 11.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| yaw | float | 12 values | calculated (F1) | Current yaw |
| project(g, yaw) | 2D vector | — | calculated | On-screen direction of world ground direction g |
| world(s) | enum | ±x, ±z | calculated | World direction a screen direction moves the piece |

**Output Range:** a one-to-one map of 4 screen directions to 4 world directions. **Example:** at yaw 75°, the +x axis appears 15° off screen-right, so screen-right → +x.

### F4. Turn animation and fade

| Value | Range | Default | Source | Meaning |
|---|---|---|---|---|
| turn_anim_ms | 100–250 | 150 | data file | Animation per 30° step (reduced motion: 0, instant cut) |
| fade_alpha | 0.15–0.5 | 0.3 | data file | Opacity of blocks in front of the piece in Fade mode |
| fade_ms | 60–150 | 100 | data file | Fade in/out time |
| max_faded_blocks | 20–64 | 40 | data file | Above this many faded blocks in one frame, Fade falls back to Cutaway for that frame |

## Edge Cases

- **If rotate-view is pressed during a turn animation**: the step is applied at once from the current *logical* step (k ± 1), so pressing the opposite direction reverses the turn; the animation continues to the new target (no queueing lag, no skipped steps).
- **If a drag is in progress in Touch Controls when the view turns**: Touch Controls ends the drag (its edge case); the camera does not wait.
- **If the board is masked to a non-square shape**: framing uses the footprint's bounding box (W × D), so it still fits at every yaw.
- **If a level's board would make the cube edge smaller than 20 px**: the level fails validation (Board / Grid F5); the camera never zooms out past it.
- **If a twist flips the board's down axis**: the camera does not flip; the board's "top" is now at the bottom of the screen and the spawn zone moves with it (Board / Grid edge case). Framing already includes the full height, so nothing moves.
- **If Fade mode and the falling piece is behind a tall wall of blocks**: all blocks on the camera-to-piece and camera-to-ghost lines fade; if that would fade more than `max_faded_blocks` (default 40), the camera falls back to Cutaway for that frame to avoid a see-through mess.
- **If Cutaway mode and the ghost is at the floor**: everything above layer 0 is hidden except the falling piece; the stack is shown as outlines so the player keeps context.
- **If reduced motion is on**: turns are instant cuts (turn_anim_ms = 0); shake and punch are off; fades still happen (they are not motion).
- **If the app is paused during a turn**: the turn completes instantly to its target step before the pause menu shows.
- **If two players' boards share a screen (later)**: each board has its own camera and its own yaw; one player's turn never turns another's view.

## Dependencies

**Upstream (this system depends on):**
| System | Hard / soft | Interface |
|---|---|---|
| Board / Grid | Hard | Footprint, mask, board_height, cell contents, height-limit layer |
| Level Data & Definition | Soft | Occlusion mode and optional pose; defaults otherwise |

**Downstream (depend on this system):**
| System | Hard / soft | Interface |
|---|---|---|
| Touch Controls | Hard | Current yaw and screen-to-world direction map; accepts `rotate_view` |
| Movement & Rotation | Hard | Uses the direction map (via Touch Controls) |
| HUD | Soft | Board screen rectangle |
| Game Feel & VFX | Soft | Applies shake/punch through the camera |
| Local Multiplayer Setup | Soft | One camera per board |

Board / Grid lists Camera as a downstream system (size and mask) — consistent. Touch Controls lists Camera as upstream for the view mapping — consistent, with its rotate-view step updated to 30° (see Cross-References).

## Visual/Audio Requirements

- The diorama look (art bible §6): the island body and underside are visible at the default elevation; backdrop stays low-contrast behind the board.
- Faded blocks keep their outline and hue at reduced opacity so the stack's shape stays readable; cutaway layers show as thin outlines.
- A small compass or view indicator (12 ticks, current one lit) sits near the rotate-view button so the player knows which way they face.
- Audio: a soft "whirr" per turn step (owned by Audio).

## Game Feel

Turning should feel like spinning a lazy Susan under a toy diorama: quick (150 ms per step), smooth, and never disorienting. The board stays centred and the same size at every angle, so the only thing that changes is the viewpoint. Mapping switches instantly, so a player can turn and move in one motion.

## UI Requirements

- Rotate-view button (56 pt, Touch Controls), with hold-to-repeat.
- View indicator: 12-tick compass showing the current step.
- Settings: reduced motion (instant turns), board-drag orbit on/off (Touch Controls).

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/board-grid.md` F5, Core Rules, Edge Cases | Projection assumption, screen share, cube-size floor, down-axis flip |
| `design/gdd/touch-controls.md` Rules 2, 4; F3 | Screen-relative mapping, no input on board, hold-repeat timings; its rotate-view step is 30° (updated with this GDD) |
| `design/art/art-bible.md` §6, §7 | Diorama look, landscape layout, reduced motion |
| `design/gdd/piece-set.md` | Ghost and falling piece drawn above occlusion |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device. Defaults: 8 × 8 × 16 board, elevation 30°, margin 0.5, reference phone 2532 × 1170.

**Projection and pose**
1. [U] **GIVEN** any loaded level, **WHEN** the camera is built, **THEN** the projection is orthographic and elevation is 30° (unless the level overrides it).
2. [U] **GIVEN** yaw_offset 45°, **WHEN** k runs 0–11, **THEN** there are 12 yaws 30° apart and the corner views (axes diagonal) are exactly k = 0, 3, 6, 9.
3. [U] F1: k = 4 → 165°; k = 0 → 45°; k = 11 → 15°.
4. [I] **GIVEN** 10 minutes of play with turns, clears and shakes, **WHEN** sampled every frame, **THEN** elevation and orthographic size never change.

**Framing (F2)**
5. [U] **GIVEN** 8 × 8 × 16, **WHEN** ortho_h is computed, **THEN** W_screen ≈ 11.3 and the result is 20.0–20.5 world units.
6. [U] **GIVEN** that board, **WHEN** projected at all 12 yaws, **THEN** all bounds, including the spawn zone, lie inside the board's screen area.
7. [M] **GIVEN** the reference phone, **WHEN** viewed at all 12 yaws, **THEN** the vertical cube edge measures ≥ 28 px (target); 20–28 px is a warning; below 20 px fails.
8. [U] **GIVEN** a level whose cube edge would be below 20 px, **WHEN** validated, **THEN** it fails; the camera never zooms out past it.
9. [U] **GIVEN** a masked board, **WHEN** framed, **THEN** framing uses the W × D bounding box and fits at every yaw.

**Rotate-view**
10. [U] **GIVEN** Idle, **WHEN** `rotate_view(+1)` or `(−1)`, **THEN** k changes by ±1 mod 12 and the direction map switches in the same frame.
11. [I] **GIVEN** a turn (150 ms default), **WHEN** it completes, **THEN** the state returns to Idle and piece and board positions are unchanged.
12. [I] **GIVEN** a turn in progress, **WHEN** rotate is pressed again (either direction), **THEN** k updates at once from the logical step and the animation retargets with no queue and no skipped step.
13. [M] **GIVEN** the rotate-view button held, **WHEN** held 600 ms (±50 ms), **THEN** 6 steps have occurred.
14. [I] **GIVEN** board-orbit on, **WHEN** a drag is released, **THEN** yaw snaps to the nearest of the 12 steps; **GIVEN** orbit off (default), **THEN** board drags do not turn the view.
15. [I] **GIVEN** a turn in progress, **WHEN** pause opens, **THEN** the turn completes instantly before the menu shows; while Frozen, rotate input is ignored.
16. [U] **GIVEN** a down-axis flip, **WHEN** it occurs, **THEN** camera yaw, elevation and size are unchanged.

**Direction map (F3)**
17. [U] **GIVEN** each of the 12 yaws, **WHEN** mapped, **THEN** screen left, right, up and down map to four different world directions.
18. [U] **GIVEN** yaw 75°, **THEN** screen-right → +x.
19. [U] **GIVEN** k = 0, 3, 6, 9, **THEN** the tie rule gives right = up-right, left = down-left, up = up-left, down = down-right, consistently in all four corner views.

**Occlusion (F4)**
20. [I] **Fade:** **GIVEN** a locked block crossed by the line from a piece or ghost cube toward the camera, **THEN** it fades to alpha 0.3 over 100 ms with its outline kept, and returns to full when no longer crossed.
21. [I] **Fade fallback:** **GIVEN** 41 blocks to fade in one frame, **THEN** that frame uses Cutaway; at 40 or fewer it stays Fade.
22. [I] **Cutaway:** **GIVEN** the ghost's top layer L, **THEN** layers above L are hidden or outlined and the piece is drawn; at L = 0, everything above layer 0 shows as outlines.
23. [I] **Ghost only:** **GIVEN** that mode, **THEN** nothing fades or is cut away, and the footprint column outline under the piece is shown.
24. [I] **GIVEN** any mode, **THEN** the falling piece, ghost and height line stay at full opacity and visible every frame.

**Juice and reduced motion**
25. [I] **GIVEN** shake or punch, **THEN** offsets are translation only and criteria 5–6 still pass.
26. [I] **GIVEN** reduced motion, **THEN** turns are instant cuts and shake/punch are off; fades still run.

**Multiplayer**
27. [I] **GIVEN** two boards, **WHEN** board A's view turns, **THEN** board B's yaw is unchanged.

## Open Questions

- **12 steps vs readability**: are the in-between angles (non-corner) as readable as corner views at 28 px, or do they create confusing near-edge-on faces? Prototype; fall back to corner views only if needed.
- **Elevation**: is 30° (2:1 dimetric) right for an 8 × 8 × 12 stack, or does a steeper look help see inside? Prototype 30° vs 35–40°.
- **Fade threshold**: is 40 faded blocks the right fallback point to Cutaway?
- **Local multiplayer**: one shared camera or one per board on a split screen (Local Multiplayer Setup).
