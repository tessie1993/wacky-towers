# Shop

> **Status**: In Design
> **Author**: Tessa + agents (economy-designer)
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; Comeback Energy; Readable Chaos

## Summary

The Shop is where the Star Jar is spent. Stars are the only currency (`design/gdd/points-system.md`, the Star Economy). It sells three things, for stars only: **perks** (bought once, kept forever, equipped per character), **potions** (one-use buffs you bring into a level or a tournament round) and **cosmetics** (looks only). Characters are never sold; they join through the story. Spending only empties the jar: a level's earned stars, biome gates and bonus gates never change. Every price is fixed and visible. There are no random boxes, no rotating stock and no timed offers. Monetization is undecided, so the shop is designed for none, and the price data carries a currency field as the only seam.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Star Economy (points-system.md), Characters & Perks, Buffs & Debuffs, Save & Profile (ADR-0013)`

## Overview

The Shop turns jar stars, earned from campaign stars, replays and tournaments (Star Economy), into choices that change how the next level plays or looks. **Perks** come from each character's perk set (`design/gdd/characters-perks.md`). Each character's signature perk is free and always on; the three edge perks cost 10, 20 or 35 stars by tier. Higher tiers open as the player reaches later biomes or plays tournaments, and a friend's perks go on sale when that friend joins the story (Lana in Ice, Boulder in Lava, Glim in Cave) or once the profile has played a tournament, where all four are playable. Each perk is sold once and has no upgrade levels, so the shop can never push a loadout past the ~15% edge cap. **Potions** carry one of the four buff effects from Buffs & Debuffs (Helper Drop, Slow Time, Preview Peek, Bomb). They cost 2–4 stars, the player carries up to 5 of each, and one is brought into a level or a tournament round. A potion is used up only when it is actually used, and a potion run can still earn ★★★. **Cosmetics** appear four per biome as biomes open, plus four party cosmetics. Perks and cosmetics are a finite catalog of 645 stars, sized to a completionist's lifetime jar income (≈ 610, hard maximum 656), while potions are the one repeatable sink (Star Economy F7). Each of the 4 profiles has its own jar and its own purchases. This serves *Variation Over Depth* (perks and potions change the play), *Comeback Energy* (a potion can carry a stuck player past a hard level) and *Readable Chaos* (fixed prices, a short catalog, nothing hidden). All values are starting defaults.

## Player Fantasy

