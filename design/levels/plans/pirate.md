# Pirate Cove: level plans (14 levels)

Pirate Cove is the 11th main biome. It comes after Underwater (decision 2026-10-14) and has no biome design doc of its own. The sources are `design/levels/mockup-alignment.md` §2.2–2.3 and `design/decisions/2026-10-14-story-cast-decisions.md`. It introduces **no new primary module**: `fort_siege`, `balance_plate`, `bridge_dash` and `boss_hp` are all known by the time the player gets here. Its job is **combination under sea pressure**. The tide rocks the raft, cannonballs stick, tentacles pinch and parrots steal. The finale is the Rainbow Kraken. The defender hook is `crab_claw`, reskinned as tentacles.

Layer 1 findings, in short:
- The data borrows heavily from Underwater. `pirate_05` copies `underwater_05`, `pirate_08` copies `underwater_08`, and `pirate_10` and `pirate_h1` both use the `underwater_10` pairing.
- The Kraken appears four times with almost the same rules (04, 10, h1, h3).
- The hard track runs **slower** than the finale (g0 1.15–1.2 against 1.2).
- Every level uses `mus_underwater_default`.
- None of the 14 levels uses a module, although `assets/data/modules/bridge_dash.json` exists and lists a `pirate` skin.

The proposed changes below turn these into a teach, twist, combine, boss arc.

## Curve

| id | tier | type | goal | g0 | stars (t2/t3 ms or s2/s3 layers) |
|---|---|---|---|---|---|
| pirate_01 | 1 | funny | clear_n 2 | 0.80 | 290000 / 205000 |
| pirate_02 | 2 | twist | clear_n 3 | 0.85 | 435000 / 310000 |
| pirate_03 | 3 | balance | clear_n 3 | 0.90 | 435000 / 310000 |
| pirate_04 | 4 | defender | clear_n 3 | 0.95 | 435000 / 305000 |
| pirate_05 | 5 | race | height 10 (cov 0.6), trim | 0.95 | 265000 / 185000 |
| pirate_06 | 6 | completing | clear_n 3 (hull frame) | 1.00 | 380000 / 270000 |
| pirate_07 | 7 | funny | clear_n 4 | 1.05 | 580000 / 410000 |
| pirate_08 | 8 | defender | survive 150 s | 1.10 (+0.1/min) | s2 1 / s3 2 |
| pirate_09 | 9 | twist | clear_n 4 vs rival | 1.15 | 580000 / 410000 |
| pirate_10 | 10 | defender (boss) | clear_n 4 | 1.20 | 580000 / 410000 |
| pirate_bonus | 11 | completing | clear_n 3 (gold row) | 1.10 | 400000 / 285000 |
| pirate_h1 | 12 | defender | clear_n 4 | 1.15 | 535000 / 375000 |
| pirate_h2 | 13 | twist | clear_n 3 vs rival | 1.15 | 400000 / 285000 |
| pirate_h3 | 14 | defender | clear_n 4 | 1.20 | 535000 / 375000 |

Curve notes:
- g0 rises smoothly from 0.80 to 1.20 on the main path, with a flat step at 04–05.
- The hard track never exceeds the finale. The proposal is h1 1.25, h2 1.25, h3 1.30.
- Clear-count stars follow about 145 s / 103 s per clear, so they are consistent.

Biome-wide proposed change: set `music` to `pirate_01`…`pirate_h3` placeholder ids in every JSON. The current `mus_underwater_default` makes the biome sound like the previous one, which mockup-alignment §2.3 rules out (it asks for a squeeze-box shanty).

---

### pirate_01: Parrot Drop  (tier 1, funny)

