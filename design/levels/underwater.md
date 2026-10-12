# Underwater Biome: Puff's Pearl (levels 01-10, bonus, hard track)

> **Status**: Draft v1 (level-designer, 2026-10-10), for user review. Biome 4 of 10 on the main chain.
> **Author**: level-designer
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Format copied from**: `design/levels/meadow.md` (section for section, level for level).
> **Sources**: `production/narrative/campaign-story/brief.md` (section 3.4, rules 1-12), `dialogue-campaign-skits.md` (section 4 and 0.6), `lore-world.md` (3.4), `visual-direction.md` (3.2 Underwater, 2.2), `design/gdd/mechanics-module.md` (atoms, F1 budget), `campaign-structure.md`, `level-data-definition.md`, `twist-library.md`, `level-specific-mechanics.md`, `level-goals-fail-states.md`, `scoring-stars.md`, `production/session-state/decisions.md`.
> **Field definitions**: `design/gdd/level-data-definition.md`; defaults from the owning GDDs.

**Every number, name and beat in this file is a tunable default**, a starting point for the prototype and playtests. The validator enforces only the safe ranges in the owning GDDs. Atom ids come from the mechanics-module library; an atom marked **(Pr)** is Proposed, **(C)** Candidate, **(D)** Designed. Ids marked with a dagger (rule ids such as `bounce_pad`†) are new rule-JSON ids this file proposes; ADR-0004 / ADR-0005 own the final names.

---

## 1. Level name and theme

**Puff's Pearl.** Puff the pufferfish found a giant glowing pearl and wants it back in its clam before sunset. Blocks fall as a slow **bubble drizzle** into a turquoise reef bowl. Admiral Crab, a hoarder in a tiny hat ("for the fleet"), has been given a bottle he thinks is a treasure map (it is a picture invitation; the violet flag is the tag on the bottle) and hoards every shiny thing to "find" it. He pranks the reef with currents, ink, a whirlpool and a stealing claw. In the finale the last clear topples his pile, pops the pearl into the clam and sends him off in a bubble. Keepsake: the pearl on the wizard's hat. Friend joined: none (Lana, from Ice, is the only friend unlocked here).

**Quirk: "Everything floats."** Pieces sink like slow bubbles, the water leans on them, and the stack is never quite where you left it. Each level has **one** disturbance (plus at most one special object), strangeness **zig-zags** (calm puzzle 06, short survive 08) rather than ramping, and plain layer clears are home base.

### Biome rules (decisions)

| Rule | Default |
|---|---|
| Islands | One reef shelf per level inside the bowl-island: sandy shallows (01), clam beds (02), current channel (03), jellyfish garden (04), coral tower (05), pearl-necklace flat (06), kelp forest (07), sunken toy ship (08), whirlpool shelf (09), Crab's treasure pile in front of the clam grotto (10) |
| Stage | Busy diorama or clean stage per level as the story needs; puzzle and survive levels clean, current / ink / boss levels busy. Caustics only on the island body and seabed, never on the grid |
| Intro skit | 3 s or less, wordless, played during the Countdown (no play time lost); ends on the hand-off (Puff looks up, wand glint, first piece) |
| Payoff skit | 5 s or less, tap to skip; the finale 6 s first play, last 2 beats on replays. One Mizzle clue at most per level (<= 1.5 s, at the rim or in the backdrop, never over the grid, never during a warning) |
| Mascot | **Puff** (Underwater only). Inflates at every surprise, deflates, bobs up and bumps the surface. Tiers 1-2: helper (points at a good cell + **Puff's bubble** catch, below). Tier 3 on: watcher (WO09, reactions only). Puff never pranks |
| Boss | **Admiral Crab**: his treasure pile is a backdrop landmark from 04, he holds the bottle from 05, boss in 10 (a wide low oval, two mismatched claws, a tiny admiral hat). Rivals, never cruel; he is bonked in a bubble |
| Physics | None. Buoyancy is a rule (bubbles, currents), not a simulation |
| Rubber duck | Hidden in an air bubble trapped under the shelf in 01 and 02 (SE05 angle gem, visible from one low snap angle; tap to collect; no stars attached) |
| Events as Underwater events | Wind (EV01) = **Tide Current**; Invisible Blocks (EV02) = **Ink Cloud**; Spawned Objects (EV04) = **Jelly Drift**; Conveyor (EV05) = **Undertow**; Rising Floor (EV07) = **Rising Silt**; Turntable (BL11) = **Whirlpool**; Biome event (EV16) = **Crab's Claw**; Sideways Gravity (AR02) = **School Swim** |
| Prototype priority | **04, 06, 09, 10** (PROTO: the four levels that carry a new atom no earlier biome proves) |
| Skills | Lana's **Stitch** (Ice) pins the stack; it vetoes the `stack` rules here (Undertow, Whirlpool, Crab's Claw, Rising Silt). That is its intended counter for a short window, not a bug. Skills that re-roll the queue (Glim, later) do nothing on kit-box and fixed-list levels (06, B). Not this file's call; flagged in section 10 |

**Puff's bubble (WO11, tiers 1-2).** Once per level (`mascot_catches` 1), when a piece locks so that it leaves at least one **new covered hole** (an empty active cell directly below one of its cubes) **and** clears nothing, the lock is undone before Resolving: Puff swallows the piece in a bubble (about 300 ms) and spits it out at the spawn position in its current orientation with the gravity clock reset. Not on a lock that meets the goal, not during a warning. Catches do not affect stars. Tier 3 on and the hard track: 0. Puff also **points** at a good cell (`mascot_hint`) in 01-02.

**Common defaults** (unless a level says otherwise): weighted bag, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, all rotation axes (CV01), `t_piece` 8 s. Speeds are hand-set within +/-0.05 of campaign F2, which for biome 4 is `0.78 + 0.045 x (tier - 1)` (0.78, 0.825, 0.87, 0.915, 0.96, 1.005, 1.05, 1.095, 1.14, 1.185); puzzle levels (06, B) and the hard track sit below F2 on purpose (hard through rules, not speed, as in the Meadow). "Standard" = the 8 Standard shapes (I O T L S Tripod Screw-L Screw-R).

**Budget (mechanics module F1).** At most 2 atoms new to the player and 4 non-default atoms per level; showpiece levels in tiers 7-10 may run 6 non-default. Bundles (M1 = GO02 + CL14 + FT02, M2 = GO03 + CL14) count 1; secrets (SE) count 0; slot defaults (BL01, AR01, CV01, CL01, CO01, GO01, FT01) count 0. **"New" is counted against the Meadow only**, because the Candy and Ice level files are written in parallel; if those biomes already teach an atom used here, the real count only drops. Atoms met in the Meadow: BL01, BL02, BL05, BL07, AR01, AR09, CV01, CV02, PL01, PL03, CL01, CL14, CO01, GO01-GO04, FT01, FT02, FT07, EV01-EV05, SP19, SP21, SP22, SP26, SP28, SP31, WO09, WO11, SE05.

**Grids**: one string per row, row 0 = `z = 0` (back), character 0 = `x = 0` (left). Mask `#` active, `.` off; starting layers `#` starter block, `m` biome object (jellyfish / pearl), `.` empty; targets `+` / `#` target cell. Side views are a slice at one `z` row seen from the front; `=====` is the danger line at `H_play`, `S` the spawn zone, `:` skips empty rows.

## 2. Estimated play time and summary

