# Cave Biome: Nugget's Light (levels 01–10, bonus, hard track)

> **Status**: Draft v1 for user review (level-designer, 2026-10-10)
> **Author**: Tessa + level-designer
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Format**: copies `design/levels/meadow.md` section for section. Biome number 7 in the main chain (after Forest, before Clockwork).
> **Sources**: `production/narrative/campaign-story/brief.md` (§3.7, §2.3, §5 Glim, §7), `lore-world.md` §3.7, `dialogue-campaign-skits.md` §7, `visual-direction.md` §1.6 and §3.2 Cave (wins over lore on light, per the coordinator), `design/gdd/mechanics-module.md` (atoms, F1), `design/gdd/campaign-structure.md`, `design/gdd/twist-library.md`, `design/gdd/level-specific-mechanics.md`, `design/gdd/level-goals-fail-states.md`, `design/gdd/scoring-stars.md`, `design/gdd/level-data-definition.md`.

**Every number, name and beat in this file is a tunable default**, a starting point for the prototype and playtests. The validator enforces only the safe ranges in the owning GDDs.

---

## 1. Level name and theme

**Nugget's Light.** Nugget the short-sighted mole lives in the rock core under the Forest's Great Tree. His headlamp is broken and flickers; he wants a gem big enough to fix it. Blocks fall as a soft **pebble drizzle** down a shaft from the forest floor. Geode, a huge rock golem, only wants to stay asleep, but Mizzle's parcel (a party lantern chain, lowered down the shaft by the mail-cloud) landed on his nose and switched on. Blinded awake, he stamps, shakes the ceiling and rattles the minecart rails to make it stop. In the finale the last clear cracks him open: out hatches a vain crystal bird that lights the whole cave, sees its dusty reflection and flaps off, offended. The new light shows a chalk blueprint on the wall, and **Glim the bat architect** drops down and joins. Keepsake: a gem (the one that fixes Nugget's headlamp).

**Quirk: "Lowest light."** The darkest biome of the campaign, but never black and never scary: lantern pools, glow-moss and soft crystals. Darkness only ever touches the backdrop and island body; the grid keeps a minimum lit level, and the falling piece, its ghost, the danger line and every telegraph are never faded (twist-library rule 8). The Cave's own ideas are **rock inside the board** (BL18), **echo twins** (PL10) and **a lantern circle** (a lit radius around your piece). Strangeness zig-zags, it does not ramp.

**Thread (Mizzle, strength 3), the softer low point.** Shadow puppets on the crystal wall in 05 show him playing with friends. In the 09 payoff the bats flap off and the wizard's group laughs at the bat gag; he thinks it is at him. His little crooked tower **leans, and he props it up with his wand**; he walks slowly off into a lantern glow, cuffs dangling, and leaves **a small lantern behind, still lit**. No collapse, no `tear`, no sleeve wipe (user ruling, staged as in `visual-direction.md` §3.2). Missing every clue still gives a clean, happy story.

### Biome rules (decisions)

