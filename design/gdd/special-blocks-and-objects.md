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
7. **Audio ids.** The cue list uses `SFX_<AREA>_<THING>` with areas `SP` (special piece), `EV` (level event), `PL` (physics or landing twist), `FT` (fail type), `BOSS`, `MASCOT` (`sfx-cue-list.md` section 1). Where a cue already exists it is cited by that id (for example `SFX_SP_EGG_HATCH`, `SFX_SP_CHICK_HOP`, `SFX_SP_EGG_BONUS`, `SFX_EV_MUSHROOM_POP`, `SFX_PL_STICKY_SPLAT`, `SFX_SP_FOG_GHOST`, `SFX_PL_WOBBLE_SLIP`). Where it does not, entries give a proposal `SFX_SP_<NAME>` and mark it `AUDIO-NEW`. Short names in the shape entries above (for example `ring_fit_chime`) are shorthand for `SFX_SP_RING_FIT` and so on. The count of 79 rows in the cue list must be updated by the audio director when these are accepted. Style rule from the cue list: cute toybox, soft, wood, felt, rubber, bells; no gore or horror.
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
#### 3.2.b Special BLOCK KINDS, part 1: meadow and living things

Baseline kinds that are not special (listed so the registry is complete): `block` (kind 1, plain piece cube) and `starter` (kind 2, glyph `#`, a level-placed plain cube). Both `solid`, both `fills_layer` true (`assets/data/content/blocks.json:3-22`). Everything below is also in `blocks.json` unless marked `*`.

**BK-01 mushroom (kind 3, glyph `m`)**
- **What.** A springy toadstool that pops up on a free surface after a sparkle warning. It is a small obstacle that you build around, or clear.
- **Rule.** Trigger: every `spawn_every_locks` (5) locks. One lock before, a free surface cell is marked and a sparkle shows (`mushroom_popup.gd:26-38`). Effect: on the next due lock the cell becomes a mushroom cube, unless it was filled, then the spawn is cancelled with `mushroom_cancelled` (`:19-25`). Limits: at most `objects_max` (4) mushrooms on the board; only cells at least 4 layers below the limit and with something or nothing-active under them (`:30`); `place_mode: lowest` restricts to the lowest candidates. Fill: `fills_layer` true, so it counts toward layers and clears with them (`blocks.json:23-32`). Gravity: it is placed on a supported surface and then behaves like a normal cube in slice collapses. Other specials: `object_kind` lets the same rule spawn any registered kind (`:16`), so the same warning and cap machinery spawns goo or a pest later. Rescue: wiped like any cube. Top-out: counts as height.
- **Look.** Red cap with cream spots, a bouncy idle squash every 1.5 s, a rim of hazard orange only while it is a warning mark (sparkle). Skins: meadow cap, candy gumdrop-mushroom, forest moss cap, cave glowing fungus, underwater anemone, neon holo-cap. Never a plain cube silhouette.
- **Audio.** `SFX_EV_MUSHROOM_SPARKLE` (warn) and `SFX_EV_MUSHROOM_POP` (spawn), both in `sfx-cue-list.md:85-86`.
- **Fits.** Meadow (legacy `src/levels/meadow/meadow_04/meadow_04.json:50` uses it, but the levels.md frame makes meadow_04 the sheep drive and does not list it), forest, cave, candy.
- **Intro and teach.** Not in the first 12. Recommended first use: meadow_h2 or forest_01. Teach: the sparkle already tells you where; hint "Sparkle means something is growing here."
- **Fairness.** It can pop into a spot you wanted. Counterplay: the cell is shown a full lock ahead, and a piece placed there cancels the spawn.
- **Engine.** EXISTS (`src/mechanics/behaviour/mushroom_popup.gd`). View for sparkle and squeak is in the Meadow cue list. No gap.
- **Source.** Own idea from the meadow set; the toadstool-style prop appears in the biome and party boards (`party_biome_islands_ref.jpg`, Appendix A).

