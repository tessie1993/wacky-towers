# Camera & Rotate-View

> **Status**: Designed
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10 (against ADR-0007, ADR-0010, ADR-0012, ADR-0014)
> **Implements Pillar**: Readable Chaos; The Block Is the Constant

## Summary

The Camera shows the board as an orthographic toy diorama from a fixed angle, with the whole board always in frame at one zoom. The player can drag the view freely around the board, and on release it settles to the nearest of 12 steps of 30° (the four classic corner views are every third step, with one-press shortcuts); buttons step one snap at a time. The camera tells Touch Controls which world direction "screen-left" means after every turn. Each level picks an occlusion aid — fade blocks in front of the piece (default), a layer cutaway, or ghost only — so the falling piece, its ghost and the height line are never hidden.

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
4. One orthographic size per level **and per screen orientation**, computed at load (and again on an orientation change, rule 5a) so the whole board — footprint plus all `board_height` layers, including the spawn zone — fits inside the board's screen area for the current orientation (landscape and portrait each have their own board rectangle from the HUD layout; Board / Grid F5) at **every** one of the 12 yaws. Corner views are the widest; framing for them fits all angles. No zoom change happens when the view turns.
5a. **Portrait and landscape.** Both orientations are supported. If the phone is turned during a level, the game **pauses** (`ScreenLayout` → `AppFlow.request_pause(&"rotate")`, ADR-0014 §5), re-lays out the screen (board rectangle, controls), recomputes the framing, and waits for the player to tap Resume. The yaw step `k` is kept. Turning the phone in menus just re-lays out.
5. The board is centred in its screen area; HUD plates and thumb zones never overlap it (art bible §7, Touch Controls rule 4).

**Rotate-view**
6. `rotate_view(+1)` / `rotate_view(−1)` turn the yaw one 30° step clockwise / anticlockwise. The turn animates over `turn_anim_ms`; logically it is instant, so input mapping switches at once.
7. Holding the rotate-view button repeats steps using Touch Controls F3 timings. A half-turn (6 steps = 1 press + 5 repeats) takes about 600 ms of holding (240 + 4 × 90 ms).
8. **Free orbit + snap (always on; user decision 2026-10-10, ADR-0014 §3).** A board drag (touch drag that starts outside the control zones, mouse drag; on gamepad the right stick steps snaps instead, ADR-0012/0014) turns the view freely at `orbit_px_per_step` px per 30° (player sensitivity setting). **While dragging, the logical snap `k` and the direction map do not change**: moves and rotations still use the snap the drag started from. On release, `k` becomes the nearest **allowed** snap (rule 9a), the direction map switches at once (`view_changed`), and the view settles to it over `settle_ms`. **Corner shortcuts:** four actions jump straight to k = 0, 3, 6, 9 (or the nearest allowed snap under sideways gravity). **Invert** flips the sign of steps and drags. **Auto** (optional setting, ACC-21) may make at most one automatic turn per piece (gravity change, or a fully hidden ghost), never during a drag.
9. Turning never moves the piece or the board; only the view changes.
9a. **Sideways gravity.** When the board's down axis is a ground axis (±x or ±z; e.g. Level-Specific Mechanics M9, or a gravity twist), only the **side-on snaps** are allowed, so the piece falls across the screen rather than toward or away from the player. A snap is side-on when the angle between the camera's horizontal view direction and the down axis is at least `side_on_min_deg` (default 45°, inclusive) from both parallel directions. With the default yaws this allows 8 of the 12 snaps (all four corner views included) and skips the 4 that look almost along the fall. `rotate_view` skips the disallowed snaps. If the current snap becomes disallowed when gravity changes, the camera turns to the nearest allowed snap (a normal animated turn). Up/down gravity (±y) allows all 12.

**Screen-to-world mapping (for Touch Controls)**
10. The camera publishes the **current yaw** and, for each of the four screen directions (left, right, up, down), the **world ground direction** (±x or ±z) whose on-screen projection is closest to it. Each screen direction gets a different world direction.
11. At yaws where two world directions are equally close to a screen direction (the corner views, where the axes appear diagonal), the mapping uses a fixed tie rule: screen-right = the world direction that appears up-right, screen-left = down-left, screen-up = up-left, screen-down = down-right. This stays consistent across all four corner views.

**Occlusion aid (per level)**
12. Level Data picks one mode; default **Fade**:
    - **Fade:** any locked block whose cell is crossed by a line from the centre of any cube of the falling piece or its landing ghost toward the camera (along the view direction) becomes see-through (alpha `fade_alpha`), and **its ink outline fades with it** to the same alpha, so faded blocks never draw a wireframe over the piece. Blocks return to full opacity when no longer in front.
    - **Cutaway:** every layer above the landing ghost's top layer is hidden (or drawn as outlines only); the falling piece is always drawn.
    - **Ghost only:** no fading or cutaway; the landing ghost plus a highlighted column outline (the footprint cells under the piece) carry the information.
