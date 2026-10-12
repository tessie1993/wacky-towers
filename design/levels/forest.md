# Forest Biome: Chip's Bridge (levels 01–10, bonus, hard track)

> **Status**: Draft v1 for user review (level-designer, 2026-10-10)
> **Author**: Tessa + level-designer
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Format**: copies `design/levels/meadow.md` section for section. Biome number 6 in the main chain (after Lava, before Cave).
> **Sources**: `production/narrative/campaign-story/brief.md` (§3.6, §2.3, §7), `lore-world.md` §3.6, `dialogue-campaign-skits.md` §6, `visual-direction.md` (Forest), `design/gdd/mechanics-module.md` (atoms, F1), `design/gdd/campaign-structure.md`, `design/gdd/twist-library.md`, `design/gdd/level-specific-mechanics.md`, `design/gdd/level-goals-fail-states.md`, `design/gdd/scoring-stars.md`, `design/gdd/level-data-definition.md`.

**Every number, name and beat in this file is a tunable default**, a starting point for the prototype and playtests. The validator enforces only the safe ranges in the owning GDDs.

---

## 1. Level name and theme

**Chip's Bridge.** Chip the baby beaver wants to cross the stream to the berry patch before bedtime, and has gnawed the bridge through (again). Blocks fall as a soft **leaf-and-acorn drizzle** through the canopy. Grandpa Oak, a cranky ancient tree, only wants one uninterrupted nap, but a set of party wind chimes (Mizzle's parcel, hung on his lowest branch by the mail-cloud, who took the branch for a coat hook) rings with every breeze. Oak shakes his acorns, rustles his leaves and stomps his roots to make it stop. In the finale the last clear makes him yawn, burst into pink blossom and settle across the stream as the bridge; the chimes ring softly in the blossoms. Keepsake: an acorn.

**Quirk: "The breather."** Forest follows the heat of Lava and comes before the dark of the Cave. It has the **lowest prop density and the slowest ambient motion** of the campaign so far. Every level has one clear, friendly disturbance, two levels cannot be lost (05 build race, 06 puzzle is a free retry), and the boss is a sleepy tree, not a fighter. Strangeness still zig-zags rather than ramping.

**Thread (Mizzle, strength 3).** First contact lands in 09: an acorn falls, the wizard's glint and a violet cuff reach it together, Mizzle blushes, flees, and leaves a **tiny crooked block** (matte, lopsided, never glossy; it must not read as a playable piece). Levels 03–08 carry one small clue each (§8). Missing every clue still gives a clean, happy story.

### Biome rules (decisions)

| Rule | Default |
|---|---|
| Islands | One per level, shaped by the story: acorn stump (01), hollow family log (02), log bridge over the stream (03), squirrel fork-branch (04), treehouse limb (05), firefly glade (06), leaf-swept branch (07), woodpecker trunk (08), root-belt bank (09), Grandpa Oak's gap (10); bonus on a berry-bush basket. All hang off the Great Tree island |
| Stage | Calm and clean by default; "busy" only where the disturbance needs it (04, 07, 09, 10). Landmark in every backdrop: Grandpa Oak's crown, snoring |
| Intro skit | A wordless 3-second mini-scene in which Chip shows the problem, played during the Countdown (no play time lost) |
| Payoff skit | A skit of 5 s or less on every win, tap to skip; the biome finale is 6 s on first play |
| Mascot | **Chip** (Forest only), WO09 watcher on every level (reactions only, staging only, no gameplay effect). No catches (`mascot_catches` 0). Chip never pranks the board; the gnawing gags live in the skits |
| Boss | **Grandpa Oak** (never hurt: he is bonked into a blossom). Visible in the backdrop from 01; his chimes are visible from 03 on |
| Friends | **Lana** (Stitch) and **Boulder** (Smash) have joined by now and may be picked in solo play; **Glim does not join until the Cave** (his Redraw never appears here). No level is tuned around a skill and star times are balanced for no perks and no skills. Stitch vetoes every `stack`-tagged write (04, 08, 09 heist and belt, 10 belt, H2), which is a valid counter to those twists and is allowed |
| Physics | None in the Forest |
| Rubber duck | Sits in an empty bird's nest among the roots under the island in 01 and 02 (SE05, visible from one low snap angle; tap to collect; no stars attached) |
| Forest events | Wind = **Leaf Gust**; Spawned Objects = **Acorn Shower**; Conveyor = **Root Slide**; Invisible Blocks = **Firefly Night**; Quake = **Woodpecker Knock** (EV12); new **Squirrel Heist** (EV25, §1 rule notes) |
| Callbacks | Meadow's gust, spawned objects, conveyor, fog and split piece return, remixed. Only one callback per level is the *new* idea; the rest are known |
| Dressing | Block set Forest Bark (primary) / Moss & Stone; UI frame: mossy log wood with bark-rough edges, a tiny mushroom cluster and a fern curl at the top corners (art-director to confirm). Foliage stays duller and more olive than the lime and mint pieces |
| Prototype priority | **02, 04, 08, 10** (★PROTO): they carry the new rules (BL17 shelf, EV25 heist, EV12 knock + SP12 vines, and the boss stack) |

**Lighting (decision, six presets from `lore-world.md` §3.6; the journey is late afternoon green into warm lantern dusk, then pink twilight).** Used as written in each level below.

| L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10 | B |
|---|---|---|---|---|---|---|---|---|---|---|
| green afternoon | green afternoon | green afternoon | dappled gold | dappled gold | firefly dusk | lantern dusk | lantern dusk | lantern dusk | **blossom twilight** | sunset berry |

`visual-direction.md` lists a different split (five stages, firefly night at 09). The lore file's six presets are used here; see §10.

