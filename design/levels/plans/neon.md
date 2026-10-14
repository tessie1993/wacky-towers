# Neon plan: Glowtown

> Layer 1 (Play, Progression role) by level-design, 2026-10-14. Truth for goals, rules, boards, knobs and stars:
> `src/levels/neon/<id>/<id>.json`. Design intent: `design/levels/neon.md` (a short proposal table, no per-level specs).
> Minigame blocks: `design/levels/mockup-alignment.md` §2.2 (Neon row) and `minigame-stages.md` §1.11–1.12.
> Every number in "Proposed changes" is a tunable default for the user to approve; nothing here edits a JSON.

## Biome intro

**Glowtown** is a bright toy city at violet dusk: painted signposts, cyan and peach accents, and no flashing effects. It is
biome 10 of 12, between Clockwork and Celestial, and the story thread runs to Mizzle's lonely billboard. The biome should feel
like **a night out**: fast, colourful, a little show-off.

**What the JSONs do today, and the gaps.**
1. **Neon has no verb of its own.** Its main ten reuse Clockwork's stopwatch (02, 08), conveyor (03, 10) and turntable (09)
   straight after the player spent a whole biome on them. Only `mirror` (04) and `bubble` (07) are fresh. The colour and light
   rules that suit a neon city (`chameleon_paint`, `colour_pop`, `mono_layer`, `fever_rush`, `golden_row`) appear only in the
   bonus and the hard track.
2. **Six rules ship with `params: {}`** (02 stopwatch, 03 conveyor, 04 mirror, 07 bubble, 09 turntable and gust, 10 all
   three), so what the player sees is whatever the code defaults are. Telegraph timings must be data in the level.
3. **`neon_05` keeps 5x5 star times on an 8x8 height race** with no coverage set, so its stars cannot be reached.
4. **`neon_06` ships a `fixed_list`**, which breaks the random-every-attempt rule.
5. **Curve inversion across biomes.** Neon g0 runs 0.95–1.30 and Clockwork's runs 0.97–1.40, so the later biome is slower at
   every tier. `neon_10` (1.30) is gentler than `clockwork_10` (1.40).
6. **No minigame blocks.** The mockups give Neon Glow Paint Clash, Neon Maze, Rail Rush, Cyber Defender and Laser Sprint, and
   none is bound. The finale has `mascot_role: boss` but no boss mechanic.

**Target arc.** The plan teaches Neon's **light and colour** verbs (01 balloons, 03 paint, 04 mirror) and twists them (05
climb, 06 pixel sign, 07 bubbles). It then combines them (08 defend, 09 surge) and ends on a three-phase billboard showdown
that uses the Glow Paint Clash block (10).

### Curve table (current JSON, with the proposed value in brackets where it changes)

