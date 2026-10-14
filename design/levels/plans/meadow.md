# Meadow plan: Pip's Picnic

> Layer 1 (Play, Progression role) by level design, 2026-10-14. Sources: `src/levels/meadow/*/*.json` (the source of truth for numbers), `assets/data/campaign/catalog.json`, `design/levels/meadow.md`, `design/levels/mockup-alignment.md`, `design/levels/minigame-stages.md`, `assets/data/rules/*.json`, `assets/data/modules/*.json`.
> Star times are shown in seconds (the JSON stores ms). Every "Proposed change" is a proposal for the user and the game-designer. No JSON has been edited.

## Biome intro

**Theme.** A sunny hillside picnic. Blocks fall as a soft drizzle. Pip the harvest mouse is the helper for tiers 1–3 and a watcher after that. The Miller, a badger, causes every disturbance from his mill and is the boss in 10. This is the most classic biome: plain layer clears are home base, and each level adds at most one visible disturbance.

**Mechanics the Meadow introduces** (the 4 the rest of the campaign assumes the player knows):
1. **Layer clears with 3D rotation**: spin only in 01, then the full spin/tilt/roll set in 02 through the starter-layer "pockets".
2. **Weather that moves your piece**: `gust` (Dandelion Gust), which pushes the falling piece one cell on a telegraphed timer.
3. **The board changes itself**: `mushroom_popup`, `sprouts`, `hatching_eggs` (living blocks that fill cells for you or against you).
4. **The stack transforms**: `fog` (memory), `topsy_tumble` (the stack turns over), `mill_belt` (the floor slides). These are the first rule-twists and the base for every later biome.

It also introduces three of the six level types outside clearing: **height race** (05), **fill-shape picture** (06) and **survive/defender** (08).

### Curve table (as authored in JSON)

| id | tier | type | goal | g0 | stars ★★ / ★★★ |
|---|---|---|---|---|---|
| meadow_01 | 1 | funny | clear_n 2 | 0.60 | 290 / 210 s |
| meadow_02 | 2 | balance | clear_n 3 (2 starter layers) | 0.60 | 230 / 160 s |
| meadow_03 | 3 | balance | clear_n 4 | 0.70 | 585 / 410 s |
| meadow_04 | 4 | twist | clear_n 3 (ring mask) | 0.75 | 355 / 250 s |
| meadow_05 | 5 | race | height 10 (coverage 0.6) | 0.80 | 240 / 170 s |
| meadow_06 | 6 | completing | shape, 50 cells | 0.70 | 155 / 110 s |
| meadow_07 | 7 | twist | clear_n 4 (2 starter layers) | 0.85 | 345 / 250 s |
| meadow_08 | 8 | defender | survive 150 s | 0.90 (+0.15/min) | 1 / 2 layers |
| meadow_09 | 9 | balance | clear_n 4 | 0.95 | 580 / 410 s |
| meadow_10 | 10 | twist (boss) | clear_n 3 | 1.00 | 420 / 300 s |
| meadow_bonus | 11 | completing | shape 32 cells, 6 pieces, 60 s | 0.50 | 45 / 30 s |
| meadow_h1 | 12 | twist | clear_n 4 | 0.95 | 535 / 375 s |
| meadow_h2 | 13 | funny | clear_n 4 | 1.00 | 535 / 375 s |
| meadow_h3 | 14 | funny | clear_n 4 (2 starter layers) | 1.00 | 320 / 220 s |

### What the curve gets right, and what it gets wrong

