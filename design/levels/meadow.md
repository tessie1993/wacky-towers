# Meadow Biome — First Playable (levels 1–10)

> **Status**: Draft (Phase 2, user answers 2026-10-09)
> **Author**: Tessa + level-designer
> **Last Updated**: 2026-10-09
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Field definitions**: `design/gdd/level-data-definition.md` (schema), owning GDDs for defaults

**Every number in this file is a tunable default** — a starting point for the prototype and playtests, not a rule. Change any of them freely; the validator only enforces the safe ranges in the owning GDDs.

## Theme and intent

A sunny floating meadow island: grass tiles, wooden signs, mushrooms, dew, a mossy mill belt. Ten levels, **one new idea each**, and level 10 stacks them, plus one star-unlocked **bonus puzzle**. The blocks never change; what changes is the **goal** (Clear, Height, Shape, Survive), the **board** (seven footprints), the **starting contents** (pre-built puzzles) and one twist or mechanic. The campaign-wide arc and track rules are in `design/gdd/campaign-structure.md` ("Campaign shape").

**The wacky test** (user decision, round 3; applies to every level in every biome). A level passes only if it has all four:
1. **A surprising rule change**: the world misbehaves in a way you can see within two pieces.
2. **Something silly**: a piece, prop or critter with personality.
3. **A funny failure**: losing, trimming or a twist going wrong looks fun, never harsh.
4. **A big visual moment**: at least one screen-wide beat (the double clear, the flip, the boss reveal).

Humour mix: wholesome slapstick, dry and absurd, cheeky chaos. **Meadow mascot**: a small local critter (species and name TBD with narrative-director and art-director; working name "the meadow critter") sits on the island edge and reacts to clears, gusts, trims and wins. **Twists are biome events**: in the meadow, Wind is the *Dandelion Gust*, Spawned Objects the *Mushroom Pop-up*, Invisible Blocks the *Morning Fog*, Gravity Flip the *Topsy Tumble*. The rules are the Twist Library's; only the name, dressing and mascot reaction are the meadow's.

**Common defaults** (unless a level says otherwise): weighted bag, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, rotation axes all (spin, tilt, roll), `t_piece` 8 s. Speeds are hand-set per level (user decision Q1) and match campaign F2 (`0.6 + 0.045 × (tier − 1)`) within ±0.05.

**ASCII grids** (masks, starting contents, target shapes): one string per row, row 0 = `z = 0`, character 0 = `x = 0`. Mask: `#` active, `.` off. Starting layers: `#` starter block, `m` mushroom, `.` empty. Target layers: `#` target cell, `.` not a target.

## Summary table

| # | id | Name | New idea | Goal | Board (W×D, H_play / mask) | Pieces · opening | g0 | Twist(s) | Mechanic | Top-out | Est. length | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | meadow_01 | First Sprout | Drop and spin | Clear 4 | 4×4, 8 | 5 flat · first 2 from {O, I} | 0.6 | — | — | rescue, 2 warnings | ~3 min | 145 s / 105 s |
| 2 | meadow_02 | Tilt & Roll | Tilt/roll, 3D pieces | Clear 3 | 6×6, 10 + 2 starter layers with 3D pockets | 8 Standard · first 3 from {Tripod, Screw-L, Screw-R} | 0.6 | — | — | rescue, 1 | ~2.5 min | 130 s / 90 s |
| 3 | meadow_03 | Breezy Hill | Wind | Clear 5 | 8×4 lane, 10 | 8 Standard | 0.7 | Wind (+x, every 8 s) | — | rescue, 1 | ~7 min | 365 s / 255 s |
| 4 | meadow_04 | Mushroom Ring | Spawned objects | Clear 3 | 7×7 ring (centre 3×3 off, A = 40), 10, `spawn_anchor` (3, 5) | 8 Standard | 0.75 | Spawned Objects (every 5 locks) | — | rescue, 1 | ~5.3 min | 270 s / 190 s |
| 5 | meadow_05 | Tall Tower | Build up, not clear | Height 10, coverage 0.6 | 5×5, 12 | 8 Standard + Big Cube (w 0.5) | 0.8 | — | Build Race | **trim** | ~4.7 min | 240 s / 170 s |
| 6 | meadow_06 | Flower Bed | Fill a picture | Shape: 2-layer flower, 50 cells | 8×8, 8 | I, O, T, L, S, Tripod + Duo, Tri-Corner | 0.7 | — | Target Shape | **trim** | ~3 min | 155 s / 110 s |
| 7 | meadow_07 | Hide & Seek | Memory | Clear 4 | 6×6, 10 + 2 starter layers (fade too) | 8 Standard | 0.85 | Invisible Blocks (visible 5 s) | — | rescue, 1 | ~4 min | 195 s / 140 s |
| 8 | meadow_08 | Dewdrop | Instant lock + Survive | Survive 2:30, `ramp_per_min` 0.15 | 5×5, 8 | 8 Standard | 0.9 (× 0.7 sticky) | — | Sticky Landing | rescue, 1 | 2.5 min | 1 / 2 layers |
| 9 | meadow_09 | Topsy-Turvy | Down becomes up | Clear 4 | 6×6, 10 | 8 Standard | 0.95 | Gravity Flip (2 layers or 40 s) | — | rescue, 1 | ~6.4 min | 325 s / 230 s |
| 10 | meadow_10 | Meadow Mill | Finale stack + boss | Clear 3 | 8×6 (A = 48), 12 | 7 Standard (no S) + Chair | 1.0 | Wind (+z) + Spawned Objects | Conveyor (+x, every 2 locks, wrap) | rescue, 1 | ~6.2 min | 315 s / 225 s |
| B | meadow_bonus | Picnic Puzzle | Fixed piece list | Shape: 4×4×2 basket | 4×4, 6 | `fixed_list`: I, O, Big Cube, I, O, Big Cube | 0.5 | — | Target Shape | trim; out of pieces = lost | ~1 min | 60 s / 40 s |

