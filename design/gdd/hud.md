# HUD (basic)

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Readable Chaos

## Summary

The MVP HUD is a thin strip of plates along the top edge of a landscape phone: goal and warnings on the left, the active-rule icons in the middle, and the next piece (shown as the real 3D piece) on the right above the rotate thumb. Everything else that matters during play — the height limit, the ghost, targets, danger — lives on the board itself, and the board's area is never covered.

> **Quick reference** — Layer: `Presentation` · Priority: `MVP` · Key deps: `Piece Spawner & Queue, Level Goals & Fail States`

## Overview

The HUD shows the player what they need to plan the next move without pulling their eyes off the board for long. Following the art bible (§7), information sits in themed plates along the top edge, controls sit in the bottom thumb arcs (Touch Controls), and in-world cues (height limit, danger line, landing ghost, target ribbons and outlines, status shells) stay on the board where the danger is. The MVP HUD has four groups: the **pause button** and **goal plate** (goal icon, progress, warnings left) top-left; the **rule strip** (icons of active twists, the level mechanic, buffs) top-centre with an optional level clock; and the **preview plate** (next piece, 1–3 deep, plus the hold slot when enabled) top-right, above the rotate thumb so the eye moves from the piece to the controls that turn it. A left-hand mirror swaps left and right. The HUD also owns the **danger state**: when the stack nears the limit, the plates take on a warm tint and the board's danger line pulses. Score, items and versus panels are added by their own GDDs later; their slots are reserved. This serves *Readable Chaos*: the board stays clear, and every number the player needs is in one predictable place. All values are starting defaults; detailed layout belongs to `/ux-design`.

## Detailed Design

### Core Rules

**Layout (landscape, right-handed default)**
1. Three zones: a **top band** for HUD plates, the **board area** in the centre (never covered by HUD or touch input; Board F5 gives it about 57.5% of screen height and 45% of width), and the **bottom thumb arcs** for controls (Touch Controls).
2. Top band, left to right:
   - **Pause** button (44 pt, top-left corner inside the safe area).
   - **Goal plate**: goal icon, progress as a number (e.g. `2 / 3`, `7 / 10`, `1:42`, `38 / 60`) and a thin bar (Level Goals F4); warning tokens (one per warning left).
   - **Rule strip** (centre): one 44 pt icon per active rule (framework rule 16), ordered by layer (mechanic, twists, buffs/debuffs, items); duration rules show a shrinking ring. The level clock appears here only when the goal is Survive, the level has a time limit, or the player turns it on.
   - **Preview plate** (top-right): the next piece as the real 3D piece in its spawn orientation from the gameplay camera angle (art bible §7), first plate ≥ 64 pt; with `preview_count` 2–3, further pieces stack below at ≥ 48 pt. The **hold plate** sits to the left of the preview when hold is enabled (Spawner).
3. **Left-hand mirror** (Touch Controls) swaps the left and right groups; the rule strip stays centred.
4. **Reserved slots** for later systems: score (Scoring & Stars) under the goal plate; item slots in the item strip (Touch Controls, left side); opponent mini-boards and player frames (Local Multiplayer Setup). The MVP leaves them empty without shifting the four groups.
5. Everything stays inside the safe-area insets; no HUD element overlaps the board's screen rectangle at any of the 12 view angles.

**Behaviour**
6. The HUD only displays; it never changes game state. Exceptions are taps: **pause** opens the pause menu; a **rule icon** tap shows its two-word name and one-line description for 1.5 s without pausing; the **hold plate** tap sends `hold` (when enabled).
7. Values update in the same frame as their source event (spawn, resolve, rule start/end, warning).
8. **Danger state**: when `stack_height()` is within `danger_margin` layers of the height limit (Formulas F2), the HUD plates take a warm tint and the in-world danger line (Board) pulses; the state clears when the stack drops. During a warning (Level Goals) the goal plate's warning token breaks with a pop.
9. HUD plates do not rotate with the camera; the preview piece is drawn from the gameplay camera's **current** yaw so it always matches the board.
10. With reduced motion, pop-ins and pulses become instant changes and static highlights.

### States and Transitions

