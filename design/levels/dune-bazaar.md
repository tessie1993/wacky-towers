# Side Island: Dune Bazaar (levels 01–05, bonus)

> **Status**: Draft v1 for user review (level-designer, 2026-10-10). Written straight through under the /team-narrative round ("side islands also in full detail; designers decide, user reviews the finished result"). Post-MVP scope.
> **Author**: level-designer
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Format source**: `design/levels/meadow.md` (section for section), with the per-level layout of `design/levels/candy.md`.
> **Sources**: `production/narrative/campaign-story/brief.md` §4, `lore-world.md` §4.2 and X6, `dialogue-campaign-skits.md` §11.2, `visual-direction.md` §2.3 and §3.4, `design/gdd/mechanics-module.md` (atoms, F1 budget), `campaign-structure.md`, `level-data-definition.md` (rule 4f `side_island`), `scoring-stars.md`, `design/levels/meadow.md`, `candy.md`, `ice.md`, `underwater.md`, `lava.md` (what the player already knows).
> **Field definitions**: `design/gdd/level-data-definition.md`; defaults from the owning GDDs.

**Every number, name and beat in this file is a tunable default**, a starting point for the prototype and playtests. The validator enforces only the safe ranges in the owning GDDs. Atom status: **D** Designed, **C** Candidate, **Pr** Proposed; **NEW** = an atom this island needs that the library does not have yet (named, no id; §1).

---

## 1. Level name and theme

**Tuft's Big Trade.** Tuft the meerkat has one shiny pebble and wants to trade it up, stall by stall, into something wonderful. Blocks fall as a **sand drizzle** of glazed terracotta over mesa islands in the volcano's dry lee, under striped awnings and lanterns, in hot gold light with a mirage on the far dunes. Madame Sphinx, a reclining cat-sphinx who poses picture riddles, wants someone clever enough to answer one; she flips riddle cards that turn the sand soft and fill the plaza with mirages. In the finale she flips her last card, stares at it, solves it herself, purrs, and naps in the sun on the warm awning; Tuft steals her riddle cards. Cloud charm: **a lantern** hung from the wizard's cloud.

**A gag island, not a plot island.** Brief §4 and lore X6: no Mizzle plot beyond **one wink** (level 02), and **Madame Sphinx got no gift from Mizzle**: her riddles are her own. No friend joins; friends appear only as the player's chosen character (Lana and Boulder have joined by now on the main path, so Stitch and Smash may be on the button; Glim only after Cave). No postcard.

**Quirk: "Nothing is what it looks like."** The sand gives way, the plaza shows cubes that are not there, the ground walks off on a camel, and the boss speaks only in pictures. The pieces and the controls stay honest; the **landing ghost is always the truth**. Strangeness zig-zags across the five levels.

### Biome rules (decisions)

| Rule | Default |
|---|---|
| Unlock | Opens when `lava_10` is finished (no star gate). Biome record `assets/data/biomes/dune_bazaar.json`, `side_island: true` (level-data rule 4f): its levels never gate the main chain and its stars count toward no main gate |
| Size | 5 levels (tiers 1–5) + 1 bonus (tier 11). Slot 05 is the finale. **No hard track** (brief §4 and skits §11) |
| Islands | One per level (lore 4.2 A): spice stall, sinking-sand yard, mirage plaza, camel caravan, the sphinx steps; bonus: a merchant's tent. Settles into smooth sand with a ripple line |
| Stage | Busy diorama or clean stage per level; calm levels quiet, chaos levels busy. Backdrop: heat shimmer, drifting sand, lanterns |
| Arrival skit | First visit only, on the map, 4 s (skits §11.2) |
| Intro skit | A 3-second wordless mini-scene during the Countdown (no play time lost). Boss intro (05) from skits §11.2 |
| Payoff skit | ≤ 5 s on every win, tap to skip; finale 6 s on first play, last 2 beats on replays |
| Mascot | **Tuft** (Dune Bazaar only), **watcher** (WO09, staging only): pops up from holes at the rim, `question`, `sparkle`, `sweat`. In the bonus Tuft **points** at the next solution piece after 2 failed tries (WO12, Pr). No helper nudge, no catch |
| Boss | **Madame Sphinx** in 05 (lounging on an awning in the backdrop from 03). Wind-up tell (visual-direction 2.3): the paw lifts, the eyes narrow, the headdress glints. Her **riddle cards** are pictogram-only forecasts of her events (no text) |
| Friends | None join. Stitch (Lana) pins the stack, so a camel step is skipped while it holds; Smash (Boulder) removes sand like any cube. Star times are authored with no skill and no perks |
| Physics | None |
| Rubber duck | For sale on a stall shelf under the island in 01 and 02, with a price tag drawn as one coin (SE05, one low snap angle, tap to collect, no stars) |
| Events as bazaar events | Sinking sand (**NEW**) = **Soft Sand**; Mirage cube (**NEW**) = **Mirage**; Creature back (BL14) = **Camel Caravan**; Survive (GO04) = **Ride to the Oasis** |
| Failure gag (every level) | The stack slumps into a sand dune; the meerkat mob pops up all over it, looking around (`question`); Tuft pops out last with a jar on its head. In 05 Madame Sphinx licks a paw, unimpressed. Nobody is hurt |
| Light | Lore 4.2 F mapped to the shared archetypes (visual-direction §5.3): 01 hot morning (B), 02 white noon (C), 03 white noon + heat shimmer (C + I mirage overrides on far planes only), 04 amber afternoon (D), 05 lantern sunset (F), B tent shade (H) |
| Blocks / frame | Block set **Desert glazed terracotta** (`block-art-sets.md`; lore 4.2 E and visual-direction 3.4 agree). Frame: sun-bleached cedar with brass lantern hooks and a woven rug-fringe edge. Sand stays pale ochre-beige, low saturation, so it never reads as reward gold |
| Music | One full track per level, supplied by the user. Ids `mus_dune_bazaar_01`…`05`, `mus_dune_bazaar_bonus` are **placeholders**; unknown ids warn and fall back to the biome `default_music` |
| Prototype priority | **02, 03, 05** (★PROTO): the two new atoms and the boss |

