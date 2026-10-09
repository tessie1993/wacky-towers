# Tournament Flow

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Comeback Energy; Variation Over Depth

## Summary

A tournament is 3, 5, 7 or 13 rounds of about 3 minutes each for 2–4 players. Each round's mode is picked by the Randomizer; the round winner gets a round win, and the first player to win a majority of the rounds wins the tournament (with a sudden-death round if nobody gets there).

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Scoring & Stars, Mode / Minigame Randomizer, Items`

## Overview

Tournament Flow is the party shell around versus rounds. The host picks a length (3, 5, 7 or 13 rounds) and settings (modes on/off, items on/off); the flow then repeats: Randomizer picks the round → round plays (Level Goals versus rules: first to the goal wins; topped-out players are out; last standing wins) → round result and standings → next round. A tournament is won by the first player to reach a **majority** of the planned rounds, `floor(R/2) + 1` wins; it can end early. With 3–4 players nobody may reach the majority, so after the last round the players with the most wins play a **sudden-death** Clear Race. Comeback is built in through standing-weighted items (Items), the trailing player's re-roll (Randomizer), and fresh rounds that reset the board. This serves *Comeback Energy* (every round is a fresh chance) and *Variation Over Depth* (every round different). All values are starting defaults.

## Detailed Design

### Core Rules

1. **Setup** (host): players 2–4 (Local Multiplayer Setup), length `R ∈ {3, 5, 7, 13}`, modes enabled, items on/off; a `tournament_seed` is generated.
2. **Round loop**: Randomizer pick (with re-roll window) → countdown → round play → result. Between rounds a standings screen (round wins, who's on a streak) lasts up to `between_round_ms` (default 12 000) or until all players tap ready.
3. **Round result**: the round winner (Level Goals rule 15) gets 1 round win. A round shared tie (Level Goals edge case) gives each tied player a win.
4. **Round time cap**: if no one has won after `round_time_cap_s` (default 240 s), the player with the highest goal progress (Level Goals F4) wins; ties by score.
5. **Tournament win**: the first player to reach `M = floor(R/2) + 1` round wins wins immediately (F1).
6. **No majority**: if all R rounds are played and no one has M wins, the players tied for the most wins play a **sudden-death** Clear Race (N = 1, no twists); others watch. The winner takes the tournament.
7. **Comeback**: items weighted by standing (Items F2, standing = round wins, then current-round progress); the trailing player's re-roll (Randomizer rule 6).
8. **End**: results screen with winner, round history, MVP moments (most layers, biggest clear). Results go to the Points System (later) and Save & Profile.

### States and Transitions

**Setup → Round Pick → Round Countdown → Round Play → Round Result → (Round Pick | Sudden Death | Tournament Result)**. Pause in a tournament pauses all players (Local Multiplayer Setup).

### Interactions with Other Systems

Mode / Minigame Randomizer (rounds), Level Goals & Fail States (round results, versus rules), Scoring & Stars (tie-breaks, MVP moments), Items (standing-weighted rolls), Local Multiplayer Setup (players, devices, sync), Save & Profile and Points System (results, later), HUD and Menus (screens), Audio, Mascot Reactions.

## Formulas

### F1. Majority target

The majority_target formula is defined as:

`M = floor(R / 2) + 1`

**Output Range:** R 3 → 2; 5 → 3; 7 → 4; 13 → 7. **Example:** in a 5-round tournament the first to 3 round wins takes it; it can end after round 3.

### F2. Tournament length estimate

The tournament_length formula is defined as:

`t ≈ R_played × (t_round + t_between)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| R_played | int | M to R (+1 sudden death) | calculated | Rounds actually played |
| t_round | float | 120–240 s | data / measured | About 180 s |
| t_between | float | 10–30 s | data file | Pick + standings, about 20 s |

**Output Range:** about 7 min (3 rounds, early end at 2) to about 47 min (13 rounds). **Example:** 7 rounds all played → 7 × 200 s ≈ 23 min.

## Edge Cases

- **If two players reach M in the same round** (shared tie win): sudden death between them.
- **If a player disconnects or leaves**: they are out for the current round and score no round win; they may rejoin from the next round; if fewer than 2 players remain, the tournament ends with current standings.
- **If the host leaves**: the tournament ends; results so far are shown.
- **If a round hits the time cap with equal progress and score**: shared win.
- **If all players top out in the same frame**: Level Goals' versus tie rules decide.
- **If R = 13 and the leader reaches 7 early**: the tournament ends early (no need to play out).

## Dependencies

**Upstream:** Scoring & Stars, Mode / Minigame Randomizer, Items, Level Goals & Fail States, Local Multiplayer Setup (Hard).
**Downstream:** Points System, Save & Profile, Menus, Mascot Reactions, Audio (Soft).

## Tuning Knobs

| Knob | Range | Default |
|---|---|---|
| lengths offered | 3 / 5 / 7 / 13 | all |
| round_time_cap_s | 120–360 | 240 |
| between_round_ms | 5 000–30 000 | 12 000 |
| sudden-death mode | any template | Clear Race N = 1 |

## Visual/Audio Requirements

Standings board with round-win trophies per player in player colours (art bible §4: red, blue, green, purple, plus shape-coded badges for colour-blind players); round-win stamp; a streak flame for 2+ wins in a row; finale celebration. Audio: `round_win`, `match_point` (a player one win from M), `tournament_win`.

## Game Feel

The tournament should feel like a party: short rounds, quick transitions, and a visible "match point" moment that rallies the others.

## UI Requirements

Setup screen, between-round standings, sudden-death banner, tournament results. 📌 **UX Flag — Tournament Flow**: `/ux-design` for the tournament screens.

## Cross-References

`design/gdd/mode-minigame-randomizer.md` (rounds, re-roll), `level-goals-fail-states.md` (versus rules, F4), `items.md` (standing weighting), `scoring-stars.md` (tie-breaks), `local-multiplayer-setup.md` (players, devices), `design/art/art-bible.md` §4 (player colours), `game-concept.md` (3/5/7/13-round tournaments).

## Acceptance Criteria

1. [U] F1: R = 3, 5, 7, 13 → M = 2, 3, 4, 7.
2. [U] **GIVEN** a player reaches M, **THEN** the tournament ends at once with them as winner.
3. [U] **GIVEN** 4 players and 5 rounds with wins 2/2/1/0, **THEN** a sudden-death Clear Race between the two 2-win players decides it.
4. [U] **GIVEN** a round at 240 s with no winner, **THEN** the highest progress wins.
5. [I] **GIVEN** a disconnect mid-round, **THEN** that player is out for the round and can rejoin next round.
6. [M] **GIVEN** a 7-round playtest, **THEN** it takes 20–30 minutes and at least one round is won by the player who was last before it.

## Open Questions

- **Points for losers**: participation points toward the Points System (later).
- **Handicaps**: optional per-player handicap (slower gravity) for mixed-skill families?
- **Spectator view** in sudden death for the eliminated players.
