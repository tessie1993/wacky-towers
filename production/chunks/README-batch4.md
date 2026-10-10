# Coding chunks — batch 4: real first playable (meadow_01), then all of Meadow (CH-037..CH-147)

> **NO TESTS (user rule 2026-10-10).** Ignore every "tests first", "Tests to write FIRST", gdUnit and test-file instruction in this file and in the tickets. Writers write game code only; the integrator proves each chunk in the editor (script eval + `logs_read`, or run the scene + screenshot). New tickets: `README-batch5.md`.

Lead: godot-specialist (fresh lead, 2026-10-10). Source: `production/orchestration/core-loop-orchestration-plan.md` (CH-037..077 numbers kept),
`docs/architecture/architecture-modular-layout.md` (paths), `orchestration-playbook.md` (wave size, merges, gates),
`block-rendering-plan.md` RND-01..08 (folded below), `production/levels/meadow/coder-handoff.md` (levels 02–10).
Conventions, Run and "Done when" = `production/chunks/README.md`. Test roots add `game`, `ui`, `levels`, `mechanics`, `assets`.

**Rules for every ticket in this batch**
- **3 axes everywhere.** Movement, kicks (incl. up-kick), collision and controls support spin, tilt and roll on X/Y/Z from the first playable.
  meadow_01's spin-only is the per-level knob `control.rotation_axes_enabled`; it hides controls, never removes code.
- Intent contract (shared by CH-045, CH-046, CH-058, CH-098; GUIDE actions feed it through CH-045): signals `move_requested(screen_dir: Vector2i)` (screen-up = `(0,-1)`),
  `rotate_requested(screen_axis: StringName, dir: int)` (`&"spin"|&"tilt"|&"roll"`; +1 = spin right / tilt away / roll right),
  `soft_drop_changed(on: bool)`, `hard_drop_requested()`, `rotate_view_requested(step: int)`, `pause_requested()`.
- Same-file chains run as ONE agent: `board_state.gd` 050+054; `movement.gd` 051+053; `board_sim.gd` 035 → 064 → 066 → 068 (one agent each, strictly ordered, start on `done`).
- Staging (`_staging/` + `.gdignore` + integrator) only for GP tickets and level scenes; logic chunks write direct.
- **Plugins (user decision 2026-10-10):** controls = GUIDE, camera = phantom_camera, mascot/boss/level events = beehave, greybox platforms = TileMapLayer3D, tests = gdUnit4. Adoption tickets are PLG-nn in `README-plugins.md` (not duplicated here); rows naming a "PLG … ticket" wait for it. Sim/core never imports a plugin.
- Physics: Meadow uses **no Jolt physics**. Its one "physics" level (05) uses grid `wobble` (CH-118). Physics Mode GDD stays unbuilt.
- The lead edits status rows; writers report in the 5-line template.

Models: H = Haiku, S = Sonnet. RND = block-rendering-plan id folded in.

## Status