13. Whatever the mode, the falling piece, its landing ghost and the height-limit line are never hidden or faded.

**Juice**
14. Camera shake and punch (for clears, item hits) are short offsets only, never rotations or zooms that change the framing; they respect reduced motion (art bible §7) and are owned by Game Feel & VFX.

### States and Transitions

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **Framing** | Computes the orthographic size and default pose from the board | Level loads (board Setup) | Done → Idle |
| **Idle** | Still at one of the 12 yaws | Framing done; turn or settle finished | `rotate_view` / corner shortcut → Turning; board drag → Orbiting |
| **Turning** | Animating to a target snap (step, shortcut or settle); mapping already switched | `rotate_view`, corner shortcut, orbit release | Animation ends → Idle; board drag → Orbiting |
| **Orbiting** | Free drag in progress; `k` and the map unchanged | Board drag | Release → `k` = nearest allowed snap, map switches → Turning (settle over `settle_ms`) |
| **Frozen** | Pose fixed; rotate-view and orbit input ignored (pause, results, cutscene) | Mode ends or pause | Resume → Idle; next level → Framing |

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Board / Grid | → Camera | Footprint size, mask, `board_height`, height-limit layer, cell contents (for occlusion) |
| Touch Controls / Input (ADR-0012) | ↔ | `rotate_view(±1)`, corner shortcuts, orbit drag and release; camera returns the settled snap `k` and the screen-to-world direction map (`view_changed`), which also resolves Turn/Flip/Roll to world axes |
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
| yaw_offset | float | 0–359° | data file | Yaw of step 0; default 45° so corner views are k = 0, 3, 6, 9 (only `yaw_offset mod 30` = 15° keeps corners on the grid; `view.yaw_offset_deg` stores 45) |
| yaw | float | 0–359° | calculated | Camera yaw around the board centre |

**Output Range:** 12 values, 30° apart. **Example:** k = 4 → 45 + 120 = 165°.

### F2. Orthographic framing size

The ortho_size formula is defined as:

`ortho_h = max( H_screen_world , W_screen_world / aspect_area )`, with
`W_screen_world = max over the 12 yaws of ( W × |cos yaw| + D × |sin yaw| )`,
`H_screen_world = (W_screen_world × sin(elev)) + (board_height × cos(elev))`; `margin` (in cells) is added to both W_screen_world and H_screen_world **before** the aspect comparison. On-screen cube edge = `cos(elev) × Sa_h / ortho_h` (the vertical edge, identical at every yaw in orthographic projection) — Board / Grid F5. The values are computed for the **orientation profile** in use (landscape or portrait).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| W, D | int | 4+ | data file (Board) | Footprint width and depth in cells |
| board_height | int | 7–20 | calculated (Board F4) | Layers drawn, including the spawn zone |
| elev | float | 25–40° | data file | Camera elevation above horizontal; default 30° (2:1 dimetric) |
| Sa_w, Sa_h | float | px | constant (profile, Board F5) | Board screen area. Landscape 1139 × 673 (45% × 57.5% of 2532 × 1170); portrait 1076 × 1139 (92% × 45% of 1170 × 2532). Placeholders until the HUD layout is set |
| aspect_area | float | landscape ~1.69, portrait ~0.94 | calculated | `Sa_w / Sa_h` |
| margin | float | 0.3–1.0 cells | data file | Breathing room around the board; default 0.5 |
| ortho_h | float | world units | calculated | Orthographic view height that fits the board at every yaw |

**Output Range:** depends on board size and profile; the result must keep the cube edge ≥ 20 px (target ≥ 28 px, Board F5). Landscape gives the smaller cube for every square board up to about 17 × 17, so it is the profile the readability check binds on.
**Example:** default 6 × 6 × 14, elev 30°: W_screen = 6 × (cos 45° + sin 45°) ≈ 8.49 (the 45° corner yaw is the widest of the 12); H_screen ≈ 8.49 × 0.5 + 14 × 0.866 ≈ 16.37 → plus margin ≈ 16.87 world units. Landscape: 673 / 16.87 ≈ 39.9 px per unit (width 1139 / 8.99 ≈ 127, not binding) → cube edge ≈ 34.5 px. Portrait: 1139 / 16.87 ≈ 67.5 (width 1076 / 8.99 ≈ 120, not binding) → ≈ 58.5 px. 8 × 8 × 16: ≈ 29.1 px landscape, ≈ 49.3 px portrait.

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
| side_on_min_deg | 30–60 | 45 | data file | Under sideways gravity, how far from the fall direction a snap's view must be to be allowed (rule 9a) |
| settle_ms | 0–300 | 150 | data file (knob) | Settle tween after an orbit release (reduced motion: 0) |
| orbit_px_per_step | 40–160 | 80 | player setting (sensitivity) | Drag distance per 30° of free orbit |

