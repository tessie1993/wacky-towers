# Minigame Stages: Arena and Level Layout

> Owner: level-designer | Status: Draft, needs creative-director/game-designer review | 2026-10-13
> Source: `assets/art/reference/minigame_mockups/mockup_01.jpg` to `mockup_14.jpg` (viewed). Mockups 15 to 20 were not viewed; Bomb Defuse, Balloon Race and Herd Sheep are designed from their names only.
> Schema: `src/levels/meadow/meadow_05/meadow_05.json`, `candy_07` (mask + starting_contents), `ice_10` (`down_axis: "-x"`, `spawn_anchor`), `meadow_bonus` (`goal.time_limit_ms`), `candy_10` (`goal.type: "bonk_boss"`).

## 0. Ground rules

- **Cast.** The mockups show knights, elves, dwarves, chefs, mummies, cavemen, a dinosaur and two other products' logos ("Tetro Party Dimensions", "Wacky Party Quest"). Take only the **concepts** from them, none of the characters or branding. Every stage below uses only the wizard, pirate, astronaut, robot, penguin, alien, tiki and biome mascots. Art needs to recast before any paintover.
- **Randomness.** Every stage has `"seed": null` and no `fixed_list`, so pieces are random on each attempt. Versus stages give all players the **same** random sequence within one attempt (NEW: `opponents.shared_seed`, default `true`), so the bags differ between attempts but are fair within one.
- **Data only.** Every number below is a JSON value: duration is `goal.time_limit_ms`, star thresholds are `stars`, bot strength is `opponents[].skill`. Nothing is hardcoded.
- **Board.** Every board is at least 8x8 (`width`, `depth`). `mask` and `starting_contents` rows use `#`/`.`. Rows run along `depth` (z) and characters along `width` (x). `spawn_anchor` is `[x, z]`.
- **Stars.** The existing convention is `t2`/`t3` in ms, where lower is better. Race and clear goals keep that convention. Survival and score stages need **NEW `stars.metric`** (`"score"` / `"survived_ms"`, where higher is better). `three_star_zero_metrics` is reused where it fits.
- **Placement.** Minigames go in as new ids `<biome>_mg<n>` (tier = the tier they follow + 0.5 in the level-select order, NEW: fractional `tier` or an `after` field). They are optional side nodes and never on the critical path. Clearing the critical path never requires one.

### Shared NEW block (all versus stages)

```json
"opponents": {
  "mode": "split",            // split = own board per player | shared = one board, multi-cursor | boss = AI hazard only
  "shared_seed": true,
  "bots": [ { "cast": "robot", "skill": 0.45 } ]
}
```
Candidate wiring: the tournament templates `versus_build_race`, `versus_clear_race`, `versus_shape_race` and `versus_survival` in `assets/data/tournament/templates.json` already describe split-board versus. Map onto those before building anything new.

---

## 1. Stage sheets

### 1.1 Bridge Bashers (mockup 01): meadow `meadow_mg1`
- **Arena:** two cliff banks with a river gap. Players fill the gap until a continuous deck connects the banks.
- **Board:** `width 12, depth 8, h_play 6, down_axis "-y"`, no mask. `starting_contents` layers 0 to 2 fill cols 0-2 and 9-11 (banks), so the river is cols 3-8.
  ```
  "0".."2": "###......###" x8 rows
  ```
- **Spawn anchor:** `[6, 2]` (P1 lane z 0-3), `[6, 6]` (bot lane z 4-7).
- **Pieces:** `i, o, l, t, big_cube`. A piece that lands in the river with no support sinks one layer before locking (NEW `river_sink`, optional; v1 can ship without it).
- **Goal:** `"shape"` + `fill_shape`, target = layer 3 across x 0-11 in your lane. `time_limit_ms 75000`.
- **Opponent:** split lane, 1 bot `pirate` skill 0.40.
- **Stars:** t2 60000, t3 45000.
- **Rules:** `fill_shape`, `wobble {wobble_max 4}`, `gust {wind_dir "+x"}`.
- **Pacing:** after `meadow_05` (the first height level). It is a low-stakes sideways-building break before the curve rises at 06.

