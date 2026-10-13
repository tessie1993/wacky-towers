# Campaign Minigames ("Party Stops")

> **Status**: Designed (autonomous run, 2026-10-13); awaiting design review and playtest
> **Author**: game-designer
> **Extends**: `tournament-minigames.md` (MG1–MG15 contract), `party-minigames-wave2.md` (MG22–MG36), `arcade-pack.md`, `mode-minigame-randomizer.md`
> **Adds**: minigames MG37–MG50, and 22 campaign Party Stop stages (2 per biome)
> **Sources**:
> - The user's mockups `assets/art/reference/minigame_mockups/mockup_01–04, 11–13, 16.jpg` (viewed); the other 12 sheets were not viewed and are known only from the coordinator's concept list
> - The user's references `party_versus_ref.jpg` and `party_modes_ref.jpg`
> - Genre knowledge (no live web research)
>
> **Pillar note**: the falling block stays the star. Every mockup concept is adapted so the player's verb is dropping, rotating or sliding Piece Set shapes. Mascots act on the blocks you place; you never steer the mascot directly.

## Overview

Party minigames exist today only in tournaments. This system puts them into the campaign as **Party Stops**: two optional side stages per biome (22 in all). Each one is a minigame with a biome theme, played solo against 1–3 bots, a boss or a score target, and rated 1–3 stars on the player's own metric. Party Stops branch off the main chain. They never gate it and are never harder than their neighbouring main levels. This GDD also adds 14 new minigames (MG37–MG50), adapted from the user's mockup sheets to falling 3D blocks. Every one is built mostly from existing rule ids (`assets/data/rules/*.json`), goal types and minigame templates. All five of the user's named concepts are among them (Block Bridge Dash, Wobble Builders, Island Claim Battle, Speed Stack, Block Racers). Mockup concepts that share a verb are merged into one minigame and appear as biome **skins** (for example, Cake Stackers and Fruit Stack are skins of Wobble Builders). The new minigames also join the tournament pool through the existing minigame template contract.

## Player Fantasy

"A breather and a giggle between puzzles." After a few careful main levels, the map shows a confetti-ringed tent. Inside, the wizard races the tiki across a lava gap on blocks you dropped. Or the pirate's catapult lobs your own pieces at the robot's fort. Or the penguin clings to an iceberg you keep patching. The rules are clear within five seconds, a round lasts 60–150 seconds, and a bad run costs nothing. Each stop is a *preview* of party mode: you learn the minigame alone, then recognise it in tournaments with friends.

- **MDA targets**: **Challenge** (primary, through quick mastery), **Fantasy** (biome skins and cast rivals), **Fellowship by proxy** (bots that taunt, send things and celebrate).
- **SDT**: *Competence* (short rounds, readable star bar, instant retry); *Autonomy* (stops are optional and chosen freely); *Relatedness* (the cast and biome mascots act as rivals and allies).
- **Flow**: Party Stops are the **release** in the sawtooth curve. They come after the build-up of levels 1–3 and 5–7.

## Detailed Design

### Research distillation (mockup + genre → block verb)

| Mockup concept(s) | Genre lesson | Wacky Towers adaptation |
|---|---|---|
| Bridge Bashers, Bridge Dash, Meadow Mayhem, Volcano Dash | Mario Party / Fall Guys races where everyone sees everyone | Your drops become the bridge your mascot walks on (MG37) |
| Tumbling Towers, Cake Stackers, Fruit Stack, Wonky Builders | Tricky Towers: humour in near-collapse | Tower on a tilting seesaw with a Balance meter (MG38) |
| Neon Splat, Island Claim | Territory painting you can read at a glance | Landed cubes paint the floor (MG39) |
| Speed Stack | Tetris sprint | Clear N layers fastest (MG40) |
| Rolling Rumble, Balloon Race, Runaway Rail Rush, Glacier Rush, Galactic Grab | Kart racing; collecting stars on the track | Your drops pave the track ahead of your kart (MG41) |
| Avalanche Ascent, Summit Scramble, Frenzy Footholds, Jungle Vine Ascent, Candy Climb, Pyramid Climber | Climb away from a rising hazard | Drops become footholds; the mascot auto-climbs (MG42) |
| Fort Frenzy, Fort Blast, Shatter Shootout, Castle Siege Crash, Candy Crushers | Artillery games and siege toys | Build a fort, then lob pieces at the rival's fort (MG43) |
| Digging Frenzy, Rubble Rumble | Mining and dig-down | Layer clears dig down to reveal gems (MG44) |
| Clockwork Conveyor | Overcooked-style conveyor pressure | Catch pieces off belts into colour hoppers (MG45) |
| Kraken Blockade, Boss Bash | A boss with a health bar (Pummel Party) | Build a wall and fire clears at a boss (MG46) |
| Chroma Sky Climb, Cosmic Climb | A path ascent with a stability meter and wind | Build a stair path through gusts (MG47) |
| Maze Heist, Neon Maze, Herd Sheep, Coral Conduit | Route puzzles and guard stealth (Monument Valley path logic) | Drops become walls or floor that route a mascot (MG48) |
| Bomb Defuse, Potion Puzzle | Colour matching under a fuse (Puyo) | Fill colour rings on a turntable before the fuse ends (MG49) |
| Slippery Sumo Iceberg, Bumper Battle | Sumo shove-off | Sliding pieces shove rival mascots off a floe (MG50) |

