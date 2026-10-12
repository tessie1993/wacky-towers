# Side Island: Tumble Fair (levels 01–05, bonus)

> **Status**: Draft v1 for user review (level-designer, 2026-10-10). Written straight through under the /team-narrative round ("side islands also in full detail; designers decide, user reviews the finished result"). Post-MVP scope.
> **Author**: level-designer
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Format source**: `design/levels/meadow.md` (section for section), with the per-level layout of `design/levels/candy.md`.
> **Sources**: `production/narrative/campaign-story/brief.md` §4, `lore-world.md` §4.1 and X6, `dialogue-campaign-skits.md` §11.1, `visual-direction.md` §2.3 and §3.4, `design/gdd/mechanics-module.md` (atoms, F1 budget), `campaign-structure.md`, `level-data-definition.md` (rule 4f `side_island`), `scoring-stars.md`, `design/levels/meadow.md` and `candy.md` (what the player already knows).
> **Field definitions**: `design/gdd/level-data-definition.md`; defaults from the owning GDDs.

**Every number, name and beat in this file is a tunable default**, a starting point for the prototype and playtests. The validator enforces only the safe ranges in the owning GDDs. Atom status: **D** Designed, **C** Candidate, **Pr** Proposed.

---

## 1. Level name and theme

**Bounce's Big Prize.** Bounce the baby elephant wants to win the biggest prize at the fair, a giant plush teddy (a wizard teddy) on the top shelf of the prize booth. Blocks fall as a **confetti drizzle** over a floating fairground of striped tents, bunting and a slowly turning ferris wheel, on a bright warm evening that ends in soft fireworks. Baron Balloon, a pompous hot-air balloon with a twirly moustache, wants to be the biggest thing at the fair; he puffs himself up, blows the ring-toss rings around and sets the big top spinning. In the finale the last clear sends a ring onto his valve: he deflates in loops around the fair and lands as a bouncy castle, and everyone bounces on him (he secretly enjoys it). Cloud charm: **a balloon** tied to the wizard's cloud.

**A gag island, not a plot island.** Brief §4 and lore X6: no Mizzle plot beyond **one wink** (level 03), and **Baron got no gift from Mizzle**: his want is his own (to be biggest). No friend joins; friends appear only as the player's chosen character. No postcard. Tumble Fair is also the **tournament hub** on the map (ring toss, balloon pop, ticket race minigames live in the tournament files, not here).

**Quirk: "Every ride moves."** Each level is a fair ride or stall with one ride-rule (a ring lands, a tent bounces, a mirror copies, a car spins, a balloon floats). Classic play stays the base; the strangeness zig-zags across the five levels, and the finale stacks the three ride rules the player has met.

### Biome rules (decisions)

