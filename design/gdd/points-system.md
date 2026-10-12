# Star Economy

> **Status**: In Design
> **Author**: Tessa + agents (economy-designer)
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10
> **Implements Pillar**: Comeback Energy; Variation Over Depth; The Block Is the Constant
> **File note**: this file keeps its old name (`points-system.md`) so existing links still work. There is no "points" currency any more: **stars are the only currency** (decision sheet, /team-narrative round).

## Summary

Stars are the game's one currency. A profile holds two star numbers: **earned stars** (the best stars on each level; they show progress and open biomes and bonus levels, and they **never go down**) and the **Star Jar**, a spendable star balance that the Shop draws on. Every campaign star you earn drops **one** star into the jar, once, ever. Replays pay a small, capped trickle, and tournaments pay the winner a win award and every other finisher a small finish award (about 30% of a win, smaller on repeats). Spending only empties the jar; it never touches earned stars. Each of the 4 save profiles has its own jar. There is no real-money path; the price data carries a currency field as the only seam.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Scoring & Stars, Campaign Structure, Tournament Flow, Save & Profile (ADR-0013)`

## Overview

The Star Economy turns mastery into choice. **Earned stars** are owned by Scoring & Stars: the saved best per level, summed for biome gates (Campaign Structure F1, 15 of 30), bonus gates (20 of 30) and every star display. The economy never writes them. On top of them sits the **Star Jar** (`wallet.star_balance`). When a result raises a level's best stars, each newly earned star also drops into the jar (F1), so the jar can never receive more campaign stars than the campaign holds (492 at launch: 100 main levels, 10 bonus levels, 30 hard-track remixes and 24 side-island levels, each with 3 stars). A replay that raises nothing pays at most `replay_cap` (default 1) jar star per level (F2). Tournaments pay the winner `≈ M` stars, more with more players (F3), and each other finisher a finish award of about 30% of that (F4). Both shrink with each further tournament in the same lobby (F5), so farming with a second phone earns no more per hour than playing the campaign. Arcade, quick versus, lost levels and score pay nothing; score is a separate number (Scoring & Stars) and never turns into stars. Prices are set in stars by the Shop (`design/gdd/shop.md`), sized so a completionist's lifetime jar income and the finite catalog come out about even (F7). This serves *Comeback Energy* (a player who loses a tournament still gets a finish award), *Variation Over Depth* (stars buy perks, potions and looks) and *The Block Is the Constant* (stars come from playing blocks, never from menus or timers). All values are starting defaults, tuned by playtest.

## Player Fantasy

"I got the third star, and a star dropped into my jar. Two more and I can buy the Bomb potion." Stars should feel like the same reward the player already chases, with a bonus: the star stays on the level card **and** a copy drops into the jar. Buying something empties the jar, never the level. A child must never feel that a purchase "took away" their stars or locked a biome. A child who loses a tournament to a parent still sees a star or two drop into the jar.

## Detailed Design

### Core Rules

**Two star numbers**
1. **Earned stars** are the saved best stars per level (Scoring & Stars rule 4). Only results raise them; nothing lowers them, including spending. Biome gates, bonus gates, the map, level cards and biome totals read **only** earned stars.
2. The **Star Jar** is the spendable balance, one per profile (`wallet.star_balance`, rule 15). Guests (no profile, ADR-0013 §6) earn and keep nothing.
3. The jar never goes below 0 and is capped at `jar_cap` (default 9 999). Earnings over the cap are discarded with a "jar full" note. A normal player never comes close (F7).
4. Jar stars are earned only by the rules below and spent only in the Shop. They cannot be transferred between profiles, refunded for money, or bought.
5. All jar amounts are integers. Each formula states its own rounding.

