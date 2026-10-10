# Characters & Perks

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10
> **Implements Pillar**: Expression; Comeback Energy; Readable Chaos

## Summary

Four playable characters: the cloud wizard and three cute builder friends. Each has one big skill (Skills GDD) and a **perk set**: one always-on **signature** perk that is a pure trade-off (sidegrade) and three **edge** perks that give a small, capped advantage. Perks and potions work in every mode, including the solo campaign; quick versus allows sidegrades only. A loadout's total edge is capped at about 15%, and campaign star times are balanced for no perks at all.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Rule-Twist Framework, Skills, Shop / Points (later)`

## Overview

A character is a data record: a slot id (C1–C4 until the narrative team names them), a mechanical identity, one skill, one signature perk and three edge perks. Names, looks and personalities come later from narrative and art; nothing here depends on them. **C1** is the cloud wizard (tempo: time and falling speed); **C2** a demolition friend (breaking things, surviving trouble); **C3** a builder friend (filling and placing); **C4** a juggler friend (queue and item tricks). The Miller is never playable (decision sheet, Round 5). A **perk** is a Rule-Twist Framework rule at layer `perk` (rank 1): above the base game, below items, buffs, skills, twists and level mechanics, scoped to its player, lasting the whole level or round. Perks change only rule-adjustable knobs or run a small `RuleBehaviour`; they never touch core systems directly. The player picks a character and up to `edge_slots` (2) owned edge perks in the character-select screen; the signature is always on. Which perks are active is filtered **by mode** (rule 8). Every edge perk carries an **edge value** `e` (expected share of level time saved, F2), and a loadout's summed edge may not exceed `edge_cap` (0.15, F1). Because star times assume no perks, potions or skill use, perks only make stars easier. This serves *Expression* (character and loadout choice), *Comeback Energy* (a capped edge can never decide a round on its own) and *Readable Chaos* (few, simple, listed perks). All values are starting defaults.

## Detailed Design

### Core Rules

**Characters**
1. A character has: `character_id` (`c1`–`c4`), `identity` tag, `skill_id`, `signature_perk_id`, three `edge_perk_ids`, and narrative-owned fields (name key, model, portrait, voice) left blank until supplied.
2. **Availability**: all four characters are playable from the first launch in quick versus and tournaments (a new Wi-Fi group must be able to pick at once). In the campaign the default is C1 only, with the friends joining as the story meets them (narrative to place the joins; open question).
3. **Duplicates** are allowed in multiplayer: two players may pick the same character. Players are told apart by player colour and badge (art bible §4), not by character.

