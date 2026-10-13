# Minigame Economy (Party Stops and Tournament Minigames)

> **Status**: Draft (proposal; needs user decisions D1–D4 below)
> **Author**: Tessa + agents (economy-designer)
> **Last Updated**: 2026-10-13
> **Implements Pillar**: Variation Over Depth; Comeback Energy; Readable Chaos
> **Extends**: `design/gdd/points-system.md` (Star Economy) F1, F2, F7; `design/gdd/shop.md` F4, F5; `design/gdd/campaign-structure.md` rules 4, 17

## Overview

This GDD sets out how the new minigames pay the player. **Party Stops** are short minigame stages placed inside the campaign, 2 per biome (22 for 11 biomes). New **tournament minigames** are extra round types inside the existing Tournament Flow. The Star Jar stays the only persistent currency. A Party Stop earns 0–3 **earned stars**, just like a level. Each new star drops one jar star (Star Economy F1, 1:1, which is a standing user decision). Party Stop stars **never count toward `biome_star_gate`**. They can top up a biome's **bonus gate** by at most `party_stop_bonus_gate_credit_max` (3) stars. Party Stops pay no replay trickle, because they are short enough to farm. Everything collected *inside* a minigame round (coins, gems, collectible "stars", hearts, power-ups and next-item queues) is **round-scoped** and is thrown away when the round ends. Its only route into the persistent economy is the designed one: it feeds the round score, the score sets the stars, and the stars pay the jar (bounded by F1). Tournament minigames add **no new faucet**. They are rounds, and Star Economy F3–F5 still pays per tournament. Under this design the 22 stops add at most **66** lifetime jar stars, and a completionist's income stays within the shop's ±10% safe band (F4 below).

## Player Fantasy

"A party on the way!" Halfway through a biome the map shows a bunting-covered stop: a 1–2 minute burst of silly chaos such as herding sheep, smashing a candy fort or sledging down a glacier. You grab coins, bump into rivals and fire a water cannon, then walk away with up to three stars and a little drop into the jar. You can't get stuck: skipping a stop never locks a biome. The coins you grabbed were points in that game, not money that vanished. Nobody sells you hearts or power-ups, and nothing has to be refilled.

## Detailed Design

### Core Rules

**Placement and gating**
1. Each campaign biome has `party_stops_per_biome` (default 2) Party Stops. Stop *i* opens when the biome's main-path level at tier `party_stop_unlock_tiers[i]` (default `[4, 8]`) is finished. This spreads the stop income across the biome instead of bunching it at the end.
2. Party Stops are **off the main path**. They are never needed to open the next level, the next biome, a remix or a side island.
3. **Biome gate**: Party Stop stars are **excluded** from `stars(b)` in Campaign Structure F1 (`open(b+1)`), whatever `party_stop_counts_biome_gate` says. That flag must be `false`, and the loader rejects `true` (validation, AC 3).
4. **Bonus gate**: the bonus level opens when `stars_main(b) + min(stars_ps(b), party_stop_bonus_gate_credit_max) ≥ bonus_star_gate` (F2). Party Stops can help a player reach the bonus level, but the bonus stays mostly earned by puzzle play: at least 17 of the 20 must still come from main-path levels.

**Stars and the jar**
5. A Party Stop result gives 0–3 **earned stars** from the minigame's own thresholds (★ / ★★ / ★★★ on the player's own score or goal progress, set in each minigame's data). Stars are judged on **your own performance, never on placement against bots or friends**. That way a young solo player can earn ★★★, and bot difficulty never sets the payout.
6. Only the best result is kept (same as Scoring & Stars rule 4). Each **newly** earned star drops **one** jar star (Star Economy F1, unchanged). Each stop can put at most 3 jar stars into the jar, ever.
7. **Replays**: Party Stops use `party_stop_replay_cap` (default **0**) instead of `replay_cap`. A replay that raises no star pays nothing. Stops stay freely replayable for fun and high scores. Reason: a stop lasts about 1.5 min against about 4 min for a puzzle level, so a paid replay would earn at roughly 40 stars/h, almost 3× the campaign rate (F3).
8. On a Party Stop only the active profile's player is paid. Couch friends and guests in the same stop earn nothing (Star Economy rule 2).
9. Party Stop stars **do** show on the map and in biome totals as "party stars", in their own ring next to the gate counter. They are never added to the gate number shown (Readable Chaos).

