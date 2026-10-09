# Wacky Towers — Architecture Overview

> **Status**: Proposed (all nine ADRs are `Proposed`; only the user, or technical-director on the user's confirmation, may accept them)
> **Date**: 2026-10-09
> **Engine**: Godot 4.7.2, Mobile renderer, Jolt physics, GDScript (C++ GDExtension later, only on profiler evidence)
> **Owner**: godot-specialist (lead architect), with engine-programmer, godot-gdextension-specialist, network-programmer

Every number in these documents is a **tunable default** that lives in data, not a fixed rule.

## 1. Principles

1. **Modular, data first, minimal hardcoding** (standing user instruction, 2026-10-09). New mechanics, twists, minigames, clear rules, arrival styles, goals, top-out rules, board kinds, layouts and content types are added **without editing core code**:
   - **Values** live in JSON data: knob tables, rule definitions, levels, content types, palette, biomes (ADR-0005). Core code reads knobs by id and holds no tuning numbers.
   - **Behaviours** are pluggable GDScript classes found by id through the **plugin registry** (ADR-0004). Core code knows only the plugin base classes.
   - **Minigames** are separate scenes found through minigame data entries (ADR-0004 section 9).
   - Core code changes only when a new *kind* of extension point is needed. That is an ADR change.
2. **Pure, deterministic simulation.** Rules run in a `BoardSim` that is a RefCounted object, with a fixed 60 Hz integer-ms tick and integer-only math. Commands go in and events come out. Nodes only draw (ADR-0001).
3. **One rule runtime.** Every rule change goes through knobs, hooks, vetoes and strategy slots, ordered by GDD priority (ADR-0004).
4. **Untrusted data never runs code.** Levels are JSON and are validated before anything is allocated. `.tres` files are used only for internal generated assets (ADR-0003, ADR-0005).
5. **Dependency injection, few autoloads.** The sim, rules, loader and validator receive what they need. The only planned autoload is `NetSession`, which owns the `MultiplayerPeer` (ADR-0009). `_mcp_game_helper` is a dev tool.
6. **GDScript first.** A hot path moves to C++ only after a device profile proves the need. It stays behind the same coarse packed-array API, keeps a GDScript twin, and must pass parity tests (ADR-0008).

## 2. Layers

```
 DATA      assets/data/**.json (levels, rules, knobs, content, biomes, minigames, palette)
           assets/data/shapes/shape_bank.tres (generated from block GLBs)
              │ DataLoader + LevelValidator (ADR-0005)        PluginRegistry (ADR-0004)
              ▼                                                      │ ids → scripts
 SIM       BoardSim (per player, RefCounted, fixed tick)  ◀──────────┘
             ├ BoardState ×1..n (ADR-0002)   ├ Shapes/Orientations (ADR-0003)
             ├ Spawner + Seeds (ADR-0006)    └ RuleRuntime: knobs · hooks · vetoes · slots (ADR-0004)
              │ Array[SimEvent]                      ▲ SimCommand(tick)
              ▼                                      │
 NODES     BoardController (Node, _physics_process) ─┤
             ├ BoardView ×n: MultiMesh + piece GLB + previews (ADR-0007)
             ├ HUD / Audio / Game Feel
             ├ Touch input + Camera → SimCommand
             └ MatchClient ⇄ NetSession (autoload) ⇄ TournamentHost (ADR-0009)
 SCENES    Campaign level scene · Arcade · Tournament · Minigame scenes (own loop; reuse SIM as a library)
```

## 3. The nine ADRs

| ADR | Title | Layer | Owner | Depends on |
|---|---|---|---|---|
| [0001](adr-0001-logic-visual-split-tick.md) | Logic/visual split and tick model | Foundation | godot-specialist | — |
| [0002](adr-0002-board-data-model.md) | Board data model (6-way gravity, overlays, multiple boards) | Foundation | engine-programmer | 0001 |
| [0003](adr-0003-shape-bank-orientation.md) | Shape bank and orientation math | Foundation | godot-specialist | — |
| [0004](adr-0004-rule-twist-runtime.md) | Rule-twist runtime and plugin registry | Core | godot-specialist | 0001, 0002, 0005, 0006 |
| [0005](adr-0005-data-format-validator.md) | Data format (JSON) and validator | Foundation | godot-specialist | 0002, 0003, 0004 (schemas) |
| [0006](adr-0006-rng-seeds.md) | RNG and seeds | Foundation | godot-specialist | — |
| [0007](adr-0007-block-rendering.md) | Block rendering | Presentation | engine-programmer | 0001, 0002, 0003 |
| [0008](adr-0008-gdscript-cpp-gdextension-android.md) | GDScript first, C++ on profiler evidence | Foundation | godot-gdextension-specialist | 0001, 0002 |
| [0009](adr-0009-local-multiplayer.md) | Local multiplayer, one phone per player | Feature | network-programmer | 0001, 0004, 0005, 0006 |

```
0006 RNG ─────────────┐
0003 Shapes ──────────┤
0001 Tick ──▶ 0002 Board ──▶ 0004 Rules ◀──▶ 0005 Data/Validator
   │            │              │
   │            └────▶ 0007 Rendering
   ├────────────────▶ 0008 Native path (later)
   └──── 0004/0005/0006 ──▶ 0009 Multiplayer
```

0004 and 0005 refer to each other on purpose. The runtime defines the knob, rule and plugin schemas, and the validator checks levels against them. They are built together.

## 4. One tick, step by step

1. **Input.** Touch input, or a received network effect, becomes a `SimCommand` for the next tick.
2. **`BoardSim.step()`.** In order:
   1. Apply the commands. The `on_command` hook and vetoes run first.
   2. Run the `on_tick` hooks. Board writes they make are buffered.
   3. Run the gravity/travel step: the piece moves along its travel direction (any of 6) and `on_fall_step` runs. If a linked board face is reached, `LayoutKind` hands the piece to the next board.
   4. Rest and lock timers run as integer-ms deadlines. On lock: `on_enter`, then the cells are written, then `on_lock`.
   5. Resolving: the `clear.detector` slot finds the groups to clear. `on_clear` runs, then the `clear.collapse` slot, then `on_resolve_end`. Queued mask, down-axis and slot changes apply here. Resolving lasts the data-driven `t_resolve_ms`.
   6. The `goal.type` and `goal.top_out` slots run, then `on_goal_check`.
   7. The buffered writes are applied in priority order. The tick returns `Array[SimEvent]`.
3. **`BoardController`.** It re-emits the events as signals. `BoardView` applies the deltas, while HUD, audio and `MatchClient` (progress at `sync_hz`) react to them.

## 5. Extension recipes: "how to add a new X"

Each recipe touches only the files listed. If a recipe ever needs a core edit, stop and raise an ADR change.

| To add… | Do this | Files |
|---|---|---|
| **Twist that changes only numbers or forbids actions** | Write a rule JSON with `layer`, `icon`, `params`, `modifiers`, `vetoes`, and add an icon | `assets/data/rules/<id>.json`, icon |
| **Twist or mechanic with behaviour** (wind, conveyor, spawned objects) | Do the rule JSON with `"behaviour": "<plugin_id>"`. Add a `class_name X extends RuleBehaviour` script with `const PLUGIN_ID`, `subscribed_hooks()` and `handle()`, which works only through `RuleApi`. Optionally add a `validate()`. Add a unit test with a fake `RuleApi` | `src/gameplay/rules/<id>.gd`, rule JSON, `tests/unit/rules/<id>_test.gd` |
| **Item, buff, debuff, perk, skill** | The same as a twist, with `layer` set to `item_buff` or `perk` | as above |
| **Clear rule** (row, colour, colour-connect…) | A `ClearDetector` plugin, then add its id to the `clear.detector` choices in the knob JSON | `src/gameplay/clear/<id>.gd`, `assets/data/knobs/clearing.json` |
| **Collapse rule** (slice, cascade, none) | A `CollapsePolicy` plugin, plus a choices entry | `src/gameplay/clear/`, knob JSON |
| **Arrival style** (top, side then fall, side travel) | An `ArrivalStyle` plugin that returns spawn cells, orientation and `travel_dir`, plus a choices entry | `src/gameplay/arrival/<id>.gd`, `assets/data/knobs/spawn.json` |
| **Goal type** | A `GoalEvaluator` plugin, plus a choices entry | `src/gameplay/goals/<id>.gd`, `assets/data/knobs/goals.json` |
| **Top-out rule** (warnings, trim, lose) | A `TopOutPolicy` plugin, plus a choices entry | `src/gameplay/goals/`, knob JSON |
| **Piece router** (which board or lane gets the piece) | A `PieceRouter` plugin, plus a choices entry | `src/gameplay/layout/`, knob JSON |
| **Board kind** (grid, physics) | A `BoardKind` plugin that speaks the same `SimCommand`/`SimEvent` contract | `src/gameplay/board_kinds/<id>/` |
| **Layout** (floating islands, lanes, track) | A `LayoutKind` plugin that places, links and validates boards. Levels use `layout.kind` plus a `boards[]` list with `transform` and `links` | `src/gameplay/layout/<id>.gd` |
| **Island or board shape** (ring, plus, lane strip) | Data only: the board `mask`, size and down axis in the level | level JSON |
| **Content type** (obstacle, object, overlay, status) | A content JSON entry (`slot`, `solid`, `fills_layer`, mesh, look kind). Behaviour, if any, is a `RuleBehaviour` | `assets/data/content/*.json` (+ rule) |
| **Status look** | Reuse a look kind in data. A new kind is one shader branch | `assets/data/content/statuses.json` (+ shader) |
| **Level** | A level JSON file. CI validates it | `assets/data/levels/<biome>/<id>.json` |
| **Biome / diorama dressing** | A biome JSON naming its dressing scene, props and default palette | `assets/data/biomes/<biome>.json`, scene |
| **Block set** (art) | Export GLBs with the naming convention. Tests check them against the shape bank | `assets/models/blocks/<set>/` |
| **Shape** | Model it, export it, then rerun `extract_shape_bank.gd` and fill in the hand fields | GLBs, `shape_bank.tres` |
| **Knob** | Add an entry to the owning system's knob JSON. Code reads it by id | `assets/data/knobs/<system>.json` |
| **Hook point** | Call `runtime.run_hook(&"on_x", ctx)` from the system that owns the moment, and list it in ADR-0004 | owning system |
| **Minigame** | Make a scene with its own root script, plus a minigame JSON (`scene`, players, `standing` id, weights). It reuses `BoardSim`, `BoardState`, `ShapeBank` and `Seeds` as a library. Network uses generic `mg_event`/`mg_state` with its own kind table (ADR-0009) | `src/minigames/<id>/`, `assets/data/minigames/<id>.json` |
| **Standing rule for item rolls** | A `StandingFn` plugin, named in the minigame or round data | `src/gameplay/standing/<id>.gd` |
| **Network message** | Append a message type. Readers ignore unknown types and trailing bytes; anything else bumps `proto_ver` (ADR-0009) | `src/net/` |
| **Native hot path** | Profile first. Then a `Wt<X>` GDExtension class with the same API as its GDScript twin, chosen by the factory, with parity tests (ADR-0008) | `src/native/` (later) |

Discovery: a plugin is any `class_name` script whose base chain reaches a plugin base class and that declares `const PLUGIN_ID`. `PluginRegistry` finds it with `ProjectSettings.get_global_class_list()`. If that fails in an Android export, the fallback is a generated `plugins.json` (ADR-0004).

## 6. `src/` layout

```
src/
  core/
    sim/        board_sim.gd, board_controller.gd, sim_command.gd, sim_event.gd, replay.gd
    board/      board_state.gd, board_spec.gd, board_limits.gd, content_types.gd   (ADR-0002)
    shapes/     shape_def.gd, shape_bank.gd, orientations.gd                     (ADR-0003)
    rules/      rule_runtime.gd, knob_registry.gd, rule_api.gd, rule_instance.gd,
                plugin_registry.gd, bases/ (rule_behaviour, clear_detector, collapse_policy,
                arrival_style, goal_evaluator, top_out_policy, piece_router, board_kind,
                layout_kind, standing_fn)                                       (ADR-0004)
    rng/        seeds.gd                                                         (ADR-0006)
  data/         data_loader.gd, level_data.gd, level_validator.gd, level_migrations.gd (ADR-0005)
  gameplay/     rules/ clear/ arrival/ goals/ layout/ board_kinds/ standing/  ← plugins only
  view/         board_view.gd, piece_view.gd, preview_baker.gd, shaders/       (ADR-0007)
  input/        touch_controls.gd, camera_rig.gd
  ui/           hud/, menus/
  net/          net_session.gd (autoload), tournament_host.gd, match_client.gd, codec.gd (ADR-0009)
  minigames/    <id>/ (scene + scripts)
  app/          main.tscn, scene flow, save/profile
  native/       (empty until ADR-0008 triggers)
  dev/          block_set_preview (existing dev tool)
assets/data/    levels/ rules/ knobs/ content/ biomes/ minigames/ shapes/ palette.json
tools/asset-pipeline/  block_post_import.gd (existing), extract_shape_bank.gd
addons/wt_level_tools/ editor validator panel (planned, built when authoring needs it)
tests/unit/     sim/ board_grid/ shapes/ rules/ rng/ data/ gameplay/ net/
tests/integration/  level_flow/ multiplayer_loopback/
```

**Export note.** Add `*.json` to the export filter for non-resource files, or the data will be missing from the APK.

## 7. Build order

1. **RNG** (`Seeds`, FNV, goldens). Tests first.
2. **Shapes**: `Orientations` tables, extractor, `shape_bank.tres`, block-set test switched over to the bank.
3. **Board**: `BoardSpec` validation, `BoardState` queries and deltas, all 6 down axes.
4. **Data**: the JSON loader, knob JSON files, and a minimal `LevelValidator` (board, pieces, knobs).
5. **Sim and tick**: `BoardSim` with commands and events, spawner (bag), movement, fall/lock, the default slots (`layer` clear, `slice` collapse, `top` arrival, `clear_n` goal, `warnings` top-out), and replay. All headless and tested.
6. **Rule runtime**: knob F1 resolution, hooks, vetoes, lifetimes, plugin registry.
7. **View**: `BoardController`, debug MultiMesh with flat hue, piece GLB, ghost, camera, touch.
8. **meadow_01 end to end on an Android device**, with screenshot evidence.
9. **Meadow twists and mechanics** as plugins and data (wind, spawned objects, invisible, gravity flip, build race / trim, target shape, sticky, conveyor), then meadow_02 to meadow_10.
10. **Multi-board layouts** (islands, lanes) when the first level design needs them.
11. **Multiplayer**: loopback tests, then ENet on the LAN, discovery, room code, QR.
12. **Editor validator panel**, once there is pain in authoring levels.
13. **Alpha**: Physics Mode (`BoardKind` physics), minigame scenes, native hot paths only if profiling shows the need.

## 8. Multiplayer in brief (ADR-0009)

- **Host and boards.** One phone hosts the tournament (`TournamentHost`), and every phone simulates only its own board. There is no lockstep. Pieces are never sent, because the shared `round_seed` produces the same pieces on every phone.
- **Transport.** ENet over `SceneMultiplayer` with byte-message RPCs.
- **Joining.** Players join from a nearby list (UDP broadcast), by a 4-character room code, or by QR code. Android comes first. Online play later uses peer-to-peer WebRTC, with the same messages.
- **The leader.** Debuffs target the player with the most points. Rejoining keeps the player's seat and wins.

## 9. Decisions the architecture team made (no gameplay change)

| Decision | Where |
|---|---|
| Integer-only gameplay math; scalar knobs are fixed-point milli-units. This keeps cross-device re-simulation possible later | 0001, 0004, 0009 |
| Unknown keys in level JSON are errors; format changes go through `schema` | 0002, 0005 |
| `on_enter` hook added for non-solid content displaced by a lock | 0002, 0004 |
| Multiple boards per level: each board stays a box, joined by data `links`. Layout and routing are plugins | 0002 §7, 0004, 0005 |
| The board stores hue ids; colours come from `palette.json` | 0002, 0003, 0007 |
| Visual tunables and status looks are data | 0007 §7 |
| Attack randomness uses its own RNG stream keyed by `instance_id` | 0006, 0009 |

## 10. Open items

**For design (these change gameplay, so they are escalated):**
- Does "most points" for the debuff leader mean this round's score or the whole tournament? (ADR-0009 open question 1; the default is this round.)
- The height limit and spawn zone when gravity is along x or z (ADR-0002 open item 1).
- Hard board size caps compared with the GDD's "no maximum" (ADR-0002 open item 2).

**To verify on device:**
- `get_global_class_list()` in an Android export (0004).
- `*.json` packed and listable in the APK (0005).
- RNG goldens on Android (0006).
- The MultiMesh layout and vertex budget (0007).
- UDP broadcast with MulticastLock (0009).

**Owned by peer ADRs:**
- QR scan option (0009 recommends C, the system camera, first).
- Online integrity (0009, with security-engineer).