**Common defaults** (unless a level says otherwise): weighted bag, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, all rotation axes (Turn / Flip / Roll are known by now), `t_piece` 8 s. **Pieces**: "8 Std" = I, O, T, L, S, Tripod, Screw-Left, Screw-Right. **Speeds** are hand-set within ±0.05 of campaign F2 (`0.6 + 0.045 × (tier − 1) + 0.06 × (6 − 1)` = 0.900 at tier 1 up to 1.305 at tier 10); puzzle levels (06, B) are exempt and set a slow `g0` so the player can think. **Star times** use Scoring & Stars F1 (`t2 = round5(0.85 × t_est)`, `t3 = round5(0.6 × t_est)`), with `t_est = N × A × 2.667 s` for Clear-N (`A` = active cells per layer, `t_piece` 8 s, 4 cubes per piece, 75% fill efficiency; this reproduces the Meadow's published times). Levels with starter blocks, puzzles and the bonus hand-set their times. Stars are for play with no perks.

**Budget (mechanics module F1).** At most 2 atoms new to the player and 4 non-default atoms per level; tiers 7–10 showpiece levels may use up to 6 non-default. "New" below means *not used in the Meadow or in an earlier Forest level*. The Candy, Ice, Underwater and Lava level files are written separately; the validator recount against the real path order happens when all biome files exist (flagged in §10). A bundle counts 1 (M1 = GO02 + CL14 + FT02, M2 = GO03 + CL14). Slot defaults: BL01, AR01, CV01, CL01, CO01, GO01, FT01. Secrets (SE05) and the mascot field count 0.

**Grids**: one string per row, row 0 = `z = 0` (back), character 0 = `x = 0` (left). Mask `#` active, `.` off; starting layers `#` starter block, `.` empty; targets `#` target cell; shelf grids `S` shelf, `o` opening. Side views are a slice at one `z` row seen from the front; `=====` is the danger line at `H_play`, `S` the spawn zone, `:` skips empty rows.

### Forest rule notes (new and changed rules; owners named in §10)

| Rule | Definition (all values tunable) |
|---|---|
| **EV25 Squirrel Heist** (new atom, Proposed, layer `twist`, tags `grid stack`, counter: **clear to cancel**) | Every `heist_every_locks` (6; 3–12) locks, a squirrel on the branch picks a **target**: one exposed cube (open cell above it) in the **fullest unfinished layer**, if that layer is at least `heist_min_fill` (0.5) full; ties go to the lowest layer, then a pick from the rule's seeded stream. It is announced `heist_warn_locks` (1) lock ahead: the squirrel runs along the branch to the target, a dotted line and a paw-point mark the cube. At the next lock the squirrel grabs the cube and scampers off (the cube is removed). The heist is **cancelled** (the squirrel droops its tail and goes home) if the target's layer clears, or if a cube locks directly above the target. If no layer is eligible the squirrel naps and nothing happens. The hole is open from above, so it can always be refilled. Never targets below layer 1 or the last cube of a layer |
| **EV12 Woodpecker Knock** (Candidate, layer `twist`, tags `floor stack`, counter: **ride it out**) | Every `knock_interval_ms` (13 000 ± `knock_jitter_ms` 3 000) of play time a woodpecker knocks. `knock_warn_ms` (1 500) before, three knocks and a shiver in the bark; the **overhang cubes about to pop** (a cube with an empty cell directly below it, evaluated once, at the same time) are outlined with dotted lines. It applies at the first Resolving after the warning (like the flip, twist-library rule 11): those cubes pop off like popcorn, **at most `knock_pop_max` (4) per knock, highest first**. Cubes above a popped cube stay where they are (slice mode). Vine cubes (SP12) are immune. Nobody is hurt; the cubes just hop away |
| **SP12 Vines** (Candidate, layer `content`) | `vine_per_bag` (1; 0–2) one piece in each bag is leafy-green: on lock, its cubes and every cube face-touching them are flagged *vined* until cleared. Vined cubes are immune to knock pops (and to any trim or shake) |
| **Acorn Shower** (EV04 `mushroom_popup` + SP19 skinned as an acorn) | Twist-library T4 as written: `spawn_every_locks` 5, `objects_max` 4, the cell is marked one lock ahead. **Staging only**: the acorn visibly falls from the canopy onto the marked cell. Optional param `place_mode` (`random` default, `lowest`): `lowest` marks a cell in the lowest top-surface layer (random among ties), so acorns fill dips (twist-library rule 20 allows variants that reuse the contract) |
| **Leaf Gust** (EV01 `gust`) | Twist-library T1 as written; `wind_mode` `fixed` or `rotating` (rule 4). The arrow on the board edge is a swirl of leaves |
| **Root Slide** (EV05 `conveyor`, mechanic) | Level-Specific Mechanics M4 as written: unmasked rectangle, wrap on. The roots on the bank slide the whole stack; the staging shows roots writhing one lock before |
| **Firefly Night** (EV02 `fog`) | Twist-library T2 as written; the faded cubes leave a faint swarm of fireflies at their cells (staging; the ghost still lands correctly) |

## 2. Estimated play time and summary

| # | id | Name | Story beat | New idea (atoms) | Chip | Stage | Goal | Board | Pieces | g0 | Top-out | Length | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | forest_01 | Acorn Shelf | Gnaw a stump flat | round stump (BL02) | watcher | clean, calm | Clear 3 | 21-cell round, H8 | 8 Std; first 2 from {O, I} | 0.85 | rescue, 2 | ~2.8 min | 145 / 100 s |
| 02 ★ | forest_02 | Hollow Log | Beds in the log | canopy shelf (BL17) | watcher | clean, calm | Clear 3 | 6×6, H10, shelf at 2 + 2 starter layers | 8 Std + Big Cube (w 0.4); first 3 {O, O, Tripod} | 0.95 | rescue, 1 | ~3 min | 160 / 115 s* |
| 03 | forest_03 | Stream Crossing | Rebuild the log bridge | Acorn Shower (EV04 + SP19) | watcher | clean | Clear 5 | 8×3 lane, H10 | 8 Std | 0.95 | rescue, 1 | ~5.3 min | 270 / 190 s |
| 04 ★ | forest_04 | Squirrel Branch | Raiders on the fork | Squirrel Heist (EV25), fork mask (BL02) | watcher | busy | Clear 4 | 25-cell fork, H10 | 8 Std | 1.00 | rescue, 1 | ~4.5 min | 225 / 160 s |
| 05 | forest_05 | Treehouse Limb | Climb to the door | narrow tall limb (M1) | watcher | clean, tense | Height 10 (cov. 0.6) | 4×4, H12 | 8 Std | 1.05 | trim | ~3.2 min | 165 / 115 s* |
| 06 | forest_06 | Firefly Glade | Light the jar | fixed list (AR09), budget (FT07), fill shape (M2) | watcher | clean, hushed | Shape 24 | 4×4, H6 | fixed: L I O L I I | 0.60 | out of pieces | ~1.5 min | 75 / 50 s |
| 07 | forest_07 | Leaf-Swept Branch | Leaves from every side | swirl wind (EV01 rotating), maple seeds (SP28) | watcher | busy | Clear 4 | 6×6, H10 | 8 Std | 1.15 | rescue, 1 | ~6.4 min | 325 / 230 s |
| 08 ★ | forest_08 | Woodpecker Trunk | Knock, knock | Knock (EV12), Vines (SP12) | watcher | busy, tense | Clear 5 | 4×4, H12 | 8 Std | 1.20 | rescue, 1 | ~3.6 min | 180 / 130 s |
| 09 | forest_09 | Root-Belt Bank | The roots slide | Root Slide (EV05) + Heist (EV25) | watcher | busy | Clear 4 | 7×5, H10 | 8 Std | 1.25 | rescue, 1 | ~6.2 min | 315 / 225 s |
| 10 ★ | forest_10 | Oak's Gap | Boss: Grandpa Oak | Shower + Gust + Root Slide, 3 chimes | boss | busiest | Clear 3 | 8×6, H12 | I O T L Tripod Screws Chair | 1.30 | rescue, 1 | ~6.4 min | 325 / 230 s |
| B | forest_bonus | Berry Basket | Pack the berries | kit box (AR13), fill shape (M2), budget (FT07) | watcher | clean | Shape 32 | 4×4, H7 | kit: O×4, I, L×2, Duo×2 | 0.60 | out of pieces | ~2 min | 130 / 90 s |
| H1 | forest_h1 | Firefly Night | Chip chews the candle | Firefly Night (EV02) + swirl gust | watcher | busy, dark | Clear 5 | 6×6, H10 | 8 Std | 1.20 | rescue, 1 | ~8 min | 410 / 290 s |
| H2 | forest_h2 | Raiders & Woodpecker | Raid and rattle | Heist (EV25) + Knock (EV12) + Vines | watcher | busy | Clear 4 | 6×6, H10 | 8 Std | 1.20 | rescue, 1 | ~6.4 min | 325 / 230 s |
| H3 | forest_h3 | Canopy Windows | Windows in the wind | shelf (BL17) + swirl gust | watcher | clean, tense | Clear 4 | 6×6, H10, shelf at 3 + 3 starter layers | 8 Std + Big Cube (w 0.4) | 1.15 | rescue, 1 | ~3.5 min | 170 / 120 s* |

★ = prototype priority. \* ★★★ also requires no cube trimmed (05) or hand-set times (02, H3 have starter layers and the shelf, so F1 would overestimate; 06, B and the puzzles are hand-set against their piece lists). Length notes: 01, 02, 04, 05, 06, 08 and B are short on purpose; the validator's 5–15 min length warning is expected on those.

**F1 budget table** (nd = non-default atoms, new = new to the player; "met" = Meadow or earlier Forest):

| Level | Non-default atoms | nd | new |
|---|---|---|---|
| 01 | BL02 | 1 | 0 (BL02 met in Meadow 04) |
| 02 | BL17 (starter blocks are `starting_contents` data inside BL17, not a second Board atom) | 1 | 1 (BL17) |
| 03 | EV04, SP19 | 2 | 0 |
| 04 | BL02, EV25 | 2 | 1 (EV25) |
| 05 | M1 bundle | 1 | 0 |
| 06 | AR09, M2 bundle, FT07 | 3 | 2 (AR09, FT07; a Meadow-bonus-skipper has not met them) |
| 07 | EV01, SP28 | 2 | 0 |
| 08 | EV12, SP12 | 2 | 2 |
| 09 | EV05, EV25 | 2 | 0 |
| 10 | EV05, EV01, EV04, SP19 | 4 (cap 6, showpiece) | 0 |
| B | AR13, M2 bundle, FT07 | 3 | 1 (AR13) |
| H1 | EV02, EV01 | 2 | 0 |
| H2 | EV25, EV12, SP12 | 3 | 0 |
| H3 | BL17, EV01 | 2 | 0 |

Twists per level never exceed 2 (10 has 2 twists + the Root Slide mechanic; the finale's third-twist allowance is unused).

**Hard track (decision).** `forest_bonus` is tier 11 (unlocks at 20 forest stars). The remixes are **tiers 12–14** (`forest_h1`–`h3`); all three open when `forest_10` is finished. Neither the bonus nor the remixes count toward the next biome's star gate. Stars still pay points as usual.

## 3. Layout overview

```text
01 acorn stump  02 hollow log     03 log bridge       04 fork branch   05 treehouse limb
.###.           ######            ########            ##...##          ####
#####           #oo###  shelf     ########            ##...##          ####
#####           #oo###  y = 2     ########            .#####.          ####
#####           ######                                ..###..          ####
.###.           ####oo                                ..###..          (12 tall)
                ####oo                                ..###..
                                                      ..###..
06 firefly jar  07 leafy branch   08 woodpecker trunk 09 root-belt bank   10 Oak's gap (belt →)
####            ######            ####                #######             ########
####            ######            ####                #######             ########
####            ######            ####                #######             ########
####            ######            ####                #######             ########
(6 tall)        ######            (12 tall)           #######             ########
                ######                                                    ########
```

## 4. Critical path and optional paths

- **Critical path**: 01 → 10 in order (linear inside a biome). Finishing 10 completes the Forest; the next biome (Cave) opens with 15 of 30 forest stars. Boo Hollow (side island) opens after the Cave, not here.
- **Optional**: ★★★ times on every level; the rubber duck in 01–02; the bonus Berry Basket (20 stars); hard-track remixes H1–H3 (after 10).

## 5. Pacing chart

```text
strangeness (how far from classic)
 high |                                #   #
      |                          #     #   #
  mid |           #  #     #     #     #   #
      |        #  #  #     #  #  #  #  #   #
  low |  #  #  #  #  #  #  #  #  #  #  #   #
      +-01-02-03-04-05-06-07-08-09-10--B
        learn  twist  breather mem  squirrel flip? FINALE
```

Zig-zag, not a ramp: two teaching levels (01 round stump, 02 shelf) → two twist levels (03 acorns, 04 squirrel raid) → a no-lose pair (05 build race, 06 firefly puzzle) → the wind from every side (07) → the knock (08) → the remix of belt + heist (09, the hardest) → the three-rule boss (10). Short and long alternate (campaign rule 12): short (01, 02), mid (03, 04), short (05, 06), long (07), short (08), long (09), long finale. No two pressure peaks in a row before the finale: the heavy ones (04, 08, 09) are separated by easier levels. Energy stays "warm", lower than the Lava before it.

---

## 6. Level specs (encounter lists, sketches, beats)

### 01 Acorn Shelf

**Story card.** Chip gnawed the top off a stump to make a shelf for the acorn collection. Fill each ring and it clears: three clears and the shelf is built. · **Chip: watcher** (no gameplay help).
**Stage**: clean, calm; a mossy stump on a quiet bank, Oak snoring in the distance. **Light**: green afternoon. **Intro skit** (3 s): Chip gnaws a stump flat and spits sawdust; an acorn drops onto it and rolls off the edge; Chip looks up at the canopy (`idea`). **Payoff skit** (4 s): the three cleared rings stack up as a round shelf; Chip puts the acorn on top and holds still (`sparkle`); it wobbles and rolls into the stream; Chip dives after it (`sweat`). **Mizzle clue**: none (the thread starts at 03). **Reactions (R)**: clear `sparkle`; warning `sweat`.

```text
Recipe: BL02 (5×5 corners off, A = 21, H8) · AR01 · CV01 · GO01 (3) · FT01 (2 warnings) · CL01 + CO01 · SE05 duck · WO09
One sentence: "Fill a whole ring and it clears."
New to the player: nothing. Tier 1 re-teaches the controls in the Forest's look.
```
**Encounters**: none (pure classic). Pieces 8 Std; `opening_set` [O, I], count 2. `T_level` 180. Control: CV01, all three rotation pairs (Turn / Flip / Roll).

```text
mask 5×5 (A = 21)     side (z = 2)
.###.                 11 . . S . .   spawn zone
#####                  8 ==========  danger line
#####                  :
#####                  0 # # # # #   the stump top
.###.
```
**How it plays**: (1) an O drifts down slowly through leaf light. (2) The first ring clears in about 5 pieces: the stump sinks a notch, a leaf spins away, a soft chime. (3) T, L and S arrive; the round edge teaches that corners are missing (no gaps to fill there). (4) The third clear and the shelf is done.
**Teaches**: the controls and the rule, in the new look; the corner cut-outs show the mask is part of the board.
**Readability**: the rounded mask shows as a worn stump top; inactive cells are plain bark ring, never placeable.
**Wacky test**: surprising, a stump you can build on; silly, the acorn that will not stay put; funny failure, Chip hugs the acorn on a warning; big moment, the sunburst on the third clear.

```json
{ "schema": 1, "id": "forest_01", "biome": "forest", "tier": 1,
  "board": { "width": 5, "depth": 5, "h_play": 8,
             "mask": { "layers": { "all": [".###.","#####","#####","#####",".###."] } },
             "spawn_anchor": { "x": 2, "z": 2 } },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_l","screw_r"], "opening_set": ["o","i"], "opening_count": 2 },
  "knobs": { "fall.g0": 0.85, "goal.warnings_max": 2, "goal.top_out": "rescue" },
  "goal": { "type": "clear_n", "N": 3, "T_level": 180 },
  "rules": [ { "id": "wo09_watcher", "params": {} } ],
  "stars": { "t2": 145000, "t3": 100000 },
  "music": "forest_01_tbd", "story": { "mascot_role": "watcher", "icon": "stump" } }
```

---

### 02 Hollow Log ★PROTO

**Story card.** Chip's family sleeps in a hollow log, and the beds are under the roof. The roof has leaf-ringed windows: drop pieces through them to fill the bedrooms, or just build on the roof. · **Chip: watcher** (tucks in the kits).
**Stage**: clean, calm; a fallen log cut away to show a bedroom. **Light**: green afternoon. **Intro skit** (3 s): three baby beavers in nightcaps peek out of leaf windows; an acorn drops through one and bonks a sleepy kit (`question`). **Payoff skit** (4 s): the kits flop into perfect beds, leaf blankets drawn up; Chip tiptoes out and blows out a firefly lantern (`sleep`). **Mizzle clue**: none. **Reactions (R)**: piece through a window `sparkle`; clear `idea`.

```text
Recipe: BL17 canopy shelf (6×6, H10, shelf_y 2, two 2×2 openings; starter blocks as data) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · SE05 duck · WO09
One sentence: "Some of the roof has windows: pieces fall through them."
New to the player: BL17 canopy shelf (1).
```
**Encounters**: a fixed **shelf** at layer 2 covers the footprint except two 2×2 openings (leaf-ringed). Shelf cells hold pieces up and never clear; a piece over an opening falls through to the chamber below. The chamber (layers 0–1) starts with starter blocks everywhere except under the two openings (a 2×2×2 hole under each, 16 gap cells). Two paths to Clear 3: fill the holes (4 O's: each hole takes two stacked O's, or a Big Cube, or a Tripod plus others) and layers 0 and 1 clear together as a **double**; the third clear comes from the open deck above the shelf (layers 3 and up, 36 cells). Players who ignore the windows can clear three deck layers, only slower. Pieces 8 Std plus a Big Cube (w 0.4); `opening_set` [O, O, Tripod], count 3.

```text
starter layers 0 and 1 (same)   shelf layer 2                 side (z = 1)
######                          SSSSSS                        10 ===============
#..###   hole A (x1–2, z1–2)    SooSSS   opening A             :
#..###                          SooSSS                         3 . . . . . .     the deck
######                          SSSSSS                         2 S o o S S S     shelf, opening A
####..   hole B (x4–5, z4–5)    SSSSoo   opening B             1 # . . # # #     chamber, hole A
####..                          SSSSoo                         0 # . . # # #
```
**How it plays**: (1) an O spawns and the ghost shows it dropping through window A into the bedroom hole; Chip waves. (2) Two O's fill hole A; the Big Cube or two more fill hole B. (3) Layers 0 and 1 clear together (a double); the chamber is hollow again. (4) One clear on the deck finishes it.
**Teaches**: the shelf rule (windows swallow pieces), the ghost's fall-through line, and that the deck is a normal board. Nothing is lost if a window is skipped.
**Readability**: openings are ringed with bright leaves; the ghost always draws the fall-through; the chamber is lit warm so the holes read as beds.
**Wacky test**: surprising, a roof with windows; silly, kits in nightcaps, snoring beds; funny failure, a piece wedged half in a window with a "pop"; big moment, the double clear that empties the chamber.

```json
{ "schema": 1, "id": "forest_02", "biome": "forest", "tier": 2,
  "board": { "width": 6, "depth": 6, "h_play": 10,
             "shelf": { "y": 2, "openings": [ {"x":1,"z":1,"w":2,"d":2}, {"x":4,"z":4,"w":2,"d":2} ] },
             "starting_contents": { "layers": {
               "0": ["######","#..###","#..###","######","####..","####.."],
               "1": ["######","#..###","#..###","######","####..","####.."] } } },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_l","screw_r","big_cube"], "weights": {"big_cube": 0.4},
              "opening_set": ["o","o","tripod"], "opening_count": 3 },
  "knobs": { "fall.g0": 0.95, "goal.warnings_max": 1, "goal.top_out": "rescue" },
  "goal": { "type": "clear_n", "N": 3 },
  "stars": { "t2": 160000, "t3": 115000 },
  "recipe": { "atoms": ["BL17","AR01","CV01","CL01","CO01","GO01","FT01","SE05","WO09"] },
  "music": "forest_02_tbd" }
```

---

### 03 Stream Crossing

**Story card.** Chip gnawed the log bridge in two. Rebuild it layer by layer; Oak's cranky shaking drops acorns that plop onto the log and fill a cell for free, if you plan for them. · **Chip: watcher** (holds the plank).
**Stage**: clean; a stream, a short mossy bank, lily-free water. **Light**: green afternoon. **Intro skit** (3 s): two halves of the bridge float past Chip, who holds a plank and looks at them (`idea`). **Payoff skit** (4 s): the log is whole; acorns line up on it like beads and bounce into the stream one by one; Chip crosses with a berry. **Mizzle clue (M, 1.5 s, at the rim)**: in the shade of the far bank, fireflies gather around a droopy hat; it shoos them, they stay (`blush`). **Reactions (R)**: acorn lands `exclaim`; clear `sparkle`.

```text
Recipe: BL01 (8 wide × 3 deep, H10) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · EV04 Acorn Shower + SP19 (place_mode lowest) · WO09
One sentence: "Acorns fall onto your log and fill a cell for you."
New to the player: nothing hard (Meadow 04's spawned object, dressed as an acorn, falling from above).
```
**Encounters**: an acorn every 5 locks (max 4), marked by a sparkle one lock ahead, that lands in the lowest part of the stack (`place_mode` lowest, ties random). It clears with its layer. The staging drops the acorn from Oak's branch onto the cell, so the player sees it fall and can plan. Pieces 8 Std.

```text
top-down 8×3             side (z = 1)
########                 13 . . . S S . . .   spawn zone
###S####                 10 ================  danger line
########                  :
                           0 a . # # . # # #  a = acorn in the lowest dip
```
**How it plays**: (1) pieces fall calm; the log is a narrow lane, so 3D pieces feel cramped. (2) After the 4th lock, a sparkle marks a floor cell; an acorn drops with a "plop". (3) The player leaves the dip alone for the acorn or plans around it. (4) Five clears and the bridge is whole.
**Teaches**: "something may land on your stack for free, and you can see where." Because acorns pick the lowest cell, the player can *use* them to fill a hole they are not ready to fill.
**Readability**: the sparkle one lock ahead, the same as the Meadow mushroom; acorns are warm brown, outlined, never the same hue as a piece.
**Wacky test**: surprising, the sky delivers a free cube; silly, acorns with tiny caps rolling in a line; funny failure, an acorn fills the cell a perfect piece needed and Oak snores smugly; big moment, the splash of the first bridge clear.

```json
{ "schema": 1, "id": "forest_03", "biome": "forest", "tier": 3,
  "board": { "width": 8, "depth": 3, "h_play": 10, "spawn_anchor": { "x": 3, "z": 1 } },
  "knobs": { "fall.g0": 0.95, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 5 },
  "rules": [ { "id": "mushroom_popup", "params": { "spawn_every_locks": 5, "objects_max": 4, "skin": "acorn", "place_mode": "lowest" } } ],
  "stars": { "t2": 270000, "t3": 190000 },
  "music": "forest_03_tbd" }
```

---

### 04 Squirrel Branch ★PROTO

**Story card.** A gang of squirrels runs along the fork-branch and grabs a cube from your fullest layer, just before you finish it. Finish it first, or cover the cube. · **Chip: watcher** (gasps).
**Stage**: busy; a Y-fork of a big branch, a squirrel crew peeking out of leaves. **Light**: dappled gold. **Intro skit** (3 s): a striped-tail squirrel slides down the branch with a sack; Chip gasps (`exclaim`); the squirrel winks. **Payoff skit** (4 s): the squirrels return a pile of acorns, then one snatches back a single acorn and bolts; Chip shrugs (`dots`). **Mizzle clue (M, 1.5 s)**: on a far log, Mizzle sits and doodles a block in the air; it comes out nearly square (`idea`). **Reactions (R)**: warning of a heist `exclaim`; cancelled heist `sparkle`; cube grabbed `sweat`.

```text
Recipe: BL02 (7×7 fork mask, A = 25, H10, spawn_anchor (3,2)) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV25 Squirrel Heist · WO09
One sentence: "A squirrel will grab a cube from your fullest layer: finish it first."
New to the player: EV25 (1).
```
**Encounters**: **Squirrel Heist** (rule notes in §1): `heist_every_locks` 6, `heist_warn_locks` 1, `heist_min_fill` 0.5. The counter is **clear to cancel** (a clear of the target's layer, or a piece locked over the target, sends the squirrel home empty). The squirrel is a staging character: it runs from a side branch to the target during the warning lock. Pieces 8 Std.

```text
mask 7×7 (A = 25)        side (z = 2, the crossbar)
##...##                  13 . . . S . . .   spawn zone
##...##                  10 ===============  danger line
.#####.                   :
..###..                   1 . # # # # # .   the heist target glows
..###..                   0 . # # # # # .
..###..
..###..
```
**How it plays**: (1) the first layers fill calmly; the fork shows where the tines are narrow. (2) After the 5th lock, a squirrel scampers to the fullest layer and points; one open cube glows with a dotted line. (3) The player has one lock to finish the layer or drop a piece over the cube. (4) Cancelled heists make the squirrel droop; a missed one takes a cube, leaving a clean hole to refill.
**Teaches**: pressure that rewards finishing what you started, and the new reading of "dotted line plus paw = this cube is next".
**Readability**: the telegraph is one lock, but the squirrel also appears at the board rim during the lock before (two beats). The target is always an open cube. A hole never creates a covered hole.
**Wacky test**: surprising, your own cube is stolen; silly, the sack and the wink; funny failure, the squirrel zips off with your cube and returns with a flag; big moment, finishing a layer in the last second and the squirrel face-plants.

```json
{ "schema": 1, "id": "forest_04", "biome": "forest", "tier": 4,
  "board": { "width": 7, "depth": 7, "h_play": 10, "spawn_anchor": { "x": 3, "z": 2 },
             "mask": { "layers": { "all": ["##...##","##...##",".#####.","..###..","..###..","..###..","..###.."] } } },
  "knobs": { "fall.g0": 1.00, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "squirrel_heist", "params": { "heist_every_locks": 6, "heist_warn_locks": 1, "heist_min_fill": 0.5 } } ],
  "stars": { "t2": 225000, "t3": 160000 },
  "music": "forest_04_tbd" }
```

---

### 05 Treehouse Limb

**Story card.** Chip wants the treehouse door, high on the limb. Stack to the sign; nothing clears, too high pops off, and you cannot lose. · **Chip: watcher** (climbs as the limb grows).
**Stage**: clean, tense; a narrow limb among leaves, a treehouse door far above. **Light**: dappled gold. **Intro skit** (3 s): Chip jumps for the door, can't reach, and points at the limb (`idea`). **Payoff skit** (4 s): Chip scrambles up and opens the door: a berry bowl; it dives in headfirst. **Mizzle clue (M, 1.5 s)**: far off, he tiptoes past sleeping Oak to retie a chime; it clinks and Oak's eye twitches (`sweat`). **Friend cameo**: Lana's yarn bunting hangs from the limb in the backdrop (she has joined; no gameplay). **Reactions (R)**: layer 5 `sparkle`; trimmed cubes `sweat`.

```text
Recipe: BL01 (4×4, H12) · AR01 · CV01 · M1 build race (GO02 height 10, coverage 0.6 + CL14 + FT02 trim) · CO01 · WO09
One sentence: "Build up to the sign; nothing clears."
New to the player: nothing (M1 from Meadow 05); a narrow tall board.
```
**Encounters**: none; no twists, no wobble. Pieces 8 Std. Trim: cubes at or above layer 12 pop off; the level never fails. A well variant (BL03, a narrow "neck") is possible once BL03 is reviewed.

```text
top-down 4×4    side (z = 2)
####            15 . S S .   spawn zone
####            12 ========  danger line (trim)
####            10 - - - -   sign: layer 10 must be ≥ 60% full (10 of 16)
####             :
                 0 . . . .
```
**How it plays**: (1) the floor fills; a full layer glows and stays. (2) The height meter climbs and Chip climbs with it. (3) Stacking a narrow tower makes every misplaced piece matter. (4) Layer 10 reaches 10 cubes; the door swings open.
**Teaches**: a no-fail breather. Height is not lost by mistakes; the pleasure is the climb.
**Readability**: the sign is wood and a bright rope; the trim line is the top branch. No danger music.
**Wacky test**: surprising, full layers stay; silly, Chip climbing a tower of its own; funny failure, cubes hop off like popcorn and a branch bonks Chip; big moment, the door opening on berries.

```json
{ "schema": 1, "id": "forest_05", "biome": "forest", "tier": 5,
  "board": { "width": 4, "depth": 4, "h_play": 12 },
  "knobs": { "fall.g0": 1.05, "goal.top_out": "trim" },
  "goal": { "type": "height", "H_target": 10, "height_coverage": 0.6 },
  "rules": [ { "id": "build_race", "params": {} } ],
  "stars": { "t2": 165000, "t3": 115000 },
  "music": "forest_05_tbd" }
```

---

### 06 Firefly Glade (puzzle)

**Story card.** Chip wants a jar of fireflies. Six pieces, no spares: fill the glowing jar shape. The fireflies mark every cell. · **Chip: watcher** (holds the jar up).
**Stage**: clean, hushed; a dim glade, fireflies drifting. **Light**: firefly dusk. **Intro skit** (3 s): Chip holds an empty jar to a swarm; they zip around it and around it, never in (`question`). **Payoff skit** (4 s): the jar is full and glows; a firefly lands on Chip's nose and it crosses its eyes (`sparkle`). **Mizzle clue (M, 1.5 s)**: he picks up one of Chip's dropped planks and leans it neatly by the bridge (`dots`). **Reactions (R)**: good fit `sparkle`; wrong lock `sweat`.

```text
Recipe: BL01 (4×4, H6) · AR09 fixed list [L, I, O, L, I, I] · CV01 · M2 fill shape (GO03 24 cells + CL14) · FT07 piece budget (6) · WO09
One sentence: "Six pieces, no spares: fill the glowing jar."
New to the player: AR09, FT07 (2). Retry is free and instant.
```
**Encounters**: none. Preview 3. Target: a wide base of 16 cells and a central bar of 8 (24 cells). Known solution (proof for the validator's `solution` list): base layer 0: L (z3 x0–2 plus x2 z2), I (z0 row), O (x0–1, z1–2), L (x3 z1–3 plus x2 z1); layer 1: I (x1, z0–3), I (x2, z0–3). Dealt in list order, every placement is supported. One L must be flipped over (Flip) to be the mirror of the other, depending on how it spawns. Stars: ★★ 75 s, ★★★ 50 s (no timer on screen).

```text
target layer 0 (16)   layer 1 (8)   side (z = 1)
####                  .##.          6 ======   danger line
####                  .##.          :
####                  .##.          1 . # # .   bar on layer 1
####                  .##.          0 # # # #   wide base
```
**How it plays**: (1) read the preview (L, I, O) and the glowing cells; the fireflies show every cell. (2) Soft/hard drop with no clock pressure. (3) The two L's lock the base's L-shaped gaps; one needs a flip. (4) The two I's fill the bar; the jar glows. A misplaced piece wastes a piece, and instant retry is free.
**Teaches**: the puzzle verb (fixed list, no spares) in a quiet breather. A puzzle can be lost (out of pieces) but never frustrates, since reset costs nothing.
**Readability**: target cells are fireflies; filled cells go solid; the next piece in the list is shown with its ghost.
**Wacky test**: surprising, fireflies are the targets; silly, a firefly on Chip's nose; funny failure, the jar goes dim and Chip sighs; big moment, the jar lighting up.

```json
{ "schema": 1, "id": "forest_06", "biome": "forest", "tier": 6,
  "board": { "width": 4, "depth": 4, "h_play": 6 },
  "pieces": { "fixed_list": ["l","i","o","l","i","i"] },
  "knobs": { "fall.g0": 0.60, "spawn.preview_count": 3, "goal.top_out": "out_of_pieces" },
  "goal": { "type": "shape", "piece_budget": 6,
            "target_shape": { "layers": { "0": ["####","####","####","####"], "1": [".##.",".##.",".##.",".##."] } } },
  "stars": { "t2": 75000, "t3": 50000 },
  "solution": "see level notes",
  "music": "forest_06_tbd" }
```

---

### 07 Leaf-Swept Branch

**Story card.** Autumn leaves swirl around the branch from every side. The arrow shows where the next gust goes, and a maple seed splits when it lands. · **Chip: watcher** (chases leaves).
**Stage**: busy; a long branch among drifting leaves. **Light**: lantern dusk. **Intro skit** (3 s): a leaf lands on Chip's head; a gust swirls it round; Chip chases it in a spin (`question`). **Payoff skit** (4 s): the leaves settle into one tidy pile; Chip jumps in (`sparkle`). **Mizzle clue (M, 1.5 s)**: he watches Chip from behind a trunk; counts on his fingers to two, and smiles (`dots`). **Reactions (R)**: gust warning `exclaim`; clear `sparkle`.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV01 Leaf Gust (wind_mode rotating) · SP28 maple seed
One sentence: "Gusts come from any side: read the arrow."
New to the player: nothing (EV01 and SP28 are Meadow 03); the direction now changes each gust.
```
**Encounters**: **Leaf Gust**, `wind_mode` rotating (one of the four ground axes per gust, drawn when the gap is drawn so the arrow shows it), `wind_interval_ms` 9 000 ± 2 500, `wind_strength` 1, `wind_warn_ms` 1 000 (arrow of leaves on the board edge, world-anchored). **Maple seed** (SP28): 1 piece per bag; on landing it splits into its two halves (seeded cut), which fall separately like a spinning seed.

```text
top-down 6×6 (gust direction rotates)   side (z = 2)
######     ↑                            13 . . . S . .   spawn zone
######                                  10 =============  danger line
##S###     ← →  one of four             :
######                                   0 # # . # # #
######
######
```
**How it plays**: (1) the first piece falls calm; a leaf swirl arrives. (2) The first gust may push left, then the next up: the player learns the arrow. (3) The player builds a flat stack so any direction is fine; a maple seed splits and its halves scatter. (4) Four clears.
**Teaches**: reading a directional telegraph, which prepares the finale's cross-gusts.
**Readability**: the arrow and leaf streaks are world-anchored; they stay correct after a camera snap. Gusts never move locked cubes.
**Wacky test**: surprising, wind from every side; silly, Chip spinning after a leaf; funny failure, a gust blows a piece onto the wrong edge and Chip laughs; big moment, a long swirl of leaves across the whole board.

```json
{ "schema": 1, "id": "forest_07", "biome": "forest", "tier": 7,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 1.15, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "gust", "params": { "wind_mode": "rotating", "wind_interval_ms": 9000, "wind_jitter_ms": 2500, "wind_strength": 1, "wind_warn_ms": 1000 } },
             { "id": "split_piece", "params": { "per_bag": 1 } } ],
  "stars": { "t2": 325000, "t3": 230000 },
  "music": "forest_07_tbd" }
```

---

### 08 Woodpecker Trunk ★PROTO

**Story card.** A woodpecker knocks on the trunk, and the shiver shakes loose any cube with nothing under it. Build flat, or use the leafy vine pieces: they hold their neighbours tight. · **Chip: watcher** (a cap of bark on its head).
**Stage**: busy, tense; a tall trunk, a woodpecker with a drum rhythm. **Light**: lantern dusk. **Intro skit** (3 s): the woodpecker knocks; an acorn drops onto Chip's head (`exclaim`). **Payoff skit** (4 s): the knocking stops; the woodpecker taps a thank-you rhythm and Chip taps back. **Mizzle clue (M, 1.5 s)**: a small crooked block appears on the stream bank; he peeks, then takes it back (`sweat`). **Reactions (R)**: warning `exclaim`; vine saves a cube `sparkle`; cubes pop `sweat`.

```text
Recipe: BL01 (4×4, H12) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · EV12 Woodpecker Knock · SP12 Vines
One sentence: "Knock, knock: loose cubes pop off."
New to the player: EV12, SP12 (2).
```
**Encounters**: **Woodpecker Knock** (§1): interval 13 s ± 3 s, warning 1.5 s with dotted outlines on the cubes that would pop, at most 4 cubes per knock, highest first, applied at the next Resolving. Counter: **ride it out** (build flat) or use **Vines**: one vine piece per bag, whose cubes and touching cubes are immune. Stitch (Lana) vetoes a knock; Smash is irrelevant. Pieces 8 Std.

```text
top-down 4×4      side (z = 1)
####              15 . S S .   spawn zone
####              12 ========  danger line
####               :
####               2 . # # .   dotted outlines on overhang cubes
                   1 # . # #
                   0 # # # #
```
**How it plays**: (1) a calm start; the woodpecker taps but nothing falls. (2) After the first knock, the player sees which overhang cubes would have popped and learns to build flat. (3) A vine piece appears and the player uses it to hold an awkward overhang. (4) Five clears on a narrow trunk.
**Teaches**: reading dotted outlines, and the vine counter-tool.
**Readability**: only cubes with an empty cell directly below are outlined; the cap of 4 means a knock never wipes the board; popped cubes hop off with a cartoon "bock".
**Wacky test**: surprising, the tree shakes cubes loose; silly, the drum rhythm and Chip's tapping back; funny failure, a lid pops off your hole and the woodpecker bows; big moment, a vine piece saving a whole shelf of cubes.

```json
{ "schema": 1, "id": "forest_08", "biome": "forest", "tier": 8,
  "board": { "width": 4, "depth": 4, "h_play": 12 },
  "knobs": { "fall.g0": 1.20, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 5 },
  "rules": [ { "id": "woodpecker_knock", "params": { "knock_interval_ms": 13000, "knock_jitter_ms": 3000, "knock_warn_ms": 1500, "knock_pop_max": 4 } },
             { "id": "vines", "params": { "vine_per_bag": 1 } } ],
  "stars": { "t2": 180000, "t3": 130000 },
  "music": "forest_08_tbd" }
```

---

### 09 Root-Belt Bank (remix)

**Story card.** The roots on the bank slide the whole stack sideways, and squirrels still raid your fullest layer. Drop where the gap will be, and finish layers before the squirrels. When the last clear shakes an acorn loose, someone small reaches for it too. · **Chip: watcher** (carried along on a root).
**Stage**: busy; a bank of writhing roots, squirrels in the leaves. **Light**: lantern dusk. **Intro skit** (3 s): the roots slide like a conveyor and carry Chip along; it clings and looks back (`question`). **Payoff skit = first contact** (5 s): see §8. **Reactions (R)**: belt wind-up `exclaim`; heist warning `exclaim`; clear `sparkle`. **Friend cameo (payoff)**: Boulder carries a plank past the post, background only.

```text
Recipe: BL01 (7 wide × 5 deep, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV05 Root Slide [mechanic] · EV25 Squirrel Heist · WO09
One sentence: "The roots move your stack; the squirrels raid it."
New to the player: nothing (both known).
```
**Encounters**: **Root Slide** (conveyor, mechanic): +x, every 3 locks, wrap on (unmasked rectangle). **Squirrel Heist**: every 5 locks, 1 lock warning. The target marker follows its cube when the roots slide (the stack moves as one). The belt moves what the squirrels target, so the "drop where the gap will be" skill and "finish before it is stolen" combine. Stitch vetoes both (counter allowed). Pieces 8 Std.

```text
top-down 7×5 (belt → along x)    side (z = 2)
→ → → → → → →                    15 . . . S . . .   spawn zone
#######                          10 ===============  danger line
#######                           :
###S###                           1 # # . # # . #
#######                           0 # # # . # # #   → shift +x, wrap
#######
```
**How it plays**: (1) after the 3rd lock the stack slides right and wraps; roots writhe one lock ahead. (2) The first heist marks the fullest layer; the player rushes to complete it as the belt shifts. (3) The player learns to leave the gap one cell to the *left* of where it will land. (4) The last clear shakes an acorn loose: first contact.
**Teaches**: the remix of two known ideas; the hardest combination in the biome.
**Readability**: the belt wind-up and the squirrel's target marker are separate beats: the belt moves on the lock, the squirrel strikes on the next lock. Never on the same lock (validator: heist strikes on locks not divisible by the belt interval when possible).
**Wacky test**: surprising, the floor moves while a squirrel grabs a cube; silly, Chip riding a root; funny failure, a squirrel and a belt meet and the cube pops off the wrong end; big moment, the acorn tumble.

```json
{ "schema": 1, "id": "forest_09", "biome": "forest", "tier": 9,
  "board": { "width": 7, "depth": 5, "h_play": 10 },
  "knobs": { "fall.g0": 1.25, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "conveyor", "params": { "dir": "+x", "conveyor_every": 3, "conveyor_wrap": true } },
             { "id": "squirrel_heist", "params": { "heist_every_locks": 5, "heist_warn_locks": 1 } } ],
  "stars": { "t2": 315000, "t3": 225000 },
  "music": "forest_09_tbd" }
```

---

### 10 Oak's Gap (boss: Grandpa Oak) ★PROTO

**Story card.** The wind chimes keep ringing, and Grandpa Oak wants a nap. Phase 1: he rustles his leaves, shakes his acorns and stomps his roots. Each clear knocks a chime off his branch. The last clear makes him yawn, burst into pink blossom and lie down across the gap as the bridge. · **Boss**: Grandpa Oak (a wide trunk, bushy brow, root feet); Chip holds a plank and watches.
**Stage**: busiest, but soft; the stream gap, Oak's crown with three chimes, blossoms waiting. **Light**: blossom twilight. **Intro skit** (3 s, from the skits doc): 0.0–1.0 the chimes tinkle, Oak yawns and snaps awake (`angry`); 1.0–2.0 he shakes his branches, acorns rain on the stream; 2.0–3.0 hand-off: Chip with a plank looks up at the wizard, glint, first piece. **Payoff skit** (6 s on first play, the last 2 beats on replays; from the skits doc): 0.0–1.5 last clear, Oak yawns across the stream (`sleep`); 1.5–3.0 he bursts into pink blossom and settles as the bridge, keepsake pop: the acorn; 3.0–4.0 Chip scampers across, gnaws the handrail, stops itself (`sweat`); 4.0–5.0 [R] the chimes hang in the blossoms, ringing softly, Oak snores (`sleep`); 5.0–6.0 [R] the tiny crooked block sits on the bridge post (callback to 09, a held 0.5 s, not a new clue). **Mizzle clue**: none new. **Reactions (R)**: each clear Oak sulks and a chime falls (`angry` then `sleep`); warning use Oak grins.

```text
Recipe: BL01 (8 wide × 6 deep, H12) · AR01 · CV01 · GO01 (3 = 3 chimes) · FT01 (1) · CL01 + CO01 · EV05 Root Slide [mechanic] · EV01 Leaf Gust · EV04 Acorn Shower + SP19 · WO09
One sentence: "The roots slide your stack; the wind and acorns come too."
New to the player: nothing (all three known).
```
**Encounters**:
- **Root Slide** (conveyor): +x, every 3 locks, wrap on (the board is a rectangle because Conveyor forbids masks).
- **Leaf Gust**: fixed +z (across the belt), every 10 s ± 2.5 s, 1 cell, 1 s warning.
- **Acorn Shower**: every 6 locks, max 3, `place_mode` random; marked one lock ahead.
- **Staggered starts (decision)**: no phase atom is needed. Belt shifts on the 3rd lock, the first gust falls due at about 8–12 s, and the first acorn is marked on the 5th lock, so the rules arrive one after another and the player is never hit by all three at once on the first lock. Each clear knocks a chime off Oak's branch: staging only; the rules do not change. Squirrels and the woodpecker are not used (they are Oak's friends, not his weapons); a third twist (the finale allowance) is unused.
- Oak is the face of the rules: the belt is his stomping roots, the gust is his rustling leaves, the acorns are his shaking branches. He sulks on each clear and dozes more on each chime that falls.

```text
top-down 8×6 (belt → along x, gust ↓ along +z)   side (z = 3)
→ → → → → → → →                                  15 . . . S S . . .   spawn zone
########                                         12 ================  danger line
########   ↓                                      :
###S####                                           1 # # . . # # . #
########                                           0 # # # . # # # #   → shift +x, wrap
########
########
```
**How it plays**: (1) after the 3rd lock the whole stack slides right and wraps. (2) The first gust blows across the belt; the first acorn marks a cell. (3) Each clear drops a chime and Oak's eyelids sink. (4) The third clear and he yawns, blooms, and becomes the bridge.
**Teaches**: nothing new: it is the final exam of belt, wind and acorns.
**Readability**: three clear, distinct disturbance types with three different telegraphs (roots writhe, leaves swirl, sparkle); each fires at a different time. If playtests find it too busy, drop the gust to every 14 s or swap it out (§10).
**Wacky test**: surprising, the tree itself is the boss and the bridge; silly, Oak's brows and snores; funny failure, he grins when you use a warning; big moment, the pink blossom and the chimes ringing.

```json
{ "schema": 1, "id": "forest_10", "biome": "forest", "tier": 10,
  "board": { "width": 8, "depth": 6, "h_play": 12 },
  "pieces": { "shapes": ["i","o","t","l","tripod","screw_l","screw_r","chair"] },
  "knobs": { "fall.g0": 1.30, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 3 },
  "rules": [ { "id": "conveyor", "params": { "dir": "+x", "conveyor_every": 3, "conveyor_wrap": true } },
             { "id": "gust", "params": { "wind_mode": "fixed", "wind_dir": "+z", "wind_interval_ms": 10000, "wind_jitter_ms": 2500, "wind_warn_ms": 1000 } },
             { "id": "mushroom_popup", "params": { "spawn_every_locks": 6, "objects_max": 3, "skin": "acorn" } } ],
  "stars": { "t2": 325000, "t3": 230000 },
  "music": "forest_10_tbd", "story": { "mascot_role": "boss", "icon": "oak" } }
```

---

### B Berry Basket (bonus, tier 11, 20 forest stars)

**Story card.** Chip's berry bush is ripe. Pick the pieces in any order from the kit box and pack the basket before bedtime. Nine pieces, no spares. · **Chip: watcher** (hops from foot to foot).
**Stage**: clean; a berry bush glade, a woven basket. **Light**: sunset berry. **Intro skit** (3 s): Chip holds an empty basket under a ripe bush; one berry drops into it with a plink (`sparkle`). **Payoff skit** (5 s, from the skits doc): 0.0–2.0 the last berry tops the basket; 2.0–4.0 Chip starts gnawing the handle (`idea`); 4.0–5.0 the handle drops and Chip holds both halves up proudly (`sparkle`). **Postcard 6** (Scrapbook only, not in-level): his candles are blown out by a far gust. **Reactions (R)**: good pick `sparkle`; wrong lock `sweat`.

```text
Recipe: BL01 (4×4, H7) · AR13 kit box [O×4, I, L×2, Duo×2] · CV01 · M2 fill shape (GO03 32 cells + CL14) · FT07 piece budget (9) · WO09
One sentence: "Nine pieces in any order: pack the basket."
New to the player: AR13 (1). Retry is free; reset is instant.
```
**Encounters**: none. The kit box shows all nine pieces; pick one, it falls. Known solution: layer 0 (the base, 16): four O quadrants; layer 1 (the ring, 12): I along z0, L (x0 z1–3 plus x1 z3), L (x3 z1–3 plus x2 z3); layer 2 (the handle posts, 4): Duo on (x0, z1–2), Duo on (x3, z1–2). Every placement is supported only if the layer below is done first, so the order matters. Stars: ★★ 130 s, ★★★ 90 s.

```text
layer 0   layer 1   layer 2   side (z = 1)
####      ####      ....      7 =====
####      #..#      #..#      :
####      #..#      #..#      2 # . . #   handle posts
####      ####      ....      1 # . . #   ring
                              0 # # # #   base
```
**How it plays**: (1) read the kit and see the three-layer basket. (2) Pick the Os for the base first. (3) The ring's I and L's lock the rim; the hollow stays empty. (4) The Duos make the handle; Chip gnaws it.
**Teaches**: the kit box (order matters). It is the biome's wackiest level (the handle gag).
**Readability**: target cells glow berry-pink; the next-supported layer is lit; used pieces are greyed in the box.
**Wacky test**: surprising, you pick the order; silly, a gnawed handle; funny failure, a wrong pick and the berries roll away; big moment, the handle posts closing.

```json
{ "schema": 1, "id": "forest_bonus", "biome": "forest", "tier": 11,
  "board": { "width": 4, "depth": 4, "h_play": 7 },
  "pieces": { "kit": ["o","o","o","o","i","l","l","duo","duo"] },
  "knobs": { "fall.g0": 0.60, "spawn.arrival": "kit_box", "goal.top_out": "out_of_pieces" },
  "goal": { "type": "shape", "piece_budget": 9,
            "target_shape": { "layers": { "0": ["####","####","####","####"], "1": ["####","#..#","#..#","####"], "2": ["....","#..#","#..#","...."] } } },
  "stars": { "t2": 130000, "t3": 90000 },
  "music": "forest_bonus_tbd" }
```

---

## 7. Hard-track remixes (tiers 12–14; open after 10)

### H1 Firefly Night

**Story card.** Chip chewed the lantern's candle and the glade went dark. Your stack fades into a faint swarm of fireflies, and leaves swirl from every side. · **Chip: watcher** (holds a stub of candle). **Light**: firefly dusk (dark). **Intro skit**: Chip bites the candle; the lantern goes out and fireflies take its place (`sweat`). **Payoff skit**: the lantern is relit; Chip tries to bite a firefly and gets a spark on its nose (`question`).

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · EV02 Firefly Night (visible 4 000 ms, fade 1 000, alpha 0.12, reveal 600) · EV01 Leaf Gust (rotating, 10 s ± 2.5 s)
```
```text
top-down 6×6        side (z = 2)
######              10 ===========
######               :
##S###               1 ~ ~ . ~ ~ ~   ~ = faded cubes show as fireflies
######               0 # # . # # #
######
######
```
Pieces 8 Std; `g0` 1.20; Clear 5; ★★ 410 s, ★★★ 290 s (~8 min).

### H2 Raiders & Woodpecker

**Story card.** The squirrels raid your fullest layer while the woodpecker rattles the loose cubes. Use the vine piece to hold the shelf. · **Chip: watcher** (hides under a leaf). **Light**: dappled gold. **Intro skit**: the squirrel crew and the woodpecker meet on a branch and shake on it (`exclaim`). **Payoff skit**: the squirrels and woodpecker take a bow as a band; Chip claps.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV25 Squirrel Heist (every 7 locks) · EV12 Woodpecker Knock (every 15 s ± 3 s, pop max 3) · SP12 Vines (1 per bag)
```
```text
top-down 6×6     side (z = 2)
######           10 ===========
######            :
##S###            2 . # # # . .   dotted outlines: next knock pops
######            1 # . # # # #
######            0 # # # # # #
######
```
Pieces 8 Std; `g0` 1.20; Clear 4; ★★ 325 s, ★★★ 230 s (~6.4 min). Stitch vetoes both rules (valid counter).

### H3 Canopy Windows

**Story card.** The windows in the roof again, and now the wind blows pieces over them. Fall through the windows, or build on the roof. · **Chip: watcher** (leans out of a window). **Light**: lantern dusk. **Intro skit**: a gust blows a leaf into a window, then out of another; Chip follows with its eyes (`question`). **Payoff skit**: Chip leans out of a window to catch a leaf and falls into the next.

```text
Recipe: BL17 canopy shelf (6×6, H10, shelf_y 3, two 2×2 openings; 3 starter layers as data) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV01 Leaf Gust (rotating, 8 s ± 2 s)
```
```text
starter layers 0–2 (same)   shelf layer 3      side (z = 1)
..####   hole A (x0–1)      ooSSSS              10 =============
..####                      ooSSSS               :
######                      SSSSSS               3 o o S S S S   shelf, opening A
######                      SSSSSS               2 . . # # # #   chamber, hole A (3 deep)
####..   hole B (x4–5)      SSSSoo               1 . . # # # #
####..                      SSSSoo               0 . . # # # #
```
Pieces 8 Std + Big Cube (w 0.4); `g0` 1.15; Clear 4 (three chamber layers by filling both 2×2×3 holes with 6 pieces, one deck layer); hand-set ★★ 170 s, ★★★ 120 s (~3.5 min).

---

## 8. Narrative beats

Wordless (campaign story rules): intro and payoff skits per level, Chip's reactions, Oak in the backdrop from 01, one Mizzle clue per level from 03 (at most 1.5 s, never over the grid, never during a warning). Arc: Chip builds a shelf (01), beds the kits (02), rebuilds the bridge (03), is robbed by squirrels (04), climbs the treehouse (05), jars fireflies (06), is swirled by leaves (07), is knocked by the woodpecker (08), rides the roots (09, **first contact**), and wakes Oak to a bridge of blossom (10). The bonus and remixes are after-party gags.

| Level | Mizzle clue (strength cap 3) | Emote |
|---|---|---|
| 03 | Fireflies gather around a droopy hat in the shade; it shoos them, they stay | `blush` |
| 04 | He sits on a far log, doodles a block; nearly square | `idea` |
| 05 | He tiptoes past Oak to retie a chime that clinks | `sweat` |
| 06 | He picks up one of Chip's dropped planks and leans it neatly by the bridge | `dots` |
| 07 | He watches Chip from behind a trunk; counts on fingers to two, smiles | `dots` |
| 08 | A small crooked block appears on the stream bank; he peeks at it, takes it back | `sweat` |
| 09 | ★ **First contact**: the last clear shakes an acorn loose; the wand glint and a violet cuff reach it together | `blush` |

**First contact (09 payoff, 5 s)**: 0.0–0.5 the acorn drops from Oak's branch; the player's glint and the cuff touch it together. 0.5–1.0 Mizzle sees the wizard and freezes (`blush`). 1.0–1.5 he flees; where he stood sits a tiny crooked block. 1.5–5.0 the stack and the roots settle; Chip looks at the block and at the wizard (`question`). The glint is the player's last clear (the wizard reacts to the player's play, rule 8). The block is matte and mismatched, never glossy.

**Map change (3 s, after the finale)**: 0.0–1.0 blossom covers the bridge, flag 6 rings as chimes; 1.0–2.0 the crooked block pops onto a corner of the hat's map icon (the wizard keeps it as a prop, not a Keepsake); 2.0–3.0 the horizon tower gets a fifth floor, noticeably straighter. **Hidden thread**: a violet ribbon on a low branch of Oak (backdrop, from 03).

## 9. Music and audio cues

One track per level, supplied by the user; ids are placeholders (`forest_01_tbd` … `forest_10_tbd`, `forest_bonus_tbd`, H1–H3 reuse `forest_07_tbd` until the user provides new ones). Until the tracks arrive, every Forest level plays the biome `default_music` ("Carefree" is a placeholder only). No stems and no layered mixes: each track simply plays for its level. Authoring notes for the user's tracks: 01–03 relaxed and bright, 04 a little cheeky for the squirrel raid, 05–06 hushed (no danger music, since neither can be lost), 07–09 warm lantern tempo, 10 the biggest and ends in a soft chime, the bonus a sweet berry-picking tune. A **danger stinger** only where `topout_rule` is rescue. Skits use short stingers, never voices.

SFX cues (one-shots, no music change): wind chimes on every clear in 10 (one chime falls); a woodpecker knock triplet on EV12; a squirrel scamper and "pop" on a heist; acorn plops on landing; the roots rumble one lock before a belt shift; a flower-bloom "ahh" on the 10th payoff. The SFX pack (MB-003) provides the base sounds.

## 10. Open questions

- **EV25 Squirrel Heist is a new atom.** It needs adding to `mechanics-module.md` as Proposed (slot 11, tags `grid stack`, counter: clear to cancel) with its rule JSON and a `stack` tag for Stitch. Owner: game-designer.
- **BL17 canopy shelf (Proposed) semantics.** (a) I assume CO01 slice collapse never moves the shelf; layers below the shelf clear and fall within the chamber. (b) The module's "the shelf layer clears on its non-shelf cells" is ambiguous; 02 and H3 are written so they never rely on it (the third clear comes from the deck). (c) BL05 and BL17 are both Board-slot atoms; I use `starting_contents` as data inside BL17 instead of a second atom. Owner: game-designer / ADR-0002.
- **AR13 Kit box (Proposed)** needs its `SimCommand` for picking a piece (module hook). The bonus relies on it. Owner: game-designer.
- **EV12 and SP12 (Candidate)** need their rules written into an owning GDD. EV12 here pops overhang cubes (FT04 logic) with a cap of 4 per knock, evaluated once, so a chain cannot clear a stack; SP12 vines flag the piece and its touching cubes at lock. Both are tunable. Settle-style knocks were rejected because they work as a free hole cleanup.
- **`place_mode` on `mushroom_popup`** (`random` / `lowest`) is a proposed param (twist-library rule 20 allows variants); 03 falls back to `random` with no gameplay change if it is not added.
- **Lighting mismatch.** `lore-world.md` §3.6 (six presets, firefly at L6) and `visual-direction.md` (five stages, firefly night at L9) differ. This file follows the lore. Owner: art-director.
- **F1 recount.** "New to the player" is counted against the Meadow and earlier Forest levels only; the Candy, Ice, Underwater and Lava files are not written yet. Recount against the real path order (atoms from those biomes may already be known, which only lowers the counts). The bundle table in the module may also want EV04 + SP19 as one bundle (counts 1).
- **06 and B `solution` lists.** The validator should replay the known solutions given above. In 06 one L must be mirrored (Flip); confirm the Std L can be flipped over.
- **10 busyness.** If playtests find Root Slide + Leaf Gust + Acorn Shower too much, slow the gust (14 s) or swap it out with EV13 as in the Meadow, or spend the finale's third-twist allowance on nothing. EV18 lift tiles (considered for a hard-track "Rising Roots") are not used because their rule is unspecified.
- **Skills.** Stitch vetoes `stack` writes; Smash can remove a chunk (it can undo a Heist hole or a knock-popped lid). Neither is tuned against. Glim does not join until the Cave.
- **Star times** are formula estimates (and hand-set where noted); replace with playtest medians.