**Campaign stars (the main faucet)**
6. When a result raises a level's best stars, the jar gains **one star per newly earned star** (F1). A first win with ★★★ drops 3. A level can therefore put at most 3 stars into the jar from its stars, ever.
7. This holds for every campaign level: main path (tiers 1–10), bonus (tier 11), hard-track remixes (tiers 12+) and side-island levels. There is no biome or track multiplier: a star is a star.
8. Stars earned with relaxed timing (ADR-0013 §4, no badge), with perks on or with a potion used (`shop.md` rule 18, ★★★ still allowed) count and pay the same.
9. Lost levels pay nothing. Retrying is free (Campaign Structure rule 6).

**Replays (the trickle)**
10. A **replay** is a win on an already-won level that raises no star. It pays `replay_pay` (default 1) if the run earned at least `replay_min_stars` (default 2) and the level has paid fewer than `replay_cap` (default 1) replays (F2). The level can still be replayed freely for fun, times and score.
11. A win that raises stars pays by rule 6 **instead**, and does not count toward `replay_cap`.

**Tournaments (wins and finishes)**
12. When a tournament ends normally (Tournament Flow), the **winner** gets the win award (F3) and every other player still in it at the end gets the **finish award** (F4). An exact tie for the win is a split win: each tied winner gets the full win award (decision sheet).
13. Within one lobby session (Local Multiplayer Setup), each tournament already completed lowers the next one's awards (F5). The count `k` is kept in memory only, never saved, and resets when the lobby closes. Nothing in the jar is computed from wall time (ADR-0013 §5).
14. A tournament that ends early (host leaves, fewer than 2 players remain; Tournament Flow edge cases) pays **no** win award. If at least `M` rounds were played, every player still in it gets the finish award; otherwise nothing. A player who left before the end gets nothing.
15. On LAN (ADR-0009, one phone per player), each device pays **its own** active profile from the host's authoritative result. A guest device pays nothing.
16. **Quick versus pays nothing** (default; see Open Questions). Arcade pays nothing.

**Bookkeeping (save fields, inside the ADR-0013 `wallet` map)**
17. The Star Economy owns these fields (integers, keyed by stable level ids):
    ```json
    "wallet": { "star_balance": 0, "earned_total": 0, "spent_total": 0,
                "replays_paid": { "meadow_03": 1 } }
    ```
    No "stars paid" field is needed: the newly earned stars are the best stars after the result minus the best before it, and the best never goes down (rule 1). `earned_total` only grows. `star_balance = earned_total − spent_total` must always hold; the loader repairs `star_balance` from the totals if they disagree and logs a warning.
18. Jar stars are applied when the `LevelResult` (or the tournament result) is applied, and saved in the **same** `progress.json` write as the earned stars (ADR-0013 §3), so the level card and the jar never get out of step.
19. **Migration / backfill**: the schema migration that adds these fields drops the reserved `wallet.points` key (never written by any build) and, for a save that already has earned stars, adds the sum of all earned stars to the jar once, with no replay awards.

### States and Transitions

Per level: earned stars **0 → 1 → 2 → 3** (only up; each step also drops one jar star), and independently **replays 0 → 1 (= `replay_cap`, exhausted)**. Per lobby: **k = 0 → 1 → 2 …** (in memory; reset on lobby close). The jar has no states.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Scoring & Stars | → Star Economy | Stars in the run; best stars before/after (earned stars stay owned by Scoring & Stars) |
| Campaign Structure, Level Data | → Star Economy | Level id; gates read earned stars only, never the jar |
| Tournament Flow | → Star Economy | Winner(s), finishers, early end, rounds played, `M`, player count |
| Local Multiplayer Setup | → Star Economy | Lobby open/close (`k`) |
| Save & Profile (ADR-0013) | ↔ | `wallet` map in each profile's `progress.json`; guests excluded |
| Shop | ↔ | Reads the jar; debits on purchase (`spent_total`) |
| Menus & Level Select, HUD (result screens) | Star Economy → | Star drop into the jar on result screens; jar counter on map and shop |
| Characters & Perks, Skills | — | No direct flow; perks are bought through the Shop; characters join by story, never bought |
| Arcade Mode, quick versus | — | Pay nothing (score only), by design |

