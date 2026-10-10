# ADR-0010: Level Flow and App Lifecycle

## Status

Accepted (2026-10-10, accepted by user: Orchestrator chosen for menus and level flow; godot_state_charts rejected and to be removed)

## Date

2026-10-10

## Last Verified

2026-10-10

## Decision Makers

Tessa (user), godot-specialist (engine validation); cross-checked against Godot Game Dev Studio skills `godot-master`, `godot-scene-management`, `godot-platform-mobile`, `godot-state-machine-advanced`, `godot-prompter-mobile-development`

## Summary

The game needs one owner for the screen flow (boot → title → island map → level intro → play → pause → results → next/retry), the level phases (Intro → Countdown → Playing → Warning → Won/Lost/Out, Paused), Android backgrounding and the Back button, and scene loading. The phases that change gameplay (Countdown, Playing, Warning, Won/Lost/Out) and the level clock live in `BoardSim` as sim ms. The screen flow, Intro, Paused and Results are thin Orchestrator graphs on an `AppFlow` node under `Main` that call typed GDScript. Pause is `SceneTree.paused`, Back is handled through `NOTIFICATION_WM_GO_BACK_REQUEST` on a screen stack, and levels load with threaded `ResourceLoader`.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core / Scripting (app lifecycle, scene flow) |
| **Layer** | Core |
| **Knowledge Risk** | MEDIUM: lifecycle notifications and threaded loading are stable since 4.0, but none of them is in `docs/engine-reference/godot/`. Orchestrator 2.5 is post-cutoff. The 4.6 dual-focus change affects Back and pause-menu focus |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md`, `deprecated-apis.md`, `current-best-practices.md`, `modules/ui.md`, `modules/input.md`; `addons/orchestrator/orchestrator.gdextension` (`compatibility_minimum="4.7"`), `addons/orchestrator/CHANGELOG.md` (2.5.stable, 2026-07-03) |
| **Post-Cutoff APIs Used** | Orchestrator 2.5 (GDExtension, OScript graphs); 4.6 dual focus (`grab_focus()` is keyboard/gamepad only) |
| **Verification Required** | (1) On an Android device: `NOTIFICATION_APPLICATION_FOCUS_OUT` and `NOTIFICATION_APPLICATION_PAUSED` arrive for the home button, the app switcher and an incoming call. (2) `application/config/quit_on_go_back = false` plus `NOTIFICATION_WM_GO_BACK_REQUEST` on Android, including gesture navigation. (3) `ResourceLoader.load_threaded_request/get_status/get` timing for `meadow_01.tscn` on the reference phone, < 500 ms. (4) Orchestrator's Android `.so` loads in an export, and the OScript graph runs in a release build and in a headless gdUnit run. (5) The OScript file extension and text format in 2.5 (not named in the addon's README or CHANGELOG); confirm before the first graph is saved. **Verified headless on 4.7.2 (2026-10-10):** `SceneTree.set_quit_on_go_back` and the project setting `application/config/quit_on_go_back` both exist; `Tween.set_pause_mode` and `Input.flush_buffered_events` exist |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Accepted): tick, sim phases, no wall clock in the sim |
| **Enables** | Touch input pipeline ADR (pause cancel contract), save/profile ADR (`app_backgrounded` save hook, result fan-out), camera/orientation ADR (rotate-pause), ADR-0009 round flow (per-board `OUT`) |
| **Blocks** | GP-5 first playable; Meadow MVP plan step 4 (menus + flow) and step 6 (levels won + lost) |
| **Ordering Note** | Adds level phases to `BoardSim` (ADR-0001 interface), so do it before goal and top-out plugins are wired in GP-3. `t_warning_ms` and `countdown_ms` must be in the knob registry (ADR-0004) before the sim reads them |

## Context

### Problem Statement

Three GDD requirements have no owner: the level state machine with its result fan-out (TR-level-goals-fail-states-003), pausing at once on backgrounding or a call with no input buffered across the pause (TR-touch-controls-005), and Android Back stepping exactly one screen (TR-menus-level-select-002). The modular layout names `Main`, `AppFlow` and `PlaySession` but does not say who owns the level clock. ADR-0001 says the sim has no wall clock, while the goals GDD says the clock runs only in Playing. The user wants framework flow in Orchestrator graphs, and the untracked `godot_state_charts` addon is a competing choice. One of them has to go.

### Constraints

- ADR-0001: `BoardSim` is pure RefCounted on a fixed 60 Hz integer-ms tick, with no nodes, signals, `await` or wall time. Pause, warnings and backgrounding stop ticking.
- architecture.md principle 5: few autoloads; only `NetSession` is planned.
- ADR-0008: GDScript first. Orchestrator is a third-party native binary, so it is recorded here as an exception.
- Android first, Mobile renderer, both orientations.
- Values are data: phase durations are knobs, not constants.

### Requirements

- Level phases Intro → Countdown → Playing → (Warning) → Won/Lost/Out, plus Paused. The level clock runs only in Playing (goals GDD rules 12–14).
- Results fan out to Scoring & Stars, Campaign, Tournament Flow and the results screen. Board frozen, input disabled.
- Backgrounding or a call pauses at once, cancels touches and buffers nothing across the pause. Resuming mid-level shows the pause menu.
- Pause during Countdown restarts the countdown on resume (`ux/pause.md`). After resume, a 600 ms "1" beat comes before ticking restarts.
- Back returns exactly one screen. From Play it opens Pause, from Pause it resumes, from Title it asks "Quit?". Never more than one confirmation in a row.
- Tap-to-intro load time under 500 ms on the reference phone.

## Decision

### 1. Who owns what

| Owner | Owns | Clock |
|---|---|---|
| `BoardSim` (pure, ADR-0001) | `LevelPhase`: `COUNTDOWN → PLAYING ⇄ WARNING → WON / LOST / OUT`; the **level clock** | sim ms: `level_ms = (playing_ticks * 1000) / SIM_HZ` |
| `PlaySession` (Node, Orchestrator graph) | `INTRO`, `PAUSED`, `RESUME_BEAT`, `RESULTS`; starts and stops stepping | none (does not step the sim) |
| `AppFlow` (Node under `Main`, Orchestrator graph) | screen stack, Back, lifecycle notifications, threaded loads | none |

- The sim is constructed in `COUNTDOWN`. `PlaySession` does not step it until Intro ends.
- `COUNTDOWN` lasts `countdown_ms` (knob, default 3 000). The first spawn happens on the tick it ends.
- `WARNING` lasts `t_warning_ms` (new knob, default 1 500, GDD target ≤ 1.5 s). The rescue wipe happens on entry. The view animates inside the window, like `t_resolve_ms` in ADR-0001.
- `playing_ticks` counts only ticks in `PLAYING`. Survive goals, time-limit fails and star times read `level_ms()`.
- `WON`, `LOST` and `OUT` are terminal. The sim emits one `level_result` event and from then on ignores every command and spawns nothing (board Frozen). `OUT` is versus only; the mode (ADR-0009) decides the round.

### 2. Pause

- Pause means `get_tree().paused = true`. `BoardController` is `PROCESS_MODE_PAUSABLE`, so `_physics_process` and the tick stop. Tweens, particles and the camera stop with it. The pause overlay, `AppFlow` and `Main` are `PROCESS_MODE_WHEN_PAUSED` or `ALWAYS`.
- Triggers: the ❚❚ button, Esc/P, gamepad Start, Back from Play, `NOTIFICATION_APPLICATION_FOCUS_OUT`, `NOTIFICATION_APPLICATION_PAUSED`, and an orientation change mid-level (rotated-pause variant).
- **Nothing buffered across a pause.** `BoardController` holds input commands in its own pending list and calls `sim.queue_command()` only inside `_physics_process`, just before `step()`. On pause it calls `input.cancel_all()` (drops active touches and gesture state) and `controller.clear_pending()`. The sim queue is always empty between frames, so the `BoardSim` interface does not change.
- Resume: `get_tree().paused = false`, then `RESUME_BEAT` (600 ms, node-side tween) with `controller.stepping = false`, then stepping resumes. If the sim phase is `COUNTDOWN`, the controller queues `SimCommand(&"countdown_restart")` first.
- `NOTIFICATION_APPLICATION_PAUSED` also stores `Engine.max_fps`, drops it to 1 and mutes the Master bus for battery and heat (studio `godot-platform-mobile`, `thermal_throttle_monitor.gd`), then emits `app_backgrounded`. The save ADR saves on that signal without blocking the main thread (`WorkerThreadPool`; iOS allows ~5 s; `godot-master` Workflow 4). `RESUMED` restores the stored `max_fps` and unmutes. `RESUMED` / `FOCUS_IN` never unpause: the game stays paused with the pause menu showing.
- Pause during `RESULTS` is ignored.
- The rotate trigger comes from the viewport's `size_changed` signal when the aspect flips during Play (the camera/orientation ADR owns the detection). It is not a lifecycle notification.
- `input.cancel_all()` clears touch state by index (release events are not delivered while the app is in the background), calls `Input.flush_buffered_events()`, and releases any held actions.

### 3. Back (Android) and the screen stack

- Project setting `application/config/quit_on_go_back = false`. It sets `SceneTree.quit_on_go_back` at boot; both exist on 4.7.2.
- `AppFlow._notification(NOTIFICATION_WM_GO_BACK_REQUEST)` and the `ui_cancel` action (Esc, gamepad B) all call `AppFlow.back()`. Android Back may also arrive as `ui_cancel`, so `back()` runs at most once per process frame (guard on `Engine.get_process_frames()`). It pops exactly one entry: an overlay (Settings, Rules) → the screen below; Play → Pause; Pause → resume; Island map → Title; Title → the "Quit?" dialog; the "Quit?" dialog → close it. Quitting happens only from the dialog's confirm (`get_tree().quit()`).
- Screens are Control scenes under `Main/Screens`. Overlays push on top without freeing what is below. Only one confirmation dialog can be on the stack. `ScreenStack` is a pushdown stack (studio `godot-state-machine-advanced`, `hsm_pushdown_stack.gd`): `pop()` never removes the base screen (Title), and a screen uncovered by a pop gets `enter(is_resume = true)`, so entry animations and skits do not replay. Screen ids are `StringName` constants, never string literals.
- 4.6 dual focus: after every push or pop, `AppFlow` calls `grab_focus()` on the new top screen's first control, which covers keyboard/gamepad focus. Touch needs no focus.

### 4. Scene loading

- `PLAY_SESSION` (the same for every level) is `preload`ed by `Main` at boot.
- Level scenes load with `ResourceLoader.load_threaded_request(path, "", false)` (no sub-threads by default; benchmark `true` on the reference phone). `AppFlow` polls `load_threaded_get_status()` in `_process` behind a loading cover (shown only after 150 ms, so fast loads never flash), then takes the scene with `load_threaded_get()`.
- `load_threaded_request` returns an `Error`. Anything other than `OK` is treated like a failed load.
- Back during a load is ignored. `THREAD_LOAD_FAILED` (or `INVALID_RESOURCE`) shows an error toast and stays on the island map; every started request is consumed with `load_threaded_get` so nothing stays cached.
- The loading-cover and resume-beat tweens are bound to the tree, `get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)`, never to a screen node that may be freed (`godot-master` NEVER #11).
- While Results is showing, `AppFlow` prefetches the next level's scene, so "Next" is usually instant. At most the current and the next level stay cached.
- Shader warm-up for the block set (ADR-0007 risk) runs inside the same cover before Intro.
- Paths come only from biome data (`assets/data/biomes/<biome>.json`, ADR-0005). The framework never names a level.

### 5. Orchestrator use

**Chosen tool: Orchestrator** (user, 2026-10-10). `godot_state_charts` is rejected (Alternative 1); the project uses one flow tool.

**Gate: Android-export smoke test first.** Before the first graph is saved in Phase 4 of `production/orchestration/meadow-mvp-plan.md`, build a debug Android APK containing one trivial OScript graph (boot → push Title → pop) and run it on a device, plus the same graph in a release export and a headless gdUnit run (verification items 4 and 5). Evidence goes to `production/qa/evidence/adr-0010/`. Pass = the `.so` loads, the graph runs, no errors in logcat.

**Fallback: plain GDScript.** If the smoke test fails, or Orchestrator later breaks on a Godot point release, `AppFlow` and `PlaySession` become plain GDScript enum state machines (Alternative 2) that call the same typed methods. Because graphs only sequence (below), the swap is ~100 lines and touches nothing in `core`, `data`, `view` or `ui`. The fallback needs no new ADR; record the switch in this ADR's Migration Plan.

- Exactly two graphs: `src/game/app_flow.<ext>` (screen stack and lifecycle) and `src/game/play/play_session.<ext>` (Intro / Paused / ResumeBeat / Results). `<ext>` is the OScript extension confirmed in verification item 5. It must not be guessed.
- **Graphs only sequence.** Every node in a graph calls a typed GDScript method or reads a signal. No gameplay rule, number, path or save logic lives in a graph. The logic they call (`ScreenStack`, `LevelLoadJob`, `BoardController`, `LevelResult`) is GDScript and covered by gdUnit tests.
- Orchestrator is used only in `src/game/`. `core`, `data`, `mechanics`, `view` and `ui` never use it. The layering test is extended to fail on OScript files outside `src/game/`.
- `addons/godot_state_charts/` and `godot_state_charts_examples/` are deleted. They are untracked and nothing references them.
- Editor lock leftovers `addons/orchestrator/~orchestrator.*` are never committed (add `~*.dll*` to `.gitignore`).

### Architecture Diagram

```
Main (Node, ALWAYS) ── preload PLAY_SESSION · lifecycle notifications
 └ AppFlow (Node, ALWAYS; Orchestrator graph → ScreenStack, LevelLoadJob)
     ├ Screens/  Title · IslandMap · Settings(overlay) · QuitDialog       (Control, ui/)
     └ World/    PlaySession (Orchestrator graph: INTRO→[sim]→PAUSED/RESUME_BEAT→RESULTS)
                   ├ Stage (LevelStage, loaded threaded)
                   ├ BoardController (PAUSABLE) ── step() ──▶ BoardSim
                   │      pending cmds ─▶ queue_command   LevelPhase: COUNTDOWN→PLAYING⇄WARNING→WON/LOST/OUT
                   │      ◀── SimEvent: phase_changed, level_result (level_ms, counts)
                   └ UI: Hud · TouchInput · PauseOverlay(WHEN_PAUSED) · ResultPanel

