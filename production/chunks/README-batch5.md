# Coding chunks - batch 5: Meadow build tickets for MB-015..MB-039 (no tests)

Written by lead-programmer 2026-10-10 for `production/orchestration/meadow-build-tasks.md`. **User rule: NO TESTS.** Tickets describe game code only and how the integrator sees it working in the editor (script eval + `logs_read`, or run a scene + `editor_screenshot`). Writers do not write test files and do not launch Godot. Conventions: `README.md` (ignore its tests-first lines). Chunks keep their batch-4 CH number when the MB task already names one (CH-049..CH-066 etc.); new chunks use CH-153 onward.

Same-file chains run as ONE agent in order: `input` 153 -> 154 -> 155 | `movement.gd` 051 -> 053 | `board_sim.gd` 035 -> 064 -> 166 -> 066 -> 167 (-> 068 later).

| ID | MB | Title | Depends | Status |
|---|---|---|---|---|
| CH-049 | MB-017 | LevelLoader + LoadResult | CH-084 (knob additions), CH-037 (JsonNum), CH-034 (LevelData) | staged |
| CH-051 | MB-021 | Movement: ActivePiece cells, translate, drop distance, resting | CH-048 (ActivePiece), CH-031 (BoardState queries); GDD movement-rotation (Designed) | staged |
| CH-053 | MB-021 | Movement: rotate X/Y/Z with kicks and up-kick budget | CH-051, CH-160, CH-001 (Orientations) | staged |
| CH-055 | MB-024 | CatalogLoader + CatalogResult | CH-049, CH-038 (palette), CH-047 (shape_bank.tres), CH-022, CH-083 | ready |
| CH-056 | MB-025 | BoardView: MultiMesh locked blocks (greybox) | CH-041 (ArtSet/BoardGeom), CH-050 (delta), CH-080 (SlotMap), CH-081 (BlockViewMath), ADR-0007 | staged |
| CH-057 | MB-025 | PieceView: falling piece from the shape GLB with interpolation | CH-041, CH-047, CH-048 | staged |
| CH-058 | MB-032 | BoardController: fixed tick, intents to SimCommands, pending list | CH-154 (GameInput), CH-159 (rig), CH-035/064 (BoardSim) | ready |
| CH-059 | MB-016 | `top` arrival plugin | CH-052 (RuleApi read subset), CH-047 (shape bank), CH-150 | staged |
| CH-060 | MB-022 | `layer` and `none` clear detectors | CH-151 (bases), CH-050 (BoardState writes, for later use) | staged |
| CH-061 | MB-022 | `clear_n` goal evaluator | CH-151, CH-148 | staged |
| CH-062 | MB-033 | Greybox HUD + result panel bound from HudSnapshot | CH-165; GDD hud + ux/hud (Designed) | ready |
| CH-064 | MB-031 | BoardSim: countdown, first spawn, spawn event | CH-035, CH-044, CH-059, CH-049, CH-148 | staged |
| CH-066 | MB-031 | BoardSim: hard drop, grace, lock delay, lock write | CH-166, CH-050, CH-148; GDD fall-drop-lock (Designed) | staged |
| CH-087 | MB-023 | StarRater (time stars, relaxed scaling) | CH-148, GDD scoring-stars (in revision: take values from the file at start time) | ready |
| CH-088 | MB-023 | ScoreKeeper (clear F2, combo, drop and place points) | CH-148, GDD points-system (Designed) | ready |
| CH-153 | MB-015 | InputAxes + spin/tilt/roll GUIDE actions | MB-005 (GUIDE verified) | staged |
| CH-154 | MB-015 | GameInput: 3 rotation pairs, enabled_axes, cancel_all | CH-153 (same agent) | staged |
| CH-155 | MB-015 | InputContextRouter + play / play_paused / menu / remap_capture contexts | CH-153, CH-154 | staged |
| CH-156 | MB-019 | ViewSnap (settled snap k, allowed mask, direction + rotation-axis map) | CH-023 (CameraMath) | staged |
| CH-157 | MB-019 | OrthoFraming (ortho size, offsets, cube edge px) | CH-024 (CameraMath.ortho_size) | staged |
| CH-158 | MB-019 | MotionPrefs (reduced-motion value object) | none | staged |
| CH-159 | MB-019 | BoardCameraRig: free orbit, settle tween, view_changed, freeze | CH-156, CH-157, CH-158; MB-006 verdict (phantom_camera or plain Camera3D) | ready |
| CH-160 | MB-021 | KickTable: ordered kick candidates (GDD F2) | CH-048 | staged |
| CH-161 | MB-022 | `slice` collapse policy | CH-054 (`BoardState.shift_layers`), CH-060 | staged |
| CH-162 | MB-022 | `rescue` and `lose` top-out policies | CH-151, CH-050, CH-054, CH-148 | staged |
| CH-163 | MB-025 | BoardStage: floor, grid and back-wall guides (readability) | CH-041 | staged |
| CH-164 | MB-025 | GhostView: landing ghost + landing shadow | CH-057 | staged |
| CH-165 | MB-033 | HudSnapshot value type | CH-148, GDD hud (Designed) | staged |
| CH-166 | MB-031 | BoardSim: gravity, soft drop, move command | CH-064, CH-051 | staged |
| CH-167 | MB-031 | BoardSim: rotate command, lock-reset hookup | CH-066, CH-053 | staged |
| CH-168 | MB-027 | UiScreen base, UiLayers, UiIntents | none (ADR-0016) | staged |
| CH-169 | MB-027 | ScreenStack (pushdown) + back rules | CH-168 | staged |
| CH-170 | MB-027 | AppFlow node: screens, Back, pause request, level open | CH-168, CH-169, CH-155 (router); MB-014 deferred (Android smoke test moved to the end, desktop first) | ready |
| CH-171 | MB-028 | ThemeScaler, UiFormat and the string-key lint | CH-168; GDD ux/ui-theme (Designed) | staged |
| CH-172 | MB-029 | ProfileStore (4 slots, in memory) + MemorySaveIO | none; ADR-0013 is the spec | staged |
| CH-173 | MB-034 | Title screen + Quit dialog | CH-168, CH-169, CH-171, CH-172; GDD ux/title | ready |
| CH-174 | MB-034 | Profile select screen (list + delete confirm) | CH-168, CH-171, CH-172; GDD ux/profile-select | ready |
| CH-175 | MB-034 | Profile create/rename panel | CH-174 | ready |
| CH-176 | MB-035 | Island map screen (cloud wizard over 10 islands) | CH-168, CH-171; GDD ux/island-map; data `assets/data/campaign/meadow_map.json` | ready |
| CH-177 | MB-035 | Level intro card + countdown overlay | CH-168, CH-165, CH-171; GDD ux/level-intro-countdown | ready |
| CH-178 | MB-039 | Pause overlay (+ confirm dialogs) | CH-168, CH-165, CH-170; GDD ux/pause | ready |
| CH-179 | MB-039 | Results screen (win / loss) | CH-168, CH-171, CH-087; GDD ux/results | ready |
| CH-180 | MB-027 | AppFlow Orchestrator graph (thin) - after the smoke test | CH-170; MB-014 pass | ready |

