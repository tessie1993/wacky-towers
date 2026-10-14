# Cave (Nugget's Light): level plans (14 levels)

Cave is "lowest light", the darkest biome, but never scary: lantern pools, glow-moss and crystals. The grid, the falling piece, the ghost and every telegraph stay lit (twist-library rule 8). Its own ideas are **rock inside the board** (`rock_obstacle`, BL18), **echo twins** (`mirror`, PL10) and the **lantern circle** (`fog` with `lantern_radius`). The boss is Geode, the rock golem, who is cracked open into a crystal bird, and Glim joins at the payoff. The design doc is `design/levels/cave.md`; its 4x4 to 8x6 boards were amended to 8x8 on 2026-10-13, and the JSONs are the truth here. The mockup arc (`mockup-alignment.md` §2.2) wants:
- **Digging Frenzy** (`dig_down`) at 03;
- **Rubble Rumble** at 04;
- **Maze Heist** (`route_runner`) at 05;
- a Sprint at 08;
- a **Crystal Golem** boss at 10;
- **Crystal Cart Haul** on the hard track.

Layer 1 findings, in short:
- **Type mix**: five of the ten main levels are `twist`, and there is **no defender until the boss**.
- **The dig verb only appears on the hard track**: `cave_h3` already uses `goal.type: dig_rescue`, the mockup's signature cave game.
- **Clear-count dips**: 08 asks for 2 clears after 06's 4.
- **Fixed list**: `cave_07` uses a hardcoded `fixed_list`.
- **Boss structure**: the boss has no phases.
- **Hard track speed**: g0 sits at 1.30, below the finale's 1.35.

## Curve

| id | tier | type | goal | g0 | stars (t2/t3 ms) |
|---|---|---|---|---|---|
| cave_01 | 1 | balance | clear_n 2 | 0.95 | 290000 / 205000 |
| cave_02 | 2 | twist | clear_n 2 (stalagmite + lip) | 1.00 | 265000 / 190000 |
| cave_03 | 3 | twist | clear_n 2 | 1.05 | 295000 / 205000 |
| cave_04 | 4 | twist | clear_n 4 | 1.10 | 580000 / 410000 |
| cave_05 | 5 | race | height 10 (cov 0.6), trim | 1.15 | 230000 / 160000 |
| cave_06 | 6 | funny | clear_n 4 (mirror x) | 1.20 | 345000 / 250000 |
| cave_07 | 7 | completing (puzzle) | shape 24, budget 3, fixed list | 0.60 | 60000 / 40000 |
| cave_08 | 8 | twist | clear_n 2 | 1.25 | 290000 / 205000 |
| cave_09 | 9 | twist | clear_n 5 (mirror z) | 1.30 | 435000 / 305000 |
| cave_10 | 10 | defender (boss) | clear_n 3 | 1.35 | 435000 / 305000 |
| cave_bonus | 11 | completing (kit) | shape 32, budget 6 | 0.60 | 70000 / 45000 |
| cave_h1 | 12 | twist | clear_n 4 | 1.30 | 580000 / 410000 |
| cave_h2 | 13 | defender | clear_n 4 | 1.30 | 535000 / 375000 |
| cave_h3 | 14 | twist | dig_rescue 3 moles | 1.30 | 170000 / 120000 |

Curve notes:
- g0 rises 0.95 → 1.35 with the 07 puzzle dip.
- The proposal for the hard track is h1 1.35, h2 1.40, h3 1.40.
- The cave starts at 0.95, above the Forest opener (0.85), which fits biome 8.
- Length spikes: 04 (4 clears, about 9.7 min at t2) and 09 (5 clears).

---

### cave_01: Cave Mouth  (tier 1, balance)

**Play** (layer 1)
- Goal: clear_n 2; rescue top-out with 2 warnings.
- How it plays: This is an open 8x8 ledge with a gentle wobble. Off-centre or overhanging loads sway, and only past `wobble_max` 8 does the top cube shift. Clearing is otherwise classic. The player learns that the cave floor is uneven and keeps the stack squat and centred.
- Teaches / tests: The cave tone and mild stability awareness.
- Rules and minigame blocks: `wobble` {wobble_max 8}.
- Board: 8x8, h_play 8, empty; opening 2 from {o, i}; 8-shape bag.
- Difficulty: g0 0.95, stars 290 s / 205 s.
- Proposed changes: none.

