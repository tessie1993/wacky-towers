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