**Play** (layer 1)
- Goal: clear_n 2; rescue top-out with 2 warnings.
- How it plays: The player stacks on an open 8x8 beach. Once per bag, the pirate's parrot grabs a piece and carries it down slowly (balloon, g × 0.6, 3 s drift). That gives the player time to line it up over a hole. There is no threat; the parrot is a helper that shows off precise placement.
- Teaches / tests: The cove's tone, and that some pieces arrive "carried" so they can be placed carefully.
- Rules and minigame blocks: `mascot_hint` (onboarding); `balloon` {balloon_per_bag 1, balloon_g_mult 0.6, balloon_drift_ms 3000}, skinned as a parrot carry. No module.
- Board: 8x8, h_play 10, empty; random bag of 8 shapes (i o t l s tripod screw_l screw_r); opening 2 from {o, i}; seed null.
- Difficulty: g0 0.80, stars 290 s / 205 s. This is the calmest point in the biome.
- Proposed changes: `music` → `pirate_01`. Otherwise none.

**Progression role** (layer 1): This is the arrival breather after the Underwater finale. It is helper-flavoured on purpose, so the next two levels can add pressure (sticky cannonballs, then the tide).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_02: Cannonball Beach  (tier 2, twist)

**Play** (layer 1)
- Goal: clear_n 3; rescue top-out with 1 warning.
- How it plays: Six locks in, soft practice cannonballs start to plop down every 5 locks (up to 5) and stick where they land. Each one is a 1-cell obstacle the player must build around or bury inside a layer that is about to clear. The skill is reading the landing marker and choosing whether a ball "plugs" a hole or "spoils" a flat.
- Teaches / tests: Foreign objects on the board that you clear around. This is the seed of Fort Blast ammo.
- Rules and minigame blocks: `gumdrop_hail` {object gumdrop → cannonball skin, sticky true, spawn_every_locks 5, objects_max 5, hail_after_locks 6}. The intended module is `siege_shot` (not built).
- Board: 8x8, h_play 10, empty; random 8-shape bag.
- Difficulty: g0 0.85, stars 435 s / 310 s. A gentle first twist.
- Proposed changes: `music` → `pirate_02`. Optional: set `objects_max` to 4 so the 8x8 does not clutter before the first clear.

**Progression role** (layer 1): This introduces the cannonball object that returns, combined with other rules, in 09 and h2. It sits before the balance level so the two twists are learned separately.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_03: Tumbling Towers  (tier 3, balance)

**Play** (layer 1)
- Goal: clear_n 3; default top-out.
- How it plays: The board is a raft rocking on the tide. `tilt_plate` tracks the load's centre of mass, and once the load passes 0.65 off-centre, one cube slips. A steady sea breeze (wind toward −x every 3.5 s ±0.5 s, 600 ms warning) pushes the falling piece, so the player has to place against the wind to keep the raft level. Clears relieve the weight.
- Teaches / tests: Load balancing against a constant directional push. This is the biome's signature balance level (mockup row 6).
- Rules and minigame blocks: `gust` {wind_mode fixed, wind_dir −x, wind_interval_ms 3500, jitter 500, strength 1, warn 600}; `tilt_plate` {slip_threshold 0.65, slip_count 1, slip_after_resolves 2}. The intended module is `balance_plate` on Jolt (flag F2); the grid tilt is the fallback.
- Board: 8x8, h_play 10, empty raft; random bag.
- Difficulty: g0 0.90, stars 435 s / 310 s. The wind every 3.5 s is the fastest gust in the biome, which is a lot at tier 3.
- Proposed changes:
  - Set `wind_interval_ms` 3500 → 5000 and `wind_warn_ms` 600 → 1000. Tier 3 should read the gust, not fight it.
  - When the module framework lands, add `"modules":[{"id":"balance_plate","params":{"skin":"pirate_raft"}}]` and a `vertical_gauge` Balance/Danger thermometer (mockup row 6).
  - `music` → `pirate_03`.

**Progression role** (layer 1): Balance was taught on the tutorial island; this re-skins it with a wind twist. It is the "T" of the arc whose combine is h2 (deck tilt plus rival).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_04: Tentacle Tickle  (tier 4, defender)

