# Skills

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10
> **Implements Pillar**: Comeback Energy; Readable Chaos; Variation Over Depth

## Summary

Every playable character has one big skill: a game-changing move, much stronger than an item, behind one button. How often you may use it depends on the **mode**: in the campaign and Arcade a **charge meter** fills as you clear layers; in quick versus and tournament rounds you get it **once per round**; some rounds or levels switch it off or make it a **consumable**. A skill is a bundle of Rule-Twist Framework rules at the `item_buff` layer, so it can never switch off a level's mechanic or twist.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Rule-Twist Framework, Buffs & Debuffs, Characters & Perks`

## Overview

A skill is the character's "ultimate": four skills, one per playable character (Characters & Perks slots C1–C4), each with a different mechanical identity: **tempo** (C1, the cloud wizard), **demolition** (C2), **building** (C3) and **queue tricks** (C4). Each skill has a **self effect** that works everywhere, including the solo campaign, and an optional **versus rider** that hits an opponent (the leader, as Items rule 8) only when there is someone to hit. Skills are data (a skill JSON naming framework rules and their parameters), reuse the eight Buffs & Debuffs effects wherever they can, and add a small `RuleBehaviour` only where they must (Perfect Fill, Pick & Mix). The **use rule** is not fixed per skill: the skill's data carries a per-context table with defaults (charge / once / consumable / off), and a level or a tournament recipe may override it through the Skill Rule atom (WO12). The skill-hook atoms Skill Clash (IN32), Skill Echo (IN33), Skill Surge (EV23) and Skill Swap (WO13) plug into the states and the charge formula defined here. This serves *Comeback Energy* (rank-scaled charge and leader-targeted riders), *Readable Chaos* (one button, one skill at a time, every effect badged) and *Variation Over Depth* (four very different big moves on the same blocks). Star times are balanced with no skill use, so a skill only ever makes a star easier, never required. All values are starting defaults.

## Detailed Design

### Core Rules