| State | Shown | Enters when | Leaves when |
|---|---|---|---|
| **Hidden** | Nothing | Menus, Intro card | Countdown starts |
| **Countdown** | Goal plate, rule strip, preview (first piece) | Countdown | First spawn → Play |
| **Play** | Everything | First spawn | Pause / result |
| **Danger** | Play + warm tint, pulsing line | F2 true | F2 false |
| **Paused** | Dimmed HUD under the pause menu (full rule list) | Pause | Resume |
| **Result** | Hidden behind the result screen | Win / loss | Next level |

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Piece Spawner & Queue | → HUD | Preview pieces, held piece, hold availability; hold tap → Spawner |
| Level Goals & Fail States | → HUD | Goal, progress, warnings, clock, result |
| Rule-Twist Framework | → HUD | Active rules, icons, durations, start/end/blocked events |
| Board / Grid | → HUD | `stack_height()`, height limit (danger state), board screen rectangle |
| Camera & Rotate-View | → HUD | Current yaw for drawing the preview |
| Touch Controls | ↔ | Shared safe-area layout, left-hand mirror, control scale |
| Piece Set | → HUD | Hue, motif and shape for the preview |
| Scoring & Stars, Items, Local Multiplayer Setup | → HUD (later) | Reserved slots |
| Onboarding & Accessibility | → HUD | Reduced motion, scale, clock toggle |

## Formulas

### F1. Top band height

The top_band_height formula is defined as:

`band_pt = inset_top + max(preview_first_pt, plate_min_pt) + 2 × margin_pt`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| inset_top | float | 0–50 pt | device | Safe-area inset at the top in landscape |
| preview_first_pt | float | 64–96 | data file | First preview plate size; default 64 |
| plate_min_pt | float | 44–64 | data file | Other plates' height; default 48 |
| margin_pt | float | 4–16 | data file | Gap above and below plates; default 8 |

**Output Range:** about 80–130 pt. **Example:** reference phone (2532 × 1170 px at 3×, landscape 844 × 390 pt, top inset 0): 64 + 16 = 80 pt = 240 px, leaving 930 px below; the board needs about 670 px (Board F5), so it fits with about 260 px for the bottom arcs and margins.

### F2. Danger state

The danger_state formula is defined as:

`danger = stack_height() ≥ H_play − 1 − danger_margin`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| stack_height() | int | −1 to `board_height − 1` | calculated (Board) | Highest occupied layer |
| H_play | int | 6–12 | data file (Board) | Height limit layer index |
| danger_margin | int | 1–4 | data file | Layers of warning before the limit; default 2 |

**Output Range:** true / false. **Example:** `H_play = 12`, margin 2 → danger when the stack reaches layer 9 (three layers below the limit layer: 9, 10, 11 are the last safe ones).

### F3. Preview plate size for extra pieces

The preview_plate_size formula is defined as:

`size_i = max(48, preview_first_pt × 0.75^(i−1))` for preview position `i = 1..preview_count`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| i | int | 1–3 | calculated | Position in the preview |
| preview_first_pt | float | 64–96 | data file | First plate size |

**Output Range:** 48 pt up to `preview_first_pt`. **Example:** 64 → 64, 48, 48 pt.

## Edge Cases

- **If `preview_count = 0`**: the preview plate is hidden; its space stays empty (no reflow).
- **If hold is enabled mid-level** (perk, item): the hold plate pops in left of the preview.
- **If more than 6 rules are active**: the strip shows 5 icons and a "+N" chip; tapping it pauses and opens the full list.
- **If the device has a large top inset** (notch in landscape on one side): plates shift within the safe area; the board area shrinks first only if F1 leaves less than the board needs, and the validator's cube-size check (Board F5) still applies.
- **If the view rotates**: plates stay put; the preview piece re-renders from the new yaw within one frame.
- **If the stack is in danger during a gravity flip**: F2 uses the board's current re-indexed layers.
- **If a rule icon is tapped during a fast moment**: the label shows without pausing; it never covers the board.
- **If the left-hand mirror is on**: preview and hold go top-left, goal plate and pause top-right.
- **If HUD scale is 150%** (accessibility): plates grow; the clock and rule strip may move to a second row inside the top band; the board shrinks only within Board F5's limits.
- **If the level has no warnings** (`warnings_max = 0`): no tokens are shown.

## Dependencies

**Upstream:** Piece Spawner & Queue (Hard), Level Goals & Fail States (Hard), Rule-Twist Framework (Hard), Board / Grid (Hard: stack height, limit, board rectangle), Camera & Rotate-View (Soft: yaw for the preview), Piece Set (Soft), Touch Controls (Hard: shared layout).

**Downstream:** Onboarding & Accessibility (Hard: HUD settings), Scoring & Stars, Items, Local Multiplayer Setup, Menus (Soft: reserved slots and shared plate style).

## Tuning Knobs