The two concepts not covered as MG37–MG50 are reused as existing minigames: **Lava Escape** (MG13 skin) and **Treasure** pulls (MG33).

### New minigames MG37–MG50

Standing kinds and hooks follow `tournament-minigames.md` rules 4–5 (S = Send, St = Steal, Sh = Shared). In the "Reuses" column, "Reuses" means existing rule ids, goals or templates. "New" lists the only new code each one needs.

| id | Name | Verb | Rule (one line) | t_mg | Standing / star metric | Reuses | New |
|---|---|---|---|---|---|---|---|
| MG37 | Block Bridge Dash | Span the gap | Drop pieces to bridge a chasm while the hazard rises; your mascot walks forward over any solid cells | 120 s | race_progress; finish time s (lower) | MG6 walkway, `lava_rise`, `build_race`, `speed_bump` (Speed Boost) | Walker steps 1 cell when the next cell is solid |
| MG38 | Wobble Builders | Balance high | Stack on a seesaw or spring platform that tilts toward your centre of mass; tallest stable tower wins | 90 s | height cells | MG5 physics, `wobble`, `bounce_pad`, `height` goal | Balance meter + F4 tilt |
| MG39 | Island Claim Battle | Paint territory | Landed cubes paint the floor below them your colour; landing on rival cells flips them | 90 s | % cells owned | `chameleon_paint`, `confetti_fill`, `fill_shape` scan | Ownership map |
| MG40 | Speed Stack | Sprint-clear | Clear N layers as fast as possible | 150 s cap | race_progress; time s (lower) | `clear_n`, `stopwatch` | None (template only) |
| MG41 | Block Racers | Pave and race | The board scrolls as a road (`conveyor`); clears boost your kart, holes slow it, star coins sit on the road | 120 s | race_progress; finish time s (lower) | `conveyor`, `mill_belt`, `speed_bump`, `star_coins`, `balloon` | Kart speed F7 |
| MG42 | Summit Scramble | Build footholds | A hazard rises (lava, avalanche or silt); your mascot climbs onto the highest reachable block you dropped | 120 s | height cells reached | `lava_rise`, `rising_silt`, `snowball`, `vines`, MG13 | Auto-climb F6 |
| MG43 | Fort Blast | Build, then lob | 40 s building a fort from falling pieces, then alternate catapult lobs of your next piece at the rival fort | 120 s | destruction % of the rival fort | `anvil_drop`, `crumble_tiles`, MG22 aim/spin | Fort-damage tally F5 |
| MG44 | Digging Frenzy | Dig down | Each layer clear removes a layer and drops the board 1 level, revealing gems in the dug cells | 120 s | depth (layers dug) | `dig_rescue` goal, `clear_n`, `angle_gem`, `mud` | None (template only) |
| MG45 | Clockwork Conveyor | Sort to hoppers | Pieces arrive on belts; drop each into the hopper of its colour before it falls into the lava | 90 s | pieces sorted | `conveyor`, `mill_belt`, MG9 Speed Sort colours | None (template only) |
| MG46 | Kraken Blockade | Wall and fire | A boss's tentacles smash cells off your wall; each layer you clear fires a cannon hit on the boss's HP | 150 s | boss-defeat time s (lower) | `bonk_boss` goal, `climber_boss`, `storm_bolt` | Tentacle telegraph pattern |
| MG47 | Chroma Sky Climb | Stair to the stars | Build a rising stair path through gusts; your mascot walks up; same-colour steps give a bonus | 150 s | race_progress; finish time s (lower) | `gust`, `rainbow_piece`, `build_race`, `height` goal | None (template only) |
| MG48 | Maze Heist | Route the runner | Your drops become walls and floor; your mascot pathfinds to the goals (keys, sheep to the pen, pearls along a conduit) and avoids a guard | 120 s | goals reached | `key_stamp`, `fog`, `mascot_paw`, MG17 maze view (code) | Grid flood fill + guard patrol |
| MG49 | Bomb Defuse | Fill the rings | A turntable board with a fused bomb at its centre; completing a colour ring cuts a wire and adds fuse time | 90 s | rings completed | `countdown_bomb`, `colour_pop`, `turntable` | Ring detector |
| MG50 | Slippery Sumo | Shove off | Shared ice floe: landed pieces slide (`ice_slide`) and push mascots; be the last mascot on | 90 s | alive_time s | `ice_slide`, `piston_punch`, `magnet_pull`, `thin_ice` | Mascot shove impulse |

