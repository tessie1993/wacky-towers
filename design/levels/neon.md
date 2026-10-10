# Neon: Glowtown

Status: Proposed implementation design (2026-10-10). No Neon level design existed in the source repository. These ten levels are new proposals awaiting author review and playtest. They connect Clockwork to Celestial through Mizzle’s lonely billboard. All story plays wordlessly.

| Level | Name | Board | Goal | Rule | 2★ / 3★ |
|---|---|---|---|---|---|
| 01 | Welcome to Glowtown | 4×4, H8 | clear_n 3 | classic | 145 / 105 s |
| 02 | Traffic Lights | 5×5, H10 | clear_n 4 | stopwatch | 260 / 185 s |
| 03 | Moving Sidewalk | 8×4, H10 | clear_n 4 | conveyor | 310 / 220 s |
| 04 | Looking Glass Arcade | 6×6, H10 | clear_n 4 | mirror | 340 / 240 s |
| 05 | Cloud Nine Sign | 5×5, H12 | height 9 | build_race | 260 / 185 s |
| 06 | Pixel Picture | 4×4, H6 | shape 40 cells | fill_shape | 80000 / 55000 s |
| 07 | Neon Shower | 6×6, H10 | clear_n 5 | bubble | 360 / 255 s |
| 08 | Rush Hour | 5×5, H10 | survive 150 | stopwatch | 240 / 170 s |
| 09 | Power Surge | 6×6, H12 | clear_n 5 | turntable, gust | 410 / 290 s |
| 10 | The Lonely Billboard | 7×7, H14 | clear_n 4 | conveyor, mirror, gust | 390 / 275 s |

Each level keeps one legible new idea, then remixes familiar ones. Level 05 offers a trim tower breather; 06 is an eight-piece stepped neon-sign puzzle; 08 is a timed sprint. Level 10 lights an empty second chair beside Mizzle’s billboard and points toward the final island. Art is a bright toy city with violet dusk, painted signposts and cyan/peach accents; no flashing effects. Track ids mus_neon_01–10 are user-supplied placeholders. Stars are initial estimates, not tuned medians. Local physics use existing deterministic grid rules.

**Hard-track star rule (bonus and remixes):** `t2 = round5(0.80 × t_est)`, `t3 = round5(0.55 × t_est)`, `t_est = N × A × 2.667 s` (A = cells per layer). Tier 10 (`neon_10`) is 390 / 275 s for Clear 4 on 7×7; these are tighter per unit of work. Bonus and remixes count toward no star gate. Mascot: watcher on all four.

## Bonus level (tier 11)

| id | Name | Rules | Goal | Board | g0 | ★★ / ★★★ |
|---|---|---|---|---|---|---|
| neon_bonus | Glow Party | `mirror` + `fever_rush` + `golden_row` | Clear 5 | 5×5, H10 | 1.10 | 265 / 185 s |

### B Glow Party (bonus, tier 11, 20 neon stars)

**Story card.** Glowtown throws a rooftop rave. Every piece you drop gets a mirrored dance partner, two quick clears start **Rave Fever** (the drizzle slows, every clear pays double), and the **Spotlight Row** sweeps up the stack paying a gold bonus each time you clear it. The biome's wackiest level: a party, not a test. · **Mascot: watcher** (dances; a party hat on Fever).
**Ideas**: Looking Glass (`mirror`, from 04) is the known rule; it doubles the fill rate so clears come fast and Fever is easy to reach.
**Wave-3**: `fever_rush` as **Rave Fever** (`window_ms` 8000, `clears_needed` 2, `fever_ms` 10000, `bonus` 150, `gravity_scale` 0.5: generous on purpose) and `golden_row` as the **Spotlight Row** (`start_layer` 0 so the first clear can hit it, `bonus` 300). Bonus allowance: 3 rules (2 twists + 1 level rule).
**Goal**: Clear 5 on 5×5, H10, 8 Std, `g0` 1.10 (gentler than 10: it is a party).
**Wacky test**: surprising, every piece brings a twin; silly, the whole skyline flashes to the beat (slow colour pulses, no strobing) and the board becomes a disco floor during Fever; funny failure, a mirrored twin lands in the hole you were saving and the mascot does an embarrassed shuffle; big moment, a Fever clear on the Spotlight Row: score shower, the spotlight jumps up a layer, confetti-coloured glow (staging only).
**Counterplay**: chain clears inside the 8 s window to hold Fever; aim the clear at the spotlight layer for the 300 bonus; the twin's footprint is shown on the ghost, so leave room for both.
**Star rationale**: t_est = 5 × 25 × 2.667 = 333 s → 265 / 185 s. Mirror and Fever both speed play, so the 3★ is reachable for Fever chains without being free.

## Hard-track remixes (tiers 12–14)

Each remix recombines 1–2 rules Neon taught **plus exactly one wave-3 mechanic** (`design/gdd/mechanics-wave3.md`). Twist cap: at most 2 twists + 1 level rule. Runtime files: `src/levels/neon/neon_h1..h3/`.

