# Clockwork plan: Tock's Midnight

> Layer 1 (Play, Progression role) by level-design, 2026-10-14. Truth for goals, rules, boards, knobs and stars:
> `src/levels/clockwork/<id>/<id>.json`. Design intent: `design/levels/clockwork.md`. Minigame blocks:
> `design/levels/mockup-alignment.md` §2.2 (Clockwork row) and `design/levels/minigame-stages.md` §1.10.
> Every number in "Proposed changes" is a tunable default for the user to approve; nothing here edits a JSON.

## Biome intro

**Quirk: "everything ticks".** Every Clockwork disturbance runs on a schedule the player can read: a quarter-turn every N locks,
a piston every N locks, a stopwatch freeze every ~14 s. Each one winds up one beat ahead. The skill the biome trains is
**planning one beat ahead**: where the gap *will be* after the turn, the belt or the punch. Biome 9 of 12 sits between Cave and
Neon. The player already knows conveyors, flips, wobble, defend-core and build races from earlier biomes. Clockwork's own new
verbs are **Cog Turn** (`turntable`), **Piston Punch** (`piston_punch`), **Stopwatch** (`stopwatch`) and **Winding Keys**
(`key_stamp` + `wind_keys`, the only goal in the game about which way a face points).

**What the JSONs do today, and the gaps.** The 2026-10-13 move to 8x8 boards and the level-type pass kept the biome's
rules but left four problems:
1. `clockwork_05` still uses the **4x4 star times on an 8x8 board**, so its stars cannot be reached (see 05).
2. `clockwork_06` ships a **`fixed_list`**, which breaks the standing rule that the next block is random on every attempt.
3. `clockwork_04` adds `defend_core` with **no `core` cells** (default `[]`), so nothing can be attacked.
4. **No minigame blocks.** The mockups give Clockwork Clockwork Conveyor, Bomb Defuse, Factory Frenzy and the forge-boss
   finale. No authored level uses any of them, and the finale's boss is staging only (no HP, no phases).

**Target arc (teach, twist, combine, payoff).** 01–03 teach (turn, belt), 04–06 twist (punch, climb, defuse), 07–09
combine (stopwatch, keys, turn+rewind), 10 boss with three phases. The bonus is a whimsical puzzle. H1–H3 are the
hard remixes.

### Curve table (current JSON, with the proposed value in brackets where it changes)

| # | id | Type | Rules (JSON) | Goal | Board | g0 | ★★ / ★★★ (s) | Intensity 1–5 | Beat |
|---|---|---|---|---|---|---|---|---|---|
| 01 | clockwork_01 | balance | wobble 8 | Clear 2 | 8x8 cog mask, H8 | 0.97 | 245 / 170 | 1 | teach: controls, loose gears |
| 02 | clockwork_02 | twist | turntable /4 cw | Clear 1 [2] | 9x9 [8x8], H10 | 1.05 | 185 / 130 [290 / 205] | 2 | teach: Cog Turn |
| 03 | clockwork_03 | twist | conveyor +x /3 [+ conveyor_sort block] | Clear 3 | 8x8, H10 | 1.10 | 435 / 310 | 2 | teach: belt in the Clockwork rhythm |
| 04 | clockwork_04 | defender | piston_punch /4, defend_core 3 HP | Clear 3 | 8x8, H10 | 1.15 | 435 / 310 | 3 | twist: pistons as a shield tool |
| 05 | clockwork_05 | race | build_race | Height 8 [6], cov 0.6 | 8x8, H12 | 1.18 | 165 / 115 [385 / 270] | 2 | breather climb (no fail) |
| 06 | clockwork_06 | completing | fill_shape, fixed list [random bag, fuse] | Shape 28 | 8x8, H6 | 0.60 | 80 / 55 [110 / 80] | 2 | twist: Bomb Defuse block |
| 07 | clockwork_07 | race | stopwatch, race_rival 0.2 | Clear 4 | 8x8, H10 | 1.28 | 580 / 410 | 3 | combine: freeze + rival |
| 08 | clockwork_08 | twist | key_stamp 2/bag | Wind 4 keys | 8x8, H10 | 1.30 | 200 / 140 | 3 | combine: orientation goal |
| 09 | clockwork_09 | funny | turntable /5 ccw, flip stack | Clear 4 | 8x8, H10 | 1.35 | 580 / 410 | 4 | combine: hardest remix |
| 10 | clockwork_10 | twist [boss] | conveyor, piston_punch, stopwatch [phased] | Clear 3 [boss 3 HP] | 8x8, H12 | 1.40 | 435 / 305 | 5 | payoff: Cuckoo Prime |
| B | clockwork_bonus | completing | fill_shape, turntable /2 | Shape 28 (kit) | 8x8, H6 | 0.60 | 110 / 75 | 2 | whimsy: music box |
| H1 | clockwork_h1 | twist | conveyor, magnet_pull [+ Factory Frenzy] | Clear 4 | 8x8, H10 | 1.30 [1.42] | 545 / 375 | 4 | hard: belt vs magnet |
| H2 | clockwork_h2 | twist | turntable /4, pressure_cooker | Clear 4 | 8x8, H10 | 1.30 | 540 / 375 | 4 | hard: turn under steam |
| H3 | clockwork_h3 | twist | key_stamp, piston_punch /5, magnet_pull | Wind 5 keys | 8x8, H10 | 1.30 | 240 / 170 | 5 | hard: keys exam |

