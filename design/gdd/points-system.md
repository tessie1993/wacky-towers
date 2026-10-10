# Points System

> **Status**: In Design
> **Author**: Tessa + agents (economy-designer)
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10
> **Implements Pillar**: Comeback Energy; Variation Over Depth; The Block Is the Constant

## Summary

Points are the game's one meta currency. They are earned only two ways: **stars** in the campaign (paid once per star, ever) and **wins** in multiplayer (round wins and tournament wins). Replaying a level you already beat pays a small amount that halves each time and stops after three paid replays, so a level cannot be farmed. Each of the 4 save profiles has its own wallet. Points are spent only in the Shop (perks, potions, cosmetics). There is no real-money path; the price data carries a currency field as the only seam.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Scoring & Stars, Campaign Structure, Tournament Flow, Save & Profile (ADR-0013)`

## Overview

The Points System turns mastery into choice. The campaign pays for **each star the first time it is earned** on a level (★ 10, ★★ 15, ★★★ 25 at biome 1), scaled up gently by biome so later, longer levels pay more (F1, F2). The bonus level and hard-track remixes pay 1.5×. Once a level's stars are paid, they are never paid again. A later win on that level with no new star pays a **replay award** that halves with each paid replay and stops after `replay_cap` (default 3), so the total a level can ever pay is fixed (F3). Multiplayer pays for **wins only**: each round win, plus a tournament-win bonus that grows with tournament length and player count (F4). Repeat tournaments in the same lobby pay a little less each time, down to a floor (F5), and the best possible multiplayer rate stays below the campaign's rate, so "farming" a tournament with a second phone earns less than just playing. Arcade, failed levels and score pay nothing: score is a different number (Scoring & Stars) and never converts to points. Each profile's wallet lives in its own `progress.json` (ADR-0013 §5 `wallet`), so siblings never share or transfer points. Points serve *Comeback Energy* (every round win pays, even for a player who loses the tournament), *Variation Over Depth* (points buy perks, potions and cosmetics that change how a level plays or looks) and *The Block Is the Constant* (points come from playing blocks, never from menus or timers). All values are starting defaults, tuned by playtest.

## Player Fantasy

"I got the third star, and now I can afford the Bomb potion for that volcano level." Points should feel like a reward for getting better, never like a chore. The player always sees what the next purchase is and roughly how many stars away it is. Kids should never feel punished for losing a tournament to a parent: every round they win still pays.

## Detailed Design

### Core Rules

**Wallet**
1. Each profile has one wallet: an integer `points` balance (ADR-0013 §5 `wallet.points`). Guests (no profile, ADR-0013 §6) earn and keep nothing.
2. The balance never goes below 0 and is capped at `wallet_cap` (default 99 999). Earnings over the cap are discarded with a "wallet full" note. A normal player never comes close (F7).
3. Points can only be **earned** by the rules below and only **spent** in the Shop (`design/gdd/shop.md`). They cannot be transferred between profiles, refunded for money, or bought.
4. Points are integers. Every award is computed as a real number and rounded half up once, at the end of its formula.

**Campaign: stars (the main faucet)**
5. When a level result raises the saved best stars (Scoring & Stars rule 4), the player is paid for **each newly reached star tier** on that level: from `stars_paid + 1` to the new best (F2). `stars_paid` is stored per level in the wallet (rule 18), so a star tier is paid **exactly once per profile, ever**.
6. A first win with ★★★ pays all three tiers at once (★ + ★★ + ★★★).
7. Stars earned with relaxed timing (ADR-0013 §4, no badge) pay exactly the same.
8. Stars on main-path levels (tiers 1–10) pay ×1. Stars on the bonus level (tier 11) and hard-track remixes (tiers 12+) pay `extra_track_mult` (default 1.5), because they are the optional hard content (Campaign Structure rules 10, 17).
9. Lost levels pay nothing. Retrying is free (Campaign Structure rule 6); the first win is when stars are paid.

**Campaign: replays (the trickle)**
10. A **replay** is a win on a level that was already won before, which raises no star tier. It pays a replay award (F3) based on the stars earned **in that run**, halved for each replay already paid on that level.
11. After `replay_cap` paid replays (default 3) a level pays no more replay awards. The level can still be replayed freely for fun, times and score.
12. A win that raises stars pays star points (rule 5) **instead of** a replay award, and does not count toward `replay_cap`.