| # | id | Name | Story beat | New idea (atoms) | Puff | Stage | Goal | Board | Pieces | g0 | Top-out | Length | Stars (2 / 3) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | underwater_01 | Bubble Float | The pearl rides the bubbles | bubble wrap (look only), Puff's bubble (WO11) | helper | clean, calm | Clear 3 | 5x5, H9 | Standard; first 2 from {O, I} | 0.75 | rescue, 2 | ~3.3 min | 170 / 120 s |
| 02 | underwater_02 | Clam Pockets | Beds for three clams | pockets (BL05) | helper | clean, calm | Clear 3 | 6x6, H10 + 2 starter layers | Standard; first 3 a bag of {Tripod, Screw-L, Screw-R} | 0.8 | rescue, 1 | ~2.8 min | 150 / 105 s |
| 03 | underwater_03 | Current Lane | Shells on the stream | steady Tide Current (EV01) | watcher | busy | Clear 4 | 8x4 lane, H10 | Standard | 0.85 | rescue, 1 | ~5.7 min | 290 / 205 s |
| 04 | underwater_04 | Jellyfish Garden | Boing! | bounce pads (SP35, **new**), Jelly Drift (EV04) | watcher | busy | Clear 4 | 6x5, H10 | Standard | 0.9 | rescue, 1 | ~5.3 min | 270 / 190 s |
| 05 | underwater_05 | Coral Tower | Reach the sunlight | build race (M1) in a Tide (EV01) | watcher | clean, tense | Height 10 (cov. 0.6) | 5x5, H12 | Standard + Duo (w 0.5) | 0.95 | trim | ~5.2 min | 265 / 185* |
| 06 | underwater_06 | Pearl Necklace | Thread the pearls | kit box (AR13, **new Pr**), undo (FT12, **new Pr**), fill shape (M2) | watcher | clean, calm | Shape 36 | 6x6, H6 | kit: Tripod x4, S x4, O x1 | 0.6 | out of pieces | ~3 min | 210 / 135 s |
| 07 | underwater_07 | Ink Cloud | The shy octopus | Ink Cloud (EV02), kelp mask (BL02) | watcher | busy, hushed | Clear 3 | 7x7 mask (45), H10 | Standard | 1.0 | rescue, 1 | ~6 min | 305 / 215 s |
| 08 | underwater_08 | Sunken Ship | Silt creeps up | Rising Silt (EV07, **new**), Survive (GO04) | watcher | clean, tense | Survive 150 s | 5x5, H8 | Standard | 1.05 (ramp) | rescue, 1 | 2.5 min | 1 / 2 layers |
| 09 | underwater_09 | Whirlpool | The reef spins | Whirlpool (BL11, **new**) + Tide (EV01) | watcher | busy | Clear 3 | 6x6, H10 | Standard | 1.1 | rescue, 1 | ~4.8 min | 245 / 175 s |
| 10 | underwater_10 | Crab's Pile | Boss: Admiral Crab | Undertow (EV05), Tide (EV01), Crab's Claw (EV16, **new**) | boss | busiest | Clear 3 | 8x6, H12 | Standard + Duo (w 0.5) | 1.15 | rescue, 1 | ~6.4 min | 325 / 230 s |
| B | underwater_bonus | Treasure Chest | Pack the chest | fixed list (AR09), budget (FT07), shape (M2) | watcher | clean, hurried | Shape 36 | 4x4, H6 | fixed: BigCube x2, I x4, O | 0.5 | out of pieces | ~1.5 min | 75 / 50 s |
| H1 | underwater_h1 | School Swim | The reef sails sideways | Sideways Gravity (AR02) + Tide | watcher | busy | Clear 4 | 6x6 cross-section, 10 deep | Standard | 1.0 | rescue, 1 | ~6.4 min | 325 / 230 s |
| H2 | underwater_h2 | Pearl Dive | Pearls stuck up high | Treasure Down (GO08 + SP11, **new**) + Tide | watcher | busy | Pearls to the floor (3) | 6x6, H10 + 4 starter layers | Standard | 0.95 | rescue, 1 | ~5 min | 255 / 180 s |
| H3 | underwater_h3 | Crab's Rematch | He is back, with ink | Crab's Claw (EV16) + Ink Cloud (EV02) | watcher | busy | Clear 3 | 6x6, H10 | Standard | 1.0 | rescue, 1 | ~4.8 min | 245 / 175 s |

PROTO = 04, 06, 09, 10. \* = 3 stars also requires no cube trimmed (Scoring and Stars). Star times use Scoring and Stars F1 (`t2 = round5(0.85 x t_est)`, `t3 = round5(0.6 x t_est)`) with `t_est = N x t_beat` and `t_beat = 2.667 s x A` for 8 Standard shapes (c 4, eta 0.75, `t_piece` 8 s; the same constants the Meadow used), except 02 (starter layers; hand-set), 06 and B (puzzles; hand-set), 08 (Survive, F4), 05 (build race estimate, Level-Specific Mechanics F2) and H2 (starter layers; hand-set). Short on purpose, validator length warning expected: 01, 02, 06, 08, B.

**Hard track (decision, as in the Meadow).** `underwater_bonus` is tier 11 (unlocks at 20 underwater stars). The remixes are **tiers 12-14** (`underwater_h1`-`h3`); all three open when `underwater_10` is finished. Neither the bonus nor the remixes count toward the next biome's gate. Stars still pay points as usual.

**New atoms and who owns the full rules** (all values below are defaults until each lands in its owning GDD):

| Atom | Status | First used | Needs |
|---|---|---|---|
| SP35 Bounce pad (jellyfish) | C | 04 | Full rule in an obstacles / living-content GDD; this file fixes the reading (section 6, 04) |
| AR13 Kit box | Pr | 06 | Review to Candidate; validator replay of a `solution` |
| FT12 Undo and reset | Pr | 06 | Two ADR-0001 command kinds (`undo`, `reset`) |
| EV07 Rising Floor ("Rising Silt") | C | 08 | Gap-column guard (below) |
| BL11 Turntable ("Whirlpool") | D (MG12) | 09 | Square footprint, 90-degree-symmetric mask; first campaign use |
| EV16 Biome event ("Crab's Claw") | C | 10 | Its own rule JSON (section 6, 10); counter = Clear to cancel |
| AR02 Side then fall ("School Swim") | D | H1 | Board / Grid semantics of `down_axis` +x |
| GO08 Treasure down + SP11 Treasure | C | H2 | Pearls are excluded from layer clears |

## 3. Layout overview

```text
01 sandy shallows  02 clam beds     03 current lane  04 jelly garden  05 coral tower
#####              ######           ########         ######          #####
#####              ######           ########         ######          #####
#####              ######           ########         ######          #####
#####              ######           ########         ######          #####
#####              ######                            ######          #####
                   ######

06 pearl necklace  07 kelp forest   08 sunken ship   09 whirlpool     10 Crab's pile (undertow ->)
######             #######          #####            ######          ########
######             #.###.#          #####            ######          ########
######             #######          #####            ######          ########
######             #.###.#          #####            ######          ########
######             #######          #####            ######          ########
######             #######                           ######          ########
```

## 4. Critical path and optional paths

- **Critical path**: 01 -> 10 in order (linear inside a biome). Finishing 10 completes the Underwater; the next biome (Lava) opens with 15 of 30 stars.
- **Optional**: three-star times on every level; the rubber duck in 01-02; the bonus Treasure Chest (20 stars; earns Postcard 4 in the Scrapbook); hard-track remixes H1-H3 (after 10).
- **Puzzle levels**: 06 on the main path (retry is free, undo is free) and the bonus (1-2 per biome, campaign rule 15).

## 5. Pacing chart

```text
strangeness (how far from classic)
 high |                                    #       #
      |                    #        #     #   #   #
  mid |           #  #  #   #  #     #  #  #   #   #
      |        #  #  #  #   #  #  #  #  #  #   #   #
  low |  #  #  #  #  #  #   #  #  #  #  #  #   #   #
      +-01-02-03-04-05------06----07-08--09--10--B
        learn   twist   remix  calm puzzle  ink  silt whirl FINALE
```

