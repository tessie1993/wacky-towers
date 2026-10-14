# Forest (Chip's Bridge): level plans (14 levels)

Forest is "the breather" between the heat of Lava and the dark of the Cave. It has the lowest prop density and slow ambient motion. Every level has one friendly disturbance: squirrels, acorns, leaf gusts, a woodpecker, root slides. The boss is a sleepy tree, Grandpa Oak, who is bonked into blossom. The design doc is `design/levels/forest.md`; its 4x4 to 7x5 boards were amended to 8x8 on 2026-10-13, and the JSONs are the truth here. The mockup arc (`mockup-alignment.md` §2.2) wants:
- **Tumbling Towers treetop** (`balance_plate`);
- **Jungle Vine Ascent** (`summit_climb`);
- **Rolling Rumble** (`road_race`) at 08;
- **Goblin Ambush** (`fort_siege` defend) at 09;
- a boss at 10;
- the chaser races **Rolling Idol Run** and **Jungle Dash** on the hard track.

Layer 1 findings, in short:
- Variety in 01–07 is good.
- 08 dips the curve (2 clears at tier 8, after 4 at tier 7).
- 09 and h3 share the same conveyor-plus-heist core.
- The boss (10) has no boss structure: three rules run from the first second and there is no hit bar.
- `forest_06` uses a hardcoded `fixed_list`.
- 04 introduces two new pressures at once (heist and core).
- No level uses a module, although `bridge_dash` exists with a `forest` skin and fits "Stream Crossing" exactly.

## Curve

| id | tier | type | goal | g0 | stars (t2/t3 ms) |
|---|---|---|---|---|---|
| forest_01 | 1 | funny | clear_n 2 (60-cell stump mask) | 0.85 | 245000 / 170000 |
| forest_02 | 2 | twist | clear_n 3 (starter log + shelf) | 0.95 | 285000 / 205000 |
| forest_03 | 3 | twist | clear_n 3 | 0.95 | 430000 / 305000 |
| forest_04 | 4 | defender | clear_n 4 (40-cell fork mask) | 1.00 | 295000 / 210000 |
| forest_05 | 5 | race | height 10 (cov 0.6), trim | 1.05 | 165000 / 115000 |
| forest_06 | 6 | completing (puzzle) | shape 24, budget 6, fixed list | 0.60 | 75000 / 50000 |
| forest_07 | 7 | balance | clear_n 4 | 1.15 | 580000 / 410000 |
| forest_08 | 8 | defender | clear_n 2 | 1.20 | 290000 / 210000 |
| forest_09 | 9 | defender | clear_n 4 | 1.25 | 575000 / 410000 |
| forest_10 | 10 | twist (boss) | clear_n 3 | 1.30 | 435000 / 305000 |
| forest_bonus | 11 | completing (kit) | shape 32, budget 9 | 0.60 | 130000 / 90000 |
| forest_h1 | 12 | twist | clear_n 4 | 1.25 | 535000 / 375000 |
| forest_h2 | 13 | defender | clear_n 3 | 1.25 | 400000 / 285000 |
| forest_h3 | 14 | funny | clear_n 4 | 1.30 | 530000 / 375000 |

Curve notes:
- g0 ramps from 0.85 to 1.30, and the 06 puzzle dip (0.60) is intentional.
- h1 and h2 (1.25) sit below the finale (1.30). The proposal is h1 1.30, h2 1.35, h3 1.35.
- Length spikes at 07 and 09 (about 9.6 min at t2). With 08's 2 clears between them, the 07 to 09 stretch goes long, short, long. The fix is to raise 08 and lower 09.

---

### forest_01: Acorn Shelf  (tier 1, funny)

**Play** (layer 1)
- Goal: clear_n 2; rescue top-out with 2 warnings.
- How it plays: The board is an 8x8 stump top with four knot-holes masked out, which leaves 60 live cells. The player stacks and clears normally, and the knots are natural slots for I and L ends. Every 6 locks the squirrels jumble the upcoming queue, and the preview visibly shuffles. That nudges the player to read the queue again instead of planning far ahead.
- Teaches / tests: The forest tone, a mild queue disruption, and masked cells.
- Rules and minigame blocks: `jumbled_queue` {every 6}.
- Board: 8x8 with a mask (holes at (1,1), (5,1), (1,5), (5,5)), h_play 8, spawn [3,3]; opening 2 from {o, i}; 8-shape bag.
- Difficulty: g0 0.85, stars 245 s / 170 s.
- Proposed changes: Add `"variation":{"symmetries":["identity","mirror_x","mirror_z","rot90"]}` so the knot holes move. A static mask on the opener is a fixed feel.

