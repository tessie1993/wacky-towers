# Level-Design Playtest: Campaign Start Frames (2026-10-14)

> **Lead**: level-design lead (studio-level-design-lead + godot-genre-puzzle lenses)
> **Build**: branch `ccr-86d4b3f2-dl6mzv`, Godot 4.7.2, opengl3 under xvfb, 720x1280 portrait
> **Scope**: all 12 catalog biomes (168 levels). Screenshots of 4 levels per biome (`_01`, `_07`, `_10`, `_h3`) plus 6 spot checks. JSON read for all 168.
> **Not run**: the gdUnit suite (user request). No `src/**` or level JSON edited: another agent is editing level data, so later JSON edits may already change some findings.

## Method and evidence

- **Capture**: a scratch SceneTree script based on `tools/qa/island_capture.gd`. It instances `src/app/main.tscn`, sets `_smoke`, calls `main._start_level(id)`, waits 30 frames, then freezes physics and saves the frame. So each shot is about 1 s into the attempt (HUD clock 0:01), with the first piece still falling.
- **Sheets** (3 across; first, middle and last in catalog order: tier 1, tier 7, tier 14):
  `production/qa/evidence/playtest-2026-10-14/levels/<biome>_sheet.png` for meadow, candy, ice, underwater, pirate, lava, forest, cave, clockwork, neon, celestial and carnival.
- **Raw shots** (48, including the `_10` finales): `production/qa/evidence/playtest-2026-10-14/levels/shots/<id>.png`.
- A start frame shows the layout, the HUD and how readable the board is. It does **not** show feel, rule timing or real difficulty. The difficulty notes below are read from the JSON (goal, `n`, `fall.g0`, rule count). No one has played these levels yet.

## Campaign-wide findings (these explain most per-biome verdicts)

| # | Finding | Data |
|---|---|---|
| C1 | **Board shapes barely vary.** 163 of 168 boards are 8x8. The only exceptions are four 9x9 boards and `ice_10` (16x3 side-travel). Masks (`meadow_04`, `forest_04`, `candy_05`) only show as a faint floor texture at 720x1280, so in practice every island looks like the same square. | `board` dims |
| C2 | **Goals barely vary.** 123 of 168 levels (73%) use `clear_n`. 9 of 12 finales (`_10`) are `clear_n` with 2-3 stacked rules. Only `candy_10` (bake_oven) has a finale goal of its own. | `goal.type` |
| C3 | **Every biome uses the same template.** T5 is always `height` + `build_race`, T6 is always `shape` (fill_shape), T8 is usually `survive`, and T10 is `clear_n` with 3 rules. With the biome skin hidden, a player could not tell candy_05 from forest_05. | tier vs goal |
| C4 | **Shape and objective targets can't be seen at the start.** On `meadow_06`, `ice_06` and `cave_07` the HUD says "Fill the marked flower bed 0/N" but no marked cells show on the board. `clockwork_08` keyholes are tiny decals. | shots2 spot checks |
| C5 | **Wrong copy and HUD text.** `main.gd::_goal_text` hard-codes "Fill the marked flower bed" for *every* shape goal, including Ice "Snowman Picture" and Cave "Twin Gems". `bake_oven` has no case, so `candy_10` shows "Clear 4 full layers 0/1" when the real goal is a 4-high bake. | `src/app/main.gd:848-859`; candy_10 shot |
| C6 | **Too many rules at T1.** Several first levels list 3-4 rules on the pill: `candy_01` (mono_layer, mascot_mood, mascot_catch, angle_gem), `ice_01` (mascot_hint, stopwatch, angle_gem, race_rival, plus a time limit), `carnival_01` (4 rules) and `underwater_01` (4). That breaks "one new idea in isolation". | rules[] |
| C7 | **Pirate is a copy of Underwater.** Same board, goal and rules on `pirate_03`/`underwater_03` (gust+tilt_plate), `pirate_05`/`underwater_05` (build_race+gust) and `pirate_08`/`underwater_08` (survive + rising_silt, T150, identical params). The only difference in each pair is `fall.g0` (±0.05). | diff |

