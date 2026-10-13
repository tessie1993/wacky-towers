# Mockup Review: Engine View (Level Modules + Head-to-Head)

Reviewer: godot-specialist. Engine: Godot 4.7.2, GDScript, Mobile renderer. Date: 2026-10-13.
Status: review notes. No code was changed.

**Inputs**
- 18 of 20 mockups viewed: `mockup_01`–`14`, `16`, `17`, `18`, `20`. `15` and `19` were not viewed.
- `design/gdd/campaign-minigames.md` (rev 2).
- `docs/architecture/campaign-minigame-integration-notes.md`.
- Source: `src/core/sim/board_sim.gd`, `src/core/rules/**`, `src/mechanics/README.md`, `src/mechanics/candy/bake_stage.gd`, `src/mechanics/goal/bonk_boss_goal.gd`, `src/view/wt_toy_actor.gd`, `src/view/wt_block_materials.gd`, `src/view/wt_stage.gd` (outline), `src/app/bot_player.gd`, `src/app/main.gd` (session, rivals and LAN paths), `assets/data/biome_looks.json`.

**Not read in this pass. Claims that depend on these are marked *unverified*:**
- ADR-0009 (local multiplayer) and ADR-0004/0011.
- The HUD code in `src/ui/game_ui.gd`.
- The `WtToyActor` pose table.
- `WtPhysicsChallenge` internals.
- The engine-reference deprecated/breaking files.

This plan uses only APIs already in the repo (RefCounted plugins, `SubViewport`, `Tween`, Beehave). It introduces no new engine API.

---

## 0. Key findings from the code

1. **Phase swaps already exist in one place.**
   - `RuleApi.request_goal(config)` (`rule_api.gd:123`) queues a structural `goal` op.
   - `BoardSim._apply_structural` (`board_sim.gd:1371-1381`) swaps `_level.goal`, re-selects the `GoalEvaluator` slot and calls `begin()`.
   - `bake_stage.gd` uses this for Candy's oven → bonk phase. It is the prototype for module phases.
2. **Composition precedent.** `BakeStageRule` holds a `FrostingRule` and forwards hooks to it. However, a composed behaviour shares its parent's `RuleApi` and params, so reused rules cannot keep their own params that way.
3. **Lose from a goal evaluator is not honoured.**
   - `_lock()` acts only on `WON` from `evaluate()` (`board_sim.gd:982-986`).
   - `_goal_step()` only evaluates every tick for `goal.type == survive` (`:752-760`).
   - Module fail conditions (fuse, walker falls, topples) therefore need a small BoardSim change.
4. **Only the twist layer can be swapped at runtime.**
   - `set_rule_definitions()` / `_replace_twists()` replace only the twist layer (rank 3).
   - Rules otherwise end only via `lifetime` (`_expire_rules`, `:1310`).
   - No API adds or removes mechanic-layer rules per phase.
5. **One active piece per BoardSim.** A shared floor with several players dropping on one board is not supported. Head-to-head therefore means one BoardSim per seat.
6. **Rivals already run locally.**
   - `main.gd` already steps N rival `BoardSim`s with `WtBotPlayer` in tournament block rounds (`main.gd:102-104, 403-415`).
   - The LAN path steps `_network_sims` in sorted-id order (`:944-955`).
   - Head-to-head on BoardSim is therefore an extension, not new infrastructure.
7. **The bot has a fixed objective.** `WtBotPlayer` looks for a low, hole-free placement (`bot_player.gd:35-60`) and has no notion of an objective (gap, boss, foothold).
8. **Toy actors are presentation only.**
   - `WtToyActor` is a `Node3D` with a Beehave pose tree. Its header says "geometry is not gameplay collision".
   - `WtStage` places three of them: wizard, mascot and boss (`wt_stage.gd:933-954`).
   - No actor moves across board cells today.
9. **Skins.**
   - `biome_looks.json` has `styles` and per-biome `block / sky / island / props / accent / frame`.
   - It is read by `WtBlockMaterials.look()` and `WtIslandBuilder`.
   - There is no per-module skin data yet.
