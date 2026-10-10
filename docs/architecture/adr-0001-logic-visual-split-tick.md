# ADR-0001: Logic/Visual Split and Tick Model

## Status

Accepted (2026-10-10, accepted by user)

## Date

2026-10-09

## Last Verified

2026-10-09

## Decision Makers

Tessa (user), godot-specialist (lead architect)

## Summary

Every board's game rules run in one pure `BoardSim` (RefCounted, no nodes, no awaits) advanced by a fixed 60 Hz tick whose clock is integer milliseconds, fed by a tick-stamped command queue and producing an event list. Nodes only read events and draw; the same sim runs headless in tests, in input replays, and as a library inside minigame scenes.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core / Scripting |
| **Layer** | Foundation |
| **Knowledge Risk** | MEDIUM — `_physics_process` and RefCounted are stable since 4.0; physics interpolation moved to SceneTree in 4.6 |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md`, `current-best-practices.md`, `modules/physics.md` |
| **Post-Cutoff APIs Used** | None in the sim. View may use physics interpolation (SceneTree-based since 4.6) |
| **Verification Required** | Verified 2026-10-09 headless on 4.7.2: `Engine.physics_ticks_per_second` defaults to 60; `physics/common/physics_interpolation` exists; `Node.reset_physics_interpolation()` and `Engine.get_physics_interpolation_fraction()` exist. Still to verify on an Android device: interpolation look on the falling piece. |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None |
| **Enables** | ADR-0002 (board), ADR-0004 (rules), ADR-0006 (RNG), ADR-0007 (rendering), ADR-0009 (multiplayer) |
| **Blocks** | Every gameplay story (fall, lock, clear, goals) |
| **Ordering Note** | Implement the tick clock and command queue before Fall/Drop/Lock |

## Context

### Problem Statement

The core rules (gravity steps, 500 ms lock delay, 150 ms grace, 200 ms entry delay, clears, goals) must be exact, testable headless, and identical whether drawn on a phone, run in a gdUnit test, or replayed for debugging. Twists, minigames and multiplayer all build on top. If rules live in nodes and `_process(delta)`, timing depends on frame rate and nothing can be tested without a scene.

### Current State

No gameplay code exists (`src/dev/` holds only a block-set preview).

### Constraints

- GDScript only for now; C++ GDExtension later only when profiling demands it (ADR-0008).
- Mobile renderer, Android first; frame rate may drop below 60.
- Each phone simulates only its own board; no lockstep (Local Multiplayer GDD rule 2).
- Physics Mode needs Jolt rigid bodies, which live in the scene tree.

### Requirements

- All GDD timers are integer ms and must fire on the same tick every run for the same inputs.
- Same seed + same command log on one device = same game (input replay, user decision round 2).
- Sim is unit-testable without a SceneTree.
- Minigame scenes can reuse the sim parts as a library.

## Decision

### The sim

- `BoardSim extends RefCounted` owns one **player's play space**: one or more boards (islands, lanes; ADR-0002 section 7) and their rule state: board (ADR-0002), active piece, spawner, rule runtime (ADR-0004), goal state, RNG streams (ADR-0006). No `Node`, no signals, no `await`, no `Time`/`OS` calls, no global RNG.
- Dependencies are injected at construction: `BoardSim.new(level: LevelData, round_seed: int, catalog: GameCatalog)`.

### The clock

- Fixed rate `SIM_HZ = 60` (tunable default; a sim constant, not tied to the display).
- The sim counts ticks. Sim time is derived, never accumulated: `now_ms(tick) = (tick * 1000) / SIM_HZ` (integer division). Tick lengths come out as 16/17 ms and 60 ticks are exactly 1000 ms, so there is no drift.
- Timers store a **deadline in ms** (`lock_deadline_ms = now_ms + lock_delay_ms`) and fire on the first tick where `now_ms >= deadline`. A timer copies its knob value when it starts (Rule-Twist GDD rule 7).
- Gravity: `g_milli` is in milli-cells per second; step interval `= 1_000_000 / g_milli` ms (integer division), computed when each step is scheduled.
- Pause, warnings and app backgrounding stop ticking; the sim has no wall clock.

### Commands in, events out

- Input is turned into `SimCommand {tick, kind: StringName, args}` (move, rotate, soft_drop_on/off, hard_drop, hold, plus network-received attacks). Commands are queued with the tick they apply on (the next tick) and applied in arrival order at the start of that tick.
- `BoardSim.step()` runs one tick: apply commands → rule `on_tick` hooks → gravity/travel step → lock → resolve (clear strategy, collapse) → goal check → append `SimEvent`s.
- **Lock veto** (2026-10-10, implementation plan): before writing cubes the sim asks `can(&"piece.lock", ...)`. If a rule vetoes it after calling `RuleApi.return_piece_to_spawn()`, the piece returns to its spawn origin in its current orientation with the gravity clock reset (mascot catch, WO11).
- Events are plain data: `SimEvent {tick, kind: StringName, data: Dictionary}` (`piece_spawned`, `piece_moved`, `piece_locked`, `cells_cleared`, `rule_started`, `rule_blocked`, `goal_reached`, …). `step()` returns the tick's events; the sim keeps no listeners.
- **Resolving has a duration from data**, not from animations: the sim stays in Resolving for `t_resolve_ms` (Layer Clearing) and the view plays its animation in that window. The sim never waits for the view.

### The node side

- `BoardController extends Node` (one per `BoardSim`, i.e. per player) calls `sim.step()` in `_physics_process`, at most `max_catch_up_ticks` (default 4) per frame, then re-emits events as typed Godot signals for the view (ADR-0007), HUD, audio and network (ADR-0009).
- Views read sim state read-only through getters and the events; they never write to it.
- Controller can record `{level_hash, round_seed, commands[]}` for **input replay** (debug, same device). Replaying feeds the log into a fresh `BoardSim`.

### Direction of travel (6 gravity directions)

- The board has a down axis in any of 6 directions (ADR-0002 owns storage). The active piece has its own **travel direction**, defaulting to board down; the `spawn.entry` strategy (ADR-0004) may set it for side arrivals. A fall step moves the piece one cell along its travel direction. This keeps "falls sideways forever" and "enters from the side then falls down" both as data choices.

### Exceptions

- **Physics Mode** (Alpha): `PhysicsBoard` uses Jolt bodies in the scene, so it is not a pure sim. It accepts the same `SimCommand`s and emits the same `SimEvent` kinds where they apply. Not deterministic; fine, since no lockstep is needed.
- **Minigames** are separate scenes (user decision round 2). They reuse `BoardState`, `ShapeBank`, `Orientations`, `Seeds` and, where useful, `BoardSim` as a library, but own their own loop. They should still drive any grid logic from a fixed tick.

### Architecture

```
 Touch / Net ──SimCommand(tick)──▶ BoardController (Node, _physics_process)
                                       │ step() ×N (fixed 60 Hz)
                                       ▼
                          BoardSim (RefCounted, pure)
            BoardState · Piece · Spawner · RuleRuntime · Goals · Seeds
                                       │ Array[SimEvent]
                                       ▼
                          BoardController re-emits signals
                 ┌──────────────┬───────────┬──────────┬─────────┐
               BoardView       HUD        Audio      NetSync   ReplayRecorder
