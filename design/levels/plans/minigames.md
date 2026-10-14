# Minigames: building blocks and tournament rounds

> Layer 1 (Play) by the level-design team, 2026-10-14. Layers 2 (In the world), 3 (Art) and 4 (Godot review) refine or replace the first-pass notes below.
> Template and standing rules: `design/levels/plans/README.md`. Quality bar: `.claude/docs/reference-quality-bar.md`.

## How to read this file

**Sources read:** reference boards `assets/art/reference/style/09_minigames_a.jpg` to `12_minigames_d.jpg` (all four viewed); `design/levels/minigame-stages.md`; `design/levels/arcade-pack.md`; `design/gdd/campaign-minigames.md` (the module system, user decisions of 2026-10-13); `assets/data/modules/_framework.json` and `bridge_dash.json`; `src/core/modules/*`; `src/physics/wt_physics_challenge.gd` (13 physics toy-box variants); `assets/data/tournament/templates.json` (MG1 to MG36) and `randomizer.json`; `src/game/minigames/*`; `src/game/modes/wt_tournament_randomizer.gd`.

**What a minigame is here.** The user decided on 2026-10-13 (`campaign-minigames.md`) that minigames are **modules**: building blocks that run as phases inside normal campaign levels and are reskinned per biome. The same module code is also a **head-to-head tournament round**. This file follows that decision. The separate `<biome>_mgN` side nodes proposed in `minigame-stages.md` are superseded on placement. Its board sketches are still useful as first layouts.

**Shared rules for every minigame**
- **Pillar.** The player only moves, rotates, drops or (in a few modules) releases or slides pieces. Mascots, karts, walkers and bosses react to what the player builds. No minigame adds a new avatar control scheme.
- **Controls.** Standard drop controls: move, rotate, soft drop, hard drop, hold (where the level enables it). On touch these are the same swipe and tap set as campaign levels. Extra inputs are listed per minigame. There are only two: *release* (Wobble Plate) and *fire* (Catapult Keep, Knockdown Tower).
- **Board.** 8x8 or bigger in every campaign use (`_framework.json` `min_board_side: 8`). The playable area also meets 8x8 unless the minigame says otherwise and flags it for the user.
- **Randomness.** Pieces are random on every attempt (`attempt_seed = hash(level_id, attempt_counter)`, GDD F1). Hazard timing, boss attacks and layouts that vary per attempt draw from the same stream. Nothing is a fixed list.
- **Tournament.** 2 to 4 seats with mirrored boards, or one shared arena where marked. Every seat uses the same `round_seed`, so all players get the same pieces and hazards in one round. Bots fill empty seats (GDD F2). A minigame unlocks for tournaments once its first campaign appearance has been cleared.
- **Text.** All text is live UI. Tutorial bubbles are 12 words or fewer, and each minigame proposes one below. No baked text, no beige panels.
- **Naming.** The boards are layout and idea references only. **No board title is used as a minigame or level name in this file.** Existing violations are listed under "Naming fixes" at the end.

**Status legend:** EXISTS = in data or code today. PARTIAL = some pieces exist. MISSING = design only.

## Summary

| # | id (proposed module id) | Name | Verb | Debut biome (see progression.md) | Tournament round | Status |
|---|---|---|---|---|---|---|
| 1 | `gap_runner` (`bridge_dash`) | Gap Runner | span a gap for a walker | Meadow | yes | PARTIAL: data + pure layout/reach/walker code |
| 2 | `wobble_plate` (`balance_plate`) | Wobble Plate | stack high on a tilting plate | Candy | yes | MISSING (rules `wobble`, `tilt_plate` exist) |
| 3 | `foothold_climb` (`summit_climb` + `rising_hazard`) | Foothold Climb | build steps ahead of a rising hazard | Ice | yes | MISSING (rules `lava_rise`, `rising_silt`, `snowball`, `vines` exist) |
| 4 | `catapult_keep` (`fort_siege`) | Catapult Keep | build a keep, then lob at the rival | Candy | yes | MISSING (rules `anvil_drop`, `crumble_tiles` exist) |
| 5 | `deep_dig` (`dig_down`) | Deep Dig | clear layers to tunnel down | Cave | yes | PARTIAL: goal `dig_rescue` exists |
| 6 | `sorting_belt` (`conveyor_sort`) | Sorting Belt | drop pieces onto matching belts | Clockwork | yes | MISSING (rules `conveyor`, `mill_belt`, `colour_pop` exist) |
| 7 | `giant_bonk` (`boss_hp`) | Giant Bonk | wall up, clear layers to hit a boss | Underwater | yes (shared boss) | PARTIAL: goal `bonk_boss`, rule `climber_boss` exist |
| 8 | `sky_steps` (`stair_path`) | Sky Steps | build a rising stair for a walker | Celestial | yes | PARTIAL: reuses `gap_runner` reach code |
| 9 | `sneak_route` (`route_runner`) | Sneak Route | lay a path for a runner past a guard | Meadow (herd form) | yes | PARTIAL: MG17 maze view, rule `key_stamp` exist |
| 10 | `fuse_rings` (`ring_defuse`) | Fuse Rings | fill rings before fuses burn | Neon | yes | PARTIAL: rule `countdown_bomb` exists |
| 11 | `floe_footing` (`floe_survive`) | Floe Footing | keep a mascot on a shrinking floe | Ice | yes (shared floe) | MISSING (rules `ice_slide`, `thin_ice`, `piston_punch` exist) |
| 12 | `paver_rally` (`road_race`) | Paver Rally | pave a road ahead of a kart | Lava | yes | MISSING (rules `conveyor`, `star_coins` exist) |
| 13 | `splat_claim` (`paint_claim`) | Splat Claim | claim floor colour against a rival | Forest | yes (shared floor) | MISSING (rules `chameleon_paint`, `confetti_fill`, `goo_spread` exist) |
| 14 | `knockdown_tower` (NEW) | Knockdown Tower | your clears fire shots at a shared tower | Pirate | yes (shared tower) | MISSING, new proposal |
| 15 | `gate_squeeze` (NEW) | Gate Squeeze | shape your top layer to pass a sweeping wall | Underwater | yes | PARTIAL: MG1 wall-fit logic exists in tournament code |
| 16 | `domino_run` (physics toy-box) | Domino Run | topple a physics chain onto a bell | Clockwork bonus | yes (physics round) | PARTIAL: `domino_chain` variant exists in physics challenge |