| ID | Story | Title | Depends | Wave | Model | Status |
|----|-------|-------|---------|------|-------|--------|
| CH-037 | DAT-001 | JsonNum: one whole-number helper (plan gap 2) | none | W1 | H | todo |
| CH-038 | VEW-003 | Palette (sampled candy_toy) + shape hue hand fields + PaletteTable (RND-02) | none | W1 | S | blocked (GLBs have no colour; palette to be authored) |
| CH-039 | DAT-004 | meadow_01 JSON into its level folder + biomes/meadow.json | none | W1 | H | done |
| CH-040 | INP-001 | Desktop key table — **superseded** by the PLG GUIDE mapping context (no ticket file) | — | — | — | superseded |
| CH-042 | INP-001 | Gestures: tap / hold / drag / flick classifier | none | W1 | S | done |
| CH-078 | SIM-001 | Move SimCommand + SimEvent to core/model (plan gap 5) | none | W1 | H | done |
| CH-079 | VEW-002 | Cube mesh `.res` + import contract test (RND-01) | none | W1 | S | done |
| CH-080 | VEW-002 | SlotMap (pure, RND-04) | none | W1 | S | done |
| CH-034 | DAT-002 | LevelData + GameCatalog (existing ticket) | CH-022, CH-028, CH-033 | W2 | H | in-progress |
| CH-041 | VEW-003 | ArtSet + BoardGeom (RND-03; cube scale fixes 1.03 overlap) | CH-038, CH-079 | W2 | S | todo |
| CH-043 | RUL-001 | GoalState + GoalEvaluator + TopOutPolicy bases | CH-078 | W2 | S | superseded by CH-151 |
| CH-044 | SIM-002 | Spawner: weighted bag + opening set + lookahead | CH-028 | W2 | S | done |
| CH-045 | INP-001 | GuideIntents: GUIDE actions → intent signals (desktop keys) | PLG GUIDE ticket | W3 | S | todo |
| CH-046 | INP-002 | TouchInput Scheme A (all axes, hidden when disabled) | CH-042 | W2 | S | staged |
| CH-081 | VEW-002 | BlockViewMath (pure, RND-05) | none | W1 | H | done |
| CH-084 | DAT-001 | Knob additions (warning, intro, ghost alpha, controls, layer order) | none | W2 | H | done |
| CH-035 | SIM-001 | BoardSim skeleton (existing ticket; board_sim agent #1) | CH-034, CH-078 | W3 | S | todo |
| CH-047 | SHP-003 | Shape bank extractor + `shape_bank.tres` + `ShapeDef.source_pivot` | CH-027, CH-028 | W3 | S | done |
| CH-048 | SIM-003 | ActivePiece (shape, orient, pivot, cells, up-kick count) | CH-027 | W3 | H | done |
| CH-049 | DAT-002 | LevelLoader minimal + LoadResult (float weights → copies, G3) | CH-034, CH-037, CH-084 | W3 | S | staged |
| CH-052 | RUL-001 | RuleApi read subset | CH-031, CH-034 | W3 | H | done |
| CH-083 | BRD-001 | Meadow content types in blocks.json (mushroom, sprout, egg, chick) | none | W3 | H | done |
| CH-087 | SCO-001 | StarRater (time stars, survive stars, F1/F4 fallback, trim = warning) | CH-043 | W3 | S | todo |
| CH-088 | SCO-001 | ScoreKeeper (clear F2, combo/drop/place F3) | none | W3 | S | todo |
| CH-050 | BRD-003 | BoardState writes + delta (+ CH-054 same agent) | CH-031 | W4 | S | done |
| CH-054 | BRD-003 | BoardState.shift_layers (with CH-050) | CH-050 | W4 | S | done |
| CH-051 | SIM-003 | Movement translate / drop / resting, 3D (+ CH-053 same agent) | CH-031, CH-048 | W4 | S | staged |
| CH-053 | SIM-003 | Movement rotate X/Y/Z + kick table F2 incl. up-kick budget (with CH-051) | CH-051 | W4 | S | staged |
| CH-055 | DAT-002 | CatalogLoader + CatalogResult | CH-049, CH-038, CH-047, CH-022, CH-083 | W4 | S | todo |
| CH-059 | RUL-003 | `top` arrival plugin | CH-052, CH-047 | W4 | S | staged |
| CH-061 | RUL-003 | `clear_n` goal + `rescue` + `lose` top-out plugins | CH-043, CH-052, CH-050 | W4 | S | todo |
| CH-062 | UI-001 | HUD + result panel (stars, time, score) | CH-078 | W4 | S | todo |
| CH-056 | VEW-002 | BoardView MultiMesh greybox (RND-06) | CH-041, CH-050, CH-080, CH-081 | W5 | S | staged |
| CH-057 | VEW-003 | PieceView + ghost (RND-08) | CH-041, CH-047, CH-048 | W5 | S | staged |
| CH-058 | APP-001 | BoardController (fixed tick, intents → world commands via the camera) | CH-035, CH-045, CH-046, PLG camera ticket | W5 | S | todo |
| CH-060 | RUL-003 | `layer` + `none` detectors + `slice` collapse | CH-052, CH-054 | W5 | S | todo |
| CH-064 | SIM-003 | BoardSim spawn / countdown / gravity / soft drop / move (board_sim #2) | CH-035, CH-044, CH-051, CH-059, CH-049 | W5 | S | todo |
| CH-085 | MDW-000 | Meadow kit: stand-in island platform (greybox via TileMapLayer3D, any footprint/mask) | CH-041, PLG TileMapLayer3D ticket | W5 | S | todo |
| CH-086 | MDW-000 | Meadow kit: sky, light presets, mill silhouette, Pip/Miller proxies, stage-on-clear node | none | W5 | S | todo |
| CH-063 | GP-1 | **Board part** (integrator, godot-ai) | CH-056, CH-055, CH-049 | W6 | S | todo |
| CH-065 | APP-001 | PlaySession + LevelStage + `_template/level_stage_base.tscn` | CH-058, CH-056, CH-057, CH-062 | W6 | S | todo |
| CH-066 | SIM-004 | BoardSim rotate / hard drop / grace / lock delay / lock write (board_sim #3) | CH-064, CH-053, CH-050 | W6 | S | todo |
| CH-082 | VEW-002 | Clear flash: dying MultiMesh + `spatial_block_clear.gdshader` (RND-07) | CH-056 | W6 | S | todo |
| CH-067 | GP-2 | **Piece part** (integrator) | CH-066, CH-065, CH-057 | W7 | S | todo |
| CH-068 | SIM-005/006 | BoardSim per-lock resolve + warning phase + end + stars + score (board_sim #4) | CH-066, CH-060, CH-061, CH-087, CH-088 | W7 | S | todo |
| CH-069 | MDW-001 | meadow_01 level scene (inherits template, kit island 4×4) | CH-065, CH-085, CH-086, CH-039 | W7 | S | todo |
| CH-070 | APP-001 | Main boot (`run/main_scene`) | CH-055, CH-065, CH-039 | W7 | S | todo |
| CH-071 | GP-3 | **Drop/lock/clear part** + headless meadow_01 win test | CH-068, CH-067 | W8 | S | todo |
| CH-072 | GP-4 | **Camera + input part** (12 snaps, view-relative tilt/roll, touch + keys) | CH-067, PLG GUIDE + camera tickets | W8 | S | todo |
| CH-073 | GP-5 | **FIRST PLAYABLE**: QA plays meadow_01 to win + loss (input_simulate) | CH-071, CH-072, CH-069, CH-070 | W9 | S | todo |
| CH-074 | RUL-002 | RuleDef catalogue fields | CH-033 | W10 | S | todo |
| CH-077 | RUL-002 | Seed slot mechanic entries (13 JSON) + catalog file test | CH-074 | W10 | H | todo |
| CH-091 | RUL-002 | RuleApi buffered writes + `FakeRuleApi` test double | CH-052 | W10 | S | todo |
| CH-093 | RUL-002 | KnobRegistry.recompute (rule knob modifiers) | CH-074 | W10 | S | todo |
| CH-094 | SIM-003 | Rotation undo / restore (M&R 14–16) | CH-053 | W10 | S | todo |
| CH-095 | INP-003 | Waiting input buffer + d-pad hold-to-repeat | CH-058 | W10 | S | todo |
| CH-096 | MDW-002 | meadow_02 JSON (catch omitted) + pocket test | CH-049 | W10 | H | todo |
| CH-075 | RUL-002 | MechanicCatalog loader (plugin must resolve only for status built/tested) | CH-074, CH-077 | W11 | S | todo |
| CH-090 | RUL-002 | RuleRuntime + RuleInstance (hooks in layer order, vetoes, lifetimes) | CH-074, CH-091 | W11 | S | todo |
| CH-097 | MDW-002 | meadow_02 level scene (burrow) + 3-axis playtest | CH-096, CH-069 | W11 | S | todo |
| CH-098 | INP-004 | TouchInput Scheme B (drag & flick) | CH-095 | W11 | S | todo |
| CH-099 | INP-005 | Touch layout: portrait / landscape, left-hand mirror, turn-phone pause | CH-095 | W11 | S | todo |
| CH-100 | VEW-005 | Rotation feedback: axis gizmo flash + blocked bonk | CH-057 | W11 | S | todo |
| CH-076 | DAT-003 | Level rules validation (ids, params, F3 budget, tags, biome warning) + level_files_test | CH-075 | W12 | S | todo |
| CH-092 | RUL-003 | BoardSim hook wiring (tick/spawn/lock/resolve hooks, lock veto, buffered writes) | CH-090, CH-091, CH-068 | W12 | S | todo |
| CH-101 | MDW-003 | Mechanic entries A: mascot_catch, gust, dandelion_puff | CH-077 | W12 | H | todo |
| CH-102 | MDW-004 | Mechanic entries B: mushroom_popup, build_race, wobble, fill_shape, sticky_landing | CH-077 | W12 | H | todo |
| CH-103 | MDW-006 | Mechanic entries C: sprouts, fog, fog_ghost, topsy_tumble, hatching_eggs, mill_belt | CH-077 | W12 | H | todo |
| CH-104 | MDW-002 | `mascot_catch` plugin (lock veto → return to spawn) | CH-092 | W13 | S | todo |
| CH-105 | MDW-003 | Spawner per-bag piece tags (G5) | CH-044 | W13 | S | staged |
| CH-106 | MDW-003 | `gust` twist plugin | CH-092 | W13 | S | todo |
| CH-107 | MDW-003 | Gust telegraph presenter scene (world-anchored arrow) | CH-065 | W13 | S | todo |
| CH-108 | MDW-003 | meadow_01..03 JSON: add mascot_catch; meadow_03 JSON | CH-101, CH-076 | W13 | H | todo |
| CH-109 | MDW-003 | `dandelion_puff` plugin (seeded split on landing) | CH-105, CH-092 | W14 | S | todo |
| CH-110 | MDW-003 | meadow_03 level scene (hillside lane 8×4) | CH-106, CH-107, CH-108, CH-109 | W14 | S | todo |
| CH-111 | MDW-002 | Pip / Miller proxy presenters (beehave trees on sim events) | CH-086, CH-104, PLG beehave ticket | W14 | S | todo |
| CH-112 | MDW-004 | BoardView content meshes (per-kind MultiMesh) | CH-056, CH-083 | W15 | S | todo |
| CH-113 | MDW-004 | `mushroom_popup` plugin + sparkle presenter | CH-092, CH-083 | W15 | S | todo |
| CH-114 | MDW-004 | meadow_04 JSON (mask ring, spawn_anchor; G7 tie toward +z) | CH-102, CH-076 | W15 | H | todo |
| CH-116 | MDW-004 | meadow_04 level scene (pond ring) | CH-112, CH-113, CH-114 | W16 | S | todo |
| CH-117 | MDW-005 | `height` goal + `trim` top-out plugins | CH-061 | W16 | S | todo |
| CH-118 | MDW-005 | `wobble` plugin (grid overhang sway, slip at wobble_max) | CH-092 | W16 | S | todo |
| CH-119 | MDW-005 | meadow_05 JSON (big_cube weight 0.5, build_race) | CH-102, CH-093 | W16 | H | todo |
| CH-120 | MDW-005 | Wobble sway + height sign presenters | CH-065 | W16 | S | todo |
| CH-121 | MDW-005 | meadow_05 level scene (hilltop) | CH-117, CH-118, CH-119, CH-120 | W17 | S | todo |
| CH-122 | MDW-006 | `shape` goal plugin + LevelLoader `target_shape` grid | CH-061, CH-049 | W17 | S | todo |
| CH-123 | MDW-006 | `sprouts` plugin (grow into targets, stop when covered) | CH-092, CH-083 | W17 | S | todo |
| CH-124 | MDW-006 | Target-shape overlay presenter | CH-065 | W17 | S | todo |
| CH-125 | MDW-006 | meadow_06 JSON | CH-103, CH-076 | W17 | H | todo |
| CH-126 | MDW-006 | meadow_06 level scene (garden bed) | CH-122, CH-123, CH-124, CH-125 | W18 | S | todo |
| CH-127 | MDW-007 | Block fade status shader (per-instance alpha, ADR-0007) | CH-082 | W18 | S | todo |
| CH-128 | MDW-007 | `fog` plugin (fade / reveal status events) | CH-092 | W18 | S | todo |
| CH-129 | MDW-007 | `fog_ghost`: phasing piece, CMD_TAP + pick_cell, deepest-hole sink | CH-105, CH-092, CH-094 | W18 | S | todo |
| CH-130 | MDW-007 | meadow_07 JSON | CH-103, CH-076 | W18 | H | todo |
| CH-131 | MDW-007 | meadow_07 level scene (foggy hollow) | CH-127, CH-128, CH-129, CH-130 | W19 | S | todo |
| CH-132 | MDW-008 | `survive` goal plugin | CH-061 | W19 | S | todo |
| CH-133 | MDW-008 | BoardSim `fall.ramp_per_min` | CH-092 | W19 | S | todo |
| CH-134 | MDW-008 | meadow_08 JSON (sticky_landing data rule) | CH-102, CH-093 | W19 | H | todo |
| CH-135 | MDW-008 | meadow_08 level scene (dewy lawn) | CH-132, CH-133, CH-134 | W20 | S | todo |
| CH-136 | MDW-009 | BoardState.set_down + settle to new floor | CH-054 | W20 | S | todo |
| CH-138 | MDW-009 | `hatching_eggs` plugin (egg → chick hops) | CH-092, CH-083 | W20 | S | todo |
| CH-139 | MDW-009 | meadow_09 JSON | CH-103, CH-076 | W20 | H | todo |
| CH-137 | MDW-009 | `topsy_tumble` twist (flip at next Resolving, spawn moves) | CH-136 | W21 | S | todo |
| CH-140 | MDW-009 | Topsy presenter (side arrows, countdown ring) | CH-065 | W21 | S | todo |
| CH-141 | MDW-010 | BoardState.shift_contents (wrap) | CH-136 | W21 | S | todo |
| CH-142 | MDW-010 | meadow_10 JSON (3-rule stack, chair) | CH-103, CH-076 | W21 | H | todo |
| CH-143 | MDW-009 | meadow_09 level scene (tree island) | CH-137, CH-138, CH-139, CH-140 | W22 | S | todo |
| CH-144 | MDW-010 | `mill_belt` mechanic plugin | CH-141, CH-092 | W22 | S | todo |
| CH-145 | MDW-010 | Belt surface + Miller boss presenter (beehave) | CH-111, PLG beehave ticket | W22 | S | todo |
| CH-146 | MDW-010 | meadow_10 level scene (mill yard, boss) | CH-144, CH-145, CH-142, CH-106, CH-137 | W23 | S | todo |
| CH-147 | MDW-QA | Meadow 01–10 QA pass (handoff §5 checklist, evidence per level) | CH-146 + all level scenes | W23 | S | todo |

IDs not used: CH-089, CH-115 (kept free for fixes). Existing tickets on this path: CH-022, CH-028, CH-030+031 (done), CH-034 (in progress), CH-035.
Off-path existing: CH-009 fuzz, CH-036 replay (any wave from W10 with spare writers).

## Waves

| Wave | Writers (parallel, no shared file) | Gate / integration |
|---|---|---|
| W1 | 037 H, 038 S, 039 H, 042 S, 078 H, 079 S, 080 S, 081 H | one `--import`, full suite |
| W2 | (034 in progress), 041 S, 043 S, 044 S, 046 S, 084 H | import, suite, Opus review; 046 screenshot |
| W3 | 035 S, 045 S, 047 S, 048 H, 049 S, 052 H, 083 H, 087 S (088 rides W4 if 8 is too many) | import, suite |
| W4 | 050+054 S, 051+053 S, 055 S, 059 S, 061 S, 062 S | suite; 062 screenshot |
| W5 | 056, 057, 058, 060, 064, 085, 086 (all S) | suite; scene screenshots |
| W6 | 065, 066, 082 + **GP-1 063** | GP-1 evidence |
| W7 | 068, 069, 070 + **GP-2 067** | GP-2 evidence |
| W8 | **GP-3 071**, **GP-4 072** | headless win test green |
| W9 | **GP-5 073** | **first playable of the real game** |
| W10–W12 | mechanics DB + rule runtime + input hardening + meadow_02 | see rows |
| W13–W23 | Meadow 03 → 10 in system order (catch/gust/puff → mask/mushroom → height/trim/wobble → shape/sprouts → fog → survive/ramp → flip/eggs → belt) | per level scene: screenshot + input_simulate playtest |