**Play** (layer 1)
- Goal: clear_n 3.
- How it plays: Once the stack is 2 layers tall, a shy baby tentacle rises from the shallows about every 22 s (±4 s). Its 2.5 s telegraph is a ripple and a shadow on the target column, and then it pinches one cube off the stack. Clearing a layer resets its counter (it is shooed away). The player learns to keep the vulnerable layer short-lived by clearing fast, and to avoid leaving one-cube "handles" sticking out.
- Teaches / tests: A timed thief that clears push back. This foreshadows the Kraken.
- Rules and minigame blocks: `crab_claw` {claw_start_layers 2, claw_every_ms 22000, claw_jitter_ms 4000, claw_warn_ms 2500, claw_grab 1, counter clear}, with a tentacle skin.
- Board: 8x8, h_play 10, empty; random bag.
- Difficulty: g0 0.95, stars 435 s / 305 s. This is the first real defender and is softer than `underwater_10`.
- Proposed changes: `music` → `pirate_04`. Otherwise none; this is the right teach level for the finale.

**Progression role** (layer 1): It teaches the Kraken's verb at low intensity, so the 10 boss is a payoff and not a surprise. It sits between balance (03) and race (05) to vary the type.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_05: Crow's Nest Race  (tier 5, race)

**Play** (layer 1)
- Goal: height h_target 10 with layer coverage 0.6; trim top-out (cannot fail).
- How it plays: The player builds a lookout mast up to the crow's nest marker. Layers do not clear (`build_race`). Wind toward +x every 6 s ±2 s nudges pieces, so the mast drifts if the player does not compensate. Duo pieces (weight 0.5) let the player patch coverage gaps cheaply.
- Teaches / tests: Height building and coverage discipline.
- Rules and minigame blocks: `build_race`; `gust` {wind_dir +x, interval 6000, jitter 2000, warn 1000}.
- Board: 8x8, h_play 12, empty; 8 shapes plus duo (w 0.5).
- Difficulty: g0 0.95, stars 265 s / 185 s. This is a no-fail breather, but it is a copy of `underwater_05`.
- Proposed changes: Make it a real race. Add `{"id":"race_rival","params":{"rival_rate":0.2,"rubber_band":0.6,"rival_warn_pct":80}}`, skinned as gulls building a rival nest on the next mast. This also introduces `race_rival` alone before 09 combines it with cannonballs. Keep trim, so losing the race costs only stars: map the rival's finish to the ★★ fail and not to level fail (needs a `race_rival` "stars_only" option, or accept a fail state at tier 5). `music` → `pirate_05`.

**Progression role** (layer 1): This is the mid-biome breather with no top-out. With the gull rival it becomes the teach step for 09 Fort Blast.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_06: Hull Patch  (tier 6, completing)

**Play** (layer 1)
- Goal: clear_n 3; rescue top-out with 1 warning.
- How it plays: A wrecked hull frame is pre-built on the 8x8. Layer 0 is a 6x6 rectangular ring; layer 1 holds the corner ribs. The player fills the interior "planking" and the outer rim. The frame gives natural walls to slot pieces against, so it plays as a satisfying fill-in puzzle under mild speed. Each finished deck clears.
- Teaches / tests: Reading pre-placed structure and filling around it efficiently.
- Rules and minigame blocks: none (starting_contents only). No module.
- Board: 8x8, h_play 10. Starting layer 0 is a ring at x/z 1–6; layer 1 has corner ribs. Pieces are random, but there is **no per-attempt layout variation**, so every attempt has an identical frame.
- Difficulty: g0 1.00, stars 380 s / 270 s.
- Proposed changes:
  - Add `"variation":{"symmetries":["identity","mirror_x","mirror_z","rot90","rot180","rot270"],"jitter":{"glyphs":"#","radius":1}}` so the rib gaps move between attempts (the standing rule is no fixed board feel).
  - Add `gumdrop_hail` {spawn_every_locks 8, objects_max 2, hail_after_locks 10}, skinned as barnacles, as a light callback to 02. With no rules at all, this is the only "standard rules" level in the biome.
  - `music` → `pirate_06`.