**Common defaults** (unless a level says otherwise): weighted bag, 8 Standard shapes, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, all rotation axes (Turn / Flip / Roll, CV01), `t_piece` 8 s. Stars authored with no perks and no skill.

**Speed (side-island rule, proposed; same as Tumble Fair).** Level `L` uses campaign F2 with the biome it unlocks after and tier `2L`: `g0 = 0.6 + 0.045 × (2L − 1) + 0.06 × (b − 1)`, with **b = 5** (Lava). That gives 0.885 / 0.975 / 1.065 / 1.155 / 1.245; levels hand-set within ±0.05, a little under the line because the island is optional.

**Star times.** Scoring F1: `t_est = N × t_beat`, `t_beat ≈ 2.67 × A` s, `t2 = round5(0.85 × t_est)`, `t3 = round5(0.6 × t_est)`. Levels with starter layers (02, 05) and the bonus are hand-set; 04 uses Survive layer stars (Scoring F4).

**Budget (mechanics module F1).** At most 2 atoms new to the player and 4 non-default atoms per level; bundles (M1, M2) count 1; mascot atoms and secrets (WO09, WO12, SE05) count 0. Slot defaults: BL01, AR01, CV01, CL01, CO01, GO01, FT01. **"New" is counted against the shortest path to this island**: the Meadow, Candy, Ice, Underwater and Lava main paths (tiers 1–10) only; bonuses, remixes and Tumble Fair are optional. Known on that path, among others: BL02, BL05, BL06, BL11, BL12, AR02, AR13, EV01–EV07, EV09, EV12, GO04, M1, M2, PL01, PL02, PL07, SP35, SP40, FT07 and FT12 (Underwater 06). Not known: SP34, BL14. AR09 (fixed list) has appeared only in optional bonuses and Lava H3, so it is counted as new.

**Grids**: one string per row, row 0 = `z = 0` (back), character 0 = `x = 0` (left). Mask `#` active, `.` off. Starting contents: `#` sandstone (starter block), `s` soft sand, `.` empty. Targets `+`. Side views are a slice at one `z` row seen from the front; `=====` is the danger line at `H_play`, `S` the spawn zone, `:` skips empty rows.

### New atoms this island needs

Named, **no id** (the module owner assigns ids; the provisional ids other biome files already claimed are not reused). Each is one content rule written through `RuleApi`, deterministic, layer `content`.

| Name | Rule (one line) | Hook | Cost | Used in |
|---|---|---|---|---|
| **Sinking sand** (content `sand`) | A sand cell is solid for support but **never counts as filled**. When a piece locks and **every** cube of it that rests on something rests on sand, the piece sinks 1 cell rigidly: the sand under it is consumed and the piece takes its place (once per lock, before the clear check). A piece with any cube on solid ground does not sink and the sand stays | `RuleBehaviour` `on_lock` (S4a, before clears) | S | 02, 05 |
| **Mirage cube** (content `mirage`) | Every `mirage_every_locks`, `mirage_count` decoy cubes shimmer into empty cells on the top surface (seeded). A mirage is **not solid** (pieces and the ghost pass through it), never counts for clears, height or top-out, and pops when a piece passes through or locks over it, or after `mirage_life_locks` | `RuleBehaviour` `on_lock`, layer `twist` | S | 03, 05 |

Params on existing atoms (data only): **BL14** Creature back needs its edge rule pinned down: here the step is a **one-cell compact shift** toward `step_dir`: the stack moves 1 cell, cubes against the wall stay and anything behind a staying cube stays; nothing leaves the board, nothing falls (slice collapse is unchanged). **WO12** `hint_after_retries` 2 with a `solution` list (bonus).

Why not existing atoms: **SP34 Crumble cube** dissolves one cube after a delay (per cube, timed) and leaves a hole; soft sand needs a whole piece to settle into the sand it chose, so the result is a filled cell, not a hole. **EV02 Invisible blocks** hides real cubes; a mirage shows fake ones (the opposite read). Both new atoms reuse the EV04 telegraph and spawn code.

## 2. Estimated play time and summary

| # | id | Name | Story beat | New idea (atoms; **bold** = new to the player) | Tuft | Stage | Goal | Board | Pieces | g0 | Top-out | Length | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | dune_bazaar_01 | Spice Stall | Stock the spice stall | masked stall (BL02, known) | watcher | clean, calm | Clear 3 | 5×5 corners off (21), H9 | 8 Std; first 2 from {O, I} | 0.85 | rescue, 1 | ~2.8 min | 145 / 100 s |
| 02 ★ | dune_bazaar_02 | Soft Sand | The yard swallows things | **Sinking sand (NEW)**, starter yard (BL05) | watcher | clean, calm | Clear 3 | 6×6, H10 + sand yard | 8 Std; first 3 a bag of {O, L, T} | 0.95 | rescue, 1 | ~2.5 min | 140 / 100 s |
| 03 ★ | dune_bazaar_03 | Mirage Plaza | The oasis that wasn't | **Mirage cube (NEW)** | watcher | busy | Clear 4 | 6×6, H10 | 8 Std | 1.05 | rescue, 1 | ~6.4 min | 325 / 230 s |
| 04 | dune_bazaar_04 | Camel Caravan | Ride to the oasis | **Creature back (BL14)**, Survive (GO04) | watcher | clean, tense | Survive 150 s | 5×5, H9 | 8 Std | 1.12 (+0.15/min) | rescue, 1 | 2.5 min | 1 / 2 layers |
| 05 ★ | dune_bazaar_05 | Madame Sphinx | Boss: the last riddle | sand steps + mirages (callbacks), riddle cards | boss (Tuft cheers) | busiest | Clear 4 | 6×6, H12 + sphinx steps | 8 Std | 1.20 | rescue, 1 | ~5.9 min | 300 / 215 s |
| B | dune_bazaar_bonus | Rug Riddle | Unroll the merchant's rug | **fixed list (AR09)**, budget (FT07), undo (FT12), shape (M2), Tuft's peek (WO12) | watcher, points | clean, calm | Shape 28 in 120 s | 6×4, H4 | fixed: I Tripod Duo Tripod I Tripod Duo Tripod | 0.60 | out of pieces / 120 s | ≤ 2 min | 75 / 50 s* |

