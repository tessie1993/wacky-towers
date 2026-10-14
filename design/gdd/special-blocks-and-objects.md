# Special Blocks and Objects

> **Status**: DRAFT, in progress (skeleton written first, sections filled one by one)
> **Author**: systems-designer (studio expert pass), for the user
> **Date**: 2026-10-14
> **Scope**: every special SHAPE, special BLOCK KIND, platform OBJECT and player-triggered ITEM in Wacky Towers, existing and new
> **Decisions are the user's.** Anything marked `PROPOSED` or listed under Open Questions is a recommendation, not a ruling.

## Work log (resume point)

- Skeleton written. Sections still to fill are marked `TODO`.

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
4. **Layer fill.** `fills_layer` true means the cell counts toward a full layer. Cells with `fills_layer` false (rock, shelf) are excluded from the denominator. Each entry states which applies.
5. **Rescue.** The soft rescue wipes the lowest planes. It never releases a goal item and never collects an item cube (`items.md` edge cases). Specials in wiped planes are lost with no payout. Entries state exceptions only.
6. **Top-out line.** A special inside the danger band counts as stack height like any cube, unless the entry says `static_geometry` (then it adds none, as the masked columns of meadow_01 do).
7. **Audio ids** are proposals in the form `<id>_<event>` (`bounce_pad_hop`, `goo_spread_warn`). They must be reconciled with `design/gdd/audio/sfx-cue-list.md` by the audio director. `AUDIO-CHECK`.
8. **Biome skins.** A kind keeps one silhouette and one badge in every biome. The biome only changes material and palette (the 12-biome block sheet in `biome_block_materials_ref.png`: grass and clover, frosted jelly, frosted ice, bubble gem, cracked lava, bark and leaf, crystal rock, brass and gears, neon circuit, starfield, striped candy tent, patterned sandstone). Skin names below are proposals.

**Counting rule used in the index.** "Item" means one catalogue entry. A mirror pair (hook_left and hook_right) is one entry. A family of identical-behaviour variants (frosting and frosting_three) is one entry.

### 3.2 Catalogue (one entry per item)

Field order for every entry: **What** / **Rule** (trigger, effect, duration, layer fill and clears, gravity, other specials, rescue and top-out) / **Look** / **Audio** / **Fits** / **Intro and teach** / **Fairness** / **Engine** / **Source** (reference). Biomes use the 12 in `levels.md` plus the two extra sheet biomes (tumble fair, dune bazaar) where a skin exists.

#### 3.2.a Special SHAPES

The bank has 67 shapes in 10 families (`assets/data/shapes/families.json:4-92`, `shape_bank.tres`). Per `piece-set.md` Core Rule 6, tags never change a shape's cubes, and biomes never add shapes. A shape is "special" here because its form gives it a rule effect or a level job. Most shape powers need a platform object to bite on (a peg, a pillar, a pocket), which is why shapes and objects are specified together.

**SH-01 ring, SH-02 arch, SH-03 loop (hollow family)**
- **What.** Pieces with a hole through them. The ring is 8 cubes (`shape_bank.tres:634-643`, 3 distinct orientations). The arch is 7 (`:22-31`, 12). The loop is 6 (`:351-360`, 4). They drop over a standing thing, and they make a pocket you cannot fill from above.
- **Rule.** Trigger: the piece lands. Effect (existing): the hole becomes a covered hole once the ring is down. `mascot_catch` already vetoes a lock that covers a hole when a level turns it on (`src/mechanics/behaviour/mascot_catch.gd`, README line 27). Effect (NEW): a ring-type piece may be placed so its hole is around a `peg` or `pillar` (OB-14, OB-15). That counts as a "fit" and the piece locks one lock-delay early with a ring chime. The hole inside a ring is a pocket: `fills_layer` for the pocket cell stays false until filled, so a layer with a ring-pocket cannot clear until the pocket holds something. Level data must say so (`pocket_ok`), or the validator warns. Gravity: normal. Specials: a critter or key placed in the pocket is protected from hail and goo until the ring clears. Rescue: a pocket with a critter in it is wiped like anything else. Top-out: normal.
- **Look.** Hue is Hollow lime `#9FD65B` (`piece-set.md`). The hole itself must be bright and open: a glowing inner rim and a tiny "fits here" chevron on the ghost when a peg is under it.
- **Audio.** `ring_fit_chime` when it drops over a peg, `ring_land` otherwise.
- **Fits.** Meadow (fence posts for ring toss), carnival (ring-toss poles), pirate (anchor rings), clockwork (washers on spindles), ice (ice-fishing holes). `piece-set.md` already lists pillar levels. Not in the first 12 levels at present (see 8.1).
- **Intro and teach.** First in a carnival or meadow bonus level with one peg and no pressure. Teach by a looping preview of a ring dropping over a post and the hint "Drop the ring over the post!" (12 words or fewer).
- **Fairness.** Risk: a ring makes an unfillable hole and ends a run through no fault. Counterplay: the 1-lookahead tiling check (gap G5 in `levels.md`) must pass with rings in the bag, and a ring-pocket is never counted against the player in stars. Rings never appear at weight above the knob `ring_weight` (section 7).
- **Engine.** PARTIAL. Shapes EXIST. The peg fit and pocket flag are NEW. Size 3 days. Owner: gameplay-programmer (rule), systems-designer (validator spec).
- **Source.** The ring and pillar idea comes from `piece-set.md` ("rings drop over pillars"). Visual idea: ring-toss and poles in the party and carnival boards `party_minigames_ref.jpg` (to be confirmed in Appendix A).