Zig-zag, not a ramp: two teaching levels (01-02) -> a steady current (03) -> the first bounce (04, the PROTO that decides if the new atom reads) -> a no-clear break in the tide (05) -> the calm puzzle (06) -> ink and memory (07) -> a short survive (08) -> the whirlpool remix (09) -> the claw finale (10). Short and long alternate (campaign rule 12): 3.3, 2.8, **5.7**, 5.3, 5.2, 3, **6**, 2.5, 4.8, **6.4** minutes; no two long in a row before the finale. Danger music only where `topout_rule` is rescue (not 05, 06, B).

## 5b. Mizzle clue map (strength cap 2, one clue per level, slots 03-09)

| Slot | Beat (from the skits doc) | Placed in | Emote |
|---|---|---|---|
| 01, 02 | none | | |
| 03 | A parcel's violet ribbon drifts down through the water | payoff | none |
| 04 | **Star beat**: a spyglass lens glints from a distant cloud above the surface | payoff | none |
| 05 | Crab holds the picture invitation; one panel (a long table) is visible for a beat | payoff | none |
| 06 | **Star beat**: the necklace's glow sweep finds the far cloud; a droopy hat ducks | payoff | `sweat` |
| 07 | A small grey-violet cloud trails a violet cuff that waves, then stops halfway | payoff | `dots` |
| 08 | The far cloud edges a little closer, then backs off | payoff | `blush` |
| 09 | At the rim, a violet cuff points the spyglass at the bottle in Crab's pile; it lowers | payoff | `tear` |
| 10 | The finale's one clue: a violet cuff snatches the bottle from Puff; the cloud zips behind a bigger one | finale beat 5 [R] | Puff `question` |

All clues sit at the water-surface rim (top of the frame) or in the backdrop, are lit by a soft spotlight pool, and never run during a warning.

---

## 6. Level specs (encounter lists, sketches, beats)

### 01 Bubble Float

**Story card.** Puff found a giant glowing pearl and must carry it back to the clam before sunset. Every clear pops a bubble that lifts the pearl one shelf up. · **Puff: helper** (points at the emptiest cell; one bubble catch).
**Stage**: clean, calm; sandy shallows with shell pockets and swaying kelp at the rim. **Intro skit**: Puff pushes the pearl up a slope with its nose, slips, the pearl rolls back into a shell; Puff inflates (`exclaim`), deflates, looks up. **Payoff skit**: three bubbles lift the pearl shelf by shelf; Puff rides the last one, bumps the surface and floats back down, deflating (`heart`). **Clue**: none.

```text
Recipe: BL01 (5x5, H9) · AR01 · CV01 · CL01 + CO01 · GO01 (3) · FT01 (2 warnings) · SE05 duck · WO11 bubble catch (+ mascot_hint)
One sentence: "Fill a whole layer and it clears."
Atoms: all slot defaults; WO11 (known). nd 1, new 0.
```
**Encounters**: none (pure classic). Standard shapes, `opening_set` [O, I], count 2. `g0` 0.75, `T_level` 200.

```text
top-down 5x5       side (z = 2)
#####              10 . . S . .    spawn zone
##S##               9 =========    danger line
#####               :
#####               0 . . . . .    the sandy shallows
#####
```
**How it plays**: (1) an O sinks slowly inside a soft bubble; Puff points at a corner. (2) The first layer clears in about 6 pieces: bubbles burst, a leaf-less "plink", the pearl lifts a shelf. (3) T, L, S and then the 3D shapes arrive; all rotation axes are on. (4) The third clear lifts the pearl to the top shelf.
**Wacky test**: surprising, the pearl rides the clear; silly, bubble-wrapped pieces; funny failure, Puff goes full round and pale on a warning; big moment, Puff bumping the surface.
**Readability**: bubble skin is a thin translucent shell (outline stays visible, caustics never on the grid); the landing ghost uses the normal ghost style. **Lighting**: `env_underwater_light_noon_caustics`. **Music**: `underwater_01`.
**Teaches**: the biome look and the base loop with forgiving rules (2 warnings, slow sink, helper Puff).

```json
{ "schema": 1, "id": "underwater_01", "biome": "underwater", "tier": 1, "name": "level.underwater_01.name",
  "board": { "width": 5, "depth": 5, "h_play": 9 },
  "pieces": { "opening_set": ["O","I"], "opening_count": 2 },
  "knobs": { "fall.g0": 0.75, "goal.warnings_max": 2 },
  "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "mascot_hint" }, { "id": "mascot_catch", "params": { "mascot_catches": 1 } },
             { "id": "angle_gem", "params": { "cell": [2,-1,2], "view_snap": 150 } } ],
  "stars": { "t2": 170000, "t3": 120000 }, "music": "underwater_01",
  "story": { "mascot_role": "helper", "icon": "pearl" } }
```

---

### 02 Clam Pockets

**Story card.** Three clams lost their pearl beds; each bed is an oddly shaped hole. Fit the three funny pieces so every clam can close. A deliberate echo of the Meadow's burrow: it re-checks Flip and Roll before the biome asks for them. · **Puff: helper** (points at the pocket the current piece fits; one bubble catch).
**Stage**: clean, calm; the clam shelf in cut-away, three open clams as dressing. **Intro skit**: three clams yawn at three holes; a small fish swims into one and sticks out at both ends. **Payoff skit**: the clams snap shut one by one with a pearl glint each; the double clear lifts the shelf; Puff pops a bubble (`heart`). **Clue**: none.

```text
Recipe: BL05 (6x6, H10, 2 starter layers) · AR01 · CV01 (spin, tilt, roll) · CL01 + CO01 · GO01 (3) · FT01 (1) · SE05 duck · WO11 bubble catch
One sentence: "Turn the piece to fit its bed."
Atoms: BL05 + WO11 (both known). nd 2, new 0.
```
**Encounters**: three pockets, each exactly fillable by one 3D piece (Meadow convention: a cut of the named piece, three cells of an L in the top starter layer plus one stem cell below). A: **Tripod**, stem under the L's corner. B and C: the two **Screws**, stem under an end of the L; B and C are mirror images, so each screw fits only one bed. Flat pieces cannot fill a pocket exactly. Standard shapes; `opening_set` [Tripod, Screw-L, Screw-R], count 3 (a bag: each once, random order). Filling all three beds completes both starter layers (a double clear), then one free clear on the open board.

```text
layer 0         layer 1         side (z = 1)
######          ######          10 ==============
####.#  A       ###..#  A        :
######          ####.#           1 # # # . . #   bed A (x3-4, L of 3)
#.####  B       #..##.  B,C      0 # # # # . #   stem under A's corner (x4)
####.#  C       ##.#..
######          ######
```
Check: layer 0 holes (4,1) (1,3) (4,4); layer 1 holes A (3,1)(4,1)(4,2), B (1,3)(2,3)(2,4), C (5,3)(4,4)(5,4). 12 cubes fill 3 + 9 holes exactly, so both layers clear together.
**How it plays**: (1) a Tripod spawns; Puff points at bed A; tilt so the stem points down. (2) A screw fits only one of the two other beds; rolling it shows the mirror trick. (3) The third bed fills and both layers clear (a double). (4) One free clear. `T_level` 160.
**Wacky test**: surprising, the board starts half built; silly, clams with tiny eyelids and a snore; funny failure, a "nope" wobble from Puff; big moment, the double clear.
**Readability**: pocket holes are lit by a soft rim; the ghost shows the stem going in. The validator confirms each pocket is exactly fillable by its named shape. **Lighting**: `env_underwater_light_noon_caustics`. **Music**: `underwater_02`.
**Teaches**: all three rotation axes through pockets, and that the 3D pieces are the key to special holes.