★ = prototype priority. \* ★★★ also requires no cube trimmed. Star times use Scoring F1 except 02 and 05 (hand-set: starter layers), 04 (Survive, layer stars) and B (hand-set against its hourglass). Length mix: 2.8, 2.5, **6.4**, 2.5, **5.9**. 01, 02, 04 and B are short on purpose; the validator's 5–15 min length warning is expected.

**Bonus (decision).** `dune_bazaar_bonus` is tier 11 and opens at **10 of 15** island stars (the main-biome 20 of 30 gate, scaled). It is the island's **riddle**: the one fixed-list puzzle (campaign rule 15). The finale's riddle cards are staging that forecasts its events, not a second puzzle (§10).

**Novelty budget per level** (`nd` non-default / `new` first use on the shortest path; bold = new):

| # | Non-default atoms | nd | new |
|---|---|---|---|
| 01 | BL02 | 1 | 0 |
| 02 | BL05, **Sinking sand** | 2 | 1 |
| 03 | **Mirage cube** | 1 | 1 |
| 04 | **BL14**, GO04 | 2 | 1 |
| 05 | BL05, Sinking sand, Mirage cube | 3 | 0 (twists: Mirage 1; sand is content) |
| B | **AR09**, M2 bundle, FT07, FT12 | 4 | 1 (WO12 is a mascot atom, counts 0) |

## 3. Layout overview

```text
01 spice stall  02 sand yard   03 mirage plaza  04 camel's back (← steps)  05 sphinx steps   B merchant's rug
.###.           ##ss##         ######           #####                       ......           ++++++
#####           ##ss##         ######           #####                       .####.  (layer 0) ++++++
#####           ######         ######           #####                       .####.           ++++++
#####           s###s#         ######           #####                       .####.           ++++++
.###.           s##sss         ######           #####                       .####.           (+ 4 corner cushions)
                ss####         ######                                       ......
```

## 4. Critical path and optional paths

- **Island path**: 01 → 05 in order (linear). Finishing 05 completes Dune Bazaar, hangs the lantern charm on the wizard's cloud and plays the map change. Nothing on the main chain depends on it.
- **Optional**: ★★★ times on every level; the duck for sale in 01–02; the Rug Riddle (10 island stars); the Mizzle wink in 02.

## 5. Pacing chart

```text
strangeness (how far from classic)
 high |                          #
      |               #          #
  mid |          #    #          #   #
      |          #    #     #    #   #
  low |    #     #    #     #    #   #
      +---01----02---03----04---05---B
        warm  sinks  fakes  ride FINALE riddle
```

Zig-zag, not a ramp: a short classic opener (01) → the first new rule, short and calm (02, soft sand) → the long trick level (03, mirages) → a short no-clear-needed sprint (04, survive on the camel) → the long finale that recombines 02 and 03 (05). The bonus is a calm riddle with an hourglass.

---

## 6. Level specs (encounter lists, sketches, beats)

Skit abbreviations: **I** intro (≤ 3 s, ends on the hand-off), **P** payoff (≤ 5 s), **M** Mizzle wink (one level only, ≤ 1.5 s, backdrop, never over the grid or during a warning), **R** reactions (one bubble at a time, ≤ 1 s). JSON sketches show only fields that differ from defaults; rule ids are sketches pending the rule JSON of ADR-0011; ids marked `*` belong to the NEW atoms.

**Arrival (map, first visit, 4 s; skits §11.2)**: 0.0–1.5 the cloud drifts into hot gold light; a mirage shimmers. 1.5–3.0 Tuft pops up from a hole, then another, then another (`question`). 3.0–4.0 Madame Sphinx lounges on an awning, holding up a picture riddle (`smug`).

### 01 Spice Stall

**Story card.** Tuft trades its shiny pebble for a stall's worth of spice jars, and now the stall needs stocking. Fill the stall's counter layer by layer. · **Tuft: watcher** (pops up behind the counter on each clear).
**Beats.** **I**: Tuft stacks spice jars on the stall; a puff of sand topples them; Tuft dives into a hole and pops back up with a jar on its head. **P**: the stall is stocked; the sleepy camel sniffs a jar, sneezes, and Tuft pops up dusted orange. **M**: none. **R**: `question` on the first piece, `sparkle` on a clear, `sweat` on a warning.
**Stage**: clean, calm; a spice stall on a small mesa, the duck for sale on the shelf below. **Light**: hot morning (B). **Music**: `mus_dune_bazaar_01`.

```text
Recipe: BL02 (5×5, corners off, A = 21, H9) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · SE05 duck · WO09
One sentence: "Fill a whole layer and it clears."
```
**Atoms**: non-default BL02 (known). 1 non-default, 0 new.
**Encounters**: none (classic in terracotta). Pieces 8 Standard; `opening_set` [O, I], count 2.
**Goal / fail**: Clear 3; top-out rescue, 1 warning. **Stars**: `t_est = 3 × 2.67 × 21 ≈ 168 s` → ★★ 145 s, ★★★ 100 s. **Length**: ~2.8 min (short on purpose).

```text
top-down (corners off)   side (z = 2)
.###.                    12 . . S . .   spawn zone
#####                     9 ==========  danger line
##S##                     :
#####                     0 . . . . .   the stall counter
.###.
```
**How it plays**: (1) the first pieces fall; the cut corners are the stall's posts. (2) The first clear pops a row of jars onto the shelf. (3) The player learns the corners: a corner-off layer needs I and L pieces along the edges. (4) Third clear: stocked.
**Readability**: the off corners are brass lantern posts, plainly not floor; terracotta glaze patterns keep pieces readable on sand.
**Teaches**: a warm-up for a returning player, in the new block set. **Wacky test**: surprising, the stall's corners are posts; silly, jars clink as each cube locks; funny failure, the stall slumps and jars roll out like marbles; big moment, the camel's sneeze.