`clear_layers` ("sprint clear") from the GDD catalogue is not listed as its own minigame. It is the base campaign verb with a timer, so it stays a wrapper phase (`legacy_goal` with `stopwatch`) and does not count toward variety.

---

### gap_runner: Gap Runner

**Play**:
- **Rules.** Two pillars stand at the board edges with an open pit between them. A biome mascot waits on the near pillar. Drop pieces to build a walkable surface from pillar to pillar. Neighbouring columns may differ by at most `step_max` (1) layer. When an unbroken path exists and stays intact for `hold_ms` (500 ms), the mascot walks across at `walk_ms` (250 ms) per cell. If a piece breaks the path mid-walk, the mascot stops at the last intact cell and waits.
- **Controls.** Standard drop controls only.
- **Win / lose.** Win when the mascot reaches the far pillar. Lose on top-out, or on the level timer when one is set. With the `rising_hazard` overlay, also lose when the hazard touches the mascot.
- **Length.** Campaign phase 45 to 75 s. Tournament round 120 s (GDD MG37).
- **Players.** 1 in campaign; 2 to 4 in tournaments, on mirrored lanes.
- **Twist and pressure.** Clears are off (`clear.enabled: false`), so every misplaced cube stays. Speed and tidiness pull against each other: a flat bridge is fast to walk, but a tall ramp is easier to build. The optional `pace_mascot` overlay adds a ghost rival as visual pressure. It never fails the level.
- **As a level block.** Phase 1 of a chain, for example span, then climb (`carry: shift` turns the bridge into the foot of the climb). Scale with `gap_cells` from 4 to 8, then `step_max` held at 1, then add `gust_wind`. First appearance is solo in Meadow.
- **As a tournament round.** Race progress = the walker's share of the path (`WtSpanReach` progress 0 to 1000). Hook: Send "Crumble Plank" (removes one bridge cell on the target's board, telegraphed for 1 s).
- **Tutorial bubble:** "Build a path so Pip can walk across." (8 words)

**Modules and data**:
- EXISTS: `assets/data/modules/bridge_dash.json` (params `gap_cells`, `pillar_cells`, `pillar_height`, `lane_z`, `step_max`, `walk_layer_min`, `walk_ms`, `hold_ms`; overlays `rising_hazard`, `pace_mascot`, `gust_wind`; 11 skins). `src/core/modules/bridge_dash_layout.gd` (pure board builder), `span_reach.gd` (BFS reachability and progress), `span_walker.gd` (clock-injected walker state machine with snapshot and restore). Tournament MG6 "Mascot Bridge Race" runs in `rules_b.gd` using `WtMinigameGeometry.bridge_path`.
- MISSING: anything that calls these classes. Nothing references `WtBridgeDashLayout` or `WtSpanWalker` outside `src/core/modules/`. Also missing: the `modules` array loader and phase runner; goal type `span` in `assets/data/knobs/goals.json` (`goal.type` choices end at `bake_oven`); `design/gdd/modules-framework.md`, which the data and code both cite but which does not exist; unit tests under `tests/unit/` (no span or bridge tests found); the MG37 template. The MG6 board (8x3) is below the 8x8 rule for campaign reuse.
- Proposed data change: `bridge_dash.json` `title` "Bridge Bashers" becomes "Gap Runner" (board name, see Naming fixes). Keep id `bridge_dash` for code stability, or alias it to `gap_runner`.

**In the world** (first pass): a broken footpath, ravine or lava rift on each island. The mascot needs to reach something on the far side, such as a picnic, a lost egg or a key. The bridge is how the island gets mended.

**Art** (first pass): cliff pillars in biome material, with the pit reading clearly as empty (water, cloud or lava glow). A footprint trail lights each reachable cell. The walker carries a small biome prop. A HUD progress ribbon across the top (live UI). Ref board 09 (top left) for the cliff-and-river composition, and 10 (top left) for floating-island pillars. Do not copy the board's heat meter or labels.