10. **Two minigame runtimes exist.** `WtMinigameSession` with `rules_a`–`d` (MG1–36) is separate from BoardSim. MG37–50 should **not** go there. They should be BoardSim levels with modules, so campaign and versus share one code path (see §3).

---

## 1. Module runtime architecture

### 1.1 Shape

A new plugin kind, `LevelModule`, is driven by one director rule and one goal evaluator. All of it lives inside BoardSim's existing tick and hook pipeline. It keeps the invariants: deterministic, no nodes, no wall clock, `api.rng()` only.

```
src/core/rules/bases/level_module.gd           # new @abstract base -> PluginRegistry auto-discovers kind &"LevelModule"
src/core/modules/module_def.gd                  # parsed assets/data/modules/<id>.json (schema, ranges, board needs, overlays, skins)
src/core/modules/module_plan.gd                 # parsed level "modules" array -> ordered phases [{primary, overlays[], until, carry}]
src/core/modules/grid_walker.gd                 # deterministic cell walker (bridge, climb, route, stair, floe)
src/mechanics/modules/module_director.gd        # RuleBehaviour PLUGIN_ID &"module_director" (owns phases)
src/mechanics/modules/modules_goal.gd           # GoalEvaluator PLUGIN_ID &"modules"
src/mechanics/modules/<id>_module.gd            # one LevelModule per module id (clear_layers_module.gd, boss_hp_module.gd, ...)
src/data/module_loader.gd / module_validator.gd # schema + level checks (GDD edge cases)
assets/data/modules/<id>.json                   # defaults, safe ranges, s_p slopes, requires, compatible_overlays, rules[]
```

`PluginRegistry` classifies any `class_name` whose ancestor lives under `res://src/core/rules/bases/` (`plugin_registry.gd:45-53`). Adding `level_module.gd` there therefore registers module plugins with no registry change.

### 1.2 `LevelModule` contract

```gdscript
@abstract
class_name LevelModule extends RefCounted
## One gameplay unit run as a phase (primary) or alongside one (overlay). Declares const PLUGIN_ID.
const ROLE_PRIMARY := &"primary"
const ROLE_OVERLAY := &"overlay"

@abstract func role() -> StringName
## Merged params (module defaults <- level params, F3 already applied by the loader).
@abstract func configure(params: Dictionary) -> void
func subscribed_hooks() -> Array[StringName]: return []
func begin(api: RuleApi) -> void: pass                     # phase start (after carry)
func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void: pass
func end(api: RuleApi) -> void: pass                       # phase end; overlays clean up
func until_met(state: GoalState, api: RuleApi) -> bool: return false
func failed(state: GoalState, api: RuleApi) -> StringName: return &""   # reason or &""
## Rule ids this module composes (e.g. boss_hp -> storm_bolt). Director adds/removes them per phase.
func composed_rules() -> Array[Dictionary]: return []
## HUD meters, integer milli units. See 1.5.
func meters(state: GoalState) -> Array[Dictionary]: return []
## Bot hint: extra placement value for cells (see 3.3). 0 = neutral.
func bot_value(cells: Array[Vector3i], api: RuleApi) -> int: return 0
func snapshot() -> Dictionary: return {}
func restore(state: Dictionary) -> void: pass
func validate(level: LevelData, catalog: GameCatalog) -> Array[ValidationIssue]: return []
```

### 1.3 Director, goal and the BoardSim changes they need

**Loader.** `LevelLoader` accepts a top-level `modules` key; `KEYS_TOP` is extended. When it is present, the loader:
- forces `goal.type = "modules"`;
- injects `{"id": "module_director", "layer": "mechanic"}` into `level.rules`;
- stores the parsed `ModulePlan` on the goal config (`goal.plan`).

A level without `modules` is wrapped as one `legacy_goal` phase. It is easiest to keep that path untouched: no director, no `modules` goal. This satisfies GDD acceptance criterion 5 with zero regression risk.