```json
{ "schema": 1, "id": "underwater_02", "biome": "underwater", "tier": 2,
  "board": { "width": 6, "depth": 6, "h_play": 10,
    "starting_contents": { "layers": {
      "0": ["######","####.#","######","#.####","####.#","######"],
      "1": ["######","###..#","####.#","#..##.","##.#..","######"] } } },
  "pieces": { "opening_set": ["tripod","screw_l","screw_r"], "opening_count": 3 },
  "knobs": { "fall.g0": 0.8 }, "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "mascot_hint" }, { "id": "mascot_catch", "params": { "mascot_catches": 1 } },
             { "id": "angle_gem", "params": { "cell": [3,-1,3], "view_snap": 210 } } ],
  "stars": { "t2": 150000, "t3": 105000 }, "music": "underwater_02" }
```

---

### 03 Current Lane

**Story card.** A steady current runs through the reef and carries Puff's shell collection down the lane. Swim with it, not against it. · **Puff: watcher** (chases a shell, inflates when a piece is pushed the wrong way).
**Stage**: busy; a sandy channel, streaks of current in the backdrop, a school of fish passing. **Intro skit**: the current sweeps Puff's shells along the sand; Puff chases them, puffed up like a ball. **Payoff skit**: the current dies, the shells settle in neat rows; Puff sets the last one on top. **Clue (M)**: a violet-ribboned parcel drifts down through the water and snags on a kelp frond; Puff `question` (strength 1).

```text
Recipe: BL01 (8 wide x 4 deep, H10) · AR01 · CV01 · CL01 + CO01 · GO01 (4) · FT01 (1) · EV01 Tide Current (steady)
One sentence: "The water pushes your piece; build with it."
Atoms: EV01 (known). nd 1, new 0.
```
**Encounters**: **Tide Current** (EV01, rule `gust`): push toward +x, `wind_interval_ms` 3 000, `wind_jitter_ms` 500, `wind_strength` 1, `wind_warn_ms` 600. Unlike the Meadow's rare gust, this is a **steady drift**: a piece takes about 4 pushes on the way down (`g0` 0.85, ~12 cells in 14 s), enough to cross half the lane. The x = 7 wall is the brace. Hazard-orange arrow on the board edge, current streaks in the backdrop (world-anchored, so a camera rotate keeps them correct).

```text
top-down 8x4 (current ->)   side (z = 1)
########                    13 . . . S S . . .   spawn zone
###S####  -> -> ->          10 ================  danger line
########                     :
########                     0 . . . . . . . . |  wall at x = 7 = the brace
```
**How it plays**: (1) the first pieces fall calm in the shallows; the streaks start. (2) The first push moves a piece one cell right; the player learns to hold a piece back. (3) Building from the downstream wall lets the current finish placements for you ("Use it"). (4) Four clears; each pops a bubble row that drifts downstream. `T_level` 340.
**Wacky test**: surprising, your piece moves on its own; silly, shells tumbling past; funny failure, a gust slides a piece into a corner and Puff shrugs; big moment, a long current streaming bubbles down the lane.
**Readability**: the arrow brightens during the 600 ms warning and stays dim between; pieces keep their outlines under caustics. **Lighting**: `env_underwater_light_noon_caustics` (shafts brighter). **Music**: `underwater_03`.
**Teaches**: that a twist can be weather rather than an enemy; the Tide Current is the biome's recurring word.

```json
{ "schema": 1, "id": "underwater_03", "biome": "underwater", "tier": 3,
  "board": { "width": 8, "depth": 4, "h_play": 10 },
  "knobs": { "fall.g0": 0.85 }, "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "gust", "params": { "wind_mode": "fixed", "wind_dir": "+x", "wind_interval_ms": 3000,
             "wind_jitter_ms": 500, "wind_strength": 1, "wind_warn_ms": 600 } } ],
  "stars": { "t2": 290000, "t3": 205000 }, "music": "underwater_03",
  "story": { "mascot_role": "watcher" } }
```

---

### 04 Jellyfish Garden (PROTO)

**Story card.** The wizard grows a reef garden and the jellyfish keep drifting in. Landing on one makes a piece hop and drift a cell; use them as springy corners. · **Puff: watcher** (bounces from jelly to jelly in the backdrop).
**Stage**: busy; jelly bells in apricot and peach, a coral wall, Crab's treasure pile appears far back (landmark). **Intro skit**: Puff drifts over a jellyfish, boings to the surface and bumps it; the jelly squeaks. **Payoff skit**: the jellies line up and wobble in a row; Puff bounces down the line, `exclaim`. **Clue (M, star beat)**: a spyglass lens glints from a distant cloud above the surface (1.2 s, after Puff's last bounce; Puff does not notice).

```text
Recipe: BL01 (6x5, H10) · AR01 · CV01 · CL01 + CO01 · GO01 (4) · FT01 (1) · SP35 Bounce pad (3 jellies) · EV04 Jelly Drift
One sentence: "Jellyfish bounce your piece sideways."
Atoms: SP35 (new), EV04 (known). nd 2, new 1.
```
**Encounters**:
- **Bounce pad** (SP35, rule `bounce_pad`†, `bounce_h` 2): when a falling piece first touches a pad it hops up 2 cells, slides one cell onward in the direction of its last sideways move (no move = straight hop and settle), then falls again and locks normally. **Once per landing**; a pad hit after a bounce just supports the piece. The landing **ghost already shows the post-bounce cell**, so nothing is hidden. Pads are solid, count as filled cells, and clear with their layer.
- **Jelly Drift** (EV04, rule `mushroom_popup` with `object_id` "jelly"): every 8 locks one jelly drifts onto a free top-surface cell (marked by a sparkle one lock ahead), max 3 on the board.
- Starting jellies at (1,1), (4,1), (3,3) on layer 0.

```text
layer 0 start (m = jelly)   side (z = 1)
......                      13 . . S S . .    spawn zone
.m..m.                      10 ============   danger line
......                       :
...m..                       1 . . . . . .
......                       0 . m . . m .    pads on the sand
```
**How it plays**: (1) the first piece lands on a pad: hop, slide, settle (the ghost warned it). (2) The player starts aiming at a pad to nudge a piece into a gap one cell away. (3) A new jelly drifts in and covers a hole; the layer clears and takes the jelly with it. (4) Four clears. `T_level` 320.
**Wacky test**: surprising, the floor is bouncy; silly, squeaking jellies with faces; funny failure, a pad boings the piece into the exact wrong cell and the jelly giggles; big moment, a double bounce that finishes a layer.
**Readability**: pad = a bright apricot jelly bell (not cyan, not magenta) with a soft glow ring; the bounce arrow appears in the ghost only. **Lighting**: `env_underwater_light_noon_caustics`. **Music**: `underwater_04`.
**Teaches**: that the ghost is the truth; a content object can change a landing, not the rules.

```json
{ "schema": 1, "id": "underwater_04", "biome": "underwater", "tier": 4,
  "board": { "width": 6, "depth": 5, "h_play": 10,
    "starting_contents": { "layers": { "0": ["......",".m..m.","......","...m..","......"] } } },
  "knobs": { "fall.g0": 0.9 }, "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "bounce_pad", "params": { "bounce_h": 2, "dir_mode": "last_move" } },
             { "id": "mushroom_popup", "params": { "object_id": "jelly", "spawn_every_locks": 8, "objects_max": 3 } } ],
  "stars": { "t2": 270000, "t3": 190000 }, "music": "underwater_04" }
```

---

### 05 Coral Tower

**Story card.** Puff's seahorse friends want a lookout tower that reaches the sunlit surface. Stack to the coral sign; nothing clears, too high pops off, and the current leans on the tower. · **Puff: watcher** (rides a bubble up as the tower grows).
**Stage**: clean, tense; a bare coral base and a lot of blue water above, the surface glittering at the top. **Intro skit**: seahorse postmen strain upward, give up, and draw a tower in the sand. **Payoff skit**: Puff pops through the surface from the tower top; far back, Crab holds up the picture from his bottle, upside down. **Clue (M)**: one panel (a long table) is visible on Crab's picture for a beat (1.2 s); Crab squints, turns it around, shrugs.

