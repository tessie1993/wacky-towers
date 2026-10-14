# Ice plan: Pebble's Egg Escape

> Layer 1 (Play, Progression role) by level design, 2026-10-14. Sources: `src/levels/ice/*/*.json` (the source of truth for numbers), `assets/data/campaign/catalog.json`, `design/levels/ice.md`, `design/levels/mockup-alignment.md`, `design/levels/minigame-stages.md`, `assets/data/rules/*.json`, `assets/data/modules/*.json`.
> Star times are shown in seconds (the JSON stores ms). Every "Proposed change" is a proposal for the user and the game-designer. No JSON has been edited.

## Biome intro

**Theme.** A floating glacier broken into floes. Blocks fall as a soft flurry. Pebble the penguin carries a snowball egg home to the igloo. Big Sniffles, a yeti with a cold, sneezes the avalanches that cause every glide, roll, whiteout and crack, and is the boss of 10. Quirk: "glide and quiet", the campaign's calm, deadpan biome, where the player learns to **use** sliding rather than fight it.

**Mechanics Ice introduces:**
1. **Glide**: `ice_slide`, where a piece slides 1 cell along a world-anchored direction when it touches down (the ghost shows the second cell), and the **Curling Flick** verb (`control.verb: curling_flick`), where the player flicks the landed piece along an axis until it is blocked.
2. **Rolling snow**: `snowball`, a living block that rolls downhill every N locks and grows as it goes.
3. **A shrinking floor**: `thin_ice` (rim strips crack off on a telegraphed timer) and `crumble_tiles`.
4. **Sideways gravity**: `side_travel` with `down_axis: -x` (the sled finale), and the first rival race (`race_rival`).

### Curve table (as authored in JSON)

| id | tier | type | goal | g0 | stars ★★ / ★★★ |
|---|---|---|---|---|---|
| ice_01 | 1 | race | clear_n 2, 360 s limit, vs rival | 0.72 | 290 / 205 s |
| ice_02 | 2 | twist | clear_n 3 | 0.75 | 435 / 310 s |
| ice_03 | 3 | balance | clear_n 4 | 0.80 | 585 / 410 s |
| ice_04 | 4 | defender | clear_n 3 | 0.85 | 440 / 310 s |
| ice_05 | 5 | race | height 9 (coverage 0.6) | 0.85 | 215 / 155 s |
| ice_06 | 6 | completing | shape, 39 cells | 0.80 | 120 / 85 s |
| ice_07 | 7 | twist | clear_n 4 | 0.95 | 580 / 410 s |
| ice_08 | 8 | balance | survive 140 s | 1.00 (+0.15/min) | 1 / 2 layers |
| ice_09 | 9 | funny | clear_n 4 (2 starter layers) | 1.05 | 480 / 340 s |
| ice_10 | 10 | twist (boss) | clear_n 4 (sideways) | 1.10 | 270 / 190 s |
| ice_bonus | 11 | completing | shape 32 cells, kit of 6 | 0.50 | 120 / 80 s |
| ice_h1 | 12 | defender | clear_n 4 | 1.05 | 535 / 375 s |
| ice_h2 | 13 | defender | clear_n 3 | 1.05 | 400 / 285 s |
| ice_h3 | 14 | balance | clear_n 4 | 1.05 | 445 / 310 s |

### What the curve gets right, and what it gets wrong

