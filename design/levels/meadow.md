# Meadow Biome: Pip's Picnic (levels 01–10, bonus, hard track)

> **Status**: Approved design (user, 2026-10-10). Replaces the 2026-10-09 draft.
> **Author**: Tessa + level-designer
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Sources**: `production/levels/meadow/layout.md` (sketch draft), `production/levels/campaign/biome-stories.md` (story), `production/levels/campaign/biome-bible.md` §2.1, `design/gdd/mechanics-module.md` (atoms), `docs/architecture/adr-0005-data-format-validator.md` (level JSON).
> **Field definitions**: `design/gdd/level-data-definition.md`; defaults from the owning GDDs.

**Every number, name and beat in this file is a tunable default**, a starting point for the prototype and playtests. The validator enforces only the safe ranges in the owning GDDs.

---

## 1. Level name and theme

**Pip's Picnic.** Pip the harvest mouse wants a picnic on the hilltop with all the meadow friends. Blocks fall as a soft **block drizzle** from a sunny sky. The Miller, a flour-dusted badger who likes his mill quiet and his gusts loud, rigs the mill to blow gusts, pop mushrooms, fog the grass and flip the hill. In the finale the last clear bonks him off his roof into a flour cloud; he stomps off vowing a rematch. Keepsake: a tiny windmill on the wizard's hat.

**Quirk: "Gentle weather."** Each level adds at most one visible disturbance (plus at most one special piece), and plain layer clears are home base. The Meadow is the most classic biome (about 85% classic play), but strangeness **zig-zags** level to level rather than rising in a straight line.

### Biome rules (decisions)

