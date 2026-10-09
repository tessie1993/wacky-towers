# Meadow Layout Sketches: Pip's Picnic (levels 01–10 + bonus)

> **Status**: Draft v1 for user review (level-designer, 2026-10-10)
> **Sources**: `production/levels/campaign/biome-stories.md` (Meadow story, 10-beat arc), `production/levels/campaign/biome-bible.md` (quirk, owned atoms, 85% classic), `design/gdd/mechanics-module.md` (atoms, recipes, F1 budget), `docs/architecture/adr-0005-data-format-validator.md` (level JSON), `design/levels/meadow.md` (numbers; not edited here).
> **Every number, name and beat is a tunable default.** Numbers from `meadow.md` are unchanged. v2 (same day) adds skits, stage feel, and five **proposed** atom additions (03, 05, 06, 07, 09) that change those levels' rules; they go into `meadow.md` only if the user approves.

## How to read this

**Biome rules for the Meadow**
- **Quirk: "Gentle weather".** Blocks fall as a soft *block drizzle*. Each level adds **one** visible disturbance at most, and plain layer clears stay home base. Tiers 1–2 teach the drizzle and the 3D hand (one calm puzzle, no events); 03–09 each add one Miller-made disturbance; 10 stacks three of them under the boss.
- **Closest to classic.** 8 of 10 main levels are top-drop, whole-layer clears (about 85% classic play time). Only 05 (tower) and 06 (picture) switch clearing off, and both are no-fail breathers.
- **Pip** (harvest mouse) is the only mascot here (user decision): **small help on tiers 1–3** (WO06 helper: Pip points at a good cell and **catches one bad drop per level**: the first piece that would lock over a covered hole is caught mid-air and handed back at the spawn, telegraphed by Pip leaping), then **reactions only from tier 4 on** (WO09 watcher). Pip never pranks in the Meadow.
- **The Miller** is visible on the hill from 03 on, causing every disturbance (user decision).
- **One island per level, shaped by the story** (user decision): a seed plot, a burrow, a hillside lane, a pond ring, a hilltop, a garden bed, a foggy hollow, a dewy lawn, a tree island, the mill yard.
- **Hidden rubber duck** in the tutorials (01, 02): it peeks from the island's underside, visible from one low camera snap angle; tap it to collect (SE05 angle gem, dressed as the duck).
- **Prototype priority** (user pick): **02, 05, 09, 10** are marked ★PROTO.
- **The Miller** (flour-dusted badger) causes every disturbance from 03 on. He is seen at the mill on the hill in the backdrop, cranking things, long before the finale.

**Look and flow** (user answers, 2026-10-10)
- **Stage**: each level is either a **busy diorama** (props, critters, the Miller in view) or a **clean stage** (the board and Pip, little else), whichever the story needs. Calm puzzle levels are clean and quiet; chaos levels are busy.
- **Intro skit**: every level opens with a **3-second wordless mini-scene** in which Pip shows the problem. It plays during the Countdown, so it costs no play time.
- **Payoff skit**: every win ends with a short skit in which the tiny story resolves.
- **Drift from classic is a zig-zag, not a ramp.** Meadow levels go up and down in strangeness (01 pure classic, 05–06 no clears, 07 back to clears, 09–10 wild), with the biome still the most classic overall.
- **Physics silliness** is per level: in the Meadow only 05 Tall Tower wobbles (PL03), because a lookout should sway.