- **Right:** speed rises in a clean sawtooth (0.6 → 1.0, with the 06 dip as a rest). Each mechanic is taught on its own before it is combined: gust 03 → 10 and h1; mushrooms 04 → h2; flip 09 → 10 and h2; fog 07 → h3. All six level types are present.
- **Wrong 1, goal monotony:** 9 of 14 levels are `clear_n`, and the whole hard track is "clear 4". There is no goal variety after tier 9.
- **Wrong 2, length spikes:** 03 (585 s ★★) and 09 (580 s ★★) are about 10-minute levels. The 8x8 amendment raised them by ×1.6–1.8, and they now sit next to 2–4 minute levels. Tier 3 should not be the second-longest level in the biome.
- **Wrong 3, stars not rescaled:** 05 Tall Tower went from 5x5 to 8x8 (2.56× the cells per layer) and kept its 240 / 170 s stars. As authored, ★★ is out of reach.
- **Wrong 4, no minigame blocks:** no meadow level uses a module, although `bridge_dash` (Bridge Bashers) is the only module with a data file, and its first skin is the meadow.
- **Wrong 5, hardcoded sequence:** `meadow_bonus` uses `pieces.fixed_list`, which breaks the standing rule "the next block is random on every attempt".
- **Wrong 6, the boss has no face:** `meadow_10` is "clear 3 with three rules". The Miller never takes a hit you can see, while `candy_10` already uses a `bonk_boss` stage.

**Proposed biome arc after the changes:** teach (01–02) → twist (03 bridge, 04 mushrooms) → rest/build (05 tower, 06 picture) → memory and pressure (07 fog, 08 dew defence) → combine (09 flip + eggs) → **pay off with a boss that has HP** (10) → puzzle bonus → three hard remixes with **three different goals**.

---

### meadow_01: First Sprout  (tier 1, funny)

**Play** (layer 1)
- Goal: `clear_n` 2 (rescue top-out, 2 warnings).
- How it plays: Pieces from a small pool (I, O, T, L, S) drift down slowly at g0 0.6, and only spin rotation is enabled, so every decision is "where" and never "which axis". The first two pieces are from {O, I}, so the first lock is always flat and easy to read. One piece per bag hangs from a balloon: it falls at 0.7× speed and floats for up to 4 s, which gives the player extra aiming time. The only pressure is filling a 64-cell layer without leaving covered holes.
- Teaches / tests: "Fill a whole layer and it clears."
- Rules and minigame blocks: `balloon` {balloon_per_bag 1, balloon_g_mult 0.7, balloon_drift_ms 4000}. No module.
- Board: 8x8, h_play 8, empty floor. Per-attempt variation comes from the random bag only (the opening is drawn at random from {O, I}).
- Difficulty: g0 0.6; ★★ 290 s, ★★★ 210 s. The floor of the biome curve.
- Proposed changes: (1) Do not let the balloon piece be one of the 2-piece opening: add `balloon.start_after_locks: 3` (NEW param) so the first lock teaches the plain drop, and the balloon arrives as a "surprise gift" on lock 4 or later. (2) Add `knobs.control.ghost_preview: "strong"` for this level only, because the 8x8 floor is large and the landing ghost is the main reading tool.

**Progression role** (layer 1): The first level of the campaign, unless the proposed Wizard's Practice Island (mockup-alignment §2.1) ships before it. It teaches the base verb with one gentle, helpful oddity, so the game reads as "wacky" from the first minute. It hands off to 02, which adds 3D rotation.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_02: Tilt & Roll  (tier 2, balance)

**Play** (layer 1)
- Goal: `clear_n` 3 (rescue, 1 warning).
- How it plays: The board starts with two starter layers that have pockets shaped exactly for the Tripod and the two Screws, and the first three pieces are one of each in random order. The player has to tilt and roll the piece so it drops cleanly into its pocket, and a correct fit clears both starter layers together. A gentle `wobble` meter (max 10) grows when overhangs are made, so a sloppy fit makes the stack creak before it slips. Pip's catch undoes one bad lock per level (one that leaves a new covered hole and clears nothing).
- Teaches / tests: The 3D rotation axes, and the first idea that overhangs are dangerous.
- Rules and minigame blocks: `mascot_catch` {catches 1}; `wobble` {wobble_max 10}. No module.
- Board: 8x8 (the 6x6 design inset by 1 cell), h_play 10, 2 starter layers with 3 pockets. The opening is a random order of {Tripod, Screw-L, Screw-R}, and pieces after that are random from 8 shapes. No layout variation.
- Difficulty: g0 0.6; ★★ 230 s, ★★★ 160 s. Flat with 01: a new skill at the same speed.
- Proposed changes: (1) Add a `variation` block (symmetries: mirror_x, mirror_z, rot180) so the pockets are not always in the same corner. The puzzle stays isomorphic, and the board is not memorised on retry. (2) The ring of empty cells around the inset 6x6 starter (row 0, row 7, columns 0 and 7) means the "double clear" needs about 28 more cells per layer than the design. Check that a double clear is still reachable in about 4–6 pieces; if not, fill the outer ring in both starter layers except for 2 gap cells per layer.

