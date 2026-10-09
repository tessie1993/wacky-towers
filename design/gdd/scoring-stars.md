# Scoring & Stars

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Readable Chaos; Comeback Energy; Variation Over Depth

## Summary

Every finished campaign level earns 1 to 3 stars: one for finishing, two for beating the level's 2-star time, three for beating the 3-star time without using a warning. Star times come from the level's estimated length and are tuned by playtests. A separate in-level **score** rewards multi-layer clears, combos, hard drops and broken obstacles; it matters in Arcade and versus, while stars drive the campaign.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Layer Clearing, Level Goals & Fail States`

## Overview

Scoring & Stars has two outputs. **Stars** are the campaign's mastery measure (concept: "3-star clears, time-based"): the level clock from Level Goals is compared with two star times per level, and the third star also requires finishing without a rescue warning. Star times default to fixed shares of the level's length estimate (Level Data F1) and are replaced by playtest data as levels are tuned. Survive levels, whose time is fixed, rate stars by layers cleared instead. The player's best stars per level are saved and feed the Points System (meta currency, later). **Score** is the moment-to-moment number: points for each resolve's clears (more for clearing several layers at once), a combo bonus for consecutive clearing pieces, a little for hard-drop distance and placed cubes, and points for broken obstacles; chain rounds in cascade mode multiply. Score is shown in Arcade and versus (and kept as a personal best in the campaign), but it never decides stars, so the campaign rewards clean, quick play rather than score farming. This serves *Readable Chaos* (stars are three simple conditions), *Variation Over Depth* (the same rules rate every goal type), and *Comeback Energy* (combos and multi-clears let a trailing versus player catch up fast). All values are starting defaults.

## Detailed Design

### Core Rules

**Stars (campaign)**
1. A level that is lost gives 0 stars. A level that is won gives:
   - ★ for finishing;
   - ★★ if the level clock is ≤ `t2` (Formulas F1);
   - ★★★ if the level clock is ≤ `t3` **and** no warning was used.
   A won level that misses `t3` but used no warning still gets only the stars its time earns.
2. **Survive** goals (fixed time) use layers cleared instead of time: ★★ if `layers_cleared ≥ s2`, ★★★ if `layers_cleared ≥ s3` and no warning was used (F4).
3. Star times come from Level Data's `stars` section; if absent they use F1 (or F4 for Survive). Times are rounded to 5 s for display.
4. Only the **best** result per level is saved (more stars, then faster time). Stars are never lost on a replay.
5. Results are sent to Save & Profile, Campaign Structure (unlocks) and the Points System (later).

**Score (all modes)**
6. Score events (Formulas F2, F3):
   - **Clear**: per resolve with `n` layers cleared, `clear_base × n(n+1)/2`, scaled by board size, times the chain multiplier in cascade/chunk rounds.
   - **Combo**: if consecutive locked pieces each cause a clear, the k-th consecutive clear adds `combo_bonus × (k − 1)`. A piece that clears nothing resets the combo.
   - **Hard drop**: `drop_points` per cell dropped.
   - **Placement**: `place_points` per cube locked.
   - **Obstacles**: points per obstacle broken by type (crate, rock, junk).
7. Rescue wipes score nothing. Deferred layers score when they actually clear.
8. Score is displayed in Arcade and versus HUDs (reserved slot, HUD rule 4) and as a campaign personal best on the result screen.

### States and Transitions

Stars are computed once, on the result. Score accumulates during Playing; the combo counter goes **Idle → Running (k ≥ 1) → Idle** (reset on a non-clearing lock or a warning).

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Level Goals & Fail States | → Scoring | Result, clock, layers cleared, warnings used |
| Layer Clearing | → Scoring | `clear_resolved` (n layers, rounds) |
| Obstacle Clearing | → Scoring | Break events with type and source |
| Fall, Drop & Lock | → Scoring | Lock events, hard-drop distance, cubes |
| Level Data & Definition | ↔ | Star times per level; length estimate F1 |
| Save & Profile, Campaign Structure | Scoring → | Best stars, times, scores |
| Points System | Scoring → | Stars earned (later) |
| HUD, Menus, Arcade Mode, Tournament Flow | Scoring → | Score display, result screen, rankings |
| Game Feel & VFX, Audio | Scoring → | Star stamps, combo pops |

## Formulas

### F1. Star times

The star_times formula is defined as:

`t2 = round5(star2_share × t_est)`, `t3 = round5(star3_share × t_est)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| t_est | float | 60–1200 s | calculated (Level Data F1) | Level length estimate |
| star2_share | float | 0.6–1.0 | data file | Default 0.85 |
| star3_share | float | 0.4–0.9 | data file | Default 0.6 |

