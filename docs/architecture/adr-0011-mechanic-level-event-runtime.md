# ADR-0011: Mechanic and Level-Event Runtime (Rules in the Sim, Beehave Staging)

## Status

Accepted (2026-10-10, accepted by user)

## Date

2026-10-10

## Last Verified

2026-10-10

## Decision Makers

Tessa (user; wave 1 decision sheet 2026-10-10: "Beehave: staging/animation only. Anything that changes the board is a RuleRuntime rule inside BoardSim"), technical-director (author). Inputs: game-designer `design/gdd/meadow-candidate-atoms.md` (Open Questions 1, 2, 6), architecture review 2026-10-10 gap ADR #2.

## Summary

Every mechanic atom and level event that changes the game (Pip's catch, the Miller's gusts, flip and belt, eggs, ants, sprouts, wobble, mushrooms) is a `RuleBehaviour` (or slot plugin) inside the pure `BoardSim` tick and acts only through `RuleApi` (ADR-0001, ADR-0004). Two new layer ranks are added (`mascot` 1, `content` 2), and the resolve sequence gets two new steps: S4a (structure changes) and S4c (one post-hook clear pass). Beehave 2.9.3 trees are presentation only. They live in the level scene, read `SimEvent`s that a `StagingHost` hands them once per frame, and drive animation, skits and character reactions. They never write to the sim, so a replay gives the same result with or without them.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core / Scripting (rules); Presentation (staging) |
| **Layer** | Core (rules), Presentation (staging) |
| **Knowledge Risk** | LOW for the sim side: pure GDScript RefCounted, no new engine API. MEDIUM for staging: beehave 2.9.3 is a third-party GDScript addon (post-cutoff version), and its `BeehaveTree._ready()` calls `get_tree().root.get_node("BeehaveGlobalDebugger")` unconditionally outside the editor (`addons/beehave/nodes/beehave_tree.gd` lines 138 and 323) |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `current-best-practices.md`; `addons/beehave/plugin.cfg` (2.9.3), `addons/beehave/nodes/beehave_tree.gd` (`ProcessThread { IDLE, PHYSICS, MANUAL }`, `tick()`, `interrupt()`, `tick_rate`), `addons/beehave/plugin.gd` (registers autoloads `BeehaveGlobalMetrics`, `BeehaveGlobalDebugger`), `addons/beehave/debug/global_debugger.gd` |
| **Post-Cutoff APIs Used** | None in the sim. Staging: beehave 2.9.3 node API (`BeehaveTree`, `Blackboard`, composites, `ActionLeaf`/`ConditionLeaf`) |
| **Verification Required** | (1) A `StagingTree` (subclass of `BeehaveTree`) runs with `process_thread = MANUAL` when the two beehave autoloads are stripped from a release export: the subclass overrides `_get_global_debugger()` and `_get_global_metrics()` to return a no-op stub node when the autoload is missing. Without that override the release build errors on the first tree's `_ready()`. (2) Beehave trees load and tick in a headless gdUnit run on 4.7.2. (3) Beehave trees run in an Android export (pure GDScript, so low risk). (4) `interrupt()` resets running leaves on retry without leaking `running_action` blackboard entries |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Accepted): pure tick, events out, lock veto, no wall clock. ADR-0004 (Accepted): `RuleBehaviour`, hooks, vetoes, `RuleApi`, F2 priority. ADR-0002 (Accepted): content types, board writes. ADR-0005 (Accepted): level JSON names rules, never code. ADR-0006 (Accepted): per-rule RNG streams. ADR-0010 (Accepted): `PlaySession` Intro/Results phases, `BoardController` signals, pause |
| **Enables** | CH-111 Pip / Miller presenters, CH-145 belt + Miller boss presenter, every Meadow level from meadow_02 on, ADR-0015 audio (same event consumer pattern), ADR-0017 level maker (atoms in a form, staging trees attached only in official scenes) |
| **Blocks** | MDW-002 (Pip's catch), Meadow MVP plan step 6 (levels 02–10 won and lost), any story implementing PL03, SP21, SP22, SP26, SP28, SP31, WO11, EV01–EV05 |
| **Ordering Note** | Amends ADR-0004 §2 (two ranks) and the per-lock sequence in `fall-drop-lock.md` rule 15 (S4a, S4c, P3). The rank table and S4a/S4c must land in core before the first `content` atom (SP21 in meadow_09) or the first flip. `StagingHost` must exist before CH-111 |

## Context

### Problem Statement

The Meadow needs a mascot that catches one bad drop (WO11), a villain who causes every disturbance (gusts EV01, flip EV03, belt EV05), and living content (eggs SP21, ants SP31, sprouts SP22, mushrooms EV04). The game-designer sketched each atom as a beehave tree "acting through the sim" and left two questions for this ADR: does a tree tick once per hook call or once per sim tick (OQ 1), and do mechanics write through `RuleApi` or `SimCommand` (OQ 2)? A third asks to accept the S4a/S4c steps and the `mascot`/`content` ranks (OQ 6). The architecture review flagged the core clash: beehave is node-based and ticks in `_process` / `_physics_process`, with `Time`-based decorators and a random selector, while ADR-0001 requires a pure RefCounted sim on an integer-ms tick. The user settled the direction on 2026-10-10: beehave is staging only.

### Constraints

- ADR-0001: `BoardSim` holds no `Node`, signal, `await`, `Time`, `OS` or global RNG. Same seed + same command log = same game on one device.
- ADR-0004: behaviours see only `RuleApi`. Board writes from `on_tick` / `on_fall_step` are buffered to end of tick; mask, down-axis and slot changes are queued to Resolving.
- ADR-0005: level JSON is data only. Player-made levels (future) may name rules, never code or trees.
- Values are data: no rule number lives in a scene or a tree (scene-build sheets: "no rule numbers in the scene").
- Flagship-phone and PC targets, Mobile renderer. Framework budget 0.5 ms per frame (TR-rule-twist-framework-010).
- GDScript only (ADR-0008).

### Requirements

- Every atom in `mechanics-module.md` maps to a slot plugin, a `RuleBehaviour` or content without core edits (TR-mechanics-module-001).
- Mascot behaviours decide and act at runtime (TR-mechanics-module-009).
- A fixed sub-step order: clear check, flip, conveyor shift, then spawn (TR-level-specific-mechanics-004), extended by S4a/S4c.
- Telegraphs come ahead of the action and are world-anchored (TR-twist-library-003).
- Gust times, directions and object cells are identical across runs for one seed (TR-twist-library-002).
- Presentation consumes events from all systems (TR-game-feel-vfx-001), and reduced motion changes variants, never gameplay timing (TR-game-feel-vfx-005).

## Decision

### 1. The split

| Concern | Where it runs | May write | Clock |
|---|---|---|---|
| Anything that changes board, piece, queue, goals, score, lock outcome, or any number the player is scored on | `RuleBehaviour` / slot plugin inside `BoardSim.step()` | through `RuleApi` only | sim ms (`api.now_ms()`) |
| Any decision that depends on game state and that the player can read (Pip's hint cell, gust direction, which cell a mushroom takes, "Pip would have caught that") | `RuleBehaviour`, announced by an event | through `RuleApi.emit()` | sim ms |
| How it looks and sounds: character poses, skits, camera cues, telegraph props, cheers and sulks, idle fidgets | beehave `StagingTree` in the level scene | node properties of its own presenter scene only | frame time (free) |

**Rule of thumb:** if removing the staging tree could change a single `SimEvent` or `state_hash()`, the logic is in the wrong place.

This answers the GDD's open questions:
- **OQ 1:** no tree runs in the sim. The atom sketches in `meadow-candidate-atoms.md` are kept as **logic specs** and implemented as plain GDScript in `handle(hook, ctx, api)`: one `match hook` branch per Sequence of the sketch. A behaviour handles every subscribed hook call it receives, so it can act at P3, S2, S3 and S4b in one tick.
- **OQ 2:** confirmed. Mechanics write through `RuleApi`. `SimCommand` is only for player intent and network-received attacks (ADR-0001). A rule never queues a `SimCommand`.
- **OQ 6:** accepted (sections 2 and 3).

### 2. Layer ranks (amends ADR-0004 §2 and GDD F2)

| Layer | Rank | Counts for F3 budget | Examples |
|---|---|---|---|
| `base` | 0 | no | core defaults |
| `perk` | 1 | no | character perks |
| `mascot` | 1 | no | WO06 helper, WO11 Pip's catch, WO07–WO09 later |
| `item_buff` | 2 | no | items, potions, skills |
| `content` | 2 | no | SP21 eggs, SP22 sprouts, SP26 ghost, SP28 puff, SP31 ants |
| `twist` | 3 | yes (≤ 2) | EV01 gust, EV03 flip, EV04 mushrooms, PL03 wobble |
| `mechanic` | 4 | yes (≤ 1) | EV05 mill belt, M1, M2, PL01 |

- The table is data: `res://assets/data/rule_layers.json` (`{layer: {rank, budget_key}}`), loaded by `RuleDef`. A rule JSON with an unknown layer fails validation (ADR-0005).
- `mascot` shares rank 1 with `perk`, and `content` shares rank 2 with `item_buff`. Ties fall through to F2's `activated_tick`, then `rule_id`, so the order stays total and deterministic. On a shared rank, a veto still wins a tie (ADR-0004 §6).
- The resulting S4b order is: ants, eggs and sprouts → mushrooms and wobble → the belt (GDD 0.6).

### 3. Resolve sequence (amends `fall-drop-lock.md` rule 15)

| Step | What happens | Hook | Notes |
|---|---|---|---|
| P0 | commands applied in arrival order | `on_command` | |
| P1 | rule tick | `on_tick` | writes buffered to end of tick (ADR-0004 §7) |
| P2 | gravity / travel step | `on_fall_step` | |
| **P3** | lock veto: `can(&"piece.lock")` | `veto()` | WO11 catch. A vetoed lock is not a lock: no `on_lock`, no counter advances |
| S1 | cubes written | | |
| S2 | | `on_lock` | |
| S3 | clear routine (slot `clear.detector`, `clear.collapse`) | `on_clear` per cell | |
| **S4a** | queued `request_down_axis` / `request_mask` / `request_slot` applied, then the stack settles | — | EV03 flip. Only here may the board's structure change |
| S4b | | `on_resolve_end` (ascending F2) | content, then twists, then the mechanic |
| **S4c** | if any S4b subscriber wrote or removed content (the `RuleApi` write buffer's dirty flag), the clear routine runs **once** more | `on_clear` | `on_resolve_end` does not run again; a layer still full waits for the next check. S4c clears count normally |
| S5–S10 | goal, top-out, outcome, entry delay, spawn | `on_goal_check`, `on_top_out`, `on_spawn` | |

- `t_resolve_ms` grows by the S4c round's clear time when S4c clears something. The sim reports the final Resolving length in the `resolve_started` event, so the view and staging never guess it.
- No input acts during Resolving (TR-fall-drop-lock-004). The outcome is fixed at S7.

### 4. Behaviour shape

```gdscript
class_name MascotCatch extends RuleBehaviour
const PLUGIN_ID := &"mascot_catch"
var _catches_left: int                     # set in on_level_start from api.param(&"mascot_catches")

func subscribed_hooks() -> Array[StringName]: return [&"on_level_start"]
func veto(action: StringName, ctx: HookContext, api: RuleApi) -> bool:
	if action != &"piece.lock": return false
	# K2–K7 from meadow-candidate-atoms §7, pure queries only
	...
func snapshot() -> Dictionary: return {&"left": _catches_left}
```

- State lives in the behaviour's own fields: ints, StringNames, packed arrays. No `Node`, `Object` references, `Callable`s or floats.
- `snapshot() -> Dictionary` (new `RuleBehaviour` virtual, default `{}`) returns all mutable state. `BoardSim.state_hash()` folds every active rule's snapshot in F2 order. A behaviour with state that it leaves out of the snapshot is a bug, and the replay test catches it.
- State is set in `on_level_start`. A retry builds a new `BoardSim` with new behaviour instances (ADR-0010 `PlaySession.restart()`).
- Counters count locks (only completed S1 locks) or sim ms. Never frames.
- `RuleApi` gains the pure queries the atoms need (GDD §10): `would_clear(cells)`, `new_covered_holes(cells)`, `would_top_out(cells)`, `goal_would_meet(cells)`, `spawn_cells_free()`, plus the writes `set_piece_flag(flag)` and `return_piece_to_spawn(hold_ms)`. Queries never write and never draw RNG.

### 5. The Meadow events

| Event | Rule (layer, rank) | Steps | Sim emits (for staging) | Staging tree reads it to |
|---|---|---|---|---|
| **Pip's catch** WO11 | `mascot_catch` (`mascot`, 1); tiers 1–3 only, rule absent from 04 | P3 veto, hold `catch_ms` with no gravity | `mascot_catch {from_cells, to_cells, hold_ms}`; `mascot_catch_spent {cells}` when K3–K7 hold but no catch is left | Pip leaps and carries the piece back inside `hold_ms`; Pip covers his eyes on `_spent` |
| **Pip's hint** WO06 | `mascot_hint` (`mascot`, 1) | `on_spawn` | `mascot_hint {cell}` | Pip points at the cell |
| **Gust** EV01 (the Miller's sails) | `gust` (`twist`, 3) | P1 `on_tick`; piece moved only by `try_translate` | `gust_warn {dir, at_ms}` `wind_warn_ms` ahead; `gust {dir, moved}`; `gust_dropped` | grass bends, sails spin up, Miller cranks |
| **Topsy Tumble** EV03 (the Miller's lever) | `flip` (`twist`, 3) | due → warning (`flip_warn_ms` play time) → S4a at the first Resolving after the warning | `flip_due {axis, in_ms}`, `flip_applied {axis}` | Miller hauls the lever, countdown ring, islet turns |
| **Mill Belt** EV05 | `mill_belt` (`mechanic`, 4) | S4b, last | `belt_windup` (lock before a shift), `belt_shift {dir, wrapped}` | Miller's lever, belt rolls |
| **Hatching eggs** SP21 | `egg` (`content`, 2) + content types `egg`, `chick` (ADR-0002) | S3 `on_clear` bonus; S4b hatch; S4c if a chick completes a layer | `egg_bonus`, `egg_hatched {cell}`, `chick_hop {from, to}` | eggs wobble, chick hops |
| **Picnic ants** SP31 | `ants` (`content`, 2) + content type `ant` | S3 shoo; S4b eat and move (canonical sort, one `api.rng()` draw) | `ant_shooed`, `ant_moved {from, to}`, `ant_ate`, `ant_left` | ant march, crumbs |

**The Miller is the face of the rules, not a rule** (`world-and-scenes.md` beat 10). His "pranks" are the gust, flip and belt rules above. His poses (crank, lever, cheer on `phase_changed → WARNING`, sulk on `cells_cleared`, bonk on `level_result`) are staging only. The meadow_10 boss phases are emergent: phase 2 is "after the 2nd clear", which the flip rule's own trigger (`flip_every_layers` 2) already produces. Staging derives `boss_phase` by counting `cells_cleared` events, and the sim keeps no boss state. If a later boss needs phases that change rules, that is a `mechanic`-layer rule (or EV13 Halftime swap) that emits `boss_phase {n}`.

### 6. The telegraph contract

- Staging can't predict the sim, so **every action that the view must show in advance is announced by the sim** with a `*_warn` / `*_due` event that carries the absolute `at_ms` or the remaining `in_ms` (TR-twist-library-003).
- Every window that staging animates inside comes in event data (`hold_ms`, `in_ms`, the Resolving length). Staging never reads gameplay knobs.
- Staging clamps its animations to those windows, as the view does for `t_resolve_ms` (ADR-0001). The sim never waits for staging.

### 7. Staging runtime

- **`StagingHost`** (`src/view/staging/staging_host.gd`, Node, `PROCESS_MODE_PAUSABLE`): one per `BoardController`. `PlaySession.start()` binds it to the controller's `sim_event(ev)` signal and to a read-only `SimReadout` (getters only: `get_board()`, `level_ms()`, `get_phase()`, `progress()`). It never gets the `BoardSim` or the controller.
- Each frame in `_process`, the host copies the frame's events, in tick order (up to `max_catch_up_ticks` ticks' worth), into every tree's blackboard as `&"events"`, updates `&"latest"` (kind → last event) and `&"reduced_motion"`, then calls `tick()` once on each tree. Trees use `process_thread = MANUAL`, so the host fixes the order and pausing the tree pauses staging.
- **`StagingTree extends BeehaveTree`** (`src/view/staging/staging_tree.gd`): `@export var rule_id: StringName` (empty for a level's story tree), MANUAL thread, and overrides of `_get_global_debugger()` / `_get_global_metrics()` that return a stub when the beehave autoloads are stripped (Engine Compatibility item 1).
- **Shared leaves** in `src/view/staging/leaves/`: `OnEvent(kind)` (condition: an event of that kind is in this frame's batch), `LatestIs(kind, key, value)`, `PlayAnimation(path, anim, window_key)` (RUNNING until finished or until the event's window ends), `MoveTo(marker)`, `PlaySkit(id)`, `EmitCue(kind)` (to audio and the camera, ADR-0015 / ADR-0014).
- **Allowed in staging:** `Time`, `delta`, beehave's `Cooldown`, `Delayer`, `TimeLimiter`, `SelectorRandom`, `SequenceRandom`, and a cosmetic `RandomNumberGenerator` owned by the host. Staging randomness is cosmetic and is never replayed.
- **Forbidden in staging:** any reference to `BoardSim`, `BoardController`, `RuleApi`, `RuleRuntime`, `SimCommand`, `queue_command`, `push_command` or `step(`; mutating an event's `data`; reading knobs; setting `get_tree().paused`.
- **Intro and Results skits** (ADR-0010) run on the same trees while the sim isn't stepping. `PlaySession` waits for `StagingHost.skit_finished` (with a timeout of `intro_skit_max_ms`, a knob) before Countdown. That is the flow waiting for a skit, not the sim waiting for the view. Retry skips the skit.
- **Retry:** `StagingHost.reset()` calls `interrupt()` on each tree and clears the blackboards.
- **Reduced motion** (follows the OS setting): leaves pick the short variant. Gameplay timing is unchanged, because the sim never sees it (TR-game-feel-vfx-005).
- The beehave autoloads `BeehaveGlobalMetrics` and `BeehaveGlobalDebugger` are dev-only and are stripped from release exports with the other dev autoloads (decision sheet defaults).

### 8. How a level attaches staging

- **Default presenter per mechanic:** the mechanic JSON's existing `view.scene` field (`assets/data/mechanics/<id>.json`, modular layout §5) names a presenter scene in `src/mechanics/<id>/` whose root holds a `StagingTree` with `rule_id = <id>`. `StagingHost` instances the default presenter for every rule in the level that has one and no override. Player-made levels (JSON only) get staging this way with no scene work.
- **Official levels:** the level scene `src/levels/<biome>/<id>/<id>.tscn` (root `LevelStage`) has a `Trees` node (`scene-build-sheets.md`). It may hold:
  - one story tree `<id>_events` (skits, mascot cues, story-grows presenter; `rule_id` empty), and
  - one override tree per mechanic (`rule_id` set). An override replaces that rule's default presenter.
- Biome characters are kit scenes reused across levels: `src/levels/_kit/staging/pip_presenter.tscn`, `miller_presenter.tscn`. A level places them under `Trees` and positions them with markers.
- Level JSON never names a tree, so data stays code-free (ADR-0005). The level maker (ADR-0017) picks atoms in a form. It doesn't author trees: those are attached in the official `.tscn` by the dev team.
- A scene check (test, below) fails when an override tree's `rule_id` is not in the level JSON's rules. It warns when a rule that emits `*_warn` / `*_due` events has neither a default presenter nor an override.
- A level with no `Trees` node and no presenters still plays: the sim, HUD and base board view are complete without staging.

### 9. Determinism and replay

- The sim's event list and `state_hash()` must be identical: (a) on a second replay of the same `{level_hash, round_seed, commands}`, (b) with and without a `StagingHost`, (c) with reduced motion on or off, (d) at any frame rate or catch-up count.
- Behaviours: `api.rng()` only (ADR-0006); candidates sorted canonically first (layer index along down, then x, then z); **no draw when `n ≤ 1`**; never iterate a Dictionary or a Set for a choice without sorting its keys; integer math only (fixed-point milli-units for scalars, ADR-0004 §3).
- The ban list for `src/core/**` and `src/mechanics/**` (except `src/mechanics/*/presenter/` and `*.tscn`): `extends Node`, `Node`, `signal`, `await`, `Time.`, `OS.`, `randi(`, `randf(`, `randomize(`, `RandomNumberGenerator.new(`, `beehave`, `Beehave`, `get_tree(`.
- `Replay` records sim inputs only. Staging is never recorded; re-running a replay re-creates the visuals from the events.

### 10. Test strategy (gdUnit4)

| Level | What | Where |
|---|---|---|
| [U] per atom | each behaviour through `FakeRuleApi`: the GDD's acceptance criteria per atom (e.g. WO11 1–7) | `tests/unit/mechanics/<id>_test.gd` |
| [U] sim order | P3 veto leaves counters unchanged; S4a before S4b; S4c runs once and only after an S4b write; S4b order ants → mushroom → belt from the rank table | `tests/unit/sim/resolve_sequence_test.gd` |
| [U] ranks | `rule_layers.json` loads; `mascot`/`perk` and `content`/`item_buff` ties break by tick, then id; unknown layer rejected | `tests/unit/rules/rule_rank_test.gd` |
| [U] determinism | each Meadow mix (02–10) run twice from one replay → identical events and `state_hash()`; a behaviour that changes state without `snapshot()` fails | `tests/unit/sim/mechanic_replay_test.gd` |
| [U] layering | the ban lists in sections 7 and 9 as a grep over source files | the layering test (`tests/unit/architecture/`) |
| [I] staging | a recorded event list (from `Replay`) fed to a `StagingHost` headless with stub presenters: the expected leaves run (Pip's leap starts on `mascot_catch`, the Miller sulks on `cells_cleared`); the sim's `state_hash()` with and without the host is identical | `tests/integration/staging/` |
| [I] level scenes | every official level scene loads headless; override `rule_id`s match its JSON | `tests/integration/levels/level_staging_test.gd` |
| [M] look | each presenter's key pose captured in play | screenshots in `production/qa/evidence/` (Visual/Feel stories) |

### Architecture Diagram

```
 level JSON (rules + params) ─▶ RuleRuntime ─▶ BoardSim.step()  (pure, 60 Hz, sim ms)
                                   │   P3 veto ─ S1 ─ S2 ─ S3 ─ S4a ─ S4b ─ S4c ─ S5..S10
                                   │   RuleBehaviours: mascot_catch · gust · flip · egg · ants · mill_belt
                                   │        └ only via RuleApi (writes, queries, rng, emit)
                                   ▼
                          Array[SimEvent]  (mascot_catch, gust_warn, flip_due, belt_windup, ...)
                                   │
                    BoardController ── sim_event(ev) ──┬─▶ BoardView · HUD · Audio
                                                       │
                                     StagingHost (PAUSABLE, _process, read-only SimReadout)
                                       │ bb.events / bb.latest / bb.reduced_motion ; tree.tick() ×1
                                       ▼
          LevelStage/Trees: <id>_events · pip_presenter · miller_presenter · overrides
          + default presenters from mechanics/<id>.json view.scene
                                       │ AnimationPlayer · tweens · skits · cues
                                       ✗ never writes back to the sim
```

### Key Interfaces

```gdscript
# core/rules (ADR-0004 additions)
class_name RuleBehaviour extends RefCounted
func snapshot() -> Dictionary: return {}            ## all mutable state; folded into state_hash()

class_name RuleApi extends RefCounted
func would_clear(cells: PackedVector3Array) -> bool
func new_covered_holes(cells: PackedVector3Array) -> int
func would_top_out(cells: PackedVector3Array) -> bool
func goal_would_meet(cells: PackedVector3Array) -> bool
func spawn_cells_free() -> bool                     ## current orientation
func return_piece_to_spawn(hold_ms: int) -> void    ## call before vetoing piece.lock
func set_piece_flag(flag: StringName, on: bool) -> void

# view/staging
class_name SimReadout extends RefCounted            ## getters only, wraps BoardSim
func get_board(board_id: int = 0) -> BoardState
func level_ms() -> int
func get_phase() -> int

class_name StagingHost extends Node
func bind(controller_signal: Signal, readout: SimReadout, presenters: Array[PackedScene]) -> void
func reset() -> void                                ## interrupt trees, clear blackboards
func play_skit(id: StringName) -> void
signal skit_finished(id: StringName)

class_name StagingTree extends BeehaveTree
@export var rule_id: StringName                     ## empty = level story tree
```

### Implementation Guidelines

- Every board-changing effect must be a `RuleBehaviour` or slot plugin in `src/mechanics/<id>/` with its JSON in `assets/data/mechanics/<id>.json`. Never put one in a tree, a presenter or a level script.
- A behaviour must announce in an event every decision the view has to show, with the window length in the event data.
- Behaviours must put all mutable state in `snapshot()`.
- Staging trees must use `StagingTree` (never a bare `BeehaveTree`) with `process_thread = MANUAL`, ticked only by `StagingHost`.
- Presenters must never hold gameplay numbers. Cosmetic values (pose speed, bob height) are presenter exports.
- One `StagingHost` per board. Versus boards (ADR-0009) may run with no presenters to save budget.

## Alternatives Considered

### Alternative 1: Beehave trees ticked from inside `BoardSim.step()`
- **Description**: The behaviour owns a tree and ticks it once per subscribed hook call; leaves act only through `RuleApi` (the GDD sketch, review option A).
- **Pros**: The designer's sketches become runnable trees; visual debugging in the beehave panel.
- **Cons**: `BeehaveTree` and every leaf are `Node`s that need a SceneTree, so the sim is no longer pure RefCounted, and headless unit tests need a scene. `tick()` reads `Time.get_ticks_usec()`, and the stock `Cooldown`/`Delayer`/random composites use wall time or global RNG. Tree state (`running_action`, blackboard) sits outside `state_hash()`.
- **Rejection Reason**: Breaks ADR-0001, and the user ruled on 2026-10-10 that beehave is staging only.

### Alternative 2: A small pure RefCounted behaviour-tree runtime in core
- **Description**: Our own Selector/Sequence/Condition/Action classes, ticked by the behaviour.
- **Pros**: Keeps the sketch shape; deterministic; testable.
- **Cons**: A second tree framework next to beehave. The Meadow atoms are 5–12 steps each, so a `match hook` block is shorter and easier to read.
- **Rejection Reason**: Not needed now. Revisit if a mascot decision (WO08 mood swing, a boss with many phases) grows past roughly 40 lines of branching. It would plug in behind `RuleBehaviour` with no interface change.

### Alternative 3: Level events as `SimCommand`s injected by a node-side director
- **Description**: A level script or tree decides "gust now" and pushes a command.
- **Pros**: Easy authoring in the scene.
- **Cons**: The decision runs on frame time; replays would need the director's commands, and versus results would depend on frame rate.
- **Rejection Reason**: Contradicts ADR-0001 and OQ 2.

### Alternative 4: No beehave; presenters as AnimationPlayer + signal scripts
- **Pros**: No third-party addon.
- **Cons**: Character presenters with idle, react, interrupt and skit branches turn into hand-written state machines. The user picked beehave for mascot and boss staging (plugin decision 2026-10-10).
- **Rejection Reason**: User choice. Simple presenters (a telegraph prop) may still be a plain script; `StagingTree` is required only when a tree is used.

## Consequences

### Positive
- One place for game logic: replay, versus and tests see every mechanic, and staging can be redone freely by art without touching the rules.
- Player-made levels get staging from default presenters with no code.
- The meadow_10 boss needs no boss system; it is three rules plus a presenter.
- The GDD's open questions 1, 2 and 6 are closed.

### Negative
- Designers' tree sketches must be translated by hand into `handle()` code. Mitigated: the sketches stay in the GDD as the logic spec, and each atom test follows its acceptance criteria.
- Every decision the view shows needs its own event kind, so the event vocabulary grows. Mitigated: event kinds are StringNames, and adding one needs no framework edit.
- `StagingTree` depends on beehave internals (`_get_global_debugger`). A beehave upgrade must re-check the override.

### Neutral
- `rule_layers.json` replaces the hardcoded ranks in GDD F2. The GDD should point to it.

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Beehave tree crashes in release because the debugger autoload is stripped | High if unhandled | High | `StagingTree` overrides; verification item 1 before CH-111 closes |
| A staging script writes to the sim | Medium | High | It never receives the sim (`SimReadout` only); layering grep test |
| Behaviour state missed from `snapshot()` hides a replay bug | Medium | Medium | Determinism test per Meadow mix; code review checklist |
| S4c makes a chain the designer didn't expect | Low | Medium | Runs once, `on_resolve_end` not re-run; unit test |
| Staging animation runs longer than the sim window (catch hold, flip warning) | Medium | Low | Windows come in event data; `PlayAnimation` clamps to the window |
| Staging cost on busy levels (meadow_10: belt, gust, flip, Pip, Miller) | Low | Medium | MANUAL ticks once per frame; budget below; profile meadow_10 |

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| mechanics-module.md (TR-mechanics-module-001) | ~90 atoms map to slot plugins, RuleBehaviours or content without core edits | Section 1 split; atoms are `RuleBehaviour`s with JSON; presenters found through `view.scene` |
| mechanics-module.md (TR-mechanics-module-009) | Mascot behaviours decide and act at runtime | `mascot` layer rank 1; decisions in the sim, shown by staging (sections 2, 5) |
| meadow-candidate-atoms.md §0.1, §0.2, §0.6, §0.7; Open Questions 1, 2, 6 (no TR ids registered yet) | S4a, S4c, ranks, tree convention, tree tick rate, RuleApi vs SimCommand | Sections 1–4 |
| meadow-candidate-atoms.md §7 (WO11) | Pip's catch at P3, hold, counters unchanged | Section 5 row, `return_piece_to_spawn`, resolve test |
| rule-twist-framework.md (TR-rule-twist-framework-004) | Hooks in ascending F2 priority, highest writes last | Rank table; S4b order |
| rule-twist-framework.md (TR-rule-twist-framework-007) | Each rule has its own seeded stream | `api.rng()` only; canonical sort; no draw when n ≤ 1 |
| rule-twist-framework.md (TR-rule-twist-framework-008) | Tick writes buffered; mask/down-axis changes in Resolving | S4a is the only structure step |
| rule-twist-framework.md (TR-rule-twist-framework-011) | Rule events reach the HUD within one frame | Same event path; `StagingHost` reads the same frame's batch |
| twist-library.md (TR-twist-library-002, -003, -005) | Gusts identical for one seed; telegraphs ahead of action; flip in Resolving | Section 5 gust/flip rows; section 6 telegraph contract; S4a |
| level-specific-mechanics.md (TR-level-specific-mechanics-001, -004) | Mechanic is layer 4 and beats everything; fixed sub-step order | `mechanic` rank 4; section 3 sequence (clear, flip, shift, spawn) |
| fall-drop-lock.md (TR-fall-drop-lock-003, -004) | Single per-lock sequence; no input during Resolving | Section 3, with P3/S4a/S4c added |
| game-feel-vfx.md (TR-game-feel-vfx-001, -005) | Presentation consumes events; reduced motion keeps timing | `StagingHost` event batch; reduced motion is staging-only |

## Performance Implications

- **CPU (sim)**: the new behaviours stay inside ADR-0004's 0.5 ms framework budget. Queries like `new_covered_holes` run only at P3, once per lock.
- **CPU (staging)**: ≤ 0.3 ms per frame for all trees on the flagship reference phone (meadow_10 worst case: 5 trees). One `tick()` per tree per frame; beehave metrics off in release.
- **Memory**: < 200 KB for trees and blackboards; presenter meshes and animations belong to the ADR-0007 / art budgets.
- **Load Time**: presenters load with the level scene (ADR-0010 threaded load); default presenters add one `PackedScene` per mechanic.
- **Network**: none. Versus sends commands/events (ADR-0009); staging is local.

## Migration Plan

Little code exists (`src/core/rules/rule_api.gd` is a stub, `src/core/rules/rule_def.gd` knows only `twist` and `mechanic`). Changes to existing docs and code, for their owners (not made by this ADR):
- ADR-0004 §2: add the rank table pointer (`rule_layers.json`); §5: `snapshot()`; §7: the new `RuleApi` queries and writes.
- `design/gdd/rule-twist-framework.md` F2: add `mascot` 1 and `content` 2; point to `rule_layers.json`.
- `design/gdd/fall-drop-lock.md` rule 15 and `layer-clearing.md` rule 1: P3, S4a, S4c.
- `design/gdd/meadow-candidate-atoms.md`: mark the tree sketches as logic specs (section 1) and close OQ 1, 2, 6.
- `production/levels/meadow/scene-build-sheets.md` "Beehave slot": trees are `StagingTree`s; per-mechanic trees are overrides of the default presenter.
- `docs/architecture/tr-registry.yaml`: point TR-mechanics-module-009 at ADR-0011.
- `src/core/rules/rule_def.gd`: read layers from `rule_layers.json`.

**Rollback plan**: staging is a leaf layer. Removing beehave means replacing `StagingTree`s with plain presenter scripts that read the same blackboard keys. The sim is not touched.

## Validation Criteria

- [ ] [U] WO11 acceptance criteria 1–7 pass in `tests/unit/mechanics/mascot_catch_test.gd`.
- [ ] [U] `resolve_sequence_test`: S4a before S4b; S4c runs once, only after an S4b write; a caught lock fires no `on_lock` and advances no counter.
- [ ] [U] `rule_rank_test`: S4b order ants → mushroom → belt; rank ties break by tick, then id.
- [ ] [U] `mechanic_replay_test`: every Meadow mix 02–10 gives identical events and `state_hash()` over two replays.
- [ ] [U] Layering grep test passes with the ban lists of sections 7 and 9.
- [ ] [I] `tests/integration/staging/`: the same replay with and without a `StagingHost` gives the same `state_hash()`; Pip's leap leaf starts on `mascot_catch`.
- [ ] [I] Every official Meadow level scene loads headless and its override `rule_id`s match its JSON.
- [ ] [M] Release export (PC and Android) with beehave autoloads stripped: meadow_02 plays a catch with Pip's leap, no errors in the log.
- [ ] [M] meadow_10 on the reference phone: staging ≤ 0.3 ms per frame (profiler capture in `production/qa/evidence/`).

## Related
- ADR-0001 (depends on: pure sim, lock veto), ADR-0004 (amends: ranks, `snapshot()`, `RuleApi` additions), ADR-0002 (content types `egg`, `chick`, `ant`, `sprout`), ADR-0005 (level JSON names rules only; validator rejects unknown layers), ADR-0006 (rule RNG), ADR-0007 (view consumes the same events), ADR-0009 (versus boards may run without presenters), ADR-0010 (`PlaySession` skits, pause, retry)
- ADR-0014 camera cues, ADR-0015 audio cues, ADR-0017 level maker (atoms only; trees in official scenes)
- `design/gdd/mechanics-module.md`, `design/gdd/meadow-candidate-atoms.md`, `design/gdd/rule-twist-framework.md`, `design/gdd/level-specific-mechanics.md`, `design/gdd/twist-library.md`, `design/gdd/fall-drop-lock.md`
- `production/levels/meadow/scene-build-sheets.md`, `production/levels/meadow/world-and-scenes.md`, `docs/architecture/architecture-modular-layout.md` §5