**Progression role** (layer 1): This is the biome opener. A light rule keeps it from being "standard rules" (user rule).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_02: Gem Pockets  (tier 2, twist)

**Play** (layer 1)
- Goal: clear_n 2; 1 warning.
- How it plays: Unbreakable rock sits inside the board: a 2-cell stalagmite at (3,3) on layers 0–1 and a 2-cell lip at layer 2 near the back corner. Layers count as complete around the rock. The player fits pieces around and under it; the lip makes an overhang pocket that only some pieces reach. Each attempt rotates or mirrors the rock and jitters it by 1 cell.
- Teaches / tests: Rock inside the board, the cave's board idea.
- Rules and minigame blocks: `rock_obstacle` {cells (3,0,3), (3,1,3), (1,2,1), (2,2,1)}; starting `R`. Variation: 8 symmetries plus jitter on `R`.
- Board: 8x8, h_play 10, spawn [4,4]; opening {o, i}; 8-shape bag.
- Difficulty: g0 1.00, stars 265 s / 190 s.
- Proposed changes: none. This is a good model for per-attempt variation.

**Progression role** (layer 1): It teaches rock cells, which return in 05 (stalagmite column) and h2 (twin stalagmites).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_03: Minecart Ledge  (tier 3, twist)

**Play** (layer 1)
- Goal: clear_n 2; 1 warning.
- How it plays: The whole stack rides a minecart rail. Every 3 locks it slides one cell toward +x and wraps. The player plans each placement for where the gap *will* be after the next slide. The original 8x3 lane is now an open 8x8.
- Teaches / tests: Conveyor shift. It is already known from Lava 09 and Forest 09/10, so it is not new here.
- Rules and minigame blocks: `conveyor` {every 3, wrap, skin minecart, +x}.
- Board: 8x8, h_play 10, spawn [3,3], empty; 8-shape bag.
- Difficulty: g0 1.05, stars 295 s / 205 s.
- Proposed changes: The conveyor is already known by biome 8, so this slot is better spent on the cave's signature game, **Digging Frenzy** (mockup row 15), using data that already works in `cave_h3`:
  ```json
  "goal":{"type":"dig_rescue","critters_needed":2},
  "board":{"width":8,"depth":8,"h_play":10,"starting_contents":{"layers":{
    "0":["########","########","###o####","########","########","#####.##","########","########"],
    "1":["########","##.#####","########","########","#####o##","########","########","##.#####"]}}},
  "variation":{"symmetries":["identity","mirror_x","mirror_z","rot90","rot180","rot270"],"jitter":{"glyphs":"o","radius":1}}
  ```
  The packed earth fills the whole 8x8, with one gap per layer and gems/moles (`o`) to free. Clears dig down. There is no fog yet, because h3 adds the lantern later. Move the minecart conveyor to 10 and h1, where it is already used.

**Progression role** (layer 1): As Digging Frenzy it introduces the cave's core verb (dig), which h3 then tests in the dark. That is a true teach and test pair.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_04: Bat Roost  (tier 4, twist)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning.
- How it plays: Bats flap and push the falling piece one cell. The direction rotates every 9 s (±2.5 s, 1 s warning). Every 6 locks a pebble drops onto the top surface (up to 3), adding small clutter. It is busy but light.
- Teaches / tests: Steering against a rotating push, plus object clutter.
- Rules and minigame blocks: `gust` {rotating, 9000, 2500, 1, 1000, skin bat_flap}; `mushroom_popup` {every 6, max 3, skin pebble}.
- Board: 8x8, h_play 10, empty; 8-shape bag.
- Difficulty: g0 1.10, stars 580 s / 410 s. This is the longest main-path cave level and comes at tier 4.
- Proposed changes:
  - Set `goal.n` 4 → 3 and stars to 435000 / 305000.
  - Fix the missing defender. Replace the pebble `mushroom_popup` with `{"id":"defend_core","params":{"core_hp":3,"attack_every_ms":16000,"warn_ms":2500}}`: shield Nugget's lamp from bat droppings. Relabel `level_type` to `defender`.
  - The pebbles stay in h2, and Rubble Rumble (mockup row 3) can be served by h2.

