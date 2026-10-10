# Wacky Towers: Modular Layout (src/ folders, level scenes, mechanics database, game parts, block sets)

> **Status**: Proposed (godot-specialist, 2026-10-10). Changes the folder names in `architecture.md` §6 and `implementation-plan.md` §1–§3; no ADR decision changes. Applying it needs the edits listed in §9.
> **Engine**: Godot 4.7.2, GDScript, Mobile renderer.
> **Goal**: separate folders for the framework, levels, UI, mechanics and the pure sim, so many small agents can write chunks in parallel without colliding, and so a new level or mechanic never edits core code.

Every number here is a tunable default.

---

## 1. Principles (unchanged, restated as folder rules)

1. **`src/core/` is pure.** RefCounted/Resource only. No `Node`, signals, `await`, `Time`, `OS`, global RNG, floats in sim state. It never imports anything outside `src/core/`.
2. **Mechanics are plugins.** Every rule-bending atom (slot default, twist, level mechanic, obstacle behaviour) lives in `src/mechanics/` and talks only to `RuleApi`. Core finds plugins through `PluginRegistry` by `PLUGIN_ID`.
3. **Values are data.** Knobs, content types, mechanic definitions, levels and palettes are JSON. Scenes hold presentation only.
4. **Each level is its own scene and its own folder.** The scene owns the *place*; its JSON owns the *rules*.
5. **The game framework is one scene** (`PlaySession`) that is the same for every level. It instances the level scene; levels never contain framework nodes.
6. **Keep what works.** Files already on disk stay where they are (§9.1 lists zero moves for code that exists; only planned paths change).

---

## 2. Final folder tree