```text
Recipe: BL01 (5x5, H12) · AR01 · CV01 · GO02 (H 10, coverage 0.6) + FT02 trim + CL14 [M1 build race] · EV01 Tide Current
One sentence: "Build up to the sign; nothing clears."
Atoms: M1 bundle (known) + EV01 (known). nd 2, new 0.
```
**Encounters**: **Tide Current** (EV01) at the Meadow's default pace (push toward -x, every 6 s +/- 2 s, 1 cell, 1 s warning); the tower leans toward the downstream side, so overhangs matter. No wobble (no physics in this biome). Trim: cubes at or above layer 12 pop off; the level never fails. Pieces Standard + **Duo** (w 0.5) to patch single gaps.

```text
top-down 5x5 (current <-)    side (z = 2)
#####                        15 . . S . .    spawn zone
#####                        12 ===========  danger line (trim)
##S##   <- <- <-              9 - - - - -    sign: layer 9 must be >= 60% full (15 of 25)
#####                         :
#####                         0 . . . . .
```
**How it plays**: (1) the floor fills; a full layer glows and stays. (2) The height meter and Puff's bubble climb. (3) A push shoves a piece onto an overhang; the tower creaks, nothing breaks. (4) Layer 9 reaches 15 cubes and the sign lights. `T_level` 310 (about 38 pieces).
**Wacky test**: surprising, full layers stay; silly, the seahorses salute each layer; funny failure, trimmed cubes float to the surface like corks; big moment, Puff breaking through the waterline.
**Readability**: the sign is a coral-pink ribbon, not danger red; the sky above the water line stays calm. **Lighting**: `env_underwater_light_noon_caustics` (surface glitter at the tower top). **Music**: `underwater_05`.
**Teaches**: a remix; the player already knows build races and Tide, the new thing is both at once.

```json
{ "schema": 1, "id": "underwater_05", "biome": "underwater", "tier": 5,
  "board": { "width": 5, "depth": 5, "h_play": 12 },
  "pieces": { "shapes": ["I","O","T","L","S","tripod","screw_l","screw_r","duo"], "weights": { "duo": 0.5 } },
  "knobs": { "fall.g0": 0.95, "goal.top_out": "trim" },
  "goal": { "type": "height", "H_target": 10, "height_coverage": 0.6 },
  "rules": [ { "id": "build_race" },
             { "id": "gust", "params": { "wind_dir": "-x", "wind_interval_ms": 6000, "wind_jitter_ms": 2000, "wind_warn_ms": 1000 } } ],
  "stars": { "t2": 265000, "t3": 185000 }, "music": "underwater_05" }
```

---

### 06 Pearl Necklace (PROTO, puzzle)

**Story card.** The pearl needs a string. Thread the necklace shape with the nine pieces in the kit: four Tripods put a pearl on each corner, the rest are the string. Undo and reset are free. · **Puff: watcher** (sits on the board edge and inflates a little more with each wrong try; no help).
**Stage**: clean, calm; a pale sand flat, a velvet cushion shape drawn in the sand. **Intro skit**: Puff holds up the pearl, then a necklace outline in the sand; the pearl does not fit. **Payoff skit**: the pearls light up one after another round the ring. **Clue (M, star beat)**: the glow sweeps up through the water and across the surface and finds the far grey-violet cloud; a droopy hat ducks (`sweat`), the glow carries on.

```text
Recipe: BL01 (6x6, H6) · AR13 kit box (9 pieces) · CV01 · GO03 (36 cells) + CL14 [M2 fill shape] · FT07 piece budget · FT12 undo and reset
One sentence: "Fit every piece into the necklace."
Atoms: AR13 (Pr, new), FT12 (Pr, new), M2 bundle, FT07 (known). nd 4, new 2.
```
**Encounters**: no twist. **Kit box**: all nine pieces are shown in a box and used once each in any order (`preview_count` = all). Fail: out of pieces with the shape unfilled (retry is free; undo and reset are free and unlimited). Stars never depend on undo; only time.

```text
target layer 0 (32)   target layer 1 (4)   side (z = 0)
++++++                +....+                H_play 6
++++++                ......                 :
++..++                ......                 1 + . . . . +    pearls on the corners
++..++                ......                 0 + + + + + +
++++++                ......
++++++                +....+
```
**Known solution** (pieces needed by the validator replay): Tripods (L of 3 flat + nub up) on the four corners: NW (0,0)(1,0)(0,1), NE (5,0)(4,0)(5,1), SW (0,5)(1,5)(0,4), SE (5,5)(4,5)(5,4), nubs on the corner cell. O at (0,2)(1,2)(0,3)(1,3). Four S pieces: (2,0)(3,0)(1,1)(2,1); (3,1)(4,1)(4,2)(5,2); (4,3)(5,3)(3,4)(4,4); (1,4)(2,4)(2,5)(3,5). That covers all 32 ring cells and the 4 pearls with no gap or overlap. Kit: Tripod x4, S x4, O x1.
**How it plays**: (1) read the box: four 3D pieces, four S, one O. (2) The Tripods obviously want the corners (pearls). (3) The S pieces must interlock around the O. (4) The last piece clicks and the pearls glow. `T_level` ~180, no clock pressure.
**Wacky test**: surprising, no clears at all; silly, the pearl blinks at each placement; funny failure, the kit runs dry and Puff swells and floats off the screen; big moment, the ring of pearls lighting in order.
**Readability**: targets are soft dotted outlines; filled cells pop with a "plink"; the kit box greys used pieces. Skills that re-roll the queue are off here. **Lighting**: `env_underwater_light_afternoon_goldgreen`. **Music**: `underwater_06`.
**Teaches**: planning, not reflexes; the biome's first puzzle, calm so it can follow the busy 05.

```json
{ "schema": 1, "id": "underwater_06", "biome": "underwater", "tier": 6,
  "board": { "width": 6, "depth": 6, "h_play": 6 },
  "pieces": { "kit": ["tripod","tripod","tripod","tripod","S","S","S","S","O"] },
  "knobs": { "fall.g0": 0.6, "spawn.arrival": "kit_box", "goal.top_out": "out_of_pieces" },
  "goal": { "type": "shape", "target_shape": { "layers": {
     "0": ["++++++","++++++","++..++","++..++","++++++","++++++"],
     "1": ["+....+","......","......","......","......","+....+"] } } },
  "rules": [ { "id": "fill_shape" }, { "id": "undo_reset" } ],
  "stars": { "t2": 210000, "t3": 135000 }, "music": "underwater_06",
  "story": { "mascot_role": "watcher" } }
```

---

### 07 Ink Cloud

**Story card.** A shy octopus lives in the kelp forest. Startled, she squirts ink, and the stack fades from view; every clear washes the ink away for a moment. · **Puff: watcher** (pops out of the ink on clears).
**Stage**: busy but hushed; tall waving kelp at the rim, an octopus peeking from a pot. **Intro skit**: the octopus peeks, Puff inflates in surprise, the octopus squirts ink and the kelp turns dark. **Payoff skit**: the last clear sends a clean current through the forest; the octopus waves four arms apologetically and hands Puff a bubble. **Clue (M)**: a small grey-violet cloud at the surface trails a violet cuff that waves, then stops halfway (`dots`).

```text
Recipe: BL02 (7x7, four kelp pillars off, A = 45, H10) · AR01 · CV01 · CL01 + CO01 · GO01 (3) · FT01 (1) · EV02 Ink Cloud
One sentence: "Your stack fades; remember it."
Atoms: BL02 (known), EV02 (known). nd 2, new 0.
```
**Encounters**: **Ink Cloud** (EV02, rule `fog`): visible 3.5 s after a lock, fade 1 s, alpha 0.1, reveal 0.7 s on each clear. The landing ghost, height line and falling piece never fade. Mask: four kelp pillars (off cells) at (1,2), (5,2), (1,4), (5,4); the centre (3,3) and the spawn row stay active so every shape spawns whole. Kelp is drawn as short matte sprouts at the pillars (at most 1 cube high), never tall enough to hide the grid.