**Progression role** (layer 1): After the change, this gives the main path a defender before the boss and keeps 01–05 type-varied (balance, twist, twist/dig, defender, race).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_05: Stalagmite Climb  (tier 5, race)

**Play** (layer 1)
- Goal: height h_target 10 with coverage 0.6; trim (cannot fail).
- How it plays: A rock stalagmite column runs at (3,3) on layers 0–6. The player builds up around it toward the daylight crack. The column is free support for overhangs near it, but it splits the floor, so coverage needs pieces that wrap around it. Layers do not clear.
- Teaches / tests: Height building around fixed rock.
- Rules and minigame blocks: `build_race`; `rock_obstacle` {column at x3 z3, y0–6}.
- Board: 8x8, h_play 12, spawn [2,2]; 8-shape bag.
- Difficulty: g0 1.15, stars 230 s / 160 s. Like Forest 05, these stars are likely too tight for 8x8 coverage (they were set for 5x5).
- Proposed changes:
  - Recalibrate stars to about t2 360000 / t3 255000, pending playtest.
  - Add the `cave_02` variation block (symmetries plus jitter radius 1 on `R`), so the column moves.
  - Future slot: **Maze Heist** (`route_runner`) once it exists; `key_stamp` (an existing rule) is the likely stand-in to prototype.

**Progression role** (layer 1): This is the mid-biome no-fail breather, and it callbacks the 02 rock.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_06: Crystal Chamber  (tier 6, funny)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning.
- How it plays: The crystal wall copies every placement mirrored across x. One piece fills two spots, so layers fill twice as fast, but a misplacement is also doubled. The player learns to use the mirror: build on one half and let the echo finish the other.
- Teaches / tests: Echo twins (mirror).
- Rules and minigame blocks: `mirror` {mirror_axis x, skin crystal_echo}.
- Board: 8x8, h_play 10, spawn [2,3], empty; 8-shape bag.
- Difficulty: g0 1.20, stars 345 s / 250 s.
- Proposed changes: none.

**Progression role** (layer 1): This teaches the mirror, which is tested in 07 (puzzle), 09 (on the other axis, in the dark) and the bonus.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_07: Twin Gems (puzzle)  (tier 7, completing)

**Play** (layer 1)
- Goal: shape. Fill 24 cells (a 4x4 floor and a 4x2 cap) with a budget of 3 pieces, mirrored across x; trim.
- How it plays: Three fixed pieces (l, l, o) at g 0.6 with a 3-piece preview. Each placement is mirrored, so 12 cubes fill 24 cells. The player must find the one placement per piece whose echo also lands inside the gem.
- Teaches / tests: Mirror planning as a puzzle.
- Rules and minigame blocks: `fill_shape` {trim}; `mirror` {x}; `pieces.fixed_list`.
- Board: 8x8, h_play 6; the target is centred at x2–5 / z2–5.
- Difficulty: g0 0.60, stars 60 s / 40 s.
- Proposed changes: Replace `fixed_list` with a kit: `"pieces":{"kit":["l","l","o"],"shapes":["l","o"]}` and `"knobs":{"spawn.arrival":"kit_box", ...}`. Keep budget 3. That satisfies the no-hardcoded-sequence rule and keeps the puzzle.

**Progression role** (layer 1): This is the quiet puzzle dip between 06 and the dark 08–10 run.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_08: Pitch-Dark Gallery  (tier 8, twist)