**SH-04 giant_ring (giant family)**
- **What.** A 12-cube ring (`shape_bank.tres:216-225`). It is a boss-sized ring. It is the only shape that can surround a whole platform feature such as the Hearth Stump or a 2x2 pillar.
- **Rule.** As SH-01, plus it spans up to 3 layers. Weight is very low (Giant family: "low weight", `piece-set.md`). Allowed only where the level lists it.
- **Look.** Blackberry `#6E4F9E`, thick gold rim so it reads as a trophy.
- **Audio.** `giant_ring_land` (deep thud plus chime).
- **Fits.** Celestial finale (orbit ring around a planet prop), pirate (ship wheel), carnival finale.
- **Intro and teach.** Never earlier than the third chapter. Shown in the NEXT strip with a "big" pulse for 2 s before it spawns.
- **Fairness.** Risk: 12 cubes can bury a stack. Counterplay: spawn only when the stack is at or below half height (knob `giant_max_height_frac`, section 7).
- **Engine.** Shape EXISTS. Spawn gate NEW, 1 day, gameplay-programmer.
- **Source.** None (ours).

**SH-05 hook_left and hook_right (pento_3d)**
- **What.** 5-cube hooks (`shape_bank.tres:258-280`, 24 orientations each). A hook can catch on a ledge, branch or rail.
- **Rule.** Trigger: a hook cube ends one cell above a `hang_point` object (OB-16: peg, branch, rail) while another cube rests on solid. Effect (NEW): a hook with its hook-cube over a hang point locks as "hung": it gets the `anchored` status for `hang_locks` (4) locks. Anchored cubes are not moved by wobble, conveyor, wind, bounce, or quake. When the timer ends the status is removed. Never permanent. Clears: a hung cube in a full layer clears normally and the status goes with it. Rescue: wiped like any cube.
- **Look.** Lavender `#A78BEB`. A small rope loop or brass hook icon where it hangs. The anchored cubes show a thin gold outline while anchored.
- **Audio.** `hook_hang_clink`.
- **Fits.** Forest (branches), pirate (rails, rope), clockwork (rails), cave (stalactite hooks), carnival (tent rope).
- **Intro and teach.** Forest or pirate, one level where wind or tilt is the threat and a hang point is near the platform edge. Teach with the hang point glowing and a hint "Hook it on the branch!".
- **Fairness.** Risk: players who do not know it ignore it; no harm. Because it is only a bonus, it never blocks a win.
- **Engine.** Shapes EXIST. Hang rule and object NEW, 3 days, gameplay-programmer. Reuses `anchored` status already used by `rock_obstacle.gd:20`.
- **Source.** Hooks and ropes from the pirate and cliff boards (`minigame_mockups`, see Appendix A).

**SH-06 claw_left and claw_right (pento_3d)**
- **What.** 5-cube claws (`shape_bank.tres:93-115`). A claw grips a bump on the stack.
- **Rule.** NEW, optional. A claw whose claw-cube lands beside an existing cube on the same layer, with a gap-free contact on two opposite faces, locks "gripped": lock delay 0 and immune to the next gust or bounce push (one event). One use per piece. Clears normal.
- **Look.** Lavender, with two pincer tips tinted gold on the gripping cube.
- **Audio.** `claw_grip_snap`.
- **Fits.** Underwater (crab), pirate, clockwork.
- **Intro and teach.** Underwater level 04 or later, where `crab_claw` is the hazard, so claws feel like the answer. Teach by tying it to the crab (the player's claw answers the crab's claw).
- **Fairness.** Pure bonus. No harm.
- **Engine.** Shapes EXIST. Grip rule NEW, 1.5 days, gameplay-programmer.
- **Source.** Underwater sheet (crab and shell) `underwater_biome_sheet_ref.png`.