**Progression role** (layer 1): This is the calm completing level after the race and before the parrot chaos of 07. It rests the player before the tense 08 to 10 run.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_07: Parrot Pilfer  (tier 7, funny)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning.
- How it plays: Every 6 locks a cheeky parrot squawks one lock ahead, swoops, and steals a block from the fullest layer, as long as that layer is at least 50% full. That punishes the "nearly complete" layer the player was building. The counter-play is to finish layers quickly, or to keep two layers at similar fill so the theft does not land on the one about to clear.
- Teaches / tests: Managing which layer is fullest, a heist that targets your progress.
- Rules and minigame blocks: `squirrel_heist` {heist_every_locks 6, heist_warn_locks 1, heist_min_fill 0.5}, with a parrot skin.
- Board: 8x8, h_play 10, empty; random bag.
- Difficulty: g0 1.05, stars 580 s / 410 s. This is a long level (4 clears).
- Proposed changes: Callback the 01 parrot by adding `balloon` {balloon_per_bag 1} (same parrot, now on both sides: it carries one piece and steals another). This raises funny value with no new verb. `music` → `pirate_07`.

**Progression role** (layer 1): The comic beat before the pressure run. It reuses the parrot character from 01 in an antagonistic role (a twist on a known element).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_08: Sinking Deck  (tier 8, defender)

**Play** (layer 1)
- Goal: survive 150 s (fall ramps +0.1 g per minute).
- How it plays: Every 10 locks the tide adds a junk layer at the bottom with 3 gaps (1-lock warning). The stack rises toward the danger line at h_play 8, which is the lowest ceiling in the biome. The player has to keep clearing tide layers through their gaps to stay afloat until the rescue boat arrives.
- Teaches / tests: Survival under a rising floor.
- Rules and minigame blocks: `rising_silt` {silt_every_locks 10, silt_gaps 3, silt_warn_locks 1}, with a seawater skin.
- Board: 8x8, h_play 8, empty; random bag.
- Difficulty: g0 1.10 with ramp, stars s2 1 / s3 2 layers. This is a copy of `underwater_08` (same rule, same params), so it repeats the previous biome.
- Proposed changes: Replace it with **Plank Bridge** per mockup-alignment §2.2 slot 08. `assets/data/modules/bridge_dash.json` exists and lists a `pirate` skin:
  ```json
  "board":{"width":12,"depth":8,"h_play":8},
  "modules":[{"id":"bridge_dash","params":{"gap_cells":6,"pillar_cells":2,"pillar_height":3,"walk_ms":300,"hold_ms":500},
              "overlays":[{"id":"rising_hazard","params":{"skin":"tide"}}]}],
  "goal":{"type":"span"}
  ```
  The player drops planks across a harbour gap between two pier pillars while the tide rises. The pirate walks the finished deck. Until the module framework runs, keep `rising_silt` but change it so it is not an `underwater_08` clone: silt_every_locks 8, silt_gaps 2, h_play 10. `music` → `pirate_08`.

**Progression role** (layer 1): This is the first high-pressure level of the run to the boss. As Plank Bridge it is also the biome's only sideways-building level, which gives real variety before the 09/10 stacking set pieces.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_09: Fort Blast  (tier 9, twist)

**Play** (layer 1)
- Goal: clear_n 4 before the rival fort finishes; 1 warning.
- How it plays: A rival ship's fort builds across the bay (`race_rival` at rate 0.2, rubber band 0.5, with a warning at 80%). The player races to make 4 clears. Each clear is meant to load a soft cannonball, but no projectile exists yet, so today this plays as a plain clear race with a progress bar.
- Teaches / tests: Racing a visible opponent.
- Rules and minigame blocks: `race_rival` {rival_rate 0.2, rubber_band 0.5, rival_warn_pct 80}. The intended modules are `fort_siege`, `siege_shot` and `material_hp` (none built).
- Board: 8x8, h_play 10, empty; random bag.
- Difficulty: g0 1.15, stars 580 s / 410 s.
- Proposed changes: Make this the **combine** level. Add `gumdrop_hail` {object cannonball, sticky true, spawn_every_locks 5, objects_max 4, hail_after_locks 4}, so the rival "fires back": its cannonballs land on the player's board, which is the 02 verb. With rival 0.2 (from 05) plus cannonballs (from 02), the level reads as Fort Blast before `fort_siege` exists. When `fort_siege` lands, swap to `"modules":[{"id":"fort_siege","params":{"skin":"pirate","rival":"bot_ship"}}]`. `music` → `pirate_09`.

