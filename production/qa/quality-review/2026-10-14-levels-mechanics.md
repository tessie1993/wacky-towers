# Quality review: levels and mechanics, 2026-10-14

**Reviewer**: game-designer acting as strict level-design and mechanics critic
**Bar**: `.claude/docs/reference-quality-bar.md`. An item passes at 8/10 or above.
**Verdict**: **FAIL**. Overall score is **4.8 / 10**. No biome passes, and neither do the core mechanics.

## 0. Scope, inputs and limits

| Input | Status | Notes |
|---|---|---|
| `assets/data/campaign/catalog.json` | FOUND | 168 levels in **12** biomes: meadow, candy, ice, underwater, pirate, lava, forest, cave, clockwork, neon, celestial, carnival (Tumble Fair). The brief said 13. The 13th, the Wizard's Practice Island tutorial from `mockup-alignment.md` 2.1, **does not exist** and is scored as a defect (D3) |
| `src/levels/**/<id>.json` (live fields) | FOUND | Read by field across all 168 levels: `fall.g0`, goal type and n, `stars`, rule ids, `level_type`, `fixed_list`/`kit`, `variation`, knob overrides |
| `assets/data/rules/*.json`, `assets/data/knobs/{fall,controls,clearing}.json` | FOUND | Rule list and core knob defaults |
| `design/levels/mockup-alignment.md` | FOUND | The target for minigame modules, bosses and the tutorial island |
| `src/core/sim/spawner.gd`, `src/core/board/level_variation.gd`, `src/core/sim/sim_events.gd`, `src/core/sim/score_keeper.gd`, `src/view/wt_stage.gd`, `src/view/fx/wt_audio.gd`, `src/app/main.gd` (seed) | FOUND | Fairness, variety and feel hooks |
| `production/qa/bot-playtest-2026-10-13.md`, `campaign-difficulty-review-2026-10-10.md` | FOUND | Completability signals and timing audit |
| `production/qa/evidence/playtest-2026-10-14/*.png`, `full-build/ui/hud_720.png`, `full-build/ice10-sequences.json` | FOUND | Readability at 720x1280 and per-seed sequences |
| Human playtest data (first-attempt rate, median times, star distribution) | **ABSENT** | Felt difficulty and felt lock delay are **NOT ASSESSED — NO PLAYER DATA**. Every level's metadata says "Initial estimates; no playtest medians" |
| Skills `godot-genre-puzzle`, `gamedev-level-design`, `gamedev-game-feel`, `studio-level-design-lead` | READ AS FILES | No Skill tool was available. I read their SKILL.md files and applied them: teach, then reinforce, then combine; sawtooth pacing; layered feedback; no hard-coded sequences |
| gdUnit suite | NOT RUN | Excluded by the brief |

## 1. Scoreboard

Columns: T = teaching and twist cadence; V = rule variety and duplicates; C = difficulty curve (g0, n, stars); H = hard track; B = boss and set-piece; M = minigame modules inside levels; F = fairness and spawn safety; Fe = feel; R = readability at 720x1280; P = per-attempt variety. Scores are 1 to 10.

| Biome | T | V | C | H | B | M | F | Fe | R | P | **Score** | Result |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Meadow | 5 | 6 | 4 | 4 | 4 | 2 | 6 | 4 | 5 | 6 | **5.0** | FAIL |
| Candy | 5 | 7 | 5 | 6 | 7 | 3 | 6 | 4 | 5 | 6 | **5.6** | FAIL |
| Ice | 6 | 5 | 5 | 4 | 3 | 2 | 3 | 4 | 5 | 6 | **4.6** | FAIL |
| Underwater | 5 | 4 | 5 | 4 | 3 | 2 | 6 | 4 | 5 | 5 | **4.4** | FAIL |
| Pirate | 3 | 2 | 5 | 3 | 2 | 2 | 6 | 4 | 5 | 5 | **3.5** | FAIL |
| Lava | 5 | 5 | 5 | 2 | 4 | 2 | 4 | 4 | 5 | 4 | **4.1** | FAIL |
| Forest | 4 | 5 | 5 | 5 | 3 | 2 | 6 | 4 | 5 | 5 | **4.4** | FAIL |
| Cave | 5 | 4 | 5 | 5 | 4 | 2 | 6 | 4 | 4 | 5 | **4.4** | FAIL |
| Clockwork | 6 | 6 | 5 | 5 | 5 | 3 | 6 | 4 | 5 | 5 | **5.0** | FAIL |
| Neon | 4 | 3 | 4 | 4 | 3 | 2 | 6 | 4 | 5 | 5 | **4.0** | FAIL |
| Celestial | 4 | 5 | 5 | 4 | 4 | 2 | 6 | 4 | 5 | 5 | **4.4** | FAIL |
| Carnival (Tumble Fair) | 5 | 5 | 5 | 5 | 3 | 2 | 6 | 4 | 5 | 5 | **4.5** | FAIL |
| **Core mechanics** (see 1.1) | | | | | | | | | | | **5.0** | FAIL |