### 1.2 Herd Sheep: meadow `meadow_mg2` (designed from title only)
- **Arena:** an open field with a pen gap on one rim. Players drop pieces as fences to steer wandering sheep into the pen.
- **Board:** `10x10, h_play 4, -y`. Mask notches the pen mouth at the south edge:
  ```
  "##########" x9, "###....###"
  ```
  `starting_contents` layer 0: two pen posts `#` at (3,8),(6,8).
- **Spawn anchor:** `[5, 3]`.
- **Pieces:** `i, l, o` as fence segments. A sheep that is boxed in for 3 s is "herded" toward the nearest open cell.
- **Goal:** `"rescue_all"` (reused from `candy_h2`), sheep count 6, `time_limit_ms 90000`.
- **Opponent:** none (solo). Biome mascot = `mascot_catch` helper.
- **Stars:** t2 75000, t3 55000; `three_star_zero_metrics ["sheep_escaped"]`.
- **Rules:** `pest {skin "sheep", rim_escape true}`, `mascot_catch`, `sprouts`.
- **NEW:** `pest.herd_target` param (pests path toward the pen mask cell instead of the rim).
- **Pacing:** after `meadow_08`. It is the gentle second minigame before the meadow boss stretch.

### 1.3 Cake Stackers (mockup 05): candy `candy_mg1`
- **Arena:** a round cake plate on a turntable. Stack tiers as high as possible without toppling.
- **Board:** `9x9, h_play 12, -y`. Circular mask:
  ```
  "..#####..", ".#######.", "#########", "#########", "#########",
  "#########", "#########", ".#######.", "..#####.."
  ```
- **Spawn anchor:** `[4, 4]`.
- **Pieces:** `o, i, t, big_cube, tripod`; `jelly_piece` weighting 0.2.
- **Goal:** `"height" h_target 10`, `time_limit_ms 60000`.
- **Opponent:** split, 2 bots (`alien` 0.35, `tiki` 0.50).
- **Stars:** t2 48000, t3 36000.
- **Rules:** `turntable`, `wobble {wobble_max 5}`, `tier_frosting`, `jelly_piece`, `build_race {topout_rule "trim"}`.
- **Pacing:** after `candy_05`. It reuses that level's height skill with the turntable as the only new twist.

### 1.4 Avalanche Ascent (mockup 01): ice `ice_mg1`
- **Arena:** a narrow summit column. The tower is the climb and snowballs roll down the slope.
- **Board:** `8x8, h_play 16, -y`. The mask cuts a slope notch on the uphill side:
  ```
  "##......", "###.....", "####....", "#####...", "######..", "#######.", "########", "########"
  ```
  This is a diagonal footprint. It reads as a mountain face and forces staircase stacking.
- **Spawn anchor:** `[5, 6]`.
- **Pieces:** standard 8 shapes. `snowball` knocks the top unsupported cube off one cell downhill.
- **Goal:** `"height" h_target 14`, `time_limit_ms 90000`.
- **Opponent:** split, 1 bot `penguin` 0.50 (penguin is cast, not the biome mascot here).
- **Stars:** t2 75000, t3 58000.
- **Rules:** `build_race {topout_rule "trim"}`, `snowball`, `gust {wind_dir "-z"}`, `thin_ice`.
- **Pacing:** after `ice_06`. It needs players who already know `snowball` and `gust` from the main list.

### 1.5 Kraken Blockade (mockup 04/07): underwater `underwater_mg1`
- **Arena:** a sea wall between two towers. The kraken boss attacks the wall, and completed layers fire at it.
- **Board:** `12x8, h_play 8, -y`. Mask = wall footprint (the outer ring is water):
  ```
  "............", "............", "############", "############",
  "############", "############", "............", "............"
  ```
  This gives an effective footprint of 12x4. The 8x8 minimum is met by the board but **not by the playable cells**, so flag it for user decision (alternative: an 8x8 square fort).
- **Spawn anchor:** `[6, 3]`.
- **Pieces:** standard. `crab_claw` (reskin "tentacle") steals one cube per sweep.
- **Goal:** `"bonk_boss"` (reused from `candy_10`), each layer clear = 1 hit, boss HP 6, `time_limit_ms 60000`.
- **Opponent:** `mode "boss"`, co-op up to 4 on the shared wall (NEW `shared`).
- **Stars:** t2 50000, t3 38000.
- **Rules:** `crab_claw {skin "tentacle"}`, `bubble`, `rising_silt`, `climber_boss {skin "kraken"}`.
- **Pacing:** after `underwater_09`. It is the biome's pre-finale set piece.