**Tournament use.** Every MG37–MG50 template carries the full contract: `standing_metric`, `interaction_hook`, `item_whitelist` and an optional twist. That puts them in the Randomizer pool. Hooks:

| Minigame | Hook |
|---|---|
| MG37 | S: Crumble Plank |
| MG38 | S: Gust |
| MG39 | Sh: the floor |
| MG40 | S: Grey Garbage |
| MG41 | S: Oil Slick |
| MG42 | S: Rockfall |
| MG43 | St: the shots |
| MG44 | Sh: the gem vein |
| MG45 | S: Jam Belt |
| MG46 | Sh: the boss (co-op in tournaments) |
| MG47 | S: Gust |
| MG48 | S: Alert Guard |
| MG49 | S: Fuse Burn |
| MG50 | Sh: the floe |

**Gap noted.** MG16–MG21 exist in code (`rules_a.gd`, `rules_b.gd`) but have no design table in any GDD. MG48 reuses MG17's maze view; confirm this with lead-programmer.

### Party Stop rules

1. **Map placement.** Each biome has two Party Stop nodes, `P1` and `P2`, branching off the chain. `P1` unlocks when `<biome>_03` is cleared and `P2` when `<biome>_07` is cleared. Neither stop unlocks anything on the main chain, the bonus or the hard tracks.
2. **Data.** Each Party Stop is a Level Data file at `src/levels/<biome>/<biome>_party_<n>/<biome>_party_<n>.json` with an extra block:
   - `"minigame": { "id", "skin", "theme_rules": [...], "opponents": {"kind": "target"|"bots"|"boss", "count"}, "bot_skill", "metric", "metric_dir": "higher"|"lower", "stars": {"t1","t2","t3"}, "t_mg_ms" }`
   - Catalog entries gain `"party_stop": true` and `"after": "<level_id>"`.
   - Shared globals live in `assets/data/campaign/party_stops.json`.
3. **Board.** The minimum is 8×8, as everywhere. Race, arena and fort stages may be wider. Size comes from the template data.
4. **Pieces.** The piece order is random for each attempt (F1). The player and all bots share that attempt's `round_seed`, so the challenge is identical for everyone. Sends change only the target's own copy (contract rule 3).
5. **Cast.** Bots and allies are drawn from the wizard, pirate, astronaut, robot, penguin, alien, tiki, the biome mascots, and generic fantasy archetypes (knight, elf, dwarf). No franchise characters.
6. **Bots** play the same template at `bot_skill` (F2). They use the template's hook at the player on the contract's charge rules, scaled by `bot_send_scale` (F3). Bots have no items.
7. **Stars.** Stars come only from the player's own metric, compared against `t1/t2/t3` (F8). Placing against bots is shown and celebrated but **never decides stars**.
   - **Race stages** (lower-is-better time) give 0 stars if the player does not finish within `t_mg`.
   - **Alive-time stages** stop the clock at `t_mg`.