**Overall** is the mean of the 12 biomes and core mechanics: **4.8 / 10**.

### 1.1 Core mechanics against AAA puzzle standards

| Area | Score | Evidence |
|---|---|---|
| Randomizer and fairness | 7 | The 7-bag-style shuffle is seeded through `Seeds` (`spawner.gd`). `opening_set` lets a level give friendly first pieces. `main.gd:371` draws a fresh seed for every attempt and logs it, and the `ice10-sequences.json` seeds all differ. **But** `opening_set` is used by almost no level after meadow_01, and the sim has **no spawn-safety check**: ice_10 loses with 2 or fewer locks (bot `INSTANT_LOSS`) |
| Lock delay, gravity, grace | 6 | The defaults are sound: lock delay 500 ms, 10 resets, entry delay 200 ms, hard-drop grace 150 ms. g0 is flat inside a biome and gravity effectively **resets every biome** (meadow_10 1.0 to candy_01 0.65). `fall.ramp_per_clear` 0.05 is the only ramp inside a level. The felt timing is NOT ASSESSED (no player data) |
| Event vocabulary for juice | 3 | `SimEvents` has no `COMBO`, `NEAR_MISS`, `PERFECT_CLEAR`, `DANGER_ENTER/EXIT` or `LOCK_RESET`. `ScoreKeeper` tracks a combo but never emits it |
| Feedback layering | 3 | In `wt_stage.gd`, the lock burst fires at the fixed world origin `(0,0.7,0)`, not at the piece. The clear burst is a fixed 45 particles at `(0,1.2,0)` whether 1 or 4 layers clear. There is no shake, no hit-stop, no pitch rise on combos and no layer flash. Mechanic `*_warning` events are **silent** unless listed in the wave-3 `BOARD_SFX` map. `WtAudio.cue()` calls `load()` on every play |
| Danger readability | 4 | Danger is one binary flag at `stack_height >= h_play - 2` with a pulsing plane. It has no graded tension and no music layer |
| Sim performance | 2 | Fog levels run at 600 ticks in 45 to 132 s headless, which is 5 to 12x **slower than real time** (meadow_07, ice_07, underwater_07, lava_07, cave_08/09, forest_h1, celestial_07, carnival_08). Ordinary levels manage only about 210 ticks/s. This blocks phone play and bot QA |
| Undo, reset, soft-lock detection | 6 | `CMD_UNDO` and `CMD_RESET` and the `undo_reset` rule exist, but only some puzzle levels enable them. The finite puzzles (bonus levels and tier 6) fail with `out_of_pieces` at lock 3 to 9 and never warn that the puzzle has become unsolvable |
| Per-attempt layout variety | 4 | `LevelVariation` (symmetry plus jitter, re-validated) is excellent engineering, but only **17 of 168** levels opt in |

## 2. Cross-campaign findings (the systemic problems)