| Knob | Range | Default | Affects |
|---|---|---|---|
| preview_first_pt | 64–96 | 64 | Preview readability vs. space (F1, F3) |
| plate_min_pt | 44–64 | 48 | Plate height |
| margin_pt | 4–16 | 8 | Band height |
| danger_margin | 1–4 | 2 | When the danger state starts (F2) |
| rule_strip_max_icons | 3–8 | 5 | Icons before the "+N" chip |
| show_clock | off / on | off (on for Survive or time limits) | Clock visibility |

## Visual/Audio Requirements

- Plates use the biome frame (wood with vines in the meadow) with parchment inserts and ink text (art bible §4, §7); display font for numbers with fixed-width digits; H2 24–28 pt for progress and clock, never below 18 pt.
- Preview plate: real 3D piece, slow idle turn disabled during play (static), lit like the board.
- Rule icons: hazard-orange frames for twists and mechanics, cyan and magenta chevrons for buffs and debuffs (art bible §4).
- Danger tint: warm darkening of plate edges, never the danger red fill (red stays on the board's line).
- Pop-ins 150–250 ms with a slight overshoot; frames never animate during play (art bible §7).
- Audio: the HUD makes no sounds of its own except a soft click on taps; events from other systems carry their sounds.

## Game Feel

The HUD should be glanceable: one look tells the player the goal, what's next and what rules are on. Targets: every update in the same frame as its event; preview readable in under 0.5 s; no HUD motion during play except pop-ins, the danger pulse and duration rings.

## UI Requirements

This whole GDD is a UI requirement. 📌 **UX Flag — HUD**: run `/ux-design hud` to produce `design/ux/hud.md` (exact positions, safe areas on target devices, mirror and 150% scale variants) before implementation.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/art/art-bible.md` §4, §7 | Top-band plates, 64 pt 3D preview, typography, frames, effect accents, animation timing |
| `design/gdd/board-grid.md` F5; Core Rule 10 | Board area share, height limit, stack height |
| `design/gdd/piece-spawner-queue.md` UI Requirements | Preview and hold plates (position set here: top-right) |
| `design/gdd/level-goals-fail-states.md` F4; UI Requirements | Goal, progress, warnings, clock |
| `design/gdd/rule-twist-framework.md` Core Rule 16; UI Requirements | Rule strip |
| `design/gdd/touch-controls.md` Core Rule 5; UI Requirements | Thumb zones, mirror, scale |
| `design/gdd/camera-rotate-view.md` F1 | Current yaw for the preview |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device.

1. [M] **GIVEN** the reference phone in landscape, **THEN** pause and goal plate are top-left, rule strip top-centre, preview top-right, all inside the safe area, and none overlaps the board rectangle at any of the 12 view angles.
2. [I] **GIVEN** the left-hand mirror, **THEN** the left and right groups swap and the rule strip stays centred.
3. [U] F1: no inset, 64 pt preview, 8 pt margins → 80 pt band; the board's 670 px fits below on the reference phone.
4. [U] F2: `H_play = 12`, margin 2 → danger at stack height 9, not at 8.
5. [U] F3: preview 3 deep at 64 → 64, 48, 48 pt.
6. [I] **GIVEN** a spawn, **THEN** the preview shows the new next piece in the same frame, drawn from the current camera yaw.
7. [I] **GIVEN** a rule starts or ends, **THEN** its icon appears or disappears in the same frame; 7 rules → 5 icons and "+2".
8. [I] **GIVEN** a rule icon tap, **THEN** its name and description show for 1.5 s and the game does not pause.
9. [I] **GIVEN** a warning, **THEN** a token breaks; **GIVEN** `warnings_max = 0`, **THEN** no tokens show.
10. [I] **GIVEN** `preview_count = 0`, **THEN** the preview plate hides and nothing else moves.
11. [I] **GIVEN** reduced motion, **THEN** pop-ins and pulses are instant and static.
12. [M] **GIVEN** a playtest, **THEN** testers can read the next piece and goal progress in under 0.5 s glances (think-aloud), and no tester reports the HUD covering the board.

## Open Questions

- **Clock by default**: off except for Survive and time limits — do players want it for 3-star chasing? Decide with Scoring & Stars.
- **Preview turn**: should the preview piece slowly rotate to show its 3D shape, or stay static from the camera angle? Default static; test.
- **Versus HUD**: per-player frames and opponent mini-boards for 2–4 players (Local Multiplayer Setup).
- **Portrait**: if the Touch Controls prototype moves to portrait, this layout is redone.
- **Board F5 placeholder**: F1 confirms the board's 57.5% height share fits on the reference phone; confirm the 45% width share once controls are laid out in `/ux-design`.
