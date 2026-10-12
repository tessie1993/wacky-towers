## Architecture Review Report
Date: 2026-10-10
Engine: Godot 4.7.2
GDDs Reviewed: 33 (+ systems-index)
ADRs Reviewed: 9
Mode: full (workflow standard, automation guided)

Reviewed-Content-Hash: docs/architecture/adr-0001-logic-visual-split-tick.md 64f9439c96316bc118557718eebe24ffdb7bc31b
Reviewed-Content-Hash: docs/architecture/adr-0002-board-data-model.md db952af3feeb11d004c5abb327cd10d8c22438d6
Reviewed-Content-Hash: docs/architecture/adr-0003-shape-bank-orientation.md 6ee562fbca70b3b1d50f839faacfaa09ed53e6f0
Reviewed-Content-Hash: docs/architecture/adr-0004-rule-twist-runtime.md 5b75e3dbeb730059fc4331071ae8f7f494a97764
Reviewed-Content-Hash: docs/architecture/adr-0005-data-format-validator.md 8ee6546f35d5f7bc8338823394d80d52dbdd9fa7
Reviewed-Content-Hash: docs/architecture/adr-0006-rng-seeds.md 0d8d04a40b9e08b8f49b9bcc939ceab21106dd93
Reviewed-Content-Hash: docs/architecture/adr-0007-block-rendering.md 38ea4f0fb73a2645b1ea599972cfb52d2f3b97be
Reviewed-Content-Hash: docs/architecture/adr-0008-gdscript-cpp-gdextension-android.md b030c74727f5acbf51f73d168015688678d52ff9
Reviewed-Content-Hash: docs/architecture/adr-0009-local-multiplayer.md 7394b125754fe8dc58daabd65b4af0f5ab28a143
Reviewed-Content-Hash: design/gdd/arcade-mode.md 960597acde179a23ffd45299859999b72e0f4a7e
Reviewed-Content-Hash: design/gdd/block-status-effects.md 52e63d9c09a161eb7e945c42711a45fd411ec781
Reviewed-Content-Hash: design/gdd/board-grid.md 63015249705592a7d5709db07b119e91233e44f6
Reviewed-Content-Hash: design/gdd/buffs-debuffs.md 653c87d3fdf0ccf6d070e69a3aa779e5928d314a
Reviewed-Content-Hash: design/gdd/camera-rotate-view.md 6177dcea0aa232cd7a230c5bab17b939d207527f
Reviewed-Content-Hash: design/gdd/campaign-structure.md 51d86bc82c46c5234afaad93b5a2e89a970d5e02
Reviewed-Content-Hash: design/gdd/fall-drop-lock.md fdda1907d4656d13efae2007325924d368345b2c
Reviewed-Content-Hash: design/gdd/game-concept.md 81078e3ba1318b61a3e7ef8d09ff68d6d7d23311
Reviewed-Content-Hash: design/gdd/game-feel-vfx.md a3988e548273e07fcd1844fdca6ac2922181afc5
Reviewed-Content-Hash: design/gdd/hud.md 06694615eb02077e44e18caa9664be32ac7d0c88
Reviewed-Content-Hash: design/gdd/items.md 31ebedb59a31b91b241e0eaee5cd13599cb26348
Reviewed-Content-Hash: design/gdd/layer-clearing.md 8eaf0d8373a0e20e7f2a170d0391cbc5b1bbbf38
Reviewed-Content-Hash: design/gdd/level-data-definition.md 70eeb85ae491bd822c4b4d9c51c4408e1dd78b7f
Reviewed-Content-Hash: design/gdd/level-goals-fail-states.md 635b92d8e0f68695601f15c0124808d6e05b506f
Reviewed-Content-Hash: design/gdd/level-specific-mechanics.md 1fcff238e07911d23fe9fd1814ab691332e2092d
Reviewed-Content-Hash: design/gdd/local-multiplayer-setup.md e9d00a2dd3996c75ee572f16ca918b2c2f98d0b6
Reviewed-Content-Hash: design/gdd/mechanics-catalog.md 3ef3172266709f2aa17cef02bdbc7eac61a9a9e4
Reviewed-Content-Hash: design/gdd/mechanics-module.md be282a8193f815fabd9123b4d5b6a115532d83ac
Reviewed-Content-Hash: design/gdd/menus-level-select.md 5247c0feddb41330fdd26cac51f7ca336311a312
Reviewed-Content-Hash: design/gdd/mode-minigame-randomizer.md 2c51f654014144dd92e52750d02aef951492e39c
Reviewed-Content-Hash: design/gdd/movement-rotation.md 675d0fc02704ef8afad5aa641ae3b015e37d2801
Reviewed-Content-Hash: design/gdd/obstacle-clearing.md a05a380087e00e7c3d54015df06f7eaccb6aec30
Reviewed-Content-Hash: design/gdd/obstacles.md dc3dc49e6373fb6a17335702c9ac636f0f33988f
Reviewed-Content-Hash: design/gdd/physics-mode.md 5dd3f3e483a1670ae32b781ba2b72e52dcf9218d
Reviewed-Content-Hash: design/gdd/piece-set.md df6d7672de2b036554cbe23be8a5f0357a3bef56
Reviewed-Content-Hash: design/gdd/piece-spawner-queue.md efd0a4648622dac6bcab2e6134aeeab2c741aaa2
Reviewed-Content-Hash: design/gdd/rule-twist-framework.md 31a9d3bf9ab23e6eb1974261211d709511930962
Reviewed-Content-Hash: design/gdd/save-profile.md 52429711125dbed9b035281eea3cde4ca0d96fea
Reviewed-Content-Hash: design/gdd/scoring-stars.md 54f7a09fda6b3c5a8f7dc9dea545d7ca9b2b12bc
Reviewed-Content-Hash: design/gdd/systems-index.md c27fefd7176cc9c748b4187146ce37f86051987e
Reviewed-Content-Hash: design/gdd/touch-controls.md 478c10cf586614229aab6fc4cd4f7889973e47e1
Reviewed-Content-Hash: design/gdd/tournament-flow.md 276e712da057db0c6e1b8a06e9d86517d34f886e
Reviewed-Content-Hash: design/gdd/tournament-minigames.md 9bcb4487e84921e491f74edd5e38c90821c0bf48
Reviewed-Content-Hash: design/gdd/twist-library.md a5b820b35395ec0dcad6af149164c1528ff05b8e

