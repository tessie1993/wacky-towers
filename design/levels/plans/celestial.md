# Celestial plan: Comet's Bedtime, the Hat Reveal (the finale biome)

> Layer 1 (Play, Progression role) by level-design, 2026-10-14. Truth for goals, rules, boards, knobs and stars:
> `src/levels/celestial/<id>/<id>.json`. Design intent: `design/levels/celestial.md`. Minigame blocks:
> `design/levels/mockup-alignment.md` §2.2 (Celestial row, "Cosmic Gateway" finale) and `minigame-stages.md` §1.13.
> Every number in "Proposed changes" is a tunable default for the user to approve; nothing here edits a JSON.

## Biome intro

**Quirk: "Up is optional."** Celestial is the last main biome (11 of 12 in catalog order; the Carnival / Tumble Fair side island follows) and the campaign's absurd-twist
climax. It has the only level where **you choose which way is down** (`control.verb: choose_down`), floaty zero-G puffs, an
eclipse that hides the stack, and a finale where the nine earlier bosses' **gadgets** tumble in as a parade (`event_card`)
while the Sleepy Moon's pillow presses down from above (`lava_lid`). Gravity is the campaign's highest: g0 1.14–1.50.

**The bar for a finale biome.** Every level should feel like a **victory lap with a twist**: it calls back to a mechanic the
player mastered earlier, then bends it in a way only the sky can. The final act escalates into a set-piece boss that uses
everything. Measured against that bar, the JSONs today have these gaps:
1. **The signature verb arrives late and buried.** `celestial_08` introduces choose-down (the most novel control in the game)
   together with `storm_bolt` **and** `defend_core`, and its g0 was *raised* to 1.45. It is never seen again: neither the
   finale nor any remix uses it.
2. **The new zero-G idea (EV10) is shipped as `balloon`**, which the player already met in neon_01 and Carnival. 05, 07 and
   09 all use the same balloon, so the "new" Celestial idea reads as a repeat.
3. **The finale is not yet a climax.** `celestial_10` (event-card parade + pillow lid, Clear 3) is good material, but it has
   no HP, no phases and no use of choose-down. It also runs at the same g0 as 09 (1.50).
4. Familiar issues: `celestial_05` stars sit far below the work an 8x8 board needs. `celestial_06` ships a `fixed_list`.
   `celestial_08`'s `defend_core` has no `core` cells (no level in the repo sets `core`). `celestial_02` stacks a pocket
   puzzle, a stopwatch, a rival and a time limit at tier 2.
5. **No minigame blocks.** The mockups give Celestial Chroma Sky Climb, Galactic Grab, Cosmic Climb, Moon Stack and the
   Cosmic Gateway finale on the Quantum Spire hex-decal board. None is bound.

**Target arc.** 01–03 take a victory lap (mystery stars, pockets, solar wind on a tilting plate). 04–06 twist (meteors, a zero-G
climb, the comet-tail puzzle). 07–09 combine (eclipse, **every way down taught cleanly**, the orbit spin). 10 is a three-phase
grand finale that ends with every way down under the Moon's pillow.

### Curve table (current JSON, with the proposed value in brackets where it changes)

