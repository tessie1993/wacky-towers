# Core Loop Orchestration Plan: first playable meadow_01, then a steady chunk stream

> **Status**: Active (godot-specialist, 2026-10-10)
> **Layout**: `docs/architecture/architecture-modular-layout.md` (folders, level scenes, mechanics database, game parts, block sets)
> **Sources**: `docs/architecture/implementation-plan.md`, ADR-0001..0009, `production/chunks/` CH-001..036, `production/levels/meadow/coder-handoff.md`, `production/orchestration/core-loop-rules-audit.md` (all 28 proposed defaults adopted by the orchestrator as tunable working defaults), `design/levels/meadow.md`, core-loop GDDs.
> **End state of the fast path**: `meadow_01` runs in Godot from `Main`, and a QA agent plays it with godot-ai `input_simulate` to a win and to a loss, with screenshots retained.

---

## A. True current state (disk + coordinator updates, 2026-10-10)

| Chunk | Story | State | Evidence / drift |
|---|---|---|---|
| CH-001..005 | SHP-001, BRD-001 | done | `orientations.gd`, `board_limits.gd`, `content_types.gd`, `board_state.gd` (Down helpers only), `ascii_grid.gd` + tests |
| CH-006 | BRD-001 | done | `AsciiGrid.parse_layers` (coordinator: green) |
| CH-007 | BRD-001 | done | `board_spec.gd` + result; still holds a private `_whole_int` (gap 2 not applied) |
| CH-008 | BRD-001 | in flight | starting contents + anchor |
| CH-009 | BRD-001 | todo | fuzz; after first playable |
| CH-010, 011 | DAT-001 | done | `json_reader.gd`; `JsonReader.whole_int` still public (gap 2 not applied) |
| CH-012, 013 | DAT-001 | done | `knob_defs.gd`; `KnobDefs._whole_int` still exists |
| CH-014 | DAT-001 | in flight | KnobRegistry |
| CH-015..017 | DAT-001 | done | all 9 knob files on disk (README said 017 todo: stale) |
| CH-018 | DAT-001 | in flight | knob files test |
| CH-019 | RUL-001 | done | HookContext, VetoResult, ClearGroup, ArrivalPlan, `RuleApi` empty stub |
| CH-020 | SHP-002 | done **with drift** | uses `Array[Vector3i]`, not `PackedVector3iArray` (that type does not exist in 4.7; editor-check). CH-026/027 and plan/ADR-0003 still name it |
| CH-021 | RUL-001 | in flight | 4 bases |
| CH-022 | RUL-001 | todo | PluginRegistry |
| CH-023, 024 | VEW-004 | done | `camera_math.gd` incl. `ortho_size` |
| CH-025 | VEW-004 | in flight | CameraRig |
| CH-026 | SHP-002 | in flight | must use `Array[Vector3i]` |
| CH-027 | SHP-002 | todo | same type fix |
| CH-028 | SHP-002 | in flight | ShapeBank |
| CH-029 | BRD-002 | in flight | BoardState storage |
| CH-030, 031 | BRD-002 | todo | layers, queries |
| CH-032 | SIM-001 | done | verify location: gap 5 wants `sim_command.gd`/`sim_event.gd` in `src/core/model/` (ticket said `core/sim`) |
| CH-033 | RUL-002 | done | RuleDef container |
| CH-034, 035, 036 | DAT-002, SIM-001 | todo | containers, sim skeleton, replay |
| GP-0 | integration | in flight | `src/dev/board_preview.tscn` (candy_toy via godot-ai) |

Totals: 36 existing tickets: 20 done, 8 in flight, 8 todo.

**Drift between README, plan and disk**
1. README status table is stale (017, 020 shown todo; done on disk).
2. `PackedVector3iArray` in plan §1.2, ADR-0003, CH-020/026/027 (must be `Array[Vector3i]`).
3. Plan gap 2 (`JsonNum`) decided, not done: three copies of the whole-number rule. Fixed by CH-037.
4. `project.godot` (uncommitted) enables GUIDE, Phantom Camera, TileMapLayer3D, Script-IDE, xesa plugins and adds `GUIDE`, `PhantomCameraManager`, `MCPRuntimeServer` autoloads; the plan deferred GUIDE/Phantom Camera and allows no gameplay autoloads. `addons/beehave/`, `addons/godotsteam/` are new and unused (decision G1).
5. `view.yaw_offset_deg` = 15 in `knobs/view.json`, `CameraMath.DEFAULT_BASE_DEG` = 45.
6. QA: `block_set_import_test` red: neon_voxel has no `blk_neon_voxel_cube.glb`.
7. Stray `res://control.tscn` (empty Control, untracked): delete.
8. Level path conflict G1 (plan vs modular brief): decided `src/levels/<biome>/<id>/` (layout doc §4.1).