| Rule | Default |
|---|---|
| Islands | Chambers inside the Great Tree's rock core, each a ledge or pocket the camera sees like an island (drip pool below as the "underside"): cave mouth (01), gem-pocket wall (02), minecart ledge (03), bat roost (04), stalagmite to the daylight crack (05), crystal chamber (06), twin-gem niche (07), pitch-dark gallery (08), echo hall (09), Geode's hollow (10); bonus in a treasure-map cavern |
| Stage | Calm by default; "busy" only where the disturbance needs it (04, 09, 10). Landmark in every backdrop: the **minecart rail loop** and Geode asleep in his alcove (snoring rock shape). The crystal wall behind the board is the shadow-puppet screen |
| Intro skit | A wordless 3-second mini-scene in which Nugget shows the problem, played during the Countdown (no play time lost) |
| Payoff skit | 5 s or less on every win, tap to skip; the finale is 6 s on first play (last 2 beats on replays), then the 4 s friend join |
| Mascot | **Nugget** (Cave only), WO09 watcher on every level (reactions only, no gameplay effect). No catches (`mascot_catches` 0; WO11 is Pip-only). Nugget squints, walks into walls, sneezes at dust; never pranks the board |
| Boss | **Geode** (never hurt: he is cracked into a crystal bird). Asleep in the backdrop from 01; the lantern chain blinks on him from 03; awake in 10 |
| Friends | **Lana** (Stitch) and **Boulder** (Smash) may be picked in solo play. **Glim joins at the 10 payoff**, so her **Redraw** (re-rolls the next few pieces and chalk-outlines perfect-fit spots) is first available in B and H1–H3. Redraw does nothing on fixed-list and kit-box levels (07, B). No level is tuned around a skill; star times are balanced for no perks and no skills. Stitch vetoes `stack`-tagged writes (03, 10 rail; 10, H2 stomp), a valid counter |
| Physics | None in the Cave |
| Rubber duck | Hangs upside-down in a row of bats under the ledge in 01 and 02 (SE05, visible from one low snap angle; tap to collect; no stars attached) |
| Cave events | Wind = **Bat Flap** (EV01); Spawned Objects = **Rockfall** (EV04 + SP19 skinned as a pebble); Conveyor = **Minecart Rail** (EV05); Invisible Blocks = **Lantern Circle** (EV02 with the `lantern_radius` variant, §1 rule notes); Quake = **Geode Stomp** (EV12); Pond mirror = **Echo Twin** (PL10); Carved cavern = **cave rock** (BL18) |
| Callbacks | Meadow's belt, gust, objects and fog; Forest's knock (as Geode's stomp). Only the Cave atoms are the *new* ideas |
| Dressing | Block set: Slate with crystal clusters (primary). Crystals amber, rose-quartz `#D8A8A8`, pale lilac-grey `#B8B0C8`; never cyan, saturated violet or magenta. Pieces get a lighter outline or thin rim light (dark-biome rule). UI frame: old mine timber, dark stained planks, iron brackets, two small **painted** crystal studs (not glowing) (art-director to confirm) |
| Prototype priority | **02, 06, 08, 10** (★PROTO): BL18 cave rock, PL10 echo twin, the lantern-circle variant, and the finale stack |

**Lighting (decision: `visual-direction.md` §3.2, which wins over `lore-world.md` §3.7 per the coordinator).** Five stages from the shared archetypes (visual-direction §5.3) plus a cave tint. Used as written in each level below.

| L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10 | B |
|---|---|---|---|---|---|---|---|---|---|---|
| entrance spill (D) | entrance spill (D) | lantern (H) | lantern (H) | lantern (H) | crystal glow (G) | crystal glow (G) | lantern circle (I) | lantern circle (I) | crystal-bird bloom (warm, brightest) | treasure-map lantern (H) |

Hard track: H1 lantern (H), H2 crystal glow (G), H3 lantern circle (I). In "lantern circle" the darkness touches only the backdrop and island body; the grid keeps a minimum lit level.

**Common defaults** (unless a level says otherwise): weighted bag, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, all rotation axes (Turn / Flip / Roll), `t_piece` 8 s. **Pieces**: "8 Std" = I, O, T, L, S, Tripod, Screw-Left, Screw-Right. **Speeds** are hand-set within ±0.05 of campaign F2 (`0.6 + 0.045 × (tier − 1) + 0.06 × (7 − 1)` = 0.960 at tier 1 up to 1.365 at tier 10); puzzle levels (07, B) are exempt and use a slow `g0` 0.60. **Star times** use Scoring & Stars F1 (`t2 = round5(0.85 × t_est)`, `t3 = round5(0.6 × t_est)`), with `t_est = N × A × 2.667 s` for Clear-N (`A` = active cells per layer). Levels with cave rock, echo twins, starter layers, puzzles and the bonus hand-set their times (stated in each level). Stars are for play with no perks and no skills.

**Budget (mechanics module F1).** At most 2 atoms new to the player and 4 non-default atoms per level; tiers 7–10 showpiece levels may use up to 6. "New" below means *not used in the Meadow, the Forest or an earlier Cave level* (Candy, Ice, Underwater and Lava atoms may already be known, which only lowers the counts; recount flagged in §10). Bundles count 1 (M1 = GO02 + CL14 + FT02, M2 = GO03 + CL14). Slot defaults: BL01, AR01, CV01, CL01, CO01, GO01, FT01. Secrets (SE05) and the mascot field (WO09) count 0.

**Grids**: one string per row, row 0 = `z = 0` (back), character 0 = `x = 0` (left). Mask `#` active, `.` off; rock grids `R` rock (inactive volume cell), `.` open; starting layers `#` starter block, `.` empty, `m` buried mole; targets `#` target cell. Side views are a slice at one `z` row seen from the front; `=====` is the danger line at `H_play`, `S` the spawn zone, `:` skips empty rows.

### Cave rule notes (owners named in §10)

| Rule | Definition (all values tunable) |
|---|---|
| **BL18 Cave rock** (Carved cavern, **Proposed**, Board slot) | A per-cell volume mask: `rock` cells are inactive cells at any layer (stalagmites from the floor, ledges in mid-air, arches). Rock is solid: pieces rest on it and cannot pass through it. A layer is full when its **active** cells are full; rock never clears and never moves (slice collapse moves only content). Validator: flood-fill reachability from the spawn for a monomino; rejects unreachable active cells; no rock cell at or above `H_play − 1` (a piece resting on it would lock over the danger line); spawn zone all active. Cells under a ledge are reached by sliding sideways during the fall or lock delay; the ghost shows it. Rock never shares a board with the conveyor (M4 rule 17, rectangle) or a flip |
| **PL10 Echo Twin** (Pond mirror, **Proposed**, layer `twist`) | On lock, a twin copy of the piece is written mirrored across the board's centre plane on `mirror_axis` (x or z), then drops rigidly until supported; twin cells that are taken are skipped. A second, paler ghost shows where the twin will land. Twin cubes at or above `H_play` are trimmed with a crystal chime, never a top-out. Staging: the crystal wall "echoes" the piece; a soft repeated click |
| **Lantern Circle** (EV02 `fog` + new param `lantern_radius`) | Twist-library T2 as written (`visible_ms`, `fade_ms`, `invisible_alpha`, `reveal_ms`), plus: every locked block within `lantern_radius` cells (Chebyshev distance on x/z, all heights) of the **falling piece's ghost footprint** is shown at full alpha while the piece is in play, as if lit by Nugget's headlamp. `lantern_radius` 0 = plain fog. View-side only (the ghost position is sim state, so replays agree); collision, fullness and the ghost are unchanged. The falling piece, ghost, danger line and telegraphs are never faded |
| **Bat Flap** (EV01 `gust`) | T1 as written. The board-edge arrow is a fan of bat wings; a squeak on the gust |
| **Rockfall** (EV04 `mushroom_popup` + SP19, skin `pebble`) | T4 as written: marked by a dust trickle from the ceiling one lock ahead, then a pebble cube plops onto the cell. Pebbles fill and clear like blocks |
| **Minecart Rail** (EV05 `conveyor`, mechanic) | M4 as written: unmasked rectangle, wrap on. The rails rattle one lock before; the stack rides the cart bed |
| **Geode Stomp** (EV12 Quake, **Candidate**) | Same rule as Forest's Woodpecker Knock (`forest.md` §1): every `knock_interval_ms` ± jitter, `knock_warn_ms` warning with dotted outlines on the overhang cubes about to pop, at most `knock_pop_max` per stomp, highest first, applied at the next Resolving. Staging: Geode raises both fists, dust drifts from his shoulders |

## 2. Estimated play time and summary

| # | id | Name | Story beat | New idea (atoms) | Nugget | Stage | Goal | Board | Pieces | g0 | Top-out | Length | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | cave_01 | Cave Mouth | Nugget's flickering lamp | none (classic) | watcher | clean, calm | Clear 3 | 5×5, H8 | 8 Std; first 2 from {O, I} | 0.95 | rescue, 2 | ~3.3 min | 170 / 120 s |
| 02 ★ | cave_02 | Gem Pockets | Gems under the lip | cave rock (BL18) | watcher | clean, calm | Clear 3 | 5×5, H10, stalagmite + lip | 8 Std; first 2 {O, I} | 1.00 | rescue, 1 | ~3 min | 155 / 110 s* |
| 03 | cave_03 | Minecart Ledge | The cart won't stop | Minecart Rail (EV05) | watcher | clean | Clear 4 | 8×3 lane, H10 | 8 Std | 1.05 | rescue, 1 | ~4.3 min | 220 / 155 s |
| 04 | cave_04 | Bat Roost | Bats in a flap | Bat Flap (EV01 rotating) + Rockfall (EV04) | watcher | busy | Clear 4 | 6×6, H10 | 8 Std | 1.10 | rescue, 1 | ~6.4 min | 325 / 230 s |
| 05 | cave_05 | Stalagmite Climb | Up to the daylight crack | build race (M1) round a stalagmite (BL18) | watcher | clean, tense | Height 10 (cov. 0.6) | 5×5, H12, stalagmite | 8 Std | 1.15 | trim | ~4 min | 230 / 160 s* |
| 06 ★ | cave_06 | Crystal Chamber | The wall copies you | Echo Twin (PL10, x) | watcher | clean, hushed | Clear 4 | 6×6, H10 | 8 Std | 1.20 | rescue, 1 | ~3.8 min | 195 / 140 s* |
| 07 | cave_07 | Twin Gems (puzzle) | Fill the gem niche | fixed list (AR09) + echo, fill shape (M2), budget (FT07) | watcher | clean, calm | Shape 24 | 4×4, H6 | fixed: L L O | 0.60 | out of pieces | ~1 min | 60 / 40 s* |
| 08 ★ | cave_08 | Pitch-Dark Gallery | Lamp out | Lantern Circle (EV02 + `lantern_radius`) | watcher | clean, tense | Clear 4 | 5×5, H10 | 8 Std | 1.25 | rescue, 1 | ~4.4 min | 225 / 160 s |
| 09 | cave_09 | Echo Hall | Echoes in the dark | Echo Twin (z) + Lantern Circle | watcher | busy | Clear 6 | 6×6, H10 | 8 Std | 1.30 | rescue, 1 | ~5.8 min | 295 / 205 s* |
| 10 ★ | cave_10 | Geode's Hollow | Boss: Geode | Minecart Rail + Stomp (EV12) + Lantern Chain (EV02) | boss | busiest | Clear 3 | 8×6, H12 | I O T L Tripod Screws Chair | 1.35 | rescue, 1 | ~6.4 min | 325 / 230 s |
| B | cave_bonus | Treasure Map | Dig for the X | kit box (AR13) + echo, fill shape (M2), budget (FT07) | watcher | clean, silly | Shape 32 | 4×4, H6 | kit: O I O I T S | 0.60 | out of pieces | ~1.5 min | 70 / 45 s* |
| H1 | cave_h1 | Runaway Cart | The cart speeds up | Minecart Rail (every 2) + Bat Flap | watcher | busy | Clear 5 | 7×5, H10 | 8 Std | 1.30 | rescue, 1 | ~7.8 min | 395 / 280 s |
| H2 | cave_h2 | Cave-In | Geode rolls over | cave rock (BL18) + Stomp + Rockfall | watcher | busy, tense | Clear 4 | 6×6, H10, 2 stalagmites | 8 Std | 1.30 | rescue, 1 | ~6 min | 300 / 210 s* |
| H3 | cave_h3 | Mole Rescue | The crew is stuck | dig to rescue (GO21) + Lantern Circle | watcher | clean, dark | Free 3 moles | 6×6, H10 + 3 starter layers | 8 Std | 1.25 | rescue, 1 | ~3.5 min | 170 / 120 s* |

★ = prototype priority. \* hand-set star times: cave rock changes `A` per layer (02, 05, H2), echo twins write about 1.7 cubes per placed cube (06, 09: `t_est ≈ 0.6 × F1`), starter layers (H3), and the puzzle and bonus against their piece lists (07, B; also ★★★ requires no cube trimmed in 05). Length notes: 01, 02, 06, 07, 08, B and H3 are short on purpose; the validator's 5–15 min length warning is expected on those.

**F1 budget table** (nd = non-default atoms, new = new to the player; "met" = Meadow, Forest or earlier Cave):

| Level | Non-default atoms | nd | new |
|---|---|---|---|
| 01 | none | 0 | 0 |
| 02 | BL18 | 1 | 1 (BL18) |
| 03 | EV05 | 1 | 0 (Meadow 10, Forest 09) |
| 04 | EV01, EV04, SP19 | 3 | 0 |
| 05 | M1 bundle, BL18 | 2 | 0 |
| 06 | PL10 | 1 | 1 (PL10) |
| 07 | AR09, M2 bundle, FT07, PL10 | 4 | 0 (AR09, FT07 met in Forest 06) |
| 08 | EV02 (+ `lantern_radius`) | 1 | 1 (counted as new: the variant changes how fog is read) |
| 09 | PL10, EV02 | 2 | 0 |
| 10 | EV05, EV12, EV02 | 3 (cap 6) | 0 (EV12 met in Forest 08) |
| B | AR13, M2 bundle, FT07, PL10 | 4 | ≤ 1 (AR13 if the Forest bonus was skipped) |
| H1 | EV05, EV01 | 2 | 0 |
| H2 | BL18, EV12, EV04, SP19 | 4 | 0 |
| H3 | BL05, GO21, EV02 | 3 | 1 (GO21) |

Twists per level never exceed 2 (10 runs 2 twists plus the Minecart Rail mechanic; the finale's third-twist allowance is unused). Puzzle levels: 07 on the main path (fixed list) and the bonus (kit box), within campaign rule 15 (1–2).

**Hard track (decision).** `cave_bonus` is tier 11 (unlocks at 20 cave stars). The remixes are **tiers 12–14** (`cave_h1`–`h3`); all three open when `cave_10` is finished. Neither the bonus nor the remixes count toward the next biome's star gate. Stars still pay points as usual.

## 3. Layout overview

```text
01 cave mouth  02 gem pockets   03 minecart ledge   04 bat roost   05 stalagmite (12 tall)
#####          RR###  lip y2    ########            ######         #####
#####          #####            ########            ######         #####
#####          ##R##  stalag.   ########            ######         ##R##  rock y0–6
#####          #####            (rail → +x)         ######         #####
#####          #####                                ######         #####
                                                    ######
06 crystal     07 twin niche   08 dark gallery   09 echo hall     10 Geode's hollow (rail →)
######  mirror ####  mirror    #####             ######  mirror   ########
######   |x    ####   |x       #####             ######   — z     ########
######         ####            #####             ######           ########
######         ####            #####             ######           ########
######         (6 tall)        #####             ######           ########
######                                           ######           ########
```

## 4. Critical path and optional paths

- **Critical path**: 01 → 10 in order (linear inside a biome). Finishing 10 completes the Cave, unlocks Glim, and opens Clockwork with 15 of 30 cave stars. **Boo Hollow** (side island) opens after the Cave.
- **Optional**: ★★★ times on every level; the rubber duck in 01–02; the bonus Treasure Map (20 stars; earns Postcard 7 in the Scrapbook); hard-track remixes H1–H3 (after 10; the first levels where Redraw can be used in the Cave).

## 5. Pacing chart

```text
strangeness (how far from classic)
 high |                                #   #
      |                       #     #  #   #
  mid |           #  #        #     #  #   #   #
      |        #  #  #  #     #  #  #  #   #   #
  low |  #  #  #  #  #  #  #  #  #  #  #   #   #
      +-01-02-03-04-05-06-07-08-09-10--B
        learn  rail bats climb echo puz dark echo+dark FINALE
```

Zig-zag, not a ramp: two teaching levels (01 classic in the dark look, 02 rock in the board) → a known mechanic in the new look (03 rail) → the busy bat level (04, a pressure peak) → a no-fail climb (05) → the echo (06, short) → a one-minute puzzle (07) → the dark (08) → echo in the dark (09, the hardest) → the three-rule boss. Short and long alternate (campaign rule 12): short (01, 02), mid (03), long (04), mid (05), short (06, 07, 08), long (09), long finale. Pressure peaks 04, 09 and 10 are separated by calm levels. Energy is the **lowest** of the campaign (brief §7): hushed stages, slow ambient motion, warm lantern pools; the story dips at 09 and lifts with light at 10.

---

## 6. Level specs (encounter lists, sketches, beats)

### 01 Cave Mouth

**Story card.** Nugget's headlamp flickers at the cave mouth. Every clear lights a glow-worm on the ceiling; three and the path in is lit. · **Nugget: watcher** (no gameplay help).
**Stage**: clean, calm; the cave mouth under the Great Tree's roots, daylight behind, bats hanging under the ledge. **Light**: entrance spill (D). **Intro skit** (3 s): Nugget taps its flickering headlamp, walks into a stalagmite, rubs its nose (`question`), then looks up at the wizard: glint, first piece. **Payoff skit** (4 s): three glow-worms twinkle on; Nugget beams, takes one step into the cave and bonks a wall anyway (`dizzy`). **Mizzle clue**: none (slots 01–02 carry none). **Reactions (R)**: clear `sparkle`; warning `sweat`.

```text
Recipe: BL01 (5×5, H8) · AR01 · CV01 · GO01 (3) · FT01 (2 warnings) · CL01 + CO01 · SE05 duck · WO09
One sentence: "Fill a whole layer and it clears."
Atoms used: all defaults. New to the player: nothing; tier 1 re-teaches the controls in the dark look.
```
**Encounters**: none (pure classic). Pieces 8 Std; `opening_set` [O, I], count 2. `T_level` 200.

```text
top-down 5×5      side (z = 2)
#####             11 . . S . .   spawn zone
#####              8 ==========  danger line
##S##              :
#####              0 . . . . .   the cave-mouth floor
#####
```
**How it plays**: (1) an O drifts down through the daylight spill. (2) The first layer clears in about 6 pieces: a glow-worm lights, a soft drip chime. (3) Screws and Tripods arrive; the player re-finds all three rotation pairs. (4) The third clear lights the path.
**Teaches**: the controls and the rule in the new, darker look; that pieces keep a light rim against the dark backdrop.
**Readability**: the grid sits in the daylight spill; piece outlines lighter than the backdrop; the danger line is a lantern-lit rope.
**Wacky test**: surprising, a mole that cannot see the board; silly, Nugget bonking walls; funny failure, Nugget's lamp goes out on a warning and it pats the air; big moment, the third glow-worm lighting the path.

```json
{ "schema": 1, "id": "cave_01", "biome": "cave", "tier": 1,
  "board": { "width": 5, "depth": 5, "h_play": 8 },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_l","screw_r"], "opening_set": ["o","i"], "opening_count": 2 },
  "knobs": { "fall.g0": 0.95, "goal.warnings_max": 2, "goal.top_out": "rescue" },
  "goal": { "type": "clear_n", "N": 3, "T_level": 200 },
  "rules": [ { "id": "wo09_watcher", "params": {} } ],
  "secrets": [ { "id": "SE05", "params": { "prop": "rubber_duck_bats", "view_snap": "low_3" } } ],
  "stars": { "t2": 170000, "t3": 120000 },
  "music": "cave_01_tbd", "story": { "mascot_role": "watcher", "icon": "headlamp" } }
```

---

### 02 Gem Pockets ★PROTO

**Story card.** Two gems glint in pockets under a rock lip. Slide pieces in under the lip to fill them, and build round the little stalagmite. Rock is part of the board: it never clears and never moves. · **Nugget: watcher** (reaches for the gems, too short).
**Stage**: clean, calm; a gem-pocket wall at the back, a stalagmite in the middle of the floor. **Light**: entrance spill (D). **Intro skit** (3 s): Nugget spots two glints under a lip, reaches, can't; it squints at the stalagmite and bonks it (`question`). **Payoff skit** (4 s): the gems pop out of the cleared pockets into Nugget's paws; it holds one to its headlamp, too small, and pockets it anyway (`sparkle`). **Mizzle clue**: none. **Reactions (R)**: piece slid under the lip `sparkle`; clear `idea`.

```text
Recipe: BL18 cave rock (5×5, H10; stalagmite (2,2) y0–1; lip (0,0)(1,0) at y2) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · SE05 duck · WO09
One sentence: "Rock is part of the board: slide under it, build round it."
Atoms used: BL18 (Proposed). New to the player: BL18 (1).
```
**Encounters**: the **stalagmite** (2 rock cells) sits in the centre of layers 0–1, so those layers need 23 cubes each; the **lip** (2 rock cells at layer 2 over x 0–1, z 0) covers the two back-left pockets of layers 0–1. A piece falling straight down there lands on the lip (fine, it counts for layer 3); to fill the pockets the player moves the piece in sideways under the lip during the fall or lock delay, and the ghost shows the tuck. Layer 2 has 23 active cells (the lip). Three clears = layers 0, 1, 2 (or later ones). Pieces 8 Std; `opening_set` [O, I], count 2. Stars hand-set: `A` ≈ 23 → `t_est` ≈ 184 s.

```text
rock layer 0–1   rock layer 2    side (z = 0)
.....            RR...           10 ==========  danger line
.....            .....            :
..R..            .....            2 R R . . .   the lip
.....            .....            1 . . . . .   pockets under the lip
.....            .....            0 . . . . .
```
**How it plays**: (1) an O falls; the ghost shows it landing on the lip, then, as the player moves it forward and back under, the tuck. (2) The I lies along z = 0 under the lip and fills a pocket row. (3) Layers 0 and 1 clear round the stalagmite (it stays; the stack drops round it). (4) Layer 2 clears with the lip in it.
**Teaches**: the BL18 rule (rock is solid, part of the board, never clears) and the sideways tuck, which the Cave reuses in 05 and H2.
**Readability**: rock is matte stone with a darker edge, never cube-glossy (it must not read as a piece); pocket cells glint with a gem decal until filled; the ghost always draws the tuck path.
**Wacky test**: surprising, the floor has a rock in it; silly, Nugget's arm too short; funny failure, a piece parked on top of the lip and Nugget taps it like a hat; big moment, the gems popping out.

```json
{ "schema": 1, "id": "cave_02", "biome": "cave", "tier": 2,
  "board": { "width": 5, "depth": 5, "h_play": 10,
             "rock": { "layers": { "0": [".....",".....","..R..",".....","....."],
                                   "1": [".....",".....","..R..",".....","....."],
                                   "2": ["RR...",".....",".....",".....","....."] } },
             "spawn_anchor": { "x": 3, "z": 3 } },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_l","screw_r"], "opening_set": ["o","i"], "opening_count": 2 },
  "knobs": { "fall.g0": 1.00, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 3 },
  "rules": [ { "id": "wo09_watcher", "params": {} } ],
  "secrets": [ { "id": "SE05", "params": { "prop": "rubber_duck_bats", "view_snap": "low_3" } } ],
  "stars": { "t2": 155000, "t3": 110000 },
  "recipe": { "atoms": ["BL18","AR01","CV01","CL01","CO01","GO01","FT01","SE05","WO09"] },
  "music": "cave_02_tbd" }
```

---

### 03 Minecart Ledge

**Story card.** Nugget's minecart has a mind of its own: every few pieces the whole cart bed rolls one cell along the rail and round the loop. Drop where the gap *will be*. · **Nugget: watcher** (rides the cart, holding on).
**Stage**: clean; a rail ledge, the bouncing minecart, the rail loop in the backdrop. **Light**: lantern (H). **Intro skit** (3 s): Nugget loads a pebble into the cart; the cart bounces off on its own; Nugget runs after it (`exclaim`), then looks up: glint. **Payoff skit** (4 s): the cart stops neatly at a buffer; Nugget climbs in proudly; it rolls off again with Nugget in it (`dizzy`). **Mizzle clue (M, 1.5 s, rim)**: on the crystal wall, a second, droopier shadow walks behind Nugget's shadow, then stops (no emote). **Reactions (R)**: rail wind-up `exclaim`; clear `sparkle`.

```text
Recipe: BL01 (8 wide × 3 deep, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV05 Minecart Rail [mechanic] · WO09
One sentence: "The cart moves your stack: drop where the gap will be."
Atoms used: EV05 (Designed). New to the player: nothing (Meadow 10, Forest 09).
```
**Encounters**: **Minecart Rail** (conveyor): +x, every 3 locks, wrap on (unmasked rectangle). The rails rattle and the cart's front bumper lifts on the lock before each shift (`belt_windup`). Pieces 8 Std. Stars: `A` 24 → `t_est` 256 s.

```text
top-down 8×3 (rail → along x)   side (z = 1)
→ → → → → → → →                 13 . . . S S . . .   spawn zone
########                        10 ================  danger line
###S####                         :
########                         0 # # . # # . # #   → shift +x, wrap
```
**How it plays**: (1) three calm locks, then the rattle and the first shift. (2) A gap at x = 7 wraps to x = 0. (3) On the narrow lane the player learns to aim one cell "behind" the gap. (4) Four clears; the cart stops at the buffer.
**Teaches**: re-teaches the belt (some players skipped the Forest's hard levels) on a short lane where the wrap is easy to see.
**Readability**: the rail and the wind-up are on the board edge (world-anchored); the ghost of the next piece already accounts for the shifted stack (M4 rule 16).
**Wacky test**: surprising, the floor rolls; silly, a cart with no driver; funny failure, the cart rolls a gap away just as the piece lands and Nugget shrugs; big moment, the cart braking at the buffer.

```json
{ "schema": 1, "id": "cave_03", "biome": "cave", "tier": 3,
  "board": { "width": 8, "depth": 3, "h_play": 10, "spawn_anchor": { "x": 3, "z": 1 } },
  "knobs": { "fall.g0": 1.05, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "conveyor", "params": { "dir": "+x", "conveyor_every": 3, "conveyor_wrap": true, "skin": "minecart" } } ],
  "stars": { "t2": 220000, "t3": 155000 },
  "music": "cave_03_tbd" }
```

---

### 04 Bat Roost

**Story card.** The bat colony is in a flap. Their wings shove your piece from any side (read the wing arrow), and each flap knocks pebbles loose from the ceiling that plop onto your stack. · **Nugget: watcher** (ducks every flap).
**Stage**: busy; a roost with rows of hanging bats, a dust-trickle ceiling. **Light**: lantern (H). **Intro skit** (3 s): Nugget sneezes at the dust; the whole roost flaps up in a cloud (`exclaim`); a pebble bonks Nugget's lamp; glint. **Payoff skit** (4 s): the bats settle back in a neat row; Nugget hangs upside-down beside them to fit in, and falls off (`dizzy`). **Mizzle clue (M, 1.5 s)**: at the rim, Mizzle hangs a spare lantern on a hook, then hides it behind his back (`sweat`). **Reactions (R)**: flap warning `exclaim`; pebble lands `question`; clear `sparkle`.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV01 Bat Flap (rotating) · EV04 Rockfall + SP19 (pebble) · WO09
One sentence: "Bats shove your piece; pebbles drop on your stack."
Atoms used: EV01, EV04, SP19 (all Designed). New to the player: nothing; the two known twists meet for the first time.
```
**Encounters**: **Bat Flap**: `wind_mode` rotating (one of four ground axes per flap, drawn with the gap so the arrow shows it), 9 000 ± 2 500 ms, strength 1, warning 1 000 ms. **Rockfall**: every 6 locks, max 3, marked by a dust trickle one lock ahead, `place_mode` random. Never on the same beat: a flap only hits a falling piece, the pebble lands in Resolving. Pieces 8 Std. Stars: `A` 36 → `t_est` 384 s.

```text
top-down 6×6 (flap direction rotates)   side (z = 2)
######     ↑                            13 . . . S . .   spawn zone
######                                  10 =============  danger line
##S###     ← →  one of four             :
######                                   1 # p . # # .   p = pebble
######                                   0 # # . # # #
######
```
**How it plays**: (1) a calm first piece; the bats stir. (2) The first flap shoves the piece one cell; the player reads the wing arrow. (3) A dust trickle marks a cell; a pebble fills it for free, or blocks a gap the player wanted. (4) Four clears; the colony settles.
**Teaches**: reading two different telegraphs on one board (wings on the edge, dust on a cell); the biome's first pressure peak.
**Readability**: the wing arrow is world-anchored; pebbles are warm grey, outlined, never a piece hue; the dust trickle is the same "one lock ahead" beat as the Meadow mushroom.
**Wacky test**: surprising, a roof that rains rocks; silly, Nugget hanging with the bats; funny failure, a flap shoves a piece onto a fresh pebble and the bats squeak; big moment, the whole colony lifting in a cloud.

```json
{ "schema": 1, "id": "cave_04", "biome": "cave", "tier": 4,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 1.10, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "gust", "params": { "wind_mode": "rotating", "wind_interval_ms": 9000, "wind_jitter_ms": 2500, "wind_strength": 1, "wind_warn_ms": 1000, "skin": "bat_flap" } },
             { "id": "mushroom_popup", "params": { "spawn_every_locks": 6, "objects_max": 3, "skin": "pebble" } } ],
  "stars": { "t2": 325000, "t3": 230000 },
  "music": "cave_04_tbd" }
```

---

### 05 Stalagmite Climb

**Story card.** A thin crack of daylight high above: Nugget wants a peek. Stack round the big stalagmite up to the rope sign; nothing clears, too high pops off, and you cannot lose. · **Nugget: watcher** (climbs as the tower grows).
**Stage**: clean, tense; a tall stalagmite, a pin of daylight at the top. **Light**: lantern (H), with the daylight crack as the far landmark. **Intro skit** (3 s): Nugget squints up at the crack, jumps, bonks the stalagmite, points up (`idea`). **Payoff skit** (4 s): Nugget reaches the top and pokes its snout into the daylight; it sneezes and slides all the way down (`dizzy`). **Mizzle clue (M, 1.5 s) ★ Shadow puppets**: crystal light on the far wall casts a small hooked-hat figure among little friend shapes, playing; the figure makes a clumsy bow (`dots`). Backdrop only, never over the grid, never during a warning. **Reactions (R)**: layer 5 `sparkle`; trimmed cubes `sweat`.

```text
Recipe: BL18 cave rock (5×5, H12; stalagmite (2,2) y0–6) · AR01 · CV01 · M1 build race (GO02 height 10, coverage 0.6 + CL14 + FT02 trim) · CO01 · WO09
One sentence: "Build up to the sign; nothing clears."
Atoms used: BL18 (Proposed, met in 02), M1. New to the player: nothing.
```
**Encounters**: no twists. The **stalagmite** fills the centre column from layer 0 to 6 (7 rock cells), so the lower tower is a ring of 24 cells and climbs faster; from layer 7 up the board is the full 25. Coverage at layer 10: 15 of 25 cells. Trim: cubes at or above layer 12 pop off; the level never fails. The rock's top (layer 7) is a free ledge to build on. Pieces 8 Std. Stars hand-set (Meadow 05 at 5×5 was 240 / 170 s; the rock saves about 7 cubes): ★★ 230 s, ★★★ 160 s and no cube trimmed.

```text
top-down 5×5   side (z = 2)
#####          15 . . S . .   spawn zone
#####          12 ===========  danger line (trim)
##R##          10 - - - - -   sign: layer 10 ≥ 60% full (15 of 25)
#####           6 . . R . .   stalagmite top at layer 6
#####           0 . . R . .
```
**How it plays**: (1) the ring fills round the stalagmite; full layers glow and stay. (2) At layer 7 the stalagmite's tip becomes a ledge. (3) The tower narrows to the sign; overhangs are fine (no wobble). (4) Layer 10 reaches 15 cubes; Nugget scrambles up.
**Teaches**: a no-fail breather that reuses cave rock as a helper, not an obstacle.
**Readability**: the sign is a rope with a lantern; the trim line is a row of stalactite tips; no danger music.
**Wacky test**: surprising, the rock helps you; silly, Nugget's sneeze slide; funny failure, cubes hop off the top and the bats catch one; big moment, the snout in the daylight.

```json
{ "schema": 1, "id": "cave_05", "biome": "cave", "tier": 5,
  "board": { "width": 5, "depth": 5, "h_play": 12,
             "rock": { "columns": [ { "x": 2, "z": 2, "y_from": 0, "y_to": 6 } ] },
             "spawn_anchor": { "x": 1, "z": 1 } },
  "knobs": { "fall.g0": 1.15, "goal.top_out": "trim" },
  "goal": { "type": "height", "H_target": 10, "height_coverage": 0.6 },
  "rules": [ { "id": "build_race", "params": {} } ],
  "stars": { "t2": 230000, "t3": 160000 },
  "music": "cave_05_tbd" }
```

---

### 06 Crystal Chamber ★PROTO

**Story card.** The crystal wall copies everything: each piece you lock gets a mirror twin on the other side of the chamber. Two for one, if you keep it tidy. · **Nugget: watcher** (waves at its own reflection).
**Stage**: clean, hushed; a crystal chamber with a faceted wall down the middle line of the board. **Light**: crystal glow (G). **Intro skit** (3 s): Nugget waves at the crystal; its reflection waves back a beat late; Nugget squints closer and bonks the crystal (`question`); glint. **Payoff skit** (4 s): the twin stacks clear together; Nugget and its reflection high-five through the crystal, and both bonk (`sparkle`). **Mizzle clue (M, 1.5 s)**: by his lantern at the rim, Mizzle builds a small crooked tower of crystal chips (`idea`). **Reactions (R)**: twin lands `sparkle`; twin skipped `question`; clear `note`.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · PL10 Echo Twin (mirror_axis x) · WO09
One sentence: "Every piece gets a mirror twin across the crystal."
Atoms used: PL10 (Proposed). New to the player: PL10 (1).
```
**Encounters**: **Echo Twin**, `mirror_axis` x (the plane between x = 2 and x = 3). On lock the twin is written mirrored (x → 5 − x), then drops rigidly until supported; taken cells are skipped. A pale second ghost shows the twin's landing. A piece placed across the centre mirrors onto itself, so most of its twin is skipped (wasted): the lesson. Twin cubes at or above `H_play` are trimmed with a chime. Pieces 8 Std. Stars hand-set: about 1.7 cubes per placed cube → `t_est ≈ 0.6 × 384 = 230 s`.

```text
top-down 6×6 (mirror | between x2 and x3)   side (z = 2)
###|###                                    13 . . S | . . .   spawn zone
###|###                                    10 =====|=======  danger line
#S#|###                                     :
###|###                                     1 # . # | # . #   twin mirrors the left
###|###                                     0 # # . | . # #
###|###
```
**How it plays**: (1) a piece locks on the left; its twin pops onto the right with a crystal click. (2) A layer fills in half the pieces when both halves stay symmetric. (3) A piece dropped across the middle has no room for its twin: a "nope" chime, cubes skipped. (4) Four clears; the wall rings.
**Teaches**: the echo rule on an otherwise classic board, and the second ghost.
**Readability**: the mirror plane is a faint crystal line on the floor (world-anchored); the twin ghost is paler and dotted so it never reads as the main ghost; skipped twin cells flash once.
**Wacky test**: surprising, two pieces for one; silly, the reflection waving late; funny failure, a twin lands on top of your own hole; big moment, two halves clearing at once.

```json
{ "schema": 1, "id": "cave_06", "biome": "cave", "tier": 6,
  "board": { "width": 6, "depth": 6, "h_play": 10, "spawn_anchor": { "x": 1, "z": 2 } },
  "knobs": { "fall.g0": 1.20, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "pond_mirror", "params": { "mirror_axis": "x", "skin": "crystal_echo" } } ],
  "stars": { "t2": 195000, "t3": 140000 },
  "music": "cave_06_tbd" }
```

---

### 07 Twin Gems (puzzle)

**Story card.** A niche in the crystal wall has a gem-shaped hole. Three pieces, no spares, and every piece gets its twin: fill the glowing gem. · **Nugget: watcher** (holds its headlamp up to the niche).
**Stage**: clean, calm; a small crystal niche, the gem outline glowing. **Light**: crystal glow (G). **Intro skit** (3 s): Nugget holds up a pebble to the gem-shaped hole; it is much too small; it looks at the wizard (`question`); glint. **Payoff skit** (4 s): the gem shape lights up and pops out as a big gem; Nugget hugs it, it is too heavy, they both tip over (`sparkle`). **Mizzle clue (M, 1.5 s)**: a bat flaps past his crystal-chip tower; he steadies it with both hands (`sweat`). **Reactions (R)**: good fit `sparkle`; wrong lock `sweat`.

```text
Recipe: BL01 (4×4, H6) · AR09 fixed list [L, L, O] · CV01 · M2 fill shape (GO03 24 cells + CL14) · FT07 piece budget (3) · PL10 Echo Twin (x) · WO09
One sentence: "Three pieces and their twins: fill the gem."
Atoms used: AR09, M2, FT07 (Designed), PL10 (Proposed, met in 06). New to the player: nothing. Retry is free and instant.
```
**Encounters**: none. Preview 3. Target: layer 0 full (16 cells), layer 1 the gem bar z 1–2 across all x (8 cells) = 24 cells. Mirror on x: the left half (x 0–1) is 12 cells = 3 pieces; the twins fill the right half. **Known solution** (for the validator's `solution` list): L on layer 0 at (x0, z0–2) + (x1, z0); the second L, turned 180° (Turn), at (x1, z1–3) + (x0, z3); O on layer 1 at (x0–1, z1–2). Dealt in list order, every placement is supported; every twin is supported. A piece placed across the middle wastes its twin and loses the puzzle. Glim's Redraw cannot change a fixed list. Stars: ★★ 60 s, ★★★ 40 s (no timer on screen).

```text
target layer 0 (16)   layer 1 (8)   side (z = 1)
##|##                 ..|..          6 ======   danger line
##|##                 ##|##          :
##|##                 ##|##          1 # # | # #   gem bar
##|##                 ..|..          0 # # | # #   base
```
**How it plays**: (1) read the list (L, L, O) and the glowing gem. (2) The first L goes in the back-left; its twin fills the back-right. (3) The second L needs a half turn to close the left base. (4) The O caps the gem bar; the twin finishes it.
**Teaches**: echo as a planning tool: think in halves. The main-path puzzle level of the Cave (campaign rule 15).
**Readability**: target cells are faint crystal facets; filled cells go solid; both ghosts show at once.
**Wacky test**: surprising, three pieces fill a six-piece shape; silly, Nugget toppled by the gem; funny failure, a twin lands on the wrong layer and the gem goes dim; big moment, the gem popping out.

```json
{ "schema": 1, "id": "cave_07", "biome": "cave", "tier": 7,
  "board": { "width": 4, "depth": 4, "h_play": 6 },
  "pieces": { "fixed_list": ["l","l","o"] },
  "knobs": { "fall.g0": 0.60, "spawn.preview_count": 3, "goal.top_out": "out_of_pieces" },
  "goal": { "type": "shape", "piece_budget": 3,
            "target_shape": { "layers": { "0": ["####","####","####","####"], "1": ["....","####","####","...."] } } },
  "rules": [ { "id": "pond_mirror", "params": { "mirror_axis": "x" } } ],
  "solution": [ { "shape": "l", "cells": [[0,0,0],[0,0,1],[0,0,2],[1,0,0]] },
                { "shape": "l", "cells": [[1,0,1],[1,0,2],[1,0,3],[0,0,3]] },
                { "shape": "o", "cells": [[0,1,1],[1,1,1],[0,1,2],[1,1,2]] } ],
  "stars": { "t2": 60000, "t3": 40000 },
  "music": "cave_07_tbd" }
```
(`solution` cells are `[x, y, z]`.)

---

### 08 Pitch-Dark Gallery ★PROTO

**Story card.** Nugget's headlamp is the only light in the gallery. Your stack fades into the dark, but the cubes near your falling piece stay lit, like a lamp held over it. Clears flash the whole gallery bright for a moment. · **Nugget: watcher** (follows the piece with its lamp).
**Stage**: clean, tense; a long dark gallery, glow-worms only. **Light**: lantern circle (I) (darkness in the backdrop and island body only). **Intro skit** (3 s): Nugget's lamp gives a last flicker and goes out; two eyes blink in the dark; then the lamp sputters back on, dim (`sweat`); glint. **Payoff skit** (4 s): the last clear flashes the gallery bright; it is full of moles in headlamps who were there all along; they all wave (`exclaim`). **Mizzle clue (M, 1.5 s)**: in a lantern pool at the rim, Mizzle adds a crooked top block to his crystal-chip tower and admires it (`dots`). **Reactions (R)**: clear `sparkle`; warning `sweat`.

```text
Recipe: BL01 (5×5, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV02 Lantern Circle (lantern_radius 1) · WO09
One sentence: "Only the cubes near your piece stay lit."
Atoms used: EV02 (Designed) with the new `lantern_radius` param. New to the player: the lantern variant (1).
```
**Encounters**: **Lantern Circle**: `visible_ms` 3 000, `fade_ms` 800, `invisible_alpha` 0.12, `reveal_ms` 600, `lantern_radius` 1 (every locked cube within one cell of the ghost footprint, on x and z, at any height, is shown at full alpha while the piece is in play). So the player always sees the landing neighbourhood and must remember the rest. Pieces 8 Std. Stars: `A` 25 → `t_est` 267 s.

```text
top-down 5×5 (lit ring round the ghost)   side (z = 2)
.....                                    13 . . S . .   spawn zone
.lll.                                    10 ==========  danger line
.lGl.     G = ghost footprint             :
.lll.     l = lit cubes (radius 1)        1 ~ # # # ~   ~ = faded, # = lit near the ghost
.....                                     0 ~ ~ # ~ ~
```
**How it plays**: (1) the first locks fade after 3 s. (2) Moving the piece sweeps the lamp across the stack, showing holes as it passes. (3) The player learns to "scan" with the piece before dropping. (4) Each clear flashes the gallery; four clears and the moles wave.
**Teaches**: the lantern rule: aiming with light, not memory alone. It prepares 09 and the finale.
**Readability**: falling piece, ghost, danger line and telegraphs never fade; the lit ring has a warm lamp edge; faded cubes keep a faint outline.
**Wacky test**: surprising, your own stack disappears; silly, a gallery full of moles; funny failure, a piece lands on a cube you forgot and Nugget squints; big moment, the bright flash on a clear.

```json
{ "schema": 1, "id": "cave_08", "biome": "cave", "tier": 8,
  "board": { "width": 5, "depth": 5, "h_play": 10 },
  "knobs": { "fall.g0": 1.25, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "fog", "params": { "visible_ms": 3000, "fade_ms": 800, "invisible_alpha": 0.12, "reveal_ms": 600, "lantern_radius": 1, "skin": "lantern_circle" } } ],
  "stars": { "t2": 225000, "t3": 160000 },
  "music": "cave_08_tbd" }
```

---

### 09 Echo Hall (remix)

**Story card.** The echo hall copies every piece across the hall, front to back, and the lamp still only lights what is near. Keep both halves tidy in the dark. · **Nugget: watcher** (calls into the hall; its echo answers late).
**Stage**: busy; a long hall of reflections, the bat colony on the ceiling. **Light**: lantern circle (I). **Intro skit** (3 s): Nugget squeaks into the hall; the echo squeaks back three times; a bat answers too (`question`); glint. **Payoff skit = the low point (5 s, see §8)**: the last clear flashes the hall; the bats flap off in a squeaky cloud and Nugget, the wizard and the friends laugh at the bat gag. **Mizzle clue (M, inside the payoff, 1.5 s) ★ The low point (softer)**: §8. **Reactions (R)**: twin lands `note`; clear `sparkle`; warning `sweat`.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (6) · FT01 (1) · CL01 + CO01 · PL10 Echo Twin (mirror_axis z) · EV02 Lantern Circle (lantern_radius 1) · WO09
One sentence: "Echoes in the dark: every piece has a twin, and only your lamp shows them."
Atoms used: PL10 (Proposed), EV02 + `lantern_radius`. New to the player: nothing (06 and 08).
```
**Encounters**: **Echo Twin**, `mirror_axis` z (front-back, the plane between z = 2 and z = 3), so it reads differently from 06. **Lantern Circle**: `visible_ms` 3 500, `fade_ms` 800, `invisible_alpha` 0.12, `reveal_ms` 700, `lantern_radius` 1. The lamp lights the twin's neighbourhood too (both ghost footprints count), so the player can check the far half before dropping. Clear 6 because twins double the fill rate. Pieces 8 Std. Stars hand-set: `t_est ≈ 0.6 × 6 × 96 = 346 s`.

```text
top-down 6×6 (mirror — between z2 and z3)   side (x = 2), z runs left → right
######                                      13 . . . S . .   spawn zone
######                                      10 ============  danger line
######  ——                                  :
######                                       1 ~ # . | . # ~   twin mirrors front-back
######                                       0 # ~ # | # ~ #
######
```
**How it plays**: (1) the first twin pops in from the far side of the hall. (2) Faded cubes come back as the lamp passes over them, on both halves. (3) The player keeps the stack symmetric, so memory needs only one half. (4) Six clears; the bats lift off and the low point plays.
**Teaches**: the remix of two Cave ideas; the hardest main-path level in the biome.
**Readability**: the mirror line is world-anchored and stays lit; twin ghost paler and dotted; telegraphs never fade.
**Wacky test**: surprising, echoes you cannot see; silly, the echo squeaks; funny failure, a twin lands on a forgotten cube and the hall "boings"; big moment, the bat cloud.

```json
{ "schema": 1, "id": "cave_09", "biome": "cave", "tier": 9,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 1.30, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 6 },
  "rules": [ { "id": "pond_mirror", "params": { "mirror_axis": "z", "skin": "crystal_echo" } },
             { "id": "fog", "params": { "visible_ms": 3500, "fade_ms": 800, "invisible_alpha": 0.12, "reveal_ms": 700, "lantern_radius": 1, "skin": "lantern_circle" } } ],
  "stars": { "t2": 295000, "t3": 205000 },
  "music": "cave_09_tbd" }
```

---

### 10 Geode's Hollow (boss: Geode) ★PROTO

**Story card.** The lantern chain blinks in Geode's face and he wants to sleep. He rattles the minecart rails under your stack, stomps so loose cubes pop off, and the blinking chain throws the hollow into flickering dark. Each clear dims one lantern bulb. The last clear cracks him open. · **Boss**: Geode (a big round boulder with mitten fists and a sleepy face, the lantern chain wrapped round him); Nugget watches from the rim.
**Stage**: busiest, but soft; Geode's hollow, the biggest chamber, the rail loop under the board. **Light**: deep lantern circle during play, turning to **crystal-bird bloom** (the brightest the cave gets, warm) in the payoff. **Intro skit** (3 s, from the skits doc): 0.0–1.0 the lantern chain flashes in Geode's face, he sits up squinting (`angry`); 1.0–2.0 he stamps, rocks tumble from the ceiling; 2.0–3.0 hand-off: Nugget adjusts its headlamp, looks up at the wizard; glint; first piece. **Payoff skit** (6 s first play; [R] = beats 4–5; from the skits doc): 1. 0.0–1.5 last clear, Geode cracks down the middle (`dizzy`); 2. 1.5–3.0 out hatches a vain crystal bird, it preens and lights the whole cave (`smug`), keepsake pop: the gem; 3. 3.0–4.0 Nugget squints in the light, sneezes at the dust (`dizzy`); 4. 4.0–5.0 [R] the bird sees its reflection is dusty and flaps off offended (`angry`); 5. 5.0–6.0 [R] the new light falls on the cave wall: a chalk blueprint; something upside-down above it unrolls its ears: hand-off to the **friend join** (§8). **Mizzle clue**: none (slot 10); flag 7 hangs on the lantern chain as set dressing. **Reactions (R)**: each clear a bulb dims and Geode's eyelids droop (`sleep`); warning use Geode grins (`smug`).

```text
Recipe: BL01 (8 wide × 6 deep, H12) · AR01 · CV01 · GO01 (3 = 3 lantern bulbs) · FT01 (1) · CL01 + CO01 · EV05 Minecart Rail [mechanic] · EV12 Geode Stomp · EV02 Lantern Chain (lantern_radius 2) · WO09
One sentence: "The rail moves your stack, Geode's stomp shakes loose cubes, and the lamp shows only what is near."
Atoms used: EV05 (Designed), EV12 (Candidate), EV02 + `lantern_radius`. New to the player: nothing (03, Forest 08, 08).
```
**Encounters**:
- **Minecart Rail** (conveyor): +x, every 3 locks, wrap on (the board is a rectangle because Conveyor forbids masks).
- **Geode Stomp** (EV12): every 14 000 ± 3 000 ms, warning 1 500 ms (fists rise, dust drifts; dotted outlines on the overhang cubes that would pop), at most 3 pops per stomp, highest first, at the next Resolving. Counter: build flat.
- **Lantern Chain** (EV02): `visible_ms` 5 000, `fade_ms` 1 000, `invisible_alpha` 0.15, `reveal_ms` 800, `lantern_radius` 2 (wider than 08, because the stack also moves). The stomp outlines are telegraphs and are never faded.
- **Staggered starts (decision)**: no phase atom is needed. The rail shifts on the 3rd lock, the first stomp falls due at about 11–17 s, and blocks first fade 5 s after their lock, so the three rules arrive one after another. Each clear dims one lantern bulb: staging only; the rules do not change. Bats and rockfall are not used (Geode's stomp is the "rocks tumble" beat; the intro shows it).
- Geode is the face of the rules: the rail is his rumble, the stomp his fists, the dark his blinking chain. He sulks on each clear and dozes more as each bulb dims.

```text
top-down 8×6 (rail → along x)   side (z = 3)
→ → → → → → → →                 15 . . . S S . . .   spawn zone
########                        12 ================  danger line
########                         :
###S####                          2 . # . . . . # .   dotted = pops on the next stomp
########                          1 # # . ~ # # . #   ~ = faded
########                          0 # # # . # ~ # #   → shift +x, wrap
########
```
**How it plays**: (1) after the 3rd lock the stack rides the rail and wraps. (2) The first stomp outlines the loose cubes; the player flattens the top. (3) The chain blinks and the stack fades; the wide lamp shows the landing area, which the rail keeps moving. (4) Each clear dims a bulb; the third cracks Geode open.
**Teaches**: nothing new: the final exam of rail, stomp and dark.
**Readability**: three disturbances with three different telegraphs (rail rattle on the edge, dotted outlines on cubes, slow fade with a lit ring); none fires on the same beat as another by default. If playtests find it too busy, raise `lantern_radius` to 3 or drop the stomp to every 18 s (§10).
**Wacky test**: surprising, a sleeping boulder as a boss; silly, the vain crystal bird; funny failure, Geode grins and dozes off mid-grin when you use a warning; big moment, the crack, the hatch, and the cave lighting up.

```json
{ "schema": 1, "id": "cave_10", "biome": "cave", "tier": 10,
  "board": { "width": 8, "depth": 6, "h_play": 12 },
  "pieces": { "shapes": ["i","o","t","l","tripod","screw_l","screw_r","chair"] },
  "knobs": { "fall.g0": 1.35, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 3 },
  "rules": [ { "id": "conveyor", "params": { "dir": "+x", "conveyor_every": 3, "conveyor_wrap": true, "skin": "minecart" } },
             { "id": "woodpecker_knock", "params": { "knock_interval_ms": 14000, "knock_jitter_ms": 3000, "knock_warn_ms": 1500, "knock_pop_max": 3, "skin": "geode_stomp" } },
             { "id": "fog", "params": { "visible_ms": 5000, "fade_ms": 1000, "invisible_alpha": 0.15, "reveal_ms": 800, "lantern_radius": 2, "skin": "lantern_chain" } } ],
  "stars": { "t2": 325000, "t3": 230000 },
  "music": "cave_10_tbd", "story": { "mascot_role": "boss", "icon": "geode", "friend_unlock": "glim" } }
```
(The EV12 rule id follows `forest.md` (`woodpecker_knock`); a neutral id such as `quake` is the module owner's call, §10.)

---

### B Treasure Map (bonus, tier 11, 20 cave stars)

**Story card.** Nugget found half a treasure map; the crystal echo draws the other half. Pick pieces from the kit box in any order and fill the map chest; every piece gets its twin. Six pieces in the box, only four needed. · **Nugget: watcher** (hops, shovel ready).
**Stage**: clean, silly; a treasure-map cavern with an X on the floor. **Light**: treasure-map lantern (H). **Intro skit** (3 s): Nugget unrolls half a map; the crystal wall shows the other half; Nugget turns the map round and round (`question`); glint. **Payoff skit** (5 s, from the skits doc): 0.0–2.0 the last map piece fits, an X glows; 2.0–4.0 Nugget digs at the X, dirt flies (`idea`); 4.0–5.0 Nugget pops up wearing the treasure, a crown, over its headlamp (`sparkle`). **Postcard 7** (Scrapbook only, not in-level): he draws ten pictures on one long sheet and holds it up, the full invitation (`idea`). **Reactions (R)**: good pick `sparkle`; decoy picked `question`.

```text
Recipe: BL01 (4×4, H6) · AR13 kit box [O, I, O, I, T, S] · CV01 · M2 fill shape (GO03 32 cells + CL14) · FT07 piece budget (6) · PL10 Echo Twin (x) · WO09
One sentence: "Pick any piece; its echo fills the other half of the map."
Atoms used: AR13 (Proposed), M2, FT07, PL10 (Proposed). New to the player: AR13 only if the Forest bonus was skipped (≤ 1). Retry is free.
```
**Encounters**: none. The kit box shows all six pieces; pick one, it falls; used pieces grey out. Target: two full layers (32); the left half (x 0–1) is 16 cells = 4 pieces. The **T and S are decoys**: neither tiles a 2-wide half cleanly, and a piece across the centre wastes its twin. **Known solution**: O at (x0–1, z0–1, y0), O at (x0–1, z2–3, y0), I at (x0, z0–3, y1), I at (x1, z0–3, y1); every placement and twin is supported. The level ends when the target is full (pieces left over are fine) or the kit is empty. Glim's Redraw does nothing on a kit box. Stars: ★★ 70 s, ★★★ 45 s.

```text
targets (both layers)   side (z = 1)
##|##                    6 ======
##|##                    :
##|##                    1 I I | I I   the I's (twins on the right)
##|##                    0 O O | O O   the O's
```
**How it plays**: (1) read the kit: two O, two I, a T and an S. (2) Pick an O; its twin fills the right base corner. (3) The second O finishes the base; the I's lie along z on layer 1. (4) The X glows and Nugget digs. Picking the T or S first is the funny wrong turn.
**Teaches**: nothing required; the wackiest level (decoys, echo, a mole in a crown).
**Readability**: map-parchment target cells; the twin ghost shows the mirror; decoys look normal (fair: they simply do not fit).
**Wacky test**: surprising, half a map that draws itself; silly, the crown on a headlamp; funny failure, the S's twin sticks out of the chest like a tongue; big moment, the X glowing.

```json
{ "schema": 1, "id": "cave_bonus", "biome": "cave", "tier": 11,
  "board": { "width": 4, "depth": 4, "h_play": 6 },
  "pieces": { "kit": ["o","i","o","i","t","s"] },
  "knobs": { "fall.g0": 0.60, "spawn.arrival": "kit_box", "goal.top_out": "out_of_pieces" },
  "goal": { "type": "shape", "piece_budget": 6,
            "target_shape": { "layers": { "0": ["####","####","####","####"], "1": ["####","####","####","####"] } } },
  "rules": [ { "id": "pond_mirror", "params": { "mirror_axis": "x" } } ],
  "solution": [ { "shape": "o", "cells": [[0,0,0],[1,0,0],[0,0,1],[1,0,1]] },
                { "shape": "o", "cells": [[0,0,2],[1,0,2],[0,0,3],[1,0,3]] },
                { "shape": "i", "cells": [[0,1,0],[0,1,1],[0,1,2],[0,1,3]] },
                { "shape": "i", "cells": [[1,1,0],[1,1,1],[1,1,2],[1,1,3]] } ],
  "stars": { "t2": 70000, "t3": 45000 },
  "music": "cave_bonus_tbd" }
```

---

## 7. Hard-track remixes (tiers 12–14; open after 10)

Glim has joined: Redraw is available here (not tuned against).

### H1 Runaway Cart

**Story card.** The minecart has had too much fun: it rolls every two pieces now, and the bats flap at it as it passes. · **Nugget: watcher** (clings to the cart's back). **Light**: lantern (H). **Intro skit** (3 s): the cart rolls past at speed with Nugget's lamp spinning on its front; bats scatter (`exclaim`). **Payoff skit** (4 s): the cart crashes softly into a pile of pebbles; Nugget climbs out, and Glim, hanging above, straightens the rail with a chalk line (`idea`). **Reactions (R)**: rail wind-up `exclaim`; clear `sparkle`.

```text
Recipe: BL01 (7×5, H10) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · EV05 Minecart Rail (+x, every 2, wrap) · EV01 Bat Flap (fixed +z, 10 s ± 2.5 s, 1 s warning)
Atoms used: EV05, EV01 (both met). New: none.
```
```text
top-down 7×5 (rail →, flap ↓)   side (z = 2)
→ → → → → → →                   13 . . . S . . .
#######   ↓                     10 ===============
###S###                          :
#######                          0 # # . # # . #   → shift every 2 locks
#######
#######
```
Pieces 8 Std; `g0` 1.30; Clear 5; `A` 35 → `t_est` 467 s; ★★ 395 s, ★★★ 280 s (~7.8 min). Flap and shift never share a beat (the flap only hits a falling piece; the shift is in Resolving).

```json
{ "schema": 1, "id": "cave_h1", "biome": "cave", "tier": 12,
  "board": { "width": 7, "depth": 5, "h_play": 10 },
  "knobs": { "fall.g0": 1.30, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 5 },
  "rules": [ { "id": "conveyor", "params": { "dir": "+x", "conveyor_every": 2, "conveyor_wrap": true, "skin": "minecart" } },
             { "id": "gust", "params": { "wind_mode": "fixed", "wind_dir": "+z", "wind_interval_ms": 10000, "wind_jitter_ms": 2500, "wind_warn_ms": 1000, "skin": "bat_flap" } } ],
  "stars": { "t2": 395000, "t3": 280000 },
  "music": "cave_h1_tbd" }
```

### H2 Cave-In

**Story card.** The crystal bird flew off, and Geode (now a much smaller rock) rolls over in his sleep: stomps shake loose cubes and pebbles rain onto the stack, between two stalagmites. · **Nugget: watcher** (holds a tiny umbrella). **Light**: crystal glow (G). **Intro skit** (3 s): a small snoring rock rolls over; the ceiling sprinkles pebbles on Nugget's umbrella (`sweat`). **Payoff skit** (4 s): the rock settles; Glim chalks a "keep quiet" sign (a pictogram: a finger on lips) and hangs it on him (`sparkle`). **Reactions (R)**: stomp warning `exclaim`; pebble lands `question`; clear `sparkle`.

```text
Recipe: BL18 cave rock (6×6, H10; stalagmites (1,1) and (4,4), y0–2) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV12 Geode Stomp (every 15 s ± 3 s, warn 1.5 s, pop max 3) · EV04 Rockfall + SP19 (every 7 locks, max 3)
Atoms used: BL18, EV12, EV04, SP19 (all met). New: none. 4 non-default.
```
```text
top-down 6×6 (R = stalagmite y0–2)   side (z = 1)
######                               10 ===========
#R####                                :
######                                2 . R . # . .   dotted outlines on overhangs
######                                1 # R . # # .
####R#                                0 # R # # # #
######
```
Pieces 8 Std; `g0` 1.30; Clear 4 (layers 0–2 have `A` 34, above 36); stars hand-set from `t_est ≈ 350 s`: ★★ 300 s, ★★★ 210 s (~6 min). Stalagmites never move; a stomp never pops rock.

```json
{ "schema": 1, "id": "cave_h2", "biome": "cave", "tier": 13,
  "board": { "width": 6, "depth": 6, "h_play": 10,
             "rock": { "columns": [ { "x": 1, "z": 1, "y_from": 0, "y_to": 2 }, { "x": 4, "z": 4, "y_from": 0, "y_to": 2 } ] },
             "spawn_anchor": { "x": 2, "z": 2 } },
  "knobs": { "fall.g0": 1.30, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "woodpecker_knock", "params": { "knock_interval_ms": 15000, "knock_jitter_ms": 3000, "knock_warn_ms": 1500, "knock_pop_max": 3, "skin": "geode_stomp" } },
             { "id": "mushroom_popup", "params": { "spawn_every_locks": 7, "objects_max": 3, "skin": "pebble" } } ],
  "stars": { "t2": 300000, "t3": 210000 },
  "music": "cave_h2_tbd" }
