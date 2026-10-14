# Lava (Cinder's Snack): level plans (14 levels)

Lava is "warm ground": the floor itself is the character. It sits still, hides pockets, rises, pops, shakes, slides, and in the finale does all of it. The design doc is `design/levels/lava.md`. It was written for 5x5 to 8x6 boards; every JSON has since been amended to 8x8 (2026-10-13), and the JSONs are the truth here. The mockup arc (`mockup-alignment.md` §2.2) wants:
- **Volcano Dash** (`bridge_dash`) at 03;
- **Frenzy Footholds** (`summit_climb` with rising lava) at 05;
- **Lava Escape** (`floe_survive`) at 08;
- the **Molten Guardian / Smolder** boss at 10;
- **Lava Rumble** at the bonus.

Layer 1 findings, in short:
- The rule set is the strongest of the four biomes here. Lava rise, ember drill, geyser pads, smoke, quake and magma belt all exist in data, and `lava_10` already phases its rules with `active_after_clears`.
- Three problems remain:
  - Two levels use a hardcoded `fixed_list`: `lava_bonus` and `lava_h3`.
  - `lava_h3` is **not winnable** after the 8x8 amendment. Its 7 fixed pieces hold 24 cubes, but clearing layer 0 now needs 50.
  - `lava_04` is the longest main-path level (4 clears, t2 580 s) at tier 4.
- No level uses a minigame block yet. `lava_05` and `lava_08` can take the mockup minigame identity today with existing rules.

## Curve

| id | tier | type | goal | g0 | stars (t2/t3 ms or s2/s3 layers) |
|---|---|---|---|---|---|
| lava_01 | 1 | defender | clear_n 2 | 0.85 | 290000 / 205000 |
| lava_02 | 2 | twist | clear_n 2 | 0.90 | 255000 / 180000 |
| lava_03 | 3 | defender | clear_n 2 | 0.95 | 285000 / 205000 |
| lava_04 | 4 | funny | clear_n 4 | 1.00 | 580000 / 410000 |
| lava_05 | 5 | race | height 10 (cov 0.6), trim | 1.00 | 240000 / 170000 |
| lava_06 | 6 | completing | shape 52 cells, trim | 1.05 | 160000 / 115000 |
| lava_07 | 7 | twist | clear_n 3 | 1.10 | 435000 / 310000 |
| lava_08 | 8 | balance | survive 150 s | 1.15 (+0.15/min) | s2 1 / s3 2 |
| lava_09 | 9 | defender | clear_n 3 | 1.20 | 435000 / 305000 |
| lava_10 | 10 | twist (boss) | clear_n 3 | 1.25 | 440000 / 305000 |
| lava_bonus | 11 | completing (puzzle) | shape 28 cells, fixed list | 0.70 | 100000 / 60000 |
| lava_h1 | 12 | defender | clear_n 3 | 1.30 | 430000 / 305000 |
| lava_h2 | 13 | twist | clear_n 4 | 1.30 | 525000 / 365000 |
| lava_h3 | 14 | twist (puzzle) | clear_n 1, fixed list | 0.80 | 260000 / 170000 |

Curve notes:
- g0 is a clean +0.05 per tier ramp to 1.25, and the hard track is at 1.30, which is correct.
- Length zig-zag: 04 (about 9.7 min at t2) is a spike between short levels. The proposal cuts it to 3 clears.
- All six level types are present in 01–10.

---

### lava_01: Warm Start  (tier 1, defender)

**Play** (layer 1)
- Goal: clear_n 2; default rescue top-out.
- How it plays: This is an open 8x8 campfire ledge with a five-shape bag (i o t l s), so it plays as a classic warm-up. At 60 s the lowest layer bubbles for 3 s and sinks into lava (cubes lost, no credit), at most twice. A player who clears early never sees the lava eat anything. A slow player learns the biome's rule at no real cost.
- Teaches / tests: The lava clock: clear low layers before the floor rises.
- Rules and minigame blocks: `lava_rise` {melt_every_s 60, first_s 60, melt_max 2, melt_warn_ms 3000}.
- Board: 8x8, h_play 8, empty; opening 2 from {o, i}; random bag.
- Difficulty: g0 0.85, stars 290 s / 205 s.
- Proposed changes: none. A gentle rise as the biome's first idea is the right teach.

**Progression role** (layer 1): This is the biome opener. It plants the rising-lava rule that 03, 05 (proposed), 09 and h1 escalate.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_02: Ember Pockets  (tier 2, twist)