## Formulas

### F1. Campaign jar stars

The campaign_jar formula is defined as:

`J_star = best_after − best_before`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| best_before | int | 0–3 | save (level record) | Earned stars on this level before the result |
| best_after | int | 0–3 | calculated (Scoring & Stars) | Earned stars after the result (`max(best_before, s_run)`) |

**Output Range:** 0–3. **Examples:** meadow_03 first win ★★ → **+2**; later ★★★ → **+1**; any later win → 0 (a replay, F2). First win ★★★ on a side-island level → **+3**. Campaign maximum at launch: (100 + 10 + 30 + 24) levels × 3 = **492**.

### F2. Replay award

The replay_award formula is defined as:

`J_replay = replay_pay` if `best_after = best_before` and `s_run ≥ replay_min_stars` and `n < replay_cap`, else `0`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| s_run | int | 1–3 | calculated | Stars earned in this run (not the saved best) |
| n | int | 0–replay_cap | save (`wallet.replays_paid`) | Replays already paid on this level |
| replay_pay | int | 0–2 | data file | Default 1 |
| replay_min_stars | int | 1–3 | data file | Default 2 |
| replay_cap | int | 0–3 | data file | Default 1 |

**Output Range:** 0–1 per replay at defaults. **Examples:** meadow_03 (best ★★) replayed at ★★: n = 0 → **+1**, n = 1 → 0. Replayed at ★ → 0 (below `replay_min_stars`).

**Anti-farming bound:** lifetime replay income ≤ `replay_pay × replay_cap × levels` = 1 × 1 × 164 = **164 stars**, no matter how long someone replays.

### F3. Tournament win award

The win_award formula is defined as:

`base_win = round_half_up( tw_per_M × M × (1 + tw_player_step × (P − 2)) )`
`J_win = floor( base_win × lobby_mult(k) )`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| M | int | 2–7 | calculated (Tournament Flow F1) | Majority target, `floor(R/2) + 1` |
| P | int | 2–4 | calculated | Players at tournament start |
| tw_per_M | float | 0–3 | data file | Default 1 |
| tw_player_step | float | 0–0.5 | data file | Default 0.25 (beating 3 rivals is harder than beating 1) |
| k | int | ≥ 0 | F5 | Tournaments already completed in this lobby |

**Output Range:** 2–11 at k = 0. Rounding down after the decay is deliberate: tiny repeated tournaments run out (2-player, 3-round at k ≥ 4 pays 0).

### F4. Tournament finish award

The finish_award formula is defined as:

`base_finish = max( finish_min, round_half_up(finish_frac × base_win) )`
`J_finish = floor( base_finish × finish_mult(k) )`, with `finish_mult(k) = max(0, 1 − finish_step × k)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| finish_frac | float | 0–0.5 | data file | Default 0.3 (user: about 30% of a win) |
| finish_min | int | 0–2 | data file | Default 1 (the first finish always pays a star) |
| finish_step | float | 0–1 | data file | Default 0.5 (finish awards dry up faster than wins) |

**Output Range:** 1–3 at k = 0. Because a star cannot be split, small tournaments round **up** to 1 (up to 50% of a 2-star win); large ones land near 30%.

**Worked values, F3 and F4 (k = 0 → 4):**

| Tournament | base_win | Win, k = 0 / 1 / 2 / 3 / 4 | base_finish | Finish, k = 0 / 1 / 2 | Length (Tournament Flow F2) |
|---|---|---|---|---|---|
| 2 players, R = 3 (M 2) | 2 | 2 / 1 / 1 / 1 / 0 | 1 | 1 / 0 / 0 | ≈ 7 min |
| 2 players, R = 7 (M 4) | 4 | 4 / 3 / 2 / 2 / 1 | 1 | 1 / 0 / 0 | ≈ 23 min |
| 3 players, R = 5 (M 3) | 4 | 4 / 3 / 2 / 2 / 1 | 1 | 1 / 0 / 0 | ≈ 15 min |
| 4 players, R = 5 (M 3) | 5 | 5 / 4 / 3 / 2 / 2 | 2 | 2 / 1 / 0 | ≈ 17 min |
| 4 players, R = 13 (M 7) | 11 | 11 / 9 / 7 / 6 / 4 | 3 | 3 / 1 / 0 | ≈ 45 min |

At k = 0, a 4-player, 5-round tournament pays 5 + 3 × 2 = 11 stars across the table (≈ 2.75 per player, ≈ 9.7 per player per hour).

### F5. Lobby rematch decay

The lobby_mult formula is defined as:

`lobby_mult(k) = max(lobby_floor, 1 − lobby_step × k)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| k | int | ≥ 0 | calculated (memory only) | Tournaments completed in this lobby session |
| lobby_step | float | 0–0.5 | data file | Default 0.15 |
| lobby_floor | float | 0–1 | data file | Default 0.4 |