- **Right:** the speed ramp is clean (0.72 → 1.10), with the 06 dip as a rest. The biome has a real identity (glide), and the sled finale is a genuine change of perspective. Every level except 01 adds one idea. All six level types appear.
- **Wrong 1, goal monotony, the worst of the four biomes:** 10 of 14 levels are `clear_n`, including all three hard-track remixes.
- **Wrong 2, length spikes:** 02 (435 s), 03 (585 s), 07 (580 s) and 09 (480 s) are 7–10 minute levels; 03 is again a 10-minute tier-3 level, as in Meadow and Candy.
- **Wrong 3, the opener is overloaded:** the design says 01 is "classic with the Ice look", but the JSON adds a rival race, a stopwatch freeze-and-catch-up, and a 6-minute time limit.
- **Wrong 4, data bugs:** `ice_05` weights `big_cube` 0.5 but does not list `big_cube` in `shapes`, and its stars were not rescaled from 5x5 (215 / 155 s for 9 layers of 64 cells). `ice_03` adds `wobble`, against the biome rule "Physics: none". `ice_10` is **16 wide x 3 deep**, which breaks the standing 8x8 minimum.
- **Wrong 5, no minigame blocks.** Mockup-alignment binds Avalanche Ascent (`summit_climb`), Glacier Gauntlet (`floe_survive`), an Ice-ramp Bridge and Glacier Rush to Ice. Avalanche Ascent can be built **today** from existing rules (`build_race` + `snowball` + a slope mask), per the `ice_mg1` sketch in minigame-stages.
- **Wrong 6, slide over-use:** `ice_slide` appears in 02, 05, 07, 09, 10 and h3. It is the quirk, but in 07, 09 and h3 it adds noise rather than a decision.

**Proposed biome arc after the changes:** teach glide (01 classic + rival, 02 slide) → twist (03 curling into a target, 04 snowballs) → build and rest (05 igloo, 06 snowman) → perception and pressure (07 whiteout, 08 thin ice) → combine (09 cracked berg) → **set piece with a boss presence** (10 sled run past Sniffles) → kit puzzle → hard track with **three different goals**: an avalanche climb (h1), a curling clear in fog (h2), a shrinking-floor clear (h3).

---

### ice_01: Egg Nest  (tier 1, race)

**Play** (layer 1)
- Goal: `clear_n` 2 within `time_limit_ms` 360000, racing a scripted rival (1 warning).
- How it plays: Classic stacking on the Ice floe at 0.72. A rival penguin's progress bar fills at 30% of the expected rate, with rubber-banding (0.5), and warns at 80%, so the player feels a gentle chase. Every 18 s ± 3 s a stopwatch freezes the falling piece for 2 s (1.5 s warning), then the game runs at 1.4× for 2 s to catch up, so the player gets a free aiming pause followed by a rush. Pebble points at the best cell.
- Teaches / tests: The race against a visible rival (the base of the tournament duel rounds).
- Rules and minigame blocks: `race_rival` {rival_rate 0.3, rubber_band 0.5, rival_warn_pct 80}; `stopwatch` {stop_every_ms 18000, jitter 3000, warn 1500, stop_ms 2000, catchup_scale 1400, catchup_ms 2000}; `mascot_hint`; `angle_gem` {under_island}. No module.
- Board: 8x8, h_play 9, empty. Random bag of 8 shapes.
- Difficulty: g0 0.72; ★★ 290 s, ★★★ 205 s. Biome floor.
- Proposed changes: **Remove `stopwatch` from 01** (two twists plus a time limit is too much for a biome opener, and the design calls 01 "classic"). Keep `race_rival`, since the rival is a readable and welcome new idea, and drop the 360 s `time_limit_ms` (the rival already supplies the pressure; losing to it should cost stars, not the level). Move `stopwatch` to `ice_h2` or a later biome.

**Progression role** (layer 1): Re-entry after the Candy boss: classic play with the Ice look, plus the campaign's first rival race, which teaches the progress-bar duel format the tournament uses. It hands off to 02's glide.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_02: Slippery Floe  (tier 2, twist)

**Play** (layer 1)
- Goal: `clear_n` 3.
- How it plays: When a piece first touches down, it slides one cell along +z (the same world direction every time) before lock delay ends, unless it is blocked. The landing ghost shows the touchdown cell and a faint second cell with an arrow. The player learns to aim one cell "uphill" of the gap, or to place pieces against the +z wall, where they cannot slide.
- Teaches / tests: Glide: "aim one cell short and let it slide."
- Rules and minigame blocks: `ice_slide` {slide_dir +z, slide_cells 1}; `mascot_hint`; `angle_gem` {under_island}. No module.
- Board: 8x8, h_play 10, empty. Random bag.
- Difficulty: g0 0.75; ★★ 435 s, ★★★ 310 s.
- Proposed changes: `goal.n` 3 → 2 and stars about 290 / 205 s. The idea is learned in the first clear; a third 64-cell layer at tier 2 is length without a new decision. Add a short starter strip along the +z wall (layer 0, z 7 filled except 2 gaps) so the first slide visibly "docks" a piece into a gap.