1. **Cookie-cutter slot template.** Tier 05 is `build_race` plus a height goal in **11 of 12 biomes**. Tier 06 is a `fill_shape` picture puzzle, mostly with a `fixed_list` or `kit`, in every biome. Tier 08 is `survive` with `ramp_per_min` in 6 biomes. Tier 10 is `conveyor` + `gust` + one local rule with `clear_n 3` in forest, underwater and neon, and the same pattern in cave. A player learns the template by biome 3.
2. **Goal n does not scale with the campaign.** n stays at 2 to 5 from meadow to carnival. neon_01 has n=1 in biome 10, and clockwork_02 and lava_h3 have n=1. Finales usually ask **fewer** clears (3) than their tier 07 and 09 levels (4).
3. **Stars are formulaic, not tuned.** The time stars follow n exactly: n=2 is 290000/205000, n=3 is 435000/310000 and n=4 is 580000/410000, more than 25 times each, whatever the tier, rules or g0. A finale with three stacked hazards gets the same 3-star time as a tier 03 level. The bot cleared candy_09 in 26 s, 6% of t3, and neon_h3 at 13% of t3.
4. **The hard track is often softer than the finale.** Its g0 is **below** tier 10 in meadow_h1 (0.95 vs 1.0), all three ice h-levels (1.05 vs 1.1), underwater_h1 and h2 (1.05 vs 1.15), forest_h1 and h2 (1.25 vs 1.3), all three cave h-levels (1.3 vs 1.35), all three clockwork h-levels (1.3 vs 1.4), celestial_h1 and h2 (1.45 vs 1.5), and lava_h3 (0.8 vs 1.25). Live and `design_spec` values also drift: celestial_08, carnival_08, carnival_h3, ice_h2, meadow_h3, cave_h3.
5. **The mockup modules are absent from levels.** Not one level uses the module framework. `bridge_dash`, `fort_siege`, `boss_hp`, `summit_climb`, `dig_down` and `route_runner` from `mockup-alignment.md` are missing. "Kraken Blockade" (pirate_10) and "Fort Blast" (pirate_09) are only names: gust plus crab_claw with clear_n, and race_rival with clear_n.
6. **Bosses have no face.** Only candy_10 (`bake_oven` plus `climber_boss`), candy_h3 (`bonk_boss`) and the clockwork `wind_keys` levels have a goal unlike a normal level. The other 9 finales are `clear_n` with stacked rules and no boss HP, no phases and no arena change.
7. **Hard-coded sequences.** The brief says no hard-coded sequences. `fixed_list` appears in forest_06, cave_07, celestial_06, clockwork_06, neon_06, carnival_06 and **lava_h3**, and `kit` in underwater_06, besides the bonus levels. neon_01 to neon_10 carry an empty `"fixed_list": []` stub.
8. **The first-hour difficulty is a wall.** meadow_01 needs 2 full 8x8 layers, 128 cells or about 32 tetracubes, as the player's first level. The bot never finished meadow_01, 02 and 04, candy_01, lava_01, forest_01 to 04, cave_01 and 02, or clockwork_01. The bot is weak, but every one of these is an opener.
9. **Readability at 720x1280** (`meadow_02_mid.png`, `pcam_after_celestial_720x1280.png`, `hud_720.png`):
   - The active piece uses the same blue material as the locked stack.
   - The landing marker is a pale tan square that blends into the stone path.
   - The NEXT caption ("O, T, Tripod") is about 10 px, and the timer "0:36" is about 10 px and clipped by the frame.
   - There is no per-layer fill readout (how close each layer is to clearing).
   - Up to 13 buttons crowd the bottom third.
   - The retained `hud_720.png` evidence shows a **blank grey board**, so the gameplay HUD evidence is invalid.

## 3. Per-biome notes (worst issues only)

- **Meadow (5.0).** The intro is controls-first and gentle (balloon, wobble, gust), which is good. But the opener is the 128-cell wall, fog in meadow_07 is the performance hog, and meadow_10 "Meadow Mill" is a three-rule stack with no mascot set piece. The Bridge Bashers, Shepherd's Pen and Hay Bale Sprint modules are missing.
- **Candy (5.6, the best).** It has real goal variety: height, shape, survive, bake_oven, rescue_all, bonk_boss. But candy_09 introduces goo, licorice and flip together, and the bot won it at 6% of t3. `mascot_mood` sits on 11 of 14 levels and `colour_pop` on 7. Sugar Siege is missing.
- **Ice (4.6).** ice_10 suffers an instant top-out within 2 locks. ice_01's rule stack (mascot_hint, stopwatch, angle_gem, race_rival) is **identical** to celestial_02's. ice_02 to ice_04 carry the unsupported field `recipe`. Avalanche Ascent and Glacier Gauntlet are missing.
- **Underwater (4.4).** crab_claw appears in 02, 10 and h3. underwater_10 "Crab's Pile" is the stock conveyor + gust + X finale. The Crab King boss and Submarine Salvage are missing.
- **Pirate (3.5, the worst).**
  - It has no native mechanic: crab_claw is borrowed from underwater, gumdrop_hail from candy, squirrel_heist from forest and rising_silt from underwater.
  - **pirate_06 has `"rules": []`**, a plain standard level, which breaks the user's "no standard rules" decision.
  - pirate_10 "Kraken Blockade" is gust + crab_claw with clear_n 4, which is a **duplicate of pirate_h1 "Kraken Blockade II"**.
  - The pirate files have no `metadata.design_spec`.