A cosy toy shop on a shelf (Menus' toy-shop mood): you can see everything, you know how many stars it costs, and you save up for the thing you want. Stars come out of the jar, never off your levels. Buying feels like a small celebration, never a gamble. A child who taps the wrong thing can undo it.

## Detailed Design

### Core Rules

**The shop screen**
1. The Shop is a menu screen reached from the main menu (Menus & Level Select "Shop later"; screens owned by ADR-0016). It opens once the profile has finished `shop_unlock_level` (default `meadow_03`) **or** played one tournament, so the first visit already offers something affordable (≈ 4–6 jar stars in hand, enough for a potion).
2. The catalog is data (`assets/data/shop/catalog.json`, proposed path, validated at load). Each entry has: `id` (stable StringName), `kind` (`perk` / `potion` / `cosmetic`), `price` `{ "currency": "stars", "amount": int }`, `requires` (unlock conditions, rule 9), and display keys (translation keys only).
3. **Every price is fixed and always shown**, as a number with the jar icon. The shop has no random rewards, no rotating or limited stock, no discounts tied to time and no "only today" offers. Nothing in the shop reads wall time (ADR-0013 §5).
4. **Buying**: tap an item, then a confirm card shows the item, its price and "jar after". Confirming debits `wallet.star_balance` and adds to `wallet.spent_total` (Star Economy rule 17) and grants the item in the **same** `progress.json` write (ADR-0013 §3), so a crash can never take stars without giving the item, or the reverse. Buying **never** changes earned stars (Star Economy rule 1).
5. Purchases happen only in menus, never while a `PlaySession` exists (ADR-0013 §3 "no saves in play").
6. **Not enough stars**: the buy button shows "Need N more" and a hint naming the nearest unearned stars ("★★★ on meadow_07: +1 for the jar"), pointing the player at play, not grind (goal gradient).
7. **Undo**: the most recent purchase can be undone with one tap while the player is still on the shop screen, provided the item is unused (a potion still at full count, a perk not yet equipped in a level, any cosmetic). Leaving the shop ends the undo window. This is for young players' mis-taps; it is not a refund system.
8. Owned items are never taken away: no expiry, no durability, no clawback after a rebalance or price change.

**Unlock conditions (`requires`)**
9. An entry is shown **locked** (silhouette plus condition) until its `requires` holds, then **for sale**:
   - `biome_open: b`: biome `b` is open (Campaign Structure F1, read from earned stars);
   - `tournaments_played: n`: the profile's `tournament.played ≥ n` (ADR-0013 §4);
   - `character: id`: the character has joined the profile's story (Characters & Perks rule 2);
   - conditions in a list are AND; a `any_of` list is OR.

**Characters (not sold)**
10. Characters are **never** sold. The cloud wizard is available from the start; Lana joins in Ice, Boulder in Lava and Glim in Cave (story, decision sheet). All four are always playable in multiplayer.

**Perks**
11. The perks themselves (effects, signature vs edge, loadout size, the ~15% edge cap) are owned by `design/gdd/characters-perks.md`. The Shop only prices and sells the edge perks.
12. Each character's **signature perk** is free and always on (Characters & Perks rule 5); it is not in the shop. The three edge perks are priced by tier (F1) and unlock by tier **and** character:
    - tier 1: shop open;
    - tier 2: `any_of [biome_open: 2, tournaments_played: 5]`;
    - tier 3: `any_of [biome_open: 4, tournaments_played: 15]`;
    - a friend's perks additionally need `any_of [character: <friend>, tournaments_played: 1]`, because all four characters are playable in multiplayer from the start.
    The tournament paths keep a party-only profile from being locked out.
13. A perk is bought **once** and owned forever by that profile. There are no perk upgrade levels and no duplicate copies, so the shop cannot raise any perk's strength. Equipping and swapping perks is free.

**Potions**
14. A potion is a one-use carrier for a **buff** effect from Buffs & Debuffs (never a debuff). The launch potions are listed in F2. A potion-only effect (for example "extra warning") must first be added to Buffs & Debuffs as an effect.
15. A profile carries at most `potion_stack_max` (default 5) of each potion. The buy button is disabled at the cap.
16. **Bringing a potion**: on the Level Intro (campaign, Arcade) or the round pick (tournaments), the player may pick up to `potions_per_level` (default 1) potion. It sits in a dedicated **potion slot** next to the item slots, so it never blocks an item pickup and works even when `items_enabled` is off (the campaign default, Items rule 12).
17. **Using**: tapping the potion slot applies the effect, with the same timing rules as an item (Items rule 7: usable while Playing, queued during Resolving). The potion is **consumed on use only**. An unused potion goes back to the inventory when the level or round ends, whether it was won, lost or quit. If the effect has **no effect** (Buffs & Debuffs rule 5), the potion is **not** consumed and stays in the slot.
18. **Stars**: a potion run can earn **all three stars**, including ★★★ (user decision; `potion_blocks_star3 = false`). Star times are balanced for no perks and no potions, so a potion is help over a hard spot, in line with relaxed timing earning all 3 stars without a badge. The knob exists in case playtests show ★★★ is being bought; the new stars pay the jar as usual (Star Economy rule 8), and F5 keeps that from being a profit.
19. **Modes**:
    - campaign and Arcade: allowed (rule 16);
    - tournaments: allowed when the host's `potions_allowed` setting is on (default on); at most 1 per round and `potions_per_tournament` (default 2) per tournament; off in sudden death (Characters & Perks rule 8);
    - quick versus: **off**, following the sidegrade-only rule for that mode.
20. Potions are spent from the inventory when used (ADR-0013 `inventory.potions`). The count is written with the level or round result (ADR-0013 §3: no saves in play). If the app is killed mid-level, the use is not saved and the potion is kept.

**Cosmetics**
21. Cosmetics change looks only: board skin, piece sticker set, character outfit, frame trim. They never change rules, timing or readability. Every cosmetic must pass the art bible's readability rules (piece hues, colour-blind shape codes), checked by art review.
22. Launch catalog (F3): **4 per main biome** (2 small, 1 fancy, 1 grand), unlocked by `biome_open: b`, plus **4 party cosmetics** unlocked by `tournaments_played: 1`. Side islands have no shop set at launch. Owned cosmetics go into ADR-0013 §4 `cosmetics: { id: { "owned": true } }`.
23. Cosmetics given for free elsewhere (a Mastered biome, the mascot wish SE07 in the mechanics module) are **not** sold in the shop.

**Skills**
24. Skills are not sold. Each character's one skill comes with the character (`design/gdd/skills.md`). If skills.md defines **consumable** skills, their refills would be sold here under the potion rules (15–20). See Open Questions.

**Monetization seam (none now)**
25. Monetization is undecided, so nothing in the shop needs it. The seam is:
    - `price.currency` is an enum whose only valid value in this build is `stars`; the catalog validator rejects anything else;
    - the shop reads prices through a `PriceSource` and completes purchases through a `PurchaseProvider`; this build ships only the Star Jar provider;
    - any future real-money record goes into its own save `kind` (ADR-0013 §5), never into `progress.json`.
    There are no ad or store SDKs in this build. Whether to monetize, and how, is a creative-director decision; the game concept lists a "pay-to-win shop" as something that would turn players away.

### States and Transitions

Per catalog entry and profile: **Locked → For sale → Owned** (perks, cosmetics; one-way except the undo of rule 7) or **For sale ⇄ At cap** (potions, by count). Per potion in a level: **Carried → In slot → Used** (consumed) or **→ Returned** (unused, or no effect).

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Star Economy (`points-system.md`) | ↔ | Jar balance; debit (`spent_total`); "need N more" hints from unearned stars |
| Characters & Perks (`characters-perks.md`) | ↔ | Edge-perk list, tiers, character joins; owned perks back |
| Skills (`skills.md`) | → Shop | Whether any skill is consumable (refills) |
| Buffs & Debuffs | Shop → | Potion effects applied to self |
| Items | ↔ | Potion slot uses item timing; independent of item slots |
| Level Goals / Level Intro, Tournament Flow | ↔ | Potion pick before a level or round; host `potions_allowed` |
| Campaign Structure | → Shop | Biome open (unlocks; earned stars only) |
| Save & Profile (ADR-0013) | ↔ | `inventory.perks`, `inventory.potions`, `cosmetics`, `tournament.played` |
| Menus & Level Select, ADR-0016 | ↔ | Shop screen, main-menu entry |
| Art bible, Game Feel & VFX | → Shop | Cosmetic looks, readability checks |

## Formulas

### F1. Perk price

The perk_price formula is defined as:

`price(perk) = perk_tier_price[tier(perk)]`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| tier | int | 1–3 | Characters & Perks data | Edge-perk tier (signatures are free and not sold) |
| perk_tier_price[1..3] | int | 0–100 | data file | Defaults 10 / 20 / 35 stars |

**Output Range:** 10–35 stars. **Example:** one character's three edge perks cost 10 + 20 + 35 = **65**; all 4 characters × 3 = **260**.

### F2. Potion price and stock

The potion_price table is defined as:

| Potion id | Effect (Buffs & Debuffs) | Price (stars) | Unlock (`requires`) |
|---|---|---|---|
| `potion_helper_drop` | Helper Drop | 2 | shop open |
| `potion_slow_time` | Slow Time | 2 | shop open |
| `potion_preview_peek` | Preview Peek | 3 | `biome_open: 2` or `tournaments_played: 5` |
| `potion_bomb` | Bomb | 4 | `biome_open: 3` or `tournaments_played: 10` |

`carry(potion) ≤ potion_stack_max`; full stock of all four = `5 × (2 + 2 + 3 + 4)` = **55**.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| price | int | 2–10 | data file | Per potion; must stay above `replay_pay` (F5) |
| potion_stack_max | int | 1–20 | data file | Default 5 |
| potions_per_level | int | 0–2 | data file | Default 1 |
| potions_per_tournament | int | 0–13 | data file | Default 2 |

**Output Range:** 2–4 stars. **Rationale:** a potion costs 2–4 earned stars (≈ 8–16 min of typical play at ≈ 15 stars/h), and the ★★★ it may help win drops only 1 star into the jar, so a potion always costs more than the star it helps earn (F5).

### F3. Cosmetic price

The cosmetic_price formula is defined as:

`price(c) = cosmetic_grade_price[grade(c)]`, grades `small` / `fancy` / `grand`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| cosmetic_grade_price | int | 2–100 | data file | Defaults 5 / 10 / 15 stars |
| per-biome set | — | — | catalog | 2 small + 1 fancy + 1 grand = **35** |

**Output Range:** 5–15 stars. **Example:** 10 biome sets + 1 party set = 11 × 35 = **385**.

### F4. Finite sink capacity

The sink_capacity formula is defined as:

`S_finite = Σ_perks price + Σ_cosmetics price`

**Example (defaults):** 260 + 385 = **645**. Star Economy F7 compares it with lifetime jar income: typical player ≈ 290 (spends everything, keeps choosing), completionist ≈ 610 (hard maximum 656: 492 campaign stars + 164 replay stars), so 100% completion and the full catalog arrive together, with tournament income covering the gap and potions. Potions are the only unlimited sink.

### F5. No-profit-loop check

The loop_check inequality is defined as:

`min(potion price) > replay_pay` and each earned star pays the jar once (Star Economy rule 6)

**Variables:** `replay_pay` = 1, at most once per level (Star Economy F2); `min(potion price)` = 2.

**Output:** 2 > 1 → **holds**. A potion used on a replay costs more than the replay can pay, and the star a potion helps win (★★★ allowed) pays 1 once. In tournaments a potion can help win a larger award (up to 11 stars), but a win is never guaranteed, rivals can bring potions too, the cap is 2 per tournament and F5 of the Star Economy decays repeats, so there is no repeatable buy-potion → earn-stars loop. Any tuning change must keep this inequality.

### F6. Time to afford (typical player)

Uses Star Economy F6 at the typical rate of ≈ 15 stars/h (flat across biomes; a session is ≈ 20 minutes ≈ 5 stars):

| Item | Price | When it becomes available | Time to afford from 0 | Sessions |
|---|---|---|---|---|
| Helper Drop / Slow Time potion | 2 | shop open (meadow_03) | ≈ 8 min | < 1 |
| Preview Peek potion | 3 | biome 2 | ≈ 12 min | < 1 |
| Bomb potion | 4 | biome 3 | ≈ 16 min | < 1 |
| Tier-1 perk | 10 | shop open | ≈ 40 min | 2 |
| Tier-2 perk | 20 | biome 2 | ≈ 80 min | 4 |
| Tier-3 perk | 35 | biome 4 | ≈ 2.3 h | 7 |
| Small / fancy / grand cosmetic | 5 / 10 / 15 | its biome | 20 / 40 / 60 min | 1 / 2 / 3 |

**Result:** a purchase roughly every 40–90 min of play, with potions as small top-ups between them. The tier-3 perk is the longest save-up (≈ 2.3 h), which is intended: it is the strongest edge. A friend's perks go on sale when they join (Ice = biome 3, Lava = 5, Cave = 7), spreading the perk spending across the campaign.

## Edge Cases

- **If a purchase write fails** (disk full, validation failure, ADR-0013 §3): the purchase is rolled back in memory and an error card is shown. The jar and inventory stay as they were.
- **If the player double-taps confirm**: the second tap is ignored while the write is pending (one purchase per confirm card).
- **If a purchase empties the jar**: earned stars, gates and bonus levels are unchanged (Star Economy rule 1); the map still shows every star.
- **If an item's price changes in a patch**: owned items stay owned; nothing is refunded or charged; the new price applies to future purchases only.
- **If a catalog entry is removed in a patch**: owned copies stay in the save (ADR-0013 keeps unknown keys) and keep working if the effect still exists. If the effect no longer exists, the owned potions show as "retired" and are refunded to the jar at their last price (the only refund case).
- **If a potion's effect is changed in a patch**: owned potions use the new effect.
- **If the potion slot is used during Resolving**: queued to the end of the Resolving (Items rule 7).
- **If a potion is used and the level is then lost or quit**: the potion is consumed (it was used).
- **If the level is quit before the potion is used**: the potion goes back to the inventory.
- **If the potion has no effect** (for example Slow Time on a level whose mechanic sets gravity): it stays in the slot and is not consumed.
- **If a potion helps beat the ★★★ time**: ★★★ is earned and pays the jar 1 star (rule 18).
- **If the host turns `potions_allowed` off between rounds**: from the next round no potion can be picked; potions in slots go back unused.
- **If a player tries to undo after equipping the perk in a level, or after using the potion**: undo is unavailable (rule 7).
- **If a profile is deleted**: its purchases and jar go with it (ADR-0013 §6 delete).
- **If a friend has not joined yet and no tournament was played**: their edge perks show as locked silhouettes with the friend's portrait as the condition (rule 12).
- **If all potions are at cap and the catalog is owned**: the shop shows "Everything collected!"; the jar keeps filling from tournaments (Star Economy F7 accepts this).
- **If the save is read-only** (newer schema, ADR-0013 §2): buying is disabled with a short notice.
- **If a guest opens the shop**: the shop is hidden for guests (no jar).

## Dependencies

**Upstream:** Star Economy (Hard: jar and debit), Characters & Perks (Hard: edge-perk list, tiers, character joins), Buffs & Debuffs (Hard: potion effects), Save & Profile / ADR-0013 (Hard: inventory maps, atomic write), Items (Soft: timing rules reused by the potion slot), Campaign Structure (Soft: biome open), Tournament Flow (Soft: `tournament.played`, host setting), Skills (Soft: consumable refills only), narrative story bible (Soft: where each friend joins).

**Downstream:** Menus & Level Select and ADR-0016 (Hard: shop screen, main-menu entry), Level Goals / Level Intro and Tournament Flow (Soft: potion pick), HUD (Soft: potion slot), Game Feel & VFX, Audio (Soft).

Bidirectional notes: Buffs & Debuffs, Items, Piece Set, Piece Spawner and Save & Profile already list the Shop. **HUD, Level Goals (Level Intro), Tournament Flow (host setting `potions_allowed`, potion pick at round pick) and `characters-perks.md` (rule 6 "Shop / Points" → "Shop / Star Economy"; rule 2 joins by story) need to add or update the Shop** (not edited by this GDD).

## Tuning Knobs

All in `assets/data/shop/catalog.json` / `assets/data/economy/stars.json` (proposed paths).

| Knob | Range | Default | Affects |
|---|---|---|---|
| shop_unlock_level | any level id | meadow_03 | When the shop first opens |
| perk_tier_price[1..3] | 0–100 | 10 / 20 / 35 | Perk pacing (F1, F6) |
| perk tier unlock gates | biome / tournaments | 2 or 5; 4 or 15 | When stronger edges appear |
| friend perk gate | story / tournaments | join or 1 tournament | When a friend's perks go on sale |
| potion prices | 2–10 | 2 / 2 / 3 / 4 | Potion sink size; must keep F5 true |
| potion_stack_max | 1–20 | 5 | Potion hoarding limit |
| potions_per_level / potions_per_tournament | 0–2 / 0–13 | 1 / 2 | How much a potion can swing a level or a tournament |
| potions_allowed (host) | on/off | on | Potions in tournaments |
| potion_blocks_star3 | true/false | false | Whether potion runs can earn ★★★ (user: yes) |
| cosmetic_grade_price | 2–100 | 5 / 10 / 15 | Long-tail sink (F3) |
| cosmetics per biome | 0–8 | 4 | Catalog size (F4) |

**Safe-range notes:** keep F4's `S_finite` within ±10% of the completionist jar income (Star Economy F7, ≈ 610), so the catalog neither runs out long before 100% nor is out of reach at it (645 is +6%). Keep every perk tier at or below about 2.5 h of saving at ≈ 15 stars/h (≤ 37 stars). Prices are small integers, so tune in whole stars; a one-star change on a potion is a 25–50% change.

## Visual/Audio Requirements

- A painted-wood toy-shop shelf in the current biome's frame set (decision sheet: painted wood frames per biome; art bible §7). Three shelves or tabs: Perks (by character), Potions, Looks. The Star Jar sits on the counter showing the balance.
- Each item shows its price as a large number plus the jar-star icon (distinct from the gold earned-star stamp). Locked items are soft silhouettes with the unlock condition as an icon ("biome 4 island", "5 tournaments", a friend's portrait).
- Buying: stars hop out of the jar into the paper bag and the item hops in; the jar counter ticks down. Undo: the item hops back out and the stars return to the jar.
- Potions in play: a corked bottle in the potion slot with the effect's cyan buff badge (Buffs & Debuffs); a pop and fizz on use.
- Audio events: `shop_buy`, `shop_undo`, `shop_cant_afford` (soft, never a buzzer), `potion_use`.

## Game Feel

Browsing should feel like a toy shop, not a store page: calm, readable and never pushy. Targets (playtest): testers can say what each item does and what it costs without help; no tester feels they "had to" buy something to finish a main-path level; no tester thinks buying lowered their level stars; at least half of the testers who finished biome 2 have bought a perk.

## UI Requirements

Shop screen (three tabs, Star Jar counter, confirm card with "jar after", undo toast), potion pick on Level Intro and round pick, potion slot in the HUD. Fully usable with touch, keyboard/mouse and gamepad (ADR-0012), buttons ≥ 56 dp (decision sheet). 📌 **UX Flag — Shop**: the shop screen is on the extra-UI list (world/story/UI round). Include it, the Level Intro potion pick and the HUD potion slot in `/ux-design`.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/points-system.md` (Star Economy) Core Rules 1–4, 6, 8, 17; F2, F6, F7 | Two star numbers, jar, debit, replay cap, earn rate, sink/faucet model |
| `design/gdd/characters-perks.md` Core Rules 1, 2, 5–8 | Signature and edge perks, character availability, edge cap, perk modes |
| `design/gdd/skills.md` | Skill use rules (consumable refills) |
| `design/gdd/buffs-debuffs.md` Core Rules 1–5; starter effects | Potion effects, no-effect rule |
| `design/gdd/items.md` Core Rules 4, 7, 12 | Item slots, use timing, items off in the campaign |
| `design/gdd/campaign-structure.md` F1 | Biome open (unlocks) |
| `design/gdd/tournament-flow.md` Core Rules 1, 2 | Host setup, round pick |
| `docs/architecture/adr-0013-save-profile-settings.md` §3, §4, §5, §6 | Atomic write, cosmetics map, inventory maps, monetization seam, profile delete |
| `design/gdd/mechanics-module.md` SE07 | Free cosmetic from the mascot wish (not sold) |
| `production/session-state/decisions.md` (/team-narrative round) | Stars only; potions allow ★★★; characters by story |
| `design/gdd/game-concept.md` | Shop supports play; "pay-to-win shop" as a turn-off |

## Acceptance Criteria

1. [U] **GIVEN** a jar of 12 and a 10-star tier-1 perk, **WHEN** bought, **THEN** jar 2, `spent_total +10`, the perk is owned, all in one write, and every earned-star total is unchanged.
2. [U] **GIVEN** a jar of 7, **THEN** the 10-star perk's button reads "Need 3 more" and buying is refused.
3. [U] **GIVEN** a fault injected into the purchase write, **THEN** jar and inventory are unchanged after reload.
4. [U] **GIVEN** a purchase and an undo on the same shop visit, **THEN** jar and inventory equal the pre-purchase state; after leaving the shop, undo is unavailable.
5. [U] **GIVEN** 5 Slow Time potions, **THEN** buying another is disabled.
6. [U] **GIVEN** a tier-2 perk, **THEN** it is locked until biome 2 is open **or** 5 tournaments were played, and for sale after either.
7. [U] **GIVEN** Lana has not joined and no tournament was played, **THEN** her edge perks are locked; after either, tier-1 is for sale.
8. [U] **GIVEN** a potion brought into a level and not used, **THEN** after a win, loss or quit the count is unchanged.
9. [U] **GIVEN** a potion whose effect returns "no effect", **THEN** it is not consumed.
10. [U] **GIVEN** a tournament with `potions_per_tournament = 2`, **THEN** a third potion cannot be picked; with `potions_allowed` off, none can.
11. [U] **GIVEN** quick versus, **THEN** no potion pick is offered.
12. [U] **GIVEN** a catalog entry with `currency` other than `stars`, or any entry of kind `character`, **THEN** the catalog fails validation.
13. [U] F4: the default catalog sums to 645; F5 holds for the default knobs (min potion 2 > `replay_pay` 1).
14. [U] **GIVEN** `potion_blocks_star3 = false` and a potion used in a run beating `t3` with no warning, **THEN** ★★★ and jar +1 (if the level was at ★★).
15. [I] **GIVEN** the shop screen on touch, keyboard/mouse and gamepad, **THEN** every item can be browsed, bought and undone with each input (screenshot evidence in `production/qa/evidence/`).
16. [M] **GIVEN** a playtest through biome 2, **THEN** no tester feels a purchase was required to finish a main-path level, no tester thinks buying lowered their stars, and median time between purchases is 40–100 min.

## Open Questions

- **Consumable skills**: if `skills.md` gives any skill a consumable use rule, should its refills be sold here (potion rules, priced like potions)?
- **Potions in quick versus**: default off (sidegrade-only spirit). Confirm.
- **Side-island cosmetics**: none at launch; adding a 35-star set per island (+140) would push `S_finite` to 785, above the completionist income. Only with a matching faucet change.
- **Potion-only effects** (extra warning, shield): need Buffs & Debuffs entries first.
- **Monetization**: undecided; seam only (rule 25). Any decision goes to the creative director.