| # | id | Type | Rules (JSON) | Goal | Board | g0 | ★★ / ★★★ (s) | Intensity 1–5 | Beat |
|---|---|---|---|---|---|---|---|---|---|
| 01 | celestial_01 | funny | mascot_hint, angle_gem, mystery_piece /6 | Clear 2 | 8x8, H9 | 1.14 | 290 / 205 | 1 | lap: mystery stars |
| 02 | celestial_02 | race | mascot_hint, stopwatch, angle_gem, race_rival 0.33; pockets [drop stopwatch] | Clear 3, limit 330 s | 8x8, H10, 2 starter layers | 1.15 | 265 / 185 | 2 | lap: pocket race |
| 03 | celestial_03 | balance | gust fixed +x, tilt_plate 0.65 | Clear 4 | 8x8, H10 | 1.23 | 585 / 410 | 2 | lap: solar wind on a plate |
| 04 | celestial_04 | twist | mushroom_popup (star rock) /4 | Clear 3 | 8x8, H10 | 1.25 | 435 / 310 | 3 | twist: meteor field |
| 05 | celestial_05 | race | build_race, balloon 0.5 [zero-G float], big_cube 0.5 | Height 10 [7], cov 0.6 | 8x8, H12 | 1.30 | 240 / 170 [420 / 295] | 2 | breather: orbit tower |
| 06 | celestial_06 | completing | fill_shape, fixed list [random bag] | Shape 24 | 8x8, H6 | 0.60 | 75 / 50 [105 / 75] | 2 | puzzle: comet's tail |
| 07 | celestial_07 | balance | fog (eclipse), balloon | Clear 4 | 8x8, H10 | 1.40 | 580 / 410 | 3 | combine: eclipse |
| 08 | celestial_08 | defender [twist] | choose_down; storm_bolt, defend_core [moved out] | Clear 3 | 8x8, H6 | 1.45 [1.30] | 435 / 310 | 3 [teach] | the signature: every way down |
| 09 | celestial_09 | funny | turntable /5, balloon [+ choose_down] | Clear 4 | 8x8, H10 | 1.50 | 580 / 410 | 4 | combine: orbit spin |
| 10 | celestial_10 | twist [boss] | event_card parade, lava_lid pillow [3 phases] | Clear 3 [boss 3 HP] | 8x8, H12 | 1.50 [1.55] | 440 / 305 [540 / 380] | 5 | grand finale |
| B | celestial_bonus | completing | fill_shape, undo_reset; kit | Shape 24 | 8x8, H6 | 0.60 | 90 / 60 | 2 | whimsy: hat box |
| H1 | celestial_h1 | defender | gust rotating, storm_bolt 8 s [+ defend_core] | Clear 4 | 8x8, H10 | 1.45 [1.55] | 550 / 375 | 4 | hard: meteor storm |
| H2 | celestial_h2 | funny | fog, mystery_piece /4 [+ choose_down] | Clear 4 | 8x8, H10 | 1.45 [1.55] | 540 / 375 | 5 | hard: wishing eclipse |
| H3 | celestial_h3 | funny | turntable /5, jumbled_queue /5 | Clear 4 | 8x8, H10 | 1.50 [1.58] | 550 / 375 | 5 | hard: constellation shuffle |

Sawtooth with the changes: 1-2-2-3-2-2-3-3-4-5. Moving 08 from a defender spike to a clean teach puts a learn beat right
before the two peaks. The finale gets its own g0 step (1.55), the hard track sits at or above it, and the hardest numbers in the
game live in H3.

---

### celestial_01: First Star  (tier 1, funny)

**Play** (layer 1)
- Goal: `clear_n` n 2 (`T_level` 200), rescue, 2 warnings.
- How it plays: Calm O and I openers, then every 6th piece arrives as a **shooting star**, a mystery piece whose shape is
  hidden in the queue until it spawns. The player keeps the stack flat enough that any surprise fits. A helper points at a good
  cell (`mascot_hint`), and a duck constellation (`angle_gem`) is visible from one camera angle as a secret.
