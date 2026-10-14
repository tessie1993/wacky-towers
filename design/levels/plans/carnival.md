# Carnival plan: the Tumble Fair

> Layer 1 (Play, Progression role) by level-design, 2026-10-14. Truth for goals, rules, boards, knobs and stars:
> `src/levels/carnival/<id>/<id>.json`. Design intent: `design/levels/tumble-fair.md` (see the mapping warning below).
> Minigame blocks: `design/levels/mockup-alignment.md` §2.2 (Tumble Fair row) and §3 (the Midway hub), and
> `minigame-stages.md` §1.14–1.15 (Tumbling Towers, Balloon Race). Rule definitions: `design/gdd/mechanics-wave3.md`.
> Every number in "Proposed changes" is a tunable default for the user to approve; nothing here edits a JSON.

## Biome intro

**The Tumble Fair** is Baron Balloon's travelling fair: ring toss, coconut shy, mirrors, teacups, the big top, the ferris
wheel, confetti cannons. It is the home of the 4-player tournament (the Midway hub, mockup-alignment §3), so its levels are
where solo players should meet the **party minigames as levels** first.

**Mapping warning: Carnival is not the same thing as tumble-fair.md** (checked; the user and creative-director need to decide):

| | `design/levels/tumble-fair.md` | Catalog `carnival` + JSONs |
|---|---|---|
| Size | 5 levels + bonus, **no hard track** | 10 levels + bonus + h1–h3 (14) |
| Unlock | after `candy_10`, no star gate, side island | 12th and last biome, after Celestial |
| Gravity | g0 0.70 → 1.05 (gentle) | g0 1.20 → 1.55 (the game's fastest) |
| Ids | `tumble_fair_01..05`, `_bonus` | `carnival_01..10`, `_bonus`, `_h1..h3` |
| JSON `metadata.source` | n/a | `design/levels/carnival.md`, **which does not exist** |

Only the names carry over (Helter-Skelter, Hall of Mirrors, Ferris Wheel, Baron Balloon). This plan treats the JSONs as
truth: Carnival is a **post-finale encore biome** at top gravity. Recommendation for the owners: write
`design/levels/carnival.md` as the source the JSONs cite, and retire or merge tumble-fair.md. If Carnival really is meant to
open after Candy, every g0 in this file is about 0.4 too fast.

**What the JSONs do today, and the gaps.**
1. **Names and rules are crossed.** `carnival_03` "Hall of Mirrors" has no mirror (it has turntable + Fever).
   `carnival_04` "Teacup Twirl" does not spin (it has paint + colour pop). `carnival_08` "Ferris Wheel Climb" neither turns nor
   climbs (it has a boiler + fog). `carnival_h2` "Spin-o-Rama" has no spin. The mirror the title promises sits in 07.
2. **Familiar faults:** `carnival_05` has unreachable stars for an 8x8 height race, and `carnival_06` ships a `fixed_list`.
3. **The curve is flat at the top.** 09, 10 and H1–H3 are all g0 1.55, so the boss and all three remixes are no faster than
   09. The finale's four rules include two score-only ones (Fever, Golden Row) and there is no boss HP.
4. **No minigame blocks**, in the one biome whose fiction *is* minigames. The mockups give it Balloon Race, Tumbling Towers,
   Bridge Builders, Bomb Defuse and Lava Escape (the Midway's four islands), and `minigame-stages.md` places Tumbling Towers
   and Balloon Race here.

**Target arc (an encore, so remix-first).** 01–03 are fairground warm-ups: ring toss, coconut shy, the mirror tent. 04–06 twist
(teacups, Balloon Race, prize booth). 07–09 combine (bumper paint, ferris loop-the-loop, confetti cannons). 10 is the Baron's
**Grand Show**: a three-round mini-tournament against the Baron, which previews the party mode.

### Curve table (current JSON, with the proposed value in brackets where it changes)

| # | id | Type | Rules (JSON) [proposed] | Goal | Board | g0 | ★★ / ★★★ (s) | Intensity 1–5 | Beat |
|---|---|---|---|---|---|---|---|---|---|
| 01 | carnival_01 | funny | mascot_hint, angle_gem, golden_row, balloon | Clear 2 | 8x8, H10 | 1.20 | 290 / 205 | 1 | ring toss warm-up |
| 02 | carnival_02 | balance | mascot_hint, angle_gem, star_coins, mushroom_popup, wobble 7 [− star_coins] | Clear 3 | 8x8, H10 | 1.25 | 435 / 310 | 2 | coconut shy |
| 03 | carnival_03 | twist | fever_rush, turntable /6 [mirror + echo_drop] | Clear 4 [3] | 8x8, H10 | 1.28 | 585 / 410 [435 / 310] | 2 | Hall of Mirrors |
| 04 | carnival_04 | twist | chameleon_paint, colour_pop [turntable /6 + fever_rush] | Clear 3 | 8x8, H10 | 1.33 | 435 / 310 | 3 | Teacup Twirl |
| 05 | carnival_05 | race | build_race, magnet_pull, big_cube 0.5 [+ race_rival; Balloon Race] | Height 10 [7], cov 0.6 | 8x8, H12 | 1.38 | 240 / 170 [420 / 295] | 2 | Big Top / Balloon Race |
| 06 | carnival_06 | completing | fill_shape, jumbled_queue /3, fixed list [random bag] | Shape 32 | 8x8, H6 | 0.60 | 95 / 65 [125 / 90] | 2 | prize booth |
| 07 | carnival_07 | funny | echo_drop, mirror [chameleon_paint + colour_pop] | Clear 4 | 8x8, H10 | 1.45 | 580 / 410 | 3 | Bumper Blocks |
| 08 | carnival_08 | twist | pressure_cooker, fog [pressure_cooker + flip] | Clear 3 | 8x8, H10 | 1.50 | 435 / 310 | 4 | Ferris loop-the-loop |
| 09 | carnival_09 | defender | storm_bolt 9 s, ice_slide +z | Clear 4 | 8x8, H10 | 1.55 | 580 / 410 | 4 | confetti cannons |
| 10 | carnival_10 | twist [boss] | mystery_piece, storm_bolt, fever_rush, golden_row [3 rounds vs Baron] | Clear 3 [Baron 3 HP] | 8x8, H12 | 1.55 [1.60] | 440 / 305 [540 / 380] | 5 | the Baron's Grand Show |
| B | carnival_bonus | funny | rusty_hinge 1, turntable /3, confetti_fill | Clear 2 | 9x9, H10 | 1.30 | 365 / 260 | 2 | lucky ticket |
| H1 | carnival_h1 | defender | magnet_pull, storm_bolt 8 s | Clear 4 | 8x8, H10 | 1.55 [1.60] | 550 / 375 | 4 | hard: midnight midway |
| H2 | carnival_h2 | funny | mystery_piece /4, echo_drop /4 [mystery + turntable /3] | Clear 4 | 8x8, H10 | 1.55 [1.62] | 540 / 375 | 5 | hard: spin-o-rama |
| H3 | carnival_h3 | twist | rusty_hinge 2, pressure_cooker 0.12 / 2.0 | Clear 3 | 8x8, H10 | 1.55 [1.65] | 405 / 285 | 5 | hard: pressure cooker prize |

Sawtooth with the changes: 1-2-2-3-2-2-3-4-4-5. Every proposed rule swap only rotates rules the biome already ships (03 ↔
04 ↔ 07, fog → flip in 08, echo → turntable in H2), so the rule budget does not grow. The hard track gets its own step above
the boss (1.60 → 1.65).

---

### carnival_01: Ring Toss Rally  (tier 1, funny)

**Play** (layer 1)
- Goal: `clear_n` n 2, rescue, 2 warnings.
- How it plays: Calm O and I openers. Layer 1 is the gold "ring-toss row": clearing it pays +200 and counts toward a gold
  tally. One piece per bag floats in on one of the Baron's balloons (gravity ×0.6, drifting every 3 s), so the player hooks it
  back on line like a ring toss. A helper points at a good cell, and a prize duck (`angle_gem`) hides at one camera angle.
- Teaches / tests: the Carnival look and "aim the floaty one"; aiming a clear at a particular row.
- Rules and minigame blocks: `mascot_hint` {}; `angle_gem` {skin "duck_prize"}; `golden_row` {start_layer 1, bonus 200,
  goal_counter "gold"}; `balloon` {1 per bag, g ×0.6, drift 3000}. No module.
- Board: 8x8, H10, random 8-shape bag; the first 2 come from {O, I}.
- Difficulty: g0 1.20; ★★ 290 s / ★★★ 205 s; the floor (high in absolute terms, because this is the encore biome).
- Proposed changes: none to the rules. Tutorial bubble (on the gold row's first highlight): "Clear the gold row for a prize!"

**Progression role** (layer 1): The encore opener after the Celestial finale. It is busy-looking but gentle, so the jump in speed is
softened by two warnings and a helper.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_02: Helter-Skelter  (tier 2, balance)

**Play** (layer 1)
- Goal: `clear_n` n 3, rescue, 1 warning.
- How it plays: The coconut shy. Every 4 locks a coconut lands on the stack as an obstacle (up to 4), and the tower wobbles if
  it leans (`wobble_max` 7), shedding a loose cube. Five star coins sit from layer 1 up and pay +50 each when cleared. The
  player builds level around the coconuts and clears the coin layers.
- Teaches / tests: balance with obstacles landing on the stack.
- Rules and minigame blocks: `mascot_hint`; `angle_gem`; `star_coins` {coins 5, min_layer 1, score 50, goal_counter "coins"};
  `mushroom_popup` {4, max 4, skin "coconut"}; `wobble` {wobble_max 7}. No module.
- Board: 8x8, H10, random 8-shape bag; coin and coconut cells random per attempt.
- Difficulty: g0 1.25; ★★ 435 s / ★★★ 310 s.
- Proposed changes: three gameplay rules at tier 2 is busy. Drop `star_coins`, since it is score-only and competes with the
  coconuts for the player's eye. **Later module block: Tumbling Towers** (`balance_plate`, mockup #6; `minigame-stages.md`
  §1.14 puts it right after this level). Once `balance_plate` exists, replace `wobble` with it as a seesaw over the dunk tank:
  the Balance thermometer and the coconuts are the counter-weights.

**Progression role** (layer 1): Second warm-up. It sets up the balance verb that the Grand Show's round 2 tests.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_03: Hall of Mirrors  (tier 3, twist)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: Today the stack turns a quarter every 6 locks, and two clears within 7 s start Fever (8 s, gravity ×0.6,
  +100 per clear). **There is no mirror in the Hall of Mirrors.**
- Teaches / tests: (today) turn + combo. (Intended by the name) a reflected twin.
- Rules and minigame blocks: `fever_rush` {7000, 2, 8000, 100, 0.6}; `turntable` {turn_locks 6, clockwise, warn 1}.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.28; ★★ 585 s / ★★★ 410 s (nearly 10 min at tier 3).
- Proposed changes (**name and rules crossed**): move 07's rules here. `mirror` {mirror_axis "x", skin "funhouse"} gives
  every piece a funhouse twin, and `echo_drop` {every 4} makes every 4th piece repeat the last shape, "the mirror shows you
  the same thing again". Move Fever + turntable to 04. With mirror doubling the fill rate, set `goal.n` 4 → 3 and stars t2
  435000, t3 310000.

**Progression role** (layer 1): Last warm-up. The funhouse twin is the biome's signature, which tumble-fair.md also marks as the
signature (★PROTO) and puts at slot 03.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_04: Teacup Twirl  (tier 4, twist)

**Play** (layer 1)
- Goal: `clear_n` n 3, rescue, 1 warning.
- How it plays: Today a landed piece that touches two cubes of one colour takes that colour, and 6 touching same-colour cubes
  pop (layers still clear). The player paints regions and pops them. **Nothing twirls.**
- Teaches / tests: (today) colour painting, a callback to Neon. (Intended) spinning teacups.
- Rules and minigame blocks: `chameleon_paint` {min_neighbours 2}; `colour_pop` {pop_min 6, layer_clear_too true}.
- Board: 8x8, H10, random 8-shape bag; colours random per piece.
- Difficulty: g0 1.33; ★★ 435 s / ★★★ 310 s.
- Proposed changes (**name and rules crossed**): take 03's `turntable` {turn_locks 6, clockwise, warn 1} as the teacup's spin
  and `fever_rush` {7000, 2, 8000, 100, 0.6} as the "dizzy rush": two quick clears make the teacup spin wildly, but the
  drizzle slows. Move paint + pop to 07 (Bumper Blocks). Tutorial bubble on the first turn: "The teacup spins! Keep your stack
  flat."

**Progression role** (layer 1): Opens the twist act with a known board move made playful by Fever.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_05: Big Top Tower  (tier 5, race)

**Play** (layer 1)
- Goal: `height` h_target 10, height_coverage 0.6, trim top-out, no fail.
- How it plays: A no-clear climb up the big top's pole. Big cubes come often (weight 0.5). Every 4 s a hook-a-duck magnet at
  the east wall (column 7, row 3) tugs the falling piece one cell east, after an 800 ms warning, so the player drops in the
  cooldown or uses the tug to reach the east side.
- Teaches / tests: a breather race with a pull.
- Rules and minigame blocks: `build_race` {}; `magnet_pull` {magnet_col [7,3], 4000 / 800, x}; `big_cube` weight 0.5.
- Board: 8x8, H12; random bag including big cubes.
- Difficulty: g0 1.38; ★★ 240 s / ★★★ 170 s. **Unreachable** (the same scaling fault as clockwork_05 and celestial_05).
- Proposed changes:
  1. `goal.h_target` 10 → 7; `stars` t2 420000, t3 295000. Add `race_rival` {rival_rate 0.25, rubber_band 0.5} as the Baron's
     own tower, so the race type is felt.
  2. **Bind Balloon Race** (mockup #34, `road_race` + A12 `balloon_lift`, the Tumble Fair 05 slot and `minigame-stages.md`
     §1.15). Once the modules land, the stack is cargo lifted by balloons: build a light, wide tower and gusts push it. Interim
     form with existing rules: swap `magnet_pull` for `balloon` {1 per bag, g ×0.6, drift 3000} + `gust` {fixed, +x, 9000,
     2000, 1, 1000}. This is the solo preview of the tournament's Balloon Race round.

**Progression role** (layer 1): The breather in the middle of the act, and the first time the solo player meets a Midway
tournament round.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_06: Prize Booth Puzzle  (tier 6, completing)

**Play** (layer 1)
- Goal: `shape`, piece_budget 8. The target is a 4x4x2 prize block on layers 0–1, centred (32 cells).
- How it plays: The player fills the prize shelf from a **fixed** list of Is and Os at slow gravity with a 3-piece preview.
  Every 3 locks the booth keeper jumbles the preview queue, so the plan the player made changes.
- Teaches / tests: exact fill when the queue is shuffled.
- Rules and minigame blocks: `fill_shape` {trim}; `jumbled_queue` {every 3}; `pieces.fixed_list` [i o i o o i o i].
- Board: 8x8, H6, centred target; **no per-attempt variation** in the pieces (only the jumble order).
- Difficulty: g0 0.60; ★★ 95 s / ★★★ 65 s.
- Proposed changes (**standing-rule violation**: `fixed_list`):
  1. Remove `fixed_list`. Use a random bag of {i 0.5, o 0.5}, `piece_budget` 8 → 11, and allow overspill. The jumble stays: it
     is the level's joke, and with a random bag it is a fair one.
  2. **Bomb Defuse block** (mockup #33, `ring_defuse` + `countdown_bomb`; a Midway island). Once the module exists, the prize
     is a bomb-shaped surprise box, and the player fills the ring before the fuse runs out. Interim: `goal.time_limit_ms` 120000.
  3. `stars` t2 125000, t3 90000.

**Progression role** (layer 1): The calm puzzle beat and the second Midway-island preview.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_07: Bumper Blocks  (tier 7, funny)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: Today every piece lands with a funhouse twin mirrored across x, and every 4th piece echoes the shape just
  played. Twins bump into the gap you were saving, which is the joke.
- Teaches / tests: symmetric planning plus a predictable repeat.
- Rules and minigame blocks: `echo_drop` {every 4}; `mirror` {mirror_axis "x", skin "funhouse"}.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.45; ★★ 580 s / ★★★ 410 s; opens the combine act.
- Proposed changes: take 04's colour rules (mirror and echo move to 03). **Bumper paint**: `chameleon_paint`
  {min_neighbours 2} + `colour_pop` {pop_min 6, layer_clear_too true}, with `spawn.colour_count` 3. A piece that bumps two cubes
  of one colour takes their paint, and 6 alike pop. To make it a *combine* level, keep `echo_drop` {every 4} as well, so the
  echoed piece is a planned second chance to finish a colour group.

**Progression role** (layer 1): The first combine level. It pairs Neon's paint (callback) with the Carnival echo.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_08: Ferris Wheel Climb  (tier 8, twist)

**Play** (layer 1)
- Goal: `clear_n` n 3, rescue, 1 warning.
- How it plays: Today every lock without a clear builds popcorn steam (+0.08 gravity scale, cap ×1.6) until a clear releases
  it. The stack fades under popcorn steam (visible 5 s, then 15 %, revealed for 0.6 s per lock). The player clears early and
  remembers the stack. There is no wheel.
- Teaches / tests: risk timing plus memory.
- Rules and minigame blocks: `pressure_cooker` {step 0.08, max_scale 1.6}; `fog` {5000, 1000, 0.15, 600, "popcorn_steam"}.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.50 (raised from 1.40 by the 2026-10-14 curve pass); ★★ 435 s / ★★★ 310 s.
- Proposed changes (**name and rules crossed**): replace `fog` with the wheel going over the top, `flip` {flip_mode "stack",
  flip_every_layers 2, flip_every_ms 40000, flip_warn_ms 2000}. Every two clears the car loops and the stack turns over. Keep
  `pressure_cooker` as the climb's rising gauge. The aha: a clear both releases the steam **and** brings the wheel closer to
  the loop, so flat tops matter twice.

**Progression role** (layer 1): The middle combine level, and the hardest Carnival rules before the cannons.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_09: Confetti Cannon  (tier 9, defender)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: Confetti cannons fire at the tower every 9 s (±2 s, 1.5 s telegraph), and every landed piece slides one cell
  toward +z on the slick stage before it locks. The player aims one cell short (−z) and keeps the stack low so cannon hits are
  shallow.
- Teaches / tests: defending under fire while correcting for a slide.
- Rules and minigame blocks: `storm_bolt` {9000, warn 1500, jitter 2000}; `ice_slide` {slide_dir "+z", slide_cells 1}.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.55; ★★ 580 s / ★★★ 410 s; the peak before the boss.
- Proposed changes: add `confetti_fill` {min_layers 2, max_fill 3}, so a double clear fires your own cannon back and fills up to
  3 covered holes. That makes it a defender level with a counterattack, and it teaches the Grand Show's round-3 reward.

**Progression role** (layer 1): The peak of the act. It rehearses the bolt telegraph and the double-clear reward that the boss uses.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_10: Baron Balloon's Big Show  (tier 10, twist; boss)

**Play** (layer 1)
- Goal: `clear_n` n 3, rescue, 1 warning.
- How it plays: Every 5th piece is a mystery piece, fireworks bolts hit every 12 s (±2 s, 1.5 s telegraph), two clears within
  8 s start Fever (×0.6 gravity, +150), and layer 2 is a +300 golden row. Three clears end the show. The Baron is a watcher in
  staging only; two of the four rules are score-only and do not affect survival.
- Teaches / tests: (today) a pile-up of known rules.
- Rules and minigame blocks: `mystery_piece` {every 5}; `storm_bolt` {12000, 1500, 2000}; `fever_rush` {8000, 2, 8000, 150,
  0.6}; `golden_row` {start_layer 2, bonus 300, goal_counter "gold"}. Pieces include `chair`.
- Board: 8x8, H12, random bag + chair.
- Difficulty: g0 1.55 (same as 09); ★★ 440 s / ★★★ 305 s.
- Proposed changes (**make it a show, not a pile-up**):
  1. **The Grand Show: a three-round mini-tournament against the Baron**, which previews the party mode. Each round is a
     Midway island template played against one scripted bot (`opponents.bots` [{cast "baron", skill 0.5}], `minigame-stages.md`
     §0 shared block, same `round_seed`). Winning a round is one hit on the Baron's `boss_hp` 3:
     - Round 1 "Balloon Race" (`road_race` + `balloon_lift`, as 05).
     - Round 2 "Tumbling Towers" (`balance_plate`, as 02's later form).
     - Round 3 "Confetti Finale": clear race (`versus_clear_race` template) with `storm_bolt` fireworks and
       `confetti_fill` (as 09).
     Losing a round costs the warning, not the level. The tournament templates in `assets/data/tournament/templates.json`
     (`versus_*`) are the place to start.
  2. **Interim without modules or bots**: `goal.type` `bonk_boss` HP 3, one hit per clear. Phase the rules by hit (a proposed
     per-rule `active_from_clear`): hit 0, `balloon` {1, 0.6, 3000} (the Baron's balloons, the tumble-fair.md boss idea); hit
     1, add `storm_bolt`; hit 2, add `mystery_piece`. Drop `golden_row` (score-only clutter in a boss) and keep `fever_rush` as the
     comeback mechanic.
  3. `fall.g0` 1.55 → 1.60; `stars` t2 540000, t3 380000 for the three-act run. Retype it as `defender`.

**Progression role** (layer 1): The encore finale and the bridge from the solo campaign to the Tumble Fair tournament. Beating the Baron
unlocks the Midway's wheel (mockup-alignment §3) and the hard track.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_bonus: Lucky Ticket  (tier 11, funny)

**Play** (layer 1)
- Goal: `clear_n` n 2, rescue, 1 warning.
- How it plays: The ticket wheel turns the stack a quarter every 3 locks, and each piece may only be rotated once (a rusty
  hinge), so the player picks a placement that suits the piece's spawn orientation and lets the wheel do the turning. A
  multi-layer clear fires confetti that fills up to 4 covered holes.
- Teaches / tests: letting the board rotate for you when you cannot.
- Rules and minigame blocks: `rusty_hinge` {max_turns 1}; `turntable` {turn_locks 3, clockwise, warn 1}; `confetti_fill`
  {min_layers 2, max_fill 4}.
- Board: 9x9, H10, random 8-shape bag.
- Difficulty: g0 1.30; ★★ 365 s / ★★★ 260 s; an off-curve reward.
- Proposed changes: with `n` 2, `confetti_fill` (which needs a 2-layer clear) fires at most once. Set `goal.n` 2 → 4 and
  stars t2 540000, t3 380000, so the confetti loop is the level. Optional block: the tumble-fair.md **Prize Shelf**
  (`fill_shape` race, 75 s) as a second bonus, but with a random bag rather than its fixed list.

**Progression role** (layer 1): An optional reward after the Baron.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_h1: Midnight Midway  (tier 12, defender)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: A shooting-gallery magnet at column 1, row 4 tugs every falling piece west every 3 s (600 ms warning), and
  bolts hit every 8 s (±2 s). The player drops inside the pull cooldown and keeps the stack low against the bolts.
- Teaches / tests: defender under a fast pull.
- Rules and minigame blocks: `magnet_pull` {magnet_col [1,4], 3000 / 600, x}; `storm_bolt` {8000, 1500, 2000}.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.55; ★★ 550 s / ★★★ 375 s.
- Proposed changes: `fall.g0` 1.55 → 1.60. Later module block: **Lava Escape** (`floe_survive`, the Midway's fourth island)
  as the night-time survival version.

**Progression role** (layer 1): The first hard remix.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_h2: Spin-o-Rama  (tier 13, funny)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: Today every 4th piece is a mystery shape, and every 4 locks the last shape echoes as the next one. The two
  run on the same beat, so a mystery piece and an echo can collide. **Nothing spins.**
- Teaches / tests: improvising with surprise and repeated shapes.
- Rules and minigame blocks: `mystery_piece` {every 4}; `echo_drop` {every 4}.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.55; ★★ 540 s / ★★★ 375 s.
- Proposed changes (**name and rules crossed**): replace `echo_drop` with `turntable` {turn_locks 3, clockwise, warn 1}, so
  surprise shapes land on a fast-spinning ride. Move `mystery_piece` to every 5, so it does not land on the turn beat (Readable
  Chaos). `fall.g0` 1.55 → 1.62.

**Progression role** (layer 1): The middle remix, the hard version of the teacup.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### carnival_h3: Pressure Cooker Prize  (tier 14, twist)

**Play** (layer 1)
- Goal: `clear_n` n 3, rescue, 1 warning.
- How it plays: Each piece can rotate at most twice (rusty hinge), and every clearless lock builds steam (+0.12, cap ×2.0)
  until a clear releases it. The player commits to placements fast, takes small clears early, and never chases a perfect fit.
- Teaches / tests: decisive play under rising speed, the game's last mastery test.
- Rules and minigame blocks: `rusty_hinge` {max_turns 2}; `pressure_cooker` {step 0.12, max_scale 2.0}.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.55 (raised from 1.45 by the 2026-10-14 curve pass); ★★ 405 s / ★★★ 285 s.
- Proposed changes: `fall.g0` 1.55 → 1.65, the top of the whole game. Effective speed at full steam is then 3.3, so playtest
  the cap; if it is unplayable, keep max_scale 2.0 and lower g0 to 1.60.

**Progression role** (layer 1): The final unlock in the catalog: an encore-of-the-encore for completionists.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_
