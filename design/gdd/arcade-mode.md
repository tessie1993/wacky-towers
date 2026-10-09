# Arcade Mode

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant

## Summary

Arcade is an endless score chase: play until you top out, while the speed slowly climbs and a new random twist rotates in every few layers. The goal is a high score; one rescue warning keeps a bad moment from ending a good run.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Level Goals & Fail States, Scoring & Stars, Twist Library`

## Overview

Arcade is the short-session mode from the concept ("a score chase with short sessions"). It reuses every core system with one special goal, `endless`: there is no win, and the run ends on a loss. Speed ramps with layers cleared, Specials join the piece set as the run goes on, and the twist set **rotates**: every `twist_rotation_layers` layers (default 5), the active twist changes to another twist the player has unlocked in the campaign, announced two seconds ahead. Early in a run one twist is active; after 10 layers, two. Items are on (buffs only, as in all solo play). Score uses Scoring & Stars; the best score is saved per biome skin. This serves *Variation Over Depth* (every run passes through many twists) and *The Block Is the Constant* (pure falling-and-clearing at its core). All values are starting defaults.

## Detailed Design

### Core Rules

1. **Setup**: board 8 × 8, `H_play` 12, the 8 Standard shapes; the player picks any unlocked biome as the skin (and its twist pool, rule 5); items on (buffs only); `warnings_max = 1`; no level mechanic.
2. **Goal**: `endless` (Level Goals): no win condition; the run ends when the player loses. The level clock and score are recorded.
3. **Speed**: `g0 = 1.0`, `ramp_per_clear = 0.08`, `g_max = 6` (F1).
4. **Piece set growth**: after `specials_after_layers` (default 10) layers, the Specials unlocked in the campaign join the set (up to the 8-shape limit by replacing the oldest additions; validator rules apply).
5. **Twist rotation**: the pool is every twist the player has met in the campaign (at least Wind in the meadow). At layers 0, 5, 10, … (`twist_rotation_layers`), the twist set is redrawn from the pool with the Arcade random stream: 1 twist before layer 10, then 2 (framework cap). Incompatible pairs are not drawn. The new set takes effect at the next Resolving after a 2 s announcement.
6. **End**: on a loss the run ends; the result screen shows score, layers, time and the best score for that skin.

### States and Transitions

Uses Level Goals' flow (Intro → Countdown → Playing ⇄ Warning → Lost), with a **Rotating** sub-state for the 2 s twist announcement inside Playing.

### Interactions with Other Systems

Level Goals (`endless` goal), Scoring & Stars (score, best), Twist Library and Rule-Twist Framework (rotation), Fall, Drop & Lock (ramp), Piece Set and Spawner (set growth), Items (buffs), Campaign Structure (unlocked twists and Specials), Save & Profile (best scores), Menus (entry).

## Formulas

### F1. Arcade speed

The arcade_speed formula is defined as:

`g(L) = min(g_max, g0 + ramp_per_clear × L)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| L | int | ≥ 0 | calculated | Layers cleared this run |
| g0, ramp_per_clear, g_max | float | — | data file | 1.0, 0.08, 6 |

**Output Range:** 1.0 to 6 cells/s; the cap is reached at L = 63. **Example:** L = 20 → 2.6 cells/s.

### F2. Twist count by layer

The arcade_twists formula is defined as:

`n_twists(L) = 1 if L < 10 else min(2, |pool|)`; a new draw at every `L` divisible by `twist_rotation_layers`

**Output Range:** 1–2. **Example:** a player who has met Wind and Spawned Objects: layers 0–9 one of them; from 10, both.

## Edge Cases

- **If the pool has one twist**: it stays active; from layer 10 still one.
- **If a rotation would draw the current set again**: allowed (random), but never more than twice in a row (re-draw).
- **If a rotation lands during a warning**: it waits for the warning to end.
- **If Gravity Flip rotates out while flipped**: the board flips back at the next Resolving with a settle (Twist Library rule 11).
- **If the player pauses**: everything freezes; the run continues on resume.
- **If the app is closed mid-run**: the run is lost (no resume in the Vertical Slice).

## Dependencies

**Upstream:** Level Goals & Fail States (Hard: `endless`), Scoring & Stars (Hard), Twist Library and Rule-Twist Framework (Hard), Campaign Structure (Soft: unlocked pool).
**Downstream:** Save & Profile, Menus & Level Select (Soft), Points System (Soft, later).

## Tuning Knobs

| Knob | Range | Default |
|---|---|---|
| ramp_per_clear | 0.02–0.2 | 0.08 |
| twist_rotation_layers | 2–10 | 5 |
| specials_after_layers | 0–30 | 10 |
| warnings_max | 0–2 | 1 |

## Visual/Audio Requirements

Arcade uses the chosen biome's skin; the twist announcement is a banner with the twist icon (2 s); score is shown in the HUD's reserved slot; a "new best" stamp on the result. Audio: `twist_rotate`, `new_best`.

## Game Feel

A run should feel like a rising storm: calm start, steady speed-up, a fresh twist every couple of minutes. Target median run 5–10 minutes for a practised player.

## UI Requirements

Arcade entry and biome-skin picker (Menus), result screen with best score. Covered by the `/ux-design` passes for Menus and the result screen.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/level-goals-fail-states.md` | `endless` goal, warnings, flow |
| `design/gdd/scoring-stars.md` F2, F3 | Score |
| `design/gdd/twist-library.md` | Twist pool, incompatibilities |
| `design/gdd/rule-twist-framework.md` F3 | 2-twist cap |
| `design/gdd/items.md` Core Rule 11 | Buffs only in solo |
| `design/gdd/game-concept.md` | Arcade as a score chase |

## Acceptance Criteria

1. [U] **GIVEN** an Arcade run, **THEN** it has no win condition and ends only on a loss.
2. [U] F1: L = 20 → 2.6 cells/s; L = 70 → 6.
3. [U] F2: before layer 10 one twist; from 10 two (if the pool allows); a new draw every 5 layers, with a 2 s banner.
4. [U] **GIVEN** an incompatible pair in the pool, **THEN** it is never drawn together.
5. [U] **GIVEN** 10 layers cleared, **THEN** unlocked Specials join the set within the 8-shape limit.
6. [I] **GIVEN** a run ends, **THEN** the best score per skin is saved if beaten.
7. [M] **GIVEN** a playtest, **THEN** median run length is 5–10 minutes for players who finished the meadow.

## Open Questions

- **Leaderboards / daily seed**: an Arcade daily with a fixed seed (Level Data allows pinned seeds) — later.
- **Mechanics in Arcade**: rotate level mechanics too? Not by default (they're level ideas).
- **Resume**: save a run when the app closes?