**Living blocks and special pieces in the Meadow** (proposed additions to `meadow.md`; each needs its Candidate rules defined before build)
| Atom | Meadow level | Story fit |
|---|---|---|
| SP28 Split piece ("dandelion puff") | 03 Breezy Hill | Puff pieces burst into two halves on landing, like a seed head |
| PL03 Wobble (physics) | 05 Tall Tower | The lookout sways; a big overhang makes the top piece slip |
| SP22 Growing sprout | 06 Flower Bed | Two planted seeds grow into the raised flower centre on their own |
| SP26 Ghost piece ("fog ghost") | 07 Hide & Seek | A see-through piece drifts through the fog until you tap it solid |
| SP21 Hatching egg | 09 Topsy-Turvy | The flip shook eggs out of the upside-down tree; chicks hop into gaps |
| SP20 Moody cube, SP27 Rainbow piece | Candy (not Meadow) | Both need colour rules, which are Candy's quirk |
| SP25 Jelly piece | Candy (jelly) | A squishy piece fits the sticky-sweet biome |
| SP23 Sleepy piece | Forest (Grandpa Oak's nap) or Celestial | Napping pieces suit the sleepy bosses there |

New research atoms considered and **not** used in the Meadow (to keep it closest to classic): CV14 Push cube, CV15 Gravity nudge, BL16 Seesaw, SP34 Crumble, SP35 Bounce pad (a good fit for a Mushroom Ring remix later), GO23 Bridge race and IN21 (versus only), GO24 Echo, EV17 Speed-up bump, SC09 Push your luck, WO10 Mascot pick (versus only).

**Recipe notes**
- Slot defaults (not counted as non-default): BL01 box, AR01 top drop, CV01 move + 3-axis rotate, CL01 layer, CO01 slice, GO01 clear N, FT01 warnings.
- **Budget (module F1)**: at most 2 atoms new to the player and 4 non-default per level. "New" counts only non-default atoms; the base slot defaults are taught by level 01 itself. A level mechanic that bundles atoms (M1 build race = GO02 + CL14 + FT02; M2 = GO03 + CL14) counts as one new idea, as the module counts GO06 + GO07.
- Events are presented as Meadow events: Wind = **Dandelion Gust**, Spawned Objects = **Mushroom Pop-up**, Invisible Blocks = **Morning Fog**, Gravity Flip = **Topsy Tumble**, Conveyor = **Mill Belt**.

**Sketch legend**
- Top-down: `#` active cell, `.` off (or empty), `+` target cell, `S` spawn anchor, `m` mushroom, arrows = event direction. Row 0 = `z = 0` (back), character 0 = `x = 0` (left).
- Side view: a slice at one `z` row, looking from the front. `y` counts up from the floor. `=====` is the danger line at `H_play` (cubes at or above it top out). `S` is the spawn zone. `#` starter block, `+` target cell, `m` mushroom. `:` skips identical empty rows.

## Summary

| # | Level | Story beat | New idea (atoms new to player) | Pip | Stage | Goal | Board | g0 | Non-default atoms |
|---|---|---|---|---|---|---|---|---|---|
| 01 | First Sprout | Plant Pip's seed | drizzle, spin (CV02) | helper | clean, calm | Clear 4 | 4×4, H8 | 0.6 | 1 |
| 02 | Tilt & Roll | Beds in the burrow | tilt/roll, pre-built pockets (BL05) | helper | clean, calm | Clear 3 | 6×6, H10 | 0.6 | 1 |
| 03 | Breezy Hill | Seeds on the wind | Dandelion Gust (EV01), puff pieces (SP28) | helper | busy | Clear 5 | 8×4 lane, H10 | 0.7 | 2 |
| 04 | Mushroom Ring | Pond party crashers | ring mask (BL02), Mushroom Pop-up (EV04 + SP19) | watcher | busy | Clear 3 | 7×7 ring, H10 | 0.75 | 2 |
| 05 | Tall Tower | Spy on the mill | build race (M1 bundle), wobble (PL03) | watcher | clean, tense | Height 10 | 5×5, H12 | 0.8 | 4 |
| 06 | Flower Bed | Picnic bouquet | fill a picture (GO03), growing sprouts (SP22) | watcher | clean, calm | Shape 50 | 8×8, H8 | 0.7 | 4 |
| 07 | Hide & Seek | Morning fog | Morning Fog (EV02), fog ghost (SP26) | watcher | busy (fog) | Clear 4 | 6×6, H10 | 0.85 | 3 |
| 08 | Dewdrop | Stuck in the dew | Survive (GO04), sticky (PL01) | watcher | clean, tense | Survive 2:30 | 5×5, H8 | 0.9 | 2 |
| 09 | Topsy-Turvy | The hill flips | Topsy Tumble (EV03), hatching eggs (SP21) | watcher | busy | Clear 4 | 6×6, H10 | 0.95 | 2 |
| 10 | Meadow Mill | Boss: the Miller (2 phases) | Mill Belt (EV05) + boss | boss | busiest | Clear 3 | 8×6, H12 | 1.0 | 3 |
| B | Picnic Puzzle | Pack the basket before the ants | fixed list (AR09), piece budget (FT07), 60 s clock | watcher | clean, hurried | Shape 32 | 4×4, H6 | 0.5 | 4 |
| H1 | Seed Sprouts | The sprout went to seed | sprouts everywhere (SP22) + gust callback | watcher | busy | Clear 5 | 6×6, H10 | 0.9 | 3 |
| H2 | Picnic Ants | Ants raid the stack | pests (SP31) + mushroom callback | watcher | busy | Clear 4 | 6×6, H10 | 0.9 | 3 |
| H3 | Two Fields | Two patches, one drizzle | islands (BL07) | watcher | clean, tense | Clear 3 per field | 2 × 4×4, H8 | 0.85 | 1 |

Rows 01 and 02 also carry SE05 (the rubber duck), which adds 1 to their non-default count (still within budget).

Pacing: short tutorial (01–02) → longer twist levels (03–04) → no-fail breathers (05–06) → short memory level (07) → short sprint (08) → long flip level (09) → finale (10). Short and long alternate (campaign rule 12).

---

## 01 First Sprout

**Story card.** Pip found a seed and needs a tidy plot to plant it. Every clear makes the sprout grow a leaf, and four leaves make a sprout. · **Pip: helper** (points at the emptiest cell after a lock and catches one bad drop).

**Stage**: clean stage, calm. A bare plot of soil and Pip.
**Intro skit (3 s)**: Pip digs a hole, drops in the seed, pats it, looks up at the drizzle and waits.
**Payoff skit**: the sprout shoots up into a sunflower taller than Pip; Pip hangs the picnic basket on it.

**Recipe**
```text
Name:          First Sprout
Context:       campaign
Story:         Pip needs a tidy plot for the seed · mascot: helper
Board:         BL01 (4×4, H_play 8)
Arrival:       AR01
Verb:          CV02 (spin only)
Goal:          GO01 (4 layers)
Fail:          FT01 (2 warnings)
Optional:      CL01 + CO01 · SE05 rubber duck (underside)
One sentence:  "Fill a whole layer and it clears."
```

**Defaults.** Pieces I, O, T, L, S; first 2 drawn from {O, I}. g0 0.6, `T_level` 180. ★★ 145 s, ★★★ 105 s.

**Wacky test.** Surprising rule: the first clear itself (the plot sinks and a leaf pops). Silly: the sprout grows a leaf per clear and a flower on the win. Funny failure: Pip covers its eyes on a warning, then peeks. Big moment: the 4th clear, when the sprout shoots up into a tall stalk.

**Sketch**
```text
top-down 4×4            side (slice z = 1)
####                    y
#S##                    11 . S S .   spawn zone
####                     8 ========  danger line
####                     7 . . . .
                         :
seed plot in the centre  0 . . . .   (empty plot; the seed sits under the tiles)
```

**How it plays**
1. 0–10 s: an O drifts down slowly. Pip points at a corner. The player moves, spins, drops.
2. 10–30 s: the second piece (O or I) completes half the layer; the next two finish it. The first clear: the plot sinks, a leaf pops, a big chime.
3. Middle: L, T and S arrive. Spin is the only rotation, so the player learns which way each flat shape fits.
4. End: the 4th clear grows the stalk and a flower opens. Pip hugs the stalk.

---

## 02 Tilt & Roll ★PROTO

**Story card.** Pip's stone burrow has three oddly shaped bedroom holes. Fit the three funny pieces so every friend gets a bed. · **Pip: helper** (points at the pocket the current piece fits and catches one bad drop).

**Stage**: clean stage, calm. The burrow seen in cut-away.
**Intro skit (3 s)**: three sleepy friends in nightcaps stare at the oddly shaped holes; one tries to lie in a hole and sticks out at both ends.
**Payoff skit**: each friend flops into a perfect bed and snores; Pip tiptoes out and blows out a candle.

**Recipe**
```text
Name:          Tilt Roll
Context:       campaign
Story:         Fit the beds into the burrow · mascot: helper
Board:         BL05 (6×6, H_play 10, 2 starter layers with 3 pockets)
Arrival:       AR01
Verb:          CV01 (spin, tilt, roll)
Goal:          GO01 (3 layers)
Fail:          FT01 (1 warning)
Optional:      CL01 + CO01 · SE05 rubber duck (underside)
One sentence:  "Turn the piece to fit its bed."
```

**Defaults.** 8 Standard; the first 3 are a bag of {Tripod, Screw-Left, Screw-Right}. g0 0.6. ★★ 130 s, ★★★ 90 s.

**Wacky test.** Surprising: the board starts half built with holes. Silly: each pocket has a sleepy friend's nightcap on its edge; a filled pocket snores. Funny failure: a wrong piece gets a "nope" wobble from Pip. Big moment: filling all three beds clears both layers at once (a double).

**Sketch**
```text
top-down, layer 0     layer 1          side (slice z = 1)
######                ######           y
#.###.                #..#..           10 ==============
######                #.##.#            :
######                ###.##            1  # . . # . .   pockets A (x1–2), B (x4–5)
####.#                ###..#            0  # . # # # .   pocket holes go 2 deep
######                ######
A = Tripod bed, B and C = the two screw beds (mirror images)
```

**How it plays**
1. 0–15 s: a Tripod spawns. Pip points at bed A. The player tilts it so three arms sit on top and one cube drops into the hole.
2. 15–40 s: a screw arrives. It only fits one of the two remaining beds; rolling it the other way shows the mirror trick.
3. Middle: the third bed fills, both starter layers clear together, and the friends pop out yawning.
4. End: one free clear on the open board with all 8 Standard shapes.

---

## 03 Breezy Hill

**Story card.** Dandelion gusts blow Pip's seeds along the hill. Build with the wind, not against it. · **Pip: helper** (catches one bad drop; otherwise gets seeds stuck on its face and sneezes).

**Stage**: busy diorama. A grassy slope, dandelions everywhere, the mill turning at the top.
**Intro skit (3 s)**: Pip holds out a handful of seeds; a gust from the mill blows them out of its paws and Pip tumbles after them.
**Payoff skit**: the wind dies down, the seeds land in neat rows down the lane, and Pip plants the last one with a flourish.

**Proposed addition: puff pieces (SP28).** One piece per bag carries a dandelion-puff tag. On landing it bursts into its two halves, which fall separately: a seed head scattering. It is a nudge toward the brace wall, not a punishment.

**Recipe**
```text
Name:          Breezy Hill
Context:       campaign
Story:         The Miller's sails send gusts down the hill · mascot: helper
Board:         BL01 (8 wide × 4 deep, H_play 10)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (5 layers)
Fail:          FT01 (1 warning)
Optional:      CL01 + CO01 · EV01 Dandelion Gust (+x, every 8 s ± 2 s, 1 cell) · SP28 puff (1 per bag)
One sentence:  "Gusts push your piece downhill."
```

**Defaults.** 8 Standard. g0 0.7. ★★ 365 s, ★★★ 255 s.

**Wacky test.** Surprising: your piece moves without you. Silly: Pip's seeds stick to its whiskers. Funny failure: a gust shoves a piece into the wrong spot, and Pip shrugs. Big moment: a long gust streams petals down the whole lane.

**Sketch**
```text
top-down 8×4 (gust →)       side (slice z = 1)
########                    y
###S####   → → → →          13 . . . S S . . .   spawn zone
########                    10 ================   danger line
########                     :
the downhill wall at x = 7   0 . . . . . . . . |  wall at x = 7 = the brace
                                 → Dandelion Gust pushes toward x = 7
```

**How it plays**
1. 0–20 s: the first pieces fall with no gust. The grass starts to bend to the right (the telegraph).
2. 20–30 s: the first gust shoves the piece one cell right. Pip sneezes out a seed.
3. Middle: the player learns to build from the downhill wall, so gusts push pieces home.
4. End: five clears, each blowing a puff of seeds off the hill toward the mill.

---

## 04 Mushroom Ring

**Story card.** Cheeky mushrooms keep popping up around the pond and bounce Pip like trampolines. They make free blocks, if you plan for them. · **Pip: watcher** (bounces on mushrooms in the backdrop, pulls faces at them).

**Stage**: busy diorama. The pond, lily pads, frogs watching from the edge.
**Intro skit (3 s)**: Pip lays out a picnic cloth by the pond; a mushroom pops up under it and launches the cloth into the water.
**Payoff skit**: the mushrooms line up in a ring and bow; Pip bounces across their heads to fetch the cloth from the pond.

**Recipe**
```text
Name:          Mushroom Ring
Context:       campaign
Story:         Mushrooms crash the pond party · mascot: watcher
Board:         BL02 (7×7 ring, centre 3×3 pond off, H_play 10, spawn anchor (3,5))
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (3 layers)
Fail:          FT01 (1 warning)
Optional:      CL01 + CO01 · EV04 Mushroom Pop-up with SP19 (every 5 locks, max 4)
One sentence:  "Mushrooms pop up and fill a cell for you."
```

**Defaults.** 8 Standard. g0 0.75. ★★ 270 s, ★★★ 190 s.

**Wacky test.** Surprising: things grow on your stack. Silly: mushrooms with faces squeak when cleared. Funny failure: a mushroom blocks the perfect gap and grins. Big moment: the pond sparkles and splashes on each clear.

**Sketch**
```text
top-down 7×7 ring          side (slice z = 3, through the pond)
#######                    y
#######                    13 . . . . . . .   (spawn is on the front band, z = 5)
##...##   . = pond         10 ==============
##...##                     :
##...##                     1 # m . . . # .   m = mushroom on the stack
###S###                     0 # # . . . # #   pond gap in the middle
#######
```

**How it plays**
1. 0–20 s: the first pieces go around the ring. The 2-wide band means flat pieces lie along it.
2. 20–30 s: after the 5th lock, a sparkle marks a cell (a lock ahead), then a mushroom pops up with a squeak.
3. Middle: the player learns to leave a 1-cell gap where the sparkle is, so the mushroom fills it.
4. End: the third ring closes; the mushrooms on it squeak away and the pond splashes.

---

## 05 Tall Tower ★PROTO

**Story card.** Pip wants a lookout to spy on the mill. Stack to the wooden sign. Nothing clears; too high just pops off. · **Pip: watcher** (climbs as the tower grows, waves from the top).

**Stage**: clean stage, tense. A bare hilltop, the mill far away, a lot of sky.
**Intro skit (3 s)**: Pip jumps to see over the tall grass toward the mill and can't; it draws a tower in the dirt with a stick.
**Payoff skit**: Pip climbs to the top, raises a spyglass and spots the Miller cranking a giant fan; Pip's ears go flat ("so that's who it is").

**Proposed addition: wobble (PL03), the Meadow's one physics level.** Overhangs add sway to the lookout; past the limit the top piece slips one cell (and may pop off at the danger line). It is light physics silliness that suits a wobbly lookout.

**Recipe**
```text
Name:          Tall Tower
Context:       campaign
Story:         Build Pip a lookout to spy on the mill · mascot: watcher
Board:         BL01 (5×5, H_play 12)
Arrival:       AR01
Verb:          CV01
Goal:          GO02 (height 10, coverage 0.6)       ┐ M1 No-Clear Build Race
Fail:          FT02 (trim)                          │ (one bundled idea)
Optional:      CL14 (clears off)                    ┘ · PL03 wobble
One sentence:  "Build up to the sign; nothing clears."
```

**Defaults.** 8 Standard + Big Cube (weight 0.5). g0 0.8. ★★ 240 s; ★★★ 170 s and no cube trimmed.

**Wacky test.** Surprising: full layers stay. Silly: Big Cube lands with a fat "thunk" and Pip bounces. Funny failure: trimmed cubes bounce off the island like popcorn, and the Miller (in the backdrop) laughs. Big moment: reaching the sign, Pip raises a spyglass and fireworks go off.

**Sketch**
```text
top-down 5×5             side (slice z = 2)
#####                    y
#####                    15 . . S . .   spawn zone
##S##                    12 ===========  danger line: cubes here pop off (trim)
#####                     9 - - - - -   sign ribbon: layer 9 must be ≥ 60% full (15 of 25)
#####                     :
                          0 . . . . .
```

**How it plays**
1. 0–20 s: the first pieces fill the floor. Nothing clears; a full layer just glows and stays.
2. 20–40 s: the height meter climbs. The sign at layer 9 sways in the wind.
3. Middle: a Big Cube arrives; two layers rise in one go. Overhangs are fine; only the top layer has to be 60% full.
4. End: the top layer under the sign reaches 15 cubes; Pip scrambles up and the spyglass glints at the mill. Any cube over layer 11 pops off with a bonk.

---

## 06 Flower Bed

**Story card.** Pip's bouquet for the picnic: plant the flower picture. Petals bloom as cells fill. · **Pip: watcher** (waters each petal as it blooms).

**Stage**: clean stage, calm. A flat garden bed with a watering can.
**Intro skit (3 s)**: Pip looks at an empty vase, then at the bare garden bed, and draws a flower outline in the soil.
**Payoff skit**: the flower blooms; Pip tries to pick it and the whole flower bed comes up as one giant bouquet, which Pip staggers off with.

**Proposed addition: growing sprouts (SP22).** Two sprout cubes start planted in the flower centre on layer 0. Every 4 locks each grows one cube up, to at most one cube (`grow_max` 1), filling a layer-1 target cell for free. A cube placed on top stops the growth.

**Recipe**
```text
Name:          Flower Bed
Context:       campaign
Story:         Plant the picnic bouquet · mascot: watcher
Board:         BL01 (8×8, H_play 8)
Arrival:       AR01
Verb:          CV01
Goal:          GO03 (50 target cells)               ┐ M2 Fill the Target Shape
Fail:          FT02 (trim)                          │
Optional:      CL14                                 ┘ · SP22 sprouts at (3,0,2), (4,0,2)
One sentence:  "Cover the flower outline."
```

**Defaults.** I, O, T, L, S, Tripod, Duo, Tri-Corner. g0 0.7. ★★ 155 s; ★★★ 110 s and no cube trimmed.

**Wacky test.** Surprising: you are painting, not clearing. Silly: each covered cell sprouts a petal. Funny failure: trimmed petals float away and Pip chases them. Big moment: the whole flower blooms on the last cell.

**Sketch**
```text
top-down, layer 0 targets   layer 1 targets   side (slice z = 2)
.++..++.                    ........          y
++++++++                    ..++++..           8 ================  danger line (trim)
.++++++.                    ..++++..           :
++++++++                    ..++++..           1 . . + + + + . .   raised flower centre
.++..++.                    ........           0 . + + + + + + .   petals on the grass
...++...                    ........
.++++...  (leaf)            ........
...++...  (stem)            ........
```

**How it plays**
1. 0–15 s: outlines glow on the grass. The first piece covers 4 petal cells and they bloom.
2. 15–40 s: the player finds that Duo and Tri-Corner pieces fit the petal tips neatly.
3. Middle: the raised centre (layer 1) needs a flat base first; cubes outside the outline are allowed, just wasted.
4. End: the last stem cell fills and the flower opens. Pip tucks it into the basket.

---

## 07 Hide & Seek

**Story card.** Morning fog rolls in and swallows the stack. Pip plays peek-a-boo with it; clears blow the fog away for a moment. · **Pip: watcher** (hides in the fog and pops out on clears).

**Stage**: busy diorama, but hushed: fog banks, dew, an owl half asleep.
**Intro skit (3 s)**: Pip sets the basket on the stack, turns around, and the fog swallows the basket; Pip pats the air looking for it.
**Payoff skit**: the last clear blows the fog away; the basket is sitting on Pip's head the whole time.

**Proposed addition: fog ghost (SP26).** One piece per bag is a see-through fog ghost. It passes through locked cubes until you tap to make it solid, and it locks where it is (or the nearest free cell up). In the fog, it lets you slip a piece into a hole you remember.

**Recipe**
```text
Name:          Hide Seek
Context:       campaign
Story:         The Miller's mill puffs fog over the meadow · mascot: watcher
Board:         BL05 (6×6, H_play 10, 2 starter layers)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (4 layers)
Fail:          FT01 (1 warning)
Optional:      CL01 + CO01 · EV02 Morning Fog (visible 5 s, fade 1 s, alpha 0.1, reveal 0.6 s) · SP26 fog ghost (1 per bag)
One sentence:  "Your stack fades; remember it."
```

**Defaults.** 8 Standard. g0 0.85. ★★ 195 s, ★★★ 140 s.

**Wacky test.** Surprising: the stack vanishes. Silly: Pip's ears stick out of the fog. Funny failure: a piece lands "on nothing", and it was something. Big moment: every clear blows the fog off in one puff.

**Sketch**
```text
top-down, layer 0   layer 1          side (slice z = 0)
##.###              ##.#..           y
######              .#####           10 ==============
#####.              ##.##.            :
.#####              .###..            1  # # . # . .   faded after 5 s
######              ######            0  # # . # # #   faded after 5 s
###.##              ##..##
starter layers are visible through Intro and Countdown, then fade
```

**How it plays**
1. Countdown: the starter layers are fully visible; this is the moment to memorise the holes.
2. 0–30 s: the fog rolls in. The ghost still lands correctly, so the player uses it to "feel" the stack.
3. Middle: the first clears come fast (the starter layers need about 15 cubes), and each one blows the fog away for 0.6 s.
4. End: the last two clears are on memory alone. Pip pops out of the fog on the win.

---

## 08 Dewdrop

**Story card.** Sticky dew glues every piece the moment it touches, and Pip too. Hold the line for 2:30 until the sun dries the grass. · **Pip: watcher** (stuck to a dewdrop, wriggling).

**Stage**: clean stage, tense. Glittering wet grass, a low sun on the horizon.
**Intro skit (3 s)**: Pip steps onto the grass and is glued in place by a dewdrop; it pulls, its feet stretch like taffy, and it snaps back.
**Payoff skit**: the sun rises, the dew evaporates in a sparkle and Pip pops free so hard it somersaults into the basket.

**Recipe**
```text
Name:          Dewdrop
Context:       campaign
Story:         Pip is stuck in dew; hang on till it dries · mascot: watcher
Board:         BL01 (5×5, H_play 8)
Arrival:       AR01
Verb:          CV01
Goal:          GO04 (survive 150 s, ramp 0.15 cells/s per min)
Fail:          FT01 (1 warning)
Optional:      CL01 + CO01 · PL01 Sticky Landing (× 0.7 fall speed)
One sentence:  "Pieces stick the moment they land."
```

**Defaults.** 8 Standard. g0 0.9. Stars by layers cleared: ★★ 1, ★★★ 2 with no warning.

**Wacky test.** Surprising: no sliding after landing. Silly: dewdrops splat on every lock. Funny failure: a piece sticks at a silly angle on a ledge, and Pip groans. Big moment: at 2:30 the sun pops out and the dew evaporates in a burst of sparkles.

**Sketch**
```text
top-down 5×5           side (slice z = 2)
#####                  y
#####                  11 . . S . .   spawn zone
##S##                   8 ===========  danger line (only 8 layers: tense)
#####                   :
#####                   0 . . . . .   dew on the grass
a sun dial on the HUD fills over 2:30
```

**How it plays**
1. 0–15 s: the first piece touches down and sticks instantly with a splat. The player sees that the landing ghost is the only aim tool.
2. 15–30 s: pieces fall slower (× 0.7) to give aim time; the player aims in the air.
3. Middle: the speed creeps up each minute; a clear gives breathing room.
4. End: the sun dial fills and the dew dries; Pip pops free.

---

## 09 Topsy-Turvy ★PROTO

**Story card.** The Miller flips the whole hill. Pip hangs upside down from a tree that now grows downward. · **Pip: watcher** (dangles from a root and swings into view as the flip is due).

**Stage**: busy diorama. A tree with nests, roots in the air after a flip, the Miller at his lever.
**Intro skit (3 s)**: the Miller yanks a lever; the hill turns over and Pip is left hanging from a root, basket dangling.
**Payoff skit**: the hill flips back; Pip drops onto the grass, the chicks drop onto Pip, and they all sit in a pile, dizzy.

**Proposed addition: hatching eggs (SP21).** Two eggs start on the floor (the flip shook them out of the tree). Each hatches after 6 locks into a chick cube that hops to the lowest free neighbour cell, filling a gap. Clearing an egg before it hatches gives a bonus.

**Recipe**
```text
Name:          Topsy Turvy
Context:       campaign
Story:         The Miller flips the hill · mascot: watcher
Board:         BL01 (6×6, H_play 10)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (4 layers)
Fail:          FT01 (1 warning)
Optional:      CL01 + CO01 · EV03 Topsy Tumble (every 2 layers or 40 s, 2 s warning) · SP21 eggs at (1,0,1), (4,0,4)
One sentence:  "Down becomes up."
```

**Defaults.** 8 Standard. g0 0.95. ★★ 325 s, ★★★ 230 s.

**Wacky test.** Surprising: gravity flips. Silly: the tree, the sign and Pip all hang upside down. Funny failure: the stack lands on its head with a "whump" and Pip's hat falls off. Big moment: the whole stack tumbling to the new floor.

**Sketch**
```text
top-down 6×6       side (slice z = 2), before → after a flip
######             y   before            after
######             13  . . S . . .       # # . # # #   (old floor, now the top)
##S###             10  ============      :
######              :                    ============
######              1  # . # # . #        . . S . . .  (new spawn at the old floor)
######              0  # # . # # #
countdown ring on the island sides fills 2 s before the flip
```

**How it plays**
1. 0–30 s: normal stacking. The Miller is seen cranking a lever on the hill.
2. After 2 clears (or 40 s): arrows and a countdown ring warn; the next lock flips the hill and the stack slides to the new floor.
3. Middle: the player learns to keep the top flat, because a spiky top becomes a messy floor after the flip.
4. End: the 4th clear; the hill flips back right side up, and Pip lands on its bottom.

---

## 10 Meadow Mill (boss: the Miller) ★PROTO

**Story card.** The Miller wants a quiet mill and loud gusts. **Phase 1**: he cranks the belt and blows his sails. **Phase 2**: after two sails are knocked off, he pulls the big lever and flips the whole hill. The last clear, on the upside-down hill, bonks him off the roof into a flour cloud. · **Mascot: boss** (the Miller); Pip cheers from the picnic blanket.

**Stage**: busiest diorama. The mill yard island: the mill, its sails, flour sacks, the belt, the Miller on the roof.
**Intro skit (3 s)**: Pip spreads the picnic blanket; the Miller slams a shutter, cranks his sails and the belt starts rolling the blanket away.
**Payoff skit**: the Miller sails off the roof into a flour cloud, climbs out white from ears to tail, shakes a fist and stomps off vowing a rematch; the hill rights itself and the picnic finally starts. Keepsake: a tiny windmill.

**Recipe**
```text
Name:          Meadow Mill
Context:       campaign
Story:         Beat the Miller at his own mill · mascot: watcher (Pip) + boss (Miller)
Board:         BL01 (8 wide × 6 deep, H_play 12)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (3 layers = 3 sails)
Fail:          FT01 (1 warning)
Optional:      CL01 + CO01 · EV05 Mill Belt (+x, every 2 locks, wrap) [mechanic]
               · EV01 Dandelion Gust (+z, every 8 s)
               · EV03 Topsy Tumble (flip_every_layers 2, flip_every_ms 180 000: flips only after the 2nd clear)
One sentence:  "The belt moves your stack; then the hill flips."
```

**Defaults.** I, O, T, L, Tripod, Screw-Left, Screw-Right, Chair. g0 1.0. ★★ 315 s, ★★★ 225 s.

**Boss duel play (two phases).** **3 sails = 3 clears.**
- **Phase 1 (sails 1–2)**: belt and gusts. Each event is the Miller's wind-up: he pulls the belt lever (shift) or spins the sails (gust).
- **Phase 2 (sail 3)**: the 2nd clear makes the flip due; the Miller hauls a giant lever (2 s warning), the hill flips, the stack settles against the new floor, and the belt keeps running upside down. One clear to win.
- He cheers when you use a warning and sulks on each clear. The rules are only the declared rules (the phase change is the flip's own 2-clear trigger); the Miller is their face. The gusts keep blowing in phase 2; stopping them would need EV13 Halftime swap.
- Mushrooms (in the earlier draft) are dropped so the finale stays at 2 twists + 1 mechanic.

**Wacky test.** Surprising: the floor moves, then the whole hill turns over. Silly: the Miller's dramatic wind-ups and his giant lever. Funny failure: the Miller dances on the mill roof when you use a warning. Big moment: the flip, then the final clear launching him into a flour cloud.

**Sketch**
```text
top-down 8×6 (belt → along x, gust ↓ along +z)     side (slice z = 3)
→ → → → → → → →                                    y
########                                           15 . . . S S . . .   spawn zone
########     ↓ gust                                12 ================  danger line
###S####                                            :
########                                            1 # # . . # # . #
########                                            0 # # # . # # # #   → the whole stack shifts +x
########                                               wrap: cubes leaving x = 7 come back at x = 0
mill on the +x edge; the Miller on its roof
phase 2: the danger line and spawn move to the old floor (as in 09)
```

**How it plays**
1. 0–20 s: the Miller turns his lever; after the 2nd lock the whole stack slides one cell right and wraps around. The player sees it before planning around it.
2. 20–40 s: the first gust blows across the belt. Two motions, each with its own wind-up.
3. Phase 1: the player learns to drop where the gap *will be* after the next shift. Each clear knocks a sail off.
4. Phase 2: after the 2nd sail falls, the Miller hauls the giant lever, the hill flips and the stack settles upside down. The belt keeps turning.
5. End: the third clear on the flipped hill bonks the Miller off the roof into flour.

---

## B Picnic Puzzle (bonus, unlocks at 20 meadow stars)

**Story card.** A line of ants is marching toward the picnic. Pack the basket before they arrive in 60 s. Six pieces, no spares: one wrong drop and the picnic spills. · **Pip: watcher** (dodges each drop and shoos at the ants).

**Stage**: clean stage, hurried. A picnic cloth on a tiny island; an ant trail creeps across the grass toward it.
**Intro skit (3 s)**: Pip lays out the food; an ant scout spots it, whistles, and a long line of ants turns toward the cloth.
**Payoff skit**: the lid snaps shut just as the ants arrive; they bonk into the basket one after another, and Pip sits on the lid looking smug.

**Recipe**
```text
Name:          Picnic Puzzle
Context:       campaign (hard track)
Story:         Pack the basket before the ants arrive · mascot: watcher
Board:         BL01 (4×4, H_play 6)
Arrival:       AR09 (fixed list: I, O, Big Cube, I, O, Big Cube)
Verb:          CV01
Goal:          GO03 (32 target cells: the full 4×4 × 2 layers)
Fail:          FT07 (out of pieces = lost) + time limit 60 s (extra fail, Level Goals rule 11)
Optional:      CL14
One sentence:  "Six pieces, 60 seconds: fill the basket."
```

**Defaults.** Preview 3. g0 0.5 (soft drop and hard drop are the way to beat the clock). ★★ 45 s; ★★★ 30 s and no cube trimmed.

**Wacky test.** Surprising: you know every piece, but the clock is ticking. Silly: the ants march in a neat line with tiny forks. Funny failure: the ants arrive and carry the whole basket away over their heads. Big moment: the lid slamming shut in the ants' faces.

**Sketch**
```text
top-down (both layers)   side (slice z = 2)
++++                     y
++++                      9 . S S . .   spawn zone
++++                      6 =========  danger line
++++                      :
                          1 + + + +     I goes along this row on layer 1
                          0 + + + +     I goes along this row on layer 0
solution: Big Cubes fill rows z 0–1; I pieces lie along z 2 (one per layer); O pieces stand upright in z 3
```

**How it plays**
1. 0–10 s: the preview shows the next three pieces (I, O, Big Cube). The player plans where each goes.
2. 10–30 s: the first I lies along a row on the floor; the O stands upright in the back row.
3. Middle: the first Big Cube fills a corner block of four columns; the second I lies on top of the first.
4. End: the last Big Cube closes the basket before the ant line reaches it. A misplaced piece (or the 60 s running out) means the ants carry the basket off; retry is instant and free.

---

## Hard-track remixes (optional, unlocked by finishing 10)

Off the main path, harder and retry-friendly. Each remixes a Meadow idea with one living block. Ids `meadow_h1`–`h3`; how the schema marks hard-track levels (tier 12+?) is open.

### H1 Seed Sprouts

**Story card.** Pip's sunflower from level 01 went to seed, and now sprouts pop up all over the plot, growing toward the sky. Cap them and clear them before they poke through the danger line. · **Pip: watcher** (tries to weed them and gets flicked).
**Stage**: busy diorama, the seed plot from 01, now overgrown. **Intro skit (3 s)**: Pip admires the sunflower; it sneezes seeds everywhere and sprouts shoot up around Pip's feet. **Payoff skit**: the last sprout is cleared; Pip plants one single seed in a pot and puts a lid on it.

```text
Name:          Seed Sprouts
Context:       campaign (hard track)
Story:         The sprout went to seed · mascot: watcher
Board:         BL05 (6×6, H_play 10, 4 sprout cubes on the floor)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (5 layers)
Fail:          FT01 (1 warning)
Optional:      CL01 + CO01 · SP22 sprouts (grow_locks 3, no cap but a cube above) · EV01 gust callback (every 10 s)
One sentence:  "Sprouts grow every few pieces: cap them or clear them."
```
Defaults: 8 Standard, g0 0.9.
```text
top-down 6×6, sprouts ^      side (slice z = 1)
######                       10 ============   danger line
#^##^#                        3 . ^ . . ^ .    sprouts grow 1 cube every 3 locks
######                        :
######                        0 # ^ # # ^ #
#^##^#
######
```

### H2 Picnic Ants

**Story card.** The ants found the picnic stack. Each one munches a cube every time a piece locks; a clear next to an ant sends it packing. · **Pip: watcher** (swats with a napkin, misses).
**Stage**: busy diorama, a picnic cloth island crawling with ants. **Intro skit (3 s)**: Pip stacks sandwiches; an ant walks up, takes a bite out of the bottom one and the stack leans. **Payoff skit**: the last ant is cleared; the whole colony marches away carrying one crumb, and Pip waves goodbye with the napkin.

```text
Name:          Picnic Ants
Context:       campaign (hard track)
Story:         Ants raid the picnic stack · mascot: watcher
Board:         BL05 (6×6, H_play 10, 2 starter layers with 3 ants)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (4 layers)
Fail:          FT01 (1 warning)
Optional:      CL01 + CO01 · SP31 ants (eat one neighbouring cube per lock; a clear next to an ant removes it) · EV04 + SP19 mushroom callback (every 6 locks)
One sentence:  "Ants eat your stack; clear next to them."
```
Defaults: 8 Standard, g0 0.9.
```text
top-down, layer 1 (a = ant)   side (slice z = 2)
######                        10 ============
#a####                         1 # # . # a #   ants walk the stack and leave holes
###.##                         0 # # # # # #
####a#
#a####
######
```

### H3 Two Fields

**Story card.** Pip has two vegetable patches and one block drizzle. Each piece goes to the patch you pick; clear 3 layers in each before either one overflows. · **Pip: watcher** (runs between the two patches with a watering can).
**Stage**: clean stage, tense. Two small islands joined by a plank. **Intro skit (3 s)**: Pip waters one patch; the drizzle starts on the other and Pip skids back and forth across the plank. **Payoff skit**: both patches grow a giant carrot; Pip pulls one, then the other, and is flattened by the second.

```text
Name:          Two Fields
Context:       campaign (hard track)
Story:         Two patches, one drizzle · mascot: watcher
Board:         BL07 (2 islands, each 4×4, H_play 8)
Arrival:       AR01 (tap a field to send the piece there)
Verb:          CV01
Goal:          GO01 (3 layers on each field)
Fail:          FT01 (1 warning, shared)
Optional:      CL01 + CO01
One sentence:  "Pick a field for every piece; keep both growing."
```
Defaults: 8 Standard, g0 0.85.
```text
top-down                    side view
####      ####              8 =====      =====   danger line on both
####  ==  ####                :            :
####      ####              0 . . . .    . . . .
####      ####                field A      field B
       (plank)
```

---

## Draft level JSON (ADR-0005 shape)

Knob ids and param names follow the GDDs and are illustrative until the knob JSON files exist. Per the coordinator: `stars` is an object `{t3, t2}` in milliseconds; `story` holds the premise as a translation key (`premise_key`) and the mascot role (an enum, WO06–WO09 names); `recipe` uses the ADR's `{slot, atom}` list with module atom IDs. The starting-contents format is with the architecture lead.

### meadow_01

```json
{
  "schema": 1,
  "id": "meadow_01", "biome": "meadow", "tier": 1, "name": "LVL_MEADOW_01_TITLE",
  "layout": { "kind": "single" },
  "board": { "width": 4, "depth": 4, "h_play": 8, "down_axis": "-y" },
  "pieces": { "shapes": ["i", "o", "t", "l", "s"], "weights": {},
              "opening_set": ["o", "i"], "opening_count": 2 },
  "knobs": { "fall.g0": 0.6, "control.rotation_axes_enabled": ["spin"],
             "spawn.preview_count": 1, "goal.warnings_max": 2, "goal.t_level": 180,
             "clear.collapse": "slice", "spawn.arrival": "top", "goal.top_out": "rescue" },
  "goal": { "type": "clear", "n": 4 },
  "twists": [],
  "stars": { "t3": 105000, "t2": 145000 },
  "seed": null,
  "recipe": [ { "slot": "board", "atom": "BL01" }, { "slot": "arrival", "atom": "AR01" },
              { "slot": "verb", "atom": "CV02" }, { "slot": "goal", "atom": "GO01" },
              { "slot": "fail", "atom": "FT01" }, { "slot": "clear", "atom": "CL01" },
              { "slot": "collapse", "atom": "CO01" }, { "slot": "secret", "atom": "SE05" } ],
  "story": { "title_key": "LVL_MEADOW_01_TITLE", "premise_key": "LVL_MEADOW_01_PREMISE",
             "mascot_role": "helper", "icon": "sprout" }
}
```

### meadow_05

```json
{
  "schema": 1,
  "id": "meadow_05", "biome": "meadow", "tier": 5, "name": "LVL_MEADOW_05_TITLE",
  "layout": { "kind": "single" },
  "board": { "width": 5, "depth": 5, "h_play": 12, "down_axis": "-y" },
  "pieces": { "shapes": ["i", "o", "t", "l", "s", "tripod", "screw_left", "screw_right", "big_cube"],
              "weights": { "big_cube": 0.5 } },
  "knobs": { "fall.g0": 0.8, "spawn.arrival": "top", "goal.top_out": "trim",
             "placement.rule": "wobble" },
  "goal": { "type": "height", "h_target": 10, "height_coverage": 0.6 },
  "mechanic": { "id": "no_clear_build_race",
                "params": { "h_target": 10, "height_coverage": 0.6, "topout_rule": "trim" } },
  "twists": [],
  "stars": { "t3": 170000, "t2": 240000 },
  "seed": null,
  "recipe": [ { "slot": "board", "atom": "BL01" }, { "slot": "arrival", "atom": "AR01" },
              { "slot": "verb", "atom": "CV01" }, { "slot": "goal", "atom": "GO02" },
              { "slot": "fail", "atom": "FT02" }, { "slot": "clear", "atom": "CL14" },
              { "slot": "placement", "atom": "PL03" } ],
  "story": { "title_key": "LVL_MEADOW_05_TITLE", "premise_key": "LVL_MEADOW_05_PREMISE",
             "mascot_role": "watcher", "icon": "tower" }
}
```

### meadow_10

```json
{
  "schema": 1,
  "id": "meadow_10", "biome": "meadow", "tier": 10, "name": "LVL_MEADOW_10_TITLE",
  "layout": { "kind": "single" },
  "board": { "width": 8, "depth": 6, "h_play": 12, "down_axis": "-y" },
  "pieces": { "shapes": ["i", "o", "t", "l", "tripod", "screw_left", "screw_right", "chair"], "weights": {} },
  "knobs": { "fall.g0": 1.0, "clear.collapse": "slice", "spawn.arrival": "top",
             "goal.top_out": "rescue", "goal.warnings_max": 1 },
  "goal": { "type": "clear", "n": 3 },
  "mechanic": { "id": "conveyor_floor",
                "params": { "conveyor_dir": "+x", "conveyor_every": 2, "conveyor_wrap": true } },
  "twists": [
    { "id": "wind", "params": { "wind_dir": "+z", "wind_mode": "fixed", "wind_interval_ms": 8000,
                                "wind_jitter_ms": 2000, "wind_strength": 1 } },
    { "id": "gravity_flip", "params": { "flip_every_layers": 2, "flip_every_ms": 180000, "flip_warn_ms": 2000 } }
  ],
  "stars": { "t3": 225000, "t2": 315000 },
  "seed": null,
  "recipe": [ { "slot": "board", "atom": "BL01" }, { "slot": "arrival", "atom": "AR01" },
              { "slot": "verb", "atom": "CV01" }, { "slot": "goal", "atom": "GO01" },
              { "slot": "fail", "atom": "FT01" }, { "slot": "clear", "atom": "CL01" },
              { "slot": "collapse", "atom": "CO01" }, { "slot": "event", "atom": "EV05" },
              { "slot": "event", "atom": "EV01" }, { "slot": "event", "atom": "EV03" } ],
  "story": { "title_key": "LVL_MEADOW_10_TITLE", "premise_key": "LVL_MEADOW_10_PREMISE",
             "mascot_role": "watcher", "icon": "windmill" }
}
```

## Open items

- **Format**: `story.premise_key` + `story.mascot_role` and `stars {t3, t2}` follow the coordinator's ruling; ADR-0005 and the module example need the same update. `starting_contents` (cell list vs. ASCII) is with the architecture lead.
- **Candidate atoms to define before build**: WO06 (Pip's "catch one bad drop" on tiers 1–3), SE05 (rubber duck), SP28, PL03, SP22, SP26, SP21 (proposed additions), SP31 (H2), BL07 tap-to-choose arrival (H3).
- **Hard-track schema**: how `meadow_h1`–`h3` are marked (tier value, unlock rule "finish 10") is open for Campaign Structure.
- **Finale phases**: phase 2 is triggered by the flip's own 2-clear rule. A true phase change (e.g. gusts stop) would need EV13 Halftime swap.
- **Budget reading**: "new atoms" counts only non-default atoms, and a level mechanic bundle counts as one idea. Confirm with the module owner (module open question 1).
- **Story vs. bible**: `biome-bible.md` §2.1 still has the older Meadow story (sky-mill, "the meadow critter"); this file follows `biome-stories.md` (Pip, the Miller badger).