**BK-02 sprout (kind 4, glyph `^`)**
- **What.** A seed that grows upward as you place pieces. It builds a living column.
- **Rule.** Trigger: every `grow_locks` (4) locks. One lock before, a bud shows (`sprouts.gd:46-47`). Effect: if the cell above the tip is free and the column has grown fewer than `grow_max` (default 1; 0 means uncapped) cells, a new sprout cube appears above it (`:48-53`). Growth metadata (`sprout_id`, count) is stored on the cube and follows slice collapse, belt and flip moves, even after the root clears (README line 31). Fill: `fills_layer` true, so a growing sprout can complete a layer or block one. Gravity: normal. Other specials: pairs with `mill_belt` and `flip` by design (identity retained). Rescue: the sprout is lost with the plane. Top-out: grows only if free above; it never pushes a piece.
- **Look.** Green stalk with two leaves and a bud; the bud pulses faster on the warning lock. Skins: meadow beanstalk, candy sugar-cane, forest sapling, underwater kelp, clockwork brass vine, neon circuit-vine.
- **Audio.** `SFX_SP_SPROUT_GROW` (`sfx-cue-list.md:91`).
- **Fits.** meadow_h1 Beanstalk Rescue uses it ("Sprouts grow new cells on the stalks as you lock pieces", `levels.md:428`; "sprouts grow every two locks, then every lock", `:438`). Forest, celestial garden.
- **Intro and teach.** h1 only in Chapter 1. No earlier teach exists, which is a gap: add a gentle intro in meadow_07 or the bonus (one sprout, `grow_max` 1). Proposed hint: "The bud grows next lock."
- **Fairness.** Risk: a column grows into the landing space and blocks the spawn row. Counterplay: growth stops when the cell above is not free; a `grow_max` cap; the bud warning.
- **Engine.** EXISTS (`src/mechanics/behaviour/sprouts.gd:13-53`). Note: levels.md h1 says "every two locks, then every lock", so `grow_locks` needs a per-phase change (see Formulas F6). Size 0.5 day, gameplay-programmer.
- **Source.** Our own level plan (h1). Reference mockups show growing vines and jungle (checked in Appendix A).

**BK-03 egg (kind 5, glyph `e`) and BK-04 chick (kind 6, glyph `c`)**
- **What.** An egg that hatches into a chick after a few pieces. The chick hops to the lowest neighbour column, so a chick is a small living thing that finds low ground.
- **Rule.** Trigger: every completed lock ages each egg by 1 (`hatching_eggs.gd:20-24`). At `hatch_locks` (6), the egg is removed and a chick appears at the lowest reachable neighbouring cell in a fixed tie order right, left, forward, back, same cell (`:28-47`). One lock before hatching, an `egg_hatch_warning` plays. Clear bonus: an egg cleared before it hatches pays `egg_bonus` (25) points (`:12-14`). Fill: both are `fills_layer` true (`blocks.json:43-62`). Gravity: the chick lands by the rigid-drop calculation on the neighbour column (`:39-40`). Other specials: a chick next to a goo cell is not protected. Rescue: wiped with the plane. Top-out: a chick can hatch into a danger plane; the spawn simply picks the lowest option.
- **Look.** Egg: cream oval cube with speckles and a faint crack line that grows over the 6 locks (crack stage = age). Chick: yellow puffball with orange beak, hop-in-place idle. Skins: meadow, candy marshmallow-chick, pirate parrot egg, underwater turtle egg, celestial star-egg.
- **Audio.** `SFX_SP_EGG_HATCH`, `SFX_SP_CHICK_HOP`, `SFX_SP_EGG_BONUS` (`sfx-cue-list.md:100-102`). The egg-hatch and bonus cues exist; `SFX_SP_EGG_HATCH` has no file yet (GAP).
- **Fits.** Meadow and candy easter-style levels. Not in the first 12 levels frame; a natural fit for meadow_h2 or a bonus. Pairs with `dented_cube` nest (SH-11).
- **Intro and teach.** One egg on an easy level, hint "It hatches in a few moves." The crack stages teach by themselves.
- **Fairness.** Risk: a chick wanders into an awkward cell. Counterplay: it always chooses the lowest, never higher; clear the egg for bonus.
- **Engine.** EXISTS (`src/mechanics/behaviour/hatching_eggs.gd`). View crack stages: gap, 1 day, technical-artist.
- **Source.** Own meadow idea; critters and eggs appear in the party boards (Appendix A).