Sawtooth check: 1-2-2-3-2-2-3-3-4-5. The 05/06 dip is the breather before the combine act. This is right as long as 05's
stars are fixed. Length check: 07 and 09 have a ★★ of 9.7 min, the longest in the biome. The boss (435 s) is shorter on
purpose, because it is a set piece rather than an endurance test.

---

### clockwork_01: Cog Plaza  (tier 1, balance)

**Play** (layer 1)
- Goal: `clear_n` n 2 (`T_level` 180), rescue top-out, 2 warnings.
- How it plays: Calm O and I openers drift onto a cog-shaped floor with four notched-out cells. The player fills the 60
  live cells of a layer while `wobble` (max 8, gentler than the default 6) makes a lopsided stack sway and shed a loose
  "gear" cube. The pressure is soft: keep the build level and the gears stay put. Two clears polish the plaza.
- Teaches / tests: the controls in the Clockwork look, plus "the notches are part of the board, not holes to fill".
- Rules and minigame blocks: `wobble` {wobble_max 8}; `opening_set` [o, i] x2. No module.
- Board: 8x8 with a 4-notch cog mask (cells (3,1), (1,3), (5,3), (3,5) off), H8, spawn [3,2]. Weighted random bag of the
  8 standard shapes on every attempt; only the first 2 come from {O, I}.
- Difficulty: g0 0.97; ★★ 245 s / ★★★ 170 s; the floor of the curve.
- Proposed changes: none to the rules. Tutorial bubble (≤12 words, event-keyed on the first wobble warning): "Lopsided
  stacks shake loose gears. Keep it level!"

**Progression role** (layer 1): This is the on-ramp after Cave. It re-teaches stacking in a new skin and quietly re-introduces
balance, so 02 can spend the player's attention entirely on the turn.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_02: Gear Workshop  (tier 2, twist)

**Play** (layer 1)
- Goal: `clear_n` n 1, 1 warning.
- How it plays: Every 4 locks the cog ring lights tooth by tooth, and on the next resolve the whole stack turns 90°
  clockwise about the board centre. The ghost already shows the turned stack, so aiming is always honest. The "aha" is that
  a flat stack is immune: build flat and the turn costs nothing, but leave a ragged edge and your saved gap swings to the far
  side.
- Teaches / tests: reading a scheduled board move (BL11 Cog Turn), the biome's signature tick.
- Rules and minigame blocks: `turntable` {turn_locks 4, clockwise true, turn_warn_locks 1}. No module.
- Board: 9x9, H10, no mask, random 8-shape bag.
- Difficulty: g0 1.05; ★★ 185 s / ★★★ 130 s. The board is low on the curve, but **one clear is too short to learn the
  turn**: about 20 pieces means 5 turns, and the level ends on the first success.