**`ModuleDirector`** (RuleBehaviour) subscribes to `on_level_start, on_tick, on_lock, on_clear, on_resolve_end, on_goal_check`. It:
- instantiates the `LevelModule`s for the current phase;
- forwards hooks to them;
- writes goal metrics: `module_phase`, `module_phases`, `module_done` (0/1), `module_fail` (reason hash);
- emits sim events.

**`ModulesGoal`** (GoalEvaluator):
- `evaluate()` returns `WON` when `metrics.module_done == 1`;
- returns `LOST` when `module_fail` is non-zero (needs change A below);
- `progress()` returns the phase pips and meters (1.5).

**Phase transition** runs only in `on_resolve_end`:
1. The active piece has already locked. This satisfies "a piece in the air lands first".
2. The director checks `until_met()`. Completion is checked before `failed()`, so "completion wins" in the same tick.
3. It calls `end()` on the primary and overlays.
4. It applies `carry` with existing writes:
   - `clear`: `api.remove_cell` on every occupied cell, with a new `BoardState.Cause.PHASE` so views can confetti-pop;
   - `shift`: one `api.move_cells` batch (cycle-safe);
   - `keep`: no-op.
5. It sends `api.request_rules(owner, add, remove)` (change B) for composed rules.
6. It sends `api.request_spawn_hold(phase_banner_ms)` (change C).
7. It emits `module_phase_started {phase, id, skin, banner_ms}`.
8. It calls `begin()` on the new primary and overlays.

**Required BoardSim / RuleApi changes.** They are small and all go through the existing structural queue.

| # | Change | Where | Why |
|---|---|---|---|
| A | Honour `LOST` from `evaluate()` in `_lock()`. Also evaluate every tick in `_goal_step()` when the goal plugin opts in (`func ticks() -> bool`). This generalises the hardcoded `survive` check. | `board_sim.gd:752-760, 982-986`; `goal_evaluator.gd` | Module fails (fuse 0, walker falls, hazard touch) and time-based `until` (floe_survive) |
| B | Structural op `rules`: add or remove rule entries tagged `owner`, at a new `module` rank (5). Reuse `_create_rule` and the removal half of `_replace_twists` filtered by owner instead of rank 3. | `board_sim.gd` (`_apply_structural` order: after `slot`); `rule_api.gd` | Composed rules (`rising_silt`, `storm_bolt`, `crumble_tiles`, `gust`) keep their own params and `RuleApi` and get flushed by `_collect_api`. The `bake_stage` inline composition cannot do that. |
| C | Structural op `spawn_hold`: `_entry_deadline = max(_entry_deadline, now + ms)`. The level clock keeps running; `_warning_until` must not be used because it freezes `_level_ticks`. | `board_sim.gd` | Phase banner (GDD rule 3.2) |
| D | `RuleApi.create_plugin(kind, id)`, or pass `catalog.plugins` to the director at `on_level_start` | `rule_api.gd` | Director instantiates `LevelModule`s. `RuleApi` holds `_catalog` but exposes no accessor *(verified only by the outline)*. |
| E | `state_hash()` includes the director snapshot. This works already through `RuleBehaviour.snapshot()` if the director returns its modules' snapshots. | `module_director.gd` | Replays, LAN and the determinism test (AC 6) |

### 1.4 JSON

**Module definition** (`assets/data/modules/boss_hp.json`):

```json
{
  "schema": 1,
  "id": "boss_hp",
  "role": "primary",
  "params": {
    "hp":               {"default": 10,   "min": 4,    "max": 30,    "s_p": 0.10},
    "dmg_per_clear":    {"default": 1,    "min": 1,    "max": 3},
    "attack_period_ms": {"default": 7000, "min": 4000, "max": 12000, "s_p": -0.08},
    "attack_cells":     {"default": 2,    "min": 1,    "max": 4}
  },
  "requires": {"min_w": 8, "min_d": 8, "min_h": 10, "clear_enabled": true},
  "zones": ["full"],
  "compatible_overlays": ["rising_hazard", "gust_wind"],
  "rules": [{"id": "storm_bolt", "params_from": {"period_ms": "attack_period_ms"}}],
  "until": ["boss_hp_zero"],
  "fail": ["wall_breached_row0"],
  "skins": ["candy", "underwater", "lava", "forest", "cave", "clockwork", "celestial", "carnival"],
  "bot": {"prefer": "clears"}
}
```