---

## B. Gaps that block coding (each routed; defaults adopted so nobody waits)

| # | Gap | Owner | Working default used by the tickets |
|---|---|---|---|
| B1 | `PackedVector3iArray` in ADR-0003 / plan / CH-026 / CH-027 | godot-specialist (me) | `Array[Vector3i]`; orchestrator patches CH-026 (in flight) and CH-027 before start |
| B2 | Pivot cube and GLB placement | godot-specialist | audit default: pivot = cube nearest bbox centre (ties: smallest x, then y, then z); extractor stores `ShapeDef.source_pivot` (CH-047) |
| B3 | Spawn position ("long axis left-right" is camera-relative) | game-designer | `top` arrival: `spawn_orient`, bbox centred on `spawn_anchor` (lower cell on ties), lowest cube at layer `h_play` (CH-059) |
| B4 | Resolving duration (Layer Clearing F2) | systems-designer | `t_resolve = clear.anim_ms + clear.settle_ms` when ≥ 1 layer cleared, else 0, capped at `clear.resolve_max_ms` (`ponytail:` in CH-068) |
| B5 | Rescue meaning of `warnings_max` 2 | systems-designer | each top-out with `warnings_left > 0` wipes `k` bottom layers (Goals F3) and uses one warning; with 0 left → lost (CH-061) |
| B6 | Stars in the first playable | systems-designer | `t3` if `level_ms ≤ t3` and no warning used, `t2` if `level_ms ≤ t2`, else 1 star; private in BoardSim until StarRater (CH-068) |
| B7 | Minimal HUD content | ux-designer | goal `"Layers n/N"`, next piece name, warnings left, mm:ss clock, countdown 3-2-1, pause button; result panel: won/lost, stars, Retry (CH-062) |
| B8 | Scheme A layout positions | ux-designer | d-pad bottom-left, spin ±/tilt ±/roll ± bottom-right, drop centre-bottom, rotate-view top-right; disabled axes hidden (CH-046) |
| B9 | `view.yaw_offset_deg` 15 vs 45 | game-designer (Camera GDD) | rig keeps CameraMath default 45 until confirmed |
| B10 | neon_voxel cube GLB missing | technical-artist | first playable uses candy_toy only |
| B11 | Disabled rotation axes check | godot-specialist | input hides disabled buttons; sim also rejects a rotate whose `screen_axis` is not in `control.rotation_axes_enabled` (CH-066) |
| B12 | Rules-audit items (28) | orchestrator | all adopted: lock timer starts on rest; fixed in-tick order; ≤ 1 fall step per tick; cell centre `(x−W/2+0.5, y+0.5, z−D/2+0.5)`; yaw grows +x→+z, `rotate_view(+1)` clockwise from above; spin right = `rotate(y, −1)`; same-orientation rotation leaves cells unchanged |
| B13 | x/z height limit (plan gap 12) | level-designer + game-designer | not needed for Meadow (all −y) |

---

## C. First-playable fast path

**Cut for the first playtest** (all "after first playable"): rule runtime hooks/vetoes/lifetimes (RUL-002), ControlVerb plugin (BoardController maps gestures to commands directly), LayoutKind, level validator beyond the loader's own checks, rotation undo/restore (M&R rules 14–16), input buffer in Waiting, hold-to-repeat, replay (CH-036), fuzz (CH-009), Pip's catch, rubber duck, skits, block shader/ghost shader, clear VFX, 3D next-piece preview, audio, level select, profile, Android export, neon_voxel.

**Kept**: meadow_01 as designed (4×4, h_play 8, i o t l s, opening pair {o, i}, spin only, clear 4, rescue with 2 warnings, time stars), candy_toy GLBs, desktop keys + Scheme A touch, 12-snap camera, minimal HUD.

Groups are parallel inside; no two chunks in a group touch the same file. A chunk starts when its own deps are done. **GP** = game-part integration ticket (layout doc §6).