- Teaches / tests: the controls at Celestial gravity (1.14 is the game's highest tier-1 speed), plus "leave room for a
  surprise".
- Rules and minigame blocks: `mascot_hint` {}; `angle_gem` {skin "duck_constellation"}; `mystery_piece` {every 6}. No module.
- Board: 8x8, H9, random 8-shape bag; the first 2 come from {O, I}; the mystery shape is random per attempt.
- Difficulty: g0 1.14; ★★ 290 s / ★★★ 205 s; the floor of the curve.
- Proposed changes: none. Tutorial bubble on the first mystery piece: "Shooting star! Its shape is a surprise."

**Progression role** (layer 1): The arrival. It opens the victory lap gently and sets the biome's "the sky surprises you" tone.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_02: Constellation Stone  (tier 2, race)

**Play** (layer 1)
- Goal: `clear_n` n 3 within `time_limit_ms` 330000, 1 warning.
- How it plays: The board starts with two layers of stone that hide pockets (the "beds" for three star-sheep). The opening
  three pieces are Tripod and Screws, the shapes that fit the pockets. The player fills the pockets to finish both starter
  layers while a ghost rival (0.33 %/s) races the same goal and a stopwatch freezes and rushes the piece every 16 s.
- Teaches / tests: reading a pre-built board (pockets) under race pressure.
- Rules and minigame blocks: `mascot_hint`; `stopwatch` {16000 ±3000, warn 1500, stop 2000, catchup 1500 / 2000};
  `angle_gem`; `race_rival` {0.33, 0.5, 80}. `starting_contents` layers 0–1.
- Board: 8x8, H10. **Per-attempt variation is done well here**: `variation.symmetries` re-orients the pocket layout from the
  attempt seed, so the puzzle stays isomorphic but never memorised.
- Difficulty: g0 1.15; ★★ 265 s / ★★★ 185 s; a 330 s hard limit.
- Proposed changes: four pressures at tier 2 is a curve spike, and the stopwatch is the player's fifth stopwatch level.
  Remove `stopwatch`. Keep the rival and the time limit, since they are what make it a race. The pocket puzzle is the level's
  identity.

**Progression role** (layer 1): Second lap level. It calls back to Meadow's pockets, and its variation pattern should be copied
into 06 and the bonus.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_03: Solar Wind Causeway  (tier 3, balance)

**Play** (layer 1)
- Goal: `clear_n` n 4, 1 warning.
- How it plays: Every 7 s (±2 s) a 1 s-telegraphed solar wind pushes the falling piece one cell east. Meanwhile the board is
  a tilting plate: if the stack's weight leans past 0.65 for 2 resolves, one cube slips off the low edge. The player
  counter-weights against the wind, building the west side a little heavier so the gusted pieces even it out.
- Teaches / tests: balance against a constant one-way force.
- Rules and minigame blocks: `gust` {fixed, +x, 7000, 2000, strength 1, warn 1000}; `tilt_plate` {slip_threshold 0.65,
  slip_count 1, slip_after_resolves 2}. No module today.
- Board: 8x8, H10, random 8-shape bag; gust timing is jittered.
- Difficulty: g0 1.23; ★★ 585 s / ★★★ 410 s.
- Proposed changes: **bind Chroma Sky Climb** (mockup #16, `stair_path` + `gust_wind`, Celestial's 03 slot) as phase 2 once
  modules land: after 2 clears, a rainbow staircase outline appears and the player builds 6 steps into the wind (`stair_path`,
  steps 6). The Stability thermometer is the tilt plate's danger gauge, so it is the same HUD. Interim: none. Change
  `goal.n` 4 → 3 and stars t2 435000, t3 310000 so a tier-3 level is not 10 minutes long.

**Progression role** (layer 1): Ends the lap act. Wind and tilt are both known, and putting them together is the first Celestial
bend.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_04: Meteor Field  (tier 4, twist)

**Play** (layer 1)
- Goal: `clear_n` n 3, 1 warning.
- How it plays: Every 4 locks a star-rock lands on the stack (up to 4 on the board at once). These are fixed obstacles the
  player has to build around or bury, and a clear removes the layer they sit in. A well-placed piece can wrap a rock so it
  fills a gap for you.
- Teaches / tests: building around content that arrives on a schedule.
- Rules and minigame blocks: `mushroom_popup` {spawn_every_locks 4, objects_max 4, skin "star_rock"}. No module.
- Board: 8x8, H10, random 8-shape bag; rock positions random per attempt.
- Difficulty: g0 1.25; ★★ 435 s / ★★★ 310 s.
- Proposed changes: telegraph each rock with a 1-lock shadow on its landing cell (a proposed `mushroom_popup.warn_locks` 1),
  so a rock never lands where the ghost is aiming. Tutorial bubble: "Star-rocks land on shadows. Build around them!"

**Progression role** (layer 1): Opens the twist act. The rock-drop is the event the finale's parade reuses as its "drop" card.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_05: Orbit Tower  (tier 5, race)

**Play** (layer 1)
- Goal: `height` h_target 10, height_coverage 0.6, trim top-out, no fail.
- How it plays: The player climbs a tower with nothing clearing. Big cubes (weight 0.5) come often and fill fast, and one
  piece per bag floats down on a balloon at half gravity and drifts every 3 s. It is a no-lose climb toward the orbit.
- Teaches / tests: the build race as a breather, with floaty pieces.
- Rules and minigame blocks: `build_race` {}; `balloon` {1 per bag, g ×0.5, drift 3000}; `big_cube` weight 0.5.
- Board: 8x8, H12; random bag including big cubes.
- Difficulty: g0 1.30; ★★ 240 s / ★★★ 170 s. **Unreachable:** layer 10 at 60 % coverage on 8x8 is about 600 cells of
  support even with big cubes.
- Proposed changes:
  1. `goal.h_target` 10 → 7; `stars` t2 420000, t3 295000 (big cubes make it faster per cell than clockwork_05).
  2. Make the Celestial idea new: replace `balloon` with a **zero-G puff** (design EV10: a piece that hovers at its height
     for up to 3 s when you release input, then falls), using `balloon` {balloon_g_mult 0.0, balloon_drift_ms 0} plus a proposed
     `hover_ms` 3000. That gives a "place in mid-air" feel the player has never had.
  3. Later module binding: **Galactic Grab** (`road_race`, Celestial 05 slot) belongs on a race level, but a breather should
     stay simple; put Galactic Grab in H1 instead.

**Progression role** (layer 1): The breather in the middle of the twist act. It introduces the zero-G hover that 07 and 09 bend.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_06: Constellation Dome  (tier 6, completing)

**Play** (layer 1)
- Goal: `shape`, piece_budget 6. The target is a full 4x4 base on layer 0 plus a T-shaped comet tail on layer 1 (a 4-wide
  top row and a 2x2 below it), centred (24 cells).
- How it plays: Today the player places a **fixed** list (I O O I I O) at slow gravity with a 3-piece preview.
- Teaches / tests: exact fill as a quiet puzzle.
- Rules and minigame blocks: `fill_shape` {trim}; `pieces.fixed_list`. No module.
- Board: 8x8, H6, centred target; **no per-attempt variation**.
- Difficulty: g0 0.60; ★★ 75 s / ★★★ 50 s.
- Proposed changes (**standing-rule violation**: `fixed_list`):
  1. Remove `fixed_list`. Use a random bag of {i 0.5, o 0.5}, `piece_budget` 6 → 9, allow overspill.
  2. Copy celestial_02's `variation.symmetries`, so the comet tail points a different way each attempt (four rotations, all
     valid on the centred base).
  3. `stars` t2 105000, t3 75000. Keep `skill.redraw` off.

**Progression role** (layer 1): The quiet puzzle before the combine act. It is also the last calm level of the main campaign.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_07: Eclipse  (tier 7, balance)

**Play** (layer 1)
- Goal: `clear_n` n 4, 1 warning.
- How it plays: The eclipse rolls over the stack. Placed cubes stay visible for 4 s, fade over 1 s to 12 % alpha, and flash
  back for 0.6 s on each lock. Balloon pieces drift in at half gravity. The player has to remember the shape of the stack they
  can no longer see, and use each lock's reveal to check it.
- Teaches / tests: spatial memory under drift.
- Rules and minigame blocks: `fog` {visible_ms 4000, fade_ms 1000, invisible_alpha 0.12, reveal_ms 600, skin "eclipse"};
  `balloon` {1, 0.5, 3000}. No module.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.40; ★★ 580 s / ★★★ 410 s; opens the combine act.
- Proposed changes: swap `balloon` for 05's zero-G hover (if adopted), so the hover gains a twist: you can hover a piece in the
  dark to wait for the next reveal. Retype to `funny` or keep it as balance? Keep balance only if `tilt_plate` returns; without
  a balance rule it is mistyped. Proposed: add `tilt_plate` {0.7, 1, 2}, so the eclipse hides how the plate leans, a real
  Celestial bend on 03.

**Progression role** (layer 1): The first combine level. It recombines 03's plate and 05's hover in the dark.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_08: Every Way Down  (tier 8, defender)

**Play** (layer 1)
- Goal: `clear_n` n 3, 1 warning.
- How it plays: The player **chooses which way the piece falls**: down, or sideways along ±x or ±z
  (`control.verb: choose_down`). Any face of the low (H6) box can act as a floor. Today that arrives together with meteors
  (`storm_bolt` every 12 s) and a core under fire (`defend_core` 3 HP, every 14 s, no core cells set).
- Teaches / tests: the game's most novel control, the climax verb of the whole campaign.
- Rules and minigame blocks: knobs `control.verb` choose_down, `control.travel_dirs` [down, +x, -x, +z, -z]; `storm_bolt`
  {12000, 2000, 2000}; `defend_core` {3 HP, 14000, warn 2500, **core unset**}. No module.
- Board: 8x8, H6, random 8-shape bag.
- Difficulty: g0 1.45 (raised from 1.30 to fix a curve inversion); ★★ 435 s / ★★★ 310 s.
- Proposed changes (**teach the signature verb in isolation**, per the puzzle-genre rule "introduce mechanics in isolation
  before combining"):
  1. Remove `storm_bolt` and `defend_core` from 08; move the defender pair to H1, where it fits the meteor-storm theme.
  2. `fall.g0` 1.45 → 1.30. Choosing a direction is a thinking verb, and 07 (1.40) already carries the curve. The "inversion"
     the amendment fixed is better solved by the step into 09.
  3. Retype to `twist`. Tutorial bubbles (event-keyed): first spawn, "Swipe a side: that way is down!"; first sideways lock,
     "Any wall can be a floor."
  4. Stars: keep 435 / 310 until playtest (the verb is new, so medians matter more than formula).

**Progression role** (layer 1): The biome's new verb, deliberately late so it feels like an endgame reward. 09, H2 and the finale's
last phase reuse it, so the climax is built on it.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_09: Drift Islet  (tier 9, funny)

**Play** (layer 1)
- Goal: `clear_n` n 4, 1 warning.
- How it plays: The islet orbits: the stack turns a quarter clockwise every 5 locks, and balloon pieces drift down at half
  gravity. A drifting piece that is mid-air during a turn lands on the turned stack, which is funny when it ends up in the
  "wrong" gap.
- Teaches / tests: the orbit remix (turn + float); the peak before the boss.
- Rules and minigame blocks: `turntable` {turn_locks 5, clockwise, warn 1}; `balloon` {1, 0.5, 3000}. No module.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.50; ★★ 580 s / ★★★ 410 s; the curve's "4".
- Proposed changes: **combine the new verb**: add `control.verb` choose_down with `control.travel_dirs` [down, +x, -x] (two
  sideways options only, a gentler subset). After a turn, the best floor is often a side wall. Keep the balloon (or the
  hover, if adopted). This makes 09 the "combine" for 08 instead of a repeat of Clockwork's turntable.

**Progression role** (layer 1): The last regular level. It proves the player can use choose-down under a board twist before the
finale asks for it under fire.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_10: The Top of the Sky  (tier 10, twist; boss, grand finale)

**Play** (layer 1)
- Goal: `clear_n` n 3, 1 warning.
- How it plays: Every 8 locks a **gadget card** from one of the nine earlier bosses tumbles in, with no repeats: the lever,
  horn or chimes cause a **gust**; the piping bag, bottle or clock-stopper **drop** a star-rock; the bath bomb, lanterns or
  mixtape **slide** the stack one cell. From 150 s the Sleepy Moon's **pillow** lid presses down from the top (every 40 s, up
  to 2 times, 5 s warning), and each clear pushes it back up one layer. Three clears put the Moon to sleep. The chair piece is in
  the set.
- Teaches / tests: a gadget boss rush, a callback to every biome.
- Rules and minigame blocks: `event_card` {event_card_locks 8, no_repeat, a pool of 9 gadget cards, gust strength 1 / warn
  1000, drop skin star_rock, slide 1}; `lava_lid` {lid, first 150 s, every 40 s, max 2, warn 5000, push per clear 1}.
- Board: 8x8, H12, random 8-shape bag + chair; card order random per attempt (no_repeat).
- Difficulty: g0 1.50; ★★ 440 s / ★★★ 305 s.
- Proposed changes (**make it the campaign's climax**). The material is right (all nine bosses' gadgets, the Moon), but the
  structure is flat:
  1. **Three-act grand finale as the Cosmic Gateway** (the mockup's Celestial finale, on the Quantum Spire hex-decal board
     skin), with `boss_hp` 3 where each act is one hit:
     - Act 1 "The Gadget Parade" (callback to every biome): `event_card` as today until 1 clear.
     - Act 2 "Climb to the Moon": Chroma Sky Climb (`stair_path` + `gust_wind`, 5 steps up to the Moon's nightcap) with the
       parade still running, until the stair is built.
     - Act 3 "Every Way Down": `control.verb` choose_down (all 5 directions) while the pillow `lava_lid` presses from above
       (first lid at act start, every 30 s, max 2). Clear 1 layer → the Moon yawns and falls asleep.
  2. **Interim without the module framework**: `goal.type` `bonk_boss` HP 3, one hit per clear, so the player sees the Moon's
     sleep meter. Turn on choose_down after hit 2 and move the pillow to start at hit 2 instead of at 150 s (a proposed
     `lava_lid.lid_from_clear` 2), so the last act is the biggest.
  3. `fall.g0` 1.50 → 1.55, a step up from 09. `stars` t2 540000, t3 380000 for the longer three-act run. Retype it as
     `defender` (you hold off the Moon), which also improves the biome's type mix.

**Progression role** (layer 1): The end of the main campaign. Act 1 replays every biome (through the gadgets), act 2 replays the
mockup climb, act 3 replays Celestial's own verb. Finishing it plays the grand-finale skit, opens Drizzle Rock (the epilogue)
and the Celestial hard track.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_bonus: Hat Box  (tier 11, completing)

**Play** (layer 1)
- Goal: `shape`, piece_budget 5. The target is a 4x4 base on layer 0 plus a 2x2 crown on layers 1–2, centred (24 cells).
- How it plays: The kit box shows I, I, O, O and a Big Cube. The player picks in any order and packs the old hat: the big cube
  is the 2x2x2 core, and the Is and Os ring the base. `undo_reset` lets them take back a placement freely.
- Teaches / tests: the kit puzzle with undo, a relaxed reward.
- Rules and minigame blocks: `fill_shape` {trim}; `undo_reset` {}; `spawn.arrival` kit_box.
- Board: 8x8, H6, centred target; the same kit every attempt.
- Difficulty: g0 0.60; ★★ 90 s / ★★★ 60 s.
- Proposed changes: add `pieces.kit_variants` (proposed field, as clockwork_bonus) with two more 5-piece kits for the same
  24 cells. Kit B [big_cube, I, I, I, O] (base: big cube + I I I; crown: O). Kit C [big_cube, O, O, O, O] (base: big cube +
  O O O; crown: O). Optional module binding: **Moon Stack** (`balance_plate`, Celestial bonus slot) as a second bonus when
  `balance_plate` exists.

**Progression role** (layer 1): A gentle, optional epilogue-flavoured puzzle between the finale and the hard track.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_h1: Meteor Storm  (tier 12, defender)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: The solar wind rotates direction every 9 s (±2.5 s), and meteor bolts strike every 8 s with a 1.5 s
  telegraph. The player hard drops in gust warnings and keeps the stack low and flat so bolt damage is shallow.
- Teaches / tests: defending under two fast, different-coloured telegraphs.
- Rules and minigame blocks: `gust` {rotating, 9000, 2500, 1, 1000}; `storm_bolt` {bolt_interval_ms 8000, bolt_warn_ms 1500,
  no jitter}.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.45; ★★ 550 s / ★★★ 375 s.
- Proposed changes: take 08's `defend_core` here with real cells: `core` = centre 2x2 on layer 0, 3 HP, attack every 14 s.
  The storm then has a target and the type is honest. Add `storm_bolt.bolt_jitter_ms` 1500 so the bolts are not metronomic.
  `fall.g0` 1.45 → 1.55 (not below the finale). Later module binding: **Galactic Grab** (`road_race`) as a race variant of this
  storm.

**Progression role** (layer 1): The first hard remix. It is the hardest defender level in the game.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_h2: Wishing Eclipse  (tier 13, funny)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: The eclipse hides the stack (visible 4 s, fade 1 s to 15 %, reveal 0.7 s on lock), and every 4th piece is a
  wishing star whose shape is hidden until it spawns. The player plays from memory and keeps a flat top so any surprise fits in
  the dark.
- Teaches / tests: memory plus improvisation.
- Rules and minigame blocks: `fog` {4000, 1000, 0.15, 700, eclipse}; `mystery_piece` {every 4}.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.45; ★★ 540 s / ★★★ 375 s.
- Proposed changes: add `control.verb` choose_down with `travel_dirs` [down, +x, -x, +z, -z]. Choosing which way is down in the
  dark is the design's original "Dark Side" remix (celestial.md H2) and the hardest use of the signature verb. `fall.g0` 1.45 →
  1.55.

**Progression role** (layer 1): The middle remix. It brings back 08's verb at full difficulty.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### celestial_h3: Constellation Shuffle  (tier 14, funny)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: The stack turns a quarter every 5 locks, and every 5th piece the queue is jumbled, so the 3-piece preview the
  player was planning around reshuffles. They plan loosely, build flat, and keep two placements in mind for every queue.
- Teaches / tests: adaptive planning when both the board and the queue move.
- Rules and minigame blocks: `turntable` {5, clockwise, warn 1}; `jumbled_queue` {every 5}; `spawn.preview_count` 3.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.50; ★★ 550 s / ★★★ 375 s; the last main-campaign level.
- Proposed changes: offset the two schedules so they never fire on the same lock (`jumbled_queue.every` 5 → 7). The player can
  then read each one on its own (Readable Chaos). `fall.g0` 1.50 → 1.58, making it the game's top gravity.

**Progression role** (layer 1): The very last challenge in the campaign: a mastery test for players who want everything.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_