**Progression role** (layer 1): The second teaching level. It turns the 5-shape spin-only game of 01 into the full 8-shape, 3-axis game that the rest of the campaign uses. Wobble at a forgiving value here pre-teaches the tower physics that 05 tests. It hands off to 03, the first rule that acts on the piece.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_03: Breezy Hill  (tier 3, balance)

**Play** (layer 1)
- Goal: `clear_n` 4 (rescue, 1 warning). **Proposed: `bridge_dash` span goal** (see below).
- How it plays (as authored): Every 8 s ± 2 s the grass bends for 1 s, and then a +x gust shoves the falling piece one cell toward the x = 7 wall. The player learns to build from the downhill wall so gusts push pieces home. One piece per bag is a dandelion puff that splits into two halves on landing, and the halves tumble into gaps. Pip catches one bad lock.
- Teaches / tests: Gust: "the weather moves your piece; build with it, not against it."
- Rules and minigame blocks: `gust` {+x, fixed, 8000 ms ± 2000, strength 1, warn 1000}; `dandelion_puff` (1 per bag); `mascot_catch` {1}. No module.
- Board: 8x8, h_play 10, empty. Random bag only.
- Difficulty: g0 0.7; ★★ 585 s, ★★★ 410 s. **A length spike**: about 10 minutes at tier 3, the second-longest level in the biome.
- Proposed changes: **Rebuild 03 as the Meadow's first minigame block, Bridge Bashers** (`bridge_dash`, meadow skin) with the `gust_wind` overlay. Moment to moment: two hill banks with a brook between them. Pieces drop into the gap to build a deck, and when the path holds for `hold_ms` Pip walks across to fetch the blown seeds. The gust still pushes pieces along +x, now *across* the gap, so the lesson becomes "aim upwind of the gap". JSON: `modules: [{ "id": "bridge_dash", "params": { "gap_cells": 4, "pillar_cells": 2, "pillar_height": 2, "step_max": 1, "hold_ms": 500 }, "overlays": [{ "id": "gust_wind", "params": { "wind_dir": "+x", "wind_interval_ms": 8000, "wind_jitter_ms": 2000, "wind_warn_ms": 1000 } }] }]`; keep `mascot_catch` 1; move `dandelion_puff` to `meadow_h1` (see there); type `race`; stars from the bridge race (target ★★ about 150 s, ★★★ about 105 s, to be set by playtest). This fixes the 10-minute spike, gives the biome a minigame block on the critical path, and keeps the gust lesson. Flag: mockup-alignment binds Bridge Bashers to slot 05, but 05 is the ★PROTO wobble tower and the biome's no-fail break, so 03 is the better host. **Depends on** the module framework (mockup-alignment §5 step 1). Fallback if modules are not ready: keep the authored level, but with `clear_n` 4 → 3 and stars ×0.75 (about 440 / 310 s).

**Progression role** (layer 1): The first rule that acts on the falling piece. As a bridge race, it is also the first appearance of a minigame module (solo, gentle, as campaign rule 12 requires), and that is what the tournament's Bridge Builders round unlocks from later. It comes before 04, where the board itself starts changing.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_04: Mushroom Ring  (tier 4, twist)