| Group | Chunks (model) | Integration |
|---|---|---|
| **FP-1** (now, beside in-flight 008, 014, 018, 021, 025, 026, 028, 029, GP-0) | CH-038 palette + hue hand fields (S), CH-039 meadow_01 JSON + biome JSON (H), CH-040 desktop key table (H), CH-041 ArtSet + BoardGeom (S), CH-042 Gestures (H) | — |
| **FP-2** | CH-022 PluginRegistry (S), CH-027 ShapeDef.build (S), CH-030 BoardState layers (S), CH-037 JsonNum (H), CH-043 goal bases + GoalState (S), CH-044 Spawner (S), CH-045 KeyboardInput (S), CH-046 TouchInput (S) | — |
| **FP-3** | CH-031 BoardState queries (S), CH-034 LevelData + GameCatalog (H), CH-047 shape bank extractor + `shape_bank.tres` (S), CH-048 ActivePiece (H) | — |
| **FP-4** | CH-035 BoardSim skeleton (S), CH-049 LevelLoader minimal (S), CH-050 BoardState writes + delta (S), CH-051 Movement translate/drop/resting (S), CH-052 RuleApi read subset (H) | — |
| **FP-5** | CH-053 Movement rotate + kicks (S), CH-054 BoardState.shift_layers (S), CH-055 CatalogLoader (S), CH-056 BoardView MultiMesh (S), CH-057 PieceView + ghost (S), CH-058 BoardController (S) | — |
| **FP-6** | CH-059 `top` arrival (S), CH-060 `layer` clear + `slice` collapse (S), CH-061 `clear_n` + `rescue` + `lose` (S), CH-062 HUD + result panel (S) | **CH-063 GP-1 Board part** |
| **FP-7** | CH-064 BoardSim spawn/countdown/gravity/soft drop/move (S), CH-065 PlaySession + LevelStage + level template (S) | — |
| **FP-8** | CH-066 BoardSim rotate/hard drop/grace/lock delay/lock write (S) | **CH-067 GP-2 Piece part** |
| **FP-9** | CH-068 BoardSim per-lock sequence + end + stars (S), CH-069 meadow_01 level scene (S), CH-070 Main boot (S) | — |
| **FP-10** | — | **CH-071 GP-3 Drop/lock/clear part** (+ headless win test), **CH-072 GP-4 Camera + input part** |
| **FP-11** | — | **CH-073 GP-5 First playable**: QA plays meadow_01 with `input_simulate` |

Critical path: CH-029 → 030 → 031 → 051 → 053 → 066 → 068 → 071 → 073 (board_sim.gd chunks 035 → 064 → 066 → 068 are sequential by design: one file).

File-collision check (shared files): `board_state.gd` 029 → 030 → 031 → 050 → 054 (one per group); `shape_def.gd` 026 → 027 → 047; `board_sim.gd` 035 → 064 → 066 → 068; `movement.gd` 051 → 053; `sim_events.gd` only 064, 066, 068 (sequential); `board_spec.gd` 008 → 037; `json_reader.gd`, `knob_defs.gd` only 037 in FP; `project.godot` only 070.

Fast-path counts: 37 new tickets (CH-037..073, of which 5 GP) + 13 existing on the path (008, 014, 021, 022, 025, 026, 027, 028, 029, 030, 031, 034, 035) = 50 chunks left to first playable.

---

## D. After-first-playable backlog (keeps chunks flowing)

| Wave | Content | Notes |
|---|---|---|
| **AF-0 FP+1** | meadow_02 data-only (starter pockets, 3 axes; catch omitted), playtest with 3-axis rotation | biggest design risk (tilt/roll on touch); CH-008 already gives starter layers |
| **AF-1 Hardening** | CH-009 fuzz, CH-036 replay, FND-000 layering + banned-API tests (new folder names), DAT-003 LevelValidator, rotation undo/restore, 100 ms input buffer, hold-to-repeat, ControlVerb base + `piece` verb (moves gesture mapping out of BoardController), LayoutKind + `single`, `validate()` on bases, StarRater class, physics interpolation check | mostly Sonnet, one file each |
| **AF-2 Mechanics database** | CH-074 RuleDef catalogue fields, CH-075 MechanicCatalog loader, CH-076 level rules validation, CH-077 seed slot entries (Haiku), then one Haiku data chunk per Meadow mechanic entry (gust, mushroom_popup, fog, topsy_tumble, mill_belt, wobble, sprouts, hatching_eggs, dandelion_puff, fog_ghost, mascot_catch, spin_only, sticky_landing, build_race, fill_shape), RUL-002 rule runtime + FakeRuleApi, KnobRegistry.recompute, RuleApi buffered writes | tickets 074–077 written; rest ticketed when AF-1 lands |
| **AF-3 Meadow 02–05** | per level: level folder (scene + JSON), plugin(s), mechanic entries, smoke test, screenshot; mascot_catch (WO11) | MDW-002..005 from plan §6 Wave 8 |
| **AF-4 Meadow 06–10** | MDW-006..010, fog shader (shader specialist), gravity flip settle | |
| **AF-5 UI/menus** | AppFlow, level select (biome json order), ProfileStore, pause menu, result next/retry, Kenney placeholders + credits | |
| **AF-6 Presentation** | block shader (outline), ghost shader, lock cue ring, clear ripple/settle, PreviewBaker next-piece, audio stubs, neon_voxel set (after cube GLB) | technical-artist + shader specialist |
| **AF-7 Device** | Android export preset, APK on device, ADR open items (class list in export, JSON in pck, RNG goldens) | devops-engineer |

