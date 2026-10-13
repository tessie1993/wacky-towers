# Level Type Mix

> **Status**: Applied to level JSON 2026-10-13; awaiting playtest
> **Source**: user request: "Make race levels. Balance levels. Defender levels. Funny levels. Completing levels. Tetris with a twist levels. No standard rules."
> **Field**: each level carries `metadata.level_type` in its JSON under `src/levels/<biome>/<id>/<id>.json`.

## Type definitions

| Type | Meaning | Typical rules |
|---|---|---|
| `race` | Beat a clock, a rival or another racer | `build_race` (height goal), `stopwatch`, `goal.time_limit_ms` |
| `balance` | Wobble, tilt, stacking stability | `wobble`, `topsy_tumble`, `balloon`, `gust`, `quake`, `thin_ice` |
| `defender` | Protect the stack from attacks or hazards | `storm_bolt`, `woodpecker_knock`, `lava_rise`, `crab_claw`, `snowball`, `squirrel_heist`, `pest`, `rising_silt`, `gumdrop_hail`, `piston_punch`, `climber_boss` |
| `funny` | Silly, chaotic twists | `jumbled_queue`, `confetti_fill`, `balloon`, `bounce_pad`, `mystery_piece`, `flip`, `mirror`, `echo_drop`, `bubble`, `moody_cube` |
| `completing` | Fill a shape, picture or packing puzzle | `fill_shape` (goal `shape`) |
| `twist` | Tetris with a twist: layer clearing plus an unusual rule | any `clear_n` level whose main rule is none of the above |

Notes:
- The rule lists below leave out the helper rules `mascot_hint`, `mascot_catch`, `mascot_mood`, `mascot_paw` and `angle_gem`. These are not twists.
- Tagging rule: the type follows the rule that most shapes play. A survive level with bolts is `defender`, not `twist`.
- **Mix target**: each biome's 10 main levels (`_01` to `_10`) include at least one of each of the 6 types. Bonus and hidden (`_h1` to `_h3`) levels are tagged but not counted.

## Per-biome tables