---

### Traceability Summary
Total requirements: 242 (33 GDDs; systems-index read as the index)
✅ Covered: 128 (53%) — every covering ADR is Accepted
⚠️ Partial: 74
❌ Gaps: 40

| Batch | GDDs | TRs | ✅ | ⚠️ | ❌ |
|---|---|---|---|---|---|
| Core loop (board, pieces, spawner, movement, fall/lock, clearing, goals, camera, touch, HUD, scoring) | 11 | 68 | 41 | 20 | 7 |
| Rules & content (rule framework, twists, mechanics catalog/module, level data, level mechanics, obstacles, obstacle clearing, status, buffs, items) | 11 | 83 | 51 | 28 | 4 |
| Modes & meta (concept, feel/VFX, menus, campaign, arcade, physics, randomizer, tournament ×2, local MP, save) | 11 | 91 | 36 | 26 | 29 |

Full matrix: `docs/architecture/requirements-traceability.md`. TR-IDs: `docs/architecture/tr-registry.yaml` (v2).
Not in scope: `design/gdd/meadow-candidate-atoms.md` and `design/gdd/meadow-asset-list.md` (written while this review ran), and the new `design/gdd/ux|audio|narrative/` subfolders.

### Coverage Gaps (no ADR exists)
Grouped into the ADRs that would close them (★ = needed for the Meadow MVP).