```

### H3 Mole Rescue

**Story card.** Three of Nugget's mining crew dug themselves in (again), one in each of the bottom layers, and the gallery is dark. Clear the layer a mole is in to pop it free; the lamp shows only what is near. · **Nugget: watcher** (taps on the rock to find them). **Light**: lantern circle (I). **Intro skit** (3 s): three little headlamp glows shine up through the starter blocks; Nugget knocks, three knocks answer (`idea`). **Payoff skit** (4 s): the three moles pop out in a row, bonk heads, and all squint at the wizard; Glim counts them off with her pencil (`exclaim`). **Reactions (R)**: mole freed `sparkle`; warning `sweat`.

```text
Recipe: BL05 (6×6, H10, 3 starter layers with 1 buried mole each) · AR01 · CV01 · GO21 Dig to rescue (3 moles) · FT01 (1) · CL01 + CO01 · EV02 Lantern Circle (visible 3 000, fade 800, alpha 0.12, reveal 600, lantern_radius 1)
Atoms used: BL05, EV02 (met), GO21 (Candidate). New: GO21 (1). 3 non-default.
```
```text
layer 0       layer 1       layer 2       side (z = 2)
######        #.####        ####.#        10 ===========
##.###        ######        ######         :
#m####        ###m.#        ######         2 # # # # . #
######        ######        .#m###         1 # # # m . #   m = mole (solid, freed by its layer's clear)
###.##        ##.###        ######         0 # m # # # #
######        ######        ######
```
Starter blocks are visible through Intro and Countdown, then their timers start at the first spawn (twist-library rule 7). A mole is solid content that fills its cell; clearing its layer frees it (it hops out, staging). Win when all 3 are freed. Pieces 8 Std; `g0` 1.25; about 10 gap cells across the three layers plus the slice drops; stars hand-set: ★★ 170 s, ★★★ 120 s (~3.5 min).

```json
{ "schema": 1, "id": "cave_h3", "biome": "cave", "tier": 14,
  "board": { "width": 6, "depth": 6, "h_play": 10,
             "starting_contents": { "layers": {
               "0": ["######","##.###","#m####","######","###.##","######"],
               "1": ["#.####","######","###m.#","######","##.###","######"],
               "2": ["####.#","######","######",".#m###","######","######"] },
               "legend": { "#": "block", "m": "mole" } } },
  "knobs": { "fall.g0": 1.25, "goal.warnings_max": 1 },
  "goal": { "type": "dig_rescue", "critters_needed": 3 },
  "rules": [ { "id": "fog", "params": { "visible_ms": 3000, "fade_ms": 800, "invisible_alpha": 0.12, "reveal_ms": 600, "lantern_radius": 1, "skin": "lantern_circle" } } ],
  "stars": { "t2": 170000, "t3": 120000 },
  "music": "cave_h3_tbd" }