Star times use Scoring & Stars F1 (0.85 / 0.6 of the estimate) except levels 2 and 7, whose estimates are hand-set because starting contents make F1 overestimate. Retuned from the Phase 1 draft by the length math (kept by the user): level 3 Clear 3 → 5, level 7 Clear 3 → 4, level 5 on 5×5. Retuned by the systems-designer's math: level 8 on 5×5, H_play 8 (the 8×8 plus gave a survive pressure of only 0.42, so no tension); level 10 at A = 48 (about 125 s per clear). Levels 1, 2, 6 and 8 are short on purpose (tutorials and breathers); the validator's length warning is expected there.

## Pacing chart (intensity across the biome)

```
intensity
 high |                                                   #
      |                                    #        #     #
      |                #            #      #   #    #     #
  mid |         #      #     #      #      #   #    #     #
      |    #    #      #     #   #  #      #   #    #     #
  low | #  #    #      #     #   #  #      #   #    #     #
      +-01-02---03-----04----05--06-07-----08--09---10---
        learn   twist  twist build pic mem  sprint flip FINALE
```

Rhythm: two teaching levels → two twist levels on unusual boards → a **break from clearing** (05 tower, 06 picture: no fail, lower pressure) → memory → a short sprint → the hardest twist → the finale. Each spike is followed by a lower or different kind of challenge, never two pressure peaks in a row before the finale.

---

## Level specs

### meadow_01 — First Sprout
- **Teaches**: drop, move, spin, hard drop, a layer clear. Spin only (`rotation_axes_enabled: [spin]`).
- **Board**: 4 × 4, H_play 8 (12 drawn). Cubes are large (~36 px) so the first touch is easy.
- **Pieces**: I, O, T, L, S. `opening_set: [O, I]`, `opening_count: 2`: the first two pieces fill half a layer cleanly.
- **Goal**: Clear 4 (`T_level` 180 → F1 N = 4). `warnings_max` 2: the first scares are free.
- **Critical path**: about 4–6 pieces per clear; four clears ≈ 21 pieces.
- **Leading elements**: the landing ghost and a soft grass glow on the emptiest cells.
- **Stars**: ★★ 145 s, ★★★ 105 s with no warning used.
- **Audio**: meadow theme, gentle layer; first clear plays a bigger chime than usual (one time only).

### meadow_02 — Tilt & Roll
- **Teaches**: tilt and roll, and that 3D pieces exist. Axes: spin, tilt, roll.
- **Board**: 6 × 6, H_play 10, with two starter layers (blocks drawn as meadow stone, `shape_id: starter`). Three pockets each fit exactly one 3D piece: Tripod (A), and the two screws (B, C, mirror images). A flat piece cannot fill a pocket exactly (the four cells are not in one plane).