**Level** (unchanged from the GDD, plus an optional per-entry `skin`): see `campaign-minigames.md` rule 2.

**Per-module skins in `biome_looks.json`.** Add a `modules` block per biome. This is view-only data; the sim sees only the `skin` string, which is used for validation.

```json
"lava": {
  "block": {"...": "..."},
  "modules": {
    "bridge_dash":   {"walker": "cinder", "gap_fx": "lava_river", "plank_style": "lava", "banner_key": "MOD_VOLCANO_DASH"},
    "summit_climb":  {"walker": "cinder", "summit_prop": "trophy", "foothold_glow": "#FF8A3D"},
    "rising_hazard": {"kind": "lava", "surface_color": "#FF6A1A", "glow": 1.4, "particles": "embers"},
    "boss_hp":       {"boss": "smolder", "boss_scale": 2.2, "attack_fx": "magma_lob", "name_key": "MOD_MAGMA_GOLEM"}
  }
}
```

Lookup is `WtBlockMaterials.look(biome).get("modules", {}).get(module_id, {})`, falling back to `meadow` and then to the module file's default. Walker and boss ids must be `WtToyActor.setup()` ids (`cinder`, `smolder`, `geode`, `oak`, ...), so no new character code is needed for skins.

### 1.5 Module-owned HUD meters

Meters are **data, not per-module UI code**. Each `LevelModule.meters()` returns rows such as:

```json
{"id": "boss_hp", "kind": "bar_h", "value_milli": 600, "max_milli": 1000, "danger_milli": 0,
 "label_key": "HUD_BOSS_HP", "icon": "boss", "slot": "top"}
```

- `kind` takes one of: `thermo_v` (Heat, Altitude, Balance, Stability in the mockups), `bar_h` (Boss HP, Lava Rise, Fort HP), `counter` (Keys 1/3, Depth 32 m), `pips` (rings, phases).
- `ModulesGoal.progress()` returns `{"phase": i, "phases": n, "meters": [...]}`. That already flows through the `GOAL_PROGRESS` event and `goal_progress()`.
- New UI: `src/ui/hud/module_meter.gd` (one `Control`, draws all four kinds) and `src/ui/hud/module_meter_rack.gd` (lays out by `slot`: `left` thermometer, `top` bar, `right` counter). This matches the mockup layout: left thermometer, top-centre bar, right "Next" box.
- Values are integer milli, so the sim stays integer. The rack tweens only the display value.
- *Unverified:* how `game_ui.gd` consumes `goal_progress` today. Hook the rack wherever `show_hud(_hud_snapshot())` (`main.gd:493`) builds goal text.
- Phase banner: `module_phase_started` → `ui.show_phase_banner(name_key, skin)`, and pips in the top bar.

### 1.6 Module views and walkers

**Grid walker (sim).** `GridWalker` (RefCounted, integer) holds:
- `cell: Vector3i`, `step_ms`, `reach_up`, `drop_max`, `state` (`walk | wait | fall | done`);
- `next_step(api) -> Vector3i`: a BFS over top surfaces (`api.is_free` / `api.kind_at`) with a canonical neighbour order, so ties are deterministic.

It is used by `bridge_dash` (walk across the gap row), `summit_climb` (F6), `route_runner` (BFS to goals, "?" idle when sealed), `stair_path` and `floe_survive` (being pushed off = `fall`). Its state goes into the module snapshot. It emits `walker_moved {id, from, to, kind}`.