- Proposed changes: `board.width/depth` 9 → 8 (an even square still maps cells to cells under a 90° turn, and it matches 01's
  footprint); `goal.n` 1 → 2; `stars` t2 290000, t3 205000 (F1: t_est = 2 × 64 × 2.667 = 341 s). With two clears, the
  player sees "turn hurts a ragged stack" in clear 1 and gets to use "build flat" in clear 2.

**Progression role** (layer 1): It introduces the biome's first new verb in isolation (Non-Verbal Tutorial: isolation). 09, H2 and
the bonus reuse the turn, so it must be learned cleanly here.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_03: Tram Street  (tier 3, twist)

**Play** (layer 1)
- Goal: `clear_n` n 3, 1 warning.
- How it plays: Every 3 locks a tram bell rings, and the whole stack slides one cell east (+x) and wraps around. The player
  learns the one-cell lead ("drop where the gap will be") and that long east–west lanes make I pieces valuable. It is a known
  rule (Meadow, Forest, Lava) taught again in the Clockwork rhythm.
- Teaches / tests: the belt as a schedule, and the setup for the finale's belt phase.
- Rules and minigame blocks: `conveyor` {conveyor_every 3, conveyor_wrap true, conveyor_dir "+x"}. No module today.
- Board: 8x8, H10, spawn [3,3], random 8-shape bag.
- Difficulty: g0 1.10; ★★ 435 s / ★★★ 310 s. It is a re-teach, so it sits low; it is long for tier 3 (7 min ★★).
- Proposed changes: **bind the Clockwork Conveyor minigame block** (mockup #13, `conveyor_sort`, the 03 slot in
  mockup-alignment §2.2) as a second phase once the module framework lands. Phase 1 is the current belt until 1 clear.
  Phase 2 is `conveyor_sort` (sort mode, 3 hoppers at the east end, 6 sorted cubes) until done. Interim, with existing rules:
  add `colour_pop` {pop_min 6, layer_clear_too true}, so 6 touching same-colour cubes on the belt pop like a hopper intake.
  That gives the belt a second, faster scoring verb and shortens the level. Then set `goal.n` 3 → 2 and stars t2 300000,
  t3 210000 (re-time after playtest).

**Progression role** (layer 1): Second teach level. It brings back a familiar mechanic between two new ones (02 turn, 04 pistons)
so the curve dips, and it rehearses the belt the boss uses in phase 1.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_04: Spring Yard  (tier 4, defender)

**Play** (layer 1)
- Goal: `clear_n` n 3, 1 warning.
- How it plays: Four wall pistons (west wall row 1, east wall row 4, layers 0 and 1) wind up with a hiss every 4 locks, then
  shove the cubes from the wall to the first gap one cell inward. A gap at the wall is easy to fill, and a push that completes
  a layer clears it. At the same time `defend_core` fires a telegraphed shot every 15 s (2.5 s warning) at a core with 3 HP.
  The player is meant to cover the core with blocks.
- Teaches / tests: a board twist you can **use** (EV20 Piston Punch), under light defender pressure.
- Rules and minigame blocks: `piston_punch` {piston_locks 4, 4 pistons}; `defend_core` {core_hp 3, attack_every_ms 15000,
  warn_ms 2500}. No module.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.15; ★★ 435 s / ★★★ 310 s. It is the first "3" on the curve.
- Proposed changes:
  1. **Bug:** `defend_core.core` is unset (default `[]`), so there is no core to defend. Set `core` to the centre 2x2 on
     layer 0: cells (3,3), (4,3), (3,4), (4,4).
  2. **Make the two rules talk to each other.** Today the pistons are on rows 1 and 4 and the core is in the middle, so they
     never interact. Move the pistons to rows 3 and 4 (west wall row 3 y0/y1, east wall row 4 y0/y1) so that a punch closes the
     gap in the **shield row next to the core**. The aha becomes "leave the gap on the piston row and the machine bricks up your
     shield for you".
  3. Tutorial bubble on the first wind-up: "Pistons push your row in. Leave gaps at the wall!"

**Progression role** (layer 1): This is the twist act's opener and the biome's second new verb. Defender pressure gives the
pistons a reason to exist. It sets up H3, where pistons return with keys.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_05: Clock Tower  (tier 5, race)