```
layer 0          layer 1
######           ######
#.###.           #..#..      A: top L at (1,1)(2,1)(1,2), hole below the corner (1,1)
######           #.##.#      B: top L at (4,1)(5,1)(4,2), hole below the end (5,1)
######           ###.##      C: top L at (3,4)(4,4)(3,3), hole below the end (4,4)
####.#           ###..#
######           ######
```

- **Pieces**: 8 Standard. `opening_set: [Tripod, Screw-Left, Screw-Right]`, `opening_count: 3`. The opening is a bag of the three (Spawner rule 5a), so each comes exactly once in a random order and the player has to read which pocket the current piece fits.
- **Goal**: Clear 3. Filling all three pockets clears layers 0 and 1 together (a double, a big moment); one free clear follows.
- **Stars**: hand estimate ~150 s → ★★ 130 s, ★★★ 90 s.
- **Validator**: each pocket must be exactly fillable by its named shape (authoring check, Open Questions).

### meadow_03 — Breezy Hill
- **Teaches**: Wind. Telegraph first (arrow + bending grass), then the gust.
- **Board**: 8 wide (x) × 4 deep (z), H_play 10. A long lane: the wind blows along it (`wind_dir: +x`) toward the x = 7 wall.
- **Twist**: Wind, `wind_interval_ms` 8 000 (slower than the 6 000 default), jitter 2 000, strength 1, fixed.
- **Goal**: Clear 5 (P_eff ≈ 10.7; t_est ≈ 427 s).
- **Play idea**: the downwind wall is a brace: build from the x = 7 end and let gusts push pieces home. Fighting the wind upwind is the slow route.
- **Stars**: ★★ 365 s, ★★★ 255 s.
- **Audio**: wind layer joins the meadow theme; whoosh on gusts.

### meadow_04 — Mushroom Ring
- **Teaches**: Spawned Objects (a sparkle one lock ahead, then a mushroom pops up).
- **Board**: 7 × 7 with the centre 3 × 3 off (a 2-wide ring, A = 40), H_play 10. The centre is a pond. `spawn_anchor: (3, 5)` on the front band because the footprint centre is inactive.

```
#######
#######
##...##
##...##
##...##
#######
#######
```

- **Twist**: Spawned Objects, `spawn_every_locks` 5, `objects_max` 4.
- **Goal**: Clear 3 (P_eff ≈ 13.3; t_est ≈ 320 s).
- **Play idea**: mushrooms fill cells for free; a ring is hard to close, so a mushroom in the right corner is a gift. Corners of the ring are the tricky cells.
- **Stars**: ★★ 270 s, ★★★ 190 s.

### meadow_05 — Tall Tower
- **Teaches**: a build race. Clearing is off; build up to the sign.
- **Board**: 5 × 5, H_play 12 (16 drawn). Skinny, tall, dramatic.
- **Pieces**: 8 Standard plus Big Cube at weight 0.5 (bag of 17: two of each Standard, one Big Cube). Big Cube is the fun "free 2 layers" piece. c ≈ 4.24.
- **Mechanic**: No-Clear Build Race, `H_target` 10, `height_coverage` 0.6, `topout_rule` trim. No twist (user decision Q6).
- **Top-out (trim)**: any cube at or above layer 12 pops off the island with a bonk; no warning is used, the level never fails. Over-building only costs time.
- **Est.**: F2 → 10 × 0.6 × 25 / 4.24 ≈ 35 pieces ≈ 283 s.
- **Stars**: ★★ 240 s; ★★★ 170 s **and no cube trimmed**.
- **Leading elements**: a wooden sign and ribbon at layer 10; the counting layer glows when it reaches coverage.

### meadow_06 — Flower Bed
- **Teaches**: Fill the Target Shape. Clearing off.
- **Board**: 8 × 8, H_play 8 (12 drawn). First big footprint, but low and calm.
- **Pieces**: I, O, T, L, S, Tripod, Duo, Tri-Corner (8 shapes, c ≈ 3.6). Helpers let the player finish petals cleanly.
- **Mechanic**: Fill the Target Shape, `topout_rule` trim. Target (50 cells): a flower lying on the grass, with its centre raised one layer.

```
layer 0 (38)     layer 1 (12)
.##..##.         ........
########         ..####..
.######.         ..####..
########         ..####..
.##..##.         ........
...##...         ........
.####...         ........
...##...         ........
```

- **Est.**: F3 → 50 / (3.6 × 0.6) ≈ 23 pieces ≈ 184 s. A breather after the tower.
- **Stars**: ★★ 155 s; ★★★ 110 s and no cube trimmed.
- **Leading elements**: flower outlines on the grass; covered cells bloom.