**View.** `src/view/modules/wt_module_view.gd` is a base `Node3D` with:
- `setup(module_id, skin: Dictionary, geom: BoardGeom)`;
- `sync(events)`;
- a registry by module id, mirroring `WtMinigameArt.create()`.

`WtStage.sync()` forwards `module_*` / `walker_*` events to the active module views.

`WtWalkerView` drives a `WtToyActor`:
- on `walker_moved` it plays a `Tween` (hop arc, 0.8 × `step_ms`) between `BoardGeom` cell centres;
- it calls `set_pose(&"walk" | &"climb" | &"cheer" | &"fall")`.
- *Unverified:* whether `_apply_pose` already has `walk` and `climb`. If not, add those poses to the toy pose table (presentation only).

---

## 2. Feasibility per mockup concept

Legend:
- **E** = easy: mostly existing rules, about 1–3 dev-days.
- **M** = medium: new module logic plus a walker or view, about 3–6 dev-days.
- **H** = hard: new sim capability or physics, more than 6 dev-days or a design compromise.
- **Grid** = deterministic BoardSim logic. **Jolt** = would need real physics. **Walker** = a character moving on blocks (today only a toy actor).

| Concept (mockup) | Module | Rating | Sim type | Walker | Notes |
|---|---|---|---|---|---|
| Speed Stack, Laser/Woodpile Sprint | `clear_layers` | E | Grid | – | `clear_n` goal plus `stopwatch`. Almost free. |
| Boss Bash, Kraken Blockade, Abyssal Kraken Siege, Magma Golem (13, 04, 07) | `boss_hp` | E | Grid | – | `bonk_boss` metric plus `storm_bolt` for attacks. The boss is a big `WtToyActor` (exists: `_boss`). |
| Lava Rise / Avalanche / Silt overlay (02, 03, 11, 12) | `rising_hazard` | E | Grid | (touches walker) | `rising_silt` exists. Lava/water is a view plane at `h(t)`. Fail needs change A. |
| Gust / storm cloud (04 Chroma, Kraken Keep 08) | `gust_wind` | E | Grid | – | `gust`, `dandelion_puff` exist. |
| Crumble floor (Glacier Gauntlet 12) | `crumble_floor` | E | Grid | – | `crumble_tiles`, `thin_ice`, `quicksand` exist. |
| Digging Frenzy, Rubble Rumble, Gem Grab (01, 04, 14) | `dig_down` | E–M | Grid | optional | `dig_rescue` and `angle_gem` exist. The drill/kart actors in the art are cosmetic. |
| Clockwork Conveyor, Factory Frenzy (04, 06) | `conveyor_sort` | M | Grid | – | `conveyor`/`mill_belt` move contents. Hopper scoring by colour at the belt end is new. |
| Bomb Defuse, Potion Puzzle (16, 20) | `ring_defuse` | M | Grid | – | `countdown_bomb`/`colour_pop`/`turntable` exist (*`countdown_bomb` not seen in the README list; verify*). Ring masks plus a fuse need change A. |
| Neon Splat, Island Claim, Frosting Splat (14, 16) | `paint_claim` | M (solo) / H (shared arena) | Grid | – | `chameleon_paint`/`goo_spread`. A scripted pest painter is easy. A true shared floor is not possible (one piece per sim), so use the mirrored version plus the % compare. |
| Bridge Bashers, Bridge Dash, Meadow Mayhem, Jungle Bridge Rush, Volcano Dash (01, 02, 10, 12, 13) | `bridge_dash` | M | Grid | **yes** | Board with a masked gap (`request_mask`); the walker crosses when a supported path exists. Swinging maces in Volcano Dash are a view-only telegraph plus `storm_bolt`-style damage. |
| Avalanche Ascent, Summit Scramble, Frenzy Footholds, Jungle Vine Ascent, Candy/Pyramid/Cosmic Climb, Jungle Giant Ascent (01, 02, 03, 08, 09, 11, 12, 20) | `summit_climb` | M | Grid | **yes** | F6 is a pure integer walker. It shares `GridWalker` with bridge. |
| Chroma Sky Climb, Cosmic Climb (04, 12) | `stair_path` | M | Grid | **yes** | Walker plus a `max_step` rule. A cheap reuse once the walker exists. |
| Maze Heist, Neon Maze, Pirate Plunder Maze, Coral Conduit, Herd Sheep (02, 05, 09, 13) | `route_runner` | M–H | Grid | **yes** (+ guard) | BFS walker plus key/goal cells (`key_stamp`). The guard is a second walker. MG17 maze view reuse is unconfirmed. Gravity flip (Neon) = `flip`. A top-down readability camera may be needed (camera work). |
| Fort Frenzy, Fort Blast, Shatter Shootout, Castle Siege Crash, Candy Crushers, Airship Scrap Brawl (01, 02, 03, 07, 11, 12) | `fort_siege` | H | Grid (ballistic arc is a view) | – | Needs a second board region (the rival fort) in the same `BoardState`, or a scripted target grid, plus aim input. The lob is a deterministic integer arc resolved to a cell, then `request_post_clear_damage`. Physics-y debris is VFX only. |
| Tumbling Towers, Wonky Builders, Cake Stackers, Fruit Stack, Sugar Rush Stack, Kraken Keep, Moon Stack (03, 05, 08, 20) | `balance_plate` | M (Grid, F4) / H (Jolt) | **Grid recommended** | – | F4 is integer COM maths. `wobble` exists. Visual tilt = rotate the board root `Node3D` by `tilt_milli` with a Tween. **Do not** use Jolt: not deterministic across devices, no bots/LAN (see the earlier notes, §3B). |
| Rolling Rumble, Balloon Race, Rail Rush, Glacier Rush, Galactic Grab, Sweet Rush Rails (03, 05, 09, 11, 16) | `road_race` | H | Grid (kart is a 1D integer track position) | kart (not a toy walk) | F7 is integer. The track is a board row the player paves; the kart reads `hole_frac`. The art implies a winding 3D track, which is a large view and camera job. Keep the track straight on-board and curve only the scenery. |
| Slippery Sumo, Bumper Battle, Lava Rumble, Lava Escape (11, 13, 14, 16) | `floe_survive` | H | Grid (discrete shoves) | **yes** | Shoves = `piston_punch`/`ice_slide` on the walker cell. Seat-vs-seat pushing in a shared floe needs cross-sim coupling (§3.2). Bumper-car physics in the art is Jolt-only: do not build it. |
| Cosmic Gravity Goal, Magnetic Mash, Wormhole Gravity Rush, Nebula Laser Hack, Steampunk Gear-Up, Submarine Salvage, Deep Sea Bubble Build, Prehistoric Nest Defense, Temple Roller Run, Clockwork Chaos, Quantum Spire (06, 07, 08, 09, 10, 17) | not in the 14 | – | – | – | Mostly expressible as skins or overlays of existing modules: magnet = `magnet_pull`, wormhole = `flip`/`down`, gears = `turntable`, bubbles = `bubble`, nest = `boss_hp` defend, roller = `snowball`. **Cosmic Gravity Goal** (hoverboard ball game) does not fit the drop-a-piece pillar. Drop it. |
| Hub island map (16, 18) | – | M | UI/scene | – | A level-select presentation, not a module. Uses `WtIslandBuilder` per biome. |