**Progression role** (layer 1): The pre-boss combine: race (05) plus cannonballs (02). With the change, h2 must differ (see h2).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_10: Kraken Blockade  (tier 10, defender, boss)

**Play** (layer 1)
- Goal: clear_n 4 ("four bonks"); default top-out.
- How it plays: The Rainbow Kraken blocks the bay. Tentacles pinch a cube every 18 s (±4 s, 2 s warning) once the stack is 2 layers tall, and spray gusts push pieces toward +z every 8 s. Each clear is narrated as a bonk. Both rules run from the first second, so there are no phases and the Kraken has no health bar. Mechanically it is `pirate_04` plus wind.
- Teaches / tests: A test of tentacle defence (04) under wind (03/05).
- Rules and minigame blocks: `gust` {wind_dir +z, interval 8000, jitter 2000, warn 1000}; `crab_claw` {start 2, every 18000, jitter 4000, warn 2000, grab 1, counter clear}. The intended module is `boss_hp`.
- Board: 8x8, h_play 12, empty; 8 shapes plus duo (w 0.5).
- Difficulty: g0 1.20, stars 580 s / 410 s. This is the peak of the main curve.
- Proposed changes: Give it a boss structure using goals and params that already exist:
  - `"goal":{"type":"bonk_boss","hits":4}` (the goal type exists in `candy_10`; copy its param names). The boss bar fills from clears.
  - Phase the rules with `active_after_clears` (already used in `lava_10`):
    - phase 1: tentacles only;
    - phase 2 (`active_after_clears`:1): + `gust` spray;
    - phase 3 (`active_after_clears`:2): + `fog` ink {visible_ms 4500, fade_ms 1000, invisible_alpha 0.1, reveal_ms 700};
    - final hit (`active_after_clears`:3): tentacle `claw_every_ms` 12000.
  - Remove `duo` from the bag. It softens a finale.
  - `music` → `pirate_10`.

**Progression role** (layer 1): This is the biome finale and pays off 04 (tentacle), 03 (wind) and h3's ink. With phases it becomes a three-act set piece, as `lava_10` is.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_bonus: Treasure Hoard  (tier 11, completing)

**Play** (layer 1)
- Goal: clear_n 3, with a gold-row counter; rescue top-out with 1 warning.
- How it plays: Layer 1 is a glittering treasure layer. Completing it banks a +200 bonus and ticks a gold counter. Play is standard clearing with a visible "fill this one" target. It is a calm reward after the Kraken.
- Teaches / tests: Prioritising a specific layer.
- Rules and minigame blocks: `golden_row` {start_layer 1, bonus 200, goal_counter gold}. The intended module is `fort_siege` (target: shared_tower), for Shatter Shootout against a bot ship.
- Board: 8x8, h_play 10, empty; random bag.
- Difficulty: g0 1.10, stars 400 s / 285 s.
- Proposed changes:
  - Add a light thief to make the gold row tense and funny: `squirrel_heist` {heist_every_locks 7, heist_min_fill 0.6}, with a parrot skin. The parrot goes for the gold.
  - When `fort_siege` with `target: shared_tower` is built, this slot becomes **Shatter Shootout** (mockup row 7) and Treasure Hoard moves to the reward scene.
  - `music` → `pirate_bonus`.