Levels marked `*` were changed in this pass. See [Levels changed](#levels-changed).

### Meadow

| Level | Type | Twist rules |
|---|---|---|
| meadow_01 * | funny | balloon (gentle) |
| meadow_02 * | balance | wobble (gentle, max 10) |
| meadow_03 | balance | gust, dandelion_puff |
| meadow_04 | twist | mushroom_popup |
| meadow_05 | race | build_race, wobble |
| meadow_06 | completing | fill_shape, sprouts |
| meadow_07 | twist | fog, fog_ghost |
| meadow_08 * | defender | sticky_landing, storm_bolt |
| meadow_09 | balance | topsy_tumble, hatching_eggs |
| meadow_10 | twist | mill_belt, gust, topsy_tumble |
| meadow_bonus | completing | fill_shape (time limit) |
| meadow_h1 | twist | sprouts, gust, star_coins |
| meadow_h2 | funny | mushroom_popup, topsy_tumble, confetti_fill |
| meadow_h3 | funny | fog, fog_ghost, mystery_piece |

### Candy

| Level | Type | Twist rules |
|---|---|---|
| candy_01 | twist | mono_layer |
| candy_02 | defender | mono_layer, gumdrop_hail |
| candy_03 | twist | mono_layer, syrup_band, gumdrop_hail |
| candy_04 * | balance | mono_layer, jelly_piece, wobble |
| candy_05 | race | build_race, tier_frosting |
| candy_06 | completing | fill_shape, rainbow_piece |
| candy_07 | defender | colour_pop, pest |
| candy_08 | twist | colour_pop, speed_bump, earned_specials (survive) |
| candy_09 | funny | colour_pop, goo_spread, licorice_lock, flip |
| candy_10 | defender | bake_stage, climber_boss, gumdrop_hail |
| candy_bonus | completing | fill_shape (time limit) |
| candy_h1 | funny | colour_pop, moody_cube |
| candy_h2 | twist | syrup_band, frosting (rescue_all) |
| candy_h3 | defender | colour_pop, climber_boss, countdown_bomb |

### Ice

| Level | Type | Twist rules |
|---|---|---|
| ice_01 * | race | stopwatch, goal.time_limit_ms 360000 |
| ice_02 | twist | ice_slide |
| ice_03 * | balance | wobble (max 8), curling flick |
| ice_04 | defender | snowball |
| ice_05 | race | build_race, ice_slide |
| ice_06 | completing | fill_shape, snowball |
| ice_07 | twist | fog, ice_slide |
| ice_08 | balance | thin_ice (survive) |
| ice_09 | funny | flip, ice_slide |
| ice_10 | twist | side_travel, gust, ice_slide |
| ice_bonus | completing | fill_shape, undo_reset |
| ice_h1 | defender | snowball, gust, rusty_hinge |
| ice_h2 | defender | fog, storm_bolt |
| ice_h3 | balance | thin_ice, ice_slide, crumble_tiles |

### Underwater

| Level | Type | Twist rules |
|---|---|---|
| underwater_01 * | balance | balloon (buoyant pieces) |
| underwater_02 * | defender | crab_claw (gentle) |
| underwater_03 | balance | gust (currents) |
| underwater_04 | funny | bounce_pad, mushroom_popup |
| underwater_05 | race | build_race, gust |
| underwater_06 | completing | fill_shape, undo_reset |
| underwater_07 | twist | fog |
| underwater_08 | defender | rising_silt (survive) |
| underwater_09 | twist | turntable, gust |
| underwater_10 | defender | conveyor, gust, crab_claw |
| underwater_bonus | completing | fill_shape |
| underwater_h1 | funny | bounce_pad, gust, quicksand |
| underwater_h2 | twist | turntable, magnet_pull |
| underwater_h3 | defender | crab_claw, fog, golden_row |

### Lava

| Level | Type | Twist rules |
|---|---|---|
| lava_01 * | defender | lava_rise (gentle) |
| lava_02 | twist | ember |
| lava_03 | defender | lava_rise |
| lava_04 | funny | mushroom_popup, bounce_pad |
| lava_05 | race | build_race |
| lava_06 | completing | fill_shape |
| lava_07 | twist | fog, ember |
| lava_08 | balance | quake (survive) |
| lava_09 | defender | conveyor, lava_rise, lava_rock_spawn |
| lava_10 | twist | lava_rock_spawn, quake, fog |
| lava_bonus | completing | fill_shape |
| lava_h1 | defender | lava_rise, lava_rock_spawn |
| lava_h2 | twist | locked_cube, quake |
| lava_h3 | twist | ember |

### Forest

| Level | Type | Twist rules |
|---|---|---|
| forest_01 * | funny | jumbled_queue (every 6) |
| forest_02 | twist | anchored_shelf |
| forest_03 | twist | mushroom_popup |
| forest_04 | defender | squirrel_heist |
| forest_05 | race | build_race |
| forest_06 | completing | fill_shape |
| forest_07 | balance | gust, dandelion_puff |
| forest_08 | defender | woodpecker_knock, vines |
| forest_09 | defender | conveyor, squirrel_heist |
| forest_10 | twist | conveyor, gust, mushroom_popup |
| forest_bonus | completing | fill_shape |
| forest_h1 | twist | fog, gust, anvil_drop |
| forest_h2 | defender | woodpecker_knock, vines, echo_drop |
| forest_h3 | funny | conveyor, squirrel_heist, jumbled_queue |

### Cave

| Level | Type | Twist rules |
|---|---|---|
| cave_01 * | balance | wobble (max 8) |
| cave_02 | twist | rock_obstacle |
| cave_03 | twist | conveyor |
| cave_04 | twist | gust, mushroom_popup |
| cave_05 | race | build_race, rock_obstacle |
| cave_06 | funny | mirror |
| cave_07 | completing | fill_shape, mirror |
| cave_08 | twist | fog |
| cave_09 | twist | mirror, fog |
| cave_10 | defender | conveyor, woodpecker_knock, fog |
| cave_bonus | completing | fill_shape, mirror |
| cave_h1 | twist | conveyor, gust |
| cave_h2 | defender | woodpecker_knock, mushroom_popup, rock_obstacle |
| cave_h3 | twist | fog (dig_rescue) |

### Clockwork

| Level | Type | Twist rules |
|---|---|---|
| clockwork_01 * | balance | wobble (max 8) |
| clockwork_02 | twist | turntable |
| clockwork_03 | twist | conveyor |
| clockwork_04 | defender | piston_punch |
| clockwork_05 | race | build_race |
| clockwork_06 | completing | fill_shape |
| clockwork_07 | race | stopwatch |
| clockwork_08 | twist | key_stamp (wind_keys) |
| clockwork_09 | funny | turntable, flip |
| clockwork_10 | twist | conveyor, piston_punch, stopwatch |
| clockwork_bonus | completing | fill_shape, turntable |
| clockwork_h1 | twist | conveyor, magnet_pull |
| clockwork_h2 | twist | turntable, pressure_cooker |
| clockwork_h3 | twist | key_stamp, piston_punch, magnet_pull (wind_keys) |

### Neon

| Level | Type | Twist rules |
|---|---|---|
| neon_01 * | balance | balloon (gentle) |
| neon_02 | race | stopwatch |
| neon_03 | twist | conveyor |
| neon_04 | funny | mirror |
| neon_05 | race | build_race |
| neon_06 | completing | fill_shape |
| neon_07 | funny | bubble |
| neon_08 * | defender | stopwatch, storm_bolt (survive) |
| neon_09 | twist | turntable, gust |
| neon_10 | twist | conveyor, mirror, gust |
| neon_bonus | twist | mirror, fever_rush, golden_row |
| neon_h1 | race | stopwatch, fever_rush |
| neon_h2 | twist | turntable, gust, golden_row |
| neon_h3 | twist | mono_layer, mirror, chameleon_paint |

### Celestial

| Level | Type | Twist rules |
|---|---|---|
| celestial_01 * | funny | mystery_piece (every 6) |
| celestial_02 * | race | stopwatch, goal.time_limit_ms 330000 |
| celestial_03 | balance | gust (solar wind) |
| celestial_04 | twist | mushroom_popup |
| celestial_05 | race | build_race, balloon |
| celestial_06 | completing | fill_shape |
| celestial_07 | balance | fog, balloon |
| celestial_08 * | defender | storm_bolt (meteors), choose_down control |
| celestial_09 | funny | turntable, balloon |
| celestial_10 | twist | event_card, lava_lid |
| celestial_bonus | completing | fill_shape, undo_reset |
| celestial_h1 | defender | gust, storm_bolt |
| celestial_h2 | funny | fog, mystery_piece |
| celestial_h3 | funny | turntable, jumbled_queue |

### Carnival

| Level | Type | Twist rules |
|---|---|---|
| carnival_01 | funny | golden_row, balloon |
| carnival_02 * | balance | star_coins, mushroom_popup, wobble |
| carnival_03 | twist | fever_rush, turntable |
| carnival_04 | twist | chameleon_paint, colour_pop |
| carnival_05 | race | build_race, magnet_pull |
| carnival_06 | completing | fill_shape, jumbled_queue |
| carnival_07 | funny | echo_drop, mirror |
| carnival_08 | twist | pressure_cooker, fog |
| carnival_09 | defender | storm_bolt, ice_slide |
| carnival_10 | twist | mystery_piece, storm_bolt, fever_rush, golden_row |
| carnival_bonus | funny | rusty_hinge, turntable, confetti_fill |
| carnival_h1 | defender | magnet_pull, storm_bolt |
| carnival_h2 | funny | mystery_piece, echo_drop |
| carnival_h3 | twist | rusty_hinge, pressure_cooker |

## Mix summary (main levels 01-10)

| Biome | race | balance | defender | funny | completing | twist |
|---|---|---|---|---|---|---|
| meadow | 1 | 3 | 1 | 1 | 1 | 3 |
| candy | 1 | 1 | 3 | 1 | 1 | 3 |
| ice | 2 | 2 | 1 | 1 | 1 | 3 |
| underwater | 1 | 2 | 3 | 1 | 1 | 2 |
| lava | 1 | 1 | 3 | 1 | 1 | 3 |
| forest | 1 | 1 | 3 | 1 | 1 | 3 |
| cave | 1 | 1 | 1 | 1 | 1 | 5 |
| clockwork | 2 | 1 | 1 | 1 | 1 | 4 |
| neon | 2 | 1 | 1 | 2 | 1 | 3 |
| celestial | 2 | 2 | 1 | 2 | 1 | 2 |
| carnival | 1 | 1 | 1 | 2 | 1 | 4 |

Every biome meets the target of at least one of each type.

## Levels changed

Each change below is recorded in the level's `metadata.design_amendments` (date 2026-10-13). Where `metadata.design_spec.rules` exists, the rule is mirrored there too.

**14 standard levels given a real twist:**

| Level | Was | Added | Type |
|---|---|---|---|
| meadow_01 | no rules | balloon: 1/bag, g x0.7, drift 4000 ms (gentle tutorial) | funny |
| meadow_02 | mascot_catch only | wobble: wobble_max 10 (gentle; default 6) | balance |
| ice_01 | mascot_hint, angle_gem | stopwatch: every 18000 ms, stop 2000 ms; goal.time_limit_ms 360000 | race |
| ice_03 | no rules | wobble: wobble_max 8 | balance |
| underwater_01 | mascot helpers, angle_gem | balloon: 1/bag, g x0.6, drift 3500 ms | balance |
| underwater_02 | mascot helpers, angle_gem | crab_claw: every 30000 ms, warn 2500 ms, grab 1, starts at layer 2 | defender |
| lava_01 | no rules | lava_rise: first 60 s, every 60 s, max 2, warn 3000 ms (no design_spec rules array) | defender |
| forest_01 | no rules | jumbled_queue: every 6 | funny |
| cave_01 | no rules | wobble: wobble_max 8 | balance |
| clockwork_01 | no rules | wobble: wobble_max 8 | balance |
| neon_01 | no rules | balloon: 1/bag, g x0.7, drift 4000 ms | balance |
| celestial_01 | mascot_hint, angle_gem | mystery_piece: every 6 | funny |
| celestial_02 | mascot_hint, angle_gem | stopwatch: every 16000 ms, stop 2000 ms; goal.time_limit_ms 330000 | race |
| celestial_08 | no rules | storm_bolt: 12000 ms, warn 2000, jitter 2000 (no design_spec rules array) | defender |

**4 levels re-twisted to fill a gap in the mix (goal kept):**

| Level | Gap filled | Added | Type |
|---|---|---|---|
| meadow_08 | meadow defender | storm_bolt: 15000 ms, warn 2500, jitter 2000 | defender |
| candy_04 | candy balance | wobble: wobble_max 7 | balance |
| neon_08 | neon defender | storm_bolt: 12000 ms, warn 2000, jitter 2000 | defender |
| carnival_02 | carnival balance | wobble: wobble_max 7 | balance |

All other 136 levels only gained the `metadata.level_type` tag.

### Tuning rationale
- **Time limits**: about 1.25 x the level's `t2` star time, rounded. A player who would earn 2 stars never hits the limit.
- **wobble_max**: a higher value is gentler, since the meter must fill further before a piece slips. The default and meadow_05 use 6. Openers use 8 to 10.
- **storm_bolt**: the GDD safe range is 5000 to 20000 ms (mechanics-wave3 W11). New uses sit at 12000 to 15000 ms, gentler than the carnival hidden levels at 8000 ms.
- **crab_claw, lava_rise, jumbled_queue, mystery_piece**: each is set gentler than the softest existing use of that rule in the campaign.

## Follow-ups
- `race_rival`, `tilt_plate` and `defend_core` JSON appeared in `assets/data/rules/` at the end of this pass. They are not used yet. Good candidates:
  - `race_rival`: ice_01, celestial_02, clockwork_07, neon_02
  - `tilt_plate`: meadow_02, cave_01, clockwork_01
  - `defend_core`: meadow_08, celestial_08, lava_01
- `bounce_pad` was not used for the tutorial levels. Its pads come from `mushroom_popup` (`object_kind: bounce_pad`, see lava_04), which is too much for a first level, so meadow_01 uses balloon instead.
- All new values are initial estimates. Playtest the 18 changed levels, especially both time-limited races and the meadow_01 and meadow_02 tutorials.