**Perks**
4. A perk has: `perk_id` (unique across characters), `character_id`, `kind` (`signature` or `edge`), `edge` value `e`, icon, one-line description key, and framework operations (modifiers on rule-adjustable knobs, or a `RuleBehaviour` id). Layer is always `perk`, scope the owner, lifetime the whole level / round.
5. **Signature perk**: always active for its character in every mode where perks are on. It must be a sidegrade: `|e| ≤ sidegrade_tolerance` (0.02, F2).
6. **Edge perks**: `0 < e ≤ edge_max_single` (0.08). Owned through the Shop / Points system (later; prices are the Shop's). Not owned = not selectable.
7. **Loadout**: signature + up to `edge_slots` (2) owned edge perks of the chosen character. The loadout is valid only if `E_loadout ≤ edge_cap` (F1); the select screen greys out a perk that would break the cap. The equipped set is saved per perk in the profile (`inventory.perks[perk_id] = {"owned": bool, "equipped": bool}`, ADR-0013 reserved map).

**Modes**
8. Which perks and potions are active, per context:

| Context | Signature | Edge perks | Potions |
|---|---|---|---|
| Campaign level (solo) | on | on | on |
| Arcade (solo) | on | on | on |
| Quick versus round | on | **off** | **off** (see Open Questions) |
| Tournament round | on | on | on |
| Tournament sudden death | on | on | off |
| Minigame scene with no `BoardSim` | off unless the minigame declares support | off | off |
| Level-maker test play | as the level's context | as the level's context | off |

9. Filtering happens at level / round load: filtered-out perks are never instantiated (they do not show as "no effect").
10. In multiplayer each player's phone sends its character and loadout ids; the host checks ownership-independent rules (mode filter, F1 cap, ids exist in the shared data version, ADR-0009) and rejects an invalid loadout back to the select screen. Perk data is identical on every phone (version check).

**Interaction rules**
11. Perks combine with everything else through framework F1 (multiply, then clamp). A perk never overrides an item, skill, twist or level mechanic (lowest non-base layer).
12. A perk whose knob or hook does not exist in the current level (for example a skill-charge perk under the `once` skill rule, or an item-slot perk with items off) is shown on the pause list as "not used here" and does nothing.
13. **Relaxed timing** (accessibility) scales star times only; perks are unchanged and still count nothing toward star balance.
14. **Potions** are one-use shop items applied at level start as `item_buff` rules (Shop GDD, later). They are not perks and are not counted in `E_loadout`; star times still assume none.

**Perk sets (starting defaults)**

| Perk | Character | Kind | Effect | e |
|---|---|---|---|---|
| **Light Feet** | C1 | signature | `lock_delay_ms × 1.2`, `ramp_per_clear × 1.15` | ≈ 0 |
| Breeze Brake | C1 | edge | `gravity_scale × 0.92` | 0.06 |
| Patient Hands | C1 | edge | `lock_delay_ms × 1.25` | 0.05 |
| Quick Study | C1 | edge | `skill.charge_rate × 1.25` | 0.04 |
| **Sturdy** | C2 | signature | `warnings_max + 1`, `lock_delay_ms × 0.85` | ≈ 0 |
| Second Wind | C2 | edge | `warnings_max + 1` | 0.05 |
| Rubble Charge | C2 | edge | Behaviour: each obstacle broken adds 0.05 skill charge (`charge` only) | 0.04 |
| Deep Pockets | C2 | edge | `item_slots + 1` (cap 3, Items rule 4) | 0.03 |
| **Steady Build** | C3 | signature | `preview_count + 1`, `gravity_scale × 1.1` | ≈ 0 |
| Long Look | C3 | edge | `preview_count + 1` (cap 3) | 0.05 |
| Gentle Landing | C3 | edge | `hard_drop_grace_ms × 1.5` | 0.03 |
| Builder's Charge | C3 | edge | Behaviour: each resolve with ≥ 2 layers adds 0.05 skill charge (`charge` only) | 0.04 |
| **Juggle** | C4 | signature | `hold_enabled = true`, `lock_delay_ms × 0.85` | ≈ 0 |
| Lucky Bag | C4 | edge | `randomizer = bag` (fair bag) | 0.05 |
| Second Look | C4 | edge | `preview_count + 1` (cap 3) | 0.05 |
| Trick Charge | C4 | edge | Behaviour: each item used adds 0.1 skill charge (`charge` only) | 0.04 |

15. Edge values are design estimates until measured (F2); the largest pair per character is 0.11, so the cap does not bite at defaults and exists to bound later tuning, new perks or more slots.
16. **3★ note**: `warnings_max` perks never help the 3★ condition (it requires no warning used, Scoring rule 1); their edge is on 1–2★ and survival.

### States and Transitions

Per perk instance: framework states, **Pending** (loaded with the level) → **Active** (`on_level_start`, after Countdown) → **Expired** (level / round end). Perks are not Suspended by pause (they have no clock). Per loadout: **Editing → Valid / Invalid (cap)** in the select screen; only Valid can start a level.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Rule-Twist Framework | Perk → | Layer-1 rules (modifiers, small behaviours) |
| Skills | ↔ | Character → skill; charge perks change `skill.charge_rate` and F1 terms |
| Items | Perk → | `item_slots + 1`; item-use events (Trick Charge) |
| Fall, Drop & Lock, Piece Spawner & Queue, Level Goals | ← | Knobs: gravity, lock, ramp, grace, preview, hold, randomizer, warnings |
| Obstacle Clearing, Layer Clearing | → Perk | Break and clear events (charge perks) |
| Scoring & Stars | ← | Star times assume no perks (F2 measurement baseline) |
| Shop / Points (later) | → | Ownership of edge perks; potions |
| Save & Profile (ADR-0013) | ↔ | `inventory.perks` owned / equipped |
| Local Multiplayer (ADR-0009) | ↔ | Character + loadout ids, host validation |
| Menus / UI (ADR-0016), HUD | ← | Character select + perks screen; pause-screen perk list |

## Formulas

### F1. Loadout edge cap

The loadout_edge formula is defined as:

`E_loadout = Σ e_i` over equipped edge perks (signature excluded); valid when `E_loadout ≤ edge_cap`

**Variables:**
| Symbol | Type | Range | Source | Description |
|---|---|---|---|---|
| e_i | float | 0.01–0.08 | data file (F2 estimate or measurement) | Edge of edge perk i |
| n_equipped | int | 0–edge_slots | player choice | Edge perks equipped |
| edge_slots | int | 1–3 | data file | Default 2 |
| edge_cap | float | 0.10–0.20 | data file | Default 0.15 |
| E_loadout | float | 0 – 0.24 | calculated | Summed edge |

**Output Range:** 0 (no edge perks) to `edge_slots × edge_max_single` (0.16 at defaults, 0.24 at 3 slots); values above `edge_cap` are rejected, so the active range is 0–0.15. The sum is used instead of a product because it is always ≥ the true combined effect `1 − Π(1 − e_i)`, so the cap is conservative. **Example:** Breeze Brake 0.06 + Patient Hands 0.05 = 0.11 → valid. Two tuned perks at 0.08 each = 0.16 > 0.15 → the second is greyed out.

### F2. Perk edge value (measurement definition)

The perk_edge formula is defined as:

campaign: `e = 1 − median(t_with) / median(t_without)`; Arcade check: `e_score = median(s_with) / median(s_without) − 1`

**Variables:**
| Symbol | Type | Range | Source | Description |
|---|---|---|---|---|
| t_with, t_without | float | 60–1 200 s | measured (bot or playtest, same seeds) | Level clock to win with / without the perk, on a fixed reference set of campaign levels |
| s_with, s_without | int | ≥ 0 | measured | Arcade scores with / without |
| e | float | −0.1 – 0.2 | calculated | Edge; positive = advantage |
| sidegrade_tolerance | float | 0.01–0.05 | data file | Default 0.02 (signatures) |
| edge_max_single | float | 0.05–0.10 | data file | Default 0.08 |

**Output Range:** unbounded in principle; a measured `e` outside its kind's band (signature `|e| > 0.02`, edge `e > 0.08` or `e ≤ 0`) fails balance review and the perk's numbers are retuned. `median(t_without) > 0` always (a level takes time). **Example:** reference levels median 300 s without, 282 s with Breeze Brake → `e = 1 − 282/300 = 0.06`.

### F3. Star safety with a full loadout

The star_margin formula is defined as:

`t_expected = t_base × (1 − E_loadout)`; star times stay those of Scoring F1 (`t2`, `t3` from `t_base`), never scaled by perks

**Variables:**
| Symbol | Type | Range | Source | Description |
|---|---|---|---|---|
| t_base | float | 60–1 200 s | measured | Median no-perk win time |
| E_loadout | float | 0–0.15 | F1 | Loadout edge |
| t_expected | float | 51–1 200 s | calculated | Expected time with the loadout |

**Output Range:** `t_expected` is at most 15% below `t_base`. **Example:** `t_base = 300 s`, full 0.15 loadout → 255 s. If the level's `t_est` is also 300 s, `star3_share = 0.6` gives a 3★ time of 180 s for everyone, so a perk player is helped by at most ~45 s and a no-perk player is never locked out.

## Edge Cases

- **If a player equips perks then enters quick versus**: edge perks are filtered at load; the loadout stays saved for other modes.
- **If a perk's knob is overridden by a higher layer** (a twist sets `gravity_scale`): the perk loses (F1 set wins); "not used here" on the pause list only if it can never apply this level, otherwise it silently stacks where it can.
- **If `preview_count` is already 3**: Long Look / Second Look / Steady Build are clamped to 3; Steady Build's gravity penalty still applies (the trade-off holds even when the bonus is clamped — tuning must accept this, or Steady Build's penalty is waived when clamped; open question).
- **If `hold_enabled` is already true for the level**: Juggle's bonus is nothing and its lock penalty still applies (same rule).
- **If an owned perk is removed by a data update**: the profile entry is ignored and the loadout drops it; no crash.
- **If the edge cap is lowered by a data update and a saved loadout breaks it**: the last-equipped perk is unequipped on load and the select screen says so.
- **If two players pick the same character**: allowed; both have the same perks and skill.
- **If a perk's `randomizer = bag` meets a level whose randomizer is set by a twist or mechanic**: the higher layer wins.
- **If items are off**: Deep Pockets and Trick Charge are "not used here".
- **If the skill rule is `once` or `off`**: charge perks are "not used here".
- **If the host rejects a loadout** (cap broken, unknown id, version mismatch): the player returns to select with a reason; the round waits for them (Tournament Flow ready rules).