```
src/
  core/                         PURE SIM (no Node). Exists; unchanged.
    rng/        seeds.gd                                                   (done)
    shapes/     orientations.gd, shape_def.gd, shape_bank.gd               (ADR-0003)
    board/      board_state.gd, board_spec.gd, board_spec_result.gd, board_limits.gd,
                content_types.gd, ascii_grid.gd, json_num.gd               (ADR-0002)
    model/      level_data.gd, game_catalog.gd, sim_command.gd, sim_event.gd,
                goal_state.gd, validation_issue.gd                         (plain value types)
    rules/      knob_defs.gd, knob_registry.gd, rule_api.gd, rule_def.gd, rule_instance.gd,
                rule_runtime.gd, plugin_registry.gd, hook_context.gd, veto_result.gd,
                bases/ (rule_behaviour, clear_detector, clear_group, collapse_policy,
                        arrival_style, arrival_plan, goal_evaluator, top_out_policy,
                        control_verb, layout_kind)                         (ADR-0004)
    sim/        sim_events.gd, board_sim.gd, active_piece.gd, movement.gd, spawner.gd,
                replay.gd, star_rater.gd                                   (ADR-0001)
  data/                         IO + parse + validate (exists). json_reader.gd, level_loader.gd,
                                load_result.gd, catalog_loader.gd, catalog_result.gd,
                                level_migrations.gd, level_validator.gd, mechanic_catalog.gd
  mechanics/                    PLUGINS ONLY (was `gameplay/` in the plan; nothing on disk yet)
    slots/<slot>/<id>.gd        framework defaults, one small file each:
                                arrival/top.gd, clear/layer.gd, clear/none.gd, collapse/slice.gd,
                                goal/clear_n.gd, goal/height.gd, goal/shape.gd, goal/survive.gd,
                                top_out/rescue.gd, top_out/trim.gd, top_out/lose.gd,
                                layout/single.gd, verb/piece.gd
    <mechanic_id>/              one folder per behaviour mechanic/twist/obstacle:
                                <mechanic_id>.gd (class_name, const PLUGIN_ID) + optional
                                helper scene/shader the VIEW looks up by id (never core)
                                e.g. gust/, mushroom_popup/, fog/, topsy_tumble/, mill_belt/,
                                wobble/, sprout/, hatching_egg/, dandelion_puff/, fog_ghost/, mascot_catch/
  view/                         RENDERING (exists: camera_math.gd)
                                camera_math.gd, camera_rig.gd/.tscn, art_set.gd, board_geom.gd,
                                board_view.gd/.tscn, piece_view.gd/.tscn, shaders/ (later)
  game/                         FRAMEWORK (was `app/` + `input/` in the plan; nothing on disk yet)
    main.gd, main.tscn          boot: catalog, profile, first level (run/main_scene)
    app_flow.gd                 screen switching (level select ⇄ play), after first playable
    play/                       play_session.gd/.tscn (the framework scene), board_controller.gd
    level/                      level_stage.gd (base script every level scene's root uses)
    input/                      gestures.gd, keyboard_input.gd, touch_input.gd/.tscn
    profile_store.gd            after first playable
  ui/                           HUD + menus (Control scenes; read signals only)
    hud/                        hud.gd/.tscn, result_panel.gd/.tscn
    menus/                      level_select.gd/.tscn (after first playable)
  levels/                       ONE FOLDER PER LEVEL (scene + its JSON side by side)
    _template/                  level_stage_base.tscn (root LevelStage + BoardAnchor + Diorama + MascotSpots + default light/env)
    _generic/                   generic_level.tscn (player/daily levels; dressed from biome JSON)
    meadow/
      meadow_01/                meadow_01.tscn (inherits _template), meadow_01.json
      meadow_02/ … meadow_10/, meadow_bonus/, meadow_h1/ … (same shape)
      _shared/                  biome props/scenes reused by several meadow levels (optional)
  dev/                          dev-only tools and part scenes (exists: block_set_preview.*);
                                game-part scenes gp1_board_part.tscn … live here
  net/, minigames/, native/     not created until their epics (plan §8)

assets/
  models/blocks/<set_id>/       blk_<set>_<shape>.glb + blk_<set>_cube.glb (candy_toy: 68 files; neon_voxel: 67, NO cube)
  data/
    knobs/*.json                exists
    content/blocks.json         exists (content types: glyph, solid, fills_layer)
    mechanics/<id>.json         MECHANICS DATABASE (§5); replaces the plan's assets/data/rules/
    biomes/<biome>.json         {art_set, levels: [{id, scene}], generic dressing, music}
    palettes/<set_id>.json      hue id → colour, per block set (§7)
    shapes/shape_bank.tres      generated (ADR-0003), shape_hand_fields.json (hand fields: hue, family, motif)
    input/desktop_keys.json     dev keyboard bindings (data, registered into InputMap at runtime)
    atom_tags.json, credits.json
tools/asset-pipeline/           block_post_import.gd (exists), extract_shape_bank.gd, sample_block_colours.gd
tests/unit/<module>/…           mirrors src: core subsystems keep their folders (board_grid, shapes, rng, rules, sim, model),
                                plus data/, view/, mechanics/, game/, ui/, levels/
tests/integration/level_flow/   headless level runs (meadow_01 win, boot)
```

**Stray file**: `res://control.tscn` at the project root is an empty `Control` (217 B, untracked). Delete it; nothing references it.

---

## 3. Allowed import directions

A module may name `class_name`s only from the modules in its row. Signals and dictionaries cross boundaries; nothing else.

| Module | May import | Must never import |
|---|---|---|
| `core/rng`, `core/shapes`, `core/board` | nothing | everything else |
| `core/model` | `core/board`, `core/shapes`; the three type names `KnobDefs`, `RuleDef`, `PluginRegistry` (whitelisted, plan §1.2) | sim, data, mechanics, view, game, ui, levels |
| `core/rules` | `core/rng`, `core/shapes`, `core/board`, `core/model` | sim, data, mechanics, view, game, ui, levels |
| `core/sim` | all `core/*` | data, mechanics (only through `PluginRegistry`), view, game, ui, levels |
| `data` | `core/*` | mechanics, view, game, ui, levels |
| `mechanics` | `core/rules` (bases, `RuleApi`, `HookContext`…), `core/board`, `core/shapes`, `core/model` | `core/sim`, data, view, game, ui, levels, other mechanics |
| `view` | `core/*` read-only getters and value types, `data/JsonReader` (palette read) | mechanics, game, ui, levels |
| `ui` | `core/model` value types (`SimEvent`), `core/sim/SimEvents` constants | data, mechanics, view internals, game, levels |
| `game` | everything except `levels` (the framework never names a level; it loads one by path from biome data) | `levels` |
| `levels` | `game/level/LevelStage` only (scene root script); view/ui scenes may be instanced for dressing | core, data, mechanics, ui scripts |
| `dev`, `tools`, `tests` | anything | — (never shipped; export excludes `src/dev/`) |