| # | id | Name | Recombines | Wave-3 (biome event) | Goal | Board | g0 | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|
| H1 | neon_h1 | Fever Hour | Traffic Lights stopwatch (02, 08) | `fever_rush` (**Rave Fever**) | Clear 6 | 5×5, H10 | 1.30 | 320 / 220 s |
| H2 | neon_h2 | Spotlight Surge | Power Surge: turntable + gust (09) | `golden_row` (**Spotlight Row**) | Clear 5 | 6×6, H12 | 1.30 | 385 / 265 s |
| H3 | neon_h3 | Colour Shift | Looking Glass mirror (04) + mono-layer bonus (Candy 03 callback) | `chameleon_paint` (**Colour Shift**) | Clear 5 | 6×6, H10, 3 colours | 1.30 | 385 / 265 s |

### H1 Fever Hour

**Story card.** Rush hour on the traffic-light square: the lights freeze your piece, then wave it through fast. Clear three times in quick succession and the square catches **Rave Fever**: the traffic slows and every clear pays double. · **Mascot: watcher**.
**Idea recombined**: `stopwatch` (every 14 s ± 3 s, warn 1 s, freeze 2 s, catch-up ×1.6 for 2.5 s).
**Wave-3**: `fever_rush` as **Rave Fever** at the GDD defaults (`window_ms` 6000, `clears_needed` 3, `fever_ms` 8000, `bonus` 100, `gravity_scale` 0.6).
**Goal**: Clear 6 on 5×5, H10, 8 Std, `g0` 1.30.
**Wacky test**: surprising, slowing down is the reward for going fast; silly, the traffic lights dance to the Fever beat; funny failure, a freeze in the middle of a combo lets the 6 s window run out and the meter drains with a sad trombone; big moment, a freeze-aimed hard drop that is the third quick clear and kicks off Fever.
**Counterplay**: set up stacked near-full layers so clears chain within 6 s; use the freeze to aim (move and rotate still work), drop before the catch-up; Fever's slow gravity softens the next catch-up.
**Star rationale**: t_est = 6 × 25 × 2.667 = 400 s → 320 / 220 s.

### H2 Spotlight Surge

**Story card.** The power-surge plaza again: the stage turns and the wind blows from a new side each gust. Now a **spotlight** picks out one layer; clear that layer and the crowd cheers, then the spotlight climbs. · **Mascot: watcher**.
**Ideas recombined**: `turntable` (every 5 locks, clockwise, wind-up 1) + `gust` (rotating, 10 000 ± 2500 ms, strength 1, warn 1000; slower than 09 to leave room for the spotlight).
**Wave-3**: `golden_row` as the **Spotlight Row** (`start_layer` 1, `bonus` 200). Score only; it is the route to a high score, not to the goal.
**Goal**: Clear 5 on 6×6, H12, 8 Std, `g0` 1.30.
**Wacky test**: surprising, the best layer to clear is the one in the light, not the lowest; silly, the spotlight operator (backdrop) scrambles to follow each turn; funny failure, you clear the layer just under the spotlight and the crowd groans; big moment, a two-layer clear including the spotlight, the beam leaping up as the stage turns.
**Counterplay**: build the spotlight layer first (the turn keeps layer counts, so a turned spotlight layer is still as full); drop gusts by hard-dropping in the warning.
**Star rationale**: t_est = 5 × 36 × 2.667 = 480 s → 385 / 265 s.

### H3 Colour Shift

**Story card.** In the Looking Glass Arcade every piece gets a mirrored twin, and the arcade paint is wet: a piece that lands against two or more cubes of one colour turns that colour. A layer that ends up all one colour clears an extra layer with it. · **Mascot: watcher** (changes colour with the last piece).
**Ideas recombined**: `mirror` (04) + `mono_layer` (`mono_extra_layers` 1; callback from `candy_03`, so this is not a new idea for the player), `spawn.colour_count` 3.
**Wave-3**: `chameleon_paint` as the **Colour Shift** (`min_neighbours` 2). Under layer clears alone a recolour would be cosmetic; the mono-layer bonus is what makes the colour shift a decision.
**Goal**: Clear 5 on 6×6, H10, 8 Std, `g0` 1.30. Twist count: 2 twists (mirror, chameleon_paint) + 1 mechanic (mono_layer).
**Wacky test**: surprising, your piece changes colour after it lands; silly, the twin and the original can land against different colours and end up mismatched; funny failure, a nearly mono layer gets one piece that touches only one red cube and stays blue; big moment, a twin pair both shifting to the same colour and completing a mono layer that pops two layers at once.
**Counterplay**: place pieces against two cubes of the colour you want; build mono layers from the edges in; ignore colour when a normal clear is safer (mono is a bonus, never required).
**Star rationale**: t_est = 5 × 36 × 2.667 = 480 s → 385 / 265 s. Mono bonuses can shave time; stars are not tuned around them.

**Music/audio**: tracks `neon_bonus_tbd`, `neon_h1_tbd`…`neon_h3_tbd` are user-supplied placeholders (play `mus_neon_06`, `mus_neon_08`, `mus_neon_09`, `mus_neon_04` until supplied). One-shots: a rising synth arpeggio on the Fever meter and a drop on `fever_start`; a crowd cheer on `gold_cleared`; a wet "splotch" on each `chameleon`. No flashing effects (Neon art rule); Fever is a slow colour pulse.
**Open questions**: `golden_row` and `fever_rush` pay score only; there is no counter-based goal type yet, so the `goal_counter` param is left at default and unused by goals. `neon_h1`: stopwatch catch-up and Fever both write `fall.gravity_scale` under separate owners; confirm they multiply (1.6 × 0.6 ≈ 0.96 during overlap is intended).