```text
mask 7x7      side (z = 3, through the middle)
#######       13 . . . S . . .   spawn zone
#######       10 ==============
#.###.#        :
#######        1  # # # . # # #   fades after 3.5 s
#.###.#        0  # # # # # # #
#######
#######
```
**How it plays**: (1) the first layers fill in plain sight; the first lock fades. (2) The ink thickens; the landing ghost is the only aim tool. (3) A clear washes the ink for 0.7 s: study the stack. (4) Three clears. `T_level` 360.
**Wacky test**: surprising, the stack vanishes; silly, the octopus's embarrassed blush; funny failure, a piece lands "on nothing" that was something; big moment, the whole forest turning clear at the last clear.
**Readability**: ink is a deep indigo-grey wash on blocks only (never on ghost, line or piece); kelp stays off cyan and off magenta. **Lighting**: `env_underwater_light_kelp_shade`. **Music**: `underwater_07`.
**Teaches**: memory play with a net (the ghost never lies); a calm, shaped board lets the fade be the only strangeness.

```json
{ "schema": 1, "id": "underwater_07", "biome": "underwater", "tier": 7,
  "board": { "width": 7, "depth": 7, "h_play": 10,
    "mask": { "rows": ["#######","#######","#.###.#","#######","#.###.#","#######","#######"] } },
  "knobs": { "fall.g0": 1.0 }, "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "fog", "params": { "visible_ms": 3500, "fade_ms": 1000, "invisible_alpha": 0.1, "reveal_ms": 700 } } ],
  "stars": { "t2": 305000, "t3": 215000 }, "music": "underwater_07" }
```

---

### 08 Sunken Ship

**Story card.** Silt creeps up around the sunken toy ship. Keep clearing so the sand never covers the deck, and hold on for 2:30 until the tide turns. · **Puff: watcher** (props the ship's mast with its nose).
**Stage**: clean, tense; a toy ship half in the sand, dust drifting. **Intro skit**: the toy ship tilts as a mound of silt creeps up its side; Puff holds the mast. **Payoff skit**: the tide turns, the silt washes off, the ship bobs upright and floats up through the water with Puff on the bow. **Clue (M)**: the far cloud edges a little closer, then backs off (`blush`).

```text
Recipe: BL01 (5x5, H8) · AR01 · CV01 · CL01 + CO01 · GO04 (150 s, ramp_per_min 0.1) · FT01 (1) · EV07 Rising Silt
One sentence: "Sand rises from below; keep it cleared."
Atoms: GO04 (known), EV07 (new). nd 2, new 1.
```
**Encounters**: **Rising Silt** (EV07, rule `rising_silt`†): every 10 locks a sand row (1-3 gaps, here 3) pushes up from the floor and the stack shifts up one layer. The mound grows at the edge one lock ahead with a hazard-orange triangle (telegraph). **Guard against soft locks**: gap columns are chosen from columns whose previous layer-0 cell is empty and open to the sky (so the new gap is reachable); if there is none, the rise is skipped and replayed after the next clear. A silt row clears like any layer once its gaps are filled. Survive stars by layers cleared (Scoring and Stars F4): 150 s on 5x5, `t_beat` 66.7 s -> expected 2.25 -> **2 stars at 1 layer, 3 stars at 2 layers with no warning**.

```text
top-down 5x5         side (z = 2)
#####                11 . . S . .    spawn zone
##S##                 8 ===========  danger line (only 8 layers)
#####                 :
#####                 1 # # . # #   <- silt row with 3 gaps (every 10 locks)
#####                 0 # # # # #
```
**How it plays**: (1) normal play; the first silt mound shows after 9 locks. (2) The row rises, everything shifts up; the player fills the gaps to clear it. (3) Speed creeps up each minute; a clear buys headroom. (4) The tide dial fills at 2:30. `g0` 1.05, ramp 0.1 per minute.
**Wacky test**: surprising, the floor rises; silly, the ship's tiny flag leans; funny failure, silt lands under a tall stack and the ship wobbles; big moment, the ship bobbing up at 2:30.
**Readability**: silt is a pale sand tone with a clear row outline, not hazard orange (the orange triangle is the telegraph). Stitch (Lana) vetoes the rise for its window. **Lighting**: `env_underwater_light_afternoon_goldgreen`. **Music**: `underwater_08`.
**Teaches**: pressure from below; a short, sharp level between two longer ones.

```json
{ "schema": 1, "id": "underwater_08", "biome": "underwater", "tier": 8,
  "board": { "width": 5, "depth": 5, "h_play": 8 },
  "knobs": { "fall.g0": 1.05, "fall.ramp_per_min": 0.1 },
  "goal": { "type": "survive", "T": 150 },
  "rules": [ { "id": "rising_silt", "params": { "silt_every_locks": 10, "silt_gaps": 3, "silt_warn_locks": 1 } } ],
  "stars": { "s2": 1, "s3": 2 }, "music": "underwater_08" }
```

---

### 09 Whirlpool (PROTO)

**Story card.** A whirlpool spins the whole reef. Every few pieces the stack turns a quarter-turn, so your holes move; the current keeps pushing from the same side. · **Puff: watcher** (gets dizzy, spiral eyes).
**Stage**: busy; fish swirling in a ring, kelp leaning into the spin, a bubble spiral in the backdrop. **Intro skit**: a whirlpool opens in the sand; the fish form a ring; Puff spins and sees stars. **Payoff skit**: the spin slows, the fish do a conga line, Puff steadies itself on a rock. **Clue (M)**: at the rim a violet cuff points a spyglass at the bottle in Crab's pile; it lowers (`tear`).

```text
Recipe: BL01 (6x6, H10) · AR01 · CV01 · CL01 + CO01 · GO01 (3) · FT01 (1) · BL11 Whirlpool [mechanic] · EV01 Tide Current
One sentence: "The stack turns a quarter-turn now and then."
Atoms: BL11 (new), EV01 (known). nd 2, new 1.
```
**Encounters**:
- **Whirlpool** (BL11, rule `turntable`†, level mechanic): every 5 locks, at Resolving, the whole stack (not the camera, not the spawn zone) turns 90 degrees clockwise about the vertical centre axis (rigid, like the conveyor). A ring countdown fills the lock before. Footprint must be square and 90-degree-symmetric: the plain 6x6 is.
- **Tide Current** (EV01): the Meadow pace (toward +x, 8 s +/- 2 s, 1 cell, 1 s warning). The current is world-fixed, so after a turn it pushes a different side of the stack.
- Order in a Resolving: clears, then the turn (S4b), like the Conveyor.

```text
top-down 6x6 (turns clockwise every 5 locks)    side (z = 2), before -> after a turn
######                                          13 . . S . . .
######      ring countdown on the lock before   10 ============
##S###                                           :
######                                           1 # . # # . #   holes are in new columns
######                                           0 # # . # # #   after a quarter-turn
######
```
**How it plays**: (1) two quiet turns teach the ring countdown. (2) Keep the top flat; a spiky top turns into a spiky wall. (3) A tide push after a turn feels different: reread the lane. (4) The third clear stops the spin. `T_level` 290.
**Wacky test**: surprising, the stack turns; silly, spiral fish; funny failure, a turn drops a hole directly under the next piece; big moment, the first full turn with the bubble spiral.
**Readability**: the turn is announced by a ring on the island rim (not hazard orange; ring = timer); the camera never turns. Stitch vetoes a turn for its window. **Lighting**: `env_underwater_light_kelp_shade`. **Music**: `underwater_09`.
**Teaches**: remix: reread the stack after a change; the biome's one spatial surprise.

```json
{ "schema": 1, "id": "underwater_09", "biome": "underwater", "tier": 9,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 1.1 }, "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "turntable", "params": { "turn_every_locks": 5, "turn_dir": "cw", "turn_warn_locks": 1 } },
             { "id": "gust", "params": { "wind_dir": "+x", "wind_interval_ms": 8000, "wind_jitter_ms": 2000, "wind_warn_ms": 1000 } } ],
  "stars": { "t2": 245000, "t3": 175000 }, "music": "underwater_09" }
```

---

### 10 Crab's Pile (boss: Admiral Crab) (PROTO)

**Story card.** Admiral Crab hoards everything shiny "for the fleet", including Puff's pearl. Phase 1: he rolls the undertow and swirls the tide. Phase 2: after two clears he starts reaching down with his claw for your stack. The last clear topples his pile and pops the pearl into the clam. · **Boss**: Admiral Crab; Puff cheers from a rock (watcher).
**Stage**: busiest; Crab's treasure pile with a sunken rowboat, the giant clam glowing in the backdrop, bubble streams. **Intro skit (boss intro)**: Crab unrolls the picture from the bottle, holds it upside down, points at it (`exclaim`); he snaps up Puff's pearl and adds it to the pile (`smug`); Puff deflates, looks up. **Payoff skit (6 s)**: 1) last clear: the pile topples and the pearl pops into the clam (keepsake: the pearl); 2) a big bubble swallows Crab and shoots him off, tiny hat spinning (`dizzy`); 3) the bottle bobs up, Puff inflates and catches it in its spines; 4) [R] Puff floats to the surface and offers it to a small cloud; 5) [R] **clue**: a violet cuff snatches the bottle, the cloud zips behind a bigger one, Puff `question`. The flag (the tag on the bottle) is the finale's one thread item.

