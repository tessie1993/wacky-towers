# Campaign Minigames (Level Modules + Tournament Head-to-Head)

> **Status**: Designed (autonomous run, 2026-10-13, rev 2 after the user's direction); awaiting design review and playtest
> **Author**: game-designer
> **Extends**: `tournament-minigames.md` (minigame contract, MG1–MG15), `party-minigames-wave2.md` (MG22–MG36), `mode-minigame-randomizer.md`, `level-data-definition.md`
> **User decisions (2026-10-13)**:
> 1. Minigames are **not** separate stages. They are reusable **modules** composed inside normal campaign levels and reskinned per biome.
> 2. The tournament randomly picks minigames as **head-to-head rounds**. All players share one seed per round; bots fill empty seats.
> 3. The economy follows level stars as normal.
>
> **Sources**:
> - The user's mockups `assets/art/reference/minigame_mockups/mockup_01–04, 11–13, 16.jpg` (viewed); the remaining sheets are known from the coordinator's concept list
> - The user's references `party_versus_ref.jpg` and `party_modes_ref.jpg`
> - Genre knowledge (no live web research)

## Overview

This system turns the party minigame ideas into **level modules**. A module is a self-contained gameplay unit with its own objective, parameters and biome skin. Examples: a bridge you must span, a rising-lava phase, a boss with HP, a dig-down shaft, a tilting balance plate.

- **Composition.** A campaign level lists one or more modules in a new `modules` array. They run in **phases** (one after another) and as **overlays** (alongside a phase). The level is complete when its last phase is complete, and is scored with the level's normal stars.
- **Coverage.** Each biome draws on a small set of modules. Its 10 main levels, bonus and hard levels h1–h3 follow a fixed teach → combine → remix pattern.
- **Tournament.** The same module code powers the head-to-head pool: MG37–MG50 join MG1–MG36 in the Randomizer. Every player shares one round seed, and bots fill empty seats.
- **Pieces.** Pieces stay random on every attempt.
- **Pillar.** The falling block stays the star: in every module the player only drops, rotates or slides pieces, and mascots act on what you place.

## Player Fantasy

"Every level is a little party of its own." A Lava level opens with bridging a gap so the wizard can cross. Then the floor starts to glow, and you are stacking footholds to climb out. Then a magma golem rises, and every layer you clear is a cannon shot at its health bar. The puzzle verb never changes, but the reason for it does, every minute or two. In tournaments those same modules come back as head-to-head showdowns you already know how to play.

- **MDA targets**: **Challenge** (primary), **Discovery** (new module combinations), **Fantasy** (biome skins, cast and mascots); **Fellowship** in tournaments.
- **SDT**:
  - *Competence*: each module is taught alone before it is combined.
  - *Autonomy*: modules offer different approaches (wide vs tall, safe vs fast).
  - *Relatedness*: mascots walk, climb and cheer on your blocks.
- **Flow**: phases form a mini sawtooth inside one level (build → payoff banner → harder phase). The biome pattern forms the larger sawtooth.

## Detailed Design

### Module rules

1. **Definition.** A module is a registered gameplay unit with:
   - `id`
   - `role`: `primary` (has a completion condition) or `overlay` (a hazard or modifier with no completion condition)
   - a parameter schema with defaults and safe ranges, in `assets/data/modules/<id>.json`
   - board requirements (minimum width, depth and height)
   - a list of compatible overlays
   - a list of skins
   - its own fail condition, if any
2. **Level JSON.** A level may contain:
   ```json
   "goal": {"type": "modules"},
   "modules": [
     {"id": "bridge_dash", "skin": "lava", "phase": 1, "params": {"gap_cells": 6}, "until": {"type": "walker_at_end"}, "carry": "keep"},
     {"id": "summit_climb", "skin": "lava", "phase": 2, "params": {"target_height": 9}, "until": {"type": "mascot_height", "value": 9}, "carry": "keep"},
     {"id": "rising_hazard", "skin": "lava", "phase": [2], "params": {"r": 0.08}},
     {"id": "boss_hp", "skin": "lava", "phase": 3, "params": {"hp": 10}, "until": {"type": "boss_hp_zero"}, "carry": "clear"}
   ]
   ```
3. **Phases.**
   - **Primary modules** run in ascending `phase` order, one primary per phase.
   - When a phase's `until` is met:
     1. Any piece in the air finishes landing.
     2. A `phase_banner_ms` banner plays (default 1 500; spawning is paused and the clock keeps running).
     3. The next phase starts.
   - The level is complete when the last phase's `until` is met.
4. **Overlays** run during the phases they list (`"phase": [2,3]` or `"all"`). There are at most `max_overlays_per_phase` (default 2) per phase. Overlays never complete; they stop when their phase ends.
5. **Carry.** `carry` controls what the board looks like when the next phase starts:
   - `keep`: the board stays as it is.
   - `clear`: the board is emptied with a confetti pop.
   - `shift`: the board scrolls by `shift_cells` so the new objective has room (for example, a bridge becomes the foot of a climb).
6. **One board.** All of a level's modules share one board, at least 8×8. The validator checks every module's board requirement against the level's board.
7. **Fail.** A level fails on top-out (existing `goal.top_out` handling) or on any active module's fail condition, for example:
   - a mascot touches the hazard
   - a fuse reaches 0
   - topples exceed `topples_max`

   The existing `goal.warnings_max` and rescue behaviour still apply.
8. **Rules still apply.** The `rules` array (`assets/data/rules/*.json`) works as before and stacks with modules. Many modules are thin compositions of existing rule ids (see the catalogue).
9. **Legacy goals.** A level with an existing goal (`clear_n`, `shape`, `height`, `survive`, `wind_keys`, `bake_oven`, `rescue_all`, `bonk_boss`, `dig_rescue`) and no `modules` is loaded as a single implicit module, `legacy_goal`. Existing levels keep working unchanged.
10. **Pieces.** Pieces are random for each attempt (F1). Each phase draws from the same attempt stream, so phase pieces are not predictable from earlier attempts.
11. **Stars and economy.** Stars use the level's normal `stars` block (time thresholds in ms, as in `meadow_02.json`). Modules do not add their own stars or currency. Rewards follow level stars as normal.
12. **Scaffolding.**
    - A biome introduces at most 2 new primary modules.
    - A module's first appearance is solo, with no overlay.
    - Overlays first appear on a module the player has already seen.
    - A module's first appearance in a biome uses that biome's skin.

### Module catalogue

Each primary module also gives its name to a tournament template (MG37–MG50). Overlays (O1–O4) and wrappers (W1–W3) are campaign-only, but tournament templates may embed overlays.

| Module id | Role | Verb | Key params (data) | `until` / fail | Reuses | From mockup / MG |
|---|---|---|---|---|---|---|
| `bridge_dash` | primary | Span the gap | `gap_cells`, `lanes`, `walker_step_ms` | walker reaches the far side / walker falls | MG6 walkway, `build_race`, `speed_bump` | Bridge Bashers, Bridge Dash, Meadow Mayhem, Volcano Dash; MG37 |
| `balance_plate` | primary | Balance high | `w_base`, `tilt_max`, `s_fail`, `t_grace`, `target_height`, `topples_max` | height ≥ target / topples > max | MG5 physics, `wobble`, `bounce_pad` | Tumbling Towers, Wonky Builders, Cake Stackers, Fruit Stack; MG38 |
| `paint_claim` | primary | Paint territory | `target_pct`, `rival_rate` (scripted pest painter) | owned % ≥ target | `chameleon_paint`, `confetti_fill`, `goo_spread` | Neon Splat, Island Claim; MG39 |
| `clear_layers` | primary | Sprint-clear | `n` | n layers cleared | `clear_n`, `stopwatch` | Speed Stack; MG40 |
| `road_race` | primary | Pave and race | `track_len`, `v_base`, `boost`, `hole_drag`, `coins` | kart at finish / kart stalled `stall_ms` | `conveyor`, `mill_belt`, `star_coins`, `balloon` | Rolling Rumble, Balloon Race, Rail Rush, Glacier Rush, Galactic Grab; MG41 |
| `summit_climb` | primary | Build footholds | `climb_reach`, `climb_step_ms`, `target_height` | mascot height ≥ target / hazard touch | `vines`, MG13 | Avalanche Ascent, Summit Scramble, Frenzy Footholds, Jungle Vine Ascent, Candy Climb, Pyramid Climber; MG42 |
| `fort_siege` | primary | Build, then lob | `build_phase_ms`, `rival_fort_cells`, `splash_cells`, `return_fire_ms` | rival fort ≥ `target_pct` destroyed / own fort < `fort_min_cells` | `anvil_drop`, `crumble_tiles`, MG22 aim | Fort Frenzy, Fort Blast, Shatter Shootout, Castle Siege Crash, Candy Crushers; MG43 |
| `dig_down` | primary | Dig down | `depth`, `gems`, `rescue` (bool) | depth reached (+ rescue) | `dig_rescue`, `angle_gem`, `mud` | Digging Frenzy, Rubble Rumble; MG44 |
| `conveyor_sort` | primary | Sort to hoppers | `sort_n`, `belt_speed`, `hopper_colours` | n sorted / `miss_max` exceeded | `conveyor`, `mill_belt`, MG9 colours | Clockwork Conveyor; MG45 |
| `boss_hp` | primary | Wall and fire | `hp`, `dmg_per_clear`, `attack_period_ms`, `attack_cells` | HP 0 / wall breached to row 0 | `bonk_boss`, `climber_boss`, `storm_bolt` | Kraken Blockade, Boss Bash; MG46 |
| `stair_path` | primary | Stair to the stars | `path_len`, `colour_bonus`, `max_step` | walker at the top | `rainbow_piece`, `build_race` | Chroma Sky Climb, Cosmic Climb; MG47 |
| `route_runner` | primary | Route the runner | `goals_n`, `guard` (bool), `followers` (sheep, pearls) | goals reached / caught by guard | `key_stamp`, `fog`, `mascot_paw`, MG17 maze view | Maze Heist, Neon Maze, Herd Sheep, Coral Conduit; MG48 |
| `ring_defuse` | primary | Fill the rings | `rings_n`, `fuse_ms`, `ring_bonus_ms` | rings done / fuse reaches 0 | `countdown_bomb`, `colour_pop`, `turntable` | Bomb Defuse, Potion Puzzle; MG49 |
| `floe_survive` | primary | Keep your footing | `survive_ms`, `floe_cells`, `shove_period_ms` | time survived / mascot off the floe | `ice_slide`, `thin_ice`, `piston_punch` | Slippery Sumo Iceberg, Bumper Battle, Lava Escape, Glacier Gauntlet; MG50 |
| `rising_hazard` (O1) | overlay | Outbuild it | `kind` (lava, avalanche, silt, water), `h0`, `r` | fail if the hazard touches the mascot or the stack top | `lava_rise`, `rising_silt`, `snowball` | Frenzy Footholds, Summit Scramble, Avalanche Ascent |
| `gust_wind` (O2) | overlay | Brace for wind | `period_ms`, `strength` | — | `gust`, `dandelion_puff` | Chroma Sky Climb cloud |
| `crumble_floor` (O3) | overlay | Patch the floor | `rate`, `pattern` | — | `crumble_tiles`, `thin_ice`, `quicksand` | Glacier Gauntlet |
| `pace_mascot` (O4) | overlay | Beat the rival | `pace_s` (scripted ghost rival; visual pressure only) | — (never fails the level) | `mascot_paw` | Bridge Bashers / race rivals |
| `legacy_goal` (W1) | wrapper | Any legacy goal | the existing `goal` block | as the goal | all existing goals | — |
| `bake_oven` / `wind_keys` / `rescue_all` (W2) | wrapper | Existing biome goals as phases | existing params | as the goal | existing | — |
| `shape_fill` (W3) | wrapper | Fill the outline | `shape` | shape filled | `shape`, `fill_shape` | — |

**Overlay compatibility.** The validator rejects combinations such as `rising_hazard` + `dig_down` (opposite directions) and `crumble_floor` + `bridge_dash`. The full matrix lives in each module's `compatible_overlays` list.

### Biome module plan

**Level pattern (every biome)**, where A and B are the biome's two signature modules, R is a recurring module from an earlier biome, and O is the biome overlay:

| Level | Composition | Purpose |
|---|---|---|
| 01–02 | `legacy_goal` (authored board) | Biome rules and pieces |
| 03 | A solo | Teach A |
| 04 | A + O | Add pressure |
| 05 | B solo | Teach B |
| 06 | B + O | Add pressure |
| 07 | A → B (2 phases) | First chain |
| 08 | R (biome skin) + O | Recall an older module |
| 09 | B → R + O | Combination |
| 10 | A → B → finale (`boss_hp` or a biome finale) | Biome climax |
| bonus | Showcase module solo, relaxed params | A "party" breather |
| h1 | L07 chain × `hard_mult` | Mastery |
| h2 | L09 chain × `hard_mult` + a second overlay | Mastery |
| h3 | L10 chain × `hard_mult` | Mastery |

**Authored levels.** Existing levels keep their authored board, rules and story. Where the plan gives modules to a level that already has a legacy goal, the level designer either:
- keeps the legacy goal as phase 1 (`legacy_goal` → module), or
- replaces the goal, recording a `design_amendments` entry.

| Biome | Skin | A (signature 1) | B (signature 2) | R (recurring) | O (overlay) | L10 finale chain | Bonus showcase |
|---|---|---|---|---|---|---|---|
| Meadow | meadow | `clear_layers` "Hay Bale Sprint" | `bridge_dash` "Meadow Mayhem" | — (first biome: `route_runner` "Herd Sheep" introduced as R, solo) | `gust_wind` (dandelion) | sprint → bridge → herd sheep | `balance_plate` "Fruit Stack" |
| Candy | candy | `balance_plate` "Cake Stackers" | `fort_siege` "Candy Crushers" | `clear_layers` | `gust_wind` (sugar breeze) + rule `gumdrop_hail` | cake stack → fort siege → `boss_hp` "Gingerbread Giant" | `paint_claim` "Frosting Splat" |
| Ice | ice | `summit_climb` "Avalanche Ascent" | `floe_survive` "Iceberg Sumo" | `bridge_dash` (ice ramps) | `rising_hazard` (avalanche) | bridge → avalanche climb → iceberg sumo | `road_race` "Glacier Rush" |
| Underwater | underwater | `route_runner` "Coral Conduit" | `boss_hp` "Kraken Blockade" | `summit_climb` | `rising_hazard` (silt) | conduit → climb → Kraken | `road_race` "Current Racers" |
| Lava | lava | `bridge_dash` "Volcano Dash" | `summit_climb` "Frenzy Footholds" | `floe_survive` "Lava Escape" | `rising_hazard` (lava) | bridge → footholds → `boss_hp` "Magma Golem" | `fort_siege` "Fort Blast" |
| Forest | forest | `balance_plate` "Tumbling Towers" (treetop) | `summit_climb` "Jungle Vine Ascent" | `route_runner` | `crumble_floor` (rotten logs) | towers → vine climb → `boss_hp` "Boss Bash" (scarecrow giant) | `clear_layers` "Woodpile Sprint" |
| Cave | cave | `dig_down` "Digging Frenzy" | `route_runner` "Maze Heist" (golem guard) | `clear_layers` | `crumble_floor` (rubble) | dig → heist → `boss_hp` "Crystal Golem" | `ring_defuse` "Mine Bomb" |
| Clockwork | clockwork | `conveyor_sort` "Clockwork Conveyor" | `ring_defuse` "Bomb Defuse" | `balance_plate` | `rising_hazard` (lava below the factory) | sort → defuse → `boss_hp` "Gear Titan" | `fort_siege` "Castle Siege Crash" |
| Neon | neon | `paint_claim` "Neon Splat" | `route_runner` "Neon Maze" (gravity flip) | `road_race` "Runaway Rail Rush" | `crumble_floor` (glitch tiles) | splat → maze → rail rush | `clear_layers` "Laser Sprint" |
| Celestial | celestial | `stair_path` "Chroma Sky Climb" | `road_race` "Galactic Grab" | `summit_climb` "Cosmic Climb" | `gust_wind` (storm cloud) | stair → galactic race → `boss_hp` "Storm Cloud" | `balance_plate` "Moon Stack" |
| Carnival (Tumble Fair) | carnival | `road_race` "Balloon Race" | `fort_siege` "Shooting Gallery" | remix: any earlier A or B | rotates (each level picks 1 earlier overlay) | Grand Tour: balloon race → `paint_claim` "Island Claim" → `ring_defuse` → `boss_hp` "Ringmaster Bot" (4 phases, the only one) | `paint_claim` "Island Claim Battle" |

All 14 primary modules appear in the campaign. Exact `params` per level are the level-designer's job, within the safe ranges in each module file and the F3 scaling below.

### Tournament head-to-head pool

1. **Pick.** The Randomizer picks a template for each round from the unlocked pool, as now (`mode-minigame-randomizer.md` rules 1–7). The pool is the existing MG1–MG36 plus MG37–MG50 below.
2. **Unlock.** An MG37–MG50 template unlocks when the player has cleared its module's first campaign appearance. This means a player has seen every round type before meeting it in versus.
3. **Head-to-head.** 2–4 seats with mirrored boards (or one shared arena where the hook is Shared).
   - Every seat uses the same `round_seed`, so all players get the same pieces, hazards and walls.
   - Sends and Steals change only the target's copy.
4. **Bots fill empty seats.** Before the round, empty seats get bots from the cast. Bot skill comes from the tournament difficulty setting (F2).
   - If a human disconnects mid-round, a bot takes over their seat at their current state, and the result is credited to the human's standing.
5. **Winner.** The winner is the first to meet the module's `until`, or the best standing metric at `t_mg`. Ties are shared (Tournament Flow rule 3).
6. **Campaign vs versus.** In versus, scripted campaign opponents (the rival fort's return fire, the pest painter, the pace mascot) are replaced by real seats.

| MG | Template | Module(s) | t_mg | Standing | Hook | Arena |
|---|---|---|---|---|---|---|
| MG37 | Block Bridge Dash | `bridge_dash` + `rising_hazard` | 120 s | race_progress | S: Crumble Plank | mirrored lanes |
| MG38 | Wobble Builders | `balance_plate` | 90 s | height | S: Gust | mirrored |
| MG39 | Island Claim Battle | `paint_claim` | 90 s | score (% owned) | Sh: the floor | shared island |
| MG40 | Speed Stack | `clear_layers` | 150 s | race_progress | S: Grey Garbage | mirrored |
| MG41 | Block Racers | `road_race` | 120 s | race_progress | S: Oil Slick | mirrored track, shared view |
| MG42 | Summit Scramble | `summit_climb` + `rising_hazard` | 120 s | alive_time, then height | S: Rockfall | mirrored |
| MG43 | Fort Blast | `fort_siege` | 120 s | score (destruction %) | St: lobs hit rivals | facing forts |
| MG44 | Digging Frenzy | `dig_down` | 120 s | race_progress (depth) | Sh: gem vein | mirrored |
| MG45 | Clockwork Conveyor | `conveyor_sort` | 90 s | score | S: Jam Belt | mirrored |
| MG46 | Kraken Blockade | `boss_hp` | 150 s | score (damage dealt) | Sh: the boss (co-op race for the most damage) | shared boss |
| MG47 | Chroma Sky Climb | `stair_path` + `gust_wind` | 150 s | race_progress | S: Gust | mirrored |
| MG48 | Maze Heist | `route_runner` | 120 s | score (goals) | S: Alert Guard | mirrored |
| MG49 | Bomb Defuse | `ring_defuse` | 90 s | score (rings) | S: Fuse Burn | mirrored |
| MG50 | Slippery Sumo | `floe_survive` (seats push each other) | 90 s | alive_time | Sh: the floe | shared floe |

**Gap noted.** MG16–MG21 exist in code (`rules_a.gd`, `rules_b.gd`) but have no GDD. `route_runner` assumes it can reuse MG17's maze view (lead-programmer to confirm).

## Formulas

**F1 — Seeds.**
- Campaign: `attempt_seed = hash(level_id, profile_attempt_counter)`. The counter goes up on every start, so each retry differs. Every phase draws from the same attempt stream.
- Tournament: `round_seed = hash(tournament_seed, round_index)`. All seats, bots included, use it. Bot decisions use `hash(round_seed, seat_index)`, and Sends use `attack_rng`.

**F2 — Tournament bot skill.**
`bot_skill = clamp(diff_base[setting] + jitter·(u − 0.5), 0, b_max)`
- `diff_base`: easy 0.30, normal 0.55, hard 0.80. `jitter` = 0.10, `b_max` = 0.90.
- `u` comes from `hash(round_seed, seat_index)`.
- The skill sets reaction delay `lerp(1 200, 350, skill)` ms and placement error `lerp(1.5, 0.2, skill)` cells.
- Example: on normal with u = 0.8 → 0.55 + 0.03 = **0.58**.

**F3 — Module difficulty scaling across a biome.**
`p = p_base · (1 + s_p · (k − 1)) · (hard ? hard_mult : 1)`
- `k` = the module's appearance index within the biome (1 = first).
- `s_p` = the per-param slope (signed: −0.08 for `walker_step_ms`, +0.10 for `gap_cells`).
- `hard_mult` = 1.25 for h1–h3.
- The result is clamped to the module's safe range.
- Example: `gap_cells` base 4, third appearance, hard → 4 · 1.2 · 1.25 = 6.

**F4 — Balance (`balance_plate`).**
`S = clamp(1 − |x_com − x_base| / (w_base/2), 0, 1)`
- Tilt = `tilt_max·(1 − S)·sign(x_com − x_base)`, with `tilt_max` = 12°.
- A topple happens when `S < s_fail` (0.15) for longer than `t_grace` (1.5 s). It costs `topple_penalty` (2) cells.
- Example: on an 8-cell base with the COM 3 cells off-centre, S = 0.25 and tilt = 9°.

**F5 — Fort damage (`fort_siege`).**
`destruction% = 100 · cells_removed / cells_at_build_end`
- Each hit removes its cells plus `splash_cells` (1). Unsupported cells fall and count as removed.
- A fort under `fort_min_cells` (12) is padded with free stone.
- Example: a 40-cell fort losing 22 cells = 55%.

**F6 — Climb and hazard (`summit_climb`, `rising_hazard`).**
- Each `climb_step_ms` (500), the mascot steps to an adjacent column whose top is ≤ `climb_reach` (1) higher.
- The hazard height is `h(t) = h0 + r·t_phase`. Example: r = 0.08 at 100 s → 8 cells.

**F7 — Kart speed (`road_race`).**
`v = v_base·(1 + boost·clears_5s)·(1 − hole_drag·hole_frac)`
- The minimum speed is 0.25. Each coin adds 0.2 s of boost.
- Defaults: `v_base` = 1.0, `boost` = 0.35, `hole_drag` = 0.6.

**F8 — Level star suggestion (authoring aid).**
`T_med = Σ_i m_med_i + (phases − 1)·phase_banner_ms`
- The suggested time thresholds are `t2 = T_med` and `t3 = T_med / 1.35`, in the level's existing `stars` block.
- `m_med_i` is the designer's estimated median per module phase, replaced by playtest medians when they exist.
- Example: phases of 60 s + 75 s + 90 s with 2 banners → T_med = 228 s; t2 = 228 000 ms, t3 ≈ 169 000 ms.

## Edge Cases

- **`until` met in the same tick as a fail.** Completion wins. The rule is generous and deterministic.
- **Phase ends with a piece in the air.** The piece lands first, then the banner plays. Pieces never spawn during the banner.
- **`carry: keep` leaves the board too full for the next phase** (for example, a tall tower before a bridge). The validator requires `shift` or `clear` when consecutive modules declare conflicting board zones. At runtime, a top-out uses the normal rescue.
- **An overlay listed for a phase with no primary.** The validator rejects it.
- **Incompatible overlay or module** (for example, `rising_hazard` with `dig_down`). The validator rejects it with no silent drop.
- **The board is smaller than a module requires, or smaller than 8×8.** The validator rejects it.
- **`route_runner` path sealed by the player's own walls.** The mascot idles with a "?" bubble until a path exists. Paths are never forced open. If `t_mg` exists, the timer keeps running.
- **`boss_hp` stalemate.** The boss never destroys row 0, so the player can always build and clear.
- **`fort_siege` tiny-fort exploit.** Prevented by `fort_min_cells` padding (F5).
- **Stalling in hazard modules.** `rising_hazard`, `crumble_floor` and fuses run on timers, so waiting always loses.
- **Unlucky seed.** The Piece Set bag guarantees shape variety, and Retry rerolls the seed.
- **Legacy level with both `goal` (non-`modules`) and `modules`.** The validator rejects it. A level uses one or the other.
- **Tournament: every human leaves.** The round is abandoned with no result. Bots never finish a round alone.
- **Tournament: a 1-human tournament.** This is allowed (practice). All other seats are bots, and the seed rules are unchanged.
- **Tournament: disconnect mid-round.** A bot takes over the seat at its current state (rule 4). If the human reconnects within `rejoin_ms` (30 000), they take the seat back at the bot's state.
- **App suspended.** The game pauses (in tournaments, the local seat pauses and the host runs that seat with a bot until resume). On resume there is a 3-second countdown.

## Dependencies

| System / doc | Direction | Contract |
|---|---|---|
| `level-data-definition.md` | extends | Adds the `modules` array, `goal.type: "modules"`, `carry`, and the phase/overlay schema; that doc must add them |
| Level Goals (`level-goals-fail-states.md`) | wraps | Legacy goals become modules via `legacy_goal` (W1–W3); fail handling stays the same |
| Rule library (`assets/data/rules/*.json`) | requires | Modules compose existing rule ids; the `rules` array stacks with modules |
| Module data (`assets/data/modules/*.json`) | **new** | One file per module: params, ranges, board needs, compatible overlays, skins |
| Piece Spawner | requires | Attempt seed (campaign); shared `round_seed` (tournament) |
| Campaign catalog (`assets/data/campaign/catalog.json`) | unchanged | No new stages; levels gain modules in place |
| Economy / stars | unchanged | Stars from the level's `stars` block only |
| `tournament-minigames.md` contract | requires | MG37–MG50 obey rules 1–13 |
| `mode-minigame-randomizer.md` | provides to | MG37–MG50 join the pool; unlock rule 2 above |
| Tournament Flow / Local Multiplayer | requires | Seat filling, disconnect takeover, shared seed |
| Bot player (**new**) | requires | Plays any module at `bot_skill` (F2); lead-programmer to scope |
| `src/game/minigames/` | refactor | Module code is shared by campaign phases and tournament templates (MG17 maze view reused) |
| HUD / UX | requires | Phase banner, phase progress pips, per-module meters (balance, altitude, boss HP, fort %, fuse) |
| level-designer | provides plan | Per-level params using the biome plan and F3 |
| narrative-director / art-director | provides intent | Skin names are working titles; the mockups are mood references |

Each linked doc needs a back-reference, and `systems-index.md` needs an entry. Both are flagged for the producer.

## Tuning Knobs

All values live in `assets/data/modules/<id>.json` (module defaults and ranges), the level's `modules[].params`, and `assets/data/tournament/bots.json` (F2). Nothing is hardcoded.

| Knob | Category | Default | Safe range | Effect / rationale |
|---|---|---|---|---|
| `phase_banner_ms` | Feel | 1 500 | 800–2 500 | A breath between phases without breaking flow |
| `max_overlays_per_phase` | Gate | 2 | 1–3 | Readability cap |
| Max phases per level | Gate | 3 (4 for Carnival L10 only) | 1–4 | Keeps level length 2–5 min |
| `s_p` per param | Curve | per module file | ±0–0.15 | Ramp across a biome (F3) |
| `hard_mult` | Curve | 1.25 | 1.1–1.5 | Hard track pressure |
| `diff_base` easy / normal / hard | Curve | 0.30 / 0.55 / 0.80 | 0.2–0.9 | Tournament bot strength |
| `jitter` | Feel | 0.10 | 0–0.2 | Bots feel distinct |
| `rejoin_ms` | Gate | 30 000 | 10 000–60 000 | Reconnect window |
| `tilt_max`, `s_fail`, `t_grace`, `topple_penalty` | Feel | 12°, 0.15, 1.5 s, 2 | 6–18°, 0.05–0.3, 0.5–3 s, 0–4 | Balance drama vs fairness |
| `build_phase_ms`, `splash_cells`, `fort_min_cells` | Gate / Curve | 40 000, 1, 12 | 25 000–60 000, 0–2, 8–20 | Fort pacing |
| `climb_step_ms`, `climb_reach`, `r` | Feel / Curve | 500, 1, 0.08 | 300–800, 1–2, 0.04–0.15 | Climb vs hazard |
| `v_base`, `boost`, `hole_drag` | Feel | 1.0, 0.35, 0.6 | 0.5–1.5, 0.2–0.6, 0.3–0.9 | Race feel |
| `walker_step_ms` | Feel | 600 | 400–900 | Bridge pace |
| `attack_period_ms` (boss) | Curve | 7 000 | 4 000–12 000 | Boss pressure |
| `fuse_ms`, `ring_bonus_ms` | Gate | 45 000, 8 000 | 30 000–60 000, 4 000–12 000 | Defuse tension |

## Acceptance Criteria

**Functional (automated, `tests/unit/level_modules/`, `tests/integration/level_modules/`):**

1. [U] A level with 3 primary modules runs them in phase order. The level completes only when phase 3's `until` is met.
2. [U] An overlay runs only during its listed phases and stops when they end.
3. [U] `carry` values `keep`, `clear` and `shift` produce the expected board state at a phase start.
4. [U] The validator rejects each case listed in Edge Cases: an incompatible overlay, an undersized board, `goal` + `modules` together, a primary-less overlay phase, and conflicting zones without `shift` or `clear`.
5. [I] Every existing level JSON without `modules` loads as `legacy_goal` and plays as before (regression across all 11 biomes).
6. [U] Two campaign attempts produce different piece sequences. In a tournament round, every seat (bots included) receives the identical sequence.
7. [U] F2 gives 0.58 for normal with u = 0.8. F3 gives `gap_cells` = 6 for the worked example. F4, F5 and F6 match their examples.
8. [I] A tournament with 1 human and 3 bots completes. A mid-round disconnect hands the seat to a bot, and rejoining within `rejoin_ms` hands it back.
9. [I] MG37–MG50 pass the contract checks and appear in the Randomizer only after their module's first campaign appearance is cleared.
10. [I] Stars and rewards for a module level come only from the level's `stars` block. No module grants currency.
11. Each biome's level using a module for the first time has a retained screenshot in `production/qa/evidence/`.

**Experiential (playtest, at least 6 players, phone):**

12. At least 80% can say what the new phase wants within 5 s of the phase banner.
13. Multi-phase levels have a median length of 2–5 min. Fewer than 15% of fails happen in the first 5 s of a phase (that would mean the transition is unfair).
14. At least 70% say module levels "feel more varied" than single-goal levels, and fewer than 10% say they are "confusing".
15. In tournaments, at least 75% of players recognise an MG37–MG50 round from the campaign without reading the card.
