# Special Blocks and Objects

> **Status**: DRAFT r2 (revision after the round 1 blind panel, `production/qa/quality-review/2026-10-14-special-blocks-r1.md`). Awaiting the round 2 panel.
> **Author**: systems-designer, for the user
> **Date**: 2026-10-14
> **Scope**: every special SHAPE, special BLOCK KIND, platform OBJECT and player-triggered ITEM in Wacky Towers, existing and new
> **Decisions are the user's.** The user decisions in Appendix E are binding. `PROPOSED` marks a recommendation, not a ruling.
> **The 12 biomes** (`assets/data/campaign/catalog.json:3-16`, catalog order): meadow, candy, ice, underwater, pirate, lava, forest, cave, clockwork, neon, celestial, carnival. Dune Bazaar and Tumble Fair are arena skins (`design/levels/dune-bazaar.md`, `tumble-fair.md`), not campaign biomes.

## Work log (r2 resume point)

Fix numbers are those of the merged list in the round 1 report.
- Batch 1 (this file): header, conventions, status-by-cause table (3.1b), shape entries SH-01 to SH-13 (fix 4, 7, 10).
- Batch 2: block kind entries (goo redesign, anchored fixes, ART-CHECK resolved, badge fixes) (fix 4, 7, 9, 10).
- Batch 3: object entries (core, cargo, rival, new objects OB-40 to OB-43), item entries (fix 1, 2, 7).
- Batch 4: interaction matrix rebuilt, 3.4 biome matrix and introduction order, 3.5 reference coverage, 3.6 readability, 3.7 gap sizing (fix 5, 8, 9, 10).
- Batch 5: formulas F1 to F12, edge cases, knobs (fix 3, 6).
- Batch 6: acceptance, 8.1 first 12 (incl. h2, h3), Appendices B, D, E, F (fix 1, 3, 10).
- Status at the time of writing this line: batch 1 in progress. Later lines below are updated as batches land.
- Other files were not edited. The registry and other GDDs still need the follow-up edits (see Appendix B, decision 5).

## 1. Overview

This document is the one catalogue of every thing in Wacky Towers that is not a plain block. It has four groups.

- **(a) Special SHAPES.** Falling pieces whose form is the power. A ring can drop over a pillar. A hook can hang. The jack touches a cell on all six sides.
- **(b) Special BLOCK KINDS.** One cell that carries a power: bomb, sticky goo, bouncy pad, ice, key, gem, egg, and more. A kind lives in `assets/data/content/blocks.json` (24 kinds today).
- **(c) OBJECTS.** Things on the platform that are not falling pieces: critters, cargo, switches, anchors, hazards, pickups and NPC props.
- **(d) Player-triggered items.** Power-ups the player taps: the 8 item-strip items and the 4 character skills.

Each entry says what it does in game-builder words, gives its exact rule, how it must look at phone size, how it sounds, where it fits in the 12 biomes, how it is taught, how it can be unfair, and whether the engine already has it. Entries marked EXISTS point at `file:line`. Entries marked PARTIAL or NEW state the gap, its size and its owner.

Basis for this pass (read in full or in part): `design/levels/levels.md`, `level-identity-spec.md`, `minigame-party-rules.md`, `reference-quality-bar.md`, `design/gdd/piece-set.md`, `block-status-effects.md`, `items.md`, `skills.md`, `obstacles.md`, `src/mechanics/README.md`, the rule plugins under `src/mechanics/`, `assets/data/content/blocks.json`, `assets/data/shapes/families.json` and `shape_bank.tres` (67 shapes, 10 families), `assets/data/items/starter.json`, `assets/data/meta/abilities_runtime.json`, and the reference boards listed in Appendix A.

Limits of this pass, stated plainly: the session had no shell, so no PIL crops were made. Images were opened whole with Read. `wt_block_materials.gd`, `biome_looks.json` and `tools/qa/block_gallery.gd` were located but their art detail is cited from the existing docs, not re-read. Items that need that detail are tagged `ART-CHECK`.

Rules this document obeys: no "clear N layers" goal; pieces speed up instead of a timer on Tetris-variant levels; every special must pass the 0.5 s read test; the references give style and ideas only, never names, logos or IP; no beige UI; no "Tetris" naming.

## 2. Player Fantasy

"Every block has a personality." The player should feel like a toy-box builder, not an accountant.

- A bomb block makes them grin and then plan: where do I put this so the boom helps?
- A bouncy pad makes the whole board giggle. A lamb flies. Nothing is lost for long.
- A key is a little hunt: find the lock, carry it there, open the thing. A gem is a treat to chase.
- Hazards (goo, pests, hail) are naughty, not cruel. They always warn first, and a clear always has an answer.
- Items are a tap-for-a-surprise jackpot earned by a clear.

Pillars served: P2 "the stack is the answer" (every special is solved by stacking, not by a new verb), Readable Chaos (telegraph, then act), The Block Is the Constant (specials are still cubes in the same grid), Variation Over Depth (one new idea per level, never a pile).

## 3. Detailed Rules

### 3.1 Taxonomy and conventions

**Four groups, four id prefixes.** `SH-` shape, `BK-` block kind, `OB-` object, `IT-` item. A trailing `*` in the index marks a NEW item (not in the engine today). Status shells (frozen, vines, honey, burning, crumbling, shadow, spiked) are block kinds carried as a status on a cell, so they take `BK-` ids.

| Group | Test for membership | Example |
|---|---|---|
| (a) SH special shape | The silhouette is the power. Cubes are normal. | ring, hook, jack |
| (b) BK special block kind | One cell has a power. It has a `kind_id` in `blocks.json`, or a status on a normal cell. | candy_bomb, goo, key cube |
| (c) OB object | Not a falling piece. It sits on or beside the platform, or is the platform's own rule prop. It may or may not be a grid cell. | lamb, basket, switch, peg |
| (d) IT item | The player taps it (item strip or skill button). | Bomb item, Smash skill |

**A cell kind versus a rule.** In the engine a kind (`blocks.json`) is only a label and flags (`solid`, `fills_layer`). The behaviour is a rule plugin that reads the kind (`src/mechanics/README.md`). So every BK entry names both. Per-level numbers live in the level's `rules` params, not in the rule JSON (the rule JSONs under `assets/data/rules/` hold only the param schema).

**Conventions used by every entry** (stated once so entries stay short):

1. **Read test.** At 720x1280, one cube is about 28 to 60 px. A special must be identified in 0.5 s by three signals together: (1) a silhouette or top-face change, (2) a looping animation, (3) a rim colour role. Surface texture alone never counts (`block-status-effects.md` look rule). Colour roles: buff rim cyan, debuff rim magenta, hazard rim orange, danger rim red, reward gold, per the art bible override in `piece-set.md`. Every special also carries a distinct icon badge so colour-blind players can tell them apart.
2. **Telegraph rule.** Every hazard shows a warning one lock ahead or at least 2 s ahead before it acts. This is already how `mushroom_popup`, `gumdrop_hail`, `lava_rock_spawn`, `crab_claw`, `quake` and `woodpecker_knock` work. A new hazard must follow it.
3. **Clear rule.** A hazard must have a clear-based or placement-based answer. Where the engine has it, "clear cancels" is used (`goo_spread` `cancel_on_clear`, `crab_claw`, `squirrel_heist`).
4. **Layer fill (corrected in r2).** A layer is full when every ACTIVE cell in it is filled (`layer_full`: `_layer_active[k] > 0 and _layer_filled[k] == _layer_active[k]`, `board_state.gd:200-201`). A cell with `fills_layer` true that holds a cube is filled. An active cell with `fills_layer` false that holds a cube is NOT filled, so it BLOCKS its layer (this is how the grumpy moody cube works, `moody_cube.gd:16`). Only a cell with the status `static_geometry` leaves the active count (`board_state.gd:94-96, 373-377`), so it neither fills nor blocks. Rock and shelf are `fills_layer` false plus `static_geometry`. Each entry states which applies.
5. **Rescue.** The soft rescue calls `wipe_bottom`, which removes cells with `Cause.RESCUE` (`board_state.gd:601-608`). `fixed` and `anchored` cells are NOT wiped (`can_remove`, `:685-688`). Everything else in the wiped layers is wiped, including gems, eggs, moles and locked cubes. The status-by-cause table in 3.1b is the one source of truth. A rescue never collects an item cube or a gem (a wipe is not a clear). A NEW flag `rescue_safe` protects goal objects (3.1b).
6. **Top-out line.** A special inside the danger band counts as stack height like any cube, unless it is `static_geometry` (then it adds none, as the masked columns of meadow_01 do).
7. **Audio ids.** The cue list uses `SFX_<AREA>_<THING>` with areas `SP` (special piece), `EV` (level event), `PL` (physics or landing twist), `FT` (fail type), `BOSS`, `MASCOT` (`sfx-cue-list.md` section 1). Where a cue already exists it is cited by that id (for example `SFX_SP_EGG_HATCH`, `SFX_SP_CHICK_HOP`, `SFX_SP_EGG_BONUS`, `SFX_EV_MUSHROOM_POP`, `SFX_PL_STICKY_SPLAT`, `SFX_SP_FOG_GHOST`, `SFX_PL_WOBBLE_SLIP`). Where it does not, entries give a proposal `SFX_SP_<NAME>` and mark it `AUDIO-NEW`. Short names in the shape entries above (for example `ring_fit_chime`) are shorthand for `SFX_SP_RING_FIT` and so on. The count of 79 rows in the cue list must be updated by the audio director when these are accepted. Style rule from the cue list: cute toybox, soft, wood, felt, rubber, bells; no gore or horror.
8. **Biome skins.** A kind keeps one silhouette and one badge in every biome. The biome only changes material and palette. The block sheet `biome_block_materials_ref.png` shows 12 skins: meadow, candy, ice, underwater, lava, forest, cave, clockwork, neon, celestial, plus Tumble Fair (striped tent) and Dune Bazaar (sandstone). The sheet has NO pirate skin. The campaign has 12 biomes including pirate and carnival (`catalog.json:3-16`). So pirate needs a block skin (gap, art-director; Appendix 3.4 lists it) and carnival can reuse the Tumble Fair skin. Skin names below are proposals.
9. **Readability rules (r2).** Three more rules apply to every entry; section 3.6 has the detail.
   - **See-through:** a goal object (gem, key, critter, cargo, core) draws a gold silhouette outline through cubes in front of it.
   - **Badge sheet:** each special has one badge shape that no other special and no biome hero ornament shares. The badge list is in 3.6. Where an entry below names a badge, it is the 3.6 badge.
   - **Colour roles:** buff cyan, debuff magenta, hazard orange, danger red, reward gold. A reward block never takes the hazard colour. A warning mark on the board uses hazard orange, never the object's own rim.
10. **Ids and counts (r2).** One id is one entry. Grouped headings carry several ids. Appendix F lists every id with its status; Appendix D is computed from it.

**Counting rule.** One id is one entry. A mirror pair (hook_left and hook_right) shares one id. A family of identical-behaviour variants (frosting and frosting_three, the four helpers, the four heavy shapes) shares one id. The status shells have their own ids (BK-22, BK-23a to BK-23f). Appendix F is the index.

### 3.1b Removal and protection: status by cause (engine fact, r2)

Source: `can_move` and `can_remove` (`src/core/board/board_state.gd:677-695`), `remove` (`:335-355`), `wipe_bottom` (`:601-608`), clear order (`src/core/sim/board_sim.gd:1421-1436`). The causes are `Cause { CLEAR, DISPLACED, DAMAGE, MASKED, TRIM, RESCUE }` (`board_state.gd:24`).

What each cause means in this game:
- **CLEAR:** a full layer clears (`board_sim.gd:1429-1435`).
- **DISPLACED:** a rule moves or deletes a cube: quake, woodpecker, squirrel, claw, bubble pop, a `place` over an occupied cell.
- **DAMAGE:** a bomb blast, item bomb, Smash, ember melt, pest bite, frosting peel.
- **TRIM:** tilt slip, wobble pop-off, trim top-out.
- **RESCUE:** the soft top-out wipe.
- **MASKED:** a mask or floor change. Always removes (`:683-684`).

| Status on the cell | CLEAR | DISPLACED | DAMAGE | TRIM | RESCUE | MASKED | Can move (slides, belts, collapse) |
|---|---|---|---|---|---|---|---|
| none (plain cube) | Y | Y | Y | Y | Y | Y | Y |
| `fixed` | N | N | N | N | N | Y | N |
| `anchored` | N | N | Y | N | N | Y | N (unless forced) |
| `clear_protected` | N | Y | Y | Y | Y | Y | Y |
| `locked` | N | N | Y | Y | Y | Y | N |
| `vined` | Y | Y | Y | N | Y | Y | Y |
| `hits_left` or `hp` above 1 | as other flags | as other flags | H (loses 1, stays) | as other flags | as other flags | Y | as other flags |
| **NEW `hung`** | Y | N | Y | N | Y | Y | N |
| **NEW `blast_safe`** | Y | Y | N | Y | Y | Y | Y |
| **NEW `rescue_safe`** | Y | Y | Y | Y | N | Y | Y |

Y = the cell is removed. N = blocked. H = the hit counter drops by 1 and the cell stays (`board_state.gd:341-348`).

The cells the engine already builds, from their code:

| Cell | Flags set (source) | Result |
|---|---|---|
| rock, shelf | `fixed`, `static_geometry`, `anchored`, `clear_protected`, `fills_layer` false (`rock_obstacle.gd:20`, `anchored_shelf.gd:20`) | Only MASKED removes it. Not wiped by rescue. Not an active cell. |
| sponge | `anchored`, `clear_protected`, `fixed` via `CandyCells.protect` (`candy_cells.gd:49-50`) | Only MASKED removes it. Still an active cell that counts as filled. |
| licorice | `anchored`, `clear_protected` (`licorice_lock.gd:9`) | Removed only by DAMAGE and MASKED. A blast or Smash removes it. A rescue does not. |
| climber boss | `anchored`, `clear_protected`, `boss` (`climber_boss.gd:42`) | Removed by DAMAGE and MASKED. Not wiped by rescue. It cannot be `fixed` because it moves with `force` (`:52`, and `remove` refuses force on `fixed`, `board_state.gd:338`). |
| frosting, frosting_three | `clear_protected`, `frosting_layers` (`frosting.gd:10`) | A clear does not remove it; the peel hook lowers the coat count. DAMAGE removes it at once (no `hp` key). Rescue wipes it. |
| locked cube | `locked` (`locked_cube.gd:16`) | CLEAR and DISPLACED blocked until unlocked. DAMAGE and RESCUE remove it. A blast removes a locked cube. |
| grumpy moody | `clear_protected`, `fills_layer` false (`moody_cube.gd:16`) | Blocks its layer. Rescue wipes it. |
| rock from a geyser | `rock`, `clear_protected`, `fills_layer` false, `hits_left` 2 (`lava_rock_spawn.gd:27`); NOT `fixed`, NOT `anchored`, NOT `static_geometry` | Blocks its layer (active cell, not filled). CLEAR is blocked. DAMAGE counts `hits_left` down, then removes it. Rescue and DISPLACED remove it. Adjacent clears hit it (`_hit_adjacent`). |

Rules taken from the table (they replace the r1 text):
1. **`anchored` is a "stay put" flag, not a "survive everything" flag.** It blocks clears, rescue, displacement and trim. It does not block DAMAGE. So a blast, the item bomb, Smash and ember all remove anchored cells. `earned_specials.gd:18` skips anchored cells on purpose; the item bomb and Smash do not (`wt_abilities.gd:202` skips only `fixed` and `locked`). This is a gap (3.7, GAP-3).
2. **`anchored` cannot be used for a hung cube or a protected gem.** An anchored cell can never be cleared. A hung cube must still clear, and a gem must be collected by a clear. So the doc uses three NEW flags, each one line in `can_remove` and `can_move`. Size 0.5 day, owner lead-programmer (core file), gameplay-programmer (tests).
   - `hung`: blocks DISPLACED, TRIM and moves. It does not block CLEAR, DAMAGE or RESCUE. It has a lock counter (`hung_locks`) and the rule that sets it removes it.
   - `blast_safe`: blocks DAMAGE only.
   - `rescue_safe`: blocks RESCUE only.
   - A level sets `blast_safe` and `rescue_safe` together as `goal_object` on gems, keys, critters and cargo while a goal needs them.
3. **A hung cube floats.** `hung` blocks moves, so if the cubes below clear, the hung cube stays in place until the lock counter ends, then the rule requests a settle. That is the intended read: the cube "hangs".
4. **Rescue does not wipe `fixed` or `anchored` cells.** It does wipe gems, eggs, chicks, moles, goo, frosting, locked cubes and plain cubes unless they carry `rescue_safe`.
5. **`on_clear` hooks run before the removal test** (`board_sim.gd:1421-1430`). So frosting peel, locked unlock and licorice untie run when a layer is full even though those cells survive the clear.

### 3.2 Catalogue (one entry per item)

Field order for every entry: **What** / **Rule** (trigger, effect, duration, layer fill and clears, gravity, other specials, rescue and top-out) / **Look** / **Audio** / **Fits** / **Intro and teach** / **Fairness** / **Engine** / **Source** (reference). Biomes use the 12 in `levels.md` plus the two extra sheet biomes (tumble fair, dune bazaar) where a skin exists.

#### 3.2.a Special SHAPES

The bank has 67 shapes in 10 families (`assets/data/shapes/families.json:4-92`, `shape_bank.tres`). Per `piece-set.md` Core Rule 6, tags never change a shape's cubes, and biomes never add shapes. A shape is "special" here because its form gives it a rule effect or a level job. Most shape powers need a platform object to bite on (a peg, a pillar, a pocket), which is why shapes and objects are specified together.

**SH-01 ring, SH-02 arch, SH-03 loop (hollow family)**
- **What.** Pieces with a hole through them. The ring is 8 cubes (`shape_bank.tres:634-643`, 3 distinct orientations). The arch is 7 (`:22-31`, 12). The loop is 6 (`:351-360`, 4). In a ring-toss level they drop over a post and score. Anywhere else they are a risk, and the bag gate below keeps them out.
- **Rule.** The hole is made of ordinary empty cells. An enclosed empty cell is an active cell that is not filled, so its layer cannot be full until something fills it (`board_state.gd:200-201`). That is a real hazard:
  - A flat ring (hole axis vertical) leaves an open shaft. Only a 1x1 cross-section fills it (mono, or the end of a standing i or duo).
  - An upright ring (hole axis horizontal) leaves a pocket no falling piece can reach. It blocks its layer until a rescue wipes it.
  - So the validator rejects any bag with a hollow piece unless the level has a `peg` goal (below) or sets `pocket_ok` and the solver (G5) proves a way out. `mascot_catch` (README line 27) can veto one covered-hole lock per catch.
  - NEW fit rule with a goal behind it: a `peg` (BK-40) is a solid post. No piece may overlap it, except a hollow piece whose hole axis lines up with it. A ring that locks around a peg is a "fit". It emits `ring_fit`, scores `fit_points` (150) and adds 1 to the `ring_toss` counter. A new goal evaluator `ring_toss` wins when `pegs_needed` pegs each hold a ring.
  - Peg cells are `static_geometry`, so a fitted ring leaves no pocket.
  - Lock timing is not changed (the r1 "locks early" line is removed).
  - Gravity normal. Rescue wipes ring cubes like any cube. A peg is `fixed` and stays. Top-out normal.
- **Look.** Hue is Hollow lime `#9FD65B` (`piece-set.md`). The hole is a bright open rim. The ghost shows a gold "fits here" ring on a peg, and a red dot in any enclosed cell it would leave. Badge: a ring-and-post icon (3.6).
- **Audio.** `SFX_SP_RING_FIT` (AUDIO-NEW) on a fit, normal land otherwise.
- **Fits.** carnival (Ring Toss Rally, `catalog.json` carnival_01), candy bonus (lollipop pegs), pirate (belaying pins). `piece-set.md` lists pillar levels. It is not in the first 12 levels (Appendix E). Intro slot: 3.4.
- **Intro and teach.** carnival_01 (`catalog.json:2066`): one peg, no pressure, the looping preview of a ring dropping over a post, and the hint "Drop the ring over the post!" (under 12 words).
- **Fairness.** Risk: a ring makes a pocket that blocks a layer. Counterplay: the bag gate above, the red-dot ghost, `ring_weight` 0 in levels without a peg goal, and the solver check (G5). A pocket caused by a ring never counts as a wasted piece in stars.
- **Engine.** PARTIAL. Shapes EXIST. The peg collision rule changes the core movement path (an aligned-hole overlap exception), so it goes to lead-programmer. The `ring_toss` goal is a new evaluator. Size in 3.7 (GAP-6).
- **Source.** `piece-set.md` ("rings drop over pillars"); ring-toss and posts at a fair (carnival plan `design/levels/plans/carnival.md`, level 01 "Ring Toss Rally"); the arch piece in play on `style/14_tournament_flow.png`.

**SH-04 giant_ring (giant family)**
- **What.** A 12-cube ring (`shape_bank.tres:216-225`). It is a boss-sized ring. It is the only shape that can surround a whole platform feature such as the Hearth Stump or a 2x2 pillar.
- **Rule.** As SH-01, plus it spans up to 3 layers. Weight is very low (Giant family: "low weight", `piece-set.md`). Allowed only where the level lists it.
- **Look.** Blackberry `#6E4F9E`, thick gold rim so it reads as a trophy.
- **Audio.** `giant_ring_land` (deep thud plus chime).
- **Fits.** celestial finale (orbit ring around a planet prop), carnival finale (`carnival_10`). Pirate wheel skin is optional.
- **Intro and teach.** Only in biomes 11 and 12, after the ring-toss lesson (3.4). Shown in the NEXT strip with a "big" pulse for 2 s before it spawns. Same pocket rules as SH-01, so it only spawns in a level with a peg goal.
- **Fairness.** Risk: 12 cubes can bury a stack. Counterplay: spawn only when the stack is at or below half height (knob `giant_max_height_frac`, section 7).
- **Engine.** Shape EXISTS. Spawn gate NEW, 1 day, gameplay-programmer.
- **Source.** None (ours).

**SH-05 hook_left and hook_right (pento_3d)**
- **What.** 5-cube hooks (`shape_bank.tres:258-280`, 24 orientations each). A hook can catch on a ledge, branch or rail.
- **Rule.** Trigger: a hook cube locks directly under or beside a `hang` point (BK-42: branch, rail, rope loop) while another cube of the piece rests on support. Effect (NEW): the whole piece gets the NEW `hung` status for `hang_locks` (4) locks (3.1b). `hung` blocks DISPLACED, TRIM and moves. It does NOT use `anchored`, because `anchored` blocks CLEAR and RESCUE (`board_state.gd:685-688`), and a hung cube must still clear in a full layer.
  - What a hung cube resists: quake and woodpecker (DISPLACED), tilt slip and wobble pop-off (TRIM), belt and turntable moves and settle after a clear (moves).
  - What it does not resist: a clear, a blast, Smash, a rescue wipe (3.1b).
  - It is never permanent. The rule removes `hung` when the counter ends and requests a settle.
  - The stake: in a level whose threat is tilt, quake or belt, a hung piece is the player's one reliable answer. A level may require it (a "hold the beacon" cell that quake targets).
- **Look.** Lavender `#A78BEB`. A brass hook badge. While hung, a thin gold outline and a rope line to the hang point; the outline fades over the last lock.
- **Audio.** `SFX_SP_HOOK_CLINK` (AUDIO-NEW).
- **Fits.** forest (branches), clockwork (rails), cave (stalactites), carnival (tent rope). Pirate (rigging) once its block skin exists.
- **Intro and teach.** forest_07 "Leaf-Swept Branch" (`catalog.json:1213`), a wind and branch level (3.4). The hang point glows and the hint is "Hook it on the branch!".
- **Fairness.** Risk: a player ignores it and loses to the threat. Counterplay: the level shows the threat telegraph and the hang point together, and hook pieces appear at least once per bag in that level (`hook_per_bag` 1).
- **Engine.** PARTIAL. Shapes EXIST. The `hung` flag, the hang rule and the hang point are NEW (3.7, GAP-3 and GAP-7).
- **Source.** Ropes and hooks on rope bridges in the jungle and pirate boards (Bridge Rush, `mockup_10.jpg` and `mockup_12.jpg`; scene names cited because file attribution for the early mockups is uncertain, Appendix A).

**SH-06 claw_left and claw_right (pento_3d)**
- **What.** 5-cube claws (`shape_bank.tres:93-115`). A claw grips a bump on the stack.
- **Rule.** NEW. A claw piece carries the piece flag `braced` while it falls. `braced` cancels the next push on that piece: one gust, one magnet pull, one ice slide or one bounce hop (the landing arbiter R-2 reads it). It is spent by the first push it cancels. A claw whose claw-cube lands beside an existing cube with contact on two opposite faces also gets `hung` for 2 locks (3.1b). Clears normal.
  - **What the claw answers:** push hazards. It does NOT answer the crab claw hazard. That hazard steals a top cube (`crab_claw.gd:36-40`) and is answered by a clear.
  - The stake: in a level with a current, gust or magnet (underwater_03, `catalog.json:600`), a braced claw is the way to place a piece exactly where you aim.
- **Look.** Lavender, with two pincer tips tinted gold. A small brace badge on the grip cube. The braced state shows a gold ring on the piece.
- **Audio.** `SFX_SP_CLAW_GRIP` (AUDIO-NEW).
- **Fits.** underwater (current), clockwork (belt), ice (slide), cave.
- **Intro and teach.** underwater_03 "Current Lane" (3.4). Hint: "Claw pieces hold against the current."
- **Fairness.** Pure help, with a stake. The first claw piece of the level arrives in the first bag.
- **Engine.** PARTIAL. Shapes EXIST. The `braced` flag and R-2 arbiter are NEW (3.7, GAP-2).
- **Source.** The crab and shell props on `underwater_biome_sheet_ref.png` for the look only. The rule is ours.

**SH-07 jack (chunky)**
- **What.** A 7-cube cross with one orientation (`shape_bank.tres:298-307`, `families.json:67`): a centre cube with one cube on each of its 6 faces.
- **Rule.** Resolved from the shape data: the jack is a centre cube with one cube on each of its 6 faces, 7 cubes in a 3x3x3 box, with 1 distinct orientation (`shape_bank.tres:298-307`). It spans 3 layers: the middle layer gets 5 cubes, the top and bottom get 1. NEW power "pin": when the jack's lowest arm lands in a 1-cell hole, the whole piece gets `hung` for 3 locks (3.1b: blocks belt moves, quake, tilt slip, and settle). It still clears, still takes blasts, and is still wiped by rescue.
  - The stake: in a belt or conveyor level (clockwork_03 Tram Street) a pinned jack is the one piece the belt cannot move.
- **Look.** Cocoa `#9A6A4A` family, with a bright orange centre bead so the centre reads. Badge: a pin icon.
- **Audio.** `SFX_SP_JACK_PIN` (AUDIO-NEW).
- **Fits.** clockwork (belt), carnival (toy jacks), cave.
- **Intro and teach.** clockwork_03 (3.4), a platform with a single 1-cell hole at the belt start.
- **Fairness.** Risk: 3 layers tall. It only spawns when at least 3 free layers exist above the stack (spawn gate, as SH-04).
- **Engine.** PARTIAL. Shape EXISTS. The pin rule uses the NEW `hung` flag (3.7, GAP-3). The arm length ART-CHECK is closed above.
- **Source.** None.

**SH-08 pole (long bar)**
- **What.** A 6-cube straight bar (`families.json:83-85`, `shape_bank.tres:621-630`). `pento_i` is the 5-long cousin.
- **Rule.** Existing: the longest extent is 6, above the default cap of 4, so the board spawn clearance grows to 6 (`piece-set.md` F2 and edge cases). A pole is the natural "bridge" piece for `span` goals (meadow_08, meadow_h1).
- **Look.** Cobalt `#5468D8`, with a striped barber-pole pattern so length reads.
- **Audio.** `pole_land`.
- **Fits.** Meadow 03 (cart plank), 08 (lily pads), h1 (rope bridge), pirate (plank), carnival (high-striker pole).
- **Intro and teach.** Opt-in per level only.
- **Fairness.** Risk: spawn clearance 6 may fail the board-height readability check. Counterplay: the validator in `piece-set.md` Edge Cases already fails or warns.
- **Engine.** EXISTS.
- **Source.** None.

**SH-09 mono, duo, tri_straight, tri_corner (helpers)**
- **What.** 1 to 3-cube fillers (`families.json:24-29`). Mono is 1 cube, 1 orientation (`shape_bank.tres:364-373`).
- **Rule.** Existing: helper drops from the `helper_drop` item or perks. Mono is also the body of the moody cube (`moody_cube.gd:9`) and the carrier of single-cell jobs.
- **Look.** Mint, plainer, dice pips (`piece-set.md`).
- **Audio.** `helper_land` (soft).
- **Fits.** Teach levels, rescue after a mistake, the final cell of a fill goal.
- **Intro and teach.** Level 01 onward.
- **Fairness.** They are the fairness valve. They are never given as a penalty.
- **Engine.** EXISTS.
- **Source.** None.

**SH-10 big_cube, giant_mega_cube, giant_slab, giant_fridge (heavy shapes)**
- **What.** Big blocks: big_cube is 8 cubes (2x2x2, 1 orientation, `shape_bank.tres:36-45`). giant_mega_cube is 27 (3x3x3, `:202-211`). giant_slab is 9 and giant_fridge is 12 (`:188-239`).
- **Rule.** NEW tag "heavy": a heavy piece counts each cube as `heavy_weight` (2) in the tilt plate sum (F7). The engine counts every cube as 1 today: `measure` takes cells only (`tilt_plate.gd:72-86`) and `weighted_cells` returns cells (`:57-68`), so weights need a signature change (3.7, GAP-5). On landing, a heavy piece closes up to `max_crush` (default 3, `anvil_drop.gd:37`) gap cells under each column, as `anvil_drop` does for flagged spawns. Heavy shapes make the flag permanent per shape.
  - **Spawn gate for ALL heavy and giant shapes** (r2): a heavy shape spawns only when the plate tilt `tau` after a worst-case landing would stay under the warning line (`warn_at` x `slip_threshold`), computed with F7 for the shape's cube count at weight 2 on the heavy side. The level validator also caps heavy shapes at `heavy_per_bag` 1. The 8-cube big_cube at weight 2 is 16 weight units; the 27-cube mega cube is 54, which tips most plates at once, so it is never allowed in a tilt level.
