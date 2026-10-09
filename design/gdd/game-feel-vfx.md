# Game Feel & VFX

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Readable Chaos; The Block Is the Constant

## Summary

Game Feel & VFX turns the events every system already sends — moves, locks, clears, warnings, items — into a consistent language of squash, puffs, shakes and haptics. One rule sits above all the juice: when an effect would hide the board, the board wins. Effects scale with the size of the moment, are capped so a big clear never becomes a screen-filling mess, and everything has a reduced-motion version.

> **Quick reference** — Layer: `Presentation` · Priority: `Vertical Slice` · Key deps: `Layer Clearing, Buffs & Debuffs, Items`

## Overview

Each GDD already lists the visual and audio events it fires. This system owns how those events look and feel together: a shared **feedback vocabulary** (squash and settle for contact, puffs and confetti for removal, translation-only camera punch for impact, chevrons and edge glows for effects, haptic ticks and pulses), a **priority order** so the most important feedback always reads first (the falling piece, ghost and danger cues before anything else; art bible §3 eye order), **intensity scaling** by event size (a 4-layer clear is bigger than a 1-layer clear, up to a cap), a **concurrency budget** so effects never pile up, and **reduced motion** rules applied everywhere. It also defines the performance budget for VFX on the reference phone. This serves *Readable Chaos* (feedback that clarifies instead of hiding) and *The Block Is the Constant* (the satisfaction of placing and clearing blocks is the core feel). All values are starting defaults; individual effect specs come from `/asset-spec`.

## Detailed Design

### Core Rules

1. **Clarity first.** No effect may cover the falling piece, its ghost, the height-limit line or a danger cue. Particles spawn behind or around the board's live area, or fade out of the piece's screen rectangle.
2. **Vocabulary**:

| Moment | Visual | Camera | Haptic |
|---|---|---|---|
| Move / rotate | Snap and turn (Movement & Rotation) | — | Light tick (optional) |
| Blocked | Bonk shake, red outline on blocked cubes | — | Short buzz |
| Land / lock | Squash, dust puff, settle flash | Punch on hard-drop lock | Medium pulse |
| Layer clear | Hue confetti, bottom-to-top ripple | Punch scaled by layers | Strong pulse per layer |
| Warning / rescue | Board-edge danger flash, rescue wipe | Small shake | Double pulse |
| Buff / debuff | Cyan / magenta chevron, edge glow | — | Light pulse |
| Item collected / used | Bubble fly, streak to target | — | Light pulse |
| Win / loss | Biome celebration / gentle topple | — | Success / soft pattern |

3. **Priority** when effects compete for the frame budget: (1) piece, ghost, danger; (2) lock and clear; (3) warnings; (4) items and effects; (5) ambience. Lower priorities are dropped first.
4. **Intensity scaling** by event size (F1), capped at `intensity_cap`.
5. **Concurrency budget**: at most `max_vfx_systems` (default 6) particle systems and `max_particles` (default 600) live at once on the reference phone; new effects above the budget replace the oldest lowest-priority ones.
6. **Camera**: only translation punch and shake, never zoom or rotation (Camera & Rotate-View); total offset ≤ `max_punch_px` (default 6 px).
7. **Reduced motion** (setting): no shake, no punch, no confetti; fades and static highlights instead; timings unchanged so gameplay is identical.
8. **Haptics** follow the table, off by setting, and are rate-limited to one pulse per 50 ms.

### States and Transitions

Stateless per event; a global **Reduced motion** flag and **Haptics** flag switch variants.

### Interactions with Other Systems

Consumes events from Movement & Rotation, Fall Drop & Lock, Layer Clearing, Level Goals, Obstacle Clearing, Buffs & Debuffs, Items, Twist Library, Level-Specific Mechanics, Rule-Twist Framework; uses Camera (punch API), Onboarding & Accessibility (settings), Audio (paired sounds).

## Formulas

### F1. Intensity scaling

The feel_intensity formula is defined as:

`I = min(intensity_cap, 1 + intensity_step × (size − 1))`, where `size` = layers cleared, cells removed / 27 (bombs), or 1 for single events

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| intensity_step | float | 0.1–0.5 | data file | Default 0.25 |
| intensity_cap | float | 1–3 | data file | Default 2 |

**Output Range:** 1–2: multiplies particle count, punch distance and haptic strength. **Example:** a 4-layer clear → min(2, 1.75) = 1.75; 6 layers → 2 (capped).

### F2. VFX frame budget

`t_vfx ≤ vfx_budget_ms` (default 2 ms GPU + 0.5 ms CPU per frame on the reference phone at 60 fps).

## Edge Cases

- **If a clear and a warning happen together**: the warning flash takes priority over confetti (rule 3).
- **If the budget is exceeded**: lowest-priority effects are dropped, never the piece, ghost or danger cues.
- **If reduced motion is on**: all shake, punch and confetti are replaced; the game plays identically.
- **If the device is in low-power mode**: particle counts halve.
- **If several players' effects stack in split screen**: each half has its own budget (half each).

## Dependencies

**Upstream:** Layer Clearing, Buffs & Debuffs, Items (Hard), plus the event sources listed above (Soft), Camera & Rotate-View (Hard: punch rules).
**Downstream:** Audio, Mascot Reactions (Soft: shared event timing), Onboarding & Accessibility (Hard: settings).

## Tuning Knobs

| Knob | Range | Default |
|---|---|---|
| intensity_step / intensity_cap | F1 | 0.25 / 2 |
| max_vfx_systems / max_particles | 2–12 / 100–2 000 | 6 / 600 |
| max_punch_px | 0–12 | 6 |
| vfx_budget_ms | 1–4 | 2 |

## Visual/Audio Requirements

This GDD is the visual requirement hub; per-effect specs come from `/asset-spec system:game-feel-vfx` after the art bible is approved. Painterly, chunky, toy-like effects (art bible §6), effect accents per §4.

## Game Feel

Every action answers within one frame; big moments feel big; nothing feels noisy. Target: playtesters describe clears as "satisfying" and never report losing track of the piece during effects.

## UI Requirements

Settings toggles for reduced motion and haptics (Menus & Level Select, Onboarding & Accessibility).

## Cross-References

`design/art/art-bible.md` §3, §4, §6 (eye order, accents, juice style), `camera-rotate-view.md` (translation-only punch), the Visual/Audio sections of all gameplay GDDs (event lists).

## Acceptance Criteria

1. [U] F1: 1 layer → 1.0; 4 → 1.75; 6 → 2.0.
2. [I] **GIVEN** a 4-layer clear with a warning, **THEN** the warning flash and the piece/ghost are never covered.
3. [I] **GIVEN** 10 simultaneous effect requests, **THEN** at most 6 systems and 600 particles are live; the dropped ones are lowest priority.
4. [I] **GIVEN** reduced motion, **THEN** no shake, punch or confetti plays in any system.
5. [M] **GIVEN** the reference phone, **THEN** VFX stay within 2 ms GPU per frame during a 4-layer clear (profiler).
6. [M] **GIVEN** a playtest, **THEN** no tester reports losing the piece behind an effect.

## Open Questions

- Haptic patterns per platform (iOS Core Haptics vs. Android vibration) → implementation.
- Should combo streaks add a screen-edge glow? Test for clutter.