**Multiplayer: wins only**
13. **Tournament** (Tournament Flow): each round win pays `tp_round` (default 10) to the winner, including sudden-death and shared-tie round wins (Tournament Flow rules 3, 6). The tournament winner also gets the win bonus (F4), which scales with the majority target `M` and the number of players.
14. **Quick versus** (a single versus match; mode set by the decision sheet, no GDD yet): a match win pays `qv_win` (default 6). A lost match pays nothing.
15. **Lobby rematch decay**: within one lobby session (Local Multiplayer Setup), every tournament or quick-versus match already completed lowers the next one's payout (F5) to a floor of `lobby_floor` (default 40%). The count is kept in memory only, never saved, and resets when the lobby closes. This follows ADR-0013 §5: nothing in the wallet is computed from wall time.
16. On LAN (ADR-0009, one phone per player), each device pays **its own** active profile from the host's authoritative result. A device whose player is a guest pays nothing.
17. A tournament that ends early (host leaves, fewer than 2 players remain; Tournament Flow edge cases) pays the round wins already earned and **no** win bonus.

**Bookkeeping (save fields, inside the ADR-0013 `wallet` map)**
18. The Points System owns these fields (all integers, all keyed by stable ids):
    ```json
    "wallet": { "points": 0, "earned_total": 0, "spent_total": 0,
                "stars_paid":   { "meadow_03": 2 },
                "replays_paid": { "meadow_03": 1 } }
    ```
    `stars_paid` and `earned_total` only grow. `points = earned_total − spent_total` must always hold; the loader repairs `points` from the totals if they disagree and logs a warning.
19. Points are applied when the `LevelResult` (or the tournament/match result) is applied, and saved in the same `progress.json` write as the stars (ADR-0013 §3), so stars and points can never get out of step.
20. **Backfill**: when a save from before the Points System is loaded (stars present, `stars_paid` missing), every existing star is paid once by F2, with no replay awards. This runs once, inside the schema migration that adds these fields.

### States and Transitions

Per level: **Unpaid → Partly paid (stars_paid 1–2) → Fully paid (3)**, and independently **replays 0 → 1 → 2 → 3 (exhausted)**. Per lobby: **k = 0 → 1 → 2 …** (in memory; reset on lobby close). The wallet itself has no states.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Scoring & Stars | → Points | Stars earned in the run; best stars before/after |
| Campaign Structure, Level Data | → Points | Biome index, tier (track), level id |
| Tournament Flow | → Points | Round winners, tournament winner, `R`, `M`, player count |
| Quick versus (no GDD yet), Local Multiplayer Setup | → Points | Match winner; lobby open/close |
| Save & Profile (ADR-0013) | ↔ | `wallet` map in each profile's `progress.json`; guests excluded |
| Shop | ↔ | Reads balance; debits on purchase (`spent_total`) |
| Menus & Level Select, HUD (result screens) | Points → | "+N" on result screens; wallet counter on map and shop |
| Characters & Perks (`characters-perks.md`), Skills (`skills.md`) | — | No direct flow; they are bought through the Shop |
| Arcade Mode | — | Pays nothing (score only), by design |

## Formulas

### F1. Biome multiplier

The biome_mult formula is defined as:

`bm(b) = 1 + biome_step × (b − 1)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| b | int | 1–10 | data file (Level Data `biome`) | Biome index along the main chain; side-island biomes use the index of the biome they branch from |
| biome_step | float | 0–0.3 | data file | Default 0.15 |

**Output Range:** 1.0 (biome 1) to 2.35 (biome 10). `Σ bm(1..10) = 16.75`. **Example:** biome 4 → 1.45. Rationale: later biomes have longer, harder levels (Campaign Structure F2), so their stars pay more while shop prices stay fixed. Purchases come at a steady pace instead of slowing down.

### F2. Star points

The star_points formula is defined as:

`P_star = Σ_{k = stars_paid + 1 .. new_best} round(star_value[k] × bm(b) × track_mult)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| star_value[1..3] | int | 0–100 each | data file | Defaults 10 / 15 / 25 (the hardest star pays most) |
| stars_paid | int | 0–3 | save (`wallet.stars_paid`) | Highest tier already paid on this level |
| new_best | int | 1–3 | calculated (Scoring & Stars) | New saved best stars |
| track_mult | float | 1–2 | data file | 1.0 main path; `extra_track_mult` 1.5 for tiers 11+ |

**Output Range:** 0 (no new tier) to 176 (35 + 53 + 88: all three tiers at once on a biome-10 hard-track level). **Examples:**
- meadow_03, first win ★★: 10 + 15 = **25**. Later replay reaching ★★★: **+25**. Any later win: 0 star points.
- Biome 10 tier 10, first win ★★★: round(23.5) + round(35.25) + round(58.75) = 24 + 35 + 59 = **118**.