---

## E. Fleet roster

| Group | Opus reviewer (one per group, reviews every chunk diff before "done") | Writers |
|---|---|---|
| FP-1 | technical-artist (038, 041), godot-gdscript-specialist (039, 040, 042) | 038 S, 039 H, 040 H, 041 S, 042 H |
| FP-2 | engine-programmer (022, 027, 030, 037), gameplay-programmer (043, 044), godot-gdscript-specialist (045, 046) | 022 S, 027 S, 030 S, 037 H, 043 S, 044 S, 045 S, 046 S |
| FP-3 | engine-programmer | 031 S, 034 H, 047 S, 048 H |
| FP-4 | engine-programmer (035, 050, 052), gameplay-programmer (049, 051) | 035 S, 049 S, 050 S, 051 S, 052 H |
| FP-5 | gameplay-programmer (053, 054), engine-programmer (055), technical-artist (056, 057), godot-gdscript-specialist (058) | all S |
| FP-6 | gameplay-programmer (059–061), ui-programmer (062), godot-specialist (GP-1) | all S; GP-1 S integrator with godot-ai |
| FP-7..9 | gameplay-programmer (064, 066, 068), godot-specialist (065, 069, 070, GP-2) | all S |
| FP-10..11 | godot-specialist (GP-3, GP-4), qa-lead (GP-5) | S integrators; GP-5 QA agent (Sonnet) |
| AF-2 | godot-gdscript-specialist | 074–076 S, 077 + seed entries H |
| AF-6 | godot-shader-specialist, technical-artist | S |

Model rule: **Haiku** = data files, constants, containers with no logic, mechanical extraction refactors. **Sonnet** = any logic, node scenes, input, MCP scene building.

---

## F. QA hooks

1. **After every group**: full headless suite (command in `tests/README.md`; run `--import` first when a group adds `class_name` files):
   `"$G" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode`. Exit 0 required; 101 (orphans) is a fail for node chunks. `No test cases found` is not a pass.
2. **Scene / player-visible chunks** (041 cube mesh check, 046, 056, 057, 062, 065, 069, all GP): godot-ai MCP live checks in order: `editor_state` (no script errors), `logs_read` (no new `ERROR`/`SCRIPT ERROR`), `test_run` (the chunk's folder), `project_run` / play the scene, `editor_screenshot` → `production/qa/evidence/<ticket-id>[-n].png`. A parse check is not a run.
3. **GP tickets** also run a scripted playtest with `input_simulate` (keys listed in `desktop_keys.json`), then `logs_read`, then the screenshots named in the ticket.
4. **GP-5** writes `production/qa/evidence/CH-073-playtest.md`: steps, what was seen, win and loss reached, time to win, any errors.
5. Headless integration: `tests/integration/level_flow/meadow_01_headless_test.gd` (CH-071) must stay green from FP-10 on.

---

## G. User decisions (with recommendation)

1. **Editor add-ons and autoloads.** `project.godot` now autoloads GUIDE and PhantomCameraManager and enables 7 plugins; beehave and godotsteam were added. *Recommend*: remove the `GUIDE` and `PhantomCameraManager` autoloads (keep the plugins installed, disabled) until a story needs them; keep `MCPRuntimeServer` and `_mcp_game_helper` as dev-only with the FND-000 export guard; delete or park beehave and godotsteam (no AI or Steam target before mobile), else give each a `credits.json` entry.
2. **First playtest scope.** meadow_01 is spin-only, so it does not test 3-axis rotation, the concept's top risk. *Recommend*: ship meadow_01 first (fastest), then AF-0 meadow_02 data-only right after (one data chunk + one scene chunk).
3. **Level folders.** *Recommend* (decided, please confirm): `src/levels/<biome>/<id>/<id>.tscn + <id>.json`, replacing the plan's `scenes/levels/` + `assets/data/levels/` split.
4. **Framework scene by composition.** *Recommend* (decided, please confirm): the shared `PlaySession` scene instances each level scene (root `LevelStage`), instead of each level inheriting the full framework scene. Your rule stays: one scene per level, rules in JSON.
5. **Where the first playtest runs.** *Recommend*: desktop editor run with keys + mouse-clicked touch buttons first; Android APK as AF-7 (no export preset exists yet).