**Play** (layer 1)
- Goal: clear_n 2; 1 warning.
- How it plays: A 5x5 crust slab on layer 0 has three 1-cell pockets, each sealed by a lid on layer 1. One piece per bag carries a glowing ember cube. When it locks, the ember melts 1 cube straight down, so stood on end over a lid it drills into the pocket. The slow route also works: fill around the lids and clear layer 1. The board is rotated or mirrored each attempt.
- Teaches / tests: The ember drill, a piece that edits the board.
- Rules and minigame blocks: `ember` {drill_depth 1}; `pieces.tags.ember.per_bag` 1. Variation: 8 symmetries.
- Board: 8x8, h_play 10. Starting slab at x1–5 / z1–5 with 3 pockets and 3 lids; the rest is empty. Opening 2 from {i, i}; bag i o t l s duo tripod.
- Difficulty: g0 0.90, stars 255 s / 180 s.
- Proposed changes: On 8x8 a full layer is 64 cells and the 25-cell slab no longer dominates, so the pocket puzzle is diluted. Extend the slab to fill layer 0 except the 3 pockets (rows 1–6, x1–6, plus the rim), so the pockets are *the* gaps in layer 0 and drilling them clears it immediately. That restores the "aha".

**Progression role** (layer 1): It teaches the ember, which returns as a probe in 07 (smoke) and as the core of h3.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_03: Lava Lane  (tier 3, defender)

**Play** (layer 1)
- Goal: clear_n 2.
- How it plays: The lava rises every 35 s from 40 s, up to 3 times. Meanwhile a centre core (3 HP) takes a telegraphed shot every 18 s (2.5 s warning) unless it is covered. The player has to stack over the core to shield it and also keep low layers clearing before the lava eats them, so two clocks pull in different directions.
- Teaches / tests: Two pressures at once: cover something versus clear fast.
- Rules and minigame blocks: `lava_rise` {35, 40, 3, 3000}; `defend_core` {core_hp 3, attack_every_ms 18000, warn_ms 2500}.
- Board: 8x8, h_play 10, spawn [3,3]. The original 8x3 lane was lost in the 8x8 amendment, so "Lane" no longer describes the board.
- Difficulty: g0 0.95, stars 285 s / 205 s.
- Proposed changes:
  - When modules run, make this **Volcano Dash**:
    ```json
    "board":{"width":12,"depth":8,"h_play":8},
    "modules":[{"id":"bridge_dash","params":{"gap_cells":6,"pillar_height":3,"walk_ms":250},"overlays":[{"id":"rising_hazard","params":{"skin":"lava"}}]}]
    ```
    (`bridge_dash.json` exists and lists the `lava` skin.)
  - Until then, recover the lane with starting_contents: basalt walls (`#`) on z0–1 and z6–7 for layers 0–3. That leaves a 4-wide trench where clears are quick, and it keeps the board 8x8.

**Progression role** (layer 1): This is the first double clock. It escalates 01's lava, and as Volcano Dash it is the biome's first minigame block.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_04: Geyser Pop  (tier 4, funny)