Per-level maximum by biome (main path, rounded): 50 · 58 · 66 · 73 · 80 · 88 · 96 · 103 · 110 · 118 → **842 per 10-level column, 8 420 for the main path**.

### F3. Replay award

The replay_award formula is defined as:

`P_replay = round(replay_base × s_run × bm(b) × replay_decay^n)` if `n < replay_cap`, else `0`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| replay_base | float | 0–5 | data file | Default 2 |
| s_run | int | 1–3 | calculated | Stars earned in this run (not the saved best) |
| n | int | 0–replay_cap | save (`wallet.replays_paid`) | Replays already paid on this level |
| replay_decay | float | 0–1 | data file | Default 0.5 |
| replay_cap | int | 0–10 | data file | Default 3 |

**Output Range:** 0–14 per replay at defaults. Lifetime cap per level: `replay_base × 3 × bm × (1 + 0.5 + 0.25) = 10.5 × bm` (10.5 in biome 1, about 25 in biome 10). **Examples:** meadow_03 replayed at ★★: n = 0 → 4, n = 1 → 2, n = 2 → 1, n = 3 → 0. Biome 10 at ★★★, n = 0 → round(14.1) = 14.

**Anti-farming proof:** the lifetime replay value of the whole campaign is bounded: `10.5 × Σ bm × 10` = 1 759 (main path) + about 700 (extras) ≈ **2 460 points**, no matter how long someone replays.

### F4. Tournament and quick-versus award

The versus_award formula is defined as:

`P_tour = round( (tp_round × W + is_winner × tp_win × M × (1 + tp_player_step × (P − 2))) × lobby_mult(k) )`

`P_qv = round(qv_win × is_match_winner × lobby_mult(k))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| W | int | 0–R+1 | calculated (Tournament Flow) | Round wins this player earned (incl. sudden death, shared ties) |
| M | int | 2–7 | calculated (Tournament Flow F1) | Majority target, `floor(R/2) + 1` |
| P | int | 2–4 | calculated | Players at tournament start |
| tp_round | int | 0–50 | data file | Default 10 |
| tp_win | int | 0–50 | data file | Default 10 |
| tp_player_step | float | 0–0.5 | data file | Default 0.25 (beating 3 rivals is harder than beating 1) |
| qv_win | int | 0–30 | data file | Default 6 |
| is_winner, is_match_winner | 0/1 | — | calculated | 1 for the tournament or match winner |

**Output Range:** 0 to 175 per tournament at k = 0 (4 players, 13 rounds, winner with 7 wins). **Examples (k = 0):**

| Tournament | Winner | Others (total) | Length (Tournament Flow F2) | Winner per hour | Average per player per hour |
|---|---|---|---|---|---|
| 2 players, R = 3, won 2–0 | 20 + 20 = **40** | 0 | ≈ 7 min | ≈ 340 | ≈ 170 |
| 2 players, R = 7, won 4–3 | 40 + 40 = **80** | 30 | ≈ 23 min | ≈ 210 | ≈ 145 |
| 4 players, R = 5, won 3–1–1–0 | 30 + 45 = **75** | 20 | ≈ 17 min | ≈ 265 | ≈ 85 |
| 4 players, R = 13, won with 7 | 70 + 105 = **175** | 60 | ≈ 45 min | ≈ 235 | ≈ 80 |

### F5. Lobby rematch decay

The lobby_mult formula is defined as:

`lobby_mult(k) = max(lobby_floor, 1 − lobby_step × k)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| k | int | ≥ 0 | calculated (memory only) | Tournaments + quick-versus matches already completed in this lobby session |
| lobby_step | float | 0–0.5 | data file | Default 0.15 |
| lobby_floor | float | 0–1 | data file | Default 0.4 |

**Output Range:** 1.0 → 0.85 → 0.70 → 0.55 → 0.40 (from the 5th on). **Example:** a family's third tournament of the evening (k = 2), 4 players, R = 5: the winner gets round(75 × 0.7) = 53.

**Farming check:** two phones running 2-player, 3-round tournaments won 2–0 back to back (about 8.5 per hour) earn `40 × (1 + 0.85 + 0.70 + 0.55 + 0.40 × 4.5)` ≈ **196 points/hour**. A typical campaign player earns 217–510/hour (F7), so farming earns less than playing.