**Play** (layer 1)
- Goal: `clear_n` 3 (rescue, 1 warning).
- How it plays: The island is a ring: the centre 3x3 (the pond) is masked off, so every layer is a band around the pond, and pieces must bridge corners without falling into the hole. Every 5 locks a sparkle marks a free top-surface cell, and one lock later a mushroom pops up there (max 4 on the board) and fills that cell. The player plans by leaving a 1-cell gap where the sparkle is, so the mushroom completes the layer instead of blocking it.
- Teaches / tests: The board changes on its own, and a telegraphed change can be used.
- Rules and minigame blocks: `mushroom_popup` {spawn_every_locks 5, objects_max 4}. No module.
- Board: 8x8 with a mask (centre 3x3 off at x 2–4, z 2–4; the extra 8th row and column added by the amendment make the ring off-centre), h_play 10, spawn_anchor (3, 5). Mushroom cells come from the rule's random stream on each attempt.
- Difficulty: g0 0.75; ★★ 355 s, ★★★ 250 s. A medium bump after 03.
- Proposed changes: (1) The 7x7 → 8x8 amendment made the ring lopsided: the band is 2 wide on the left and top and 3 wide on the right and bottom. Re-centre it: mask rows 2–5, columns 2–5 off (a 4x4 pond), giving a symmetric 2-wide band of 48 cells, and set spawn_anchor to (3, 6). (2) Add a `variation` block (mirror_x, mirror_z) for the spawn side.

**Progression role** (layer 1): The first "living board" level, after 03's moving-piece lesson. It also teaches the first non-rectangular footprint, which later biomes (Candy's cake masks, Ice floes) rely on. The mushroom comes back in `meadow_h2`. After it comes the rest pair 05–06.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_05: Tall Tower  (tier 5, race)

**Play** (layer 1)
- Goal: `height` 10 with `goal.height_coverage` 0.6 (layer 9 must be at least 60% full). Top-out is trim, so the level cannot be failed.
- How it plays: Nothing clears. Full layers glow and stay, and the height meter climbs toward the sign. Overhangs feed the wobble meter (max 6). When it fills, the last piece slips one cell toward the heavy side, and it pops off if that takes it off the island. Big Cubes (weight 0.5) add two layers of a 2x2 column at once, which is fast but makes overhangs easy. The tension is speed against stability: race up, but keep the tower square.
- Teaches / tests: Building up instead of clearing, and the wobble meter at full strength.
- Rules and minigame blocks: `build_race` {topout_rule trim}; `wobble` {wobble_max 6}. No module.
- Board: 8x8, h_play 12, empty. 8 standard shapes + Big Cube. Random bag only.
- Difficulty: g0 0.8; ★★ 240 s, ★★★ 170 s (★★★ also requires no trimmed cube).
- Proposed changes: **The stars were not rescaled for 8x8** (`design_spec` holds the same 240 / 170 s that were tuned for 5x5). Ten layers of 64 cells at about 80% fill is about 100 pieces, against about 50 on 5x5. Change `goal.h_target` 10 → 8 (keep h_play 12 for slip room) and set stars to about 490 / 345 s (5x5 pace of about 4.8 s per piece × about 102 pieces), then tune by playtest. Alternative: keep h_target 10 and add a mask to 6x6 active cells (the board stays 8x8), with stars about 400 / 280 s.

**Progression role** (layer 1): The first non-clearing level and the first no-fail rest: it pays off the tilt and roll and wobble from 02. It is the biome's ★PROTO for physics, and its height verb is the base for Ice's `summit_climb` (Avalanche Ascent) later. It comes before 06, the second rest.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_06: Flower Bed  (tier 6, completing)

**Play** (layer 1)
- Goal: `shape`: cover the 50 target cells of a flower picture (38 cells on layer 0 for the petals and stem, 12 on layer 1 for the raised centre). Top-out is trim.
- How it plays: Painting, not clearing. The outline glows, and each correct cell blooms a petal. Pieces that land outside the outline are wasted and will be trimmed. The small pieces (Duo, Tri-Corner) fit the petal tips and the 1-wide stem. Two sprout cubes on layer 0 at the centre grow one cube up every 4 locks (max 1), filling a layer-1 target for free unless the player caps them. The thinking is "which piece fits which notch", with low time pressure.
- Teaches / tests: The fill-shape (picture) goal and the small-piece set.
- Rules and minigame blocks: `fill_shape` {topout_rule trim, stick_when_filled false}; `sprouts` {grow_locks 4, grow_max 1}. No module.
- Board: 8x8, h_play 8, two sprout cells at (3, 2) and (4, 2). The target is fixed, and pieces are random.
- Difficulty: g0 0.7 (a deliberate dip); ★★ 155 s, ★★★ 110 s (★★★ needs no trimmed cube). The calmest level of the biome.
- Proposed changes: (1) Add a `variation` block (mirror_x only, because the flower is left-right symmetric except for the leaf at row 6) so the leaf flips side on each attempt. (2) Otherwise none: this is the right rest beat.