Enforced by `tests/unit/architecture/layering_test.gd` (FND-000), with the folder names above.

```
          game ─────────────────────────────────────────┐
        /  │   \                                         │
     ui  view  input(game/input)      levels ──▶ game/level/LevelStage
        \  │   /
          data ──────────────▶ core/*  ◀── mechanics (plugins, via PluginRegistry)
```

---

## 4. Level scenes (each level is its own scene)

### 4.1 Decision on path conflict G1 (coder handoff)

**Levels live in `src/levels/<biome>/<level_id>/`, scene and JSON together.** This supersedes the plan's split (`scenes/levels/meadow/*.tscn` + `assets/data/levels/meadow/*.json`). Why: one folder = one level, so a level chunk touches one folder; the user asked for a `levels` module; the export filter `*.json` already includes JSON anywhere under `res://`. Player and daily levels stay JSON-only in `user://levels/` and play on `src/levels/_generic/generic_level.tscn`.

### 4.2 What a level scene owns vs what the framework provides

| Level scene (`src/levels/<biome>/<id>/<id>.tscn`) owns | Framework scene (`src/game/play/play_session.tscn`) owns |
|---|---|
| Root `LevelStage` (Node3D, script `src/game/level/level_stage.gd`) | `BoardController` (owns `BoardSim`, fixed tick) |
| `Diorama`: island, props, biome set dressing, backdrop | `BoardRoot` → `BoardView` (MultiMesh) → `PieceView` (piece + ghost) |
| `BoardAnchor` (Marker3D): where board footprint centre, floor level sits | `CameraMount` → `CameraRig` → `Camera3D` (orthographic, 12 snaps) |
| `MascotSpots` (Node3D) → `Marker3D` by name (`pip_idle`, `pip_cheer`) | `UI` (CanvasLayer): `Hud`, `TouchInput`, `ResultPanel` |
| `WorldEnvironment` + `DirectionalLight3D` (biome look; inherited default from `_template`) | `KeyboardInput` (Node, desktop dev keys) |
| optional `Skits` (AnimationPlayer: `intro`, `payoff`) | pause, retry, result flow |
| exports: `level_json`, `block_set`, `camera_yaw_index`, `camera_elevation_override_deg` | wiring: signals from `BoardController` to view, HUD, stage |
| **never**: rule values, scripts on framework nodes, board size | **never**: biome dressing, level ids |

```gdscript
class_name LevelStage extends Node3D
## Root of every level scene: the place, not the rules. The framework reads these exports.
@export_file("*.json") var level_json: String = ""          # res:// path to this level's JSON ("" on generic_level)
@export var block_set: StringName = &""                      # "" = biome art_set (§7)
@export var camera_yaw_index: int = 0                        # Camera rule 3
@export var camera_elevation_override_deg: float = 0.0       # 0 = knob default
func board_anchor() -> Marker3D                              ## $BoardAnchor; required
func mascot_spot(spot: StringName) -> Marker3D               ## $MascotSpots/<spot> or null
func play_skit(skit: StringName) -> void                     ## no-op if no Skits/AnimationPlayer or no such animation
```

### 4.3 How the framework loads a level

1. `Main._ready`: `CatalogLoader.load_catalog()` → `GameCatalog` (fatal on errors in debug).
2. Pick the level: first playable boots straight into `meadow_01` (path from `biomes/meadow.json`). Later `AppFlow.open_level(scene_path)` from level select.
3. `var stage: LevelStage = load(scene_path).instantiate()` (internal `res://` path from biome data only, ADR-0005).
4. `LevelLoader.load_level(stage.level_json, catalog)` → `LoadResult {level, issues}`; errors stop here with a message.
5. `var session: PlaySession = PLAY_SESSION.instantiate()`; `add_child(session)`; `session.start(stage, level, catalog, round_seed)`.
6. `PlaySession.start`: adds the stage as child `Stage`; puts `BoardRoot` at `stage.board_anchor().global_transform`; builds `BoardSim.new(level, round_seed, catalog)`; binds view, camera (yaw from the stage export), HUD, input; connects signals; starts the countdown.
7. `PlaySession.finished(result)` → `Main` shows the result panel's retry → `session.restart()` (new sim, same stage, same seed rule).