**Progression role** (layer 1): The biome's core idea, on its own. 03 adds control of the glide (flick), and 05, 07, 09 and 10 reuse it.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_03: Sled Slope  (tier 3, balance)

**Play** (layer 1)
- Goal: `clear_n` 4.
- How it plays: The Curling Flick: during lock delay the player can flick the landed piece once along an axis, and it slides until it is blocked (over a gap it drops). Two stone blocks on the floor act as stops. Pieces spawn at (3, 3), so the player flicks them outward to the walls or against the stones. A wobble meter (max 8) also punishes overhangs.
- Teaches / tests: Steering the glide: a player-controlled slide.
- Rules and minigame blocks: `control.verb` curling_flick, `control.flick_per_piece` 1; `wobble` {wobble_max 8}. No module.
- Board: 8x8, h_play 10, 2 stones at (2, 5) and (5, 5). Per-attempt `variation`: 8 symmetries + stone jitter radius 1.
- Difficulty: g0 0.8; ★★ 585 s, ★★★ 410 s. **A 10-minute tier-3 level**, the longest non-boss level in the biome.
- Proposed changes: **Turn 03 into a curling target**. Goal → `shape` with a "house" target of 2 layers (a 4x4 ring at z 0–3, x 2–5, about 24 cells) at the far end; spawn_anchor → (3, 6) at the near end; the flick carries pieces up the sheet into the house, and the 2 stones become guards to curl around. Remove `wobble` (the biome rule is "no physics", and wobble muddies the flick lesson). Type → `twist`; stars about 160 / 115 s (★★★ no trimmed cube). This makes the flick the whole level instead of an optional nudge, gives Ice a second non-clear goal, and removes the length spike. Fallback: keep the clear goal, drop wobble, `goal.n` 4 → 3, stars about 440 / 310 s.

**Progression role** (layer 1): The control step after 02's passive glide, and the base for the h2 remix (curling in fog). It hands off to 04, where the board starts rolling on its own.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_04: Snowball Field  (tier 4, defender)

**Play** (layer 1)
- Goal: `clear_n` 3.
- How it plays: Two snowballs (`n`) sit on the floor near the +x side. Every 2 locks each rolls one cell toward -x, if the next column's top is within 1 cell of its height, and gains one cube on top as it rolls (up to 3). One lock before each roll a dotted track shows where it goes. A blocked ball parks and becomes an ordinary block. New balls appear at the high end every 8 locks (max 2). The player shapes the slope: a flat lane lets a ball roll into a gap as free filler, and a step of 2 parks it where it is useful.
- Teaches / tests: A living block that can be steered by the shape of the stack.
- Rules and minigame blocks: `snowball` {slope_dir -x, roll_locks 2, snow_max 3, balls_max 2, respawn_locks 8}. No module.
- Board: 8x8, h_play 10, 2 snowballs at (6, 2) and (6, 4). Per-attempt `variation`: 8 symmetries + jitter radius 1 (the slope direction must rotate with the symmetry).
- Difficulty: g0 0.85; ★★ 440 s, ★★★ 310 s. ★PROTO.
- Proposed changes: Confirm that `variation` symmetries also rotate `snowball.slope_dir`; if the runtime does not, the balls start on the "downhill" side after a rot180 and never roll. Otherwise, restrict `variation.symmetries` to [identity, mirror_z]. Stars ×0.85 (about 375 / 265 s), since the balls act as filler.

**Progression role** (layer 1): Ice's living-block level (Meadow's mushrooms and eggs grown up), and the base for Avalanche Ascent (h1, proposed) and the snowman picture (06).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_05: Igloo Climb  (tier 5, race)