### F6. Time to afford

The time_to_afford formula is defined as:

`T_afford = max(0, price − W_now) / R_earn`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| price | int | 30–700 | Shop catalog | Item price (Shop F1–F3) |
| W_now | int | 0–wallet_cap | save | Current balance |
| R_earn | float | points/hour | F7 model / playtest | The player's earn rate |

**Example:** a fresh profile wanting a 200-point tier-1 perk in the meadow (R_earn ≈ 217/h, about 72 per 20-minute session): 200 / 217 ≈ **0.9 h ≈ 3 sessions**, around meadow level 6–7.

### F7. Sink/faucet model for the 100-level campaign and tournaments

**Faucets (lifetime, one profile):**

| Faucet | Formula | Typical player | Completionist | Bounded? |
|---|---|---|---|---|
| Main-path stars (100 levels) | F2 | ≈ 5 480 (all ★, all ★★, ★★★ on 30%) | 8 420 | Yes, exhaustible |
| Extra-track stars (bonus + ~3 hard-track remixes per biome, 1.5×) | F2 × 1.5 | ≈ 300 (a few bonus levels) | ≈ 5 050 | Yes |
| Replays | F3 | ≈ 330 (≈ 5 paid replays per biome) | ≈ 2 460 | Yes, hard cap |
| Tournaments / quick versus | F4, F5 | 20–80 per evening | same | **No** (open-ended, decayed) |
| **Campaign total** | | **≈ 6 100 over ≈ 15 h** | **≈ 15 930 over ≈ 30+ h** | |

A *minimum* player (exactly the 15-star gate in every biome: ★ on all, ★★ on half) earns about 175 × 16.75 ≈ **2 930** on the main path.

**Typical-player earnings by biome** (main path, `10 × (★ + ★★) + 3 × ★★★`, ≈ 1.5 h per biome, Campaign Structure Game Feel):

| Biome | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Earned | 325 | 377 | 429 | 478 | 520 | 572 | 624 | 673 | 715 | 767 |
| Cumulative | 325 | 702 | 1 131 | 1 609 | 2 129 | 2 701 | 3 325 | 3 998 | 4 713 | 5 480 |
| Points / hour | ≈ 217 | 251 | 286 | 319 | 347 | 381 | 416 | 449 | 477 | 511 |

**Sinks (from `shop.md`, F4 there):**

| Sink | Capacity | Runs out? |
|---|---|---|
| Perks (12 buyable at the default 4 characters × 3) | 5 200 | Yes, one-time purchases |
| Cosmetics (44 at launch) | 10 450 | Yes, one-time purchases |
| Potions | unlimited (30–60 each, 5 per type carried) | No, the only repeatable sink |
| **Finite total** | **15 650** | |

**Balance verdict (defaults):**
- **Typical player:** earns ≈ 6 100 over the campaign; one character's full perk set (1 300) is affordable by the end of biome 4 (≈ 6 h), and by the end of the campaign the player has roughly all 12 perks **or** one character's perks plus about 4 000 in cosmetics, with about 10 potions used along the way. The balance at each biome's end stays low (0–400 when the player spends). Every point has a use, and there is no hoard.
- **Completionist:** earns ≈ 15 930 against 15 650 of finite sinks, so 100% completion and the full catalog arrive together, with about 280 left plus tournament income for potions.
- **Party-only profile** (never plays the campaign): ≈ 24 points per 4-player 5-round tournament on average. A tier-1 perk takes about 8–9 tournaments (≈ 2.5 h). This is the slow path. See Open Questions (participation points).
- **After the catalog is exhausted**, tournaments keep paying and only potions remain as a sink, so the balance grows. This is accepted: the economy is closed and per-profile, with no trading, no leaderboards and no fixed prices tied to the balance, so a large late balance harms nobody. The health check that matters is the time between purchases **during** the campaign (target: a purchase every 1–1.5 h of play).

## Edge Cases