| # | Suggested ADR | Layer | Domain | Engine risk | Closes |
|---|---|---|---|---|---|
| 1 ★ | `/architecture-decision level-flow-app-lifecycle` — level state machine (Intro/Countdown/Playing/Warning/Result/Paused), Android backgrounding, Back button, scene loading; rule on Orchestrator vs the untracked `godot_state_charts` addon | Core | Core/Scripting | MEDIUM | TR-level-goals-fail-states-003, TR-touch-controls-005, TR-menus-level-select-002 |
| 2 ★ | `/architecture-decision mechanic-level-event-runtime` (the planned ADR-0011) — beehave trees ticked from `BoardSim.step()`, leaves act only through `RuleApi`, or view-only | Core | Core/Scripting | MEDIUM-HIGH | mascot/level-event TRs (partials in batch B) |
| 3 ★ | `/architecture-decision touch-input-pipeline` — InputEvent → GUIDE → SimCommand, gesture classes, multi-touch zones, buffer clock (sim ticks, for replay), haptics; assess 4.7 `VirtualJoystick` | Foundation | Input/Platform | MEDIUM | TR-touch-controls-003 |
| 4 ★ | `/architecture-decision save-profile-settings` — `user://`, atomic temp+rename with backup, `.get()` defaults, settings; stars keyed by level id + version (not `level_hash`) | Core | Persistence | MEDIUM | TR-touch-controls-007, TR-scoring-stars-003, TR-save-profile-001/002/004/006/007, TR-menus-level-select-004/006, TR-campaign-structure-002/005, TR-arcade-mode-006, TR-tournament-flow-008, TR-mechanics-module-010 |
| 5 ★ | `/architecture-decision camera-orientation-safe-area` — PhantomCamera rig, 12 snaps, portrait/landscape reframe, safe area, 3D picking | Presentation | Camera/UI | MEDIUM | TR-camera-rotate-view-006, TR-hud-003, TR-mechanics-module-012 |
| 6 ★ | `/architecture-decision audio-feedback-pipeline` — buses, event→cue map, layered music, VFX budget + eviction, haptics rate limit, fps-based quality governor | Presentation | Audio/VFX | MEDIUM | TR-game-concept-008, TR-game-feel-vfx-002/006/007/008 |
| 7 | `/architecture-decision physics-mode-jolt` | Feature | Physics | HIGH | TR-game-concept-004, TR-physics-mode-002/003/004/005/008/009, TR-tournament-minigames-009 |
| 8 | `/architecture-decision shared-device-split-screen` (or ADR-0009 addendum) | Presentation | Rendering/Input | MEDIUM | TR-local-multiplayer-setup-007/008/009 |
| 9 | `/architecture-decision cloud-save` | Platform | Platform | HIGH (native plugins vs ADR-0008) | TR-save-profile-005 |
| 10 | `/architecture-decision board-history-undo` | Core | Core | LOW | TR-mechanics-module-007 |
| 11 | `/architecture-decision music-beat-clock` | Feature | Audio/Core | MEDIUM | TR-mechanics-module-008 |

### Cross-ADR Conflicts

**Conflict: ADR-0004 vs ADR-0005**
Type: Dependency (cycle)
ADR-0004 claims: depends on ADR-0005 (JSON data, validator).
ADR-0005 claims: depends on ADR-0004 (knob and rule schemas the validator checks).
Impact: no valid build order between the two; each "must be Accepted first".
Resolution options:
  1. ADR-0004 owns the knob/rule schemas; ADR-0005 depends on ADR-0004; ADR-0004 drops its ADR-0005 edge (RuleRuntime consumes already-validated data — an interface, not a dependency). Recommended.
  2. Move the schemas into ADR-0005 and have ADR-0004 depend on it.

**Pattern risk: planned ADR-0011 vs ADR-0001** (not yet a written ADR)
beehave and Orchestrator are node-based and tick in `_process`; ADR-0001 requires a pure RefCounted sim on a fixed 60 Hz integer-ms tick, and ADR-0004 requires every effect to go through `RuleApi`. Resolve in gap ADR #2.

**ADR-0002 amendments needed** (from GDD flags, not ADR-vs-ADR): `color` as colour-key id (0 = none) separate from hue; per-cell item tag; `insert_layers(n)` op for junk pushed from the floor.