| # | id | Type | Rules (JSON) | Goal | Board | g0 | ★★ / ★★★ (s) | Intensity 1–5 | Beat |
|---|---|---|---|---|---|---|---|---|---|
| 01 | neon_01 | balance | balloon 1/bag | Clear 1 [2] | 8x8, H8 | 0.95 [1.00] | 195 / 140 [300 / 210] | 1 | teach: floaty party balloons |
| 02 | neon_02 | race | stopwatch {}, race_rival 0.26 | Clear 2 | 8x8, H10 | 1.00 [1.05] | 335 / 235 | 2 | teach: race through the lights |
| 03 | neon_03 | twist | conveyor {} [chameleon_paint + colour_pop] | Clear 3 | 8x8, H10 | 1.05 [1.10] | 465 / 330 | 2 | teach: Glow Paint (new) |
| 04 | neon_04 | funny | mirror {} | Clear 4 | 8x8, H10 | 1.10 [1.15] | 605 / 425 | 3 | twist: mirror twins |
| 05 | neon_05 | race | build_race | Height 9 [6, cov 0.6] | 8x8, H12 | 1.10 | 260 / 185 [385 / 270] | 2 | breather climb |
| 06 | neon_06 | completing | fill_shape, fixed list [random bag] | Shape 40 | 8x8, H6 | 0.90 | 80 / 55 [120 / 85] | 2 | puzzle: pixel sign |
| 07 | neon_07 | funny | bubble {} | Clear 4 | 8x8, H10 | 1.15 [1.22] | 510 / 365 | 3 | twist: floating pieces |
| 08 | neon_08 | defender | stopwatch {}, storm_bolt 12 s | Survive 150 s | 8x8, H10 | 1.20 [1.28] | s2 1 / s3 2 | 4 | combine: Cyber Defender |
| 09 | neon_09 | twist | turntable {}, gust {} | Clear 4 | 8x8, H12 | 1.25 [1.33] | 585 / 410 | 4 | combine: power surge |
| 10 | neon_10 | twist [boss] | conveyor, mirror, gust [phased] | Clear 4 [boss] | 9x9 [8x8], H14 | 1.30 [1.42] | 645 / 455 [480 / 340] | 5 | payoff: the Lonely Billboard |
| B | neon_bonus | twist | mirror, fever_rush, golden_row | Clear 2 | 9x9, H10 | 1.10 | 345 / 240 | 2 | party |
| H1 | neon_h1 | race | stopwatch, fever_rush | Clear 4 | 8x8, H10 | 1.30 [1.42] | 545 / 375 | 4 | hard: freeze into Fever |
| H2 | neon_h2 | twist | turntable /5, gust rotating, golden_row | Clear 4 | 8x8, H12 | 1.30 [1.42] | 550 / 375 | 4 | hard: spotlight surge |
| H3 | neon_h3 | twist | mono_layer, mirror, chameleon_paint | Clear 4 | 8x8, H10, 3 colours | 1.30 [1.40] | 550 / 375 | 5 | hard: colour exam |

Sawtooth with the changes: 1-2-2-3-2-2-3-4-4-5. The g0 lift brings Neon level with or just above Clockwork at the same tier.
The boss (1.42) sits just above `clockwork_10` (1.40), so the campaign keeps rising into Celestial.

---

### neon_01: Welcome to Glowtown  (tier 1, balance)

**Play** (layer 1)
- Goal: `clear_n` n 1, rescue, 1 warning.
- How it plays: The player stacks in a calm square. One piece per bag arrives tied to a party balloon: it falls at ×0.7
  gravity and drifts sideways every 4 s, so you nudge it back on line before it lands. It is a gentle reminder that a piece
  is not always where it spawned.
- Teaches / tests: the controls in the Neon look; leading a slow, drifting piece.
- Rules and minigame blocks: `balloon` {balloon_per_bag 1, balloon_g_mult 0.7, balloon_drift_ms 4000}. No module.
- Board: 8x8, H8, random 8-shape bag; which piece carries the balloon is random per attempt.
- Difficulty: g0 0.95; ★★ 195 s / ★★★ 140 s; the floor of the curve.
- Proposed changes: `goal.n` 1 → 2 (one clear on 8x8 is about 16 pieces and ends before the player meets a second balloon);
  `stars` t2 300000, t3 210000; `fall.g0` 0.95 → 1.00. Tutorial bubble on the first balloon piece: "Balloon pieces drift. Nudge
  them back!"

**Progression role** (layer 1): The on-ramp after the Clockwork boss. It drops the intensity to 1 and introduces a soft balance idea
that the bubble level (07) builds on.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_02: Traffic Lights  (tier 2, race)

**Play** (layer 1)
- Goal: `clear_n` n 2, rescue, 1 warning.
- How it plays: The traffic lights turn red, the falling piece freezes in mid-air, and the player aims while it hangs. Green
  then waves it through at catch-up speed. A ghost rival (0.26 %/s, rubber band 0.5) is racing the same two clears, and it
  warns at 80 %.
- Teaches / tests: racing a visible rival while reading a timing twist the player already knows from Clockwork.
- Rules and minigame blocks: `stopwatch` {} (**code defaults**); `race_rival` {rival_rate 0.26, rubber_band 0.5,
  rival_warn_pct 80}. No module.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.00; ★★ 335 s / ★★★ 235 s.
- Proposed changes: write the stopwatch params explicitly as the traffic-light cycle: {stop_every_ms 12000, stop_jitter_ms
  2000, stop_warn_ms 1000 (amber), stop_ms 2000 (red), catchup_scale 1400, catchup_ms 2000 (green)}. The milder catch-up
  than Clockwork's suits a tier-2 level. `fall.g0` 1.00 → 1.05.