**Play** (layer 1)
- Goal: `height` 9 with coverage 0.6. Trim (no fail).
- How it plays: A height race on ice: nothing clears, and every piece slides one cell along +z on touchdown, so the tower creeps toward the +z wall unless the player builds against it. The skill is building a square chimney when every piece wants to drift.
- Teaches / tests: Build race + glide: plan the drift into the tower.
- Rules and minigame blocks: `build_race`; `ice_slide` {+z, 1}. No module.
- Board: 8x8, h_play 12, empty. **`pieces.weights` lists `big_cube` 0.5, but `big_cube` is not in `shapes`**, so no Big Cube ever spawns.
- Difficulty: g0 0.85; ★★ 215 s, ★★★ 155 s (★★★ no trimmed cube). A no-fail rest.
- Proposed changes: (1) **Add `big_cube` to `pieces.shapes`** (the design lists "8 Std + Big Cube (w 0.5)"). (2) **Rescale the stars**: they are the 5x5 values. Nine layers of 64 cells at about 80% fill is about 115 pieces, against about 45 on 5x5. Either set `goal.h_target` 9 → 7 with stars about 420 / 300 s, or keep 9 and mask the floe to a round 6x6 igloo yard inside the 8x8 board (stars about 330 / 235 s). Test against `meadow_05`'s rescale so the two height levels sit on one curve.

**Progression role** (layer 1): The first of two no-fail rests. It repeats the height race from Meadow 05 and Candy 05 with the glide added, so the familiar verb carries the new twist.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_06: Snowman Picture  (tier 6, completing)

**Play** (layer 1)
- Goal: `shape`: a 39-cell snowman (34 on layer 0: hat, head, body and a wide base; 5 on layer 1: a 3-cell scarf, a nose and a button). Trim.
- How it plays: A calm painting puzzle. Two snowballs start on the back row and roll toward +z every 3 locks (no respawns, max 2 on the board), growing up to 2 cubes: if the player leaves a flat lane, a snowball rolls into the body outline and paints cells for free; if it rolls off the outline, it wastes them. Small pieces (Duo, Tri-Corner) finish the hat and the base corners.
- Teaches / tests: Picture goal + steering a living block into the picture.
- Rules and minigame blocks: `fill_shape`; `snowball` {slope_dir +z, roll_locks 3, snow_max 2, balls_max 2, respawn_locks 0}. No module.
- Board: 8x8, h_play 8, 2 snowballs at (1, 0) and (5, 0). The target is fixed (column x 7 unused).
- Difficulty: g0 0.8 (the dip); ★★ 120 s, ★★★ 85 s (★★★ no trimmed cube). The calmest Ice level.
- Proposed changes: Centre the snowman (it uses x 0–6; column 7 is empty), so the board does not read as lopsided: shift the target +0 and widen the base rows to 8 cells (two cells more), or add a mirrored scarf end at x 6. Add `variation` mirror_x (target and snowballs together).

**Progression role** (layer 1): The second rest and the Ice picture level (companion of Meadow 06 and Candy 06). It turns 04's snowball into a friendly tool, just before the pressure of 07–08.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_07: Whiteout  (tier 7, twist)

**Play** (layer 1)
- Goal: `clear_n` 4.
- How it plays: The Meadow fog at blizzard strength: locked cubes are visible for only 3 s, fade over 1.2 s to 12% alpha, and a clear reveals the stack for 0.7 s. On top of that, every piece slides one cell along +z on touchdown, so the player has to remember the stack *and* aim one cell short. There is no fog ghost here.
- Teaches / tests: Memory under glide.
- Rules and minigame blocks: `fog` {visible_ms 3000, fade_ms 1200, invisible_alpha 0.12, reveal_ms 700}; `ice_slide` {+z, 1}. No module.
- Board: 8x8, h_play 10, empty. Random bag.
- Difficulty: g0 0.95; ★★ 580 s, ★★★ 410 s. **About 10 minutes**, as long as the boss stretch.
- Proposed changes: (1) `goal.n` 4 → 3, stars about 435 / 310 s. (2) Give the player something to remember from: add 2 starter layers with holes (as `meadow_07`, with a `variation` block) so the countdown is a memorisation beat. Fog on an empty board has nothing to memorise until the player builds it, so the first minutes are plain play.

**Progression role** (layer 1): The perception twist of the biome, a callback to Meadow 07 at higher strength. It is the first of two pressure levels before the combine.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_08: Thin Ice  (tier 8, balance)