## Dependencies

**Upstream:** Rule-Twist Framework (Hard), Skills (Hard), Items (Soft: slot and use events), Fall, Drop & Lock, Piece Spawner & Queue, Level Goals & Fail States (Hard: knobs), Scoring & Stars (Hard: star baseline), Save & Profile (Hard), Local Multiplayer (Hard in versus).

**Downstream:** Shop / Points (Hard, later: sells edge perks and potions), Tournament Flow (Soft: loadout check before rounds), Menus / UI (Hard: character select + perks screen), HUD (Soft: pause list), Narrative and Art (fill names, looks, portraits).

Bidirectional notes needed in: Rule-Twist Framework, Items, Scoring & Stars, Tournament Flow (not edited in this pass).

## Tuning Knobs

| Knob | Range | Default | Affects |
|---|---|---|---|
| edge_cap | 0.10–0.20 | 0.15 | Maximum loadout advantage (F1) |
| edge_slots | 1–3 | 2 | Edge perks per loadout |
| edge_max_single | 0.05–0.10 | 0.08 | Strongest allowed edge perk |
| sidegrade_tolerance | 0.01–0.05 | 0.02 | How neutral a signature must be |
| per-perk modifiers | knob safe ranges | perk table | Each perk's strength |
| charge perk amounts | 0.02–0.15 | 0.05 / 0.05 / 0.1 | Rubble, Builder's, Trick Charge |
| mode filter table | on / off per cell | rule 8 | Where edges and potions apply |