### ADR Dependency Order
Source: `.claude/scripts/adr-dep-graph.sh` (9 ADRs, 16 edges, every ADR has a dependency section). The only real cycle is ADR-0004 ↔ ADR-0005 (the script's other CYCLE lines are the nodes left over once that cycle blocks the sort).

Recommended order once the cycle is broken (option 1):
Foundation (no dependencies): ADR-0001 tick/sim split, ADR-0003 shape bank, ADR-0006 RNG seeds
Depends on Foundation: ADR-0002 board data model (0001)
Core: ADR-0004 rule runtime (0001, 0002, 0006) → ADR-0005 data format/validator (0003, 0004)
Feature/Presentation: ADR-0007 block rendering (0001, 0002, 0003), ADR-0008 GDScript/C++/Android (0001, 0002), ADR-0009 local multiplayer (0001, 0004, 0005, 0006)

### GDD Revision Flags (Architecture → Design Feedback)

| GDD | Assumption | Reality (ADR / engine reference) | Action |
|---|---|---|---|
| hud.md | Next-piece preview drawn from the live camera yaw, re-rendered within a frame of a turn | ADR-0007 §6 bakes one static angle per shape at load | Bake 12 yaws (check atlas ≤ 4 MB) or change HUD |
| level-goals-fail-states.md | Survive/time limits checked "every frame"; versus ties "same frame" | ADR-0001 fixed 60 Hz tick; ADR-0009 ties by round clock | Reword to sim tick / sim ms |
| scoring-stars.md | F2 fractional factors (A/64, chain_bonus 0.5) | ADR-0001 integer-only gameplay math | Restate in fixed-point with a rounding rule |
| board-grid.md | Footprint "no maximum" | ADR-0002 caps 24/side, 8192 cells | Add caps to safe ranges |
| board-grid.md + ACs | Defaults stated as 6×6 / 8×8×12 / 8×8×16 in different docs | ADR-0007 context uses 8×8×12 | Align the wording |
| movement-rotation.md, piece-set.md | 1–8 cubes per piece, ≤112 queries per rotation | Giant family up to 27 cubes | Scale bounds or exclude Giant from kicks |
| fall-drop-lock.md, hud.md, level-goals AC21 | Ghost/HUD update "same frame" as the command | ADR-0001 applies commands next tick (≤17 ms) | Reword to "the tick the command applies" |
| mechanics-catalog.md, level-specific-mechanics.md, tournament-minigames.md | Slot names `clear_detector`, `spawn_entry`, `board_kind`… | ADR-0004 ids `clear.detector`, `spawn.arrival`, `board.kind`… | Rename to ADR ids |
| rule-twist-framework.md | Knob names, float F1, `on_tick(dt)` every frame | ADR-0004 dotted knob ids, fixed point; ADR-0001 per tick, no dt | Update rule 4 table, F1, tick wording |
| level-data-definition.md | Per-system sections, `mechanic` + `twists`, format open | ADR-0005 flat `knobs`, one `rules` list, `schema`, JSON decided | Align to ADR-0005 |
| mechanics-module.md | Recipe JSON shape; slot atoms excluded from F3 | ADR-0005 `rules` list, ASCII layers; ADR-0004 counts by layer | Align; settle F3 counting with LSM |
| level-specific-mechanics.md (M11) | One board, two down axes | ADR-0002: one down axis per BoardState | Re-spec as two linked boards |
| items.md | Item tag on one cube, kept after lock | ADR-0002 tags per piece | Needs ADR-0002 amendment |
| obstacles.md, buffs-debuffs.md | Junk pushed in from the floor lifts the stack | ADR-0002 has no insert/lift op | Needs ADR-0002 amendment |
| physics-mode.md | Engine choice open; generic joints; non-determinism OK | Jolt already set; Jolt ignores HingeJoint3D damp; ADR-0009 re-sims boards | Physics ADR; exclude physics rounds from re-sim |
| local-multiplayer-setup.md | Network tech TBD; shared-tablet split supported | ADR-0009 decided ENet, one phone per player | Cite ADR-0009; split-screen ADR or cut |
| save-profile.md, campaign-structure.md | Storage TBD; cloud sync; re-versioned level keeps stars | No save ADR; no built-in cloud API; plan keys stars by `level_hash` | Save ADR; key by id + version |
| mode-minigame-randomizer.md | Float template weights / share | ADR-0006 integer weights; ADR-0004 milli-units | Store as integer milli-units |
| game-feel-vfx.md | Detect low-power mode, halve particles | No sourced 4.7 API | Replace with fps-based governor |

21 systems-index rows (22 GDDs) set to `Needs Revision`.

### Engine Compatibility Issues
Engine: Godot 4.7.2 (Mobile renderer, Android first)
ADRs with Engine Compatibility section: 9 / 9. All name 4.7.2; no stale versions.
Deprecated API references: none (grep of `deprecated-apis.md` names across all ADRs).
Post-cutoff API conflicts: none between ADRs.

HIGH:
- ADR-0007: MultiMesh 20-float layout (transform + colour + custom), `use_colors`/`use_custom_data`, Shader Baker setting name — all unverified on 4.7.2. Add a shader warm-up at level load (mobile pipeline-compile hitches).
- ADR-0008: no godot-cpp 4.7 tag (only `master`); acceptable while there is no native code. Cloud save would need native plugins (gap #9).

MEDIUM (verify on an Android export):
- ADR-0004: `ProjectSettings.get_global_class_list()` returns `class_name` scripts in an exported build.
- ADR-0005: `DirAccess` listing of `res://assets/data/**.json` inside the `.pck` (JSON must be in the export include filter).
- ADR-0009: whether `CHANGE_WIFI_MULTICAST_STATE` is enough for broadcast beacons.

### Engine Specialist Findings
The `godot-specialist` consultation was interrupted by the user; the engine lens used instead was the Godot Game Dev Studio `godot-master` skill, cross-checked against `docs/engine-reference/godot/`.
- `project.godot` autoloads `_mcp_game_helper` (godot_ai) and `MCPRuntimeServer` (godot_mcp_toolkit) would ship in the game: exclude them from export presets or gate them behind a debug feature tag. HIGH for release, LOW now.
- `godotsteam` is enabled; its desktop-only native libraries may break or bloat the Android export. Disable it for Android presets. MEDIUM.
- GUIDE, PhantomCamera and beehave are registered autoloads with no ADR; gap ADRs #2, #3 and #5 should own them.
- Mobile renderer use in ADR-0007 matches the mobile guidance (not Forward+). Per-instance data through MultiMesh custom data is correct: instance uniforms are per GeometryInstance3D, not per MultiMesh instance.
- For gap ADR #2: keep logic in RefCounted objects ticked by the sim; nodes only for presentation.

### Architecture Document Coverage
`docs/architecture/architecture.md` exists (sections 1–10, "The nine ADRs").
Missing from the architecture layers: Save & Profile (0 mentions), haptics (0), app/level flow and menus (1 passing mention), audio (2 passing mentions), and the plugin roles (Orchestrator, beehave, GUIDE, PhantomCamera — 0 mentions each).
Orphaned architecture: none found.

---

### Verdict: FAIL

Foundation/Core requirements are uncovered (level flow, touch input pipeline, the mechanic/level-event runtime), and there is a dependency cycle between ADR-0004 and ADR-0005. Everything that is covered rests on Accepted ADRs.

### Blocking Issues (must resolve before PASS)
1. Break the ADR-0004 ↔ ADR-0005 cycle (edit both ADRs' dependency tables).
2. Write gap ADRs #1 level flow, #2 mechanic/level-event runtime, #3 touch input pipeline.
3. Write gap ADR #4 save/profile (MVP needs stars, unlocks, settings).

### Required ADRs
1. Level flow & app lifecycle (Core)
2. Mechanic & level-event runtime — ADR-0011 (Core)
3. Touch input pipeline (Foundation)
4. Save, profile & settings (Core)
5. Camera rig, orientation & safe area (Presentation)
6. Audio & feedback pipeline (Presentation)
7. Physics Mode on Jolt (Feature, post-MVP)
8. Shared-device split screen (Presentation, post-MVP)
9. Cloud save (Platform, post-MVP)
10. Board history / undo (Core, post-MVP)
11. Music beat clock (Feature, post-MVP)