**Play** (layer 1)
- Goal: clear_n 4.
- How it plays: Every 5 locks a steam vent pad appears on the top surface (up to 3; 2 hits to break). A piece landing on a pad hops up 1 and relocks one cell onward in its last move direction. The player learns to *aim* at pads to reach awkward gaps, and to avoid pads that would shove a piece into a bad cell.
- Teaches / tests: A board object that relocates your piece. It is a verb, not a threat.
- Rules and minigame blocks: `mushroom_popup` {objects_max 3, object_kind bounce_pad, hard_hits 2, spawn_every_locks 5}; `bounce_pad` {bounce_h 1, dir_mode last_move}.
- Board: 8x8, h_play 10, empty; 8-shape bag (with duo, tri_corner).
- Difficulty: g0 1.00, stars 580 s / 410 s. This is the longest main-path level and is too long for tier 4.
- Proposed changes: Set `goal.n` 4 → 3 and stars to 435000 / 305000 (the biome's ~145 s per clear rate). Optional: `objects_max` 3 → 4 to make the funny moments more frequent.

**Progression role** (layer 1): This is the comic relief after two clock levels. The pad verb returns as rock spawns in 09/10.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_05: Obsidian Tower  (tier 5, race)

**Play** (layer 1)
- Goal: height h_target 10 with coverage 0.6; trim top-out (cannot fail).
- How it plays: The player builds a lookout tower; layers do not clear. Big Cube (w 0.5) adds 2 layers at once if it lands flat. There is no other pressure, so it is a pure stacking exercise.
- Teaches / tests: Height discipline and coverage.
- Rules and minigame blocks: `build_race`.
- Board: 8x8, h_play 12, empty; i o t l s tripod screw_l big_cube.
- Difficulty: g0 1.00, stars 240 s / 170 s.
- Proposed changes: Make it **Frenzy Footholds** (mockup row 8) with existing data. Add `{"id":"lava_rise","params":{"melt_every_s":60,"first_s":50,"melt_max":2,"melt_warn_ms":3000}}`. Each melt cuts the headroom by 1 (12 → 10), so the height target stays reachable but the race becomes real: build to 10 before the second melt makes trim bite. ★★★ still needs no trimmed cubes. When `summit_climb` exists, swap to it with a `rising_hazard` overlay and the Heat thermometer.

**Progression role** (layer 1): This is the mid-biome race. With rising lava it combines the 01 clock with height building instead of being a calm copy of other biomes' 05.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_06: Marshmallow Roast  (tier 6, completing)

**Play** (layer 1)
- Goal: shape. Fill 52 target cells: two skewers, each a stick and a marshmallow block over layers 0–1. Trim top-out.
- How it plays: Glowing outlines show the picture. The player paints it, keeping layer 0 flat so layer 1 has support. Duo and tri-corner fill the 2-cell stick ends. Cubes outside the outline do nothing. There is no clock.
- Teaches / tests: Reading an outline and placing with precision.
- Rules and minigame blocks: `fill_shape`.
- Board: 8x8, h_play 8, empty; i o t l s tripod duo tri_corner.
- Difficulty: g0 1.05, stars 160 s / 115 s. This is the breather in the biome.
- Proposed changes: Randomise the picture per attempt with `"variation":{"symmetries":["identity","mirror_x","mirror_z","rot180"]}` so the skewers do not sit in the same rows every attempt. No new pressure.

**Progression role** (layer 1): This is the calm completing level between the race and the smoke level, and it rests the player before the 07 to 10 run.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_07: Smoke Screen  (tier 7, twist)

**Play** (layer 1)
- Goal: clear_n 3.
- How it plays: 3.5 s after each placement the stack fades to 10% opacity (1 s fade), and clears reveal it for 0.8 s. The player builds from memory and the landing ghost. The ember piece (1 per bag) shows its melt outline through the smoke, so it doubles as a **probe** that reveals the hidden cells under it.
- Teaches / tests: Memory under hidden information, plus a clever reuse of a known tool.
- Rules and minigame blocks: `fog` {visible_ms 3500, fade_ms 1000, reveal_ms 800, invisible_alpha 0.1}; `ember` {drill_depth 1}, per_bag 1.
- Board: 8x8, h_play 10, empty; 8-shape bag.
- Difficulty: g0 1.10, stars 435 s / 310 s.
- Proposed changes: none. This is a textbook twist (the ember from 02 gets a new use).

**Progression role** (layer 1): This is the "twist" of the ember (02). Smoke is phase 3 of the 10 boss, so it is taught here.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_08: Eruption  (tier 8, balance)

**Play** (layer 1)
- Goal: survive 150 s; speed ramps +0.15 g per minute.
- How it plays: After 25 s of calm, the island rumbles every 30 s (2 s warning). Up to 6 cubes with an empty cell under them (overhangs, roofs over holes) plop into the lava. The player has to stack tight and hole-free while the fall speed climbs.
- Teaches / tests: Structural tidiness (no overhangs).
- Rules and minigame blocks: `quake` {quake_every_s 30, first_s 25, quake_warn_ms 2000, quake_max_cubes 6}.
- Board: 8x8, h_play 10, empty; 8-shape bag.
- Difficulty: g0 1.15 with ramp, stars s2 1 / s3 2 layers. On 8x8, 2 layers in 150 s is a low bar at tier 8.
- Proposed changes:
  - Set stars to s2 2 / s3 3. They were copied from the 5x5 version; 8x8 layers clear more slowly, but the ramp helps.
  - Move toward **Lava Escape** (mockup slot 08): add `crumble_tiles` (existing rule; floor tiles crack under the stack, params per `assets/data/rules/crumble_tiles.json`), so the floor gives way as well as shaking. When `floe_survive` lands, swap to that module.
  - The `balance` type label is loose (no tilt). Relabel to `defender`, or keep it to preserve the six-type mix.

**Progression role** (layer 1): This is the short tense sprint that introduces the quake, which is phase 2 of the boss.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_09: Magma Flow  (tier 9, defender)

**Play** (layer 1)
- Goal: clear_n 3.
- How it plays: Every 3 locks the whole stack slides one cell toward +x and wraps. From 50 s the lava rises every 60 s (2 max). Every 8 locks a rock pops onto the top surface (up to 2; 2 hits). The player reads three known clocks at once and plans placements one slide ahead.
- Teaches / tests: The combine. Everything known so far moves at once.
- Rules and minigame blocks: `conveyor` {+x, every 3, wrap}; `lava_rise` {60, 50, 2}; `lava_rock_spawn` {every_locks 8, objects_max 2, rock, hard_hits 2}.
- Board: 8x8, h_play 12, empty; 8-shape bag.
- Difficulty: g0 1.20, stars 435 s / 305 s.
- Proposed changes: Add `melt_warn_ms` 3000 to `lava_rise`. It is missing here, so the default applies, while every other lava level sets it explicitly. Telegraph consistency matters with 3 clocks running.

**Progression role** (layer 1): This is the pre-boss combine of 01/03 (lava), 04 (objects) and a new conveyor. It mirrors the meadow pattern.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_10: Smolder's Spa  (tier 10, twist, boss)

**Play** (layer 1)
- Goal: clear_n 3 ("three dunks").
- How it plays: The fight runs in three phases:
  1. Smolder kicks bath-bomb rocks onto the stack every 6 locks.
  2. After the first clear, he stomps: a quake every 40 s drops overhangs.
  3. After the second clear, he puffs smoke: the stack fades 4.5 s after each placement.

  The third clear dunks him. The phases come from `active_after_clears`, so the boss escalates with the player's progress.
- Teaches / tests: The finale tests 04 (objects), 08 (quake) and 07 (smoke).
- Rules and minigame blocks: `lava_rock_spawn` {every 6, max 3, rock, hard_hits 2}; `quake` {40 s, active_after_clears 1, warn 2000, max 6}; `fog` {4500, 1000, 800, active_after_clears 2, alpha 0.1}.
- Board: 8x8, h_play 12, empty; i o t l tripod screw_l screw_r chair.
- Difficulty: g0 1.25, stars 440 s / 305 s.
- Proposed changes:
  - Set `"goal":{"type":"bonk_boss","hits":3}`, copying `candy_10`, so Smolder gets a boss bar (mockup "Molten Guardian" boss bar).
  - Add `lava_rise` {melt_every_s 50, first_s 30, melt_max 2, melt_warn_ms 3000}, active from phase 1, so the biome's signature rule is in its own finale. It is currently absent.
  - When `boss_hp` exists, move to it with the same phases.

**Progression role** (layer 1): This is the biome finale and showpiece. Phase-gated rules make it the clearest set piece of the four biomes in this pass.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_bonus: Forge Puzzle  (tier 11, completing)

**Play** (layer 1)
- Goal: shape. Fill a 28-cell anvil: a 4x2 foot on layer 0, a 2x2 waist on layer 1, and an 8x2 face on layer 2. Trim top-out; preview 3.
- How it plays: The pieces arrive in a fixed order (big_cube, duo, duo, i ×4) at g 0.7. The player works out the one stacking order that builds the anvil, using the 3-piece preview.
- Teaches / tests: Spatial planning with a known set.
- Rules and minigame blocks: `fill_shape` {topout_rule trim}; `pieces.fixed_list`.
- Board: 8x8, h_play 6, spawn [3,3].
- Difficulty: g0 0.70, stars 100 s / 60 s.
- Proposed changes: A `fixed_list` breaks the standing rule "the next block is random on every attempt". Convert it to the kit-box pattern already used in `forest_bonus` and `cave_bonus`:
  ```json
  "pieces":{"kit":["big_cube","duo","duo","i","i","i","i"],"shapes":["big_cube","duo","i"]},
  "knobs":{"spawn.arrival":"kit_box", ...},
  "goal":{"type":"shape","piece_budget":7, ...}
  ```
  Remove `fixed_list`. The player picks the order, so the puzzle stays and no sequence is hardcoded. Also add `"variation":{"symmetries":["identity","mirror_x","rot90","rot270"]}` to rotate the anvil.

**Progression role** (layer 1): This is an optional puzzle reward after the boss. A later candidate slot is **Lava Rumble** against bots (mockup row 27) once `floe_survive` exists.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_h1: Lava Rush  (tier 12, defender)

**Play** (layer 1)
- Goal: clear_n 3.
- How it plays: The lava rises fast, every 25 s from 30 s, up to 4 times. That takes the headroom from 10 to 6. Rocks pop every 6 locks (up to 2). The player has to clear low and often while working around rock clutter at g 1.3.
- Teaches / tests: Mastery of the lava clock.
- Rules and minigame blocks: `lava_rise` {25, 30, 4}; `lava_rock_spawn` {6, 2, rock, 2}.
- Board: 8x8, h_play 10, empty; 8-shape bag (screws, no duo).
- Difficulty: g0 1.30, stars 430 s / 305 s.
- Proposed changes:
  - Add `melt_warn_ms` 2500 (shorter than the main path, explicitly set).
  - Restore the "rush" identity with the walled-trench starting_contents proposed for 03 (basalt on z0–1 and z6–7, layers 0–3). Or, when modules exist, make this the hard **Volcano Dash** (`bridge_dash` gap_cells 8 with `rising_hazard`).

**Progression role** (layer 1): This is the first hard remix, pure pressure on the biome's core rule.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_h2: Ash Crust  (tier 13, twist)

**Play** (layer 1)
- Goal: clear_n 4.
- How it plays: Two dense starter layers are pre-built with gaps, and several ash-crusted locked cubes (`k`) sit in them. A locked cube is unlocked when a clear touches it (`locked_cube` defaults). A quake every 40 s (up to 4 cubes) drops overhangs. The player has to find the gaps in a nearly complete stack and fill them without leaving roofs. The layout is rotated or mirrored per attempt.
- Teaches / tests: Reading and finishing an existing messy stack under quake pressure.
- Rules and minigame blocks: `locked_cube`; `quake` {quake_every_s 40, quake_max_cubes 4}. Variation: 8 symmetries.
- Board: 8x8, h_play 10. Starting layers 0–1 are a 6x6 block with gaps and 6 `k` cubes; the rim is empty.
- Difficulty: g0 1.30, stars 525 s / 365 s.
- Proposed changes:
  - Add `quake_warn_ms` 2000 explicitly.
  - Add `jitter` {glyphs "k", radius 1} to the variation, so the locked cubes move between attempts as well as rotating.

**Progression role** (layer 1): This hard twist is "Smash-friendly" (Boulder joined at 10). It is the only Lava level with locked cubes.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### lava_h3: Forge Fixings  (tier 14, twist)

**Play** (layer 1)
- Goal: clear_n 1. The intent is to drill the two lidded holes in a 4x4 slab and complete the layer with 7 fixed pieces (2 of them embers).
- How it plays: As authored for 4x4, the player stands the ember I-pieces on the lids, drills into the holes, then fills out the layer. **On the amended 8x8 board this is not winnable.** Layer 0 has 14 starter cubes, so 50 cells are empty. The 7 pieces hold 24 cubes, and there is no rescue once the list runs out.
- Teaches / tests: The ember drill as a precise puzzle tool.
- Rules and minigame blocks: `ember` {drill_depth 1}; `fixed_list` with `fixed_tags` (embers on the first two).
- Board: 8x8, h_play 6. Starting layer 0 is a 4x4 slab at x2–5 / z2–5 with holes at (3,3) and (4,4); layer 1 has lids over them.
- Difficulty: g0 0.80, stars 260 s / 170 s.
- Proposed changes (**blocking**):
  1. Fill the 8x8 rim on layers 0 and 1 with starter blocks, so only the original 4x4 interior is live: every row of layers 0–1 is `#` outside x2–5 / z2–5. Keep the holes and lids.
  2. Restore `goal.n` 2 (the original design).
  3. Replace `fixed_list`/`fixed_tags` with a kit:
     ```json
     "pieces":{"kit":["i","i","i","i","tri_corner","tri_corner","duo"],"tags":{"ember":{"per_bag":2}}},
     "knobs":{"spawn.arrival":"kit_box"}
     ```
  4. Add `"variation":{"symmetries":["identity","mirror_x","mirror_z","rot90","rot180","rot270"]}`.

  Have someone hand-verify the solution after the change.

**Progression role** (layer 1): This is the cerebral hard-track closer and the ember's mastery exam (02, 07, h3).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_