## Visual/Audio Requirements

- Character select: four character cards (placeholder silhouettes until art), identity icon, skill icon and one-line skill description; perk chips under the card (signature with a ribbon, edge chips with a small "+" and an edge bar filling toward the cap).
- Perks show in play only on the pause screen (framework); no HUD badge.
- Audio events: `character_pick`, `perk_equip`, `perk_blocked` (cap reached).

## Game Feel

Picking a character should feel like choosing a play style, not buying a win. Targets: a full edge loadout shortens median win time by at most 15% (F3); in quick versus no character wins more than 30% of 4-player rounds in playtests (2-player: 55%).

## UI Requirements

Character select + perks screen (decision sheet: designed now), loadout greying at the cap, "not used here" tags on the pause list. 📌 **UX Flag — Characters & Perks**: `/ux-design` for character select + perks and the pause perk list.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/rule-twist-framework.md` Core Rules 4–6, 12, 16; F1 | Layer `perk`, knob list, stacking, visibility |
| `docs/architecture/adr-0011-mechanic-level-event-runtime.md` §2 | `perk` rank 1 |
| `docs/architecture/adr-0004-rule-twist-runtime.md` §2–3 | Rule JSON, knob registry |
| `docs/architecture/adr-0013-save-profile-settings.md` | `inventory.perks` |
| `docs/architecture/adr-0009-local-multiplayer.md` | Host validation, shared data version |
| `design/gdd/skills.md` | Skills per character, `skill.charge_rate`, F1 |
| `design/gdd/items.md` Core Rule 4 | Perk +1 slot, cap 3 |
| `design/gdd/scoring-stars.md` Core Rule 1, F1 | Star times; 3★ needs no warning |
| `design/gdd/game-concept.md` | Expression; characters with perks; shop perks and potions |

## Acceptance Criteria

1. [U] F1: 0.06 + 0.05 → valid; 0.08 + 0.08 with cap 0.15 → invalid, second perk greyed.
2. [U] **GIVEN** quick versus, **THEN** only signature perks are instantiated; no potions apply.
3. [U] **GIVEN** a campaign level with C1 and Breeze Brake, **THEN** effective `gravity_scale` is base × 0.92 (framework F1) and a twist's `set` overrides it.
4. [U] **GIVEN** any perk, **THEN** its rule has layer `perk` (rank 1) and loses ties to items, skills, twists and mechanics.
5. [U] **GIVEN** a charge perk under skill rule `once`, **THEN** it does nothing and the pause list shows "not used here".
6. [U] **GIVEN** a saved loadout over a newly lowered cap, **THEN** the last-equipped perk is unequipped on load.
7. [I] **GIVEN** a LAN round where a client sends a loadout over the cap, **THEN** the host rejects it and the client returns to select.
8. [U] **GIVEN** Long Look with `preview_count` already 3, **THEN** the value stays 3 (clamp).
9. [M] F2: each signature measures `|e| ≤ 0.02` and each edge perk `0 < e ≤ 0.08` on the reference level set.
10. [M] F3: with a full loadout, median win time on reference levels is ≥ 85% of the no-perk median.
11. [M] Quick versus playtest: no character exceeds 30% wins in 4-player or 55% in 2-player rounds.

## Open Questions

- **Potions in quick versus**: the decision sheet says potions are "active everywhere" and quick versus is "sidegrades only"; defaulted to **off** in quick versus. Confirm.
- **Edge perks in Arcade**: defaulted to on (solo, no leaderboards yet). Revisit if Arcade leaderboards arrive.
- **Campaign join points** for C2–C4 (narrative + campaign structure); all four are always available in multiplayer.
- **Clamped sidegrades** (Steady Build at preview 3, Juggle with hold already on): keep the penalty or waive it when the bonus is clamped?
- **New rule-adjustable knobs**: `skill.charge_rate` (Skills) and `item_slots` (Items) must be added to the framework's closed list (Core Rule 4); not edited here.
- **Character mastery** (game concept "character mastery"): not designed; no levels or unlocks per character yet.
- **Systems index**: needs an entry for this GDD (not edited in this pass).