### 1.6 Coral Conduit (mockup 05): underwater `underwater_mg2`
- **Arena:** a flat seabed grid. Lay one-layer pipe from inlet to outlet before the flow meter fills.
- **Board:** `10x8, h_play 3, -y`. `starting_contents` layer 0 holds coral blockers `#` that are scattered and fixed:
  ```
  "..........", "...#......", "......#...", "..#.......", ".......#..", "....#.....", ".#.....#..", ".........."
  ```
- **Spawn anchor:** `[5, 4]`. Inlet is at (0,3) and outlet at (9,4), marked by art and not by cells.
- **Pieces:** `i, l, s, t` only. They lock flat on layer 0.
- **Goal:** NEW `"connect"` (path of filled cells from inlet to outlet, orthogonal), `time_limit_ms 45000`.
- **Opponent:** split, 1 bot `astronaut` 0.40.
- **Stars:** t2 35000, t3 25000.
- **Rules:** `mono_layer`, `bubble`, `rising_silt` (the meter visual).
- **Pacing:** after `underwater_04`. It is a cerebral contrast to the stacking levels.

### 1.7 Rubble Rumble (mockup 01): lava `lava_mg1`
- **Arena:** a cracked rubble plinth over lava. Clear layers to tunnel down before the lava climbs.
- **Board:** `10x10, h_play 10, -y`. Octagon mask:
  ```
  "..######..", ".########.", "##########" x6, ".########.", "..######.."
  ```
  `starting_contents` layers 0-3: full rubble with 2 random-free holes per layer (holes authored, 4 layouts in a NEW `starting_contents_variants` list picked per attempt).
- **Spawn anchor:** `[5, 5]`.
- **Pieces:** standard. `lava_rock_spawn` drops 1x1 rocks every N locks.
- **Goal:** `"clear_n" n 6`, `time_limit_ms 75000`.
- **Opponent:** split, 3 bots (`wizard` 0.3, `robot` 0.45, `tiki` 0.6) for 4-player party.
- **Stars:** t2 60000, t3 45000.
- **Rules:** `lava_rise`, `lava_rock_spawn`, `quake`, `rock_obstacle`.
- **Pacing:** after `lava_03`. It is fast and explosive, and introduces the lava_rise pressure that 04+ builds on.

### 1.8 Fort Frenzy (mockup 01/02): forest `forest_mg1`
- **Arena:** two treehouse forts facing each other. Build your fort while lobbing anvils at the rival's.
- **Board:** `13x8, h_play 10, -y`. Centre clearing masked out:
  ```
  "######.######" x8
  ```
- **Spawn anchor:** `[3, 4]` (P1), `[9, 4]` (bot).
- **Pieces:** standard. Each layer clear earns one lob.
- **Goal:** `"height" h_target 8` OR rival topples. `time_limit_ms 90000`.
- **Opponent:** split on one board (the halves), 1 bot `pirate` 0.5.
- **Stars:** t2 70000, t3 52000.
- **Rules:** `build_race`, `earned_specials`, `anvil_drop`, `wobble {wobble_max 5}`, `woodpecker_knock`.
- **NEW:** cross-half targeting so `anvil_drop` hits the opponent's half (`earned_specials.target "opponent"`).
- **Pacing:** after `forest_05` (the forest height level).

### 1.9 Digging Frenzy (mockup 04): cave `cave_mg1`
- **Arena:** a packed earth block. Clear layers to dig down to crystal coins.
- **Board:** `8x8, h_play 12, -y`. `starting_contents` layers 0-5 are full `#` except for one random-free shaft column, and `star_coins` sit in layers 1, 3 and 5. Placement uses the existing star_coins params.
- **Spawn anchor:** `[4, 4]`.
- **Pieces:** standard; `locked_cube` 0.1.
- **Goal:** `"clear_n" n 6`, `time_limit_ms 90000`.
- **Opponent:** split, 2 bots (`alien` 0.4, `robot` 0.55).
- **Stars:** t2 70000, t3 50000; `three_star_zero_metrics ["coins_missed"]`.
- **Rules:** `star_coins`, `rock_obstacle`, `quake`, `locked_cube`, `fog`.
- **Pacing:** after `cave_02`, which shares the dig-out shape.