**Physics summary.** None of the 14 modules *requires* Jolt.
- Jolt-looking art (tilting plates, bumpers, karts, lobbed ammo, tumbling debris) should be **view-only** over deterministic grid state.
- Keep the existing `WtPhysicsChallenge` (MG5 / Crane) as the only physics stage. It stays campaign/solo only.

**Walker summary.** Five modules need characters on blocks: `bridge_dash`, `summit_climb`, `stair_path`, `route_runner` and `floe_survive`.
- One `GridWalker` (sim) plus one `WtWalkerView` (view over `WtToyActor`) covers all five.
- Building it once is the main reason `summit_climb` and `bridge_dash` rank high in §4.

---

## 3. Head-to-head

### 3.1 Runtime

MG37–50 are **BoardSim levels with a `modules` block** (a `versus` template carries a `level{}`, as the 4 versus modes already do). They are **not** `WtMinigameSession` rules scripts. That keeps one module implementation for campaign and versus.

A new `src/game/modes/wt_versus_round.gd` (RefCounted) generalises today's `_rivals`/`_bots` arrays in `main.gd` and the `_network_sims` loop:

```
WtVersusRound
  seats: Array[WtSeat]        # WtSeat {index, sim: BoardSim, controller: StringName (&"human"|&"bot"|&"net"), bot: WtBotPlayer, name}
  shared: WtSharedArena       # optional cross-seat state (3.2), null for mirrored rounds
  setup(level_source: Dictionary, round_seed: int, players: Array, catalog) -> bool
  step() -> Array[SimEvent]   # local seat's events; steps seats in ascending index (deterministic order)
  results() -> Array[Dictionary]   # same row shape as minigame_round.gd so WtModes.record_round is unchanged
  takeover(index) / release(index) # disconnect -> bot at current state (GDD rule 4)
```

