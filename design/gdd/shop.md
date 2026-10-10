# Shop

> **Status**: In Design
> **Author**: Tessa + agents (economy-designer)
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; Comeback Energy; Readable Chaos

## Summary

The Shop is where points are spent. It sells three things, for points only: **perks** (bought once, kept forever, equipped per character), **potions** (one-use buffs you bring into a level or a tournament round) and **cosmetics** (looks only). Every price is fixed and visible. There are no random boxes, no rotating stock and no timed offers. Monetization is undecided, so the shop is designed for none, and the price data carries a currency field as the only seam.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Points System, Characters & Perks, Buffs & Debuffs, Save & Profile (ADR-0013)`

## Overview

The Shop turns the points earned from stars and wins (`design/gdd/points-system.md`) into choices that change how the next level plays or looks. **Perks** come from each character's perk set (`design/gdd/characters-perks.md`). Each character's starter perk is free, and the others cost 200, 400 or 700 points by tier. Higher tiers open as the player reaches later biomes or plays tournaments, so edges arrive at the pace of the campaign. Each perk is sold once and has no upgrade levels, so the shop can never push a loadout past the ~15% edge cap that Characters & Perks enforces. **Potions** carry one of the four buff effects from Buffs & Debuffs (Helper Drop, Slow Time, Preview Peek, Bomb). They cost 30–60 points, the player carries up to 5 of each, and one is brought into a level (campaign or Arcade) or a tournament round. A potion is used up only when it is actually used. **Cosmetics** (board skins, sticker sets, outfits, frame trims) appear four per biome as biomes open, plus four party cosmetics. Together, perks and cosmetics are a finite catalog of 15 650 points sized to match a completionist's lifetime earnings, while potions are the one repeatable sink (sink/faucet model: Points System F7). Each of the 4 profiles has its own wallet and its own purchases. This serves *Variation Over Depth* (perks and potions change the play), *Comeback Energy* (a potion can carry a stuck player past a hard level) and *Readable Chaos* (fixed prices, a short catalog, nothing hidden). All values are starting defaults.

## Player Fantasy

A cosy toy shop on a shelf (Menus' toy-shop mood): you can see everything, you know what it costs, and you save up for the thing you want. Buying feels like a small celebration, never a gamble. A child who taps the wrong thing can undo it.

## Detailed Design

### Core Rules

**The shop screen**
1. The Shop is a menu screen reached from the main menu (Menus & Level Select "Shop later"; screens owned by ADR-0016). It opens once the profile has finished `shop_unlock_level` (default `meadow_03`) **or** played one tournament, so the first visit already offers something affordable (≈ 75 points in hand, Points System F2).
2. The catalog is data (`assets/data/shop/catalog.json`, proposed path, validated at load). Each entry has: `id` (stable StringName), `kind` (`perk` / `potion` / `cosmetic`), `price` `{ "currency": "points", "amount": int }`, `requires` (unlock conditions, rule 9), and display keys (translation keys only).
3. **Every price is fixed and always shown.** The shop has no random rewards, no rotating or limited stock, no discounts tied to time and no "only today" offers. Nothing in the shop reads wall time (ADR-0013 §5).
4. **Buying**: tap an item, then a confirm card shows the item, its price and "balance after". Confirming debits `wallet.points` and `wallet.spent_total` (Points System rule 18) and grants the item in the **same** `progress.json` write (ADR-0013 §3), so a crash can never take points without giving the item, or the reverse.
5. Purchases happen only in menus, never while a `PlaySession` exists (ADR-0013 §3 "no saves in play").
6. **Not enough points**: the buy button shows "Need N more" and a hint naming the nearest unearned stars ("★★★ on meadow_07 pays +25"), pointing the player at play, not grind (goal gradient).
7. **Undo**: the most recent purchase can be undone with one tap while the player is still on the shop screen, provided the item is unused (a potion still at full count, a perk not yet equipped in a level, any cosmetic). Leaving the shop ends the undo window. This is for young players' mis-taps; it is not a refund system.
8. Owned items are never taken away: no expiry, no durability, no clawback after a rebalance or price change.

**Unlock conditions (`requires`)**
9. An entry is shown **locked** (silhouette plus condition) until its `requires` holds, then **for sale**:
   - `biome_open: b`: biome `b` is open (Campaign Structure F1);
   - `tournaments_played: n`: the profile's `tournament.played ≥ n` (ADR-0013 §4);
   - `character: id`: the character is available to the profile (Characters & Perks);
   - conditions in a list are AND; a `any_of` list is OR.

**Perks**
10. The perks themselves (effects, edge vs sidegrade, loadout size, the ~15% edge cap) are owned by `design/gdd/characters-perks.md`. The Shop only prices and sells them.
11. Each character's **starter perk** is free and owned as soon as the character is available. The other perks are priced by tier (F1) and unlock by tier:
    - tier 1: when the shop opens;
    - tier 2: `any_of [biome_open: 2, tournaments_played: 5]`;
    - tier 3: `any_of [biome_open: 4, tournaments_played: 15]`.
    The tournament path keeps a party-only profile from being locked out of tiers 2–3.
12. A perk is bought **once** and owned forever by that profile. There are no perk upgrade levels and no duplicate copies, so the shop cannot raise any perk's strength. Equipping and swapping perks is free (Characters & Perks).
13. Sidegrade perks (the only perks in quick versus, decision sheet) cost the same as edge perks of the same tier: they are choices, not cheaper versions.

**Potions**
14. A potion is a one-use carrier for a **buff** effect from Buffs & Debuffs (never a debuff). The launch potions are listed in F2. A potion-only effect (for example "extra warning") must first be added to Buffs & Debuffs as an effect.
15. A profile carries at most `potion_stack_max` (default 5) of each potion. The buy button is disabled at the cap.
16. **Bringing a potion**: on the Level Intro (campaign, Arcade) or the round pick (tournaments), the player may pick up to `potions_per_level` (default 1) potion. It sits in a dedicated **potion slot** next to the item slots, so it never blocks an item pickup and works even when `items_enabled` is off (the campaign default, Items rule 12).
17. **Using**: tapping the potion slot applies the effect, with the same timing rules as an item (Items rule 7: usable while Playing, queued during Resolving). The potion is **consumed on use only**. An unused potion goes back to the inventory when the level or round ends, whether it was won, lost or quit. If the effect has **no effect** (Buffs & Debuffs rule 5), the potion is **not** consumed and stays in the slot.
18. **Stars**: potions do not block any star by default (`potion_blocks_star3 = false`). Star times are balanced for no perks and no potions (decision sheet), so a potion is help over a hard spot, in line with relaxed timing earning all 3 stars without a badge. The knob exists in case playtests show ★★★ is being bought.
19. **Modes**:
    - campaign and Arcade: allowed (rule 16);
    - tournaments: allowed when the host's `potions_allowed` setting is on (default on); at most 1 per round and `potions_per_tournament` (default 2) per tournament, so a well-stocked player can't potion every round;
    - quick versus: **off**, following the sidegrade-only rule for that mode.
20. Potions are spent from the inventory when used (ADR-0013 `inventory.potions`). The count is written with the level or round result (ADR-0013 §3: no saves in play). If the app is killed mid-level, the use is not saved and the potion is kept.

**Cosmetics**
21. Cosmetics change looks only: board skin, piece sticker set, character outfit, frame trim. They never change rules, timing or readability. Every cosmetic must pass the art bible's readability rules (piece hues, colour-blind shape codes), checked by art review.
22. Launch catalog (F3): **4 per biome** (2 small, 1 fancy, 1 grand), unlocked by `biome_open: b`, plus **4 party cosmetics** unlocked by `tournaments_played: 1`. Owned cosmetics go into ADR-0013 §4 `cosmetics: { id: { "owned": true } }`.
23. Cosmetics given for free elsewhere (a Mastered biome, the mascot wish SE07 in the mechanics module) are **not** sold in the shop.

**Skills**
24. Skills are not sold. Each character's one skill comes with the character (`design/gdd/skills.md`). If skills.md defines **consumable** skills, their refills would be sold here under the potion rules (15–20). See Open Questions.

**Monetization seam (none now)**
25. Monetization is undecided, so nothing in the shop needs it. The seam is:
    - `price.currency` is an enum whose only valid value in this build is `points`; the catalog validator rejects anything else;
    - the shop reads prices through a `PriceSource` and completes purchases through a `PurchaseProvider`; this build ships only the points provider;
    - any future real-money record goes into its own save `kind` (ADR-0013 §5), never into `progress.json`.
    There are no ad or store SDKs in this build. Whether to monetize, and how, is a creative-director decision; the game concept lists a "pay-to-win shop" as something that would turn players away.

### States and Transitions

Per catalog entry and profile: **Locked → For sale → Owned** (perks, cosmetics; one-way except the undo of rule 7) or **For sale ⇄ At cap** (potions, by count). Per potion in a level: **Carried → In slot → Used** (consumed) or **→ Returned** (unused, or no effect).

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Points System | ↔ | Balance; debit (`spent_total`); "need N more" hints from unearned stars |
| Characters & Perks (`characters-perks.md`) | ↔ | Perk list, tiers, starter perks, character availability; owned perks back |
| Skills (`skills.md`) | → Shop | Whether any skill is consumable (refills) |
| Buffs & Debuffs | Shop → | Potion effects applied to self |
| Items | ↔ | Potion slot uses item timing; independent of item slots |
| Level Goals / Level Intro, Tournament Flow | ↔ | Potion pick before a level or round; host `potions_allowed` |
| Campaign Structure | → Shop | Biome open (unlocks) |
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
| tier | int | 0–3 | Characters & Perks data | 0 = starter (free) |
| perk_tier_price[0..3] | int | 0–2 000 | data file | Defaults 0 / 200 / 400 / 700 |

**Output Range:** 0–700 at defaults. **Example:** one character's full set (starter + tiers 1–3) costs 0 + 200 + 400 + 700 = **1 300**. With the default assumption of 4 characters × 3 buyable perks, all perks cost **5 200**. If `characters-perks.md` lands with a different count, F4 is recomputed from the real list.

### F2. Potion price and stock

The potion_price table is defined as:

| Potion id | Effect (Buffs & Debuffs) | Price | Unlock (`requires`) |
|---|---|---|---|
| `potion_helper_drop` | Helper Drop | 30 | shop open |
| `potion_slow_time` | Slow Time | 40 | shop open |
| `potion_preview_peek` | Preview Peek | 40 | `biome_open: 2` or `tournaments_played: 5` |
| `potion_bomb` | Bomb | 60 | `biome_open: 3` or `tournaments_played: 10` |

`carry(potion) ≤ potion_stack_max`; full stock of all four = `5 × (30 + 40 + 40 + 60)` = **850**.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| price | int | 10–200 | data file | Per potion |
| potion_stack_max | int | 1–20 | data file | Default 5 |
| potions_per_level | int | 0–2 | data file | Default 1 |
| potions_per_tournament | int | 0–13 | data file | Default 2 |

**Output Range:** 30–60 per potion. **Rationale:** a potion costs about one ★★★ (25–59 points by biome), so using one to win a hard level's last star is roughly break-even, never a loop (F5).

### F3. Cosmetic price

The cosmetic_price formula is defined as:

`price(c) = cosmetic_grade_price[grade(c)]`, grades `small` / `fancy` / `grand`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| cosmetic_grade_price | int | 50–2 000 | data file | Defaults 100 / 250 / 500 |
| per-biome set | — | — | catalog | 2 small + 1 fancy + 1 grand = **950** |

**Output Range:** 100–500. **Example:** 10 biome sets + 1 party set = 11 × 950 = **10 450**.

### F4. Finite sink capacity

The sink_capacity formula is defined as:

`S_finite = Σ_perks price + Σ_cosmetics price`

**Example (defaults):** 5 200 + 10 450 = **15 650**. Points System F7 compares it with lifetime faucets: typical player ≈ 6 100 (spends everything, keeps choosing), completionist ≈ 15 930 (owns the full catalog at 100% completion, about 280 left for potions). Potions are the only unlimited sink.

### F5. No-profit-loop check

The loop_check inequality is defined as:

`min(potion price) > max replay award` and star points are paid once per tier (Points System rule 5)

**Variables:** `max replay award = replay_base × 3 × bm(10)` = 2 × 3 × 2.35 ≈ 14 (Points System F3); `min(potion price)` = 30.

**Output:** 30 > 14 → **holds**. Using a potion on a replay always costs more than it can earn, and the star points it helps win can only be won once. No buy-potion → earn-points loop exists. Any tuning change must keep this inequality.

### F6. Time to afford (typical player)

Uses Points System F6 with the typical-player rates from Points System F7 (217 points/h in biome 1, rising to 511/h in biome 10; a session is assumed to be about 20 minutes):

| Item | Price | When it becomes available | Earn rate then | Time to afford from 0 | Sessions |
|---|---|---|---|---|---|
| Helper Drop potion | 30 | shop open (meadow_03) | 217/h | ≈ 8 min | < 1 |
| Slow Time potion | 40 | shop open | 217/h | ≈ 11 min | < 1 |
| Tier-1 perk | 200 | shop open | 217/h | ≈ 55 min | ≈ 3 |
| Tier-2 perk | 400 | biome 2 | 251/h | ≈ 1.6 h | ≈ 5 |
| Bomb potion | 60 | biome 3 | 286/h | ≈ 13 min | < 1 |
| Tier-3 perk | 700 | biome 4 | 319/h | ≈ 2.2 h | ≈ 7 |
| Small / fancy / grand cosmetic | 100 / 250 / 500 | its biome | 347/h (biome 5) | 17 min / 43 min / 1.4 h | 1 / 2 / 4 |

**Result:** a purchase roughly every 1–1.5 h of play, with potions as small top-ups between them. The tier-3 perk is the longest save-up (≈ 2 h), which is intended: it is the strongest edge.

## Edge Cases

- **If a purchase write fails** (disk full, validation failure, ADR-0013 §3): the purchase is rolled back in memory and an error card is shown. Points and inventory stay as they were.
- **If the player double-taps confirm**: the second tap is ignored while the write is pending (one purchase per confirm card).
- **If an item's price changes in a patch**: owned items stay owned; nothing is refunded or charged; the new price applies to future purchases only.
- **If a catalog entry is removed in a patch**: owned copies stay in the save (ADR-0013 keeps unknown keys) and keep working if the effect still exists. If the effect no longer exists, the owned potions show as "retired" and are refunded at their last price (the only refund case).
- **If a potion's effect is changed in a patch**: owned potions use the new effect.
- **If the potion slot is used during Resolving**: queued to the end of the Resolving (Items rule 7).
- **If a potion is used and the level is then lost or quit**: the potion is consumed (it was used).
- **If the level is quit before the potion is used**: the potion goes back to the inventory.
- **If the potion has no effect** (for example Slow Time on a level whose mechanic sets gravity): it stays in the slot and is not consumed.
- **If the host turns `potions_allowed` off between rounds**: from the next round no potion can be picked; potions in slots go back unused.
- **If a player tries to undo after equipping the perk in a level, or after using the potion**: undo is unavailable (rule 7).
- **If a profile is deleted**: its purchases go with it (ADR-0013 §6 delete).
- **If a character is not yet available**: its perks show as locked silhouettes (rule 9); its starter perk is granted when it becomes available.
- **If all potions are at cap and the catalog is owned**: the shop shows "Everything collected!"; points keep accruing (Points System F7 accepts this).
- **If the save is read-only** (newer schema, ADR-0013 §2): buying is disabled with a short notice.
- **If a guest opens the shop**: the shop is hidden for guests (no wallet).

## Dependencies

**Upstream:** Points System (Hard: balance and debit), Characters & Perks (Hard: perk list, tiers, starter perks, character availability), Buffs & Debuffs (Hard: potion effects), Save & Profile / ADR-0013 (Hard: inventory maps, atomic write), Items (Soft: timing rules reused by the potion slot), Campaign Structure (Soft: biome open), Tournament Flow (Soft: `tournament.played`, host setting), Skills (Soft: consumable refills only).

**Downstream:** Menus & Level Select and ADR-0016 (Hard: shop screen, main-menu entry), Level Goals / Level Intro and Tournament Flow (Soft: potion pick), HUD (Soft: potion slot), Game Feel & VFX, Audio (Soft).

Bidirectional notes: Buffs & Debuffs, Items, Piece Set, Piece Spawner and Save & Profile already list the Shop. **HUD, Level Goals (Level Intro), Tournament Flow (host setting `potions_allowed`, potion pick at round pick) and `characters-perks.md` need to add the Shop** (not edited by this GDD).

## Tuning Knobs

All in `assets/data/shop/catalog.json` / `assets/data/economy/points.json` (proposed paths).

| Knob | Range | Default | Affects |
|---|---|---|---|
| shop_unlock_level | any level id | meadow_03 | When the shop first opens |
| perk_tier_price[0..3] | 0–2 000 | 0 / 200 / 400 / 700 | Perk pacing (F1, F6) |
| perk tier unlock gates | biome / tournaments | 2 or 5; 4 or 15 | When stronger edges appear |
| potion prices | 10–200 | 30 / 40 / 40 / 60 | Potion sink size; must keep F5 true |
| potion_stack_max | 1–20 | 5 | Potion hoarding limit |
| potions_per_level / potions_per_tournament | 0–2 / 0–13 | 1 / 2 | How much a potion can swing a level or a tournament |
| potions_allowed (host) | on/off | on | Potions in tournaments |
| potion_blocks_star3 | true/false | false | Whether potion runs can earn ★★★ |
| cosmetic_grade_price | 50–2 000 | 100 / 250 / 500 | Long-tail sink (F3) |
| cosmetics per biome | 0–8 | 4 | Catalog size (F4) |

**Safe-range notes:** keep F4's `S_finite` within ±10% of the completionist faucet (Points System F7), so the catalog neither runs out long before 100% nor is out of reach at it. Keep every perk tier at or below about 2.5 h of saving at its unlock biome's rate (F6).

## Visual/Audio Requirements

- A painted-wood toy-shop shelf in the current biome's frame set (decision sheet: painted wood frames per biome; art bible §7). Three shelves or tabs: Perks (by character), Potions, Looks.
- Each item shows its price as a large number plus the currency icon. Locked items are soft silhouettes with the unlock condition as an icon ("biome 4 island", "5 tournaments").
- Buying: the item hops into a paper bag with a coin-drop sound; the wallet counter ticks down. Undo: the item hops back out.
- Potions in play: a corked bottle in the potion slot with the effect's cyan buff badge (Buffs & Debuffs); a pop and fizz on use.
- Audio events: `shop_buy`, `shop_undo`, `shop_cant_afford` (soft, never a buzzer), `potion_use`.

## Game Feel

Browsing should feel like a toy shop, not a store page: calm, readable and never pushy. Targets (playtest): testers can say what each item does and what it costs without help; no tester feels they "had to" buy something to finish a main-path level; at least half of the testers who finished biome 2 have bought a perk.

## UI Requirements

Shop screen (three tabs, confirm card, undo toast), potion pick on Level Intro and round pick, potion slot in the HUD. Fully usable with touch, keyboard/mouse and gamepad (ADR-0012), buttons ≥ 56 dp (decision sheet). 📌 **UX Flag — Shop**: the shop screen is on the extra-UI list (world/story/UI round). Include it, the Level Intro potion pick and the HUD potion slot in `/ux-design`.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/points-system.md` Core Rules 1–4, 18; F3, F6, F7 | Wallet, debit, replay cap, earn rates, sink/faucet model |
| `design/gdd/characters-perks.md` (in progress) | Perk list, tiers, starter perks, edge cap (~15%), loadouts |
| `design/gdd/skills.md` (in progress) | Skill use rules (consumable refills) |
| `design/gdd/buffs-debuffs.md` Core Rules 1–5; starter effects | Potion effects, no-effect rule |
| `design/gdd/items.md` Core Rules 4, 7, 12 | Item slots, use timing, items off in the campaign |
| `design/gdd/campaign-structure.md` F1 | Biome open (unlocks) |
| `design/gdd/tournament-flow.md` Core Rules 1, 2 | Host setup, round pick |
| `docs/architecture/adr-0013-save-profile-settings.md` §3, §4, §5, §6 | Atomic write, cosmetics map, inventory maps, monetization seam, profile delete |
| `design/gdd/mechanics-module.md` SE07 | Free cosmetic from the mascot wish (not sold) |
| `design/gdd/game-concept.md` | Shop supports play; "pay-to-win shop" as a turn-off |