- **If a replay raises ★★ to ★★★**: pays the ★★★ tier only (F2); no replay award; `replays_paid` unchanged.
- **If the first win is ★ and a later run reaches ★★★ directly**: pays ★★ + ★★★ in that run.
- **If a level is re-versioned or its star times change** (ADR-0013 §4): saved stars stay and `stars_paid` stays. Nothing is re-paid or clawed back, even if the new star times are harder.
- **If a level's biome or track changes in data**: already-paid tiers stay paid at the old value; new tiers pay at the new value.
- **If a level is removed from the shipped campaign**: points already earned are kept.
- **If the player wins with a potion or perks on**: pays normally (star times are balanced for no perks; potions follow `shop.md` rule 18).
- **If the app is killed after a win but before the save**: neither stars nor points were written. They stay consistent because they are saved in the same write (rule 19).
- **If two players tie a round** (shared win): both are paid `tp_round`.
- **If two players reach M in the same round**: both are paid their round wins; only the sudden-death winner gets the win bonus.
- **If a player disconnects and rejoins** (Tournament Flow): paid for rounds they actually won; the win bonus only if they win the tournament.
- **If a player is a guest on their phone**: nothing is paid or saved (ADR-0013 §6).
- **If the lobby is closed and reopened to reset the decay**: allowed. It costs re-setup time, and F5 shows that the uncapped rate is still below the campaign rate. Not worth a persistent counter (see Open Questions).
- **If the wallet would pass `wallet_cap`**: the balance is clamped and the excess discarded with a "wallet full" note; `earned_total` counts only what was kept.
- **If `points ≠ earned_total − spent_total` on load** (corruption or a bug): `points` is recomputed from the totals and a warning is logged; it can never go negative.
- **If the save has a newer schema** (read-only mode, ADR-0013 §2): wins in this session pay nothing to disk. The result screen shows "progress can't be saved on this version" (owned by ADR-0016).
- **Cloud merge (later)**: `stars_paid` merges by max per level and `replays_paid` by max. The balance cannot be merged by max because points are spent. It needs a per-device earn/spend ledger, designed with the first cloud backend (Open Questions; ADR-0013 §8 leaves the inventory merge to its owner).

## Dependencies

**Upstream:** Scoring & Stars (Hard: best stars, stars in run), Campaign Structure and Level Data (Hard: biome, tier, level id), Tournament Flow (Hard: round and tournament results), Save & Profile / ADR-0013 (Hard: `wallet` map, guests, atomic write), Local Multiplayer Setup and ADR-0009 (Soft: lobby lifetime, host-authoritative result), quick versus (Soft; no GDD yet).

**Downstream:** Shop (Hard: balance, debit), Menus & Level Select and result screens (Soft: "+N" display, wallet counter), Characters & Perks (`characters-perks.md`) and Skills (`skills.md`) indirectly through the Shop (Soft).

Bidirectional notes: Scoring & Stars, Campaign Structure, Tournament Flow and Save & Profile already list the Points System downstream. Characters & Perks and Skills should list Shop/Points as their purchase path.

## Tuning Knobs

All in `assets/data/economy/points.json` (proposed path; data-driven, validated at load).

| Knob | Range | Default | Affects |
|---|---|---|---|
| star_value[1..3] | 0–100 | 10 / 15 / 25 | Main faucet size; how much ★★★ mastery is worth |
| biome_step | 0–0.3 | 0.15 | Late-campaign earn rate (F1); 0 = flat |
| extra_track_mult | 1–2 | 1.5 | Reward for optional hard content |
| replay_base | 0–5 | 2 | Replay trickle size |
| replay_decay | 0–1 | 0.5 | How fast replays dry up |
| replay_cap | 0–10 | 3 | Paid replays per level; 0 = no replay awards |
| tp_round | 0–50 | 10 | Value of each round win |
| tp_win | 0–50 | 10 | Tournament-win bonus per M |
| tp_player_step | 0–0.5 | 0.25 | Extra bonus for bigger tournaments |
| qv_win | 0–30 | 6 | Quick-versus match win |
| lobby_step / lobby_floor | 0–0.5 / 0–1 | 0.15 / 0.4 | Rematch decay (F5) |
| wallet_cap | 9 999–999 999 | 99 999 | Display and overflow guard |

**Safe-range notes:** keep `star_value[3] ≥ star_value[2]` (mastery pays most). Keep the F5 farming rate below the biome-1 campaign rate (≈ 217/h): raising `tp_round` or `tp_win` above about 15 breaks this unless `lobby_floor` drops. Keep `replay_base × 3 × bm(10)` below the cheapest potion price (Shop F5), so a potion used on a replay is never a profit.

## Visual/Audio Requirements

- Result screen: after the stars stamp in (Scoring & Stars), each newly paid star flies a "+N" coin to the wallet counter, one per tier, rising pitch. Replay awards show a smaller "+N replay" with no fly. A level with replays exhausted shows nothing (no "0").
- Tournament results: each phone shows its own player's "+N" per round win and the win bonus.
- Audio events: `points_gained` (per tier), `points_replay`, `wallet_full`.

