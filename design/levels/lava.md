# Lava Biome: Cinder's Snack (levels 01–10, bonus, hard track)

> **Status**: Draft v1 for user review (level-designer, 2026-10-10). Written straight through under the /team-narrative round ("biomes 6–10 + side islands: designers decide, user reviews the finished result").
> **Author**: level-designer
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Format source**: `design/levels/meadow.md` (section for section).
> **Sources**: `production/narrative/campaign-story/brief.md` (§3.5, §5, §7), `lore-world.md` §3.5, `dialogue-campaign-skits.md` §5, `visual-direction.md` (Lava), `design/gdd/mechanics-module.md` (atoms, F1 budget), `campaign-structure.md`, `level-data-definition.md`, `level-specific-mechanics.md`, `scoring-stars.md`, `skills.md` (Smash), `production/levels/campaign/biome-stories.md` §7 (10-beat arc).
> **Field definitions**: `design/gdd/level-data-definition.md`; defaults from the owning GDDs.

**Every number, name and beat in this file is a tunable default**, a starting point for the prototype and playtests. The validator enforces only the safe ranges in the owning GDDs. Atom ids come from the mechanics library; status is **D** Designed, **C** Candidate, **Pr** Proposed.

---

## 1. Level name and theme

**Cinder's Snack.** Cinder the fire salamander wants to roast one marshmallow before the volcano rumbles, and every snack she gets near comes out charcoal. Blocks fall as a slow **ember drizzle** over a red-dusk volcano island of black obsidian, magma veins and ash dunes. Smolder, a baby dragon who secretly wants a bath, refuses the box of bath bombs a violet-ribboned parachute dropped into his crater and throws tantrums instead: he kicks geysers, stomps quakes and puffs smoke. In the finale the last clear launches the whole bath-bomb box into the crater pool with him in it; he sputters, sinks to the chin, and will not admit he liked it. Keepsake: the ember. Boulder the pygmy hippo (demolition worker) joins the wizard after the payoff and her **Smash** skill unlocks. Story beat 5 of the plot spine: the Miller turns up at the rim and shows the wizard the **Rosetta** (level 08), and Mizzle walks away under a tower of parcels (level 07).

**Quirk: "Warm ground."** The floor itself is the biome's character. Each level changes what the ground does (sits still, hides a pocket, rises, pops, holds a tower, browns, hides in smoke, shakes, slides, and finally goes through all of it) while the blocks and the controls stay the same. Strangeness zig-zags level to level, as in the Meadow (no straight ramp).

### Biome rules (decisions)