### meadow_07 — Hide & Seek
- **Teaches**: Invisible Blocks: remember the stack; clears reveal it.
- **Board**: 6 × 6, H_play 10, with two starter layers that fade like everything else. Starter blocks are visible through Intro and Countdown, then their `visible_ms` timer starts at the first spawn.

```
layer 0          layer 1
##.###           ##.#..
######           .#####
#####.           ##.##.
.#####           .###..
######           ######
###.##           ##..##
```

- **Twist**: Invisible Blocks, `visible_ms` 5 000 (gentler than 4 000), fade 1 000, alpha 0.1, reveal 600.
- **Goal**: Clear 4. The two starter layers need ~15 cubes, so the first clears come fast and give reveals early; the last two are on memory.
- **Stars**: hand estimate ~230 s → ★★ 195 s, ★★★ 140 s.

### meadow_08 — Dewdrop
- **Teaches**: Sticky Landing (locks on touch) and the Survive goal (user decision Q3).
- **Board**: 5 × 5, H_play 8 (12 drawn). Small and low, so a few sticky mistakes really matter (systems-designer retune; the earlier 8 × 8 plus had no tension).
- **Mechanic**: Sticky Landing, `sticky_gravity_scale` 0.7 → effective speed 0.63 rising to about 0.9 by the end (`ramp_per_min` 0.15).
- **Goal**: Survive 150 s. Short and tense on purpose.
- **Stars** (Scoring F4, P_eff ≈ 8.3 → expected ≈ 2.25 layers): ★★ 1 layer cleared, ★★★ 2 layers and no warning used.

### meadow_09 — Topsy-Turvy
- **Teaches**: Gravity Flip.
- **Board**: 6 × 6, H_play 10. Small enough that the flipped stack stays readable.
- **Twist**: Gravity Flip, `flip_every_layers` 2, `flip_every_ms` 40 000, warn 2 000.
- **Goal**: Clear 4 (P_eff 12; t_est ≈ 384 s).
- **Play idea**: a flat, tidy stack survives a flip; a spiky one becomes a mess at the new top.
- **Stars**: ★★ 325 s, ★★★ 230 s.

### meadow_10 — Meadow Mill
- **Teaches**: nothing new: the finale stacks two twists and a mechanic, on the widest, tallest board of the biome.
- **Board**: 8 wide (x, along the belt) × 6 deep (z), H_play 12 (16 drawn), A = 48 (≈ 125 s per clear). A rectangle rather than the suggested 8 × 8 plus mask, because Conveyor requires an unmasked rectangular board (Level-Specific Mechanics rule 17); same A, same pacing.
- **Finale boss**: the mill's owner, a cheeky character (working name "the Miller"; design with narrative-director and art-director) who runs the show. Its sails blow the Dandelion Gusts, it cranks the belt, and it tosses mushrooms onto the stack. Same rules as the twists, given a face: it winds up before each event (the telegraph), cheers your trims and sulks on each clear. On the win it gets bonked off the mill by the final clear (the big visual moment).
- **Pieces**: I, O, T, L, Tripod, Screw-Left, Screw-Right, Chair (c ≈ 4.1).
- **Mechanic**: Conveyor Floor, `conveyor_dir` +x, `conveyor_every` 2, wrap on.
- **Twists**: Wind, `wind_dir` +z (across the belt, so the two motions never cancel), interval 8 000; Spawned Objects, every 6 locks, max 4.
- **Goal**: Clear 3 (P_eff ≈ 15.5; t_est ≈ 372 s).
- **Play idea**: drop where the gap *will be* after the belt moves; mushrooms ride the belt too.
- **Stars**: ★★ 315 s, ★★★ 225 s.
- **Audio**: full meadow theme with the mill rhythm; the win plays the biome-complete sting.

### meadow_bonus — Picnic Puzzle (bonus, unlocked at 20 meadow stars)
- **Teaches**: puzzle levels: a fixed piece list, every piece counts. Off the main path (hard track), retry-heavy on purpose, retry is free.
- **Board**: 4 × 4, H_play 6. The target is a picnic basket: the whole 4 × 4 footprint, 2 layers (32 cells).

```
layer 0 and layer 1 (both)
####
####
####
####
```