```

### Key Interfaces

```gdscript
class_name BoardSim extends RefCounted
func _init(level: LevelData, round_seed: int, catalog: GameCatalog) -> void
func queue_command(cmd: SimCommand) -> void
func step() -> Array[SimEvent]          # advances exactly one tick
func get_tick() -> int
func now_ms() -> int                    # (tick * 1000) / SIM_HZ
func get_board(board_id: int = 0) -> BoardState  # read-only use by views; several boards per level (ADR-0002 s7)
func state_hash() -> int                # board, queue, active rules, RNG states; replay checks and ADR-0009 checkpoints
func progress() -> Dictionary           # cheap snapshot for mini-boards (ADR-0009)

class_name SimCommand extends RefCounted
var tick: int
var kind: StringName
var args: Array

class_name SimEvent extends RefCounted
var tick: int
var kind: StringName
var data: Dictionary
```

### Implementation Guidelines

- Tests drive `BoardSim` directly: queue commands, call `step()` N times, assert events/state. No scene, no `await`.
- Use `now_ms()` deadlines everywhere; never subtract `delta` from a float timer.
- **Integer-only gameplay math.** Scalar knobs are fixed-point milli-units (`gravity_scale` 1000 = x1.0, ADR-0004); JSON authors write decimals and the loader converts once. Same-device replay is the tested guarantee; integer math also keeps cross-device re-simulation possible later (ADR-0009).
- Keep `step()` allocation-light: reuse the event array where possible (`ponytail:` until profiling says otherwise).

## Alternatives Considered

### Alternative 1: Rules in nodes with `_process(delta)`
- **Pros**: Familiar Godot style, less plumbing.
- **Cons**: Frame-rate dependent timers, untestable without scenes, no replay.
- **Rejection Reason**: Breaks determinism and headless testing.

### Alternative 2: Float accumulated timers in a fixed step
- **Pros**: Simple.
- **Cons**: Drift (16.666… ms steps), timers fire a tick early/late depending on accumulation.
- **Rejection Reason**: Integer deadlines are just as simple and exact.

### Alternative 3: Sim emits Godot signals directly
- **Pros**: No re-emit layer.
- **Cons**: Sim becomes an Object with listeners; listener order and re-entrancy leak into rules.
- **Rejection Reason**: Plain event lists keep the sim pure and order explicit.

### Alternative 4: Sim awaits view animations
- **Rejection Reason**: Headless tests would hang; rules would depend on animation length.

## Consequences

### Positive
- Exact timing, headless tests, debug replays, reuse by minigames and C++ later (a hot path can move behind the same interface).

### Negative
- An extra controller/event layer; view needs interpolation for smooth motion between ticks.

### Neutral
- Input latency is at most one tick (≤ 17 ms).

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Slow phone drops frames → many catch-up ticks | Medium | Medium | `max_catch_up_ticks`; profile; move hot paths to C++ (ADR-0008) |
| A rule behaviour reads wall time or global RNG | Medium | High | Code review + grep test banning `Time.`, `randi()`, `randf()` in `src/core` and `src/gameplay` |
| View animations longer than `t_resolve_ms` | Medium | Low | View clamps to the sim's Resolving window |

## Performance Implications

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| CPU (frame time) | 0 | < 1 ms sim per tick, GDScript | 2 ms sim + rules on reference phone |
| Memory | 0 | < 1 MB per board | 4 MB |
| Load Time | — | negligible | — |
| Network | — | n/a (ADR-0009) | — |

## Migration Plan

None — new code.

**Rollback plan**: The sim/view boundary is the event list; a node-based fallback could consume the same events.

## Validation Criteria

- [ ] Unit test: lock delay 500 ms fires on tick 30 after rest (`now_ms` 500); 60 ticks = 1000 ms exactly.
- [ ] Unit test: same seed + same command log → identical event list (replay).
- [ ] Unit test runs `BoardSim` with no SceneTree.
- [x] Verified on 4.7.2 (headless, 2026-10-09): tick default 60, physics-interpolation setting and methods present.

## GDD Requirements Addressed

| GDD Document | System | Requirement | How This ADR Satisfies It |
|-------------|--------|-------------|--------------------------|
| `design/gdd/fall-drop-lock.md` | Fall, Drop & Lock | Lock delay 500 ms, grace 150 ms, entry delay 200 ms; timers pause with the game | Integer-ms deadlines on a fixed tick; pause stops ticking |
| `design/gdd/rule-twist-framework.md` | Rule-Twist | Running timer keeps its start value (rule 7); `on_tick` hook | Timer copies knob at start; `on_tick` runs each step |
| `design/gdd/piece-spawner-queue.md` | Spawner | Replaying the same seed gives the same game | Pure sim + command log |
| `design/gdd/local-multiplayer-setup.md` | Multiplayer | Each device simulates its own board; no lockstep | Sim per board; network sends commands/events only |
| `design/gdd/layer-clearing.md` | Layer Clearing | Clear/collapse animation time `t_resolve` | Resolving duration from data; view animates inside it |
| `design/gdd/physics-mode.md` | Physics Mode | Rigid bodies on Jolt | Named exception: `PhysicsBoard` with same command/event contract |