**Output Range:** 1.0 → 0.85 → 0.70 → 0.55 → 0.40 (from the 5th on).

**Farming check** (two phones, 2-player, 3-round tournaments won 2–0 back to back, ≈ 8.5 per hour):
- **One lobby:** the farming profile gets 2 + 1 + 1 + 1 + 0 … ≈ **5 stars in the first hour**, then 0; the other phone gets 1 once.
- **Closing and reopening the lobby every time** (≈ 1.5 min extra per cycle, ≈ 7 cycles/h): ≈ **14 stars/h** for the winning profile, or ≈ 10.5 each if the two alternate. The typical campaign rate is ≈ 15/h (F7), so even the worst case does not beat playing, and it costs tedious re-setup. Accepted; see Open Questions.

### F6. Time to afford

The time_to_afford formula is defined as:

`T_afford = max(0, price − J_now) / R_earn`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| price | int | 2–35 | Shop catalog | Item price in stars (Shop F1–F3) |
| J_now | int | 0–jar_cap | save | Current jar |
| R_earn | float | stars/hour | F7 model / playtest | The player's earn rate (typical ≈ 15/h) |

**Example:** a fresh profile wanting a 10-star tier-1 perk in the meadow: 10 / 15 ≈ **0.67 h ≈ 2 sessions** of 20 minutes, around meadow level 5.

### F7. Sink/faucet model (100 main levels, extras, side islands, tournaments)

**Faucets (lifetime, one profile; 1 earned star = 1 jar star):**

| Faucet | Levels | Max stars | Typical player | Completionist | Bounded? |
|---|---|---|---|---|---|
| Main path (10 biomes × 10) | 100 | 300 | ≈ 230 (all ★, all ★★, ★★★ on 30% = 23 per biome) | 300 | Yes |
| Bonus levels (1 per biome) | 10 | 30 | ≈ 10 (≈ 5 at ★★) | 30 | Yes |
| Hard-track remixes (≈ 3 per biome) | 30 | 90 | ≈ 9 | 90 | Yes |
| Side islands (4 × 6 levels) | 24 | 72 | ≈ 24 (two islands at ★★) | 72 | Yes |
| Replays (F2) | 164 | 164 | ≈ 15 | ≈ 120 | Yes, hard cap |
| **Campaign total** | | **656** | **≈ 290 over ≈ 18 h** | **≈ 610 over ≈ 35 h** | |
| Tournaments (F3–F5) | — | — | 5–20 per family evening | same | **No** (open-ended, decayed) |

A *minimum* player (exactly the 15-star gate in every biome) puts **150** stars into the jar on the main path.