```text
Recipe: BL01 (8 wide x 6 deep, H12) · AR01 · CV01 · CL01 + CO01 · GO01 (3) · FT01 (1) · EV05 Undertow [mechanic] · EV01 Tide Current · EV16 Crab's Claw
One sentence: "The sea drags your stack; then the claw reaches in."
Atoms: EV05 + EV01 (known), EV16 (new). nd 3, new 1. A finale: 1 mechanic + 2 twists.
```
**Encounters**:
- **Undertow** (EV05, rule `conveyor`): toward +x, every 3 locks, wrap on (the board is a rectangle because the conveyor forbids masks). Crab's face of it: he leans on a giant seaweed rope.
- **Tide Current** (EV01): across the undertow (+z), 8 s +/- 2 s, 1 cell, 1 s warning. Runs in both phases.
- **Crab's Claw** (EV16, rule `crab_claw`†, counter **Clear to cancel**): starts after the 2nd clear (`claw_start_layers` 2, so it needs no new atom for the phase change; the Meadow trick). Every 20 s +/- 4 s, Crab's claw reaches down over a top-surface column: a hazard-orange triangle and diagonal stripes mark the **column** for 2 s (`claw_warn_ms`); the claw then takes the **highest cube in that column** (one cube, `claw_grab` 1) and drops it on his pile. If a clear happens during the warning, the claw pinches nothing and Crab shakes his claw (bonk). It never takes a cube from a stack of fewer than 2 layers and never targets a cell directly under a falling piece. It only removes top cubes, so nothing above is left unsupported.
- Crab is the face of the rules: every event is a wind-up (rope tug, claw rise, hat tip). He cheers when you use a warning and sulks on each clear.
- **Phase 2 busyness check**: if undertow + tide + claw is too much, swap the tide out with EV13 (Halftime swap), as the Meadow note allows.

```text
top-down 8x6 (undertow -> along x, tide v along +z)    side (z = 3)
-> -> -> -> -> -> -> ->                                15 . . . S S . . .   spawn zone
########                                               12 ================  danger line
########   v                                            :
###S####                                                1 # # . . # # . #
########                                                0 # # # . # # # #   -> shift +x, wrap
########
########
phase 2 (after the 2nd clear): claw marks one top column for 2 s, then lifts its top cube
```
**How it plays**: (1) after the 3rd lock the stack slides right and wraps. (2) The first tide push crosses the belt. (3) Phase 1: drop where the gap *will be*; each clear knocks a coin or crown off Crab's pile. (4) Phase 2: the claw hangs over a column: clear to shoo it, or build around it. (5) The third clear topples the pile. `T_level` 385.
**Wacky test**: surprising, the floor moves, then something steals your cube; silly, Crab's hat tips on each wind-up; funny failure, the claw lifts your best cube and Crab hugs it; big moment, the pile toppling and the pearl popping into the clam.
**Readability**: the claw's hazard marker is the only orange on screen during the wind-up; Crab (matte brick-red, not danger red) stays in the boss zone and never overlaps the grid. Stitch vetoes the shift, the claw and the turn for its window. **Lighting**: `env_underwater_light_amber_sunset` (the surface glows amber above). **Music**: `underwater_10`.
**Teaches**: the finale stacks what the player knows (belt, tide) with one new fightable event (the claw).

```json
{ "schema": 1, "id": "underwater_10", "biome": "underwater", "tier": 10,
  "board": { "width": 8, "depth": 6, "h_play": 12 },
  "pieces": { "shapes": ["I","O","T","L","S","tripod","screw_l","screw_r","duo"], "weights": { "duo": 0.5 } },
  "knobs": { "fall.g0": 1.15 }, "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "conveyor", "params": { "conveyor_every": 3, "conveyor_dir": "+x", "conveyor_wrap": true } },
             { "id": "gust", "params": { "wind_dir": "+z", "wind_interval_ms": 8000, "wind_jitter_ms": 2000, "wind_warn_ms": 1000 } },
             { "id": "crab_claw", "params": { "claw_start_layers": 2, "claw_every_ms": 20000, "claw_jitter_ms": 4000,
                                              "claw_warn_ms": 2000, "claw_grab": 1, "counter": "clear" } } ],
  "stars": { "t2": 325000, "t3": 230000 }, "music": "underwater_10",
  "story": { "mascot_role": "watcher", "boss": "admiral_crab" } }
```

---

### B Treasure Chest (bonus, tier 11, 20 underwater stars)

**Story card.** The reef treasure goes into one chest, and the pieces come in a set order. Pack it before the lid pops; Puff sits on top and inflates with every piece that does not fit. · **Puff: watcher** (on the lid).
**Stage**: clean, hurried; a sunken chest on the sand, coins in a shaft of light. **Intro skit**: a chest creaks open on the sand; Puff sits on the lid. **Payoff skit (5 s)**: the last coin fits; the chest creaks shut; Puff sits on the lid and inflates with pride, the lid pops open again; Puff deflates, the lid closes, Puff `note`. Earns **Postcard 4** (Scrapbook only). **Clue**: none.

```text
Recipe: BL01 (4x4, H6) · AR09 fixed list [BigCube, BigCube, I, I, I, I, O] · CV01 · GO03 (36 cells) + CL14 [M2] · FT07 out of pieces
One sentence: "Seven pieces in this order fill the chest."
Atoms: AR09, FT07, M2 bundle (all known from the Meadow bonus). nd 3, new 0.
```
**Encounters**: preview 3; Puff's inflation is a staging meter driven by "uncovered target cells under the lid" (no gameplay effect). Retry is instant. Skills that re-roll the queue are off. **Known solution**: the two Big Cubes fill the west half (x 0-1, both layers); the four I pieces lie along z, two on the floor (x 2 and x 3) and two on top; the O (dome, layer 2) rests on the middle (x 1-2, z 1-2) with all four supports filled. Dealt in list order every placement is supported.