**Progression role** (layer 1): This is a gentle opener after the Lava finale. The squirrels come back as thieves in 04, 09 and h3.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_02: Hollow Log  (tier 2, twist)

**Play** (layer 1)
- Goal: clear_n 3; 1 warning.
- How it plays: A hollow log is pre-built on layers 0–1: a 6x6 C-shape with a 2x2 cavity. An anchored bark shelf (`H`) sits on layer 2 and holds up without support. The player has to fill the cavity *under* the shelf by sliding pieces in from the side, then complete the layers. Big Cube (w 0.4) and the opening {o, o, tripod} help seal the bed fast.
- Teaches / tests: Anchored shelves and filling under an overhang.
- Rules and minigame blocks: `anchored_shelf` {cells = the layer-2 `H` cells}.
- Board: 8x8, h_play 10. Starting layers 0–2 are inside x1–6 / z1–6; the outer rim is empty.
- Difficulty: g0 0.95, stars 285 s / 205 s.
- Proposed changes: Add `"variation":{"symmetries":["identity","mirror_x","mirror_z","rot90","rot180","rot270"]}` and mirror the `anchored_shelf.cells` list with it (this needs LevelVariation to transform rule cells as well as starting_contents; flag it to programming). Otherwise none.

**Progression role** (layer 1): This is the biome's new board idea (shelf). It returns in h3's design intent ("Canopy Windows").

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_03: Stream Crossing  (tier 3, twist)

**Play** (layer 1)
- Goal: clear_n 3; 1 warning.
- How it plays: Every 5 locks an acorn object drops into the **lowest** open cell (up to 4). It plugs holes the player was saving, which sometimes helps and sometimes blocks. The 8x3 stream lane was lost in the 8x8 amendment, so the "crossing" theme has no shape on the board.
- Teaches / tests: Spawned objects that settle low.
- Rules and minigame blocks: `mushroom_popup` {spawn_every_locks 5, objects_max 4, skin acorn, place_mode lowest}.
- Board: 8x8, h_play 10, spawn [3,3], empty; 8-shape bag.
- Difficulty: g0 0.95, stars 430 s / 305 s.
- Proposed changes: This level should be the forest's first minigame block.
  - Module version:
    ```json
    "board":{"width":12,"depth":8,"h_play":8},
    "modules":[{"id":"bridge_dash","params":{"gap_cells":6,"pillar_cells":2,"pillar_height":3,"walk_ms":300},"overlays":[{"id":"pace_mascot","params":{"skin":"chip"}}]}]
    ```
    The player rebuilds the log bridge across the stream and Chip walks it. `bridge_dash.json` exists and lists the `forest` skin.
  - Fallback with no framework: starting_contents banks, `#` on x0–1 and x6–7 for layers 0–2, so the stream is the 4-wide gap. Keep the acorns at place_mode lowest so they "fall into the stream" and help the player.