```

---

## 8. Narrative beats

Wordless (campaign story rules): intro and payoff skits per level, Nugget's reactions, Geode asleep in the backdrop from 01, one Mizzle clue per level in slots 03–09 (at most 1.5 s, at the rim or backdrop, never over the grid, never during a warning). Arc: Nugget's lamp flickers (01), finds gems (02), chases the cart (03), sneezes up the bats (04), peeks at daylight (05), meets its reflection (06), pops a gem from the wall (07), finds the dark gallery full of moles (08), laughs with the bats (09, **the low point**), and sees Geode hatch into light (10); Glim joins. The bonus and remixes are after-party gags.

| Level | Mizzle clue (strength cap 3; from `dialogue-campaign-skits.md` §7) | Emote |
|---|---|---|
| 03 | A second, droopier shadow walks behind Nugget's shadow on the wall, then stops | none |
| 04 | He hangs a spare lantern on a hook at the rim, then hides it behind his back | `sweat` |
| 05 | ★ **Shadow puppets**: crystal light casts a small hooked-hat figure playing among little friend shapes | `dots` |
| 06 | He builds a small crooked tower of crystal chips by his lantern | `idea` |
| 07 | A bat flaps past his tower; he steadies it with both hands | `sweat` |
| 08 | He adds a crooked top block and admires it | `dots` |
| 09 | ★ **The low point (softer)**: below | `dots` |

**The low point (09 payoff, 5 s; the clue is 1.5 s of it).** 0.0–2.0 the last clear flashes the hall; the bats flap off in a squeaky cloud, one wearing Nugget's lamp; Nugget, the wizard and the friends laugh (the wizard reacts to the player's clear, rule 8). 2.0–2.5 at the rim, Mizzle turns toward the laughter; his crooked crystal-chip tower **tilts**. 2.5–3.0 he props it up with his wand; it stays leaning. 3.0–3.5 shoulders drop, hat tip droops (`dots`); he **walks off slowly into a lantern glow**, cuffs dangling. 3.5–5.0 where he stood, **a small lantern is left behind, still lit**; Nugget, still giggling, glances at it (`question`). No collapse, no `tear`, no sleeve wipe (staged per `visual-direction.md` §3.2, the version the coordinator named; see §10 for the differing skit-doc draft). The lantern is the hopeful note and the bridge to the Clockwork table.

**Friend join: Glim (4 s, then unlock card; from the skits doc)**: 0.0–1.0 Glim drops from the ceiling to hang upside-down by the blueprint, scowls at the mess (`angry`); 1.0–2.5 she wipes a crooked line off with her wing, redraws it, and the route out glows on the wall (`idea`); 2.5–3.5 Nugget follows the line and bumps into nothing for once (`sparkle`); 3.5–4.0 Glim salutes the wizard with the rolled blueprint (`exclaim`). Unlock card: her silhouette fills with colour; the blueprint unrolls behind her ear. Tap to skip; she is unlocked either way. Her look: warm cocoa-grey fur `#7A6A64` (never purple), dusty-peach ear insides, navy blueprint with white chalk, no spectacles.

