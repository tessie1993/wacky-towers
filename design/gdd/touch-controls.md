# Touch Controls

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Readable Chaos; Comeback Energy

## Summary

Touch Controls turn thumbs into piece commands — move, rotate on three axes (spin, tilt, roll), soft/hard drop, rotate the view, and use items — in landscape on a phone. Two candidate schemes go to a prototype: **Twin Pads** (on-screen buttons) and **Drag & Flick** (gestures in side zones beside the board), with optional axis-ring hints for learning; measured playtest targets pick the default. Both keep fingers off the board, follow the screen after view changes, need only one finger, and let any move be undone until the piece locks.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `None`

## Overview

Touch Controls turn thumbs into piece commands: move the falling piece across the footprint, rotate it about three axes, soft- and hard-drop it, rotate the view, and (later) fire items and skills. It is the concept's biggest usability risk — 3D rotation on a phone — so this GDD defines **two candidate schemes to prototype side by side** rather than one final answer: **A. Twin Pads** (on-screen buttons: d-pad plus rotation diamond) as the precise, learnable benchmark, and **B. Drag & Flick** (drag and flick gestures in side zones beside the board) as the candidate for the final feel. A third idea, **Grab & Gizmo** axis rings, is kept as an optional learning overlay for both. Both schemes share one set of rules: input never covers the board, everything follows the screen (left stays left after rotate-view), every action is one finger with no chords, and nothing is final until the piece locks. The prototype's measured results (see Acceptance Criteria) pick the default scheme; the other may stay as an option. This system serves *Readable Chaos* (the board stays visible and the controls stay predictable under pressure) and *Comeback Energy* (a trailing player must be able to act fast and accurately). All values are starting defaults.

## Detailed Design

### Core Rules