| Rule | Default |
|---|---|
| Unlock | Opens when `candy_10` is finished (no star gate). Biome record `assets/data/biomes/tumble_fair.json`, `side_island: true` (level-data rule 4f): its levels never gate the main chain and its stars count toward no main gate |
| Size | 5 levels (tiers 1–5) + 1 bonus (tier 11). Slot 05 is the finale. **No hard track** (brief §4 and skits §11 give side islands none) |
| Islands | One per level (lore 4.1 A): ring-toss stall, helter-skelter base, funhouse mirror tent, ferris-wheel car, the big top ring; bonus: the prize-booth shelf. Settles into sawdust with a scatter of confetti |
| Stage | Busy diorama or clean stage per level; calm levels quiet, chaos levels busy. Backdrop: barrel organ, bunting flutter, the turning wheel |
| Arrival skit | First visit only, on the map, 4 s (skits §11.1) |
| Intro skit | A 3-second wordless mini-scene during the Countdown (no play time lost). Boss intro (05) from skits §11.1 |
| Payoff skit | ≤ 5 s on every win, tap to skip; finale 6 s on first play, last 2 beats on replays |
| Mascot | **Bounce** (Tumble Fair only), **watcher** (WO09, staging only) on every level: bounces on the tent roofs in the backdrop, `exclaim`, `sparkle`, `sweat`. No helper or catch here (WO11 is Pip's) |
| Boss | **Baron Balloon** in 05 (watching from above the tents from 03). Wind-up tell (visual-direction 2.3): he inflates and rises, the moustache twirls, the basket swings back. Bonked, never hurt |
| Friends | None join. If the player has Lana (Ice) or later friends, their skills work as usual; star times are authored with no skill and no perks |
| Physics | None |
| Rubber duck | In the hook-a-duck pond under the island in 01 and 02: one of the floating ducks is the real one (SE05, one low snap angle, tap to collect, no stars) |
| Events as fair events | Spawned Objects (EV04) = **Ring Toss**; Bounce pad (SP35) = **Bouncy Tent**; Pond mirror (PL10) = **Funhouse Mirror**; Turntable (BL11) = **Ferris Turn** (04) / **Big Top Spin** (05); Balloon (EV10) = **Baron's Balloons** |
| Failure gag (every level) | The tower topples into the sawdust; clown mice catch the cubes in their big shoes; Bounce covers its eyes with its ears. In 05 Baron chuckles and twirls his moustache. Nobody is hurt |
| Light | Lore 4.1 F mapped to the shared archetypes (visual-direction §5.3): 01–02 golden evening (E), 03 sunset (E, low-sun override), 04 string-light twilight (F), 05 fireworks night (G, slow soft bursts), B tent interior (H) |
| Blocks / frame | Block set **Candy Stripes** (visual-direction 3.4; see §10 for the lore's Toy Box alternative). Frame: red-and-cream striped painted wood, pennant cord trim, a tiny ticket stub at one corner. Bunting is warm red / yellow / cream only, so the one violet item reads as the wink |
| Music | One full track per level, supplied by the user. Ids `mus_tumble_fair_01`…`05`, `mus_tumble_fair_bonus` are **placeholders**; unknown ids warn and fall back to the biome `default_music` |
| Prototype priority | **03, 05** (★PROTO): the mirror twin (Pr atom, the island's signature) and the boss |

**Common defaults** (unless a level says otherwise): weighted bag, 8 Standard shapes, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, all rotation axes (Turn / Flip / Roll, CV01), `t_piece` 8 s. Stars authored with no perks and no skill.

**Speed (side-island rule, proposed).** A side island compresses a biome arc into five levels, so level `L` uses campaign F2 with the biome it unlocks after and tier `2L`: `g0 = 0.6 + 0.045 × (2L − 1) + 0.06 × (b − 1)`, with **b = 2** (Candy). That gives 0.705 / 0.795 / 0.885 / 0.975 / 1.065; levels hand-set within ±0.05.

**Star times.** Scoring F1: `t_est = N × t_beat`, `t_beat ≈ 2.67 × A` s (A = active cells per layer), `t2 = round5(0.85 × t_est)`, `t3 = round5(0.6 × t_est)`. Levels whose rule changes how fast layers fill (03 twin copies, 05 balloons) and the bonus are hand-set.

**Budget (mechanics module F1).** At most 2 atoms new to the player and 4 non-default atoms per level; bundles (M1, M2) count 1; mascot atoms and secrets (WO09, SE05) count 0. Slot defaults: BL01, AR01, CV01, CL01, CO01, GO01, FT01. **"New" is counted against the shortest path to this island**: the Meadow and Candy main paths (tiers 1–10) only, because bonuses and remixes are optional and a player may come straight here after `candy_10`. Known on that path, among others: BL02, BL05, EV01–EV05, SP19, SP21, SP22, SP25, SP26, SP27, SP28, SP31, PL01, PL03, CL05, CL07, GO04, M1, M2. A player who arrives later (after Ice or Underwater) will already know SP35 and BL11, so the real count can only go down.

**Grids**: one string per row, row 0 = `z = 0` (back), character 0 = `x = 0` (left). Mask `#` active, `.` off. Starting contents `p` bouncy tent pad, `.` empty. Targets `+`. Side views are a slice at one `z` row seen from the front; `=====` is the danger line at `H_play`, `S` the spawn zone, `:` skips empty rows.

### Fair rule defaults used below

Full rules belong in the owning GDDs (§10); these are this island's values.

- **Ring Toss (EV04, `object: ring`).** Every `spawn_every_locks` a clown mouse tosses a 1-cube hoop onto a free top-surface cell, marked by a target sparkle one lock ahead (`telegraph_locks` 1), at most `objects_max` on the board. A ring fills its cell, never moves, and clears with its layer (it pops into a paper ticket, cosmetic). Counter: *use it* (leave a 1-cell gap under the sparkle).
- **Bouncy Tent (SP35).** A pad object. A piece that lands with any cube on a pad hops up `bounce_h` 1 and relocks one cell onward in its last horizontal move direction; if it never moved sideways, one cell **clockwise around the island centre** (`bounce_dir_default: "cw"`). If the onward cell is blocked or off the board, it relocks where it landed. Once per landing. The landing ghost shows the bounce end cell. Pads fill their cell and clear with their layer.
- **Funhouse Mirror (PL10, Pr).** `mirror_axis` x: on lock, a twin copy is written mirrored across the board's centre plane (between x = 2 and x = 3 on a 6-wide board), then drops rigidly until supported; twin cells already taken are skipped. Twin cubes at or above `H_play` are trimmed with a splash, never a top-out. A second, wavy ghost shows where the twin will land.
- **Ferris Turn / Big Top Spin (BL11).** Every `turn_every_locks` the locked stack turns 90° (`turn_dir` clockwise seen from above) about the board's vertical centre axis, at the start of Resolving. Square, 90°-symmetric footprints only. Spawn, danger line and the falling piece do not turn. Telegraph one lock ahead: a creak, the arrow ring on the island rim lights and the car (or ring) shudders.
- **Baron's Balloons (EV10).** One piece per bag (`per_bag` 1) arrives tied to a little balloon: it falls at × `balloon_slow` 0.5, and every `bob_every_ms` 3 000 it bobs **up** 1 cell (not above the spawn row, not into a cube). A hard drop pops the balloon (a squeak) and the piece drops normally. `active_after_clears` lets a level start the rule mid-level.

## 2. Estimated play time and summary

| # | id | Name | Story beat | New idea (atoms; **bold** = new to the player) | Bounce | Stage | Goal | Board | Pieces | g0 | Top-out | Length | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | tumble_fair_01 | Ring Toss | Win a ticket | Ring Toss (EV04, known) | watcher | clean, calm | Clear 3 | 5×5, H9 | 8 Std; first 2 from {O, I} | 0.70 | rescue, 2 | ~3.3 min | 170 / 120 s |
| 02 | tumble_fair_02 | Helter-Skelter | Bounce off the tents | **Bouncy Tent (SP35)**, ring board (BL02) | watcher | busy | Clear 4 | 6×6 ring (centre 2×2 off), H10 + 3 pads | 8 Std | 0.80 | rescue, 1 | ~5.7 min | 290 / 205 s |
| 03 ★ | tumble_fair_03 | Funhouse Mirror | The reflection copies you | **Funhouse Mirror (PL10, Pr)** | watcher | busy, silly | Clear 4 | 6×6, H10 | 8 Std | 0.90 | rescue, 1 | ~3.6 min | 180 / 130 s |
| 04 | tumble_fair_04 | Ferris Wheel | The car spins | **Ferris Turn (BL11)**, ring callback | watcher | busy | Clear 3 | 6×6, H10 | 8 Std | 0.95 | rescue, 1 | ~4.8 min | 245 / 175 s |
| 05 ★ | tumble_fair_05 | Baron Balloon | Boss: deflate the Baron | **Baron's Balloons (EV10)**, Big Top Spin, Ring Toss | boss (Bounce cheers) | busiest | Clear 4 | 6×6, H12 | 8 Std | 1.05 | rescue, 1 | ~6.5 min | 340 / 240 s |
| B | tumble_fair_bonus | Prize Shelf | Stock the prize booth | **fixed list (AR09)**, **budget (FT07)**, shape (M2) | watcher | clean, hurried | Shape 24 in 75 s | 6×2, H4 | fixed: I I O L L O | 0.55 | out of pieces / 75 s | ≤ 1.5 min | 50 / 35 s* |

★ = prototype priority. \* ★★★ also requires no cube trimmed. Star times use Scoring F1 except 03 (hand-set: twins fill layers about 1.8× faster), 05 (hand-set: +5% for balloon pieces) and B (hand-set against its 75 s clock). Length mix: 3.3, **5.7**, 3.6, 4.8, **6.5** (short and long alternate; the finale is long). 01, 03 and B are short on purpose; the validator's 5–15 min length warning is expected.

**Bonus (decision).** `tumble_fair_bonus` is tier 11 and opens at **10 of 15** island stars (the main-biome 20 of 30 gate, scaled). It is the island's **one puzzle level** (campaign rule 15: fixed list).

**Novelty budget per level** (`nd` non-default / `new` first use on the shortest path; bold = new):

| # | Non-default atoms | nd | new |
|---|---|---|---|
| 01 | EV04 (ring) | 1 | 0 |
| 02 | BL02, **SP35**, EV04 (pad respawn) | 3 | 1 |
| 03 | **PL10 (Pr)** | 1 | 1 |
| 04 | **BL11**, EV04 | 2 | 1 |
| 05 | BL11, EV04, **EV10** | 3 | 1 (twists 3 = finale cap) |
| B | **AR09**, M2 bundle, **FT07** | 3 | 2 (0 if a main-biome bonus was played) |

## 3. Layout overview

```text
01 ring-toss stall  02 helter-skelter   03 mirror tent   04 ferris car   05 big top ring   B prize shelf
#####               ######              ###|###          ######          ######            ######
#####               ######              ###|###          ######          ######            ######
#####               ##..##   (pole)     ###|###          ######          ######
#####               ##..##              ###|###          ######          ######
#####               ######              ###|###          ######          ######
                    ######              ###|###          ######          ######
                                        | = mirror plane  (turns 90°)    (turns 90°)
```

## 4. Critical path and optional paths

- **Island path**: 01 → 05 in order (linear). Finishing 05 completes Tumble Fair, ties the balloon charm to the wizard's cloud and plays the map change. Nothing on the main chain depends on it.
- **Optional**: ★★★ times on every level; the hook-a-duck in 01–02; the Prize Shelf (10 island stars); the Mizzle wink in 03.
- **Tournament hub**: the island's map node also opens the tournament lobby (tournament files own it).

## 5. Pacing chart

```text
strangeness (how far from classic)
 high |                         #
      |           #             #
  mid |       #   #       #     #
      |       #   #   #   #     #   #
  low |   #   #   #   #   #     #   #
      +--01--02--03--04--05----B
        warm bounce copy spin FINALE puzzle
```

Zig-zag, not a ramp: a warm opener with a known rule (01) → the first new rule, long (02) → the strangest rule, short (03, the twin) → a spin with a familiar callback (04) → the three-ride finale (05). The bonus is a short calm puzzle with a clock.

---

## 6. Level specs (encounter lists, sketches, beats)

Skit abbreviations: **I** intro (≤ 3 s, ends on the hand-off), **P** payoff (≤ 5 s), **M** Mizzle wink (one level only, ≤ 1.5 s, backdrop, never over the grid or during a warning), **R** reactions (one bubble at a time, ≤ 1 s). JSON sketches show only fields that differ from defaults; rule ids are sketches pending the rule JSON of ADR-0011.

**Arrival (map, first visit, 4 s; skits §11.1)**: 0.0–1.5 the cloud drifts over striped tents and a turning ferris wheel. 1.5–3.0 Bounce bounces off a tent roof, too high, and waves its trunk on the way down (`exclaim`). 3.0–4.0 Baron Balloon puffs himself bigger over the fair (`smug`).

### 01 Ring Toss

**Story card.** Bounce wants a ticket from the ring-toss stall. Clown mice keep tossing rings onto your stack; each ring fills a cell for free if you leave it room. · **Bounce: watcher** (bounces on the stall awning).
**Beats.** **I**: a clown mouse tosses a ring, misses the bottles, and it lands on Bounce's trunk; Bounce looks up, glint. **P**: the third clear rings every bottle; the mouse hands Bounce a ticket; Bounce trumpets and the ticket flutters off its trunk. **M**: none. **R**: `exclaim` when a ring lands, `sparkle` on a clear, `sweat` on a warning.
**Stage**: clean, calm; a ring-toss stall with a bottle pyramid, the hook-a-duck pond below. **Light**: golden evening (E). **Music**: `mus_tumble_fair_01`.

```text
Recipe: BL01 (5×5, H9) · AR01 · CV01 · GO01 (3) · FT01 (2 warnings) · CL01 + CO01 · EV04 Ring Toss · SE05 duck · WO09
One sentence: "Rings land on your stack; leave them a gap."
```
**Atoms**: non-default EV04 (known from Meadow 04 and Candy 02). 1 non-default, 0 new.
**Encounters**: **Ring Toss**: `spawn_every_locks` 5, `objects_max` 3, `hail_after_locks` 4 (no ring before the 4th lock), sparkle one lock ahead. Pieces 8 Standard; `opening_set` [O, I], count 2.
**Goal / fail**: Clear 3; top-out rescue, 2 warnings (the island's gentle opener). **Stars**: `t_est = 3 × 2.67 × 25 = 200 s` → ★★ 170 s, ★★★ 120 s. **Length**: ~3.3 min.

```text
top-down 5×5      side (z = 2)
#####             12 . . S . .   spawn zone
#####              9 ==========  danger line
##S##              :
#####              1 . r . . .   r = ring (fills a cell)
#####              0 # # . # #   a few locked pieces on the stall counter
```
**How it plays**: (1) the first pieces fall slowly; the stall is calm. (2) After the 4th lock a target sparkle appears; a mouse tosses a ring onto it with a "ding". (3) The player leaves a 1-cell gap where the next sparkle is and gets a free plug. (4) The third clear rings the bottles.
**Readability**: the sparkle is the only forecast; rings are bright red-and-cream hoops with a ticket-stub tag, clearly not a piece; the landing ghost keeps its outline style.
**Teaches**: the controls in fair clothes for a returning player, and a known rule (spawned objects) as a warm-up. **Wacky test**: surprising, someone else is throwing things on your tower; silly, rings land with a carnival "ding" and wobble; funny failure, a ring lands in the perfect gap and the mouse bows anyway; big moment, the third clear rings every bottle at once.

```json
{ "schema": 1, "id": "tumble_fair_01", "biome": "tumble_fair", "tier": 1, "name": "LVL_TUMBLE_FAIR_01_TITLE",
  "board": { "width": 5, "depth": 5, "h_play": 9, "down_axis": "-y" },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right"], "opening_set": ["o","i"], "opening_count": 2 },
  "knobs": { "fall.g0": 0.70, "goal.top_out": "rescue", "goal.warnings_max": 2 },
  "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "mushroom_popup", "params": { "object": "ring", "spawn_every_locks": 5, "objects_max": 3, "hail_after_locks": 4 } },
             { "id": "angle_gem", "params": { "skin": "hook_a_duck" } } ],
  "stars": { "t2": 170000, "t3": 120000 }, "seed": null, "music": "mus_tumble_fair_01",
  "story": { "title_key": "LVL_TUMBLE_FAIR_01_TITLE", "premise_key": "LVL_TUMBLE_FAIR_01_PREMISE", "mascot_role": "watcher", "icon": "ring" } }
```

---

### 02 Helter-Skelter

**Story card.** Bounce slides down the helter-skelter and boings off the striped tents. Pieces that land on a bouncy tent hop up and land one cell on, so aim one cell short. · **Bounce: watcher** (rides the slide in the backdrop).
**Beats.** **I**: Bounce whizzes down the helter-skelter on a mat, hits a tent roof and boings clean over the stack. **P**: Bounce slides down again, bounces off the last tent and lands perfectly on the mat; the balloon animals squeak and clap. **M**: none. **R**: `exclaim` on a bounce, `heart` on a clear.
**Stage**: busy; the striped helter-skelter tower rises from the island centre (the 2×2 hole is its pole), tent roofs around the rim. **Light**: golden evening (E). **Music**: `mus_tumble_fair_02`.

```text
Recipe: BL02 (6×6 ring, centre 2×2 off, A = 32, H10, spawn_anchor (2,4)) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · SP35 Bouncy Tent (3 starting pads) · EV04 pad respawn · SE05 duck · WO09
One sentence: "Tents bounce your piece one cell on."
```
**Atoms**: non-default BL02, SP35 (**new**), EV04 (known). 3 non-default, 1 new.
**Encounters**: three pads start on the floor at (0,0), (5,2) and (2,5) (they fill their cells). **Bouncy Tent** (SP35): `bounce_h` 1, onward one cell in the last move direction, else clockwise round the pole. **Pad respawn** (EV04, `object: pad`): every 6 locks, `objects_max` 3, sparkle one lock ahead. Pieces 8 Standard.
**Goal / fail**: Clear 4; top-out rescue, 1 warning. **Stars**: `t_est = 4 × 2.67 × 32 ≈ 342 s` → ★★ 290 s, ★★★ 205 s. **Length**: ~5.7 min.

```text
layer 0 (p = pad)   side (z = 2, through the pole)
p.....              13 . . S . . .   spawn on the front band
......              10 ============  danger line
.....p ← pole        :
......               1 . . . . . .
......               0 . . | | . p   | = pole (off), p = pad
..p...
mask: ###### / ###### / ##..## / ##..## / ###### / ######
```
**How it plays**: (1) a piece slid sideways onto a pad boings up and lands one cell on. (2) The ghost shows the bounce end cell, so the player aims one cell short. (3) A piece dropped straight onto a pad hops clockwise round the pole (the helter-skelter direction). (4) Clears take pads with them; a sparkle shows where the next tent pops back.
**Readability**: pads are striped tent tops with a spring wobble; the ghost draws the bounce arc and its end cell; the clockwise arrow is painted on the pole base.
**Teaches**: a rule that acts after landing, read from the ghost (Candy 03's syrup glide in a new form). **Wacky test**: surprising, your piece jumps after landing; silly, a "boing" and a tent wobble; funny failure, a piece bounces off into the wrong gap and Bounce shrugs; big moment, a clear pops all the tents like balloons.

```json
{ "schema": 1, "id": "tumble_fair_02", "biome": "tumble_fair", "tier": 2, "name": "LVL_TUMBLE_FAIR_02_TITLE",
  "board": { "width": 6, "depth": 6, "h_play": 10, "mask": ["######","######","##..##","##..##","######","######"], "spawn_anchor": [2,4],
    "starting_contents": { "layers": { "0": ["p.....","......",".....p","......","......","..p..."] } } },
  "knobs": { "fall.g0": 0.80, "goal.top_out": "rescue", "goal.warnings_max": 1 },
  "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "bounce_pad", "params": { "bounce_h": 1, "bounce_dir_default": "cw" } },
             { "id": "mushroom_popup", "params": { "object": "pad", "spawn_every_locks": 6, "objects_max": 3 } },
             { "id": "angle_gem", "params": { "skin": "hook_a_duck" } } ],
  "stars": { "t2": 290000, "t3": 205000 }, "music": "mus_tumble_fair_02",
  "story": { "title_key": "LVL_TUMBLE_FAIR_02_TITLE", "premise_key": "LVL_TUMBLE_FAIR_02_PREMISE", "mascot_role": "watcher", "icon": "tent" } }
```

---

### 03 Funhouse Mirror ★PROTO

**Story card.** In the funhouse tent a magic mirror runs down the middle of the board. Every piece you lock gets a mirrored twin on the other side. Twins fill layers fast, and they can fill your holes or bury them. · **Bounce: watcher** (its skinny reflection copies it, wrongly).
**Beats.** **I**: Bounce looks into the funhouse mirror; its reflection is a skinny elephant; Bounce waves, the reflection waves the other trunk. **P**: the mirror goes wobbly with a giggle; the skinny reflection steps out and hugs Bounce, and two elephants bounce out of the tent. **M (the island's one wink, lore 4.1 slot, skits §11.1 content)**: during the payoff, in the backdrop past the tent flap, a violet cuff hands a ticket to the ticket booth; the booth's little flag is violet (1.2 s, no emote). **R**: `question` at the first twin, `sparkle` on a clear, `dizzy` when a twin is trimmed.
**Stage**: busy, silly; a striped tent interior with wavy mirrors around the rim; Baron Balloon peeks in through the roof hole (first appearance). **Light**: sunset (E, low-sun override, warm light through the tent flap). **Music**: `mus_tumble_fair_03`.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · PL10 Funhouse Mirror (mirror_axis x) · WO09
One sentence: "Every piece gets a mirror twin."
```
**Atoms**: non-default PL10 (**new**, Pr). 1 non-default, 1 new.
**Encounters**: **Funhouse Mirror** (PL10): the plane sits between x = 2 and x = 3. A piece wholly in the left half gets a full twin in the right half (and vice versa); a piece on the seam twins onto itself, so taken cells are skipped and a symmetric piece on the seam adds nothing. The twin drops rigidly until supported, so it can fall into a hole on its side. Twin cubes at or above layer 10 are trimmed with a splash (no top-out from a twin). Pieces 8 Standard.
**Goal / fail**: Clear 4; top-out rescue, 1 warning (only the player's own piece can top out). **Stars (hand-set)**: twins add about 0.8 of a piece per lock, so `t_beat ≈ 96 / 1.8 ≈ 53 s`; `t_est ≈ 213 s` → ★★ 180 s, ★★★ 130 s. **Length**: ~3.6 min (short on purpose).

```text
top-down 6×6 (| mirror)   side (z = 2), one lock: piece P on the left, twin T on the right
###|###                   13 . . S | . .     spawn
###|###                   10 ======|======   danger line
##S|###                    :       |
###|###                    1 . P P | . T T   the twin lands mirrored
###|###                    0 # P # | # T #   and drops until supported
###|###
```
**How it plays**: (1) the first piece locks and its wavy twin pops out of the mirror on the other side with a "boing". (2) The second ghost shows where the twin will land, so the player checks both sides before dropping. (3) A hole on one side gets filled by a twin from the other; a messy side gets messier twice as fast. (4) Layers fill quickly; four clears in a few minutes.
**Readability**: the mirror plane is a shimmering silver line on the floor and a frame at both board edges; the twin's ghost is the player's ghost style, mirrored with a wavy rim; twins flash silver for 0.3 s when written.
**Teaches**: thinking in pairs (a symmetry puzzle with no new controls). **Wacky test**: surprising, every piece appears twice; silly, the twin is a little wobbly and giggles into place; funny failure, a twin buries your perfect gap and Bounce's reflection points at it; big moment, a double clear made of one piece and its twin.

```json
{ "schema": 1, "id": "tumble_fair_03", "biome": "tumble_fair", "tier": 3, "name": "LVL_TUMBLE_FAIR_03_TITLE",
  "board": { "width": 6, "depth": 6, "h_play": 10, "down_axis": "-y" },
  "knobs": { "fall.g0": 0.90, "goal.top_out": "rescue", "goal.warnings_max": 1 },
  "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "pond_mirror", "params": { "mirror_axis": "x" } } ],
  "stars": { "t2": 180000, "t3": 130000 }, "music": "mus_tumble_fair_03",
  "story": { "title_key": "LVL_TUMBLE_FAIR_03_TITLE", "premise_key": "LVL_TUMBLE_FAIR_03_PREMISE", "mascot_role": "watcher", "icon": "mirror" } }
```

---

### 04 Ferris Wheel

**Story card.** The board is a big ferris-wheel car, and every time the wheel creaks the car spins a quarter turn. Rings still fly in from the ring-toss stall below. Build so the stack works from any side. · **Bounce: watcher** (rides in the next car, waving).
**Beats.** **I**: Bounce climbs into a ferris-wheel car; the car spins round and Bounce slides along the bench, dizzy. **P**: the wheel stops at the top; Bounce looks out over the whole fair, spots the prize booth's giant teddy and points, trunk trembling with excitement. **M**: none. **R**: `dizzy` on the first turn, `sparkle` on a clear, `exclaim` when a ring lands.
**Stage**: busy; the car's floor is the board, the wheel's spokes and lit bulbs behind, the fair far below. **Light**: string-light twilight (F). **Music**: `mus_tumble_fair_04`.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · BL11 Ferris Turn (every 4 locks, cw) · EV04 Ring Toss callback · WO09
One sentence: "The car spins a quarter turn every 4 pieces."
```
**Atoms**: non-default BL11 (**new**), EV04 (known). 2 non-default, 1 new. Twists 2.
**Encounters**: **Ferris Turn** (BL11): `turn_every_locks` 4, `turn_dir` cw, creak and rim arrows one lock ahead; the turn applies at the start of Resolving, before the clear check. **Ring Toss** callback: every 6 locks, max 2. Pieces 8 Standard.
**Goal / fail**: Clear 3; top-out rescue, 1 warning. **Stars**: `t_est = 3 × 96 = 288 s` → ★★ 245 s, ★★★ 175 s. **Length**: ~4.8 min.

```text
top-down 6×6, before → after a turn (cw)   side (z = 2)
A B . . . .      . . . . . A               13 . . S . . .
. . . . . .      . . . . . B               10 ============
. . . . . .  →   . . . . . .                :
. . . . . .      . . . . . .                1 # . . # . .
. . . . . .      . . . . . .                0 # # . # # #
. . . . . .      . . . . . .
```
**How it plays**: (1) normal stacking; the wheel creaks after the 3rd lock. (2) The car spins: your back-left corner is now back-right. (3) The player learns to keep the stack flat and fill from the middle, so a turn moves no gaps into awkward places. (4) A ring flies in after a turn; the third clear stops the wheel at the top.
**Readability**: the turn counter is a ring of 4 bulbs on the car rim (one lights per lock); the camera does not turn with the car; a brief motion trail shows each cube's path.
**Teaches**: the stack can move under you on a schedule (a plan-ahead rule), the ride the finale reuses. **Wacky test**: surprising, the whole stack spins; silly, the car's little bench and Bounce's ears flap on each turn; funny failure, a turn swings your gap under a ring and the mouse waves; big moment, the third clear and the view from the top.

```json
{ "schema": 1, "id": "tumble_fair_04", "biome": "tumble_fair", "tier": 4, "name": "LVL_TUMBLE_FAIR_04_TITLE",
  "board": { "width": 6, "depth": 6, "h_play": 10, "down_axis": "-y" },
  "knobs": { "fall.g0": 0.95, "goal.top_out": "rescue", "goal.warnings_max": 1 },
  "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "turntable", "params": { "turn_every_locks": 4, "turn_dir": "cw" } },
             { "id": "mushroom_popup", "params": { "object": "ring", "spawn_every_locks": 6, "objects_max": 2 } } ],
  "stars": { "t2": 245000, "t3": 175000 }, "music": "mus_tumble_fair_04",
  "story": { "title_key": "LVL_TUMBLE_FAIR_04_TITLE", "premise_key": "LVL_TUMBLE_FAIR_04_PREMISE", "mascot_role": "watcher", "icon": "ferris_wheel" } }
```

---

### 05 Baron Balloon (boss) ★PROTO

**Story card.** Baron Balloon wants to be the biggest thing at the fair. He blows the ring-toss rings across the big top, spins the circus ring, and after two clears he puffs balloons onto your pieces so they float. Each clear lands a ring on his basket; the fourth lands on his valve. · **Boss**: Baron Balloon; Bounce cheers from the ring edge (watcher).
**Beats.** **I (skits §11.1, 3 s)**: 0.0–1.5 Baron inflates until he blots out the ferris wheel. 1.5–2.0 he blows the ring-toss rings across the board (`smug`). 2.0–3.0 hand-off: Bounce looks up; glint; first piece. **P (finale, 6 s; [R] 4–5 on replays)**: 0.0–1.5 last clear: a ring lands on Baron's valve; he squeaks. 1.5–3.0 he deflates in loops around the fair (`dizzy`). 3.0–4.0 he lands flat and puffs into a bouncy castle (`gloom`). [R] 4.0–5.0 Bounce bounces on him (`sparkle`). [R] 5.0–6.0 the cloud charm: a balloon ties itself to the wizard's cloud (`heart`). **M**: none (the island's wink is in 03). **R**: Baron `smug` on each wind-up, `angry` puff on each clear; Bounce `exclaim` when a balloon piece bobs.
**Stage**: busiest; the big top's sawdust ring, seals juggling, Baron floating above the tent poles. **Light**: fireworks night (G; slow soft bursts, photosensitivity-safe, reduced motion = static glow). **Music**: `mus_tumble_fair_05`.

```text
Recipe: BL01 (6×6, H12) · AR01 · CV01 · GO01 (4 = 4 rings on the Baron) · FT01 (1) · CL01 + CO01 · BL11 Big Top Spin (every 5 locks) · EV04 Ring Toss (Baron blows them) · EV10 Baron's Balloons (from clear 2)
One sentence: "The ring spins, rings fly, then pieces float."
```
**Atoms**: non-default BL11, EV04, EV10 (**new**). 3 non-default, 1 new. Twists 3 (the finale cap).
**Encounters**:
- **Big Top Spin** (BL11): every 5 locks, cw. Baron's tell before each spin: he inflates and rises, the moustache twirls.
- **Ring Toss** (EV04): every 5 locks, offset by 2 from the spin (so a spin and a ring never share a lock), max 4; Baron's basket swings back as he blows.
- **Phase switch (decision)**: **Baron's Balloons** (EV10) start at `active_after_clears` 2: one piece per bag floats at × 0.5 and bobs up 1 every 3 s; a hard drop pops the balloon. No new atom is needed for the phase (EV13 Halftime swap was not used, as in the Meadow finale).
- The Baron is the face of the rules (campaign rule 16): every event is his wind-up; he cheers when you use a warning and deflates a little (5% smaller) on each clear.

```text
top-down 6×6 (ring spins cw)   side (z = 2)
######                         15 . . S . . .   spawn zone (balloons bob no higher than this)
######     o  (ring sparkle)   12 ============  danger line
##S###                          :
######                          1 # o . # . #   o = ring
######                          0 # # . # # #   sawdust ring
######
phase 2: one piece per bag floats on a balloon (falls at half speed, bobs up 1 every 3 s)
```
**How it plays**: (1) the ring spins every 5 locks; rings fly in between spins. (2) Two clears: two rings on the basket; Baron goes red and puffs balloons. (3) A balloon piece drifts slowly: the player either uses the slow fall to aim, or hard-drops to pop it. (4) The fourth clear hits the valve.
**Readability**: the two timers are offset and drawn separately (spin bulbs on the rim, ring sparkle on the surface); the balloon is tied to the piece with a visible string and the ghost ignores the bob (it shows the drop point if released now); Baron never covers the grid (he floats above the spawn zone, behind it at the 12 snap angles).
**Teaches**: the island's ideas together, with a familiar escape hatch (hard drop pops the balloon). **Wacky test**: surprising, pieces float back up; silly, Baron's moustache twirl and squeaky deflation loops; funny failure, a balloon piece bobs up into your spawn and Baron laughs so hard he spins; big moment, the deflation loop round the fair and the bouncy castle.

```json
{ "schema": 1, "id": "tumble_fair_05", "biome": "tumble_fair", "tier": 5, "name": "LVL_TUMBLE_FAIR_05_TITLE",
  "board": { "width": 6, "depth": 6, "h_play": 12, "down_axis": "-y" },
  "knobs": { "fall.g0": 1.05, "goal.top_out": "rescue", "goal.warnings_max": 1 },
  "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "turntable", "params": { "turn_every_locks": 5, "turn_dir": "cw" } },
             { "id": "mushroom_popup", "params": { "object": "ring", "spawn_every_locks": 5, "spawn_offset_locks": 2, "objects_max": 4 } },
             { "id": "balloon_piece", "params": { "per_bag": 1, "balloon_slow": 0.5, "bob_every_ms": 3000, "active_after_clears": 2 } } ],
  "stars": { "t2": 340000, "t3": 240000 }, "music": "mus_tumble_fair_05",
  "story": { "title_key": "LVL_TUMBLE_FAIR_05_TITLE", "premise_key": "LVL_TUMBLE_FAIR_05_PREMISE", "mascot_role": "watcher", "boss": "baron_balloon", "icon": "balloon" } }
```

---

### B Prize Shelf (bonus, tier 11, 10 island stars)

**Story card.** Bounce finally has enough tickets. Stock the prize booth's stepped shelf in 75 seconds before the booth closes, using exactly six pieces. The giant teddy waits on top. · **Bounce: watcher** (hops from foot to foot).
**Beats.** **I**: the ticket-taker goat flips the booth's sign to a closing-time clock pictogram; Bounce slaps a fistful of tickets on the counter. **P (skits §11.1, 5 s)**: 0.0–2.0 the last prize fits the prize shelf. 2.0–4.0 Bounce reaches for the giant teddy, the shelf tips (`sweat`). 4.0–5.0 the teddy lands on Bounce, hugging it (`heart`). **M**: none. **R**: `sweat` as the clock runs low, `sparkle` on each step filled.
**Stage**: clean, hurried; the inside of a prize booth, the goat's clock as the visible timer. **Light**: tent interior (H). **Music**: `mus_tumble_fair_bonus`.

```text
Recipe: BL01 (6 wide × 2 deep, H4) · AR09 fixed list [I, I, O, L, L, O] · CV01 · GO03 (24 cells, stepped shelf) + CL14 [M2] · FT07 out of pieces · time limit 75 s (extra fail) · WO09
One sentence: "Six pieces, 75 seconds: stock the shelf."
```
**Atoms**: non-default AR09 (**new** on the shortest path), M2 bundle, FT07 (**new** on the shortest path). 3 non-default, 2 new (0 for a player who played a main-biome bonus).
**Encounters**: preview 3. **Known solution**: I along z = 0, x 0–3, layer 0; I along z = 1, x 0–3, layer 0; O flat at x 4–5, layer 0; L flat on layer 1 at (0,0) (1,0) (2,0) (0,1); L flat on layer 1 at (3,0) (1,1) (2,1) (3,1) (the second L is flipped); O flat at x 0–1, layer 2. Dealt in list order, every placement is supported. Cubes above layer 3 are trimmed.
**Goal / fail**: Shape 24 in 75 s; out of pieces or the clock = the booth shutters close (retry is instant). **Stars (hand-set)**: ★★ 50 s; ★★★ 35 s and no cube trimmed. **Length**: ≤ 1.5 min.

```text
targets by layer        side (z = 0)
layer 0  ++++++         4 ============  danger line
         ++++++         2 + + . . . .   top step (O)
layer 1  ++++..         1 + + + + . .   middle step (L + L)
         ++++..         0 + + + + + +   bottom shelf (I, I, O)
layer 2  ++....
         ++....
```
**How it plays**: (1) read the preview (I, I, O) and plan the bottom shelf. (2) Lay both I pieces flat along the back and front rows; the O fills the right end. (3) The two L pieces interlock into the middle step; the second needs a Flip. (4) The last O tops the stack; the teddy wobbles.
**Readability**: each step is outlined in ticket-stub dashes; the goat's clock is the timer (and a HUD ring); the danger line is a strip of bunting.
**Teaches**: a fixed list, read ahead; the second L is the trick (Flip makes the mirror shape). **Wacky test**: surprising, every piece is known but the clock ticks; silly, prizes (a plush duck, a toffee apple) pop onto each filled cell; funny failure, the shutters slam and Bounce's trunk is stuck in them, then pops free; big moment, the teddy hug.

```json
{ "schema": 1, "id": "tumble_fair_bonus", "biome": "tumble_fair", "tier": 11, "name": "LVL_TUMBLE_FAIR_BONUS_TITLE",
  "board": { "width": 6, "depth": 2, "h_play": 4, "down_axis": "-y" },
  "pieces": { "fixed_list": ["i","i","o","l","l","o"] },
  "knobs": { "fall.g0": 0.55, "spawn.preview_count": 3, "goal.top_out": "trim", "goal.time_limit_s": 75 },
  "goal": { "type": "shape", "target_shape": { "layers": { "0": ["++++++","++++++"], "1": ["++++..","++++.."], "2": ["++....","++...."] } } },
  "rules": [ { "id": "fill_shape", "params": { "top_out": "trim" } }, { "id": "piece_budget", "params": {} } ],
  "stars": { "t2": 50000, "t3": 35000 }, "music": "mus_tumble_fair_bonus",
  "story": { "title_key": "LVL_TUMBLE_FAIR_BONUS_TITLE", "premise_key": "LVL_TUMBLE_FAIR_BONUS_PREMISE", "mascot_role": "watcher", "icon": "teddy" } }
```

---

## 7. Hard-track remixes

None. Side islands are 5 levels + 1 bonus (brief §4, skits §11). If the producer later approves remixes, the natural three are "Mirror Spin" (PL10 + BL11), "Bouncy Balloons" (SP35 + EV10) and "Baron's Rematch" (05 at H14 with the mirror).

## 8. Narrative beats

Wordless (campaign story rules; brief §4): intro and payoff skits per level, Bounce's reactions, Baron above the tents from 03. Arc: Bounce wins a ticket (01), slides the helter-skelter (02), meets its reflection (03, the wink; Baron's first peek), spots the giant teddy from the wheel (04), deflates the Baron (05), and wins the teddy (B, which hugs it flat).

- **Mizzle**: one wink only, in 03's payoff backdrop (a violet cuff hands a ticket to the booth; the booth flag is violet; ≤ 1.5 s). No clue, no flag panel, no postcard. **Baron got no gift**: his balloon, rings and spin are his own showing off (lore X6).
- **Map change (3 s, after the 05 payoff; skits §11.1)**: 0.0–1.5 the ferris wheel lights. 1.5–3.0 a bouncy castle appears beside it.
- **Cloud charm**: a balloon (Scrapbook keepsake tab, one of the 4 charms).

## 9. Music and audio cues

One track per level, supplied by the user (no stems). Ids are placeholders; until a track exists the level falls back to the biome's `default_music` (`mus_tumble_fair_default`, a warning, not a failure). "Carefree" is a placeholder only.

| Level | Track id | Mood brief for the track |
|---|---|---|
| 01 | `mus_tumble_fair_01` | Warm barrel-organ waltz, unhurried |
| 02 | `mus_tumble_fair_02` | Bouncy oom-pah with slide whistles |
| 03 | `mus_tumble_fair_03` | Wonky funhouse tune, slightly detuned, playful |
| 04 | `mus_tumble_fair_04` | Gentle carousel lilt, a creak on the turn (SFX, not in the track) |
| 05 | `mus_tumble_fair_05` | Pompous brass march for the Baron; fireworks pops are SFX |
| B | `mus_tumble_fair_bonus` | Ticking closing-time galop |

Cues (SFX, not music): a carnival "ding" when a ring lands, a spring "boing" on a tent bounce, a mirror shimmer and giggle when a twin is written, a creak one lock before each turn, a balloon squeak on a pop, a long deflating raspberry in the finale payoff. Ambience (under the SFX slider): a far barrel organ, crowd laughter as hums, balloon squeaks, bunting flutter. Danger stinger only where `topout_rule` is rescue (not B). Skits use short stingers, never voices.

## 10. Open questions

- **New atoms**: none needed. Still Proposed here: **PL10**. Candidate (rules to write before build): **SP35**, **EV10**; **BL11** is Designed for MG12 only, so its campaign use needs a check. EV10's `bob_every_ms` and `active_after_clears`, SP35's `bounce_dir_default: "cw"` and EV04's `spawn_offset_locks` are new **params** on existing atoms for the module owner.
- **Side-island structure vs Campaign Structure rule 1** ("exactly 10 levels" per biome): side-island biomes need an exception (5 + bonus, tiers 1–5 + 11), the 10-of-15 bonus gate and the "speed with b = unlock biome, tier 2L" rule above. Owner: game-designer / Campaign Structure.
- **Block set conflict**: visual-direction 3.4 gives **Candy Stripes** (used here); lore 4.1 E gives **Toy Box** (citing a block-art-sets review decision). Art-director to pick.
- **Wink content**: skits §11.1 (cuff hands a ticket to the booth, used), lore 4.1 (cuff wins a ring-toss prize, slot L3, slot used) and visual-direction 2.3 (a violet pennant in the bunting) differ. Narrative-director to confirm.
- **Light journey**: lore gives 6 per-level lights (used); visual-direction gives a 3-preset journey (E, F, G). They are compatible (01–03 E, 04 F, 05 G, B H); confirm the preset count with art-director.
- **Mirror twin on top-out (03)**: twins are trimmed above the danger line and never cause a top-out; confirm in the PL10 rule. Also confirm PL10 + BL11 are compatible if a remix pairs them.
- **Turntable during a warning**: should a rescue warning pause the spin? Default: no (the spin keeps its lock count).
- **Pads under a turn**: none here (02 has no turn); if pads ever ride a turntable, their cw default turns with them.
- **Star times** are formula estimates; replace with playtest medians.