**Progression role** (layer 1): A known twist reskinned (red/amber/green), so the new thing in 02 is only the rival. The race
type comes early so that 05 and H1 can build on it.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_03: Moving Sidewalk  (tier 3, twist)

**Play** (layer 1)
- Goal: `clear_n` n 3, rescue, 1 warning.
- How it plays: Today, a moving sidewalk shifts the whole stack along a belt on a schedule and the player drops where the gap
  will be. It is the **third conveyor level in a row** for the player (clockwork_03, clockwork_10, neon_03).
- Teaches / tests: nothing new (the conveyor is known).
- Rules and minigame blocks: `conveyor` {} (code defaults). No module.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.05; ★★ 465 s / ★★★ 330 s.
- Proposed changes (**samey; give Neon its signature verb here**):
  1. Replace `conveyor` with **Glow Paint**: `chameleon_paint` {min_neighbours 2} + `colour_pop` {pop_min 6,
     layer_clear_too true}, with `spawn.colour_count` 3. A landed piece touching two cubes of one colour takes that colour,
     and 6 touching same-colour cubes pop. Layers still clear. The player learns to paint a region and then pop it.
  2. This is the interim form of the **Glow Paint Clash** block (mockup #30, `paint_claim`, Neon's 03 slot). Once the module
     lands, add a scripted painter (the mockup's "Solo vs scripted painter") who re-colours one cell every 6 locks, telegraphed.
  3. Keep the sidewalk as staging only. `fall.g0` 1.05 → 1.10. Tutorial bubble: "Land on two colours to paint. Six alike pop!"

**Progression role** (layer 1): Neon's first new verb in isolation. 06 (pixel sign), H3 (Colour Shift) and the boss's phase 2
all reuse it.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_04: Looking Glass Arcade  (tier 4, funny)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: Every piece the player drops lands with a mirrored twin on the far side of the board's mirror axis. The ghost
  shows both footprints, so the player plans two placements at once. Layers fill twice as fast, and a twin also lands in the
  hole you were saving for an I.
- Teaches / tests: symmetric planning (mirror).
- Rules and minigame blocks: `mirror` {} (code defaults: axis not stated). No module.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.10; ★★ 605 s / ★★★ 425 s. **That is too long:** mirror doubles the fill rate, yet the stars allow 10 minutes.
- Proposed changes: `mirror` {mirror_axis "x", skin "arcade_glass"} made explicit. Add `golden_row` {start_layer 0,
  bonus 200} as a score-only "high-score row", which fits the arcade and is funny when your twin completes it. Retime stars
  for the doubled fill: t2 330000, t3 230000 (half the per-cell estimate, rounded up). `fall.g0` 1.10 → 1.15.

**Progression role** (layer 1): The first twist act level. The mirror returns in the bonus, H3 and the boss.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_05: Cloud Nine Sign  (tier 5, race)

**Play** (layer 1)
- Goal: `height` h_target 9, trim top-out, no coverage set.
- How it plays: Nothing clears. The player stacks up to the sign's bracket, and cubes above H12 pop off. It is a no-lose climb.
- Teaches / tests: the build race as a breather.
- Rules and minigame blocks: `build_race` {}. No module.
- Board: 8x8, H12, random 8-shape bag.
- Difficulty: g0 1.10; ★★ 260 s / ★★★ 185 s. **These are the 5x5 times on an 8x8 board, so the stars cannot be reached.**
  With no `height_coverage`, the reading of "reach height 9" is also unclear (one thin pillar may count).
- Proposed changes: `goal.h_target` 9 → 6, add `goal.height_coverage` 0.6; `stars` t2 385000, t3 270000 (same per-cell rate as
  clockwork_05). Add `race_rival` {rival_rate 0.25, rubber_band 0.5} as a rival sign-painter, so the race type is felt. Later
  module binding: **Rail Rush** (`road_race`, mockup Neon 08 slot) is a better race for the hard track than for a breather;
  keep 05 simple.

**Progression role** (layer 1): The dip after the mirror and before the pixel puzzle and the bubbles.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_06: Pixel Picture  (tier 6, completing)

**Play** (layer 1)
- Goal: `shape`, piece_budget 8. The target is a stepped sign: a 4x4x2 block on layers 0–1 and a 2x2 post on layers 2–3, centred
  (40 cells).
- How it plays: Today the player places a **fixed** list (big cube, big cube, I, I, O, O, O, O) into a glowing outline. The two
  2x2x2 big cubes and two Is make the base, and four Os stack the post. It is a slow think-then-place puzzle.
- Teaches / tests: exact fill with the 8-cell big cube.
- Rules and minigame blocks: `fill_shape` {}; `pieces.fixed_list`. No module.
- Board: 8x8, H6, centred target; **no per-attempt variation**.
- Difficulty: g0 0.90; ★★ 80 s / ★★★ 55 s.
- Proposed changes (**standing-rule violation**: `fixed_list`):
  1. Remove the `fixed_list`. Use a random bag of {big_cube 0.4, o 0.4, i 0.2}, `piece_budget` 8 → 11, and allow overspill
     (cubes outside the outline are legal and wasted). Keep `spawn.preview_count` 3 and `skill.redraw` off.
  2. Make it a **pixel picture**: set `spawn.colour_count` 3 with a coloured target (base cyan, post peach) and reuse 03's
     `chameleon_paint` {min_neighbours 2}. The ★★★ goes to a picture with matching colours, which needs a proposed
     `stars.three_star_requires` "colour_match" flag. That gives the completing level the biome's own verb.
  3. `stars` t2 120000, t3 85000.

**Progression role** (layer 1): The calm puzzle beat in the middle of the biome. It also rehearses painting before the boss uses it.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_07: Neon Shower  (tier 7, funny)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: Some pieces arrive inside glowing bubbles (an Underwater callback) that float and drift instead of falling
  cleanly. The player herds them into place, and a bubble that lands in the wrong slot is funny rather than fatal.
- Teaches / tests: steering floating content; it is the twist act's light-relief level.
- Rules and minigame blocks: `bubble` {} (the rule exposes no params). No module.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.15; ★★ 510 s / ★★★ 365 s.
- Proposed changes: `bubble` has no params, so the rate is code-only. Add `bubble_per_bag` (proposed param, default 2) so the
  level controls how often it happens. Pair it with `fever_rush` {window_ms 8000, clears_needed 2, fever_ms 8000, bonus 100,
  gravity_scale 0.7}, so a quick double clear starts a "neon shower" party in which the drizzle slows. This teaches Fever in
  the main path before H1 and the bonus depend on it. `fall.g0` 1.15 → 1.22.

**Progression role** (layer 1): A funny beat before the combine act. It teaches the Fever loop that the bonus and H1 exploit.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_08: Rush Hour  (tier 8, defender)

**Play** (layer 1)
- Goal: `survive` t_ms 150000, rescue, 1 warning.
- How it plays: The player has to stay alive for 2.5 minutes. The stopwatch freezes and rushes pieces, and every 12 s (±2 s)
  a 2 s-telegraphed power surge (`storm_bolt`) strikes the tower. Clearing layers keeps the stack low enough to ride it out.
- Teaches / tests: holding a stack under two timed pressures (defender).
- Rules and minigame blocks: `stopwatch` {} (code defaults); `storm_bolt` {bolt_interval_ms 12000, bolt_warn_ms 2000,
  bolt_jitter_ms 2000}. No module.
- Board: 8x8, H10, random 8-shape bag; bolt timing is jittered per attempt.
- Difficulty: g0 1.20; stars `s2` 1 / `s3` 2. **The star metric is not named** in the JSON (clears? warnings left?).
- Proposed changes:
  1. Name the metric: `stars.metric` "clears" with s2 3 / s3 5, so surviving well means clearing.
  2. **Bind Cyber Defender** (mockup #31, `fort_siege` `mode: defend`, on Neon's hard-track row): the surges become waves of
     viruses, and each clear fires a shot that knocks one out (counter "Targets 8/15"). Interim: keep `storm_bolt` but rename
     it in staging to "virus hit".
  3. Explicit stopwatch params {stop_every_ms 15000, jitter 3000, warn 1000, stop 2000, catchup 1500, 2000}, kept off the bolt
     beat. `fall.g0` 1.20 → 1.28.

**Progression role** (layer 1): Opens the combine act with the biome's only defender level, and sets up the boss's survive phase.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_09: Power Surge  (tier 9, twist)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: The stage turns a quarter on a lock schedule while gusts push the falling piece sideways from changing
  directions. The player builds flat (turns are free on a flat stack) and hard drops in the gust warning.
- Teaches / tests: two known board and air pressures at once (turntable from Clockwork, gust from Meadow).
- Rules and minigame blocks: `turntable` {} and `gust` {} (both **code defaults**). No module.
- Board: 8x8, H12, random 8-shape bag.
- Difficulty: g0 1.25; ★★ 585 s / ★★★ 410 s; the peak before the boss.
- Proposed changes: make both rules explicit and give the level a Neon reason to exist: `turntable` {turn_locks 5, clockwise
  true, turn_warn_locks 1}; `gust` {wind_mode "rotating", wind_interval_ms 9000, wind_jitter_ms 2000, wind_strength 1,
  wind_warn_ms 1000}. Add `golden_row` {start_layer 1, bonus 200} as the "surge line" that the stage keeps spinning away from
  you. Score only, so it is a choice, not a requirement. `fall.g0` 1.25 → 1.33.

**Progression role** (layer 1): The hardest regular level. The turn and gust telegraphs prepare the player for the boss's phase 3.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_10: The Lonely Billboard  (tier 10, twist; boss)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: Today the belt, the mirror and the gust are all on from the first lock on a 9x9, H14 board. Each piece gets a
  twin, the stack slides, and the wind shoves. Four clears light the billboard. There is no boss presence in play, although the
  mascot role is `boss`.
- Teaches / tests: the final exam, but of two borrowed rules plus the mirror.
- Rules and minigame blocks: `conveyor` {}, `mirror` {}, `gust` {} (all defaults). No module.
- Board: 9x9, H14, random 8-shape bag.
- Difficulty: g0 1.30; ★★ 645 s / ★★★ 455 s (10.75 min to ★★, the longest main level in the biome).
- Proposed changes (**the finale needs phases and a face**):
  1. **Three phases on the billboard**, using the mockup's Neon finale chain ("Paint, Maze, Rail Rush"), with `boss_hp` 3
     where each phase is one hit:
     - Phase 1 "Light the letters": `mirror` + Glow Paint (`chameleon_paint` + `colour_pop`), pop 2 colour groups → 1 hit.
     - Phase 2 "Power down": survive 45 s of `storm_bolt` {10000, 2000, 2000} surges while clearing 1 layer → 1 hit.
     - Phase 3 "Switch on": `turntable` + `gust` (09's pair) and clear 1 layer → the billboard lights.
     Neon Maze and Rail Rush (`route_runner`, `road_race`) replace phases 2–3 once those modules exist.
  2. **Interim without the module framework**: `goal.type` `bonk_boss`, HP 3, one hit per clear. Drop `conveyor` (it is the
     player's fourth conveyor level). Keep `mirror` + `gust` and add `chameleon_paint` {min_neighbours 2}, so all three are
     Neon or Neon-adjacent verbs.
  3. `board` 9x9 → 8x8 (the mirror reads more cleanly on an even board); `fall.g0` 1.30 → 1.42; `stars` t2 480000, t3 340000.
     Retype `level_type` to defender.

**Progression role** (layer 1): The biome payoff. It replays paint (03), mirror (04), surges (08) and the spin (09), and its finale
points the player toward Celestial. Finishing it opens the hard track and the final biome.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_bonus: Glow Party  (tier 11, twist)

**Play** (layer 1)
- Goal: `clear_n` n 2, rescue, 1 warning.
- How it plays: A rooftop rave. Every piece has a mirrored dance partner, so layers fill fast. Two clears within 8 s start
  Rave Fever (10 s, gravity ×0.5, +150 per clear), and the Spotlight Row on layer 0 pays +300 when it clears. It is a party,
  not a test.
- Teaches / tests: chaining clears for Fever; it is the biome's wackiest level.
- Rules and minigame blocks: `mirror` {}; `fever_rush` {window_ms 8000, clears_needed 2, fever_ms 10000, bonus 150,
  gravity_scale 0.5}; `golden_row` {start_layer 0, bonus 300}.
- Board: 9x9, H10, random 8-shape bag.
- Difficulty: g0 1.10; ★★ 345 s / ★★★ 240 s; an off-curve reward.
- Proposed changes: with `n` 2, the player can reach Fever at most once (it needs two clears), which wastes the party.
  Set `goal.n` 2 → 4 and `stars` t2 360000, t3 250000 (mirror halves the effective work). Optional module binding: **Laser
  Sprint** (mockup Neon bonus) when a laser-sweep atom (A8) exists.

**Progression role** (layer 1): An optional reward between the boss and the hard track. It shows off the Fever and Spotlight loops
that H1 and H2 test.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_h1: Fever Hour  (tier 12, race)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: The traffic-light stopwatch freezes the piece (every 14 s ±3 s, 2 s), then rushes it at ×1.6. Three clears
  inside 6 s start Fever (8 s, gravity ×0.6, +100 per clear). The player stacks near-full layers and uses each freeze to aim
  the hard drop that starts the chain.
- Teaches / tests: combo timing against a timing twist.
- Rules and minigame blocks: `stopwatch` {14000, 3000, 1000, 2000, 1600, 2500}; `fever_rush` {6000, 3, 8000, 100, 0.6}.
- Board: 8x8, H10, random 8-shape bag.
- Difficulty: g0 1.30; ★★ 545 s / ★★★ 375 s.
- Proposed changes: it is typed **race** but has no rival. Add `race_rival` {rival_rate 0.3, rubber_band 0.4,
  rival_warn_pct 80}, or retype it to twist. I recommend the rival, because Fever is the way to beat it. `fall.g0` 1.30 → 1.42
  (at or above the boss). Open question carried from neon.md: the stopwatch catch-up and Fever both scale gravity; confirm they
  multiply.

**Progression role** (layer 1): The first hard remix. It turns the bonus's Fever party into a race.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_h2: Spotlight Surge  (tier 13, twist)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: The stage turns a quarter every 5 locks and the wind rotates direction every 10 s (±2.5 s). A spotlight picks
  out layer 1 and pays +200 when that layer clears, then climbs. The best layer to clear is the lit one, not the lowest.
- Teaches / tests: choosing which layer to complete under two board pressures.
- Rules and minigame blocks: `turntable` {turn_locks 5, clockwise, warn 1}; `gust` {rotating, 10000, 2500, strength 1, warn
  1000}; `golden_row` {start_layer 1, bonus 200}.
- Board: 8x8, H12, random 8-shape bag.
- Difficulty: g0 1.30; ★★ 550 s / ★★★ 375 s.
- Proposed changes: `fall.g0` 1.30 → 1.42. If 09 adopts the surge-line `golden_row` (above), H2 becomes its hard version; that
  is consistent.

**Progression role** (layer 1): The middle remix. It harder-tunes 09's pair with a scoring decision.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_

---

### neon_h3: Colour Shift  (tier 14, twist)

**Play** (layer 1)
- Goal: `clear_n` n 4, rescue, 1 warning.
- How it plays: Three colours. Every piece lands with a mirrored twin; a piece touching two cubes of one colour turns that
  colour, and a layer that ends up all one colour clears an extra layer with it. The player paints from the edges inwards and
  takes plain clears when a mono layer is out of reach.
- Teaches / tests: the colour exam: paint, mirror and mono together.
- Rules and minigame blocks: `mono_layer` {mono_extra_layers 1}; `mirror` {}; `chameleon_paint` {min_neighbours 2};
  `spawn.colour_count` 3.
- Board: 8x8, H10, random 8-shape bag; colours random per piece.
- Difficulty: g0 1.30; ★★ 550 s / ★★★ 375 s; the hardest Neon level.
- Proposed changes: `mirror` {mirror_axis "z"} made explicit (a different axis from 04's "x" gives a fresh read). `fall.g0` 1.30
  → 1.40. If 03 adopts Glow Paint, this level becomes the natural graduation of the biome's own verb.

**Progression role** (layer 1): The biome's final exam on the hard track, bringing together everything colour-based.

**In the world** (layer 2):
_(layer 2: pending)_

**Story beat** (layer 2):
_(layer 2: pending)_

**Art** (layer 3):
_(layer 3: pending)_

**Godot review** (layer 4):
_(layer 4: pending)_
