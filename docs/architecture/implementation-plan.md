# Wacky Towers: Implementation Plan (framework + Meadow 01–10)

> **Status**: Active plan (dev-team owned; technical decisions are the architecture team's, per user instruction 2026-10-10)
> **Date**: 2026-10-10
> **Owner**: godot-specialist (lead architect)
> **Engine**: Godot 4.7.2, GDScript, Mobile renderer, Jolt (unused by the Meadow slice), gdUnit4 6.2.1
> **Builds on**: `architecture.md` and ADR-0001 to ADR-0009 (all Accepted by the user, 2026-10-10). The ADR changes this plan needed (§9) are applied.

This is the buildable plan: folders, classes, the scene tree, data files and an ordered story list that ends with **Meadow 01–10 playable on an Android phone**. It designs only what the Meadow slice needs, plus the extension points the ADRs already commit to. Everything else is listed as deferred in §8.

---

## 1. Module map

### 1.1 Layering (strict)

```
            app ──────────────────────────────────────────┐
             │ (assembles everything; owns scene flow)     │
   ui ── view ── input                                      │
     \    │      /     (read core state + SimEvents; never mutate sim)
      \   │     /                                           │
       data ───────────── (IO + parse + validate → core model types)
         │                                                  │
   gameplay (plugins only: extend core/rules/bases)         │
         │                                                  │
 core: sim ─▶ rules ─▶ model ─▶ board, shapes, rng  ◀───────┘
```

| Layer | May import (by `class_name`) | Must never import |
|---|---|---|
| `core/rng` | nothing | everything else |
| `core/shapes` | nothing | everything else |
| `core/board` | nothing | everything else |
| `core/model` | `core/board`, `core/shapes` | rules, sim, data, gameplay, view, input, ui, app |
| `core/rules` | `core/rng`, `core/shapes`, `core/board`, `core/model` | sim internals, data, gameplay, view, input, ui, app |
| `core/sim` | all of `core/*` | data, gameplay (only through `PluginRegistry`), view, input, ui, app |
| `data` | `core/*` | gameplay, view, input, ui, app |
| `gameplay` | `core/rules` (bases, `RuleApi`, `HookContext`, …), `core/board`, `core/shapes`, `core/model` | `core/sim` internals (`BoardSim`), data, view, input, ui, app |
| `view`, `input`, `ui` | `core/*` read-only getters, `SimEvent`, each other through signals | `data` writers, `gameplay` |
| `app` | everything | — |

- **Purity.** `core/*` and `gameplay/*` are `RefCounted` or `Resource` only: no `Node`, no signals, no `await`, no `Time`, no `OS`, no global RNG, no float noise (ADR-0001, ADR-0006).
- **Enforced by tests** (story FND-000): `tests/unit/architecture/layering_test.gd` reads `ProjectSettings.get_global_class_list()` to map every `class_name` to its folder, then scans each file under `src/core` and `src/gameplay` for whole-word uses of class names from a forbidden layer, and for the banned tokens `randi(`, `randf(`, `randomize(`, `Time.`, `OS.get_ticks`, `FastNoiseLite`, `await `, `extends Node`. A hit fails CI.
- **One deliberate change to `architecture.md` §6**: `LevelData` and the read-only catalogs move from `data/` to a new `core/model/`, so `BoardSim` can take a `LevelData` without core importing `data/`. `data/` keeps all IO, parsing and validation.

### 1.2 Folders, classes and public API

Signatures are binding for the coders. Every public method gets a `##` doc comment. `Down`, `Op` and `By` enums are from ADR-0002.

#### `src/core/rng/` (ADR-0006)

```gdscript
class_name Seeds extends RefCounted
static func derive(round_seed: int, parts: Array) -> int                 # 32-bit FNV-1a
static func make_rng(round_seed: int, parts: Array) -> RandomNumberGenerator
static func shuffle(rng: RandomNumberGenerator, items: Array) -> void      # Fisher–Yates from the end
static func weighted_pick(rng: RandomNumberGenerator, weights: PackedInt32Array) -> int
```

#### `src/core/shapes/` (ADR-0003)

```gdscript
class_name Orientations extends RefCounted
const COUNT := 24
enum Axis { X, Y, Z }
static func turn(o: int, axis: Axis, dir: int) -> int          # dir = +1 / -1
static func apply(o: int, v: Vector3i) -> Vector3i
static func matrix(o: int) -> Array[Vector3i]                   # 3 rows; tests only

class_name ShapeDef extends Resource                           # fields exactly as ADR-0003
func offsets(o: int) -> Array[Vector3i]
func bbox(o: int) -> Vector3i
func min_corner(o: int) -> Vector3i
static func canonical_key(offsets: Array[Vector3i]) -> String

class_name ShapeBank extends Resource
@export var shapes: Array[ShapeDef]
func get_shape(id: StringName) -> ShapeDef                      # null if unknown
func has_shape(id: StringName) -> bool
func ids() -> PackedStringArray
```

#### `src/core/board/` (ADR-0002)

```gdscript
class_name BoardLimits extends RefCounted                       # built from knobs/board.json values
var min_side: int; var max_side: int; var min_height: int; var max_height: int
var max_cells: int; var max_errors: int; var min_active_per_layer: int
var spawn_clearance: int                                        # C in board height = h_play + C (Board F4); LevelLoader sets it to L_max of the level's piece set

class_name JsonNum extends RefCounted                           # core/board/json_num.gd: the ONE whole-number rule for JSON floats
static func whole_int(v: Variant) -> Variant                    # int, or null if not a finite whole number; used by BoardSpec, KnobDefs, JsonReader

class_name ContentTypes extends RefCounted                      # built from assets/data/content/*.json
func kind_of_glyph(glyph: String) -> int                        # -1 if unknown
func id_of(kind: int) -> StringName
func kind_of(id: StringName) -> int
func is_solid(kind: int) -> bool
func fills_layer(kind: int) -> bool
func slot(kind: int) -> int                                     # SLOT_CELL / SLOT_OVERLAY
func hue(kind: int) -> int                                      # default hue for non-piece content

class_name BoardSpec extends RefCounted
var size: Vector3i; var h_play: int; var down: int; var mask: PackedByteArray  # W×D footprint
var spawn_anchor: Vector2i; var contents: Array[Dictionary]    # [{cell: Vector3i, kind: int}]
static func parse(data: Dictionary, limits: BoardLimits, types: ContentTypes, field_prefix: String = "board") -> BoardSpecResult

class_name BoardSpecResult extends RefCounted
var spec: BoardSpec                                             # null when errors is not empty
var errors: PackedStringArray

class_name BoardState extends RefCounted                        # full API as ADR-0002 "Key Interfaces"
static func down_from_token(token: String) -> int               # "-y" → Down.Y_NEG, -1 if bad
static func down_vector_of(d: int) -> Vector3i
func active_cell_count() -> int                                 # needed by BoardView (ADR-0007)
func h_play() -> int
```

#### `src/core/model/` (new folder; plain typed containers, no parsing)

```gdscript
class_name LevelData extends RefCounted
var id: StringName; var biome: StringName; var tier: int; var schema: int
var name_key: String; var level_hash: String
var layout_kind: StringName                                     # "single" for all of Meadow
var boards: Array[BoardSpec]                                    # 1 for Meadow
var pieces: Dictionary   # {shapes: PackedStringArray, weights: Dictionary[StringName,int], opening_set, opening_count, fixed_list, tags}
var knobs: Dictionary[StringName, Variant]                      # level base overrides, already fixed-point
var goal: Dictionary                                            # goal section (targets), type lives in knobs
var rules: Array[Dictionary]                                    # [{id, params, layer}] = mechanic + twists + recipe expansion
var stars: Dictionary                                           # {t2, t3} ms or {s2, s3} layers
var seed: int                                                   # -1 = none
var story: Dictionary

class_name GameCatalog extends RefCounted                       # everything trusted, loaded once at boot
var shapes: ShapeBank
var content: ContentTypes
var knob_defs: KnobDefs
var rule_defs: Dictionary[StringName, RuleDef]
var plugins: PluginRegistry
var palette: PackedColorArray                                   # hue id → Color (view only)
var limits: BoardLimits
```

`GameCatalog` holds `KnobDefs`, `RuleDef` and `PluginRegistry`, which live in `core/rules`; `core/model` may name them because a type reference is not behaviour. (This is the single allowed `model → rules` reference; the layering test whitelists exactly these three names.)

`core/model/` also holds the plain value types shared by rules, sim, data and plugins (decided 2026-10-10, chunk gaps 4–5): `SimCommand`, `SimEvent`, `GoalState`, `ValidationIssue`. They are listed under their old sections below for their fields; their files live in `src/core/model/`.

#### `src/core/rules/` (ADR-0004)

```gdscript
class_name KnobDefs extends RefCounted
func has(id: StringName) -> bool
func def(id: StringName) -> Dictionary                          # {type, default, min, max, allows_zero, rule_adjustable, choices}
func coerce(id: StringName, raw: Variant) -> Variant            # JSON value → typed/fixed-point; null + error if invalid
func last_error() -> String

class_name KnobRegistry extends RefCounted
func _init(defs: KnobDefs, level_overrides: Dictionary[StringName, Variant]) -> void
func value(id: StringName) -> Variant                           # cached effective value (GDD F1)
func int_value(id: StringName) -> int
func flag(id: StringName) -> bool
func recompute(active: Array[RuleInstance]) -> void             # called by RuleRuntime on start/end only
signal-free; clamps are returned as SimEvent `knob_clamped` by RuleRuntime

class_name RuleDef extends RefCounted                           # parsed rules/<id>.json
var id: StringName; var layer: StringName; var icon: String; var name_key: String
var params: Dictionary; var modifiers: Array[Dictionary]; var vetoes: Array[Dictionary]
var behaviour: StringName; var lifetime: Dictionary; var incompatible_with: PackedStringArray
var tags_requires: PackedStringArray; var tags_provides: PackedStringArray

class_name RuleInstance extends RefCounted                      # fields as ADR-0004 §8
class_name HookContext extends RefCounted                       # var hook: StringName; var data: Dictionary; var depth: int
class_name VetoResult extends RefCounted                        # var vetoed: bool; var rule_id: StringName

class_name PluginRegistry extends RefCounted
func _init(class_list: Array[Dictionary]) -> void               # pass ProjectSettings.get_global_class_list()
func create(kind: StringName, plugin_id: StringName) -> RefCounted   # kind = base class name, e.g. &"ClearDetector" (kinds = classes under core/rules/bases/); null if unknown
func ids(kind: StringName) -> PackedStringArray
func errors() -> PackedStringArray                              # duplicate PLUGIN_ID etc.

class_name RuleRuntime extends RefCounted
func _init(catalog: GameCatalog, knobs: KnobRegistry, round_seed: int) -> void
func activate(def_id: StringName, params: Dictionary, scope: int) -> RuleInstance
func expire(inst: RuleInstance) -> void
func knob(id: StringName) -> Variant
func slot(id: StringName) -> RefCounted                         # instance of the plugin named by the slot knob
func run_hook(hook: StringName, ctx: HookContext) -> void
func can(action: StringName, requester_rank: int, ctx: HookContext) -> VetoResult
func tick_lifetimes(now_ms: int, paused: bool) -> void
func take_events() -> Array[SimEvent]                           # rule_started/ended/blocked, chain_dropped, knob_clamped

class_name RuleApi extends RefCounted                           # the only object plugins see (ADR-0004 §7)
func now_ms() -> int
func knob(id: StringName) -> Variant
func param(name: StringName) -> Variant
func rng() -> RandomNumberGenerator                             # the calling rule's own stream
func board(board_id: int = 0) -> BoardState                     # read-only by convention; writes go through the methods below
func piece() -> Dictionary                                      # {shape_id, orient, cells: Array[Vector3i], travel_dir, tags} or {}
# buffered writes (applied at end of tick / in Resolving, priority order)
func set_cell(c: Vector3i, kind_id: StringName, hue: int = 0) -> void
func clear_cell(c: Vector3i, cause: int) -> void
func move_cells(from: PackedInt32Array, to: PackedInt32Array) -> void
func set_status(c: Vector3i, status_id: StringName, counter: int) -> void
func request_down_axis(d: int) -> void
func request_slot(slot_id: StringName, plugin_id: StringName) -> void
# piece
func try_translate(dir: Vector3i) -> bool
func set_travel_dir(dir: Vector3i) -> void
func replace_piece(cells_groups: Array[Array]) -> void    # split piece (SP28)
func return_piece_to_spawn() -> void                                    # mascot catch (WO11)
func inject_front(shape_id: StringName, tags: PackedStringArray) -> void
func emit(kind: StringName, data: Dictionary) -> void                   # view/audio-only event
```

`bases/` (each `@abstract`, `class_name`, one file; plugins declare `const PLUGIN_ID: StringName`):

```gdscript
@abstract class_name RuleBehaviour extends RefCounted     # subscribed_hooks(), handle(), veto(), validate()
@abstract class_name ClearDetector extends RefCounted     # find_clears(board: BoardState, api: RuleApi) -> Array[ClearGroup]
class_name ClearGroup extends RefCounted                  # var cells: PackedInt32Array; var counts_as_layers: int
@abstract class_name CollapsePolicy extends RefCounted    # collapse(board: BoardState, cleared: Array[ClearGroup], api: RuleApi) -> void
@abstract class_name ArrivalStyle extends RefCounted      # plan_arrival(shape: ShapeDef, board: BoardState, api: RuleApi) -> ArrivalPlan
class_name ArrivalPlan extends RefCounted                 # var origin: Vector3i; var orient: int; var travel_dir: Vector3i; var blocked: bool
@abstract class_name GoalEvaluator extends RefCounted     # configure(goal: Dictionary) -> void; evaluate(state: GoalState, api: RuleApi) -> int  (0 running, 1 won, 2 lost); progress(state) -> Dictionary
@abstract class_name TopOutPolicy extends RefCounted      # resolve_top_out(board: BoardState, state: GoalState, api: RuleApi) -> int (0 continue, 2 lost)
@abstract class_name ControlVerb extends RefCounted       # commands_for(gesture: Dictionary, api: RuleApi) -> Array[SimCommand]; apply(cmd: SimCommand, api: RuleApi) -> void
@abstract class_name LayoutKind extends RefCounted        # map_exit(board_id, cells, face) -> Dictionary
```

Every base also has `func tags() -> PackedStringArray` (compatibility tags) and `func validate(level: LevelData, catalog: GameCatalog) -> Array[ValidationIssue]` returning `[]` by default. `BoardKind`, `PieceRouter` and `StandingFn` bases are **not written** until the first story that needs them (§8); the registry needs no change to add them.

#### `src/core/sim/` (ADR-0001)

```gdscript
class_name SimCommand extends RefCounted   # var tick: int; var kind: StringName; var args: Array   (file in core/model/)
class_name SimEvent extends RefCounted     # var tick: int; var kind: StringName; var data: Dictionary   (file in core/model/)
class_name SimEvents extends RefCounted    # const StringNames for every core event kind (one vocabulary)

class_name ActivePiece extends RefCounted
var uid: int; var shape: ShapeDef; var orient: int; var origin: Vector3i; var travel_dir: Vector3i; var tags: PackedStringArray
func cells() -> Array[Vector3i]

class_name Movement extends RefCounted     # pure: kicks + translate/rotate against a BoardState (Movement & Rotation GDD)
static func try_translate(p: ActivePiece, board: BoardState, dir: Vector3i) -> bool
static func try_rotate(p: ActivePiece, board: BoardState, axis: Orientations.Axis, dir: int, kicks: Dictionary) -> bool
static func drop_distance(p: ActivePiece, board: BoardState) -> int   # = board.cast(cells, travel_dir)

class_name Spawner extends RefCounted      # Piece Spawner & Queue GDD
func _init(pieces: Dictionary, knobs: KnobRegistry, round_seed: int, scope: int) -> void
func next() -> Dictionary                  # {shape_id, tags}
func peek(n: int) -> Array[Dictionary]     # never changes state
func is_exhausted() -> bool                # fixed_list levels

class_name GoalState extends RefCounted    # layers_cleared, cells_trimmed, warnings_left, level_ms, locks, result   (file in core/model/)
class_name StarRater extends RefCounted
static func rate(stars: Dictionary, state: GoalState) -> int

class_name BoardSim extends RefCounted
enum Phase { COUNTDOWN, WAITING, FALLING, RESTING, GRACE, RESOLVING, ENDED }
func _init(level: LevelData, round_seed: int, catalog: GameCatalog) -> void
func queue_command(cmd: SimCommand) -> void
func commands_for_gesture(gesture: Dictionary) -> Array[SimCommand]   # via the control.verb slot
func step() -> Array[SimEvent]
func get_tick() -> int
func now_ms() -> int
func get_phase() -> Phase
func get_board(board_id: int = 0) -> BoardState
func get_piece() -> ActivePiece           # null when none; read-only use
func ghost_cells() -> Array[Vector3i]
func preview(n: int) -> Array[Dictionary]
func goal_progress() -> Dictionary
func state_hash() -> int

class_name Replay extends RefCounted
var level_hash: String; var round_seed: int; var commands: Array[SimCommand]
static func run(level: LevelData, catalog: GameCatalog, replay: Replay, ticks: int) -> Array[SimEvent]
```

Gesture dictionary (input → verb), documented once in `ControlVerb`:
`{kind: &"move"|&"rotate"|&"soft_drop"|&"hard_drop"|&"hold"|&"tap", dir: Vector3i (world, move), axis: int, sign: int (rotate, world axis already resolved by the camera), on: bool (soft_drop), cell: Vector3i (tap)}`.

#### `src/data/` (ADR-0005)

```gdscript
class_name JsonReader extends RefCounted
static func read_file(path: String, max_bytes: int) -> Dictionary      # {ok, data, error}; never ResourceLoader
static func read_dir(res_dir: String) -> Dictionary                    # {files: Dictionary[StringName, Dictionary], errors: PackedStringArray}; res:// only; key = file stem; whole numbers via JsonNum

class_name AsciiGrid extends RefCounted
static func parse_layers(section: Dictionary, size: Vector3i, legal: String, field: String) -> Dictionary  # {cells: Array[Dictionary{cell, glyph}], errors}
static func parse_mask(rows: Array, w: int, d: int, field: String) -> Dictionary                         # {mask: PackedByteArray, errors}

class_name CatalogLoader extends RefCounted
static func load_catalog(root: String = "res://assets/data") -> CatalogResult    # GameCatalog + errors

class_name LevelLoader extends RefCounted
static func load_level(path: String, catalog: GameCatalog) -> LoadResult          # {level: LevelData, issues}
static func parse_level(raw: Dictionary, catalog: GameCatalog) -> LoadResult      # tests feed dictionaries directly
static func level_hash(raw: Dictionary) -> String                                 # SHA-256 of JSON.stringify(raw, "", true)

class_name LevelMigrations extends RefCounted   # schema 1 only; upgrade(raw, from) -> raw; newer → error
class_name ValidationIssue extends RefCounted   # level_id, field, rule, severity, message   (file in core/model/)
class_name LevelValidator extends RefCounted
func validate(level: LevelData, catalog: GameCatalog) -> Array[ValidationIssue]
```

#### `src/gameplay/` (plugins only; no shared state, no core edits)

```
gameplay/
  slots/clear/       layer.gd (CL01, default), none.gd (CL14)
  slots/collapse/    slice.gd (CO01, default)
  slots/arrival/     top.gd (AR01, default)
  slots/goal/        clear_n.gd (GO01), height.gd (GO02), shape.gd (GO03), survive.gd (GO04)
  slots/top_out/     rescue.gd (FT01), trim.gd (FT02), lose.gd
  slots/layout/      single.gd (default)
  verbs/             piece.gd (CV01 default; CV02 is the same verb + rule veto data)
  twists/            gust.gd (EV01), mushroom_popup.gd (EV04), fog.gd (EV02), topsy_tumble.gd (EV03)
  mechanics/         mill_belt.gd (EV05/M4), wobble.gd (PL03), sprout.gd (SP22), hatching_egg.gd (SP21),
                     dandelion_puff.gd (SP28), fog_ghost.gd (SP26), mascot_catch.gd (WO11)
  daily/             (empty until the daily generator story; §8)
```

Plugin ids are snake_case words, not catalogue codes (`PLUGIN_ID := &"gust"`); the atom code goes in the rule JSON (`"atom": "EV01"`) for traceability. Sticky Landing (PL01), spin-only (CV02) and the build-race / fill-shape bundles (M1, M2) need **no code**: they are rule JSON modifiers, vetoes and slot `set`s.

#### `src/view/` (ADR-0007)

```gdscript
class_name BoardView extends Node3D
func bind(board: BoardState, cube_mesh: Mesh, palette: PackedColorArray) -> void
func apply_delta(delta: PackedInt32Array) -> void
func set_down(d: int) -> void

class_name PieceView extends Node3D        # falling piece + ghost; GLB per shape_id from the art set
func show_piece(shape_id: StringName, orient: int, origin: Vector3i, hue: int) -> void
func move_piece(orient: int, origin: Vector3i) -> void      # positions on tick; physics interpolation smooths
func show_ghost(cells: Array[Vector3i]) -> void
func clear() -> void

class_name CameraMath extends RefCounted   # pure, unit-tested
static func yaw_degrees(k: int, base_deg: int, step_deg: int) -> float
static func screen_dir_to_world(k: int, screen_dir: Vector2i, base_deg: int, step_deg: int) -> Vector3i   # Camera rules 10–11
static func view_axes(k: int, base_deg: int, step_deg: int) -> Dictionary   # {tilt: Vector3i, roll: Vector3i}
static func ortho_size(board_size: Vector3i, elevation_deg: float, aspect: float, margin: float) -> float

class_name CameraRig extends Node3D
signal yaw_changed(k: int)
func frame_board(board_size: Vector3i) -> void
func rotate_view(step: int) -> void                          # ±1, tweened, logically instant
func get_yaw_index() -> int
func screen_dir_to_world(screen_dir: Vector2i) -> Vector3i
func world_axis_for(screen_axis: StringName) -> Vector3i     # &"spin" / &"tilt" / &"roll"
func pick_cell(screen_pos: Vector2, board_view: BoardView) -> Vector3i   # for tap verbs; Vector3i(-1,-1,-1) if none
```

#### `src/input/`

```gdscript
class_name TouchInput extends Control      # Scheme A buttons + keyboard dev actions
signal gesture(g: Dictionary)              # world-resolved gesture (uses an injected CameraRig)
func setup(camera: CameraRig, enabled_axes: PackedStringArray) -> void
func set_layout(portrait: bool) -> void
```

Scheme B (drag and flick) is a second class later, `GestureInput`, with the same signal. No change elsewhere.

#### `src/ui/`

```
ui/hud/hud.tscn + hud.gd (class_name Hud)      goal progress, next-piece list, warnings, level clock, pause, rule icons
ui/hud/result_panel.tscn                        win/lose, stars, retry, next
ui/menus/level_select.tscn + level_select.gd    biome → levels, stars, locks
```

#### `src/app/`

```gdscript
class_name Main extends Node               # main.tscn; boot: loads GameCatalog + ProfileStore, owns AppFlow
class_name AppFlow extends Node            # swaps the current screen: level select ⇄ level scene
func open_level(scene_path: String) -> void              # official level scene (res:// from biome JSON)
func open_level_data(level: LevelData) -> void           # player/daily level on scenes/levels/generic_level.tscn
func open_level_select(biome: StringName) -> void
class_name LevelScene extends Node3D       # level_scene.tscn; assembles one play session
func start(level: LevelData, catalog: GameCatalog, round_seed: int) -> void
signal finished(result: Dictionary)
class_name ProfileStore extends RefCounted # user://profile.json: best stars per level id + level_hash; points counters later
func best_stars(level_id: StringName) -> int
func record(level_id: StringName, level_hash: String, stars: int) -> void
```

`src/net/`, `src/minigames/`, `src/native/`: not created in this plan (§8).

### 1.3 Data files (all JSON unless noted)

```
assets/data/
  credits.json                 (exists; FND-000)
  palette.json                 hue id → hex (from the art docs; art owns the values)
  atom_tags.json               tag vocabulary + conflict pairs
  knobs/  board.json fall.json spawn.json controls.json clearing.json goals.json rules.json view.json data.json
  content/ blocks.json         block, starter, mushroom, sprout, egg, chick (kind_id, glyph, slot, solid, fills_layer, hue, mesh)
  content/ statuses.json       fog fade, ghost (look kinds; ADR-0007 §7)
  rules/  <rule_id>.json       spin_only, sticky_landing, build_race, fill_shape, gust, mushroom_popup, fog,
                               topsy_tumble, mill_belt, wobble, sprouts, hatching_eggs, dandelion_puff, fog_ghost, mascot_catch
  biomes/ meadow.json          {art_set, levels: [{id, scene}], default dressing scene (generic levels), music key}
scenes/levels/                 base-inheriting level scenes: generic_level.tscn, meadow/meadow_01.tscn … meadow_10.tscn
  levels/meadow/ meadow_01.json … meadow_10.json
  shapes/ shape_bank.tres      (generated, ADR-0003)
assets/i18n/strings.csv        keys only in data; English column first
```

---

## 2. Autoloads, scene tree and level loading

### 2.1 Autoloads

**No new gameplay autoloads in this plan.**

| Autoload | Status | Why |
|---|---|---|
| `_mcp_game_helper` | exists, dev tool | Kept for the Godot AI MCP verification loop. Must not ship: FND-000 adds an export exclusion or a debug-build guard and a test that checks for it (§8 risk R6). |
| `NetSession` | deferred (ADR-0009) | The only planned autoload; it owns the `MultiplayerPeer`, which is genuinely process-global. Created in the multiplayer epic. |

What would normally be autoloads is owned by `Main` and **injected**: `GameCatalog` (immutable after boot), `ProfileStore`, and `AppFlow`. This keeps every class unit-testable with fakes (coding standard: dependency injection over singletons) and avoids hidden order-of-boot bugs. An event bus is not needed: there is one `LevelScene` at a time and it wires its children directly.

### 2.2 Scene tree: one scene per level (user direction 2026-10-10)

**Decision.** Every official level is its own scene that **inherits** the base level scene and **points at its level JSON**. The scene owns the *place*: island/diorama, props, mascot spots, board anchor, camera framing overrides, intro/payoff skit animation. The JSON owns the *rules*: board, pieces, knobs, goal, rules, stars. A scene never holds a rule value, so the sim, validator, `level_hash`, replays and tests stay data-driven, and player-made levels (JSON only) play on a generic scene with no code path of their own.

```
src/app/level_scene.tscn  (base; script LevelScene)          scenes/levels/meadow/meadow_01.tscn (inherits base)
LevelScene (Node3D, app/level_scene.gd)                       LevelScene  level_json = "res://assets/data/levels/meadow/meadow_01.json"
├─ WorldEnvironment, DirectionalLight3D   default lighting    ├─ (inherited nodes, values overridable)
├─ BoardController (Node)                 owns BoardSim       ├─ Diorama  ← seed-plot island, props, rubber duck
├─ Diorama (Node3D)                       empty in base       │   ├─ BoardAnchor (Marker3D)  where board (0,0,0) sits
│  └─ BoardAnchor (Marker3D)              board origin        │   └─ MascotSpots (Node3D) → Marker3D "pip_idle", "pip_cheer"…
│     └─ BoardView (Node3D) ×n            MultiMesh           └─ Skits (AnimationPlayer)  "intro", "payoff" (optional)
│        └─ PieceView (Node3D)            piece + ghost
├─ MascotSpots (Node3D)                   empty in base       scenes/levels/generic_level.tscn (inherits base)
├─ CameraRig (Node3D) → Camera3D          orthographic         ← biome default diorama from biomes/<biome>.json; used for
└─ UI (CanvasLayer): Hud, TouchInput, ResultPanel                 player levels, daily levels and any level without a scene
Main (Node) → AppFlow (Node) → one LevelScene at a time
```

`LevelScene` exports (set per level scene in the inspector; presentation only):

```gdscript
@export_file("*.json") var level_json: String          # official levels only; empty on generic_level.tscn
@export var camera_yaw_index: int = 0                   # Camera rule 3: per-level default snap
@export var camera_elevation_override_deg: float = 0.0  # 0 = knob default
@export var skit_player: AnimationPlayer                # null = no skit
```

Rules: (1) the base scene owns all wiring; inherited scenes only add/override **visual** nodes and these exports, never scripts on the core nodes. (2) `BoardAnchor` is the only placement contract; multi-board levels add one anchor per board id (`BoardAnchor_<id>`), falling back to the level JSON `transform`. (3) Mascot spots are `Marker3D`s found by name, so a mascot story needs no scene code. (4) A test (`tests/unit/levels/level_scenes_test.gd`) instantiates every scene under `res://scenes/levels/`, checks it inherits the base, that `level_json` exists, validates, and that its `id` matches the scene file name and the biome list.

**Wiring** (call down, signal up; all done in `LevelScene.start()`):
1. `BoardController.setup(BoardSim.new(level, round_seed, catalog))`.
2. `BoardView.bind(sim.get_board(), cube_mesh, catalog.palette)`; `CameraRig.frame_board(size)`; `TouchInput.setup(camera_rig, enabled_axes)`.
3. `TouchInput.gesture` → `BoardController.submit_gesture(g)` → `sim.commands_for_gesture(g)` → `sim.queue_command(cmd)` stamped for the next tick.
4. `BoardController` re-emits events as typed signals: `cells_changed(board_id: int, delta: PackedInt32Array)`, `piece_spawned(info: Dictionary)`, `piece_moved(info: Dictionary)`, `piece_locked(info: Dictionary)`, `layers_cleared(info: Dictionary)`, `goal_progress(info: Dictionary)`, `rule_event(ev: SimEvent)`, `level_ended(result: Dictionary)`, plus a generic `sim_event(ev: SimEvent)` for anything else (audio, game feel, skits).
5. View, HUD and result panel connect to those signals. `level_ended` → `LevelScene.finished` → `AppFlow` → `ProfileStore.record`.

**Pause / orientation change**: `LevelScene` sets `BoardController.set_physics_process(false)` (the sim has no wall clock, so it simply stops) and shows the pause overlay; on resume it re-frames the camera. App backgrounding uses `NOTIFICATION_APPLICATION_PAUSED` the same way.

**Smooth piece motion**: enable `physics/common/physics_interpolation` (setting verified on 4.7.2 in ADR-0001). `PieceView` sets transforms in the physics tick; Godot interpolates. `reset_physics_interpolation()` on spawn, rotation snap and teleports (verified present).

### 2.3 How a level loads

1. **Boot** (`Main._ready`): `CatalogLoader.load_catalog()` reads `knobs/`, `content/`, `rules/`, `palette.json`, `atom_tags.json`, loads `shape_bank.tres`, and builds `PluginRegistry` from `ProjectSettings.get_global_class_list()`. Any catalog error is fatal in debug and shown as an error screen in release.
2. **Level select** reads `biomes/meadow.json` for the order and scene of each level (`levels: [{"id": "meadow_01", "scene": "res://scenes/levels/meadow/meadow_01.tscn"}, …]`; internal `res://` data, so it may name scenes, ADR-0005) and `ProfileStore` for stars and unlocks.
3. **Open**: `AppFlow.open_level(scene_path)` instantiates the level scene (`load()` on a `res://` path from internal data only); `LevelScene._ready` reads its `level_json` and calls `LevelLoader.load_level(level_json, catalog)`. A player/daily level is opened with `AppFlow.open_level_data(level: LevelData)`, which instantiates `generic_level.tscn`, dresses it from the biome JSON and skips the file read. The loader steps:
   1. `JsonReader.read_file` (size cap `data.max_level_bytes`), `JSON.parse_string`, top-level must be a Dictionary.
   2. `LevelMigrations.upgrade` (schema 1 only today).
   3. Field-by-field parse into `LevelData`; unknown keys are errors; numbers through `whole_int`; `knobs` values through `KnobDefs.coerce` (fixed point once, here).
   4. Each board through `BoardSpec.parse` (bounds before allocation; ASCII mask and starting layers per §5).
   5. `recipe` (if present) expands into slot knobs and rule entries; explicit `knobs`/`twists`/`mechanic` win.
   6. `LevelValidator.validate` (+ each named plugin's `validate()`). Errors stop the load; warnings print in debug.
4. **Start**: `round_seed` = level `seed` if pinned, else a fresh value drawn **in `app/`** from a randomized `RandomNumberGenerator` (the only non-deterministic draw in the game, outside the sim). `LevelScene.start(level, catalog, round_seed)`.

Meadow level JSON shape (schema 1; the ADR-0005 shape, with §5 grid forms):

```json
{
  "schema": 1, "id": "meadow_02", "biome": "meadow", "tier": 2,
  "name": "LVL_MEADOW_02_TITLE",
  "board": {
    "width": 6, "depth": 6, "h_play": 10, "down_axis": "-y",
    "starting_contents": { "layers": {
      "0": ["######", "#.###.", "######", "######", "####.#", "######"],
      "1": ["######", "#..#..", "#.##.#", "###.##", "###..#", "######"] } }
  },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right"],
              "opening_set": ["tripod","screw_left","screw_right"], "opening_count": 3 },
  "knobs": { "fall.g0": 0.6, "goal.top_out": "rescue", "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "n": 3 },
  "rules": [ { "id": "mascot_catch", "params": { "catches": 1 } } ],
  "stars": { "t2": 130000, "t3": 90000 },
  "story": { "title_key": "LVL_MEADOW_02_TITLE", "premise_key": "LVL_MEADOW_02_PREMISE", "mascot_role": "helper", "icon": "bed" }
}
```

Two schema points decided here (both consistent with ADR-0005's intent, recorded in §9): `goal.type` is written in the `goal` section and copied into the `goal.type` slot knob by the loader; and a single `rules` list replaces the separate `mechanic`/`twists` keys, each entry's `layer` coming from its rule definition, so the validator's F3 budget (≤ 2 `twist` + ≤ 1 `mechanic`) counts by layer. Special pieces, living blocks and mascot atoms have layer `content` / `mascot` and do not count toward F3, which is what the approved meadow.md combinations require (e.g. 03 = gust + dandelion puff).

---

## 3. Extension recipes (one new file + one data entry, no core edits)

Each recipe lists exactly what to add. If one ever needs a core edit, stop: that is an ADR change. Tests for each new plugin go in `tests/unit/gameplay/<plugin_id>_test.gd` and drive it through `FakeRuleApi` (`tests/unit/support/fake_rule_api.gd`, built in RUL-002).

| Add a… | New file | Data entry | Test |
|---|---|---|---|
| **Mechanic atom with behaviour** (wobble, sprout, egg) | `src/gameplay/mechanics/<id>.gd`: `class_name X extends RuleBehaviour`, `const PLUGIN_ID := &"<id>"`, `subscribed_hooks()`, `handle()`; optional `veto()`, `validate()` | `assets/data/rules/<id>.json` with `"behaviour": "<id>"`, `"layer"`, `"atom"`, `params` schema, `requires`/`provides` tags; content type in `content/blocks.json` if it places cubes | plugin test with `FakeRuleApi` |
| **Mechanic atom that is only numbers/vetoes** (sticky, spin-only) | none | `rules/<id>.json` with `modifiers`/`vetoes` only | `tests/unit/rules/rule_data_test.gd` loads every rule file (already generic) |
| **Twist** (gust, fog, flip) | `src/gameplay/twists/<id>.gd` extends `RuleBehaviour` | `rules/<id>.json` with `"layer": "twist"`, icon | plugin test |
| **Clear rule** (row, colour, colour-connect) | `src/gameplay/slots/clear/<id>.gd` extends `ClearDetector` | add `<id>` to `clear.detector` `choices` in `knobs/clearing.json` | detector test on fixture boards under all 6 down axes |
| **Collapse rule** (cascade, chunks) | `src/gameplay/slots/collapse/<id>.gd` extends `CollapsePolicy` | `clear.collapse` choices | test |
| **Goal type** | `src/gameplay/slots/goal/<id>.gd` extends `GoalEvaluator` (owns parsing of its own `goal` fields in `configure()` and checking them in `validate()`) | `goal.type` choices in `knobs/goals.json` | test |
| **Top-out rule** | `src/gameplay/slots/top_out/<id>.gd` extends `TopOutPolicy` | `goal.top_out` choices | test |
| **Arrival style** (side travel) | `src/gameplay/slots/arrival/<id>.gd` extends `ArrivalStyle` | `spawn.arrival` choices in `knobs/spawn.json` | test |
| **Control verb** (swap, tap-pop) | `src/gameplay/verbs/<id>.gd` extends `ControlVerb` | `control.verb` choices in `knobs/controls.json`; a new gesture kind is documented on `ControlVerb` (input emits it only if the HUD offers the control, chosen by the verb's `tags()`) | verb test: gesture → commands → applied state |
| **Board kind** (physics, Alpha) | `src/gameplay/board_kinds/<id>/…` extends `BoardKind` (base written with the first board-kind story) | `board.kind` choices | parity test on the shared command/event contract |
| **Layout** (islands, lanes) | `src/gameplay/slots/layout/<id>.gd` extends `LayoutKind` | level `layout.kind` + `boards[]` | layout validate test |
| **Content type** (new obstacle) | none, unless it behaves (then a `RuleBehaviour`) | entry in `content/blocks.json` with a unique `kind_id` and `glyph` | content table test checks uniqueness |
| **Level** (official) | `scenes/levels/<biome>/<id>.tscn` inheriting `src/app/level_scene.tscn` (Scene → New Inherited Scene), dressing + `BoardAnchor` + mascot spots, `level_json` set | `levels/<biome>/<id>.json` + `{id, scene}` in `biomes/<biome>.json` | `level_files_test.gd` + `level_scenes_test.gd` pick both up automatically |
| **Level** (player / daily) | none | the level JSON only; plays on `generic_level.tscn` | validator at import |
| **Knob** | none | entry in the owning `knobs/<system>.json` | knob table test (generic) |
| **Hook point** | the owning system calls `runtime.run_hook(&"on_x", ctx)` (this *is* a core edit to the owning system, by design; list it in ADR-0004) | — | — |

---

## 4. Libraries

| Library | State in repo | Decision | Why |
|---|---|---|---|
| **gdUnit4 6.2.1** | installed, used | **Adopt** | Test runner, CI action already set up. |
| **godot-ci** | not installed | **Adopt at APP-001** for the Android export job (Docker image with export templates). Tests stay on `gdUnit4-action`. | No export preset existed before FND-000; adding the job before there is an APK to build is waste. |
| **Kenney CC0** (UI pack, Game Icons) | not installed | **Adopt at UI-001** for HUD placeholders under `assets/third_party/kenney/`, each with a `credits.json` entry. | Readable placeholders now; art direction replaces them. |
| **Godot built-in translation (CSV)** | stub exists | **Adopt** | All text in data is keys; `tr()` in UI. |
| **G.U.I.D.E 0.14** | installed, **not enabled** | **Defer** | The game is touch-first: Scheme A is plain `Control` buttons and Scheme B is a small gesture recogniser; both emit our own gesture dictionary. GUIDE's value is context-based remapping across keyboard/gamepad, which no GDD needs yet, and it adds a runtime singleton. Keyboard dev controls use the built-in `InputMap`. Revisit when controller support or a remap screen is designed. |
| **Phantom Camera 0.11** | installed, **not enabled** | **Defer** | Gameplay camera = 12 discrete yaw snaps at fixed elevation and fixed ortho size: one `Tween` on one `Node3D`. Phantom Camera adds a host and per-frame follow logic we do not use. Revisit for intro/payoff skits and the boss camera. |
| **TileMapLayer3D 1.2** | installed, not enabled | **Skip for gameplay** (board is not a tile map). Possibly evaluate for diorama dressing authoring later. | — |
| **Script-IDE, godot_ai, godot_mcp_toolkit** | installed (editor tools) | **Keep as editor/dev tools only** | Must be excluded from exports (R6). |
| **Beehave / LimboAI** | not installed | **Skip now** (reference for bot opponents later) | No AI in the Meadow slice. |
| **kenyoni QR**, **webrtc-native** | not installed | **Defer to multiplayer** (ADR-0009) | — |
| **OR-tools CP-SAT** | — | **Defer**; tooling only, never in the APK | The meadow_02 pocket check is a tiny brute-force test (MDW-002), enough for now. |
| **PuzzleScript** | — | Design sandbox only | Not code. |

Every add-on that stays in `addons/` keeps its `credits.json` entry; the credits test enforces it.

---

## 5. Decision: level starting-contents format

**ASCII layers are authored; `BoardSpec.parse` turns them into a cell list. Level JSON accepts only the ASCII form.**

- Level file: `board.starting_contents = {"layers": {"<y>": [D rows of W chars]}}`, row 0 = `z = 0`, char 0 = `x = 0` (Level Data GDD rule 4a, meadow.md grids). Layer keys are strings in JSON and must be whole numbers `0 ≤ y < h_play`.
- **The legend is data, not code**: each content type in `content/blocks.json` has a one-character `glyph` (`#` starter, `m` mushroom, `^` sprout, `e` egg, `a` ant, …). `.` is always empty. An unknown glyph is an error naming the cell. A new obstacle is a new content entry with a new glyph; no parser change.
- **Targets** use the same form: `goal.target_shape = {"layers": {"<y>": rows}}` with `+` or `#` for a target cell (meadow.md uses `+`), `.` empty. Parsed by the `shape` goal plugin's `configure()` through `AsciiGrid`.
- **Inside the engine** `BoardSpec.contents` is the ADR-0002 cell list `[{cell, kind}]`, so the board, network and replay code never see ASCII.
- Hue: starter content uses its content type's `hue`; per-cell hue in starting contents is not supported (no Meadow level needs it). If a later level needs it, add an optional `cells` list next to `layers` in a schema bump.
- Why not the cell list in files: the approved design and the GDD both author in ASCII; two formats means two parsers and two validators; ASCII diffs cleanly and is what the level designer reads. Why not ASCII in the engine: ADR-0002's cell list is the right in-memory form.
- **Pending edit**: ADR-0002 §6 item 6 and ADR-0005 "Level file shape" (`target_layers`) to say this. Owner: godot-specialist.

---

## 6. Ordered story list

Epics: **FND** foundation housekeeping · **SHP** shapes · **BRD** board · **DAT** data · **RUL** rules runtime · **SIM** simulation · **VEW** view · **INP** input · **UI** HUD/menus · **APP** assembly · **MDW** Meadow content.

Every story: tests first in the named folder (gdUnit4, `[system]_[feature]_test.gd`, `test_[scenario]_[expected]`), then code; headless run green; a parse check is not a run. Visual/UI stories retain screenshots in `production/qa/evidence/`. Each is sized for one Sonnet `godot-gdscript-specialist` session.

### Wave 0 (running now)

**FND-000 Housekeeping** — *in progress (Sonnet coder)*
- Files: `assets/data/credits.json`, `assets/i18n/strings.csv` + `internationalization/locale/translations` in project.godot, `export_presets.cfg` (Android preset, `include_filter="*.json"`, editor add-ons excluded), `tests/unit/data/credits_test.gd`, `tests/unit/architecture/banned_api_test.gd`, `tests/unit/architecture/layering_test.gd` (§1.1), CI unchanged except running `--import` first if the action does not.
- AC: every `addons/*` and `assets/third_party/*` folder has a credits entry (test); banned-token grep passes on an empty `src/core`; export preset lists `*.json`; `_mcp_game_helper` is excluded from or inert in release exports (test reads the preset or the guard).
- Deps: none.

**FND-001 RNG** — *in progress (Sonnet coder)*
- Files: `src/core/rng/seeds.gd`. Tests: `tests/unit/rng/seeds_derive_test.gd`, `seeds_shuffle_test.gd`.
- AC: ADR-0006 goldens (FNV "a" = `0xE40C292C`; `randi_range(0,7)` sequence for seed 12345); bag k direct = bag k dealt; weighted pick with integer weights.
- Deps: none.

### Wave 1 (parallel: SHP-001, BRD-001, DAT-001, RUL-001, VEW-004)

**SHP-001 Orientation tables**
- Files: `src/core/shapes/orientations.gd`. Tests: `tests/unit/shapes/orientations_table_test.gd`.
- AC: 24 distinct integer matrices, det +1; index 0 identity; BFS order stable; `turn` ×4 about one axis returns start; `apply` matches matrix product.
- Deps: none.

**BRD-001 BoardSpec, BoardLimits, ContentTypes, ASCII grids**
- Files: `src/core/board/board_spec.gd`, `board_spec_result.gd`, `board_limits.gd`, `content_types.gd`, `src/data/ascii_grid.gd`, `assets/data/content/blocks.json` (block, starter), `assets/data/knobs/board.json`.
- Tests: `tests/unit/board_grid/board_spec_parse_test.gd`, `board_spec_fuzz_test.gd` (1000 hostile dicts: no crash, no allocation over caps, error list ≤ `max_errors`), `tests/unit/data/ascii_grid_test.gd`.
- AC: ADR-0002 §6 checks 1–7 with field-and-cell error messages; JSON-float whole-number rule pinned; ASCII legend from content glyphs; footprint-centre default anchor (lower cell on ties); A ≥ `min_active_per_layer`.
- Deps: none. (`BoardSpec.parse` calls `AsciiGrid`, a pure static helper in `data/`; this is the one allowed `core/board → data/ascii_grid` use, or move `AsciiGrid` into `core/board/` — **decision: put it in `core/board/ascii_grid.gd`** so the layering stays strict.)

**DAT-001 JSON reader, knob tables, KnobDefs, KnobRegistry (base values)**
- Files: `src/data/json_reader.gd`, `src/core/rules/knob_defs.gd`, `knob_registry.gd`, `assets/data/knobs/{fall,spawn,controls,clearing,goals,rules,view,data}.json` with every knob from the GDD tables in §1.3 and their ranges.
- Tests: `tests/unit/data/json_reader_test.gd`, `tests/unit/rules/knob_defs_test.gd`, `knob_registry_base_test.gd`, `tests/unit/data/knob_files_test.gd` (every knob file loads; defaults inside ranges; ids unique).
- AC: scalar fixed point (`0.6` → 600); count/flag/choice/slot coercion with named errors; level override beats default; out-of-range rejected; `JSON.parse_string` float behaviour pinned; file over cap rejected.
- Deps: none.

**RUL-001 Plugin registry + plugin bases**
- Files: `src/core/rules/plugin_registry.gd`, `bases/{rule_behaviour,clear_detector,clear_group,collapse_policy,arrival_style,arrival_plan,goal_evaluator,top_out_policy,control_verb,layout_kind}.gd`, `hook_context.gd`, `veto_result.gd`. Test fixtures: `tests/unit/rules/fixtures/test_only_detector.gd` (`PLUGIN_ID = &"test_only"`).
- Tests: `tests/unit/rules/plugin_registry_test.gd`.
- AC: a test-only `ClearDetector` is found by id with no other edit (ADR-0004 validation item); duplicate id → error; abstract bases cannot be instantiated; unknown id → null.
- Deps: none. (Bases reference `BoardState`/`ShapeDef` types: create empty forward stubs only if BRD-002/SHP-002 are not merged yet; preferred order is to merge after them in wave 2 if a stub would be needed.)

**VEW-004 Camera math + CameraRig** (view work can start early; pure math first)
- Files: `src/view/camera_math.gd`, `src/view/camera_rig.gd`, `src/view/camera_rig.tscn`.
- Tests: `tests/unit/view/camera_math_test.gd` (12 yaws = 45° + 30°k; screen→world map incl. corner tie rule; tilt/roll axis per yaw; ortho size fits footprint + full height in portrait and landscape).
- AC: rotate_view tween over `view.turn_anim_ms`, input mapping switches instantly; sideways-gravity snap restriction is a TODO hook (not needed in Meadow); screenshot of a placeholder box at 3 yaws.
- Deps: DAT-001 only for knob ids (can hard-wire test values and read knobs at APP-001).

### Wave 2 (parallel: SHP-002, BRD-002, SIM-001)

**SHP-002 ShapeDef, ShapeBank, canonical key**
- Files: `src/core/shapes/shape_def.gd`, `shape_bank.gd`. Tests: `tests/unit/shapes/shape_canonical_test.gd`, `shape_def_test.gd`.
- AC: distinct counts O = 3, I = 3, T = 12, Big Cube = 1 (GDD F4) on hand fixtures; screw L ≠ R; spawn orientation = smallest +y extent, lowest index on ties.
- Deps: SHP-001.

**BRD-002 BoardState layout + queries**
- Files: `src/core/board/board_state.gd` (read side). Tests: `tests/unit/board_grid/board_state_layout_test.gd`, `board_state_queries_test.gd`, parameterised over all 6 down axes.
- AC: Board GDD AC 1–9; `layer_cells`, `layer_full`, `stack_height`, `over_limit`, `can_place`, `cast(dir)` under 6 axes; mask expansion; no allocation in `is_free/can_place/cast`.
- Deps: BRD-001.

**SIM-001 Commands, events, clock, BoardSim skeleton, Replay**
- Files: `src/core/model/{sim_command,sim_event}.gd`, `src/core/sim/{sim_events,board_sim,replay}.gd` (phases, tick, `now_ms`, command queue, empty step pipeline with the ADR-0001 order as named private steps).
- Tests: `tests/unit/sim/sim_clock_test.gd` (60 ticks = 1000 ms; deadline 500 ms fires on tick 30), `sim_command_queue_test.gd`, `replay_test.gd` (same log → same events).
- AC: no SceneTree used; commands apply at the start of the next tick in arrival order.
- Deps: FND-001.

### Wave 3 (parallel: SHP-003, BRD-003, SIM-002, DAT-002)

**SHP-003 Shape bank extraction (headless tool)**
- Files: `tools/asset-pipeline/extract_shape_bank.gd` (`extends SceneTree`, `-s` script; reads cube child **translations**, rounds to `Vector3i`, connectivity/duplicate/rotation-duplicate checks; merges hand fields by `shape_id`), generated `assets/data/shapes/shape_bank.tres`; update `tests/unit/assets/block_set_import_test.gd` to read the bank and delete `CUBE_COUNTS`.
- Tests: `tests/unit/shapes/shape_bank_file_test.gd` (bank loads; every shape face-connected; counts per GDD), block-set test now compares **every** set to the bank canonically.
- AC: 67 shapes from `candy_toy` (the 68th file is `cube`); `neon_voxel` matches; rerunning the tool is a no-op diff. Command recorded in the tool header.
- Deps: SHP-002.

**BRD-003 BoardState mutations + delta**
- Files: `board_state.gd` (write side). Tests: `tests/unit/board_grid/board_state_mutation_test.gd`, `board_state_shift_test.gd`, `board_state_connected_test.gd`.
- AC: delta triples per ADR-0002 §5; `shift_layers({2,5})` (Layer Clearing AC 7) under −y, +x, −z; `set_down` emits `LAYOUT` and rebuilds counters; `connected(COLOR|PIECE|SOLID)` reuses stamp array; `get_record`; `active_cell_count`.
- Deps: BRD-002.

**SIM-002 Spawner & queue**
- Files: `src/core/sim/spawner.gd`. Tests: `tests/unit/sim/spawner_bag_test.gd`, `spawner_opening_test.gd`, `spawner_fixed_list_test.gd`.
- AC: weighted bag (Spawner F1, `bag_max_size` scaling); `opening_set`/`opening_count` (meadow_01 first 2 ∈ {O, I}; meadow_02 first 3 = a bag of tripod + both screws); `fixed_list` and `is_exhausted`; `peek` never changes state; same seed → same 100 pieces; a rule drawing from its own stream does not change them.
- Deps: FND-001, DAT-001 (knob reads). Uses shape ids only (no bank needed).

**DAT-002 LevelData + LevelLoader + migrations**
- Files: `src/core/model/level_data.gd`, `game_catalog.gd`, `src/data/level_loader.gd`, `level_migrations.gd`, `load_result.gd`, `src/core/model/validation_issue.gd`.
- Tests: `tests/unit/data/level_loader_test.gd` (minimal level with only id/biome/tier; unknown key; fractional int; 10 MB file; newer schema; `level_hash` stable), `tests/unit/data/no_untrusted_load_test.gd` (grep: no `load(`/`ResourceLoader` on `user://` or variable paths in `src/`).
- AC: ADR-0005 loader rules; §5 ASCII form via `BoardSpec.parse`; `goal.type` → slot knob; `rules` entries keep `id` + `params`.
- Deps: BRD-001, DAT-001.

### Wave 4 (parallel: SIM-003, DAT-003, RUL-002, VEW-002)

**SIM-003 Active piece + movement + rotation**
- Files: `src/core/sim/active_piece.gd`, `movement.gd`. Tests: `tests/unit/sim/movement_translate_test.gd`, `movement_rotate_kick_test.gd`.
- AC: Movement & Rotation GDD: translate via `can_place`; rotate via `Orientations.turn` about the world axis given; kick table (`kick_order`, `max_up_kicks_per_piece`, wide kicks); `rotation_axes_enabled` handled as a veto action `rotate.<axis>` (so CV02 is data); ghost = `drop_distance`.
- Deps: SHP-002, BRD-002, DAT-001.

**DAT-003 LevelValidator**
- Files: `src/data/level_validator.gd`, `src/data/catalog_loader.gd` (+ `catalog_result.gd`).
- Tests: `tests/unit/data/level_validator_test.gd` (Level Data AC 2, 3, 4, 8a: 3 twists, unknown knob, out of range, opening shape outside set, anchor inactive, wrong grid rows, conveyor on mask, flip with build race, shape not fitting the region), `tests/unit/data/level_files_test.gd` (every file under `res://assets/data/levels/` validates; zero files = pass for now).
- AC: plugin `validate()` results merged; issues name level, field, rule.
- Deps: DAT-002, RUL-001, SHP-002.

**RUL-002 Rule runtime: rule defs, instances, F1 modifiers, hooks, vetoes, RuleApi**
- Files: `src/core/rules/{rule_def,rule_instance,rule_runtime,rule_api}.gd`; `knob_registry.gd` gains `recompute()`. Test support: `tests/unit/support/fake_rule_api.gd`.
- Tests: `tests/unit/rules/rule_runtime_priority_test.gd`, `rule_runtime_veto_test.gd`, `rule_runtime_lifetime_test.gd`, `knob_registry_modifiers_test.gd`, `rule_api_buffer_test.gd`.
- AC: Rule-Twist GDD AC 1–17, 19 that apply without a sim (F1 set/mul/add/clamp in fixed point; F2 ascending order; veto ties → veto; `max_hook_depth`; F4 lifetimes suspended while paused/resolving; writes from `on_tick` buffered and applied in priority order; each rule's RNG = `Seeds.make_rng(seed, ["rule", id, n])`).
- Deps: DAT-001, RUL-001, BRD-003.

**VEW-002 Debug BoardView (MultiMesh, flat hue)**
- Files: `src/view/board_view.gd`, `board_view.tscn`, `assets/data/palette.json` (placeholder values from the art docs).
- Tests: `tests/unit/view/board_view_slots_test.gd` (cell↔slot bookkeeping: add/remove swap-last/move; `visible_instance_count` = filled; LAYOUT rebuild). Debug scene `src/dev/board_view_debug.tscn` filling a board; screenshot evidence.
- AC: formats set before `instance_count`; per-instance setters (`set_instance_transform`, `set_instance_color`) — **ponytail: per-instance setters; switch to `multimesh_set_buffer` only when profiling says so**, which also defers ADR-0007 verification items 1 and 3; `StandardMaterial3D` with `vertex_color_use_as_albedo` for flat hue (no custom shader yet); cube mesh from `blk_<set>_cube.glb`. Records ADR-0007 verification item 2 result.
- Deps: BRD-003.

### Wave 5 (parallel: SIM-004, VEW-003, INP-001)

**SIM-004 Fall, drop, lock**
- Files: `board_sim.gd` (FALLING/RESTING/GRACE/WAITING logic), `src/core/model/goal_state.gd`.
- Tests: `tests/unit/sim/fall_gravity_test.gd`, `fall_soft_hard_drop_test.gd`, `fall_lock_delay_test.gd`.
- AC: Fall/Drop/Lock rules 1–13 and 17 with integer-ms deadlines (gravity step = `1_000_000 / g_milli`; clock resets on spawn; soft drop F1; hard drop + grace + commit; lock delay + `lock_resets_max` + restore on new low; `lock_delay_ms = 0` instant lock); **lock veto point**: before writing cubes the sim asks `can(&"piece.lock", …)`; if vetoed by a rule that called `api.return_piece_to_spawn()`, the piece returns to its spawn origin in its current orientation with the gravity clock reset (needed by WO11); countdown phase uses `goal.countdown_ms`.
- Deps: SIM-001, SIM-002, SIM-003, RUL-002.

**VEW-003 PieceView + ghost**
- Files: `src/view/piece_view.gd`, `piece_view.tscn`, `src/view/art_set.gd` (path helper: `blk_<set>_<shape>.glb`, cube wrap for `blk_<set>_cube.glb`).
- Tests: `tests/unit/view/art_set_paths_test.gd`; screenshot of piece + ghost at two orientations.
- AC: GLB per shape; ghost = same GLB with a translucent unshaded material (proper ghost shader later); physics interpolation on, reset on spawn/rotate.
- Deps: SHP-003.

**INP-001 Touch input (Scheme A) + keyboard dev**
- Files: `src/input/touch_input.gd`, `touch_input.tscn` (portrait + landscape layouts), `InputMap` actions `wt_move_*`, `wt_spin_*`, `wt_tilt_*`, `wt_roll_*`, `wt_soft_drop`, `wt_hard_drop`, `wt_rotate_view_*` in project.godot.
- Tests: `tests/unit/input/touch_input_gesture_test.gd` (button press → gesture dict with world dir from a stub camera; hidden axes not emitted; tap vs hold on drop button by `controls.tap_threshold_ms`).
- AC: Touch Controls rules 1–3, 5, 5a, 6, 9; no input starts on the board area; screenshot both orientations.
- Deps: VEW-004.

### Wave 6

**SIM-005 Per-lock sequence + default slot plugins**
- Files: `board_sim.gd` (resolve pipeline, rule 15 order), `src/gameplay/slots/clear/layer.gd`, `clear/none.gd`, `collapse/slice.gd`, `arrival/top.gd`, `layout/single.gd`, `verbs/piece.gd`.
- Tests: `tests/unit/sim/lock_sequence_test.gd` (exact hook order on_lock → clear → on_resolve_end → goal → top-out), `tests/unit/gameplay/{layer,none,slice,top,piece}_test.gd`.
- AC: Layer Clearing rules for layer + slice; Resolving lasts the data-driven duration (F2 from `clear.*_ms`, capped by `resolve_max_ms`); spawn centred on the bbox, long axis left-right, at `spawn_anchor`; blocked spawn = top-out; `cells_changed` events per resolve step.
- Deps: SIM-004, BRD-003.

**SIM-006 Goals, top-out, stars**
- Files: `src/gameplay/slots/goal/clear_n.gd`, `top_out/rescue.gd`, `trim.gd`, `lose.gd`, `src/core/sim/star_rater.gd`.
- Tests: `tests/unit/gameplay/{clear_n,rescue,trim,lose}_test.gd`, `tests/unit/sim/star_rater_test.gd`, `tests/integration/level_flow/meadow_01_headless_test.gd` (scripted command log wins meadow_01 headless — once DAT-004 lands).
- AC: Level Goals rules 2, 8, 10a–c; rescue F3 `k = max(1, s − (H_play − 1 − rescue_margin))` silent wipe; trim pop-off never fails and counts `cells_trimmed`; goal checked before trim; stars `{t2,t3}` by level time and `{s2,s3}` by layers.
- Deps: SIM-005.

**DAT-004 Meadow data set + meadow_01**
- Files: `assets/data/biomes/meadow.json`, `levels/meadow/meadow_01.json`, `rules/spin_only.json`, `rules/mascot_catch.json` (data only; behaviour lands in MDW-002), `strings.csv` keys for meadow titles/premises.
- Tests: covered by `level_files_test.gd`; plus `tests/unit/data/meadow_01_content_test.gd` (Level Data AC 8: spin only, 5 flat shapes, first 2 ∈ {O, I}).
- Deps: DAT-003. (mascot_catch rule may be omitted from meadow_01 until MDW-002.)

**VEW-001 BoardController**
- Files: `src/core/sim/…` none; `src/app/board_controller.gd` (Node; lives in `app/` because it is the node bridge, not core).
- Tests: `tests/unit/app/board_controller_test.gd` (catch-up cap `max_catch_up_ticks`; events re-emitted as the typed signals of §2.2; paused = no ticks), using `auto_free`.
- Deps: SIM-001 (can run in wave 3 against the skeleton; listed here because its signals are finalised with SIM-005).

### Wave 7

**UI-001 Minimal HUD + result panel**
- Files: `src/ui/hud/hud.tscn`, `hud.gd`, `result_panel.tscn`, Kenney placeholder icons + credits.
- Tests: `tests/unit/ui/hud_bindings_test.gd` (signals update labels; all text via `tr()` keys).
- AC: goal progress, next pieces (shape name/icon placeholder; PreviewBaker deferred), warnings left, level clock, pause; result shows stars, retry, next; screenshots portrait + landscape.
- Deps: VEW-001.

**APP-001 Main, AppFlow, base LevelScene, first level scene; meadow_01 end to end**
- Files: `src/app/main.gd`, `main.tscn` (set as `run/main_scene`), `app_flow.gd`, `level_scene.gd`, `level_scene.tscn` (base, §2.2), `profile_store.gd`, `scenes/levels/generic_level.tscn`, `scenes/levels/meadow/meadow_01.tscn` (inherits base; placeholder island + `BoardAnchor` + one mascot spot), `tests/unit/levels/level_scenes_test.gd`.
- Tests: `tests/integration/level_flow/level_scene_boot_test.gd` (scene loads meadow_01, runs N physics frames headless without errors, no orphans), `tests/unit/app/profile_store_test.gd`.
- AC: boot → meadow_01 directly (level select comes in MDW-011); win/lose/retry loop; **Android debug APK installs and plays meadow_01**; screenshots in `production/qa/evidence/meadow_01_*.png`; verification of open items: JSON packed and listable in APK, `get_global_class_list()` finds plugins in the export, RNG goldens on device (record results in ADR-0004/0005/0006).
- Deps: everything above.

### Wave 8 (Meadow content; MDW stories are mostly parallel with each other)

Each MDW story = its level scene `scenes/levels/meadow/meadow_XX.tscn` (inherits the base; placeholder island, `BoardAnchor`, mascot spots; real dressing comes from art) + the plugin(s) + rule JSON + level JSON + plugin tests + one headless level-flow smoke (`tests/integration/level_flow/meadow_XX_smoke_test.gd`: loads, plays a scripted log for N seconds, no errors) + screenshot evidence.

| ID | Title | New code | Data | Deps |
|---|---|---|---|---|
| MDW-002 | Tilt & Roll: starter pockets, all 3 axes, Pip's catch | `mechanics/mascot_catch.gd` (veto `piece.lock` when the lock leaves a new covered hole and clears nothing; `catches` param) | `meadow_02.json` (starter layers, opening bag) | APP-001 |
| MDW-002b | Pocket solvability test | none | — | `tests/unit/levels/meadow_02_pockets_test.gd`: each pocket exactly fillable by its named shape (brute force 24 orients × positions) | MDW-002 |
| MDW-003 | Breezy Hill: Dandelion Gust | `twists/gust.gd` (interval ± jitter from rule RNG, telegraph event, `try_translate` 1 cell) | `rules/gust.json`, `meadow_03.json` (8×4) | APP-001 |
| MDW-003b | Dandelion puff split piece | `mechanics/dandelion_puff.gd` (on lock: seeded split into two face-connected halves, `replace_piece`; halves fall separately) | `rules/dandelion_puff.json` (1 per bag via spawner `tags`) | MDW-003 |
| MDW-004 | Mushroom Ring: ring mask + Pop-up | `twists/mushroom_popup.gd` (every N locks, max M, sparkle one lock ahead, free top-surface cell from rule RNG) | `content` mushroom, `rules/mushroom_popup.json`, `meadow_04.json` | APP-001 |
| MDW-005 | Tall Tower: build race + trim + wobble | `slots/goal/height.gd` (H + coverage F2), `mechanics/wobble.gd`: sway = **current** overhang-cube count (recomputed each lock, so filling under an overhang lowers it); at `wobble_max` the last-placed piece slips 1 cell toward the heavier side, then sway resets to 0. Heavier side = the larger cube-count imbalance about the footprint centre, on x or z (ties: x before z; perfect balance: toward the slipping piece's own offset from centre, else +x) | `rules/build_race.json` (sets `clear.detector=none`, `goal.top_out=trim`), `rules/wobble.json`, `meadow_05.json` | SIM-006 |
| MDW-006 | Flower Bed: fill shape + sprouts | `slots/goal/shape.gd` (target layers via `AsciiGrid`, ★★★ needs no trim), `mechanics/sprout.gd` | `rules/fill_shape.json`, `rules/sprouts.json`, content sprout, `meadow_06.json` | SIM-006 |
| MDW-007 | Hide & Seek: Morning Fog | `twists/fog.gd` (per-cell visible/fade timers as status; reveal on clear); BoardView reads status → fade (CUSTOM.a, dither shader: first custom shader, by godot-shader-specialist) | `rules/fog.json`, `statuses.json`, `meadow_07.json` | VEW-002 |
| MDW-007b | Fog ghost piece + tap verb | `mechanics/fog_ghost.gd` (ignores locked cubes until tapped; tapped = lock where it is, nearest free cell up if blocked; **untapped = sinks through and fills the deepest free hole in its column**); `tap` gesture in `TouchInput` (via `CameraRig.pick_cell`); landing preview for the ghost read from knob `controls.fog_ghost_preview` (`faint` | `none`) | `rules/fog_ghost.json`; knob `controls.fog_ghost_preview` in `knobs/controls.json` (choice, default `faint`, rule_adjustable so difficulty rules can set `none`); `meadow_07` = `faint` | MDW-007 |
| MDW-008 | Dewdrop: survive + sticky | `slots/goal/survive.gd` | `rules/sticky_landing.json` (data only: `fall.lock_delay_ms` set 0, `fall.hard_drop_grace_ms` set 0, `fall.gravity_scale` ×0.7), `meadow_08.json` (stars by layers) | SIM-006 |
| MDW-009 | Topsy-Turvy: gravity flip | `twists/topsy_tumble.gd` (every K layers or T ms, warning event, `request_down_axis` applied at next Resolving; stack settles by cascade-to-new-floor step); camera unaffected (±y) | `rules/topsy_tumble.json`, `meadow_09.json` | SIM-006 |
| MDW-009b | Hatching eggs | `mechanics/hatching_egg.gd` (after N locks becomes chick cube, hops to lowest free neighbour along current down; bonus event if cleared first) | content egg/chick, `rules/hatching_eggs.json` | MDW-009 |
| MDW-010 | Meadow Mill: Mill Belt + boss composition | `mechanics/mill_belt.gd` (every N locks shift all CELL content +x with wrap via `move_cells`, at `on_resolve_end`; `validate()` rejects masks) | `rules/mill_belt.json`, `meadow_10.json` (belt + gust +z + flip with `flip_every_layers` 2 / `flip_every_ms` 180000) | MDW-003, MDW-009 |
| MDW-011 | Level select + progress | `ui/menus/level_select.tscn/.gd`; `AppFlow` boots to it, opens level scenes by path | `biomes/meadow.json` `{id, scene}` order, unlock = previous level won | APP-001 |
| MDW-012 | Meadow pass: all 10 on device | none (fixes only) | star times check | all MDW |

**Parallel groups summary**

| Wave | Stories (parallel inside a wave) |
|---|---|
| 0 | FND-000, FND-001 (running) |
| 1 | SHP-001, BRD-001, DAT-001, RUL-001, VEW-004 |
| 2 | SHP-002, BRD-002, SIM-001 |
| 3 | SHP-003, BRD-003, SIM-002, DAT-002, VEW-001 (against skeleton) |
| 4 | SIM-003, DAT-003, RUL-002, VEW-002 |
| 5 | SIM-004, VEW-003, INP-001 |
| 6 | SIM-005 → SIM-006 (sequential), DAT-004 (parallel) |
| 7 | UI-001, then APP-001 (meadow_01 on device) |
| 8 | MDW-002, 003, 004, 005, 006, 007, 008, 009, 011 in parallel; then 002b, 003b, 007b, 009b, 010; then 012 |

Critical path: FND-001 → SIM-001 → SIM-002 → (SIM-003, RUL-002) → SIM-004 → SIM-005 → SIM-006 → APP-001 → MDW-009 → MDW-010 → MDW-012.

---

## 7. Coding conventions (binding for coders)

1. **Static typing everywhere**: every `var`, parameter and return; typed arrays (`Array[Vector3i]`) and typed dictionaries (`Dictionary[StringName, int]`, filled from JSON with `typed.assign(parsed)`, verified on 4.7.2). Typed-return overrides must `return` explicitly (4.7 change).
2. **Doc comments** (`##`) on every `class_name` and every public method/signal, with a one-line usage example on core APIs. Private members start with `_`.
3. **No magic numbers.** Gameplay and view tunables live in `assets/data/knobs/*.json` and are read by knob id. The only code constants allowed are structural facts with a source comment (`const SIM_HZ := 60  # ADR-0001`, `Orientations.COUNT := 24`, delta op codes). Tests may use literal boundary values when the number is the point.
4. **Integer fixed point in the sim**: no `float` in `core/` or `gameplay/` state; scalars are milli-units (`1000 = 1.0`); time is integer ms from `now_ms()`; multiply before divide; no `delta` accumulation.
5. **Randomness**: only `Seeds` creates gameplay RNGs; plugins use `api.rng()`. `randi/randf/randomize`, `Time`, `OS` ticks and `FastNoiseLite` are banned in `src/core` and `src/gameplay` (test-enforced).
6. **Plugins**: one `class_name` per file, `const PLUGIN_ID: StringName`, extends exactly one base, talks only to `RuleApi`, holds no static state.
7. **Nodes**: `@onready` for child references, no `get_node` across scenes, signals declared at the top with typed parameters, connect in `_ready`/`setup`, never in `_process`. Disable `_process` when idle. No `MeshInstance3D` per locked cube anywhere.
8. **Untrusted data**: never `load()`/`ResourceLoader` on `user://` or data-derived paths; JSON only (test-enforced).
9. **Tests**: gdUnit4; file `tests/unit/<system>/<system>_<feature>_test.gd`, function `test_<scenario>_<expected>`; Arrange/Act/Assert; `auto_free()` for Nodes (orphans fail the run, exit 101); deterministic seeds; no file I/O in unit tests except the dedicated data-file tests (`level_files_test`, `knob_files_test`, `shape_bank_file_test`), which read `res://` data on purpose. Bug fix = failing regression test first.
10. **Run before closing**: `godot --headless --path . --import` once per clone, then the CI command from `coding-standards.md`. A parse check is not a run; player-visible stories need a retained screenshot.
11. **Commits**: Conventional Commits, story ID in the body (`Story: SIM-004`).

**Godot APIs this plan names, and their verification status**

| API | Status |
|---|---|
| `RandomNumberGenerator`, `Engine.physics_ticks_per_second`, `physics/common/physics_interpolation`, `Node.reset_physics_interpolation()`, `Engine.get_physics_interpolation_fraction()`, `JSON.parse_string` float numbers, typed `Dictionary` + `assign()`, `@abstract` | Verified on 4.7.2 (ADR-0001/0002/0004/0006, `current-best-practices.md`) |
| `ProjectSettings.get_global_class_list()` | Works in editor (ADR-0004); **Android export unverified** → APP-001 |
| `MultiMesh` format-before-count, `set_instance_transform`, `set_instance_color`, `visible_instance_count`; `MultiMeshInstance3D` | Stable 4.x API; not covered by the reference docs; ADR-0007 item 2 verified in VEW-002 |
| `FileAccess.get_file_as_string`, `DirAccess.get_files_at`, `JSON.stringify(data, "", true)`, `String.sha256_text()`, `Camera3D.PROJECTION_ORTHOGRAPHIC`, `Tween`/`create_tween()`, `StandardMaterial3D.vertex_color_use_as_albedo`, `NOTIFICATION_APPLICATION_PAUSED` | Stable since 4.0; **not listed in the engine-reference docs, so unverified for 4.7.2**: each story confirms with a headless test before relying on it. `DirAccess` listing inside an exported `.pck` is an open item (ADR-0005) → APP-001; fallback is an index list in `biomes/*.json` and a generated `assets/data/index.json`. |
| `Tween.tween_await()` (4.7 new) | Not used. |

---

## 8. Risks and deliberate deferrals

### Risks

| # | Risk | Mitigation |
|---|---|---|
| R1 | 1014-vertex cubes + outline blow the GPU budget on a mid-range phone | Debug view has no outline; ADR-0007 device stress test before the real shader; mitigation ladder (hidden-cube culling first). |
| R2 | `get_global_class_list()` empty in Android export | Check at APP-001; fallback generated `plugins.json` behind the same `PluginRegistry` constructor. |
| R3 | `*.json` missing or not listable in the APK | Export filter in FND-000; device check in APP-001; index-file fallback. |
| R4 | Plugins reach into sim internals or core grows `if twist == …` branches | Layering test, `RuleApi` as the only plugin surface, code review against §3. |
| R5 | Sim over budget in GDScript on device (connected groups, shifts) | Profile at MDW-012; ADR-0008 path only with evidence. |
| R6 | Dev add-ons (`_mcp_game_helper` autoload, godot_ai) ship in release | FND-000 export exclusion/guard + test. |
| R7 | Parallel coders collide on `board_sim.gd` | SIM-004/005/006 are sequential by design; MDW stories add plugin files only. |
| R8 | Design docs disagree (Level Data GDD AC 9 lists Spawned Objects for meadow_10; approved meadow.md uses Belt + Gust + Flip) | meadow.md wins (newer, approved); GDD owner to fix AC 9. |
| R9 | Gravity flip "settle to new floor" needs a cascade-like collapse | Topsy Tumble requests a one-off `clear.collapse = cascade` for that Resolving or moves cells itself via `move_cells`; decided inside MDW-009, no core change. |

### Deferred on purpose (not built in this plan)

- **Networking** (`src/net/`, `NetSession` autoload, ENet, QR, WebRTC): ADR-0009 epic after Meadow.
- **C++ / GDExtension** (`src/native/`): ADR-0008, only with a device profile.
- **Physics Mode** (`BoardKind` base, Jolt boards): Alpha. Meadow 05 "wobble" is a grid rule, not physics.
- **Multi-board layouts**, `PieceRouter`, `BoardKind`, `StandingFn` bases: first written by meadow_h3 (Two Fields) or tournament stories.
- **Bonus level and hard track** (`meadow_bonus`, `h1`–`h3`): after MDW-012 (fixed list and out-of-pieces already exist in the spawner; ants and two fields need new atoms).
- **Production visuals**: block shader with outline/dither/status looks, PreviewBaker atlas, clear ripple and settle animation, diorama dressing, mascot skits, Pip's pointing hint, SE05 rubber duck, audio. Each is a later presentation story; the sim already emits the events they need.
- **Hold, Scheme B gestures, items/buffs/perks, scoring points economy, daily generator, editor validator panel**: their GDDs are set; no Meadow level needs them.
- **Recipe expansion** in the loader is built (DAT-002), but Meadow levels write explicit knobs/rules; recipes become primary with the daily generator.

---

## 9. Changes this plan made to the ADRs (applied 2026-10-10, with acceptance)

1. `architecture.md` §6: add `core/model/`; `gameplay/` subfolders are `slots/<slot>/`, `verbs/`, `twists/`, `mechanics/`, `daily/`; `board_controller.gd` lives in `app/`; `ascii_grid.gd` in `core/board/`.
2. ADR-0001: `BoardSim._init(level, round_seed, catalog: GameCatalog)` (was `RuleCatalog`); lock veto `piece.lock` with return-to-spawn.
3. ADR-0002 §6 / ADR-0005: starting contents and targets are ASCII layers with a data-driven glyph legend (§5).
4. ADR-0004: top-out plugin ids `rescue | trim | lose` (GDD enum; "warnings" renamed to `rescue`); rule layers `content` and `mascot` do not count toward F3.
5. ADR-0005: level JSON uses one `rules` list and `goal.type` inside `goal`; `stars` is `{t2,t3}` or `{s2,s3}`.
6. ADR-0007: debug view uses per-instance setters before the packed buffer upload.

---

## 10. User gameplay decisions (2026-10-10)

| Topic | Decision | Story |
|---|---|---|
| ADRs | All nine accepted by the user | — |
| Wobble (05 Tall Tower) | Sway = current overhang count; filling under an overhang lowers it; sway resets to 0 after a slip. Heavier side chosen by the dev team (MDW-005 row) | MDW-005 |
| Fog ghost (07), untapped | Sinks through locked cubes and fills the deepest hole in its column | MDW-007b |
| Level scenes | Each official level is its own scene inheriting the base level scene and pointing at its level JSON (§2.2); rules stay in JSON; player/daily levels use `generic_level.tscn` | APP-001, MDW-* |
| Fog ghost landing preview | Set per level and difficulty: easy levels show a faint preview, harder ones none. Knob `controls.fog_ghost_preview` (`faint` / `none`), rule-adjustable | MDW-007b |