**Play** (layer 1)
- Goal: `survive` 140 s; ramp +0.15 per minute. Stars by layers: ★★ 1, ★★★ 2.
- How it plays: Every 35 s a rim strip of the floe turns blue-white and cracks for 3 s, then its whole column of cubes pops off with a splash and the strip leaves the board, in the order +z, +x, +z (3 steps). The floor shrinks from 8x8 toward 8x5 / 7x5 while speed rises, so the player keeps weight off the cracking edge and clears inward.
- Teaches / tests: A shrinking footprint: "don't build on the cracking rim."
- Rules and minigame blocks: `thin_ice` {shrink_every_ms 35000, shrink_warn_ms 3000, shrink_steps 3, shrink_order [+z, +x, +z]}. No module (this is the `floe_survive` / Glacier Gauntlet idea, built from a rule).
- Board: 8x8, h_play 8, empty. Random bag.
- Difficulty: g0 1.0; ★★ 1 layer, ★★★ 2 layers. A short spike.
- Proposed changes: (1) Type `balance` → `defender` (it is a survive / hold-the-floe level; `level-type-mix` should count it there). (2) Bind it as **Glacier Gauntlet phase 1**: add `snowball` {slope_dir -z, roll_locks 2, balls_max 1, respawn_locks 6} as the rolling hazard from the mockup, so there is something to defend against between cracks. Budget: thin ice is new, snowball is known. (3) As in `meadow_08`, the 8x8 board removed the pressure: ramp 0.15 → 0.25 per minute.

**Progression role** (layer 1): The short spike between 07 and 09, and the biome's survive level. Thin ice returns in h3.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_09: Cracked Berg  (tier 9, funny)

**Play** (layer 1)
- Goal: `clear_n` 4.
- How it plays: The berg cracks and turns over: after every 2 clears or 70 s (2 s warning, max 2 flips) the stack flips in place, as in Meadow's Topsy-Turvy, so the holey bottom of two starter layers comes up to the top. Every piece also slides one cell along +z on touchdown. The player keeps the top flat before each warning and uses the slide to tuck pieces into the edge holes that a flip exposes.
- Teaches / tests: The combine: flip (Meadow 09) + glide.
- Rules and minigame blocks: `flip` {flip_mode stack, flip_every_layers 2, flip_every_ms 70000, flip_warn_ms 2000, flip_max 2}; `ice_slide` {+z, 1}. No module.
- Board: 8x8, h_play 10, 2 starter layers inset in x 1–6, z 1–6 (an empty 1-cell ring around them). No layout variation.
- Difficulty: g0 1.05; ★★ 480 s, ★★★ 340 s.
- Proposed changes: (1) Fill the empty ring in both starter layers, leaving 3–4 rim gaps per layer, so the starter layers are near-complete as designed (today each needs 28 extra cells). (2) Add a `variation` block (8 symmetries, with `ice_slide.slide_dir` rotated). (3) Add the snowball (known from 04) as the third idea at the showpiece cap, rolling from the high side after each flip, so 09 combines the three Ice ideas (glide, roll, crack) rather than one Ice idea plus a Meadow one.

**Progression role** (layer 1): The step before the finale that combines the biome's ideas. It hands off to the change of perspective in 10.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_10: Sniffles' Sneeze  (tier 10, twist)

**Play** (layer 1)
- Goal: `clear_n` 4.
- How it plays: The camera turns side-on (at least 45°): pieces spawn at the far end of a long sled run and travel along -x, so the near wall is the floor and "layers" are slices across the run. Every 9 s ± 2 s Sniffles sneezes a +z gust across the run. After 2 clears the run ices over, and pieces also slide one cell along +z on touchdown, so phase 2 is gust plus glide sideways.
- Teaches / tests: The finale: sideways gravity + gust + glide.
- Rules and minigame blocks: `side_travel` {travel_dir -x, side_view_min_deg 45}; `gust` {+z, 9000 ± 2000, strength 1, warn 1000}; `ice_slide` {+z, 1, start_after_clears 2}. Knob `spawn.arrival: side_travel`. No module.
- Board: **16 wide x 3 deep**, h_play 6, `down_axis: -x`, spawn_anchor (4, 1). Random bag.
- Difficulty: g0 1.1; ★★ 270 s, ★★★ 190 s. The biome peak.
- Proposed changes: (1) **The board breaks the 8x8 rule** (depth 3). Set `depth` 3 → 8 and `h_play` 6 → 8, so each slice across the run is 8x8 (64 cells, like every other level), keep `width` 16 as the run, and rescale the stars (about 4 × 2.67 × 64 × 0.85 → about 580 / 410 s; then cut `goal.n` 4 → 3 for about 435 / 310 s). (2) **Give the boss a presence**: add `snowball` {slope_dir -x, roll_locks 2, snow_max 2, balls_max 2, respawn_locks 6} as Sniffles' sneezed snowballs rolling down the run toward the player's floor; together with the existing phase switch at 2 clears, the level becomes a two-phase boss run (gusts, then gusts + glide + snowballs). The ideas are all known, so the budget is fine at the showpiece cap. When `boss_hp` lands, give Sniffles an HP bar fed by clears.