### 1.10 Clockwork Conveyor (mockup 04/06): clockwork `clockwork_mg1`
- **Arena:** a cross of conveyor arms with a central furnace. Sort pieces by colour onto the matching arm.
- **Board:** `10x10, h_play 6, -y`. Plus-shaped mask:
  ```
  "...####...", "...####...", "...####...",
  "##########", "##########", "##########", "##########",
  "...####...", "...####...", "...####..."
  ```
- **Spawn anchor:** `[5, 5]` (furnace).
- **Pieces:** standard; `spawn.colour_count 4`.
- **Goal:** `"clear_n" n 5` via colour pops on arms, `time_limit_ms 60000`.
- **Opponent:** shared (NEW), 1 bot `robot` 0.5 on the opposite arms.
- **Stars:** t2 50000, t3 38000.
- **Rules:** `conveyor`, `mill_belt`, `piston_punch`, `colour_pop`, `rusty_hinge`.
- **Pacing:** after `clockwork_01`. It introduces the conveyor verb in a short, forgiving window.

### 1.11 Frenzy Footholds (mockup 03): neon `neon_mg1`
- **Arena:** a neon pit. The flood rises and you build footholds faster than it climbs.
- **Board:** `10x10, h_play 14, -y`. Square ring with a void core:
  ```
  "##########", "##########", "##....####" ... (core 4x4 ".")
  ```
  Exact rows: rows 3-6 = `"###....###"`, all others `"##########"`.
- **Spawn anchor:** `[2, 2]`.
- **Pieces:** standard; `bounce_pad` 0.1.
- **Goal:** `"survive"` (reused from `candy_08`), `time_limit_ms 90000`.
- **Opponent:** split, 3 bots (`wizard`, `astronaut`, `alien`, skill 0.35/0.5/0.65).
- **Stars:** NEW `metric "survived_ms"`, t2 70000, t3 90000.
- **Rules:** `lava_rise {skin "neon_flood"}`, `crumble_tiles`, `bounce_pad`, `magnet_pull`.
- **Pacing:** after `neon_03`.

### 1.12 Bomb Defuse: neon `neon_mg2` (designed from title only)
- **Arena:** a hot grid. Clear the layer holding each bomb before its timer hits zero.
- **Board:** `8x8, h_play 10, -y`. `starting_contents` layer 0: 3 bombs placed by `countdown_bomb`, positions randomised per attempt from its params.
- **Spawn anchor:** `[4, 4]`.
- **Pieces:** standard.
- **Goal:** `"clear_n" n 4`, `time_limit_ms 60000`.
- **Opponent:** none (solo). Party variant via `versus_clear_race`.
- **Stars:** t2 48000, t3 35000; `three_star_zero_metrics ["bombs_exploded"]`.
- **Rules:** `countdown_bomb`, `stopwatch`, `fever_rush`.
- **Pacing:** after `neon_07`. It is a spike of panic before the neon finale.

### 1.13 Chroma Sky Climb (mockup 04): celestial `celestial_mg1`
- **Arena:** a side-view rainbow stairway into the sky. A cloud blows pieces off the open edge.
- **Board:** `16x8, h_play 8, down_axis "-x"`, `spawn.arrival "side_travel"`.
- **Spawn anchor:** `[12, 4]`.
- **Pieces:** standard; `rainbow_piece` 0.15.
- **Goal:** `"shape"` with a diagonal staircase target (8 steps, layers 0-7), `time_limit_ms 75000`.
- **Opponent:** split, 1 bot `robot` 0.45.
- **Stars:** t2 60000, t3 45000.
- **Rules:** `side_travel {travel_dir "-x"}`, `fill_shape`, `gust {wind_dir "+z"}`, `chameleon_paint`, `rainbow_piece`.
- **Pacing:** after `celestial_06`.

