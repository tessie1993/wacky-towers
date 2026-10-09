# Menus & Level Select

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Readable Chaos

## Summary

The menus are a cosy toy shop: from the title, the player picks a profile and lands on a main menu with a big **Continue** button that drops them straight into their next level. From there they reach the campaign's island map, Arcade, Tournament and Settings. Any level is at most three taps away.

> **Quick reference** — Layer: `Presentation` · Priority: `Vertical Slice` · Key deps: `Campaign Structure, Save & Profile`

## Overview

Menus & Level Select is every screen outside play: title, profile select, main menu, the campaign world map (one floating island per biome) and level select (ten level nodes with stars), Arcade entry with biome-skin picker, Tournament setup and lobby (with Local Multiplayer Setup), Settings, the pause menu and result screens' navigation. The art bible sets the mood: warm indoor lamplight, the biome diorama turning on a toy-shop shelf, parchment plates in themed frames, springy UI. The guiding rule is speed to play: a **Continue** button plays the next unfinished (or last played) level, and any level is reachable in three taps from the main menu. All values are starting defaults; layouts come from `/ux-design`.

## Detailed Design

### Core Rules

1. **Screen map**: Title → Profile select (skipped if one profile and remembered) → Main menu {Continue, Campaign, Arcade, Tournament, Settings; Shop later} → Campaign: World map → Level select → Level Intro (Level Goals) → Play.
2. **Continue** plays the first unfinished level of the furthest open biome; if all are finished, the last played level.
3. **World map**: one island per biome in order; locked biomes show the star gate ("★ 15", Campaign Structure); each shows its star total.
4. **Level select**: 10 nodes per biome with best stars and best time; locked nodes greyed with a lock; tapping a node shows the Intro card (goal, twists, mechanic, star times) with a Play button.
5. **Pause menu**: Resume, Restart, Settings, Rules (full active-rule list, framework), Quit to map. Restart and Quit ask for confirmation in tournaments only.
6. **Settings**: Controls (scheme, mirror, sensitivity, one-handed, gizmo, board orbit, scale), Display (reduced motion, occlusion help, clock), Audio (music, effects, haptics), Profile, Cloud.
7. **Back** always returns one screen (system back on Android); never more than one confirmation in a row.
8. Every tappable control is ≥ 44 pt (art bible §7); menus may animate more playfully than in-play UI (art bible: menus can be slower).

### States and Transitions

The screen map in rule 1, plus overlays (Settings, Pause, dialogs) that return to the screen below.

### Interactions with Other Systems

Campaign Structure and Save & Profile (map, progress, profiles), Level Goals (Intro card, results), Scoring & Stars (stars, times), Arcade Mode, Tournament Flow and Local Multiplayer Setup (entries, lobby), Touch Controls, Camera, Onboarding & Accessibility, Audio (settings), Rule-Twist Framework (rule list).

## Formulas

### F1. Taps to play

`taps(level) = 1` via Continue; `≤ 3` via Main menu → Campaign → level node → Play (map scrolled to the open biome by default, so biome selection costs no tap unless changing biome).

**Example:** replaying meadow_04 from the main menu: Campaign (1) → node 4 (2) → Play (3).

## Edge Cases

- **If there is one profile**: profile select is skipped.
- **If every level is finished**: Continue plays the last played level and shows "replay for ★".
- **If a level is Draft or missing** (development): its node is hidden.
- **If the app resumes mid-level after backgrounding**: it shows the pause menu.
- **If a tournament is in progress on another device**: Tournament shows "Join" for that lobby.

## Dependencies

**Upstream:** Campaign Structure, Save & Profile (Hard); Level Goals, Scoring & Stars, Arcade Mode, Tournament Flow, Local Multiplayer Setup (Soft).
**Downstream:** Onboarding & Accessibility (Soft: settings entry, first run).

## Tuning Knobs

None beyond layout values in the UX spec.

## Visual/Audio Requirements

Toy-shop shelf backdrop with the current biome diorama slowly turning (art bible §4 menus mood); the world map as linked floating islands (art bible §6); wood/vine frames for the meadow. Audio: menu music, soft clicks, a chime on unlocks.

## Game Feel

Menus should feel like opening a toy box — inviting and quick. Target: launch to playing in ≤ 10 s on a returning profile (Continue).

## UI Requirements

All of it. 📌 **UX Flag — Menus & Level Select**: `/ux-design` for title, profile select, main menu, world map, level select, pause and settings.

## Cross-References

`design/art/art-bible.md` §4, §6, §7 (menu mood, islands, frames, targets), `campaign-structure.md` (map, gates), `save-profile.md` (profiles), `level-goals-fail-states.md` (Intro card, results), `scoring-stars.md`, `arcade-mode.md`, `tournament-flow.md`, `local-multiplayer-setup.md`, `rule-twist-framework.md` (rule list), `touch-controls.md` (settings).

## Acceptance Criteria

1. [I] **GIVEN** a returning profile, **WHEN** Continue is tapped, **THEN** the next unfinished level's Intro opens.
2. [I] F1: any open level is playable in ≤ 3 taps from the main menu.
3. [I] **GIVEN** a gated biome, **THEN** its island shows the star requirement.
4. [I] **GIVEN** any screen, **THEN** Back returns exactly one screen.
5. [M] **GIVEN** a returning player, **THEN** launch to play takes ≤ 10 s.

## Open Questions

- Shop placement in the main menu (Alpha).
- Character select in the tournament lobby (Characters & Perks, Alpha).