- **Lava (4.1).** lava_h3 is a hard-track level with g0 0.8, n=1 and a `fixed_list`, and all 3 bot runs died at lock 7. lava_01, 02, 03, 05, 06 and bonus carry unsupported fields (`recipe`, `layout`). There is no Molten Guardian boss.
- **Forest (4.4).** forest_08 introduces vines and woodpecker together. forest_10 is conveyor + gust + mushroom_popup. forest_06 has a fixed list and an unsupported `solution` field. Rolling Rumble and Jungle Dash are missing.
- **Cave (4.4).** Fog appears in 08, 09, 10 and h3, so the darkness gimmick repeats 4 times and is also the slow-sim case. cave_07 has a fixed list with a 3-piece budget. `secrets` is unsupported in cave_01 and 02. The Digging Frenzy and Maze Heist set pieces are missing.
- **Clockwork (5.0).** The `wind_keys` goal is a real twist (clockwork_08 and h3). But clockwork_02 has n=1 and clockwork_06 has a fixed list. Conveyor Sort and Bomb Defuse are missing.
- **Neon (4.0).** It is mostly borrowed: mirror appears in 04, 10, h3 and bonus, plus balloon, conveyor and bubble. neon_01 has n=1 in biome 10. The bot won neon_h3 at 13% of t3. neon_06 has a fixed list. Glow Paint Clash and Cyber Defender are missing.
- **Celestial (4.4).** celestial_10 introduces event_card and lava_lid together in the finale. celestial_02 duplicates ice_01. Chroma Sky Climb and Cosmic Climb are missing.
- **Carnival (4.5).** storm_bolt appears in 09, 10 and h1. carnival_06 has a fixed list. g0 reaches 1.55, but goals still sit at n=3 to 4. There is no Baron Balloon set piece.

## 4. Ranked defects and concrete fixes

