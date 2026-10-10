# Menus & Level Select

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-10 (4 profiles from the MVP, side-island biomes, ADR-0010/0013/0016)
> **Last Verified**: 2026-10-10
> **Implements Pillar**: Readable Chaos
> **Technical**: ADR-0010 (screen stack, Back, loads), ADR-0013 (profiles, settings), ADR-0016 (one scene per screen, P/L layout profiles, biome frame themes) · **MVP screens**: `design/gdd/ux/README.md` (the Meadow MVP merges main menu, world map and level select into the island map)

## Summary

The menus are a cosy toy shop: from the title, a new player creates a profile (a returning one is remembered and skips this), then a big **Continue** button drops them straight into their next level. From there they reach the campaign map, Arcade, Tournament and Settings. Any level is at most three taps away.

> **Quick reference** — Layer: `Presentation` · Priority: `Vertical Slice` · Key deps: `Campaign Structure, Save & Profile`

## Overview

Menus & Level Select is every screen outside play: title, profile select, main menu, the campaign world map (one floating island per biome) and level select (ten level nodes with stars), Arcade entry with biome-skin picker, Tournament setup and lobby (with Local Multiplayer Setup), Settings, the pause menu and result screens' navigation. The art bible sets the mood: warm indoor lamplight, the biome diorama turning on a toy-shop shelf, parchment plates in themed frames, springy UI. The guiding rule is speed to play: a **Continue** button plays the next unfinished (or last played) level, and any level is reachable in three taps from the main menu. All values are starting defaults; layouts come from `/ux-design`.

## Detailed Design

### Core Rules

1. **Screen map**: Title → Profile select (**only** at first launch, or when the last-used profile is missing; ADR-0013 `needs_profile_select()`) → Main menu {Continue, Campaign, Arcade, Tournament, Settings; Shop later} → Campaign: World map → Level select → Level Intro (Level Goals) → Play. A profile chip on Title (and the map) reopens Profile select. **Meadow MVP**: Title → (Profile select) → Island map, which is world map and level select in one (`ux/README.md`).
1a. **Profiles**: 4 slots from the MVP on; create, rename and delete live only in Profile select (`ux/profile-select.md`); a 5th profile cannot be made.
2. **Continue** plays the active profile's first unfinished level of the furthest open main-chain biome; if all are finished, the last played level.
3. **World map**: a **fixed main chain** of biome islands in order (Meadow first; Candy, Ice, Lava, Underwater and 5 more to be named), plus **optional side-island biomes** floating off the chain, linked to the main-chain biome that opens them. Locked biomes show their gate ("★ 15", Campaign Structure); each shows its star total. Side islands never block the main chain; their unlock rule is Campaign Structure's (open question there). Each biome's screens use that biome's painted-wood frame set (ADR-0016 §5).
4. **Level select**: 10 nodes per biome with best stars and best time; locked nodes greyed with a lock; tapping a node shows the Intro card (goal, twists, mechanic, star times) with a Play button.
5. **Pause menu**: Resume, Restart, Settings, Rules (full active-rule list, framework), Quit to map. Restart and Quit ask for confirmation in tournaments only.
6. **Settings** (`ux/settings.md`): Sound and Screen (device-wide), Controls, Camera, Access (per profile), Info (Credits, Privacy). Cloud is a later setting (null backend in the MVP).
7. **Back** always returns one screen (system back on Android, Esc, gamepad B; ADR-0010 §3); never more than one confirmation in a row.
8. Every tappable control is ≥ 48 dp × button size (75–200%; art bible §7, ADR-0016 §8); menus may animate more playfully than in-play UI (art bible: menus can be slower).
9. **Both orientations** on every screen, with keyboard and gamepad focus on every screen (ADR-0016 §4, §6). Extra MVP screens: Credits + privacy note, loading cover, save notices (`ux/credits.md`, `ux/loading-and-save-error.md`).

### States and Transitions

The screen map in rule 1, plus overlays (Settings, Pause, dialogs) that return to the screen below.

### Interactions with Other Systems

Campaign Structure and Save & Profile (map, progress, profiles), Level Goals (Intro card, results), Scoring & Stars (stars, times), Arcade Mode, Tournament Flow and Local Multiplayer Setup (entries, lobby), Touch Controls, Camera, Onboarding & Accessibility, Audio (settings), Rule-Twist Framework (rule list).

## Formulas

### F1. Taps to play

`taps(level) = 1` via Continue; `≤ 3` via Main menu → Campaign → level node → Play (map scrolled to the open biome by default, so biome selection costs no tap unless changing biome).

**Example:** replaying meadow_04 from the main menu: Campaign (1) → node 4 (2) → Play (3).

## Edge Cases

- **If the last-used profile is remembered**: profile select is skipped (any number of profiles).
- **If the last-used profile was deleted or is unreadable**: profile select opens after Title.
- **If a side-island biome is open but the main chain's next biome is locked**: the map shows both; Continue still targets the main chain.
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
6. [I] **GIVEN** a fresh install, **THEN** Title → Play opens profile create; **GIVEN** a remembered profile, **THEN** profile select is never shown at launch.
7. [I] **GIVEN** an open side-island biome, **THEN** it shows off the main chain with its own star total, and finishing it never changes the main-chain gate.

## Open Questions

- Shop placement in the main menu (Alpha).
- Character select in the tournament lobby (Characters & Perks, Alpha).