**Shared rules (both schemes)**
1. **Commands, not physics.** Controls emit discrete commands — `move(dir)`, `rotate(axis, ±90°)`, `soft_drop(on/off)`, `hard_drop`, `rotate_view(±1)` (one 30° step, Camera & Rotate-View), `use_item(slot)`, `use_skill(slot)`. Movement & Rotation and Fall/Drop/Lock decide whether a command succeeds.
2. **Screen-relative mapping.** "Left/right/up/down" are screen directions. They are re-mapped to world ±x / ±z using the camera's direction map (Camera & Rotate-View F3) every time the view turns, so left always moves the piece toward the world direction that looks most like screen-left.
3. **Rotation axes named in screen terms.** Yaw = **spin** (about the vertical axis), pitch = **tilt** (about the screen-horizontal axis, "toward/away from me"), roll = **roll** (about the view axis). Every rotation is a 90° step about a **world** axis: spin = the vertical axis; tilt = the horizontal world axis closest to screen-horizontal (from the camera's direction map); roll = the other horizontal world axis. The UI never shows x/y/z.
4. **Fingers off the board.** No gameplay input starts on the board's screen area. The board shows only the piece, the landing ghost and (optionally) the axis gizmo.
5. **Thumb zones (landscape, default right-handed).** Rotate and drop sit in the **right** thumb arc; movement in the **left** thumb arc; items and skills in a tap-only strip on the **left** side, away from movement; rotate-view is a 56 pt button at the top of the right zone. A **left-hand mirror** setting swaps the sides.
6. **One finger, no chords.** Every action works with a single touch. Two simultaneous touches are allowed (move with one thumb while rotating with the other) but never required.
7. **Undo until lock.** Any move or rotation can be reversed until the piece locks (the opposite command). Lock timing belongs to Fall/Drop/Lock.
8. **Feedback on every command.** Landing ghost always on; on rotation, the axis gizmo flashes on the pivot (shape- and colour-coded); optional haptic tick on move, pulse on rotate, stronger pulse on lock; a failed command (blocked move or rotation) gives a short "bonk" (no movement, small shake respecting reduced motion).
9. **Progressive disclosure.** The first levels enable one rotation axis (spin); tilt and roll are introduced one at a time over early levels (Onboarding). Disabled axes' controls are hidden, not greyed.

**Scheme A — Twin Pads (buttons)**

| Input | Action |
|---|---|
| Left thumb: 4-way d-pad (each arm ≥ 56 pt) | Tap = move 1 cell; hold = repeat |
| Right thumb: rotation diamond — up/down | Tilt away / toward |
| Rotation diamond — left/right | Spin left / right |
| Two roll arcs above the diamond | Roll left / right |
| 64 pt drop button below the diamond | Quick tap (release < tap threshold) = hard drop; hold = soft drop |
| Item/skill strip above the d-pad | Tap = use |

Each rotation button's arrow shows the on-screen motion the piece will make.

**Scheme B — Drag & Flick (gestures in side zones)**

| Input | Action |
|---|---|
| Left side zone (free space left of the board, ≥ 120 pt wide): drag | Move — the drag vector is projected onto the two on-screen ground axes; 1 cell per `drag_px_per_cell` of projected travel; the piece snaps with the ghost |
| Right side zone: flick (fast, short) | Horizontal flick = spin; vertical flick = tilt |
| Two 56 pt roll arcs in the right zone | Roll left / right |
| 64 pt drop button in the right zone | Tap = hard drop; hold = soft drop |
| Item/skill strip, left side above the drag zone | Tap = use |

Drag vs. flick is decided at release by speed and distance (Formulas F2). Flick direction must fall within a cone around horizontal or vertical; diagonal flicks are ignored.

**Learning overlay — Grab & Gizmo rings (optional, both schemes)**
- An option (on by default during onboarding) that shows three axis rings around the falling piece's pivot when a rotation control is touched, highlighting the ring that rotation will use. The rings are a visual aid only; they are never touch targets.

**One-handed mode (accessibility option)**
- All controls move into one cluster in the dominant hand's corner, using the Scheme A layout compacted: d-pad, rotation diamond and drop button share the arc; roll and rotate-view sit above it; items move to a tap-only row along the top of the cluster. Fall speed can optionally be slowed (Onboarding & Accessibility). Not part of prototype selection; tested separately.

**Board-area gestures**
- Off by default. An optional setting allows one-finger drag on the board to rotate the view (camera orbit snaps to the nearest of the 12 views, 30° apart). Off by default to avoid accidental orbits.

### States and Transitions

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **Disabled** | Input ignored (menus, cutscene, round over) | Level not running; mode ends | Level becomes Live |
| **Ready** | Accepting commands for the falling piece | A piece spawns | Piece locks → Waiting; pause → Paused |
| **Waiting** | Between lock and next spawn; commands are buffered for at most `input_buffer_ms` and applied to the new piece (rotate and move only, never hard drop) | Piece locks | Next piece spawns → Ready |
| **Paused** | Only the pause menu takes input | Pause button or app backgrounded | Resume → Ready |

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Movement & Rotation | Touch → | `move(dir)`, `rotate(axis, ±90°)`; returns success or blocked (for feedback) |
| Fall, Drop & Lock | Touch → | `soft_drop`, `hard_drop`; returns lock events (end of Ready) |
| Camera & Rotate-View | ↔ | `rotate_view(±1)`; current yaw and screen-to-world direction map |
| Board / Grid | ← | Board screen rectangle (the no-input area) |
| Piece Set | ← | Shape and spawn orientation for the ghost and gizmo |
| Items, Skills | Touch → | `use_item(slot)`, `use_skill(slot)` |
| HUD | ↔ | Button positions and sizes share the safe areas; HUD plates stay at the top edge |
| Onboarding & Accessibility | → Touch | Enabled axes, left-hand mirror, one-handed mode, sensitivity, hold-vs-tap, haptics, reduced motion, scale |
| Local Multiplayer Setup | → Touch | Which player owns which device or screen region (later) |

## Formulas

All values are starting defaults for the prototype to tune; every one is a player-adjustable sensitivity setting within its range unless marked constant.

### F1. Drag to cells (Scheme B movement)

The drag_cells formula is defined as:

`cells_total = sign(p) × floor( (|p| − dead_zone_px) / drag_px_per_cell )` when `|p| > dead_zone_px`, else 0, where `p` is the total drag travel since touch-down, projected onto one on-screen ground axis. The dead zone applies **once per drag**. Each frame the piece moves `cells_total − cells_already_moved` steps. Both ground axes are computed; the axis with the larger `|p|` wins each step to avoid diagonal drift.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p | float | any | calculated | Total drag travel along one ground axis, in px, since touch-down |
| dead_zone_px | float | 8–16 | data file | Travel ignored at drag start (default 12) |
| drag_px_per_cell | float | 36–56 | data file | Travel per one-cell step (default 44) |
| cells_total | int | −7 to +7 | calculated | Cells moved by this drag so far; capped by the board (8 wide) |

**Output Range:** −7 to +7 per drag on the default 8 × 8 board; blocked steps stop at the obstacle.
**Example:** a 150 px drag along the screen-right ground axis: (150 − 12) / 44 = 3.1 → 3 cells right.

### F2. Gesture classification (tap / flick / drag / hold)

The gesture_class formula is defined as:

- `tap` if `t < tap_ms` and `d < flick_min_px`
- `flick` if `t < flick_ms` and `d ≥ flick_min_px` and the angle to the nearest of horizontal or vertical is ≤ `flick_cone_deg` (inclusive)
- `hold` if the touch stays down ≥ `hold_ms` with `d < dead_zone_px`
- `drag` otherwise

Zones decide which classes count: in the **left (move) zone** only `drag` acts (a tap or flick there does nothing); in the **right (rotate) zone** only `flick` acts; on **buttons** only `tap` and `hold` act.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| t | float | ms | calculated | Touch duration (down to up) |
| d | float | px | calculated | Distance from touch-down to touch-up |
| tap_ms | float | 180–250 | data file | Max duration of a tap (default 200) |
| flick_ms | float | 150–250 | data file | Max duration of a flick (default 200) |
| flick_min_px | float | 60–90 | data file | Min distance of a flick (default 70) |
| flick_cone_deg | float | 25–35 | data file | Allowed deviation from horizontal/vertical (default 30) |
| hold_ms | float | 150–250 | data file | Time before a press counts as a hold (default 200; drop button: hold = soft drop) |

**Output Range:** one of tap / flick / hold / drag / ignored.
**Example:** a 140 ms, 85 px swipe at 20° from horizontal in the right zone → flick → spin.

### F3. Hold-to-repeat (Scheme A d-pad and rotate buttons when hold-repeat is on)

The repeat_count formula is defined as:

`repeats = 0` if `t < repeat_delay_ms`, else `1 + floor( (t − repeat_delay_ms) / repeat_interval_ms )`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| t | float | ms | calculated | How long the button has been held |
| repeat_delay_ms | float | 180–300 | data file | Delay before the first repeat (default 240) |
| repeat_interval_ms | float | 60–120 | data file | Time between repeats (default 90) |
| repeats | int | ≥ 0 | calculated | Extra steps after the initial press |

**Output Range:** 0 and up; a held d-pad crosses the 8-wide board (7 steps: 1 press + 6 repeats) in about 240 + 5 × 90 = 690 ms at defaults.
**Example:** held 600 ms → 1 + floor(360 / 90) = 5 repeats → 6 cells in total.

### F4. Input buffer and rotation animation (constants for the prototype)

| Value | Range | Default | Source | Meaning |
|---|---|---|---|---|
| rotate_anim_ms | 80–160 | 120 | data file | Visual rotation length; the logical rotation happens instantly |
| input_buffer_ms | 0–150 | 100 | data file | How long a move or rotate pressed in the Waiting state (between lock and spawn) is kept for the next piece |
| one_cell_screen_px | — | ≈ 56 px wide diamond | calculated (Board F5) | Cell footprint on screen at the default board; a fingertip covers 3–4 cells, which is why no input is on the board |

## Edge Cases

- **If a move or rotation is blocked** (wall, stack or obstacle): the command fails, the piece does not move, and a "bonk" plays (short shake, respecting reduced motion; optional haptic). Wall kicks, if any, are Movement & Rotation's decision.
- **If the view rotates while a drag is in progress** (Scheme B): the drag ends at the rotation; the next drag uses the new mapping. A committed step is never re-interpreted.
- **If the player presses rotate during the rotation animation**: it is applied immediately, because logical rotations are instant and only the animation lags; several presses are applied in order and never lost or merged. (`input_buffer_ms` applies only to the Waiting state.)
- **If hard drop is pressed during Waiting** (between lock and spawn): it is ignored, never buffered, so a double-tap cannot hard-drop two pieces.
- **If a touch starts on the board area**: it is ignored (unless the optional board-orbit setting is on, in which case it can only rotate the view).
- **If a touch starts in a zone and slides into another zone or onto the board**: the gesture belongs to the zone where it started; it ends when the finger lifts.
- **If two touches hit the same control**: the second is ignored until the first lifts.
- **If a flick is diagonal** (outside the cone): it is ignored, with no rotation, and with a subtle "?" hint the first 3 times per session during onboarding.
- **If a drag is slower than a flick but shorter than one cell**: it is a drag of 0 cells — nothing happens (no accidental flick).
- **If the app is backgrounded or a phone call arrives**: the game pauses immediately; all touches are cancelled; nothing is buffered across the pause.
- **If a rotation axis is disabled by the level (progressive disclosure)**: its controls are hidden; its flick direction is ignored.
- **If the left-hand mirror is on**: zones swap sides; screen-direction mapping is unchanged (left still moves left).
- **If the screen is very small or the HUD scale is 150%**: controls keep their minimum sizes (44 pt, play controls 56 pt) and the board shrinks first; if the cube edge would drop below 20 px, the game warns in Settings.

## Dependencies

**Upstream (this system depends on):** none required to accept input. It reads the board's screen rectangle (Board / Grid) and the direction map (Camera & Rotate-View) when available.

**Downstream (depend on this system):**

| System | Hard / soft | Interface |
|---|---|---|
| Movement & Rotation | Hard | `move`, `rotate` commands; success/blocked result for feedback |
| Fall, Drop & Lock | Hard | `soft_drop`, `hard_drop`; lock events |
| Camera & Rotate-View | Hard | `rotate_view(±1)`; direction map |
| Items, Skills | Hard | `use_item`, `use_skill` |
| HUD | Soft | Shares safe-area layout |
| Local Multiplayer Setup | Hard | Per-player input ownership |
| Onboarding & Accessibility | Hard | Settings and progressive disclosure that configure this system |

Board / Grid and Piece Set do not list Touch Controls; that is correct (they don't depend on it). Each downstream GDD must list Touch Controls when written.

## Visual/Audio Requirements

- Control art follows the art bible §7: pill and plate shapes, ink outlines, springy press squash (150–250 ms), biome frame trim only on plate edges.
- Rotation buttons show arrows of the on-screen motion, never x/y/z letters.
- Axis gizmo: three shape-coded rings or arrows (e.g. solid, dashed, dotted) as well as colour-coded, so colour is never the only cue.
- Gesture side zones in Scheme B are invisible during play but show a soft outline during onboarding and in Settings.
- Audio: a soft click per move, a whoosh per rotation, a dull bonk on blocked commands, a thunk on hard drop. Sounds are owned by Audio; this system only fires the events.

## Game Feel

Controls should feel snappy and trustworthy: every touch produces a visible result in under 50 ms, nothing moves that the player did not command, and mistakes are cheap until lock. Targets: input-to-movement latency under 50 ms; rotation animation 120 ms but logically instant; a full-board cross in under 0.7 s by holding (A) or one drag (B).

## UI Requirements

- Scheme A: d-pad, rotation diamond, two roll arcs, drop button, rotate-view button, item/skill strip.
- Scheme B: two invisible side zones, two roll arcs, drop button, rotate-view button, item/skill strip.
- Settings: scheme choice, left-hand mirror, one-handed mode (all controls in one corner cluster), sensitivity (drag px per cell, flick thresholds, repeat timings), hold vs tap, haptics on/off, gizmo overlay on/off, board-orbit on/off, control scale 100–150%.

📌 **UX Flag — Touch Controls**: run `/ux-design` for the in-play control layout and the controls settings screen before implementation.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/art/art-bible.md` §7 | Landscape default, thumb zones, target sizes, item placement, left-hand mirror, reduced motion, scale |
| `design/gdd/board-grid.md` F5 | Cube size (~28 px) and cell footprint on screen (~56 px), which rule out on-board input |
| `design/gdd/piece-set.md` Core Rules 9–10 | 90° rotations on three axes; spawn orientation |
| `design/gdd/camera-rotate-view.md` F1, F3 | 12 view steps of 30°; screen-to-world direction map |
| `design/gdd/game-concept.md` | Touch-controls risk; prototype-first recommendation |

## Acceptance Criteria

**[U]** = unit test, **[I]** = integration / automated input test, **[M]** = manual, device or playtest. Default values from Formulas.

**Shared rules**
1. [I] **GIVEN** each of the 12 camera yaws, **WHEN** the player moves left, **THEN** the piece moves in the world direction the camera's direction map gives for screen-left, and on screen it moves leftward (within 45° of screen-left).
2. [I] **GIVEN** board-orbit off, **WHEN** a touch starts on the board area, **THEN** no command is sent; **GIVEN** board-orbit on, **THEN** that touch can only rotate the view.
3. [I] **GIVEN** the left-hand mirror on, **WHEN** the layout loads, **THEN** zones swap sides and "left" still moves the piece screen-left.
4. [I] **GIVEN** single-touch input only, **WHEN** every command is triggered, **THEN** each works; **GIVEN** a second touch on an already-held control, **THEN** it is ignored until the first lifts.
5. [U] **GIVEN** a move or rotation, **WHEN** the opposite command is sent before lock, **THEN** the piece returns to its previous position and orientation.
6. [I] **GIVEN** a blocked move or rotation, **WHEN** sent, **THEN** the piece does not move, a bonk event fires, and no shake plays if reduced motion is on.
7. [I] **GIVEN** a level with only spin enabled, **WHEN** it loads, **THEN** tilt and roll controls are hidden (not greyed) and tilt flicks are ignored.

**Scheme A**
8. [I] **GIVEN** Scheme A, **WHEN** each d-pad arm, diamond direction and roll arc is tapped, **THEN** it sends its mapped move or rotate command.
9. [U] **GIVEN** the drop button, **WHEN** released after 199 ms, **THEN** hard drop; **WHEN** held 200 ms, **THEN** soft drop.

**Scheme B**
10. [I] **GIVEN** Scheme B, **WHEN** the player drags in the left zone, **THEN** the piece moves; **WHEN** they flick horizontally or vertically in the right zone, **THEN** it spins or tilts; a tap or flick in the left zone does nothing; roll arcs and drop button behave as in Scheme A.

**Formulas**
11. [U] F1 (dead zone once per drag): 150 px → 3 cells; 12 px → 0; 55 px → 0; 56 px → 1; capped at ±7.
12. [U] F2: (140 ms, 85 px, 20°) → flick; (140 ms, 85 px, 30°) → flick; (140 ms, 85 px, 45°) → ignored; (150 ms, 10 px) → tap; (held 200 ms, 5 px) → hold.
13. [U] F3: held 239 ms → 0 repeats; 240 ms → 1; 600 ms → 5; 690 ms → 6 (a 7-cell cross).

**Edge cases**
14. [U] **GIVEN** Waiting, **WHEN** hard drop is pressed, **THEN** it is ignored and not buffered; **WHEN** move or rotate is pressed within 100 ms before spawn, **THEN** it applies to the new piece.
15. [U] **GIVEN** a rotation animation playing, **WHEN** rotate is pressed twice, **THEN** both rotations apply immediately, in order.
16. [I] **GIVEN** a drag in progress, **WHEN** the view rotates, **THEN** the drag ends and steps already taken are unchanged.
17. [I] **GIVEN** a touch starting in one zone, **WHEN** it slides into another zone or onto the board, **THEN** the starting zone owns it until the finger lifts.
18. [M] **GIVEN** a held touch, **WHEN** the app is backgrounded or a call arrives, **THEN** the game pauses, touches are cancelled and nothing is buffered across the pause.
19. [M] **GIVEN** the reference device at 150% control scale, **THEN** controls are ≥ 44 pt (play controls ≥ 56 pt), Scheme B zones ≥ 120 pt wide, and Settings warns if the cube edge is under 20 px.
20. [M] **GIVEN** a device test build, **WHEN** the player moves the piece, **THEN** touch-to-visible-move latency is under 50 ms (high-speed camera, 20 samples).

**Prototype selection [M]** — at least 8 testers per scheme, including at least 2 left-handed and 3 non-gamers. Placement time runs from spawn to lock.
- **P1** Median placement time ≤ 6 s (flat pieces) and ≤ 10 s (3D pieces).
- **P2** Misplacement ≤ 10% — a lock the tester marks as unintended (prototype "oops" button or think-aloud).
- **P3** Hard-drop errors ≤ 3% — hard drops the tester did not intend.
- **P4** ≤ 1 rotation error per piece — rotations beyond the minimum needed to reach the final locked orientation.
- **P5** 80% place a piece with a move and one rotation, unaided, within 60 s.
- **P6** 70% use all 3 axes correctly within 3 min.
- **P7** Camera-rotate confusion ≤ 5% — the first move after a view change goes the wrong way and is reversed within 1 s.
- **P8** Unintended view rotations < 1 per round.
- **P9** Occlusion complaints < 20%.
- **P10** Median ease ≥ 4 / 5.

**Decision rule:** the scheme passing more targets becomes the default; ties go to the faster 3D placement time. The **3D test** is P1 (3D) and P6 together: if neither scheme passes it, reduce rotation scope (fewer axes or smart rotate) before adding controls.

## Open Questions

- **Which scheme wins**: decided by the prototype against the targets in Acceptance Criteria; the loser may stay as an option.
- **Landscape vs portrait**: the art bible defaults to landscape but says to revisit after this prototype.
- **Roll**: is roll needed at all, or can most pieces be placed with spin and tilt? If roll is rarely used, it could move behind a secondary control.
- **Smart rotate**: if neither scheme meets the 3D targets, try reducing rotation scope (fewer axes, or an auto-fit rotate) before adding controls — a game-design call.
- **Lock delay and reset count**: owned by Fall, Drop & Lock; they strongly affect how forgiving these controls feel.
- **Item targeting**: items that need a target (a rival's board, a cell) — tap a rival's portrait, or drag-to-aim? Decide in Items.
- **4-player on one phone**: out of scope for this prototype (Local Multiplayer Setup).
- **Smallest supported device**: needed as the reference for the 150% scale check; the 6.1" 2532 × 1170 phone is the primary reference until then.