- **Look.** Blackberry or Lemon, with a cast-iron weight stripe and a kg badge. Landing shakes the camera a little (reduced under reduced motion).
- **Audio.** `SFX_SP_HEAVY_THUD` (AUDIO-NEW).
- **Fits.** meadow_09 (counterweights on the high side), clockwork (weights), cave. Pirate (cargo) once its skin exists.
- **Intro and teach.** In meadow_09 the player teaches themselves with the tilt gauge (the frame's "new thing" is `tilt_plate`). Heavy shapes are held back to meadow_10 phase 3 and clockwork, so meadow_09 has one new package (F1, Appendix E).
- **Fairness.** Risk: a heavy piece in the wrong place tips the plate at once. Counterplay: the spawn gate above and the tilt gauge previewing the landing tilt with the ghost (3.7, GAP-8).
- **Engine.** PARTIAL. `anvil_drop` EXISTS (`src/mechanics/wave3/anvil_drop.gd`). The heavy tag in tilt sums is NEW (GAP-5).
- **Source.** None.

**SH-11 dented_cube (chunky)**
- **What.** A 7-cube block with a dent (`shape_bank.tres:147-156`, 8 orientations). The dent is a ready-made pocket for a small thing (egg, gem, key).
- **Rule.** No new rule (r2: the r1 "nest" power is cut, it had no way to place an egg in the dent). The dent is an open one-cell hollow with a floor, a shape for level designers. A level may place an egg (BK-03), gem (BK-33) or key piece target in a dent cell with `starting_contents`, or spawn an egg into it with `mushroom_popup` and `object_kind: egg`, which already picks free supported cells (`mushroom_popup.gd:29-31`). Protection comes from the normal flags: a gem or egg there can carry `goal_object` (3.1b).
- **Look.** Cocoa, with a visible bowl-shaped dent and a soft inner light.
- **Audio.** Normal land.
- **Fits.** meadow (nest), forest, candy (cupcake).
- **Intro and teach.** With the egg kind (BK-03) in meadow_h3 (3.4).
- **Fairness.** Pure help.
- **Engine.** EXISTS (shape only, no rule).
- **Source.** None.

**SH-12 party set: heart, mushroom, rocket, dog_bone, crown, snake_left, snake_right**
- **What.** Seven novelty silhouettes (`families.json:74-82`). Counts: heart 6, mushroom 7, rocket 8, dog_bone 8, crown 8, snakes 6 each (`shape_bank.tres`).
- **Rule.** Existing: they are normal pieces in party and tournament sets. NEW "power by form" proposal: **rocket** may launch (SH-13 below). The rest stay purely visual so the set reads as fun, not as rules to memorise.
- **Look.** Strawberry `#EE7A8C` family; biome skins apply.
- **Audio.** Normal land sound plus a unique 0.3 s landing sting per shape.
- **Fits.** Tournament, party, carnival, candy.
- **Intro and teach.** Not taught. They have no rule.
- **Fairness.** Some are awkward to tile; tournament bags use the shared seed, so all players get the same shapes (`minigame-party-rules.md` rule 8).
- **Engine.** EXISTS.
- **Source.** The party boards show novelty-shaped blocks (`party_modes_ref.jpg`, Appendix A).

**SH-13 rocket (power by form)** `*`
- **What.** The party "rocket" (8 cubes, 6 orientations, `shape_bank.tres:648-657`) gets a thruster on its own button.
- **Rule.** NEW. Only in race and tournament levels that list `rocket_boost`. The extra verb is one gem button (`minigame-party-rules.md` rule 3: at most one extra verb, shown as a single gem button). The button is NOT a double tap on drop (r2: hard drop is already on that gesture, and the verb would only exist while a rocket falls). The button is on screen the whole level and lights up only while a rocket piece is falling. Effect: once per rocket, the piece moves 3 cells in its last move direction (blocked cells stop it), then falls normally. It never exists in the campaign Chapter 1 levels (Appendix E) and is off in plain levels.
- **Look.** Strawberry, with a flame decal. The gem button glows while a rocket falls. Badge: a rocket flame.
- **Audio.** `SFX_SP_ROCKET_BOOST` (AUDIO-NEW).
- **Fits.** tournament rounds, neon, celestial, carnival. Not the Meadow bonus (the kite race keeps the single basket verb set of `levels.md:386-415`).
- **Intro and teach.** The first tournament race round. The gem button pulses once at the first rocket.
- **Fairness.** Optional boost. Never required.
- **Engine.** NEW. 2 days, gameplay-programmer (command) plus ui-programmer (button).
- **Source.** Party minigame boards (dash and boost verbs).

**SH-14 mirror pairs (screw, twist, kink, wiggle, periscope, snake)**
- **What.** Left and right versions that cannot be rotated into each other (`piece-set.md` Core Rule 4).
- **Rule.** Existing. Special use NEW: the `mirror` rule (`src/mechanics/behaviour/mirror.gd`) already adds mirrored copies; a level can use the pair as a "which hand" puzzle.
- **Look.** Left versions have a counter-clockwise spiral motif, right versions clockwise. A small L or R tab sits on the top face in tutorial levels only.
- **Audio.** Normal.
- **Fits.** Mirror levels (ice, neon), any chapter 2+ level.
- **Intro and teach.** One pair per level at most.
- **Fairness.** The solver must treat them as separate. Counterplay: a swap item or a helper.
- **Engine.** EXISTS.
- **Source.** None.
#### 3.2.b Special BLOCK KINDS, part 1: meadow and living things

Baseline kinds that are not special (listed so the registry is complete): `block` (kind 1, plain piece cube) and `starter` (kind 2, glyph `#`, a level-placed plain cube). Both `solid`, both `fills_layer` true (`assets/data/content/blocks.json:3-22`). Everything below is also in `blocks.json` unless marked `*`.

**BK-01 mushroom (kind 3, glyph `m`)**
- **What.** A springy toadstool that pops up on a free surface after a sparkle warning. It is a small obstacle that you build around, or clear.
- **Rule.** Trigger: every `spawn_every_locks` (5) locks. One lock before, a free surface cell is marked and a sparkle shows (`mushroom_popup.gd:26-38`). Effect: on the next due lock the cell becomes a mushroom cube, unless it was filled, then the spawn is cancelled with `mushroom_cancelled` (`:19-25`). Limits: at most `objects_max` (4) mushrooms on the board; only cells at least 4 layers below the limit and with something or nothing-active under them (`:30`); `place_mode: lowest` restricts to the lowest candidates. Fill: `fills_layer` true, so it counts toward layers and clears with them (`blocks.json:23-32`). Gravity: it is placed on a supported surface and then behaves like a normal cube in slice collapses. Other specials: `object_kind` lets the same rule spawn any registered kind (`:16`), so the same warning and cap machinery spawns goo or a pest later. Rescue: wiped like any cube. Top-out: counts as height.
- **Look.** Red cap with cream spots, a bouncy idle squash every 1.5 s, a rim of hazard orange only while it is a warning mark (sparkle). Skins: meadow cap, candy gumdrop-mushroom, forest moss cap, cave glowing fungus, underwater anemone, neon holo-cap. Never a plain cube silhouette.
- **Audio.** `SFX_EV_MUSHROOM_SPARKLE` (warn) and `SFX_EV_MUSHROOM_POP` (spawn), both in `sfx-cue-list.md:85-86`.
- **Fits.** meadow_h2 (the h2 remix kind, Appendix E), forest, cave, candy. (The legacy file `src/levels/meadow/meadow_04/meadow_04.json:50` still lists it, but the `levels.md` frame makes meadow_04 the sheep drive.) Rule layer: twist (`assets/data/rules/mushroom_popup.json:5`).
- **Intro and teach.** meadow_h2 (3.4). The sparkle teaches by itself; hint "Sparkle means something is growing here."
- **Fairness.** It can pop into a spot you wanted. Counterplay: the cell is shown a full lock ahead, and a piece placed there cancels the spawn.
- **Engine.** EXISTS (`src/mechanics/behaviour/mushroom_popup.gd`). View for sparkle and squeak is in the Meadow cue list. No gap.
- **Source.** Own idea from the meadow set; the toadstool-style prop appears in the biome and party boards (`party_biome_islands_ref.jpg`, Appendix A).

**BK-02 sprout (kind 4, glyph `^`)**
- **What.** A seed that grows upward as you place pieces. It builds a living column.
- **Rule.** Trigger: every `grow_locks` (4) locks. One lock before, a bud shows (`sprouts.gd:46-47`). Effect: if the cell above the tip is free and the column has grown fewer than `grow_max` (default 1; 0 means uncapped) cells, a new sprout cube appears above it (`:48-53`). Growth metadata (`sprout_id`, count) is stored on the cube and follows slice collapse, belt and flip moves, even after the root clears (README line 31). Fill: `fills_layer` true, so a growing sprout can complete a layer or block one. Gravity: normal. Other specials: pairs with `mill_belt` and `flip` by design (identity retained). Rescue: the sprout is lost with the plane. Top-out: grows only if free above; it never pushes a piece.
- **Look.** A stalk with a bud and a gold tip. The Meadow HUD already puts a small leaf sticker on the top of every cube (`style/15_title_and_hud.png`), so the sprout badge is NOT a leaf: it is a gold-tipped bud on a stem (3.6). The bud pulses on the warning lock. Skins: meadow beanstalk, candy sugar-cane, forest sapling, underwater kelp, clockwork brass vine, neon circuit-vine.
- **Audio.** `SFX_SP_SPROUT_GROW` (`sfx-cue-list.md:91`).
- **Fits.** meadow_h1 Beanstalk Rescue (the frame's own sprouts level: "Sprouts grow new cells on the stalks as you lock pieces", `levels.md:428`). Forest, celestial garden.
- **Intro and teach.** meadow_h1 is the sprout teach. `levels.md:431-433` says "no new mechanic", but the sprout kind is first used there, so h1 counts it as its one new package (F1). No sprout appears in meadow_01 to meadow_10 or the bonus (Appendix E: teach levels keep core objects only). Hint "The bud grows next lock."
- **Fairness.** Risk: a column grows into the landing space and blocks the spawn row. Counterplay: growth stops when the cell above is not free (`sprouts.gd:45`); the `grow_max` cap; the bud warning. **Telegraph exception:** with `grow_locks` 1 the bud lock and the growth lock are the same lock (`sprouts.gd:46-48` test `_locks % every == every - 1` and `== 0`, both true when `every` is 1). So phase B of h1 ("every lock") has no separate bud warning. This is allowed because growth only adds one cube into a free cell above a tip and never removes or moves anything; the tip of each stalk glows continuously in phase B instead.
- **Engine.** PARTIAL. The rule EXISTS (`src/mechanics/behaviour/sprouts.gd:13-53`). `levels.md:438` says the pace changes "per lamb rescued", and the rule has one `grow_locks` per level, so a per-phase change is NEW (0.5 day, gameplay-programmer; F11).
- **Source.** Our own level plan (h1). Reference mockups show growing vines and jungle (checked in Appendix A).

**BK-03 egg (kind 5, glyph `e`) and BK-04 chick (kind 6, glyph `c`)**
- **What.** An egg that hatches into a chick after a few pieces. The chick hops to the lowest neighbour column, so a chick is a small living thing that finds low ground.
- **Rule.** Trigger: every completed lock ages each egg by 1 (`hatching_eggs.gd:20-24`). At `hatch_locks` (6), the egg is removed and a chick appears at the lowest reachable neighbouring cell in a fixed tie order right, left, forward, back, same cell (`:28-47`). One lock before hatching, an `egg_hatch_warning` plays. Clear bonus: an egg cleared before it hatches pays `egg_bonus` (25) points (`:12-14`). Fill: both are `fills_layer` true (`blocks.json:43-62`). Gravity: the chick lands by the rigid-drop calculation on the neighbour column (`:39-40`). Other specials: a chick next to a goo cell is not protected. Rescue: wiped with the plane. Top-out: a chick can hatch into a danger plane; the spawn simply picks the lowest option.
- **Look.** Egg: cream oval cube with speckles and a faint crack line that grows over the 6 locks (crack stage = age). Chick: yellow puffball with orange beak, hop-in-place idle. Skins: meadow, candy marshmallow-chick, pirate parrot egg, underwater turtle egg, celestial star-egg.
- **Audio.** `SFX_SP_EGG_HATCH`, `SFX_SP_CHICK_HOP`, `SFX_SP_EGG_BONUS` (`sfx-cue-list.md:100-102`). The egg-hatch and bonus cues exist; `SFX_SP_EGG_HATCH` has no file yet (GAP).
- **Fits.** meadow_h3 (the h3 remix kind, Appendix E), candy, pirate (parrot egg), celestial. Pairs with the dent of `dented_cube` (SH-11).
- **Intro and teach.** meadow_h3 (3.4). One egg, hint "It hatches in a few moves." The crack stages teach by themselves. The chick is the egg's output, not a second new kind, so h3 adds exactly one existing kind.
- **Fairness.** Risk: a chick wanders into an awkward cell. Counterplay: it always chooses the lowest, never higher; clear the egg for bonus.
- **Engine.** EXISTS (`src/mechanics/behaviour/hatching_eggs.gd`). View crack stages: gap, 1 day, technical-artist.
- **Source.** Own meadow idea; critters and eggs appear in the party boards (Appendix A).

**BK-05 bounce_pad (kind 7, glyph `b`)**
- **What.** A trampoline cell. A piece that lands on it hops up and slides a cell. It flings the lamb in meadow_08.
- **Rule.** Trigger: the falling piece ends on a pad (any piece cube has a pad directly below it) (`bounce_pad.gd:26-30`). Effect: it fires once per piece (`_bounced`, `:24`). The piece rises up to `bounce_h` (default 2, clamped 1 to 4) cells while free (`:33-37`), then moves one cell in the last move direction (`dir_mode: last_move`) or a fixed `bounce_dir` (`:38-40`). After that the pad is ordinary support (class header, `:2`). Fill: `fills_layer` true (`blocks.json:63-72`). Also spawnable by `lava_rock_spawn` with `object: SP35` (`lava_rock_spawn.gd:21`). Gravity: the hop is a translate against gravity, then normal fall. Other specials (r2, matched to code): `bounce_pad` subscribes to `on_spawn`, `on_command` and `on_land` only (`bounce_pad.gd:9`). It has no check for goo, ice, jelly or any sticky landing. Today the hop, the `jelly_piece` hop and the `ice_slide` each fire once per piece in `on_land` and would add up. The arbiter R-2 (3.3) is NEW and fixes that. A goo veto is NEW too (R-12). A gust is applied while the piece falls, before landing (`gust.gd` subscribes to `on_tick`). Rescue: a pad is a plain cube, so a wipe removes it. Top-out: a bounce cannot lift a piece above the limit (the translate is blocked and `rise` is 0).
- **Look.** A round pink or green cushion on a coil spring, squashes when hit, ripple ring. In meadow it is a dewdrop on a lily pad (the frame's story). Skins: meadow lily-dewdrop, candy gumdrop-bounce, carnival trampoline, underwater jelly-bubble, clockwork spring plate, neon rubber-glow.
- **Audio.** Proposed `SFX_SP_BOUNCE_BOING` (AUDIO-NEW); temp `Retro/Jump.wav` as the mushroom pop does.
- **Fits.** meadow_08 Bouncy Lambs (the whole level, `levels.md:290-318`). Candy, carnival, underwater. A hazard-free fun block.
- **Intro and teach.** meadow_08. First pad sits in the preview strip with an arrow showing the bounce path. Hint 12 words or fewer: "Pads bounce! Plan where the piece lands."
- **Fairness.** Risk: a bounce flings a piece into a gap. Counterplay: the landing marker shows the bounce end (a ghost at the hop end), and it is capped at 4 cells.
- **Engine.** PARTIAL. The pad rule for pieces EXISTS (`src/mechanics/behaviour/bounce_pad.gd`). The landing arbiter R-2 is NEW (GAP-2). The lamb being flung is NEW (gap G10, `levels.md:551`). The ghost preview of the hop end is NEW (GAP-8). Sizes in 3.7.
- **Source.** Springs and trampolines in `party_modes_ref.jpg` (Wonky Builders spring base) and `party_minigames_ref.jpg` (Wobble Builders spring).

**BK-06 snowball (kind 8, glyph `n`)**
- **What.** A rolling ball of snow that rolls down a slope across your stack and grows.
- **Rule.** Trigger: every `roll_locks` (2) locks, each ball rolls one cell in `slope_dir` (default `-x`) (`snowball.gd:34-35,45-79`). One lock before it moves, a warning plays (`:46`). The ball stays a short column of up to `snow_max` (3, clamped 1 to 4) cubes and grows by one cube each roll while free above (`:76-78`). If the next step is off the footprint, blocked, or changes height by more than 1, the ball parks (`:63-68`). A parked ball is inert. At `respawn_locks` (8) it respawns at the high end (`:80`). Clearing a ball cube emits `snowball_puff`. Fill: `fills_layer` true. Gravity: climbs or falls at most 1 per step. Other specials: none. `ice_slide` moves only the falling piece on landing, so it never touches a snowball. Rescue: a ball is plain cubes, so a wipe removes them. Top-out: growth needs a free cell above.
- **Look.** White ball with a blue shadow, trailing snow puffs, a small arrow floor-decal in `slope_dir`. Skins: ice white, candy meringue, cave boulder, lava ash-ball, desert tumbleweed.
- **Audio.** Proposed `SFX_SP_SNOWBALL_ROLL` (AUDIO-NEW) and `SFX_SP_SNOWBALL_PUFF`.
- **Fits.** Ice biome (levels not yet in the first 12), mountains, carnival (rolling barrel skin).
- **Intro and teach.** Early ice level. The warning arrow is the teacher: "A snowball rolls this way next."
- **Fairness.** Risk: it rolls into a gap you were saving. Counterplay: the arrow and the lock warning; building a wall parks it.
- **Engine.** EXISTS (`src/mechanics/behaviour/snowball.gd`). No gap.
- **Source.** Ice and snow boards in the minigame mockups (checked in Appendix A) and the ice block in `biome_block_materials_ref.png`.

**BK-07 goo (kind 9, glyph `g`)**
- **What.** Naughty sticky goo. It blocks the layer it sits in, makes pieces stick where they land, and spreads. A clear next to it washes it off.
- **Today (the engine).** `goo_spread` copies goo into one free face neighbour per quiet lock (`goo_spread.gd:23-33`). It skips a spread after a clear (`:15-18`). The goo cell is `fills_layer` true (`blocks.json:83-92`), so today goo FILLS layers, which helps the player. It never touches a falling piece. The kind is a twist-layer rule (`assets/data/rules/goo_spread.json:5`). The r1 panel was right: as built, goo has no threat.
- **Rule (r2 redesign, one job: stick and block).**
  1. **Block.** Goo cells carry the status `fills_layer` false (`_update_fill_status` honours a status override, `board_state.gd:697-706`). An active cell with `fills_layer` false that holds a cube is not filled, so its layer cannot be full (convention 4). Goo blocks its layer until it is washed off. This is the same mechanism the grumpy moody cube uses.
  2. **Wash.** NEW `on_clear` step: when a clear removes a cell, each face-adjacent goo cell is removed once per resolve (cause CLEAR, like the pest shoo in `pest.gd:19-29`). A goo cell in layer k is washed by a clear in layer k-1 or k+1 (it cannot be washed by its own layer, which it blocks).
  3. **Stick.** NEW rule R-12: a piece that comes to rest with a cube directly above a goo cell locks at once (lock delay 0, the piece flag `lock_now`, as `fog_ghost.gd:30` sets) and receives no bounce, jelly or ice displacement. This is the honey behaviour of `block-status-effects.md`.
  4. **Spread.** As today, plus: (a) a one-lock warning (the target cell shows a drip, as `mushroom_popup.gd:26-38` marks a cell); (b) the target must be supported (a cube or the floor below it, as `mushroom_popup.gd:30` and `gumdrop_hail.gd` require), so goo never floats; (c) a cap `goo_max` (12).
  - Gravity: goo is a plain cube for gravity. Rescue: wiped with its plane (3.1b, plain). Top-out: spread is limited by `api.limit_layer()` (`goo_spread.gd:27`).
- **Look.** Glossy green or pink blob with a drip and a slow wobble. The warning lock shows a drip on the target. Badge: a drip drop (3.6). Skins: candy syrup, underwater slime, forest sap, lava tar, neon slime-glow.
- **Audio.** `SFX_PL_STICKY_SPLAT` for the stick (`sfx-cue-list.md:96`); `SFX_SP_GOO_SPREAD` and `SFX_SP_GOO_WASH` (AUDIO-NEW).
- **Fits.** candy, forest, underwater, lava (tar).
- **Intro and teach.** One biome level after the player knows clears (3.4). Hint: "A clear next to goo washes it off."
- **Fairness.** Risk: runaway spread (positive feedback). Counterplay: the one-lock warning, the cap, the skip after a clear, and the wash. Goo is no longer free fill, so the cap is not the only protection; F5 models the wash.
- **Engine.** PARTIAL. `goo_spread.gd` EXISTS. NEW: status override (0.25 day), wash hook (0.5), warning mark (0.75), supported-only target (0.25), cap (0.25), and the stick rule R-12, which belongs to the landing arbiter (GAP-2). Owner: gameplay-programmer. Sizes in 3.7.
- **Source.** Own idea; the candy board (Candy Clash in `party_modes_ref.jpg`) for the candy skin; mud pits on a dino board in `mockup_33.jpg` for the floor look.

**BK-08 pest (kind 10, glyph `p`)**
- **What.** A critter (ant or worm) that walks over your stack and eats ordinary blocks. A clear next to it shoos it.
- **Rule.** Trigger: every `ant_every_locks` (3) locks, each pest acts (staggered by index) (`pest.gd:30-40`). Effect: it moves to a random neighbour that is a plain `block` or `starter` and eats it (the target cube is damaged and removed) (`:49,61-69`). If it has no food, it gets hungrier and starves after `ant_starve_acts` (3) acts (`:51-60`). On any clear within one cell of a pest, it is shooed (removed) once, and pays `ant_shoo_bonus` (50) points (`:19-29`). Optional `rim_escape`: a pest on the rim leaves with the cube and counts `worms_escaped` (`:71-76`). `late_spawn_s` can add pests later. Fill: `fills_layer` true. Gravity: the cell it enters is the one it ate, so support below may vanish and a slice collapse follows. Other specials: it cannot eat specials (only block and starter), so frosting, rock, locked cube and sponge are safe. Rescue: wiped. Top-out: eating lowers the stack.
- **Look.** Small black ant or green worm on top of a cube, legs animate, a bite mark on the eaten cell. Warning: the target cell gets a crumb glow one lock ahead. Skins: meadow ant, candy ant on sugar, forest beetle, underwater crab-lice, cave worm.
- **Audio.** Proposed `SFX_SP_PEST_NIBBLE` and `SFX_SP_PEST_SHOO` (AUDIO-NEW).
- **Fits.** Forest and candy, with `worms_escaped` as a goal metric for a rescue-style level.
- **Intro and teach.** Mid-chapter. "Clear next to it to shoo it!"
- **Fairness.** Risk: it eats the base of your tower. Counterplay: clear to shoo, build away from it, starvation, and a bonus for shooing.
- **Engine.** EXISTS (`src/mechanics/behaviour/pest.gd`). A crumb warning view is NEW, 0.5 day, technical-artist.
- **Source.** Own idea.

#### 3.2.b Special BLOCK KINDS, part 2: candy and bake kinds

Source for all: `src/mechanics/candy/` and `blocks.json`. Candy levels are not in the first 12; their JSON is `src/levels/candy/candy_10/candy_10.json` and `candy_h3.json`.

**BK-09 gumdrop (kind 11, glyph `u`)**
- **What.** A coloured sweet that falls from the sky onto a surface, after a warning. It is a small "hail" block.
- **Rule.** Trigger: `gumdrop_hail` every `spawn_every_locks` (4, minimum 2); one lock before, a free supported surface cell is marked (`gumdrop_hail.gd:34-42`). Effect: on the due lock the cell becomes a gumdrop with a random flavour hue 1..`spawn.colour_count` (`:26-31`), unless it was filled (`hail_cancelled`, `:32`). Cap: `objects_max` (6) across gumdrop, icing dollop and frosting (`:36-38`). `avoid_start_holes` keeps hail out of pockets under starting cells (`:12-17`). `hail_after_locks` delays the first hail. Fill: `fills_layer` true. The event carries `sticky: true` (`:31`) but this rule writes no status; the stickiness is presentation only today. Gravity: placed on a surface only. Rescue and top-out: as any cube.
- **Look.** A shiny round gumdrop with a sugar-crystal top, flavour colour (pink, yellow, green by hue id), a falling shadow circle one lock early. Skins: candy only; other biomes reskin it as a hailstone (ice), ash chunk (lava), acorn (forest), seed pod (meadow).
- **Audio.** Proposed `SFX_SP_HAIL_WARN` and `SFX_SP_HAIL_LAND` (AUDIO-NEW).
- **Fits.** Candy biome, ice (hail skin).
- **Intro and teach.** A candy mid-teach level. Shadow circle is the teacher.
- **Fairness.** It can land in a spot you needed. Counterplay: warning mark, cancel by filling, cap of 6.
- **Engine.** EXISTS (`gumdrop_hail.gd`). The event field `sticky: true` (`:31`) is read by no rule. Treat it as presentation only (the gumdrop has no sticky rule; stickiness is goo's job, BK-07). Optional clean-up 0.1 day.
- **Source.** The candy block (frosted cube with a heart) in `biome_block_materials_ref.png`; sweet props in the candy board of `party_modes_ref.jpg` and the cake and jelly pieces in `mockup_05.jpg` and `mockup_08.jpg`.

**BK-10 icing_dollop (kind 20, glyph `D`) and BK-11 frosting (kind 12, glyph `2`) / frosting_three (kind 13, glyph `3`)**
- **What.** A dollop of icing that hardens into frosting. Frosting is a block with 2 (or 3) coats. You must clear next to it several times to peel it.
- **Rule.** Frosting at level start gets `frosting_layers` 2 (kind `frosting`) or 3 (kind `frosting_three`) and `clear_protected` true (`frosting.gd:8-10`). Trigger: any clear removing a cell face-adjacent to it (`on_clear`, `:13-22`). Effect: it peels one coat, at most once per resolve (`_peeled`, `:17-18`). At zero coats it is removed as damage (`:20`). Icing dollop (kind 20) is hailed instead of a gumdrop when `object: icing_dollop`; once the bake goal's `baked` counter is above 0, new hail becomes frosting with 2 coats, and a clear while marked cancels the hail (`gumdrop_hail.gd:19-30`). `tier_frosting` (`src/mechanics/candy/tier_frosting.gd`) adds tier rows. Fill: `fills_layer` true, but `clear_protected` means its layer cannot clear it directly: the layer clears around it and the frosting waits until peeled (like a rock in `obstacles.md`). Gravity: normal. Rescue: wiped with the plane. Top-out: counts as height.
- **Look.** Thick white-pink icing cap with swirls. 2-coat shows one swirl ring, 3-coat shows two. A coat peels with a visible flake each time. Skins: candy; ice rime-cap; lava ash-crust; forest moss-cap; neon shield-plate.
- **Audio.** Proposed `SFX_SP_FROSTING_PEEL` (AUDIO-NEW).
- **Fits.** Candy bake levels (`bake_stage`, `bake_oven_goal`), ice (rime).
- **Intro and teach.** Candy tier 2. "Clear next to it to peel the icing."
- **Fairness.** Frosting does not block its layer: it is `fills_layer` true, so the layer is full and clears around it (`board_sim.gd:1429-1430` skips cells that `can_remove` refuses). The risk is different: frosting survives every clear, so frosting cells can pile up. Counterplay: any neighbouring clear peels one coat, the coat count is visible, and `objects_max` (6) caps hailed frosting. A blast or Smash removes frosting at once (3.1b).
- **Engine.** EXISTS (`frosting.gd`, `gumdrop_hail.gd`, `tier_frosting.gd`). No gap.
- **Source.** Frosted candy block in `biome_block_materials_ref.png`; cake pieces in `mockup_05.jpg` and `mockup_08.jpg` (Cake Stackers, Sugar Rush Stack).

**BK-12 sponge (kind 14, glyph `s`)**
- **What.** A soft cake sponge that cannot be cleared away by a normal layer clear. It is a protected cell.
- **Rule.** At level start `CandyCells.protect` sets `anchored`, `clear_protected` and `fixed` (`candy_cells.gd:49-50`, called from `frosting.gd:11` and `climber_boss.gd:25`). Result from the table in 3.1b: only MASKED removes it. A clear skips it, a rescue skips it, a blast and Smash skip it (`fixed` blocks DAMAGE), nothing moves it. Fill: `fills_layer` true and it is an active cell, so it counts as filled and the layer clears around it. It is the supporting stage under the climber boss. Top-out: counts as height (it is not `static_geometry`).
- **Look.** Yellow cake crumb texture with holes; no icing. Distinct from frosting by the missing cap.
- **Audio.** Normal land. Proposed `SFX_SP_SPONGE_SQUISH` (AUDIO-NEW).
- **Fits.** Candy.
- **Intro and teach.** Candy boss (candy_10) and bake levels.
- **Fairness.** Same as frosting. Counterplay: the layer clear leaves it behind visibly.
- **Engine.** EXISTS.
- **Source.** Cake bases in the cake boards.

**BK-13 licorice (kind 15, glyph `l`)**
- **What.** A black-and-white licorice knot anchored to the board. It unties into a normal cube when a neighbour clears.
- **Rule.** Level start: anchored and `clear_protected` (`licorice_lock.gd:5-9`). Trigger: a clear removes a face-neighbour (`:11-15`). Effect: the licorice is removed and replaced by a `starter` cube, with `licorice_untied`. Fill: `fills_layer` true. Anchored means it does not move in slice shifts. Gravity: fixed. Rescue: NOT wiped (`anchored` blocks RESCUE, `board_state.gd:687`; `wipe_bottom` uses `Cause.RESCUE`, `:608`). A blast or Smash DOES remove it, because `anchored` allows DAMAGE (`:687`). Top-out: counts as height.
- **Look.** Black spiral knot with a white ribbon, small lock icon badge.
- **Audio.** Proposed `SFX_SP_LICORICE_UNTIE`.
- **Fits.** Candy.
- **Intro and teach.** Candy tier 2 or 3.
- **Fairness.** It holds a fixed spot. Counterplay: clear next to it.
- **Engine.** EXISTS (`licorice_lock.gd`).
- **Source.** None.

**BK-14 moody (kind 16, glyph `y`)**
- **What.** A grumpy gummy cube. It sulks until a neighbour shares its flavour. While it sulks it will not fill a layer.
- **Rule.** One tagged Mono per bag becomes a moody cube at spawn (`moody_cube.gd:5-9`) and on lock keeps the piece's colour (`:10-17`). Each resolve it checks six face neighbours for the same flavour (`:19-27`): happy means `fills_layer` true; grumpy means `fills_layer` false and `clear_protected` true. Emits `gummy_mood`. Gravity: normal. Other specials: a rainbow cube neighbour does NOT count as a match today. The test is colour equality only (`moody_cube.gd:15,23`), and the `rainbow` status is honoured only by the shape goal (`candy_cells.gd:47`). Making rainbow a match is NEW (0.25 day). Rescue: wiped (`clear_protected` blocks only CLEAR, `board_state.gd:691`). Top-out: height.
- **Look.** A gummy cube with a face: sad brows and flat mouth when grumpy, smile when happy. The face must read at 28 px: big eyes, bold brows.
- **Audio.** Proposed `SFX_SP_MOODY_GRUMBLE` and `SFX_SP_MOODY_HAPPY`.
- **Fits.** Candy (colour-connect levels), carnival.
- **Intro and teach.** Candy tier 2. "Put a matching colour beside it."
- **Fairness.** Risk: a lone grumpy cube blocks the whole layer. Counterplay: place a matching flavour next to it; the hint arrow points to a matching cell.
- **Engine.** PARTIAL. `moody_cube.gd` EXISTS. NEW: rainbow match (0.25 day) and the hint arrow (1 day, gameplay-programmer plus ui-programmer).
- **Source.** Faces on blocks are a party-board motif (`party_modes_ref.jpg`).

**BK-15 candy_bomb (kind 17, glyph `a`)**
- **What.** A bomb cube earned by clearing a big connected group of one flavour. It blows up a 3x3x3 area when it is cleared.
- **Rule.** Earn: after a resolve, a connected same-flavour cleared group of at least `bomb_at` (7; 0 turns it off) leaves one bomb on a free cell of that group nearest the last lock (`earned_specials.gd:23-39`). `rocket_at` and `colour_bomb_at` are schema-limited to 0 (`earned_specials.json`). Trigger: the bomb cell is cleared like any cube (`:11-12`). Effect: every non-empty cell within the 3x3x3 cube around it is removed as damage, except cells with `anchored` true (`:14-19`). It is not a layer clear itself, but removed cells can open follow-up clears. Fill: `fills_layer` true. Gravity: after the blast, collapse follows the level's collapse rule. Other specials (resolved from `can_remove`, 3.1b): the blast uses cause DAMAGE. `clear_protected` blocks only CLEAR (`board_state.gd:691`), so a blast removes frosting at once. `locked` blocks only CLEAR and DISPLACED (`:689-691`), so a blast removes locked cubes (the r1 text said the opposite). `fixed` cells (rock, shelf, sponge) survive. `anchored` cells survive only because `earned_specials.gd:18` skips them on purpose; the item bomb and Smash do not skip them. A 2-hit rock loses one hit instead of dying (`remove` decrements `hits_left`, `board_state.gd:341-348`). Rescue: wiped. Top-out: the bomb can end the pressure by deleting up to 27 cells.
- **Look.** Glossy round cherry-bomb with a lit fuse. The rim is GOLD (a reward block), and only the fuse spark is orange (r2: the r1 "orange hazard-reward rim" mixed two colour roles). Badge: a fuse and spark. Skins: candy cherry bomb, lava ember-bomb, ice crystal-bomb, clockwork dynamite-gear, celestial star-nova, pirate powder keg.
- **Audio.** Proposed `SFX_SP_BOMB_BLAST` (AUDIO-NEW); reuse `Hollywood/Wooden Crate Destruction.wav` as a stand-in (cue list uses it for sail-off).
- **Fits.** Candy; any biome as a reward block. Cave (rock-breaker), pirate.
- **Intro and teach.** Candy. First earn is shown in slow motion with a callout: "Big clears make a bomb."
- **Fairness.** Risk: the blast deletes a goal object or critter. Counterplay: a level marks goal objects `goal_object` (the NEW `blast_safe` plus `rescue_safe` flags, 3.1b). `anchored` is NOT the protection: it blocks clears (r1 error, removed). The blast preview outline shows the 3x3x3 box on the ghost.
- **Engine.** PARTIAL. `earned_specials.gd` EXISTS. NEW: the `blast_safe` flag (GAP-3) and the blast preview outline (GAP-8).
- **Source.** Bomb ideas: cannon blasts and explosions across the party boards (`mockup_02.jpg` Fort Blast, `mockup_03.jpg` Shatter Shootout).

**BK-16 countdown_bomb (kind 18, glyph `q`)**
- **What.** A thrown bomb with a number on it. When it hits zero it adds a junk layer. A clear beside it defuses it.
- **Rule.** Trigger: every `thrown_every_locks` (8) a bomb appears on a random surface cell with `cd_start` (8) (`countdown_bomb.gd:22-25`). Each lock it counts down 1; at 0 it is removed, `request_junk_layers(blast_layers)` (default 1) pushes junk up from below, and `countdown_blast` plays (`:17-21`). A clear on or face-adjacent to it defuses and removes it (`:9-15`). Fill: `fills_layer` true. Gravity: it sits on a surface cell. Rescue: if the plane is wiped, the bomb goes with it. Top-out: a junk layer pushes the stack up by one and may cause a top-out warning (`obstacles.md` rule 8).
- **Look.** Dark round bomb with a big white digit on the top face and a lit fuse that shortens. Numbers 3 and below turn red and shake. **Ruling check (Appendix E):** the digit counts LOCKS on one object. It is not a clock on the HUD, so the "no countdown shown" decision (which is about the HUD clock for hidden-timer hazards) does not apply. Badge: a digit in a round bomb (3.6). Skins: candy gum-bomb, pirate powder keg, clockwork alarm-clock, neon timer-cube.
- **Audio.** Proposed `SFX_SP_BOMB_TICK` (a soft tick per count), `SFX_SP_BOMB_DEFUSE`.
- **Fits.** Candy, pirate, clockwork. Versus mode (thrown by a rival). 
- **Intro and teach.** After blocks and clears are known. Hint: "Clear next to it before zero."
- **Fairness.** Risk 1: a bomb lands in an unreachable spot. Counterplay: a bomb never spawns where `surface` has under 2 free neighbours (proposed constraint, 0.25 day). Risk 2 (r2, from the r1 panel): the shipped defaults do not balance. `thrown_every_locks` 8 and `cd_start` 8 give about one live bomb, about 71 percent of bombs explode unaimed, and about one junk layer arrives per 11 locks against one clear per 12 (F6b). So the default is re-tuned to `thrown_every_locks` 12 and `cd_start` 10, and F6b requires `(1 / E_t) x (1 - p_def) < c` for every level that uses it. Junk then rises slower than clears when the player does nothing special.
- **Engine.** EXISTS (`countdown_bomb.gd`). The digit view is an art task, not an engine gap (1 day, technical-artist). The re-tune is data only.
- **Source.** Timer bombs and cannons in the party mockups.

**BK-17 climber_boss (kind 19, glyph `B`)**
- **What.** A 2x2 gummy boss that climbs your terraces. Clears next to it bonk it down a step.
- **Rule.** Spawn: on the first valid terrace (the highest legal 2x2 spot, ties by x then z) after the `bake_oven` goal's `baked` counter is above 0 (`climber_boss.gd:34-43`). Each resolve it moves to the highest reachable adjacent 2x2 spot, one terrace step of height at most 1 per move (`:53-59`). Trigger: a clear next to any of its 4 cells sets a bonk (`:27-32`); next resolve it drops to a lower neighbour at least `bonk_drop_cells` (1) down (`:44-52`), adds a `bonks` goal counter and emits `boss_bonk`. If no lower spot exists, `bonk_blocked`. It is `anchored` and `clear_protected` (`:42`), not `fixed`, because it moves with `force` (`:52`; `remove` refuses force on `fixed`, `board_state.gd:338`). Table 3.1b: a clear skips it, a rescue does NOT wipe it, but a blast and Smash DO remove it (`anchored` allows DAMAGE). So it needs the NEW `blast_safe` flag while the bake goal runs (GAP-3). Fill: it counts as 4 filled cells. Top-out: it cannot climb above the line, because `_candidates` rejects any cell at or above `limit_layer` (`climber_boss.gd:17`).
- **Look.** A big smug gummy bear with a crown, 2x2 footprint, bounces a little each climb. Shield-rim gold, health bar over its head with bonk pips.
- **Audio.** `SFX_BOSS_FLOUR_BONK` exists as a GAP in the Meadow list (`sfx-cue-list.md:108`); candy needs `SFX_BOSS_GUMMY_BONK` (AUDIO-NEW).
- **Fits.** Candy boss (candy_10). The `bonk_boss` goal is the identity-spec boss pattern.
- **Intro and teach.** The Chapter boss only. The previous levels teach "clear next to it".
- **Fairness.** Risk: no lower spot, no progress. Counterplay: `bonk_blocked` message, and a terrace is always reachable by design.
- **Engine.** PARTIAL. `climber_boss.gd` and goal `bonk_boss_goal.gd` EXIST. NEW: `blast_safe` (GAP-3). Boss phase hand-over: gap G13 (`levels.md:554`).
- **Source.** The big octopus and golem bosses in `mockup_02.jpg`, `mockup_04.jpg`, `mockup_07.jpg` (a boss that acts on the board).

#### 3.2.b Special BLOCK KINDS, part 3: cave, lava, forest, underwater

**BK-18 rock (kind 21, glyph `R`)**
- **What.** A solid rock that is part of the level. It does not count toward full layers. Some rocks take two hits.
- **Rule.** Permanent: `fixed`, `static_geometry`, `anchored`, `clear_protected`, `fills_layer` false (`rock_obstacle.gd:18-21`; `blocks.json:203-212` has `fills_layer: false`). Rocks placed by `params.cells` at level start (`:12-17`). `lava_rock_spawn` can also pop a rock: it warns one lock ahead (`geyser_warning`), then creates a 2-hit rock with `hits_left` (`hard_hits`, default 2, range 1 to 8) (`lava_rock_spawn.gd:23-38`); adjacent clears hit it (`_hit_adjacent`). Because it is excluded from the layer denominator, the layer clears around it. Gravity: never moves. Rescue: NOT wiped (`fixed` blocks every cause but MASKED, `board_state.gd:685-686`). Blast and Smash: no effect on a placed rock (`fixed`). The geyser rock is different: it is not `fixed`, so a blast, a rescue and DISPLACED remove it, and DAMAGE counts down `hits_left` first (3.1b). Top-out: `static_geometry` adds no stack height (`board_state.gd:94-96`).
- **Look.** Grey boulder, mossy in meadow, cracked in lava (shows hits left with cracks), crystal-flecked in cave. Square footprint but rounded outline.
- **Audio.** Proposed `SFX_SP_ROCK_CRACK` (AUDIO-NEW).
- **Fits.** Lava, cave, forest, meadow stone cage (the `shelf` and masked columns of meadow_01), any biome.
- **Intro and teach.** Early; "rocks do not need filling."
- **Fairness.** Rocks cannot be moved. They must not fully block spawn rows (validator).
- **Engine.** EXISTS (`rock_obstacle.gd`, `lava_rock_spawn.gd`).
- **Source.** Rocks in `mockup_01.jpg` (Avalanche Ascent) and the volcanic sheet props (cooled stone, obsidian spur).

**BK-19 mole (kind 22, glyph `o`)**
- **What.** A buried mole you rescue by clearing the layer it sits in.
- **Rule.** `dig_rescue` goal: a mole is rescued only when its layer clears; damage and trims do not rescue it (`dig_rescue_goal.gd:2,8-10`). Emits `critter_rescued {kind: mole}`. Fill: `fills_layer` true. Gravity: normal; it sinks with slice shifts. Rescue wipe: a mole is a plain cube, so a wipe removes it and it is NOT rescued (`dig_rescue_goal.gd:8-10` counts only a CLEAR). A level with a dig goal sets `rescue_safe` on its moles (`goal_object`, 3.1b), so a wipe skips them. Blast: removes a mole unless `blast_safe`.
- **Look.** A round brown mole with pink nose and tiny goggles, peeking from a dirt cube. Skins: cave, meadow, forest.
- **Audio.** Proposed `SFX_SP_MOLE_SQUEAK` and `SFX_SP_MOLE_FREE`.
- **Fits.** Cave dig-rescue levels (`cave_h3.json` mentions mole).
- **Intro and teach.** Cave. Mole faces peek, a "help" bubble.
- **Fairness.** A rescue wipe can destroy the goal. Counterplay: the soft rescue protects critters (proposal in Edge Cases).
- **Engine.** EXISTS in the goal; view `src/view/wt_toy_actor.gd` mentions mole.
- **Source.** The digger and mine boards (`mockup_01.jpg` Rubble Rumble, `mockup_04.jpg` Digging Frenzy).

**BK-20 locked_cube (kind 23, glyph `k`)**
- **What.** A cube in a padlock. A clear next to it unlocks it so it can be cleared.
- **Rule.** At level start every locked cube gets `locked` true (`locked_cube.gd:11-18`). Trigger: a cell face-adjacent to a clear (`on_clear`, `:22-31`). Effect: `locked` false and `cube_unlocked`, once per resolve. Cubes that are `anchored` or `fixed` are skipped. Fill: `fills_layer` true. Gravity: normal (a `locked` cell cannot move, `board_state.gd:679`). Other specials: there is no key cube in the engine; the key piece (BK-24) winds wall keyholes and does not open locked cubes. A blast or Smash removes a locked cube (DAMAGE is allowed). Rescue: wiped (`locked` blocks only CLEAR and DISPLACED). Top-out: height. **No deadlock:** `on_clear` hooks run for every cell of a full layer before removal is tested (`board_sim.gd:1421-1430`), and the hook unlocks cells face-adjacent to a cleared cell (`locked_cube.gd:22-31`). So a full layer that holds a locked cube unlocks it from its own neighbours and clears it in the same resolve. The r1 "lone layer deadlock" cannot happen.
- **Look.** A cube with a brass padlock on every face; the padlock opens with a click and drops off when unlocked. Rim: blue while locked, none when open.
- **Audio.** Proposed `SFX_SP_LOCK_CLICK`, `SFX_SP_LOCK_OPEN`.
- **Fits.** Lava (`lava/locked_cube.gd` lives in the lava folder), cave, pirate, clockwork.
- **Intro and teach.** Early lava. "Clear next to it to open it."
- **Fairness.** A locked cube does not block its layer (it fills the cell and unlocks from the clearing neighbours). It only resists a clear that does not include its neighbours, which cannot occur in a full layer. Always reachable.
- **Engine.** EXISTS (`src/mechanics/lava/locked_cube.gd`).
- **Source.** Chest and key in `mockup_02.jpg` Maze Heist and the treasure chests in `mockup_03.jpg`, `mockup_10.jpg`.

**BK-21 shelf (kind 24, glyph `H`)**
- **What.** A fixed ledge deck that holds a chamber under it and an opening above. It never moves and never counts toward a layer.
- **Rule.** `fixed`, `static_geometry`, `anchored`, `clear_protected`, `fills_layer` false, `shelf` true (`anchored_shelf.gd:18-21`; `blocks.json:233-242`). Placed by `params.cells` at level start. Gravity: fixed. Other specials: pieces rest on it; cells under it are protected pockets (hail avoids them with `avoid_start_holes`). Rescue and top-out: no height added.
- **Look.** A wooden plank or stone slab with brackets, visibly nailed to the wall.
- **Audio.** Normal land.
- **Fits.** forest (branch ledge), clockwork. (r2: the meadow_07 scaffold use is removed; meadow_07 keeps fog only, Appendix E.)
- **Intro and teach.** Not taught. Looks like a platform.
- **Fairness.** It can trap holes. The validator checks reachability.
- **Engine.** EXISTS (`src/mechanics/forest/anchored_shelf.gd`).
- **Source.** Scaffolds and ledges in `style/09_minigames_a.jpg` and the party hill boards.

**BK-22 vines, BK-23a frozen, BK-23b honey, BK-23c burning, BK-23d crumbling, BK-23e shadow, BK-23f spiked (status shells, 7 ids)**
- **What.** Seven status shells that sit on one cube. A cube holds at most one (`block-status-effects.md` Core Rule 1). Ids: BK-22 vines; BK-23a frozen; BK-23b honey; BK-23c burning; BK-23d crumbling; BK-23e shadow; BK-23f spiked.
- **Rule (all).** Table, from `block-status-effects.md`: frozen (+1 hit point, thaws when its layer takes layer damage or a neighbouring layer clears), vines (+1 hp; every `vine_every_locks` 4 locks spreads to one neighbour), honey (a piece resting on it locks at once), burning (removed after `burn_locks` 3; neighbours catch fire with `burn_spread_p` 0.3), crumbling (removed `crumble_locks` 2 locks after something lands on it), shadow (drawn at invisible alpha), spiked (first landing is pushed up 1 cell, spike breaks). Priority: a new status replaces the old unless the old one's rule ranks higher. Fill: all keep the cell's own `fills_layer`. Rescue: wiped.
- **Engine status per shell (important, this is a design-doc-only area).**
  - Vines: PARTIAL. The forest `vines` rule (`src/mechanics/forest/vines.gd:12-40`) selects `vine_per_bag` (default 1, 0 to 2) pieces per bag, marks them `vined`, and protects direct neighbours with `status.vined`. The "spreads every 4 locks" part of the GDD is not in that file. Gap: spread, 1.5 days, gameplay-programmer.
  - Burning: PARTIAL. `ember` rule (`src/mechanics/behaviour/ember.gd`) drills below tagged pieces; the burn-out and fire spread of the GDD are NEW (2 days).
  - Frozen: NEW as a status (thin_ice and ice_slide are different rules: OB-19 and OB-20; the ice CUBE is BK-35). It uses the `hp` key, so a DAMAGE hit thaws one hit instead of removing it (`board_state.gd:341-348`). 1.5 days.
  - Honey: NEW as a cell status. `sticky_landing` is the twist version (README line 38). 1 day.
  - Crumbling: PARTIAL. `crumble_tiles` (wave 3) cracks floor tiles, not cubes (`src/mechanics/wave3/crumble_tiles.gd`). Cube status NEW, 1 day.
  - Shadow: PARTIAL. `fog` hides by time (`src/mechanics/behaviour/fog.gd`), not a per-cube status. NEW, 0.5 day.
  - Spiked: NEW, 1 day.
  - Owner for all: gameplay-programmer (rule), technical-artist (shells).
- **Look (r2, badges fixed).** Each shell has one badge from the 3.6 sheet, and none shares a badge with another special or with a biome ornament: frozen = an ice-shell crack with a padlock tab (NOT a snowflake, because the ice cube BK-35 owns the snowflake and the Ice biome ornament is already a snowflake); vines = a curling tendril with a thorn (NOT a leaf, because the Meadow HUD already puts a leaf sticker on every cube); honey = an amber drop; burning = a flame; crumbling = a split block with dust; shadow = an eye-slash; spiked = a spike fan. Each also has an animation (pulse, wobble, flicker) and a rim pulse, per the look rule (`block-status-effects.md:87`).
- **Audio.** The GDD lists `freeze`, `thaw`, `vine_grow`, `honey_stick`, `ignite`, `burn_out`, `crumble`, `spike_bounce`. Map to `SFX_SP_*` and mark AUDIO-NEW.
- **Fits.** Frozen: ice. Vines: forest. Honey: candy. Burning: lava, clockwork. Crumbling: cave, carnival. Shadow: celestial, neon. Spiked: carnival, pirate.
- **Intro and teach.** One shell per level, first appearance after tier 3 of its biome.
- **Fairness.** Fire spread is a positive feedback loop. Counterplay: expected spread 0.9 per burn-out on a dense stack (F2 in the status GDD) and a cap proposed in Formulas.
- **Engine.** See the per-shell list above.
- **Source.** The art bible shells and the ice and lava block skins in `biome_block_materials_ref.png`.

#### 3.2.b Special BLOCK KINDS, part 4: piece powers (a tag on one falling piece)

These powers ride on a single falling piece through a spawn tag or piece flag. Per `piece-set.md` Core Rule 6 the tag never changes the shape. They are the "block with a power" family the user asked about: ghost, balloon, bubble, ember, wildcard, key, anvil, jelly. A level turns each on through a rule in its `rules` list. All eight exist in the engine.

**BK-24 key piece (key stamp) with keyholes**
- **What.** A piece with a gold key printed on one face. Put that face against a keyhole in the wall to wind it up.
- **Rule.** Trigger: at spawn, `key_per_bag` (default 2) pieces of each dealt bag carry one key stamp on a random outward face (`key_stamp.gd:8-31`). Injected pieces never carry one (`:12`). Trigger 2: on lock, goal `wind_keys` checks whether the stamped cube is at the keyhole's exact cell and the rotated stamp face matches the wall normal (`wind_keys_goal.gd:11-34`). Effect: the hole is "wound" (stays wound, `_wound`), `keys_wound` rises. Win: `keys_needed` (default 4) wound (`:35-36`). Fill: the piece is normal. Gravity: normal. Rescue: wiped keys do not unwind wound holes ("wound holes persist", class comment). Top-out: normal.
- **Look.** Key stamp is a big gold key emblem on one face, with a glow pulse. Keyholes are lit rings on the wall with a keyhole symbol and a count. Skins: meadow brass key on a gate, pirate chest key, clockwork winding key, cave rune key, celestial star-key.
- **Audio.** Proposed `SFX_SP_KEY_WIND` (ratchet clicks) and `SFX_SP_KEYHOLE_OPEN`.
- **Fits.** Clockwork (winding), pirate (chest), cave, meadow gate levels. Mockup: Maze Heist keys.
- **Intro and teach.** A first key level shows one keyhole and a 3-second loop of turning the key face to the wall. Hint: "Face the key at the hole!"
- **Fairness.** Risk: a piece must be rotated so the face and cell both match; frustrating if the stamped face is hidden. Counterplay: the ghost shows an arrow when the face aligns; `key_per_bag` 2 gives two tries per bag; rotation is free of cost.
- **Engine.** EXISTS (`key_stamp.gd`, `wind_keys_goal.gd`). Gap: key face art, keyhole wall art and ghost alignment arrow, 3 days, technical-artist plus ui-programmer.
- **Source.** The big glowing keys and key counter in `mockup_02.jpg` (Maze Heist). The wall keyholes are our own.

**BK-25 ghost piece (`fog_ghost` tag)**
- **What.** A see-through piece that falls through the stack until you tap it solid.
- **Rule.** Trigger: spawn with tag `fog_ghost` sets flag `intangible` (`fog_ghost.gd:12-17`). While intangible the piece passes through locked cubes. Trigger 2: hard drop, pick_cell, tap or solidify commands, or landing, makes it solid (`:18-23`). Effect: `place_nearest_up()` moves it to the nearest legal free place upward (`:29`); lock is immediate for taps (`lock_now`). Fill: normal after solid. Gravity: normal fall while ghost. Other specials: the `fog` rule lights the ghost neighbourhood at every height (README line 33). Rescue: not applicable while falling. Top-out: it cannot become solid inside the top-out band; `place_nearest_up` fails then spawn is blocked (edge case).
- **Look.** Blue-white translucent outline with a soft pulse and a faint trail; a spirit-face badge on the top face. Solid state snaps to the normal material with a flash.
- **Audio.** `SFX_SP_FOG_GHOST` (loop) and `SFX_SP_FOG_GHOST_SOLID` (`sfx-cue-list.md:94-95`).
- **Fits.** meadow_07 Fog Frolic (a candidate; the frame says fog hides the top, `levels.md:259-286`), celestial, cave, neon.
- **Intro and teach.** A fog level. Hint: "Tap to make the ghost solid."
- **Fairness.** Risk: solidifying inside crowded space fails. Counterplay: nearest-up placement and a visible solid preview.
- **Engine.** EXISTS (`src/mechanics/behaviour/fog_ghost.gd`).
- **Source.** None; fits the translucent glass-cube bridges in `mockup_04.jpg` (Chroma Sky Climb).

**BK-26 balloon piece (`balloon` twist)**
- **What.** A piece tied to a balloon. It drifts down at half speed and bobs up once before it settles.
- **Rule.** Trigger: `balloon_per_bag` (default 1) pieces per bag, chosen from the dealt bag (`balloon.gd:15-28`). Effect: gravity scale is multiplied by `balloon_g_mult` (default 0.5) (`:31`). After `balloon_drift_ms` (3000 ms) the piece bobs up one cell if it has dropped below its spawn layer and you are not soft-dropping (`:48-56`); a warning shows 500 ms before the bob (`:49-51`). Hard drop cancels the bob and restores gravity (`:39-41`); soft drop restores normal gravity while held (`:42-44`). Lock restores everything (`:57`). Fill, clears: none changed. Rescue and top-out: none.
- **Look.** A bright balloon on a string tied to the piece's top cube. The string tightens on the warning. Colour per balloon varies; pastel.
- **Audio.** Proposed `SFX_SP_BALLOON_BOB` (soft rubber squeak).
- **Fits.** Meadow (`src/levels/meadow/meadow_01/meadow_01.json:41` uses `balloon` in its legacy plan), carnival, celestial, kite bonus (a basket under a kite). The levels.md frame does not use it in meadow_01.
- **Intro and teach.** Easy first twist: slower fall is a gift. Hint: "Balloon pieces float."
- **Fairness.** Risk: low. Slow time is beneficial; the bob can lift a piece once.
- **Engine.** EXISTS (`balloon.gd`). Balloon art: gap, 1 day.
- **Source.** The Balloon Race carts in `mockup_16.jpg`.

**BK-27 bubble piece (`bubble` tag)**
- **What.** A piece that floats up instead of locking down. It pops at the ceiling.
- **Rule.** Trigger: on lock a bubble-tagged piece does not stay. It rises rigidly to the next occupied surface above or the ceiling (`bubble.gd:20-22`). If it reaches within 4 layers of the top (`layer_count()-4`), it is removed as displaced and emits `bubble_pop` (`:23-30`). Otherwise it lodges under the surface it met. Fill: normal if it lodges. Gravity: upward. Other specials: it can rise through gaps only. Rescue: wiped if lodged. Top-out: it never adds height at the top because it pops there.
- **Look.** Clear soap bubble around the piece with a rainbow sheen, wobble while falling. The pop is a spray of droplets.
- **Audio.** Proposed `SFX_SP_BUBBLE_POP`.
- **Fits.** Underwater (mockup `Deep Sea Bubble Build` uses bubble blocks), ice, candy (bubble gum).
- **Intro and teach.** Underwater_01. The preview arrow points up.
- **Fairness.** Risk: it fills a hole you need empty. Counterplay: preview of the rise end; a bubble piece is always a small shape (helper family) in tutorial levels.
- **Engine.** EXISTS (`bubble.gd`). Preview of the rise end: NEW, 1 day, ui-programmer.
- **Source.** `mockup_10.jpg` Deep Sea Bubble Build and the bubble-gem underwater cube in `biome_block_materials_ref.png`.

**BK-28 ember piece (`ember` tag)**
- **What.** A hot piece that burns down into the stack when it lands.
- **Rule.** Trigger: on lock. Effect: for each cube with nothing under it in the piece, remove cells below to depth `drill_depth` (default 1, clamp 1 to 3) as damage (`ember.gd:21-28`), then `request_settle` so the stack above falls (`:29`). Emits `ember_melt`. Fill: normal. Gravity: settle collapse follows. Other specials (resolved, 3.1b): it removes every non-empty target with cause DAMAGE (`:28`). `fixed` cells (rock, shelf, sponge) survive. `anchored`-only cells (licorice, climber boss) are removed, and a `blast_safe` goal object survives. Frosting and locked cubes are removed. Rescue and top-out: the melt can lower height, which is helpful.
- **Look.** Orange glowing cracks and a flame wisp on the top face, trailing sparks while falling, scorch mark below after the melt.
- **Audio.** Proposed `SFX_SP_EMBER_MELT` (sizzle).
- **Fits.** Lava, clockwork furnace, candy (hot caramel), pirate (powder).
- **Intro and teach.** A lava level where the stack is too high. Hint: "Embers burn what they land on."
- **Fairness.** Risk: it melts a supporting cube. Counterplay: the shaft preview, `drill_depth` 1 by default.
- **Engine.** EXISTS (`ember.gd`). Gap: skip protected cells (0.25 day) and shaft preview (1 day).
- **Source.** The lava cube skin in `biome_block_materials_ref.png` and the volcanic vent in `volcanic_biome_sheet_ref.png`.

**BK-29 rainbow piece (`rainbow` tag)**
- **What.** A wildcard piece. Its cubes match any colour.
- **Rule.** Trigger: spawn with tag `rainbow` emits `rainbow_piece` (`rainbow_piece.gd:12-16`). On lock each cube gets status `rainbow: true`, id 27 (`:19-20`). Effect: in `colour_connect` and flavour `shape` goals (README lines 11 and 20) a rainbow cube matches any flavour; in plain layer clears it counts as a normal cube. Fill: normal. Gravity: normal. Rescue and top-out: normal.
- **Look.** A shimmering rainbow gradient on the whole piece, with a sparkle wipe every 1 s and a prism badge. Never a single hue.
- **Audio.** Proposed `SFX_SP_RAINBOW_SPARKLE`.
- **Fits.** Candy (flavour levels), neon, celestial, carnival.
- **Intro and teach.** Candy tier 2 where colours matter. Hint: "Rainbow fits any colour."
- **Fairness.** Pure help.
- **Engine.** EXISTS (`rainbow_piece.gd`).
- **Source.** Rainbow roads on the party boards (the user's note about the glowing glass grid in `party_biome_islands_ref.jpg`).

**BK-30 anvil piece (`anvil_drop`, wave 3)**
- **What.** A heavy piece that squashes gaps under it.
- **Rule.** Trigger: every `every` (default 6) non-injected spawn is flagged `anvil` (`anvil_drop.gd:14-21`). On lock it crushes up to `max_crush` gap cells under each of its columns (`:22-30` and README line 92). Fill: normal. Gravity: the crush closes air gaps, so cubes above fall. Other specials: a locked cube sits in a closed gap fine; a critter in a gap would be crushed (counterplay: critters are anchored, see Edge Cases). Rescue and top-out: it can lower the stack (it may help).
- **Look.** Black cast-iron look with a heavy "weight" label on the top face and a falling shadow that is darker than normal pieces; shakes the camera lightly.
- **Audio.** `heavy_land_thud` proposal (`SFX_SP_HEAVY_THUD`, AUDIO-NEW). `SFX_PIECE_LOCK_BIG` is a possible stand-in (`sfx-cue-list.md:41`).
- **Fits.** Clockwork, pirate, cave, meadow_09 (weights).
- **Intro and teach.** Early. Hint: "Anvils squash the gaps."
- **Fairness.** It can erase a gap you saved. Counterplay: pre-flag in the NEXT strip.
- **Engine.** EXISTS (`anvil_drop.gd`).
- **Source.** The big weight hammer and gear machines in `mockup_02.jpg` and `mockup_13.jpg`.

**BK-31 jelly piece (`jelly` tag)**
- **What.** A bouncy gummy piece. It hops one extra cell when it lands and a cube may slump after.
- **Rule.** Trigger: on land, once per piece (`jelly_piece.gd:16-17`). Effect: it translates along the last move direction by `jelly_bounce` (default 1) plus `jelly_bonus` goal counter, clamped 0 to 3 (`:18-23`). On lock, one locked cube may slump down (`:24-25`). Fill: normal. Gravity: normal. Rescue and top-out: normal.
- **Look.** Wobbling translucent gummy with a shine; squash and stretch on landing; a spring-coil badge.
- **Audio.** Proposed `SFX_SP_JELLY_BOING`.
- **Fits.** Candy, carnival, underwater jelly.
- **Intro and teach.** Candy. Hint: "Jelly hops when it lands."
- **Fairness.** The hop follows the last move: you can control it. Counterplay: stop moving before landing.
- **Engine.** EXISTS (`src/mechanics/candy/jelly_piece.gd`).
- **Source.** The jelly pieces in `mockup_08.jpg` (Sugar Rush Stack).

**BK-32 mystery piece (`mystery_piece`, wave 3)**
- **What.** A "?" piece. It is announced earlier in the preview, then swapped for a surprise shape from the level's pool.
- **Rule.** Every Nth spawn is swapped for a seeded pool shape and announced earlier by `mystery_preview` (README Wave 3 table). Fill, gravity: the swapped piece is normal. Fairness is kept by the preview.
- **Look.** A purple "?" gift-box skin on the preview card and a sparkle when it reveals.
- **Audio.** Proposed `SFX_SP_MYSTERY_REVEAL`.
- **Fits.** Carnival, party tournaments.
- **Intro and teach.** Party play. Hint: "Surprise piece next!"
- **Fairness.** All players share the seed (party rule 8).
- **Engine.** EXISTS (`src/mechanics/wave3/mystery_piece.gd`).
- **Source.** The party boards' "next item" slots (`mockup_12.jpg`).

#### 3.2.b Special BLOCK KINDS, part 5: NEW kinds (proposed, `*`)

Every entry here is a proposal for the user to accept, change or cut. Each needs a new row in `blocks.json` (next free `kind_id` is 25) and a rule. The existing rule JSON schema (`assets/data/rules/*.json`) is the pattern. Size is in working days.

**BK-33* gem cube (kind `gem`, glyph `G`)**
- **What.** A glittering gem embedded in a cube. Clear its layer to collect it.
- **Rule.** Placed by level data (`starting_contents`) or hailed in by `mushroom_popup` with `object_kind: gem`. Trigger: its cell is removed by a genuine layer clear (same collection rule as the item cube, `items.md` rule 2). Effect: +`gem_points` (100) score and +1 `gems` goal counter; removal by bomb, ember, pest or rescue wipe does NOT collect it (the gem is lost, with a sad puff). Fill: `fills_layer` true, so it is part of its layer. Gravity: normal. Other specials: `pest` skips kinds other than block and starter (`pest.gd:49`). A blast, ember or Smash removes it (cause DAMAGE) unless it carries the NEW `blast_safe` flag; a rescue wipe removes it unless it carries `rescue_safe` (3.1b). A level that needs its gems sets both as `goal_object`. It does NOT use `anchored`, which would block the clear that collects it (`board_state.gd:687`). Top-out: normal height.
  - **Occlusion (r2):** a gem sits in the lowest `gem_max_layer` layers, which the stack buries from the three-quarter camera. So every gem draws the gold see-through outline (3.6) and a floor-level marker at its column that stays visible while a layer above it is sealed. The player always knows which layer to clear.
- **Look.** A faceted gem in a gold-trimmed cube, colour by gem type (blue, green, purple), a sparkle pulse every 1.2 s and a gold rim. Skins: meadow flower-bud, ice crystal, cave crystal cluster, underwater pearl cluster, lava ember-shard, celestial star-shard, clockwork gear-jewel.
- **Audio.** Proposed `SFX_SP_GEM_COLLECT` (a rising chime; `Loot Gold.wav` as a temp).
- **Fits.** Cave, ice, lava, underwater, celestial. A "collect N gems" goal fits `dig_rescue`-style levels and gem-grab minigames.
- **Intro and teach.** Cave 01. Hint: "Clear the layer to grab the gem."
- **Fairness.** Risk: a gem buried under a full stack can never be reached. Counterplay: place gems only within the lowest `gem_max_layer` layers and never in a pocket; the validator proves a path with the solver (G5).
- **Engine.** NEW. Kind row 0.1 day, rule 1 day, view 1 day. Owner: gameplay-programmer, technical-artist.
- **Source.** Gem pickups on the floor in `mockup_01.jpg` (Rubble Rumble), `mockup_03.jpg` (Frenzy Footholds), `mockup_14.jpg` (Gem Grab); crystal cube on top in `mockup_20.jpg` (Candy Climb); shard ornaments on the volcanic and underwater sheets.

**BK-34* magnet block (kind `magnet`, glyph `M`)**
- **What.** A horseshoe cell that tugs the falling piece one cell toward it.
- **Rule.** Placed by level data. Trigger: a falling piece within `magnet_range` (2) columns of the magnet and above it, once per piece, after a `pull_warn_ms` (600) telegraph of field lines. Effect: one `try_translate` toward the magnet (blocked pulls are skipped), the same effect as `magnet_pull` (`src/mechanics/wave3/magnet_pull.gd:12-30`) but tied to a visible cell instead of a timer. Fill: `fills_layer` true. Gravity: unaffected. Other specials: gust applies first, then the pull; a hung (anchored) piece ignores it; a ghost piece ignores it. Rescue: wiped. Top-out: none.
- **Look.** A red-and-silver horseshoe on a cube, blue field arcs that pulse toward the piece, tiny filings. Skins: space-lab magnet, pirate lodestone, clockwork electromagnet, neon beam emitter.
- **Audio.** Proposed `SFX_SP_MAGNET_HUM` (loop in range), `SFX_SP_MAGNET_PULL`.
- **Fits.** Clockwork, neon, celestial, cave.
- **Intro and teach.** Clockwork 02. Field arcs appear before the pull.
- **Fairness.** One cell, telegraphed, avoidable by moving out of range or hard dropping before the warning ends.
- **Engine.** NEW (reuses `magnet_pull`). 1.5 days, gameplay-programmer.
- **Source.** Magnet crane and beams in `mockup_05.jpg` (Galactic Grab), `mockup_09.jpg` (Magnetic Mash), the grapple magnet in `mockup_03.jpg`.

**BK-35* ice cube (kind `ice`, glyph `i`)**
- **What.** A slippery cube. A piece landing on it slides one cell.
- **Rule.** Placed by level data or made by the `frozen` shell. Trigger: a falling piece comes to rest with any cube on top of an ice cube. Effect: it slides one cell in the last move direction (same as `ice_slide`, `ice_slide.gd:11-25`, but only when the support is ice). Melt: removed when a burning cell or ember piece is face-adjacent, or after `ice_melt_locks` (0 = never). Fill: `fills_layer` true. Gravity: normal. Other specials: goo on ice cancels the slide (sticky wins); a bounce pad above ice: bounce first, slide skipped. Rescue: wiped.
- **Look.** Pale blue translucent cube with frost edge, a glint sweeping every 2 s, snowflake badge on the top (the biome sheet ice cube has a snow cap and flake, `biome_block_materials_ref.png`).
- **Audio.** Proposed `SFX_SP_ICE_SLIDE` (glassy squeak).
- **Fits.** Ice biome, carnival rink, pirate (floe).
- **Intro and teach.** Ice 01. The ghost shows the slide end.
- **Fairness.** One cell, previewed. A slide off an open rim is a topple (see Edge Cases).
- **Engine.** NEW. 1.5 days gameplay-programmer; ghost preview 1 day ui-programmer.
- **Source.** Ice blocks in `biome_block_materials_ref.png`, `mockup_02.jpg` (Summit Scramble), `mockup_11.jpg`.

**BK-36* fire tile (floor tile, hazard)**
- **What.** A floor tile that is hot on a beat. A cube on it burns away while it is hot.
- **Rule.** A level marks floor cells `fire`. Each tile cycles: `fire_on_locks` (2) hot, `fire_off_locks` (3) cool, with an orange glow one lock before it turns hot. At resolve, a layer-0 cube on a hot tile is removed as damage (the cubes above settle). A cool tile is a normal floor. Fill: the tile is floor, not a layer cell. Clears: clearing a layer does not stop the fire. Rescue: no refund. Top-out: none.
- **Look.** A cracked floor tile with flames when hot, embers when warning, soot when cool. The flame animation is the 0.5 s tell.
- **Audio.** Proposed `SFX_EV_FIRE_WARN`, `SFX_EV_FIRE_BURN`.
- **Fits.** Lava, clockwork (furnace), candy (oven tile).
- **Intro and teach.** Lava 03. The tile shows its cycle.
- **Fairness.** Fixed, visible cycle; plan around the cool window.
- **Engine.** NEW (extends `crumble_tiles`). 2 days, gameplay-programmer plus technical-artist.
- **Source.** The fire tiles inside the board in `party_biome_islands_ref.jpg` (the user's note: "holes and fire tiles inside the board").

**BK-37* floor hole (mask pit)**
- **What.** A missing floor cell. Nothing can rest there. A piece that slides or bounces into it falls out of play.
- **Rule.** Uses `board.mask` inactive cells (`level-identity-spec.md:11-16`; `WtIslandBuilder.build_island` builds from active cells). Cells over a hole are not valid rest cells. A piece pushed so every cube is over holes falls through; partly over holes it is held by the rest. Wobble and tilt already pop pieces off edges (`wobble.gd`, `tilt_plate.gd`). Inactive cells are excluded from layer fill. Rescue and top-out: normal.
- **Look.** A dark pit with a soft inner glow and bevelled rim; lava in lava biomes, water in meadow, stars in celestial.
- **Audio.** Proposed `SFX_PL_HOLE_FALL`.
- **Fits.** Every biome; cross, ring, twin-island footprints.
- **Intro and teach.** From meadow_06 terraces onward; footprints explain themselves.
- **Fairness.** The validator checks every level can be tiled around holes (G5).
- **Engine.** EXISTS for masks; G16 verify 1 day, fix 2 (`levels.md:557`). Per-biome hole art NEW.
- **Source.** The floor holes in the lava keep board in `party_biome_islands_ref.jpg`.

**BK-38* switch plate (floor tile and trigger)**
- **What.** A glowing tile. Cover it with a locked cube and something happens.
- **Rule.** A level marks floor cells `switch` with an `effect`: `open_gate`, `flip_wind`, `start_bridge`, `ring_bell`. Trigger: a lock puts a cube on the tile. Effect: fires once (`once: true`) or toggles on cover and release. Fill: floor. Gravity: unaffected. Other specials: clearing the pressing cube's layer releases it (toggle mode flips back). Rescue: a wipe releases it. Top-out: none.
- **Look.** A round plate with a coloured ring (blue idle, gold pressed) and a small arrow to what it controls. The target pulses in the same colour.
- **Audio.** Proposed `SFX_SP_SWITCH_CLICK`.
- **Fits.** Clockwork, cave, pirate, meadow bonus (open the hoop), carnival.
- **Intro and teach.** One per level; the linked gate pulses in matching colour.
- **Fairness.** The effect is outlined before pressing. Never required unless the level says so.
- **Engine.** NEW. 2 days, gameplay-programmer.
- **Source.** The glowing blue pads in `mockup_03.jpg`, `mockup_13.jpg`, `mockup_14.jpg`.

**BK-39* gate (movable wall)**
- **What.** A wall segment that opens and closes (a pen gate, a stone door).
- **Rule.** A mask cell group switched by `request_mask`, the call used for the Hearth Stump cage (gap G1, `levels.md:542`). Triggers: switch plate, wound keyhole, layer clear, or wave schedule. Closed = inactive floor (blocks pieces and walkers). Open = empty. Fill: excluded. Rescue: the gate state is kept. Top-out: none.
- **Look.** Wooden gate with a lantern, stone door in cave; a lit lintel shows open or shut.
- **Audio.** Proposed `SFX_SP_GATE_OPEN`, `SFX_SP_GATE_SHUT`.
- **Fits.** meadow_04 pen gates ("the pen has two gates", `levels.md:186`), cave, clockwork, pirate.
- **Intro and teach.** meadow_04.
- **Fairness.** Gate timing shows in advance (a filling bar).
- **Engine.** PARTIAL. `request_mask` exists (README line 57). Gate rule NEW, shared with G1 and G7, 2 days.
- **Source.** Pen with fence in `mockup_15.jpg`, stone doors in `mockup_02.jpg`.

**BK-40* peg (post, branch or spindle)**
- **What.** A thin standing post on a platform cell. Hollow pieces drop over it.
- **Rule.** A level marks a footprint cell `peg` with height `peg_h` (1 to 3). It is a column, not a layer cell: the cells it passes through are `fixed` with `static_geometry`, so they leave the active count and never block a layer (3.1b, `board_state.gd:94-96`). It is solid for non-hollow pieces (they cannot overlap it). A hollow piece whose hole lines up may pass over it (SH-01), which is a fit. Never cleared. Rescue: stays (`fixed`). Top-out: `static_geometry` adds no height.
  - **Readability (r2):** a peg is thin, so its base is a full 1-cell gold disc, a vertical gold beam shows above it while a hollow piece is falling, and the see-through outline (3.6) keeps it visible behind blocks.
- **Look.** A wooden post with a gold cap; a ring glow on its base while a hollow piece is falling.
- **Audio.** `SFX_SP_RING_FIT` (proposal).
- **Fits.** Meadow fence posts, carnival ring toss, clockwork spindles, pirate belaying pins, cave stalagmites.
- **Intro and teach.** First hollow level.
- **Fairness.** The validator guarantees a hollow piece in the bag when a peg goal is set.
- **Engine.** NEW. 3 days (with SH-01), gameplay-programmer.
- **Source.** Pillars and idol posts in `party_biome_islands_ref.jpg`, `mockup_11.jpg`; pillar rule in `obstacles.md`.

**BK-41* stone pillar (full-height column)**
- **What.** A fixed column from floor to sky.
- **Rule.** `obstacles.md` Core Rule 4: unbreakable, counts as filled in every layer, layers clear around it; not allowed with conveyors or flips that would move it (rule 10); at most `pillar_max_share` (25 percent) of the footprint. In the engine `pillar` appears only in view and layout code (`src/view/wt_stage.gd`, `src/view/wt_island_builder.gd`, `src/core/modules/bridge_dash_layout.gd`), not as a rule. Proposed: masked-off columns marked `static_geometry` like the meadow_01 cage, drawn as a pillar.
- **Look.** A stone column with moss or crystal and a tapered cap, never a piece colour.
- **Audio.** Normal land.
- **Fits.** Meadow ruins, cave, celestial, clockwork.
- **Intro and teach.** Not taught; reads as scenery with a shape.
- **Fairness.** Validator for share and tiling.
- **Engine.** PARTIAL. Design exists. 0.5 day on top of G16 mask work, gameplay-programmer.
- **Source.** `obstacles.md`, and the stone pillars flanking the board in `party_biome_islands_ref.jpg`.

**BK-42* hang point (branch, rail, rope loop)**
- **What.** The thing a hook catches on (SH-05).
- **Rule.** A level marks a cell or face `hang`. A hook cube that locks beside or under it makes its piece `hung` (SH-05, 3.1b). The hang point is a `fixed` `static_geometry` prop (it adds no height and does not block layers). Normal support otherwise. Rescue: stays. (r2: the "anchor bolt" variant is cut; `hung` is the only hold status.)
- **Look.** A branch stub with a leaf, a brass ring, or a rope loop; gold glow when a hook is above.
- **Audio.** `SFX_SP_HOOK_CLINK` (proposal).
- **Fits.** Forest, pirate, cave, clockwork, carnival.
- **Intro and teach.** With the hook shape.
- **Fairness.** Always optional.
- **Engine.** NEW (with SH-05).
- **Source.** Vines and ropes in `mockup_10.jpg`, `mockup_12.jpg`.

#### 3.2.c OBJECTS on the platform (existing engine rules)

Objects are not falling pieces. Some are grid cells (a kind). Most are rule props: a marker, a column, a tile or an actor that a rule reads. The Entry fields are shorter here. All share conventions 1 to 8.

A note on clocks. Several rules below run on wall-clock milliseconds (`lava_rise`, `lava_lid`, `quake`, `crab_claw`, `storm_bolt`, `magnet_pull`, `gust`, `defend_core`, `race_rival`, `thin_ice`). The frame's timer rule (`levels.md:23`) bans a visible countdown on Tetris-variant levels and removed the rising-water hazard for that reason (`levels.md:565`). Attacks in a wave schedule are allowed, because the wave is a story event.

**User ruling (Appendix E, "Hidden timer"):** millisecond schedules stay on Tetris-variant levels, but the HUD shows no countdown. The telegraph is an actor tell plus a sound before every hazard. So this doc does NOT add a lock-count schedule mode (the r1 proposal `schedule_mode: locks` is removed). The fairness of a hidden ms schedule is checked by F3b (reaction time and interval versus piece time), and a hazard may not use a warning shorter than `T_warn_min` (F3b). Assists: every ms hazard pauses during a rescue animation, a pause menu and the level intro (framework "Suspended", `buffs-debuffs.md` rule 4), and a settings option "Slower hazards" multiplies every hazard interval by 1.5 and every warning by 1.25 (knob `assist.hazard_slow`, 3.7). Accessibility: the sound cue and the actor tell are both required; a deaf player relies on the tell, a blind player on the sound.

**OB-01 defend core (the thing under attack)**
- **What.** A small thing with hit points that attacks aim at: the sprout in meadow_02.
- **Rule.** A core tile group on layer 0 with `core_hp` (3). The tiles are a `core` list of `[x, z]` pairs in the level params, with the 2x2 board centre as the default (`defend_core.gd:3-5`). **For meadow_02 the core sits in the inner curve of the crescent ledge** (`levels.md:106,122`), so the level sets `core` to those cells, not the centre. Every `attack_every_ms` a shot is announced `warn_ms` (2000) earlier, enters at a seeded edge column and travels inward along its lane. The first column with cubes loses its top cube (armour). A lane that reaches an empty core column deals `core_damage`. At 0 hp the run fails (`defend_core.gd:3-10,24-40`). Fill: core tiles are floor markers, not cubes (they are listed in `core_tiles(api)`, not placed as cells), so the cells above them are ordinary cells and count for layers normally. Rescue: a rescue never heals the core. Top-out: normal.
  - **Readability (r2):** a buried core is a risk, because the wall the player builds hides the sprout. The sprout stands taller than the wall height needed to shelter it (a 3-cell stalk with a bloom), and the see-through rule draws a gold outline through blocks in front of it (3.6).
- **Look.** A sprout in a small mound, leaning with each hit; three leaf pips for hp. A wind line is shown across the board before each shot.
- **Audio.** Proposed `SFX_EV_DEFEND_WARN`, `SFX_EV_DEFEND_HIT`.
- **Fits.** meadow_02 Windbreak (core: sprout, 3 hp, `levels.md:98-127`), meadow_10 phase 1, ice (igloo), pirate (treasure), lava (egg).
- **Intro and teach.** meadow_02. Weathervane star spins before each gust (teach by showing the line).
- **Fairness.** Warn 2 s ahead, seeded and replayable, wave schedule shortens warnings slowly.
- **Engine.** EXISTS (`src/mechanics/wave4/defend_core.gd:11`). Gap G9 (`levels.md:550`): wire it with a wind attack, a unit test and one level run, 4 days shared with two other rules, gameplay-programmer.
- **Source.** Castle and fort defence boards (`style/09_minigames_a.jpg`, `mockup_11.jpg`).

**OB-02 wind gust and weathervane**
- **What.** A wind blast that pushes the falling piece sideways. A weathervane star spins before it.
- **Rule.** A seeded gust schedule; a gust due with no falling piece is dropped (`gust.gd:2`). Warning arrow and wind sound ahead (`sfx-cue-list.md:82-83`, `SFX_EV_GUST_TELEGRAPH`, 1 s). Effect: one cell push of the active piece (not a stack write). Gravity: unaffected. Other specials: bounce, ice slide and balloon apply their effects around it; balloon bob and gust do not cancel each other. Rescue and top-out: none.
- **Look.** Streaked arrow across the grass, grass bends, leaf and dandelion particles, the gold star weathervane spins to the direction.
- **Audio.** `SFX_EV_GUST_TELEGRAPH`, `SFX_EV_GUST`.
- **Fits.** meadow_02 (the attack of `defend_core`), meadow_09 (the sail wind), meadow_10 phase 1 (`levels.md:518`). The bonus wind lanes are track events (OB-32), not this rule. Celestial, ice (blizzard), pirate (storm), cave (draft).
- **Intro and teach.** meadow_02, via the weathervane.
- **Fairness.** Always telegraphed; one cell; the landing marker updates after a gust.
- **Engine.** EXISTS (`src/mechanics/behaviour/gust.gd`). Weathervane view: NEW, 1.5 days (G9 group), technical-artist.
- **Source.** The wind cloud in `mockup_04.jpg` (Chroma Sky Climb); the weathervane is the frame's own.

**OB-03 stone throw (`storm_bolt`) and the gnome**
- **What.** A thrown stone or bolt that knocks the top cube out of a marked column.
- **Rule.** Warn on a seeded occupied column, then damage its top cube; an emptied column fizzles (README Wave 3 table; `storm_bolt.gd:2`). In meadow_05 each stone is shown 2 s before it lands (`levels.md:201-204`). Fill: removed cube opens a hole. Clears: a clear in the column before impact may cancel it (proposed: use the same cancel-on-clear idea as `crab_claw`). Rescue: none.
- **Look.** A grey stone with a landing ring and a thin arc line from the gnome; on hit, a puff and flying fragments.
- **Audio.** `SFX_EV_STONE_WARN`, `SFX_EV_STONE_HIT` (AUDIO-NEW).
- **Fits.** meadow_05 Gnome Hedge. Pirate (cannonball), cave (falling rock), ice (icicle).
- **Intro and teach.** meadow_05. Warning ring plus a gnome wind-up pose.
- **Fairness.** 2 s warning. Volleys never land in the same column twice in a row (proposed).
- **Engine.** PARTIAL. The bolt exists (`storm_bolt.gd`). Stone skin, sheep peek view, stone-cart pile meter and fail rule are gap G12 (2.5 days, gameplay-programmer plus technical-artist).
- **Source.** Gnomes throwing acorns and stones in `mockup_12.jpg` (Wacky Party meadow panel).

**OB-04 tilt plate and tilt gauge**
- **What.** The platform is a plate on a pivot. It tips toward the heavy side. Blocks slide off if it tips too far.
- **Rule.** After each resolve, tilt tau = centre-of-mass offset in permille. `warn_at` (0.7) of the `slip_threshold` (0.6) warns. At the threshold for `slip_after_resolves` resolves, the `slip_count` top cubes of the heavy half are removed off the rim (`tilt_plate.gd:1-40`). Fixed kinds (rocks) are excluded (`:26`). Real Jolt physics is NOT implemented (`:9-11`). Fill: normal. Clears: clearing lowers weight, which shifts tilt. Rescue: a rescue changes balance; run the tilt check after it.
- **Look.** A round plate that visibly tips, a rim line for the slide limit, a tilt gauge on the HUD. Sheep slide on the plate.
- **Audio.** `SFX_PL_WOBBLE_CREAK` style creak scaled by tilt (`sfx-cue-list.md:88`), `SFX_PL_WOBBLE_SLIP` on slip (`:89`).
- **Fits.** meadow_09 Tilting Hill (slip line 0.7 to 0.5, `levels.md:343`), meadow_10 phase 3, pirate (rocking ship), carnival (see-saw), cake plate (`mockup_05.jpg`).
- **Intro and teach.** meadow_09. Gauge plus "stack on the high side".
- **Fairness.** A warning always comes first. The preview of the landing tilt (ghost weight) is proposed.
- **Engine.** PARTIAL. Grid rule EXISTS (`src/mechanics/wave4/tilt_plate.gd:14`). The visible tilt view is gap G9. Heavy weights are a signature change, not a tweak: `measure(size, cells)` is static and takes cells only (`:72-86`) and `weighted_cells` returns a cell list (`:57-68`), so both need a weight per cell (GAP-5, 1.5 days, gameplay-programmer).
- **Source.** The spring and tilt plates in `party_modes_ref.jpg`, `party_minigames_ref.jpg` (Wobble Builders), `mockup_03.jpg` (Tumbling Towers) and `mockup_05.jpg` (Cake Stackers).

**OB-05 rival marker (`race_rival`)**
- **What.** A rival with its own pace. It fills a hidden bar and wins if it gets to 100 percent first.
- **Rule.** `rival_rate` percent per second, optional head start and rubber band, warning at `rival_warn_pct`. A tie goes to the player (`race_rival.gd:1-8`). Fail through `request_fail`. Events: `race_progress`, `race_rival_warning`, `race_won`, `race_rival_finished`.
- **Look.** A second kite or cart marker on a progress strip.
- **Audio.** Proposed `SFX_EV_RIVAL_PASS`.
- **Fits (r2).** NOT used in the Meadow. The user ruled "no rival speed race in this round" (`levels.md:607-609`, section 8), so the old `levels.md:408` rival (0.9 to 1.1 pace) is superseded and meadow_bonus has no rival. This rule stays available for versus and tournament race rounds and for later biomes (candy rails, jungle bridge).
- **Intro and teach.** First tournament race round. The strip is the teacher.
- **Fairness.** Rubber band; second place still passes with one star.
- **Engine.** EXISTS (`src/mechanics/wave4/race_rival.gd:9`). The wiring work of gap G9 for the kite is no longer needed in the Meadow.
- **Source.** Rival racers on `party_minigames_ref.jpg` (Block Bridge Dash) and `mockup_03.jpg` (Rolling Rumble).

**OB-06 fog bank (`fog`)**
- **What.** Mist that hides the top layers. Collision stays real.
- **Rule.** Each locked piece fades from its own lock time, respects staged clear activation, clears reveal it, and the ghost neighbourhood is always lit (README line 33; `src/mechanics/behaviour/fog.gd:7`).
- **Look.** Soft white volume above a line, edge feathered, a glowing landing marker visible through it.
- **Audio.** `SFX_EV_FOG_ROLL`, `SFX_EV_FOG_REVEAL` (`sfx-cue-list.md:92-93`).
- **Fits.** meadow_07 Fog Frolic, forest, cave, celestial.
- **Intro and teach.** meadow_07 (fog thickens with height).
- **Fairness.** Landing marker and next preview never fade.
- **Engine.** EXISTS. Fog volume art: gap (technical-artist).
- **Source.** Cloud and mist in `style/01_story_flow.jpg` (checked in the work log).

**OB-07 conveyor and mill belt**
- **What.** Parts of the stack slide along a belt.
- **Rule.** Every N locks the occupied cubes translate together (a cyclic permutation preserving identity and status) (`mill_belt.gd:2`; README line 38). Specials ride with it, so a goo or key moves with its cell.
- **Look.** Visible belt tiles with chevrons, rollers turning.
- **Audio.** `SFX_EV_MILL_BELT` (`sfx-cue-list.md:103`).
- **Fits.** meadow_10 (older plan), clockwork (conveyor), candy (rails), neon.
- **Intro and teach.** Clockwork. Chevrons show the direction.
- **Fairness.** Fixed schedule, previewed one lock ahead (proposed).
- **Engine.** EXISTS (`conveyor.gd`, `mill_belt.gd`).
- **Source.** `mockup_04.jpg` Clockwork Conveyor, `mockup_06.jpg` Factory Frenzy.

**OB-08 turntable and OB-09 piston**
- **What.** A turntable quarter-turns a square stack. A piston punches a row in from the wall.
- **Rule.** Turntable: every N locks the stack is one simultaneous permutation (`turntable.gd:2`). Piston: a row prefix shifts into its first empty cell, full rows jam (`piston_punch.gd:2`).
- **Look.** A round rotating disc under the stack with arrows; a brass piston on the wall with a push arrow.
- **Audio.** Proposed `SFX_EV_TURNTABLE`, `SFX_EV_PISTON`.
- **Fits.** Clockwork, carnival (carousel), pirate (capstan).
- **Intro and teach.** Clockwork 04 to 07.
- **Fairness.** Previewed; periodic.
- **Engine.** EXISTS.
- **Source.** Gear plate in `mockup_08.jpg` (Clockwork Chaos).

**OB-10 woodpecker and OB-11 squirrel thief (forest critters)**
- **What.** A bird knocks loose unsupported cubes. A squirrel steals one exposed cube from the fullest layer.
- **Rule.** Woodpecker: outlines unsupported cubes at warning time, pops that subset at resolution (`woodpecker_knock.gd:2`). Squirrel: every `heist_every_locks` (6, clamp 3 to 12) marks an exposed cube in the fullest unfinished layer (min fill 0.5) one lock ahead; a clear in that layer or covering the cube cancels it (`squirrel_heist.gd:14-45`).
- **Look.** A woodpecker on a branch pecking with a dotted outline on targets; a squirrel with a nut and a sparkle ring on the target.
- **Audio.** Proposed `SFX_EV_WOODPECKER_KNOCK`, `SFX_EV_SQUIRREL_STEAL`.
- **Fits.** Forest. Meadow (squirrel) later.
- **Intro and teach.** Forest 02 and 05.
- **Fairness.** Both warn; the squirrel is cancelled by a clear.
- **Engine.** EXISTS (`woodpecker_knock.gd`, `src/mechanics/forest/squirrel_heist.gd`). Actor art: gap.
- **Source.** Own idea.

**OB-12 crab claw**
- **What.** A claw warns a column and steals its top cube.
- **Rule.** After `claw_start_layers` (2) clears, warns `claw_warn_ms` (2000), then removes the top cube of the column on resolve (`crab_claw.gd:11-40`). Any clear during the warning cancels it. `claw_grab` 0 makes it a decoy.
- **Look.** A giant crab claw rising from the edge with a dotted column highlight; "clear a layer to cancel!" message.
- **Audio.** Proposed `SFX_EV_CLAW_WARN`, `SFX_EV_CLAW_GRAB`.
- **Fits.** Underwater, pirate.
- **Intro and teach.** Underwater 04.
- **Fairness.** Cancel by clear.
- **Engine.** EXISTS (`src/mechanics/underwater/crab_claw.gd:3`).
- **Source.** The Kraken and tentacle boards (`mockup_04.jpg`, `mockup_07.jpg`).

**OB-13 lava floor rise, OB-14 lava lid, OB-15 quake, OB-16 geyser vent**
- **What.** Four lava-biome pressures: the floor melts up, a soft ceiling lowers, overhangs shake loose, and a geyser pops a rock or pad.
- **Rule.** Floor rise: every `melt_every_s` (35) the floor rises one layer, up to `melt_max` (3), with a 3 s warning (`lava_rise.gd:13-37`). Lid: lowers up to `lid_max` (2) layers; clears lift it by `lid_push_per_clear` (1) and cancel a pending drop (`lava_lid.gd:14-40`). Quake: outlines up to `quake_max_cubes` (6) unsupported overhangs 2 s ahead and removes them (`quake.gd:13-40`). Geyser: marks a free supported cell, then pops a 2-hit rock or a bounce pad (`lava_rock_spawn.gd:13-38`). Fill: cubes lost in a rise are not clears. Rescue: resolved from the code. A floor rise calls `request_floor`, which removes the bottom planes with `Cause.MASKED` (`board_state.gd:709-717`), and MASKED removes everything, even `fixed` cells (`:683-684`). A rescue wipe uses `Cause.RESCUE` and skips `fixed` and `anchored` cells (`:685-688`). So a rise and a rescue are different: a rise takes rocks and shelves in the bottom planes, a rescue does not. A rescue after a rise wipes `rescue_wipe_layers` above the new floor. The two never run in the same resolve (the rescue is a top-out outcome, the rise is a timer event at `on_resolve_end`).
- **Look.** Glowing orange lava seams that brighten before action; a rim glow; a lid shown as a dim ceiling; dotted outlines on quake targets; a vent with smoke and a ring.
- **Audio.** `lava_warning` rumble; proposed `SFX_EV_LAVA_RISE`, `SFX_EV_QUAKE`, `SFX_EV_GEYSER`.
- **Fits.** Lava biome and celestial (the lid's "Moon's pillow" message).
- **Intro and teach.** Lava 01 to 05, one per level.
- **Fairness.** Millisecond schedules with a hidden clock (Appendix E). The actor tell plus a sound warn before every one: rise 3000 ms (`melt_warn_ms`), lid 3000 ms (`lid_warn_ms`), quake 2000 ms (`quake_warn_ms`) with the targets outlined, geyser 1 lock with a marked cell. F3b checks each warning against reaction time and each interval against piece time. Counterplay: clears relieve or cancel (the lid lifts per clear, `lava_lid.gd:19-30`; the quake and rise do not cancel, so their intervals are long).
- **Engine.** EXISTS (`lava_rise.gd`, `lava_lid.gd`, `quake.gd`, `lava_rock_spawn.gd`). No lock-count mode is built (removed by Appendix E). The "Slower hazards" assist multiplier is NEW (0.5 day, gameplay-programmer).
- **Source.** Lava Escape and Volcano Dash in `mockup_13.jpg`, `mockup_16.jpg`; volcanic sheet.

**OB-17 crumble tile, OB-18 quicksand tile**
- **What.** Cracked floor tiles break after touching locks and drop the column above one cell. Quicksand swallows the bottom cube every N locks.
- **Rule.** Crumble: tile breaks after N locks touch it (`crumble_tiles.gd:2`). Quicksand: every N locks the floor cube sinks and the column above slides down (`quicksand.gd:2`).
- **Look.** Cracked floor with dust; swirling sand disc.
- **Audio.** Proposed `SFX_EV_TILE_CRUMBLE`, `SFX_EV_SAND_SINK`.
- **Fits.** Cave, dune bazaar, pirate.
- **Intro and teach.** Mid-biome.
- **Fairness.** Crack stages visible before break.
- **Engine.** EXISTS (wave 3).
- **Source.** Cracked lava floor in `mockup_04.jpg` (Digging Frenzy).

**OB-19 thin ice rim and OB-20 ice slide**
- **What.** The rim strips of the platform melt away. A landing piece slides once.
- **Rule.** Thin ice telegraphs one rim strip and removes it at the next resolution, keeping a minimum width (`thin_ice.gd:2`; README line 41). Ice slide: on landing a piece slides `slide_cells` (1, clamp 1 to 2) cells in `slide_dir`, starting after `start_after_clears` clears (`ice_slide.gd:11-25`).
- **Look.** A pale cracked rim strip with a blue pulse; shiny glassy floor with sparkle.
- **Audio.** Proposed `SFX_EV_ICE_CRACK`, `SFX_EV_ICE_SLIDE`.
- **Fits.** Ice biome; carnival (ice rink).
- **Intro and teach.** Ice 01 to 03.
- **Fairness.** Preview of the strip; slide is one cell with a ghost end.
- **Engine.** EXISTS (`thin_ice.gd`, `ice_slide.gd`). Ghost end of the slide: NEW, 1 day.
- **Source.** `mockup_11.jpg` Slippery Sumo Iceberg, `mockup_12.jpg` Glacier Gauntlet.

**OB-21 syrup band and OB-22 speed bump (candy)**
- **What.** A sticky band slows pieces and then glides once. A speed bump notches the fall faster when the stack is untidy.
- **Rule.** Syrup: slow above authored rows, preview the glide end, glide up to 2 cells once then lock (`syrup_band.gd:2`; README line 40). Speed bump: mood-driven notches telegraph 1 s ahead; clears calm one notch; the baseline ramps by minute (`speed_bump.gd:2`).
- **Look.** Amber syrup layer with drips; a bump sign with a rising gauge.
- **Audio.** Proposed `SFX_EV_SYRUP_SLOW`.
- **Fits.** Candy.
- **Intro and teach.** Candy 03.
- **Fairness.** Speed bump follows the user decision "pieces speed up over time" (`levels.md:597`).
- **Engine.** EXISTS (`syrup_band.gd`, `speed_bump.gd`).
- **Source.** Syrup-like candy sauce paths in `mockup_15.jpg` (Candy Dodger).

**OB-23 golden row, OB-24 star coin, OB-25 secret angle gem (pickups)**
- **What.** Pickups. A glowing gold layer pays a bonus when cleared. Coins float in empty cells. A hidden gem can be found by looking from a low angle.
- **Rule.** Golden row: clearing the gold layer pays a bonus and a goal counter, then gold moves up a layer (`golden_row.gd:2`). Star coins: state-only coins in empty cells; covering one with a lock collects it for score and goal; clears shift or collect coins (`star_coins.gd:2`). Angle gem: a secret placed at level start (`secret_placed`); collected only by an explicit tap with the matching `secret_id` (`angle_gem.gd:11-20`); gives the secret star.
- **Look.** Gold layer: honey glow and sparkle edge. Coin: spinning gold star in mid-air with a shadow dot on the floor. Angle gem: a faint glint visible only from the matching camera angle.
- **Audio.** `SFX_EV_GOLD_ROW`, `SFX_EV_COIN`, `SFX_EV_GEM_FIND` (AUDIO-NEW).
- **Fits.** Anywhere. The secret ending slot (meadow_08 hoop, h1 golden lamb, `levels.md:318,445`).
- **Intro and teach.** Coins from level 02; gem is secret.
- **Fairness.** Optional bonuses.
- **Engine.** EXISTS (`golden_row.gd`, `star_coins.gd`, `angle_gem.gd`). Coin view: gap (state only), 1.5 days, technical-artist.
- **Source.** Star coins in `mockup_03.jpg` and `mockup_06.jpg`, stars in `mockup_15.jpg`, gems in `mockup_14.jpg`.

**OB-26 Pip's catch (`mascot_catch`)**
- **What.** A helper critter that undoes one bad lock.
- **Rule.** Veto a covered-hole lock before board writes and return the same piece to spawn; `catches` (default 1) per level; clear and goal-winning placements are protected; `happy_only` needs tidiness 0.9 (README line 27; `mascot_catch.gd:1-12`).
- **Look.** A small critter leaps and carries the piece back.
- **Audio.** `SFX_PIP_CATCH`, `SFX_PIP_CATCH_RETURN` (`sfx-cue-list.md:109-110`).
- **Fits.** Early levels.
- **Intro and teach.** Level 02 style. The first catch is a free gift.
- **Fairness.** It is a safety net.
- **Engine.** EXISTS.
- **Source.** Own cast.

#### 3.2.c OBJECTS, part 2: NEW objects (proposed, `*`)

These are the level actors and props named in `levels.md` that do not exist yet, plus a few from the references. Gap ids are those of `levels.md` section 5.

**OB-27* herd animal (sheep, lamb, penguin, gummy bear, chick-walker)**
- **What.** A small animal that wanders the platform by itself. Blocks are its fences.
- **Rule.** Gap G7 (`levels.md:548`). Each animal has a cell, a heading and a speed (`wander_cells_per_s`, default 0.6). It walks straight until the next cell is a block or a gate, then turns to a free direction, preferring cells that lead toward gaps and the pen (`herd` rule per `levels.md:179`). It never climbs more than 1 layer. It cannot walk over a hole or off the rim except by the lose rule. While a piece is falling over it the animal steps aside; a locking piece never lands on it (spawn check keeps cells free). If a lock would cover it, the lock is vetoed once and the animal is moved to the nearest free cell (`mascot_catch` style). Fill: animals are not cells and do not count for layers. Gravity: standing on the floor or on top of cubes. Clears: when its layer clears the animal drops with the stack (it stays on the surface). Rescue: a rescue never deletes animals; it teleports them to the nearest safe cell. Top-out: an animal on the top row does not count as stack height.
- **Look.** Round, fat silhouette with a bobbing walk, a name-free pastel palette, an exclamation bubble when blocked. Sheep: cream wool, dark face. Biome skins: sheep (meadow), penguin (ice), gummy bear (candy), crab (underwater), chick (farm), rabbit (forest).
- **Audio.** Proposed `SFX_SP_SHEEP_BLEAT`, with `SFX_SP_ANIMAL_PEN_IN` for success.
- **Fits.** meadow_04 Sheep on the Run (`levels.md:165-192`), meadow_10 phase 2, meadow_h1 (lambs), ice (penguins).
- **Intro and teach.** meadow_04. The pen is outlined and a looping preview shows a sheep turning at a block. Hint: "Build a lane to the pen!"
- **Fairness.** Risk: an animal walks off the edge. Counterplay: a bounce-back with a giggle and a spent warning, the edge has a low railing visual, and the second gate closes only after 5 s of warning.
- **Engine.** NEW. 6 to 8 days (G7), gameplay-programmer plus systems-designer for the handbook entry.
- **Source.** The herding panel in `mockup_15.jpg` (sheep inside a fenced pen, gnomes round it) and the penguins in `mockup_15.jpg` and `party_modes_ref.jpg`.

**OB-28* pen and pen gate (goal)**
- **What.** The goal enclosure that safe animals walk into.
- **Rule.** A mask-marked group of cells (the pen) with one or two gate cells (BK-39). An animal that steps into a pen cell is "penned" (removed from the walkers, counted in `penned`). The goal `rescue_all` or a new `herd_all` evaluator wins at all penned. Fill: pen cells are excluded floor. Rescue: gates keep their state.
- **Look.** A wooden fence pen with a flag; the pen count shown as animal faces; a gate that swings.
- **Audio.** `SFX_SP_ANIMAL_PEN_IN` (proposal).
- **Fits.** meadow_04, meadow_10 phase 2, ice.
- **Intro and teach.** meadow_04.
- **Fairness.** The pen is always reachable by design (validator).
- **Engine.** NEW with G7. 1 day on top.
- **Source.** `mockup_15.jpg`.

**OB-29* hedge wall with holes and a peeking sheep**
- **What.** A wall that stones knock holes in. A sheep peers through each hole.
- **Rule.** Gap G12 (`levels.md:553`). Wall rows are placed at level start (cells of kind `block` with a `hedge` flag, or `starter`). A stone (OB-03) removes a few cells. Each open hole that stays open for `hole_grace_s` (6 s of wave time) lets the sheep behind it slip out; `sheep_out` counts; the level fails at `sheep_out_max` (3). A hole filled by a piece closes the peek. Fill: the wall counts as normal cells; clears shorten it. Rescue: the wall is re-built by the level, not by the rescue.
- **Look.** A leafy hedge with a round hole showing a sheep's face that blinks. The wall dims red when a hole has 2 s left.
- **Audio.** `SFX_SP_SHEEP_BLEAT`, `SFX_SP_HEDGE_BREAK`.
- **Fits.** meadow_05 Gnome Hedge (`levels.md:195-224`).
- **Intro and teach.** meadow_05.
- **Fairness.** Grace timer is data; the first hole in the level is always fixable by one piece shape in the bag.
- **Engine.** NEW. 2.5 days (G12), gameplay-programmer plus technical-artist.
- **Source.** Gnomes and sheep in `mockup_12.jpg`, `mockup_15.jpg`.

**OB-30* lamb and bridge walker**
- **What.** A lamb that walks across the path you build, and is flung by bounce pads.
- **Rule.** Gap G10 (`levels.md:551`). The lamb walks along cells one layer above the platform where each step has a supporting cube. It stops at a gap and waits. A bounce pad under the lamb flings it `bounce_h` cells along its heading; it lands on the cell the path provides or falls into water (a spent warning, `levels.md:309`). Goal: reach the picnic blanket (`span` goal). Fill: not a cell. Rescue: lamb is moved to the last solid cell it stood on. Top-out: none.
- **Look.** A lamb with a bouncy walk and squash and stretch on pads, shade leaf held by Bram.
- **Audio.** `SFX_SP_LAMB_BOING` (proposal).
- **Fits.** meadow_08 (`levels.md:290-318`), meadow_h1 (lambs on stalks).
- **Intro and teach.** meadow_08. Path preview arrow.
- **Fairness.** Landing preview arc.
- **Engine.** NEW. 3 days.
- **Source.** The runner on the bridge in `mockup_01.jpg` (Bridge Bashers) and `mockup_10.jpg` (Jungle Bridge Rush).

**OB-31* cargo (picnic basket, hamper, treasure chest)**
- **What.** The thing on the moving platform you must not lose.
- **Rule (r2, matched to `levels.md` section 8, `:613-614`).** The cargo RIDES ON THE HIGHEST BLOCK of the player's build. It is not on a marked platform cell. Each resolve, it moves to the top surface cell of the tallest column nearest the platform centre (ties: lowest x, then z). The player must build "a stable, level seat" for it. Gap G8 (`levels.md:549`).
  - **Lean and topple:** a lean meter shows the platform tipping to its heavy side; bumps and wind add to the lean (`levels.md:610-612`). Past the limit, the top blocks spill off. Building on the light side rights it.
  - **Wobble warning:** when the cargo's seat is unstable (the cargo's cell has an unsupported cube beside it, or the lean passes `warn_at`), the cargo wobbles and a sound plays one lock before it can fall, so the player has a chance to save it (`levels.md:614`).
  - **Bump and gate events:** a bump pushes the cargo one cell and shakes loose unsupported cubes. A low gate (OB-32) sweeps everything above `gate_gap` layers, cargo included, so the cargo's height is a build-height test, not a placement test.
  - **Fill:** the cargo is not a cube. It is a prop on the top cell and does not change layer fill. **Rescue:** a rescue wipes the bottom planes only, so the cargo is re-seated on the new highest block, never deleted. **Top-out:** cargo above the gate gap is swept (a defined fail path).
  - It is the `goal_object` of the level: the blocks under it carry `blast_safe` only if the level says so (3.1b).
- **Look.** A wicker basket with a checked cloth, bouncing on bumps; glows gold when safe at the end.
- **Audio.** `SFX_SP_CARGO_BUMP`, `SFX_SP_CARGO_LOST` (proposals).
- **Fits.** meadow_03 Brook Run, meadow_bonus (hamper), pirate (chest), clockwork.
- **Intro and teach.** meadow_03. The strip shows a bump icon with a basket wobble.
- **Fairness.** Bumps are in the track preview, never random.
- **Engine.** NEW. Part of the 12 to 15 day G8 work.
- **Source.** The treasure chest hanging on a crane in `mockup_03.jpg` (Tumbling Towers), the cargo and chests on ships in `mockup_08.jpg`, `mockup_13.jpg`.

**OB-32* track events (bump, low gate, updraft, crosswind, cloud bump)**
- **What.** Things on a moving track. All are known ahead on the preview strip. (r2: the "low arch" is renamed "low gate", because "arch" is already the hollow piece SH-02.)
- **Rule.** Gap G8. Each event has a position on the track and an effect on the platform when it arrives: bump (shake loose unsupported cubes, shove cargo), low gate (sweep cubes above `gate_gap` layers), updraft (lift the platform, which raises its progress rate), crosswind (slide loose blocks one cell sideways), cloud bump (small shake). All are scheduled data in the level file. Fill and clears: sweeps are not clears. Rescue: the rescue wipe resets the shake. Top-out: arch sweeps are a defined loss path.
- **Look.** Icons on the strip in a fixed shape language: round bump, rainbow arch, up-arrow wind, side-arrow wind, small cloud.
- **Audio.** `SFX_EV_TRACK_BUMP`, `SFX_EV_ARCH_SWEEP`, `SFX_EV_UPDRAFT` (proposals).
- **Fits.** meadow_03 (bump, low gate), meadow_bonus (updraft, crosswind, cloud bump; the same track package, so not a new special for the bonus, F1).
- **Intro and teach.** One event type at a time in meadow_03.
- **Fairness.** Preview 8 s ahead (knob `track_preview_s`).
- **Engine.** NEW. Part of G8 (events 3 days, preview strip 2 days).
- **Source.** The race track with arch gates and the "next hazard" slot in `mockup_03.jpg` (Rolling Rumble).

**OB-33* finish flag and goal marker**
- **What.** The thing at the end of a race or build goal.
- **Rule.** A world marker that shows the goal position: the picnic lawn, the gorge edge, the lookout top. Reaching it wins when the goal is met. A race finish is a line the platform crosses. No cell effect.
- **Look.** A checkered flag or banner, glowing gold when the goal is ready.
- **Audio.** `SFX_GOAL_WIN` jingle (exists, `sfx-cue-list.md:56`).
- **Fits.** meadow_03, bonus, any race.
- **Intro and teach.** Always visible.
- **Fairness.** Never hidden.
- **Engine.** NEW view. 1 day.
- **Source.** Checkered flags in `party_minigames_ref.jpg`, `party_versus_ref.jpg`.

**OB-34* boost pad (race floor tile)**
- **What.** A pad that speeds up your platform for a short burst when you cover it.
- **Rule.** A switch-style tile (BK-38) with effect `boost`. Covering it with a lock raises the platform speed by `boost_mult` (1.25) for `boost_locks` (3) locks. It does not stack. In a rival race, it moves your progress marker only.
- **Look.** A round blue pad with a chevron. Glows when ready.
- **Audio.** `SFX_SP_BOOST` (proposal).
- **Fits.** meadow_bonus, candy rails, neon.
- **Intro and teach.** One pad in a race.
- **Fairness.** Optional gain.
- **Engine.** NEW. 1 day after BK-38.
- **Source.** Boost pads in `mockup_03.jpg`, `mockup_13.jpg`, `mockup_14.jpg`.

**OB-35* edge attacker (gnome, gargoyle statue, cannon, tentacle, drone, golem)**
- **What.** A prop at the rim that is the visible source of an attack.
- **Rule.** It owns no new logic. It is the actor that plays the telegraph and launch for an existing attack rule: `defend_core` shots, `storm_bolt` stones, `crab_claw` claws, `quake` and `gust`. Each attacker has `warn` and `fire` poses synced to the rule's events (`defend_warning`, `claw_warning`, `magnet_warning`). The statue variant stands on the rim and spits or throws when its lane is marked. Fill: none.
- **Look.** Biome skins: gnome with stones (meadow), angry stone face (lava, the user-approved board edge statue), gargoyle (candy-free dark biomes), cannon and pirate (pirate), tentacle (underwater), drone (neon), golem (cave). Clear wind-up silhouette (0.5 s).
- **Audio.** Each rule's warn cue plus `SFX_BOSS_WINDUP_*` style.
- **Fits.** meadow_02, 05, 10; lava; underwater; pirate; cave.
- **Intro and teach.** With the first level of each attack.
- **Fairness.** The attacker's pose is the telegraph, so it must match the rule timing exactly.
- **Engine.** NEW view. 3 to 5 days per attacker set (included in G19).
- **Source.** The angry stone faces and big stone idol in `party_biome_islands_ref.jpg`, gnomes in `mockup_12.jpg`, kraken in `mockup_04.jpg`, gargoyles and catapults in `mockup_11.jpg`.

**OB-36* updraft vent (steam, geyser of air)**
- **What.** A vent that lifts the falling piece up one cell as it passes.
- **Rule.** A floor cell marked `vent` with a lane (the column above it). A falling piece that overlaps the column rises one cell once per piece, after a short puff warning (the same method as a bounce). Steam is visual. It has no effect on locked cubes.
- **Look.** A brass grate with steam puffs or a leaf swirl; a faint column glow.
- **Audio.** `SFX_EV_UPDRAFT` (shared).
- **Fits.** Clockwork, celestial, meadow kite lanes.
- **Intro and teach.** One vent, with the column highlight.
- **Fairness.** One cell, telegraphed.
- **Engine.** NEW. 1 day.
- **Source.** Steam vents in `mockup_10.jpg`, `mockup_08.jpg`.

**OB-37* stump cage (grip release) and the Hearth Stump**
- **What.** The meadow_01 platform feature: a stump choked by roots and stones that lets go one grip per full layer.
- **Rule.** Gap G1 (`levels.md:542`). Masked-off columns (`static_geometry`) around a 4x4 pit are switched back on by `request_mask(x, z, true)` on all layers at each layer clear: the pit grows 4x4, 6x4, 8x4 (`levels.md:74-75`). Three grips; the third reveals the stump and wins. A rescue never releases a grip. Fill: masked cells are excluded, so layer counts rebuild at each release. Top-out: masked columns add no stack height.
- **Look.** Roots on the left, stones on the right, three bark knots as the Stump Grip meter; the stump shakes and a root snaps on each release.
- **Audio.** Proposed `SFX_EV_GRIP_RELEASE`, `SFX_EV_STUMP_FREE`.
- **Fits.** meadow_01 only.
- **Intro and teach.** It is the teach: finish a layer, the wall moves.
- **Fairness.** Layer counts and speed step per release are data (`levels.md:87`).
- **Engine.** NEW. 5 to 6 days (G1), lead-programmer (core), gameplay-programmer (rule), systems-designer (spec).
- **Source.** Own level frame; root and stone cage style from `style/01_story_flow.jpg` (tutorial island).

**OB-38* rolling boulder**
- **What.** A boulder that rolls down a marked lane and knocks the tops off the columns it crosses.
- **Rule.** Every `boulder_every_locks` (10) locks a lane (a row of the footprint) is marked with a dust trail 2 s ahead. The boulder then removes the top cube of up to `boulder_max_cols` (3) columns in that lane. A layer clear that includes the lane's top cube before impact cancels it. Fill and clears: removed cubes do not count as clears. Rescue: none. Top-out: it lowers height, so it also relieves pressure.
- **Look.** A big grey stone with carved swirl, rolling with dust and rumble, a dotted lane preview.
- **Audio.** `SFX_EV_BOULDER_WARN`, `SFX_EV_BOULDER_ROLL` (proposals).
- **Fits.** Cave, dune bazaar, jungle-themed celebrate levels. Not in the Meadow.
- **Intro and teach.** Cave 04.
- **Fairness.** Cancel by clear, 2 s warning, 3-column cap.
- **Engine.** NEW. 2.5 days.
- **Source.** Rolling boulders in `mockup_06.jpg` (Temple Roller Run), `mockup_08.jpg` (Pyramid Climber), `mockup_10.jpg`, `mockup_14.jpg`.

**OB-39* sleeping guard**
- **What.** A big sleepy guard whose sleep meter drops when you do not clear.
- **Rule.** A guard prop at the rim with a `sleep` meter 100 percent. Each lock without a clear lowers it by `sleep_drain` (8); each clear raises it by `sleep_gain` (20). At 0 it wakes, stomps once (removes the top cube of its marked column), then falls back to sleep at `sleep_reset` (50). A guard never wakes during warmup (`sleep_grace_locks`, 4).
- **Look.** A stone golem with closed eyes and "zzz"; eyes glow when low; a meter above its head.
- **Audio.** `SFX_EV_GUARD_SNORE` (quiet loop), `SFX_EV_GUARD_STOMP`.
- **Fits.** Cave, clockwork, pirate. It rewards clearing, so it is a negative-feedback loop for passive play.
- **Intro and teach.** Cave 03.
- **Fairness.** The meter is always visible.
- **Engine.** NEW. 2 days.
- **Source.** The sleeping stone guard and "Guard Sleep" meter in `mockup_02.jpg` (Maze Heist).

**OB-40* laser sweep (drone or gate)**
- **What.** A beam sweeps one lane of the board and cuts the top cube of each column it crosses.
- **Rule.** NEW. Every `laser_every_ms` (default 9000) a lane is lit as a thin dotted line for `warn_ms` (1500, the actor tell is a drone turning to face the lane), then the beam crosses and removes the top cube of up to `laser_max_cols` (3) columns of that lane with cause DAMAGE (3.1b: `fixed` cells survive, `blast_safe` objects survive). A clear in the lane's top layer before the beam arrives cancels it (same idea as `crab_claw.gd:16-21`). Millisecond schedule, hidden clock (Appendix E), F3b applies.
- **Look.** Cyan-white beam, hazard-orange dotted lane while warning, a drone or lens prop at the rim. Badge: a beam and lens (3.6).
- **Audio.** `SFX_EV_LASER_WARN`, `SFX_EV_LASER_CUT` (AUDIO-NEW).
- **Fits.** neon (signature, 3.4), celestial.
- **Intro and teach.** neon slot 03 (3.4). The lit lane is the teacher.
- **Fairness.** 1500 ms warning, cap of 3 columns, cancel by clear.
- **Engine.** NEW. 2 days, gameplay-programmer plus technical-artist. Closes catalogue gap 9 (laser sweep, `reference-minigames-catalog.md:352`, M40).
- **Source.** Drones lasering a cube wall in the neon hack scene (M40, `mockup_10.jpg`).

**OB-41* swinging ball (wrecking ball, spike ball, log)**
- **What.** A heavy ball on a chain that swings over one row of the board.
- **Rule.** NEW. Every `swing_every_ms` (default 8000) the ball swings across a marked row. The arc is visible for `warn_ms` (2000) as the chain winds up. It removes cells in that row on layer `swing_layer` (the row's top exposed cubes, up to 3) with cause DISPLACED (so `hung` and `fixed` cells resist it, 3.1b). A clear of that layer's row before the swing cancels it.
- **Look.** A big spiked ball or striped carnival ball on a chain from a post. Badge: a ball on a chain.
- **Audio.** `SFX_EV_SWING_WARN`, `SFX_EV_SWING_HIT` (AUDIO-NEW).
- **Fits.** carnival (wrecking-ball booth), lava (spiked ball over a platform), pirate (cargo hook).
- **Intro and teach.** carnival slot 04 (3.4).
- **Fairness.** 2000 ms warning, visible arc, cancel by clear, `hung` pieces resist it (this is a second stake for hooks and jacks).
- **Engine.** NEW. 2.5 days.
- **Source.** Swinging spiked balls on the lava run (M53, `mockup_13.jpg`); swinging log trap (M19, `mockup_05.jpg`).

**OB-42* gravity well (radial pull)**
- **What.** A swirling well that tugs the falling piece toward its centre.
- **Rule.** NEW, built on `magnet_pull`. A marked floor cell with radius `well_radius` (3). While a falling piece is inside the radius, every `well_pull_ms` (900) it moves one cell toward the well centre, with a pull-arrow telegraph (the ghost shows the arrow) 600 ms before the first pull (`magnet_pull.gd:21-25` already warns 600 ms). Blocked pulls are skipped (`:29-30`). The well cell itself is a floor hole (BK-37): a piece that ends wholly over it falls out of play. A `braced` claw piece cancels the first pull (SH-06).
- **Look.** A violet spiral disc with falling sparks and arrow trails. Badge: a spiral.
- **Audio.** `SFX_SP_WELL_HUM` (loop in range), `SFX_SP_WELL_PULL` (AUDIO-NEW).
- **Fits.** celestial (signature, 3.4), neon.
- **Intro and teach.** celestial slot 03 (3.4).
- **Fairness.** One cell per 900 ms, arrow shown, a hard drop before the first pull is a counter.
- **Engine.** NEW. 2 days. Closes catalogue gap 8 (radial pull, `reference-minigames-catalog.md:351`, M27, M33, M46).
- **Source.** The black hole in the wormhole board (M27, `mockup_07.jpg`).

**OB-43* claimed tile (paint tile, territory)**
- **What.** Floor tiles take the colour of the last piece that locked on them.
- **Rule.** NEW. A tile is `owned` by the player or colour of the last lock that covered it. Cleared cubes leave the tile owned. A goal `tiles_owned` (new evaluator) wins when a player owns the most tiles at the end condition. In versus, the overlay is the player's colour. Not a hazard, no clock.
- **Look.** A coloured glow on the floor tile plus a small flag icon. Badge: a flag tile.
- **Audio.** `SFX_SP_TILE_CLAIM` (AUDIO-NEW).
- **Fits.** neon (paint splat), tournament rounds (Island Claim), carnival.
- **Intro and teach.** neon slot 06 (3.4), or the first territory round.
- **Fairness.** Plain scoring, shown by a tug bar.
- **Engine.** NEW. 3 days (goal evaluator plus floor overlay). Closes the territory and paint-tile entries (M60, M86; the footprint goal M94 is a close cousin).
- **Source.** Paint-gun hex arena (M60, `mockup_14.jpg`) and claimed tile floor (M86, `party_versus_ref.jpg`).

**Recorded rejections and mappings** (so nothing from the reference gap list is lost, `reference-minigames-catalog.md:340-356`):
- **Connector or pipe path (gap 7, M20, M52, M74):** a goal type, not a special. Out of this doc. Owner: goals handbook. Reason: it changes how the level is won, not how a block behaves. The pipe pieces are skins of existing shapes.
- **Plank and crate pieces:** skins of the `plank` and `slab` shapes (3.6 skin rule). No rule.
- **Avatar on the board (gap 1), ball sport (gap 4), bumper physics (gap 3), rail laying (gap 6), projectile siege (gap 2):** out of scope for a block-stacking game with one extra verb at most (`minigame-party-rules.md` rule 3). The cannon, catapult and gnome are attacker props (OB-35), not player verbs.
- **Floor spikes:** the spiked shell BK-23f.
- **Whirlpool:** OB-42 (gravity well) with a water skin.
- **Mine cart and rails:** a track event on a moving platform (OB-32), not a separate object.

#### 3.2.d Power-ups and items the player triggers

Two systems exist. **Items** (`items.md`, `src/mechanics/behaviour/items.gd`): earned by clearing the layer that holds an item cube, held in 2 slots (1 to 3), one tap to use. In the campaign, debuffs are removed from the table (`items.md` rule 11, `items.gd:60-65` `solo`). **Skills** (`skills.md`, `src/game/abilities/wt_abilities.gd`): one per character, a charge meter in the campaign. Both are bundles of framework rules at layer `item_buff`: they never beat a level's own mechanic. Numbers are from `assets/data/items/starter.json` and `assets/data/meta/abilities_runtime.json`.

Item cube (the carrier): `p_item` 0.12 per spawned non-injected piece, clamped to 0.5 max, one random cube of the piece (`items.gd:53-58,115`); collected only by a genuine clear, lost on bomb, rescue or displaced removal. Look: a gold "?" bubble sticker on one cube, bobbing. Teach: first collection in a level that turns items on shows the item flying to the slot.

**IT-01 Slow Time (buff)**
- **What.** The pieces fall at half speed for a while.
- **Rule.** Self, 10 s, `gravity_scale x 0.5`. Weight 10, bias 0. Refreshes, never stacks. Loses to Sticky Landing's set (no-effect pop, refunded once). Interacts with the speed ramp: it multiplies it, so it cannot reduce the ramp below `0.3` of base (knob range 0.3 to 0.8). No effect on clears. Rescue: pauses during warnings.
- **Look.** Cyan chevron badge with a duration ring; clock icon; falling piece leaves a slow-motion trail.
- **Audio.** `buff_on`, `effect_end` (buff and debuff cues in `buffs-debuffs.md`); proposed `SFX_SP_ITEM_SLOW`.
- **Fits.** All biomes; clockwork (a gear-clock icon).
- **Intro and teach.** First item in the campaign: Slow Time (weight and standing make it the safest).
- **Fairness.** Pure help.
- **Engine.** EXISTS (`items.gd`, `starter.json`).
- **Source.** The stopwatch icon in `mockup_03.jpg`, `party_versus_ref.jpg` (Speed Boost clock).

**IT-02 Bomb (buff)**
- **What.** Your next piece blows up a 3x3x3 area when it locks.
- **Rule.** Self, next piece. The piece gets a `bomb` tag; on lock every cube in `(2r+1)^3` (r = `bomb_radius` 1, so 27 cells) around the piece's centre cube is removed, including its own; rocks take 2 damage; pillars are immune; not counted as layer clears (`buffs-debuffs.md` rule 6, F2). Weight 8, bias +0.5. The blast runs at `on_lock`, after the cubes are written and before the clear check. Gravity: slice mode leaves holes; cascade mode settles. Other specials: critters and keys must be `anchored` to survive; locked cubes unlock only by clears, not by blast; frosting is removed; the gem is lost.
- **Look.** Fuse sticker on the piece's top, spark trail; cartoon puff with confetti on blast.
- **Audio.** `bomb_blast` (from `buffs-debuffs.md`); `SFX_SP_BOMB_BLAST` proposal.
- **Fits.** Any biome; reskinned as a powder keg, firework, ice bomb.
- **Intro and teach.** Second item. Hint: "Your next piece goes boom."
- **Fairness.** Preview outline of the blast box on the ghost (proposed, 1 day).
- **Engine.** EXISTS (`items.gd`). Blast preview NEW.
- **Source.** The big bomb in `mockup_16.jpg` (Bomb Defuse), `mockup_19.jpg`.

**IT-03 Helper Drop (buff)**
- **What.** Three small helper pieces go to the front of your queue.
- **Rule.** Self, instant. `helper_drop_count` 3 of mono, duo, tri_straight, tri_corner, chosen by the effect's own stream, injected outside the bag. Weight 10, bias 0. Pieces injected never carry item cubes.
- **Look.** Three small pieces pop into the NEXT strip with a mint sparkle.
- **Audio.** `buff_on`.
- **Fits.** All.
- **Intro and teach.** Early.
- **Fairness.** Pure help.
- **Engine.** EXISTS.
- **Source.** None.

**IT-04 Preview Peek (buff)**
- **What.** Shows two more next pieces and turns on hold for a while.
- **Rule.** Self, 20 s. `preview_count + 2` (max 3), `hold_enabled` true. A held piece returns to the queue front at the next spawn when it ends. Weight 10, bias -0.5.
- **Look.** The NEXT plate extends with a sparkle and a hand icon.
- **Audio.** `buff_on`.
- **Fits.** All; best in race and fog levels.
- **Intro and teach.** Early.
- **Fairness.** Pure help.
- **Engine.** EXISTS.
- **Source.** The "Next Block" stacks in `mockup_33.jpg`, `mockup_35.jpg`.

**IT-05 Junk Rain, IT-06 Fog, IT-07 Speed Up, IT-08 Spin Lock (debuffs)**
- **What.** Four attacks on the leader: a grey junk layer pushed under their stack, mist over their blocks, faster fall, no tilt or roll.
- **Rule.** Opponent only. Junk Rain instant (`junk_rain_layers` 1, one random gap), Fog 10 s (`visible_ms` 1 000), Speed Up 15 s (`gravity_scale x 1.5`), Spin Lock 10 s (vetoes tilt and roll). Weights 8, 6, 8, 6; biases +1.0, +0.5, +1.0, +0.5 so trailing players draw more attacks (F2 in `items.md`). Never in the solo campaign (`solo` zeroes debuff weights, `items.gd:62-64`). Gravity and clears are normal. Other specials: Fog stacks with `fog` as a twist (twist wins); Spin Lock has no effect on spin-only levels (no-effect pop).
- **Look.** Magenta chevron on the target HUD and a magenta streak from attacker to target board edge; the board edge glows magenta, never the cubes.
- **Audio.** `debuff_on`, `junk_rise`.
- **Fits.** Versus, tournament, arcade.
- **Intro and teach.** Versus tutorial.
- **Fairness.** Targets the leader, never a player who is out.
- **Engine.** EXISTS. Netplay: host fixes the target at send time (README line 63).
- **Source.** Party versus boards (`party_modes_ref.jpg`, `party_versus_ref.jpg`).

**IT-09 Calm Skies (skill, C1 cloud wizard, tempo)**
- **What.** Time slows way down for 8 s.
- **Rule.** Self 8 s: `gravity x 0.25` (`calm_gravity_milli` 250) and lock delay x 1.5 (`calm_lock_milli` 1500, `abilities_runtime.json`). Versus rider: Speed Up for 8 s. Charge: `q` per resolve = `(0.125 n + 0.03 max(0,k-1)) x m_rate x m_rank` (`skills.md` F1); campaign default `charge`, 1 to 2 uses per level.
- **Look.** A soft blue haze and clock hands slowing; cloud icon button.
- **Audio.** Proposed `SFX_SP_SKILL_CALM`.
- **Fits.** Campaign, arcade.
- **Intro and teach.** Level 1 charge meter introduces it.
- **Fairness.** Star times assume no skills (`skills.md` overview).
- **Engine.** EXISTS (`wt_abilities.gd`).
- **Source.** None.

**IT-10 Stitch (skill, C2 Lana, protect)**
- **What.** Your stack is pinned for 10 s. Nothing can move or remove locked cubes.
- **Rule.** Self 10 s. Vetoes `stack.shift` and `stack.remove` at rank 3: beats twists and content (rank 2), loses to level mechanics (rank 4). Queued structure changes wait until it ends (`skills.md` rules 14). Never blocks clears, locks, or top-out.
- **Look.** Yarn stitches across the stack edge, a knitting-needle badge.
- **Audio.** Proposed `SFX_SP_SKILL_STITCH`.
- **Fits.** Quake, goo, pest, woodpecker levels (anything that moves or removes cubes).
- **Intro and teach.** Hidden if the level has no `stack`-tagged rule (`skills.md` rule 14).
- **Fairness.** A "rule_blocked" event shows each blocked write.
- **Engine.** EXISTS.
- **Source.** None.

**IT-11 Smash (skill, C3 Boulder, remove)**
- **What.** One big hit that removes a 3x3 chunk under your falling piece.
- **Rule.** `smash_size` 3, `smash_depth` 3 (up to 27 cubes). Not a layer clear: no score, no combo, no charge, no clear-count progress. Rocks take 1 damage; pillars and masked cells are immune. Empty chunk: no effect, not spent (`skills.md` F4).
- **Look.** An outline of the chunk follows the ghost; big fist and dust on use.
- **Audio.** Proposed `SFX_SP_SKILL_SMASH`.
- **Fits.** Any.
- **Intro and teach.** After the first charge.
- **Fairness.** Aim by moving the piece; no hidden target.
- **Engine.** EXISTS.
- **Source.** The hammer and wall-breaking golem in `mockup_13.jpg`, `mockup_32.jpg`.

**IT-12 Redraw (skill, C4 Glim, plan)**
- **What.** Re-rolls the next three pieces and marks the best landing spots.
- **Rule.** `redraw_pieces` 3; up to `fit_marks` 2 perfect-fit spots per piece (`skills.md` F5; pure search in `src/game/abilities/perfect_fit.gd`). Injected pieces are not redrawn. Stays active until the last redrawn piece locks.
- **Look.** Gold outline marks on the board; a bat-wing badge.
- **Audio.** Proposed `SFX_SP_SKILL_REDRAW`.
- **Fits.** Any.
- **Intro and teach.** First character pick.
- **Fairness.** Help only.
- **Engine.** EXISTS.
- **Source.** The "Next Block" and hint mechanics (`mascot_hint`, README line 49).

**IT-13* Hammer (item)**
- **What.** Tap one cube and smash it.
- **Rule.** Self, instant. The player taps a cell (the engine already has a `pick_cell` command, `fog_ghost.gd:20`). Removes that one cube as damage; rock takes 1; anchored, `fixed`, `clear_protected` or critter cells are immune. Not a clear. Weight 8, bias +0.5. Campaign-safe buff.
- **Look.** A big wooden mallet icon; target ring on the tapped cube.
- **Audio.** Proposed `SFX_SP_ITEM_HAMMER`.
- **Fits.** All. Good in repair and fog levels.
- **Intro and teach.** After Bomb.
- **Fairness.** Cannot remove goal objects.
- **Engine.** NEW. 1.5 days.
- **Source.** The hammer weapon in `mockup_13.jpg` (Boss Bash).

**IT-14* Shield Bubble (item)**
- **What.** Blocks the next hit from an attack.
- **Rule.** Self, up to 20 s or one hit. The next `defend_core` hit, `storm_bolt`, `crab_claw`, `quake`, `woodpecker_knock`, `squirrel_heist`, boulder or countdown blast is cancelled. Does not stop terrain (lava floor). Weight 8, bias +0.5.
- **Look.** A cyan soap-bubble over the platform with a shine; pops with a ring.
- **Audio.** Proposed `SFX_SP_ITEM_SHIELD`.
- **Fits (r2, Appendix E: items from Chapter 2).** Defender levels from biome 5 on (pirate: cannon and tentacle hazards), unlock level in the item table in 3.4. Not in any Meadow level.
- **Intro and teach.** Defender tier.
- **Fairness.** Never required.
- **Engine.** NEW. 2 days (a hook on each attack's apply step).
- **Source.** The shield in `mockup_15.jpg` (Cyber Defender).

**IT-15* Rewind (item)**
- **What.** Undo your last lock.
- **Rule.** Self, instant. Restores the board state before the last lock and returns the piece to the queue front (turn snapshots exist, `undo_reset.gd`). Only if no clear occurred in that resolve (otherwise "no effect"). Limit 1 per level. Weight 6, bias -0.5.
- **Look.** A rewind-arrow icon; a blue time-ripple.
- **Audio.** Proposed `SFX_SP_ITEM_REWIND`.
- **Fits (r2).** Puzzle and fill levels from Chapter 2 on (cave and clockwork, item table in 3.4). Not in meadow_06 or any Meadow level.
- **Intro and teach.** Fill levels.
- **Fairness.** Replays stay deterministic because the snapshot is the state.
- **Engine.** PARTIAL. `UndoResetRule` activates snapshots for authored puzzles (`undo_reset.gd:2`). A live-play item is NEW, 2 days.
- **Source.** None.

**IT-16* Grip (item)**
- **What.** Your next piece lands without sliding, bouncing or being pushed.
- **Rule.** Self, next piece. Cancels the next gust push, bounce hop, ice slide, magnet pull and jelly hop for that piece, and locks with delay 0 after rest (honey-like). Weight 8, bias 0.
- **Look.** A gold glue-drip badge on the piece, with a sticky shine.
- **Audio.** Proposed `SFX_SP_ITEM_GRIP`.
- **Fits (r2).** Levels with belts, ice, current, gust or bounce from Chapter 2 on (clockwork first, item table in 3.4). Not in meadow_08 or meadow_09. It uses the landing arbiter R-2 (the `braced` flag, SH-06).
- **Intro and teach.** In the bounce level.
- **Fairness.** Pure help.
- **Engine.** NEW. 1.5 days.
- **Source.** The honey shell in the status GDD.

Considered and not proposed: Water Cannon, Boxing Glove, Boots and Gravity Flip (seen on `mockup_13.jpg`, `mockup_14.jpg`) need a second verb or a rival to hit, so they stay out of the campaign (party rule 3: at most one extra verb). They can be versus-only later.

#### 3.2.e Catalogue gaps still open at this point

The following items from the references are not yet written up because they duplicate an item above or need a user ruling: plank pieces (a skin of the plank shape, `shape_bank.tres:607`), pipe-connector pieces (a connection goal that is new and needs a game-designer ruling), rune and mud floor tiles (skins of switch plate and honey). See Open Questions.

### 3.3 Interaction matrix

**How to read it.** The row is the special that ACTS. The column is the thing it MEETS. The cell says what happens. Codes: `-` nothing happens; `W` the row wins and the column is overridden; `L` the row loses, the column wins; `O` both act, in the order given by the Order rules below; `X(n)` an explicit rule R-n below. "Plain" means a normal block. Only specials that can actually meet are listed. Specials not in the grid (shells, status effects, items) follow the notes under the grid.

Columns, left to right: **PLN** plain block, **BNC** bounce pad or jelly hop, **GOO** goo or honey (sticky), **ICE** ice cube or ice slide, **BMB** any bomb blast, **GHO** ghost piece, **MAG** magnet pull, **WND** wind or gust, **ANC** anchored or fixed (rock, shelf, pillar, licorice, hung cube, climber), **CRT** critter (egg, chick, mole, lamb, herd animal, gem, key).

| ACTS \ MEETS | PLN | BNC | GOO | ICE | BMB | GHO | MAG | WND | ANC | CRT |
|---|---|---|---|---|---|---|---|---|---|---|
| **BNC** (hop) | X(1) lands, hops once | - | L sticky wins, no hop | O one displacement only, X(2) | - | - | O pulled before landing | O gust before landing | W (a hop never moves an anchored cube) | X(3) |
| **GOO** (spread, sticky) | X(4) spreads into free cells only | W cancels the hop | - | W cancels the slide | L goo cell is removed | - | - | - | L goo never spreads into anchored cells | X(5) |
| **ICE** (slide) | X(6) slides one cell | O one displacement only, X(2) | L sticky wins | - | - | - | - | O gust first | W stops at anchored | X(3) |
| **BMB** (blast, 3x3x3) | W removes | - | W removes | W removes | X(7) no chain by blast | W ghost cells are not solid until solid | - | - | L anchored survives (`earned_specials.gd:18`) | X(8) |
| **GHO** (ghost, intangible) | - passes through | - | - | - | - | - | L ignores pull | O wind still pushes it | - passes through | - passes through |
| **MAG** (pull, one cell) | O pulls the falling piece | O pull before bounce | - | - | - | L ignored | - | O wind first, then pull | L pulled piece stops at anchored | - |
| **WND** (gust, one cell) | O pushes the falling piece | O gust then bounce | - | O gust then slide | - | O still acts | O see MAG | - | L stops at anchored | - |
| **ANC** (fixed) | W never moves | W | W | W | W (blast-proof) | W | L | L | - | X(9) |
| **CRT** (critter) | X(10) pest only eats PLN | - | X(5) | - | X(8) | - | - | - | - | - |

**Order rules (O).** Within one lock, the order is fixed, so replays are deterministic.
1. **Flight order.** Gust push, then magnet pull, then landing detection. Both are one cell and both are skipped if blocked (`magnet_pull.gd:30`, README line 28).
2. **Landing order.** On landing, at most ONE displacement fires, chosen by priority bounce hop, then jelly hop, then ice slide. This is a NEW rule (R-2). The engine today lets `bounce_pad`, `jelly_piece` and `ice_slide` each fire once per piece and they would stack to 4 cells of travel. R-2 caps total landing travel at `bounce_h + 1` cells (5 at most).
3. **Sticky beats motion.** A sticky landing (honey, `sticky_landing`, goo under the piece) cancels every displacement above, and the piece locks at once.
4. **Lock to clear.** After the lock: item `bomb` blast (before the clear check, `buffs-debuffs.md` rule 6), then clear detection, then clear hooks (frosting peel, licorice untie, locked cube unlock, pest shoo, countdown defuse, candy bomb blast, egg bonus, gem collect), then collapse, then `on_resolve_end` hooks in plugin order (sprouts, eggs, goo spread, mushroom or hail or geyser spawn, countdown tick, wobble, tilt, belt). The README states that content writes flush at hook boundaries and that a write after the first clear pass may cause ONE more clear pass and the resolve hook does not recurse (README lines 55 to 57).

**Explicit rules.**
- **R-1 Bounce on plain.** The pad fires when any piece cube sits directly on it (`bounce_pad.gd:26-30`). Rise is `rise = min(bounce_h, free cells above)` then one cell in the last move direction.
- **R-2 One displacement.** Only the first of bounce, jelly, ice acts per piece. NEW, 0.5 day, gameplay-programmer.
- **R-3 Bounce or slide meets a critter.** Critters are not cells that pieces can overlap. A displacement that would put a piece cube on a critter cell is blocked, as any blocked step is (`try_translate` returns blocked).
- **R-4 Goo spreads into free cells only.** It never replaces a cube. A goo cell in a full layer clears with the layer like any cell.
- **R-5 Goo meets a critter.** Goo does not spread onto a critter. A critter next to goo is not stuck. There is no sticky-critter rule, to keep the read simple.
- **R-6 Ice slide on plain.** The slide direction is the last move (`ice_slide.gd` uses a fixed `slide_dir`; the ice CUBE variant BK-35 uses last move and is NEW).
- **R-7 Blasts do not chain.** Blast removal uses `Cause.DAMAGE`. Clear hooks run on clears, so a blast removing another bomb does not detonate it. If the blast completes a layer, that layer clears in the one allowed extra clear pass and any bomb cleared there then detonates (once). `ART-CHECK` that `remove_cell(..., DAMAGE)` does not fire `on_clear`. This bounds every chain to 2 blasts per lock. Knob `bomb_chain_passes` (default 1).
- **R-8 Blast meets a critter or gem or key.** Protected objects carry `anchored` while a goal needs them (`gem_safe`, `critter_safe` flags set by the level). Unprotected ones are removed and a gem is lost. A mole removed this way is NOT rescued (`dig_rescue_goal.gd:2`).
- **R-9 Fixed meets critter.** A critter never walks into an anchored cell. A critter on a cell that becomes anchored (a hung cube dropping beside it) is unaffected.
- **R-10 Pest meets non-plain.** A pest eats only `block` and `starter` kinds (`pest.gd:49`). It never eats a special, a critter, a gem, a key cube or an anchored cell.

**Notes for specials not in the grid.**
- **Frosting, locked cube, licorice, sponge:** these react to adjacent clears, not to piece-flight. A blast removes frosting at once (it is not anchored) and removes locked cubes at once. `ART-CHECK` whether blast damage respects `clear_protected`. Design intent proposed: blast damage peels 1 coat from frosting and removes everything else except `anchored`.
- **Status shells (7):** a cube holds one at a time (`block-status-effects.md` rule 1). A new status replaces the old one unless the old one's rule ranks higher.
- **Fog:** hides visuals only. Collision is unchanged, so every row above is the same with fog on.
- **Sprout:** grows into a free cell above its tip. It never pushes a piece. Blasts remove sprout cells. Pests do not eat them (a pest eats `block` and `starter` only, `pest.gd:49`).
- **Wobble and tilt:** both ignore anchored and fixed kinds (`tilt_plate.gd:26` excludes `fixed_kinds`, default rock). Heavy pieces count double (SH-10, F7).
- **Belt, turntable, piston, flip:** move cells and keep identity and status through the move (README). Specials ride with them. Anchored cells are not allowed with a belt that would move them (validator, `obstacles.md` rule 10).
- **Items and skills:** Smash and bomb never remove `fixed` or `static_geometry` cells. Stitch vetoes `stack.shift` and `stack.remove` but is beaten by level mechanics (`skills.md` rule 14).

**Banned combinations (validator rejects the level).**
| Combination | Reason |
|---|---|
| goo + countdown bomb + pest in one level | three pressure sources with no cap |
| ice cube + bounce pad + wind in one level | three displacement sources, unreadable landing |
| fog + ghost piece + fog item with no landing marker | a landing the player can never see |
| more than 2 timed hazards (E less than 5 locks) at once | pressure ratio check F3 |
| any hazard that can only be answered by a special the level does not spawn | unfair by construction |

## 4. Formulas

All values are starting defaults. Each knob lives in a data file (section 7). Table headers use: Symbol, Type, Range, Description.

### F1. Active specials cap per level

`A_max(n) = min(A_cap, 1 + floor((n - 1) / 3))`, and `new_specials(n) <= 1`

| Symbol | Type | Range | Description |
|---|---|---|---|
| n | int | 1 to 13 | Level index in its biome (01 to 10 = 1 to 10, bonus = 11, h1 = 12, h2 = 13; h3 = 14 uses the same cap as h2) |
| A_cap | int | 1 to 4 | Most special kinds or objects active at once; default 3 |
| A_max | int | 1 to A_cap | Allowed active specials in level n (the level's own goal rule counts as one) |
| new_specials | int | 0 to 1 | Specials that appear for the first time in this level |

**Output range.** 1 to 3. n = 1 to 3 gives 1, n = 4 to 6 gives 2, n = 7 to 14 gives 3. Boss levels (n = 10) recall earlier specials in phases and count each phase on its own. **Why.** `levels.md:453` states "no two levels share verb, mechanic and goal", and its Mechanics ladder shows exactly one new thing per level. **Example.** meadow_05 (n = 5): at most 2 active. Its stone throw plus its hedge wall is 2. Correct. meadow_09 (n = 9): at most 3. Tilt plate plus wind plus heavy shapes is 3. Correct.

### F2. Timed hazard interval by level and biome

`E(b, n) = clamp( round(E0 - d_lvl * (n - 1) - d_bio * (b - 1)), E_min, E0 )`, hazard spawns every `E` locks.

| Symbol | Type | Range | Description |
|---|---|---|---|
| b | int | 1 to 12 | Biome index in chapter order (meadow 1 ... carnival 12) |
| n | int | 1 to 14 | Level index as F1 |
| E0 | int | 4 to 10 | Interval in locks at the first level of the first biome; default 6 |
| d_lvl | float | 0 to 0.8 | Locks removed per level step; default 0.4 |
| d_bio | float | 0 to 0.5 | Locks removed per biome step; default 0.25 |
| E_min | int | 2 to 5 | Hard floor; default 3 |
| E | int | E_min to E0 | Locks between spawns (used as `spawn_every_locks`, `ant_every_locks`, `every_locks`, `thrown_every_locks`) |

**Output range.** 3 to 6 at defaults. The warning always comes one lock before the spawn, so E of 3 still leaves 2 free locks (`mushroom_popup.gd:26`: spawn happens when `locks % every == every - 1` marks, `== 0` fires; the engine clamps E to at least 2). **Example.** Biome 1 (meadow), level 5: 6 - 0.4 x 4 - 0 = 4.4, so E = 4. Biome 5 (lava), level 5: 6 - 1.6 - 1.0 = 3.4, so E = 3. Biome 12, level 10: 6 - 3.6 - 2.75 = -0.35, clamped to 3. **Note.** `countdown_bomb` already ships `thrown_every_locks` 8 and `cd_start` 8 (`countdown_bomb.gd:22,25`). Those are calm starter values and stay as the Candy defaults. F2 applies to hazards without a stated default.

### F3. Cap-reach fairness check

`T_cap = objects_max * E`, and the level passes only if `T_cap >= k_fair * P_eff`.

| Symbol | Type | Range | Description |
|---|---|---|---|
| objects_max | int | 1 to 8 | Cap on live hazard objects (mushroom default 4, hail 6, geyser 3) |
| E | int | 2 to 10 | Locks between spawns (F2) |
| P_eff | float | 6 to 24 | Pieces to fill one layer for the level's piece set and footprint (`piece-set.md` table; 12 on 6x6 with the 8 standard shapes, about 9.7 with specials) |
| k_fair | float | 1 to 2 | Layers of work the player must get before the board can fill with hazards; default 1.5 |
| T_cap | int | 2 to 80 | Locks needed to reach the cap |

**Output range.** `T_cap` 2 to 80. The check is a validator rule. **Example.** Mushrooms: 4 x 5 = 20 locks. P_eff 12 gives 1.5 x 12 = 18. 20 >= 18 passes. With E = 3 and the same cap of 4: 12 < 18 fails. The level must raise `objects_max` to 6 (6 x 3 = 18, passes) or raise P_eff. Raising the cap here means more hazards may sit on the board, which is fair only because they arrive slowly enough to answer.

### F4. Bounce travel

`D_b = rise + 1`, `rise = min(bounce_h, free_up)`, `bounce_h(n) = clamp(2 + floor((n - 1) / 4), 1, 4)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| bounce_h | int | 1 to 4 | Pad rise strength (engine clamps 1 to 4, `bounce_pad.gd:34`) |
| free_up | int | 0 to 4 | Free cells above the piece before a block or ceiling |
| rise | int | 0 to 4 | Cells actually lifted |
| D_b | int | 1 to 5 | Total cells moved: rise plus one sideways. The sideways step is also blocked when the cell is taken, so D_b can be rise only |
| n | int | 1 to 14 | Level index |

**Output range.** 1 to 5 cells; the lamb flung by a pad uses the same `bounce_h` as its flight length. Never negative. **Why.** `levels.md:311`: meadow_08 gets "stronger bounces" as it goes. **Example.** meadow_08 is n = 8: 2 + floor(7/4) = 3, so a pad lifts a piece 3 cells and moves it 1 sideways (4 cells of travel). The first pad of the level is set to `bounce_h` 2 for teaching (level data override).

### F5. Goo expected growth

`G(k) = min(G_max, G0 + (1 - c) * g * k)`, where `c` is the chance a lock includes a clear.

| Symbol | Type | Range | Description |
|---|---|---|---|
| G0 | int | 1 to 6 | Goo cells at level start |
| g | int | 1 to 2 | `per_lock`, new goo cells per quiet lock (default 1) |
| c | float | 0 to 0.5 | Clear chance per lock. About 1 / P_eff for steady play: 0.083 at P_eff = 12 |
| k | int | 0 to 100 | Locks played |
| G_max | int | 4 to 20 | NEW cap `goo_max` (the engine has none today); default 12 |
| G | float | G0 to G_max | Expected goo count |

**Output range.** G0 to G_max. **Example.** G0 = 2, g = 1, c = 0.083: after 40 locks, 2 + 0.917 x 40 = 38.7, capped at 12. Without the cap the goo fills the board in about 2.5 layers of play. This is why the cap is a required knob. A player who clears twice as often (c = 0.167) still sees 2 + 0.833 x 40 = 35, capped at 12. The cap, not the cancel, is what bounds goo. Clear cancel is a bonus.

### F6. Countdown defuse chance and frosting peel time

`p_def = 1 - (1 - c_adj)^cd_start`, and `L_peel = coats / c_adj`

| Symbol | Type | Range | Description |
|---|---|---|---|
| cd_start | int | 3 to 12 | Locks on the bomb (default 8) |
| c_adj | float | 0.02 to 0.2 | Chance a lock produces a clear on or touching the object. At most `c`, and about half of it for a random cell: 0.042 at c = 0.083 |
| p_def | float | 0 to 1 | Chance of a natural defuse with no aiming |
| coats | int | 1 to 3 | Frosting coats (2 or 3, `frosting.gd:10`) |
| L_peel | float | 5 to 150 | Expected locks to peel with no aiming |

**Output range.** p_def 0 to 1; L_peel unbounded as c_adj goes to 0 (a hazard that can never clear is banned by the validator: c_adj must be at least 0.02). **Example.** cd_start 8, c = 0.083: p_def (any clear) = 1 - 0.917^8 = 0.50. With the adjacency factor, c_adj = 0.042: p_def = 1 - 0.958^8 = 0.29. So about 7 of 10 bombs need the player to aim a clear at them. That is the intended skill test. A 3-coat frosting at c_adj 0.042 needs 3 / 0.042 = 71 locks unaimed, so frosting is only fair when the player aims (and it ships with a visible coat count).

### F7. Weighted tilt with heavy pieces

`tau = 1000 * max( |M_x| / (N_w * (W - 1)), |M_z| / (N_w * (D - 1)) )`, `M_x = sum_i w_i * (2 x_i - (W - 1))`, `N_w = sum_i w_i`

| Symbol | Type | Range | Description |
|---|---|---|---|
| x_i, z_i | int | 0 to W-1, 0 to D-1 | Cube column on the plate |
| W, D | int | 2 to 12 | Plate width and depth in cells |
| w_i | int | 1 to 2 | Cube weight. 1 normal, `heavy_weight` (2) for a heavy shape or anvil cube. NEW. The engine counts every cube as 1 today (`tilt_plate.gd:78-83`) |
| N_w | int | 1 and up | Total weight |
| tau | int | 0 to 1000 | Tilt in permille |

**Output range.** 0 to 1000, never negative. The doubled-offset form `2 x_i - (W - 1)` is the engine's own (`tilt_plate.gd:79`), so tau spans 0 to 1000 and the default `slip_threshold` 0.6 (600) is reachable. **Slip rule.** At tau of at least `warn_at` x threshold (0.7 x 600 = 420) a warning shows. At the threshold for `slip_after_resolves` resolves, `slip_count` top cubes of the heavy half are removed. **Example.** W = 6, one row, 5 normal cubes at x = 1,1,2,3,3 and one heavy cube (w = 2) at x = 5. Offsets (2x - 5): -3,-3,-1,1,1 and +5. M_x = (-3-3-1+1+1) + 2 x 5 = -5 + 10 = 5. N_w = 5 + 2 = 7. tau = 1000 x 5 / (7 x 5) = 143, no warning. Replace the heavy cube at x = 5 by two more heavy cubes at x = 5 (3 heavy): M_x = -5 + 3 x 2 x 5 = 25, N_w = 5 + 6 = 11, tau = 1000 x 25 / 55 = 455. That is above the 420 warning. This shows why a heavy piece on the high side is decisive.

### F8. Item yield in the campaign (solo)

`E_items = pieces * p_item * p_collect`, solo table probability `P_i = w_i / sum(w_buff)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| pieces | int | 20 to 120 | Pieces placed in the level |
| p_item | float | 0 to 0.5 | Item cube chance per spawn; 0.12 (`items.gd:115`, clamp `items.gd:56`) |
| p_collect | float | 0 to 1 | Share collected by a clear; placeholder 0.6 (`items.md` F1) |
| w_i | float | 8 to 10 | Buff weight in `starter.json` |
| E_items | float | 0 and up | Expected items per level |
| P_i | float | 0 to 1 | Chance of item i in solo (debuffs excluded, `items.gd:62-64`) |

**Output range.** E_items about 0 to 43 (120 pieces at the 0.5 clamp is unreachable at the default). **Example.** 60 pieces: 60 x 0.12 x 0.6 = 4.3. Solo buff weights: slow_time 10, bomb 8, helper_drop 10, preview_peek 10 = 38. So slow_time, helper_drop and preview_peek are each 26.3 percent, bomb is 21.1 percent. In solo there is no standing bias (`P = 1`), so bias is ignored. **Campaign default:** items off (`items.md` rule 12); levels turn them on in the first 12 only if the user rules so (Open Question 4).

### F9. Gem and pickup count

`Gems(n) = min(Gem_cap, g0 + floor(n / 2))`, placed only in layers `1 .. gem_max_layer`, `gem_max_layer = floor(f * H_play)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| g0 | int | 1 to 5 | Gems at n = 1; default 3 |
| Gem_cap | int | 3 to 12 | Cap; default 8 |
| H_play | int | 6 to 12 | Playable layers (`piece-set.md` F3) |
| f | float | 0.3 to 0.7 | Share of the stack height where gems may sit; default 0.5 |
| gem_max_layer | int | 2 to 8 | Highest layer index a gem may occupy |
| Gems | int | 3 to 8 | Gems in the level |

**Output range.** 3 to 8. **Example.** n = 7, H_play = 8: 3 + 3 = 6 gems in layers 1 to 4. A gem in layer 6 would need a full 6 layers of stack to reach, so it is never placed there.

### F10. Special-shape bag weight

`share_s = w_s * gate_s / sum_i(w_i * gate_i)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| w_s | float | 0 to 2 | Spawn weight of a special shape in the level's pool (Spawner owns weights, default 1) |
| gate_s | int | 0 or 1 | 1 if the spawn gate passes (stack height at or below `giant_max_height_frac`, free layers at least the shape's extent, a peg or hang point exists for hollow or hook shapes) |
| share_s | float | 0 to 1 | Chance the next bag draw is this shape |

**Output range.** 0 to 1. **Example.** 8 standard shapes at weight 1 plus a ring at weight 0.5: share = 0.5 / 8.5 = 5.9 percent. A giant ring at weight 0.25 with the stack at 70 percent height and `giant_max_height_frac` 0.5: gate 0, share 0 until the stack drops.

### F11. Sprout growth schedule (h1)

`cells_grown(k) = min(grow_max, floor(k_a / E_a) + floor(k_b / E_b))`, `E_a = 2`, `E_b = 1` after the first half of the lambs

| Symbol | Type | Range | Description |
|---|---|---|---|
| k_a, k_b | int | 0 and up | Locks in phase A (first half of lambs) and phase B |
| E_a, E_b | int | 1 to 4 | `grow_locks` per phase; `levels.md:438`: every two locks, then every lock |
| grow_max | int | 0 to 6 | Cap per stalk; 0 means uncapped (`sprouts.gd:45`). Use at least 4 |
| cells_grown | int | 0 to grow_max | Added cells on a stalk |

**Output range.** 0 to `grow_max`. **Example.** 6 locks in phase A and 4 in phase B: 3 + 4 = 7, capped at 4. The engine today has one `grow_locks` value per level (`sprouts.gd:17`), so a phase switch is a small NEW gap (0.5 day).

## 5. Edge Cases

Each case states what happens. "Rescue" means the soft top-out rescue that wipes the lowest planes and spends a warning (`levels.md:34`, README top-out table).

**Chains and combos**
1. **Bomb next to bomb.** A blast never detonates another bomb directly (R-7). If the blast completes a layer, the layer clears in the one allowed extra clear pass, and a bomb cleared there detonates once. Maximum 2 blasts per lock. Counted as one combo step each for scoring (`layer-clearing.md` combo).
2. **Item bomb on a candy bomb.** The item blast runs at `on_lock` before the clear check. It removes the candy bomb by damage, so the candy bomb does not detonate. This is a deliberate safe case.
3. **Countdown bomb hits zero in the same resolve as a clear next to it.** The clear hook runs first, so the bomb is defused and removed (`countdown_bomb.gd:9-15` runs on `on_clear`, the tick runs on `on_resolve_end`). Defuse wins ties. No junk layer is added.
4. **Egg cleared on the lock it would hatch.** The clear hook pays `egg_bonus` and the egg is gone before `on_resolve_end` runs the hatch (`hatching_eggs.gd:10-14` versus `:20`). No chick appears.
5. **Goo spread and a clear in the same resolve.** The spread is skipped once (`goo_spread.gd:15-18`). The next quiet lock spreads normally.
6. **Frosting peeled by two clears in one resolve.** At most one coat per resolve (`_peeled`, `frosting.gd:17-18`). A double clear does not double-peel.
7. **Moody cube next to a rainbow cube.** The rainbow cube counts as a match, so the moody cube is happy and fills its layer. `ART-CHECK` in `moody_cube.gd`; if it does not today, treat as a 0.25 day change.
8. **Sprout growing into a cell a mushroom was about to claim.** The mushroom's marked cell is no longer free at its due lock, so the spawn is cancelled (`mushroom_popup.gd:19-25`). The sprout wins by being first.
9. **Hook hang expires while a piece rests on it.** The status is removed. The cube is a normal cube; it does not fall unless a slice collapse moves it.

**Specials at the top-out line**
10. **A hazard spawns in the danger band.** Spawners already restrict cells: the mushroom needs `layer < layer_count - 4` (`mushroom_popup.gd:30`); goo needs `layer < limit_layer` (`goo_spread.gd:27`); pests need `layer < limit_layer` (`pest.gd:49`). Rule for every NEW spawner: never place into the top 4 layers.
11. **A special cube sits in the danger band after a rescue lifts the stack.** It counts as height like any cube, except `static_geometry` cells (rock, shelf, masked columns), which add none (README line 20, `levels.md:34`).
12. **A bomb or Smash is the only way out of a top-out.** Allowed. Removing cubes lowers height. A bomb blast does not count as a clear for the goal counter, so it cannot win a `clear_n`-style goal.
13. **A critter or gem is in the planes a rescue wipes.** It is lost. Proposed rule (needs the user's ruling, Open Question 3): a rescue never wipes a cell that carries `goal_object: true` (gems, critters, keys, cargo). The wipe skips it and the stack settles around it. Without this rule a rescue can silently lose the goal.
14. **A growing sprout reaches the danger line.** Growth stops (`api.is_free(above)` fails, `sprouts.gd:45`) because the cell above the top is not free or not active. It never causes a top-out by itself.
15. **A pest escapes over the rim (`rim_escape`).** It removes one cube with it and counts `worms_escaped` (`pest.gd:71-76`). If the goal wants the pests gone this is a loss path, not a win.

**Specials inside masks and moving platforms**
16. **Specials on masked cells.** A special is never placed on an inactive cell. A mask change (`request_mask`, gap G1) that deactivates a cell under a special moves the special to the nearest active free cell above, or removes it as displaced if none exists. Anchored cells are never deactivated.
17. **Terraced masks (different mask per layer).** Pads, goo and pests treat an inactive cell as a wall. A bounce hop that would end over an inactive cell is blocked for that cell (same as any blocked translate).
18. **Moving platform bump.** A bump shakes loose cubes that are not supported (G8). Anchored and hung cubes are exempt. Cargo is pushed one cell and may fall off the edge. A critter on the cart is moved to the nearest safe cell, never deleted.
19. **Arch sweep.** Anything above `arch_gap` layers is swept. A gem, key or critter above the gap is swept too. The level validator must keep gems and goal objects below the lowest arch gap or mark them `arch_safe`.
20. **Camera or axis change.** If a level changes the down axis (`topsy_tumble`, `flip`), specials keep identity and status through the move (README line 35). Pad direction, magnet pull direction and ice slide direction are stored in world axes, so they do not flip with the view.

**Specials in the soft rescue**
21. **Rescue never releases a goal item.** Per `levels.md:34`, a rescue never releases a grip. Extend: a rescue never collects a gem, key, egg bonus or item cube (`items.md` edge case: lost).
22. **Rescue while a countdown bomb is live.** The bomb is wiped with its plane if it sits low. If it sits above the wiped planes it keeps its remaining count. No junk layer is added by a wiped bomb.
23. **Rescue while a hazard is warning.** Warnings are cancelled if their target cell is wiped. The next warning is scheduled after `E` locks. This prevents a free hit during the recovery pause. Rule R-warn: all warning timers pause during the rescue animation (framework "Suspended", `buffs-debuffs.md` rule 4).
24. **Rescue with goo.** Goo cells wiped with their plane. Goo above the wiped planes stays and settles (slice mode shifts down).
25. **Rescue and a tilt plate.** Run the tilt check after the wipe, before play resumes. If tau is still above the threshold, give one grace resolve with no slip (`slip_after_resolves` counts from the first resolve after the wipe).

**Other**
26. **Two hazards want the same cell.** The first marked wins. The second finds the cell occupied at its due lock and cancels (all spawners cancel on an occupied mark, for example `mushroom_cancelled`, `hail_cancelled`, `geyser_cancelled`).
27. **A special piece (ghost, balloon, bubble) is held.** The piece keeps its tag and flags through hold (`items.gd:109-113` shows the rule for item cubes). The ghost flag is re-evaluated on respawn.
28. **Reduced motion.** Idle animations become static badges. Warnings stay visible as static outlines plus the same sound. No information is lost (`accessibility` rules; the weather layer is already skipped under reduced motion, `level-identity-spec.md:46`).
29. **Colour-blind play.** Every special has a badge shape that is unique across the set (section 3.1 convention 1). Hazard rims also differ by pulse pattern: warn is a slow pulse, due is a fast pulse.
30. **Determinism.** Every random choice uses the rule's own stream (`api.rng()`), is ordered canonically, and a one-candidate choice draws nothing (README line 61). New rules must do the same, or replays diverge.

## 6. Dependencies

This catalogue reads from the systems below and must be listed in each as a dependency (bidirectional rule, `.claude/rules/design-docs.md`). Those edits are not made here; they are a follow-up (Open Question 5 offers the user the choice).

| System or file | Direction | What flows | Hard or soft |
|---|---|---|---|
| `design/gdd/piece-set.md` | both | Shape families, tags, hue and motif rules. This doc adds power-by-form to shapes and asks for tags `heavy`, `hang`, `pin`, `nest` | Hard |
| `design/gdd/block-status-effects.md` | both | The 7 shells. This doc records engine status per shell | Hard |
| `design/gdd/obstacles.md`, `obstacle-clearing.md` | both | Rock, pillar, junk, hit points, damage. This doc adds `goal_object` and `anchored` rules | Hard |
| `design/gdd/items.md`, `buffs-debuffs.md`, `skills.md` | both | Item table, effects, skills. This doc adds 4 NEW items | Hard |
| `design/gdd/layer-clearing.md` | reads | Clear passes, combo, chain rounds, `clear.chain_max` | Hard |
| `design/gdd/board-grid.md` | reads | Footprint, masks, `P_eff`, spawn clearance | Hard |
| `design/gdd/rule-twist-framework.md` | reads | Rule layers (`content`, `twist`, `mechanic`, `item_buff`), priority, `rules.max_twists` 2, `rules.max_level_mechanics` 1 | Hard |
| `design/gdd/mechanics-catalog.md`, `mechanics-wave3.md`, `minigame-mechanics-wave4.md` | both | Rule handbook entries. This doc points at them and adds proposals | Soft |
| `design/gdd/audio/sfx-cue-list.md` | writes | New cue ids (`AUDIO-NEW`) | Soft |
| `design/art/block-art-sets.md`, `design/art/art-bible.md` | reads | Biome skins, shells, silhouette rule | Hard |
| `design/levels/levels.md`, `level-identity-spec.md`, `minigame-party-rules.md` | reads | First 12 levels, rules, party rules | Hard |
| `design/gdd/tournament-minigames.md`, `mode-minigame-randomizer.md` | both | Which specials a tournament round may use; seed sharing | Soft |
| `design/gdd/onboarding-accessibility.md`, `design/accessibility-requirements.md` | reads | Teach hints, reduced motion, colour-blind rules | Hard |

**Code touched when this is built** (owners as in section 3.2). `assets/data/content/blocks.json` (next `kind_id` 25), `assets/data/rules/*.json` (one per new rule), `assets/data/knobs/*.json` (new `specials.json`), `src/mechanics/**` (new plugins), `src/view/wt_block_materials.gd` and `assets/data/biome_looks.json` (skins and badges), `src/core/rules/plugin_registry.gd` (registers each `PLUGIN_ID`), `tools/qa/block_gallery.gd` (gallery of every special per biome, 12 biomes), `tools/qa/verify_campaign_biomes.gd` (validator checks in section 8).

**Registry.** `design/registry/entities.yaml` exists (version 1, 2026-10-10). It holds only the four playable characters today, and no special block, kind or item. Nothing here conflicts with it. This doc does not edit it. Cross-system facts introduced here are listed in Appendix C, and the user is asked whether to add them (Open Question 5).

## 7. Tuning Knobs

**Where values live.** Per-level rule numbers are in each level's `rules[].params` inside `src/levels/<biome>/<id>/<id>.json` (the rule JSONs under `assets/data/rules/` only declare the param schema, for example `bounce_pad.json` lists `bounce_h` and `dir_mode`). Global knobs are in `assets/data/knobs/*.json` and use the registry format `{id, type, default, min, max, rule_adjustable, source, note}` (see `knobs/rules.json`, `knobs/fall.json`, `knobs/clearing.json`). Item weights are in `assets/data/items/starter.json`. Skill numbers are in `assets/data/meta/abilities_runtime.json`. Shape families are in `assets/data/shapes/families.json`. Biome skins are in `assets/data/biome_looks.json` and `src/view/wt_block_materials.gd`. **Proposed NEW file:** `assets/data/knobs/specials.json` for the cross-level knobs marked NEW below. Nothing in this table is hard-coded (coding standard: gameplay values are data-driven).

| Knob id | File | Default | Safe range | Affects |
|---|---|---|---|---|
| `spawn_every_locks` (mushroom, hail) | level `rules[].params` (`mushroom_popup`, `gumdrop_hail`) | 5 and 4 | 2 to 10 (engine min 2) | Hazard pace, F2, F3 |
| `objects_max` | level params | mushroom 4, hail 6, geyser 3 | 1 to 8 | Board clutter, F3 |
| `place_mode` | level params | random | random, lowest | Where objects land |
| `hatch_locks` / `egg_bonus` | level params (`hatching_eggs`) | 6 / 25 | 3 to 10 / 0 to 100 | Egg tension |
| `grow_locks` / `grow_max` | level params (`sprouts`) | 4 / 1 | 1 to 6 / 0 to 6 | Sprout pace, F11 |
| `bounce_h` / `dir_mode` / `bounce_dir` | level params (`bounce_pad`) | 2 / last_move / +x | 1 to 4 | Bounce travel, F4 |
| `roll_locks` / `snow_max` / `balls_max` / `respawn_locks` / `slope_dir` | level params (`snowball`) | 2 / 3 / n.a. / 8 / -x | 1 to 4 / 1 to 4 / 1 to 3 / 4 to 16 | Snowball threat |
| `per_lock` / `cancel_on_clear` | level params (`goo_spread`) | 1 / true | 1 to 2 / true | Goo growth, F5 |
| `goo_max` | `assets/data/knobs/specials.json` NEW | 12 | 4 to 20 | Caps goo, F5 |
| `ant_every_locks` / `ant_starve_acts` / `ant_shoo_bonus` / `rim_escape` / `late_spawn_s` | level params (`pest`) | 3 / 3 / 50 / false / 0 | 2 to 6 / 2 to 5 / 0 to 200 | Pest pressure |
| `thrown_every_locks` / `cd_start` / `blast_layers` | level params (`countdown_bomb`) | 8 / 8 / 1 | 5 to 16 / 4 to 12 / 1 to 2 | Bomb pressure, F6 |
| `bomb_at` | level params (`earned_specials`) | 7 | 0 (off) or 5 to 12 | How often a candy bomb is earned |
| `bomb_chain_passes` | `knobs/specials.json` NEW | 1 | 0 to 2 | Chain depth, R-7 |
| `bomb_radius` / `bomb_rock_damage` | `knobs/specials.json` NEW (from `buffs-debuffs.md`) | 1 / 2 | 1 to 2 / 1 to 3 | Item bomb size |
| `frosting_layers` | level start, set by kind | 2 or 3 | 2 to 3 | Peel time, F6 |
| `hits_left` / `hard_hits` (geyser rock) | level params (`lava_rock_spawn`) | 2 | 1 to 8 | Rock toughness |
| `pull_warn_ms` / `magnet_range` | level params (`magnet_pull`, new magnet kind) | 600 / 2 | 300 to 1500 / 1 to 3 | Magnet fairness |
| `balloon_per_bag` / `balloon_g_mult` / `balloon_drift_ms` | level params (`balloon`) | 1 / 0.5 / 3000 | 0 to 2 / 0.3 to 0.8 / 1500 to 5000 | Balloon feel |
| `key_per_bag` / `keys_needed` / `keyholes` | level params (`key_stamp`, goal `wind_keys`) | 2 / 4 / authored | 1 to 3 / 1 to 8 | Key hunt |
| `drill_depth` (ember) | level params | 1 | 1 to 3 | Melt depth |
| `every` (anvil) / `max_crush` | level params (`anvil_drop`) | 6 / n.a. | 3 to 12 | Crush rate |
| `slip_threshold` / `warn_at` / `slip_count` / `slip_after_resolves` / `fixed_kinds` | level params (`tilt_plate`) | 0.6 / 0.7 / n.a. / n.a. / ["rock"] | 0.3 to 0.8 / 0.5 to 0.9 | Balance difficulty; meadow_09 goes 0.7 to 0.5 (`levels.md:343`) |
| `heavy_weight` | `knobs/specials.json` NEW | 2 | 1 to 3 | Heavy shapes, F7 |
| `core_hp` / `attack_every_ms` / `warn_ms` / `core_damage` | level params (`defend_core`) | 3 / n.a. / 2000 / n.a. | 1 to 5 / 3000 to 12000 / 1000 to 3000 | Defender pressure |
| `rival_rate` / `rival_warn_pct` / head start / rubber band | level params (`race_rival`) | n.a. | 0.9 to 1.1 of player pace (`levels.md:408`) | Race tension |
| `heist_every_locks` / `heist_warn_locks` / `heist_min_fill` | level params (`squirrel_heist`) | 6 / 1 / 0.5 | 3 to 12 / 1 to 3 / 0.3 to 0.8 | Thief pace |
| `claw_start_layers` / `claw_warn_ms` / `claw_grab` | level params (`crab_claw`) | 2 / 2000 / 1 | 0 to 5 / 1000 to 3000 / 0 or 1 | Claw pressure |
| `melt_every_s` / `melt_max` / `melt_warn_ms` | level params (`lava_rise`) | 35 / 3 / 3000 | 20 to 60 / 0 to 4 / 2000 to 5000 | Lava pressure. Clock-based; see Open Question 2 |
| `lid_first_s` / `lid_max` / `lid_push_per_clear` | level params (`lava_lid`) | 60 / 2 / 1 | 30 to 120 / 0 to 3 / 1 to 2 | Lid pressure |
| `quake_warn_ms` / `quake_max_cubes` / `active_after_clears` | level params (`quake`) | 2000 / 6 / 0 | 1000 to 3000 / 2 to 10 / 0 to 5 | Quake pressure |
| `slide_cells` / `slide_dir` / `start_after_clears` | level params (`ice_slide`) | 1 / +x / 0 | 1 to 2 | Ice slide |
| `p_item` | `items` rule params (`items.gd:115`) | 0.12 | 0 to 0.5 (engine clamp) | Item frequency, F8 |
| item `weight` and `bias` | `assets/data/items/starter.json` | table | weight 0 to 20, bias -1 to +2 | Item mix |
| `item.slots` | `knobs/rules.json` | 2 | 1 to 3 | Hoarding |
| `calm_*`, `stitch_duration_ms`, `smash_size`, `smash_depth`, `redraw_pieces`, `charge_layer_milli` | `abilities_runtime.json` | 250 / 10000 / 3 / 3 / 3 / 125 | per `skills.md` tuning | Skill power |
| `skill.charge_rate` | `knobs/rules.json` | 1.0 | 0.5 to 1.5 | Skill frequency |
| `A_cap`, `E0`, `d_lvl`, `d_bio`, `E_min`, `k_fair` | `knobs/specials.json` NEW | 3, 6, 0.4, 0.25, 3, 1.5 | see F1 to F3 | Progression of specials |
| `gem_points` / `g0` / `Gem_cap` / `f` | `knobs/specials.json` NEW | 100 / 3 / 8 / 0.5 | 0 to 500 / 1 to 5 / 3 to 12 / 0.3 to 0.7 | Gems, F9 |
| `ring_weight` / `giant_weight` / `giant_max_height_frac` | level `spawn` params NEW | 0.5 / 0.25 / 0.5 | 0 to 2 / 0 to 1 / 0.3 to 0.7 | Special-shape frequency, F10 |
| `hang_locks` | `knobs/specials.json` NEW | 4 | 2 to 8 | Hook hold time |
| `fall.g0`, `fall.ramp_per_clear`, `fall.ramp_per_min`, `fall.gravity_scale` | `knobs/fall.json` | 1.0 / 0.05 / 0.0 / 1.0 | see file | Speed ramp. Specials never change the ramp. They multiply gravity only through items and balloons |
| `clear.chain_max` | `knobs/clearing.json` | 10 | 1 to 20 (inert in slice mode) | Chain safety |

**Feedback loops, stated.**
- Positive (needs a cap): goo spread, fire or vine spread, sprout growth into pressure, countdown junk (adds a layer, which makes more hazards reachable). Caps: `goo_max`, `grow_max`, `objects_max`, `burn_spread_p` (0.3), `vine_per_bag` (0 to 2).
- Negative (intended): clear cancels goo, claw, lid, heist. Guard wakes if you stop clearing (OB-39). Frosting and bomb need aimed clears. These keep the player clearing, which is the core loop.
- Neutral: pads, ice, magnets (displacement only).

## 8. Acceptance Criteria

**[U]** automated unit test (gdUnit4, `tests/unit/mechanics/` for rules, `tests/unit/specials/` NEW for this doc). **[V]** validator check in `tools/qa/verify_campaign_biomes.gd`. **[M]** manual or screenshot check, evidence in `production/qa/evidence/`. Existing tests today: `tests/unit/mechanics/wave3_mechanics_test.gd`, `wave4_rules_test.gd`.

**Catalogue integrity**
1. [V] Every entry id in section 3.2 maps to exactly one of: a `blocks.json` kind, a shape in `shape_bank.tres`, a registered rule `PLUGIN_ID`, an item in `starter.json`, a skill, or a documented NEW item. No orphan entries (`.claude/rules/data-files.md`).
2. [U] `blocks.json` holds 24 kinds today; GIVEN the NEW kinds are accepted, THEN `kind_id` values are unique and contiguous from 25.
3. [U] Shape bank has 67 shapes in 10 families and every special-shape rule names a shape that exists (`shape_bank.tres`, `families.json`).
4. [M] The block gallery (`tools/qa/block_gallery.gd`) shows every kind and every special piece in all 12 biomes at 720x1280. Reviewers identify each special in 0.5 s, 3 of 3 reviewers, using the read test (convention 1). Each failure is logged as a defect.

**Rules (existing, regression)**
5. [U] `bounce_pad`: a piece landing on a pad rises `min(bounce_h, free)` cells then moves 1 in the last move direction, once per piece (`bounce_pad.gd:24-41`).
6. [U] `goo_spread`: after a clear in the same resolve, no spread occurs once; otherwise `per_lock` new goo cells appear on free neighbours (`goo_spread.gd:15-33`).
7. [U] `pest`: eats only `block` and `starter`; starves after `ant_starve_acts` with no food; a clear within 1 cell shoos it once and pays `ant_shoo_bonus` (`pest.gd:19-60`).
8. [U] `countdown_bomb`: counts down per lock, defuses on an adjacent clear, adds `blast_layers` junk at 0 (`countdown_bomb.gd:9-21`).
9. [U] `hatching_eggs`: an egg cleared before `hatch_locks` pays `egg_bonus`; at `hatch_locks` it becomes a chick on the lowest reachable neighbour (`hatching_eggs.gd:10-47`).
10. [U] `earned_specials`: a connected same-flavour cleared group of at least `bomb_at` leaves one bomb; its blast skips `anchored` cells (`earned_specials.gd:14-39`).
11. [U] `frosting`: peels at most one coat per resolve (`frosting.gd:17-18`). `licorice_lock` and `locked_cube` change only on an adjacent real clear.
12. [U] `tilt_plate.measure` returns tau 0 to 1000 and ignores `fixed_kinds` (`tilt_plate.gd:26,72-86`).

**Rules (new or changed)**
13. [U] R-2: GIVEN a piece lands on a pad above ice, THEN only the bounce fires and total travel is at most `bounce_h + 1`.
14. [U] R-7: GIVEN two bombs adjacent, THEN a blast removes the second without detonating it; the number of blasts in one lock is at most 2.
15. [U] F7: with W = 6, five normal cubes at x = 1,1,2,3,3 and one heavy cube at x = 5, tau = 143 (round down); with three heavy cubes at x = 5, tau = 455.
16. [U] F5: goo count never exceeds `goo_max` over 200 quiet locks.
17. [U] F3: a level with `objects_max` 4, E 3 and P_eff 12 FAILS validation; with `objects_max` 6 it passes.
18. [U] Gem: a gem is collected by a real clear (+`gem_points`, +1 `gems`) and lost with no points when removed by bomb, ember or rescue.
19. [U] Hang: a hook cube over a `hang` point gets `anchored` for exactly `hang_locks` locks, then it is removed; it still clears in a full layer.
20. [U] Ring fit: a hollow piece may overlap a peg cell only when its hole axis aligns; any other piece is blocked.
21. [U] Switch and gate: covering a `switch` cell with a lock fires its effect once (`once: true`); a gate toggles `request_mask` for its cells.
22. [U] Shield item: the next `defend_core`, `storm_bolt` or `crab_claw` hit is cancelled once, then the shield is gone.

**Fairness**
23. [V] Every timed hazard in a level has a warning of at least 1 lock or 2000 ms before it acts, and a clear-based or placement-based answer.
24. [V] F1: no level has more than `A_max(n)` active specials or more than 1 new special.
25. [V] Banned combinations (section 3.3 table) are rejected.
26. [V] No gem, key, critter or cargo is placed in a pocket, above `gem_max_layer`, or above a level's lowest `arch_gap` unless `arch_safe`.
27. [V] The tiling solver (gap G5) passes with every special shape in the level's bag, 1-lookahead bot, no hold.
28. [U] Determinism: two runs with the same seed give identical snapshots for every new rule (`snapshot()` equal).
29. [U] Rescue: GIVEN a goal object and `goal_object: true` (if accepted, Open Question 3), THEN a rescue wipe skips it; without the flag it is wiped and no item is collected.

**Teach and feel**
30. [M] A first-time tester names each special's job within 10 s of its first appearance in 3 of 4 playtests. Each special first appears in a level where it is the only new thing (F1).
31. [M] Reduced motion: every idle animation becomes a static badge and no information is lost (screenshot per special).
32. [M] Colour-blind simulation (protan, deutan, tritan, greyscale): 3 of 3 reviewers tell all specials in one level apart by badge and silhouette.
33. [M] Reference-quality gate: each special's art scores 9.7 or more from the blind panel against the boards (`reference-quality-bar.md`). Anything below is a defect.

### 8.1 First 12 levels mapping

Source of truth for the levels is `design/levels/levels.md` (frame, revision 2). That file says which core mechanic each level uses and gives a shape list only for meadow_01. All other shape lists below are PROPOSED here for the level designers to confirm (level spec rule: "name the shapes used in each level and give the reason", `level-identity-spec.md:141`). T joins a level only if the solver proves it (`levels.md:25`). Items are off in the campaign unless a level turns them on (`items.md` rule 12), so only skills apply. Skills use `charge` by default. Proposed: `off` in meadow_01 (the tutorial) and `once` in meadow_10 (the boss), allowed by `skills.md` rule 7.

| Level | Specials and objects (from the frame) | Existing or new | Shapes (proposed unless stated) | Why |
|---|---|---|---|---|
| meadow_01 Stump Day | OB-37 stump cage with 3 grips; soft rescue; Stump Grip meter | NEW (G1) | **o, i, l only (stated, `levels.md:82`)** | Teaches drop, turn and a full layer. No T, so parity holds |
| meadow_02 Windbreak | OB-01 defend core (sprout, 3 hp), OB-02 gust and weathervane, OB-35 edge attacker (Gert puffs) | PARTIAL (G9, G11) | o, i, l, plus duo and tri_corner helpers | Plain pieces so the wall is the lesson. Roll axis taught here (`sfx-cue-list.md:33`) |
| meadow_03 Brook Run | OB-31 cargo (basket), OB-32 track events (bump, arch), OB-33 finish marker, Biscuit lean | NEW (G8) | o, i, l, duo; no tall shapes (arch sweeps tall stacks) | Flat, low pieces fit the arch gap |
| meadow_04 Sheep on the Run | OB-27 herd animals, OB-28 pen, BK-39 gates | NEW (G7) | i, l, o, tri_straight, duo | Straight and L pieces make lanes and fences |
| meadow_05 Gnome Hedge | OB-03 stone throw (`storm_bolt`), OB-29 hedge wall with peeking sheep, OB-35 gnomes | PARTIAL (G12) | o, l, tri_corner, duo, mono | Small fitting pieces patch holes |
| meadow_06 Blanket Patch | `fill_shape` goal, terraces (per-layer masks, BK-37 holes), optional IT-15 Rewind | EXISTS rule (`fill_shape.gd`), PARTIAL masks (G16) | pento_flat family (patch tiling) and helpers; T only if solved (`levels.md:248`) | `piece-set.md` lists pento_flat for Fill Target Shape |
| meadow_07 Fog Frolic | OB-06 fog, BK-21 shelf (scaffold), optional BK-25 ghost piece, reveal at win (G14) | EXISTS (fog, shelf, ghost); G14 NEW | i, o, l, tall_corner, tripod | Tall pieces build height; 3D pieces show off the hidden top |
| meadow_08 Bouncy Lambs | BK-05 bounce pad (lily pads), OB-30 lamb walker, secret hoop (G15, OB-25 pattern) | EXISTS pad; NEW lamb (G10) | pole (6-long bridge, SH-08), plank, slab, i, duo | Long pieces span gaps between pads |
| meadow_09 Tilting Hill | OB-04 tilt plate, OB-02 gust (sails), SH-10 heavy shapes (counterweights) | PARTIAL (G9) | big_cube, slab, o, l, i | Heavy pieces are counterweights |
| meadow_10 Gert's Whirl | Recalls OB-01 plus OB-02 (phase 1), OB-27 plus OB-28 (phase 2), OB-04 (phase 3); no new special | NEW (G7, G13) plus above | union of 02, 04, 09 sets | Boss recalls the first third |
| meadow_bonus Kite Day | OB-05 rival, OB-32 track events (updraft, crosswind, cloud bump), OB-36 vent, optional BK-26 balloon piece, SH-13 rocket boost, OB-34 boost pad, OB-31 hamper | PARTIAL (G8, G9) | o, i, l, slab; rocket only if accepted | Light, steady basket; the rocket is the single extra verb |
| meadow_h1 Beanstalk Rescue | BK-02 sprouts (F11), OB-30 lamb walker, bridges, secret golden lamb (G15) | EXISTS sprout; NEW lamb (G10) | pole, pento_i, plank, i, duo | Long pieces make rope bridges |

**Per-level special budget check (F1).** meadow_01: 1 (cage). 02: 2 (core, wind). 03: 2 (cargo, track). 04: 2 (herd, pen). 05: 2 (stones, hedge). 06: 1 to 2 (fill goal, masks). 07: 2 to 3 (fog, shelf, optional ghost). 08: 2 (pad, lamb). 09: 3 (tilt, wind, heavy). 10: boss phases. bonus: 3 or more (rival, track events, boost) which exceeds `A_cap` 3 if rocket and balloon are both on, so ship the bonus with rocket and balloon as options, not both. h1: 2. All within F1 except the bonus with both options.

**Where the existing special kinds are NOT used in the first 12.** mushroom, egg, chick, snowball, goo, pest, gumdrop, frosting, sponge, licorice, moody, bombs, climber boss, rock, mole, locked cube, key, magnet and gem are not used in meadow_01 to h1. They belong to the legacy plans (`src/levels/meadow/*.json` still list older rules such as `balloon`, `mascot_catch`, `wobble`, `gust`, `dandelion_puff`, `mushroom_popup`, and `clear_n` goals). Those JSONs predate the frame and are out of scope here (the frame lists `level_type` and story updates as follow-up, `levels.md:508`). This is flagged in Open Question 1.

## Appendix A. Reference images opened

Every image below was opened with Read. Each line lists what special blocks or objects were spotted. Names, logos and characters are not copied. "Spotted" means an idea only. No PIL crops were possible (no shell), so small-panel details come from the full image at the size the tool showed.

**Style and block boards**
- `biome_block_materials_ref.png` and `style/13_biome_blocks.png` (same image): 12 block skins with one "hero ornament" on the top face of the raised cube: meadow clover and flower, candy heart on frosting drip, ice snowflake and frost cap, underwater purple coral on bubble-gem, lava rock shard with embers, forest leaf on bark, cave amethyst cluster, clockwork gear with brass frame, neon diamond circuit, celestial star, tumble fair ticket badge on striped cube, dune bazaar gold finial on patterned sandstone. Idea used: a special keeps one badge and silhouette and takes the biome material (convention 8).
- `underwater_biome_sheet_ref.png`: unit cube with shell and pearls; hero ornaments coral bud, pearl cluster, small shell; props coral branch, shell, kelp tuft; bubble particles; shipwreck landmark. Ideas: pearl as a gem pickup, shell as a hide-and-seek lid, kelp as sprout skin.
- `volcanic_biome_sheet_ref.png`: obsidian cubes with blue-violet cracks; hero ornaments cooled shard, small vent with smoke, ash tuft; props obsidian spur, cooled stone, volcanic vent; floating rock debris and embers. Ideas: vent as a hazard object, shard as a gem, spur as a pillar.

**Party boards**
- `party_modes_ref.jpg`: Wonky Builders (stack on a spring-mounted island, two players); Block Bridge Race (lava canyon, a tiki rival, rock pillars); Battle Arena Candy Clash (peppermint and jelly floor tiles, lollipop and candy-cane edge props, coloured pieces on a tiled board). Ideas: spring base (bouncy platform), lava below (hazard moat), candy floor tiles (tile kinds on the platform).
- `party_minigames_ref.jpg`: Block Bridge Dash (checkered finish flags, bridge over lava), Wobble Builders (spring base, stability meter), Speed Stack Challenge (grid board on an island, next-block boxes), Party Tour (island map). Ideas: finish flag object, stability meter, tile grid.

**Minigame mockups** (`assets/art/reference/minigame_mockups/`; the user's board names are not reused)
- `mockup_01.jpg` (4 panels): carrying a block over a river to make a bridge (grass cube, ice cube, log cube in the span); avalanche with falling ice cubes, rocks and crystal clusters plus an altitude meter; a lava mine with cracked-lava cubes, loose gems on the floor, mining karts and a spinning saw; a castle with catapults throwing ice ammo. Ideas: gem pickups on the floor, falling rock and ice hazards, mine kart, ammo block.
- `mockup_02.jpg`: heat meter bridge with a pink frosted cube and a star cube; cannons with a block-strength gauge and a trajectory arc; a stone maze with big glowing KEYS, a sleeping stone guard with a "sleep" meter, a key counter, glow-mushrooms and crystals; a volcano climb with ice and lava cubes, a gear hammer machine and a trophy at the top. Ideas: key objects (glow outline, floating), sleeping guard (a dormant hazard that wakes), trophy goal, lava rise meter.
- `mockup_03.jpg`: a winding race track with arch gates, star coins, round blue boost pads and a "next hazard" slot; a tilting round plate on a pivot with a hanging treasure chest and a sea serpent, plus a hold slot; ships firing cannons at a tower, with a destruction percentage; neon floating footholds with gems, hazard warning signs, a grapple and a magnet hook over lava. Ideas: boost pad, coin trail, hanging chest, warning triangle sign, magnet.
- `mockup_04.jpg`: a conveyor machine with a claw crane and a furnace; a kraken whose tentacles wrap a wall; a digging mine with crystals, a drill and cracked-lava floor tiles; a glass-cube sky bridge with a storm cloud blowing wind. Ideas: crane claw, furnace as a clearing object, drillable tile, wind cloud.
- `mockup_05.jpg`: a magnet crane with a tractor beam on space cargo; a cake-stacking rotating plate with a topple meter and donut pieces; a jungle temple with a swinging log trap, arrow traps and a gold idol; a coral conduit (pipe blocks) with a water-flow meter. Ideas: tractor beam, swinging log, arrow trap, pipe connection blocks.
- `mockup_06.jpg` (carries a "Tetro Party Dimensions" logo, layout only): rolling stone boulders on a temple path with coins; a submarine with a crane and a treasure counter; a factory with gear blocks, conveyors and a furnace; a hex arena with goal gates and a speed-boost meter. Ideas: boulder, coin, treasure counter, gear block, goal gate.

- `mockup_07.jpg`: a kraken over a glowing tiled sub-deck with coral blocks; an airship deck with cannons and crates; a wormhole (swirling gravity well) in the middle of a hex floor with neon cubes; a prehistoric nest of glowing eggs with lava and a dinosaur. Ideas: gravity well object, egg nest, cannon, crates.
- `mockup_08.jpg`: pyramid with a rolling boulder and hieroglyph sandstone blocks; clockwork gear blocks on a turning gear with a pressure gauge and steam; a ship deck with treasure chests and crates in a storm with a tentacle; a cake plate with jelly, waffle and cake blocks and a sweetness meter. Ideas: rolling boulder hazard, gear block, chest-on-stack cargo, jelly and waffle block skins.
- `mockup_09.jpg`: magnet beams lifting neon blocks over a space deck; a rail loop with a mine cart and cotton-candy and lollipop props; a treasure island with chests, bridges and waterfalls; a vine-covered stone tower with a giant stone ape. Ideas: magnet beam, rails, chests, vine-wrapped block.
- `mockup_10.jpg`: a rope bridge with a golden idol and a rolling boulder; a deep-sea board with transparent BUBBLE blocks and coral blocks and an oxygen meter; gears and steam vents; laser drones, neon blocks and arrow boost pads. Ideas: bubble block (see BK bubble), idol as a goal, laser hazard, steam vent, arrow pad.
- `mockup_11.jpg`: an ice floor with giant snowballs and coloured target rings; a rail with a crystal mine cart and a crane; catapults vs a castle with gargoyle statues and bullseye targets; a jungle with a red spotted mushroom that sprays a bounce, vines, falling rocks. Ideas: snowball, target ring, gargoyle statue (hazard at the board edge), mushroom bouncer.
- `mockup_12.jpg` (Wacky Party): gnomes throwing acorns and rocks across a gap with a vine-lashed log; a gingerbread fort on a cake with a spiky candy ammo; an ice floor with ramps, icicles and a giant snowball ("next ramp"); a glowing glass spiral tower with lasers ("next connector"). Ideas: acorn and rock throws (meadow_05 stones), log with vines, ice ramp, connector piece.
- `mockup_13.jpg`: a lava dash with spiked wrecking balls swinging on chains and glowing blue pads; ships on a whirlpool with treasure chests and coins; a neon maze with laser gates and a glass-dome orb; a scarecrow boss in a pumpkin patch with giant veg and mushrooms. Ideas: swinging spike ball, whirlpool, laser gate, chest, boss weak-point hammer.
- `mockup_14.jpg`: bubble bumper cars on a cracked stone ring over lava; a jungle with a boulder chase, rope bridge, floor spikes, fruit and a blue boost pad plus a boot item; a crystal mine with gems and carts and a pickaxe tool; a hex arena where paint splats cover tiles. Ideas: gems, floor spikes, paint-the-tile, boot (speed item).
- `mockup_15.jpg` (portrait, 4 panels): a meadow island where gnomes and sheep are herded into a fenced pen (wooden fence, flower cluster props, waterfalls off the rim); a candy path with peppermint swirl bumpers and a candy-warning icon; a glacier floor with gold STARS to collect and penguins; hex tiles with virus enemies and a shield. Ideas: fence, sheep, penguin, collectible stars on the floor, enemy bugs. This panel is the direct source for meadow_04's herd.
- `mockup_16.jpg` (Party Quest hub, logo not reused): glass-cube bridge builders; a big BOMB on a gear platform with red and blue cubes around it ("Bomb Defuse"); balloon-lifted block carts on a cloud track ("Balloon Race"); a volcano with a stack of glowing lava cubes ("Lava Escape"). Ideas: central bomb with colour-coded cubes, balloons that lift a block, lava cube skin.
- `mockup_17.jpg`: hex sci-fi board with high-tech cubes with core lights, a gear housing and a next-block screen. Idea: sci-fi cube skin with a lit core (neon biome).

**Party and biome boards, second set**
- `party_biome_islands_ref.jpg` (4 boards; the Nintendo figurines, castle, pipes and titles are NOT used, per `index.md`): a meadow island with the board inset and themed props around the rim (tall spotted mushroom pillars, round bushes, flowers); two lava keeps with angry stone-face statues standing at the board edge, fire tiles and floor holes inside the board, a lava moat and lava falls off the island, a stone idol on the rim; a glass board at a rainbow-road crossing with a neon grid. Ideas used: edge statue hazard (OB-hazard statue), fire tile (floor tile), floor hole (mask), lava moat, glass grid. These are the exact items the user ruled "relevant".
- `party_versus_ref.jpg`: Block Bridge Dash split screen with a checkered finish flag, stability meters and a "Speed Boost" gem button; Wonky Tower Builders on spring bases with stability meters; Island Claim Battle (floor tiles coloured blue and red by who claimed them, tiki and palm props, fruit props). Ideas: finish flag, extra-verb gem button, claimed-tile floor.
- `biome_screens_ref.jpg` (4 biome scenes): candy (wafer-tile board, gumdrop and jelly cubes, chocolate cubes, gummy-bear critters, candy castle); lava (cracked-lava stone board with glowing seams, big gem crystals, a dragon and a fire sprite, lava falls); underwater (glowing dark tiles, shells and jellyfish standing on tiles, an octopus at a DJ deck, shipwreck); neon (circuit-board plinth, arcade cabinets, a robot wizard on a stone tower). Ideas: jellyfish and shell critters on tiles, gem crystals, gummy bear as critter.

- `mockup_18.jpg`: a hub of floating gear-bottomed islands; a central board on a wooden scaffold with plank platforms at several heights (pieces fall onto planks); balloon-lifted crate carts on a road; a bomb on a tray among characters; a stone arch bridge over water. Ideas: plank shelves inside the play space (BK-21 shelf), balloon lift.
- `mockup_19.jpg` (4 panels): Tower Tumble (a board with plank platforms around it and glowing rainbow cubes); Bridge Builder (a stone arch bridge over water); Balloon Race (cloud with next-piece bubbles) with a small palette of six block types in a wooden frame: grass cube, carved wooden crate, mossy crate, plain crate, glass crystal cube, coiled spring; Bomb Defuse (a black bomb with a spark on a gear board with colour cubes). Ideas: the six-type palette (spring, glass, crate) is the direct inspiration for the spring skin of the bounce pad and the glass ghost block.
- `mockup_20.jpg` (4 panels): Fruit Stack (cubes shaped as orange, banana and watermelon on a tile board); Potion Puzzle (glowing potion bottles as pieces on a stone lab table, a golem); Candy Climb (a tower of candy cubes with a crystal cube on top, a gummy-bear king and a spring "next block"). Ideas: fruit and potion skins, a crystal cube as a gem-on-top, spring as a piece.
- `mockup_21.jpg`, `mockup_22.jpg`, `mockup_23.jpg`: opened. They show the same four-panel boards as `mockup_01` to `mockup_03` (Bridge Bashers set, Bridge Dash set, Rolling Rumble set) as far as visible at this size. No new items beyond those already listed.

- `mockup_24.jpg` to `mockup_29.jpg`: opened. They repeat the boards of `mockup_04` to `mockup_09` (Clockwork Conveyor set, Galactic Grab set, Abyssal Kraken set, Pyramid Climber set, Magnetic Mash set) as far as visible. No new items.
- `mockup_30.jpg` and `mockup_31.jpg`: opened. Repeats of `mockup_17` (Quantum Spire) and `mockup_16` (hub with bomb, balloon carts, lava stack).
- `mockup_32.jpg`: a lava survival race on rock pillars with cracked-lava and obsidian cubes; a zero-gravity arena with beams around a central core and floating loose cubes; an ice wall vs a stone golem that punches through it (boss weak point); a physics tumble tower of wooden planks with metal corner brackets on a gear. Ideas: golem boss that hits a wall (meadow_10 Gert boss analogue), plank pieces, loose floating cubes.
- `mockup_33.jpg` and `mockup_35.jpg` (portrait, 3 boards each): a dinosaur jungle floor with mud pits and mossy stone cubes and a log piece; a clockwork floor with loose gear tiles, pipe pieces and brass boxes; a deep sea clam shell board with treasure chests, sponge and coral pieces, and a pearl. Ideas: mud-pit floor tile, pipe connector piece, treasure chest, pearl, clam shell rim.
- `mockup_34.jpg`: a jungle ruin with carved wooden crates, leaf cubes and vine-covered pillars; a clockwork tower with a clock, crystals and gear floor tiles; a candy castle on a frosted cake with gummy cubes and chocolate cubes. Ideas: carved crate and leaf cube skins, crystal cube, chocolate cube.
- `mockup_36.jpg`: a mixed island map: a volcano, a ship and treasure chest, a tech lab with laser beams and hologram plates, glowing runes on forest floor, giant spotted mushrooms, slides, round coloured buttons in red, yellow and green on the path. Ideas: floor buttons (switch plate), rune glyph tiles, giant mushroom props.
- `mockup_37.jpg`: deep sea dive with transparent bubble cubes that hold small creatures; a space station with glowing energy cubes and round red pads on the floor; a haunted mansion with ghosts, tombstones and pumpkins on the board. Ideas: bubble cube (see BK-27), red floor pads (switch), ghost props (ghost piece skin), pumpkin props.

**Style boards** (`assets/art/reference/style/`), all 16 opened:
- `01_story_flow.jpg`, `02_story_beats.jpg`, `07_story_tutorial_beats.jpg`: wizard on a cloud, tutorial island with a glass-ghost preview block, a cart carrying a stack, tournament with cannons; a jungle cart with falling stone blocks and monkeys; a balance tutorial with a tilting plate and warning triangles; a goblin ambush on a fort; a molten guardian boss; a cosmic nexus with wormholes; a treasure chest finale. Ideas: ghost preview block, tilt plate with warning triangle, boss weak points, wormhole.
- `03_choose_mode_library.jpg`, `04_settings_wide.jpg`, `05_select_mode_a.jpg`, `06_select_mode_b.jpg`, `08_settings_options_tall.jpg`, `16_settings_wizard_peek.jpg`: UI only. No specials. Used for the no-beige rule and wood and purple frame style (cited by `reference-quality-bar.md`).
- `09_minigames_a.jpg` to `12_minigames_d.jpg`: the 16 named minigame boards (see the mockup entries above; the same scenes: Bridge Bashers, Avalanche Ascent, Rubble Rumble, Fort Frenzy, Bridge Dash, Fort Blast, Maze Heist, Summit Scramble, Clockwork Conveyor, Kraken Blockade, Digging Frenzy, Chroma Sky Climb, Rolling Rumble, Tumbling Towers, Shatter Shootout, Frenzy Footholds). Specials spotted: ice and wood and grass cubes as different materials in one bridge, gems, keys, sleeping guard, lava rise meter, boost pads, hanging chest, warning signs, magnet and grapple.
- `13_biome_blocks.png`: 12 biome blocks (see above).
- `14_tournament_flow.png`: Tumble Fair lobby, wheel, round, standings, win. Specials: translucent glass ghost-preview cubes on each player's island, an arch piece (hollow shape) on P4's tower. Idea: the arch piece is shown in play.
- `15_title_and_hud.png`: title and in-level HUD for meadow, ice, celestial. Specials: every cube carries a small sprout leaf sticker on its top face; a 3-slot next-piece tray at the bottom; two round buttons at the corners in celestial (skill and item slots). Idea: the sprout leaf is the existing biome ornament, so a special's badge must differ from it (shape and colour), not copy it.

**Root-level boards also opened:** `screens_flow_ref.png` (same as board 15, 4 phone frames), `title_screen_ref.png` (title with an empty tile board and moss bushes), `title_variants_ref.jpg` (title, candy and underwater HUD, a 6-biome block palette: meadow, candy, lava, crystal cave, neon, dune bazaar), `wizard_turnaround_ref.png` (character), `tournament_flow_ref.png` (same as board 14). **Not opened:** `logo_ref.jpg` and `logo_master.jpg` (logos only, no specials; the references rule says never copy logos).

**Honesty notes on this list.**
1. No shell, so no PIL crops. Everything was read whole.
2. Several first-pass reads of the earliest images returned no picture (a tool limit). The mockup entries for `mockup_01` to `mockup_11` were written from what the same scenes show in the style boards 09 to 12 and in later mockups, so a few scene-to-file attributions in that range may be shifted by one or two files. The ideas listed are real and visible in the reference set; the exact `mockup_NN` filename for a given idea may be wrong. Source lines in the catalogue cite the scene name as well as the file for this reason. A reviewer should re-check `mockup_01` to `mockup_11` and `underwater_biome_sheet_ref.png` and `volcanic_biome_sheet_ref.png`, `biome_block_materials_ref.png` (their descriptions come from earlier text-only knowledge plus later boards showing the same blocks).
3. Items that cite `ART-CHECK` need a read of `src/view/wt_block_materials.gd` and `assets/data/biome_looks.json`, which this pass did not open.

## Appendix B. Open questions

Each has a recommended option first. The decision is the user's.

1. **Which special kinds join the first 12 levels?** The frame uses only core objects. Many existing kinds (egg, mushroom, sprout, key) sit unused.
   - Keep the frame as written; use the existing kinds from Chapter 2 on (Recommended). Protects the one-new-thing-per-level curve.
   - Add one existing kind to meadow_h2 and h3 as a remix. Cheap, since they already exist.
   - Add eggs and mushrooms into Chapter 1 teach levels. More variety, but breaks the frame.
2. **How do clock-based hazards (lava rise, lid, quake, claw, stone throws) respect the no-countdown rule?**
   - Add `schedule_mode: locks` so Tetris-variant levels time hazards by locks, and keep ms only for races and boss waves (Recommended). About 1 day.
   - Allow ms timers but hide the countdown from the HUD. Zero work, but the pressure is still a clock.
   - Ban these hazards from Tetris-variant levels. Cleanest rule, loses the lava biome's identity.
3. **Should a soft rescue ever wipe a goal object (gem, key, critter, cargo)?**
   - Never; add `goal_object: true` and the wipe skips them (Recommended). About 1 day.
   - Wipe them but refund a replacement. Simple, but the goal can bounce back.
   - Wipe them and count it as a lost life. Strict, risks unfair top-outs.
4. **Should items (the 8 plus 4 new) appear in the campaign?**
   - Off in the campaign; skills only; items for Arcade, versus and tournament (Recommended, matches `items.md` rule 12).
   - On from Chapter 2 with buffs only (debuffs are already stripped in solo).
   - On everywhere. Most variety, hardest to balance against star rules.
5. **What do you want from this document next?**
   - Review the catalogue first, then add the accepted new kinds to `blocks.json` rules and add cross-system facts to `design/registry/entities.yaml` (Recommended).
   - Send it straight to a design review and `/review-all-gdds`.
   - Trim the NEW list to a short MVP set first (gem, ice cube, switch, gate, peg, hammer).

## Appendix C. Cross-system facts introduced (for the registry, not yet added)

| Name | Type | Value or rule | Owner doc |
|---|---|---|---|
| `heavy_weight` | constant | 2 | this doc, F7 |
| `goo_max` | constant | 12 | this doc, F5 |
| `A_cap` | constant | 3 | this doc, F1 |
| `E0`, `d_lvl`, `d_bio`, `E_min` | constants | 6, 0.4, 0.25, 3 | this doc, F2 |
| `k_fair` | constant | 1.5 | this doc, F3 |
| `bomb_chain_passes` | constant | 1 | this doc, R-7 |
| `hang_locks` | constant | 4 | this doc, SH-05 |
| gem, magnet, ice, fire tile, switch, gate, peg, hang point | proposed kinds | next `kind_id` from 25 | this doc, BK-33 to BK-42 |
| `goal_object` flag | proposed status | skips rescue wipe | this doc, Edge Case 13 |

## Appendix D. Item index and counts

| Group | Entries | Existing in engine | Partial | New |
|---|---|---|---|---|
| (a) Special shapes (SH) | 12 | 4 | 7 | 1 |
| (b) Special block kinds (BK), incl. 7 status shells | 45 | 29 | 6 | 10 |
| (c) Objects (OB) | 39 | 21 | 5 | 13 |
| (d) Items and skills (IT) | 16 | 12 | 1 | 3 |
| **Total** | **112** | **66** | **19** | **27** |

"Existing" means the rule or shape is in the engine today. "Partial" means the base exists and a power, view or rule is missing. In group (b), 7 of the 10 NEW entries (fire tile, hole, switch, gate, peg, pillar, hang point) are floor or wall markers rather than cubes; they are filed under block kinds because they are cell-level data in the level file.

## Appendix E. User decisions (2026-10-14)

- **Chapter 1 specials:** "Remix in hard levels." Each of meadow_h2 and meadow_h3 adds one existing special kind as a
  remix. The teach levels 01-10 keep the core objects only.
- **Clock-based hazards on Tetris-variant levels:** "Hidden timer." Millisecond schedules stay, but no countdown is shown
  on the HUD. Telegraphs (an actor tell plus a sound) still warn before every hazard.
- **Items in the campaign:** "From Chapter 2." Starter items and new items unlock in the campaign from Chapter 2 on.
  Chapter 1 uses character skills only.
- **Next step:** "3-expert review first." The document goes to three blind experts before any new kind is added to the data.