**Progression role** (layer 1): This teaches spawned objects (callback to Meadow). As Bridge it gives the biome a sideways-building level early.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_04: Squirrel Branch  (tier 4, defender)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning.
- How it plays: The board is a forked-branch mask with 40 live cells: two prongs at the back, a trunk and a base row. Every 6 locks a squirrel steals a cube from the fullest layer (once it is at least 50% full, 1-lock warning). At the same time a centre core (3 HP) takes a shot every 16 s unless it is covered. Two different pressures arrive in the same level.
- Teaches / tests: Theft from the fullest layer, plus shielding.
- Rules and minigame blocks: `squirrel_heist` {6, 1, 0.5}; `defend_core` {core_hp 3, attack_every_ms 16000, warn_ms 2500}.
- Board: 8x8 with a fork mask, h_play 10, spawn [3,2]; 8-shape bag.
- Difficulty: g0 1.00, stars 295 s / 210 s.
- Proposed changes: Teach one thing. Remove `defend_core` from 04 and move it to 09 (Goblin Ambush, below). Then 04 introduces only the heist (the biome's new rule, EV25), as the design doc's novelty budget intended.

**Progression role** (layer 1): This teaches the squirrel heist. After the change, defence is saved for the 09 set piece.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_05: Treehouse Limb  (tier 5, race)

**Play** (layer 1)
- Goal: height h_target 10 with coverage 0.6; trim (cannot fail).
- How it plays: The player builds up to the treehouse door. Layers do not clear and there is no other pressure. On the amended 8x8 board (originally a narrow 4x4 limb) it is a wide, easy stack, so the "climb a narrow limb" tension is gone.
- Teaches / tests: Height and coverage.
- Rules and minigame blocks: `build_race`.
- Board: 8x8, h_play 12, empty; 8-shape bag.
- Difficulty: g0 1.05, stars 165 s / 115 s. These stars are low for 8x8 coverage of 10 layers (they were set for 4x4), so ★★ is likely unreachable.
- Proposed changes:
  - Recalibrate stars. Coverage 0.6 of 64 cells over 10 layers is about 4x the 4x4 work, so set roughly t2 300000 / t3 215000 pending playtest.
  - Make it **Jungle Vine Ascent** (mockup slot 05): add `{"id":"vines","params":{"vine_per_bag":1}}`. That teaches vine pieces in a no-fail level before 08 tests them against the woodpecker.
  - Add a trunk with starting_contents: `#` at x3–4 / z3–4 on layers 0–5 (or `rock_obstacle` cells, as in `cave_05`), so the player climbs around a limb instead of filling an open plate.

**Progression role** (layer 1): This is the no-fail breather at mid-biome. With vines it becomes the teach step for 08.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_06: Firefly Glade  (tier 6, completing)

**Play** (layer 1)
- Goal: shape. Fill a 24-cell firefly jar (4x4 on layer 0, 2x4 on layer 1) with a piece budget of 6; trim.
- How it plays: The pieces come in a fixed order (l, i, o, l, i, i) at g 0.6 with a 3-piece preview. The player plans the exact packing. It is a hushed puzzle beat.
- Teaches / tests: Exact packing within a budget.
- Rules and minigame blocks: `fill_shape` {topout_rule trim}; `pieces.fixed_list`.
- Board: 8x8, h_play 6; the target is centred at x2–5 / z2–5.
- Difficulty: g0 0.60, stars 75 s / 50 s.
- Proposed changes: `fixed_list` breaks the "next block is random" rule. Replace it with the kit box (precedent: `forest_bonus`):
  ```json
  "pieces":{"kit":["l","l","i","i","i","o"],"shapes":["l","i","o"]},
  "knobs":{"spawn.arrival":"kit_box", ...}
  ```
  Keep `piece_budget` 6. Add `"variation":{"symmetries":["identity","rot90"]}` so the jar orientation changes.

**Progression role** (layer 1): This is the biome's quiet puzzle and a deliberate g0 dip between the race (05) and the busy 07.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_07: Leaf-Swept Branch  (tier 7, balance)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning.
- How it plays: The branch tilts. Once the load is 0.65 off-centre a cube slips. Leaf gusts rotate direction every 9 s (±2.5 s, 1 s warning), so the push changes from side to side. One piece per bag is a maple-seed "dandelion puff" that drifts as it falls. The player keeps the load centred while the wind keeps changing.
- Teaches / tests: Balance under a rotating push. This is the forest's Tumbling Towers.
- Rules and minigame blocks: `gust` {rotating, 9000, 2500, 1, 1000}; `dandelion_puff` {per_bag 1}; `tilt_plate` {0.65, 1, 2}. The intended module is `balance_plate` (treetop skin).
- Board: 8x8, h_play 10, empty; 8-shape bag.
- Difficulty: g0 1.15, stars 580 s / 410 s. It is long.
- Proposed changes: Set `goal.n` 4 → 3 and stars to 435000 / 305000. Three rules for 4 clears is the longest stretch in the biome. Add the `balance_plate` module with the treetop skin when it ships.

**Progression role** (layer 1): This is the balance level. It combines the gust (Meadow) with the tilt (tutorial) before the 08–10 pressure run.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_08: Woodpecker Trunk  (tier 8, defender)

**Play** (layer 1)
- Goal: clear_n 2; 1 warning.
- How it plays: About every 20 s (±2 s, 3 s warning) a woodpecker knocks the trunk and pops up to 2 loose cubes off the stack. One piece per bag is a vine piece that binds the cubes it touches, which protects them from the knock. The player places vines over the area they most need to keep.
- Teaches / tests: Protecting the stack with a special piece.
- Rules and minigame blocks: `woodpecker_knock` {20000, 2000, 3000, pop_max 2}; `vines` {vine_per_bag 1}.
- Board: 8x8, h_play 12, empty; 8-shape bag.
- Difficulty: g0 1.20, stars 290 s / 210 s. Two clears at tier 8 is a dip after 4 at tier 7.
- Proposed changes:
  - Set `goal.n` 2 → 3 and stars to 435000 / 305000.
  - With vines taught in 05 (proposed), this becomes a clean **test**. Optionally set `knock_pop_max` 2 → 3 so vines matter more.
  - Longer term, this slot is **Rolling Rumble** (`road_race`, mockup row 5) once that module exists.

**Progression role** (layer 1): This introduces the knock, which is phase 2 of the boss and the base of h2.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_09: Root-Belt Bank  (tier 9, defender)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning.
- How it plays: Every 3 locks the stack slides one cell toward +x and wraps (root slide). Every 5 locks a squirrel steals from the fullest layer. The player chases a moving target while losing cubes from the near-complete layer.
- Teaches / tests: Combining conveyor and heist.
- Rules and minigame blocks: `conveyor` {every 3, wrap, +x}; `squirrel_heist` {every 5, warn 1}.
- Board: 8x8, h_play 10, empty; 8-shape bag.
- Difficulty: g0 1.25, stars 575 s / 410 s.
- Proposed changes: h3 repeats this core (conveyor plus heist plus jumble). Make 09 the **Goblin Ambush** set piece (mockup slot 09, style/07 "Defend the fort!"), framed as a raider pack:
  - keep `squirrel_heist` {heist_every_locks 6};
  - replace `conveyor` with `defend_core` {core_hp 3, attack_every_ms 14000, warn_ms 2500} (moved from 04);
  - set `goal.n` 3 with stars 435000 / 305000.

  The player shields the treehouse core and finishes layers while raiders steal. Upgrade to `fort_siege` `mode: defend` when built.

**Progression role** (layer 1): This is the pre-boss combine: heist (04) plus defence. It leaves the conveyor fresh for the boss phase.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_10: Oak's Gap  (tier 10, twist, boss)

**Play** (layer 1)
- Goal: clear_n 3; 1 warning.
- How it plays: Three rules run from the first second: roots slide the stack +x every 3 locks, a leaf gust toward +z blows every 10 s, and acorns pop onto the top every 6 locks (up to 3). There is no phase change and no hit feedback, so it plays as a busy remix rather than a fight with Grandpa Oak.
- Teaches / tests: The finale. Everything moves.
- Rules and minigame blocks: `conveyor` {every 3, wrap, +x}; `gust` {fixed +z, 10000, 2500, 1000}; `mushroom_popup` {every 6, max 3, skin acorn}.
- Board: 8x8, h_play 12, empty; i o t l tripod screw_l screw_r chair.
- Difficulty: g0 1.30, stars 435 s / 305 s.
- Proposed changes: Give Oak three "chimes" (phases), using the `lava_10` pattern:
  - `"goal":{"type":"bonk_boss","hits":3}` (from `candy_10`);
  - phase 1: `mushroom_popup` acorns only;
  - phase 2: `gust` with `"active_after_clears":1`;
  - phase 3: `conveyor` with `"active_after_clears":2`;
  - add `woodpecker_knock` {knock_interval_ms 16000, knock_pop_max 2, active_after_clears 2}, so 08's verb appears in the finale.

  Each phase is Oak waking a little more.

**Progression role** (layer 1): This is the biome finale. With phases it pays off 03 (acorns), 07 (gust) and 08 (knock) in order, and introduces the root slide only at the climax.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_bonus: Berry Basket  (tier 11, completing)

**Play** (layer 1)
- Goal: shape. Fill a 32-cell basket (4x4 floor, a 12-cell ring wall, 4 handle posts) with a piece budget of 9; trim.
- How it plays: Pieces arrive in a kit box (o×4, i, l×2, duo×2), and the player chooses which to drop next. The challenge is building the hollow ring wall and posts without wasting a piece. It is calm, at g 0.6.
- Teaches / tests: Hollow shapes and choosing the order of a known set.
- Rules and minigame blocks: `fill_shape` {trim}; `spawn.arrival` kit_box.
- Board: 8x8, h_play 7; the target is centred at x2–5 / z2–5.
- Difficulty: g0 0.60, stars 130 s / 90 s.
- Proposed changes: Add `"variation":{"symmetries":["identity","rot90"]}`. Otherwise none; this is the model the fixed-list levels should copy.

**Progression role** (layer 1): This is an optional post-boss reward. A future slot is **Woodpile Sprint** (`clear_layers`) per the mockup.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_h1: Firefly Night  (tier 12, twist)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning.
- How it plays: It is night. The stack fades to 12% opacity 4 s after each placement, and clears reveal it for 0.6 s. Leaf gusts rotate every 10 s. Every 6 placements an anvil (a falling acorn crate) drops and crushes up to 3 cubes. The player builds from memory against wind and a periodic crush.
- Teaches / tests: Memory plus disruption.
- Rules and minigame blocks: `fog` {4000, 1000, 0.12, 600}; `gust` {rotating, 10000, 2500, 1, 1000}; `anvil_drop` {every 6, max_crush 3}.
- Board: 8x8, h_play 10, empty; 8-shape bag.
- Difficulty: g0 1.25, stars 535 s / 375 s.
- Proposed changes:
  - Set `fall.g0` 1.30 (it must not sit below the finale).
  - Longer term, the hard track should host the mockup chaser races. Make h1 **Rolling Idol Run**: `bridge_dash` (forest skin, gap_cells 8) with a `pace_mascot` boulder as the chaser stand-in, until the chaser overlay (gap table #13) exists.

**Progression role** (layer 1): This is the first hard remix, a fog twist that the main path never used in the Forest.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_h2: Drum Solo  (tier 13, defender)

**Play** (layer 1)
- Goal: clear_n 3; 1 warning.
- How it plays: The woodpecker drums fast: every 13 s (±3 s) with only a 1.5 s warning, popping up to 4 cubes. Vine pieces (1 per bag) protect. Every 4th piece "echoes": a copy of it drops again. That is a free extra piece if the player planned for it and clutter if not.
- Teaches / tests: Mastery of vines against the knock, plus planning for a double drop.
- Rules and minigame blocks: `woodpecker_knock` {13000, 3000, 1500, 4}; `vines` {1}; `echo_drop` {every 4}.
- Board: 8x8, h_play 12, empty; 8-shape bag.
- Difficulty: g0 1.25, stars 400 s / 285 s.
- Proposed changes: Set `fall.g0` 1.35. Add a 1-lock telegraph on the echo (the ghost of the copy is shown), if `echo_drop` lacks one; flag it to programming.

**Progression role** (layer 1): This is the hard test of the 08 verb.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### forest_h3: Squirrel Shuffle  (tier 14, funny)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning; preview 3.
- How it plays: The roots slide the stack every 3 locks, squirrels steal from the fullest layer every 6, and every 5 locks they jumble the 3-piece queue. It is chaotic and silly: plans get scrambled from both ends, the board and the queue.
- Teaches / tests: Adaptability, the finale of the squirrel thread from 01 and 04.
- Rules and minigame blocks: `conveyor` {3, wrap, +x}; `squirrel_heist` {6, 1, 0.5}; `jumbled_queue` {every 5}.
- Board: 8x8, h_play 10, empty; 8-shape bag.
- Difficulty: g0 1.30, stars 530 s / 375 s.
- Proposed changes: Set `fall.g0` 1.35. With 09 changed to Goblin Ambush, this stays the only conveyor-plus-heist level, so no further change is needed.

**Progression role** (layer 1): This is the biome's last word. It brings back the 01 queue jumble as a hard-mode joke.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_