- **Pieces**: `fixed_list: [I, O, Big Cube, I, O, Big Cube]` (32 cubes: exactly the basket). Preview 3, so the player can plan ahead.
- **Mechanic**: Fill the Target Shape. One wrong placement leaves a hole no later piece fits: **out of pieces = lost** (Level Goals rule 10c).
- **Known solution**: both Big Cubes fill rows z 0–1 (two 2 × 2 × 2 blocks); both I pieces lie along row z 2 (one on each layer); both O pieces stand upright in row z 3. Dealt in list order, each placement is supported.
- **Wacky**: the critter is sitting in the basket and has to dodge every drop; a failed basket tips over and the picnic spills.
- **Stars**: ★★ 60 s, ★★★ 40 s and no cube trimmed.

---

## Wacky test per level

| Level | Surprising rule | Silly thing | Funny failure | Big visual moment |
|---|---|---|---|---|
| 01 First Sprout | — (tutorial; the first clear is the surprise) | The sprout grows a leaf on each clear | The critter covers its eyes on a warning | The first clear's oversized chime and confetti |
| 02 Tilt & Roll | The board starts half-built with holes | Pockets shaped like the 3D pieces "wink" | A wrong piece gets a "nope" wobble from the critter | Double clear when all three pockets fill |
| 03 Breezy Hill | Dandelion Gusts push your piece | Seeds stick to the critter's face | A gust shoves a piece into the wrong spot; the critter shrugs | A big gust sweeps the whole lane |
| 04 Mushroom Ring | Mushrooms pop up on the stack | Mushrooms with faces squeak when cleared | A mushroom blocks the perfect gap and grins | The pond in the ring sparkles on each clear |
| 05 Tall Tower | Clearing is off; build up | Big Cube "thunks" in like a treat | Trimmed cubes bounce off the island like popcorn | The tower reaching the sign: fireworks |
| 06 Flower Bed | Fill a picture, not layers | Flowers bloom as cells fill | Trimmed petals float away | The whole flower blooms on the win |
| 07 Hide & Seek | Your stack vanishes in fog | The critter plays peek-a-boo in the fog | A piece lands on an "empty" spot that wasn't | Fog bursts away on each clear |
| 08 Dewdrop | Pieces lock on touch | Dewdrops splat on every lock | A sticky piece stuck at a silly angle | The final seconds: the dew sparkles |
| 09 Topsy-Turvy | Down becomes up | The critter hangs upside down | The stack lands on its head with a "whump" | The whole stack tumbling to the new floor |
| 10 Meadow Mill | Belt + gusts + mushrooms, with a boss | The Miller's antics | The Miller cheers your trims and warnings | The Miller bonked off the mill on the win |
| Bonus | A fixed list: every piece counts | Critter sits in the basket | The basket tips and the picnic spills | The basket lid closes with a bow |

## Narrative and environment beats

No story decisions here (narrative-director owns them). Environment only: the island gets busier level by level — a sprout (01), stones (02), windmill-less hill (03), mushroom ring around a pond (04), a tall wooden tower sign (05), a flower garden (06), fog patches (07), dew on the grass (08), an upside-down tree (09), and the mill with its belt turning (10).

## Music and audio cues

One meadow theme, layered: base (01–02) → + wind layer (03) → + plucks for mushrooms (04) → a percussive build layer for 05–06 (no danger music, since trim cannot lose) → softer, sparser mix for 07 (memory) → faster tempo for 08 (Survive) → full mix for 09–10. Danger stinger only where `topout_rule` is rescue.

## Open questions

- **Pocket check (meadow_02)**: the validator should confirm each pocket is exactly fillable by its named shape. Until then, check by hand in the prototype.
- **Short levels**: 01, 02, 06 and 08 are under 5 minutes; confirm in the playtest that this pacing feels good, or lengthen them.
- **Trim feel**: is popping cubes off the island readable as "too high" rather than as a bug? Prototype with level 05.
- **Starter block look**: meadow stone vs. a greyed candy block — art-director.
- **Star times** are formula estimates; replace with playtest medians.
- **meadow_10 board**: the systems-designer suggested an 8 × 8 plus mask (A = 48), but Conveyor forbids masks (Level-Specific Mechanics rule 17). I used an 8 × 6 rectangle with the same A. If the plus shape matters, Conveyor would need a wrap-within-active-run rule (a Level-Specific Mechanics change).
- **Mascot and boss**: species, names and personalities belong to narrative-director and art-director; the working names here are placeholders.
- **Bonus unlock**: 20 meadow stars is a starting value (Campaign Structure `bonus_star_gate`).