## Acceptance Criteria

1. [U] **GIVEN** 250 points and a 200-point tier-1 perk, **WHEN** bought, **THEN** balance 50, `spent_total +200`, the perk is owned, all in one write.
2. [U] **GIVEN** 150 points, **THEN** the 200-point perk's button reads "Need 50 more" and buying is refused.
3. [U] **GIVEN** a fault injected into the purchase write, **THEN** balance and inventory are unchanged after reload.
4. [U] **GIVEN** a purchase and an undo on the same shop visit, **THEN** balance and inventory equal the pre-purchase state; after leaving the shop, undo is unavailable.
5. [U] **GIVEN** 5 Slow Time potions, **THEN** buying another is disabled.
6. [U] **GIVEN** a tier-2 perk, **THEN** it is locked until biome 2 is open **or** 5 tournaments were played, and for sale after either.
7. [U] **GIVEN** a potion brought into a level and not used, **THEN** after a win, loss or quit the count is unchanged.
8. [U] **GIVEN** a potion whose effect returns "no effect", **THEN** it is not consumed.
9. [U] **GIVEN** a tournament with `potions_per_tournament = 2`, **THEN** a third potion cannot be picked; with `potions_allowed` off, none can.
10. [U] **GIVEN** quick versus, **THEN** no potion pick is offered.
11. [U] **GIVEN** a catalog entry with `currency` other than `points`, **THEN** the catalog fails validation.
12. [U] F4: the default catalog sums to 15 650; F5 holds for the default knobs (min potion 30 > max replay award 14).
13. [U] **GIVEN** `potion_blocks_star3 = false` and a potion used in a run beating `t3` with no warning, **THEN** ★★★.
14. [I] **GIVEN** the shop screen on touch, keyboard/mouse and gamepad, **THEN** every item can be browsed, bought and undone with each input (screenshot evidence in `production/qa/evidence/`).
15. [M] **GIVEN** a playtest through biome 2, **THEN** no tester feels a purchase was required to finish a main-path level, and median time between purchases is 45–100 min.

## Open Questions

- **Consumable skills**: if `skills.md` gives any skill a consumable use rule, should its refills be sold here (potion rules, priced like potions)?
- **Character unlocks as a sink**: are the 4 launch characters all free from the start, or are some unlocked by story or bought? Buying one would add a large one-time sink (≈ 1 000). Owned by Characters & Perks; the default here assumes they are not sold.
- **Potions in quick versus**: default off (sidegrade-only spirit). Confirm.
- **`potion_blocks_star3`**: default false (kid-friendly, consistent with relaxed timing). If playtests show ★★★ being "bought", switch to true.
- **Potion-only effects** (extra warning, shield): need Buffs & Debuffs entries first.
- **Monetization**: undecided; seam only (rule 25). Any decision goes to the creative director.