**Play** (layer 1)
- Goal: clear_n 2; 1 warning.
- How it plays: The lamp is out. Placed cubes fade to 12% opacity 3 s after placement. Only a lantern circle of radius 1 around the falling piece lights the stack under it, so the player "feels" the surface by sweeping the piece over it before dropping.
- Teaches / tests: The lantern circle, local vision.
- Rules and minigame blocks: `fog` {visible_ms 3000, fade_ms 800, alpha 0.12, reveal_ms 600, lantern_radius 1, skin lantern_circle}.
- Board: 8x8, h_play 10, empty; 8-shape bag.
- Difficulty: g0 1.25, stars 290 s / 205 s. Two clears at tier 8 is a dip.
- Proposed changes: Set `goal.n` 2 → 3 and stars to 435000 / 305000.

**Progression role** (layer 1): This teaches the lantern circle, which 09, 10 and h3 build on.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_09: Echo Hall  (tier 9, twist)

**Play** (layer 1)
- Goal: clear_n 5; 1 warning.
- How it plays: The mirror now works across z, a new axis, and the stack is dark with lantern radius 1. Every placement echoes front to back, and the player can only see the echo's landing area when the lantern passes over it. The player must trust the mirror rule without seeing both halves.
- Teaches / tests: The combine: mirror (06) plus lantern (08).
- Rules and minigame blocks: `mirror` {z, crystal_echo}; `fog` {3500, 800, 0.12, 700, lantern_radius 1, lantern_circle, mirror_axis z}.
- Board: 8x8, h_play 10, empty; 8-shape bag.
- Difficulty: g0 1.30, stars 435 s / 305 s.
- Proposed changes: Set `goal.n` 5 → 4 and keep the stars. Five clears at max density is the longest grind of the run. Optionally show the echo ghost through the fog (the mirror landing preview should never be faded: rule 8).

**Progression role** (layer 1): This is the pre-boss combine.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_10: Geode's Hollow  (tier 10, defender, boss)

**Play** (layer 1)
- Goal: clear_n 3; 1 warning.
- How it plays: Three rules run from the first second:
  - the minecart rail slides the stack +x every 3 locks;
  - Geode stomps every 14 s (±3 s, 1.5 s warning), popping up to 3 cubes;
  - the lantern chain darkens the stack (fade at 5 s, radius 2).

  Geode has no hit bar or phases, so it feels like a hard remix and not a golem fight.
- Teaches / tests: The finale.
- Rules and minigame blocks: `conveyor` {3, wrap, minecart, +x}; `woodpecker_knock` {14000, 3000, 1500, 3, skin geode_stomp}; `fog` {5000, 1000, 0.15, 800, lantern_radius 2, lantern_chain}.
- Board: 8x8, h_play 12, empty; i o t l tripod screw_l screw_r chair.
- Difficulty: g0 1.35, stars 435 s / 305 s.
- Proposed changes: Give Geode a three-phase boss arc, using the `lava_10` pattern:
  - `"goal":{"type":"bonk_boss","hits":3}` (from `candy_10`);
  - phase 1: `woodpecker_knock` stomps only, so Geode wakes;
  - phase 2: `conveyor` minecart with `"active_after_clears":1`, as he kicks the rails;
  - phase 3: `fog` lantern chain with `"active_after_clears":2`, as the lantern swings onto his nose;
  - optionally `mirror` {x} as a crystal-echo phase in place of the conveyor, if the conveyor is felt to be biome-foreign.

  Rename the boss bar to Crystal Golem / Geode. Upgrade to `boss_hp` when built.

**Progression role** (layer 1): This is the finale. With phases it pays off the stomp (new as a boss verb), the rail and the lantern (08) in an escalating order.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_bonus: Treasure Map  (tier 11, completing)

**Play** (layer 1)
- Goal: shape. Fill a 32-cell 4x4x2 block (the X on the map) with a budget of 6 pieces, mirrored across x; trim.
- How it plays: The kit box offers o, i, o, i, t, s, and the player chooses the order. Each placement is mirrored, so the player picks pieces whose echo also fits. The S and T are the traps: their mirrors flip handedness.
- Teaches / tests: Mirror plus choice of order.
- Rules and minigame blocks: `fill_shape` {trim}; `mirror` {x}; kit_box arrival.
- Board: 8x8, h_play 6; the target is centred.
- Difficulty: g0 0.60, stars 70 s / 45 s.
- Proposed changes: none (it already uses a kit, not a fixed list). A future slot is **Mine Bomb** (`ring_defuse`) per the mockup.