**Earn rate:** a biome takes ≈ 1.5 h for a typical player (Campaign Structure Game Feel) and pays ≈ 23 stars, so **≈ 15 stars/h**, flat across biomes (no biome multiplier). Typical cumulative jar income by the end of each biome (main path only): 23 · 46 · 69 · 92 · 115 · 138 · 161 · 184 · 207 · 230.

**Sinks (from `shop.md` F4):**

| Sink | Capacity | Runs out? |
|---|---|---|
| Perks (4 characters × 3 edge perks; signatures free) | 260 | Yes, one-time purchases |
| Cosmetics (44 at launch: 10 biome sets + 1 party set) | 385 | Yes, one-time purchases |
| Potions | unlimited (2–4 each, 5 per type carried) | No, the only repeatable sink |
| **Finite total** | **645** | |

**Balance verdict (defaults):**
- **Typical player:** ≈ 290 over the campaign. The cloud wizard's full perk set (65) is affordable by the end of biome 3 (≈ 4.5 h); by the end, the player owns roughly all 12 perks **or** one or two characters' perks plus ≈ 150 stars of looks, with ≈ 10 potions used along the way. The jar stays low (0–20 when the player spends). Every star has a use and there is no hoard.
- **Completionist:** ≈ 610 (hard maximum 656) against 645 of finite sinks, so 100% completion and the full catalog arrive together; tournament income covers the gap and potions.
- **Party-only profile** (never plays the campaign): a family evening of three 4-player, 5-round tournaments pays ≈ 5 stars per player on average (winners 5 / 4 / 3, finishers 2 / 1 / 0). A player who never wins gets 3 per evening, so a tier-1 perk takes 2–4 evenings. This is the slow path, by design.
- **After the catalog is exhausted**, tournaments keep paying and only potions remain, so the jar grows slowly. Accepted: the economy is closed and per-profile, with no trading and no leaderboards. The health check that matters is the time between purchases **during** the campaign (target: one purchase every 40–90 min of play).

## Edge Cases

- **If a replay raises ★★ to ★★★**: +1 jar star (F1); no replay award; `replays_paid` unchanged.
- **If the first win is ★ and a later run reaches ★★★**: +2 in that run.
- **If the player spends every jar star**: earned stars, gates, bonus levels and the map are unchanged (rule 1).
- **If a level is re-versioned or its star times change** (ADR-0013 §4): earned stars stay. Nothing is re-paid or clawed back.
- **If a level is removed from the shipped campaign**: jar stars already paid are kept; its earned stars stay in the save (ADR-0013 keeps unknown keys).
- **If the player wins with a potion or perks on**: pays normally; ★★★ is allowed (`shop.md` rule 18).
- **If the app is killed after a win but before the save**: neither the earned stars nor the jar stars were written (same write, rule 18).
- **If two players tie exactly for the tournament win** (split win): each gets the full win award; nobody else's award changes.
- **If two players reach M in the same round**: only the sudden-death winner gets the win award; the other gets the finish award.
- **If a player disconnects and rejoins** (Tournament Flow): paid by their status at the end (winner or finisher). A player not present at the end gets nothing.
- **If the host ends the tournament after 1 round** (`M` not reached): nobody is paid (rule 14), so starting and quitting tournaments cannot farm finish awards.
- **If a player is a guest on their phone**: nothing is paid or saved (ADR-0013 §6).
- **If the lobby is closed and reopened to reset the decay**: allowed; F5 shows this still earns no more than the campaign.
- **If the jar would pass `jar_cap`**: clamped; excess discarded with a "jar full" note; `earned_total` counts only what was kept.
- **If `star_balance ≠ earned_total − spent_total` on load**: `star_balance` is recomputed from the totals and a warning is logged; it can never go negative.
- **If the save has a newer schema** (read-only mode, ADR-0013 §2): wins in this session pay nothing to disk. The result screen shows "progress can't be saved on this version" (owned by ADR-0016).
- **Cloud merge (later)**: earned stars merge by max per level; `replays_paid` by max. The jar cannot merge by max because stars are spent; it needs a per-device earn/spend ledger, designed with the first cloud backend (ADR-0013 §8).