**Play** (layer 1)
- Goal: `height` h_target 8, height_coverage 0.6 (39 of 64 cells on the target layer), trim top-out, no fail.
- How it plays: Nothing clears. Full layers glow and stay, and the height meter climbs as Tock climbs the tower shaft. The
  pressure is only the clock: misplaced pieces waste time, and cubes above H12 pop off the "top beam". It is a no-lose climb
  after the pistons.
- Teaches / tests: the build-race verb (M1, known from Meadow 05) as a breather.
- Rules and minigame blocks: `build_race` {}. No module.
- Board: 8x8, H12, no mask, random 8-shape bag.
- Difficulty: g0 1.18; ★★ 165 s / ★★★ 115 s. **These are the 4x4 times kept after the board grew to 8x8.** About 487 cells
  of work at the old rate gives a ★★ of about 520 s, so today's stars are out of reach and this "breather" is the hardest
  star in the biome.
- Proposed changes: `goal.h_target` 8 → 6 (a breather should run about 5 min, not 9); `stars` t2 385000, t3 270000 (scaled
  from the design's per-cell rate: 64 × 5 + 39 = 359 cells). Optional: add `race_rival` {rival_rate 0.25, rubber_band 0.5}
  as a ghost tin mouse climbing a twin tower, so the "race" type is felt rather than implied.

**Progression role** (layer 1): This is the dip in the sawtooth between the pistons (04) and the stopwatch (07). It pays off the
tower that has been on the skyline since 01.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_06: Pendulum Hall  (tier 6, completing)

**Play** (layer 1)
- Goal: `shape`, piece_budget 7. The target is a 4x4 bob on layer 0 (x2–5, z2–5) plus a 2x2 rod on layers 1–3 (28 cells).
  Top-out is trim.
- How it plays: Today the player reads a 3-piece preview of a **fixed** list (L T T I O O O). They interlock the L and the
  Ts into the base, seal it with the I, and stack three Os up the rod. With slow gravity (0.60), it is a pure think-then-place
  puzzle with free retry.
- Teaches / tests: the puzzle verb (exact fill) as a breather.
- Rules and minigame blocks: `fill_shape` {topout_rule trim}; `pieces.fixed_list`; preview 3. No module.
- Board: 8x8, H6, target centred. **No per-attempt variation:** every attempt deals the same seven pieces.
- Difficulty: g0 0.60; ★★ 80 s / ★★★ 55 s; a valley on the curve.
- Proposed changes (**standing-rule violation**: the fixed list is a hardcoded sequence, and 06 is not a bonus):
  1. Remove `pieces.fixed_list`. Use a weighted random bag of {o, i, l, t} (o 0.35, i 0.25, l 0.2, t 0.2), raise
     `piece_budget` 7 → 10, and allow overspill: cubes outside the outline are legal and simply wasted. A random bag can
     always cover the target this way.
  2. **Bind the Bomb Defuse minigame block** (mockup #33, `ring_defuse`, the Clockwork 05-slot module and the clockwork-skinned
     hub island). The pendulum bob becomes a ticking bomb, and the player fills the ring around it before the fuse runs out.
     Interim with existing fields: `goal.time_limit_ms` 120000 as the fuse, shown on the bob. When the module lands, swap to
     `ring_defuse` with the same target.
  3. `stars` t2 110000, t3 80000 (random pieces need more reading time than a known list). Keep `skill.redraw` off.

**Progression role** (layer 1): This is the biome's completing level. It is a calm puzzle beat that, with the fuse, also teaches
the defuse block the boss reuses in phase 2. It sits between the climb and the stopwatch so that two heavy levels are never
back to back.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_07: Stopwatch Square  (tier 7, race)

**Play** (layer 1)
- Goal: `clear_n` n 4, 1 warning.
- How it plays: Every 14 s (±3 s) the town's second hand stops with a 1 s "tick… TOCK" warning. The falling piece then
  freezes in mid-air for 2.5 s; move, rotate and hard drop still work. After that, catch-up gravity runs at ×1.6 for 2.5 s.
  The skill is to aim during the freeze and drop before the rush. A ghost rival (`race_rival`, 0.2 %/s, rubber band 0.5)
  is also clearing the same goal, and it warns at 80 %.
- Teaches / tests: a timing twist that helps the player if they read it (Stopwatch Stutter), under race pressure.
- Rules and minigame blocks: `stopwatch` {stop_every_ms 14000, jitter 3000, warn 1000, stop 2500, catchup_scale 1600,
  catchup_ms 2500}; `race_rival` {rival_rate 0.2, rubber_band 0.5, rival_warn_pct 80}. No module.
- Board: 8x8, H10, random 8-shape bag; the stop timing is jittered per attempt.
- Difficulty: g0 1.28; ★★ 580 s / ★★★ 410 s; the first "combine" level.
- Proposed changes: none to the rules. Tutorial bubble on the first freeze: "Time stopped! Aim now, drop before the rush."
  Playtest flag: 9.7 min to ★★ is long for a race. If the medians agree, try `goal.n` 4 → 3 with t2 435000, t3 310000.

**Progression role** (layer 1): This is the third new verb, and it opens the combine act. The boss's phase 3 depends on the player
reading the freeze ring.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_08: Winding Keys  (tier 8, twist)

**Play** (layer 1)
- Goal: `wind_keys`, keys_needed 4. Keyholes: west wall row 3 at layer 1, east wall row 3 at layer 2, back wall (-z)
  row 3 at layer 3, front wall (+z) row 3 at layer 1.
- How it plays: Two pieces per bag carry a brass key stamp on one face. The player builds a support column to a keyhole's
  height, then uses all three rotation pairs (Turn, Flip, Roll) to point the stamp at the wall. The keyhole glows on the ghost
  when the stamp lines up, and the lock winds it. Clears still happen and free a keyhole that a plain cube covered. No twist
  runs, so the only motion on the board is the player's.
- Teaches / tests: orientation as the goal; the payoff for the third rotation pair.
- Rules and minigame blocks: `key_stamp` {key_per_bag 2}. This is the game's only face-orientation goal. No module.
- Board: 8x8, H10, random 8-shape bag; which pieces carry the stamp, and on which face, is seeded per attempt.
- Difficulty: g0 1.30; ★★ 200 s / ★★★ 140 s (hand-set). It is short and thoughtful between two long levels.
- Proposed changes: none to the rules. Two checks for the reviewer: (a) the stars were hand-set for 5x5 but stayed after the
  8x8 move. The goal needs columns, not full layers, so they probably still hold; confirm at playtest. (b) Tutorial bubble on the
  first key piece: "Point the brass key at the glowing keyhole."

**Progression role** (layer 1): This is the fourth and last new verb, with deliberately no twist so the player's attention stays on
orientation. H3 brings the keys back under pistons and a magnet.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_09: Rewind Works  (tier 9, funny)

**Play** (layer 1)
- Goal: `clear_n` n 4, 1 warning.
- How it plays: The bench turns a quarter counter-clockwise every 5 locks. Every 2 clears (or 40 s) the whole stack
  "rewinds", turning upside down in place after a 2 s curling-arrow warning. The player keeps the top flat, because the top
  becomes the floor. A rewind brings buried holes up to the surface, where one well-placed piece can fill three of them.
- Teaches / tests: the combination of two known ideas (turn from 02, stack flip from Meadow 09 / Ice 09). It is the
  hardest regular level in the biome.
- Rules and minigame blocks: `turntable` {turn_locks 5, clockwise false}; `flip` {flip_mode stack, flip_every_layers 2,
  flip_every_ms 40000, flip_warn_ms 2000}. No module.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.35; ★★ 580 s / ★★★ 410 s; the curve's "4", just before the boss.
- Proposed changes: **bind Factory Frenzy here or in H1** (the mockup row puts it at 09). I recommend H1 (below), so that 09
  stays a clean two-rule combine and the boss is the first level with a module chain. Here: none.

**Progression role** (layer 1): This is the peak before the finale. It tests that the player reads two different telegraphs (the tooth
ring and the curling arrows), which never fire on the same resolve. The boss asks for three of them.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_10: Cuckoo's Midnight  (tier 10, twist; boss)

**Play** (layer 1)
- Goal: `clear_n` n 3, 1 warning.
- How it plays: All three Clockwork pressures run together from the start, staggered by the first lock. The clock-face belt
  shifts +x every 3 locks. Two south-wall pistons punch rows 2 and 5 at layer 1 every 4 locks; because the belt moves the
  stack under them, a piston row is "whatever is under the piston now". The stopwatch freezes every 16 s (±3 s) for 2 s,
  then catch-up ×1.5. Piece set: I O T L Tripod Screws plus the Chair. Cuckoo Prime appears only in staging; three clears pop
  the stopper out.
- Teaches / tests: the final exam of belt, pistons and stopwatch.
- Rules and minigame blocks: `conveyor` {every 3, wrap, +x}; `piston_punch` {piston_locks 4, south rows 2 and 5, y1};
  `stopwatch` {16000 ±3000, warn 1000, stop 2000, catchup 1500/2000}. No module, no boss HP.
- Board: 8x8, H12, random 8-shape bag including `chair`.
- Difficulty: g0 1.40; ★★ 435 s / ★★★ 305 s; the curve's "5".
- Proposed changes (**the boss is not a boss yet**: all rules are on from the first lock, there is no HP bar, and nothing
  escalates):
  1. **Phased boss, using the modules the mockups bind to this slot** ("Sort, Defuse, Gear Titan", mockup-alignment §2.2;
     the forge boss is skinned as Cuckoo Prime). The goal becomes `boss_hp` with 3 HP, where each phase's success is one hit.
     - Phase 1 "The rim turns": `conveyor` plus Clockwork Conveyor (`conveyor_sort`, 4 sorted cubes) until 1 hit.
     - Phase 2 "Pendulum punches": add `piston_punch`; `ring_defuse` around a ticking gear (fuse 60 s) until 1 hit.
     - Phase 3 "Midnight forever": add `stopwatch`; clear 1 layer while the A1 two-sided temperature `gauge` (band mode,
       from the forge-boss board) swings, until 1 hit and the bell strikes.
  2. **Interim with today's data** (no module framework): change `goal.type` to `bonk_boss` (as `candy_10`) with HP 3, where
     each clear is one hit, so the player gets an HP bar. Delay `piston_punch` until after clear 1 and `stopwatch` until after
     clear 2 (a proposed per-rule `active_from_clear` field) so the boss escalates instead of front-loading everything.
  3. Change `metadata.level_type` from twist to defender. That gives Clockwork 3 twists in its main 10 (closer to the type-mix
     target), and a boss you hold off reads as a defender level.

**Progression role** (layer 1): This is the biome payoff. Each phase replays a verb the player learned (03 belt, 04 pistons, 06 defuse,
07 stopwatch) and adds one more, so the escalation feels earned. Finishing it opens Neon at 15/30 stars and the hard track.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_bonus: Music Box  (tier 11, completing)

**Play** (layer 1)
- Goal: `shape`, piece_budget 7. The target is a full 4x4 base on layer 0 plus a hollow 4x4 ring on layer 1, centred at
  x2–5, z2–5 (28 cells).
- How it plays: The kit box shows all seven pieces (I I I O O L L). The player picks one, and it falls. Every 2 locks the box
  turns a quarter clockwise. Both target layers are 90°-symmetric, so a turn never ruins progress; it only moves where the gaps
  are. The base must be finished before the ring (support), and the hollow stays empty for the dancer.
- Teaches / tests: the kit-box verb on a moving board, and the biome's wackiest level.
- Rules and minigame blocks: `fill_shape` {trim}; `turntable` {turn_locks 2, clockwise true}; `spawn.arrival` kit_box.
- Board: 8x8, H6, centred target. **No per-attempt variation** (the same kit every time).
- Difficulty: g0 0.60; ★★ 110 s / ★★★ 75 s; an off-curve reward at 20 stars.
- Proposed changes: to respect "random every attempt" without losing the authored puzzle, add a `pieces.kit_variants` list
  (proposed field) of 3 solvable 7-piece kits for the same target, drawn per attempt. The ring is always I + L + L (one
  I on a ring side, the two Ls closing the other three sides); only the base varies: kit A [I I I O O L L] (base I I O O,
  the current kit), kit B [I I I I I L L] (base four I rows), kit C [I O O O O L L] (base four Os). The level designer gives
  the validator one known solution per kit. Keep `skill.redraw` off.

**Progression role** (layer 1): An optional reward between the boss and the hard track. It is calm, toy-like, and reuses the Cog Turn
in its friendliest form.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_h1: Magnet Tram  (tier 12, twist)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: The street still rolls east every 3 locks. Meanwhile the depot electro-magnet at the west wall (column 0,
  row 3) tugs the falling piece one cell west every 3 s, after a 600 ms blue crackle. The two forces pull in opposite
  directions: aim one cell east when a pull is due, or hard drop inside the warning window.
- Teaches / tests: belt plus magnet under hard-track speed.
- Rules and minigame blocks: `conveyor` {3, wrap, +x}; `magnet_pull` {magnet_col [0,3], pull_interval_ms 3000,
  pull_warn_ms 600, pull_axis x}. No module.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.30; ★★ 545 s / ★★★ 375 s.
- Proposed changes:
  1. `fall.g0` 1.30 → 1.42. The hard track should sit at or above the boss (1.40), and this level has no gravity-scaling rule.
  2. **Bind Factory Frenzy** (mockup #19, `conveyor_sort` order mode, which the mockup row lists as "Factory Frenzy at speed"
     for the Clockwork hard track). Once the module lands, an order card on the depot asks for 3 cubes of a colour, and the
     magnet is what drags pieces into the intake. Interim: none beyond the g0.

**Progression role** (layer 1): The first hard remix. It takes the most familiar Clockwork rule (the belt) and adds the opposing magnet.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_h2: Boiler Bench  (tier 13, twist)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: The bench turns a quarter every 4 locks. Every lock without a clear builds steam (+0.12 gravity scale per
  lock, cap ×2.2), and the drizzle visibly speeds up. A clear blows the whistle and resets the pressure. The player has to take
  small, early clears and keep the stack flat so turns stay free, instead of saving up for a big clear.
- Teaches / tests: risk timing (when to cash in) on a moving board.
- Rules and minigame blocks: `turntable` {turn_locks 4, clockwise}; `pressure_cooker` {step 0.12, max_scale 2.2}.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.30 (effective up to 2.86 at full steam); ★★ 540 s / ★★★ 375 s.
- Proposed changes: none. g0 1.30 is right because the boiler supplies the speed.

**Progression role** (layer 1): Middle remix. It turns the Cog Turn into a pacing decision rather than a spatial one.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### clockwork_h3: Magnet Keys  (tier 14, twist)

**Play** (layer 1)
- Goal: `wind_keys`, keys_needed 5. Keyholes: west row 3 y1, east row 3 y2, back row 3 y3, front row 3 y1, west row 5 y3.
- How it plays: The player winds five keys while two pistons (west row 0 y1, east row 3 y2, every 5 locks) shove rows and an
  east-wall magnet (column 7, row 3) tugs every falling piece east every 4 s (800 ms warning). The magnet helps reach the east
  keyhole and fights the player on the two west ones, so they do the west keys straight after a pull.
- Teaches / tests: the orientation exam under three pressures.
- Rules and minigame blocks: `key_stamp` {2 per bag}; `piston_punch` {piston_locks 5}; `magnet_pull` {magnet_col [7,3],
  4000 / 800, x}.
- Board: 8x8, H10, random 8-shape bag; key faces seeded per attempt.
- Difficulty: g0 1.30; ★★ 240 s / ★★★ 170 s (hand-set). It is the hardest Clockwork level.
- Proposed changes: **check the pistons against the keyholes.** The east piston faces row 3 at y2, which is exactly the east
  keyhole's cell (east row 3 y2). The design rule is "a piston never faces a keyhole row". Move the east piston to row 5 y2 so a
  push can never shove a key cube out of line before it locks.

**Progression role** (layer 1): The biome's final exam on the hard track. It brings the 08 key goal back with 04's pistons and H1's
magnet.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_