**Round-scoped pickups (no leaks)**
10. Everything a minigame shows on the HUD during a round is **round state**: coins, gems, in-round collectible stars (for example Glacier Rush's 7/12), lives hearts, power-ups, ammo, the "next block / next item / next ammo / next conduit" queue and the meters (altitude, topple risk, oxygen). It is created at round start and destroyed at round end. It is never written to `progress.json`, and no menu screen shows a running total of it.
11. Round pickups can only affect the round's **score or goal counter** (as with `star_coins`, mechanics-wave3 W8). Score becomes stars by rule 5, and stars reach the jar only by rule 6. **No other conversion exists.** There is no "coins → jar" exchange, no end-of-round coin bank and no gem shop. `round_pickups_persist` must be `false`, and the loader rejects `true`.
12. **Naming and icons**: an in-round collectible must **not** use the earned-star stamp or the jar-star icon. Glacier Rush's collectibles become "snowflakes" or "sparkles" (or another non-star icon) in-game. Coins keep the gold reward hue (art bible `#FFC83D`) but use a coin shape, never a star.
13. **Lives hearts** are per round only. Losing the last heart ends the player's round, and stars are scored on what was reached. No persistent lives, no energy, no timers and no refills, so there is nothing to sell and nothing to wait for.

**Power-ups and items**
14. Minigame power-ups (Dash, which the mockups call "speed boost"; Water Cannon; Super Hammer; Gravity Flip) spawn **only inside the round**, from the minigame's own allow-list. They cannot be bought, carried, stored or brought in, and the Shop never lists them. At most 1 power-up is held per player (round state, rule 10).
15. **Potions** (Shop) are **off** in Party Stops (`party_stop_potions_allowed = false`). Their effects (Helper Drop, Slow Time, Preview Peek, Bomb) are falling-block buffs and may do nothing in a non-stacking minigame. Keeping them off also leaves no potion → Party Stop star route to check. In tournament minigame rounds the existing host setting `potions_allowed` and `potions_per_tournament` apply unchanged, and only for rounds whose minigame declares potion support.
16. Edge perks follow Characters & Perks: a perk whose effect has no meaning in a minigame does nothing there. The ~15% edge cap still applies. Perks are never needed for ★★★ on a stop.

**Tournament minigames**
17. New tournament minigames are **round types**. A round pays **0** jar stars by itself (`tournament_round_pay = 0`). The tournament pays once at its end, through Star Economy F3 (win), F4 (finish) and F5 (lobby decay), unchanged. Adding more minigames to the pool changes neither award size nor frequency.

### States and Transitions

Per Party Stop and profile: **Locked → Open → Played (best 0–3 stars)**. Stars only go up, and each step drops one jar star. Replays never pay (rule 7). Per round: **Round start (pickups = 0) → Playing → Round end (pickups discarded; score → stars)**.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Star Economy (`points-system.md`) | ↔ | F1 jar drop per new star; Party Stop replay cap; F7 faucet line |
| Campaign Structure | ↔ | Stop placement by tier; excluded from `open(b+1)`; bonus-gate credit |
| Shop | → | Potions off in stops; no minigame items sold; sink capacity (F4) |
| Scoring & Stars | → | Best-result-kept rule; per-minigame star thresholds |
| Items / Buffs & Debuffs | ↔ | Power-ups are round-scoped; Gravity Flip, Speed Up name clash (Open Questions) |
| Tournament Flow | → | Minigame rounds pay 0; tournament awards unchanged |
| Save & Profile (ADR-0013) | ↔ | `progress.json` stores Party Stop best stars only; no pickups |
| HUD, Art bible | → | Round counters; non-star icon for in-round collectibles |

## Formulas

### F1. Party Stop jar income

`J_ps(stop) = max(0, best_after − best_before)` (Star Economy F1); `J_ps_replay = 0` at `party_stop_replay_cap = 0`.

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| best_before / best_after | int | 0–3 | save / result | Best stars on this stop |
| N_ps | int | 0–44 | `party_stops_per_biome × biomes` | Stops in the campaign; default 2 × 11 = **22** |

**Lifetime bound:** `J_ps_max = 3 × N_ps + party_stop_replay_pay × party_stop_replay_cap × N_ps` = 3 × 22 + 0 = **66**. With replays at the main-campaign defaults (1, 1) it would be 88.

### F2. Bonus gate with credit

`bonus_open(b) = stars_main(b) + min(stars_ps(b), C) ≥ bonus_star_gate`

| Variable | Type | Range | Default | Description |
|---|---|---|---|---|
| stars_main(b) | int | 0–30 | save | Main-path stars (as today) |
| stars_ps(b) | int | 0–6 | save | Party Stop stars in biome b |
| C | int | 0–6 | 3 | `party_stop_bonus_gate_credit_max` |
| bonus_star_gate | int | 0–30 | 20 | unchanged |

**Worked values:** main 17 + stops 6 → 17 + 3 = 20 → **open**. Main 16 + stops 6 → 19 → closed. Main 20 + stops 0 → open (as today). At C = 0 the behaviour is today's; at C = 6 a player could open the bonus with only 14 main stars, which is too lenient.

### F3. Earn rate during and across Party Stops

`R_ps = stars_earned_ps / time_ps`, `R_blend = (J_campaign + J_ps) / (T_campaign + T_ps)`

Assumptions: a stop round is about 1.5 min (mockup timers 0:30–2:30), and earning its stars takes about 4 min including intro and about 2 retries. A typical player plays about 20 of 22 stops at an average of ★★.

| Profile | J_ps | T_ps | R_ps | R_blend (campaign 290 / 18 h, F7) |
|---|---|---|---|---|
| Typical | ≈ 40 | ≈ 1.5 h | ≈ 27 /h | (290 + 40) / 19.5 = **≈ 16.9 /h** (+13% over 15) |
| Completionist | ≈ 60 | ≈ 2.5 h | ≈ 24 /h | (610 + 60) / 37.5 = **≈ 17.9 /h** |
| Replays paid (rejected option, cap 1) | +22 in ≈ 0.6 h | — | ≈ 37 /h bursts | — |

**Time to afford at R_blend 16.9 /h** (Shop F6 at 15 /h in brackets): tier-1 perk 10 → 36 min (40); tier-2 20 → 71 min (80); tier-3 35 → 2.1 h (2.3 h); Bomb potion 4 → 14 min (16). Purchases still come every 36–71 min for the common 10–20-star items. That is about 10% faster at the low end than the Shop target of 40–90 min, which is accepted and is a watch metric (AC 10).

### F4. Sink/faucet check

Finite sinks (Shop F4): **645** (perks 260 + cosmetics 385). Potions are the only repeatable sink (2–4 each). Safe band (Shop tuning note): `S_finite` within ±10% of completionist income.

| Scenario | Completionist income | Hard max | S_finite | S / income | Verdict |
|---|---|---|---|---|---|
| Today (F7, 10 biomes) | 610 | 656 | 645 | 1.057 (+5.7%) | in band |
| + 22 Party Stops (replay 0) | 610 + 60 = **670** | 656 + 66 = **722** | 645 | 0.963 (−3.7%) | **in band** |
| + 22 Party Stops (replay cap 1) | 670 + ≈ 20 = 690 | 744 | 645 | 0.935 (−6.5%) | in band, but bursty (F3) |
| + Party Stops, **carnival counted as an 11th full biome** (+30 main, +3 bonus, +9 remix earned, +≈10 replays) | ≈ 722 | 722 + 42 + 14 = **778** | 645 | 0.893 (−10.7%) | **out of band** |
| same + carnival cosmetic set (35, biome parity) | ≈ 722 | 778 | **680** | 0.942 (−5.8%) | in band |

**Surplus after the catalog** (the "hoard" question): at the hard maximum of 722 against 645, a 100% player has ≈ 77 jar stars left over. That is about 25 potions at an average of 3, and potions absorb it. With 4 types × a stack of 5 (55 to refill a full stock, Shop F2) the jar drains as potions are used. No wallet inflation: the jar has no exchange rate, no trading and no prices that scale, so a surplus only means "can always afford a potion".

**Typical player:** 290 + 40 = **330** lifetime against 645 finite. They still choose (about half the catalog), so every star still has a use. Nothing is hoarded, and the jar stays at 0–20 when they spend.

**Verdict:** the 22 stops do **not** inflate the wallet as long as `party_stop_replay_cap = 0`. **One open sink question (D4):** `economy.json` lists 11 biomes including `carnival`, while Star Economy F7, Campaign Structure and the catalog model 10 biome sets. If carnival is a full 11th biome, add its 35-star cosmetic set (biome parity), or the catalog drops just below the band. This gap exists today, independently of Party Stops.

### F5. No-profit-loop check (Shop F5 extension)

Potions are off in stops (rule 15), so potion → stop star loops don't exist. Pickups never reach the jar except through stars (rule 11), so coin farming is bounded by F1 (3 per stop, ever). The tournament minigame round pays 0 (rule 17), so the F5 lobby farming check (≈ 14 /h < 15 /h) is unchanged.

### F6. In-round power-up spawn table (starting default; owned by the minigame / Items designer)

| Output | Weight | Condition | Notes |
|---|---|---|---|
| Dash (speed boost) | 30 | minigames with a moving avatar | self buff, ~5 s |
| Water Cannon | 25 | minigames with knock-back | pushes rivals or blocks; never targets an out player |
| Super Hammer | 25 | minigames with breakable blocks | one big smash |
| Gravity Flip | 20 | only minigames without a fixed floor (Twist Library rule 15 incompatibilities apply) | affects all; telegraphed |
| **Total** | **100** | entries not on the minigame's allow-list are removed and the rest renormalise | |

Expected acquisition: with one power-up on the field every 15 s (minigame knob), a 75 s round shows about 5. At 4 players with an equal share that is about 1.25 per player per round. Only one can be held, so there is no stockpiling. There is no pity timer, because nothing persists. Comeback bias can reuse Items F2 (the leader gets fewer offensive pickups).

## Edge Cases

- **If a player skips every Party Stop**: every biome, remix and side island opens exactly as today, and the bonus gate works as today (C credit = 0).
- **If a stop's star thresholds change in a patch**: best stars already earned stay, jar stars already paid stay, and the new thresholds apply to future results (same as level rebalance).
- **If a stop is removed in a patch**: its stars stay in the save (ADR-0013 keeps unknown keys) and no longer count toward the bonus-gate credit. A bonus level that is already open stays open.
- **If a stop has 6 stars and main has 17**: the bonus opens (F2 worked value). If main later drops is impossible, since stars only go up.
- **If the app is killed mid-stop**: nothing is written, and all pickups are lost by definition (rule 10).
- **If a round ends with unused power-ups, coins or hearts**: discarded, with no conversion and no "leftover bonus".
- **If a minigame collects more coins than its goal**: extra coins add score only, so they may raise the star tier, nothing else.
- **If a friend plays the stop on the same device**: only the active profile is paid (rule 8). The friend's score is shown and not saved.
- **If the jar is at `jar_cap`**: clamped as in Star Economy rule 3.
- **If a tournament minigame round ends early**: Star Economy rule 14 governs the whole tournament; the round itself pays nothing.
- **If `party_stop_counts_biome_gate` is set true in data**: validation fails (AC 3). It is a guard rail, not a tuning option.
- **If a Party Stop minigame wants a persistent reward** (for example a trophy cosmetic): it must be added as a free fixed grant in this GDD and the Shop "not sold" list (Shop rule 23), never as a currency.

## Dependencies

**Upstream:** Star Economy (Hard: F1, F7, jar), Campaign Structure (Hard: gate formula, tier placement), Scoring & Stars (Hard: best-kept, thresholds), Tournament Flow (Hard: awards per tournament), Save & Profile / ADR-0013 (Hard: best stars per stop; no round state saved), Items, Buffs & Debuffs and Twist Library (Soft: power-up effects, Gravity Flip limits).

**Downstream:** Shop (Soft: sink check; potions off in stops), HUD (Soft: round counters, party-star ring), Menus & Level Select (Soft: map stops), Art bible (Soft: non-star collectible icon).

**Bidirectional updates needed (not edited here):** `points-system.md` F7 needs a "Party Stops" faucet row (66 max). `campaign-structure.md` rules 4 and 17 need the exclusion and the bonus credit. `shop.md` rule 19 needs "Party Stops: potions off". `items.md` and `twist-library.md` need to note the round-scoped minigame power-ups. `systems-index.md` needs an entry for this GDD.

## Tuning Knobs

Proposed additions to `assets/data/meta/economy.json` (flat keys, matching the file's style):

```json
"party_stops_per_biome": 2,
"party_stop_unlock_tiers": [4, 8],
"party_stop_counts_biome_gate": false,
"party_stop_bonus_gate_credit_max": 3,
"party_stop_replay_pay": 0,
"party_stop_replay_cap": 0,
"party_stop_potions_allowed": false,
"round_pickups_persist": false,
"tournament_round_pay": 0
```

| Knob | Safe range | Default | Affects |
|---|---|---|---|
| party_stops_per_biome | 0–3 | 2 | Faucet size: each +1 adds 33 max (11 biomes); 3 per biome puts the completionist at about 703 → −8.3%, the edge of the band |
| party_stop_unlock_tiers | ascending tiers 1–10, length = per_biome | [4, 8] | Pacing of stop income inside a biome |
| party_stop_counts_biome_gate | false only | false | Guard rail: the main chain is never blocked |
| party_stop_bonus_gate_credit_max | 0–3 | 3 | How much stops help open the bonus; above 3 makes the bonus too cheap |
| party_stop_replay_pay / _cap | 0–1 / 0–1 | 0 / 0 | Replay trickle; 1/1 adds 22 max and ≈ 37 /h bursts |
| party_stop_potions_allowed | true/false | false | Potion use in stops; if true, re-check Shop F5 per minigame |
| round_pickups_persist | false only | false | Guard rail: in-round currencies never save |
| tournament_round_pay | 0 only | 0 | Guard rail: tournaments pay per tournament |

Power-up weights (F6) and spawn interval belong in the minigame data, not `economy.json`.

## Visual/Audio Requirements

- A map stop that looks like a bunting-covered stage. Party stars sit in a separate ring next to the biome counter.
- In-round collectibles get non-star icons (rule 12). The result screen shows round coins and gems turning into **score** and never flying to the jar. Only newly earned stars fly to the jar (Star Economy visuals).

## UI Requirements

Result screen for a stop: score → star stamp → jar drop for new stars only. No pickup totals outside the round. The map shows party stars apart from the gate number. 📌 **UX Flag**: include the Party Stop map node and result screen in `/ux-design`.

## Acceptance Criteria

1. [U] **GIVEN** a Party Stop first won at ★★, **THEN** jar +2 and `earned_total` +2; a later ★★★ → jar +1; any later win → jar +0.
2. [U] **GIVEN** a stop replayed at its best stars, **THEN** jar +0 and no `replays_paid` entry is written for it (`party_stop_replay_cap = 0`).
3. [U] **GIVEN** `party_stop_counts_biome_gate = true` or `round_pickups_persist = true` in data, **THEN** loading `economy.json` fails validation.
4. [U] **GIVEN** biome b with main 14 stars, tier 10 finished and stops at 6 stars, **THEN** biome b+1 is **not** open (`biome_star_gate` 15).
5. [U] **GIVEN** main 17 and stops 6, **THEN** the bonus is open; main 16 and stops 6 → closed (F2).
6. [U] **GIVEN** a round ending with 40 coins, 3 gems, 1 held power-up and 2 hearts, **THEN** after the result is applied, `progress.json` holds only the stop's best stars and the jar change from new stars.
7. [U] **GIVEN** a Party Stop, **THEN** no potion pick is offered.
8. [U] **GIVEN** a tournament of R minigame rounds, **THEN** jar changes only at the tournament's end, by Star Economy F3–F5.
9. [U] F4: with default knobs and 22 stops, the lifetime Party Stop maximum is 66 and the Shop catalog is between 90% and 110% of the modelled completionist income.
10. [M] **GIVEN** a playtest through biome 2 with its 4 stops, **THEN** the median time between purchases is 35–100 min, and no tester believes coins or gems are saved or spendable.
11. [M] **GIVEN** a solo young-player playtest, **THEN** at least 90% earn ★ on a stop on the first try, and ★★★ is reachable without perks or power-up luck.

## Open Questions / Decisions for the user

- **D1. Bonus-gate credit**: count stop stars toward bonus gates up to 3 (recommended), up to 6, or not at all.
- **D2. Party Stop replays**: no replay pay (recommended), or the main-campaign trickle (1 per stop, +22 max).
- **D3. Potions in Party Stops**: off (recommended), or on for stack-based minigames only.
- **D4. Carnival as an 11th biome**: if yes, add the carnival cosmetic set (35) and update Star Economy F7 and Campaign Structure (10 → 11 biomes). This applies with or without Party Stops.
- **Mockup review gap**: 6 of the 20 sheets were reviewed (01, 05, 10, 12, 15, 20). They show scores, timers, lives hearts, next-block / next-item / next-ammo slots, meters and in-round collectible stars. **No coin or gem counter and none of the four named power-ups appear on those sheets.** The power-up names come from the brief. Rules 10–14 are written to cover them whatever the remaining sheets show.
- **Name clashes**: "speed boost" vs the Items debuff **Speed Up**, which is why it is called **Dash** here. "Gravity Flip" is already Twist T3 (a level event); as a player-fired power-up it needs a game-designer decision. In-round "stars" clash with earned stars (rule 12).
- **Monetization**: none. Nothing in this GDD is sold for money, and no power-up, heart or pickup is sold for stars.