| Rule | Default |
|---|---|
| Islands | One per level, shaped by the story (seed plot, burrow, hillside lane, pond ring, hilltop, garden bed, foggy hollow, dewy lawn, tree island, mill yard) |
| Stage | Busy diorama or clean stage per level, as the story needs; calm puzzle levels are quiet, chaos levels busy |
| Intro skit | A 3-second wordless mini-scene in which Pip shows the problem, played during the Countdown (no play time lost) |
| Payoff skit | A short skit on every win in which the tiny story resolves |
| Mascot | **Pip** (Meadow only). Tiers 1–3: helper (points at a good cell + **Pip's catch**, below). Tier 4 on: watcher (reactions only). Pip never pranks here |
| The Miller | Visible on the hill from 03 on, causing every disturbance; boss in 10 |
| Physics | Only 05 Tall Tower (wobble) |
| Rubber duck | Hidden under the island in 01 and 02 (SE05, visible from one low snap angle; tap to collect; no stars attached) |
| Events as Meadow events | Wind = Dandelion Gust, Spawned Objects = Mushroom Pop-up, Invisible Blocks = Morning Fog, Gravity Flip = Topsy Tumble, Conveyor = Mill Belt |
| Prototype priority | **02, 05, 09, 10** (★PROTO) |

**Pip's catch (WO11, tiers 1–3).** Once per level (`mascot_catches` 1), when a piece locks so that it leaves at least one **new covered hole** (an empty active cell directly below one of its cubes) **and** clears nothing, the lock is undone before Resolving: Pip leaps and catches the piece (about 300 ms), and it returns to the spawn position in its current orientation with the gravity clock reset. Not on a lock that meets the goal, not during a warning. Catches do not affect stars. Tiers 4+ and the hard track: 0.

**Common defaults** (unless a level says otherwise): weighted bag, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, all rotation axes, `t_piece` 8 s. Speeds are hand-set and match campaign F2 (`0.6 + 0.045 × (tier − 1)`) within ±0.05. Special pieces "1 per bag" means one piece in each bag carries the tag (a Standard shape, chosen by the bag's seed).

**Budget (mechanics module F1).** At most 2 atoms new to the player and 4 non-default atoms per level. "New" counts only non-default atoms; a level mechanic bundle (M1 = GO02 + CL14 + FT02, M2 = GO03 + CL14) counts as one idea. Slot defaults: BL01, AR01, CV01, CL01, CO01, GO01, FT01.

**Grids**: one string per row, row 0 = `z = 0` (back), character 0 = `x = 0` (left). Mask `#` active, `.` off; starting layers `#` starter block, `.` empty; targets `+` / `#` target cell. Side views are a slice at one `z` row seen from the front; `=====` is the danger line at `H_play`, `S` the spawn zone, `:` skips empty rows.

## 2. Estimated play time and summary

| # | id | Name | Story beat | New idea (atoms) | Pip | Stage | Goal | Board | Pieces | g0 | Top-out | Length | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | meadow_01 | First Sprout | Plant Pip's seed | drizzle, spin only (CV02) | helper | clean, calm | Clear 4 | 4×4, H8 | 5 flat; first 2 from {O, I} | 0.6 | rescue, 2 | ~3 min | 145 / 105 s |
| 02 ★ | meadow_02 | Tilt & Roll | Beds in the burrow | tilt/roll, pockets (BL05) | helper | clean, calm | Clear 3 | 6×6, H10 + 2 starter layers | 8 Std; first 3 a bag of {Tripod, Screws} | 0.6 | rescue, 1 | ~2.5 min | 130 / 90 s |
| 03 | meadow_03 | Breezy Hill | Seeds on the wind | Gust (EV01), puff pieces (SP28) | helper | busy | Clear 5 | 8×4 lane, H10 | 8 Std | 0.7 | rescue, 1 | ~7 min | 365 / 255 s |
| 04 | meadow_04 | Mushroom Ring | Pond party crashers | ring (BL02), Pop-up (EV04 + SP19) | watcher | busy | Clear 3 | 7×7 ring, H10 | 8 Std | 0.75 | rescue, 1 | ~5.3 min | 270 / 190 s |
| 05 ★ | meadow_05 | Tall Tower | Spy on the mill | build race (M1), wobble (PL03) | watcher | clean, tense | Height 10 (cov. 0.6) | 5×5, H12 | 8 Std + Big Cube (w 0.5) | 0.8 | trim | ~4.7 min | 240 / 170 s* |
| 06 | meadow_06 | Flower Bed | Picnic bouquet | fill shape (M2), sprouts (SP22) | watcher | clean, calm | Shape 50 | 8×8, H8 | I O T L S Tripod Duo Tri-Corner | 0.7 | trim | ~3 min | 155 / 110 s* |
| 07 | meadow_07 | Hide & Seek | Morning fog | Fog (EV02), fog ghost (SP26) | watcher | busy, hushed | Clear 4 | 6×6, H10 + 2 starter layers | 8 Std | 0.85 | rescue, 1 | ~4 min | 195 / 140 s |
| 08 | meadow_08 | Dewdrop | Stuck in the dew | Survive (GO04), sticky (PL01) | watcher | clean, tense | Survive 150 s | 5×5, H8 | 8 Std | 0.9 (× 0.7) | rescue, 1 | 2.5 min | 1 / 2 layers |
| 09 ★ | meadow_09 | Topsy-Turvy | The hill flips | Flip (EV03), eggs (SP21) | watcher | busy | Clear 4 | 6×6, H10 | 8 Std | 0.95 | rescue, 1 | ~6.4 min | 325 / 230 s |
| 10 ★ | meadow_10 | Meadow Mill | Boss: the Miller | Mill Belt (EV05), 2-phase boss | boss | busiest | Clear 3 | 8×6, H12 | I O T L Tripod Screws Chair | 1.0 | rescue, 1 | ~6.2 min | 315 / 225 s |
| B | meadow_bonus | Picnic Puzzle | Pack before the ants | fixed list (AR09), budget (FT07) | watcher | clean, hurried | Shape 32 in 60 s | 4×4, H6 | fixed: I O BigCube I O BigCube | 0.5 | out of pieces / 60 s | ≤ 1 min | 45 / 30 s* |
| H1 | meadow_h1 | Seed Sprouts | The sprout went to seed | sprouts (SP22) + gust | watcher | busy | Clear 5 | 6×6, H10 | 8 Std | 0.9 | rescue, 1 | ~7 min | 410 / 290 s |
| H2 | meadow_h2 | Picnic Ants | Ants raid the stack | ants (SP31) + mushrooms | watcher | busy | Clear 4 | 6×6, H10 | 8 Std | 0.9 | rescue, 1 | ~6 min | 325 / 230 s |
| H3 | meadow_h3 | Two Fields | Two patches, one drizzle | islands (BL07) | watcher | clean, tense | Clear 3 per field | 2 × 4×4, H8 | 8 Std | 0.85 | rescue, 1 shared | ~4 min | 220 / 155 s |

★ = prototype priority. \* ★★★ also requires no cube trimmed (Scoring & Stars). Star times use Scoring & Stars F1 except 02 and 07 (hand-set, because starter layers make F1 overestimate) and B (hand-set against its 60 s clock). Length notes: 01, 02, 06, 08 and B are short on purpose; the validator's length warning is expected.

**Hard track (decision).** `meadow_bonus` is tier 11 (unlocks at 20 meadow stars). The remixes are **tiers 12–14** (`meadow_h1`–`h3`); all three open when `meadow_10` is finished. Neither the bonus nor the remixes count toward the next biome's star gate. Stars still pay points as usual.

## 3. Layout overview

```text
01 seed plot   02 burrow     03 hillside lane   04 pond ring   05 hilltop
####           ######        ########           #######        #####
####           ######        ########           #######        #####
####           ######        ########           ##...##        #####
####           ######        ########           ##...##        #####
               ######                           ##...##        #####
               ######                           #######
                                                #######
06 garden bed  07 foggy hollow  08 dewy lawn  09 tree island  10 mill yard (belt →)
########       ######           #####         ######          ########
########       ######           #####         ######          ########
########       ######           #####         ######          ########
########       ######           #####         ######          ########
########       ######           #####         ######          ########
########       ######                         ######          ########
########
########
```

## 4. Critical path and optional paths

- **Critical path**: 01 → 10 in order (linear inside a biome). Finishing 10 completes the Meadow; the next biome opens with 15 of 30 stars.
- **Optional**: ★★★ times on every level; the rubber duck in 01–02; the bonus Picnic Puzzle (20 stars); hard-track remixes H1–H3 (after 10).

## 5. Pacing chart

```text
strangeness (how far from classic)
 high |                    #           #   #
      |                 #  #     #  #  #   #
  mid |        #  #     #  #  #  #  #  #   #
      |     #  #  #     #  #  #  #  #  #   #
  low |  #  #  #  #     #  #  #  #  #  #   #
      +-01-02-03-04----05-06-07-08-09-10--B
        learn  twist   no-fail  mem sprint flip FINALE
```

Zig-zag, not a ramp: two teaching levels → two twist levels → a no-clear break (05 tower, 06 picture; no fail) → memory → a short sprint → the flip → the two-phase finale. Short and long levels alternate (campaign rule 12); no two pressure peaks in a row before the finale.

---

## 6. Level specs (encounter lists, sketches, beats)

### 01 First Sprout

**Story card.** Pip found a seed and needs a tidy plot to plant it. Every clear grows a leaf; four leaves make a sprout. · **Pip: helper** (points at the emptiest cell; one catch).
**Stage**: clean, calm; a bare plot of soil. **Intro skit**: Pip digs a hole, drops in the seed, pats it, looks up at the drizzle and waits. **Payoff skit**: the sprout shoots up into a sunflower taller than Pip; Pip hangs the picnic basket on it.

```text
Recipe: BL01 (4×4, H8) · AR01 · CV02 spin only · GO01 (4) · FT01 (2 warnings) · CL01 + CO01 · SE05 duck · WO11 catch
One sentence: "Fill a whole layer and it clears."
```
**Encounters**: none (pure classic). Pieces I, O, T, L, S; `opening_set` [O, I], count 2. `T_level` 180.

```text
top-down 4×4      side (z = 1)
####              11 . S S .   spawn zone
#S##               8 ========  danger line
####               :
####               0 . . . .   the seed plot
```
**How it plays**: (1) an O drifts down slowly; Pip points at a corner. (2) The first layer clears in about 4 pieces: the plot sinks, a leaf pops, a big chime. (3) L, T and S arrive; spin is the only rotation. (4) The 4th clear grows the stalk and a flower opens.
**Wacky test**: surprising, the first clear; silly, a leaf per clear; funny failure, Pip covers its eyes on a warning; big moment, the stalk shooting up.

---

### 02 Tilt & Roll ★PROTO

**Story card.** Pip's stone burrow has three oddly shaped bedroom holes. Fit the three funny pieces so every friend gets a bed. · **Pip: helper** (points at the pocket the current piece fits; one catch).
**Stage**: clean, calm; the burrow in cut-away. **Intro skit**: three sleepy friends in nightcaps stare at the holes; one lies in a hole and sticks out at both ends. **Payoff skit**: each friend flops into a perfect bed and snores; Pip tiptoes out and blows out a candle.

```text
Recipe: BL05 (6×6, H10, 2 starter layers) · AR01 · CV01 (spin, tilt, roll) · GO01 (3) · FT01 (1) · CL01 + CO01 · SE05 duck · WO11 catch
One sentence: "Turn the piece to fit its bed."
```
**Encounters**: three pockets, each exactly fillable by one 3D piece: A Tripod (top L at (1,1)(2,1)(1,2), hole below the corner), B and C the two screws (mirror images; holes below an end). Flat pieces cannot fill a pocket exactly. Pieces 8 Standard; `opening_set` [Tripod, Screw-Left, Screw-Right], count 3 (a bag: each once, random order).

```text
layer 0     layer 1     side (z = 1)
######      ######      10 ==============
#.###.      #..#..       :
######      #.##.#       1  # . . # . .   pockets A (x1–2), B (x4–5)
######      ###.##       0  # . # # # .   holes go 2 deep
####.#      ###..#
######      ######
```
**How it plays**: (1) a Tripod spawns; Pip points at bed A; tilt so three arms sit on top. (2) A screw fits only one of the two remaining beds; rolling it shows the mirror trick. (3) The third bed fills and both starter layers clear together (a double). (4) One free clear on the open board.
**Wacky test**: surprising, the board starts half built; silly, nightcaps on the pocket edges, filled beds snore; funny failure, a "nope" wobble from Pip; big moment, the double clear.

---

### 03 Breezy Hill

**Story card.** Dandelion gusts from the Miller's sails blow Pip's seeds along the hill. Build with the wind, not against it. · **Pip: helper** (one catch; seeds stick to its face).
**Stage**: busy; a grassy slope, dandelions, the mill turning at the top. **Intro skit**: a gust blows the seeds out of Pip's paws and Pip tumbles after them. **Payoff skit**: the wind dies, the seeds land in neat rows down the lane, and Pip plants the last one with a flourish.

```text
Recipe: BL01 (8 wide × 4 deep, H10) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · EV01 Dandelion Gust · SP28 dandelion puff · WO11 catch
One sentence: "Gusts push your piece downhill."
```
**Encounters**: Gust +x toward the x = 7 wall, every 8 s ± 2 s, 1 cell, 1 s warning (grass bends, arrow). **Dandelion puff** (SP28): 1 piece per bag; on landing it splits into its two halves (seeded cut), which fall separately like a scattering seed head.

```text
top-down 8×4 (gust →)   side (z = 1)
########                13 . . . S S . . .   spawn zone
###S####  → → →         10 ================  danger line
########                 :
########                 0 . . . . . . . . |  wall at x = 7 = the brace
```
**How it plays**: (1) first pieces fall calm; the grass starts to bend (telegraph). (2) The first gust shoves the piece one cell right. (3) The player learns to build from the downhill wall so gusts push pieces home; a puff splits and its halves tumble into gaps. (4) Five clears, each blowing seeds toward the mill.
**Wacky test**: surprising, your piece moves on its own; silly, seeds on Pip's whiskers; funny failure, a gust shoves a piece wrong and Pip shrugs; big moment, a long gust streaming petals down the lane.

---

### 04 Mushroom Ring

**Story card.** Cheeky mushrooms keep popping up around the pond. They fill a cell for free, if you plan for them. · **Pip: watcher** (bounces on mushrooms in the backdrop).
**Stage**: busy; the pond, lily pads, frogs watching. **Intro skit**: Pip lays a picnic cloth by the pond; a mushroom pops up under it and launches the cloth into the water. **Payoff skit**: the mushrooms line up and bow; Pip bounces across their heads to fetch the cloth.

```text
Recipe: BL02 (7×7 ring, centre 3×3 off, A = 40, H10, spawn_anchor (3,5)) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · EV04 Mushroom Pop-up + SP19
One sentence: "Mushrooms pop up and fill a cell for you."
```
**Encounters**: a mushroom every 5 locks (max 4) on a free top-surface cell, marked by a sparkle one lock ahead; it clears with its layer.

```text
mask 7×7     side (z = 3, through the pond)
#######      13 . . . . . . .   (spawn on the front band)
#######      10 ==============
##...##       :
##...##       1 # m . . . # .   m = mushroom
##...##       0 # # . . . # #   pond gap
###S###
#######
```
**How it plays**: (1) pieces go around the 2-wide band. (2) After the 5th lock, a sparkle, then a mushroom pops up with a squeak. (3) The player leaves a 1-cell gap where the sparkle is. (4) The third ring closes; the pond splashes.
**Wacky test**: surprising, things grow on your stack; silly, squeaking mushrooms with faces; funny failure, a mushroom blocks the perfect gap and grins; big moment, the pond splash on each clear.

---

### 05 Tall Tower ★PROTO

**Story card.** Pip wants a lookout to spy on the mill. Stack to the wooden sign; nothing clears, too high pops off, and the tower sways. · **Pip: watcher** (climbs as the tower grows).
**Stage**: clean, tense; a bare hilltop and a lot of sky. **Intro skit**: Pip jumps to see over the grass toward the mill, can't, and draws a tower in the dirt. **Payoff skit**: Pip climbs to the top, raises a spyglass and spots the Miller cranking a giant fan; Pip's ears go flat.

```text
Recipe: BL01 (5×5, H12) · AR01 · CV01 · GO02 (H 10, coverage 0.6) + FT02 trim + CL14 [M1 build race] · PL03 wobble
One sentence: "Build up to the sign; nothing clears."
```
**Encounters**: **Wobble** (PL03, the Meadow's one physics level): each overhang cube (a cube with an empty cell directly below) adds sway; at `wobble_max` 6 the most recently placed piece slips one cell toward the heavier side (and pops off if that puts it over the danger line). Trim: cubes at or above layer 12 pop off; the level never fails. Pieces 8 Standard + Big Cube (w 0.5).

```text
top-down 5×5   side (z = 2)
#####          15 . . S . .   spawn zone
#####          12 ===========  danger line (trim)
##S##           9 - - - - -   sign: layer 9 must be ≥ 60% full (15 of 25)
#####           :
#####           0 . . . . .
```
**How it plays**: (1) the floor fills; a full layer glows and stays. (2) The height meter climbs; the sign sways. (3) A Big Cube adds two layers at once; overhangs make the lookout creak and lean. (4) Layer 9 reaches 15 cubes; Pip scrambles up.
**Wacky test**: surprising, full layers stay; silly, the Big Cube "thunk"; funny failure, cubes bounce off like popcorn and the Miller laughs; big moment, the spyglass and fireworks.

---

### 06 Flower Bed

**Story card.** Pip's bouquet for the picnic: plant the flower picture. Two seeds are already planted and grow on their own. · **Pip: watcher** (waters each petal as it blooms).
**Stage**: clean, calm; a garden bed and a watering can. **Intro skit**: Pip looks at an empty vase, then at the bare bed, and draws a flower outline in the soil. **Payoff skit**: the flower blooms; Pip tries to pick it and the whole bed comes up as one giant bouquet.

```text
Recipe: BL01 (8×8, H8) · AR01 · CV01 · GO03 (50 cells) + FT02 trim + CL14 [M2 fill shape] · SP22 growing sprouts
One sentence: "Cover the flower outline."
```
**Encounters**: **Growing sprouts** (SP22): two sprout cubes start at (3,0,2) and (4,0,2); every 4 locks each grows one cube up, at most 1 (`grow_max` 1), filling a layer-1 target cell for free; a cube on top stops it. Pieces I, O, T, L, S, Tripod, Duo, Tri-Corner.

```text
layer 0 (38)   layer 1 (12)   side (z = 2)
.++..++.       ........        8 ================  danger line (trim)
++++++++       ..++++..        :
.++++++.       ..++++..        1 . . + + + + . .   raised centre (sprouts grow here)
++++++++       ..++++..        0 . + + + + + + .   petals on the grass
.++..++.       ........
...++...       ........
.++++...       ........
...++...       ........
```
**How it plays**: (1) outlines glow; the first piece blooms 4 petals. (2) Duo and Tri-Corner fit the petal tips. (3) The sprouts pop up into the raised centre; the player builds the rest of its base. (4) The last stem cell fills and the flower opens.
**Wacky test**: surprising, painting, not clearing; silly, petals sprout per cell; funny failure, trimmed petals float off and Pip chases them; big moment, the whole flower blooming.

---

### 07 Hide & Seek

**Story card.** Morning fog from the mill swallows the stack. Pip plays peek-a-boo with it; clears blow the fog away for a moment, and fog ghosts slip right through. · **Pip: watcher** (pops out of the fog on clears).
**Stage**: busy but hushed; fog banks, an owl half asleep. **Intro skit**: Pip sets the basket on the stack, turns, and the fog swallows it; Pip pats the air. **Payoff skit**: the last clear blows the fog away; the basket was on Pip's head all along.

```text
Recipe: BL05 (6×6, H10, 2 starter layers) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV02 Morning Fog · SP26 fog ghost
One sentence: "Your stack fades; remember it."
```
**Encounters**: Fog: visible 5 s, fade 1 s, alpha 0.1, reveal 0.6 s on each clear; starter blocks are visible through Intro and Countdown, then their timer starts at the first spawn. **Fog ghost** (SP26): 1 piece per bag passes through locked cubes until tapped solid; it locks where it is (nearest free cell up if blocked).

```text
layer 0     layer 1     side (z = 0)
##.###      ##.#..      10 ==============
######      .#####       :
#####.      ##.##.       1  # # . # . .   fades after 5 s
.#####      .###..       0  # # . # # #
######      ######
###.##      ##..##
```
**How it plays**: (1) Countdown: memorise the holes. (2) The fog rolls in; the landing ghost still shows where a piece lands. (3) The starter layers clear fast (about 15 cubes); a fog ghost slips down through the stack into a remembered hole. (4) The last two clears on memory.
**Wacky test**: surprising, the stack vanishes; silly, Pip's ears sticking out of the fog; funny failure, a piece lands "on nothing" that was something; big moment, the fog blown off in one puff.

---

### 08 Dewdrop

**Story card.** Sticky dew glues every piece the moment it touches, and Pip too. Hold on for 2:30 until the sun dries the grass. · **Pip: watcher** (stuck to a dewdrop, wriggling).
**Stage**: clean, tense; glittering grass, a low sun. **Intro skit**: Pip steps onto the grass and is glued in place; its feet stretch like taffy and snap back. **Payoff skit**: the dew evaporates in a sparkle and Pip pops free so hard it somersaults into the basket.

```text
Recipe: BL01 (5×5, H8) · AR01 · CV01 · GO04 (150 s, ramp_per_min 0.15) · FT01 (1) · CL01 + CO01 · PL01 Sticky Landing
One sentence: "Pieces stick the moment they land."
```
**Encounters**: Sticky Landing: lock on first touch, fall speed × 0.7 (effective 0.63 rising to about 0.9). Stars by layers cleared (Scoring F4): ★★ 1, ★★★ 2 with no warning.

```text
top-down 5×5   side (z = 2)
#####          11 . . S . .   spawn zone
#####           8 ===========  danger line (only 8 layers)
##S##           :
#####           0 . . . . .   dew on the grass
#####
```
**How it plays**: (1) the first piece sticks instantly with a splat; the landing ghost is the only aim tool. (2) Slower falls give aim time in the air. (3) Speed creeps up each minute; a clear buys room. (4) The sun dial fills; Pip pops free.
**Wacky test**: surprising, no sliding after landing; silly, dew splats; funny failure, a piece glued at a silly angle; big moment, the dew evaporating at 2:30.

---

### 09 Topsy-Turvy ★PROTO

**Story card.** The Miller flips the whole hill. Pip hangs from a tree that now grows downward, and the flip shook the eggs out of its nests. · **Pip: watcher** (dangles from a root).
**Stage**: busy; a tree with nests, the Miller at his lever. **Intro skit**: the Miller yanks a lever; the hill turns over and Pip is left hanging from a root. **Payoff skit**: the hill flips back; Pip drops onto the grass, the chicks drop onto Pip, and they sit in a dizzy pile.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV03 Topsy Tumble · SP21 hatching eggs
One sentence: "Down becomes up."
```
**Encounters**: Flip every 2 layers or 40 s, 2 s warning (arrows and a countdown ring), applied at the next Resolving; the stack turns over in place on the same island floor (twist-library rule 12), so buried holes come up to the top. **Hatching eggs** (SP21): two eggs start at (1,0,1) and (4,0,4); each hatches after 6 locks into a chick cube that hops to the lowest free neighbour cell; clearing an egg before it hatches gives a bonus.

```text
top-down 6×6   side (z = 2), before → after a flip (each column turns over in place)
######         13 . . S . . .     . . S . . .   spawn stays
######         10 ============    ============  danger line stays
##S###          :                 :
######          1 # . # # . #     # # . # # #   old floor is now the top
######          0 # # . # # #     # . # # . #   old top is now the bottom
######                                          island, floor and down axis stay
```
**How it plays**: (1) normal stacking; the Miller cranks his lever on the hill. (2) After 2 clears or 40 s, the warning, then the flip. (3) Keep the top flat, because a spiky top becomes a messy floor; chicks hop into gaps after a flip. (4) The 4th clear; the hill flips back.
**Wacky test**: surprising, gravity flips; silly, everything upside down; funny failure, the stack lands on its head with a "whump"; big moment, the stack tumbling to the new floor.

---

### 10 Meadow Mill (boss: the Miller) ★PROTO

**Story card.** The Miller wants a quiet mill and loud gusts. Phase 1: he cranks the belt and blows his sails. Phase 2: with two sails knocked off, he hauls the big lever and flips the hill. The last clear, on the upside-down hill, bonks him into a flour cloud. · **Boss**: the Miller; Pip cheers from the blanket (watcher).
**Stage**: busiest; the mill yard with sails, flour sacks, the belt and the Miller on the roof. **Intro skit**: Pip spreads the blanket; the Miller slams a shutter, cranks his sails and the belt rolls the blanket away. **Payoff skit**: the Miller sails off the roof into flour, climbs out white from ears to tail, shakes a fist and stomps off; the hill rights itself and the picnic starts. Keepsake: a tiny windmill.

```text
Recipe: BL01 (8 wide × 6 deep, H12) · AR01 · CV01 · GO01 (3 = 3 sails) · FT01 (1) · CL01 + CO01 · EV05 Mill Belt [mechanic] · EV01 Dandelion Gust · EV03 Topsy Tumble
One sentence: "The belt moves your stack; then the hill flips."
```
**Encounters**:
- **Mill Belt** (Conveyor): +x, every 2 locks, wrap on (the board is a rectangle because Conveyor forbids masks).
- **Gust**: +z (across the belt), every 8 s ± 2 s.
- **Phase switch (decision)**: the flip uses its own trigger, `flip_every_layers` 2 with `flip_every_ms` 180 000, so it fires once, right after the 2nd clear, and never again before the 3rd. Gusts keep blowing in phase 2. This needs no new atom; EV13 Halftime swap was considered and not used, because it adds a rule for one effect. Revisit if playtests find phase 2 too busy (then EV13 swaps the gust out).
- The Miller is the face of the rules: every event is his wind-up (belt lever, sail spin, giant lever). He cheers when you use a warning and sulks on each clear.

```text
top-down 8×6 (belt → along x, gust ↓ along +z)   side (z = 3)
→ → → → → → → →                                  15 . . . S S . . .   spawn zone
########                                         12 ================  danger line
########   ↓                                      :
###S####                                          1 # # . . # # . #
########                                          0 # # # . # # # #   → shift +x, wrap
########
########
phase 2: the stack turns over in place (as in 09); spawn, danger line and floor stay
```
**How it plays**: (1) after the 2nd lock the whole stack slides right and wraps. (2) The first gust blows across the belt. (3) Phase 1: drop where the gap *will be*; each clear knocks a sail off. (4) Phase 2: the giant lever, the flip, the belt keeps turning. (5) The third clear bonks the Miller off the roof.
**Wacky test**: surprising, the floor moves, then the hill turns over; silly, the Miller's wind-ups and giant lever; funny failure, he dances on the roof when you use a warning; big moment, the flip and the flour-cloud bonk.

---

### B Picnic Puzzle (bonus, tier 11, 20 meadow stars)

**Story card.** A line of ants is marching toward the picnic. Pack the basket before they arrive in 60 s. Six pieces, no spares. · **Pip: watcher** (dodges drops, shoos ants).
**Stage**: clean, hurried; a picnic cloth with an ant trail creeping toward it. **Intro skit**: an ant scout spots the food, whistles, and a long line of ants turns toward the cloth. **Payoff skit**: the lid snaps shut as the ants arrive; they bonk into the basket one after another while Pip sits on the lid, smug.

```text
Recipe: BL01 (4×4, H6) · AR09 fixed list [I, O, Big Cube, I, O, Big Cube] · CV01 · GO03 (32 cells: full 4×4 × 2 layers) + CL14 · FT07 out of pieces · time limit 60 s (extra fail)
One sentence: "Six pieces, 60 seconds: fill the basket."
```
**Encounters**: preview 3; the ant line on the cloth is the visible clock. Known solution: Big Cubes fill rows z 0–1; the I pieces lie along z 2 (one per layer); the O pieces stand upright in z 3; dealt in list order, every placement is supported. Stars: ★★ 45 s; ★★★ 30 s and no cube trimmed.

```text
targets (both layers)   side (z = 2)
++++                     9 . S S .   spawn zone
++++                     6 ========  danger line
++++                     :
++++                     1 + + + +   I on layer 1
                         0 + + + +   I on layer 0
```
**How it plays**: (1) read the preview (I, O, Big Cube) and plan. (2) Soft/hard drop to beat the clock. (3) The first Big Cube fills a corner block; the second I lies on the first. (4) The last Big Cube closes the lid; a misplaced piece or the clock means the ants carry the basket off; retry is instant.
**Wacky test**: surprising, every piece known but the clock ticks; silly, ants in a neat line with tiny forks; funny failure, the ants march off with the basket over their heads; big moment, the lid slamming in their faces.

---

## 7. Hard-track remixes (tiers 12–14; open after 10)

### H1 Seed Sprouts

**Story card.** Pip's sunflower went to seed; sprouts shoot up all over the plot. Cap them or clear them before they poke through the danger line. · **Pip: watcher** (tries to weed them, gets flicked).
**Stage**: busy, the 01 plot overgrown. **Intro skit**: the sunflower sneezes seeds and sprouts shoot up around Pip's feet. **Payoff skit**: Pip plants one seed in a pot and puts a lid on it.

```text
Recipe: BL05 (6×6, H10, 4 sprouts on the floor) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · SP22 (grow_locks 3, no grow_max) · EV01 gust callback (every 10 s)
```
```text
top-down (^ = sprout)   side (z = 1)
######                  10 ============
#^##^#                   3 . ^ . . ^ .   +1 cube every 3 locks
######                   :
######                   0 # ^ # # ^ #
#^##^#
######
```

### H2 Picnic Ants

**Story card.** The ants found the picnic stack. Each munches a cube every lock; a clear next to an ant sends it packing. · **Pip: watcher** (swats with a napkin, misses).
**Stage**: busy, a picnic cloth crawling with ants. **Intro skit**: an ant bites the bottom sandwich and the stack leans. **Payoff skit**: the colony marches off carrying one crumb; Pip waves the napkin.

```text
Recipe: BL05 (6×6, H10, 2 starter layers with 3 ants) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · SP31 ants · EV04 + SP19 mushroom callback (every 6 locks)
```
```text
layer 1 (a = ant)   side (z = 2)
######              10 ============
#a####               1 # # . # a #   ants leave holes as they eat
###.##               0 # # # # # #
####a#
#a####
######
```

### H3 Two Fields

**Story card.** Two vegetable patches, one block drizzle. Each piece goes to the patch you pick; clear 3 layers in each before either overflows. · **Pip: watcher** (runs between the patches with a watering can).
**Stage**: clean, tense; two small islands joined by a plank. **Intro skit**: Pip waters one patch while the drizzle starts on the other, and skids back and forth across the plank. **Payoff skit**: both patches grow a giant carrot; Pip pulls one, then the other, and is flattened by it.

```text
Recipe: BL07 (2 islands, 4×4 each, H8; tap a field to send the piece) · AR01 · CV01 · GO01 (3 per field) · FT01 (1, shared) · CL01 + CO01
```
```text
field A    field B      side
####       ####         8 =====      =====
####  ==   ####           :            :
####       ####         0 . . . .    . . . .
####       ####
```

---

## 8. Narrative beats

Wordless (biome-stories tone rules): intro and payoff skits per level, Pip's reactions, and the Miller in the backdrop from 03. Arc: Pip plants (01), beds the friends (02), fights the wind (03), the mushrooms (04), spots the Miller from the lookout (05, the reveal), makes the bouquet (06), loses the basket in the fog (07), gets stuck in the dew (08), is flipped by the Miller (09), and beats him at his mill (10). The bonus and remixes are after-party gags.

## 9. Music and audio cues

One meadow theme, layered: base (01–02) → + wind layer (03) → + plucks for mushrooms (04) → a light build layer for 05–06 (no danger music, since trim cannot lose) → a sparse, hushed mix for 07 → faster tempo for 08 → full mix for 09. Finale: the mill rhythm in phase 1, a key change and a drum hit on the flip, a short sting on each sail. The bonus has a ticking ant march. Danger stinger only where `topout_rule` is rescue. Skits use short stingers, never voices.

## 10. Open questions

- **Wobble, puff, sprout, ghost, eggs, ants, catch**: Candidate atoms (mechanics module); their full rules move into the owning GDDs before build. The values above are the Meadow's defaults.
- **Pocket check (02)**: the validator should confirm each pocket is exactly fillable by its named shape.
- **Fog ghost tap**: the tap gesture needs a place in Touch Controls.
- **Phase 2 busyness (10)**: if the flip plus gusts is too much, use EV13 to swap the gusts out.
- **Starting-contents format** (cell list vs. ASCII) is with the architecture lead.
- **Star times** are formula estimates; replace with playtest medians.