8. **No-gate guarantee.** Party Stop stars are **bonus stars**. Every star-count gate (biome, bonus and hard-track unlocks) must be reachable with zero Party Stop stars.
9. **Difficulty cap.** A stop's `difficulty` must be ≤ that of the main level before it (`stop_tier = tier(after)`). Its 1-star threshold targets ≥ 90% first-session completion (F8 `k1`).
10. **Retry and fail.** Retry is instant with a new attempt seed. There are no lives, energy or cost. The lives hearts in the mockups map to the template's existing fail state (for example, mascot falls); they are not a campaign resource.
11. **Items and twists.** Items are off. The theme comes from `theme_rules` (at most 2 ids from the template's compatible list). These count as "theme", not against the contract's 1-twist cap.
12. **Tutorial.** On the first visit, a single 3-second animated card shows the verb. There is no other tutorial.

### Placement: the 22 Party Stops

`P1` comes after level 03 (tier 3); `P2` comes after level 07 (tier 7). Thresholds are listed as t1 / t2 / t3. "(lower)" marks a lower-is-better time. All values are **initial estimates** from F8; nothing has been playtested yet.

| Biome | Slot (after) | MG | Skin / theme twist | Opp. | Star metric | t1 / t2 / t3 |
|---|---|---|---|---|---|---|
| Meadow | P1 (meadow_03) | MG40 Speed Stack | Hay Bale Sprint: clear 6 layers, gentle `fall.g0` | target | time s (lower) | 150 / 100 / 70 |
| Meadow | P2 (meadow_07) | MG48 Maze Heist | Herd Sheep: drops are fences; sheep to the pen, `dandelion_puff` | 1 bot | sheep penned | 4 / 7 / 10 |
| Candy | P1 (candy_03) | MG38 Wobble Builders | Cake Stackers: `frosting` makes landings stick | 1 bot | height cells | 8 / 12 / 16 |
| Candy | P2 (candy_07) | MG43 Fort Blast | Candy Crushers: gingerbread forts, `gumdrop_hail` | 1 bot | destruction % | 35 / 55 / 75 |
| Ice | P1 (ice_03) | MG42 Summit Scramble | Avalanche Ascent: `snowball` rolls down | 2 bots | height cells | 6 / 10 / 14 |
| Ice | P2 (ice_07) | MG50 Slippery Sumo | Iceberg Sumo: `thin_ice` cracks | 3 bots | alive s (of 90) | 40 / 65 / 90 |
| Underwater | P1 (underwater_03) | MG48 Maze Heist | Coral Conduit: route pearls along a conduit, `bubble` | target | pearls delivered | 2 / 3 / 4 |
| Underwater | P2 (underwater_07) | MG46 Kraken Blockade | Kraken Blockade: tentacles, `crab_claw` | boss | defeat time s (lower) | 150 / 115 / 90 |
| Lava | P1 (lava_03) | MG37 Block Bridge Dash | Volcano Dash: `lava_rise`, Speed Boost pickup | 1 bot | finish time s (lower) | 110 / 90 / 70 |
| Lava | P2 (lava_07) | MG13 Floor Is Lava | Lava Escape: `ember` sparks | 2 bots | alive s (of 150) | 60 / 100 / 140 |
| Forest | P1 (forest_03) | MG33 Tower Pull | Treasure Pull: `woodpecker_knock` jolts | target | pulls | 6 / 10 / 14 |
| Forest | P2 (forest_07) | MG38 Wobble Builders | Fruit Stack on a treetop seesaw, `vines` | 2 bots | height cells | 10 / 14 / 18 |
| Cave | P1 (cave_03) | MG44 Digging Frenzy | Rubble Rumble: `mud`, crystal gems | target | layers dug | 4 / 7 / 10 |
| Cave | P2 (cave_07) | MG48 Maze Heist | Crystal Heist: a sleeping golem guard, 3 keys, `fog` | 2 bots | keys + gems | 3 / 5 / 7 |
| Clockwork | P1 (clockwork_03) | MG45 Clockwork Conveyor | Gear Belts: `rusty_hinge` stutters | target | pieces sorted | 12 / 20 / 28 |
| Clockwork | P2 (clockwork_07) | MG49 Bomb Defuse | Clock Bomb: `turntable` + `piston_punch` | 1 bot | rings completed | 2 / 4 / 6 |
| Neon | P1 (neon_03) | MG39 Island Claim Battle | Neon Splat: paint-splat landings | 1 bot | % owned | 35 / 45 / 55 |
| Neon | P2 (neon_07) | MG32 Whack-a-Block | Arcade Whack: `decoy_bombs` | 2 bots | points | 20 / 32 / 44 |
| Celestial | P1 (celestial_03) | MG47 Chroma Sky Climb | Rainbow Tower: `gust` cloud, `rainbow_piece` | 1 bot | finish time s (lower) | 140 / 110 / 85 |
| Celestial | P2 (celestial_07) | MG41 Block Racers | Galactic Grab: space track, collect stars | 3 bots | finish time s (lower) | 120 / 95 / 75 |
| Carnival | P1 (carnival_03) | MG35 Plinko Drop | Prize Plinko: Tumble Fair jackpot | 2 bots | points | 300 / 550 / 800 |
| Carnival | P2 (carnival_07) | MG41 Block Racers | Balloon Race: `balloon` lift over gaps | 3 bots | finish time s (lower) | 120 / 95 / 75 |

**Coverage.**
- All 14 new minigames appear at least once (18 stops). MG38 and MG41 appear twice; MG48 appears three times, as Herd Sheep, Coral Conduit and Crystal Heist.
- 4 stops use existing minigames: MG13, MG32, MG33, MG35.
- Every mockup concept named by the coordinator appears as a minigame or a skin. Two exceptions: Potion Puzzle and Pyramid Climber are listed as alternate skins for MG49 and MG42 in tournaments.
- Stops alternate between target, bot and boss stages, and bot count grows across the campaign.

## Formulas

**F1 — Attempt seed (fairness).**
`attempt_seed = hash(stage_id, profile_attempt_counter)` and `round_seed = attempt_seed`. The player and all bots draw pieces from `round_seed`. Bot decisions use `hash(round_seed, bot_index)`. The counter goes up by 1 on every start, so each retry is different.

**F2 — Bot skill.**
`bot_skill = clamp(b0 + b_tier·(stop_tier − 1) + b_biome·biome_index, 0, b_max)`
- `stop_tier`: 3 (P1) or 7 (P2). `biome_index`: 0 (meadow) to 10 (carnival).
- Defaults: `b0` = 0.25, `b_tier` = 0.05, `b_biome` = 0.02, `b_max` = 0.80.
- Examples: Meadow P2 = 0.25 + 0.30 + 0 = **0.55**; Ice P1 = 0.25 + 0.10 + 0.04 = **0.39**; Carnival P2 = 0.75.
- The skill sets reaction delay `lerp(1 200, 350, skill)` ms and placement error `lerp(1.5, 0.2, skill)` cells.
- MG46 boss pressure uses the same value: tentacle period = `lerp(9 000, 5 000, skill)` ms.

**F3 — Bot Sends.**
Contract F1 charge × `bot_send_scale` (default 0.75). Bots never Send within `bot_send_grace_ms` (default 10 000) of round start.

**F4 — Balance (MG38).**
`S = clamp(1 − |x_com − x_base| / (w_base/2), 0, 1)`
- Tilt = `tilt_max·(1 − S)·sign(x_com − x_base)`, with `tilt_max` = 12°.
- The tower topples if `S < s_fail` (0.15) for longer than `t_grace` (1.5 s). Height then resets to the last stable height − `topple_penalty` (2).
- Example: on an 8-cell base with the COM 3 cells off-centre, S = 0.25 → amber meter, 9° tilt.

**F5 — Fort damage (MG43).**
`destruction% = 100 · cells_removed / cells_at_build_end`. A lobbed piece removes the cells it hits plus `splash_cells` (1) beyond them. Cells left unsupported fall and count as removed.
- Example: a 40-cell fort that loses 22 cells → 55%.
- If the fort has fewer than `fort_min_cells` (12) cells, the shortfall is padded with free stone blocks, so the percentage cannot be gamed by a tiny fort.

**F6 — Auto-climb (MG42).**
- Each `climb_step_ms` (500), the mascot steps to an adjacent column if that column's top is ≤ `climb_reach` (1) cells higher.
- The hazard height is `h(t) = h0 + r·t`, with `h0` = 0 and `r` = 0.08 cells/s.
- The mascot is out when `h(t) ≥ its feet`.
- Example: at t = 100 s, the hazard is at 8 cells.

**F7 — Kart speed (MG41).**
`v = v_base·(1 + boost·clears_recent)·(1 − hole_drag·hole_frac)`, with a minimum of 0.25.
- Defaults: `v_base` = 1.0, `boost` = 0.35, `hole_drag` = 0.6.
- `clears_recent` is the number of clears in the last 5 s. Each star coin collected adds 0.2 s of boost.

**F8 — Star thresholds.**
- Higher-is-better metrics: `t_i = round(m_med·k_i)`, with `k1` = 0.6, `k2` = 1.0, `k3` = 1.35.
- Lower-is-better times: `t_i = round(m_med / k_i)`, and `t1` is capped at `t_mg`.
- Required ordering: `t1 < t2 < t3` (higher is better) or `t1 > t2 > t3` (lower is better).
- Example: Speed Stack with an estimated median of 100 s → 167 / 100 / 74; capping t1 gives 150 / 100 / 74, shown as 70 in the table.
- `m_med` is the playtest median. Until that data exists, it is the designer's estimate.

## Edge Cases

- **Race not finished at `t_mg`.** The player gets 0 stars. The result screen shows the progress percentage and offers Retry.
- **Alive stage survived to `t_mg`.** The metric is `t_mg`, which equals t3 where t3 = `t_mg` (Ice P2). This is intended.
- **Player eliminated while bots remain.** The round ends for the player at once. The bots' remaining placings are simulated off-screen.
- **All bots out early** (MG50, MG13). The round continues alone until the player's fail or `t_mg`.
- **Ties with a bot.** Tied places are shared. This has no effect on stars.
- **Unlucky seed** (for example, no flat pieces for MG37). The Piece Set bag guarantees variety, `k1` = 0.6 absorbs bad draws, and Retry rerolls the seed.
- **MG43 tiny-fort exploit.** `fort_min_cells` padding (F5) stops it. Lobs that miss the fort land in the sea and score nothing.
- **MG48 sealed route.** If the player's walls cut every path to the goals, the mascot idles with a "?" bubble. The next landed piece can reopen a path. A path is never forced open automatically.
- **MG42 or MG50 stalling.** The hazard and the crumble run on timers, so doing nothing always loses.
- **MG46 boss.** The boss cannot destroy the bottom layer of the wall, so the player can always build. If time runs out with the boss alive, the stage gives 0 stars and the result shows the boss HP removed.
- **MG49 fuse at 0 with rings still incomplete.** The round ends and the rings completed so far count.
- **App suspended** (phone). The round pauses automatically and resumes with a 3-second countdown. Seeds are unchanged.
- **Invalid data.** The validator rejects:
  - a `theme_rules` id that is incompatible with the template
  - unordered thresholds
  - a board smaller than 8×8
  - a `difficulty` above the neighbouring main level
- **Save migration.** Unlocks are recomputed from cleared levels. A stop whose `after` level has not been cleared is hidden.

## Dependencies

| System / doc | Direction | Contract |
|---|---|---|
| `tournament-minigames.md` (minigame contract) | requires | Template slots, standing, hooks, telegraph; MG37–MG50 obey rules 1–13 |
| `party-minigames-wave2.md`, `src/game/minigames/` | requires | `rules_script`, `s.rng` / `s.attack_rng`, `add_score`, `progress`, `charge_send`; MG17 maze view |
| `mode-minigame-randomizer.md` | provides to | MG37–MG50 join the pool; rule 7 round seed |
| Level Data (`level-data-definition.md`) | extends | New `minigame` block and the `party_stop` / `after` catalog fields |
| Campaign map (`assets/data/campaign/catalog.json`) | extends | Side nodes; star gates exclude bonus stars |
| Rule library (`assets/data/rules/*.json`) | requires | Theme rules per stop; compatibility list per template |
| Level Goals (`clear_n`, `height`, `bonk_boss`, `dig_rescue`) | requires | Reused as `goal_evaluator`s |
| Piece Spawner | requires | A shared `round_seed` for the player and bots |
| Bot player (**new**) | requires | Plays any template at `bot_skill`; lead-programmer to scope |
| HUD / UX | requires | Balance meter, ownership bar, fort HP, boss HP, altitude bar, star bar with t1–t3 ticks |
| Narrative (narrative-director) | provides intent | Stage names are working titles; final names are theirs |
| Art (art-director) | provides intent | Skins listed per stop; the mockups are mood references, not specs |

Each linked doc needs a back-reference to this GDD, and `systems-index.md` needs an entry. Both are flagged for the producer, because this run edited only this file.

## Tuning Knobs

All values live in `assets/data/campaign/party_stops.json` (globals), each stop's `minigame` block, and each MG template. Nothing is hardcoded.

| Knob | Category | Default | Safe range | Effect / rationale |
|---|---|---|---|---|
| `unlock_after_p1` / `p2` | Gate | 03 / 07 | 02–05 / 06–09 | Stops sit at the sawtooth release points |
| `b0` / `b_tier` / `b_biome` / `b_max` | Curve | 0.25 / 0.05 / 0.02 / 0.80 | 0.1–0.4 / 0–0.08 / 0–0.03 / 0.6–0.9 | Bot pressure grows; never feels perfect |
| `bot_send_scale` | Curve | 0.75 | 0.5–1.0 | Solo play is gentler than human versus |
| `bot_send_grace_ms` | Feel | 10 000 | 5 000–20 000 | Lets the player learn before being attacked |
| `k1` / `k2` / `k3` | Curve | 0.6 / 1.0 / 1.35 | 0.5–0.8 / 0.9–1.1 / 1.2–1.6 | 1★ about 90%; 3★ is mastery |
| `t_mg_ms` per stop | Gate | per table | 45 000–150 000 | Short phone rounds |
| `tilt_max`, `s_fail`, `t_grace`, `topple_penalty` (MG38) | Feel | 12°, 0.15, 1.5 s, 2 | 6–18°, 0.05–0.3, 0.5–3 s, 0–4 | Wobble drama vs fairness |
| `build_phase_ms`, `splash_cells`, `fort_min_cells` (MG43) | Gate / Curve | 40 000, 1, 12 | 25 000–60 000, 0–2, 8–20 | Build-vs-blast pacing |
| `climb_step_ms`, `climb_reach`, `r` (MG42) | Feel / Curve | 500, 1, 0.08 | 300–800, 1–2, 0.04–0.15 | Climb pace vs hazard |
| `v_base`, `boost`, `hole_drag` (MG41) | Feel | 1.0, 0.35, 0.6 | 0.5–1.5, 0.2–0.6, 0.3–0.9 | Racing feel; rewards clean rows |
| `walker_step_ms` (MG37) | Feel | 600 | 400–900 | Bridge-walk pace |
| tentacle period range (MG46) | Curve | 9 000–5 000 ms | 12 000–4 000 | Boss pressure |
| `fuse_ms`, `ring_bonus_ms` (MG49) | Gate | 45 000, 8 000 | 30 000–60 000, 4 000–12 000 | Defuse tension |
| Star thresholds per stop | Curve | table | F8 ordering | Re-derive from playtest medians |

## Acceptance Criteria

**Functional (automated, `tests/unit/campaign_minigames/`, `tests/integration/campaign_minigames/`):**

1. [U] GIVEN the same `round_seed`, THEN the player and every bot get identical piece sequences. Two retries differ.
2. [U] F2 gives 0.55 (Meadow P2) and 0.39 (Ice P1). No stop exceeds `b_max`.
3. [I] GIVEN all main levels cleared at 3★ and zero Party Stop stars, THEN every biome, bonus and hard-track gate is open.
4. [U] Stars depend only on the player's metric. A fixed metric gives the same stars whether the player places 1st or last.
5. [U] An unfinished race gives 0★. Alive-time is capped at `t_mg`.
6. [U] The validator rejects all four invalid-data cases in Edge Cases.
7. [U] F4–F7 match their worked examples (S = 0.25; 55%; hazard at 8 cells at 100 s; minimum kart speed 0.25).
8. [I] All 22 stop JSONs load, and the catalog lists exactly 2 stops per biome, each with a valid `after`.
9. [I] MG37–MG50 pass the minigame contract checks (hook present, `t_mg` 30–240 s) and appear in the Randomizer pool.
10. Each player-observable stop has a retained screenshot in `production/qa/evidence/`.

**Experiential (playtest, at least 6 players, phone):**

11. At least 90% earn 1★ within two attempts at each stop; 25% or fewer earn 3★ in their first session.
12. At least 80% can state the rule within 10 s of the round starting.
13. Median round length is 60–150 s, and median retries per 3★ chase are 5 or fewer.
14. At least 70% call Party Stops "a welcome break", and fewer than 10% call a bot "unfair".
15. In MG38 and MG43, at least 4 of 6 testers react aloud at a near-topple or a fort collapse.