## Per-biome verdicts

Each row covers: does each level teach one idea and then twist it, variety, difficulty curve, readability at 720x1280, and samey pairs.

| Biome | Verdict | Notes |
|---|---|---|
| **Meadow** | **Good intro, weak finish** | Good teach and twist: balloon, then wobble, then gust, then mask. g0 rises smoothly from 0.6 to 1.0. Goals do vary (clear, height, shape, survive). Board and pieces read very well. **Samey**: `meadow_07` (fog+fog_ghost) and `meadow_h3` (fog+fog_ghost+mystery_piece) share their starting contents and look almost the same on the sheet. `meadow_10` "Meadow Mill" is a 3-rule clear_n, not a finale. |
| **Candy** | **Best variety, overloaded start** | Has the only special finale goals in the game (bake_oven, bonk_boss, rescue_all). But `mascot_mood` runs on all 14 levels and `candy_01` opens with 4 rules (C6). `candy_06` drops `h_play` to 3, which is a nice twist. Readability: a pale board with pale cells. The `candy_h3` cake fills the view but stays readable. The `candy_10` HUD text is wrong (C5). |
| **Ice** | **Good, with one standout** | `ice_slide` is taught at T2 and twisted later (fog at T7, flip at T9, thin_ice at h3). The difficulty curve is smooth. `ice_10` (16x3 side-travel) is the only real board-shape twist in the campaign and reads well. `ice_01` is the worst T1 in the game (stopwatch, race rival and a time limit together). `ice_06` says "flower bed" (C5). |
| **Underwater** | **Adequate, flat** | One idea per level, but 10 of 14 are clear_n 3-4 on an 8x8 board. `underwater_06` (shape, g0 0.6) is a big dip. The finale `underwater_10` "Crab's Pile" is conveyor+gust+crab_claw clear_n. The crab boss proposed in mockup-alignment F3 is missing. Readable, with good piece contrast against grey slate. |
| **Pirate** | **Weakest: needs its own identity** | Copies Underwater (C7). No shape level. `pirate_06` "Hull Patch" is typed `completing` but has a plain clear_n with no rule. `pirate_10` and `pirate_h1` ("Kraken Blockade" and "...II") share board, goal and rule ids. The art borrows the meadow castle skyline and shows no sea. The Kraken should be a `boss_hp` fight according to mockup-alignment 1.1 #14. |
| **Lava** | **Mixed; the hard tier is broken** | lava_rise, then ember, then defend_core makes a good opening run. Readability: the board is dark and so are the pieces. Contrast is acceptable thanks to the glowing seams, but this is the lowest-contrast main biome. **Curve break**: `lava_h3` "Forge Fixings" is clear_n **n=1**, g0 0.8, with 3 piece shapes. At tier 14 it is the easiest level in the biome. `lava_09` and `lava_h1` share lava_rise+lava_rock_spawn. |
| **Forest** | **Adequate** | Good rule mix (jumbled_queue, anchored_shelf, woodpecker+vines). **Curve break**: `forest_08` drops to n=2 after n=4 at T7. Conveyor shows up in `forest_09`, `forest_10` and `forest_h3`, so the late levels blur together. `forest_08` and `forest_h2` share woodpecker_knock+vines. |
| **Cave** | **Jagged curve** | `n` goes 2, 2, 2, 4, (height), 4, (shape), **2**, **5**, 3. That is a sawtooth. `cave_07` shows "Fill the marked flower bed 0/24" with no visible target (C4/C5). `fog` appears in 08, 09, 10 and h3, four of the last six levels. `cave_h3` dig_rescue is a good distinct goal. Its start frame (dense rock with buried targets) reads well. |
| **Clockwork** | **Good ideas, buried** | `wind_keys` (08, h3) is one of the few new goals. `clockwork_02` is **n=1** on 9x9, easier than `clockwork_01` (n=2). turntable is used in 02, 09, bonus and h2. Keyhole markers on `clockwork_08`/`h3` are almost invisible at 720x1280 (C4). |
| **Neon** | **Not ready (catalog status "Proposed" for 01-10)** | All 01-10 are clear_n except height (05), shape (06) and survive (08). `neon_01` is n=1. Readability: the active piece is translucent cyan on a cyan grid, the worst piece/board contrast in the campaign (`neon_10`). `neon_10` is 9x9x14, so the island renders smaller. The mockup "Glow Paint Clash" / "Cyber Defender" ideas haven't been used. |
| **Celestial** | **Flat; starts too fast** | `celestial_01` starts at g0 **1.14**, higher than most biomes' T10. The curve after that is smooth (up to 1.5), but the biome has no goal of its own: 12 of 14 levels are clear_n. turntable is used in 09 and h3. `celestial_08` (h_play 6, storm_bolt+defend_core) is a nice compact twist. Sky and board read well. |
| **Carnival** | **Most samey** | 12 of 14 levels are clear_n (all but 05 and 06), and every level uses an 8x8 or 9x9 board. The finale `carnival_10` stacks 4 rules (mystery_piece, storm_bolt, fever_rush, golden_row) instead of having an identity. This is the Tumble Fair biome, but none of the mockup party modules show up (bridge_dash, fort_siege, balance_plate). The striped pieces read well on a pale board. |