**Progression role** (layer 1): The second rest, after the tower, and the introduction of the picture goal that Candy (06 Icing Picture) and Ice (06 Snowman Picture) reuse. Sprouts come back uncapped in `meadow_h1`. After it the biome turns to pressure with 07.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_07: Hide & Seek  (tier 7, twist)

**Play** (layer 1)
- Goal: `clear_n` 4 (rescue, 1 warning).
- How it plays: The board starts with two holey starter layers. They are visible through the countdown, and then locked cubes fade to 10% alpha 5 s after they land (1 s fade). Each clear reveals the whole stack for 0.6 s. The landing ghost still shows where a piece will land, so the player aims by memory plus the ghost. One piece per bag is a fog ghost: it falls *through* locked cubes until the player taps it solid, which is the tool for reaching a buried, remembered hole.
- Teaches / tests: Memory: "the stack fades; remember it."
- Rules and minigame blocks: `fog` {visible_ms 5000, fade_ms 1000, invisible_alpha 0.1, reveal_ms 600}; `fog_ghost` (1 per bag); knob `control.fog_ghost_preview` faint. No module.
- Board: 8x8, h_play 10, 2 starter layers (the 6x6 design inset by 1). No layout variation.
- Difficulty: g0 0.85; ★★ 345 s, ★★★ 250 s.
- Proposed changes: (1) Add a `variation` block (all 8 symmetries) so the starter holes cannot be learned by heart across retries; memorising during the countdown is the skill, not memorising across attempts. (2) As in 02, the empty 1-cell ring around the inset starter makes the first clears much bigger than designed. Fill the ring in both starter layers, leaving 3–4 random gap cells (with `jitter` on them), so "the starter layers clear fast" stays true.

**Progression role** (layer 1): The first perception twist, and the step up in intensity after the 05–06 rests. Fog is reused in `meadow_h3` and is the template for Ice's Whiteout (07). It comes before 08's survival test.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_08: Dewdrop  (tier 8, defender)

**Play** (layer 1)
- Goal: `survive` 150 s (rescue, 1 warning). Stars are by layers cleared: ★★ 1, ★★★ 2 (with no warning).
- How it plays: Sticky landing: a piece locks the instant it touches anything, with no slide and no last-moment rotation, so all aiming happens in the air (fall speed ×0.7 to compensate). Speed ramps +0.15 per minute. Every 15 s ± 2 s a lightning bolt is telegraphed for 2.5 s on a column and then zaps that column's top cube, so the player defends the tower by keeping the marked column low or covering it with a cube they can spare. Clears buy room under the low 8-layer ceiling.
- Teaches / tests: Survive goal + committing in the air; the first "defend the tower" hazard.
- Rules and minigame blocks: `sticky_landing` {sticky_gravity_scale 0.7}; `storm_bolt` {bolt_interval_ms 15000, bolt_warn_ms 2500, bolt_jitter_ms 2000}. No module.
- Board: 8x8, h_play 8, empty. Random bag.
- Difficulty: g0 0.9 (×0.7 = 0.63 effective, ramping to about 0.8 by 2:30); ★★ 1 layer, ★★★ 2 layers. A short, tense spike (2.5 min).
- Proposed changes: (1) The board grew from 5x5 to 8x8, so a layer is now 64 cells and the stack rises 2.5× slower, which removes most of the survival pressure. Restore it with `knobs.fall.ramp_per_min` 0.15 → 0.25 and `goal.t_ms` 150000 → 120000, and keep ★★ 1 / ★★★ 2 layers. (2) Make the bolt the "defender" hook it was added for: when a bolt hits a column that has no cubes, it scorches the floor cell for 1 lock (no effect beyond a visual), so a bolt is never wasted silently. The player always sees what each bolt did (readable chaos).