## Edge Cases

- **If rotate-view is pressed during a turn animation**: the step is applied at once from the current *logical* step (k ± 1), so pressing the opposite direction reverses the turn; the animation continues to the new target (no queueing lag, no skipped steps).
- **If a drag is in progress in Touch Controls when the view turns**: Touch Controls ends the drag (its edge case); the camera does not wait.
- **If the player moves or rotates the piece mid-orbit**: the command uses the map of the snap the drag started from; the map switches only on release.
- **If an orbit is released under sideways gravity near a disallowed snap**: it settles to the nearest allowed snap.
- **If a step button is pressed mid-orbit**: the drag ends as a release (settle to nearest allowed), then the step applies from that `k`.
- **If reduced motion is on during an orbit**: the drag still follows the finger (the player drives it); the release is an instant cut to the snap.
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
- Faded blocks keep their hue at reduced opacity and their outline fades with them (same alpha); the stack's shape stays readable from the faded fills. Cutaway layers show as thin outlines.
- A small compass or view indicator (12 ticks, current one lit) sits near the rotate-view button so the player knows which way they face.
- Audio: a soft "whirr" per turn step (owned by Audio).

## Game Feel

Turning should feel like spinning a lazy Susan under a toy diorama: quick (150 ms per step), smooth, and never disorienting. The board stays centred and the same size at every angle, so the only thing that changes is the viewpoint. Mapping switches instantly, so a player can turn and move in one motion.

## UI Requirements

- Rotate-view button (56 pt, Touch Controls), with hold-to-repeat.
- View indicator: 12-tick compass showing the current step.
- Four corner-view shortcuts (buttons/keys/gamepad, mapped in ADR-0012).
- Settings: reduced motion (`system`/`on`/`off`, follows the OS by default), invert, orbit sensitivity, Auto on/off (ADR-0013 persists them). Free orbit itself is always on.

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
14. [I] **GIVEN** a free board drag, **WHILE** dragging, **THEN** the view follows the drag, `k` and the direction map are unchanged and no `view_changed` / `view_snap` fires; **WHEN** released, **THEN** `k` becomes the nearest allowed snap, `view_changed` fires exactly once in the release frame, and the view settles within `settle_ms` (instantly under reduced motion).
14a. [I] **GIVEN** each corner shortcut, **THEN** `k` becomes 0, 3, 6 or 9 (or the nearest allowed snap under sideways gravity) and the map switches in the same frame.
15. [I] **GIVEN** a turn in progress, **WHEN** pause opens, **THEN** the turn completes instantly before the menu shows; while Frozen, rotate input is ignored.
16. [U] **GIVEN** a down-axis flip, **WHEN** it occurs, **THEN** camera yaw, elevation and size are unchanged.

**Direction map (F3)**
17. [U] **GIVEN** each of the 12 yaws, **WHEN** mapped, **THEN** screen left, right, up and down map to four different world directions.
18. [U] **GIVEN** yaw 75°, **THEN** screen-right → +x.
19. [U] **GIVEN** k = 0, 3, 6, 9, **THEN** the tie rule gives right = up-right, left = down-left, up = up-left, down = down-right, consistently in all four corner views.

**Occlusion (F4)**
20. [I] **Fade:** **GIVEN** a locked block crossed by the line from a piece or ghost cube toward the camera, **THEN** it fades to alpha 0.3 over 100 ms with its outline faded to the same alpha, and returns to full when no longer crossed.
20a. [U] **GIVEN** down axis −x, **WHEN** `rotate_view` steps through all snaps, **THEN** only the 8 side-on snaps are visited; **GIVEN** gravity changes to −x while at a disallowed snap, **THEN** the camera turns to the nearest allowed snap.
20b. [I] **GIVEN** a level in progress, **WHEN** the phone turns from landscape to portrait, **THEN** the game pauses, the framing is recomputed for the portrait board rectangle, `k` is unchanged, and the whole board fits at all allowed snaps.
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
- **Free orbit + snap (2026-10-10), open to playtest**: `orbit_px_per_step` 80 and `settle_ms` 150 are starting defaults.
- **Designer defaults of 2026-10-09, open to playtest**: side-on snaps only under sideways gravity (rule 9a, `side_on_min_deg` 45°); pause-and-re-layout on a phone turn (rule 5a); faded outlines (rule 12).
