# Onboarding & Accessibility

> **Status**: Draft · **Author**: accessibility-specialist + Tessa · **Date**: 2026-10-10
> **Systems index**: #37 (was Alpha; MVP-scoped here) · **Layer**: Meta
> **Requirements source**: `design/accessibility-requirements.md` (wins on conflict) · **Technical truth**: ADR-0012 (input), ADR-0013 (save/settings), ADR-0014 (camera), ADR-0016 (UI)
> Standard sections (Overview, Detailed Rules, Formulas, Edge Cases, Dependencies, Tuning Knobs, Acceptance Criteria). Every value is a tunable default.

## Overview

Wacky Towers teaches without words. A new player goes profile select, title, then straight into meadow_01's intro once; each level introduces one idea in isolation, reinforces it, then combines it with earlier ones. Rotation arrives in three pairs, Turn / Flip / Roll; Roll is taught in meadow_02. Accessibility settings are reachable from first run, Title, the island map and Pause, apply live, and are saved per profile. Relaxed timing slows the game and scales star times so a player who needs more time can still earn all 3 stars, with no badge.

## Detailed Rules

### 1. First-run flow

1. Boot, then ADR-0013 `needs_profile_select()`. With no profiles the **profile select** opens straight into create (4 slots exist; name + avatar, no typing required: pick-from-icons is allowed).
2. **First-run picker (ACC-02)**, one screen, skippable: hand (R/L), orientation (Auto/Portrait/Landscape), control preset, reduced motion (System/On/Off, default System), colourblind symbols (default Shapes). Sets `first_run.accessibility_picker_done = true` even when skipped.
3. **Title** (First run state: Play only), then **Play goes straight into meadow_01's intro**, skipping the island map **once**. Later launches use Continue / Map (ux/title.md).
4. A returning profile with a remembered slot skips 1-2 (launch to play stays within 10 s).
5. Skits are skippable by one tap (ACC-42). Nothing in this flow uses text the player must read; button labels follow the Settings "Button labels" option and use translation keys.

### 2. Non-verbal teaching

Pattern per idea: **isolation** (only the new thing, no pressure), **reinforcement** (the same thing where it helps the goal), **combination** (with earlier ideas). Teaching tools: Pip points and emotes, a ghost-hand demo, highlighted target cells, and first-time **hints** (icon bubbles, <= 3 s, tap to dismiss; ACC-54). Hints appear only the first time a rule appears in a profile and can be replayed from Settings.

| Level | Idea | Isolation | Reinforcement | Combination |
|---|---|---|---|---|
| meadow_01 | Move, Turn (spin), drop, clear a layer | Enabled axes = Turn only (CV02); 4x4 board, no timer pressure, 2 warnings; first pieces I, O | Layers 2-4: goal plate counts leaves | None (pure classic) |
| meadow_02 | **Flip and Roll** (the other two pairs); pockets | Roll gizmo shown; first 3 pieces a bag of Tripod and Screws; Pip points at bed A and demos Flip, then the mirror trick with Roll | Beds B and the third bed need different axes | Both starter layers clear together; Turn from 01 reused |
| meadow_03 | Gust (EV01): reading a telegraph | Gust telegraph with bent grass + arrow, long warning | Repeat gusts, shorter gaps | All three rotation pairs under wind |
| 04-10 | One new rule each (see `design/levels/meadow.md`) | The rule's icon appears on the goal plate; tap shows name + one-liner (HUD rule 6) | | Later levels stack earlier rules |

- **Camera** is taught in meadow_01-02 by a ghost-hand drag on the board and a snap-button highlight (ADR-0014): free orbit settles to a 30 degree snap on release.
- **Rotation help** (ACC-53): the axis gizmo is on for meadow_01-03, then Off / always On per Settings. Roll shows a third ring colour plus a dotted style (not colour alone).
- A hint is never the only carrier of a rule: the goal plate and rule icons (ACC-52) stay visible.

### 3. How accessibility settings surface

| Where | What | Notes |
|---|---|---|
| First-run picker | The five choices in section 1 | Once per profile |
| Title / Island map / Pause | Settings overlay, Accessibility tab (ACC-01) | Live; Pause opens the same tab with the board frozen |
| Settings > Accessibility | Colourblind aid, reduced motion (System/On/Off), UI scale 75-200%, button labels, rotation gizmo, clock, **Relaxed timing**, Replay hints | Per profile (ADR-0013 `settings.json`) |
| Settings > Controls | Preset, mirror, layout editor (button scale 75-200%, min 56 dp), remap, timing sliders | ACC-10 to ACC-18 |
| Settings > Camera | Orbit sensitivity, invert, Auto camera (off by default), orientation lock | ACC-20 to ACC-23, ACC-71 |
| Every page | Reset to default | ACC-03 |

Reduced motion `system` is re-read on app resume (ADR-0013/0014). **Relaxed timing** turned on from Pause applies from the **next level start** and the pause menu says so (determinism, ADR-0001).

## Formulas

### F1. Relaxed timing

