# Items

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Comeback Energy; The Block Is the Constant; Readable Chaos

## Summary

Items are earned by clearing: some pieces carry a glowing item cube, and clearing the layer that cube sits in puts a random item in one of your slots. Tap a slot to use it — buffs help you, debuffs hit the leader. In versus, players further behind draw stronger attack items. How many slots a player has depends on the mode, the level and their perks (2 by default).

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Buffs & Debuffs`

## Overview

Items are the Mario Kart layer on top of the block puzzle. They are earned through play, not menus: when a piece spawns, one of its cubes may carry an **item cube** (a mystery bubble). When that cube is removed by a layer clear, its owner **collects** an item: the item is rolled at that moment from the item table, weighted by the player's current **standing**, so a trailing player draws more attack items and the leader more modest buffs. The item goes into a free **item slot** (default 2; set by mode, level and perks, 1–3). Tapping a slot (Touch Controls' item strip) uses it: the item applies its effect from Buffs & Debuffs to the player or, for debuffs, to an automatically chosen opponent (the leader, or second place if you are leading). Items are on by default in versus and Arcade and off in the campaign unless a level turns them on (then only buffs drop). This serves *Comeback Energy* (standing-weighted rolls and leader-targeted debuffs), *The Block Is the Constant* (items come from clearing blocks) and *Readable Chaos* (a few clear slots, one-tap use, every effect badged). All values are starting defaults.

## Detailed Design

### Core Rules

**Item cubes**
1. When a piece spawns and `items_enabled` is on, it gets an item cube with probability `p_item` (default 0.12) from the items random stream (framework rule 13): one of its cubes (picked from the same stream) carries an `item` tag. Injected pieces (Helpers, junk) never carry item cubes.
2. The item cube stays tagged after locking. It is **collected** when Layer Clearing removes it (`on_clear`), by the cube's owner. Cubes removed by a Bomb, a rescue wipe or the conveyor falling off the edge are **not** collected.
3. The item is chosen **at collection**, not at spawn (F2), so it reflects the current standing.

**Slots**
4. Each player has `item_slots` slots (default 2; range 1–3; set by the mode or level; a perk may add 1, capped at 3).
5. A collected item goes into the first free slot. If all slots are full, it is **discarded** with a "full" puff and the player gets `full_slot_points` score (default 50).
6. Items are kept until used or until the round ends; they don't carry between rounds or levels.

**Use**
7. Tapping a slot uses its item (Touch Controls `use_item(slot)`). Items can be used while Playing, including Waiting; during Resolving the use is queued to the end of the Resolving.
8. **Targeting**: buffs target the user. Debuffs target the **leader** automatically; if the user is the leader, the second-placed player. Ties go to the player with the higher score. A player who is out is never targeted. (Choosing a rival by tapping their portrait is an Open Question.)
9. Using an item applies its effect (Buffs & Debuffs). If the effect has no effect (framework), the item is **refunded** to its slot once; a second no-effect use consumes it.

**Item table and standing**
10. The **standing** rank `r` of each player is by goal progress (Level Goals F4), then score; rank 1 is the leader. In solo play `r = 1`.
11. The table lists each item with a base weight and a **comeback bias** (F2). Debuffs have positive bias (more likely the further behind you are), modest buffs negative bias. In solo play (campaign, Arcade) debuffs are removed from the table.

| Item | Effect | Base weight | Bias |
|---|---|---|---|
| Slow Time | buff | 10 | 0 |
| Bomb | buff | 8 | +0.5 |
| Helper Drop | buff | 10 | 0 |
| Preview Peek | buff | 10 | −0.5 |
| Junk Rain | debuff | 8 | +1.0 |
| Fog | debuff | 6 | +0.5 |
| Speed Up | debuff | 8 | +1.0 |
| Spin Lock | debuff | 6 | +0.5 |

**Modes**
12. `items_enabled`: on by default in versus rounds and Arcade; off in the campaign unless the level turns it on. Tournament Flow and the Mode / Minigame Randomizer may turn it off for a round.

### States and Transitions

Per item cube: **Tagged** (falling or locked) → **Collected** (layer cleared) or **Lost** (removed another way). Per slot: **Empty → Held → Used** (→ Empty), or **Held → Refunded** (no-effect, once).

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Piece Spawner & Queue | → Items | `on_spawn` (item-cube roll) |
| Layer Clearing | → Items | `on_clear` of tagged cubes (collection) |
| Buffs & Debuffs | Items → | Apply effect to a target |
| Rule-Twist Framework | ↔ | Items random stream; no-effect results |
| Touch Controls | → Items | `use_item(slot)` |
| Level Goals & Fail States, Scoring & Stars | → Items | Standing (progress, score) |
| Level Data, Tournament Flow, Mode / Minigame Randomizer, Arcade Mode | → Items | `items_enabled`, `item_slots` |
| Characters & Perks, Shop | → Items | Extra slot, potions (later) |
| HUD, Game Feel & VFX, Audio | Items → | Slots, item cube look, events |

## Formulas

### F1. Expected items per round

The expected_items formula is defined as:

`E_items ≈ pieces × p_item × p_collect`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| pieces | int | ≥ 0 | calculated | Pieces placed in the round |
| p_item | float | 0–0.5 | data file | Chance a piece carries an item cube; default 0.12 |
| p_collect | float | 0–1 | measured | Share of item cubes that end in a cleared layer; placeholder 0.6 until playtests |

**Output Range:** 0 upward. **Example:** a 60-piece round → 60 × 0.12 × 0.6 ≈ 4.3 items, about one every 14 pieces.

### F2. Standing-weighted item roll

The item_weight formula is defined as:

`w_i(r) = base_i × max(0, 1 + bias_i × (r − 1) / (P − 1))` for `P ≥ 2` players; `w_i = base_i` when `P = 1`; then pick item i with probability `w_i / Σ w`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_i | float | ≥ 0 | data file | Base weight (table) |
| bias_i | float | −1 to +2 | data file | Comeback bias (table) |
| r | int | 1–P | calculated (rule 10) | Collector's rank |
| P | int | 1–4 | calculated | Players still in the round |

**Output Range:** probabilities summing to 1. **Example (2 players):** the leader (r = 1) draws with base weights: debuffs 28 of 66 ≈ 42%. Last place (r = 2): Junk Rain 16, Speed Up 16, Fog 9, Spin Lock 9, Bomb 12, Slow Time 10, Helper Drop 10, Preview Peek 5 → debuffs 50 of 87 ≈ 57%.

## Edge Cases

- **If an item cube is in a deferred layer** (Obstacle Clearing): collected when the layer actually clears.
- **If the item cube's layer is wiped by a rescue**: lost.
- **If all slots are full**: the new item is discarded for 50 points (rule 5).
- **If a perk adds a slot mid-round**: available at once.
- **If the leader uses a debuff with 2 players**: it targets the other player.
- **If all opponents are out**: debuffs can't be used (slot greyed).
- **If two players collect at the same resolve**: each rolls from its own standing at that moment.
- **If a debuff is used during the target's Resolving**: queued until the target's Resolving ends.
- **If `items_enabled` is on in a campaign level**: debuffs are removed from the table (rule 11).
- **If an item cube is on a piece swapped by a twist**: the tag moves with the replacement only if the twist says so; otherwise lost.

## Dependencies

**Upstream:** Buffs & Debuffs (Hard), Layer Clearing (Hard: `on_clear`), Piece Spawner & Queue (Hard: `on_spawn`), Rule-Twist Framework (Hard), Touch Controls (Hard: `use_item`), Level Goals & Fail States and Scoring & Stars (Hard: standing).

**Downstream:** Tournament Flow (Hard), Arcade Mode (Soft), Characters & Perks, Shop (Soft), HUD, Game Feel & VFX, Audio (Soft).

## Tuning Knobs

| Knob | Range | Default | Affects |
|---|---|---|---|
| p_item | 0–0.5 | 0.12 | Item frequency (F1) |
| item_slots | 1–3 | 2 (mode/level/perk) | Hoarding vs. using |
| full_slot_points | 0–200 | 50 | Consolation for a full hand |
| base weights / biases | table | table | Item mix and comeback strength (F2) |
| items_enabled | true / false | versus & Arcade on, campaign off | Where items exist |

## Visual/Audio Requirements

- Item cube: the piece's cube with a glowing "?" bubble sticker in reward gold (art bible §4), visible at 28 px; bubbles bob gently (static with reduced motion).
- Collection: the bubble flies from the clearing layer to the slot (300 ms) and reveals the item icon with a pop.
- Slots: circle frames in the item strip (art bible §7: circles for items) on the opposite thumb from rotate and drop; a used slot empties with a squash.
- Debuff use: a magenta streak flies from the user's HUD to the target's board.
- Audio events: `item_collected`, `item_used`, `item_full`, `item_refunded`.

## Game Feel

Getting an item should feel like a little jackpot earned by a clear; using one should be one tap with an instant visible result. Targets: collect animation ≤ 300 ms; effect visible on the target within one frame of the tap (plus the 200 ms streak).

## UI Requirements

Item strip slots (Touch Controls rule 5; HUD reserved slot); greyed slot when no target. 📌 **UX Flag — Items**: include the item strip and collection animation in `/ux-design hud`.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/buffs-debuffs.md` | The eight effects |
| `design/gdd/layer-clearing.md` Core Rule 5 | `on_clear` collection |
| `design/gdd/piece-spawner-queue.md` Core Rule 5 | Injected pieces carry no items |
| `design/gdd/rule-twist-framework.md` Core Rules 8, 13 | Hooks, random stream, no-effect |
| `design/gdd/touch-controls.md` Core Rules 1, 5 | `use_item`, item strip |
| `design/gdd/level-goals-fail-states.md` F4 | Progress for standing |
| `design/gdd/obstacle-clearing.md` Core Rules 5–6 | Deferred layers |
| `design/art/art-bible.md` §4, §7 | Reward gold, circle item frames, opposite thumb |
| `design/gdd/game-concept.md` | Pillar 3: Comeback Energy |