**What a skill is**
1. A skill has: `skill_id`, `character_id`, icon, name key, **self effect** (one or more framework rules, layer `item_buff`, scope = the user), optional **versus rider** (one rule, layer `item_buff`, scope = one opponent), a **use-rule table** (rule 6), `requires` compatibility tags (ADR-0004 §2), and `clash_eligible` (true if it has a rider).
2. Skill rules sit at `item_buff` (rank 2, ADR-0011 §2): above perks, below twists and level mechanics. They multiply with other rules and are clamped (framework F1). Where a skill reuses a Buffs & Debuffs effect, it reuses that effect's `rule_id` with skill-specific parameters; it does not fork it.
3. A player has exactly one skill (their character's), shown as one round **skill button** (input `use_skill`, ADR-0012). Using it is a player command (`SimCommand`, ADR-0001); its random choices use each rule's own stream (framework rule 13).
4. **One at a time**: while any rule of the player's own skill is Active, the button is disabled and charge does not accrue (prevents chaining).
5. **Rider targeting** follows Items rule 8 (the leader; second place if you lead; ties to the higher score; never a player who is out). With no valid target (solo, or all rivals out) the rider is skipped and the self effect still applies. In multiplayer the rider is an attack routed by the host and applied on arrival (ADR-0009).

**Use rules**
6. A skill's availability is governed by one `skill_rule` per play context:

| `skill_rule` | Meaning | Ready when | Spent by a use |
|---|---|---|---|
| `charge` | Meter `q` from 0 to 1 fills from clears (F1) | `q = 1` | `q → 0`; can be refilled |
| `once` | One use per round / level | after `once_ready_delay_s` of play | the use; no refill |
| `consumable` | Each use costs one skill token from the profile (ADR-0013 `inventory.skills[skill_id].tokens`) | tokens ≥ 1 | one token |
| `off` | No skill | never (button hidden) | — |

7. **Default per context** (each skill's data may override a row; a level's or recipe's `skill_rule` overrides both):

| Context | Default `skill_rule` | Rank scaling (F1 `m_rank`) | Notes |
|---|---|---|---|
| Campaign level (solo) | `charge` | 1 (solo) | Level Data may set `once` or `off` (for example a boss or a tutorial) |
| Arcade (solo) | `charge` | 1 | Endless run, so the meter refills |
| Quick versus round | `once` | — | Sidegrades only (Characters & Perks); skills are balanced against each other (F3) |
| Tournament round, burst or standard length (< `charge_min_round_s`) | `once` | — | WO12 recipe override allowed |
| Tournament round, showpiece length (≥ `charge_min_round_s`) | `charge` | on | WO12 override allowed |
| Tournament sudden death | `off` | — | Pure clear race, like its "no twists" rule |
| Minigame scene with no `BoardSim` | `off` | — | Unless the minigame data declares skill support |
| Level-maker test play | the level's own context | — | |

   `consumable` is no context's default; a level, a recipe or a later shop item may select it.
8. **Resolution order**: level / recipe `skill_rule` (WO12) > the skill's own per-context entry > the table in rule 7. The resolved rule is fixed at level / round start and shown as the button's state.

**Using a skill**
9. Pressing the ready button activates the self effect and, if there is a target, sends the rider. During the user's Resolving the use is queued to the end of Resolving (as Items rule 7).
10. **No effect**: if every self operation loses to a higher layer or finds nothing to act on (framework rule 5 of Buffs & Debuffs), the skill is **not spent** (meter, use or token kept) and shows the "no effect" pop. A rider that reaches its target counts as an effect.
11. A player who is out (versus loss) loses their skill for the round; a queued use is dropped.
12. Skills pause with the game, during warnings and during Resolving (framework Suspended).
13. **Compatibility**: if a level's board kind, layout or slots do not provide a skill's `requires` tags, that skill's button is hidden for the level and the validator (ADR-0005) reports it as an information note, not an error.

**The four skills**

| Skill | Character | Self effect | Versus rider |
|---|---|---|---|
| **Calm Skies** | C1 (tempo) | 8 s: `gravity_scale × 0.25` and `lock_delay_ms × 1.5` | Speed Up on the target for 8 s |
| **Mega Bomb** | C2 (demolition) | The falling (or next) piece becomes a Bomb with `bomb_radius 2` (5 × 5 × 5) and `bomb_rock_damage 3` | Junk Rain, 1 layer, on the target |
| **Perfect Fill** | C3 (building) | At the user's next `on_resolve_end` (S4b), fills every empty fillable cell of up to `fill_layers` (2) layers whose fill share ≥ `fill_threshold` (0.6), fullest first; the S4c clear then removes them | Fog on the target for 5 s |
| **Pick & Mix** | C4 (queue tricks) | For the next `pick_pieces` (3) spawns, the preview offers 3 shapes: the stream's next shape plus 2 drawn from the level's shape pool by the skill's stream; the player taps one while the previous piece falls; no tap = the stream's shape | Spin Lock on the target for 6 s |

14. **Perfect Fill**: filled cubes are ordinary cubes owned by the user with the "builder" sticker; cells that are masked, pillars, rocks, crates or other content are not fillable and do not count toward the share. Writes go through `RuleApi.set_cell` in S4b, so S4c runs the clear once (ADR-0011 §3). If no layer reaches the threshold: no effect (rule 10).
15. **Pick & Mix**: the stream index advances once per spawn as normal (the stream's shape is consumed whether or not it is picked), so the Spawner sequence is unchanged for later pieces. Injected pieces (Helpers, junk) are not offered as choices and do not use up a pick.
16. **Mega Bomb** follows Buffs & Debuffs rule 6 and F2 (radius 2 is the top of `bomb_radius`'s range); a second Bomb (item) on the same piece refreshes, it does not add a second blast.

**Skill-hook atoms (only when the level or recipe includes them)**
17. **Skill Echo (IN33)**, `charge` only: being hit by a rival's rider adds `echo_charge` to your meter (F1 term).
18. **Skill Clash (IN32)**: two rider-bearing skills whose riders target each other's users, activated within `clash_ms` by the host's receive time, both fizzle (self effects and riders cancelled) into a confetti burst. Refund: `charge` → `q = clash_refund` (0.5); `once` → the use is returned, at most once per round (a second clash spends it, as Items rule 9); `consumable` → the token is returned.
19. **Skill Surge (EV23)**: every player gets a **free use** usable for `surge_s`; it does not touch the meter, the once-use or tokens. Unused free uses vanish when the surge ends. Activation telegraphs are staggered by 300 ms. A player whose skill is Active gets the free use when it ends, if the surge is still on.
20. **Skill Swap (WO13)**: at the gong each player's **skill identity** moves to the next player in seat order; meters, once-uses and tokens stay with the player (the button), perks stay with the character. Skill rules already Active run to their end.

### States and Transitions

Per player skill button:

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **Hidden** | `skill_rule = off` or incompatible | Level / round start | — |
| **Charging** | `charge`: `q < 1`; `once`: within `once_ready_delay_s`; `consumable`: 0 tokens | Start; after a use | `q = 1` / delay over / token gained → Ready |
| **Ready** | Usable | as above | Pressed → Active (or Queued in Resolving) |
| **Queued** | Pressed during Resolving | Press in Resolving | Resolving ends → Active |
| **Active** | A self rule is Active (button disabled, no charge) | Use applied | All self rules Expired → Charging (`charge`, `consumable` with tokens) or **Spent** (`once`) |
| **Spent** | `once` used | Use expired | Round / level end |

Skill rules themselves follow the framework states (Pending → Active ⇄ Suspended → Expired).

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Rule-Twist Framework | Skill → | Layer-2 rules, hooks (`on_lock`, `on_resolve_end`, `on_spawn`), own RNG streams |
| Buffs & Debuffs | Skill → | Reused effects: Slow-style gravity, Bomb, Speed Up, Junk Rain, Fog, Spin Lock |
| Characters & Perks | ↔ | Which skill a player has; perks that change `skill.charge_rate` and charge terms |
| Layer Clearing, Obstacle Clearing | → Skill | Clears (charge, F1) |
| Piece Spawner & Queue | ↔ | Pick & Mix choices on `on_spawn`; stream index unchanged |
| Level Data, Tournament recipes (WO12), Mode / Minigame Randomizer | → Skill | `skill_rule` overrides; round length |
| Level Goals & Fail States, Items | → Skill | Standing rank (F1 `m_rank`, rider targeting) |
| Local Multiplayer (ADR-0009) | ↔ | Riders as attacks; clash timing by host receive time |
| Save & Profile (ADR-0013) | ↔ | Skill tokens (`consumable`) |
| Input (ADR-0012), HUD, Game Feel & VFX, Audio | ↔ | `use_skill`; button, meter, events |

## Formulas

### F1. Skill charge per resolve (`charge` rule)

The skill_charge formula is defined as:

`Δq = (k_layer × n + k_combo × max(0, k − 1)) × m_rate × m_rank + echo`, then `q = min(1, q + Δq)`; no charge while the skill is Active

**Variables:**
| Symbol | Type | Range | Source | Description |
|---|---|---|---|---|
| n | int | 0–12 | calculated (Layer Clearing) | Layers cleared in this resolve (deferred layers count when they clear) |
| k | int | ≥ 0 | calculated (Scoring rule 6) | Current combo count |
| k_layer | float | 0.05–0.25 | data file | Charge per layer; default 0.125 (8 layers fill the meter) |
| k_combo | float | 0–0.1 | data file | Extra charge per combo step; default 0.03 |
| m_rate | float | 0.5–1.5 | knob `skill.charge_rate` (rule-adjustable, see Open Questions) | Perk and context multiplier; default 1.0 |
| m_rank | float | 1–1.5 | calculated | `1 + rank_bias × (r − 1) / (P − 1)` for P ≥ 2; 1 when P = 1 |
| rank_bias | float | 0–0.5 | data file | Default 0.5 (last place charges 50% faster) |
| r, P | int | 1–4 | calculated (Items rule 10) | Rank and players still in |
| echo | float | 0 or echo_charge | event | `echo_charge` (0.2–0.5, default 0.34) when hit by a rival rider under IN33, else 0 |
| q | float | 0–1 | state | Meter; Ready at 1 |

**Output Range:** `q` is clamped to 0–1; overflow above 1 is lost. `Δq` per resolve is 0 (no clear, no echo) to at most `(0.25 × 12 + 0.1 × k) × 1.5 × 1.5 + 0.5`, which always fills the meter; no value is unusable. **Example:** solo, a double clear on combo step 2: `Δq = (0.125 × 2 + 0.03 × 1) × 1 × 1 = 0.28`. Same clear by last place of 4 players: `m_rank = 1 + 0.5 × 3/3 = 1.5` → 0.42.

### F2. Expected skill uses per campaign level

The expected_skill_uses formula is defined as:

`U ≈ floor(L × k_layer × m_rate + q_0)` (combo term ignored; it adds about 10% in practice)

**Variables:**
| Symbol | Type | Range | Source | Description |
|---|---|---|---|---|
| L | int | 0–60 | calculated (Level Goals, Level Data F1) | Layers cleared in the level |
| k_layer, m_rate | float | as F1 | data file | As F1 |
| q_0 | float | 0–1 | data file | Starting charge; default 0 |
| U | int | 0–15 | calculated | Uses in the level |

**Output Range:** 0 upward, bounded by `L`. Design target: **1–2 uses** in a typical campaign level (12–20 layers). **Example:** a 12-layer level → `floor(12 × 0.125) = 1`; with a 1.25 charge perk → `floor(1.875) = 1`; a 20-layer level → 2 (3 with the perk). If playtests show 3★ getting trivial, lower `k_layer` before touching star times.

### F3. Skill parity (quick versus balance check)

The skill_parity formula is defined as:

`dev_c = |V_c − V̄| / V̄`, where `V_c` = median layer-equivalents gained per use of skill c (bot or playtest), `V̄` = mean of the four `V_c`; pass when every `dev_c ≤ parity_tolerance`

**Variables:**
| Symbol | Type | Range | Source | Description |
|---|---|---|---|---|
| V_c | float | > 0 | measured | Layers cleared (own) + layers forced on the target (rider) in the 30 s after a use, minus the same without the use |
| V̄ | float | > 0 | calculated | Mean over the four skills |
| parity_tolerance | float | 0.1–0.3 | data file | Default 0.2 |
| dev_c | float | ≥ 0 | calculated | Relative deviation |

**Output Range:** `dev_c ≥ 0`, unbounded above; `V̄ > 0` by construction (a skill with `V_c ≤ 0` fails review before this check). **Example:** V = 2.4, 2.0, 2.2, 1.8 → V̄ = 2.1; dev = 0.14, 0.05, 0.05, 0.14 → all pass at 0.2.

## Edge Cases

- **If the button is pressed while the player's skill is Active**: nothing happens (disabled, rule 4).
- **If a skill is used during Resolving**: queued to the end of Resolving (Queued state).
- **If a skill's self effect loses to a twist or mechanic** (Calm Skies under Sticky Landing's set; Perfect Fill with clearing vetoed by a level mechanic): "no effect" pop, not spent (rule 10).
- **If Perfect Fill finds no layer at ≥ 0.6**: no effect, not spent.
- **If Perfect Fill's filled layer is a deferred layer** (Obstacle Clearing): it clears when the deferral allows; the fill stays.
- **If Mega Bomb is used with no falling piece** (Waiting): it tags the next piece (as Bomb).
- **If Mega Bomb and an item Bomb are on one piece**: one blast at the larger radius and higher rock damage, whichever came first (the Bomb behaviour keeps the max of its tag params; an explicit exception to "newest wins", so an item can never shrink a Mega Bomb).
- **If Pick & Mix is active and an injected piece comes next**: the injected piece spawns as is and no pick is used.
- **If Pick & Mix's pick window ends without a tap**: the stream's shape spawns.
- **If the rider's target is out or in Resolving**: out → rider skipped, self effect still applies; Resolving → queued on the target (ADR-0009).
- **If a player tops out with the skill Queued**: the use is dropped and not spent (the player is out anyway).
- **If the level ends while a skill is Active**: the rules expire with the level; nothing carries over.
- **If `once_ready_delay_s` is longer than the round**: the skill never becomes Ready; the validator warns.
- **If two players use skills in the same tick**: each applies on its own board; riders arrive in host order (ADR-0009).
- **If Skill Clash conditions are met but one skill has no rider**: no clash (only rider-bearing skills clash).
- **If Skill Swap moves a skill whose `requires` the level does not provide**: the receiver's button is Hidden until the next swap or round end; their meter is kept.
- **If Skill Surge starts while a player's `once` use is Spent**: they still get the free use.
- **If the charge meter is full and the player keeps clearing**: overflow is lost (F1).
- **If relaxed timing is on**: no change to skills; only star times scale.

## Dependencies

**Upstream:** Rule-Twist Framework (Hard), Buffs & Debuffs (Hard: reused effects), Characters & Perks (Hard: which skill), Layer Clearing (Hard: charge), Piece Spawner & Queue (Hard: Pick & Mix), Level Goals & Fail States and Items (Hard: standing, targeting), Level Data & Definition (Hard: `skill_rule`), Local Multiplayer (Hard in versus: riders, clash timing), Save & Profile (Soft: tokens).

**Downstream:** Tournament Flow and Tournament Minigames (Hard: per-round `skill_rule`, WO12, IN32, IN33, EV23, WO13), HUD, Game Feel & VFX, Audio (Soft), Shop (Soft, later: skill tokens).

Bidirectional notes needed in: Rule-Twist Framework, Buffs & Debuffs, Items, Level Data, Tournament Flow (see Open Questions; not edited in this pass).

## Tuning Knobs

| Knob | Range | Default | Affects |
|---|---|---|---|
| k_layer | 0.05–0.25 | 0.125 | Campaign / Arcade skill frequency (F1, F2) |
| k_combo | 0–0.1 | 0.03 | Reward for combos |
| rank_bias | 0–0.5 | 0.5 | Comeback strength of charge (F1) |
| skill.charge_rate | 0.5–1.5 | 1.0 | Per-player multiplier (perks) |
| once_ready_delay_s | 0–30 | 15 | Stops an opening-second skill in `once` rounds |
| charge_min_round_s | 120–300 | 180 | Round length from which tournaments use `charge` |
| calm_skies_gravity / lock / duration | 0.1–0.5 / 1.2–2.0 / 5–12 s | 0.25 / 1.5 / 8 s | C1 strength |
| mega_bomb_radius / rock_damage | 1–2 / 2–3 | 2 / 3 | C2 strength |
| fill_layers / fill_threshold | 1–3 / 0.4–0.8 | 2 / 0.6 | C3 strength |
| pick_pieces / pick_options | 1–5 / 2–4 | 3 / 3 | C4 strength |
| rider durations (Speed Up, Fog, Spin Lock) | 3–15 s | 8 / 5 / 6 s | Versus sting |
| echo_charge | 0.2–0.5 | 0.34 | IN33 |
| clash_ms / clash_refund | 400–1 500 / 0–1 | 800 / 0.5 | IN32 |
| surge_s | 3–10 | 6 | EV23 |
| parity_tolerance | 0.1–0.3 | 0.2 | Balance check (F3) |

## Visual/Audio Requirements

- Skill button: a larger circle than the item slots, character portrait inside, meter as a filling ring (`charge`), a single star pip (`once`), a token count (`consumable`); Ready pulses gently (static with reduced motion).
- Activation: a 400 ms character "pose" pop on the user's board edge with the skill's icon (cyan chevron frame, art bible §4); riders use the magenta streak like debuff items.
- Per skill: Calm Skies — soft clouds drift over the stack; Mega Bomb — bigger fuse sticker, chunkier puff; Perfect Fill — bricks pop in one by one (≤ 300 ms total) then the clear; Pick & Mix — three shape cards fan out from the preview plate.
- Audio events: `skill_ready`, `skill_used`, `skill_no_effect`, `skill_clash`, `skill_surge`, `skill_swap`.

## Game Feel

A skill should feel like the character's big moment: rare enough to look forward to, strong enough to turn a level or a round. Targets: effect visible within one frame of the press (plus the 200 ms rider streak); no rider lasts longer than 8 s; no skill removes control of the falling piece.

## UI Requirements

Skill button in the HUD (same thumb as the item strip, Touch Controls), Pick & Mix choice cards on the preview plate, button-state legend on the pause screen. 📌 **UX Flag — Skills**: include the skill button and Pick & Mix cards in `/ux-design hud`.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/rule-twist-framework.md` Core Rules 5–13, F1, F2 | Layer-2 rules, clamps, priority, RNG streams |
| `docs/architecture/adr-0004-rule-twist-runtime.md` §2, §5, §7 | Rule JSON, `requires` tags, hooks, `RuleApi` |
| `docs/architecture/adr-0011-mechanic-level-event-runtime.md` §2, §3 | `item_buff` rank 2 for skills; S4b / S4c for Perfect Fill |
| `docs/architecture/adr-0009-local-multiplayer.md` | Riders as attacks, host timing |
| `docs/architecture/adr-0012-input-pipeline.md` | `use_skill` |
| `docs/architecture/adr-0013-save-profile-settings.md` | `inventory.skills` (tokens) |
| `design/gdd/buffs-debuffs.md` Core Rules 1–7, F2 | Reused effects, Bomb blast |
| `design/gdd/items.md` Core Rules 7–10 | Targeting, queued use, refund-once |
| `design/gdd/scoring-stars.md` Core Rule 6, F1 | Combo count; star times assume no skill |
| `design/gdd/characters-perks.md` | Character slots C1–C4, charge perks |
| scratchpad `atoms-party.md` (WO12, IN32, IN33, EV23, WO13) | Skill-hook atoms |

## Acceptance Criteria

1. [U] F1: solo double clear at combo step 2 → `Δq = 0.28`; last of 4 → 0.42; `q` never exceeds 1.
2. [U] **GIVEN** a skill Active, **THEN** clears add no charge and the button is disabled.
3. [U] **GIVEN** each context in rule 7 with no overrides, **THEN** the resolved `skill_rule` matches the table; a level `skill_rule` overrides the skill's own entry, which overrides the table.
4. [U] **GIVEN** `once` with `once_ready_delay_s = 15`, **THEN** the button is Ready at 15 s of play and Spent after one use.
5. [U] **GIVEN** a skill whose self effect has no effect, **THEN** the meter / use / token is kept and `skill_no_effect` fires.
6. [U] **GIVEN** solo play, **THEN** no rider is sent and the self effect applies.
7. [U] **GIVEN** Perfect Fill with layers at 0.75, 0.65 and 0.5 full, **THEN** the first two are filled and cleared in S4c, the third is untouched.
8. [U] **GIVEN** Pick & Mix with fixed seeds, **THEN** the spawn sequence after the 3 picks equals the sequence without the skill.
9. [U] **GIVEN** Mega Bomb, **THEN** the blast covers 125 cells (clipped to the board), rocks take 3 damage, pillars are immune.
10. [U] **GIVEN** IN32 and two rider skills targeting each other 500 ms apart (host time), **THEN** both fizzle; `charge` users have `q = 0.5`; a `once` user gets the use back once.
11. [U] **GIVEN** EV23, **THEN** each player gets one free use for 6 s and their meter / once-use is unchanged.
12. [U] **GIVEN** WO13, **THEN** skills move one seat, meters stay, Active rules finish.
13. [M] F2: in campaign playtests, median skill uses per level are 1–2.
14. [M] F3: bot or playtest measurement gives every `dev_c ≤ 0.2` before quick versus ships.

## Open Questions

- **New rule-adjustable knob**: `skill.charge_rate` must be added to the framework's closed list (Core Rule 4) with owner Skills — needs a Rule-Twist Framework edit (not done here).
- **Pick & Mix input**: three tap cards on the preview plate work on touch; gamepad / keyboard mapping (cycle + confirm) needs ADR-0012 / UX input.
- **Skill tokens**: are they ever sold or earned (Shop / Points), or is `consumable` only for special levels? Monetisation is undecided; no default context uses it.
- **Campaign 3★ ease**: star times assume no skill; if 1–2 uses per level make 3★ trivial, lower `k_layer` (F2) or set `once` on short levels.
- **Skill upgrades / mastery**: none in this design (one fixed skill per character). Revisit with Characters & Perks mastery.
- **Systems index**: Skills needs an entry in `design/gdd/systems-index.md` (not edited in this pass).
