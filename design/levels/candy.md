# Candy Biome: Mallow's Birthday Cake (levels 01–10, bonus, hard track)

> **Status**: Draft for user review (level-designer, 2026-10-10). Follows `design/levels/meadow.md` section for section.
> **Author**: Tessa + level-designer
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Sources**: `production/levels/candy/layout.md` (sketch draft, user Candy decisions of rounds 5/6), `production/narrative/campaign-story/brief.md` §3.2, `lore-world.md` §3.2, `dialogue-campaign-skits.md` §2, `visual-direction.md` §2 (Candy), `design/gdd/mechanics-module.md` (atoms, F1 budget), `design/gdd/level-specific-mechanics.md` (M1, M2, M5, M7), `design/gdd/twist-library.md` (rule 16 axis flip), `design/gdd/campaign-structure.md`, `design/gdd/scoring-stars.md`, `design/gdd/level-data-definition.md` (fields).
> **Field definitions**: `design/gdd/level-data-definition.md`; defaults from the owning GDDs.

**Every number, name and beat in this file is a tunable default**, a starting point for the prototype and playtests. The validator enforces only the safe ranges in the owning GDDs. Rule ids marked `*` and atom ids marked **NEW** are provisional (section 1, "New atoms this biome needs").

---

## 1. Level name and theme

**Mallow's Birthday Cake.** Mallow the marshmallow bunny wants to build a giant birthday cake for Granny. Blocks fall as a **gummy drizzle** (the drizzle takes the flavour of the place: gummy candy in three flavours). Madame Meringue, a giant swirl of meringue who wants to be the cake topper, has been given a piping bag meant for the party icing. She pipes herself a throne instead, then pranks the bakery to get to the top. In the finale the last bonk drops her upside-down on the cake as the topper, furious; Granny blows out the candles. Keepsake: a cherry on the wizard's hat. Thread: a tall droopy hat watches from the bakery window, and a violet cuff takes one slice from the sill (clue strength 1: silhouette or prop only).

**Quirk: "Colour matters", in two steps.** Levels 01–04 turn on the **Mono Layer** bonus (CL07): a layer of one flavour is a "sugar sparkle" that also takes the next layer, and nothing is lost if you ignore colour. From 05 on, colour decides **stars (05)**, **goals (06)** and **clears (07–10)**. Candy is the second biome: about 70% classic play, strangeness zig-zags level to level.

### Biome rules (decisions)

| Rule | Default |
|---|---|
| Islands | One per level, shaped by the story: sugar-cube tin, cake-tin cupcake, lollipop lane, jelly bridge, tiered cake stand, icing slab, gummy jar, candy-floss counter, chocolate-fountain plaza, Granny's cake table on the bakery step; bonus: a heart-shaped chocolate box |
| Stage | Busy diorama or clean stage per level; calm levels quiet, chaos levels busy |
| Intro skit | A 3-second wordless mini-scene in which Mallow shows the problem, played during the Countdown (no play time lost). Boss intro (10): the same 3 s ending on the hand-off |
| Payoff skit | A short wordless skit on every win (5 s, tap to skip); the biome finale runs 6 s on first play, last 2 beats on replays |
| Mascot | **Mallow** (Candy only), a **mood swing** (WO08 driven by WO01 tidiness F10), below |
| Boss | **Madame Meringue**: on the bakery shelf in the backdrop from 05 (sniffing, looking down her nose), causes the events of 09, boss of 10. She never helps. Bonked, never hurt |
| Physics | None (the "jelly" feel in 04 is rule-based, not physics; the board stays a grid) |
| Rubber duck | A gummy duck under the island in 01 and 02 (SE05, visible from one low snap angle; tap to collect; no stars attached) |
| Events as Candy events | Spawned Objects (EV04) = **Gumdrop Hail** (02, 03) / **Meringue Dollop** (10); Speed-up bump (EV17) = **Sugar Rush** (08); Goo spread (EV11) = **Chocolate Spread** (09); Gravity flip, axis mode (EV03) = **Fountain Tilt** (09); Syrup band (EV25 **NEW**) = **Syrup River** (03, H2) |
| Failure gag (every level) | The cake slumps into a gooey heap; Mallow, mid-hop, faceplants into the icing and comes up with a frosting beard. From 05 Madame Meringue gives a slow, smug clap. Nobody is hurt |
| Prototype priority | **04, 07, 10** (★PROTO), plus **03** as the cheap fourth (one new twist; tests the slow-and-glide feel) |
| Unlock | Opens when `meadow_10` is finished and the Meadow has 15 of 30 stars. Bonus `candy_bonus` (tier 11) opens at 20 Candy stars. Hard-track remixes H1–H3 (tiers 12–14) open when `candy_10` is finished. Neither counts toward the next biome's gate |

**Mallow, the mood swing (WO01 + WO06/WO07/WO08, mascot layer, no F3 cost).** Her mood follows board tidiness (WO01, F10). Three bands, the same in every level; only the **prank card** changes:

| Band (tidiness, tunable) | Role | What she does |
|---|---|---|
| **Happy** (≥ 0.9) | helper (WO06) | Points at a good cell. In 01–03 she also has **Mallow's catch** (WO11, 1 per level): when a lock leaves a new covered hole and clears nothing, the lock is undone, the piece sticks to her ears and she hands it back at the spawn. Catches never affect stars. Tiers 4+ and the hard track: 0 |
| **Neutral** (≥ 0.7) | watcher (WO09) | Licks a lollipop, reacts; no gameplay effect |
| **Grumpy** (< 0.7) | sugar-rush prankster (WO07) | Gobbles a sweet, vibrates, then plays the level's prank card, always telegraphed 1 s ahead (a crouch, a tongue, a splash ring). In 01–02 the prank is cosmetic (she bounces off the screen edge and back), so the tutorials never punish |

Pranks are mascot-layer rules written through `RuleApi` from the rule's seeded stream, so replays agree (ADR-0011). Mallow's pranks never remove a correct placement except in 06 (cap 2 per level, telegraphed).