| Rule | Default |
|---|---|
| Islands | One per level, shaped by the story (campfire ledge, ember-pocket ledge, narrow lava lane, geyser flat, obsidian tower, roast ledge, smoky ash slope, rumbling eruption terrace, magma-flow shelf, crater rim, forge) |
| Stage | Busy diorama or clean stage per level as the story needs; calm levels are quiet, chaos levels busy. Backdrop smoke, ember drift and vents stay dull and away from hazard orange (art bible 4.4) |
| Intro skit | A 3-second wordless mini-scene played during the Countdown (no play time lost) |
| Payoff skit | 5 s or less on every win, tap to skip; finale 6 s on first play (last 2 beats on replays) |
| Mascot | **Cinder** (Lava only). Role **watcher** (WO09, staging only) on every level: huffs sparks, sulks on a warning, `sparkle` on a clear. No helper or catch rule here (those are Meadow tiers 1–3, Pip). Mood swing (WO08) is staging only |
| Boss | **Smolder**, a baby dragon, in level 10. Wind-ups: cheeks puff and wings flare (a small smoke ring) before every effect; bonked, never hurt |
| Friend | **Boulder** joins in the 10 payoff (4 s join skit + unlock card). **Smash** unlocks for the campaign, Arcade and later biomes. No Lava level requires it; star times are balanced with no skill, and the button appears only where a level offers it (skills rule 13) |
| The Miller | Cameo allowed (the one stated exception): level 08 payoff only (the Rosetta) |
| Physics | None (no wobble level; the Meadow's tower is the one physics level) |
| Rubber duck | Floating in a warm steam pool under the ledge in 01 and 02 (SE05, visible from one low snap angle; tap to collect; no stars attached) |
| Events as Lava events | Lava and lid = **Rising Lava** (EV06); Spawned Objects = **Geyser Pop** (EV04); Invisible Blocks = **Smoke Screen** (EV02); Conveyor = **Magma Belt** (EV05); Quake = **Eruption Rumble** (EV12) |
| Music | One full track per level, supplied by the user. Ids `lava_01`…`lava_10`, `lava_bonus`, `lava_h1`…`lava_h3` are **placeholders**; an unknown id warns and falls back to the biome `default_music` (level-data 4e) |
| Prototype priority | **02, 03, 08, 10** (★PROTO): the three new rules (Ember drill, Rising Lava, Rumble) and the boss |

**Common defaults** (unless a level says otherwise): weighted bag, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, all rotation axes (Turn / Flip / Roll, CV01), `t_piece` 8 s. Speeds are hand-set within ±0.05 of campaign F2 for biome 5 (`0.84 + 0.045 × (tier − 1)`). Star times use Scoring F1 (`t_est = N × A × 2.67 s` for layer clears at the default efficiency) unless a level says hand-set. Stars are authored with no perks and no skill.

**Budget (mechanics module F1).** At most 2 atoms new to the player and 4 non-default atoms per level (6 on showpiece levels in tiers 7–10). "New" here is counted conservatively as **first used in the Lava path, assuming only Meadow atoms are known**; the validator will recount against the real path (Candy, Ice, Underwater come first), which can only lower the numbers. Bundles M1 and M2 count 1. Slot defaults: BL01, AR01, CV01, CL01, CO01, GO01, FT01.

**Grids**: one string per row, row 0 = `z = 0` (back), character 0 = `x = 0` (left). Mask `#` active, `.` off; starting layers `#` starter block, `k` ash-crusted (locked) block, `L` lid block (a starter block over a hole), `.` empty; targets `+`. Side views are a slice at one `z` row seen from the front; `=====` is the danger line at `H_play`, `S` the spawn zone, `:` skips empty rows.

**Lava rule defaults used below** (full rules belong in the owning GDDs; see §10):
- **Rising Lava (EV06, campaign form).** Every `melt_every_s` the lava surface rises one layer: the cubes in the lowest live layer are lost with a sizzle (no score, no clear credit, no collapse), its cells become lava (inactive), and the headroom under the danger line shrinks by one. After `melt_max` rises the lava **cools to obsidian** and the floor is stable for good. Warning `melt_warn_ms` 3 000 (bubbling edge and a rumble). Cubes above a lava cell are held by the obsidian skin. A layer is judged complete on its live cells.
- **Eruption Rumble (EV12).** Every `quake_every_s` the island shudders after `quake_warn_ms`; cubes with an empty cell directly below them (floating roofs and overhangs) plop off the stack into the lava, at most `quake_max_cubes` per rumble.
- **Ember drill (SP40, Pr).** One piece per bag (`ember_per_bag` 1) has one glowing ember cube. On lock it melts up to `drill_depth` (1) Blocks straight below that cube, then the piece drops rigidly until supported. The landing ghost shows the post-melt cells. Never ends a level.
- **Geyser Pop (EV04 + SP35).** A vent object spawns on a free top-surface cell every `spawn_every_locks`, steam one lock ahead; the next piece landing on it hops up `bounce_h` 1 and relocks one cell onward in its move direction (once per landing). Vent objects clear with their layer.

## 2. Estimated play time and summary

| # | id | Name | Story beat | New idea (atoms) | Cinder | Stage | Goal | Board | Pieces | g0 | Top-out | Length | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | lava_01 | Warm Start | Stoke the campfire | classic, ember look | watcher | clean, calm | Clear 3 | 5×5, H8 | I O T L S; first 2 from {O, I} | 0.85 | rescue, 1 | ~3.3 min | 170 / 120 s |
| 02 ★ | lava_02 | Ember Pockets | Cool the glowing holes | Ember drill (SP40), lidded pockets (BL05) | watcher | clean, calm | Clear 3 | 5×5, H10 + 2 starter layers | I O T L S Duo Tripod | 0.90 | rescue, 1 | ~2.5 min | 150 / 105 s |
| 03 ★ | lava_03 | Lava Lane | Keep ahead of the lava | strip (BL06), Rising Lava (EV06) | watcher | busy | Clear 4 | 8×3 lane, H10 | 8 Std | 0.95 | rescue, 1 | ~4.3 min | 215 / 155 s |
| 04 | lava_04 | Geyser Pop | Geysers launch the vents | Geyser Pop (EV04), vent pads (SP35) | watcher | busy | Clear 4 | 6×6, H10 | 8 Std | 1.00 | rescue, 1 | ~6.4 min | 325 / 230 s |
| 05 | lava_05 | Obsidian Tower | A lookout cinder can fan on | build race (M1), brittle overhangs (PL02) | watcher | clean, tense | Height 10 (cov. 0.6) | 5×5, H12 | 8 Std + Big Cube (w 0.5) | 1.00 | trim | ~4.7 min | 240 / 170 s* |
| 06 | lava_06 | Marshmallow Roast | Fill the marshmallow sticks | fill shape (M2), inside the outline (PL07) | watcher | clean, calm | Shape 52 | 8×6, H8 | I O T L S Tripod Duo Tri-Corner | 1.05 | trim | ~3.2 min | 160 / 115 s* |
| 07 | lava_07 | Smoke Screen | Ash cloud after each cough | Smoke (EV02) + ember drill callback | watcher | busy, hushed | Clear 3 | 6×6, H10 | 8 Std | 1.10 | rescue, 1 | ~4.8 min | 245 / 175 s |
| 08 ★ | lava_08 | Eruption | The terrace rumbles | Survive (GO04), Rumble (EV12) | watcher | busy, tense | Survive 150 s | 5×5, H10 | 8 Std | 1.15 (ramp) | rescue, 1 | 2.5 min | 1 / 2 layers |
| 09 | lava_09 | Magma Flow | The shelf slides | Magma Belt (EV05) + Rising Lava + Geyser (callbacks) | watcher | busy | Clear 3 | 8×6, H12 | 8 Std | 1.20 | rescue, 1 | ~6.4 min | 325 / 230 s |
| 10 ★ | lava_10 | Smolder's Spa | Boss: the bath | Geyser, Rumble, Smoke in 3 phases | boss | busiest | Clear 3 | 7×7, H12 | I O T L Tripod Screws Chair | 1.25 | rescue, 1 | ~6.5 min | 335 / 235 s |
| B | lava_bonus | Forge Puzzle | Fill the anvil | fixed list (AR09), budget (FT07) | watcher | clean, hurried | Shape 28 | 8×2, H6 | fixed: Big Cube, Duo, Duo, I, I, I, I | 0.70 | out of pieces | ≤ 2 min | 100 / 60 s |
| H1 | lava_h1 | Lava Rush | The lane, faster | Rising Lava (hard) + geysers | watcher | busy | Clear 5 | 8×3 lane, H10 | 8 Std | 1.30 | rescue, 1 | ~5.3 min | 270 / 190 s |
| H2 | lava_h2 | Ash Crust | Ash-crusted starter stack | Lock (SP30) + rumble; Smash-friendly | watcher | busy | Clear 4 | 6×6, H10 + 2 starter layers | 8 Std | 1.30 | rescue, 1 | ~5 min | 295 / 205 s |
| H3 | lava_h3 | Forge Fixings | Drill the lidded holes | ember drill + fixed list (puzzle) | watcher | clean, tense | Clear 2 | 4×4, H6 + 2 starter layers | fixed: 7 pieces | 0.80 | out of pieces | ≤ 2 min | 130 / 85 s |

★ = prototype priority. \* ★★★ also requires no cube trimmed (Scoring & Stars). Star times use Scoring F1 except 02 (hand-set, starter layers), 06 (shape estimate from the Meadow's 3.64 s per target cell), 08 (Survive, layer stars), B, H2 and H3 (hand-set). Length notes: 01, 02, 06, 08 and B are short on purpose; the validator's length warning is expected. Long and short alternate (campaign rule 12): 3.3, 2.5, 4.3, **6.4**, 4.7, 3.2, 4.8, 2.5, **6.4**, **6.5** (09 and 10 are long back to back, as in the Meadow; 10 is the finale).

**Puzzle levels (campaign rule 15):** two, both off the main path: the Forge Puzzle (B) and Forge Fixings (H3). The main path stays gentle.

**Hard track (decision).** `lava_bonus` is tier 11 (unlocks at 20 lava stars). The remixes are **tiers 12–14** (`lava_h1`–`h3`); all three open when `lava_10` is finished. Neither the bonus nor the remixes count toward the next biome's star gate. If the bonus is opened before 10 is finished, Boulder has not joined and Smash is simply not shown.

**Novelty budget per level** (`nd` non-default / `new` first-use in this path, per F1 count rule; atoms in **bold** are new):

| # | Non-default atoms | nd | new |
|---|---|---|---|
| 01 | none (SE05 not counted) | 0 | 0 |
| 02 | BL05, **SP40 (Pr)** | 2 | 1 |
| 03 | **BL06**, **EV06** | 2 | 2 |
| 04 | EV04, **SP35** | 2 | 1 |
| 05 | M1 bundle (GO02 + CL14 + FT02), **PL02** | 2 | 1 |
| 06 | M2 bundle (GO03 + CL14), **PL07** | 2 | 1 |
| 07 | EV02, SP40 | 2 | 0 |
| 08 | GO04, **EV12** | 2 | 1 |
| 09 | EV05, EV06, EV04, SP19 | 4 | 0 |
| 10 | EV04, SP19, EV12, EV02 | 4 | 0 (showpiece cap 6) |
| B | AR09, M2 bundle, FT07 | 3 | 0 |
| H1 | BL06, EV06, EV04 | 3 | 0 |
| H2 | BL05, **SP30**, EV12 | 3 | 1 |
| H3 | BL05, AR09, SP40, FT07 | 4 | 0 |

## 3. Layout overview

```text
01 campfire    02 ember pockets  03 lava lane      04 geyser flat   05 obsidian tower
#####          #####             ########         ######           #####
#####          #####             ########         ######           #####
#####          #####             ########         ######           #####
#####          #####                              ######           #####
#####          #####                              ######           #####
                                                  ######
06 roast ledge   07 ash slope   08 eruption terrace  09 magma shelf (belt →)   10 crater rim
########         ######         #####                ########                  #######
########         ######         #####                ########                  #######
########         ######         #####                ########                  #######
########         ######         #####                ########                  #######
########         ######         #####                ########                  #######
########         ######                              ########                  #######
                                                                               #######
B forge (anvil)  H1 lane        H2 ash crust         H3 forge fixings
########         ########       ######               ####
########         ########       ######               ####
                 ########       ######               ####
                                ######               ####
                                ######
                                ######
```

## 4. Critical path and optional paths

- **Critical path**: 01 → 10 in order (linear inside a biome). Finishing 10 completes the Lava (and unlocks Boulder); the next biome opens with 15 of 30 stars.
- **Optional**: ★★★ times on every level; the rubber duck in 01–02; the Forge Puzzle (20 stars); hard-track remixes H1–H3 (after 10).
- **Side island unlocked here**: Dune Bazaar opens after Lava (campaign map; not part of this file).

## 5. Pacing chart

```text
strangeness (how far from classic)
 high |             #  #     #     #  #
      |          #  #  #     #  #  #  #
  mid |    #  #  #  #  #  #  #  #  #  #
      |    #  #  #  #  #  #  #  #  #  #
  low |  # #  #  #  #  #  #  #  #  #  #
      +-01-02-03-04-05-06-07-08-09-10--B
        warm  floor  geyser  build/ smoke quake belt  FINALE
        up    rises  pops    paint  hush  rumble slide
```

Zig-zag, not a ramp: a warm classic opener → a pocket puzzle-lite (new rule) → the first real pressure (lava rises) → a pop level → a no-fail pair (05 tower, 06 painting; no top-out) → a hushed memory level (07) → the short sprint (08) → the remix (09) → the three-phase finale. Short and long alternate; no two pressure peaks in a row before the finale (03 rises, 04 pops, then two calm builds).

---

## 6. Level specs (encounter lists, sketches, beats)

Every level lists: story card, stage, light, music, skits (I intro, P payoff, M Mizzle clue, R reaction), recipe, encounters, sketch, how it plays, readability notes, level JSON sketch, how it teaches, wacky test. JSON sketches show only fields that differ from defaults; rule ids are the atom ids pending the rule JSON of ADR-0011 (sketch). Clue density follows brief rule 7: at most one clue per level, at most 1.5 s, never over the grid, never during a warning.

### 01 Warm Start

**Story card.** Cinder wants to roast a marshmallow, and the campfire is a sulky little flame. Every clear stokes it with a log. · **Cinder: watcher** (huffs sparks to relight the fire).
**Stage**: clean, calm; a campfire ledge, a steam pool below. **Light**: red dusk. **Music**: `lava_01` (placeholder; warm, unhurried, a low rumble underneath).
**I**: Cinder holds a marshmallow on a stick over a puny flame; it sputters out; Cinder huffs sparks at it, looks up, glint. **P**: the fire roars; the marshmallow swells, browns, blackens into a perfect charcoal puck; Cinder stares at it (`angry`, huffs a single spark). **M**: none. **R**: `sparkle` on each clear; `sweat` on a warning (sparks shrink).

```text
Recipe: BL01 (5×5, H8) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · SE05 duck
Atoms used: all defaults. New to the player: none.
One sentence: "Fill a whole layer and it clears."
```
**Encounters**: none (pure classic with ember drift in the backdrop). Pieces I, O, T, L, S; `opening_set` [O, I], count 2. `T_level` 200.

```text
top-down 5×5     side (z = 2)
#####            11 . . S . .   spawn zone
#####             8 ==========  danger line
##S##              :
#####              0 . . . . .  the campfire ledge
#####
```
**Control**: Turn / Flip / Roll all enabled (taught in the Meadow; no tutorial overlay). **Goal / fail**: clear 3 layers; rescue with 1 warning. **Stars**: 170 / 120 s. **Length**: short, ~3.3 min.
**Readability**: obsidian blocks (glossy dark) against a glowing floor seam; the danger line is a pale ash-grey rule (not red) so lava glow never reads as danger.
**JSON sketch**:
```json
{"schema":1,"id":"lava_01","biome":"lava","tier":1,"name":"level.lava_01.name",
 "board":{"width":5,"depth":5,"h_play":8},
 "pieces":{"shapes":["i","o","t","l","s"],"opening_set":["o","i"],"opening_count":2},
 "knobs":{"fall.g0":0.85},"goal":{"type":"clear_n","N":3},
 "recipe":[{"slot":"se","atom":"SE05"}],"stars":{"t2":170000,"t3":120000},
 "music":"lava_01","story":{"mascot_role":"watcher","icon":"campfire"}}
```
**How it teaches**: a Meadow-fluent player re-enters the controls in a new skin and sees the "warm ground" quirk as pure look. The duck gives a reason to orbit the camera (the one real input check in this level).
**Wacky test**: surprising, the island is a volcano and nothing happens; silly, the charcoal puck; funny failure, the fire pouts out and Cinder shivers; big moment, the fire roaring on the 3rd clear.

---

### 02 Ember Pockets ★PROTO

**Story card.** Three glowing holes in the ledge are sealed under lids of crust. An ember piece melts a lid and drops in to cool the hole. · **Cinder: watcher** (peers into the holes, cheers a cooled one).
**Stage**: clean, calm; a ledge with cut-away holes and warm steam. **Light**: red dusk. **Music**: `lava_02` (placeholder; curious, glowing, a light pluck).
**I**: Cinder drops a pebble into a hole; the pebble glows, pops back out, lands in a lid-shaped plate. **P**: the last hole cools to dark glass; a sprout of steam rises; Cinder warms its paws on it (`heart`). **M**: none. **R**: `exclaim` when an ember piece melts a lid; `sparkle` when a hole is filled.

```text
Recipe: BL05 (5×5, H10, 2 starter layers) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · SP40 Ember drill (ember_per_bag 1, drill_depth 1) · SE05 duck
Atoms used: BL05 (Meadow), SP40 (NEW, Proposed)
One sentence: "The glowing piece melts what is below it."
```
**Encounters**: layer 0 is full except three single-cell holes; layer 1 has only the three **lids** sitting over those holes, so no ordinary piece can reach a hole. An ember piece (one per bag) standing on end melts the lid (and falls into the hole); **or** the player fills layer 1 (the 22 other cells) and clears it, which removes the lids. Two routes, one slow, one clever. Pieces I, O, T, L, S, Duo, Tripod; `opening_set` [I, I], count 2 (the first ember arrives early, see below). Ember cubes sit on an end cube so a standing piece drills.

```text
layer 0      layer 1 (L = lid)   side (z = 1)
#####        .....               10 ==========
#.###        .L...                :
###.#        ...L.                1  . L . . .   lid over the hole (x1)
##.##        ..L..                0  # . # # #   the hole is 1 deep
#####        .....
```
**How it plays**: (1) the first bag guarantees an ember piece by lock 3 (bag seeded so the ember sits on an I). (2) The ghost glows where the lid will melt; the player stands the piece on end (Flip) and drops it into the hole. (3) The second and third holes fill the same way, or the player builds layer 1 out and clears it. (4) Layer 0 clears (a double with layer 1 if both are full), then one free clear on the open board.
**Control**: Turn / Flip / Roll. **Goal / fail**: clear 3; rescue 1. **Stars**: hand-set 150 / 105 s (starter layers make F1 overestimate). **Length**: short, ~2.5 min.
**Readability**: ember cube glows from inside (colour blind safe: it is also a distinct stripe pattern); lids carry a faint crack decal; the ghost shows the melt cells as an orange outline with a down-arrow. An ember on a non-lid cell just melts one floor cube and the piece drops into it, a net-zero cube count, so a mistake costs nothing.
**JSON sketch**:
```json
{"schema":1,"id":"lava_02","biome":"lava","tier":2,"name":"level.lava_02.name",
 "board":{"width":5,"depth":5,"h_play":10,
  "starting_contents":{"layers":{"0":["#####","#.###","###.#","##.##","#####"],
                                  "1":[".....",".L...","...L.","..L..","....."]}}},
 "pieces":{"shapes":["i","o","t","l","s","duo","tripod"],"opening_set":["i","i"],"opening_count":2},
 "knobs":{"fall.g0":0.9,"goal.warnings_max":1},"goal":{"type":"clear_n","N":3},
 "rules":[{"id":"SP40","params":{"ember_per_bag":1,"drill_depth":1}}],
 "recipe":[{"slot":"se","atom":"SE05"}],"stars":{"t2":150000,"t3":105000},
 "music":"lava_02","story":{"mascot_role":"watcher","icon":"ember_hole"}}
```
**How it teaches**: one rule, shown, not told: the only way to reach a lidded hole in a hurry is the glowing piece, and the ghost previews exactly what it melts. The slow route (clear layer 1) means a player who ignores it is never stuck.
**Wacky test**: surprising, a piece that melts; silly, the lids pop like bottle caps; funny failure, an ember melts a floor cube and plugs it again, Cinder blinks; big moment, the double clear with steam clouds.

---

### 03 Lava Lane ★PROTO

**Story card.** The lava floor creeps up a narrow lane. Keep your layers clearing so the lava has nothing to eat. · **Cinder: watcher** (hops from stone to stone on the rim, fanning herself).
**Stage**: busy; a narrow strip over a glowing river, geyser puffs in the backdrop. **Light**: red dusk. **Music**: `lava_03` (placeholder; a steady, lightly urgent pulse).
**I**: Cinder sets a marshmallow stick on a ledge; the lava level bubbles up and the stick floats away; Cinder runs after it. **P**: the lava cools to a glossy obsidian road; Cinder slides along it on her belly. **M**: a trail of violet ribbon scraps along the ash path (backdrop, 1.5 s). **R**: `exclaim` on each melt warning; `sweat` when the bottom layer is lost.

```text
Recipe: BL06 Strip (8×3, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV06 Rising Lava
Atoms used: BL06 (NEW), EV06 (NEW)
One sentence: "The lava rises: clear your low layers before it eats them."
```
**Encounters**: **Rising Lava**: `melt_every_s` 35 (20–60), first rise at 40 s, `melt_max` 3, `melt_warn_ms` 3 000. After the third rise the lava cools to obsidian. Headroom goes 10 → 7. A nearly full bottom layer is the thing at stake: clear it and the lava eats an empty row. Pieces 8 Standard; cliffs at both ends of the lane (x = 0 and x = 7) are walls, not drops.

```text
top-down 8×3 (lane)      side (z = 1), 3 stages
########                  t = 0       t = 40 s     t = 110 s (cooled)
###S####                  10 ======   10 ======    10 ======
########                   :           :            :
                           1 . . . .   1 . . . .    1 # # # #  (old layer 1 is the floor)
                           0 # # # #   0 ~ ~ ~ ~    0 ~ ~ ~ ~  lava layers (inactive)
```
**How it plays**: (1) calm first 40 s: the ember drizzle falls, a ribbon of steam on the lane edge. (2) The melt warning: the near layer bubbles and a rumble sounds; the lowest layer vanishes in a sizzle (the player has hopefully cleared it). (3) Clears are now the pressure valve; the lane's width of 3 makes layers fill fast. (4) The third rise cools the lane to glossy obsidian; four clears to go.
**Control**: Turn / Flip / Roll. **Goal / fail**: clear 4; rescue 1 (headroom shrinks, so warnings are real). **Stars**: F1, 215 / 155 s (N = 4, A = 24, `t_est` 256). **Length**: ~4.3 min.
**Readability**: lava surface is a calm warm orange-red band *below* the board with a pale rim; the melting layer gets a pulsing hatch pattern 3 s ahead so it is not colour-only; the danger line stays grey.
**JSON sketch**:
```json
{"schema":1,"id":"lava_03","biome":"lava","tier":3,"name":"level.lava_03.name",
 "layout":{"kind":"single"},"recipe":[{"slot":"board","atom":"BL06"}],
 "board":{"width":8,"depth":3,"h_play":10,"spawn_anchor":{"x":3,"z":1}},
 "pieces":{"shapes":["i","o","t","l","s","tripod","duo","tri_corner"]},
 "knobs":{"fall.g0":0.95},"goal":{"type":"clear_n","N":4},
 "rules":[{"id":"EV06","params":{"melt_every_s":35,"first_s":40,"melt_max":3,"melt_warn_ms":3000}}],
 "stars":{"t2":215000,"t3":155000},"music":"lava_03",
 "story":{"mascot_role":"watcher","icon":"lava_lane"}}
```
**How it teaches**: pressure that *clears relieve*: the new rule is a clock with a visible, readable meaning. A cooled lane at the end lets the player see the ending state (obsidian road = the biome's safe floor).
**Wacky test**: surprising, the floor shrinks upward; silly, the stick floating off like a canoe; funny failure, a lost bottom layer sizzles away and Cinder grabs her tail; big moment, the lane cooling to glass on the third rise.

---

### 04 Geyser Pop

**Story card.** Geysers burst through the ledge and launch vent pads onto the stack; a piece landing on one gets popped one cell along. Plan the pop, don't fight it. · **Cinder: watcher** (rides a puff of steam and lands in a pool).
**Stage**: busy; a steaming flat with geyser stones, rock-toads burping steam. **Light**: ash-haze dusk. **Music**: `lava_04` (placeholder; bouncy, pizzicato, a burp on the off-beat).
**I**: a stone vent hisses; Cinder peers into it and is launched out, spinning, onto a rock. **P**: the geysers fall into a neat row of fountains; Cinder bounces from one to the next like stepping stones. **M**: the mail-cloud (tiny, violet, satchel bulging) struggles past the ridge (backdrop, 1.5 s), `sweat`. **R**: `exclaim` when a vent hisses; `dizzy` after a pop.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV04 Geyser Pop · SP35 vent pad
Atoms used: EV04 (Meadow), SP35 (NEW)
One sentence: "A hissing vent pops your piece one cell onward."
```
**Encounters**: a vent object every 5 locks (max 3), marked by a steam puff one lock ahead; vents clear with their layer. SP35 `bounce_h` 1; the relock cell is one cell onward in the piece's last horizontal move direction (no move = no push). Pieces 8 Standard.

```text
top-down 6×6        side (z = 3)
######              13 . . . . . .
######              10 ============
##S###               :
######               1  # v # # . #   v = vent pad
######               0  # # # # # #
######
```
**How it plays**: (1) pieces fall straight; the first vent hisses and a pad appears. (2) The player steers a piece onto the pad: it hops up one and slides one cell onward, landing in a gap the player could not reach. (3) Later the player *avoids* a pad that would shove a piece into a bad spot. (4) Fourth ring clears with a fountain.
**Control**: Turn / Flip / Roll. **Goal / fail**: clear 4; rescue 1. **Stars**: F1, 325 / 230 s. **Length**: ~6.4 min (long; follows two short levels).
**Readability**: pad is a sandy cap with a white steam plume and a one-cell arrow in the push direction; the ghost shows the post-pop cell.
**JSON sketch**:
```json
{"schema":1,"id":"lava_04","biome":"lava","tier":4,"name":"level.lava_04.name",
 "board":{"width":6,"depth":6,"h_play":10},
 "pieces":{"shapes":["i","o","t","l","s","tripod","duo","tri_corner"]},
 "knobs":{"fall.g0":1.0},"goal":{"type":"clear_n","N":4},
 "rules":[{"id":"EV04","params":{"every_locks":5,"objects_max":3,"object":"SP35"}},
          {"id":"SP35","params":{"bounce_h":1}}],
 "stars":{"t2":325000,"t3":230000},"music":"lava_04",
 "story":{"mascot_role":"watcher","icon":"geyser"}}
```
**How it teaches**: the spawn is predictable (sparkle one lock ahead, as in the Meadow's mushrooms), so a player who learned that can now read a more active object. The rule is a verb, not a threat.
**Wacky test**: surprising, your piece hops; silly, rock-toads burp in time; funny failure, a pop shoves the piece into the one bad cell and Cinder sulks; big moment, a double pop landing a perfect fit.

---

### 05 Obsidian Tower

**Story card.** Cinder wants a lookout to see where the roast-worthy things are. Build to the sign; obsidian is brittle, so overhangs snap off. · **Cinder: watcher** (fans herself on the top as it grows).
**Stage**: clean, tense; a bare obsidian terrace and lots of smoky sky. **Light**: ash-haze dusk. **Music**: `lava_05` (placeholder; spacious, a held tone, no danger drum because trim cannot lose).
**I**: Cinder tries to climb a crumbling pillar and slides down; she draws a taller tower in the ash. **P**: Cinder reaches the top; the whole terrace lights; far off, a droopy hat behind a basalt column draws a lopsided cube in the air and it falls (see M). **M**: a droopy hat peeks from behind a basalt column; the wand doodles a lopsided cube, which falls (`sweat`) (payoff, 1.5 s). **R**: `note` on each layer; `sweat` when a snap-off plops.

```text
Recipe: BL01 (5×5, H12) · AR01 · CV01 · GO02 (H 10, coverage 0.6) + FT02 trim + CL14 [M1 build race] · PL02 Overhang trim
Atoms used: M1 (Meadow), PL02 (NEW)
One sentence: "Build up to the sign; overhangs snap off."
```
**Encounters**: Overhang trim: a cube locked with an empty cell directly below it snaps off with a "tink" and drops into the lava (a gentle, readable cost). The landing ghost shows snap-off cubes as dotted red-edged cubes. Trim: cubes at or above layer 12 pop off; the level never fails. Pieces 8 Standard + Big Cube (w 0.5).

```text
top-down 5×5   side (z = 2)
#####          15 . . S . .   spawn zone
#####          12 ===========  danger line (trim)
##S##           9 - - - - -   sign: layer 9 must be ≥ 60% full (15 of 25)
#####           :
#####           0 . . . . .
```
**How it plays**: (1) full layers glow and stay; (2) a piece that leaves a gap under part of itself loses those cubes (the ghost warns); (3) a Big Cube adds two layers at once but must land flat; (4) layer 9 reaches 15 cubes; Cinder scrambles up.
**Control**: Turn / Flip / Roll. **Goal / fail**: Height 10, coverage 0.6; never fails (trim). **Stars**: F1, 240 / 170 s; ★★★ also requires no cube trimmed above the limit (a PL02 snap-off is not a trim, see §10). **Length**: ~4.7 min.
**Readability**: the sign is a wooden plank on a stick (the Meadow sign reused as a graphic echo); height ruler on the island rim.
**JSON sketch**:
```json
{"schema":1,"id":"lava_05","biome":"lava","tier":5,"name":"level.lava_05.name",
 "board":{"width":5,"depth":5,"h_play":12},
 "pieces":{"shapes":["i","o","t","l","s","tripod","screw_l","big_cube"],"weights":{"big_cube":0.5}},
 "knobs":{"fall.g0":1.0,"goal.top_out":"trim"},
 "goal":{"type":"height","H_target":10,"coverage":0.6},
 "rules":[{"id":"PL02","params":{}}],
 "recipe":[{"slot":"goal","atom":"GO02"},{"slot":"clear","atom":"CL14"},{"slot":"fail","atom":"FT02"}],
 "stars":{"t2":240000,"t3":170000},"music":"lava_05",
 "story":{"mascot_role":"watcher","icon":"tower"}}
```
**How it teaches**: stacking discipline without a fail state. The player learns "fill under overhangs" before the finale demands it.
**Wacky test**: surprising, cubes snap off; silly, the "tink"; funny failure, cubes float off like popcorn into the lava; big moment, Cinder fanning herself on the top.

---

### 06 Marshmallow Roast

**Story card.** Two marshmallow sticks are the picture. Fill the shape and the marshmallows brown; cubes outside the outline just fade. · **Cinder: watcher** (hovers a stick over each filled row).
**Stage**: clean, calm; a roast ledge with two glowing sticks drawn in the ash. **Light**: early night ember. **Music**: `lava_06` (placeholder; cosy, warm, a soft clap).
**I**: Cinder tries to roast a marshmallow; it falls into the crust (a slice of the arrival gag) and she draws two sticks in the ash. **P**: both marshmallows brown perfectly; Cinder takes a bite and the whole thing is charcoal (`angry`, a sad puff). **M**: Smolder's box in the far crater shows a star stamp; a violet cuff peeks to check it arrived (`dots`, 1.5 s, backdrop). **R**: `sparkle` as each row browns; `sweat` on a fade.

```text
Recipe: BL01 (8×6, H8) · AR01 · CV01 · GO03 (52 cells) + FT02 trim + CL14 [M2 fill shape] · PL07 Inside the outline
Atoms used: M2 (Meadow), PL07 (NEW)
One sentence: "Cover the marshmallow picture."
```
**Encounters**: PL07: cubes locked outside the target cells fade out with a puff (no penalty, no use, not counted as a trim). Pieces I, O, T, L, S, Tripod, Duo, Tri-Corner. Targets: two skewers, each a 2-cell stick plus a 6×2×2 marshmallow block.

```text
layer 0 (28)    layer 1 (24)    side (z = 1)
........        ........         8 ================  danger line (trim)
++++++++        ..++++++          :
..++++++        ..++++++          1 . . + + + + + +
........        ........          0 + + + + + + + +   stick x0–1, marshmallow x2–7
++++++++        ..++++++
..++++++        ..++++++
```
**How it plays**: (1) outlines glow; the first piece browns four cells. (2) Duo and Tri-Corner fit the stick ends. (3) The player keeps layer 0 flat so layer 1 has support. (4) The last cell fills; both marshmallows puff up, golden.
**Control**: Turn / Flip / Roll. **Goal / fail**: cover 52 cells; never fails (trim; a lost cube is rare). **Stars**: shape estimate (3.64 s per target cell, 189 s): 160 / 115 s; ★★★ also requires no cube trimmed (faded cubes do not count). **Length**: short, ~3.2 min.
**Readability**: target cells are a soft ember-outline; faded cubes show a dotted ghost for 0.5 s so the player sees what faded.
**JSON sketch**:
```json
{"schema":1,"id":"lava_06","biome":"lava","tier":6,"name":"level.lava_06.name",
 "board":{"width":8,"depth":6,"h_play":8},
 "pieces":{"shapes":["i","o","t","l","s","tripod","duo","tri_corner"]},
 "knobs":{"fall.g0":1.05,"goal.top_out":"trim"},
 "goal":{"type":"fill_shape","target_shape":{"layers":{
   "0":["........","++++++++","..++++++","........","++++++++","..++++++"],
   "1":["........","..++++++","..++++++","........","..++++++","..++++++"]}}},
 "rules":[{"id":"PL07","params":{}}],
 "recipe":[{"slot":"goal","atom":"GO03"},{"slot":"clear","atom":"CL14"},{"slot":"fail","atom":"FT02"}],
 "stars":{"t2":160000,"t3":115000},"music":"lava_06",
 "story":{"mascot_role":"watcher","icon":"marshmallow"}}
```
**How it teaches**: a painting level, a breather. PL07 forgives stray cubes so players learn to read an outline instead of brute-forcing.
**Wacky test**: surprising, painting, not clearing; silly, marshmallows puffing; funny failure, faded cubes pop like bubbles and Cinder pokes at them; big moment, both sticks browning at once.

---

### 07 Smoke Screen

**Story card.** The crater coughs ash over the stack after every few clears. The embers still show you the way. · **Cinder: watcher** (waves smoke away, coughs).
**Stage**: busy but hushed; ash slope, smoke columns, a sleepy rock-toad. **Light**: early night ember with a smoke overlay. **Music**: `lava_07` (placeholder; low and muffled, a distant rumble, sparse).
**I**: the crater coughs a gray cloud; the whole stack disappears; Cinder pats the air where it was. **P**: the last clear blows the smoke away in one puff; Cinder was holding the marshmallow all along, still pink. **M**: ★ Mizzle walks away along the ridge under a towering stack of parcels (backdrop, 1.5 s, no bubble). **R**: `question` when the stack fades; `sparkle` on a reveal.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · EV02 Smoke Screen · SP40 Ember drill (callback)
Atoms used: EV02 (Meadow), SP40 (met in 02). New to the player: none.
One sentence: "Your stack fades; the glowing piece shows what it melts."
```
**Encounters**: Smoke: visible 3.5 s, fade 1 s, alpha 0.1, reveal 0.8 s on each clear (the Meadow's 5 s is shortened for the Lava). Ember drill: `ember_per_bag` 1, `drill_depth` 1. The ember's landing ghost shows the cubes it would melt even through smoke, so an ember piece is also a *probe*: it tells the player what is below.

```text
top-down 6×6     side (z = 2)
######           13 . . S . . .
######           10 ============
##S###            :
######            1  # # . # . .   fades after 3.5 s
######            0  # # . # # #
######
```
**How it plays**: (1) the first piece lands and the smoke rolls in; (2) the player builds from memory, using the landing ghost; (3) an ember piece's melt outline reveals one cell of the hidden stack; (4) each clear pushes the smoke back for a moment.
**Control**: Turn / Flip / Roll. **Goal / fail**: clear 3; rescue 1. **Stars**: F1, 245 / 175 s. **Length**: ~4.8 min.
**Readability**: faded cubes keep a faint outline at alpha 0.1; the smoke is soft grey-violet, not black, and the surrounding backdrop dims slightly; no strobe.
**JSON sketch**:
```json
{"schema":1,"id":"lava_07","biome":"lava","tier":7,"name":"level.lava_07.name",
 "board":{"width":6,"depth":6,"h_play":10},
 "pieces":{"shapes":["i","o","t","l","s","tripod","duo","tri_corner"]},
 "knobs":{"fall.g0":1.1},"goal":{"type":"clear_n","N":3},
 "rules":[{"id":"EV02","params":{"visible_ms":3500,"fade_ms":1000,"alpha":0.1,"reveal_ms":800}},
          {"id":"SP40","params":{"ember_per_bag":1,"drill_depth":1}}],
 "stars":{"t2":245000,"t3":175000},"music":"lava_07",
 "story":{"mascot_role":"watcher","icon":"smoke"}}
```
**How it teaches**: memory under pressure, with a forgiving tool (the ember probe) that only a player who learned it in 02 can use.
**Wacky test**: surprising, the stack vanishes; silly, Cinder's tail sticking out of the smoke; funny failure, a piece lands "on nothing" that was something; big moment, the smoke blown off in one puff.

---

### 08 Eruption ★PROTO

**Story card.** The volcano rumbles; floating chunks of the stack plop off into the lava. Hold on for 2:30 until the sun-dial fills. · **Cinder: watcher** (hangs on to a rock, chattering).
**Stage**: busy, tense; the rumbling eruption terrace, ember hail in the backdrop. **Light**: early night ember → eruption night. **Music**: `lava_08` (placeholder; driving, a low pulse that quickens, then a hush on each rumble warning).
**I**: a distant rumble; Cinder's marshmallow shudders on its stick; a pebble bounces. **P**: the last rumble fades; the terrace falls still; **the Miller at the rim takes flag 5, waves it, taps the leaf card and the star card in his pocket and points at the wizard** (Rosetta, 1.5 s: 0.0–0.5 flag wave, 0.5–1.0 pocket tap, 1.0–1.5 point; Miller `exclaim`; the wizard does not respond). **M**: ★ the Rosetta above (the strongest clue so far). **R**: `exclaim` on each rumble warning; `sweat` on a plop.

```text
Recipe: BL01 (5×5, H10) · AR01 · CV01 · GO04 (150 s, ramp_per_min 0.15) · FT01 (1) · CL01 + CO01 · EV12 Eruption Rumble
Atoms used: GO04 (Meadow), EV12 (NEW)
One sentence: "The ground shakes; floating cubes plop off."
```
**Encounters**: Rumble: `quake_every_s` 30 (15–60), first rumble at 25 s, `quake_warn_ms` 2 000, `quake_max_cubes` 6. Cubes with an empty cell directly below them plop off. Telegraph: a steady rumble, ember rain from above and a pulsing rim; reduced motion: no camera shake, ember puffs only.

```text
top-down 5×5   side (z = 2)
#####          13 . . S . .   spawn zone
#####          10 ===========  danger line
##S##           :
#####           0 . . . . .   rumbling terrace
#####
```
**How it plays**: (1) 25 s of calm; (2) the first rumble plops off the roof of a covered hole; (3) the player builds tight (no overhangs, no holes under cubes); (4) speed creeps up each minute; (5) the sun-dial fills at 2:30.
**Control**: Turn / Flip / Roll. **Goal / fail**: Survive 150 s; rescue 1. **Stars** (Survive, Scoring F4): ★★ 1 layer cleared, ★★★ 2 layers with no warning (equal to the Meadow's 5×5; revisit if playtests find it easy at speed 1.15). **Length**: 2.5 min.
**Readability**: a plopping cube takes a 0.5 s hop before it falls so the player sees it; the next rumble's countdown ring is on the HUD rim. The Rosetta is placed in the payoff only, never during a rumble (rule 9).
**JSON sketch**:
```json
{"schema":1,"id":"lava_08","biome":"lava","tier":8,"name":"level.lava_08.name",
 "board":{"width":5,"depth":5,"h_play":10},
 "pieces":{"shapes":["i","o","t","l","s","tripod","duo","tri_corner"]},
 "knobs":{"fall.g0":1.15,"fall.ramp_per_min":0.15},"goal":{"type":"survive","T":150},
 "rules":[{"id":"EV12","params":{"quake_every_s":30,"first_s":25,"quake_warn_ms":2000,"quake_max_cubes":6}}],
 "stars":{"s2":1,"s3":2},"music":"lava_08",
 "story":{"mascot_role":"watcher","icon":"eruption","clue":"rosetta"}}
```
**How it teaches**: tidy stacks. The only way to lose a cube is to leave a hole under one.
**Wacky test**: surprising, the ground shakes cubes loose; silly, Cinder rattling like a maraca; funny failure, your roof plops into the lava with a bloop; big moment, the Rosetta at the end.

---

### 09 Magma Flow

**Story card.** The shelf slides sideways on a belt of magma while the lava rises and the geysers pop. The remix: use everything you know. · **Cinder: watcher** (rides a floating stone on the belt).
**Stage**: busy; a magma-flow shelf with a visible belt, the lava edge, vents. **Light**: crater night. **Music**: `lava_09` (placeholder; rolling, bass-forward, a deliberate off-beat).
**I**: a stone vent kicks a rock onto a slow orange river; the river carries it off with Cinder on top. **P**: the belt slows, stops; the shelf glows cool; Cinder hops off and stretches. **M**: Mizzle on the far ridge sees the Miller pointing; pushes his glasses up, hurries on (`blush`, backdrop, 1.5 s). **R**: `exclaim` on each shift; `dizzy` on a double hazard.

```text
Recipe: BL01 (8×6, H12) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · EV05 Magma Belt [mechanic] · EV06 Rising Lava · EV04 + SP19 Geyser Pop (ember rocks)
Atoms used: EV05, EV06, EV04, SP19 (all met before). New to the player: none (remix).
One sentence: "Everything moves: the belt, the lava, the rocks."
```
**Encounters**: Magma Belt (Conveyor): +x, every 3 locks, wrap on (unmasked rectangle; Conveyor forbids masks). Rising Lava: `melt_every_s` 60, first 50 s, `melt_max` 2. Geyser Pop: a rock object every 8 locks, `objects_max` 2. Telegraphs are staggered by 1 s (Readable Chaos).

```text
top-down 8×6 (belt → along x)    side (z = 3)
→ → → → → → → →                 15 . . . S S . . .
########                        12 ================
########                         :
###S####                         1  # # . . # # . #
########                         0  # # # . # # # #   → shift +x, wrap
########
########
```
**How it plays**: (1) the first lock; after the third the stack slides one cell and wraps. (2) The lava warns and takes the bottom layer. (3) A rock object pops on the top; the belt carries it. (4) Third clear: the belt stops and cools.
**Control**: Turn / Flip / Roll. **Goal / fail**: clear 3; rescue 1. **Stars**: F1, 325 / 230 s. **Length**: ~6.4 min.
**Readability**: belt arrows on the rim only (not on the floor); lava and belt telegraphs use different cue types (hatch + sound vs arrow + shuffle); no more than one telegraph on screen at a time.
**JSON sketch**:
```json
{"schema":1,"id":"lava_09","biome":"lava","tier":9,"name":"level.lava_09.name",
 "board":{"width":8,"depth":6,"h_play":12},
 "pieces":{"shapes":["i","o","t","l","s","tripod","duo","tri_corner"]},
 "knobs":{"fall.g0":1.2},"goal":{"type":"clear_n","N":3},
 "rules":[{"id":"EV05","params":{"dir":[1,0,0],"every_locks":3,"wrap":true}},
          {"id":"EV06","params":{"melt_every_s":60,"first_s":50,"melt_max":2}},
          {"id":"EV04","params":{"every_locks":8,"objects_max":2,"object":"SP19"}}],
 "stars":{"t2":325000,"t3":230000},"music":"lava_09",
 "story":{"mascot_role":"watcher","icon":"magma_belt"}}
```
**How it teaches**: reading three small clocks at once (a good test before the finale), each familiar from earlier.
**Wacky test**: surprising, the floor is a river; silly, Cinder surfing a stone; funny failure, a rock rides straight into the gap you were saving; big moment, the third clear freezing the river.

---

### 10 Smolder's Spa ★PROTO (boss: Smolder)

**Story card.** Smolder won't take the bath he wants. Phase 1: he kicks bath-bomb geysers. Phase 2: he stomps the crater (rumbles). Phase 3: he puffs smoke. The last clear launches the box into the crater pool with him in it. · **Boss**: Smolder; Cinder cheers from the rim (watcher).
**Stage**: busiest; the crater rim with Smolder's nest, an empty eggshell, a half-built bathtub. **Light**: crater night → steam moonlight. **Music**: `lava_10` (placeholder; big, a swaggering beat, a key change on each phase, a bubbling resolve).
**I**: Smolder kicks a bath bomb into the lava; it fizzes pink foam; he puffs smoke over the board edge, arms crossed (`smug`); Cinder huffs sparks, glint. **P** (6 s on first play): the last clear: a geyser launches the whole bath-bomb box into the crater pool with Smolder; foam everywhere; he sputters, bubbles on his horns (`angry`); he sinks to the chin, catches the camera looking, sits up stiffly (`gloom`); keepsake pop: the ember; Cinder grins; **flag 5 hung over the rim as a towel**; Cinder points at her sunken marshmallow and sulks. **Friend join** (4 s): Boulder trots in, cracks the crust, pats the extra crack shut, the marshmallow bobs up toasted, Cinder eats it (`heart`); she holds the mallet up to the wizard; unlock card. **M**: the flag-5 towel (payoff). **R**: Smolder `smug` when you use a warning; `angry` on each clear; Cinder `note` on a clear.

```text
Recipe: BL01 (7×7, H12) · AR01 · CV01 · GO01 (3 = 3 dunks) · FT01 (1) · CL01 + CO01 · EV04 + SP19 Geyser Pop · EV12 Eruption Rumble · EV02 Smoke Screen
Atoms used: EV04, SP19, EV12, EV02 (all met before). New to the player: none (showpiece cap 6).
One sentence: "Geysers, then rumbles, then smoke, until the bath."
```
**Encounters**: three phases, each a wind-up by Smolder (cheeks puff and wings flare, then a small smoke ring, then the effect):
- **Phase 1 (0 clears)**: Geyser Pop, a bath-bomb rock every 6 locks (max 3), kicked by Smolder, 1-lock steam telegraph.
- **Phase 2 (after clear 1)**: + Eruption Rumble, `quake_every_s` 40, `quake_max_cubes` 6, 2 s warning (he stomps).
- **Phase 3 (after clear 2)**: + Smoke Screen (visible 4.5 s, fade 1 s, alpha 0.1, reveal 0.8 s), puffed from his nostrils; geysers keep going, rumbles keep going.
- **Phase gating (decision)**: each rule starts at its phase via a generic activation gate `active_after_clears` (§10). **Fallback with no new atom**: stagger with the existing first-trigger delay (`first_s` for EV12, EV02 `start_ms`), as the Meadow did with `flip_every_ms` 180 000.
- Smolder is the face of the rules: he cheers (`smug`) when you use a warning and sulks (`angry`) on each clear. The third clear dunks him.

```text
top-down 7×7                      side (z = 3)
#######                          15 . . . S . . .   spawn zone
#######                          12 ==============  danger line
#######                           :
###S###                           1  # # . # # . #
#######                           0  # # # # # # #
#######
#######
phase 1: geysers, phase 2: + rumble, phase 3: + smoke
```
**How it plays**: (1) after a calm first piece, the first bath bomb pops; (2) one clear later, the crater rumbles and floating cubes plop off; (3) another clear later, smoke puffs over the stack; (4) the third clear: the geyser launches the box.
**Control**: Turn / Flip / Roll. **Goal / fail**: clear 3; rescue 1. **Stars**: F1, 335 / 235 s. **Length**: ~6.5 min. **Skill**: Smash is not yet unlocked here (Boulder joins in the payoff).
**Readability**: at most one telegraph active at any moment (staggered 1.5 s); smoke is the softest cue and always last; the countdown rings for rumbles and smoke sit on the HUD rim.
**JSON sketch**:
```json
{"schema":1,"id":"lava_10","biome":"lava","tier":10,"name":"level.lava_10.name",
 "board":{"width":7,"depth":7,"h_play":12},
 "pieces":{"shapes":["i","o","t","l","tripod","screw_l","screw_r","chair"]},
 "knobs":{"fall.g0":1.25},"goal":{"type":"clear_n","N":3},
 "rules":[{"id":"EV04","params":{"every_locks":6,"objects_max":3,"object":"SP19"}},
          {"id":"EV12","params":{"quake_every_s":40,"active_after_clears":1,"quake_warn_ms":2000,"quake_max_cubes":6}},
          {"id":"EV02","params":{"visible_ms":4500,"fade_ms":1000,"alpha":0.1,"reveal_ms":800,"active_after_clears":2}}],
 "stars":{"t2":335000,"t3":235000},"music":"lava_10",
 "story":{"mascot_role":"watcher","icon":"spa","boss":"smolder","friend_join":"boulder"}}
```
**How it teaches**: the finale rehearses the biome in a straight line: pop, shake, hide. A player who got 07 and 08 recognises everything.
**Wacky test**: surprising, three rules arrive one by one; silly, Smolder's wind-up cheek puff; funny failure, he smirks when you use a warning; big moment, the geyser launching the whole box and the dunk.

---

### B Forge Puzzle (bonus, tier 11, 20 lava stars)

**Story card.** Cinder's forge needs an anvil. Seven pieces, no spares: fit them into the anvil shape. · **Cinder: watcher** (hammers each placement, then holds a new marshmallow to the forge door).
**Stage**: clean, hurried; Cinder's little forge with an anvil and a glowing door. **Light**: forge glow. **Music**: `lava_bonus` (placeholder; ringing hammer rhythm, warm).
**I**: Cinder drags an empty anvil base onto the forge floor and stares at the gap. **P**: the last ingot fits; the forge glows; Cinder holds a new marshmallow stick to the door; it chars instantly (`dizzy`); she eats it anyway (`note`). **M**: none in-level (Postcard 5 is the Scrapbook: he sits at the head of the set table, chin on hands; the candles burn down; `dots`). **R**: `note` per hammer hit; `sweat` on a wrong fit.

```text
Recipe: BL01 (8×2, H6) · AR09 fixed list [Big Cube, Duo, Duo, I, I, I, I] · CV01 · GO03 (28 cells) + CL14 [M2] · FT07 out of pieces
Atoms used: AR09, M2, FT07 (all Meadow).
One sentence: "Seven pieces, no spares: build the anvil."
```
**Encounters**: preview 3; the target is the anvil: feet and waist on layers 0–1, a long horn on layer 2. Known solution: Big Cube at x3–4 (z0–1, layers 0–1); the two Duos lie along z at x2 and x5 (layer 0); the four I pieces lie along x on layer 2, two per z row (x0–3 and x4–7), each resting on the waist. Dealt in list order every placement is supported. A misplaced piece means out of pieces; retry is instant. Stars: ★ finish; ★★ 100 s; ★★★ 60 s.

```text
layer 2 (16)    layer 1 (4)    layer 0 (8)    side (z = 0)
++++++++        ........       ..++++..        8 . S S . . . . .
++++++++        ...++...       ..++++..        6 ================
                ...++...                        :
                                                2 + + + + + + + +   horn (layer 2)
                                                1 . . . + + . . .   waist
                                                0 . . + + + + . .   feet + waist
```
**How it plays**: (1) read the preview (Big Cube, Duo, Duo) and plan; (2) the Big Cube is the waist, the Duos the feet; (3) the four I's lie on top; (4) the last I closes the horn and the forge glows. 
**Control**: Turn / Flip / Roll. **Goal / fail**: fill 28 target cells with the 7 pieces (28 cubes); out of pieces loses. **Stars**: hand-set 100 / 60 s. **Length**: ≤ 2 min.
**Readability**: a shallow board (depth 2), so the default camera snap faces the front; a tint shows the unseen back row; target cells glow.
**JSON sketch**:
```json
{"schema":1,"id":"lava_bonus","biome":"lava","tier":11,"name":"level.lava_bonus.name",
 "board":{"width":8,"depth":2,"h_play":6,"spawn_anchor":{"x":3,"z":0}},
 "pieces":{"fixed_list":["big_cube","duo","duo","i","i","i","i"]},
 "knobs":{"fall.g0":0.7,"spawn.preview_count":3},
 "goal":{"type":"fill_shape","target_shape":{"layers":{
   "0":["..++++..","..++++.."],"1":["...++...","...++..."],"2":["++++++++","++++++++"]}}},
 "recipe":[{"slot":"arrival","atom":"AR09"},{"slot":"goal","atom":"GO03"},{"slot":"clear","atom":"CL14"},{"slot":"fail","atom":"FT07"}],
 "stars":{"t2":100000,"t3":60000},"music":"lava_bonus",
 "story":{"mascot_role":"watcher","icon":"anvil"}}
```
**How it teaches**: pure packing, no pressure from the floor; the biome's wacky bonus is the forge itself.
**Wacky test**: surprising, a fixed list in a pressure biome; silly, Cinder hammering each piece; funny failure, the anvil collapses into a pile of cubes; big moment, the glowing anvil.

---

## 7. Hard-track remixes (tiers 12–14; open after 10)

### H1 Lava Rush

**Story card.** The lane again, but the lava is hungrier and geysers pop on the stack. Cap your layers fast. · **Cinder: watcher** (running on a rock).
**Stage**: busy, the 03 lane bright with spray. **Light**: crater night. **Music**: `lava_h1` (placeholder; fast, tight).
**I**: the lava swells higher than last time; Cinder yelps. **P**: the lane cools; she sits on a cooled stone and cools her feet. **M**: none. **R**: `exclaim` per rise.

```text
Recipe: BL06 (8×3, H10) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · EV06 (melt_every_s 25, melt_max 4) · EV04 + SP19 (every 6 locks, max 2)
```
```text
side (z = 1)          rises: 25 s, 50 s, 75 s, 100 s (headroom 10 → 6, then cooled)
10 ============
 1  . . r . . . . .   r = ember rock
 0  # # # # # # # #
```
**Stars**: F1, 270 / 190 s. **Length**: ~5.3 min. **JSON**:
```json
{"schema":1,"id":"lava_h1","biome":"lava","tier":12,"board":{"width":8,"depth":3,"h_play":10},
 "knobs":{"fall.g0":1.3},"goal":{"type":"clear_n","N":5},
 "rules":[{"id":"EV06","params":{"melt_every_s":25,"first_s":30,"melt_max":4}},
          {"id":"EV04","params":{"every_locks":6,"objects_max":2,"object":"SP19"}}],
 "stars":{"t2":270000,"t3":190000},"music":"lava_h1"}
```

### H2 Ash Crust

**Story card.** Cinder's starter stack is caked in ash. A clear next to a crusted block cracks it loose. The crater keeps rumbling. · **Cinder: watcher** (scrapes ash off with a stick).
**Stage**: busy, a smoky slope. **Light**: crater night. **Music**: `lava_h2` (placeholder; grinding, heavy).
**I**: Cinder pokes a block; it cracks; ash rains. **P**: the crust flakes off in one sheet; Cinder puffs the ash away. **M**: none. **R**: `sweat` on a rumble.

```text
Recipe: BL05 (6×6, H10, 2 starter layers with ash-crusted cubes) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · SP30 Lock (skinned ash crust) · EV12 (quake_every_s 40, quake_max_cubes 4)
Atoms used: BL05 (Meadow), SP30 (NEW), EV12 (met in 08).
```
**Encounters**: a crusted cube `k` cannot clear or move until a clear next to it unlocks it. Layer 1's crust is cracked by a clear above or below it; layer 0's crust is cracked by a clear of layer 1. The chain unlocks from the top down: clear a fresh layer on top, which cracks layer 1, which cracks layer 0.

```text
layer 0         layer 1
##k##.          .#####
######          ##k###
.#####          ######
###k##          ##.##k
#####.          k#####
###.##          ##..##
```
**Smash note (optional)**: once Boulder has joined, **Smash** removes a 3×3 chunk of crust (skills rule 15: player cubes and junk are removed). It is a shortcut, never required; star times assume no skill.
**Stars**: hand-set 295 / 205 s. **Length**: ~5 min. **JSON**:
```json
{"schema":1,"id":"lava_h2","biome":"lava","tier":13,
 "board":{"width":6,"depth":6,"h_play":10,"starting_contents":{"layers":{
  "0":["##k##.","######",".#####","###k##","#####.","###.##"],
  "1":[".#####","##k###","######","##.##k","k#####","##..##"]}}},
 "knobs":{"fall.g0":1.3},"goal":{"type":"clear_n","N":4},
 "rules":[{"id":"SP30","params":{}},{"id":"EV12","params":{"quake_every_s":40,"quake_max_cubes":4}}],
 "stars":{"t2":295000,"t3":205000},"music":"lava_h2"}
```

### H3 Forge Fixings

**Story card.** The forge's gutters are lidded again. Seven pieces, in order: drill the holes, then clear two layers. · **Cinder: watcher** (taps the lids).
**Stage**: clean, tense; the forge interior. **Light**: forge glow. **Music**: `lava_h3` (placeholder; ticking, hammer clinks).
**I**: Cinder knocks on a lid; it clinks. **P**: both layers clear; the forge door swings open; she hurries a marshmallow stick in. **M**: none. **R**: `exclaim` on each melt.

```text
Recipe: BL05 (4×4, H6, 2 starter layers) · AR09 fixed list · CV01 · GO01 (2) · FT07 · SP40 Ember drill (drill_depth 1)
Atoms used: BL05, AR09, FT07, SP40 (all met).
```
**Encounters**: fixed list `[ember I, ember I, I, I, Tri-Corner, Tri-Corner, Duo]` (the Duo is the one spare). Two holes under lids; an ember I standing on end (bottom cube is the ember) melts the lid and drops through; layer 0 then clears; the remaining 14 cells of the new bottom layer are exactly I + I + Tri-Corner + Tri-Corner.

```text
layer 0     layer 1 (L = lid)   after both drills and layer 0 clears
####        ....                ####
#.##        .L..                #I##    I = a standing I's leftover cube in the new bottom row
##.#        ..L.                ##I#
####        ....                ####
fill with I (z0), I (z3), Tri-Corner (x0 z1–2 + x1 z2), Tri-Corner (x2 z1 + x3 z1–2)
```
**Stars**: hand-set 130 / 85 s. **Length**: ≤ 2 min. **JSON**:
```json
{"schema":1,"id":"lava_h3","biome":"lava","tier":14,
 "board":{"width":4,"depth":4,"h_play":6,"starting_contents":{"layers":{
  "0":["####","#.##","##.#","####"],"1":["....",".L..","..L.","...."]}}},
 "pieces":{"fixed_list":[{"shape":"i","tags":{"ember":"end"}},{"shape":"i","tags":{"ember":"end"}},"i","i","tri_corner","tri_corner","duo"]},
 "knobs":{"fall.g0":0.8,"spawn.preview_count":3},"goal":{"type":"clear_n","N":2},
 "rules":[{"id":"SP40","params":{"drill_depth":1}}],
 "stars":{"t2":130000,"t3":85000},"music":"lava_h3"}
```

---

## 8. Narrative beats

Wordless (brief rule 1): intro and payoff skits per level, Cinder's reactions, Smolder in the backdrop from 04 (he watches from the crater), the Miller at the rim in 08, Mizzle's clues in 03, 04, 05, 06, 07 and 09. Arc: Cinder lights a campfire (01), cools the ember holes (02), runs from the lava (03), rides the geysers (04), builds a lookout and spots a droopy hat (05), roasts two marshmallows to charcoal (06), loses the stack in smoke while Mizzle walks away under parcels (07), survives the eruption and watches the Miller show the wizard the cards (08, the Rosetta), rides the magma belt (09), and watches the wizard dunk Smolder (10), then meets Boulder. The bonus and remixes are after-party gags. Postcard 5 (Mizzle waiting at a set table) sits in the Scrapbook and is earned on the bonus.

| Slot | Mizzle clue (strength cap 3) | Where |
|---|---|---|
| 01–02 | none | |
| 03 | a trail of violet ribbon scraps along the ash path | backdrop |
| 04 | the mail-cloud struggles past, satchel bulging (`sweat`) | backdrop |
| 05 | a droopy hat behind a basalt column; the wand doodles a lopsided cube | payoff |
| 06 | Smolder's box shows a star stamp; a violet cuff peeks (`dots`) | backdrop |
| 07 | ★ Mizzle walks away along the ridge under a tower of parcels | backdrop |
| 08 | ★ the Rosetta | payoff |
| 09 | Mizzle sees the Miller pointing; pushes his glasses up, hurries on (`blush`) | backdrop |
| 10 | flag 5 hung as a towel | payoff |

## 9. Music and audio cues

One track per level (user-supplied; ids are placeholders), so cues live in sound effects, not in layered stems. Per level: calm-opening tracks 01, 02, 06 and a hushed 07; driving tracks 03, 04, 08, 09; swaggering 10 with a key change at each phase; a ringing hammer for the bonus. The danger stinger plays only where `topout_rule` is rescue (not 05, 06, B, H3). Telegraph cues: the **melt warning** (bubbling + rumble, 3 s) for EV06, the **rumble warning** (low rumble + ember rain, 2 s) for EV12, the **steam hiss** (1 lock ahead) for EV04, the **smoke cough** for EV02, and the **belt shuffle** for EV05. Skits use short stingers, never voices. The Rosetta has a tiny, bright "found it" sting (0.5 s). Ambience (rumble, bloops, crackles, rock-toad burps, hissing steam) follows the SFX slider.

## 10. Open questions

- **Proposed atom used**: **SP40 Ember drill** (02, 07, H3) is status Pr; it needs review into Candidate (and its `ember_per_bag` / `drill_depth` knobs in the atom list).
- **Candidate atoms used**: BL06 (03, H1), PL02 (05), PL07 (06), SP35 (04), EV12 (08, 10, H2), SP30 (H2). Their full rules move into the owning GDDs before build. **EV06** is Designed only as the minigame Floor Is Lava (MG13); the campaign form above (surface rises, bottom layer lost, cools after `melt_max`) needs a GDD entry.
- **Needed, does not exist (suggested):** a generic **rule activation gate** `active_after_clears` (a rule stays dormant until N clears, for finale phases). Fallback with no new atom: first-trigger delays, as in the Meadow's flip.
- **PL02 vs trim stars (05)**: ★★★ reads "no cube trimmed above the limit"; a PL02 snap-off is not a trim. Confirm in Scoring & Stars.
- **EV12 shake-loose scope**: the library says "unsupported cubes fall off"; the rule above caps it at `quake_max_cubes` per rumble and means cubes with an empty cell directly below. Confirm with the FT04 owner.
- **SP35 relock direction** when the piece was not moved: assumed no push. Confirm.
- **Smash on locked cubes (H2)**: skills rule 15 removes player cubes and junk; confirm that SP30-locked cubes count as player cubes.
- **Light table mismatch**: `visual-direction.md` (L1–3 red dusk, L4–5 ash-haze dusk, L6–8 early night ember, L9–10 crater night) and `lore-world.md` (smoky dusk on 04 and 07, eruption night on 08–09, steam moonlight at the end of 10) differ. This file follows visual-direction and adds the lore's smoke overlay on 07 and steam moonlight in the 10 payoff.
- **Helper mascot**: no Lava level uses WO06 (its cell-choice rule has no owner), so Cinder is a watcher throughout.
- **Star times** are formula estimates; replace with playtest medians.