**Output Range:** `t3 < t2`. **Example:** meadow_03, `t_est ≈ 512 s` → `t2 = 435 s` (7:15), `t3 = 305 s` (5:05). meadow_01, 480 s → 410 s and 290 s.

### F2. Clear score

The clear_score formula is defined as:

`points = clear_base × n(n+1)/2 × (A / 64) × (1 + chain_bonus × (round − 1))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n | int | 1–12 | calculated (Layer Clearing) | Layers cleared in this round |
| clear_base | int | 50–500 | data file | Default 100 |
| A | int | 16–144 | calculated (Board F1) | Active cells per layer (bigger layers are worth more) |
| chain_bonus | float | 0–1 | data file | Default 0.5 (cascade/chunk rounds only) |
| round | int | 1–10 | calculated | Chain round (1 in slice mode) |

**Output Range:** 25 (one layer on 4 × 4) upward. **Example:** 8 × 8, n = 1 → 100; n = 2 → 300; n = 4 → 1 000. 6 × 6 (A = 36), n = 2 → 300 × 0.5625 ≈ 169.

### F3. Combo and placement score

The combo_score formula is defined as:

`combo = combo_bonus × (k − 1)`; `drop = drop_points × cells_dropped`; `place = place_points × cubes`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| k | int | ≥ 1 | calculated | Consecutive clearing pieces |
| combo_bonus | int | 0–200 | data file | Default 50 |
| drop_points | int | 0–5 | data file | Default 2 per cell |
| place_points | int | 0–5 | data file | Default 1 per cube |
| obstacle points | int | 0–200 | data file | Crate 20, rock 50, junk 10 |

**Output Range:** small per piece (placement and drops), larger for combos. **Example:** a 4-cube piece hard-dropped 9 cells that makes a 3rd consecutive clear of 1 layer: 4 + 18 + 100 + 100 = 222.

### F4. Survive star thresholds

The survive_stars formula is defined as:

`expected = T / (P_eff × t_piece)`; `s2 = max(1, round(survive2_share × expected))`, `s3 = max(s2 + 1, round(survive3_share × expected))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| T | float | > 0 s | data file (goal) | Survive time |
| P_eff, t_piece | float | — | Board F2 / Level Goals | Pieces per clear, seconds per piece |
| survive2_share, survive3_share | float | 0.3–1.5 | data file | Defaults 0.6 and 1.0 |

**Output Range:** `s3 > s2 ≥ 1`. **Example:** T = 180 s on 8 × 8: expected = 180 / 170 ≈ 1.06 → s2 = 1, s3 = 2.

## Edge Cases

- **If a level has no `stars` section**: F1 (or F4) applies; the editor shows the computed times.
- **If `t3 ≥ t2`** (bad data): validation fails.
- **If the player wins in exactly `t3`**: ≤ counts, so 3★ if no warning was used.
- **If a warning was used but the time beats `t3`**: 2★.
- **If the level is lost**: 0 stars; score is still shown as a personal best candidate (Arcade only).
- **If the player pauses**: the clock stops (Level Goals), so pausing never costs stars.
- **If a deferred layer clears together with others**: it counts in `n` for that resolve.
- **If a combo is running when a warning happens**: the combo resets.
- **If a level changes version**: old stars are kept and marked (Level Data rule on versions).
- **If score would overflow**: capped at 9 999 999 (display), which no realistic level reaches.

## Dependencies