**Common defaults** (unless a level says otherwise): weighted bag, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, all rotation axes, `t_piece` 8 s, 3 flavours from 05 (2 in 01–04). Speeds are hand-set and match campaign F2 for biome 2 (`0.6 + 0.045 × (tier − 1) + 0.06`) within ±0.05 (F2 gives 0.66 at tier 1 and 1.065 at tier 10). Special pieces "1 per bag" means one piece in each bag carries the tag (a Standard shape, chosen by the bag's seed).

**Flavours (colour key).** Colour rules read a cube's `colour_key`. Candy needs several colours inside the Standard family, so each spawned piece rolls one flavour from the level's seeded stream: **strawberry** (peach-coral, `P`), **vanilla** (cream, `V`), **mint** (mint-sage, `M`). Knobs: `spawn.colour_count`, `spawn.colour_weights`, `spawn.colour_streak` (chance the next piece repeats the last flavour; 0.6 in 01–04 so a Mono layer is reachable, 0.4 in 05, 0 later). Each flavour also has a **surface pattern** (strawberry seed dots, vanilla swirl, mint leaf) so colour is never the only cue. Starter stone, objects, chocolate and frosting have no key; they break a Mono layer.

**Budget (mechanics module F1).** At most 2 atoms new to the player and 4 non-default atoms per level; **showpiece levels on tiers 7–10: at most 6 non-default** (user decision 2026-10-10). A bundle (M1 = GO02 + CL14 + FT02, M2 = GO03 + CL14, "earned candy bomb" = SP04 + SP01) counts as one idea; mascot atoms (WO01, WO06–WO09, WO11) and secrets (SE05) count 0. Slot defaults: BL01, AR01, CV01, CL01, CO01, GO01, FT01.

**Grids**: one string per row, row 0 = `z = 0` (back), character 0 = `x = 0` (left). Mask `#` active, `.` off. Starting contents: `#` starter stone, `.` empty, `g` gumdrop, `w` gummy worm, `c` chocolate, `l` licorice lock, `2` / `3` frosting with 2 / 3 layers, `s` baked sponge. Colour targets: `P` strawberry, `V` vanilla, `M` mint, `.` no target. Side views are a slice at one `z` row seen from the front; `=====` is the danger line at `H_play`, `S` the spawn zone, `:` skips empty rows.

### New atoms this biome needs

Everything else is an existing module atom. Ids are the next free ones in each slot and **provisional** (other biome writers may claim the same numbers; the module owner renumbers). Each is one plugin or one data entry (implementation plan §3).

| Proposed ID | Name | Rule (one line) | Hook | Cost | Used in |
|---|---|---|---|---|---|
| **EV25** | Syrup band | A set of `band_rows` is syrup. A falling piece with any cube over the band falls at × `syrup_slow` (0.5); a piece that comes to rest over it glides `syrup_glide` (≤ 2) cells along `syrup_dir` until blocked, then locks. Sticky objects do not glide | Twist `RuleBehaviour` | M | 03, H2 |
| **CO10** | Gummy cascade | After a clear, unsupported cubes fall, but every face-connected same-flavour blob falls as **one rigid chunk** and keeps its own overhangs | Collapse slot (`CollapsePolicy`) | M | 04, 09, 10, H1 |
| **SC13** | Tier frosting | Every `tier_layers` (2) layers form a tier; a tier is **frosted** when ≥ `frost_share` (0.5) of its cubes share one flavour that differs from the tier below. Stars count frosted tiers (`stars: {s2, s3}` in tiers, same shape as Survive) | Scoring rule on `on_lock` | S | 05 |
| **BL21** | Bake (stage swap) | A two-stage mechanic (BL15 stage medley with a transform). Stage 1 runs the M1 build race to the oven line. On the stage goal, after a `bake_warn_ms` oven timer, every locked cube becomes `sponge` (no flavour, solid, never clears) and dollops become frosting (SP29, 2 layers); the goal, clear detector and top-out switch to the stage-2 values. Counts as the level's **one mechanic** | Mechanic rule, `RuleBehaviour` at S4a | M | 10 |
| **SP41** | Climber boss | A 2×2×1 boss object on the top surface. After each lock it slides to the highest reachable 2×2 spot (it wants the top). A pop touching it is one bonk: it tumbles to the lowest neighbouring spot. Content layer (no F3 cost) | Content type + `RuleBehaviour` | M | 10, H3 |
| **GO31** | Bonk the boss | Win at `bonks_needed` bonks on SP41 | Goal plugin | S | 10, H3 |

Params on existing atoms (data only): GO03 **colour targets** (target cells carry a flavour glyph; a cell counts only if covered by that flavour or a rainbow cube; `win_correct`); EV04 `object: gumdrop`, `sticky`, `avoid_start_holes`; SP25 `jelly_bounce`; EV17 `bump_trigger: mood`; SP04 `bomb_at` (bomb branch only); EV03 `flip_mode: axis`, `flip_max 1`; SP29 peel rule (a clear that removes a cube face-adjacent to a frosting cell peels it by 1; frosting counts as filled for fullness and is not removed by its own layer's clear until peeled to 0).

Candidate atoms whose full rules must be written before build: CL07 bonus value, SP04 (bomb branch), SP20, SP25, SP27, SP29, SP30, SP31, SP32, EV11, EV17, GO07, WO01/WO07/WO08.

## 2. Estimated play time and summary

| # | id | Name | Story beat | New idea (atoms; **bold** = new to the player) | Mallow | Stage | Goal | Board | Pieces | g0 | Top-out | Length | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | candy_01 | Sugar Cube Start | Lay the cake base | **Mono Layer (CL07)** | mood, 1 catch | clean, calm | Clear 4 | 4×4, H8 | I O T L S; first 2 from {O, I} | 0.65 | rescue, 2 | ~3 min | 145 / 105 s |
| 02 | candy_02 | Gumdrop Hail | Gumdrops stick in the tin | pockets (BL05), **Gumdrop Hail (EV04, sticky)** | mood, 1 catch | busy | Clear 3 | 5×5, H10 + 2 starter layers | 8 Std; first 3 a bag of {T, L, Tripod} | 0.70 | rescue, 1 | ~2.5 min | 125 / 90 s |
| 03 ★ | candy_03 | Syrup River | Sail the lolly lane home | **Syrup band (EV25)**, hail callback | mood, 1 catch | busy | Clear 4 | 8×4 lane, H10 | 8 Std | 0.75 | rescue, 1 | ~6.5 min | 335 / 235 s |
| 04 ★ | candy_04 | Jelly Wobble | The jelly bridge jiggles | **jelly pieces (SP25)**, **Gummy cascade (CO10)** | mood | busy | Clear 5 | 8×3 bridge, H9 | 8 Std (flat-heavy) | 0.80 | rescue, 1 | ~5 min | 265 / 185 s |
| 05 | candy_05 | Cake Tiers | Stack tiers to the candles | build race (M1), **tier frosting (SC13)** | mood | clean, tense | Height 8 (cov. 0.6) | 6×6 round, H10 | 8 Std + Big Cube (w 0.5) | 0.85 | trim | ~4.8 min | 3 / 4 tiers* |
| 06 | candy_06 | Icing Picture | Pipe the bunny picture | fill shape (M2) with **colour targets**, **rainbow sprinkles (SP27)** | mood | clean, calm | Picture 38 of 44 | 8×8, H3 | I O T L S Duo Tri-Straight Tri-Corner | 0.85 | trim | ~3 min | 160 / 115 s* |
| 07 ★ | candy_07 | Gummy Worms | Worms raid the jar | **Colour Pop (CL05)**, **gummy worms (SP31)** | mood | busy | Clear 6 (pops or layers) | 6×6 round, H10 | 8 Std | 0.93 | rescue, 1 | ~6.5 min | 330 / 235 s |
| 08 | candy_08 | Sugar Rush | Mallow ate too much | **Sugar Rush (EV17, mood)**, **candy bombs (SP04 + SP01)** | mood (her mood is the event) | clean, frantic | Survive 150 s | 5×5, H8 | 8 Std | 0.95 | rescue, 1 | 2.5 min | 2 / 4 clears |
| 09 | candy_09 | Chocolate Fountain | The fountain tips the cake | **Chocolate Spread (EV11)**, **licorice (SP30)**, Fountain Tilt (EV03 axis) | mood | busiest | Clear 6 (pops or layers) | 6×6×6 cube | 8 Std | 1.00 | rescue, 1 | ~7 min | 380 / 270 s |
| 10 ★ | candy_10 | Madame Meringue | Bake, then bonk the topper | **Bake (BL21)**, **climber boss (SP41 + GO31)** | cheers | busiest | Stage 1 height 4 → Stage 2 bonk 3 | 7×7 round, H14 | I O T L Tripod Screws Chair | 1.05 | trim → rescue, 1 | ~6.5 min | 340 / 240 s |
| B | candy_bonus | Candy Box | Pack Granny's chocolates | fixed list (AR09), budget (FT07), colour targets, Mallow's paw | prankster | clean, hurried | Box 32 in 60 s | 4×4, H2 | fixed: Big Cube P, Big Cube V, I M, I M, O P, O M | 0.55 | out of pieces / 60 s | ≤ 1 min | 45 / 30 s* |
| H1 | candy_h1 | Moody Gummies | The gummies sulk | **moody gummies (SP20)** + pops | mood | busy | Clear 7 | 6×6, H10 | 8 Std | 1.00 | rescue, 1 | ~6.5 min | 330 / 230 s |
| H2 | candy_h2 | Frosting Factory | Frosting jammed the lane | **frosting tiles (SP29)** + syrup | mood | busy | Rescue all (peel 6 tiles) | 8×4 lane, H10 + starter | 8 Std | 1.00 | rescue, 1 | ~6 min | 350 / 245 s |
| H3 | candy_h3 | Meringue's Rematch | She wants a do-over | **countdown bonbons (SP32)** + boss | watcher | busiest | Bonk 4 | 7×7 round, H14 + baked cake | I O T L Tripod Screws Chair | 1.05 | rescue, 1 | ~5.5 min | 280 / 200 s |

★ = prototype priority. \* Stars here are not the plain F1 time pair: 05 stars count frosted tiers (SC13; ★★★ also needs no cube trimmed), 06 and the bonus are hand-set times (★★★ also needs no cube trimmed), 08 counts clears (Scoring F4 shape). Star times elsewhere use Scoring & Stars F1 with `t_est = N × t_beat` (`t_beat = (A / 4.1 / 0.75) × t_piece`, `t_piece` 8 s; syrup and starter layers add time and are hand-adjusted). 02, 09 and 10 are hand-set because starter layers or stages make F1 overestimate. Length notes: 01, 02, 06, 08 and B are short on purpose; the validator's length warning is expected. Puzzle levels (campaign rule 15): the bonus is the fixed-list puzzle; 06 is a colour puzzle on a random list.

**Hard track (decision, as the Meadow).** `candy_bonus` is tier 11 (unlocks at 20 Candy stars). The remixes are **tiers 12–14** (`candy_h1`–`h3`); all three open when `candy_10` is finished. Neither the bonus nor the remixes count toward the next biome's star gate. Stars still pay as usual.

## 3. Layout overview

```text
01 sugar-cube tin  02 cake tin    03 lolly lane      04 jelly bridge   05 cake stand
####               #####          ########           ########          .####.
####               #####          ~~~S~~~~  (~ syrup) ###S####         ######
####               #####          ~~~~~~~~           ########         ######
####               #####          ########                            ######
                   #####                                              ######
                                                                      .####.
06 icing slab      07 gummy jar   08 candy-floss counter  09 fountain cube  10 cake table
########           .####.         #####                  ######            .#####.
########           ######         #####                  ######            #######
########           ######         #####                  ######            #######
(H3, flat)         ######         #####                  ######            #######
                   ######         #####                  ######            #######
                   .####.                                ######            .#####.
```

## 4. Critical path and optional paths

- **Critical path**: 01 → 10 in order (linear inside a biome). Finishing 10 completes Candy; the next biome opens with 15 of 30 Candy stars.
- **Optional**: ★★★ targets on every level; the gummy duck in 01–02; the bonus Candy Box (20 stars); hard-track remixes H1–H3 (after 10); Mizzle's postcard 2 (earned in the bonus).

## 5. Pacing chart

```text
strangeness (how far from classic)
 high |                                      #  #
      |                         #            #  #
  mid |               #  #      #  #      #  #  #
      |         #  #  #  #  #  #  #  #   #  #  #
  low |   #  #  #  #  #  #  #  #  #  #   #  #  #
      +-01-02-03-04----05-06----07-08----09-10--B
        learn sticky   no-fail   pop sprint remix FINALE
```

Zig-zag, not a ramp: two teaching levels (01 colour bonus, 02 gumdrops) → two "sticky" levels (03 syrup, 04 jelly) → two no-fail breathers (05 tower, 06 picture) → the big step (07 colour pop, long) → a short frantic sprint (08) → the long hard remix (09) → the two-stage finale (10). Short and long levels alternate (campaign rule 12); no two pressure peaks in a row before the finale.

---

## 6. Level specs (encounter lists, sketches, beats)

Skit abbreviations: **I** intro (≤ 3 s, ends on the hand-off), **P** payoff (≤ 5 s), **M** Mizzle clue (slots 03–09, strength 1, ≤ 1.5 s, never over the grid or during a warning), **R** reactions (one bubble at a time, ≤ 1 s). Every level has one music id placeholder (`music`, a catalogue id; one track per level, supplied by the user).

### 01 Sugar Cube Start

**Story card.** Mallow needs a foundation for Granny's cake. Lay sugar-cube layers; a layer all in one flavour sparkles and pops an extra layer for free. · **Mallow: mood swing** (happy: points at the emptiest cell, 1 catch; grumpy: cosmetic bounce only).
**Beats.** **I**: Mallow drags a giant recipe card, points at the empty tin, then up at the gumdrop clouds. **P**: the base sets with a "ding"; Mallow hops on it to test it and sticks to the top, feet first. **M**: none (slots 01–02 carry no clue). **R**: `heart` on a clear, `question` on a warning, `sweat` on a top-out.
**Stage**: clean, calm; a sugar-cube tin on a lace-doily island. **Light**: steamy morning (B). **Music**: `mus_candy_01`.

```text
Recipe: BL01 (4×4, H8) · AR01 · CV01 · GO01 (4) · FT01 (2 warnings) · CL07 Mono Layer (mono_extra_layers 1) + CO01 · SE05 duck · WO08 + WO11 (1 catch)
One sentence: "Fill a layer to clear it; one flavour = sparkle."
```
**Atoms**: non-default CL07 (**new**). 1 non-default, 1 new.
**Encounters**: none (classic). Pieces I, O, T, L, S flat shapes; `opening_set` [O, I], count 2; 2 flavours (P, V), `colour_streak` 0.6. `T_level` 180. Mono telegraph: a layer ≥ 50% filled and still one flavour shows a thin ring in that colour.
**Goal / fail**: Clear 4; top-out rescue, 2 warnings. **Stars**: ★★ 145 s, ★★★ 105 s (a sparkle saves about 25 s, so colour helps but is never needed). **Length**: ~3 min (short on purpose).

```text
top-down 4×4      side (z = 1)
####              11 . S S .   spawn zone
#S##               8 ========  danger line
####               :
####               0 . . . .   the tin floor (lace doily)
```
**How it plays**: (1) an O drifts down slowly; Mallow points at a corner. (2) The first clear in about 4 pieces: the tin sinks a step, a "ding". (3) Two pink pieces in a row: a ring appears on the half-pink layer and Mallow wiggles her ears (hint). (4) The fourth clear sets the base.
**Readability**: flavour patterns on every cube; the ring is the only colour telegraph; the landing ghost keeps its outline style.
**Teaches**: the controls re-taught in Candy clothes, and the first sight of flavour as an optional bonus. **Wacky test**: surprising, a one-flavour layer explodes into sparkle and takes the next layer; silly, sugar cubes squeak like marshmallows when they lock; funny failure, the base slumps and Mallow faceplants; big moment, the first sparkle, a sugar firework over the tin.

```json
{ "schema": 1, "id": "candy_01", "biome": "candy", "tier": 1, "name": "LVL_CANDY_01_TITLE",
  "board": { "width": 4, "depth": 4, "h_play": 8, "down_axis": "-y" },
  "pieces": { "shapes": ["i","o","t","l","s"], "opening_set": ["o","i"], "opening_count": 2 },
  "knobs": { "fall.g0": 0.65, "goal.top_out": "rescue", "goal.warnings_max": 2,
             "spawn.colour_count": 2, "spawn.colour_streak": 0.6, "goal.t_piece_s": 8 },
  "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "mono_layer", "params": { "mono_extra_layers": 1 } },
             { "id": "mascot_mood", "params": { "prank": "bounce" } },
             { "id": "mascot_catch", "params": { "catches": 1 } },
             { "id": "angle_gem", "params": { "skin": "gummy_duck" } } ],
  "stars": { "t2": 145000, "t3": 105000 }, "seed": null, "music": "mus_candy_01",
  "story": { "title_key": "LVL_CANDY_01_TITLE", "premise_key": "LVL_CANDY_01_PREMISE", "mascot_role": "mood_swing", "icon": "sugar_cube" } }
```

---

### 02 Gumdrop Hail

**Story card.** It hails gumdrops, and they stick wherever they land. Granny's cake tin has three pockets shaped like pieces; fill them, and use the gumdrops as free plugs. · **Mallow: mood swing** (happy: points at the pocket the piece fits, 1 catch; grumpy: cosmetic bounce).
**Beats.** **I**: Mallow holds out an umbrella; a gumdrop bonks through it and sticks to her nose. **P**: the tin pops the layers out like a jelly mould; Mallow peels the gumdrop off her nose and eats it. **M**: none. **R**: `exclaim` when a gumdrop sticks, `heart` on the double clear.
**Stage**: busy; a cake tin set into a giant cupcake, gumdrop clouds overhead. **Light**: steamy morning (B). **Music**: `mus_candy_02`.

```text
Recipe: BL05 (5×5, H10, 2 starter layers with 3 pockets) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL07 + CO01 · EV04 Gumdrop Hail · SE05 duck · WO08 + WO11 (1 catch)
One sentence: "Gumdrops stick where they land; use them as plugs."
```
**Atoms**: non-default BL05, CL07, EV04 gumdrop (**new**: the sticky object). 3 non-default, 1 new. Gumdrop stickiness is a property of the gumdrop object (a `content` rule), not the M3 mechanic, so the mechanic slot stays CL07.
**Encounters**: three pockets, each exactly fillable by one piece: A **T** (layer 1 only, floor below), B **L** (layer 1 only), C **Tripod** (top L-tromino in layer 1, one hole below the corner in layer 0). Starter stone has no flavour. **Gumdrop Hail** (EV04): every 4 locks a 1-cube gumdrop (a flavour) falls onto a free top-surface cell marked by a shadow one lock ahead, max 6 on the board, `hail_after_locks` 6 and `avoid_start_holes` true so a gumdrop never plugs a starting pocket. It locks on first touch. Counter: *use it* (park a 1-cell gap under the shadow). Pieces 8 Standard; `opening_set` [T, L, Tripod] (a bag, random order). 2 flavours.
**Goal / fail**: Clear 3 (the two starter layers clear together as a double); top-out rescue, 1 warning. **Stars**: ★★ 125 s, ★★★ 90 s (hand-set). **Length**: ~2.5 min (short on purpose).

```text
layer 0     layer 1     side (z = 2)
#####       ...#.       10 ===========
#####       #.##.        :
#####       ###..        1  # # . # #   T pocket at x0–2 (z0), L pocket at x3–4, tripod top at x0–1 (z3–4)
.####       ..###        0  # # # # #   one hole under the tripod corner (x0, z3)
#####       .####
```
**How it plays**: (1) a T spawns; Mallow points at its pocket. (2) The L and the Tripod fill the other two; both starter layers clear as a double. (3) After the 6th lock a shadow appears; a gumdrop hails onto it and sticks. (4) The player leaves a 1-cell gap under the next shadow and gets a free plug; the third clear finishes.
**Readability**: the shadow is the only forecast; gumdrop clouds part when the hail ends; pockets are outlined.
**Teaches**: a falling object you do not steer (the shadow), and that sticky things are plugs. **Wacky test**: surprising, blocks fall that you do not steer; silly, gumdrops boing when they land; funny failure, a gumdrop lands in a gap meant for a piece and Mallow facepalms; big moment, the last pocket fills and the tin pops like a jelly mould.

```json
{ "schema": 1, "id": "candy_02", "biome": "candy", "tier": 2, "name": "LVL_CANDY_02_TITLE",
  "board": { "width": 5, "depth": 5, "h_play": 10,
    "starting_contents": { "layers": {
      "0": ["#####","#####","#####",".####","#####"],
      "1": ["...#.","#.##.","###..","..###",".####"] } } },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right"], "opening_set": ["t","l","tripod"], "opening_count": 3 },
  "knobs": { "fall.g0": 0.70, "goal.top_out": "rescue", "goal.warnings_max": 1, "spawn.colour_count": 2, "spawn.colour_streak": 0.6 },
  "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "mono_layer", "params": { "mono_extra_layers": 1 } },
             { "id": "mushroom_popup", "params": { "object": "gumdrop", "sticky": true, "spawn_every_locks": 4, "objects_max": 6, "hail_after_locks": 6, "avoid_start_holes": true } },
             { "id": "mascot_mood", "params": { "prank": "bounce" } }, { "id": "mascot_catch", "params": { "catches": 1 } },
             { "id": "angle_gem", "params": { "skin": "gummy_duck" } } ],
  "stars": { "t2": 125000, "t3": 90000 }, "music": "mus_candy_02",
  "story": { "title_key": "LVL_CANDY_02_TITLE", "premise_key": "LVL_CANDY_02_PREMISE", "mascot_role": "mood_swing", "icon": "gumdrop" } }
```

---

### 03 Syrup River ★PROTO (cheap fourth)

**Story card.** Mallow sails a lollipop raft down a syrup river to fetch the cake's cream. Syrup slows the falling piece and glides it downstream on landing; build from the dock end. · **Mallow: mood swing** (happy: helper + 1 catch; grumpy: hops onto the falling piece and nudges it 1 cell, telegraphed by a crouch).
**Beats.** **I**: Mallow pushes off on a lollipop raft, gets stuck in the syrup and paddles in slow motion. **P**: the raft reaches the dock; Mallow lifts a cream jug, slips, and the syrup slowly carries her back. **M**: a tall droopy hat tip pokes above a gumdrop hedge at the rim, then dips. **R**: `sweat` when a piece glides past the gap, `note` on a clear.
**Stage**: busy; a long lollipop lane with a syrup river along the middle and a candy dock at the downstream end. **Light**: steamy morning (B). **Music**: `mus_candy_03`.

```text
Recipe: BL01 (8 wide × 4 deep, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL07 + CO01 · EV25 Syrup River · EV04 Gumdrop Hail callback · WO08 + WO11 (1 catch)
One sentence: "Syrup slows your piece and glides it downstream."
```
**Atoms**: non-default CL07, EV25 (**new**), EV04 (callback). 3 non-default, 1 new. Twists: syrup + hail = 2.
**Encounters**: **Syrup River** (EV25): `band_rows` z = 1–2 (all x), `syrup_slow` 0.5, `syrup_dir` +x, `syrup_glide` 2, ghost shows the glide end cell, arrows on the syrup. The dry rows z = 0 and 3 fall at normal speed: a choice between fast and careful. The wall at x = 7 is the dock and stops the glide (the brace, as Meadow 03). **Gumdrop Hail** callback: every 8 locks, max 3, sticky (no glide). Pieces 8 Standard, 2 flavours.
**Goal / fail**: Clear 4; top-out rescue, 1 warning. **Stars**: ★★ 335 s, ★★★ 235 s. **Length**: ~6.5 min.

```text
top-down 8×4 (syrup ~ glides →)    side (z = 1)
########                           13 . . . S S . . .   spawn
~~~S~~~~   → → → glide             10 ================
~~~~~~~~   → → →                    :
########                            0 . . . . . . . |   dock wall at x = 7
```
**How it plays**: (1) a piece over the river drops to a crawl: lots of aim time. (2) It lands and glides 2 cells toward the dock. (3) The player learns to build up from the dock wall so glides end flush; dry rows are a fast, careful choice. (4) The fourth clear; the raft docks.
**Readability**: syrup is a glossy amber band with chevrons; the glide ghost is drawn in the piece's outline style; the arrow is world-anchored.
**Teaches**: a rule that acts after landing, with the ghost as the proof; the dock wall as an ally. **Wacky test**: surprising, a landed piece keeps moving; silly, the piece glides with a long sticky stretch-sound and syrup strings; funny failure, a piece glides past your gap and Mallow paddles after it; big moment, a clear makes the river shimmer and the raft lurches forward.

```json
{ "schema": 1, "id": "candy_03", "biome": "candy", "tier": 3, "name": "LVL_CANDY_03_TITLE",
  "board": { "width": 8, "depth": 4, "h_play": 10, "down_axis": "-y" },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right"] },
  "knobs": { "fall.g0": 0.75, "goal.top_out": "rescue", "goal.warnings_max": 1, "spawn.colour_count": 2, "spawn.colour_streak": 0.6 },
  "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "mono_layer", "params": { "mono_extra_layers": 1 } },
             { "id": "syrup_band*", "params": { "band_rows": [1,2], "syrup_slow": 0.5, "syrup_dir": "+x", "syrup_glide": 2 } },
             { "id": "mushroom_popup", "params": { "object": "gumdrop", "sticky": true, "spawn_every_locks": 8, "objects_max": 3 } },
             { "id": "mascot_mood", "params": { "prank": "hop_nudge" } }, { "id": "mascot_catch", "params": { "catches": 1 } } ],
  "stars": { "t2": 335000, "t3": 235000 }, "music": "mus_candy_03",
  "story": { "title_key": "LVL_CANDY_03_TITLE", "premise_key": "LVL_CANDY_03_PREMISE", "mascot_role": "mood_swing", "icon": "lollipop" } }
```

---

### 04 Jelly Wobble ★PROTO

**Story card.** A jelly bridge carries the cake to the party table. Jelly pieces bounce once and squish into gaps; after every clear the bridge jiggles and the stack settles down, same-flavour blobs sticking together. · **Mallow: mood swing** (happy: helper; grumpy: jumps on the bridge so the next piece bounces one extra cell). No catch (tier 4).
**Beats.** **I**: Mallow steps onto the bridge, it wobbles, she bounces twice and lands on her bottom. **P**: Mallow trampolines across the finished bridge carrying the cake and lands it on the table, perfectly. **M** (slot 04, ★ named by the brief): a droopy-hat silhouette sits in the lit bakery window, watching Granny's party (static, backdrop, no emote). **R**: `exclaim` on a bounce, `sparkle` when a blob drops whole.
**Stage**: busy; a wobbling jelly bridge between two cupcake cliffs. The one physics-silly level, but rule-based, not physics. **Light**: late morning (B+). **Music**: `mus_candy_04`.

```text
Recipe: BL01 (8×3, H9) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL07 + CO10 Gummy cascade · SP25 Jelly piece (1 per bag, jelly_bounce 1) · WO08
One sentence: "Jelly bounces and settles; same flavours stick together."
```
**Atoms**: non-default CL07, CO10 (**new**), SP25 (**new**). 3 non-default, 2 new.
**Encounters**: **Jelly piece** (SP25): on landing it hops 1 cell along its last move, then one cube may slump into the empty cell directly below it (hops are blocked by walls and the cliffs at x = 0 and 7). **Gummy cascade** (CO10): after a clear, same-flavour blobs fall as one rigid chunk and keep their overhangs, so holes fill themselves. Pieces 8 Standard, weights I, O, L × 1.5 (the bridge is shallow; the validator must confirm all 8 shapes fit 3 deep). 2 flavours.
**Goal / fail**: Clear 5; top-out rescue, 1 warning. **Stars**: ★★ 265 s, ★★★ 185 s. **Length**: ~5 min.

```text
top-down 8×3           side (z = 1), before → after a clear
########               y   before              after (gummy cascade)
###S####               3   P P . . V V . .     . . . . . . . .
########               2   # # # # # # # #  →  P P . . V V . .   blobs drop as chunks
                       1   # . # . # # . #     # . # . # # . #
cliffs at x = 0 and 7  0   # # # # # # # #     # # # # # # # #
```
**How it plays**: (1) a jelly piece lands, hops one cell and a cube slumps into the gap below. (2) The first clear: everything above jiggles down; a pink blob drops whole and keeps its overhang. (3) The player builds same-flavour blobs on purpose, because blobs hold their shape. (4) Fifth clear; the bridge settles.
**Readability**: jelly pieces are translucent with a wobble outline; the hop is shown on the ghost; blobs share a faint rim of their flavour.
**Teaches**: collapse can be a rule, and flavour can matter structurally (a second reason to care about colour). **Wacky test**: surprising, holes fill themselves after a clear; silly, jelly pieces boing and wobble for a second after they lock; funny failure, a jelly piece boings into the wrong gap and Mallow tries to pull it out by the ears; big moment, a clear makes the bridge jiggle and pink and white blobs drop as chunks.

```json
{ "schema": 1, "id": "candy_04", "biome": "candy", "tier": 4, "name": "LVL_CANDY_04_TITLE",
  "board": { "width": 8, "depth": 3, "h_play": 9, "down_axis": "-y" },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right"], "weights": { "i": 1.5, "o": 1.5, "l": 1.5 }, "tags": { "jelly": 1 } },
  "knobs": { "fall.g0": 0.80, "clear.collapse": "gummy", "goal.top_out": "rescue", "goal.warnings_max": 1, "spawn.colour_count": 2, "spawn.colour_streak": 0.6 },
  "goal": { "type": "clear", "N": 5 },
  "rules": [ { "id": "mono_layer", "params": { "mono_extra_layers": 1 } },
             { "id": "jelly_piece*", "params": { "per_bag": 1, "jelly_bounce": 1 } },
             { "id": "mascot_mood", "params": { "prank": "bridge_jump" } } ],
  "stars": { "t2": 265000, "t3": 185000 }, "music": "mus_candy_04",
  "story": { "title_key": "LVL_CANDY_04_TITLE", "premise_key": "LVL_CANDY_04_PREMISE", "mascot_role": "mood_swing", "icon": "jelly" } }
```

---

### 05 Cake Tiers

**Story card.** Build the cake up to the candles, one frosted tier at a time. A tier is frosted when half of it is one flavour, a different one from the tier below. Nothing clears; too high pops off. · **Mallow: mood swing** (happy: sits on top and points at the tier's flavour; grumpy: licks the next piece in the preview and swaps its flavour, telegraphed by a tongue).
**Beats.** **I**: Mallow stacks two tiny cakes, they topple; she looks at the candles high above and gulps. **P**: the candles light themselves; Mallow blows them out by accident and relights them with a sheepish grin; Meringue (on the shelf) rolls her eyes. **M** (slot 05, ★ named by the brief): a violet cuff takes one slice of cake from the bakery sill (1.2 s, backdrop). **R**: `sparkle` when a tier frosts, `dizzy` when a cube is trimmed. **Madame Meringue** first appears on the bakery shelf, sniffing.
**Stage**: clean, tense; a tiered cake stand on a pastry hill with a candle sign floating above. **Light**: late morning (B+). **Music**: `mus_candy_05`.

```text
Recipe: BL02 (6×6 round, 32 cells, H10) · AR01 · CV01 · M1 build race (GO02 Height 8, coverage 0.6 + CL14 + FT02 trim) · SC13 Tier frosting · WO08
One sentence: "Each tier: mostly one flavour, a new one each time."
```
**Atoms**: non-default BL02, M1 bundle, SC13 (**new**). 3 non-default, 1 new.
**Encounters**: no clears and no fail (trim). **Tier frosting** (SC13): `tier_layers` 2 (4 tiers over layers 0–7), `frost_share` 0.5; the HUD shows each tier's leading flavour as icing. The candle sign sits at layer 7 and needs 60% of 32 = 20 cubes. Pieces 8 Standard + Big Cube (w 0.5); 3 flavours, `colour_streak` 0.4. Note: a tier can only be planned because flavour-B pieces can go in a side tower while tier 1 gets flavour-A pieces (support allows towers).
**Goal / fail**: Height 8 (coverage 0.6); trim, never fails. **Stars (colour is the rule here)**: ★ reach the candles; ★★ 3 of 4 tiers frosted; ★★★ 4 of 4 frosted and no cube trimmed (`stars: {s2: 3, s3: 4}`, a small Scoring extension). **Length**: ~4.8 min (about 36 pieces).

```text
top-down 6×6 round   side (z = 2)
.####.               13 . . S . . .   spawn
######               10 ============  danger line (trim)
######                7 - - - - - -   candle sign (layer 7, 60%)
######                :   tier 4 (layers 6–7), tier 3 (4–5), tier 2 (2–3)
######                0   tier 1 (layers 0–1)
.####.
```
**How it plays**: (1) the first tier glows pink as pink pieces land. (2) A vanilla piece arrives; the player tucks it at the edge (half the tier may be other flavours). (3) Tier 2 must lead with a new flavour. (4) Messy stacking makes Mallow lick the preview, so tidiness now protects your colours.
**Readability**: tier boundaries are drawn as thin icing lines on the island rim; the leading flavour shows as a small icing swirl; the trim line is a dashed sprinkle border.
**Teaches**: flavour as a planning layer, with no pressure (no clears, no fail). **Wacky test**: surprising, stars come from colour, not time; silly, each frosted tier squirts a frosting rim and a cherry plops on top; funny failure, an unfrosted tier sags like a sad sponge and a trimmed cube bounces off to Meringue, who eats it; big moment, the fourth tier frosts and the candles burst alight.

```json
{ "schema": 1, "id": "candy_05", "biome": "candy", "tier": 5, "name": "LVL_CANDY_05_TITLE",
  "board": { "width": 6, "depth": 6, "h_play": 10, "mask": [".####.","######","######","######","######",".####."] },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right","big_cube"], "weights": { "big_cube": 0.5 } },
  "knobs": { "fall.g0": 0.85, "goal.top_out": "trim", "spawn.colour_count": 3, "spawn.colour_streak": 0.4 },
  "goal": { "type": "height", "H_target": 8, "height_coverage": 0.6 },
  "rules": [ { "id": "build_race", "params": { "top_out": "trim" } },
             { "id": "tier_frosting*", "params": { "tier_layers": 2, "frost_share": 0.5 } },
             { "id": "mascot_mood", "params": { "prank": "lick_swap" } } ],
  "stars": { "s2": 3, "s3": 4 }, "music": "mus_candy_05",
  "story": { "title_key": "LVL_CANDY_05_TITLE", "premise_key": "LVL_CANDY_05_PREMISE", "mascot_role": "mood_swing", "icon": "cake_tiers" } }
```

---

### 06 Icing Picture

**Story card.** Pipe a picture on top of the cake in two icings: a bunny face with two candles (a picture, never words). Every cell wants its own icing; rainbow sprinkles fit anywhere. · **Mallow: mood swing** (happy: licks one smudged cell clean every 6 locks; grumpy: licks a correct cell into a smudge, telegraphed, at most 2 per level). This is where her mood becomes real help or harm.
**Beats.** **I**: Mallow holds up a crayon drawing of a bunny with candles, then looks at the bare white cake top. **P**: the picture finishes; the bunny winks and the two candles light; Mallow licks the piping bag clean, cross-eyed. **M** (slot 06): one extra paper plate sits on the party table, untouched (backdrop). **R**: `sparkle` when a flavour matches, `sweat` on a smudge.
**Stage**: clean, calm; a flat cake top on a turntable, piping bags around. **Light**: late morning (B+). **Music**: `mus_candy_06`.

```text
Recipe: BL01 (8×8, H3) · AR01 · CV02 spin only (icing lies flat) · M2 fill shape (GO03 with colour targets, 44 cells, win at 38 correct + CL14 + FT02 trim) · SP27 Rainbow sprinkle (1 per bag) · WO08
One sentence: "Match each cell's icing colour."
```
**Atoms**: non-default CV02, M2 bundle (colour targets are its param), SP27 (**new**). 3 non-default, 1–2 new.
**Encounters**: a **smudge** is a wrong-flavour cube on a target cell: it stays and does not count. Cubes on plate cells (no target) are free. Rainbow sprinkles match any flavour. Pieces I, O, T, L, S, Duo, Tri-Straight, Tri-Corner (flat set). Flavour weights `P 0.3 / V 0.7` match the picture (12 strawberry and 32 vanilla cells). 2 flavours + rainbow.
**Goal / fail**: Picture, 38 of 44 correct; trim above layer 2 (anything stacked high pops off), never fails. **Stars**: ★★ 160 s, ★★★ 115 s and no cube trimmed (a smudge-free picture is bragging rights, not a star condition). **Length**: ~3 min (short on purpose).

```text
colour targets, layer 0 (P strawberry, V vanilla, . plate)   side (z = 3)
.V.PP.V.   candles (P)                                        3 ==========  trim line
.VP..PV.   ears                                               :
.VP..PV.                                                      0 V V V V V V V V   plate row
VVVVVVVV   head
V.VVVV.V   eyes (holes)
VPVPPVPV   cheeks and nose
.VVVVVV.
..VPPV..   smile
```
**How it plays**: (1) a pink L arrives; the player finds a pink patch it fits. (2) A vanilla piece has nowhere tidy to go; the player learns to park it on the plate rim. (3) A rainbow sprinkle piece fixes an awkward mixed corner. (4) Keeping the board tidy keeps Mallow happy, and she licks smudges away.
**Readability**: target cells carry a flavour glyph and the flavour pattern; smudges show a small crossed-eye face (a pose, not text); a correct cell sparkles.
**Teaches**: colour as a goal, not a bonus, in a no-fail setting. **Wacky test**: surprising, the right shape in the wrong colour does not count; silly, the bunny appears cell by cell and changes expression as it fills; funny failure, smudges give the bunny a moustache and Mallow giggles; big moment, the last cell completes the picture and it winks.

```json
{ "schema": 1, "id": "candy_06", "biome": "candy", "tier": 6, "name": "LVL_CANDY_06_TITLE",
  "board": { "width": 8, "depth": 8, "h_play": 3, "down_axis": "-y" },
  "pieces": { "shapes": ["i","o","t","l","s","duo","tri_straight","tri_corner"], "tags": { "rainbow": 1 } },
  "knobs": { "fall.g0": 0.85, "goal.top_out": "trim", "spawn.colour_count": 2, "spawn.colour_weights": { "P": 0.3, "V": 0.7 },
             "control.rotation_axes": ["spin"] },
  "goal": { "type": "shape", "win_correct": 38,
    "target_shape": { "colours": true, "layers": { "0": [".V.PP.V.",".VP..PV.",".VP..PV.","VVVVVVVV","V.VVVV.V","VPVPPVPV",".VVVVVV.","..VPPV.."] } } },
  "rules": [ { "id": "fill_shape", "params": { "top_out": "trim" } },
             { "id": "rainbow_piece*", "params": { "per_bag": 1 } },
             { "id": "mascot_mood", "params": { "prank": "smudge", "smudge_cap": 2, "happy_lick_every_locks": 6 } } ],
  "stars": { "t2": 160000, "t3": 115000 }, "music": "mus_candy_06",
  "story": { "title_key": "LVL_CANDY_06_TITLE", "premise_key": "LVL_CANDY_06_PREMISE", "mascot_role": "mood_swing", "icon": "icing_bag" } }
```

---

### 07 Gummy Worms ★PROTO

**Story card.** Cheeky gummy worms crawl out of the jar and nibble the stack. Pop same-flavour groups to send them packing before they wriggle off with a cube. **Colour now clears**: 6 or more touching cubes of one flavour pop, and full layers still clear. · **Mallow: mood swing** (happy: points at a group 1 cube short; grumpy: tickles a worm awake, so it moves twice next lock).
**Beats.** **I**: Mallow reaches into the jar; a worm pops out, steals her lollipop and wriggles off. **P**: the last worm is popped; the three worms sulk back into the jar; Mallow screws the lid on and sits on it. **M** (slot 07): a lopsided sugar cube sits on the sill where the slice was (backdrop). **R**: `exclaim` when a worm moves, `heart` on a pop.
**Stage**: busy; a round glass candy jar planted like a gummy garden, lid off, worms peeking out. Meringue on the shelf, amused. **Light**: afternoon (D). **Music**: `mus_candy_07`.

```text
Recipe: BL02 (6×6 jar: corners off, 32 cells, H10) · AR01 · CV01 · GO01 (6 clears: pops or layers) · FT01 (1) · CL05 Colour Pop (pop_min 6, pop_min_pieces 2, layer_clear_too true) + CO02 cascade · SP31 Gummy worm · WO08
One sentence: "Six of one flavour pop; pops chase the worms."
```
**Atoms**: non-default BL02, CL05 (**new**), SP31 (**new**). 3 non-default, 2 new. (CL05 carries its own cascade collapse, M5a.)
**Encounters**: **Gummy worms** (SP31): 2 at the start (floor cells, harmless until a cube sits next to them) and 1 more crawls in from the jar mouth at 60 s; each lock a worm moves to a neighbouring cube and eats it; a pop or clear in or next to it pops the worm (*clear to cancel*); a worm that reaches the rim with a cube leaves with it (a star condition). The M5d telegraph: a group exactly 1 cube short glows in its flavour. Pieces 8 Standard, 3 flavours.
**Goal / fail**: Clear 6 (pops or layers); top-out rescue, 1 warning. **Stars**: ★★ 330 s, ★★★ 235 s and no worm escaped with a cube. **Length**: ~6.5 min.

```text
top-down, layer 0 (w worm)   side (z = 2)
......                       10 ============
.w....                        :
......                        1 . . . . . .
....w.                        0 . w . . w .   worms start on the floor
......
......   mask: .####. / ###### x4 / .####.
```
**How it plays**: (1) a pink piece lands near a worm; a pink group 1 short glows. (2) The next pink piece pops the group; the worm next to it boings away. (3) The player learns to build flavour groups near worms. (4) At 60 s a third worm crawls in from the jar mouth; the last clears are a chase.
**Readability**: worms are bright, saturated, with a crumb moustache; their next-cube arrow shows one lock ahead; the 1-short glow is the only pop cue.
**Teaches**: colour clears (the biome's heart), with a pest that makes pops urgent. **Wacky test**: surprising, colour now clears, not just layers; silly, worms chew with cartoon crunches; funny failure, a worm reaches the rim and waves goodbye carrying your cube like a trophy; big moment, a pop next to a worm launches it out of the jar in a "boing".

```json
{ "schema": 1, "id": "candy_07", "biome": "candy", "tier": 7, "name": "LVL_CANDY_07_TITLE",
  "board": { "width": 6, "depth": 6, "h_play": 10, "mask": [".####.","######","######","######","######",".####."],
    "starting_contents": { "layers": { "0": ["......",".w....","......","....w.","......","......"] } } },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right"] },
  "knobs": { "fall.g0": 0.93, "clear.detector": "colour_connect", "clear.collapse": "cascade",
             "goal.top_out": "rescue", "goal.warnings_max": 1, "spawn.colour_count": 3 },
  "goal": { "type": "clear", "N": 6 },
  "rules": [ { "id": "colour_pop", "params": { "pop_min": 6, "pop_min_pieces": 2, "layer_clear_too": true } },
             { "id": "pest", "params": { "skin": "gummy_worm", "ant_every_locks": 1, "late_spawn_s": 60, "rim_escape": true } },
             { "id": "mascot_mood", "params": { "prank": "tickle_worm" } } ],
  "stars": { "t2": 330000, "t3": 235000 }, "music": "mus_candy_07",
  "story": { "title_key": "LVL_CANDY_07_TITLE", "premise_key": "LVL_CANDY_07_PREMISE", "mascot_role": "mood_swing", "icon": "gummy_worm" } }
```

---

### 08 Sugar Rush

**Story card.** Mallow ate the whole candy bowl. While the tower is messy she is on a sugar rush and everything speeds up; tidy it and she calms down. Hang on for 2:30 until she crashes into a nap. Big pops leave candy bombs. · **Mallow: mood swing, and her mood IS the event.**
**Beats.** **I**: Mallow eats one candy, then the bowl, then the wrapper; her eyes spin. **P**: at 2:30 Mallow crashes mid-hop into a nap on top of the stack, snoring; the speed drops; a wrapper floats down onto her like a blanket. **M** (slot 08): the mail-cloud's shadow passes over the cake (backdrop). **R**: `dizzy` at max rush, `heart` when she calms.
**Stage**: clean, frantic; Granny's kitchen counter with a candy-floss machine puffing and an empty candy bowl. **Light**: afternoon (D). **Music**: `mus_candy_08`.

```text
Recipe: BL01 (5×5, H8) · AR01 · CV01 · GO04 (survive 150 s, ramp_per_min 0.15) · FT01 (1) · CL05 (pop_min 6, layer_clear_too) · EV17 Sugar Rush (bump_trigger mood) · SP04 + SP01 earned candy bomb (bomb branch only) · WO08
One sentence: "Messy tower, hyper Mallow, faster drops."
```
**Atoms**: non-default GO04 (callback), CL05 (callback), EV17 (**new**), candy-bomb bundle (**new**). 4 non-default, 2 new.
**Encounters**: **Sugar Rush** (EV17, mood trigger): while Mallow is grumpy, +1 notch every 10 s (max 3, +10% fall speed per notch, 1 s jitter warning); while happy, −1 notch. A pop of ≥ 7 leaves an SP01 **candy bomb** (3×3×3 blast when cleared), counter: *use it*. Sugar meter on the HUD (0–3 notches). Pieces 8 Standard, 3 flavours.
**Goal / fail**: Survive 150 s; top-out rescue, 1 warning. **Stars** (by clears, like Meadow 08, Scoring F4 shape): ★★ 2 clears, ★★★ 4 clears and no warning used. **Length**: 2.5 min (short on purpose).

```text
top-down 5×5      side (z = 2)
#####             11 . . S . .   spawn
#####              8 ==========   danger line (8 layers: tight)
##S##              :
#####              0 . . . . .
#####             HUD: Mallow's sugar meter (0–3 notches)
```
**How it plays**: (1) calm start; Mallow happy. (2) A messy drop leaves a hole; Mallow gobbles, shakes, and the fall speeds up a notch. (3) The player learns that a pop or a clear calms her. (4) A 7-pop leaves a candy bomb; clearing it blasts a hole in the mess. (5) 2:30: nap.
**Readability**: the sugar meter and her ear spin say the same thing as the notch; a jitter shimmer warns 1 s before each notch.
**Teaches**: the mascot as a living gauge (tidiness drives speed), a self-correcting difficulty. **Wacky test**: surprising, your tidiness controls the speed; silly, Mallow's ears spin like propellers at max rush; funny failure, the gooey slump while Mallow vibrates on top; big moment, a candy bomb blast clears the mess and snaps Mallow out of the rush mid-air.

```json
{ "schema": 1, "id": "candy_08", "biome": "candy", "tier": 8, "name": "LVL_CANDY_08_TITLE",
  "board": { "width": 5, "depth": 5, "h_play": 8, "down_axis": "-y" },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right"] },
  "knobs": { "fall.g0": 0.95, "clear.detector": "colour_connect", "clear.collapse": "cascade",
             "goal.top_out": "rescue", "goal.warnings_max": 1, "spawn.colour_count": 3 },
  "goal": { "type": "survive", "T": 150, "ramp_per_min": 0.15 },
  "rules": [ { "id": "colour_pop", "params": { "pop_min": 6, "layer_clear_too": true } },
             { "id": "speed_bump*", "params": { "bump_trigger": "mood", "notch_every_s": 10, "notch_max": 3, "notch_pct": 10, "warn_ms": 1000 } },
             { "id": "earned_specials", "params": { "bomb_at": 7, "rocket_at": 0, "colour_bomb_at": 0 } },
             { "id": "mascot_mood", "params": { "prank": "rush" } } ],
  "stars": { "s2": 2, "s3": 4 }, "music": "mus_candy_08",
  "story": { "title_key": "LVL_CANDY_08_TITLE", "premise_key": "LVL_CANDY_08_PREMISE", "mascot_role": "mood_swing", "icon": "sugar_rush" } }
```

---

### 09 Chocolate Fountain

**Story card.** Madame Meringue nudges the chocolate fountain; it tips the whole cake sideways and chocolate spreads over everything it touches. Licorice ties some cubes down. Pop next to the chocolate to stop it; clear next to the licorice to untie it. · **Mallow: mood swing** (happy: points at the cube the chocolate will take next; grumpy: splashes in the fountain, +1 spread step this lock). Meringue is on the fountain's rim, pushing.
**Beats.** **I**: Meringue leans on the fountain, it tips, and a chocolate wave washes Mallow off her feet. **P**: the fountain rights itself; Mallow comes up chocolate-coated and licks herself clean, delighted; Meringue huffs. **M** (slot 09): the bakery window curtain twitches shut as Mallow waves at it (backdrop). **R**: `exclaim` at the tilt warning, `dizzy` after the wave.
**Stage**: busiest; a plaza around a three-tier chocolate fountain, tipped to one side. **Light**: golden window (E, warm rim on the cake). **Music**: `mus_candy_09`.

```text
Recipe: BL05 (6×6×6 cube, 1 starter layer: 2 chocolate, 4 licorice) · AR01 · CV01 · GO01 (6 clears: pops or layers) · FT01 (1) · CL05 (pop_min 6, layer_clear_too) + CO10 Gummy cascade · EV11 Chocolate Spread · SP30 Licorice lock · EV03 Fountain Tilt (axis mode) · WO08
One sentence: "Stop the chocolate with pops; the cake tips sideways."
```
**Atoms (showpiece, ≤ 6)**: non-default BL05, CL05, CO10, EV11 (**new**), SP30 (**new**), EV03 axis-mode (callback). 6 non-default, 2 new. Twists: spread + tilt = 2; mechanic: CL05.
**Encounters**:
- **Chocolate Spread** (EV11): each lock, chocolate coats 1 neighbouring cube (it loses its flavour, so it cannot pop) unless a pop or clear touched chocolate that lock (*clear to cancel*). The next cube is marked one lock ahead.
- **Licorice** (SP30): a locked cube that cannot clear or move until a clear removes a cube next to it. It stays fixed to the island, so on a tilt cubes pile against it.
- **Fountain Tilt** (EV03, `flip_mode` axis, `flip_to_axis` −x, `flip_max` 1): after 2 clears or 50 s, 2 s warning (arrows and a countdown ring), the down axis turns to −x and the stack settles toward the fountain wall (x = 0) as rigid slices; the danger line and spawn move to the new top. The board is a **cube (W = D = H_play = 6)** so layers keep their 36 cells after the turn. It tips once and stays tipped (the second half is played sideways).
- Pieces 8 Standard, 3 flavours.
**Goal / fail**: Clear 6 (pops or layers); top-out rescue, 1 warning. **Stars**: ★★ 380 s, ★★★ 270 s (hand-set; starter layer). **Length**: ~7 min.

```text
top-down, layer 0 (c chocolate, l licorice, # stone)   side (z = 2), tilt ← to −x
#.#l.#                                                 6 ============
#c#.##                                                  :
..l#..                                                  1 . . . . . .
#.#l#.                                                  0 # . # . l #   chocolate side = fountain side (x = 0 after the tilt)
#c..l#
#.####
```
**How it plays**: (1) the chocolate creeps one cube per lock; a pop beside it stops the creep for that lock. (2) A layer clear next to a licorice lock unties it. (3) After 2 clears the fountain tilts: the stack falls toward x = 0 as gummy chunks, piling against licorice. (4) The player learns to pop on the chocolate side, which becomes the floor after the tilt.
**Readability**: chocolate is matte brown with a drip edge, never a flavour hue; licorice has a black-and-white bow tie; the tilt arrows are world-anchored; the fountain wall is drawn as a chocolate cascade so the new floor is obvious.
**Teaches**: a remix level: pop + gummy cascade (from 04 and 07) under a blocker that spreads, and the first big change of the down axis. **Wacky test**: surprising, the cake tips over sideways and keeps going; silly, chocolate drips upward after the tilt, then remembers gravity; funny failure, the whole stack ends up chocolate-brown and Mallow licks it anyway; big moment, the tilt, with a chocolate wave sloshing across the cake.

```json
{ "schema": 1, "id": "candy_09", "biome": "candy", "tier": 9, "name": "LVL_CANDY_09_TITLE",
  "board": { "width": 6, "depth": 6, "h_play": 6, "down_axis": "-y",
    "starting_contents": { "layers": { "0": ["#.#l.#","#c#.##","..l#..","#.#l#.","#c..l#","#.####"] } } },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right"] },
  "knobs": { "fall.g0": 1.00, "clear.detector": "colour_connect", "clear.collapse": "gummy",
             "goal.top_out": "rescue", "goal.warnings_max": 1, "spawn.colour_count": 3 },
  "goal": { "type": "clear", "N": 6 },
  "rules": [ { "id": "colour_pop", "params": { "pop_min": 6, "layer_clear_too": true } },
             { "id": "goo_spread", "params": { "skin": "chocolate", "per_lock": 1, "cancel_on_clear": true } },
             { "id": "licorice_lock*", "params": {} },
             { "id": "flip", "params": { "flip_mode": "axis", "flip_to_axis": "-x", "flip_every_layers": 2, "flip_every_ms": 50000, "flip_warn_ms": 2000, "flip_max": 1 } },
             { "id": "mascot_mood", "params": { "prank": "splash" } } ],
  "stars": { "t2": 380000, "t3": 270000 }, "music": "mus_candy_09",
  "story": { "title_key": "LVL_CANDY_09_TITLE", "premise_key": "LVL_CANDY_09_PREMISE", "mascot_role": "mood_swing", "icon": "fountain" } }
```

---

### 10 Madame Meringue (finale: transformation) ★PROTO

**Story card.** **Stage 1, Batter**: fill the tin up to the oven line while Madame Meringue pipes icing dollops onto the cake with her bag (sabotage that is secretly free height). **BAKE!** The oven slams shut and the whole stack bakes into one giant sponge cake; her dollops bake into frosting. **Stage 2, Decorate**: Meringue hops on top of the cake. She always climbs to the highest spot (she wants to be the topper). Pop flavour groups right next to her to bonk her down; three bonks and she plops on top as the cake topper, upside down and furious. · **Boss: Madame Meringue**; Mallow cheers from the table (watcher); Granny dozes in her chair.
**Beats (canon, `dialogue-campaign-skits.md` §2).** **I** (boss intro, 3 s): 0.0–1.0 Meringue squeezes the piping bag and builds herself a wobbly icing throne on the cake top; 1.0–2.0 she sits, shoos Granny's candles aside (`smug`), Mallow gasps (`exclaim`); 2.0–3.0 hand-off: Mallow looks up, glint, first piece. **P** (finale, 6 s; replay keeps beats 4–5): 1. the last bonk, the throne slumps and Meringue somersaults off it (`dizzy`); 2. she plops upside-down on the cake top as the topper, stuck, legs kicking (`angry`); 3. Mallow bounces onto the cake, sticks to the icing, peels off (`heart`), **keepsake pop: the cherry**; 4. Granny leans in and blows out the candles, a puff of smoke rings Meringue's head; 5. **M (the biome's thread beat)**: on the bakery sill a violet cuff sets down a tiny white star, which pops (the thank-you). The violet ribbon flag stays on the piping bag as set dressing with no camera hold. **R**: `smug` on a warning used, `dizzy` on a bonk.
**Stage**: busiest; Granny's cake table on the bakery's front step, a giant oven hood hanging over a round cake tin, the lit bakery window behind. **Light**: golden window (E). **Music**: `mus_candy_10` (the user may split stages inside the single track).

```text
Recipe: BL02 (7×7 round: corners off, 45 cells, H14) · AR01 · CV01
Stage 1: GO02 (height 4, coverage 0.6) + CL14 + FT02 trim  (M1 behaviour, inside BL21)
Bake:    BL21 Bake NEW (the level's one mechanic): cubes → sponge, dollops → frosting SP29, goal/detector/top-out switch
Stage 2: GO31 Bonk the boss NEW (3 bonks) · CL05 (pop_min 6) + CO10 Gummy cascade · FT01 (1 warning) · SP41 Climber boss NEW (Meringue, 2×2×1)
Twist:   EV04 Meringue Dollop (every 5 locks, 1 icing cube, forecast one lock ahead)
One sentence: "Fill the tin; then bonk Meringue off the top."
```
**Atoms (showpiece, ≤ 6)**: non-default BL02, BL21 (stage bundle incl. M1 behaviour and the stage goals), CL05, CO10, SP41 + GO31 (boss bundle), EV04. 6 non-default, 2 new (BL21, SP41/GO31). One mechanic (BL21), one twist (EV04), one content type (the boss). Count assumes the stage goals are part of BL21 (flagged to the module owner).
**Encounters**:
- *Stage 1*: no clears, no fail (trim above the line). Each dollop takes a cell, free height now and frosting later. Clever players bury dollops low, where frosting will not matter. Height 4, oven line at layer 3 needs 27 of 45 cells (60%).
- *Bake*: when the line is met, a 2 s oven-timer warning, then the oven slams (3 s staging cut-in, sim applies at S4a). The sponge is solid floor and never clears; frosting on the top surface peels one layer per adjacent pop and blocks groups meanwhile. Goal, detector and top-out switch to the stage-2 values.
- *Stage 2*: Meringue always moves to the highest 2×2 spot she can reach. The player builds a tall pillar of one flavour, lets her climb onto it, then pops the group touching her: bonk, she tumbles to the lowest neighbouring spot, then climbs again. Dollops (now frosting) continue every 5 locks; a pop during a marked dollop's 1 s wind-up cancels it (*clear to cancel*). Fail (stage 2 only): the cake slumps, Mallow faceplants, Meringue sits on the heap like a crown.
- Pieces I, O, T, L, Tripod, Screw-Left, Screw-Right, Chair; 3 flavours.
**Goal / fail**: Stage 1 height 4 → Stage 2 bonk 3. Top-out trim → rescue, 1 warning. **Stars**: ★★ 340 s, ★★★ 240 s. **Length**: ~6.5 min (stage 1 about 3.4 min, stage 2 about 3 min).

```text
top-down 7×7 round     side (z = 3)
.#####.                y    stage 1                     stage 2 (after BAKE)
#######                17   . . . S . . .               . . . S . . .
#######                14   =============               =============
###S###                 :                               . . M M . . .   Meringue on the highest spot
#######                 4   - - oven line - -           P P P # . . .   pink pillar under her
#######                 :   dollops d land here         s s f s s s s   f = frosting (an old dollop)
.#####.                 0   # # d # # # #               s s s s s s s   s = sponge (baked, solid)
```
**How it plays**: (1) stage 1: fill to the oven line while dollops pop in. (2) The oven timer ticks; BAKE, steam, the cake rises a notch with a "puff". (3) Meringue hops on top and climbs the highest spot. (4) Pop a flavour group under her: bonk, tumble, climb again. (5) The third bonk flips her upside down on top.
**Readability**: Meringue is warm cream with a dark outline and a sprinkle tiara (never pink or cyan sprinkles); her next climb spot shows a faint 2×2 outline; frosting is white with a ridge pattern; the sponge is flat tan with no pattern.
**Teaches**: the finale stacks what was learned (build race from 05, colour pop from 07, gummy cascade from 04) behind one clear verb per stage. **Wacky test**: surprising, the stack you built becomes a single baked cake and the rules change; silly, Meringue's dramatic climbs and her little "hmph" on each bonk; funny failure, the cake collapses and she rides it down, smug; big moment, the bake, then the final bonk flipping her upside down on top.

```json
{ "schema": 1, "id": "candy_10", "biome": "candy", "tier": 10, "name": "LVL_CANDY_10_TITLE",
  "board": { "width": 7, "depth": 7, "h_play": 14, "mask": [".#####.","#######","#######","#######","#######","#######",".#####."] },
  "pieces": { "shapes": ["i","o","t","l","tripod","screw_left","screw_right","chair"] },
  "knobs": { "fall.g0": 1.05, "goal.top_out": "trim", "goal.warnings_max": 1, "spawn.colour_count": 3 },
  "goal": { "type": "height", "H_target": 4, "height_coverage": 0.6 },
  "rules": [ { "id": "bake_stage*", "params": {
               "bake_warn_ms": 2000, "frost_layers": 2,
               "stage2": { "goal": { "type": "bonk_boss", "bonks_needed": 3 }, "clear.detector": "colour_connect", "clear.collapse": "gummy",
                           "goal.top_out": "rescue", "goal.warnings_max": 1 } } },
             { "id": "climber_boss*", "params": { "size": [2,2,1], "skin": "meringue" } },
             { "id": "mushroom_popup", "params": { "object": "icing_dollop", "spawn_every_locks": 5, "objects_max": 4 } },
             { "id": "mascot_mood", "params": { "role": "watcher" } } ],
  "stars": { "t2": 340000, "t3": 240000 }, "music": "mus_candy_10",
  "story": { "title_key": "LVL_CANDY_10_TITLE", "premise_key": "LVL_CANDY_10_PREMISE", "mascot_role": "watcher", "icon": "meringue" } }
```

---

### B Candy Box (bonus, tier 11, 20 Candy stars)

**Story card.** Granny is at the door in 60 seconds. Pack her chocolate box: each compartment is one flavour. Mallow's paw sneaks in and eats any sweet in the wrong compartment. · **Mallow: prankster with a heart** (WO07; she only eats mistakes).
**Beats.** **I**: the doorbell rings; Mallow panics, grabs the empty box, and licks her lips at the sweets. **P** (canon): 0.0–2.0 the last sweet slots in, the lid shuts with a ribbon; 2.0–4.0 Mallow sneaks one piece out of the corner, nibbles, freezes (`sweat`); 4.0–5.0 she slots the half-eaten piece back in, pats the lid (`heart`). Clearing it earns **Postcard 2** in the Scrapbook (no in-level change). **M**: none. **R**: `exclaim` when the paw is telegraphed, `sweat` when it eats.
**Stage**: clean, hurried; a heart-shaped chocolate box on a doily, a door with a shadow behind it. **Light**: bakery interior (H, oven glow). **Music**: `mus_candy_bonus`.

```text
Recipe: BL01 (4×4, H2) · AR09 fixed list [Big Cube P, Big Cube V, I M, I M, O P, O M] · CV01 · M2 (GO03 colour targets, 32 cells) + CL14 · FT07 out of pieces + time limit 60 s · WO07 Mallow's paw
One sentence: "Right flavour, right compartment, before the doorbell."
```
**Atoms**: non-default AR09, M2 bundle, FT07. 3 non-default, 0 new (all seen in the Meadow bonus and 06).
**Encounters**: preview 3; the door shadow and a bell are the visible clock. **Paw** (WO07, mascot layer): every 15 s, after a 2 s telegraph, the most recent piece sitting on a wrong-flavour target is eaten (removed); the list does not refill, so a wrong placement ends the run (retry is instant). Known solution: Big Cube P at x0–1, z0–1; Big Cube V at x0–1, z2–3; the two I mint along z at x2 and x3 on layer 0; then O P on layer 1 over x2–3, z0–1 and O M over x2–3, z2–3. Dealt in list order, every placement is supported. Stars: ★★ 45 s; ★★★ 30 s and the paw ate nothing.
**Goal / fail**: Box 32 cells in 60 s; out of pieces or the clock ends the run. **Length**: ≤ 1 min.

```text
colour targets      layer 0        layer 1       side (z = 1)
x:  0 1 2 3         P P M M        P P P P       2 ========
                    P P M M        P P P P       1 P P P P   (O pink on top of I mint)
                    V V M M        V V M M       0 P P M M
                    V V M M        V V M M
```
**How it plays**: (1) read the preview (Big Cube, Big Cube, I) and plan. (2) Soft or hard drop to beat the clock. (3) The two Big Cubes fill the left half; the I pieces lie along z. (4) The two O pieces close the lid; the lid slams on the bell.
**Readability**: each compartment shows its flavour glyph on the floor; the paw telegraph is a napkin tucked at the edge, then a hand shadow over the piece.
**Teaches**: nothing new; it is a short rehearsal of colour targets under a clock. **Wacky test**: surprising, misplaced sweets vanish; silly, Mallow's paw sneaking in with a napkin tucked in; funny failure, time runs out and Granny opens the door to Mallow with her face in the box; big moment, the lid slams on the bell.

```json
{ "schema": 1, "id": "candy_bonus", "biome": "candy", "tier": 11, "name": "LVL_CANDY_BONUS_TITLE",
  "board": { "width": 4, "depth": 4, "h_play": 2, "down_axis": "-y" },
  "pieces": { "fixed_list": [ {"shape":"big_cube","colour":"P"}, {"shape":"big_cube","colour":"V"}, {"shape":"i","colour":"M"},
                              {"shape":"i","colour":"M"}, {"shape":"o","colour":"P"}, {"shape":"o","colour":"M"} ] },
  "knobs": { "fall.g0": 0.55, "spawn.preview_count": 3, "goal.top_out": "budget", "goal.time_limit_s": 60 },
  "goal": { "type": "shape", "target_shape": { "colours": true, "layers": {
      "0": ["PPMM","PPMM","VVMM","VVMM"], "1": ["PPPP","PPPP","VVMM","VVMM"] } } },
  "rules": [ { "id": "fill_shape", "params": {} }, { "id": "mascot_paw", "params": { "every_s": 15, "warn_ms": 2000 } } ],
  "stars": { "t2": 45000, "t3": 30000 }, "music": "mus_candy_bonus",
  "story": { "title_key": "LVL_CANDY_BONUS_TITLE", "premise_key": "LVL_CANDY_BONUS_PREMISE", "mascot_role": "prankster", "icon": "chocolate_box" } }
```

---

## 7. Hard-track remixes (tiers 12–14; open after 10)

All three keep the biome's story tone: nobody is hurt; the intro and payoff are 3 s and 5 s. Budget: ≤ 4 non-default atoms (tiers 12+ are not showpiece tiers). No Mizzle clue.

### H1 Moody Gummies

**Story card.** The gummies are in a mood: a gummy that does not touch its own flavour sulks and refuses to pop. Cheer them up by finding them friends. · **Mallow: mood swing** (grumpy prank: tickles a happy gummy grumpy). **I**: a gummy crosses its arms and turns its back on a pile. **P**: a pop of three cheered-up gummies does a conga; Mallow joins at the end. **R**: `question` at a sulking gummy, `heart` when it joins. **Stage**: busy; the 07 jar, now crowded. **Light**: afternoon (D). **Music**: `mus_candy_h1`.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (7 clears: pops or layers) · FT01 (1) · CL05 (pop_min 6) · CO10 · SP20 Moody gummy (1 per bag)
Atoms: non-default CL05, CO10, SP20 (new). 3 non-default, 1 new.
```
A moody gummy is a 1-cube piece with a flavour: grumpy while no face-adjacent cube shares its flavour; grumpy cubes do not count for pops or for layer fullness. Colours 3. g0 1.00, top-out rescue, 1 warning. **Stars**: ★★ 330 s, ★★★ 230 s. **Length**: ~6.5 min. Remix of 07. Wacky: sulking gummies with crossed arms; a conga on a big pop.

```json
{ "schema": 1, "id": "candy_h1", "biome": "candy", "tier": 12, "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 1.0, "clear.detector": "colour_connect", "clear.collapse": "gummy", "goal.warnings_max": 1, "spawn.colour_count": 3 },
  "goal": { "type": "clear", "N": 7 },
  "rules": [ { "id": "colour_pop", "params": { "pop_min": 6, "layer_clear_too": true } }, { "id": "moody_cube", "params": { "per_bag": 1 } },
             { "id": "mascot_mood", "params": { "prank": "tickle_gummy" } } ],
  "stars": { "t2": 330000, "t3": 230000 }, "music": "mus_candy_h1" }
```

### H2 Frosting Factory

**Story card.** The syrup river jammed with frosting. Each frosting tile peels one layer per clear next to it; peel them all. · **Mallow: mood swing** (grumpy: nudge). **I**: a frosting tile plops onto the lollipop lane and Mallow tries to push it with her ears. **P**: the last tile melts into a puddle; Mallow licks it and gives a thumbs-up. **R**: `exclaim` when a tile peels. **Stage**: busy; the 03 lane clogged with cream. **Light**: late morning (B+). **Music**: `mus_candy_h2`.

```text
Recipe: BL05 (8×4 lane, H10, starter layer with 6 frosting tiles: 3 of 2 layers, 3 of 3 layers) · AR01 · CV01 · GO07 Rescue all (every frosting tile gone) · FT01 (1) · CL01 + CO01 · EV25 Syrup River (callback) · SP29 Frosting
Atoms: non-default BL05, GO07 (new), SP29, EV25 (callback). 4 non-default, 2 new.
```
Starter layer (`2` / `3` = frosting layers, `#` stone, `.` empty):
```text
x0..7
#.2#.3.#   z0
#2..#.3#   z1
##.3#.#.   z2
.#2.##.#   z3
```
Syrup as in 03 (`band_rows` [1,2], glide +x). g0 1.00, top-out rescue, 1 warning. **Stars**: ★★ 350 s, ★★★ 245 s. **Length**: ~6 min. Remix of 03. Wacky: frosting tiles squish and splat a little cream with each peel.

```json
{ "schema": 1, "id": "candy_h2", "biome": "candy", "tier": 13,
  "board": { "width": 8, "depth": 4, "h_play": 10, "starting_contents": { "layers": { "0": ["#.2#.3.#","#2..#.3#","##.3#.#.",".#2.##.#"] } } },
  "knobs": { "fall.g0": 1.0, "goal.warnings_max": 1, "spawn.colour_count": 3 },
  "goal": { "type": "rescue_all", "content": "frosting" },
  "rules": [ { "id": "syrup_band*", "params": { "band_rows": [1,2], "syrup_slow": 0.5, "syrup_dir": "+x", "syrup_glide": 2 } },
             { "id": "frosting*", "params": {} }, { "id": "mascot_mood", "params": { "prank": "hop_nudge" } } ],
  "stars": { "t2": 350000, "t3": 245000 }, "music": "mus_candy_h2" }
```

### H3 Meringue's Rematch

**Story card.** Madame Meringue demands a do-over on the already-baked cake, and this time she throws countdown bonbons: each ticks down per lock and splats a junk layer at zero unless you pop next to it. Four bonks this time. · **Mallow: watcher**; **Boss: Meringue** (the hard-track rematch with one extra trick). **I**: Meringue sits smugly on a pre-baked cake and tosses a bonbon in the air. **P**: Meringue bounces off, lands upside-down on top again, and Mallow gently adds a second cherry. **R**: `sweat` as a bonbon reaches 1. **Stage**: busiest; the 10 table, the oven hood raised. **Light**: golden window (E). **Music**: `mus_candy_h3`.

```text
Recipe: BL05 (7×7 round, H14, layers 0–3 of baked sponge) · AR01 · CV01 · GO31 (4 bonks) · FT01 (1) · CL05 (pop_min 6) · SP41 Climber boss · SP32 Countdown bonbon
Atoms: non-default BL05, CL05, SP41 + GO31 (bundle), SP32 (new). 4 non-default, 1 new. Plain cascade (no CO10): her tumbles are less predictable.
```
Bonbons are thrown every 8 locks (`cd_start` 8, −1 per lock, blast 1 junk layer at 0, *clear to cancel*). Starting layers 0–3: the 7×7 round mask filled with `s`. g0 1.05, top-out rescue, 1 warning. **Stars**: ★★ 280 s, ★★★ 200 s. **Length**: ~5.5 min. Remix of 10 (stage 2 only). Wacky: bonbons with tiny ticking faces that sweat at 1.

```json
{ "schema": 1, "id": "candy_h3", "biome": "candy", "tier": 14,
  "board": { "width": 7, "depth": 7, "h_play": 14, "mask": [".#####.","#######","#######","#######","#######","#######",".#####."],
             "starting_contents": { "layers": { "0": [".sssss.","sssssss","sssssss","sssssss","sssssss","sssssss",".sssss."],
                                                "1": "same as layer 0", "2": "same as layer 0", "3": "same as layer 0" } } },
  "knobs": { "fall.g0": 1.05, "clear.detector": "colour_connect", "clear.collapse": "cascade", "goal.warnings_max": 1, "spawn.colour_count": 3 },
  "goal": { "type": "bonk_boss", "bonks_needed": 4 },
  "rules": [ { "id": "colour_pop", "params": { "pop_min": 6 } }, { "id": "climber_boss*", "params": { "size": [2,2,1] } },
             { "id": "countdown_bomb*", "params": { "thrown_every_locks": 8, "cd_start": 8, "blast_layers": 1 } } ],
  "stars": { "t2": 280000, "t3": 200000 }, "music": "mus_candy_h3" }
```
(`"same as layer 0"` is shorthand for this sketch; the real file repeats the rows.)

---

## 8. Narrative beats

Wordless (campaign story rules): intro and payoff skits per level, Mallow's reactions, Madame Meringue in the backdrop from 05, and Mizzle's clue at strength 1 (a silhouette or a prop, never his face). Arc: Mallow lays the base (01), catches the hail (02), sails the syrup (03), crosses the jelly bridge (04, the hat in the window), builds the tiers while Meringue sniffs (05, the cuff takes a slice), pipes the bunny picture (06), chases the worms (07), rides the sugar rush (08), is tipped by the fountain (09), and bonks Meringue off the cake (10). The bonus and remixes are after-party gags.

- **Arrival (map, 4 s, first time)**: the wizard's cloud drifts over a floating bakery with warm steam; Mallow bounces out holding a birthday candle, sticks to the gumdrop path, peels off (`heart`); the camera pans up to Meringue on the roof, piping a curl onto her own head with the ribboned bag (`smug`); the flag flaps unnoticed.
- **Mizzle clue slots (strength 1, all optional, at most one per level, none in 01, 02 or 10's play)**: 03 hat tip over a gumdrop hedge; **04 ★ hat silhouette in the lit bakery window**; **05 ★ violet cuff takes one slice from the sill**; 06 one extra paper plate on the party table; 07 a lopsided sugar cube on the sill; 08 the mail-cloud's shadow over the cake; 09 the curtain twitches shut. The finale's own clue is the cuff's thank-you star (payoff beat 5). Dropping any optional clue leaves the story whole.
- **Map change (3 s, after the 10 payoff)**: the cake appears on the island with a cherry on top (Meringue upside-down on it, sulking); bunting with flag 2 (the ribbon from the piping bag, panel: a crooked tower of blocks) strings from the bakery sign back to the Meadow mill; the camera drifts to the horizon, where Mizzle's crooked tower gets a second floor with one block sticking out.
- **Keepsake**: a cherry, handed over by Granny off the cake. No friend joins in Candy.
- **Side island**: Tumble Fair opens after Candy (post-MVP; `design/levels/` has its own file).

## 9. Music and audio cues

One track per level, supplied by the user (no stems). Ids are placeholders; until a track exists the level falls back to the biome's `default_music` (`mus_candy_default`, a warning, not a failure). "Carefree" is a placeholder only. Biome record: `assets/data/biomes/candy.json`, `side_island: false`.

| Level | Track id | Mood brief for the track |
|---|---|---|
| 01 | `mus_candy_01` | Gentle music-box morning, steam and plucks |
| 02 | `mus_candy_02` | Light, bouncy gumdrop pizzicato |
| 03 | `mus_candy_03` | Slow, syrupy glides, a lazy raft |
| 04 | `mus_candy_04` | Wobbly jelly bass, springy |
| 05 | `mus_candy_05` | Calm, building tower theme (no danger music, since trim cannot lose) |
| 06 | `mus_candy_06` | Quiet, painterly, hushed concentration |
| 07 | `mus_candy_07` | Cheeky chase with crunchy percussion |
| 08 | `mus_candy_08` | Fast, sugary, bright; tempo suits a speed-up |
| 09 | `mus_candy_09` | Big, bubbling chocolate groove with a sideways lurch |
| 10 | `mus_candy_10` | Boss theme with a bakery waltz feel; a key change at the bake |
| B | `mus_candy_bonus` | Ticking doorbell march |
| H1–H3 | `mus_candy_h1`–`h3` | Remix flavours of 07, 03 and 10 |

Cues (SFX, not music): squeaks on locks (01), a soft "boing" on a gumdrop landing, a long stretch on syrup glide, a jelly boing, a chime on a frosted tier, a crunch per worm bite, a rising whirr for sugar rush notches, a bubbling loop for chocolate, an oven slam and steam hiss for the bake, a "hmph" on each bonk. Danger stinger only where `topout_rule` is rescue (not 05, 06, bonus). Skits use short stingers, never voices. Tiny wordless critter sounds are allowed, capped by concurrency.

## 10. Open questions

- **Colour source**: the `spawn.colour_source seeded` / `colour_streak` / `colour_weights` knobs (flavour per piece) are a spawner extension (cost S–M) for game-designer and godot-specialist. Fallback: one flavour per piece family. Blocks 05–10, B, H1–H3.
- **Provisional atom ids** (EV25, CO10, SC13, BL21, SP41, GO31) may collide with other writers' next-free ids; the module owner renumbers.
- **Budget reading (10)**: BL21 is counted as one mechanic that includes the stage goals and the M1 behaviour; the finale also runs one twist (dollops). Confirm with the module owner.
- **Fountain Tilt (09)**: axis mode needs a cube board and a camera answer (does the view re-orient? twist-library says "camera never flips" for stack mode only). A single tilt (`flip_max 1`) is used; a tilt-back would need a `flip_to_axis` cycle param.
- **Stars by tiers (05) and by clears (08)**: a small Scoring extension (`stars: {s2, s3}` in frosted tiers). Alternative: keep time stars and add "all tiers frosted" as a ★★★ condition.
- **SP29 frosting** peel rule, **SP30 licorice** under an axis tilt, **SP20 moody gummy** (is it a 1-cube piece?): candidate rules to write.
- **Clue slots**: `lore-world.md` places the hat at 05 and the cuff at 09 and the flag as the finale clue; the skits file (followed here) places the hat at 04, the cuff at 05 and the cuff's star in the finale. Narrative-director to confirm.
- **Tier-2 pocket check (02)**: the validator should confirm each pocket is exactly fillable by its named shape, and that all 8 Standard shapes fit the 3-deep bridge in 04.
- **Star times** are formula estimates; replace with playtest medians.