## Dependencies

**Upstream:** Scoring & Stars (Hard: best stars, stars in run), Campaign Structure and Level Data (Hard: level ids; gates read earned stars), Tournament Flow (Hard: winner, finishers, early end, `M`, players), Save & Profile / ADR-0013 (Hard: `wallet` map, guests, atomic write), Local Multiplayer Setup and ADR-0009 (Soft: lobby lifetime, host-authoritative result).

**Downstream:** Shop (Hard: jar, debit), Menus & Level Select and result screens (Soft: star drop, jar counter), Characters & Perks and Skills indirectly through the Shop (Soft).

**Conflict flagged (not edited here):** ADR-0013 §5 shows the reserved literal `"wallet": { "points": 0 }`. The owning system defines the inner fields (ADR-0013 §5), so this GDD replaces it with `star_balance` (rule 17); the ADR's example should be updated to match. Other GDDs that say "points" for the meta currency (Scoring & Stars, Campaign Structure, Tournament Flow, `design/levels/meadow.md` "Stars still pay points") should say "stars / Star Jar".

## Tuning Knobs

All in `assets/data/economy/stars.json` (proposed path; data-driven, validated at load).

| Knob | Range | Default | Affects |
|---|---|---|---|
| replay_pay | 0–2 | 1 | Replay trickle size (F2) |
| replay_min_stars | 1–3 | 2 | Which replays pay |
| replay_cap | 0–3 | 1 | Paid replays per level; 0 = none |
| tw_per_M | 0–3 | 1 | Tournament win size (F3) |
| tw_player_step | 0–0.5 | 0.25 | Extra for bigger tournaments |
| finish_frac / finish_min | 0–0.5 / 0–2 | 0.3 / 1 | Finish award size (F4) |
| finish_step | 0–1 | 0.5 | How fast finish awards dry up |
| lobby_step / lobby_floor | 0–0.5 / 0–1 | 0.15 / 0.4 | Win decay (F5) |
| jar_cap | 999–99 999 | 9 999 | Display and overflow guard |

Campaign stars have no knob: one earned star is one jar star (user decision). **Safe-range notes:** keep the reset-farming rate (F5, ≈ 14/h) below the typical campaign rate (≈ 15/h); raising `tw_per_M` above 1 breaks this unless `lobby_floor` drops. Keep `replay_pay` below the cheapest potion (Shop F5). Keep `finish_frac ≤ 0.5` so finishing never pays like winning.

## Visual/Audio Requirements

- Result screen: after the stars stamp onto the level card (Scoring & Stars), a copy of each **new** star pops off and drops into the Star Jar counter, one per star, rising pitch. The stamped stars stay on the card. A replay award shows one smaller star hop with no fly. Nothing shows when nothing is paid (no "0").
- Tournament results: each phone shows its own player's win or finish stars dropping into the jar.
- Audio events: `jar_star_gained` (per star), `jar_star_replay`, `jar_full`.

## Game Feel

Earning should feel like a bonus copy of the stars the player already chases, not a second scoreboard. Targets (playtest): a typical player affords their first perk in the meadow (≈ 40 min), then a purchase every 40–90 min. No tester believes spending lowered their stars or locked a biome. No tester describes replaying a level "for stars" after its replay award is gone.

## UI Requirements