**Progression role** (layer 1): This is an optional post-boss reward, and the first place Glim's Redraw could appear (it does nothing on kit levels, per the design doc).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_h1: Runaway Cart  (tier 12, twist)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning.
- How it plays: The rail speeds up: the stack slides every 2 locks. Bats push the piece toward +z every 10 s. The player plans two moves ahead along x while correcting along z.
- Teaches / tests: Mastery of the conveyor.
- Rules and minigame blocks: `conveyor` {every 2, wrap, minecart, +x}; `gust` {fixed +z, 10000, 2500, 1000, bat_flap}.
- Board: 8x8, h_play 10, empty; 8-shape bag.
- Difficulty: g0 1.30, stars 580 s / 410 s.
- Proposed changes: Make it **Crystal Cart Haul** (mockup row 29) with existing data:
  - add `{"id":"star_coins", ...}` (an existing rule, skinned as gems riding in the carts); ★★★ needs all gems collected (`three_star_zero_metrics ["coins_missed"]`, as in `minigame-stages.md` 1.9);
  - set `goal.n` 3 with stars 435000 / 305000;
  - set `fall.g0` 1.35.

**Progression role** (layer 1): This is the first hard remix. With gems it is a distinct objective, not just a faster belt.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_h2: Cave-In  (tier 13, defender)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning.
- How it plays: Two 3-tall rock stalagmites stand at (2,2) and (5,5); per-attempt symmetry plus jitter moves them. Geode's stomp every 15 s pops up to 3 loose cubes, and pebbles drop every 7 locks. The player builds tight, hole-free layers between fixed rock while debris and quakes chip at them. This is Rubble Rumble in all but name.
- Teaches / tests: Rock plus stomp plus clutter.
- Rules and minigame blocks: `woodpecker_knock` {15000, 3000, 1500, 3, geode_stomp}; `mushroom_popup` {7, 3, pebble}; `rock_obstacle` {two columns y0–2}. Variation: 8 symmetries plus jitter on `R`.
- Board: 8x8, h_play 10, spawn [3,3]; 8-shape bag.
- Difficulty: g0 1.30, stars 535 s / 375 s.
- Proposed changes: Set `fall.g0` 1.40. Consider renaming the catalog display to **Rubble Rumble** to bind the mockup title (the name key stays).

**Progression role** (layer 1): This is the hard defender. It recombines 02's rock with the boss's stomp.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### cave_h3: Mole Rescue  (tier 14, twist)

**Play** (layer 1)
- Goal: dig_rescue, 3 moles (`critters_needed` 3).
- How it plays: Three dense 6x6 starter layers sit on the 8x8, each with gaps and a trapped mole (`o`). The rim is empty. Clears dig down, and freeing a mole's layer rescues it. The lantern circle (radius 1, fade at 3 s) means the player probes the dirt with the falling piece to find the gaps.
- Teaches / tests: The dig verb in the dark, the cave's mastery exam.
- Rules and minigame blocks: `fog` {3000, 800, 0.12, 600, lantern_radius 1, lantern_circle}.
- Board: 8x8, h_play 10; starting layers 0–2 at x1–6 / z1–6 with moles at (2,3,0), (4,3,1), (3,4,2).
- Difficulty: g0 1.30, stars 170 s / 120 s.
- Proposed changes:
  - Add the `cave_02`-style variation block (8 symmetries, jitter on `o` radius 1). The moles are always in the same cells now.
  - Set `fall.g0` 1.40.
  - If 03 becomes Digging Frenzy, this is its test: the same verb with darkness, 3 targets and a higher speed.

**Progression role** (layer 1): This is the hard-track closer and pairs with the proposed 03 Digging Frenzy (teach in the light, test in the dark).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_
