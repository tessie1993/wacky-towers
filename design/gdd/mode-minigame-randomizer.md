# Mode / Minigame Randomizer

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Variation Over Depth; Comeback Energy

## Summary

Before each tournament round, the Randomizer picks what the round will be: a versus mode (race to clear, build race, shape race, survival) or, later, a minigame, plus the round's twists. Picks are weighted, never repeat the previous round's mode, and the player furthest behind gets one re-roll per tournament.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Level Goals & Fail States, Level Data & Definition`

## Overview

Tournaments are "Mario Kart-style": every round is a surprise. The Randomizer builds each round from **round templates** — Level Data records sized for about 3-minute versus play — and picks one with weighted random choice from the pool of templates the group has unlocked and enabled. It never picks the same mode twice in a row, adds 0–2 twists drawn from the unlocked twist pool (more in later rounds), and seeds the round from the tournament seed so every device builds the same round. To keep *Comeback Energy*, the player with the fewest round wins may spend one **re-roll** per tournament to redraw the round before it starts. Vertical Slice templates cover the four goal types as races; tournament minigames (Alpha) join the same pool later. This serves *Variation Over Depth* (no two rounds alike) and *Comeback Energy* (re-roll and variety favour the trailing player). All values are starting defaults.

## Detailed Design

### Core Rules

1. **Round templates** are Level Data records tagged `versus`, with a `mode` and a selection `weight`. Starter modes (Vertical Slice):

| Mode | Goal (Level Goals) | Board | Notes |
|---|---|---|---|
| Clear Race | Clear N (F1 with `T_level` 180 s) | 6 × 6, H_play 10 | First to N layers |
| Build Race | Height | 6 × 6, H_play 12 | No-Clear Build Race mechanic |
| Shape Race | Shape | 6 × 6 | Same target for all players |
| Survival | Last standing | 6 × 6, H_play 10 | Speed ramp, warnings 0 |

2. **Pool**: templates whose twists, mechanics and shapes the host player has unlocked in the campaign, minus modes disabled in tournament settings.
3. **Pick**: weighted random over the pool, excluding the previous round's mode (F1). Uses the tournament's random stream, seeded from `tournament_seed + round_index`, so all devices agree.
4. **Twists**: round 1 has 0 twists; rounds 2–3 one twist; round 4 on up to two (framework cap), drawn from the unlocked twist pool without incompatible pairs or conflicts with the template's mechanic.
5. **Items** are on in every round unless the template turns them off (Items rule 12).
6. **Re-roll**: before a round starts, the player (or players) with the fewest round wins, if behind the leader by at least one win, may re-roll once per tournament. The re-roll redraws the template and twists (excluding the rejected template).
7. **Round seed**: each round's `round_seed` is derived from the tournament seed and round index, so piece sequences are shared when `sequence_mode = shared` (Spawner).

### States and Transitions

Per round: **Drawing → Showing** (the roulette and the pick, ~3 s) **→ Re-roll window** (5 s, if a trailing player qualifies) **→ Locked** (round starts).

### Interactions with Other Systems

Tournament Flow (asks for each round; standings for re-rolls), Level Data (templates), Level Goals (goal types), Twist Library and Rule-Twist Framework (twists, caps), Campaign Structure (unlocked pools), Items (on/off), Spawner (round seed), Tournament Minigames (later, same pool), HUD/Menus (roulette display).

## Formulas

### F1. Round pick probability

The round_pick formula is defined as:

`P(template j) = w_j / Σ w_k` over templates k in the pool whose mode ≠ previous mode

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| w_j | float | > 0 | data file | Template weight; default 1 per template, so modes with more templates come up more |

**Output Range:** probabilities summing to 1. **Example:** 4 modes with one template each, previous round was Clear Race → each of the other three has 1/3.

### F2. Twist count by round

`n_twists(round) = 0` for round 1, `1` for rounds 2–3, `min(2, pool)` from round 4.

## Edge Cases

- **If the pool has one mode only**: repeats are allowed (the no-repeat rule is skipped).
- **If a template's mechanic conflicts with every twist in the pool**: it is drawn with fewer twists.
- **If two players tie for fewest wins**: both may re-roll; the first to press uses the round's re-roll (one re-roll per round at most).
- **If a device disagrees with the host's pick** (desync): the host's pick is used (Local Multiplayer Setup).
- **If no templates are unlocked** (fresh install): the four starter templates are always available.

## Dependencies

**Upstream:** Level Goals & Fail States, Level Data & Definition (Hard); Twist Library, Rule-Twist Framework, Campaign Structure (Soft).
**Downstream:** Tournament Flow (Hard), Tournament Minigames (Hard, later).

## Tuning Knobs

| Knob | Range | Default |
|---|---|---|
| template weights | > 0 | 1 |
| twists by round | F2 | 0 / 1 / 2 |
| re-rolls per tournament (trailing) | 0–2 | 1 |
| round T_level | 120–300 s | 180 s |

## Visual/Audio Requirements

A short roulette of mode icons (≤ 3 s), landing on the pick with the twist icons; the re-roll button glows for the eligible player. Audio: `roulette_spin`, `roulette_land`, `reroll`.

## Game Feel

The pick should feel like a party moment — quick, loud, and over before anyone gets bored.

## UI Requirements

Roulette screen between rounds (Tournament Flow's between-round screen). 📌 **UX Flag**: include in `/ux-design` for tournament screens.

## Cross-References

`design/gdd/level-goals-fail-states.md` (goal types, versus rules), `level-data-definition.md` (templates, seeds), `twist-library.md` and `rule-twist-framework.md` (twists, caps), `level-specific-mechanics.md` (Build Race, Shape), `items.md` (items per round), `piece-spawner-queue.md` (shared seeds), `game-concept.md` (random-mode tournaments).

## Acceptance Criteria

1. [U] F1: with previous mode Clear Race and 4 single-template modes, the other three are each picked 33% ± 2% over 10 000 draws; Clear Race never.
2. [U] **GIVEN** the same tournament seed, **THEN** every device draws the same templates and twists.
3. [U] F2: round 1 has no twists; rounds 2–3 one; round 4+ two (when the pool allows), never incompatible.
4. [U] **GIVEN** a player behind by one win with the fewest wins, **THEN** they may re-roll once per tournament; the leader may not.
5. [I] **GIVEN** a round starts, **THEN** its `round_seed` follows from the tournament seed and round index.

## Open Questions

- **Minigames** join the pool in Alpha (Tournament Minigames).
- **Vote option**: add a "players vote from 3" setting later?
- **Mode weights**: tune after the first party playtests.

---

## Addendum (2026-10-09): Minigames in the pool

> **Author**: game-designer. Implements the "Minigames join the pool in Alpha" open question above. The 15 minigames are designed in `design/gdd/tournament-minigames.md`. All values are tunable defaults.

8. **Minigame templates** (tag `minigame`) join the pool from Alpha. Each minigame counts as its own mode for the no-repeat rule (rule 3).

9. **Category share.** Each pick first chooses a category: a minigame with probability `minigame_share` (default 0.4), otherwise a versus mode. It then picks a template inside that category with F1. If one category is empty, the other is used.

10. **No recent repeat.** A minigame played in the last `mg_no_repeat_rounds` rounds (default 3) is excluded. If that empties the minigame category, the oldest-played minigame comes back.

11. **Twists.** Minigames get 0 twists; F2 does not apply to them. A template that opts in to 1 twist (Tournament Minigames rule 12) gets its twist from the normal twist pool.

12. **Standing for items and comebacks.** Each round uses its template's `standing_metric`: Level Goals F4 for versus modes, and the minigame's own metric for minigames (`race_progress`, `score`, `height` or `alive_time`). This is the decision of 2026-10-09 that item-roll standing varies per minigame.

13. **Re-roll.** Rule 6 applies unchanged. A re-roll redraws the category too.

### F3. Minigame pick

`P(minigame j) = minigame_share × 1 / |MG_eligible|`; `P(versus template k) = (1 − minigame_share) × F1(k)`.

**Example:** 15 minigames, 3 played recently → 12 eligible → each has 0.4 / 12 ≈ 3.3%.

| Knob | Range | Default |
|---|---|---|
| minigame_share | 0–1 | 0.4 |
| mg_no_repeat_rounds | 0–10 | 3 |

**Acceptance.**
6. [U] With `minigame_share = 0.4`, between 38% and 42% of picks over 10 000 draws are minigames.
7. [U] No minigame repeats within 3 rounds while 4 or more are eligible.