| # | Severity | Where | Defect | Fix (field, new value, or system change) |
|---|---|---|---|---|
| D1 | Critical | fog rule (`src/mechanics/behaviour/fog*.gd`) | The sim runs 5 to 12x slower than real time on 9 levels | Make fog recompute only on `PIECE_LOCKED` or `CELLS_CHANGED`, not every tick. Cache per-column alphas and emit `fog_visibility` only when a value changes. Gate: 600 ticks in under 1 s headless |
| D2 | Critical | ice_10 plus `BoardSim` spawn | Instant top-out within 2 locks | Add a spawn-safety pass in `BoardSim`: if the spawn footprint at `spawn_anchor` overlaps on the first frame, apply a rescue wipe or upward kick. Then fix ice_10's `board.spawn_anchor` and `h_play` so the first 3 bag pieces can land. Gate: 0 `INSTANT_LOSS` over 20 seeds |
| D3 | Critical | campaign | The tutorial island and the mockup modules (bridge_dash, fort_siege, boss_hp, summit_climb, dig_down, route_runner) are not in any level | Build the module framework (`mockup-alignment.md` section 5, steps 1 to 3). Then re-slot 03, 05, 08 and 10 in each biome per the table in 2.2. Add `tutorial_01` to `tutorial_03` before meadow_01 |
| D4 | Critical | 9 finales | The finale is `clear_n` plus rules, with no boss | Add `boss_hp` (A6) with 2 to 3 telegraphed phases. Assign meadow_10 Mill Giant, underwater_10 Crab King, pirate_10 Kraken, lava_10 Molten Guardian, forest_10 Boss Bash, cave_10 Crystal Golem, clockwork_10 Gear Titan, neon_10, celestial_10 Cosmic Gateway, carnival_10 Baron Balloon |
| D5 | High | pirate_06 | `"rules": []`, a plain standard level | Set `rules` to `[{"id":"tilt_plate"}]` or a deck-plank rule. Better, make it Plank Bridge `bridge_dash` |
| D6 | High | pirate_10 vs pirate_h1 | The two levels are duplicates | Make pirate_10 Kraken Blockade `boss_hp` with tentacle lanes (`defend_core` params). Change pirate_h1 to Shatter Shootout (`fort_siege` with `target: shared_tower`) |
| D7 | High | ice_01 vs celestial_02 | Identical rule stack | Change celestial_02 `rules` to `stopwatch` + `balloon` + `gust` (zero-G drift) and drop `race_rival` |
| D8 | High | the hard track, all biomes | The hard track has g0 below the finale | Set every `hN` `knobs.fall.g0` to at least the tier 10 value + 0.10: meadow_h1 1.10, h2 1.10, h3 1.15; ice_h1 to h3 1.20; underwater_h1 1.25, h2 1.25, h3 1.30; forest_h1 1.40, h2 1.40, h3 1.45; cave_h1 to h3 1.45; clockwork_h1 to h3 1.50; celestial_h1 1.60, h2 1.60, h3 1.65; lava_h1 1.35, h2 1.40; neon_h1 to h3 1.40; carnival_h1 to h3 1.65. Copy the live value into `metadata.design_spec` to end the drift |
| D9 | High | lava_h3 | `fixed_list`, g0 0.8, n=1 and the same instant loss on every run | Remove `pieces.fixed_list`. Set `pieces.shapes` to the lava bag, `goal.n` 4, g0 1.35, and add `variation: {"symmetries":["mirror_x","rot180"]}` |
| D10 | High | forest_06, cave_07, celestial_06, clockwork_06, neon_06, carnival_06, underwater_06 | Hard-coded sequences in the main chain | Replace `fixed_list`/`kit` with a seeded `opening_set` plus a bag, and keep the `shape` goal. Add `undo_reset`. Add `variation` with symmetry only (shape goals cannot jitter). Remove the empty `"fixed_list": []` stubs from neon_01 to neon_10 |
| D11 | High | meadow_01, candy_01, forest_01, cave_01, clockwork_01, lava_01 | The opener is a wall | Give each opener `board.starting_contents` with 2 pre-filled layers of 56 of 64 cells, gaps open to the sky, so the first clear needs 2 to 3 pieces. Keep `goal.n` 2. Use `opening_set` `["o","i","l"]` with `opening_count` 3 |
| D12 | High | all `stars` | Formulaic time stars | Generate `t2` and `t3` from a formula: `t3 = n * cells_per_layer / 4 * sec_per_piece(g0, rules) * 0.8` and `t2 = t3 * 1.4`. Calibrate with bot plus human medians. Flag any level the bot clears under 25% of t3 (candy_09, neon_h3) and cut its t3 to 50% |
| D13 | High | all biomes | Goal n is flat | Ramp `goal.n` by biome index b (0 to 11): tier 03 = 2 + floor(b/4), tier 07 and 09 = 4 + floor(b/4), tier 10 = boss. Fix neon_01 to n 3 and clockwork_02 to n 2 |
| D14 | High | `SimEvents`, `ScoreKeeper`, `BoardSim` | No juice hooks | Add `COMBO_CHANGED {combo}`, `NEAR_MISS {height_before, rows_cleared}` (a clear while the stack is at or above `h_play - 2`), `PERFECT_CLEAR`, `DANGER_CHANGED {level 0..3}` and `LOCK_RESET`. Emit `LAYERS_CLEARED` with `{layers:[y...], count}` |
| D15 | High | `wt_stage.gd` | Feedback is flat | Place the lock burst at the piece's cells. Place the clear burst at each cleared layer's y. Scale bursts by tier (1, 2, 3, 4+ layers) with 6, 20, 45 and 90 particles. Add trauma shake of 0.15, 0.3, 0.5 and 0.8, and hit-stop of 0, 40, 60 and 90 ms, with real-time restore. Add a layer white-flash of 60 ms and a rising combo pitch (+1 semitone per combo step). Honour reduced motion |
| D16 | High | `wt_audio.gd` | Warnings are silent and assets are loaded per cue | Preload the cue table at `setup()`. Give every `*_warning` event a cue: either a generic `warn_tick` or a per-mechanic entry in `BOARD_SFX`. Add ±3% pitch randomisation |
| D17 | Medium | candy_09, forest_08, celestial_10 | Several new mechanics are introduced at once | Split the introductions. candy_09 keeps `goo_spread` + `licorice_lock`, and `flip` moves to candy_h-track. forest_08 keeps `vines` only, and `woodpecker_knock` moves to forest_09. celestial_10 keeps `event_card`, and `lava_lid` is introduced in celestial_08 first |
| D18 | Medium | 11 tier-05 levels | `build_race` repeats in the same slot | Keep `build_race` in 4 biomes. Replace it with `summit_climb` (ice, lava), `bridge_dash` (meadow, forest), `dig_down` (cave, underwater) and `balance_plate` (pirate, celestial) |
| D19 | Medium | fog overuse | Fog appears 17 times in total, including cave 4 times and lava 2 times | Allow at most 1 fog level per biome. Replace cave_09 fog with `key_stamp`, cave_h3 fog with a `dig_rescue` lantern radius, and lava_10 fog with the boss |
| D20 | Medium | 151 of 168 levels | No per-attempt layout variation | Add `"variation": {"symmetries":["mirror_x","mirror_z","rot180"],"jitter":{"glyphs":"<obstacle glyphs>","radius":1}}` to every non-puzzle level with a square board. Run `LevelVariation.check_variants` in CI |
| D21 | Medium | unsupported fields | `recipe` (ice_02 to 04, lava_01 to 03, 05, 06, bonus, forest_02, cave_02), `layout` (lava_03), `solution` (forest_06, cave_07, cave_bonus), `secrets` (cave_01, 02) | Implement each field or remove it. A level with silently ignored design data has not been reviewed |
| D22 | Medium | the view | Readability at 720x1280 | Tint the active piece (outline plus a 15% brighter emissive) apart from the stack. Make the landing marker a full-cell coloured ghost at 35% alpha plus a drop-column beam. Add a side layer meter showing per-layer fill percentage that pulses when one cell is left. Use at least a 20 px NEXT caption, or drop it for the 3D icon. Use at least a 22 px timer, unclipped |
| D23 | Medium | evidence | `hud_720.png` shows a blank board | Re-capture with a live level and retain it |
| D24 | Low | `ScoreKeeper` | The combo is score-only | Display the combo count and fever above 2. Drive the music intensity layer from `DANGER_CHANGED` |