- **Seed.** Every seat is built as `BoardSim.new(level, round_seed, catalog)`, matching LAN (`main.gd:938`). Sends and steals use the existing `CMD_RECEIVE_ITEM` (host-generated) path.
- **Lockstep.** Local seats step once per fixed tick. LAN keeps the `_on_network_frame` lockstep; `WtVersusRound` replaces that loop body.
- **Takeover.** It is trivial because seat state *is* the sim: swap `controller` to `&"bot"`, which matches the GDD.

### 3.2 Shared arenas

BoardSim has one active piece, so "shared" means **mirrored boards plus a shared scalar**, owned by `WtSharedArena` and applied between steps through host-generated commands:

| Template | Shared state | Mechanism |
|---|---|---|
| MG46 Kraken (shared boss) | Boss HP pool | Each seat's `boss_hp` metric delta is summed into the pool. The arena pushes the pool value back as `CMD_RECEIVE_ITEM {effect: boss_hp_set}`. Score = own damage. |
| MG39 Island Claim | Owned % per seat on a common map | Each seat paints its own copy. The arena computes the comparison and sends "steal" cell batches as items. *A visually shared island is a view trick: the local seat sees rival claims as tinted overlays.* |
| MG50 Slippery Sumo | Push events | A seat's shove (clear or lock event) becomes a shove item on the neighbouring seat's walker. The seats are not literally on one floe. |
| MG44 gem vein | Gem cells | Gems are removed in all seats when the first one collects them. |

A true single-board multi-piece arena (several players dropping on one board) would need BoardSim multi-piece support. **Out of scope. Do not promise it from the mockups.**

### 3.3 Bots

- Extend `WtBotPlayer._plan` scoring with `value += module.bot_value(landed, api)`, using the active primary's hint (the director exposes `active_primary()`). Examples:
  - `bridge_dash` rewards cells on the gap row;
  - `summit_climb` rewards cells within `climb_reach` ahead of the walker;
  - `boss_hp` rewards completing planes;
  - `balance_plate` penalises COM offset.
- **Skill (F2):**
  - `THINK_TICKS = lerp(72, 21, skill)` (1 200 → 350 ms at 60 Hz).
  - Placement error: with probability `err(skill)` pick the 2nd/3rd-best candidate, using `Seeds.make_rng(round_seed, ["bot", seat])`. Never global RNG.
  - Today `THINK_TICKS`/`STEP_TICKS` are consts; make them instance fields.
- **Beehave.** The bot already executes through `RuleRuntime` (Beehave, manual tick). For modules with extra verbs (fort aim, ring tap, defuse), replace the single leaf with a small tree: `Selector[ModuleVerb (condition: module wants tap/aim) → issue CMD_TAP, PlacePiece]`. Keep it manual-ticked from `WtVersusRound.step()`, never SceneTree-processed.