```json
{ "schema": 1, "id": "dune_bazaar_01", "biome": "dune_bazaar", "tier": 1, "name": "LVL_DUNE_BAZAAR_01_TITLE",
  "board": { "width": 5, "depth": 5, "h_play": 9, "mask": [".###.","#####","#####","#####",".###."] },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right"], "opening_set": ["o","i"], "opening_count": 2 },
  "knobs": { "fall.g0": 0.85, "goal.top_out": "rescue", "goal.warnings_max": 1 },
  "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "angle_gem", "params": { "skin": "duck_for_sale" } } ],
  "stars": { "t2": 145000, "t3": 100000 }, "seed": null, "music": "mus_dune_bazaar_01",
  "story": { "title_key": "LVL_DUNE_BAZAAR_01_TITLE", "premise_key": "LVL_DUNE_BAZAAR_01_PREMISE", "mascot_role": "watcher", "icon": "spice_jar" } }
```

---

### 02 Soft Sand ★PROTO

**Story card.** The yard behind the stall has three soft-sand patches. Sand holds a piece up, but it never fills a layer: land a piece wholly on sand and it sinks in and takes the sand's place. The patches are shaped like pieces. · **Tuft: watcher** (sinks to its ears, pops up elsewhere).
**Beats.** **I**: Tuft steps onto the sand and sinks to its ears; it pops up out of a different hole. **P**: the yard is firm; the meerkat mob pops up from every hole in a row like a wave, then dives. **M (the island's one wink, lore 4.2 slot, skits §11.2 content)**: during the payoff, among the market awnings in the backdrop, one awning has a violet ribbon flag and a droopy hat haggles at a cup stall (1.3 s, no emote). **R**: `exclaim` on a sink, `sparkle` on a clear, `question` when a piece does not sink.
**Stage**: clean, calm; a sandstone yard with three ochre sand patches, rippled. **Light**: white noon (C). **Music**: `mus_dune_bazaar_02`.

```text
Recipe: BL05 (6×6, H10, starter layer 0: sandstone + 3 sand patches) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · Sinking sand (NEW) · SE05 duck · WO09
One sentence: "Land a piece on sand and it sinks in."
```
**Atoms**: non-default BL05 (known), Sinking sand (**new**). 2 non-default, 1 new.
**Encounters**: three sand patches in layer 0, each the footprint of one flat piece: **O** at x 2–3, z 0–1; **L** at (0,3) (0,4) (0,5) (1,5); **T** at (3,4) (4,4) (5,4) (4,3). The other 24 floor cells are sandstone. Layer 0 clears only when all 12 sand cells have been sunk into (the first clear, about 3 pieces). Any piece that rests only on sand sinks (an upright I on one sand cell sinks too, filling one cell). Pieces 8 Standard; `opening_set` [O, L, T] (a bag, random order).
**Goal / fail**: Clear 3; top-out rescue, 1 warning. **Stars (hand-set; the starter layer makes F1 overestimate)**: ★★ 140 s, ★★★ 100 s. **Length**: ~2.5 min (short on purpose).

```text
layer 0 (s sand, # sandstone)   side (z = 4), before → after a T sinks
##ss##                          10 ============          ============
##ss##                           :                        :
######                           1 . . . T T T            . . . . . .
s###s#                           0 s # # s s s     →      s # # T T T   the T took the sand's place
s##sss
ss####
```
**How it plays**: (1) the O spawns; the O patch glows faintly; it lands on the sand, slurps down and sits flush. (2) The L needs a Flip to fit its patch; a piece half on sandstone stays up (`question`) and the sand stays soft. (3) The last patch fills and layer 0 clears. (4) Two free clears on the firm yard.
**Readability**: sand is pale, rippled, matte (sandstone is darker, banded, glossy-glazed edges); the landing ghost shows the **after-sink** position with a small down-chevron; a sink is a 0.6 s slurp animation (staging only, the sim resolves at lock).
**Teaches**: a cell that holds you up but does not count (the island's honesty rule: trust the ghost), in a calm pocket puzzle like Meadow 02. **Wacky test**: surprising, a piece sinks into the floor; silly, a sand "slurp" and a puff of dust; funny failure, a piece perches on sandstone and the patch under it stays soft, Tuft pokes it; big moment, the mob wave on the payoff.

```json
{ "schema": 1, "id": "dune_bazaar_02", "biome": "dune_bazaar", "tier": 2, "name": "LVL_DUNE_BAZAAR_02_TITLE",
  "board": { "width": 6, "depth": 6, "h_play": 10,
    "starting_contents": { "layers": { "0": ["##ss##","##ss##","######","s###s#","s##sss","ss####"] } } },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right"], "opening_set": ["o","l","t"], "opening_count": 3 },
  "knobs": { "fall.g0": 0.95, "goal.top_out": "rescue", "goal.warnings_max": 1 },
  "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "sinking_sand*", "params": { "sink_cells": 1 } },
             { "id": "angle_gem", "params": { "skin": "duck_for_sale" } } ],
  "stars": { "t2": 140000, "t3": 100000 }, "music": "mus_dune_bazaar_02",
  "story": { "title_key": "LVL_DUNE_BAZAAR_02_TITLE", "premise_key": "LVL_DUNE_BAZAAR_02_PREMISE", "mascot_role": "watcher", "icon": "sand" } }
```

---

### 03 Mirage Plaza ★PROTO

**Story card.** The plaza shimmers in the noon heat, and mirage cubes keep appearing on the stack: they look solid, but pieces fall straight through them and they never fill a layer. Trust the landing ghost and the shadows. · **Tuft: watcher** (chases a mirage oasis).
**Beats.** **I**: Tuft spots an oasis on the plaza and runs for it; it shimmers away and Tuft dives face-first into the sand. **P**: a real oasis bubbles up behind the plaza; Tuft is suspicious, pokes it, gets splashed and grins. **M**: none. **R**: `question` when a piece passes through a mirage, `sparkle` on a clear, `sweat` on a warning. Madame Sphinx first appears, lounging on an awning, holding up a riddle card (backdrop).
**Stage**: busy; a tiled plaza, palm shadows, lantern-selling tortoises, heat shimmer on the far dunes. **Light**: white noon + heat shimmer (C + I; the shimmer is on far planes only, never on the board). **Music**: `mus_dune_bazaar_03`.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · Mirage cube (NEW) · WO09
One sentence: "Some cubes are mirages; the ghost tells the truth."
```
**Atoms**: non-default Mirage cube (**new**). 1 non-default, 1 new. Twists 1.
**Encounters**: **Mirage** (NEW): `mirage_every_locks` 3, `mirage_count` 2, `mirage_life_locks` 4, `mirages_max` 4, seeded cells on the top surface (an empty cell directly above a cube or the floor). Two typical tricks: a mirage in the last gap of a layer (the layer looks full and does not clear), and a mirage "roof" over a hole. A piece that passes through a mirage pops it with a shimmer. No telegraph is needed for safety (a mirage can never hurt you; it only misleads), but every mirage has three tells: it **casts no shadow**, it wobbles in the heat, and the layer counter on the rim does not count it. Pieces 8 Standard.
**Goal / fail**: Clear 4; top-out rescue, 1 warning (a mirage never counts for top-out). **Stars**: `t_est = 4 × 96 = 384 s` → ★★ 325 s, ★★★ 230 s. **Length**: ~6.4 min.

```text
top-down 6×6   side (z = 2)
######         13 . . S . . .   spawn zone
######         10 ============  danger line
##S###          :
######          1 # # m # # #   m = mirage: the layer LOOKS full (counter says 5/6)
######          0 # # # # . #   a mirage roof can hide this hole
######
```
**How it plays**: (1) the first mirages shimmer in; a layer looks full and nothing happens; the rim counter says 5 of 6 (`question`). (2) The player drops a piece into the "full" cell; it falls straight through, popping the mirage, and the layer clears. (3) The player learns to read shadows and the ghost, not the stack. (4) Four clears; the real oasis.
**Readability**: mirages have a heat-wobble shader, no cast shadow, a slightly brighter glaze and no edge outline; the landing ghost and its floor shadow ignore them; the rim layer counter shows true counts. Reduced motion: mirages use a static 50% dither instead of the wobble.
**Teaches**: the honesty rule from 02, flipped (there, a cell held you but did not count; here, a cell looks real and is not). **Wacky test**: surprising, a cube you can drop through; silly, mirages pop like soap bubbles; funny failure, Tuft tries to lean on a mirage and falls over; big moment, a piece falls through two mirages and clears a double.

```json
{ "schema": 1, "id": "dune_bazaar_03", "biome": "dune_bazaar", "tier": 3, "name": "LVL_DUNE_BAZAAR_03_TITLE",
  "board": { "width": 6, "depth": 6, "h_play": 10, "down_axis": "-y" },
  "knobs": { "fall.g0": 1.05, "goal.top_out": "rescue", "goal.warnings_max": 1 },
  "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "mirage_cube*", "params": { "mirage_every_locks": 3, "mirage_count": 2, "mirage_life_locks": 4, "mirages_max": 4 } } ],
  "stars": { "t2": 325000, "t3": 230000 }, "music": "mus_dune_bazaar_03",
  "story": { "title_key": "LVL_DUNE_BAZAAR_03_TITLE", "premise_key": "LVL_DUNE_BAZAAR_03_PREMISE", "mascot_role": "watcher", "icon": "mirage" } }
```

---

### 04 Camel Caravan

**Story card.** Tuft's jars ride to the oasis market on a sleepy camel's back. Every few pieces the camel takes a step and the whole load shuffles one cell toward its head. Hang on for 2:30 until the oasis. · **Tuft: watcher** (rides on the camel's head, holding its ears).
**Beats.** **I**: Tuft loads the camel with jars; the camel sighs and starts walking; the jars slide toward its head. **P**: at 2:30 the oasis: the camel kneels and drinks; Tuft slides down its neck into the pool with a splash. **M**: none. **R**: `sweat` on each step, `heart` at the oasis.
**Stage**: clean, tense; the camel's saddle blanket is the board, a long dune behind, the oasis on the horizon getting closer. **Light**: amber afternoon (D). **Music**: `mus_dune_bazaar_04`.

```text
Recipe: BL14 Camel Caravan (5×5, H9, step_dir −x, every 5 locks) · AR01 · CV01 · GO04 (150 s, ramp_per_min 0.15) · FT01 (1) · CL01 + CO01 · WO09
One sentence: "Every 5 pieces the camel steps and the load shuffles toward its head."
```
**Atoms**: non-default BL14 (**new**), GO04 (known). 2 non-default, 1 new.
**Encounters**: **Camel step** (BL14): `creature_step_locks` 5, `step_dir` −x (the camel's head is at x = 0), one-cell compact shift (cubes at the x = 0 edge stay; anything behind a staying cube stays; nothing leaves the board; nothing falls). Telegraph one lock ahead: the camel turns its head and lifts a hoof; arrows on the saddle blanket. Counter: *use it* (gaps on the head side fill themselves when the load shifts into them). Pieces 8 Standard.
**Goal / fail**: Survive 150 s; top-out rescue, 1 warning. **Stars (Scoring F4)**: 5×5 `t_beat ≈ 66.7 s`, expected ≈ 2.25 → ★★ 1 layer, ★★★ 2 layers with no warning. **Length**: 2.5 min (short on purpose).

```text
top-down 5×5 (head ←)   side (z = 2), before → after a step
#####                   12 . . S . .           . . S . .
#####                    9 ==========          ==========
##S## ← ← ←              :                     :
#####                    1 . # . # #     →     # . # # .   row slides 1 toward the head; blocked runs stay
#####                    0 # . # # .           # # # . .   (left-most cube was at the wall: stays)
```
**How it plays**: (1) the camel plods; every 5th lock the load shuffles left. (2) A gap at the head end fills by itself after a step. (3) The player learns to leave gaps on the head side and build tidy on the tail side; the speed rises each minute. (4) The oasis at 2:30.
**Readability**: the step counter is five little hoofprints on the blanket rim; each cube that moves leaves a short dust trail; the camera never moves with the camel.
**Teaches**: the board itself moves on a schedule, in a no-clear-needed sprint (like Meadow 08). **Wacky test**: surprising, the floor walks; silly, the camel's sigh and ear flick before each step; funny failure, the load shuffles into a perfect jam and the camel looks back, unimpressed; big moment, the splash into the oasis.

```json
{ "schema": 1, "id": "dune_bazaar_04", "biome": "dune_bazaar", "tier": 4, "name": "LVL_DUNE_BAZAAR_04_TITLE",
  "board": { "width": 5, "depth": 5, "h_play": 9, "down_axis": "-y" },
  "knobs": { "fall.g0": 1.12, "goal.top_out": "rescue", "goal.warnings_max": 1 },
  "goal": { "type": "survive", "T": 150, "ramp_per_min": 0.15 },
  "rules": [ { "id": "creature_back", "params": { "creature_step_locks": 5, "step_dir": "-x", "step_mode": "compact_shift" } } ],
  "stars": { "s2": 1, "s3": 2 }, "music": "mus_dune_bazaar_04",
  "story": { "title_key": "LVL_DUNE_BAZAAR_04_TITLE", "premise_key": "LVL_DUNE_BAZAAR_04_PREMISE", "mascot_role": "watcher", "icon": "camel" } }
```

---

### 05 Madame Sphinx (boss) ★PROTO

**Story card.** Madame Sphinx wants someone clever enough to answer a riddle. She sits on the sphinx steps, a stepped sandstone pyramid with soft sand on its top step, and flips picture cards. Card 1 shows a cup of sand: the sand on the steps swallows pieces. After two clears, card 2 shows a palm with wavy lines: mirages. Build around the steps and clear four layers. · **Boss**: Madame Sphinx; Tuft cheers from a hole at the rim (watcher).
**Beats.** **I (skits §11.2, 3 s)**: 0.0–1.5 Sphinx flips a riddle card: a picture puzzle (no words; cup + sand = hourglass). 1.5–2.0 Tuft scratches its head (`question`). 2.0–3.0 hand-off: Tuft looks up; glint; first piece. **P (finale, 6 s; [R] 4–5 on replays)**: 0.0–1.5 last clear: Sphinx flips her last card and stares at it (`question`). 1.5–3.0 she solves it herself (`idea`) and purrs. 3.0–4.0 she stretches across the warm awning (`sleep`). [R] 4.0–5.0 Tuft pops up and steals her riddle cards (`sparkle`). [R] 5.0–6.0 the cloud charm: a lantern hangs from the wizard's cloud (`heart`). **M**: none (the wink is in 02). **R**: Sphinx `smug` on each card, `question` on each clear; Tuft `exclaim` on a sink.
**Stage**: busiest; the sphinx steps, a sand-carved sphinx of herself behind, lanterns being lit along the market. **Light**: lantern sunset (F). **Music**: `mus_dune_bazaar_05`.

```text
Recipe: BL05 (6×6, H12, starter: 3-step pyramid with 4 sand cells) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · Sinking sand (steps) · Mirage cube (from clear 2)
One sentence: "Fill around the steps; then mirages."
```
**Atoms**: non-default BL05, Sinking sand, Mirage cube (all known from 02 and 03). 3 non-default, 0 new. Twists 1 (Mirage) plus content (sand): well under the finale cap of 3. One more callback (BL14 camel steps) is possible if playtests find it mild (§10).
**Encounters**:
- **The steps** (starter, sandstone): layer 0 has the inner 4×4 (x 1–4, z 1–4) filled, the outer ring of 20 cells empty; layer 1 has the centre 2×2 (x 2–3, z 2–3) filled and **4 sand cells** at (1,1) (2,1) (4,3) (4,4). Layer 2 is empty.
- **Riddle card 1 (from the start)**: Sinking sand on the steps. A piece resting only on sand sinks into layer 1 (for example a flat I along z = 1, x 1–4, rests on the two sand cells and sinks into place).
- **Riddle card 2 (decision: the phase switch)**: the Mirage rule starts at `active_after_clears` 2 (`mirage_every_locks` 4, `mirage_count` 2, `mirages_max` 3; gentler than 03). Before the card, her tell: the paw lifts, the eyes narrow, the headdress glints (1 s).
- Madame Sphinx is the face of the rules (campaign rule 16): each card is her wind-up and also the forecast (pictograms only).

```text
layer 0 (starter)  layer 1 (starter)   side (z = 3)
......             ......              15 . . S . . .   spawn zone
.####.             .ss...              12 ============  danger line
.####.             ..##..               :
.####.             ..##s.               1 . . # # s .   top step + sand
.####.             ....s.               0 . # # # # .   bottom step; the ring is yours to fill
......             ......
```
**How it plays**: (1) the outer ring of layer 0 fills first (20 cells, the steps' bottom). (2) Layer 1 needs its sand sunk into: flat pieces laid over the sand slurp into place. (3) Two clears drop the steps; Sphinx flips card 2 and mirages shimmer onto the surface. (4) Two more clears; her last card.
**Readability**: the cards appear on an easel beside the board, never over the grid; card 2's flip happens after the clear animation, not during a warning; sand and mirage keep the exact looks of 02 and 03.
**Teaches**: the island's two honesty rules together, with the steps as a "build around" shape. **Wacky test**: surprising, the boss forecasts her own tricks; silly, she licks a paw after every clear as if she meant it; funny failure, the stack slumps and she holds up a card of a sad face; big moment, she solves her own riddle and flops into a nap.

```json
{ "schema": 1, "id": "dune_bazaar_05", "biome": "dune_bazaar", "tier": 5, "name": "LVL_DUNE_BAZAAR_05_TITLE",
  "board": { "width": 6, "depth": 6, "h_play": 12,
    "starting_contents": { "layers": {
      "0": ["......",".####.",".####.",".####.",".####.","......"],
      "1": ["......",".ss...","..##..","..##s.","....s.","......"] } } },
  "knobs": { "fall.g0": 1.20, "goal.top_out": "rescue", "goal.warnings_max": 1 },
  "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "sinking_sand*", "params": { "sink_cells": 1 } },
             { "id": "mirage_cube*", "params": { "mirage_every_locks": 4, "mirage_count": 2, "mirage_life_locks": 4, "mirages_max": 3, "active_after_clears": 2 } } ],
  "stars": { "t2": 300000, "t3": 215000 }, "music": "mus_dune_bazaar_05",
  "story": { "title_key": "LVL_DUNE_BAZAAR_05_TITLE", "premise_key": "LVL_DUNE_BAZAAR_05_PREMISE", "mascot_role": "watcher", "boss": "madame_sphinx", "icon": "riddle_card" } }
```
**Star math (hand-set)**: cells to fill for 4 clears ≈ 20 + 32 + 36 + 36 = 124; at 4.1 cells per piece and 0.75 efficiency ≈ 40 pieces × 8 s ≈ 322 s; +10% for sand and mirages ≈ 355 s → ★★ 300 s, ★★★ 215 s.

---

### B Rug Riddle (bonus, tier 11, 10 island stars)

**Story card.** Madame Sphinx's riddle for the merchant's tent: a picture of a rug with four cushions, and eight pieces dealt in a fixed order. Unroll the rug and set the cushions before the hourglass runs out. Undo is allowed; the sand keeps falling. · **Tuft: watcher** (after 2 failed tries it points at where the next piece goes, WO12).
**Beats.** **I**: the jerboa rug merchant unrolls a rug; it is missing; Sphinx holds up the riddle card (a rug, four cushions) and turns over an hourglass. **P (skits §11.2, 5 s)**: 0.0–2.0 the last rug unrolls into place. 2.0–4.0 Tuft pops up through the middle of it (`exclaim`). 4.0–5.0 the rug sags; Tuft sinks back, waving. **M**: none. **R**: `idea` when a cushion fits, `sweat` as the hourglass runs low.
**Stage**: clean, calm; a merchant's tent, rugs hung on the walls, the hourglass on a stool as the visible clock. **Light**: tent shade (H). **Music**: `mus_dune_bazaar_bonus`.

```text
Recipe: BL01 (6 wide × 4 deep, H4) · AR09 fixed list [I, Tripod, Duo, Tripod, I, Tripod, Duo, Tripod] · CV01 · GO03 (28 cells) + CL14 [M2] · FT07 out of pieces · FT12 undo & reset · time limit 120 s (extra fail) · WO12 Tuft's peek
One sentence: "Eight pieces: the rug and four cushions."
```
**Atoms**: non-default AR09 (**new** on the shortest path), M2 bundle, FT07, FT12 (both known from Underwater 06). 4 non-default, 1 new. WO12 is a mascot atom (0).
**Encounters**: preview 3; the riddle card shows the whole list as 8 pictograms during the Countdown. **Known solution** (also the WO12 `solution` list): I along z = 1, x 1–4; I along z = 2, x 1–4; Duo at (2,0) (3,0); Duo at (2,3) (3,3); four Tripods, one per corner, each with its corner cube on the floor, two arms along the edges and one arm **up** as the cushion: corner (0,0) uses (0,0) (1,0) (0,1) + (0,0) layer 1; corner (5,0) uses (5,0) (4,0) (5,1) + up; corner (0,3) uses (0,3) (1,3) (0,2) + up; corner (5,3) uses (5,3) (4,3) (5,2) + up. Every Tripod corner is reached with Turn alone from the up-arm orientation (Flip is the trap). Dealt in list order, every placement is floor-supported. Undo rewinds the board, not the hourglass.
**Goal / fail**: Shape 28 (24 floor + 4 cushions); out of pieces or the hourglass (120 s) = the rug rolls back up with Tuft inside (retry is instant). **Stars (hand-set)**: ★★ 75 s; ★★★ 50 s and no cube trimmed. **Length**: ≤ 2 min.

```text
targets             side (z = 0)
layer 0  ++++++     4 ============  danger line
         ++++++     1 + . . . . +   cushions (the Tripods' up arms)
         ++++++     0 + + + + + +   the rug
         ++++++
layer 1  +....+
         ......
         ......
         +....+
```
**How it plays**: (1) the I lies across the middle of the rug. (2) The first Tripod: the player turns it until one arm points up and the other two run along the corner's edges. (3) The Duo pieces plug the two short gaps at the rug's ends. (4) The fourth cushion: the rug unrolls fully.
**Readability**: the cushions are drawn as tasselled cushion outlines on layer 1; the rug's floor targets carry the rug pattern; the hourglass is both the stool prop and a HUD ring; WO12's point is a paw and a faint ghost, no text.
**Teaches**: a fixed list read ahead, and 3D orientation (the up arm) as the riddle's answer. **Wacky test**: surprising, the boss's riddle is a shape; silly, the rug unrolls a stripe per piece; funny failure, the rug rolls up with Tuft inside like a burrito and Tuft's head pops out; big moment, the full rug and Tuft popping through it.

```json
{ "schema": 1, "id": "dune_bazaar_bonus", "biome": "dune_bazaar", "tier": 11, "name": "LVL_DUNE_BAZAAR_BONUS_TITLE",
  "board": { "width": 6, "depth": 4, "h_play": 4, "down_axis": "-y" },
  "pieces": { "fixed_list": ["i","tripod","duo","tripod","i","tripod","duo","tripod"] },
  "knobs": { "fall.g0": 0.60, "spawn.preview_count": 3, "goal.top_out": "trim", "goal.time_limit_s": 120 },
  "goal": { "type": "shape", "target_shape": { "layers": {
    "0": ["++++++","++++++","++++++","++++++"], "1": ["+....+","......","......","+....+"] } } },
  "rules": [ { "id": "fill_shape", "params": { "top_out": "trim" } }, { "id": "piece_budget", "params": {} },
             { "id": "undo_reset", "params": {} }, { "id": "mascot_peek", "params": { "hint_after_retries": 2 } } ],
  "solution": "see Known solution (8 placements)",
  "stars": { "t2": 75000, "t3": 50000 }, "music": "mus_dune_bazaar_bonus",
  "story": { "title_key": "LVL_DUNE_BAZAAR_BONUS_TITLE", "premise_key": "LVL_DUNE_BAZAAR_BONUS_PREMISE", "mascot_role": "watcher", "icon": "rug" } }
```

---

## 7. Hard-track remixes

None. Side islands are 5 levels + 1 bonus (brief §4, skits §11). If the producer later approves remixes, the natural three are "Quicksand Caravan" (sand + camel steps), "Mirage Riddle" (fixed list with mirages, a true trick puzzle) and "Sphinx's Rematch" (05 with the camel callback).

## 8. Narrative beats

Wordless (campaign story rules; brief §4): intro and payoff skits per level, Tuft's reactions, Madame Sphinx on an awning from 03. Arc: Tuft trades its pebble for spice and stocks the stall (01), learns the yard's soft sand (02, the wink), is fooled by the plaza mirage (03, the Sphinx's first riddle card in the backdrop), rides the camel to the oasis (04), outlasts the Sphinx's riddles (05), and solves the rug riddle (B). Tuft's "trade up" want pays off in the finale: it ends up with the Sphinx's whole deck of riddle cards.

- **Mizzle**: one wink only, in 02's payoff backdrop (a violet ribbon flag on one awning; a droopy hat haggles at a cup stall; ≤ 1.5 s). No clue, no flag panel, no postcard. **Madame Sphinx got no gift**: her riddles are her own (lore X6).
- **Map change (3 s, after the 05 payoff; skits §11.2)**: 0.0–1.5 the market lanterns light. 1.5–3.0 Sphinx sleeps on the tallest awning.
- **Cloud charm**: a lantern (Scrapbook keepsake tab, one of the 4 charms).

## 9. Music and audio cues

One track per level, supplied by the user (no stems). Ids are placeholders; until a track exists the level falls back to the biome's `default_music` (`mus_dune_bazaar_default`, a warning, not a failure). "Carefree" is a placeholder only.

| Level | Track id | Mood brief for the track |
|---|---|---|
| 01 | `mus_dune_bazaar_01` | Bright morning market, hand drums and plucked strings |
| 02 | `mus_dune_bazaar_02` | Lazy, warm, a little sly (sand slurps are SFX) |
| 03 | `mus_dune_bazaar_03` | Shimmering, wavering melody, heat haze |
| 04 | `mus_dune_bazaar_04` | Steady camel-gait rhythm that quickens each minute |
| 05 | `mus_dune_bazaar_05` | Mysterious, playful sphinx theme; a flourish on each card |
| B | `mus_dune_bazaar_bonus` | Quiet riddle music with a trickling-sand pulse |

Cues (SFX, not music): a soft "slurp" and dust puff on a sink, a glassy shimmer-pop on a mirage, hoof thuds one lock before each camel step, a card flip "fwip" for each riddle card, a purr in the finale payoff. Ambience (under the SFX slider): market hums and calls (no words), wind over sand, camel snorts, lantern clinks. Danger stinger only where `topout_rule` is rescue (not B). Skits use short stingers, never voices.

## 10. Open questions

- **New atoms (no id yet)**: **Sinking sand** and **Mirage cube** (§1). Their full rules belong in the mechanics module; the module owner assigns ids.
- **Still Proposed or Candidate here**: **WO12** Mascot's peek (Pr), **FT12** Undo & reset (Pr; needs two ADR-0001 command kinds), **BL14** Creature back (C; the "compact shift" edge rule above is this file's proposal).
- **Side-island structure vs Campaign Structure rule 1** ("exactly 10 levels" per biome): side-island biomes need an exception (5 + bonus, tiers 1–5 + 11), the 10-of-15 bonus gate and the "speed with b = unlock biome, tier 2L" rule. Owner: game-designer / Campaign Structure.
- **Riddle puzzles**: the brief says "riddle (fixed-list) puzzles" (plural). This file has one (B) and uses riddle cards as the finale's event forecast, keeping the main island path gentle (rule 15: 1–2 per biome). A second riddle puzzle could replace 01 if the user wants the island puzzle-heavy.
- **Finale strength (05)**: 3 non-default atoms and 1 twist is mild for a finale; if playtests agree, add the camel steps (BL14) as a callback (4 non-default, 2 twists).
- **Wink content**: skits §11.2 (awning flag + droopy hat at a cup stall, used), lore 4.2 (a violet pennant for sale on a stall, slot L2, slot used) and visual-direction 3.4 (a violet cuff takes a lantern) differ. Narrative-director to confirm.
- **Light journey**: lore gives 6 per-level lights (used); visual-direction gives a 3-preset journey (C noon with mirage, E gold afternoon, G lantern night). 05 is "lantern sunset (F)" here vs "lantern night (G)" there; art-director to pick.
- **Sand under a camel step**: not combined here; if a remix combines them, sand cells shift like cubes.
- **Mirage and the HUD counter**: the rim layer counter is the mirage's main tell; HUD owners to confirm it exists for clear-goal levels.
- **Star times** are formula estimates; replace with playtest medians.