Two clearly different displays: **earned stars** on level cards, biome totals and gates (gold stars, as now), and the **Star Jar** counter (a jar icon with a number) on the island map, level select and shop. On the level card, unearned stars show "+1 for the jar" so the goal gradient points at stars, not grind. Player-facing name "Star Jar" (translation key `STAR_JAR`). 📌 **UX Flag — Star Economy**: include the result-screen star drop and the jar counter in `/ux-design`.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/scoring-stars.md` Core Rules 1, 4, 5 | Stars, best-only saving; earned stars stay owned there |
| `design/gdd/campaign-structure.md` Core Rules 1, 4, 6, 10, 17; F1 | Biomes, bonus, hard-track remixes, gates, free replays |
| `design/levels/meadow.md` (hard track, tiers 12–14) | 3 remixes per biome |
| `design/gdd/tournament-flow.md` Core Rules 3, 5, 6, 8; F1, F2; edge cases | M, sudden death, lengths, early end |
| `docs/architecture/adr-0013-save-profile-settings.md` §3, §4, §5, §6, §8 | Wallet map, atomic write, no wall time, guests, cloud seam |
| `docs/architecture/adr-0009-local-multiplayer.md` | Host-authoritative results paid per device |
| `design/gdd/shop.md` | Prices in stars, sink capacity |
| `production/session-state/decisions.md` (/team-narrative round) | Stars only; finish award ≈ 30%; potions allow ★★★; characters by story; tie = split win |

## Acceptance Criteria

1. [U] F1: meadow_03 first win ★★ → jar +2; a later ★★★ → +1; a further ★★★ → 0 (F2 applies instead).
2. [U] F1: first win ★★★ on a side-island level → jar +3.
3. [U] **GIVEN** any purchase, **THEN** every level's earned stars, every biome total and every gate result are unchanged.
4. [U] F2: two replays of a meadow level with best ★★, each at ★★ → +1, then 0; `replays_paid` stops at 1. A replay at ★ → 0.
5. [U] **GIVEN** a replay that raises stars, **THEN** F1 pays, no replay award, `replays_paid` unchanged.
6. [U] **GIVEN** a lost level, **THEN** jar +0 and no field changes.
7. [U] F3/F4: 4 players, R = 5 at k = 0 → winner 5, each finisher 2; at k = 2 → winner 3, finishers 0. 2 players, R = 3 at k = 4 → winner 0.
8. [U] F5: k = 0..5 → 1.0, 0.85, 0.70, 0.55, 0.40, 0.40.
9. [U] **GIVEN** an exact tie for the tournament win, **THEN** both tied players get the full win award.
10. [U] **GIVEN** a tournament ended early by the host after `M` rounds, **THEN** no win award and remaining players get the finish award; after fewer than `M` rounds, nobody is paid.
11. [U] **GIVEN** quick versus or Arcade, **THEN** jar +0.
12. [U] **GIVEN** a guest profile, **THEN** no wallet write occurs; **GIVEN** profiles 0 and 1, **THEN** stars earned in 0 never change 1's jar.
13. [U] **GIVEN** a save with earned stars and no `star_balance`, **THEN** migration adds their sum to the jar once and drops `wallet.points`.
14. [U] **GIVEN** a corrupted `star_balance` with valid totals, **THEN** the loader restores `earned_total − spent_total`; **GIVEN** a jar at `jar_cap`, **THEN** a further award leaves it at the cap.
15. [I] **GIVEN** a win, **THEN** earned stars and jar stars land in the same `progress.json` write (inject a fault after the write: both or neither are present).
16. [M] **GIVEN** a playtest of the first two biomes, **THEN** median time to the first perk purchase is 30–90 min, the median jar at the end of biome 2 is under 25, and no tester thinks spending lowered their stars.

## Open Questions

- **Quick versus**: pays nothing by default (user listed tournament wins/finishes only). Should a quick-versus win pay a star with its own decay? Revisit when that mode has a GDD.
- **Persistent tournament decay**: the in-memory lobby decay can be reset by reopening the lobby (F5, ≈ 14/h worst case). Keep it in memory; revisit only if playtests show farming.
- **Cloud jar merge**: needs a per-device earn/spend ledger when the first cloud backend lands (ADR-0013 §8).
- **Hard-track count**: F7 assumes 3 remixes per biome (30 levels, 90 stars). If later biomes ship a different count, F7 and the Shop's F4 target are recomputed.