**Map change (3 s, after the friend join)**: 0.0–1.0 the crystals light up across the island; 1.0–2.0 flag 7 ties itself round a stalagmite; 2.0–3.0 horizon: Mizzle's tower **leans but stands, propped on a stick**, with one new floor (floor 6), and the little lantern from 09 hangs on it. **Hidden thread**: one lantern-chain bulb lying on the minecart track (backdrop, 01–02); a lopsided chalk tower drawing on a wall (backdrop, 04); his propped practice tower glimpsed in a side tunnel (backdrop, static, after 09).

## 9. Music and audio cues

One track per level, supplied by the user; ids are placeholders (`cave_01_tbd` … `cave_10_tbd`, `cave_bonus_tbd`, `cave_h1_tbd` … `cave_h3_tbd`). Until the tracks arrive, every Cave level plays the biome `default_music` ("Carefree" is a placeholder only). No stems and no layered mixes: each track simply plays for its level. Authoring notes for the user's tracks: 01–02 quiet and curious (drips, a soft marimba), 03 a bouncy cart rhythm, 04 a little flappy and cheeky, 05 hushed (no danger music; it cannot be lost), 06–07 glassy and calm, 08–09 the sparsest of the campaign (not scary: warm, slow, a music-box feel), 10 the biggest, ending in a bright crystal swell for the hatch, the bonus a silly treasure-hunt tune. A **danger stinger** only where `topout_rule` is rescue. Skits use short stingers, never voices; the 09 low point uses a soft single note, no sad cue.