```text
target layer 0 and 1 (32)   target layer 2 (4)    side (z = 1)
++++                        ....                  6 ========  danger line
++++                        .++.                  :
++++                        .++.                  2 . + + .    dome
++++                        ....                  1 + + + +
                                                  0 + + + +
```
**How it plays**: (1) read the preview (Big Cube, Big Cube, I). (2) Hard drop to make the 50 s star. (3) The first I lies on the floor beside the cubes; the second beside it. (4) The dome O closes the lid. Stars: 2 at 75 s, 3 at 50 s (hand-set).
**Wacky test**: surprising, every piece is known but the lid wobbles; silly, coins stuffed in every corner; funny failure, the lid pops and a coin shoots out; big moment, the lid clicking shut.
**Lighting**: `env_underwater_light_clam_grotto`. **Music**: `underwater_bonus`.

```json
{ "schema": 1, "id": "underwater_bonus", "biome": "underwater", "tier": 11,
  "board": { "width": 4, "depth": 4, "h_play": 6 },
  "pieces": { "fixed_list": ["big_cube","big_cube","I","I","I","I","O"] },
  "knobs": { "fall.g0": 0.5, "spawn.preview_count": 3, "goal.top_out": "out_of_pieces" },
  "goal": { "type": "shape", "target_shape": { "layers": {
     "0": ["++++","++++","++++","++++"], "1": ["++++","++++","++++","++++"],
     "2": ["....",".++.",".++.","...."] } } },
  "rules": [ { "id": "fill_shape" } ],
  "stars": { "t2": 75000, "t3": 50000 }, "music": "underwater_bonus" }
```

---

## 7. Hard-track remixes (tiers 12-14; open after 10)

All three recombine biome ideas harder through rules, not speed (`g0` about 1.0, below F2).

### H1 School Swim

**Story card.** A school of fish tows the whole reef sideways. Pieces swim in from the left wall and fall toward the right wall; the stack grows against it. The tide still pushes across. · **Puff: watcher** (dizzy again).
**Stage**: busy; fish streaming, kelp streaming. **Intro skit**: the fish line up and pull the reef like a toy train. **Payoff skit**: the fish let go; the reef swings back and Puff bumps the wall.

```text
Recipe: BL01 (6x6 cross-section, 10 slices along the travel axis) · AR02 School Swim (down axis +x) · CV01 · CL01 + CO01 · GO01 (4) · FT01 (1) · EV01 Tide (ground axis z)
Atoms: AR02 (new), EV01. nd 2, new 1. Floor-tagged atoms are out (AR02 conflicts).
```
```text
side view (travel ->)         danger line = the stack reaching 2 slices from the spawn wall
S . . . . . . . # #           spawn wall at x = 0; floor wall at x = 9
S . . . . . . # # #
```
Needs Board / Grid to settle `down_axis` +x semantics; flagged in section 10. The camera is limited to the snaps that read well (Mechanics Catalog A1).

### H2 Pearl Dive

**Story card.** Three pearls sit on top of a tower of shells. Clear the shells under them so they sink to the sand. · **Puff: watcher** (cheers each time a pearl steps down).
**Stage**: busy, a shell tower in a current. **Intro skit**: three pearls glint on a shell tower; Puff cannot reach. **Payoff skit**: the last pearl rolls onto the sand; Puff pockets all three.

```text
Recipe: BL05 (6x6, H10, 4 starter layers with 3 gaps each, 3 pearls on layer 4) · AR01 · CV01 · CL01 + CO01 · GO08 Treasure down + SP11 Pearl x3 · FT01 (1) · EV01 Tide
Atoms: BL05, EV01 (known), GO08 + SP11 (new). nd 4, new 2.
```
```text
side (z = 2)              pearls are not cleared by layer clears; they slide down with the shift
 4 . m . . m .   <- pearls (m) on top
 3 # # . # # #
 2 # . # # . #   starter layers, 3 gaps each
 1 # # # . # #
 0 . # # # # #
```
Win: all three pearls on layer 0. Hand-set star times (255 / 180 s) from about 4 starter layers x 4 pieces plus extra clears.

### H3 Crab's Rematch

**Story card.** Crab is back with a borrowed octopus and a longer claw. The ink hides your stack while the claw reaches in. · **Puff: watcher**.
**Stage**: busy; Crab's pile reassembled, the octopus on his shoulder. **Intro skit**: Crab waves the claw, the octopus squirts ink. **Payoff skit**: Crab's hat spins off; he bows to Puff and leaves.

```text
Recipe: BL01 (6x6, H10) · AR01 · CV01 · CL01 + CO01 · GO01 (3) · FT01 (1) · EV16 Crab's Claw (start after the 1st clear, every 25 s) · EV02 Ink Cloud (visible 4 s)
Atoms: EV16, EV02. nd 2, new 0 (both met in 07 and 10).
```
```text
claw marks one top column for 2 s; ink hides the stack; a clear washes the ink and cancels the claw
```

---

## 8. Narrative beats

Wordless (campaign rules 1-12): intro and payoff skits per level, Puff's reactions, Crab in the backdrop from 04. Arc: Puff lifts the pearl (01), beds the clams (02), fights the current (03), bounces off the jellies (04), spots Crab and his picture from the tower (05), threads the necklace and wakes the far cloud (06), meets the octopus (07), saves the toy ship (08), is spun by the whirlpool (09), and beats Crab at his pile (10). The Mizzle clue map (section 5b) is the biome's thread: ribbon, spyglass glint, the picture invitation, the light sweep, the cuff, the closing cloud, the spyglass pointing at the bottle, and the cuff taking the bottle. The bonus and the remixes are after-party gags. Failure is always a gag: Puff goes pale and round, the octopus apologises, nobody is hurt.

## 9. Music and audio cues

One track per level (user rule): ids `underwater_01` ... `underwater_10`, `underwater_bonus`, `underwater_h1`-`h3`, supplied by the user; an unknown id falls back to the biome's `default_music` (`underwater_theme`, "Carefree" stays a placeholder). No stems, so the level mix is whatever the track gives; dynamic feel comes from SFX and stingers only: soft bubble pops on each lock, a current whoosh on a Tide Current push (rate-limited), a boing on a jelly bounce, an ink splat on a lock under Ink, a swirl whoosh and ring tick on the Whirlpool, a rope creak on the Undertow, a claw clack and a cancel plink on Crab's Claw, a rising chime when silt is cleared. Skits use short stingers, never voices. Danger stinger only where `topout_rule` is rescue. Ambience (muffled bubbling, a friendly distant hum, clicking hermit crabs, the clam's slow creak) sits under the SFX slider.

## 10. Open questions

- **New atoms' full rules**: SP35 (bounce reading: "last sideways move" vs a fixed facing per pad), EV07 (gap-column guard above), EV16 (Crab's Claw params) and GO08 + SP11 (H2) move into their owning GDDs before build. FT12 needs the two ADR-0001 command kinds.
- **Proposed atoms used**: AR13 (06), FT12 (06). AR02 and BL11 are Designed but have never run in a campaign level (square footprint for the Whirlpool; `down_axis` +x for School Swim).
- **Lana's Stitch** vetoes the `stack` rules on 08-10 and H3 for its window. If a boss level should be Stitch-proof, mark it `skill_immune` in level data (game-designer call).
- **Meadow echo (02)**: it deliberately repeats the Meadow burrow's pocket idea with new pockets. If the user wants a new idea there, the lowest-risk swap is SP39 Bubble cube (Pr) with a canopy shelf (BL17, Pr).
- **Lighting vs the art file**: `visual-direction.md` puts kelp shade on 04-05 and amber sunset on 08-10; this file follows `lore-world.md` per-level settings (kelp forest 07, whirlpool 09, sunset only 10). Both are parameter-only presets; art-director to confirm.
- **Flag 4 panel**: the skits doc (a long table) and the lore (a dotted path to a lone rock) disagree; the clue in 05 uses the skits doc. Narrative-director to settle.
- **Phase 2 busyness (10)**: if undertow + tide + claw is too much, swap the tide out with EV13.
- **Star times** are formula estimates; replace with playtest medians.
- **Starting-contents format** (cell list vs. ASCII) is with the architecture lead.