**SH-07 jack (chunky)**
- **What.** A 7-cube cross with one orientation (`shape_bank.tres:298-307`, `families.json:67`). A centre cube with an arm on each of 6 faces, as read from "7 cubes, 1 distinct orientation". `ART-CHECK` to confirm the arm length.
- **Rule.** Existing: it spans 3 layers. The centre layer receives 5 cubes. The top and bottom layers receive 1 cube each. NEW power "pin": when a jack's lowest arm lands in a 1-cell hole, it locks at once ("pinned") and cannot slide, bounce, or wobble off. A jack never rotates visibly (one orientation), so it never changes shape under a rotate input, which makes it a perfect rule-reading teacher.
- **Look.** Cocoa `#9A6A4A` family, but jacks get a bright orange centre bead so the centre reads.
- **Audio.** `jack_pin_thunk`.
- **Fits.** Carnival (toy jacks), meadow bonus, cave.
- **Intro and teach.** Chapter 2 or later. Teach on a platform with a single 1-cell hole.
- **Fairness.** Risk: 3 layers tall. Do not spawn when fewer than 3 free layers exist (spawn gate, as SH-04).
- **Engine.** Shape EXISTS. Pin rule NEW, 1 day, gameplay-programmer.
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
- **Rule.** NEW tag "heavy": a heavy piece counts each cube as `heavy_weight` (2) in the tilt plate and wobble sums (`tilt_plate.gd`, `wobble.gd`). On landing, a heavy piece closes up to `max_crush` gap cells under itself in each column, as `anvil_drop.gd` already does for flagged spawns (README Wave 3 table). Existing `anvil_drop` is the same effect as a flag; heavy shapes make the flag permanent per shape.
- **Look.** Blackberry or Lemon, with a cast-iron weight stripe and a "kg" badge. Landing shakes the camera by a small amount (reduced under reduced motion).
- **Audio.** `heavy_land_thud`.
- **Fits.** Meadow 09 (tilting hill counterweights), clockwork (weights), pirate (cargo), cave.
- **Intro and teach.** Meadow 09 is the natural first use: "stack counterweights on the high side".
- **Fairness.** Risk: a heavy piece in the wrong place tips the plate at once. Counterplay: the tilt gauge previews the landing tilt with the ghost.
- **Engine.** PARTIAL. `anvil_drop` EXISTS (`src/mechanics/wave3/anvil_drop.gd`). Heavy tag in tilt sums NEW, 1.5 days, gameplay-programmer.
- **Source.** None.

**SH-11 dented_cube (chunky)**
- **What.** A 7-cube block with a dent (`shape_bank.tres:147-156`, 8 orientations). The dent is a ready-made pocket for a small thing (egg, gem, key).
- **Rule.** NEW optional: an egg, gem or key placed in the dent (through the `drop_in` rule of the level) is "nested" and cannot be touched by goo, pests, or hail until the piece clears.
- **Look.** Cocoa, with a visible bowl-shaped dent and a soft inner light.
- **Audio.** `nest_settle`.
- **Fits.** Meadow (nest), forest, candy (cupcake).
- **Intro and teach.** With the egg object (OB-02).
- **Fairness.** Pure help.
- **Engine.** Shape EXISTS. Nest rule NEW, 1 day.
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
- **What.** The party "rocket" (8 cubes, 6 orientations, `shape_bank.tres:648-657`) gets a rule: a thruster. Tap the drop button twice in a row (hard drop already exists) and a rocket lifts and slides forward.
- **Rule.** NEW. Only in minigame levels that list `rocket_boost` (race levels, kite bonus). Effect: once per rocket, the "double-tap" moves the piece 3 cells in the last move direction, then drops. Counted as a second verb, so it is shown as one gem button (`minigame-party-rules.md` rule 3). It never works in plain levels.
- **Look.** Strawberry, with flame decal. The gem button glows when a rocket is falling.
- **Audio.** `rocket_boost_whoosh`.
- **Fits.** Meadow bonus (kite race), neon, celestial, carnival.
- **Intro and teach.** Race levels only.
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
### 3.3 Interaction matrix
TODO

## 4. Formulas

TODO

## 5. Edge Cases

TODO

## 6. Dependencies

TODO

## 7. Tuning Knobs

TODO

## 8. Acceptance Criteria

TODO

### 8.1 First 12 levels mapping
TODO

## Appendix A. Reference images opened

TODO

## Appendix B. Open questions

TODO