## Top 10 level changes (ranked by impact)

1. **pirate_10 "Kraken Blockade": switch the goal to a boss fight.** Change `goal` from `clear_n n=4` to `boss_hp` (or reuse `bonk_boss` until A6 lands). Each clear damages the Kraken, and crab_claw becomes the tentacles. **Why**: the finale currently plays like `pirate_h1`, and the mockup (alignment 1.1 #14) defines it as a boss-health fight. This change also gives Pirate an identity apart from Underwater (C7).
2. **Make the shape/fill target visible, and fix the goal copy, in all 20 `shape` levels** (first `meadow_06`, `ice_06`, `cave_07`). Draw the target cells as a high-contrast outline or ghost fill on the floor from frame 0. Also give `_goal_text` per-level text (use a `goal.label_key` or the level's title key) instead of "Fill the marked flower bed". **Why**: right now the player sees "0/24" with no target, which breaks "never hide the rules" (C4/C5). *Code change, owned by gameplay/UI, not level data.*
3. **candy_10 "Madame Meringue": fix the HUD goal text.** Add a `bake_oven` case to `_goal_text` (for example "Bake a 4-high cake 0/1"). **Why**: the HUD currently says "Clear 4 full layers", which is the wrong goal in a boss finale (C5).
4. **Re-sequence or retune `lava_h3` "Forge Fixings".** Either move it to a puzzle slot (bonus-style, tier about 6) or raise it to `n=3`, g0 at least 1.2, with full piece shapes. **Why**: n=1 at g0 0.8 is the easiest level in Lava but sits at tier 14 (curve break).
5. **Strip T1 down to one rule** in `ice_01`, `candy_01`, `carnival_01` and `underwater_01`. Keep the biome's signature rule only: ice_01 should be `ice_slide` or no twist; move stopwatch, race_rival and the time limit to ice_07. candy_01 should keep `mono_layer`; introduce mascot_mood at T2. **Why**: the non-verbal-tutorial rule says to teach one idea in isolation (C6).
6. **Differentiate the Pirate copies.** `pirate_03`: replace tilt_plate with a rocking ship deck, i.e. `balance_plate` (Tumbling Towers, mockup #6) on a 10x6 hull mask. `pirate_05`: change the height race to Fort Blast (`fort_siege`). `pirate_08`: replace rising_silt with a rising-tide/flooding variant or a `defend_core` treasure chest. **Why**: these three levels match Underwater's T3/T5/T8 in everything but ±0.05 g0 (C7).
7. **Fix the Cave sawtooth.** Make `cave_08` n=4 (not 2) and `cave_09` n=4 (not 5). Replace `fog` in `cave_10` with `dig_down`/rock_obstacle so the finale is "dig to the geode", not a fourth fog level. **Why**: the n sequence 2, 2, 2, 4, 4, 2, 5, 3 is not a smooth curve, and fog is overused.
8. **Break the 8x8 monoculture with board shapes.** Use the existing mask and `spawn_anchor` fields. Make `meadow_10` a 12x8 "mill bridge" (wide board, ties to Bridge Bashers). Make `underwater_09` "Whirlpool" a ring/donut mask. Make `celestial_09` "Drift Islet" two 6x6 islets with a gap. Make `carnival_07` "Bumper Blocks" a 10x10 with a cut-out centre. Masks must render as missing floor tiles, not a floor texture (C1). **Why**: 163 of 168 levels are the same square, and the screenshots confirm it.
9. **Give Neon contrast and a goal of its own.** Make the active piece opaque (or a strong magenta rim) on the cyan grid. Use the mockup's `paint_claim` ("Glow Paint Clash") as the `neon_06` goal instead of a generic fill_shape, and turn `neon_10` into a "light every billboard tile" completion goal. **Why**: Neon has the worst piece/board contrast at 720x1280, and 10 of its levels are still "Proposed".
10. **Separate the near-duplicate hard levels.** Make `pirate_h1` (Kraken II) a survive or defend variant of the new boss. Make `meadow_h3` drop fog_ghost and use mystery_piece + topsy_tumble. Make `lava_h1` swap lava_rock_spawn for quake + locked_cube. Make `forest_h2` replace vines with anvil_drop. **Why**: each pair has the same core rules as an earlier level in the same biome, so the hard tier just repeats it.

Also worth doing, outside the top 10: `clockwork_02` n=1 → 2 (easier than T1); `celestial_01` g0 1.14 → about 0.95 (first-level onboarding); `pirate_06` typed `completing` should get a real completion goal (`fill_shape` hull patch); make `clockwork_08`/`h3` keyhole markers at least 1 cell large, with a glow.

## Per-attempt procedural variation candidates

The standing decision is that the next block is already random each attempt. These levels have **authored layouts** that could also be seeded per attempt (from the existing `_fresh_seed()`) without hurting what they teach:

| Level(s) | What to vary | Why it suits |
|---|---|---|
| `cave_h3` Mole Rescue (dig_rescue) | Positions and depths of buried critters inside the starting rock | Digging stays the same, and the player can't memorise the route |
| `clockwork_08`, `clockwork_h3` (wind_keys) | Keyhole positions on the walls (keep min spacing, never two on the same wall at h3) | Planning matters more than memory |
| `candy_h2` Frosting Factory (rescue_all) | Which starting cubes are frosted | Same rule, a fresh puzzle each attempt |
| `meadow_07`, `ice_07`, `cave_08`, `underwater_07` (fog levels) | Starting-contents heightmap under the fog | Fog levels are about reading uncertainty, so a known layout defeats them |
| `lava_03`, `forest_04`, `clockwork_04`, `celestial_08` (defend_core) | Core cell position (inner 4x4) | Changes which side the defence goes on |
| All `height` T5 levels (`*_05`) | Mask cut-out / footprint variant from a small authored pool | Breaks C3 sameness cheaply |
| `meadow_09` (hatching_eggs), `meadow_h1` (sprouts) | Egg and sprout positions | Placement-driven rules |
| `pirate_04`, `underwater_02` (crab_claw) | Claw approach side | A defender rule should not always come from the same side |

**Keep fixed (do not randomise)**: every `shape`/fill_shape and `_bonus` puzzle (hand-authored, solution-checked, with `piece_budget`); every T1 (onboarding has to be the same for every player); and boss finales, apart from boss attack timing.

## Gaps and caveats

- The start-frame method can't judge the hazards that appear later (gust, quake, crab claw). Those need the bot playtest (`tools/qa/bot_playtest.gd`) or human sessions.
- The middle shot is tier 7 in catalog order, and the last shot is tier 14 (h3), not the `_10` finale. Raw `_10` shots are in `shots/` as well.
- Findings C4/C5 and changes 2-3 are code changes (`src/app/main.gd`, board view), not level-data changes. Route them to the gameplay/UI owners.
