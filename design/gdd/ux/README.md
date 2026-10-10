# UX specs: Meadow MVP

> **Status**: Draft (ux-designer, 2026-10-10; updated 2026-10-10 for 4 profiles, three rotation pairs, theme) · **Scope**: MVP = title, profile select, island map, meadow_01–10 + bonus, settings, credits/privacy
> **Binding decisions**: `production/orchestration/meadow-mvp-plan.md` + the 2026-10-10 user decision rounds · **Technical truth**: ADR-0010 (flow), 0012 (input), 0013 (save/profiles/settings), 0014 (camera/orientation/safe area), 0016 (UI architecture) · **Accessibility standard**: `design/accessibility-requirements.md` (accessibility-specialist)
> Every value is a tunable default. Every screen gives a **portrait (P)** and **landscape (L)** layout.

## Files

| File | Covers |
|---|---|
| [title.md](title.md) | Boot splash, title, first-run choices, profile chip |
| [profile-select.md](profile-select.md) | 4 save profiles: pick, create, rename, delete |
| [island-map.md](island-map.md) | Cloud wizard over the 10 Meadow islands + bonus (replaces main menu, world map and level select for the MVP) |
| [level-intro-countdown.md](level-intro-countdown.md) | Intro card, wordless skit, 3-2-1 |
| [hud.md](hud.md) | In-play HUD + touch controls, both orientations |
| [pause.md](pause.md) | Pause overlay, orientation-change pause |
| [results.md](results.md) | Win / loss, stars, payoff skit, next / retry |
| [settings.md](settings.md) | Sound, screen, controls, camera, accessibility, info |
| [credits.md](credits.md) | Credits (incl. CC-BY music) and privacy note |
| [loading-and-save-error.md](loading-and-save-error.md) | Loading cover, toasts, save recovery notices |
| [ui-theme.md](ui-theme.md) | Painted-wood biome frames, fonts, icon sheet, button/panel states, motion, colourblind shapes |
| [interaction-patterns.md](interaction-patterns.md) | Shared patterns: buttons, back, confirm, focus, feedback, input mapping |

Post-MVP screens (character select + perks, shop, tournament lobby, level-maker dock) are a later batch.

## Reference devices

| Profile | Size (pt) | Board rect (Camera F2) | Notes |
|---|---|---|---|
| L | 844 × 390 | 45% W × 57.5% H, centred | Binding profile for cube size |
| P | 390 × 844 | 92% W × 45% H, upper half | Both thumbs at the bottom |

Reference phone: a recent Samsung Galaxy S (flagship). PC windows of any size use the same rule: the aspect decides P or L (ADR-0014).

## Flow

```text
Boot ─► Title ─┬─(first launch: no profile)─► Profile select: Create ─► First-run picker (ACC-02) ─► meadow_01 intro
               ├─(remembered profile)──────► Island map / Continue ─► Level intro ─► Countdown ─► Play ─► Results ─┬─► Next level's intro
               └─(remembered profile missing)► Profile select: List ─► Title                    │  ▲             ├─► Retry (intro, skit skipped)
                                                                                                ▼  │             └─► Island map
Profile chip (Title, Island map) ─► Profile select ─► back to the opener                       Pause ──► Restart / Island map
Settings overlay opens from: Title · Island map · Pause (and returns to the screen below); Settings ⓘ ─► Credits / Privacy
Loading cover (> 150 ms loads), toasts and save notices can appear over any menu (loading-and-save-error.md)
```

| From | To | Trigger | Taps |
|---|---|---|---|
| Title (first launch) | Create profile → picker → meadow_01 intro | Play, ✔ (pre-filled name), ✔ | 3 |
| Title (returning) | Next unfinished level's intro | Continue | 1 |
| Title / Island map | Profile select | Profile chip | 1 |
| Title | Island map | Map | 1 |
| Island map | Level intro | Tap an open island | 1 (+1 Play) |
| Results | Next intro / retry / map | Button | 1 |
| Pause | Settings, Restart, Map | Button (Restart, Map confirm once) | 1–2 |
| Any | One screen back | Back button / Android back / Esc / gamepad B | 1 |

Taps to play a replay from launch: Title (1) → island (2) → Play (3) = Menus F1. A returning player with a remembered profile never sees Profile select (≤ 10 s launch to play).

## What the MVP drops from `menus-level-select.md` (and where each goal went)

| Removed step | What it did | Where it happens now |
|---|---|---|
| Main menu | Hub for Continue/Campaign/Arcade/Tournament | Continue on Title; Campaign = island map; Arcade/Tournament out of MVP scope |
| World map (biomes) | Choose biome (main chain + optional side islands) | Only Meadow exists; the map *is* the Meadow. A locked "next biome" cloud bank shows the 15★ gate |
| Level select (nodes) | Choose level, see stars/time | Islands carry stars + best time on the map |

Profile select is **kept** (4 profiles in the MVP, ADR-0013); it is skipped when the last-used profile is remembered.
