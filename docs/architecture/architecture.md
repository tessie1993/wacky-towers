# Wacky Towers — Master Architecture Plan

> **Status**: Accepted (2026-10-10). ADR-0001–0017 Accepted (0011–0017 accepted by user 2026-10-10).
> **Date**: 2026-10-09 (revised 2026-10-10: master plan after `architecture-review-2026-10-10.md` and the user's Wave 1 decisions)
> **Engine**: Godot 4.7.2, Mobile renderer, Jolt physics, GDScript only (C#/C++ only on a profiled hotspot, ADR-0008)
> **Platforms**: Android + PC/Steam, shipped together
> **Owner**: technical-director; godot-specialist (lead architect), engine-programmer, godot-gdextension-specialist, network-programmer

Every number here is a **tunable default** that lives in data, not a fixed rule. Folder paths: `architecture-modular-layout.md` is authoritative.

## 1. Principles

1. **Modular, data first, minimal hardcoding** (standing user instruction, 2026-10-09). New mechanics, twists, minigames, clear rules, arrival styles, goals, top-out rules, board kinds, layouts and content types are added **without editing core code**:
   - **Values** live in JSON data: knob tables, rule definitions, levels, content types, palette, biomes (ADR-0005). Core code reads knobs by id and holds no tuning numbers.
   - **Behaviours** are pluggable GDScript classes found by id through the **plugin registry** (ADR-0004). Core code knows only the plugin base classes.
   - **Minigames** are separate scenes found through minigame data entries (ADR-0004 section 9).
   - Core code changes only when a new *kind* of extension point is needed. That is an ADR change.
2. **Pure, deterministic simulation.** Rules run in a `BoardSim` (RefCounted, fixed 60 Hz integer-ms tick, integer-only math). Commands in, events out. Nodes only draw (ADR-0001).
3. **One rule runtime.** Every rule change goes through knobs, hooks, vetoes and strategy slots (ADR-0004). **Anything that changes the board is a `RuleRuntime` rule inside `BoardSim`**, including level events and mascot actions; beehave trees only stage and animate (ADR-0011). Replays stay deterministic.
4. **Untrusted data never runs code.** Levels are JSON and are validated before anything is allocated (ADR-0003, ADR-0005).
5. **Dependency injection, few autoloads.** Every autoload is listed in §4 with its ADR. A new one needs an ADR row there.
6. **GDScript first.** A hot path moves to C++ only after a device profile proves the need, behind the same coarse packed-array API, with a GDScript twin and parity tests (ADR-0008).
7. **Platform seams, not platform branches.** Steam, haptics, store/monetization and cloud save sit behind feature-tagged GDScript wrappers with no-op twins (ADR-0008 amendment 1). No monetization or analytics SDK in MVP.
8. **All player text is translation keys** (English only in MVP). Reduced motion follows the OS setting; button scale 75–200 %, min 56 dp (ADR-0016).

## 2. Layers

```
 DATA        assets/data/**.json (levels, mechanics, knobs, content, biomes, palettes, input, credits)
             assets/data/shapes/shape_bank.tres (generated from block GLBs)
                │ DataLoader + LevelValidator (0005)            PluginRegistry (0004)
                ▼                                                     │ ids → scripts
 SIM (core)  BoardSim per player, RefCounted, fixed tick  ◀───────────┘
               ├ BoardState ×1..n (0002)   ├ Shapes/Orientations (0003)   ├ Seeds (0006)
               ├ RuleRuntime: knobs · hooks · vetoes · slots (0004) + level events/mechanics (0011)
               └ LevelPhase + level clock (0010)
                │ Array[SimEvent]                         ▲ SimCommand(tick)
                ▼                                         │
 FRAMEWORK   Main ─ AppFlow (Orchestrator graph: screen stack, Back, lifecycle, threaded loads) (0010)
 (game)        ├ PlaySession (Orchestrator graph: Intro/Paused/ResumeBeat/Results) (0010)
               │   └ BoardController (Node, _physics_process, steps the sim) ─┤
               ├ Input: InputEvent → GUIDE contexts → gestures → SimCommand (0012)
               ├ ProfileStore / SettingsStore: user://, versioned, cloud seam (0013)
               └ Platform wrappers: SteamService (PC only), Haptics (0008 am.1)
 PRESENTATION  BoardView: MultiMesh + piece GLB + previews (0007) · CameraRig: PhantomCamera,
 (view, ui)    orientation, safe area (0014) · Audio + feel/VFX (0015) · Screens/HUD/theme,
               P/L layouts, painted-wood frame set per biome (0016) · beehave staging trees (0011)
 LEVELS      levels/<biome>/<id>/<id>.tscn (dressing, mascot spots, optional staging trees) + <id>.json
 TOOLS       addons/wt_level_tools/ EditorPlugin dock: atom form, live LevelValidator, test-play (0017)
 POST-MVP    MatchClient ⇄ NetSession ⇄ TournamentHost (0009) · minigame scenes · Physics Mode
```

## 3. Module map

| Module (`src/…`) | Role | Owning ADRs | May import (summary; full table in modular-layout §3) |
|---|---|---|---|
| `core/rng`, `core/shapes`, `core/board` | Pure value logic | 0006, 0003, 0002 | nothing |
| `core/model` | Plain value types (`LevelData`, `SimEvent`, `LevelResult`…) | 0001, 0005, 0010 | `core/board`, `core/shapes` |
| `core/rules` | Knob registry, rule runtime, plugin registry, plugin bases, `RuleApi` | 0004, 0011 | `core/*` below it |
| `core/sim` | `BoardSim`, spawner, movement, replay, `StarRater`, level phases | 0001, 0010 | all `core/*` |
| `data` | JSON read, load, migrate, validate | 0005 | `core/*` |
| `mechanics` | Plugins only (slots, twists, level events, skills, perks, potions) | 0004, 0011 | `core/rules`, `core/board`, `core/shapes`, `core/model` |
| `view` | Board rendering, camera rig, shaders | 0007, 0014 | `core/*` read-only |
| `ui` | Screens, HUD, theme, layouts | 0016 | `core/model` value types |
| `game` | Framework: `Main`, `AppFlow`, `PlaySession`, `BoardController`, input, profile, platform wrappers, audio director | 0010, 0012, 0013, 0015, 0008 am.1 | everything except `levels` |
| `levels` | One folder per level (scene + JSON) | 0005, 0011 (staging trees) | `game/level/LevelStage` only |
| `dev`, `tools`, `tests` | Never shipped | 0017 (`addons/wt_level_tools/`) | anything |
| `net`, `minigames`, `native` | Not created until their epics | 0009, 0004 §9, 0008 | — |

Layering is enforced by `tests/unit/architecture/layering_test.gd`. Orchestrator files may exist only in `src/game/` (ADR-0010).

**Adopted add-ons and tools** (each with a `credits.json` entry): gdUnit4 (tests), godot-ci, Orchestrator (flow, 0010), GUIDE (input, 0012), phantom_camera (0014), beehave (staging, 0011), GodotSteam (PC only, 0008 am.1), kenyoni QR (0009), Kenney CC0 art, rFXGen/jsfxr sounds; webrtc-native later (0009). Rejected: godot_state_charts (0010). **Export note:** the export filter must include `*.json`; an export smoke test checks it.

## 4. Autoloads

| Autoload | Ships in release? | Purpose | ADR |
|---|---|---|---|
| `GUIDE` | Yes | Input contexts and action mapping (touch, keyboard/mouse, gamepad) | 0012 |
| `PhantomCameraManager` | Yes | PhantomCamera host for the camera rig | 0014 |
| `BeehaveGlobalMetrics`, `BeehaveGlobalDebugger` | **No** (debug only) | beehave debugging; staging trees run without them | 0011, 0008 am.1 |
| `_mcp_game_helper` (godot_ai), `MCPRuntimeServer` (godot_mcp_toolkit) | **No** (dev only) | AI/MCP editor-runtime bridge | 0008 am.1 |
| `NetSession` | Post-MVP | Owns the `MultiplayerPeer` | 0009 |

Not autoloads, by decision: `AppFlow` and `PlaySession` (nodes under `Main`, ADR-0010); `ProfileStore`/settings (owned by `Main`, injected; ADR-0013); audio director (ADR-0015); `SteamService` (wrapper on `Main`, PC only, ADR-0008 am.1). An export smoke test fails a release build that contains a dev/debug autoload.

## 5. ADR index

| ADR | Title | Layer | Status | Depends on |
|---|---|---|---|---|
| [0001](adr-0001-logic-visual-split-tick.md) | Logic/visual split and tick model | Foundation | Accepted | — |
| [0002](adr-0002-board-data-model.md) | Board data model (6-way gravity, overlays, multiple boards) | Foundation | Accepted | 0001 |
| [0003](adr-0003-shape-bank-orientation.md) | Shape bank and orientation math | Foundation | Accepted | — |
| [0004](adr-0004-rule-twist-runtime.md) | Rule-twist runtime and plugin registry (**owns knob/rule/plugin schemas**) | Core | Accepted | 0001, 0002, 0006 |
| [0005](adr-0005-data-format-validator.md) | Data format (JSON) and validator | Core | Accepted | 0003, 0004 |
| [0006](adr-0006-rng-seeds.md) | RNG and seeds | Foundation | Accepted | — |
| [0007](adr-0007-block-rendering.md) | Block rendering | Presentation | Accepted | 0001, 0002, 0003 |
| [0008](adr-0008-gdscript-cpp-gdextension-android.md) | GDScript first, C++ on profiler evidence (+ amendment 1: PC/Steam, export hygiene) | Foundation | Accepted | 0001, 0002 |
| [0009](adr-0009-local-multiplayer.md) | Local multiplayer, one phone per player | Feature (post-MVP) | Accepted | 0001, 0004, 0005, 0006 |
| [0010](adr-0010-level-flow-app-lifecycle.md) | Level flow and app lifecycle (Orchestrator) | Core | Accepted | 0001 |
| [0011](adr-0011-mechanic-level-event-runtime.md) | Mechanic and level-event runtime (rules in sim, beehave staging) | Core | Accepted | 0001, 0002, 0004, 0005, 0006, 0010 |
| [0012](adr-0012-input-pipeline.md) | Input pipeline: touch + keyboard/mouse + gamepad (GUIDE) | Foundation | Accepted | 0001, 0010 |
| [0013](adr-0013-save-profile-settings.md) | Save, profile and settings | Core | Accepted | 0005, 0010 |
| [0014](adr-0014-camera-orientation-safe-area.md) | Camera rig, orientation and safe area (phantom_camera; free orbit settling on 12 × 30° steps) | Presentation | Accepted | 0001, 0007, 0010 |
| [0015](adr-0015-audio-feedback-pipeline.md) | Audio and feedback pipeline | Presentation | Accepted | 0001, 0005, 0010 |
| [0016](adr-0016-ui-architecture.md) | UI architecture (screens, navigation, theming, P/L layouts) | Presentation | Accepted | 0001, 0010 |
| [0017](adr-0017-level-maker-tooling.md) | Level-maker tooling (EditorPlugin) | Tools | Accepted | 0002, 0004, 0005, 0010, 0011 |

Dependencies for 0011–0017 are taken from each ADR's own "Depends On" row (2026-10-10); the ADR wins if they diverge.

```
0006 RNG ───────────────┐
0003 Shapes ────────────┤
0001 Tick ─▶ 0002 Board ─▶ 0004 Rules ─▶ 0005 Data/Validator ─▶ 0013 Save · 0015 Audio
  │            └──▶ 0007 Rendering ─▶ 0014 Camera
  ├──▶ 0010 Flow ─▶ 0012 Input · 0013 Save · 0014 Camera · 0015 Audio · 0016 UI
  ├──▶ 0011 Level events (0002, 0004, 0005, 0006, 0010) ─▶ 0017 Level maker (also 0002, 0004, 0005, 0010)
  ├──▶ 0008 Native/platform
  └──── 0004/0005/0006 ─▶ 0009 Multiplayer (post-MVP)
```

The former 0004 ↔ 0005 cycle is broken (review 2026-10-10, option 1): 0004 owns the schemas, 0005 depends on 0004, and `RuleRuntime` consumes already-validated data as an interface.

**Post-MVP ADRs** (numbered when written, 0018+): Physics Mode on Jolt · Shared-device split screen (or a 0009 addendum) · Cloud save (fills the 0013 seam; native plugins vs 0008) · Board history / undo · Music beat clock · Online play (WebRTC, 0009 follow-up) · Monetization (only if decided; seam in 0008 am.1) · Daily box-of-tricks generator (if it needs more than 0005/0006).

## 6. One tick, step by step

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

## 7. Extension recipes: "how to add a new X"

Each recipe touches only the files listed. If a recipe ever needs a core edit, stop and raise an ADR change.

> **Folder paths**: the buildable paths are in `architecture-modular-layout.md` §2 (`src/mechanics/slots/<slot>/`, `src/mechanics/<id>/`, `assets/data/mechanics/<id>.json`) and win over the shorter paths below.

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
| **Control verb** (swap, tap-pop, pull and re-place, chisel, tube move, board slide, tray drag-to-place) | A `ControlVerb` plugin that turns gestures into `SimCommand`s and applies them through `RuleApi`, plus its tags and a `control.verb` choices entry. Default is `piece` | `src/gameplay/verbs/<id>.gd`, `assets/data/knobs/controls.json` |
| **Mechanic atom** (any slot in `design/gdd/mechanics-module.md`) | Find its slot. Board/Layout, Arrival, Control Verb, Clear, Collapse, Goal and Fail atoms are plugins of that slot's base. Placement, Scoring, Interaction, Events and Special-piece atoms are `RuleBehaviour`s and/or content types. Give it compatibility tags (`requires`/`provides`). A new tag or conflict pair goes in `atom_tags.json`. Add a test | the plugin or rule files above, `assets/data/atom_tags.json` |
| **Level built from atoms** | Write the `recipe` array (slot → atom), plus optional `story` with translation keys. The validator checks tag compatibility | level JSON |
| **Daily "box of tricks" pool** | Mark atoms and parameter ranges as daily-eligible in their data. The generator seeds from `["daily", date]` and re-rolls invalid mixes | atom data, `assets/data/knobs/daily.json` |
| **Piece router** (which board or lane gets the piece) | A `PieceRouter` plugin, plus a choices entry | `src/gameplay/layout/`, knob JSON |
| **Board kind** (grid, physics) | A `BoardKind` plugin that speaks the same `SimCommand`/`SimEvent` contract | `src/gameplay/board_kinds/<id>/` |
| **Layout** (floating islands, lanes, track) | A `LayoutKind` plugin that places, links and validates boards. Levels use `layout.kind` plus a `boards[]` list with `transform` and `links` | `src/gameplay/layout/<id>.gd` |
| **Island or board shape** (ring, plus, lane strip) | Data only: the board `mask`, size and down axis in the level | level JSON |
| **Content type** (obstacle, object, overlay, status) | A content JSON entry (`slot`, `solid`, `fills_layer`, mesh, look kind). Behaviour, if any, is a `RuleBehaviour` | `assets/data/content/*.json` (+ rule) |
| **Status look** | Reuse a look kind in data. A new kind is one shader branch | `assets/data/content/statuses.json` (+ shader) |
| **Level** | Official: a level scene inheriting the base level scene (diorama, board anchor, mascot spots) that points at its level JSON; player/daily: the JSON only, on the generic scene. CI validates both (implementation plan §2.2) | `src/levels/<biome>/<id>/<id>.tscn` + `<id>.json` (one folder per level; ADR-0005 amendment 2026-10-10) |
| **Biome / diorama dressing** | A biome JSON naming its dressing scene, props and default palette | `assets/data/biomes/<biome>.json`, scene |
| **Block set** (art) | Export GLBs with the naming convention. Tests check them against the shape bank | `assets/models/blocks/<set>/` |
| **Shape** | Model it, export it, then rerun `extract_shape_bank.gd` and fill in the hand fields | GLBs, `shape_bank.tres` |
| **Knob** | Add an entry to the owning system's knob JSON. Code reads it by id | `assets/data/knobs/<system>.json` |
| **Hook point** | Call `runtime.run_hook(&"on_x", ctx)` from the system that owns the moment, and list it in ADR-0004 | owning system |
| **Minigame** | Make a scene with its own root script, plus a minigame JSON (`scene`, players, `standing` id, weights). It reuses `BoardSim`, `BoardState`, `ShapeBank` and `Seeds` as a library. Network uses generic `mg_event`/`mg_state` with its own kind table (ADR-0009) | `src/minigames/<id>/`, `assets/data/minigames/<id>.json` |
| **Standing rule for item rolls** | A `StandingFn` plugin, named in the minigame or round data | `src/gameplay/standing/<id>.gd` |
| **Network message** | Append a message type. Readers ignore unknown types and trailing bytes; anything else bumps `proto_ver` (ADR-0009) | `src/net/` |
| **Player-visible text** | Add a translation key to the translation CSV and use the key in data | `assets/i18n/*.csv` |
| **Third-party asset or add-on** | Add the files, then add a `credits.json` entry (licence, author, source). A test enforces the entry | `assets/data/credits.json` |
| **Native hot path** | Profile first. Then a `Wt<X>` GDExtension class with the same API as its GDScript twin, chosen by the factory, with parity tests (ADR-0008) | `src/native/` (later) |

Discovery: a plugin is any `class_name` script whose base chain reaches a plugin base class and that declares `const PLUGIN_ID`. `PluginRegistry` finds it with `ProjectSettings.get_global_class_list()`. If that fails in an Android export, the fallback is a generated `plugins.json` (ADR-0004).

## 8. Platform matrix

| Concern | Android (phone/tablet) | PC / Steam (Windows x86_64) | ADR |
|---|---|---|---|
| Ships | MVP, with PC | MVP, with Android | 0008 am.1 |
| Renderer | Mobile | Mobile (same look on both) | 0007 |
| Input | Touch (primary); gamepad if connected | Keyboard/mouse + gamepad; touch not required | 0012 |
| Orientation | Portrait and landscape, rotate-pause mid-level | Landscape window; portrait layout if the window is taller than wide | 0014, 0016 |
| Safe area / notch | Yes | No (window insets = 0) | 0014 |
| Back | System Back / gesture → `AppFlow.back()` | Esc / gamepad B → same | 0010 |
| Lifecycle pause | `FOCUS_OUT`, `APPLICATION_PAUSED` | Window focus out → pause | 0010 |
| Haptics | Device vibration (rate-limited) | Gamepad rumble; off on keyboard | 0015 |
| Save | `user://`, local, versioned | `user://`, local, versioned; Steam Cloud later via the 0013 seam | 0013 |
| Steam | GodotSteam **excluded** (feature tag, export filter) | GodotSteam via `SteamService`, no-op without Steam | 0008 am.1 |
| Native modules shipped | Orchestrator `.so` (arm64) | Orchestrator `.dll`, GodotSteam `.dll` | 0008 am.1, 0010 |
| Dev/AI autoloads | Stripped from release | Stripped from release | 0008 am.1 |
| Monetization / analytics | None (seam only) | None | 0008 am.1 |

## 9. Performance budget (flagship phone + PC)

Target device is a **flagship phone** (and PC); the Mobile renderer stays. Budgets are tunable defaults (performance values live in `project.yaml` / knob data) and are measured on the reference phone (a recent Samsung Galaxy S), which is the binding target; PC must meet the same numbers on a modest GPU.

| Metric | Budget | Source / owner |
|---|---|---|
| Frame rate | 60 fps sustained (120 fps optional setting on capable phones) | 0001, 0015 governor |
| Frame time | ≤ 16.6 ms total | — |
| Sim + rules per tick | ≤ 2 ms (all boards of one player) | 0001 |
| View/UI CPU per frame | ≤ 4 ms | 0007, 0016 |
| GPU per frame | ≤ 10 ms | 0007 |
| Draw calls | ≤ 200 per frame | 0007 §7 |
| Triangles on screen | ≤ 500k (diorama + boards) | 0007 §7 |
| Live particles | ≤ 1 500, oldest evicted first; fps-based quality governor | 0015 |
| Audio voices | ≤ 32 simultaneous | 0015 |
| RAM (Android) | ≤ 1.0 GB resident | — |
| Texture memory | ≤ 512 MB | technical-artist |
| Preview atlas | ≤ 4 MB | 0007, review (HUD flag) |
| Install size | ≤ 200 MB (APK/AAB per ABI; PC depot similar) | 0008 am.1 |
| Cold boot → Title | ≤ 3 s | 0010 |
| Tap island → level Intro | < 500 ms (threaded load + prefetch + shader warm-up) | 0010, 0007 |
| Input → applied | ≤ 1 sim tick (≤ 17 ms) + 1 frame | 0001, 0012 |
| Thermal | 20-minute session holds ≥ 55 fps on the reference phone | performance-analyst |
| Save write | Off the main thread; never blocks a frame | 0013 |

Budget table approved by the user 2026-10-10 as tunable defaults. MVP ships 4 save profiles (ADR-0013), so the UI list gains a Profile select screen (ADR-0016).

## 10. Build order (tied to `production/orchestration/meadow-mvp-plan.md`)

| Plan phase | Architecture work that must be ready | ADRs |
|---|---|---|
| 0 Regroup | Housekeeping: `credits.json`, `*.json` export filter, translation CSV stub, godot-ci; export presets for Android + PC with dev/AI autoload stripping and GodotSteam excluded from Android | 0005, 0008 am.1 |
| 1 Design gaps | GDD revision flags from the review (tick wording, fixed-point formulas, ADR slot ids, board caps) | 0001, 0002, 0004, 0005 |
| 2 Assets | Block GLBs against the shape bank; asset budgets from §9 | 0003, 0007 |
| 3 Core loop (B1–B5) | RNG → shapes → board → data/validator → sim + tick + level phases → rule runtime → view, camera, input. Ends: meadow_01 won + lost by `input_simulate` | 0001–0007, 0010 (phases), 0012, 0014 |
| 4 Menus + flow | **Gate first: Orchestrator Android-export smoke test** (fallback: plain GDScript). Then `AppFlow`, `ScreenStack`, `PlaySession`, Back, pause, threaded loads; screens, theme, P/L layouts | 0010, 0016, 0012 |
| 5 Save/stars/unlocks | `ProfileStore`, settings, atomic writes, stars keyed by level id + version, cloud seam | 0013 |
| 6 Levels | Level events and mechanics as `RuleRuntime` rules; beehave staging trees per level; level maker dock when authoring pain shows | 0011, 0004, 0005, 0017 |
| 7 Audio | Buses, event → cue map, layered music, haptics | 0015 |
| 8 Feel/VFX | Particle budget + eviction, quality governor, shader warm-up | 0015, 0007 |
| 9 QA + gate | Device runs on the flagship phone **and** a PC/Steam build; §9 budgets measured; release exports checked for stripped autoloads | all |

Post-MVP (after the gate): multi-board layouts as levels need them → multiplayer (0009) → minigames → Physics Mode → native hot paths only on profile evidence.

## 11. Multiplayer in brief (ADR-0009, post-MVP)

- **Host and boards.** One phone hosts the tournament (`TournamentHost`), and every phone simulates only its own board. There is no lockstep. Pieces are never sent, because the shared `round_seed` produces the same pieces on every phone.
- **Transport.** ENet over `SceneMultiplayer` with byte-message RPCs.
- **Joining.** Players join from a nearby list (UDP broadcast), by a 4-character room code, or by QR code. Android comes first. Online play later uses peer-to-peer WebRTC, with the same messages.
- **The leader.** Debuffs target the player with the most points. Rejoining keeps the player's seat and wins.

## 12. Decisions the architecture team made (no gameplay change)

| Decision | Where |
|---|---|
| Integer-only gameplay math; scalar knobs are fixed-point milli-units. This keeps cross-device re-simulation possible later | 0001, 0004, 0009 |
| Unknown keys in level JSON are errors; format changes go through `schema` | 0002, 0005 |
| `on_enter` hook added for non-solid content displaced by a lock | 0002, 0004 |
| Multiple boards per level: each board stays a box, joined by data `links`. Layout and routing are plugins | 0002 §7, 0004, 0005 |
| The board stores hue ids; colours come from `palette.json` | 0002, 0003, 0007 |
| Visual tunables and status looks are data | 0007 §7 |
| Control verb is a slot (`control.verb`, `ControlVerb` base, default `piece`). Scoring atoms are `RuleBehaviour`s with no slot | 0004 |
| Atom compatibility tags (`requires`/`provides`, conflict pairs in `atom_tags.json`) extend `incompatible_with` | 0004, 0005 |
| Level JSON gets optional `recipe` and `story`. The daily generator uses the `recipe` path and the same validator | 0005, 0006 |
| Shared-board atoms are parked: minigames are always competitive | 0004 |
| All player-visible text in data is translation keys. Player levels may carry literal escaped text | 0005 |
| No float noise feeds the sim | 0006 |
| QR is generation-only (kenyoni). Scanning uses the system camera. webrtc-native is a later binary dependency | 0009 |
| Asset credits JSON from day one, enforced by a test | 0005 |
| Attack randomness uses its own RNG stream keyed by `instance_id` | 0006, 0009 |

**Wave 1 user decisions (2026-10-10), recorded here and in the ADRs named:**

| Decision | Where |
|---|---|
| Orchestrator for menus/level flow; godot_state_charts rejected (removed in a later step) | 0010 |
| beehave = staging/animation only; board changes are `RuleRuntime` rules in `BoardSim` | 0011 |
| Android + PC/Steam ship together; MVP input = touch + keyboard/mouse + gamepad | 0008 am.1, 0012 |
| Perks and potions active in every mode incl. solo campaign; edge perks in campaign + tournaments, sidegrades only in quick versus | 0004 (data), 0011 |
| Skills: big abilities; each skill's data declares its use rule (charge meter / once per level / consumable) | 0004 (data), 0011 |
| Third rotation pair (3 axes), taught in meadow_02 | 0003, 0012 |
| Level maker = dev-team EditorPlugin dock; atoms picked in a form; reads/writes level JSON; live validator; test-play; no AI button | 0017 |
| Save local only, versioned format, cloud seam; 4 save profiles in MVP (profile-select screen, 0016) | 0013, 0016 |
| Relaxed timing: all 3 stars, star times scaled, no badge | 0013, scoring data |
| Painted-wood UI frames per biome (Meadow first), free rounded fonts, custom painted icons | 0016 |
| No analytics; monetization undecided (design for none, seam only) | 0008 am.1 |

## 13. Open items

**For design (gameplay changes, escalated):**
- Does "most points" for the debuff leader mean this round's score or the whole tournament? (ADR-0009 open question 1; default this round.)
- Height limit and spawn zone when gravity is along x or z (ADR-0002 open item 1).
- Hard board size caps vs the GDD's "no maximum" (ADR-0002 open item 2; review flag).
- ADR-0002 amendments flagged by the review: colour-key id, per-cell item tag, `insert_layers(n)`.

**To verify on device (Android flagship + PC):**
- Orchestrator Android-export smoke test (0010 gate, before phase 4).
- `get_global_class_list()` in an Android export (0004).
- `*.json` packed and listable in the APK (0005).
- RNG goldens on Android (0006).
- MultiMesh layout, vertex budget, shader warm-up (0007).
- GodotSteam absent from the Android APK; dev/AI autoloads absent from both release builds (0008 am.1).
- UDP broadcast with MulticastLock (0009, post-MVP).

**Owned by peer ADRs:** QR scan option and online integrity (0009).