## Existing tickets rewritten to the no-tests rule (still the ticket of record)

| ID | MB | Note |
|---|---|---|
| CH-037 | MB-001 | tests removed; expected results kept |
| CH-038 | MB-018 | blocked on MB-007 palette hues |
| CH-041 | MB-018 | ArtSet + BoardGeom |
| CH-043 | MB-016 | **superseded by CH-151** (same bases, gap-decision signatures) |
| CH-044 | MB-012 | done |
| CH-046 | MB-026 | touch scheme A, wait for the touch-controls GDD revision |
| CH-084 | MB-010 | done |
| CH-148 | MB-008 | done |
| CH-150 | MB-016 | validate() on bases |
| CH-151 | MB-016 | GoalEvaluator + TopOutPolicy |
| CH-152 | MB-016 | ControlVerb + LayoutKind |
| CH-009 | - | fuzz test: **dropped** (no-tests rule) |

## Not ticketed here

- MB-014 (Android smoke test): moved to the end of the project by the user (no device testing until the game is finished); CH-170 AppFlow is plain GDScript, CH-180 is the optional Orchestrator graph.
- MB-020 / MB-030 / MB-036 / MB-041 (integration tasks): integrator brief, no code tickets.
- MB-038 (CH-068 BoardSim resolve/end), MB-037 (CH-065 PlaySession, CH-070 Main), MB-040+: next ticket batch.
- Batch-4 chunks without a ticket file that these depend on (CH-047, 048, 050, 052, 054, 083, 087/088 done above): tickets for CH-048/050/052/054/083 and CH-047 still to be written if the batch-1 agents do not already have them (batch 1 is staged).