**Progression role** (layer 1): The biome's defender level, and its one pure "hold out" beat. It gives a short, sharp peak between the long 07 and 09 (campaign rule 12: alternate short and long). `storm_bolt` is reused as a boss-phase hazard in later biomes. An optional side node after 08 is Shepherd's Pen (`route_runner` + `herd_critter`, mockup-alignment #21), once A11 is built.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_09: Topsy-Turvy  (tier 9, balance)

**Play** (layer 1)
- Goal: `clear_n` 4 (rescue, 1 warning).
- How it plays: After every 2 cleared layers, or every 40 s, a 2 s warning (arrows and a countdown ring) is followed by a flip: each column of the stack turns over in place, so the messy underside becomes the top and the top becomes the floor. The skill is to keep the top flat before each warning, because a spiky top becomes a holey floor. Two eggs on the floor hatch after 6 locks each into a chick cube that hops to the lowest free neighbour cell, often into a gap after a flip. Clearing an egg before it hatches gives a bonus.
- Teaches / tests: The stack transforms; plan for the shape *after* the flip.
- Rules and minigame blocks: `topsy_tumble` {flip_every_layers 2, flip_every_ms 40000, flip_warn_ms 2000}; `hatching_eggs` {hatch_locks 6}. No module.
- Board: 8x8, h_play 10, 2 eggs on layer 0. Per-attempt `variation`: all 8 symmetries + egg jitter radius 1. This is the model the other levels should copy.
- Difficulty: g0 0.95; ★★ 580 s, ★★★ 410 s. **Too long** for the step before the boss (about 10 minutes).
- Proposed changes: `goal.n` 4 → 3 and `topsy_tumble.flip_every_layers` 2 → 1. The player gets the same number of flips (2) in 3 clears instead of 4, the level has more flips per minute, and the length drops to about ★★ 435 s / ★★★ 310 s (×0.75). This keeps 10 the longest level.

**Progression role** (layer 1): The "combine" step: it teaches the flip that the boss uses in phase 2, with a living-block helper. It is the biome's ★PROTO for the flip. Directly before the finale.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_10: Meadow Mill  (tier 10, twist)

**Play** (layer 1)
- Goal: `clear_n` 3 (rescue, 1 warning). Story: each clear knocks one sail off the Miller's mill. **Proposed: `bonk_boss` with 3 bonks** (see below).
- How it plays: The mill belt slides the whole stack +x one cell every 2 locks and wraps it around, so the player must drop where the gap *will be* after the shift. A +z gust blows across the belt every 8 s ± 2 s. The flip uses its own trigger (`flip_every_layers` 2, `flip_every_ms` 180000), so it fires once, right after the 2nd clear: phase 2 is the same belt and gusts on an upside-down stack. The chair piece joins the pool, and S is removed.
- Teaches / tests: The finale exam: belt (new) + gust (03) + flip (09) at once.
- Rules and minigame blocks: `mill_belt` {conveyor_dir +x, conveyor_every 2, conveyor_wrap true}; `gust` {+z, 8000 ± 2000, strength 1, warn 1000}; `topsy_tumble` {flip_every_layers 2, flip_every_ms 180000, warn 2000}. No module.
- Board: 8x8, h_play 12, empty (conveyor forbids masks). Random bag.
- Difficulty: g0 1.0; ★★ 420 s, ★★★ 300 s. The biome peak.
- Proposed changes: **Give the boss a face and HP.** Change the goal to `{"type": "bonk_boss", "bonks_needed": 3}` (the goal type already used by `candy_10` stage 2), and add `climber_boss` {size [2,2,1], skin "miller"}: the Miller stands on the stack top and each clear under him is a bonk (a sail falls). This makes the win readable: three hits on a character, not three anonymous clears. Keep the belt in phase 1. The flip still fires at the 2nd bonk. Once `boss_hp` (A6) exists, move to `modules: [{ "id": "boss_hp", "params": { "hp": 3, "dmg_per_clear": 1 }, "overlays": [{ "id": "mill_belt" }, { "id": "gust_wind" }] }]` with `phase_rules` swapping `gust` for `topsy_tumble` at HP 1 (mockup-alignment §5 step 6); that also resolves the "phase 2 too busy" open question in `design/levels/meadow.md` §10. Twist count stays inside the cap (2 twists + 1 mechanic).

**Progression role** (layer 1): The payoff and the biome's ★PROTO boss. It closes the Meadow arc (gust → flip → belt), unlocks the hard track, and opens Candy at 15 of 30 stars. Its `mill_belt` is the Meadow's version of the conveyor verb that Clockwork builds on.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_bonus: Picnic Puzzle  (tier 11, completing)

**Play** (layer 1)
- Goal: `shape`: fill a 4x4 × 2-layer basket (32 cells) at the centre of the board with a `piece_budget` of 6 within `time_limit_ms` 60000. Top-out trim, 0 warnings.
- How it plays: A pure packing puzzle against a clock. The player reads the 3-piece preview, plans where each I, O and Big Cube goes so the 4x4 box fills exactly, and soft- or hard-drops to beat the ant line (the visible clock). A misplaced piece cannot be recovered, because there are no spare pieces.
- Teaches / tests: Planning a full packing from the preview (spatial foresight).
- Rules and minigame blocks: `fill_shape` {topout_rule trim, stick_when_filled false}. No module.
- Board: 8x8, h_play 6, target at x 2–5, z 2–5 on layers 0–1. **Pieces: `fixed_list` [I, O, Big Cube, I, O, Big Cube]**, identical on every attempt.
- Difficulty: g0 0.5; ★★ 45 s, ★★★ 30 s (and no cube trimmed). An off-curve puzzle break.
- Proposed changes: **Remove `fixed_list`** (it breaks the standing rule). Replace it with a random *solvable* deal: `pieces.deal_pool` (NEW): a list of piece multisets that each pack the 4x4x2 box exactly, with one picked at random and dealt in random order on each attempt. Any order works, because each piece falls to the floor of its own columns. Valid multisets (I pieces must come in pairs that share a 4x2 strip): {BigCube ×2, O ×2, I ×2}, {BigCube ×3, O ×2}, {BigCube ×1, O ×4, I ×2}, {BigCube ×2, I ×4}, {O ×4, I ×4}. Set `piece_budget` to the multiset size (5–8) and show it on the HUD. Keep the 60 s clock and set stars by multiset (or keep 45 / 30 s if playtests show the 8-piece deals are not slower). The validator must prove each multiset packs the target.

**Progression role** (layer 1): Unlocks at 20 meadow stars. It is a palate cleanser and a pure-thinking contrast to the hazard levels, and it introduces piece budgets, which Candy's and Ice's puzzle bonuses reuse. It does not count toward the Candy gate.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_h1: Seed Sprouts  (tier 12, twist)

**Play** (layer 1)
- Goal: `clear_n` 4 (rescue, 1 warning).
- How it plays: Four sprout roots on the floor grow one cube up every 3 locks with no cap, so they become towers that poke toward the danger line unless the player caps them with a flat piece or folds them into a layer. A +x gust every 10 s ± 2 s drifts pieces toward the downhill wall. Six dandelion coins float in empty cells at layers 2–8; a piece that locks over one collects it (+50 score). Coins sink with each clear.
- Teaches / tests: Remix: uncapped sprouts (06) + gust (03), with coins as an optional route.
- Rules and minigame blocks: `sprouts` {grow_locks 3, grow_max 0}; `gust` {+x, 10000 ± 2000, strength 1, warn 1000}; `star_coins` {coins 6, min_layer 2, score 50, goal_counter "coins"}. No module.
- Board: 8x8, h_play 10, 4 sprout roots. Per-attempt `variation`: 8 symmetries + root jitter radius 1.
- Difficulty: g0 0.95; ★★ 535 s, ★★★ 375 s.
- Proposed changes: (1) `star_coins` is score-only because no counter goal exists; that makes the coins invisible to the star rating, and the twist feels optional. Add `stars.three_star_zero_metrics: ["coins_missed"]` (as in the `cave_mg1` sketch), so ★★★ requires all 6 coins. (2) If 03 becomes the bridge level, `dandelion_puff` (1 per bag) moves here, replacing `star_coins` only if the wave-3 counter goal is not ready; that keeps "one wave-3 rule" honest. (3) Shorten: `goal.n` 4 → 3 (stars about 400 / 280 s), because the uncapped sprouts already make each clear slower.

**Progression role** (layer 1): The first hard-track remix, open after 10. It recombines the two growth and weather ideas of the first half of the biome. The three remixes should each use a **different goal** (see h2, h3), so the hard track is not "clear 4" three times.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_h2: Petal Party  (tier 13, funny)

**Play** (layer 1)
- Goal: `clear_n` 4 (rescue, 1 warning).
- How it plays: Mushrooms pop up every 6 locks (max 3). The stack flips after every 2 clears or every 45 s (2 s warning). Any clear of 2 or more layers at once fires a petal cannon that fills up to 4 covered holes, lowest first. The player is rewarded for building toward double clears, since a double both fixes the holes and triggers the flip on a cleaner stack.
- Teaches / tests: Remix: mushrooms (04) + flip (09), with multi-clears paying off.
- Rules and minigame blocks: `mushroom_popup` {spawn_every_locks 6, objects_max 3}; `topsy_tumble` {flip_every_layers 2, flip_every_ms 45000, flip_warn_ms 2000}; `confetti_fill` {min_layers 2, max_fill 4}. No module.
- Board: 8x8, h_play 10, empty. Random bag.
- Difficulty: g0 1.0; ★★ 535 s, ★★★ 375 s.
- Proposed changes: **Change the goal to make the remix about doubles, not about a count.** `goal` → `{"type": "clear_n", "n": 4}` stays, but add `stars.three_star_zero_metrics: ["single_clears"]`, so ★★★ needs every clear to be a double or better. If that metric is not available, use `golden_row` {start_layer 3, bonus 200} as the visible "party line". This gives h2 a distinct identity (a scoring-skill level) between h1 (growth) and h3 (memory). Also add a `variation` block, since the board is empty and the mushrooms are random already: none needed beyond the bag.

**Progression role** (layer 1): The middle remix: the busiest, funniest one (two twists + one mechanic, at the cap). It sits between the growth remix and the memory finale of the hard track.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### meadow_h3: Lucky Dip  (tier 14, funny)

**Play** (layer 1)
- Goal: `clear_n` 4 (rescue, 1 warning).
- How it plays: The 07 fog returns, faster (visible 4 s), on a new two-layer starter. Every 4th queued piece is a "?" packet whose shape is revealed only when it spawns, so the player cannot plan that slot, and must keep a flat "any-shape" landing spot ready. One fog-ghost piece per bag can slip through the faded stack into a remembered hole.
- Teaches / tests: Remix: memory (07) under uncertainty about the next piece.
- Rules and minigame blocks: `fog` {visible_ms 4000, fade_ms 1000, invisible_alpha 0.1, reveal_ms 600}; `fog_ghost` (1 per bag); `mystery_piece` {every 4}. No module.
- Board: 8x8, h_play 10, 2 starter layers (inset 6x6). No layout variation.
- Difficulty: g0 1.0; ★★ 320 s, ★★★ 220 s. The hard-track peak.
- Proposed changes: **Make the final remix a picture in the fog** instead of a fourth "clear 4". Goal → `shape` with a 2-layer picnic-blanket target (about 40 cells: a checkered 6x6 on layer 0 with a 2x2 basket on layer 1), `fill_shape` {topout_rule trim}, keep `fog` (the painted cells fade, so the player must remember what is already painted) and `mystery_piece`; drop the starter layers and `fog_ghost` (one less rule for a different goal). Type → `completing`. Stars about 220 / 155 s. This gives the hard track three distinct goals (clear with coins, doubles, a picture from memory). If kept as a clear level: add a `variation` block (8 symmetries) on the starter, as for 07.

**Progression role** (layer 1): The last Meadow level. It should be the hardest reading test of the biome: memory plus an unknown next piece. It sends the player to Candy with every Meadow mechanic covered.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_