**Progression role** (layer 1): The Ice payoff: the camera move makes the finale feel different from every level before it. It unlocks the hard track, introduces Lana and her Stitch skill (per the design) and opens Underwater.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_bonus: Present Puzzle  (tier 11, completing)

**Play** (layer 1)
- Goal: `shape`: fill a 4x4 × 2-layer present box (32 cells) at the centre with a 6-piece kit. Trim.
- How it plays: A calm kit puzzle. The player picks any kit piece in any order (Big Cube ×2, Tripod ×2, Screw-Left ×2), rotates it in 3D and drops it, with unlimited undo and a one-tap reset. The thinking is how two Tripods and two same-handed Screws interlock to fill the 2-layer half that the Big Cubes do not.
- Teaches / tests: 3D interlocking of the odd shapes, with no time pressure.
- Rules and minigame blocks: `fill_shape`; `undo_reset`. Knob `spawn.arrival: kit_box`. No module.
- Board: 8x8, h_play 6, target at x 2–5, z 2–5, layers 0–1. **Kit fixed** on every attempt.
- Difficulty: g0 0.5; ★★ 120 s, ★★★ 80 s.
- Proposed changes: A kit is chosen by the player, so it is not a hardcoded *sequence*, but it is the same puzzle on every attempt. Add `pieces.kit_pool` (NEW): a list of validated 32-cell kits, one picked per attempt; for example {BigCube ×2, Tripod ×2, Screw-L ×2} (today's), {BigCube ×2, Screw-L, Screw-R, Tripod ×2}, {BigCube, Tripod ×2, Screw-L ×2, O ×2}. The validator must prove each kit packs the box.

**Progression role** (layer 1): Unlocks at 20 Ice stars. The thoughtful counterpart to the timed Meadow and Candy bonuses: no clock, undo allowed. It does not count toward the Underwater gate.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_h1: Snowball Fight  (tier 12, defender)

**Play** (layer 1)
- Goal: `clear_n` 4 (1 warning).
- How it plays: The 04 snowballs at full strength: up to 4 balls, rolling every lock toward -x and respawning every 5 locks, plus a +z gust every 10 s. `rusty_hinge` limits each piece to 2 rotations, so the player must commit to an orientation early. The board fills with rolling, growing snow that the player either channels into gaps or blocks with steps.
- Teaches / tests: Remix: snowballs (04) + gust (Meadow 03) with limited rotations.
- Rules and minigame blocks: `snowball` {slope_dir -x, roll_locks 1, snow_max 3, balls_max 4, respawn_locks 5}; `gust` {+z, fixed, 10000 ± 2000, warn 1000}; `rusty_hinge` {max_turns 2}. No module.
- Board: 8x8, h_play 10, 2 snowballs at (6, 2) and (6, 5). No layout variation.
- Difficulty: g0 1.05; ★★ 535 s, ★★★ 375 s.
- Proposed changes: **Rebuild as Avalanche Ascent** (mockup #2; `ice_mg1` sketch), from existing rules: goal → `height` 12 with coverage 0.5, `build_race` {topout_rule trim}, h_play 16, a diagonal slope mask (`["##......", "###.....", "####....", "#####...", "######..", "#######.", "########", "########"]`, a mountain face that forces staircase stacking), keep `snowball` {slope_dir -x, roll_locks 2, balls_max 3, respawn_locks 5} as the avalanche, keep `gust` {-z} and drop `rusty_hinge`. Moment to moment: the player climbs a staircase up the slope while snowballs roll down it, knocking parked balls into the steps. Type → `race`; stars about 240 / 170 s. This gives Ice its minigame block without new code; it becomes `summit_climb` + `rising_hazard` when those modules land. Flag: the slope mask leaves fewer than 64 playable cells (36), the same open question as Kraken in minigame-stages; if playable cells must be 8x8, use a 10x10 board with the same diagonal.

**Progression role** (layer 1): The first remix, turned into the Ice summit race. It previews the climb verb that Lava's Frenzy Footholds and the tournament's Summit Scramble build on.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_h2: Blind Curling  (tier 13, defender)

**Play** (layer 1)
- Goal: `clear_n` 3 (1 warning).
- How it plays: The 03 curling flick in a whiteout: every piece can be flicked once along an axis after touchdown, but the stack fades after 3.5 s (to 12% alpha), so the player flicks pieces into gaps they remember. Every 11 s a lightning bolt (1.8 s warning) zaps the top cube of a marked column, which can reopen a gap the player thought was closed.
- Teaches / tests: Remix: flick (03) + whiteout (07) + a defender hazard.
- Rules and minigame blocks: `fog` {visible_ms 3500, fade_ms 1200, invisible_alpha 0.12, reveal_ms 700}; `storm_bolt` {bolt_interval_ms 11000, bolt_warn_ms 1800}; `control.verb` curling_flick, `flick_per_piece` 1. No module.
- Board: 8x8, h_play 10, 2 stones, spawn (3, 3). Per-attempt `variation`: 8 symmetries + stone jitter.
- Difficulty: g0 1.05; ★★ 400 s, ★★★ 285 s.
- Proposed changes: If 03 becomes the curling target level, make h2 its hard echo: `goal` → `shape` "house" (as proposed for 03, 2 layers) under fog, so the flick has a destination and the fog hides how much of the house is already painted. Keep `storm_bolt` (it un-paints a house cell, which reads as a defender beat). Stars about 200 / 140 s. If 03 stays a clear level, keep h2 as is: it is a good remix.

**Progression role** (layer 1): The middle remix: the hardest reading test in Ice (memory + aim + a hazard).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### ice_h3: Floe Breakup  (tier 14, balance)

**Play** (layer 1)
- Goal: `clear_n` 4 (1 warning).
- How it plays: The floe shrinks twice (every 45 s, +z then +x, 3 s warning). Three floor tiles at (2, 2), (4, 3) and (3, 5) crumble 3 locks after something lands on them, dropping whatever sits there. Every piece slides one cell along +z. The player has to avoid both the cracking rim and the crumbling tiles while clearing on a footprint that is getting smaller.
- Teaches / tests: Remix: thin ice (08) + glide (02) + crumbling tiles.
- Rules and minigame blocks: `thin_ice` {shrink_every_ms 45000, shrink_warn_ms 3000, shrink_steps 2, shrink_order [+z, +x]}; `ice_slide` {+z, 1}; `crumble_tiles` {tiles [[2,2],[4,3],[3,5]], crumble_after 3}. No module.
- Board: 8x8, h_play 10, empty. Crumble tiles fixed (no variation).
- Difficulty: g0 1.05; ★★ 445 s, ★★★ 310 s. The hardest Ice level.
- Proposed changes: (1) Goal → `survive` 150 s with `fall.ramp_per_min` 0.2 and stars ★★ 2 / ★★★ 3 layers, making the finale of the hard track "hold the breaking floe" (the Lava Escape / Glacier Gauntlet verb) instead of a fourth clear; type → `defender`. (2) Drop `ice_slide` (three disturbances on a shrinking floor is noise, and the glide is not the point here). (3) Randomise the crumble tiles per attempt (`crumble_tiles.tiles_random` 3, NEW, or a `variation` block with the tiles as jitter glyphs in `starting_contents`).

**Progression role** (layer 1): The last Ice level: a floor that disappears under the player, sending them to Underwater, where the "floor" becomes sand and current.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_