FOCUS_OUT / APP_PAUSED / ❚❚ / Back-in-play ─▶ AppFlow.request_pause(reason)
   ─▶ tree.paused = true · input.cancel_all() · controller.clear_pending()
level_result ─▶ PlaySession.finished(LevelResult) ─▶ AppFlow ─▶ ResultPanel · StarRater · Campaign/Profile · Tournament
```

### Key Interfaces

```gdscript
# core/sim (ADR-0001 addition)
enum LevelPhase { COUNTDOWN, PLAYING, WARNING, WON, LOST, OUT }
func get_phase() -> int                 # LevelPhase
func level_ms() -> int                  # (playing_ticks * 1000) / SIM_HZ
# SimEvent kinds added: &"phase_changed" {from, to}, &"level_result" {outcome, level_ms,
#   layers_cleared, warnings_used, pieces_placed}
# SimCommand kind added: &"countdown_restart"

class_name LevelResult extends RefCounted   # core/model; built from the level_result event
var outcome: StringName                     # &"won" | &"lost" | &"out"
var level_ms: int
var layers_cleared: int
var warnings_used: int
var pieces_placed: int

# game/play
class_name BoardController extends Node
var stepping: bool                       ## false during Intro and the resume beat
func push_command(cmd: SimCommand) -> void   ## held until the next _physics_process
func clear_pending() -> void
signal level_finished(result: LevelResult)