**Godot review**: _(layer 4: pending)_

---

### wobble_plate: Wobble Plate

**Play**:
- **Rules.** The stack sits on a plate balanced on a pivot. The plate tilts toward the stack's centre of mass: `S = clamp(1 - |x_com - x_base| / (w_base/2), 0, 1)`, `tilt = tilt_max * (1 - S)` with `tilt_max` 12 degrees (GDD F4). If `S < s_fail` (0.15) for longer than `t_grace` (1.5 s), the plate topples and loses `topple_penalty` (2) top cells. A balance meter shows S live.
- **Controls.** Standard drop controls. Optional *release*: a hanging prize crate swings above, and you release it onto the top as the final piece. This idea comes from the "hold item" chest on board 12. Our crate is an original prop.
- **Win / lose.** Win when height reaches `target_height` (8 to 12) and the prize crate rests on top. Lose when topples exceed `topples_max` (2 to 3), or on top-out.
- **Length.** Campaign 60 to 90 s. Tournament 90 s (MG38).
- **Players.** 1 to 4. In a shared-plate party variant (2 seats on one plate, from `minigame-stages.md` 1.14), both stacks move one plate, so you balance against your rival.
- **Twist.** Clears are off. Heavy pieces such as `big_cube` must go on the light side. Counterweighting is the skill, not speed.
- **As a level block.** It is a natural phase 1 before a climb or boss. With `gust_wind` it is a mid-biome remix. Scale `w_base` (8 to 6 cells) and `tilt_max`.
- **As a tournament round.** Standing = height. Hook: Send "Gust" (a one-second sideways push on the target's plate).
- **Tutorial bubble:** "Keep the plate level. Heavy blocks go on the high side." (10 words)

**Modules and data**: MISSING: module JSON, balance meter, topple handler, MG38 template. EXISTS to reuse: rules `wobble.json` and `tilt_plate.json` (used by `pirate_03`), `bounce_pad`, `jelly_piece`. The physics toy-box variants `balance` and `seesaw` (`wt_physics_challenge.gd`) prove the feel but run in a separate physics scene, not on BoardSim. NEW knob: `wobble.pivot "board_centre"` (`minigame-stages.md` register).

**In the world**: a cake stand on a turntable (Candy), a treetop platform (Forest) or a buoy raft (Pirate). The mascot wants something placed up high, such as the cake topper, a nest or a flag.

**Art**: a plate on a chunky pivot, sea or void below for danger read. The balance meter is a vertical gauge on a translucent purple plank (live UI). The prize crate hangs on a rope from a crane arm. Ref board 12 (top right) for composition only. The Nessie-style sea creature on that board must not be reused.

**Godot review**: _(layer 4: pending)_

---

### foothold_climb: Foothold Climb

**Play**:
- **Rules.** A hazard (avalanche snow, silt, lava or flood) rises from the floor at `h(t) = h0 + r * t_phase` (GDD F6, `r` 0.05 to 0.10 cells/s). Every `climb_step_ms` (500 ms) the mascot steps to a neighbouring column whose top is at most `climb_reach` (1) higher. You build the footholds it climbs.
- **Controls.** Standard drop controls.
- **Win / lose.** Win when the mascot stands at `target_height`. Lose when the hazard touches the mascot or the stack top, or on top-out.
- **Length.** Campaign 75 to 100 s. Tournament 120 s (MG42).
- **Players.** 1 to 4. A last-standing variant ranks seats by alive time, then height.
- **Twist.** The safe move (build tall in the centre) leaves the mascot stranded. You must build a reachable staircase, and it must outpace the hazard.
- **As a level block.** It is the most reusable phase. It follows `gap_runner` (`carry: shift`), and it can precede `giant_bonk`. Its skin defines its biome: avalanche in Ice, silt in Underwater, lava in Lava, cloud flood in Celestial.
- **As a tournament round.** Hook: Send "Rockfall" (one 1x1 cube dropped on the target's highest column).
- **Tutorial bubble:** "Build steps. The mascot climbs one block at a time." (9 words)

**Modules and data**: MISSING: module JSON, climber AI, hazard-versus-mascot fail check, MG42 template. EXISTS: `lava_rise.json`, `rising_silt.json`, `snowball.json`, `vines.json`; tournament MG13 "Floor Is Lava" (`rules_b.gd` `_lava_tick`) already implements a rising lava line on a 4x4 board.

**In the world**: escaping a snow slide on the ice peak, climbing out of the volcano crater, or rising above the silt in the sunken city.

**Art**: hazard as a readable band with a bright leading edge. An altitude gauge sits on the left plank (live UI). The mascot shows a nervous glance when the hazard is within 2 cells. Ref boards 09 (top right), 10 (bottom right) and 12 (bottom right) for climbing poses and hazard colour. Do not reuse their knight and elf cast.

**Godot review**: _(layer 4: pending)_

---

### catapult_keep: Catapult Keep

**Play**:
- **Rules.** Phase A (`build_phase_ms`, 30 to 45 s): build a keep on your half of an 8-cell-deep board. Phase B: every layer you clear loads one lob. *Fire* aims at a column marked on the rival keep. A hit removes its cell plus `splash_cells` (1), and unsupported cells fall (GDD F5). The rival, a scripted catapult in campaign, returns fire every `return_fire_ms`.
- **Controls.** Standard drop controls plus *fire* (tap a highlighted rival column).
- **Win / lose.** Win at `target_pct` destruction (50 to 60 percent). Lose when your keep falls below `fort_min_cells` (12).
- **Length.** Campaign 90 to 120 s. Tournament 120 s (MG43).
- **Players.** 1 against a scripted rival; 2 to 4 in tournaments (facing keeps, 3 to 4 seats round-robin aim).
- **Twist.** A strong keep needs solid layers, but lobs need clears. Every clear removes your own wall. This is the core tension.
- **As a level block.** A late-phase payoff after a balance or climb phase. It never comes first.
- **As a tournament round.** Standing = destruction percent. Hook: Steal (lobs hit rivals directly).
- **Tutorial bubble:** "Clear a layer to load the catapult. Tap to fire." (10 words)

**Modules and data**: MISSING: module JSON, two-zone board, aim UI, damage resolver, rival AI, MG43 template. EXISTS: `anvil_drop.json`, `crumble_tiles.json`, `earned_specials.json`; MG22 aim controls in `rules_c.gd` for reference. NEW: `earned_specials.target "opponent"`.

**In the world**: a friendly siege game between two picnic forts (Candy), or rival treehouse camps.

**Art**: two keeps face each other with a clear gap between them. Lob arcs are telegraphed with a dotted arc and a landing ring. Keep HP bars are live UI on wood planks. Ref boards 09 (bottom right) and 10 (top right) for facing-fort framing. Catapult and cannon props are generic; recast the crew with our cast.

**Godot review**: _(layer 4: pending)_

---

### deep_dig: Deep Dig

**Play**:
- **Rules.** The board starts with 6 to 8 packed earth layers (`starting_contents`). Each layer has 1 to 2 free cells, chosen per attempt from `starting_contents_variants`. Clearing a layer removes it and the dig goes one step deeper. Crystals sit in layers 1, 3 and 5. A crystal in a cleared layer is collected. Rock cells (`rock_obstacle`) cannot be cleared until a neighbour layer clears.
- **Controls.** Standard drop controls.
- **Win / lose.** Win at `depth` reached (6 layers). The optional `rescue` flag also requires reaching the trapped mascot at the bottom (goal `dig_rescue`). Lose on top-out or on the timer.
- **Length.** Campaign 60 to 90 s. Tournament 120 s (MG44).
- **Players.** 1 to 4 (mirrored shafts).
- **Twist.** It is the reverse of building. Each free cell is a puzzle about which piece fills it. Rocks force you to work around them.
- **As a level block.** A phase 1 that opens a cavern for a following `sneak_route` or `giant_bonk` phase. Never combine it with `rising_hazard` (opposite directions; the GDD validator rejects it).
- **As a tournament round.** Standing = depth. Hook: Shared gem vein (the first seat to clear a crystal layer steals that crystal from all seats).
- **Tutorial bubble:** "Fill the gaps to clear layers and dig down." (9 words)

**Modules and data**: PARTIAL: goal `dig_rescue` exists (`goals.json`, used by `cave_h3`); `rock_obstacle.json`, `locked_cube.json`, `star_coins.json` exist. MISSING: module JSON, `starting_contents_variants`, crystal pickup, MG44 template, `mud.json` (cited by the GDD, not in `assets/data/rules/`).

**In the world**: a crystal mine under the cave island. Something precious, or a stuck friend, is down there.

**Art**: a cutaway shaft with strata colours per depth and crystals that glow through the dirt. A depth readout is live UI. Ref boards 09 (bottom left) and 11 (bottom left) for the cutaway framing. The mining carts with riders on board 09 are not reused.

**Godot review**: _(layer 4: pending)_

---

### sorting_belt: Sorting Belt

**Play**:
- **Rules.** Pieces spawn in one of 4 colours (`spawn.colour_count 4`) over a central hub. Four conveyor arms (a plus-shaped mask, 10x10) carry locked cubes outward at `belt_speed`. Each arm ends in a hopper of one colour. A completed same-colour layer segment on the matching arm pops (`colour_pop`) and counts as sorted. Cubes that reach a hopper of the wrong colour count as a miss.
- **Controls.** Standard drop controls.
- **Win / lose.** Win at `sort_n` sorted (5 to 8). Lose when misses exceed `miss_max` (3), or on top-out.
- **Length.** Campaign 60 s. Tournament 90 s (MG45).
- **Players.** 1 to 4.
- **Twist.** Placement is about destination as well as fit: you drop where the belt will carry the piece.
- **As a level block.** Phase 1 in Clockwork. Pairs with `gate_squeeze` (factory gates).
- **As a tournament round.** Standing = score. Hook: Send "Jam Belt" (the target's belts pause for 2 s).
- **Tutorial bubble:** "Drop each colour on the belt to its hopper." (9 words)

**Modules and data**: MISSING: module JSON, arm routing, hoppers, MG45 template. EXISTS: `conveyor.json`, `mill_belt.json`, `colour_pop.json`, `piston_punch.json`; MG9 "Speed Sort" colour bins (`rules_a.gd`).

**In the world**: Tock's toy factory line, packing gears into the right crates before the night shift.

**Art**: brass belts with directional chevrons, and hoppers with colour and icon (for colour-blind players). The furnace hub glows. Ref board 11 (top left) for layout. The lava sea under the factory on that board is optional and must not hide the belts.

**Godot review**: _(layer 4: pending)_

---

### giant_bonk: Giant Bonk

**Play**:
- **Rules.** A boss sits beyond the board edge with `hp` (6 to 12). Every `attack_period_ms` it strikes `attack_cells` (2 to 4 telegraphed cells: a tentacle swipe, a sneeze or a stomp) and removes them. Every layer you clear deals `dmg_per_clear` (1, or 2 for a double clear). Your stack is the wall.
- **Controls.** Standard drop controls.
- **Win / lose.** Win when boss HP reaches 0. Lose when the wall is breached to row 0 on the boss side, or on top-out.
- **Length.** Campaign 90 to 120 s as the final phase. Tournament 150 s (MG46).
- **Players.** 1 in campaign. 2 to 4 in tournaments on a **shared boss**: each seat has its own board and the seats race for most damage dealt.
- **Twist.** You need to clear (attack) and to keep the wall (defend). The telegraph lets you choose which cells to leave for the strike.
- **As a level block.** The default L10 finale phase for most biomes (see `progression.md`). It is also the obvious h3 remix.
- **As a tournament round.** Standing = damage dealt. Hook: Shared (the boss targets the leader).
- **Tutorial bubble:** "Clear layers to bonk the boss. Patch where it strikes." (10 words)

**Modules and data**: PARTIAL: goal `bonk_boss` (`goals.json`, used by `candy_h3`), rule `climber_boss.json`, `storm_bolt.json`, `crab_claw.json`. MISSING: module JSON, HP bar, telegraph system, per-biome boss data, MG46 template. Note the playable-area question in `minigame-stages.md` 1.5: a 12x4 wall inside a 12x8 board needs a user decision. Default here: a full 8x8 fort.

**In the world**: each biome's troublemaker shows up at the finale. Layer 2 owns the cast. Bosses must be original characters, not the rainbow octopus from board 11.

**Art**: the boss is large and off-board, with readable wind-up poses. Strike cells flash for 1 s before the hit. The boss HP bar is live UI at the top. Ref board 11 (top right) for scale and framing only.

**Godot review**: _(layer 4: pending)_

---

### sky_steps: Sky Steps

**Play**:
- **Rules.** A side-view board (`16x8`, `down_axis "-x"`, `spawn.arrival "side_travel"`) with a staircase target running from the bottom left to the top right (`path_len` 8 steps, `max_step` 1). A walker climbs every completed step. Pieces matching the step colour (`rainbow_piece`) give `colour_bonus` time. The `gust_wind` overlay (a storm cloud) pushes falling pieces sideways on a telegraphed cadence.
- **Controls.** Standard drop controls, with sideways travel instead of falling.
- **Win / lose.** Win when the walker reaches the top step. Lose on top-out or on the timer.
- **Length.** Campaign 60 to 90 s. Tournament 150 s (MG47).
- **Players.** 1 to 4.
- **Twist.** A sideways "fall" plus wind means you place against the push. It is the campaign's one side-view minigame.
- **As a level block.** Celestial signature. It reuses `span_reach` (a walker on a heightmap), so it is cheap once `gap_runner` ships.
- **As a tournament round.** Standing = race progress. Hook: Send "Gust".
- **Tutorial bubble:** "Build steps to the stars. Watch the cloud's breath." (9 words)

**Modules and data**: PARTIAL: `side_travel.json`, `rainbow_piece.json`, `gust.json` exist; `ice_10` already uses `side_travel` on a 16x3 board, which breaks the 8x8 rule (see progression.md). The walker code in `span_reach.gd` and `span_walker.gd` works on any heightmap. MISSING: module JSON, stair target, MG47 template.

**In the world**: the celestial causeway to the sky gate. Comet needs a path up to a star that has fallen out of place.

**Art**: glass steps that light up in sequence and a starfield backdrop. The storm cloud is a character with a readable inhale before each gust. Ref board 11 (bottom right) for mood. The cloud's design must be our own.

**Godot review**: _(layer 4: pending)_

---

### sneak_route: Sneak Route

**Play**:
- **Rules.** A flat 10x10 board (`h_play` 3 to 4). Locked pieces become walls and paths. A runner (a mascot, or a herd of followers) moves along the shortest open path to each of `goals_n` keys. A guard patrols a fixed loop. If the guard's line of sight (orthogonal, 3 cells) meets the runner, the runner is caught and returns to the last key reached. In the **herd form** (Meadow), there is no guard: you fence wandering sheep into a pen (`pest.herd_target`).
- **Controls.** Standard drop controls.
- **Win / lose.** Win when all keys are collected (or all sheep are penned). Lose on timer, or on `caught_max` catches.
- **Length.** Campaign 60 to 90 s. Tournament 120 s (MG48).
- **Players.** 1 to 4.
- **Twist.** Pieces are walls, not floor. You build to block, which reverses the usual reading of the board.
- **As a level block.** Debuts in Meadow in the gentle herd form. Returns in Cave with a guard. Pairs after `deep_dig`.
- **As a tournament round.** Standing = keys. Hook: Send "Alert Guard" (the target's guard speeds up for 3 s).
- **Tutorial bubble:** "Your blocks are walls. Steer the runner past the guard." (10 words)

**Modules and data**: PARTIAL: tournament MG17 "Magnet Maze" maze view (`rules_a.gd` or `rules_b.gd`, needs confirming per the GDD gap note), `key_stamp.json`, `pest.json`, `fog.json`, `mascot_paw.json`. MISSING: module JSON, runner pathing, guard vision, herd target, MG48 template.

**In the world**: Meadow: round up Pip's runaway sheep before the picnic. Cave: sneak past a sleeping stone guardian to collect lantern keys.

**Art**: a top-down-leaning camera so paths read. The guard's vision cone is drawn on the floor. A sleep meter is live UI. Ref board 10 (bottom left) for the guard-and-keys idea. The stone golem design is not reused.

**Godot review**: _(layer 4: pending)_

---

### fuse_rings: Fuse Rings

**Play**:
- **Rules.** `rings_n` (3 to 4) ring outlines are marked on the floor. Each holds a lit fuse (`fuse_ms` 20 to 30 s, shown as a shrinking ring). Fill every cell of a ring at any layer to defuse it. Completing a ring adds `ring_bonus_ms` to the others. When a fuse hits 0, its ring pops and drops 2 junk cubes.
- **Controls.** Standard drop controls.
- **Win / lose.** Win when all rings are defused. Lose when `bombs_exploded` exceeds the allowed count (default 1), or on top-out.
- **Length.** Campaign 45 to 60 s. Tournament 90 s (MG49).
- **Players.** 1 to 4.
- **Twist.** It is a triage puzzle: defuse the cheapest ring first for its bonus, or the most urgent one.
- **As a level block.** A short panic phase before a finale. Positions are random per attempt.
- **As a tournament round.** Standing = rings. Hook: Send "Fuse Burn" (the target's shortest fuse loses 3 s).
- **Tutorial bubble:** "Fill each ring before its fuse runs out." (8 words)

**Modules and data**: PARTIAL: `countdown_bomb.json`, `stopwatch.json`, `fever_rush.json`; tournament MG14 "Hot Block" fuse logic in `rules_b.gd`. MISSING: module JSON, ring targets, MG49 template.

**In the world**: the Neon fireworks show is about to go off early. Fill the launch rings to stop it.

**Art**: fuses as sparkling neon rings with an icon plus a number countdown (live UI). The pop is cartoon confetti, not an explosion. No board reference; style should follow board 12 (bottom right) for neon materials.

**Godot review**: _(layer 4: pending)_

---

### floe_footing: Floe Footing

**Play**:
- **Rules.** The mascot stands on a floe of `floe_cells` (about 36 on a 10x10 mask) that crumbles at `rate` from the rim inward. A shove (`piston_punch`, `shove_period_ms`) slides the mascot one cell. You place pieces to patch the floe and to build bumpers. The mascot slides on bare ice (`ice_slide`) until it hits a block.
- **Controls.** Standard drop controls.
- **Win / lose.** Win after `survive_ms` (60 to 90 s). Lose when the mascot slides off.
- **Length.** Campaign 60 to 90 s. Tournament 90 s (MG50).
- **Players.** 1 to 4. The tournament version uses a **shared floe**: seats' mascots shove each other.
- **Twist.** Pure defence, with a clear spatial read: where will the shove send the mascot?
- **As a level block.** Survival middle phase. It replaces the generic `survive` goal that currently sits at tier 08 in seven biomes.
- **As a tournament round.** Standing = alive time. Hook: Shared floe.
- **Tutorial bubble:** "Patch the ice and block slides. Keep Sniffles aboard." (9 words; swap in the biome mascot)

**Modules and data**: MISSING: module JSON, crumbling floe, shove, mascot slide, MG50 template. EXISTS: `ice_slide.json`, `thin_ice.json`, `crumble_tiles.json`, `piston_punch.json`.

**In the world**: an ice floe breaking off the glacier (Ice). It returns in Lava as a crust raft.

**Art**: cracks spread visibly before a cell falls, with dark water below. Push direction is shown with a big arrow on the floor 1 s ahead. No board reference; follow the art bible's ice palette.

**Godot review**: _(layer 4: pending)_

---

### paver_rally: Paver Rally

**Play**:
- **Rules.** A kart drives forward along a lane at `v = v_base * (1 + boost * clears_5s) * (1 - hole_drag * hole_frac)` (GDD F7, minimum 0.25). The board scrolls (a conveyor) toward the kart. You drop pieces to pave the road ahead. Holes slow it down. Coins on the road add boost.
- **Controls.** Standard drop controls.
- **Win / lose.** Win when the kart crosses the finish (`track_len`). Lose when the kart stalls for `stall_ms` (3 s).
- **Length.** Campaign 60 to 90 s. Tournament 120 s (MG41).
- **Players.** 1 to 4 (a mirrored track with a shared view of positions).
- **Twist.** It is a scrolling, forward-pressure version of layer-filling. Gaps cost speed instead of space.
- **As a level block.** Lava signature (a cooling-crust road). It later appears in carnival remixes.
- **As a tournament round.** Standing = race progress. Hook: Send "Oil Slick" (2 cells in front of the target's kart become slippery).
- **Tutorial bubble:** "Fill the road ahead. Gaps slow the kart down." (9 words)

**Modules and data**: MISSING: module JSON, scrolling board, kart, MG41 template. EXISTS: `conveyor.json`, `mill_belt.json`, `star_coins.json`, `balloon.json`.

**In the world**: racing Smolder's delivery cart across cooling lava before the crust melts.

**Art**: a road with lane arches, and the kart and driver from our cast. Speed lines and a position strip are live UI. Ref board 12 (top left) for the winding-track composition only.

**Godot review**: _(layer 4: pending)_

---

### splat_claim: Splat Claim

**Play**:
- **Rules.** Each locked cube paints the floor cells beneath it, and its top face, in your colour. A scripted rival painter (a pest) repaints `rival_rate` cells per second, heading toward your largest patch. Clearing a layer seals its painted cells permanently.
- **Controls.** Standard drop controls.
- **Win / lose.** Win when you own `target_pct` (60 percent) of the visible top faces. Lose on timer.
- **Length.** Campaign 60 s. Tournament 90 s (MG39, shared island).
- **Players.** 1 against the pest; 2 to 4 on a shared floor in tournaments.
- **Twist.** Spread versus seal: wide flat placements claim more, while clears lock in your gains.
- **As a level block.** A Forest debut with moss against a fungus pest. It returns in Neon as paint.
- **As a tournament round.** Standing = percent owned. Hook: Shared floor.
- **Tutorial bubble:** "Cover the floor in your colour. Clears lock it in." (10 words)

**Modules and data**: MISSING: module JSON, ownership grid, rival painter, MG39 template. EXISTS: `chameleon_paint.json`, `confetti_fill.json`, `goo_spread.json`, `pest.json`; MG20 "Paint Dash" paint logic.

**In the world**: moss reclaiming the forest floor before the fungus spreads (Forest); a neon paint battle (Neon).

**Art**: high-contrast ownership colours with pattern overlays for colour-blind players. A percentage bar is live UI. No board reference.

**Godot review**: _(layer 4: pending)_

---

### knockdown_tower: Knockdown Tower (NEW)

**Play**:
- **Rules.** This is a new idea inspired by the central tower on board 12 (bottom left). A neutral tower of mixed cubes stands beyond your board. Some cubes carry your colour and some carry the rival's. Each layer you clear fires one shot at a column you choose. A hit knocks out that cube, and unsupported cubes above it fall. You score for every cube of the **rival's** colour that falls, and lose points for your own.
- **Controls.** Standard drop controls plus *fire* (choose a column on the target tower).
- **Win / lose.** Campaign: win at `score_target`, lose on timer or top-out. Tournament: highest score at the end of the round.
- **Length.** Campaign 75 s. Tournament 90 s.
- **Players.** 1 against a scripted ship gunner; 2 to 4 on a **shared tower** in tournaments.
- **Twist.** Unlike Catapult Keep, the target is shared and you don't defend anything. The skill is reading which knock brings down the most rival cubes.
- **As a level block.** Pirate signature (a ship broadside on a sea stack). It can follow Catapult Keep in the Pirate finale.
- **As a tournament round.** Standing = score. Hook: Shared tower.
- **Tutorial bubble:** "Clear layers to fire. Topple the rival-coloured blocks." (8 words)

**Modules and data**: MISSING: everything. Proposed `assets/data/modules/knockdown_tower.json` with `tower_w`, `tower_h`, `own_ratio`, `shot_per_clear`, `score_target`. A physics-free collapse rule (unsupported cubes fall straight down, as in Catapult Keep F5) keeps it deterministic.

**In the world**: two pirate crews settle a dispute by knocking blocks off a sea stack.

**Art**: ships and cannons in original pirate designs, and a tower with clearly coloured cube faces. Ref board 12 (bottom left) for the two-ships-and-tower composition only.

**Godot review**: _(layer 4: pending)_

---

### gate_squeeze: Gate Squeeze (NEW)

**Play**:
- **Rules.** This is a new campaign form of the tournament wall-fit idea (MG1) and the arcade "wall" trials. Every `gate_period_ms` (20 to 30 s), a wall with a hole outline sweeps across the board at `gate_layer`, which is shown 10 s ahead. Cells at that layer outside the hole are shaved off. Cells inside the hole outline that are filled count as "threaded". A gate passes when threaded cells cover at least `fit_pct` (70 percent) of the hole.
- **Controls.** Standard drop controls.
- **Win / lose.** Win when `gates_n` (3 to 5) gates have passed. Lose when `misses_max` (2) gates fail, or on top-out.
- **Length.** Campaign 75 to 120 s. Tournament 90 s.
- **Players.** 1 to 4.
- **Twist.** You build a silhouette at a set height, on a clock, while ordinary stacking continues below.
- **As a level block.** Underwater signature (current gates). It returns in Clockwork (factory shutters).
- **As a tournament round.** Standing = gates passed. Hook: Send "Tight Gate" (the target's next hole loses its slack cells).
- **Tutorial bubble:** "Match the hole's shape at the glowing layer." (8 words)

**Modules and data**: PARTIAL: MG1 "Hole in the Wall" template (`hole_slack_start`, `hole_slack_end`, `wall_start_ms`) and the arcade wall trials (`arcade-pack.md`) define fit checking on 4x4 and 5x5 frames. MISSING: module JSON, the sweep on an 8x8 board, the shave rule.

**In the world**: a reef current pushes a gate through the sunken city (Underwater). Factory shutters slam down (Clockwork).

**Art**: a translucent wall with a bright hole outline and a target-layer ring on the stack. The sweep is fast but telegraphed. No board reference.

**Godot review**: _(layer 4: pending)_

---

### domino_run: Domino Run (physics toy-box)

**Play**:
- **Rules.** This uses the `domino_chain` variant of the physics toy-box (`wt_physics_challenge.gd`), which runs in Jolt. Place real physics pieces along an 8x3 strip. After 3 pieces, *push* tips the first one. Win when the chain rings the bell at the far end.
- **Controls.** Physics-mode controls (steer, spin, drop) plus *push*.
- **Win / lose.** Win when the bell rings. Lose after `drops_allowed` (3) pieces fall off, or on the timer (90 s).
- **Length.** 60 to 90 s.
- **Players.** 1 to 4 (a tournament physics round).
- **Twist.** Spacing and weight instead of grid fit. It is the game's one fully physical toy.
- **As a level block.** It **cannot** be a phase inside a BoardSim level ("Grid BoardSim is never approximated by physics", file header). Use it as a bonus-slot showcase scene (proposed: the Clockwork bonus) and as a tournament round.
- **As a tournament round.** Standing = chain length reached. No send hook (physics is not seeded for exact parity, so it needs a fairness check first).
- **Tutorial bubble:** "Space the blocks so they tip all the way." (9 words)

**Modules and data**: PARTIAL: the variant and its push action exist. Its strip footprint is 8x3 (`Vector3(8, .6, 3)`), below the 8x8 rule; ask the user whether physics strips are exempt. MISSING: a tournament template (no physics template in `templates.json`), seeded determinism across seats, biome skins, and a module-style entry. The other 12 variants (tower_race, grid_settle, balance, bridge_builder, seesaw, bowl_fill, windy_tower, meteor_shower, tallest_in_time, gentle_drop, moving_platform, reach_out) are candidates for later physics rounds and are not listed here as separate minigames.

**In the world**: Tock's chime clock. The chain rings the hour bell.

**Art**: wooden toy dominoes and a brass bell. The camera follows the chain once it starts. No board reference.

**Godot review**: _(layer 4: pending)_

---

## Gaps shared by all minigames (layer 1 findings)

1. **No module runtime.** No level JSON has a `modules` array, and nothing in `src/` loads one. Only `bridge_dash` has module data, and its code has no callers. Until a phase runner exists, every minigame above is design only inside campaign levels.
2. **Missing GDD.** `design/gdd/modules-framework.md` is cited by `_framework.json`, `bridge_dash.json` and all three `src/core/modules/*.gd` files, but it does not exist.
3. **Tournament templates MG37 to MG50 are missing.** `templates.json` stops at MG36. They also unlock only after their first campaign appearance, so none can unlock today.
4. **Goal registry.** `goals.json` `goal.type` has no `span`, `modules`, `connect` or `stair` entry.
5. **Board size.** Several tournament boards are below 8x8 (MG1 4x4, MG6 8x3, MG13 4x4, etc.). This is fine for tournament-only rounds, but campaign reuse must re-author them at 8x8. The user should confirm the rule applies to campaign boards only.
6. **Tests.** There are no unit tests for `span_reach` or `span_walker`, even though both are pure and easy to test.

## Naming fixes (board names must not be used)

| Where | Current | Proposed |
|---|---|---|
| `assets/data/modules/bridge_dash.json` `title` | Bridge Bashers | Gap Runner |
| `pirate_03` name | Tumbling Towers | Wobbly Crow's Perch |
| `pirate_09` name | Fort Blast | Broadside Bash |
| `pirate_10` name | Kraken Blockade | (layer 2 names the Pirate boss) |
| `pirate_h1` name | Kraken Blockade II | (layer 2) |
| `pirate_h2` name | Fort Blast: Broadside | Broadside Bash: Encore |
| `design/levels/minigame-stages.md` stage titles | board titles | the ids in this file |
| `campaign-minigames.md` MG37 to MG50 template names | several board titles | the names in this file |