## Game Feel

Earning should feel like a bonus on top of the stars, not a second scoreboard. Targets (playtest): a typical player affords their first perk during the meadow (≈ 1 h), and purchases come every 1–1.5 h of campaign play after that. No tester describes replaying a level "for points" after its replays run out.

## UI Requirements

Wallet counter on the island map, level select and shop. On the level card, show "★★★ pays +N" for unearned stars, so the goal gradient points at stars, not grind. The result screen "+N" sequence. 📌 **UX Flag — Points System**: include the result-screen points sequence and the map wallet counter in `/ux-design`.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/scoring-stars.md` Core Rules 1, 4, 5 | Stars, best-only saving, results sent to Points |
| `design/gdd/campaign-structure.md` Core Rules 1, 6, 10, 17; F2 | Biomes, tiers, extra tracks, free replays, length growth |
| `design/gdd/tournament-flow.md` Core Rules 3, 5, 6, 8; F1, F2; edge cases | Round wins, M, sudden death, lengths, early end |
| `docs/architecture/adr-0013-save-profile-settings.md` §3, §4, §5, §6, §8 | Wallet field, atomic write, no wall time, guests, cloud seam |
| `docs/architecture/adr-0009-local-multiplayer.md` (LAN, one phone per player) | Host-authoritative results paid per device |
| `design/gdd/shop.md` | Sinks, prices, sink capacity |
| `design/gdd/characters-perks.md`, `design/gdd/skills.md` (in progress) | What perks exist; skills are not sold |
| `design/gdd/game-concept.md` | "Points from 3-star clears and multiplayer wins" |

## Acceptance Criteria

1. [U] F2: meadow_03 first win ★★ → +25 and `stars_paid = 2`; a later ★★★ → +25; a further ★★★ → 0 star points.
2. [U] F2: biome 10 tier 10 first win ★★★ → +118; the same on a biome-10 tier-11 level → +176.
3. [U] F3: four replays of a fully paid meadow level at ★★ → 4, 2, 1, 0; `replays_paid` stops at 3.
4. [U] **GIVEN** a replay that raises stars, **THEN** star points are paid, no replay award, and `replays_paid` is unchanged.
5. [U] **GIVEN** a lost level, **THEN** 0 points and no field changes.
6. [U] F4: 4 players, R = 5, winner with 3 round wins, k = 0 → 75; a player with 1 round win → 10; with k = 2 → 53 and 7.
7. [U] F5: k = 0..5 → 1.0, 0.85, 0.70, 0.55, 0.40, 0.40.
8. [U] **GIVEN** a tournament ended early by the host, **THEN** round wins are paid and no win bonus.
9. [U] **GIVEN** a guest profile, **THEN** no wallet write occurs.
10. [U] **GIVEN** profiles 0 and 1, **THEN** points earned in 0 never change 1's wallet.
11. [U] **GIVEN** a save with stars but no `stars_paid`, **THEN** migration pays each star once by F2 and sets `stars_paid`.
12. [U] **GIVEN** a corrupted `points` with valid totals, **THEN** the loader restores `points = earned_total − spent_total`.
13. [U] **GIVEN** a balance at `wallet_cap`, **THEN** a further award leaves it at the cap.
14. [I] **GIVEN** a win, **THEN** stars and points land in the same `progress.json` write (inject a fault after the write: both or neither are present).
15. [M] **GIVEN** a playtest of the first two biomes, **THEN** median time to the first perk purchase is 45–90 min and the median wallet at the end of biome 2 is under 500.

## Open Questions

- **Participation points**: the brief says points come only from stars and wins. A party-only or younger player who rarely wins earns very slowly (F7). Option: `tour_participation_points` (default 0) for finishing a tournament. Needs a user decision.
- **Persistent tournament decay**: the in-memory lobby decay can be reset by reopening the lobby. A saved counter would need a time or play-count reset rule. Recommended to keep it in memory; revisit only if playtests show farming.
- **Player-facing currency name**: "points" collides with in-level score ("score points", Items `full_slot_points`). Recommend a distinct name (for example "Acorns" or "Sparkles"; translation key `CURRENCY_NAME`); the id stays `points` (ADR-0013).
- **Cloud wallet merge**: needs a per-device earn/spend ledger when the first cloud backend lands (ADR-0013 §8).
- **Side-island biomes** (world round): F1 uses the index of the parent biome. Confirm once the map is designed.
- **Quick versus GDD**: `qv_win` assumes one match = one win. Revisit when that mode is designed.