class_name PlaySession extends Node
func start(stage: LevelStage, level: LevelData, catalog: GameCatalog, round_seed: int) -> void
func restart() -> void                   ## new sim, same stage and seed rule; Intro skit skipped
signal finished(result: LevelResult)

# game
class_name AppFlow extends Node
func open_level(scene_path: String) -> void      ## threaded load, then PlaySession.start
func request_pause(reason: StringName) -> void   ## &"button" | &"back" | &"focus_out" | &"app_paused" | &"rotate"
func back() -> void                              ## pops exactly one screen
signal app_backgrounded                          ## save/profile ADR hooks here

class_name ScreenStack extends RefCounted        ## pure; unit-tested
func push(screen: StringName, overlay: bool) -> void
func pop() -> StringName                         ## never pops the base screen; uncovered screen gets enter(is_resume = true)
func top() -> StringName

class_name LevelLoadJob extends RefCounted       ## wraps ResourceLoader threaded calls
func start(path: String) -> void
func poll() -> int                               ## ResourceLoader.ThreadLoadStatus
func take() -> PackedScene

# game/input (contract for the touch input pipeline ADR)
func cancel_all() -> void                        ## drop active touches, gestures, buffers
```

### Implementation Guidelines

- `BoardSim` must own the level clock. Nothing outside the sim may measure level time, and no node may use `Time` or `delta` for star times, Survive or time limits.
- `PlaySession` must never step the sim during Intro, Paused, the resume beat or Results.
- `BoardController` must never call `sim.queue_command()` outside `_physics_process`, and must clear its pending list on every pause.
- `BoardController._physics_process` must never `await`. The step loop stays synchronous (ADR-0001; `godot-master` NEVER #7).
- Every pause trigger must go through `AppFlow.request_pause()`. Nothing else may set `get_tree().paused`.
- `quit_on_go_back` must stay `false`. Only the Quit dialog's confirm may call `get_tree().quit()`.
- Orchestrator graphs must only sequence calls to typed GDScript. Graphs must never hold gameplay values, paths or rules, and must never appear outside `src/game/`.
- Levels must load with `ResourceLoader.load_threaded_*`. Never use `change_scene_to_file` or a blocking `load()` on a level path.
- New knobs `t_warning_ms` (default 1 500) and `countdown_ms` (default 3 000; already in the goals GDD) go into `assets/data/knobs/*.json` (ADR-0004).

## Alternatives Considered

### Alternative 1: godot_state_charts 0.22.5
- **Description**: Statechart nodes (pure GDScript). Paused would be a parallel or history state over Playing.
- **Pros**: No native binary; nested and history states fit pause well; easy gdUnit tests.
- **Cons**: A second visual tool next to Orchestrator, which the user already wants for framework and level flow (MVP plan rows 4 and 6).
- **Rejection Reason**: User choice (2026-10-10): one flow tool, Orchestrator. State Charts is **rejected**; `addons/godot_state_charts/` and `godot_state_charts_examples/` are removed in a later cleanup step.

### Alternative 2: Plain GDScript enum state machine
- **Description**: About 100 lines in `AppFlow` and `PlaySession`.
- **Pros**: No dependency, fully testable.
- **Cons**: No visual graph.
- **Rejection Reason**: The user wants Orchestrator graphs for framework flow. The thin-graph rule keeps most of this option's testability. **Kept as the sanctioned fallback** if the Android-export smoke test (§5) fails.

### Alternative 3: Flow layer owns the level clock
- **Description**: A node-side timer runs the phases and tells the sim when to play.
- **Pros**: All phases in one graph.
- **Cons**: Wall-clock level time breaks ADR-0001. Survive goals, star times and replays would depend on frame rate.
- **Rejection Reason**: Contradicts ADR-0001.

### Alternative 4: A controller flag instead of `SceneTree.paused`
- **Rejection Reason**: Every tween, particle and camera motion would need to check the flag. `SceneTree.paused` freezes everything with one switch.

### Alternative 5: `AppFlow` as an autoload
- **Rejection Reason**: Breaks the few-autoloads principle. `Main` lives for the whole app anyway.

## Consequences

### Positive
- Survive goals, star times and versus results stay deterministic and replayable, because the clock is in sim ticks.
- One pause switch. No input crosses a pause, by construction rather than by checks.
- Back behaviour lives in one function backed by a unit-tested stack.
- The user gets Orchestrator graphs for the flow. The logic they call stays testable GDScript.

### Negative
- Orchestrator adds a native binary of ~9 MB per Android ABI (arm64 and armv7) to the APK, and the project now depends on a third-party native module (an ADR-0008 exception).
- OScript graphs are hard to diff in review and can't be unit tested directly. Mitigated by the thin-graph rule and the integration test.
- `BoardSim` gains a phase field, two events, one command and one knob read (`t_warning_ms`).

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Android doesn't deliver `FOCUS_OUT` for a call or notification shade on some devices | Medium | High | Handle both `FOCUS_OUT` and `APPLICATION_PAUSED`; device test (AC 3) |
| Back pops twice (`GO_BACK_REQUEST` + `ui_cancel` in one press) | Medium | Medium | Once-per-frame guard in `back()`; `ScreenStack` unit test |
| Orchestrator lags a Godot point release or is abandoned | Medium | Medium | Graphs only sequence typed GDScript, so replacing them with ~100 lines of GDScript is mechanical |
| OScript fails headless or in release export | Low | High | Verification item 4 before GP-5; the integration test runs headless |
| Level load > 500 ms on the reference phone | Medium | Medium | Prefetch the next level on Results; delayed cover; profile shader warm-up (ADR-0007) |
| A gesture-nav back swipe arrives as something other than `GO_BACK_REQUEST` | Low | Medium | Device test (verification item 2) |

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| level-goals-fail-states.md (TR-…-003) | Intro → Countdown → Playing → Warning → Won/Lost/Out, Paused; clock only in Playing; results fan out | Sim `LevelPhase` + `level_ms`; node-side Intro/Paused/Results; `level_result` → `LevelResult` → AppFlow fan-out |
| level-goals-fail-states.md edge case | App paused or backgrounded: clock stops | Tree pause stops ticking; clock is sim ticks |
| touch-controls.md (TR-…-005), rule 5b, AC 18 | Backgrounding or call: pause at once, cancel touches, buffer nothing; phone turned mid-level pauses | `FOCUS_OUT`/`APPLICATION_PAUSED`/rotate → `request_pause` → `cancel_all` + `clear_pending` |
| menus-level-select.md (TR-…-002), rule 7, AC 4 | Back returns exactly one screen; never more than one confirmation | `quit_on_go_back = false`, `GO_BACK_REQUEST` → `ScreenStack.pop()` |
| menus-level-select.md edge case | Resume mid-level after backgrounding shows the pause menu | `RESUMED`/`FOCUS_IN` do nothing; overlay stays |
| ux/pause.md | Pause during countdown restarts it; 600 ms resume beat; pause during result ignored | `countdown_restart` command; `RESUME_BEAT` with stepping off; ignored in `RESULTS` |
| ux/README.md flow | Boot → Title → Island map → Intro → Countdown → Play → Results → Next/Retry/Map; Settings overlay | `AppFlow` screen stack; `PlaySession.restart()`; prefetch Next |

## Performance Implications
- **CPU**: negligible. One phase check per tick, and graph transitions only on events.
- **Memory**: current + next level scenes cached; Orchestrator runtime ~9 MB per ABI on disk.
- **Load Time**: tap to Intro < 500 ms target on the reference phone (threaded load + prefetch).
- **Network**: none. Versus round flow stays in ADR-0009.

## Migration Plan

No flow code exists yet. Changes to existing docs:
- `architecture-modular-layout.md` §4.3 step 3: `load(scene_path)` → `LevelLoadJob` (threaded). Steps 6–7: the countdown is a sim phase, not started by `PlaySession`.
- `architecture.md`: add ADR-0010 to §3, and a "Level flow" line to §2 Layers.
- `docs/architecture/tr-registry.yaml`: point TR-level-goals-fail-states-003, TR-touch-controls-005 and TR-menus-level-select-002 at ADR-0010.
- `project.godot`: `application/config/quit_on_go_back=false`; `.gitignore`: `~*.dll*`.
- Delete `addons/godot_state_charts/` and `godot_state_charts_examples/` (untracked).

**Rollback plan**: replace the two graphs with GDScript calling the same methods (Alternative 2). Nothing in the sim or UI changes.

## Validation Criteria

- [ ] [M] **Gate:** Android-export smoke test of a trivial OScript graph passes (debug APK on device, release export, headless gdUnit) before the first real graph; otherwise switch to the GDScript fallback.
- [ ] [U] `BoardSim`: `countdown_ms = 3000` → first spawn on tick 180; `level_ms()` is 0 through the countdown and the warning, and counts only Playing ticks.
- [ ] [U] `BoardSim`: after `level_result`, commands are ignored and nothing spawns.
- [ ] [U] `ScreenStack`: every screen pops exactly one; at most one confirmation on the stack.
- [ ] [U] `BoardController`: commands pushed before a pause are not applied after resume.
- [ ] [I] headless `tests/integration/level_flow/`: boot → meadow_01 → win → Results → Next opens meadow_02's Intro; Retry skips the skit.
- [ ] [M] Android: home button, app switcher and an incoming call each pause at once with the pause menu showing on return; a held touch does not act after resume.
- [ ] [M] Android: Back from every screen goes exactly one screen back; Back on Title shows "Quit?".
- [ ] [M] Reference phone: tap on an island → Intro card < 500 ms (screenshot + timing log in `production/qa/evidence/`).

## Related
- ADR-0001 (depends on: adds level phases and level clock to `BoardSim`)
- ADR-0004 (new knob `t_warning_ms`), ADR-0005 (biome data holds level paths), ADR-0007 (shader warm-up in the load cover), ADR-0008 (Orchestrator native exception), ADR-0009 (round flow consumes `OUT`)
- `design/gdd/level-goals-fail-states.md`, `design/gdd/touch-controls.md`, `design/gdd/menus-level-select.md`, `design/gdd/ux/README.md`, `design/gdd/ux/pause.md`, `design/gdd/ux/interaction-patterns.md`
- `docs/architecture/architecture-modular-layout.md` §4.3