**Upstream:** Layer Clearing (Hard), Level Goals & Fail States (Hard), Level Data & Definition (Hard: star times, F1), Obstacle Clearing (Soft), Fall, Drop & Lock (Soft).

**Downstream:** Campaign Structure, Save & Profile, Points System (Hard: stars); Arcade Mode, Tournament Flow (Hard: score); HUD, Menus (Soft).

## Tuning Knobs

| Knob | Range | Default | Affects |
|---|---|---|---|
| star2_share / star3_share | see F1 | 0.85 / 0.6 | Star difficulty |
| survive2_share / survive3_share | see F4 | 0.6 / 1.0 | Survive star difficulty |
| clear_base | 50–500 | 100 | Score scale |
| chain_bonus | 0–1 | 0.5 | Value of chains |
| combo_bonus | 0–200 | 50 | Value of consecutive clears |
| drop_points / place_points | 0–5 | 2 / 1 | Small per-piece points |
| obstacle points | 0–200 | 20 / 50 / 10 | Obstacle value |

## Visual/Audio Requirements

- Result screen: stars stamp in one by one with a bounce (art bible §7), each with its condition shown as an icon (finish flag, clock, shield for "no warning").
- In-play score (Arcade, versus): ticks up; multi-clears and combos pop a short "×2", "Combo 3" label near the board edge (not on the board).
- Audio events: `star_awarded` (rising per star), `combo`, `score_tick` (soft, rate-limited).

## Game Feel

Stars should feel achievable but worth chasing: most players get ★ or ★★ on a first clear and come back for ★★★. Targets (playtest): first-attempt median ★★ on meadow 1–5, ★–★★ on 6–10; ★★★ reachable by a practiced player on every level.

## UI Requirements

Result screen with stars and conditions, best time and score; level select shows best stars (Menus). 📌 **UX Flag — Scoring & Stars**: include the result screen in `/ux-design`.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/level-goals-fail-states.md` Core Rules 8, 13, 14 | Clock, warnings used, result |
| `design/gdd/layer-clearing.md` Core Rule 11 | `clear_resolved`, rounds |
| `design/gdd/obstacle-clearing.md` Core Rule 11 | Break events |
| `design/gdd/level-data-definition.md` F1; Core Rule 3 | Length estimate; `stars` section |
| `design/gdd/board-grid.md` F1, F2 | Active cells; pieces per clear |
| `design/gdd/hud.md` Core Rule 4 | Reserved score slot |
| `design/gdd/game-concept.md` | 3-star time-based clears; points from stars |

## Acceptance Criteria

1. [U] F1: `t_est = 512` → t2 = 435, t3 = 305.
2. [U] **GIVEN** a win at 300 s with no warning, **THEN** ★★★; at 300 s with a warning → ★★; at 420 s → ★★; at 500 s → ★; a loss → 0.
3. [U] F4: Survive 180 s on 8 × 8 → s2 = 1, s3 = 2; 2 layers cleared and no warning → ★★★.
4. [U] **GIVEN** a replay with fewer stars, **THEN** the saved best is unchanged.
5. [U] F2: 8 × 8, n = 1 / 2 / 4 → 100 / 300 / 1 000; 6 × 6, n = 2 → 169; cascade round 2 → × 1.5.
6. [U] F3: the worked example scores 222.
7. [U] **GIVEN** a non-clearing lock or a warning, **THEN** the combo resets.
8. [U] **GIVEN** a rescue wipe, **THEN** no score and no layers counted.
9. [U] **GIVEN** a level with `t3 ≥ t2`, **THEN** validation fails.
10. [M] **GIVEN** a playtest of the 10 meadow levels, **THEN** first-attempt median stars are ★★ on 1–5 and ★–★★ on 6–10, and testers can say why they got each star.

## Open Questions

- **Star times from bots**: once a placement bot exists (Board η simulation), replace F1 defaults with bot-scaled times.
- **No-warning condition in tutorials**: should meadow_01–02 drop the warning condition for ★★★?
- **Score in the campaign HUD**: hidden by default (stars matter); show as an option?
- **Versus scoring**: whether score decides rounds in some modes — Tournament Flow.