## Acceptance Criteria

1. [U] **GIVEN** `p_item = 0.12` over 10 000 spawns (fixed seed), **THEN** 12% ± 1% carry one item cube; injected pieces never do.
2. [U] **GIVEN** an item cube in a cleared layer, **THEN** its owner gets an item; removed by Bomb, rescue or conveyor edge → not collected.
3. [U] F2: 2 players → leader debuff share ≈ 42%, last place ≈ 57% (over 10 000 rolls, ± 2%).
4. [U] **GIVEN** solo play with items on, **THEN** no debuff is ever rolled.
5. [U] **GIVEN** 2 full slots, **THEN** a new item is discarded and +50 score.
6. [U] **GIVEN** a debuff used by the leader in a 3-player round, **THEN** it targets second place; ties → higher score.
7. [U] **GIVEN** an item with no effect, **THEN** it is refunded once; the second no-effect use consumes it.
8. [I] **GIVEN** a slot tap during Resolving, **THEN** the item applies when Resolving ends.
9. [U] **GIVEN** `item_slots` from mode 1 and a perk +1, **THEN** the player has 2 slots; never more than 3.
10. [M] **GIVEN** a 2-player playtest, **THEN** about 4 items are collected per player per round (F1) and the trailing player wins at least 30% of rounds they were behind at mid-round.

## Open Questions

- **Manual targeting**: tap a rival's portrait vs. auto-leader (Touch Controls open question).
- **p_collect**: measure in playtests to tune `p_item`.
- **Campaign items**: which meadow tiers enable buffs? Campaign Structure.
- **Shop potions**: pre-level items from the Shop (Alpha).