SFX cues (one-shots, no music change): drip chime on clears (01–02); rail rattle one lock before a shift; a wing whoosh and squeak on a Bat Flap; dust trickle then a pebble "plop" on Rockfall; a crystal click for each echo twin and a "nope" chime on skipped twin cells; a lamp "fwip" when cubes re-light in the lantern circle; Geode's fist rumble before a stomp, then cartoon pops; a bulb "tink" on each clear in 10; an egg-crack and a bird trill on the hatch. Ambience (under the SFX slider): water drips, echoing pebble clicks, bat squeaks, the minecart's far rattle, Geode's deep snore. The SFX pack (MB-003) provides the base sounds.

## 10. Open questions

- **Lantern Circle needs a new EV02 param** `lantern_radius` (0 = plain fog). It is view-side and deterministic (it reads the ghost footprint, which is sim state). Twist-library T2 has no such param yet; owner game-designer (twist-library) with ADR-0011 for the view rule. Fallback with no change: plain EV02 with `visible_ms` 5 000 in 08–10 and H3 (the levels still work; they just lose the "lamp" read).
- **Proposed atoms used**: BL18 Cave rock (02, 05, H2), PL10 Echo Twin (06, 07, 09, B), AR13 Kit box (B). They need review into Candidate; BL18 needs the `rock` data format (layer grids vs. column list; both used above) and the "no rock at or above `H_play − 1`" validator guard; PL10 needs the second-ghost UI and a ruling that twin cubes count for clears and shapes. **Candidate** atoms used: EV12 (10, H2), GO21 (H3: needs the `mole` critter content and the `dig_rescue` goal plugin; SP07 Critter may be the content).
- **EV12 rule id**: `forest.md` uses `woodpecker_knock`; a neutral id (`quake`) with per-biome skins is cleaner. Module owner's call.
- **Low-point staging conflict**: `dialogue-campaign-skits.md` §7 has Mizzle *catch* the tower, carry it off, and do one sleeve wipe; `lore-world.md` §3.7 has a catch, a cuff wipe of the glasses and a tiptoe off; `visual-direction.md` §3.2 (followed here, as the coordinator directed) has the tower tilt and be propped with his wand, a slow walk into a lantern glow, a lit lantern left, no wipe. Narrative-director to align the two other docs.
- **Lighting conflict**: `lore-world.md` §3.7 lists seven presets (L5 crystal cool with a daylight crack, L7 lantern circle as the low-point level, L8–9 deep dark, L10 deep dark into bloom); `visual-direction.md` (followed) has five stages with lantern circle at L8–9. Art-director to update the lore table. Lore's island order (pitch-dark gallery at L7, cave-in at L8) is re-slotted to match: dark gallery is 08, the cave-in moved to H2.
- **Glim's Redraw**: no effect on fixed lists and kit boxes (07, B); first usable in H1–H3. If Redraw is classed as a buff, its board chalk outline must stay white, not cyan (visual-direction §1.6).
- **F1 recount**: "new to the player" counts only Meadow, Forest and earlier Cave levels; Candy, Ice, Underwater and Lava atoms may already be known. The 08 lantern variant is counted as new; if the module treats it as EV02 (known), 08 has 0 new.
- **Atom id clashes in other biome files** (not this file's to fix, but they affect any recount): EV25 is used by both `forest.md` (Squirrel Heist) and `candy.md` (Syrup band); SP41 by both `ice.md` (Snowball Roll) and `candy.md` (Climber boss). The Cave adds no new ids.
- **10 busyness**: rail + stomp + dark is the biome's hardest read. First tuning steps: `lantern_radius` 3, then stomp every 18 s, then drop the stomp (the finale's third-twist allowance stays unused).
- **07 and B `solution` lists**: the validator should replay them with the echo rule on. 07 needs a half turn (Turn) of the second L; confirm the spawn orientation.
- **Star times** are formula estimates (hand-set where noted, especially the echo levels' `0.6 × F1` guess); replace with playtest medians.