### 3.4 Presentation (Mobile)

- **Local seat:** a full `WtStage`.
- **Rivals, default on phones: 2D mini-boards.** `src/ui/versus/wt_mini_board.gd` (`Control`, `_draw`) renders each rival's column-height map plus the walker/boss marker and module meter, updated from `CELLS_CHANGED` deltas.
  - About 0 GPU cost, no extra 3D pass.
  - Matches the "player card + progress" layout in mockups 12–14.
- **Rivals, optional on tablets: 3D minis.** One `SubViewport` per rival with a reduced `BoardView` (no island, no shadows, about 256 px). Use `UPDATE_WHEN_VISIBLE` with frame-skipping (manually toggle `UPDATE_ONCE` every 4th frame). Each is a full 3D render pass, so cap it at 3 rivals and feature-gate it by device tier. *Unverified:* whether `BoardView` can run without `WtStage`.
- **Local split-screen (2–4 humans on one device):** one `SubViewportContainer` per seat, each with its own `WtStage`. Defer to ADR-0009 (not read). Expect it to be the most expensive mode on Mobile; profile before committing.

---

## 4. Build order (best reuse-to-impact)

Step 0, prerequisite (about 4–5 d): the module runtime.
- Includes `LevelModule`, `ModuleDirector`, `ModulesGoal`, `ModulePlan`, the loader/validator branch, BoardSim changes A–D, the meter rack and the phase banner.
- Prove it with a 2-phase test level.

| # | Module | Why first | Reuse | Campaign / versus impact | Est. |
|---|---|---|---|---|---|
| 1 | `clear_layers` | Smallest real primary; validates the runtime, the phase chain and the HUD without new mechanics | `clear_n`, `stopwatch` | 3 biomes + 2 bonus, MG40 | 1 d |
| 2 | `boss_hp` | Finale of 8 of 11 biomes; big spectacle from existing parts | `bonk_boss`, `storm_bolt`, existing `_boss` toy actor | 8 L10 finales, MG46 (proves the shared-scalar arena) | 2–3 d |
| 3 | `summit_climb` | Builds `GridWalker` + `WtWalkerView`, which unlock 4 more modules | `vines`, F6 | 5 biomes (Ice, UW, Lava, Forest, Celestial), MG42; the most-drawn mockup concept | 5 d (incl. walker) |
| 4 | `bridge_dash` | Second walker consumer; Meadow (first biome) needs it by L05 | walker, `request_mask`, `build_race` | Meadow, Ice, Lava, MG37; 5 mockups | 2–3 d |
| 5 | `rising_hazard` (O1) | The overlay that turns climb/bridge into the mockup "Lava Rise" drama | `rising_silt` (+ `snowball` skin) | 4 biome overlays, MG37/MG42 | 2 d |

Next in line:
- `balance_plate`: grid F4, 5 appearances.
- `route_runner`: reuses the walker; Meadow R.
- `dig_down`.

Last:
- `fort_siege`, `road_race` and `floe_survive`: H, the largest view/camera cost.

---

## 5. Risks and open questions

1. Change A alters BoardSim's outcome path. Every existing goal must still pass its tests. Gate it behind the opt-in `ticks()` and `LOST` handling only for `modules`.
2. The `module` rank (5) in `_sort_rules` puts composed rules after `mechanic`. Confirm with lead-programmer that composed hazards should observe mechanic writes, not precede them.
3. `carry: shift` combined with masked boards: `move_cells` across inactive columns is not verified.
4. `WtToyActor` pose coverage for walk/climb/fall is unverified.
5. MG37–50 as BoardSim levels means `WtModes.record_round` receives rows from `WtVersusRound` instead of `WtMinigameRound`. The row shape must match (`minigame_round.gd:86-97`).
6. The engine-reference deprecated/breaking files were not re-checked in this pass. No new engine API is proposed. Re-check if 3D-mini `SubViewport` update modes are used.