**Progression role** (layer 1): This is the optional reward after the finale. It should be a breather with one twist and not a test.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_h1: Kraken Blockade II  (tier 12, defender)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning.
- How it plays: This is the same fight as pirate_10 with tentacles every 16 s and spray every 7 s. It plays almost identically to the finale at slightly lower speed (g0 1.15 against 1.20).
- Teaches / tests: Mastery of the finale.
- Rules and minigame blocks: `gust` {+z, 7000, 2000, 1000}; `crab_claw` {start 2, every 16000, jitter 4000, warn 2000, grab 1, counter clear}.
- Board: 8x8, h_play 12; random bag (no duo).
- Difficulty: g0 1.15, stars 535 s / 375 s. It sits **below** the finale's g0, so it is an inverted curve.
- Proposed changes: Make it a distinct combine instead of a repeat, **Kraken in the Flood**:
  - keep `crab_claw` {every 15000};
  - replace `gust` with `rising_silt` {silt_every_locks 9, silt_gaps 3} (tide from 08);
  - `"goal":{"type":"bonk_boss","hits":5}`;
  - `fall.g0` 1.25.

  The pressure is now from below (tide) and from the side (tentacle), not more of the same. `music` → `pirate_h1`.

**Progression role** (layer 1): This is the first hard remix. It should pair the boss with the sea-floor rule from 08.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_h2: Fort Blast: Broadside  (tier 13, twist)

**Play** (layer 1)
- Goal: clear_n 3 against a rival fort; 1 warning.
- How it plays: Four 2-cell bollards sit on layer 0, and their positions are mirrored, rotated and jittered per attempt. A rival fort builds at rate 0.22 while sticky cannonballs fall every 4 locks after lock 4 (up to 6). The player builds around the bollards and the balls while racing the bar.
- Teaches / tests: Racing under clutter.
- Rules and minigame blocks: `race_rival` {rival_rate 0.22, rubber_band 0.5, warn 80}; `gumdrop_hail` {cannonball, sticky, every 4, max 6, after 4}. Variation: 8 symmetries plus jitter radius 1 on `#`.
- Board: 8x8, h_play 10, starting bollards at the four corners of the inner ring; random bag.
- Difficulty: g0 1.15, stars 400 s / 285 s.
- Proposed changes: If 09 adopts cannonballs, this would duplicate it. Differentiate it as **Broadside on a rolling deck**:
  - add `tilt_plate` {slip_threshold 0.6, slip_count 1, slip_after_resolves 2} (the 03 raft);
  - drop `objects_max` to 4 so the tilt is the headline;
  - `fall.g0` 1.25.

  Three known verbs (race, ammo, tilt) in one board is the hardest combine in the biome. `music` → `pirate_h2`.

**Progression role** (layer 1): This is the hard-track twist. It combines the 03 balance verb with the 09 fort race.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### pirate_h3: Rainbow Rehearsal  (tier 14, defender)

**Play** (layer 1)
- Goal: clear_n 4; 1 warning.
- How it plays: A tentacle starts pinching from the very first layer (every 20 s ±4 s, 2 s warning). Ink fog fades the stack to 10% opacity 4 s after each placement, and it reveals for 0.7 s on clears. The player builds from memory while defending a stack they can barely see. The tentacle telegraph still shows the target column, so the theft itself reveals where the cubes are.
- Teaches / tests: Defence under hidden information.
- Rules and minigame blocks: `crab_claw` {start 1, every 20000, jitter 4000, warn 2000, grab 1, counter clear}; `fog` {visible_ms 4000, fade_ms 1000, invisible_alpha 0.1, reveal_ms 700}.
- Board: 8x8, h_play 10, empty; random bag.
- Difficulty: g0 1.20, stars 535 s / 375 s.
- Proposed changes:
  - The name "Rehearsal" at tier 14, after "Blockade II", reads backwards. Rename to **Ink Storm** (`LVL_PIRATE_H3_TITLE`), or swap catalog order with h1.
  - Set `fall.g0` 1.30 so the hard track ends above the finale.
  - If pirate_10 adopts ink as phase 3, this level keeps fog **from the start** as its twist, which stays distinct.
  - `music` → `pirate_h3`.

**Progression role** (layer 1): This is the final hard challenge. It strips sight away from the Kraken fight, which is the cove's last test of mastery.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_