With Relaxed timing on, `StarRater` and level construction use these values (knob `relaxed_time_scale`, ADR-0004; read once when the level starts):

`g_relaxed = g0 x fall_scale` · `lock_relaxed = lock x lock_scale` · `telegraph_relaxed = telegraph x telegraph_scale` · `limit_relaxed = limit x time_scale` · `t2_relaxed = round5(t2 x time_scale)` · `t3_relaxed = round5(t3 x time_scale)`

| Variable | Default | Range | Meaning |
|---|---|---|---|
| fall_scale | 0.7 | 0.5-1.0 | Fall speed multiplier |
| lock_scale | 1.5 | 1.0-2.0 | Lock delay multiplier |
| telegraph_scale | 2.0 | 1.0-3.0 | Gust 1 s and flip 2 s telegraphs |
| time_scale (`relaxed_time_scale`) | 1.5 | 1.0-2.0 | Level time limits and star times |

Rationale: `1 / fall_scale = 1.43`, rounded up to 1.5, so a run at the slower fall speed fits the scaled star times. **Unchanged**: goals (layers, height, shape), Survive T (08 stays 150 s; its star thresholds are layers, not time), fog alpha/visible time use ACC-35 values (0.25 and 8 s).

**Example**: meadow_01 stars 145 / 105 s become round5(217.5) = 220 s and round5(157.5) = 160 s (round5 rounds to the nearest 5, halves up). Bonus limit 60 s becomes 90 s (clock reads 1:30), bonus star times 45 / 30 s become 70 / 45 s.

**Stars**: the record stores stars and the real clock as earned; **no relaxed flag, no badge** (user decision 2026-10-10). Stars never decrease (ADR-0013), so playing relaxed first and normal later keeps the best of both.

## Edge Cases

- **Skip first-run picker**: defaults apply (System motion, Shapes); the picker does not return, but Settings has all of it.
- **Profile created without finishing the picker (app killed)**: `accessibility_picker_done` is false, so the picker shows again at next launch for that profile.
- **Second profile on the same device**: runs the picker for that profile; audio/display settings stay device-wide.
- **meadow_01 replay**: the map-skip happens once only; hints replay only if "Replay hints" was used.
- **Player never uses Roll**: meadow_02 requires it only for the mirror bed; if the player stays stuck > 20 s (hint timer, tunable) Pip re-demos once. Relaxed timing and gizmo-always are the escape hatches.
- **Relaxed turned on mid-level**: takes effect next level; running sim never changes.
- **Rotation disabled axes**: a hint never names an axis the level has disabled.
- **OS reduced motion cannot be read** (Android verification fails): `system` behaves like Off and the picker is the way in (ADR-0014).
- **Button scale 75%**: spacing and decoration shrink first; hit areas stay >= 56 dp.
- **Screen reader (LATER)**: first focus is Play on Title.

## Dependencies

| System | Needs |
|---|---|
| Save & Profile (ADR-0013) | `first_run`, `settings.accessibility`, profile slots, `relaxed_time_scale` knob read by StarRater |
| Touch Controls / Input (ADR-0012) | Presets, remap, button scale, three rotation pairs (spin/tilt/roll) |
| Camera & Rotate-View (ADR-0014) | Free orbit + snap, Auto, reduced motion |
| UI architecture (ADR-0016) | Profile select, picker and Settings screens, `UiPrefs` |
| Scoring & Stars | `t2`/`t3` scaled per F1 |
| Level Goals, Fall/Drop/Lock, Level-Specific Mechanics | Timing values scaled per F1 |
| Level Data / `design/levels/meadow.md` | Per-level enabled axes and teaching order |
| Campaign Structure, HUD, Narrative skits | Skip, hints, goal plate |

## Tuning Knobs

`relaxed_time_scale` 1.5, `fall_scale` 0.7, `lock_scale` 1.5, `telegraph_scale` 2.0, `hint_max_s` 3, `stuck_redemo_s` 20, `gizmo_levels` (01-03), picker defaults, `button_scale` 75-200%, `ui_scale` 75-200% (text 100/125/150% per ACC-33).

## Acceptance Criteria

1. [I] Fresh install: profile create, then picker, then Title, then Play opens meadow_01's intro directly (no map); the second launch shows Continue.
2. [I] Skipping the picker leaves defaults and sets `accessibility_picker_done`; every picker option is reachable later in Settings.
3. [I] Every Accessibility setting change applies live from Pause (except Relaxed timing: next level, with the note) and survives restart, per profile.
4. [P] meadow_01 and meadow_02 completed by a first-time tester with no text and no help; Roll is used successfully in meadow_02.
5. [I] Relaxed timing on: every Meadow level is winnable by `input_simulate`; goals equal normal; F1 values hold; 3 stars earnable at the scaled times; save record has no relaxed marker.
6. [I] Reduced motion default `system` follows the OS setting; On/Off override it.
7. [I] Buttons at 75% and 200% on the reference phone and smallest phone: every in-play hit area >= 56 dp, gap >= 8 dp.
8. [I] Replay hints re-shows meadow_01's first-time hints on the next entry.