Board coordinates: the cell `(x, y, z)` centre is at `(x − W/2 + 0.5, y + 0.5, z − D/2 + 0.5)` in `BoardAnchor` space (audit default, `BoardGeom.cell_center`). So the anchor marks the footprint centre at floor level, which is what a set dresser places on the island.

### 4.4 Which levels need their own dressing (scene differences)

All official levels get a scene (the user's rule), but most differences are dressing only. From `design/levels/meadow.md` and `production/levels/meadow/coder-handoff.md`:

| Level | Scene must differ because | Mechanic-specific view nodes |
|---|---|---|
| 01 First Sprout | seed plot island, rubber duck hidden under it (SE05, later), Pip helper spot | — |
| 02 Tilt & Roll | burrow cut-away, duck | Pip pointing (later) |
| 03 Breezy Hill | hillside lane 8×4, Miller on the hill, world-anchored wind telegraph | gust telegraph (from `mechanics/gust/` scene, instanced by the view on its event) |
| 04 Mushroom Ring | pond ring (masked centre) | mushroom mesh comes from content type, no scene node |
| 05 Tall Tower | hilltop, mill in view, height sign at layer 9 | target-line marker |
| 06 Flower Bed | garden bed 8×8; target-shape outline | target overlay |
| 07 Hide & Seek | foggy hollow, hushed lighting | fog look = shader status (ADR-0007) |
| 08 Dewdrop | dewy lawn, tense stage | — |
| 09 Topsy-Turvy | tree island; scene flips its sky/props on gravity flip | none in core; listens to `sim_event` |
| 10 Meadow Mill | mill yard, belt dressing, boss Miller with two phases | belt arrows |

Rule: a level-specific visual reacts to `PlaySession.sim_event(ev)` through a script on a **dressing node** inside the level scene (allowed: levels may react to signals; they never change sim state).

---

## 5. Mechanics database

### 5.1 Format and location

**One JSON file per mechanic in `assets/data/mechanics/<id>.json`.** It is the rule definition (`RuleDef`, ADR-0004) plus catalogue metadata, so there is one source, not two. The flat folder is read by the existing `JsonReader.read_dir` (no recursive listing inside a `.pck`, which is unverified on Android). Behaviour code, if any, is `src/mechanics/<id>/<id>.gd` (or `src/mechanics/slots/<slot>/<id>.gd` for slot plugins). Sources: `mechanics-catalog.md`, `mechanics-module.md` (atom codes and slots), `twist-library.md`, `obstacles.md`, `rule-twist-framework.md`, `design/mechanics/README.md`.

```json
{
  "id": "gust",
  "atom": "EV01",
  "use": "rule",
  "layer": "twist",
  "slot": "",
  "name_key": "MECH_GUST_NAME",
  "desc_key": "MECH_GUST_DESC",
  "summary": "Every interval ± jitter, pushes the falling piece 1 cell along wind_dir after a telegraph.",
  "params": {
    "wind_dir":  {"type": "choice", "default": "+x", "choices": ["+x","-x","+z","-z"]},
    "interval_ms": {"type": "count", "default": 8000, "min": 2000, "max": 30000},
    "jitter_ms": {"type": "count", "default": 2000, "min": 0, "max": 10000, "allows_zero": true},
    "strength":  {"type": "count", "default": 1, "min": 1, "max": 3},
    "warn_ms":   {"type": "count", "default": 1000, "min": 0, "max": 3000, "allows_zero": true}
  },
  "modifiers": [], "vetoes": [], "lifetime": {},
  "plugin": {"kind": "RuleBehaviour", "id": "gust"},
  "view": {"scene": "res://src/mechanics/gust/gust_telegraph.tscn"},
  "content": [],
  "requires": [], "provides": ["moves_piece"], "incompatible_with": [],
  "biomes": ["meadow"],
  "gdd": "design/gdd/twist-library.md#wind",
  "status": "designed"
}
```

| Field | Meaning |
|---|---|
| `use` | `rule` (listed in a level's `rules`), `slot` (chosen through a slot knob such as `clear.detector`), `content` (a content type with optional behaviour) |
| `layer` | `twist`, `mechanic`, `content`, `mascot`, `slot`; the F3 budget counts `twist` and `mechanic` |
| `slot` | for `use: slot`, the slot knob id (`clear.detector`, `goal.type`, …) |
| `params` | the schema: same entry shape as knob tables (`type`, `default`, `min`, `max`, `allows_zero`, `choices`), so `KnobDefs`' coercion rules are reused, not reimplemented |
| `plugin` | `null` for data-only mechanics (sticky landing, spin only, build race bundle); else base kind + `PLUGIN_ID` |
| `view` | optional presentation scene the view instances on this mechanic's events (never loaded by core) |
| `content` | content type ids from `content/blocks.json` this mechanic places (mushroom, sprout, egg) |
| `requires`/`provides`/`incompatible_with` | compatibility tags (ADR-0004 atoms, `atom_tags.json`) |
| `biomes` | where designers may use it; outside = validator **warning**, not error |
| `gdd`, `status` | traceability: GDD anchor; `idea` / `designed` / `built` / `tested` |

Core type: the existing `RuleDef` (`src/core/rules/rule_def.gd`, CH-033 done) holds one parsed entry; it gains the catalogue fields (§9.2 edit 7) instead of a second class. `MechanicCatalog` (`src/data/mechanic_catalog.gd`) parses and validates the folder into `GameCatalog.rule_defs`.

### 5.2 How a level uses mechanics

```json
"rules": [ {"id": "gust", "params": {"wind_dir": "+z", "interval_ms": 9000}} ]
```
Slot mechanics are chosen by knob: `"knobs": {"clear.detector": "none", "goal.top_out": "trim"}`. Omitted params take the catalogue default.

### 5.3 What the validator checks (DAT-003 + catalog chunks)

1. Catalogue load: unique `id`; every field known; `params` entries valid knob-style entries; `plugin` resolves in `PluginRegistry` (`create(kind, id) != null`); every plugin id found in the registry has exactly one catalogue entry (no orphan code); `content` ids exist; `gdd` file exists (test only); `slot` mechanics appear in that slot knob's `choices`.
2. Level: each `rules[i].id` exists and has `use: rule`; each param name is in the schema and coerces (named error `rules[1].params.interval_ms: 500 outside 2000..30000`); F3 budget by layer (`rules.max_twists`, `rules.max_level_mechanics`); tag compatibility and `incompatible_with`; biome not listed → warning; then the plugin's own `validate(level, catalog)`.
3. CI: `tests/unit/data/mechanic_catalog_file_test.gd` loads the real folder; `tests/unit/levels/level_files_test.gd` validates every `src/levels/**/<id>.json`.

### 5.4 Adding a mechanic (no core edit)

1. `assets/data/mechanics/<id>.json` (designer or Haiku chunk).
2. If it behaves: `src/mechanics/<id>/<id>.gd`, `class_name <Name> extends RuleBehaviour` (or the slot base), `const PLUGIN_ID := &"<id>"`.
3. `tests/unit/mechanics/<id>_test.gd` with `FakeRuleApi`.
4. Use it in a level's `rules`. Nothing else changes.

---

## 6. Game parts (integration)

Small chunks are combined into **game parts**: after a group of chunks, one integration ticket (`GP-n`) builds a working piece of the game **in the live editor through the godot-ai MCP** (`scene_manage`, `node_create`, `script_attach`, `scene_save`, `project_run`, `editor_screenshot`, `input_simulate`, `logs_read`), saves it under the modular folders, and proves it with a screenshot and a short scripted playtest. A GP ticket writes no new gameplay logic; if wiring needs a code change, it stops and files a chunk.

| Part | Builds | Scenes it saves | Consumes |
|---|---|---|---|
| GP-0 (in flight) | candy_toy GLB board preview | `src/dev/board_preview.tscn` | block GLBs |
| GP-1 Board | real `BoardState` from meadow_01 JSON drawn by `BoardView` with candy_toy cubes, a few placed blocks, camera framing | `src/view/board_view.tscn`, `src/dev/gp1_board_part.tscn` | BoardSpec, BoardState, LevelLoader, ArtSet, palette, BoardView, CameraRig |
| GP-2 Piece | sim spawns meadow_01 pieces; a candy_toy piece falls; keys move/spin; ghost shows | `src/view/piece_view.tscn`, `src/dev/gp2_piece_part.tscn` | Spawner, ActivePiece, Movement, `top` arrival, BoardSim fall, BoardController, PieceView, KeyboardInput |
| GP-3 Drop/lock/clear | hard/soft drop, lock delay, lock write, layer clear + slice, goal + rescue; headless win test | `src/dev/gp3_lock_clear_part.tscn` | BoardSim lock + resolve, clear/collapse/goal/top-out plugins |
| GP-4 Camera + input | 12-snap rotate-view, view-relative moves, touch buttons + desktop keys | `src/game/input/touch_input.tscn`, `src/dev/gp4_input_part.tscn` | CameraRig, Gestures, KeyboardInput, TouchInput |
| GP-5 First playable | `Main` → `meadow_01` level scene inside `PlaySession` with HUD; QA plays it with `input_simulate` to a win and a loss | `src/game/main.tscn`, `src/game/play/play_session.tscn`, `src/levels/meadow/meadow_01/meadow_01.tscn`, `src/ui/hud/*.tscn` | everything above |

Part scenes in `src/dev/` stay as regression sandboxes (excluded from export).

---

## 7. Block sets (use the GLBs we made)

- **One set per level, swappable.** `LevelStage.block_set` (scene export) wins; empty → `biomes/<biome>.json` `art_set`. Meadow default: `candy_toy`.
- **`ArtSet`** (`src/view/art_set.gd`) resolves `res://assets/models/blocks/<set>/blk_<set>_<shape>.glb` (falling piece = the shape GLB itself, instanced) and `blk_<set>_cube.glb` (its first `MeshInstance3D` mesh = the MultiMesh mesh for locked cubes).
- **Locked cubes** are one `MultiMeshInstance3D` per board with `use_colors = true` and a material override with `vertex_color_use_as_albedo = true`; instance colour = `palettes/<set>.json[hue]`, hue id = the shape's `hue_id` from `shape_hand_fields.json`. The palette for candy_toy is **sampled from the candy_toy GLB materials** (CH-038), so a piece does not change colour when it locks (Fall GDD: no change of look). Proper block shader (outline, statuses) stays ADR-0007 later work.
- **neon_voxel has no `blk_neon_voxel_cube.glb`** (67 files; QA red: `block_set_import_test` "neon_voxel: no blk_neon_voxel_cube*.glb"). `ArtSet.cube_mesh()` returns null and `ArtSet.available_sets()` excludes it, so selecting it fails at load with a named error. Owner: technical-artist exports the cube. Not on the first-playable path.
- Shape geometry comes from the shape bank (`extract_shape_bank.gd` reads candy_toy cube translations); the GLB is only the look. The pivot is the cube nearest the bbox centre (audit default); the extractor stores the GLB-space position of that cube as `ShapeDef.source_pivot` so `PieceView` can place the GLB root at `cell_center(origin) − R·source_pivot`.

---

## 8. How things are added (summary)

| Add | Touch only |
|---|---|
| Level | `src/levels/<biome>/<id>/` (scene inheriting `_template/level_stage_base.tscn` + JSON) + one `{id, scene}` line in `biomes/<biome>.json` |
| Mechanic / twist / obstacle | `assets/data/mechanics/<id>.json` (+ `src/mechanics/<id>/` + test) |
| Slot plugin | `src/mechanics/slots/<slot>/<id>.gd` + catalogue entry + `choices` in the slot knob |
| Block set | `assets/models/blocks/<set>/` + `assets/data/palettes/<set>.json` |
| Knob | owning `assets/data/knobs/<system>.json` |
| HUD widget | `src/ui/hud/` |

---

## 9. Reconciliation: every change to existing docs and tickets

### 9.1 File moves for existing code

None. Everything on disk (`src/core/**`, `src/data/json_reader.gd`, `src/view/camera_math.gd`, `src/dev/block_set_preview.*`) is already where this layout puts it. Two conditional moves:
- If CH-032 wrote `sim_command.gd` / `sim_event.gd` under `src/core/sim/`, `git mv` them to `src/core/model/` (plan gap 5 decision). `sim_events.gd` stays in `core/sim`.
- `production/levels/meadow/data/meadow_NN.json` → `src/levels/meadow/meadow_NN/meadow_NN.json` (copy as each level's chunk lands; CH-039 does meadow_01).

### 9.2 Doc and ticket edits (for the orchestrator)

1. `architecture.md` §6 tree: `gameplay/` → `mechanics/`; `app/` + `input/` → `game/` (`game/input/`); add `levels/`; level row in §5 recipes → `src/levels/<biome>/<id>/`.
2. `implementation-plan.md` §1.1 layering table: rename layers `gameplay`→`mechanics`, `app`→`game`, `input`→`game/input`; add `levels` row (§3 here).
3. `implementation-plan.md` §1.2 `src/gameplay/` block → `src/mechanics/` (slots/ unchanged; `twists/` and `mechanics/` subfolders → `src/mechanics/<id>/`); §1.2 `src/app/` → `src/game/` (`level_scene.gd` → `game/play/play_session.gd` + `game/level/level_stage.gd`); `src/input/` → `src/game/input/`.
4. `implementation-plan.md` §1.3: `assets/data/rules/` → `assets/data/mechanics/`; `scenes/levels/…` and `assets/data/levels/…` → `src/levels/<biome>/<id>/`; add `palettes/<set>.json`, `input/desktop_keys.json`, `shapes/shape_hand_fields.json`.
5. `implementation-plan.md` §2.2: replace "level scene inherits the base level scene (LevelScene)" with **composition**: level scene root `LevelStage` (inherits `src/levels/_template/level_stage_base.tscn`), instanced by the framework scene `PlaySession`. Same user rule (one scene per level, rules in JSON), cleaner module boundary: levels no longer contain framework nodes.
6. `implementation-plan.md` §1.2 and ADR-0003 Key Interfaces, CH-026, CH-027: **`PackedVector3iArray` does not exist in Godot 4.7** (editor-check 2026-10-10). Use `Array[Vector3i]` everywhere (`offsets()`, `canonical_key(offsets: Array[Vector3i])`, `_rotated`, `_normalise`, `build(id, offsets: Array[Vector3i])`, `RuleApi.replace_piece(cells_groups: Array[Array])`). `shape_def.gd` on disk already does this.
7. CH-033 / `RuleDef`: extend with catalogue fields (`atom`, `use`, `slot`, `desc_key`, `summary`, `plugin_kind`, `view_scene`, `content`, `biomes`, `gdd`, `status`) in catalog chunk CH-074; no new class.
8. ADR-0005 file table: `rules/<id>.json` → `mechanics/<id>.json`; official levels `res://src/levels/<biome>/<id>/<id>.json`; official level scenes `res://src/levels/<biome>/<id>/<id>.tscn` with root `LevelStage`.
9. ADR-0007: block set per level from `LevelStage.block_set` → biome `art_set`; palette per set `palettes/<set>.json`.
10. FND-000 `layering_test.gd` (if written): folder names per §3.
11. CH-025 (in flight): `frame_board` keeps `position = size × 0.5`; `PlaySession` places the rig under a `CameraMount` at anchor space `(−W/2, 0, −D/2)` so it matches the anchor-centred cell convention. No edit needed if the coder keeps the ticket as written.
12. `implementation-plan.md` §4 libraries: GUIDE and Phantom Camera were **deferred**, but `project.godot` (uncommitted) now enables both plugins and registers `GUIDE` and `PhantomCameraManager` autoloads (plus `MCPRuntimeServer`). Either revert those autoloads or record the change; the plan's "no gameplay autoloads" rule is broken as it stands. Beehave and GodotSteam (just added to `addons/`) are **not needed now** (no AI, no Steam target before mobile) and each needs a `credits.json` entry if kept.
13. `view.yaw_offset_deg` default 15.0 in `knobs/view.json` vs `CameraMath.DEFAULT_BASE_DEG` 45: one of them is wrong; Camera GDD owner to confirm (the rig reads the knob at GP-4).