## 5. Top 15 instructions to the team (owner-tagged)

1. **[mechanics]** Fix the fog sim cost (D1). The gate is 600 ticks in under 1 s headless. Re-run the bot playtest on all 9 fog levels.
2. **[mechanics]** Add the spawn-safety and rescue pass in `BoardSim`, and fix ice_10's anchor and height (D2). The gate is 0 instant losses over 20 seeds.
3. **[mechanics]** Ship the module framework plus `bridge_dash`, `boss_hp` and `fort_siege` as the first three modules (D3, D4), following `mockup-alignment.md` section 5.
4. **[levels]** Turn all 10 non-candy finales into `boss_hp` set pieces with named bosses, 2 to 3 phases and arena changes (D4). This removes the pirate_10/h1 duplicate (D6).
5. **[levels]** Remove every `fixed_list`/`kit` from main-chain and hard-track levels, and replace them with a seeded bag plus `undo_reset` (D9, D10).
6. **[levels]** Raise every hard-track `fall.g0` to the tier 10 value + 0.10, and sync `design_spec` (D8).
7. **[levels]** Rebuild the six biome openers with pre-filled `starting_contents` so the first clear is 2 to 3 pieces away (D11). Build the tutorial island as `tutorial_01` to `tutorial_03`.
8. **[levels]** Retune the stars from the formula in D12, and replace the copy-pasted 290/435/580 thresholds. Also apply the goal-n ramp across biomes (D13).
9. **[levels]** Give pirate_06 rules, give Pirate a native mechanic (deck tilt or cannon), and de-duplicate celestial_02 from ice_01 (D5 to D7).
10. **[levels]** Break the slot template. Vary tier 05 across 4 modules, allow at most 1 fog level per biome, and split the triple introductions in candy_09, forest_08 and celestial_10 (D17 to D19).
11. **[levels]** Add the `variation` block (symmetry plus jitter) to every eligible level, and validate it in CI (D20).
12. **[mechanics]** Add the `COMBO_CHANGED`, `NEAR_MISS`, `PERFECT_CLEAR`, `DANGER_CHANGED` and `LOCK_RESET` events, and give layer coordinates on `LAYERS_CLEARED` (D14).
13. **[feel]** Tier the feedback: bursts at the real cells and layers, trauma shake, hit-stop, layer flash and combo pitch climb, all respecting reduced motion (D15). Preload the audio and give every warning a cue (D16).
14. **[ui]** Fix readability at 720x1280: active-piece contrast, a coloured ghost plus drop beam, a per-layer fill meter, a 20 px or larger NEXT caption and a 22 px or larger timer, and fewer visible buttons (D22). Re-capture `hud_720.png` with a live board (D23).
15. **[levels]** Implement or delete every `unsupported` field (D21). Then run a human playtest of 5 testers or more per biome, recording first-attempt completion, median time and star distribution. No biome may be re-scored above 7 without that data.

## 6. Re-review conditions

Re-score after D1 to D16 land. A biome can reach 8 only with all of the following:
- At least 1 mockup module in the level.
- A boss finale with phases.
- No hard-coded sequence.
- A hard track harder than the finale.
- Star times taken from measured medians.
- Tiered juice on clears and combos.
- A retained 720x1280 screenshot that shows the board.