### 1.14 Tumbling Towers (mockup 03): carnival `carnival_mg1`
- **Arena:** a seesaw platform over the dunk tank. Keep the plate level while stacking for the treasure.
- **Board:** `11x8, h_play 10, -y`. A long plank, no mask. `starting_contents` layer 0: a `#` fulcrum cell at (5,3),(5,4).
- **Spawn anchor:** `[2, 4]` (P1 end), `[8, 4]` (bot end).
- **Pieces:** standard; `big_cube` 0.3.
- **Goal:** `"height" h_target 8`, `time_limit_ms 60000`.
- **Opponent:** shared board, 1 bot `pirate` 0.5. The bot's weight affects your balance.
- **Stars:** t2 48000, t3 36000.
- **Rules:** `wobble {wobble_max 4}`, `topsy_tumble`, `balloon`.
- **NEW:** `wobble.pivot "board_centre"` (balance from the board-wide centre of mass, not per tower).
- **Pacing:** after `carnival_02`.

### 1.15 Balloon Race: carnival `carnival_mg2` (designed from title only)
- **Arena:** a fairground launch pad. Balloons carry your stack up and gusts push it sideways.
- **Board:** `8x8, h_play 14, -y`. Corners notched:
  ```
  ".######.", "########" x6, ".######."
  ```
- **Spawn anchor:** `[4, 4]`.
- **Pieces:** standard; `balloon` pieces weighted 0.2.
- **Goal:** `"height" h_target 12`, `time_limit_ms 75000`.
- **Opponent:** split, 3 bots (`tiki`, `alien`, `wizard`, skill 0.3/0.45/0.6).
- **Stars:** t2 60000, t3 45000.
- **Rules:** `balloon`, `gust`, `build_race`, `confetti_fill`.
- **Pacing:** after `carnival_06`.

---

## 2. Pacing summary

| Biome | Slot | Stage | Role in curve |
|---|---|---|---|
| meadow | after 05 | Bridge Bashers | break after first height level |
| meadow | after 08 | Herd Sheep | gentle pre-boss |
| candy | after 05 | Cake Stackers | height skill remix |
| ice | after 06 | Avalanche Ascent | combines known hazards |
| underwater | after 04 | Coral Conduit | cerebral contrast |
| underwater | after 09 | Kraken Blockade | pre-finale set piece |
| lava | after 03 | Rubble Rumble | introduces lava pressure |
| forest | after 05 | Fort Frenzy | versus height |
| cave | after 02 | Digging Frenzy | dig-out echo |
| clockwork | after 01 | Clockwork Conveyor | conveyor intro |
| neon | after 03 | Frenzy Footholds | survival |
| neon | after 07 | Bomb Defuse | panic spike |
| celestial | after 06 | Chroma Sky Climb | side-view remix |
| carnival | after 02 | Tumbling Towers | balance |
| carnival | after 06 | Balloon Race | 4-player party |

## 3. NEW mechanics register

| NEW item | Used by | Notes |
|---|---|---|
| `opponents` block (`mode`, `shared_seed`, `bots[].cast/skill`) | 12 stages | map onto tournament `versus_*` templates first |
| `opponents.mode "shared"` (multi-cursor on one board) | Kraken, Conveyor, Tumbling | largest engineering cost |
| `stars.metric` (`survived_ms`/`score`, higher is better) | Footholds | others keep the ms convention |
| goal `"connect"` (inlet to outlet path) | Coral Conduit | |
| `pest.herd_target` | Herd Sheep | |
| `earned_specials.target "opponent"` | Fort Frenzy | |
| `wobble.pivot "board_centre"` | Tumbling Towers | |
| `starting_contents_variants` | Rubble Rumble | per-attempt layout pick |
| `river_sink` (optional) | Bridge Bashers | cut-able |
| `<biome>_mg<n>` placement (`after` field) | all | level-select ordering |

## 4. Open questions for the user
1. Kraken Blockade's playable footprint is 12x4, inside a 12x8 board. Does the 8x8 minimum apply to the board or to the playable cells?
2. Should minigames be optional side nodes (recommended) or replace bonus slots?
3. Mockups 15 to 20 were not reviewed. Bomb Defuse, Balloon Race and Herd Sheep need checking against their sheets.