**BK-05 bounce_pad (kind 7, glyph `b`)**
- **What.** A trampoline cell. A piece that lands on it hops up and slides a cell. It flings the lamb in meadow_08.
- **Rule.** Trigger: the falling piece ends on a pad (any piece cube has a pad directly below it) (`bounce_pad.gd:26-30`). Effect: it fires once per piece (`_bounced`, `:24`). The piece rises up to `bounce_h` (default 2, clamped 1 to 4) cells while free (`:33-37`), then moves one cell in the last move direction (`dir_mode: last_move`) or a fixed `bounce_dir` (`:38-40`). After that the pad is ordinary support (class header, `:2`). Fill: `fills_layer` true (`blocks.json:63-72`). Also spawnable by `lava_rock_spawn` with `object: SP35` (`lava_rock_spawn.gd:21`). Gravity: the hop is a translate against gravity, then normal fall. Other specials: ice (slide twice? see matrix), goo (pad bounce is vetoed on a sticky landing), wind (gust then bounce order: gust is applied before landing). Rescue: wiped like a cube. Top-out: a bounce cannot lift a piece above the limit (the translate is blocked and `rise` is 0).
- **Look.** A round pink or green cushion on a coil spring, squashes when hit, ripple ring. In meadow it is a dewdrop on a lily pad (the frame's story). Skins: meadow lily-dewdrop, candy gumdrop-bounce, carnival trampoline, underwater jelly-bubble, clockwork spring plate, neon rubber-glow.
- **Audio.** Proposed `SFX_SP_BOUNCE_BOING` (AUDIO-NEW); temp `Retro/Jump.wav` as the mushroom pop does.
- **Fits.** meadow_08 Bouncy Lambs (the whole level, `levels.md:290-318`). Candy, carnival, underwater. A hazard-free fun block.
- **Intro and teach.** meadow_08. First pad sits in the preview strip with an arrow showing the bounce path. Hint 12 words or fewer: "Pads bounce! Plan where the piece lands."
- **Fairness.** Risk: a bounce flings a piece into a gap. Counterplay: the landing marker shows the bounce end (a ghost at the hop end), and it is capped at 4 cells.
- **Engine.** EXISTS for pieces (`src/mechanics/behaviour/bounce_pad.gd`). The lamb being flung is NEW (gap G10, `levels.md:551`, 3 days, gameplay-programmer). Ghost preview of the hop end: NEW, 1 day, ui-programmer.
- **Source.** Springs and trampolines in `party_modes_ref.jpg` (Wonky Builders spring base) and `party_minigames_ref.jpg` (Wobble Builders spring).

**BK-06 snowball (kind 8, glyph `n`)**
- **What.** A rolling ball of snow that rolls down a slope across your stack and grows.
- **Rule.** Trigger: every `roll_locks` (2) locks, each ball rolls one cell in `slope_dir` (default `-x`) (`snowball.gd:34-35,45-79`). One lock before it moves, a warning plays (`:46`). The ball stays a short column of up to `snow_max` (3, clamped 1 to 4) cubes and grows by one cube each roll while free above (`:76-78`). If the next step is off the footprint, blocked, or changes height by more than 1, the ball parks (`:63-68`). A parked ball is inert. At `respawn_locks` (8) it respawns at the high end (`:80`). Clearing a ball cube emits `snowball_puff`. Fill: `fills_layer` true. Gravity: climbs or falls at most 1 per step. Other specials: stops on ice? (see matrix; ice_slide is only for landing pieces). Rescue: wiped. Top-out: growth needs a free cell above.
- **Look.** White ball with a blue shadow, trailing snow puffs, a small arrow floor-decal in `slope_dir`. Skins: ice white, candy meringue, cave boulder, lava ash-ball, desert tumbleweed.
- **Audio.** Proposed `SFX_SP_SNOWBALL_ROLL` (AUDIO-NEW) and `SFX_SP_SNOWBALL_PUFF`.
- **Fits.** Ice biome (levels not yet in the first 12), mountains, carnival (rolling barrel skin).
- **Intro and teach.** Early ice level. The warning arrow is the teacher: "A snowball rolls this way next."
- **Fairness.** Risk: it rolls into a gap you were saving. Counterplay: the arrow and the lock warning; building a wall parks it.
- **Engine.** EXISTS (`src/mechanics/behaviour/snowball.gd`). No gap.
- **Source.** Ice and snow boards in the minigame mockups (checked in Appendix A) and the ice block in `biome_block_materials_ref.png`.

**BK-07 goo (kind 9, glyph `g`)**
- **What.** Naughty sticky goo that spreads to a neighbouring cell after a quiet lock. A clear cancels the next spread.
- **Rule.** Trigger: each resolve end. If the last resolve had a clear and `cancel_on_clear` is true (default), no spread this lock (`goo_spread.gd:15-18`). Otherwise each goo chooses a free face neighbour (6 directions) below the limit layer, and `per_lock` (default 1) new goo cells appear, picked with the rule's own random stream (`:23-33`). Fill: `fills_layer` true, so goo can fill a layer cell and count for a clear (`blocks.json:83-92`). Gravity: goo cells are placed on any free neighbour, including mid-air (see Edge Cases: unsupported goo). Other specials: sticky landing is a twist; goo as a kind does not slow pieces today. Rescue: wiped. Top-out: spread is limited by `api.limit_layer()`.
- **Look.** Glossy green or pink blob with a drip, bubbles rising, a wobble animation; the warning lock puffs a small drip on the target cell. Skins: candy syrup, underwater slime, forest sap, lava tar, neon slime-glow.
- **Audio.** `SFX_PL_STICKY_SPLAT` exists for sticky landing (`sfx-cue-list.md:96`); goo spread proposal `SFX_SP_GOO_SPREAD` (AUDIO-NEW).
- **Fits.** Candy (frosting level), forest, underwater.
- **Intro and teach.** After the player knows clears. "A clear stops the goo." is the hint.
- **Fairness.** Risk: runaway spread (positive feedback). Counterplay: every clear cancels one spread, and a cap is proposed (`goo_max`, section 7) because the rule has no cap today.
- **Engine.** EXISTS (`src/mechanics/behaviour/goo_spread.gd`). Gap: no `goo_max` cap, 0.25 day, gameplay-programmer, and a spread warning (marked cell one lock ahead) 0.5 day.
- **Source.** Own idea; the candy board `party_modes_ref.jpg` (Candy Clash) for candy skin.

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
- **Engine.** EXISTS (`gumdrop_hail.gd`). Sticky status is NEW only if design wants it (0.5 day). Open question 5.
- **Source.** The candy block (frosted cube with a heart) in `biome_block_materials_ref.png`; sweet props in the candy board of `party_modes_ref.jpg` and the cake and jelly pieces in `mockup_05.jpg` and `mockup_08.jpg`.

**BK-10 icing_dollop (kind 20, glyph `D`) and BK-11 frosting (kind 12, glyph `2`) / frosting_three (kind 13, glyph `3`)**
- **What.** A dollop of icing that hardens into frosting. Frosting is a block with 2 (or 3) coats. You must clear next to it several times to peel it.
- **Rule.** Frosting at level start gets `frosting_layers` 2 (kind `frosting`) or 3 (kind `frosting_three`) and `clear_protected` true (`frosting.gd:8-10`). Trigger: any clear removing a cell face-adjacent to it (`on_clear`, `:13-22`). Effect: it peels one coat, at most once per resolve (`_peeled`, `:17-18`). At zero coats it is removed as damage (`:20`). Icing dollop (kind 20) is hailed instead of a gumdrop when `object: icing_dollop`; once the bake goal's `baked` counter is above 0, new hail becomes frosting with 2 coats, and a clear while marked cancels the hail (`gumdrop_hail.gd:19-30`). `tier_frosting` (`src/mechanics/candy/tier_frosting.gd`) adds tier rows. Fill: `fills_layer` true, but `clear_protected` means its layer cannot clear it directly: the layer clears around it and the frosting waits until peeled (like a rock in `obstacles.md`). Gravity: normal. Rescue: wiped with the plane. Top-out: counts as height.
- **Look.** Thick white-pink icing cap with swirls. 2-coat shows one swirl ring, 3-coat shows two. A coat peels with a visible flake each time. Skins: candy; ice rime-cap; lava ash-crust; forest moss-cap; neon shield-plate.
- **Audio.** Proposed `SFX_SP_FROSTING_PEEL` (AUDIO-NEW).
- **Fits.** Candy bake levels (`bake_stage`, `bake_oven_goal`), ice (rime).
- **Intro and teach.** Candy tier 2. "Clear next to it to peel the icing."
- **Fairness.** Risk: a layer that never clears. Counterplay: hits are by adjacency, so any neighbouring clear works, and the coat count is visible.
- **Engine.** EXISTS (`frosting.gd`, `gumdrop_hail.gd`, `tier_frosting.gd`). No gap.
- **Source.** Frosted candy block in `biome_block_materials_ref.png`; cake pieces in `mockup_05.jpg` and `mockup_08.jpg` (Cake Stackers, Sugar Rush Stack).

**BK-12 sponge (kind 14, glyph `s`)**
- **What.** A soft cake sponge that cannot be cleared away by a normal layer clear. It is a protected cell.
- **Rule.** At level start it is protected via `CandyCells.protect` (`frosting.gd:11`, `climber_boss.gd:25`). Effect: `clear_protected`, so a full layer clears around it. Fill: `fills_layer` true. It is the supporting stage under the climber boss. Gravity, rescue, top-out: as any cube. `ART-CHECK` exact `protect` flags in `candy_cells.gd`.
- **Look.** Yellow cake crumb texture with holes; no icing. Distinct from frosting by the missing cap.
- **Audio.** Normal land. Proposed `SFX_SP_SPONGE_SQUISH` (AUDIO-NEW).
- **Fits.** Candy.
- **Intro and teach.** Candy boss (candy_10) and bake levels.
- **Fairness.** Same as frosting. Counterplay: the layer clear leaves it behind visibly.
- **Engine.** EXISTS.
- **Source.** Cake bases in the cake boards.

**BK-13 licorice (kind 15, glyph `l`)**
- **What.** A black-and-white licorice knot anchored to the board. It unties into a normal cube when a neighbour clears.
- **Rule.** Level start: anchored and `clear_protected` (`licorice_lock.gd:5-9`). Trigger: a clear removes a face-neighbour (`:11-15`). Effect: the licorice is removed and replaced by a `starter` cube, with `licorice_untied`. Fill: `fills_layer` true. Anchored means it does not move in slice shifts. Gravity: fixed. Rescue and top-out: as any cube; anchored cells can be wiped by a rescue like others (confirm in `rescue_top_out.gd`; `ART-CHECK`).
- **Look.** Black spiral knot with a white ribbon, small lock icon badge.
- **Audio.** Proposed `SFX_SP_LICORICE_UNTIE`.
- **Fits.** Candy.
- **Intro and teach.** Candy tier 2 or 3.
- **Fairness.** It holds a fixed spot. Counterplay: clear next to it.
- **Engine.** EXISTS (`licorice_lock.gd`).
- **Source.** None.

**BK-14 moody (kind 16, glyph `y`)**
- **What.** A grumpy gummy cube. It sulks until a neighbour shares its flavour. While it sulks it will not fill a layer.
- **Rule.** One tagged Mono per bag becomes a moody cube at spawn (`moody_cube.gd:5-9`) and on lock keeps the piece's colour (`:10-17`). Each resolve it checks six face neighbours for the same flavour (`:19-27`): happy means `fills_layer` true; grumpy means `fills_layer` false and `clear_protected` true. Emits `gummy_mood`. Gravity: normal. Other specials: a rainbow cube neighbour counts as a match (design intent; `ART-CHECK`). Rescue: wiped. Top-out: height.
- **Look.** A gummy cube with a face: sad brows and flat mouth when grumpy, smile when happy. The face must read at 28 px: big eyes, bold brows.
- **Audio.** Proposed `SFX_SP_MOODY_GRUMBLE` and `SFX_SP_MOODY_HAPPY`.
- **Fits.** Candy (colour-connect levels), carnival.
- **Intro and teach.** Candy tier 2. "Put a matching colour beside it."
- **Fairness.** Risk: a lone grumpy cube blocks the whole layer. Counterplay: place a matching flavour next to it; the hint arrow points to a matching cell.
- **Engine.** EXISTS (`moody_cube.gd`). Hint arrow NEW, 1 day, gameplay-programmer plus ui-programmer.
- **Source.** Faces on blocks are a party-board motif (`party_modes_ref.jpg`).

**BK-15 candy_bomb (kind 17, glyph `a`)**
- **What.** A bomb cube earned by clearing a big connected group of one flavour. It blows up a 3x3x3 area when it is cleared.
- **Rule.** Earn: after a resolve, a connected same-flavour cleared group of at least `bomb_at` (7; 0 turns it off) leaves one bomb on a free cell of that group nearest the last lock (`earned_specials.gd:23-39`). `rocket_at` and `colour_bomb_at` are schema-limited to 0 (`earned_specials.json`). Trigger: the bomb cell is cleared like any cube (`:11-12`). Effect: every non-empty cell within the 3x3x3 cube around it is removed as damage, except cells with `anchored` true (`:14-19`). It is not a layer clear itself, but removed cells can open follow-up clears. Fill: `fills_layer` true. Gravity: after the blast, collapse follows the level's collapse rule. Other specials: frosting is hit by blast damage at once (`anchored` is the only shield; frosting is `clear_protected`, not anchored, so it is removed: `ART-CHECK` whether damage respects `clear_protected`); locked cubes unlock only by adjacent clears, not by blast. Rescue: wiped. Top-out: the bomb can end the pressure by deleting 27 cells.
- **Look.** Glossy round cherry-bomb with a lit fuse and a gold spark; a pulsing orange rim (hazard-reward). Skins: candy cherry bomb, lava ember-bomb, ice crystal-bomb, clockwork dynamite-gear, celestial star-nova, pirate powder keg.
- **Audio.** Proposed `SFX_SP_BOMB_BLAST` (AUDIO-NEW); reuse `Hollywood/Wooden Crate Destruction.wav` as a stand-in (cue list uses it for sail-off).
- **Fits.** Candy; any biome as a reward block. Cave (rock-breaker), pirate.
- **Intro and teach.** Candy. First earn is shown in slow motion with a callout: "Big clears make a bomb."
- **Fairness.** Risk: the blast deletes a goal object or critter. Counterplay: critters and keys are `anchored` or protected (rule: protected objects have the `anchored` status).
- **Engine.** EXISTS (`earned_specials.gd`). Gap: protect objects explicitly (0.5 day) and blast preview outline (1 day, ui-programmer).
- **Source.** Bomb ideas: cannon blasts and explosions across the party boards (`mockup_02.jpg` Fort Blast, `mockup_03.jpg` Shatter Shootout).

**BK-16 countdown_bomb (kind 18, glyph `q`)**
- **What.** A thrown bomb with a number on it. When it hits zero it adds a junk layer. A clear beside it defuses it.
- **Rule.** Trigger: every `thrown_every_locks` (8) a bomb appears on a random surface cell with `cd_start` (8) (`countdown_bomb.gd:22-25`). Each lock it counts down 1; at 0 it is removed, `request_junk_layers(blast_layers)` (default 1) pushes junk up from below, and `countdown_blast` plays (`:17-21`). A clear on or face-adjacent to it defuses and removes it (`:9-15`). Fill: `fills_layer` true. Gravity: it sits on a surface cell. Rescue: if the plane is wiped, the bomb goes with it. Top-out: a junk layer pushes the stack up by one and may cause a top-out warning (`obstacles.md` rule 8).
- **Look.** Dark round bomb with a big white countdown digit on the top face and a lit fuse that shortens. Numbers 3 and below turn red and shake. Skins: candy gum-bomb, pirate powder keg, clockwork alarm-clock, neon timer-cube.
- **Audio.** Proposed `SFX_SP_BOMB_TICK` (a soft tick per count), `SFX_SP_BOMB_DEFUSE`.
- **Fits.** Candy, pirate, clockwork. Versus mode (thrown by a rival). 
- **Intro and teach.** After blocks and clears are known. Hint: "Clear next to it before zero."
- **Fairness.** Risk: a bomb lands in an unreachable spot. Counterplay: 8 locks is long; a bomb never spawns where `surface` has under 2 free neighbours (proposed constraint, 0.25 day).
- **Engine.** EXISTS (`countdown_bomb.gd`). View digit: gap, 1 day, technical-artist.
- **Source.** Timer bombs and cannons in the party mockups.

**BK-17 climber_boss (kind 19, glyph `B`)**
- **What.** A 2x2 gummy boss that climbs your terraces. Clears next to it bonk it down a step.
- **Rule.** Spawn: on the first valid terrace (the highest legal 2x2 spot, ties by x then z) after the `bake_oven` goal's `baked` counter is above 0 (`climber_boss.gd:34-43`). Each resolve it moves to the highest reachable adjacent 2x2 spot, one terrace step of height at most 1 per move (`:53-59`). Trigger: a clear next to any of its 4 cells sets a bonk (`:27-32`); next resolve it drops to a lower neighbour at least `bonk_drop_cells` (1) down (`:44-52`), adds a `bonks` goal counter and emits `boss_bonk`. If no lower spot exists, `bonk_blocked`. It is `anchored` and `clear_protected`. Fill: it counts as 4 filled cells. Rescue: wiped with its plane. Top-out: it can climb above the line (a loss if it stays there is a design choice, see Open Questions). `ART-CHECK`.
- **Look.** A big smug gummy bear with a crown, 2x2 footprint, bounces a little each climb. Shield-rim gold, health bar over its head with bonk pips.
- **Audio.** `SFX_BOSS_FLOUR_BONK` exists as a GAP in the Meadow list (`sfx-cue-list.md:108`); candy needs `SFX_BOSS_GUMMY_BONK` (AUDIO-NEW).
- **Fits.** Candy boss (candy_10). The `bonk_boss` goal is the identity-spec boss pattern.
- **Intro and teach.** The Chapter boss only. The previous levels teach "clear next to it".
- **Fairness.** Risk: no lower spot, no progress. Counterplay: `bonk_blocked` message, and a terrace is always reachable by design.
- **Engine.** EXISTS (`climber_boss.gd`, goal `bonk_boss_goal.gd`). Boss phase hand-over: gap G13 (`levels.md:554`).
- **Source.** The big octopus and golem bosses in `mockup_02.jpg`, `mockup_04.jpg`, `mockup_07.jpg` (a boss that acts on the board).

#### 3.2.b Special BLOCK KINDS, part 3: cave, lava, forest, underwater

**BK-18 rock (kind 21, glyph `R`)**
- **What.** A solid rock that is part of the level. It does not count toward full layers. Some rocks take two hits.
- **Rule.** Permanent: `fixed`, `static_geometry`, `anchored`, `clear_protected`, `fills_layer` false (`rock_obstacle.gd:18-21`; `blocks.json:203-212` has `fills_layer: false`). Rocks placed by `params.cells` at level start (`:12-17`). `lava_rock_spawn` can also pop a rock: it warns one lock ahead (`geyser_warning`), then creates a 2-hit rock with `hits_left` (`hard_hits`, default 2, range 1 to 8) (`lava_rock_spawn.gd:23-38`); adjacent clears hit it (`_hit_adjacent`). Because it is excluded from the layer denominator, the layer clears around it. Gravity: never moves. Rescue: `ART-CHECK` whether a rescue wipes fixed rocks (it should not). Top-out: `static_geometry` adds no stack height (levels.md note about masked cells).
- **Look.** Grey boulder, mossy in meadow, cracked in lava (shows hits left with cracks), crystal-flecked in cave. Square footprint but rounded outline.
- **Audio.** Proposed `SFX_SP_ROCK_CRACK` (AUDIO-NEW).
- **Fits.** Lava, cave, forest, meadow stone cage (the `shelf` and masked columns of meadow_01), any biome.
- **Intro and teach.** Early; "rocks do not need filling."
- **Fairness.** Rocks cannot be moved. They must not fully block spawn rows (validator).
- **Engine.** EXISTS (`rock_obstacle.gd`, `lava_rock_spawn.gd`).
- **Source.** Rocks in `mockup_01.jpg` (Avalanche Ascent) and the volcanic sheet props (cooled stone, obsidian spur).

**BK-19 mole (kind 22, glyph `o`)**
- **What.** A buried mole you rescue by clearing the layer it sits in.
- **Rule.** `dig_rescue` goal: a mole is rescued only when its layer clears; damage and trims do not rescue it (`dig_rescue_goal.gd:2,8-10`). Emits `critter_rescued {kind: mole}`. Fill: `fills_layer` true. Gravity: normal; it sinks with slice shifts. Rescue wipe: a mole wiped by soft rescue is lost (counts as not rescued, level can still be won if the goal allows; see Edge Cases). `ART-CHECK`.
- **Look.** A round brown mole with pink nose and tiny goggles, peeking from a dirt cube. Skins: cave, meadow, forest.
- **Audio.** Proposed `SFX_SP_MOLE_SQUEAK` and `SFX_SP_MOLE_FREE`.
- **Fits.** Cave dig-rescue levels (`cave_h3.json` mentions mole).
- **Intro and teach.** Cave. Mole faces peek, a "help" bubble.
- **Fairness.** A rescue wipe can destroy the goal. Counterplay: the soft rescue protects critters (proposal in Edge Cases).
- **Engine.** EXISTS in the goal; view `src/view/wt_toy_actor.gd` mentions mole.
- **Source.** The digger and mine boards (`mockup_01.jpg` Rubble Rumble, `mockup_04.jpg` Digging Frenzy).

**BK-20 locked_cube (kind 23, glyph `k`)**
- **What.** A cube in a padlock. A clear next to it unlocks it so it can be cleared.
- **Rule.** At level start every locked cube gets `locked` true (`locked_cube.gd:11-18`). Trigger: a cell face-adjacent to a clear (`on_clear`, `:22-31`). Effect: `locked` false and `cube_unlocked`, once per resolve. Cubes that are `anchored` or `fixed` are skipped. Fill: `fills_layer` true. Gravity: normal. Other specials: the key cube (BK-24) is the planned stronger opener (see there). Rescue: wiped. Top-out: height.
- **Look.** A cube with a brass padlock on every face; the padlock opens with a click and drops off when unlocked. Rim: blue while locked, none when open.
- **Audio.** Proposed `SFX_SP_LOCK_CLICK`, `SFX_SP_LOCK_OPEN`.
- **Fits.** Lava (`lava/locked_cube.gd` lives in the lava folder), cave, pirate, clockwork.
- **Intro and teach.** Early lava. "Clear next to it to open it."
- **Fairness.** A locked cube blocks its layer until opened; always reachable by an adjacent clear.
- **Engine.** EXISTS (`src/mechanics/lava/locked_cube.gd`).
- **Source.** Chest and key in `mockup_02.jpg` Maze Heist and the treasure chests in `mockup_03.jpg`, `mockup_10.jpg`.

**BK-21 shelf (kind 24, glyph `H`)**
- **What.** A fixed ledge deck that holds a chamber under it and an opening above. It never moves and never counts toward a layer.
- **Rule.** `fixed`, `static_geometry`, `anchored`, `clear_protected`, `fills_layer` false, `shelf` true (`anchored_shelf.gd:18-21`; `blocks.json:233-242`). Placed by `params.cells` at level start. Gravity: fixed. Other specials: pieces rest on it; cells under it are protected pockets (hail avoids them with `avoid_start_holes`). Rescue and top-out: no height added.
- **Look.** A wooden plank or stone slab with brackets, visibly nailed to the wall.
- **Audio.** Normal land.
- **Fits.** Forest (branch ledge), meadow scaffold (meadow_07), clockwork.
- **Intro and teach.** Not taught. Looks like a platform.
- **Fairness.** It can trap holes. The validator checks reachability.
- **Engine.** EXISTS (`src/mechanics/forest/anchored_shelf.gd`).
- **Source.** Scaffolds and ledges in `style/09_minigames_a.jpg` and the party hill boards.

**BK-22 vine and BK-23 status shells (frozen, honey, burning, crumbling, shadow, spiked)**
- **What.** Seven status shells that sit on one cube. A cube holds at most one (`block-status-effects.md` Core Rule 1).
- **Rule (all).** Table, from `block-status-effects.md`: frozen (+1 hit point, thaws when its layer takes layer damage or a neighbouring layer clears), vines (+1 hp; every `vine_every_locks` 4 locks spreads to one neighbour), honey (a piece resting on it locks at once), burning (removed after `burn_locks` 3; neighbours catch fire with `burn_spread_p` 0.3), crumbling (removed `crumble_locks` 2 locks after something lands on it), shadow (drawn at invisible alpha), spiked (first landing is pushed up 1 cell, spike breaks). Priority: a new status replaces the old unless the old one's rule ranks higher. Fill: all keep the cell's own `fills_layer`. Rescue: wiped.
- **Engine status per shell (important, this is a design-doc-only area).**
  - Vines: PARTIAL. The forest `vines` rule (`src/mechanics/forest/vines.gd:12-40`) selects `vine_per_bag` (default 1, 0 to 2) pieces per bag, marks them `vined`, and protects direct neighbours with `status.vined`. The "spreads every 4 locks" part of the GDD is not in that file. Gap: spread, 1.5 days, gameplay-programmer.
  - Burning: PARTIAL. `ember` rule (`src/mechanics/behaviour/ember.gd`) drills below tagged pieces; the burn-out and fire spread of the GDD are NEW (2 days).
  - Frozen: NEW as a status (thin_ice and ice_slide cover related ideas, see BK-26, BK-27). 1.5 days.
  - Honey: NEW as a cell status. `sticky_landing` is the twist version (README line 38). 1 day.
  - Crumbling: PARTIAL. `crumble_tiles` (wave 3) cracks floor tiles, not cubes (`src/mechanics/wave3/crumble_tiles.gd`). Cube status NEW, 1 day.
  - Shadow: PARTIAL. `fog` hides by time (`src/mechanics/behaviour/fog.gd`), not a per-cube status. NEW, 0.5 day.
  - Spiked: NEW, 1 day.
  - Owner for all: gameplay-programmer (rule), technical-artist (shells).
- **Look.** Frost crust with a snowflake badge; green vine wrap with leaf badge; amber gloss drips with drop badge; ember glow and flame badge; cracked ridges and dust badge; dim translucent with an eye-slash badge; spikes with a spike badge. Each also has an animation (pulse, wobble, flicker) and a rim pulse, per the look rule (`block-status-effects.md:87`).
- **Audio.** The GDD lists `freeze`, `thaw`, `vine_grow`, `honey_stick`, `ignite`, `burn_out`, `crumble`, `spike_bounce`. Map to `SFX_SP_*` and mark AUDIO-NEW.
- **Fits.** Frozen: ice. Vines: forest. Honey: candy, meadow. Burning: lava, clockwork. Crumbling: cave, desert. Shadow: celestial, neon, fog levels. Spiked: carnival, pirate.
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
- **Rule.** Trigger: on lock. Effect: for each cube with nothing under it in the piece, remove cells below to depth `drill_depth` (default 1, clamp 1 to 3) as damage (`ember.gd:21-28`), then `request_settle` so the stack above falls (`:29`). Emits `ember_melt`. Fill: normal. Gravity: settle collapse follows. Other specials: it removes any kind including frosting and keys? It does `remove_cell` on any non-empty target (`:26-28`); anchored shelves and rocks should be skipped: `ART-CHECK`. Rescue and top-out: the melt can lower height, which is helpful.
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

#### 3.2.b (continues below as more entries are added)

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

More boards are added to this list as they are opened (see the work log).

## Appendix B. Open questions

TODO
