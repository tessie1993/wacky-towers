# ADR-0004: Rule-Twist Runtime (Hooks, Knob Registry, Priority/Veto, Strategy Slots, Plugin Registry)

## Status

Proposed

> Who may move this to `Accepted`: the user, or `technical-director` on the user's explicit confirmation.

## Date

2026-10-09

## Last Verified

2026-10-10

## Decision Makers

Tessa (user), godot-specialist (lead architect). Standing instruction (2026-10-09): build modular, hardcode as little as possible, plug behaviours in through registries.

## Summary

All rule changes (twists, level mechanics, items, buffs, perks, status effects, obstacles) run through one per-board `RuleRuntime` made of a data-driven **knob registry** (effective values per GDD F1), an ordered **hook pipeline** (priority per GDD F2), **vetoes**, and **strategy slots** that swap whole sub-behaviours (clear rule, collapse, arrival style, goal, top-out, board kind). Behaviours and strategies are GDScript classes found through a **plugin registry** by id, and their data lives in JSON, so adding a new twist, clear rule or arrival style never edits core code.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core / Scripting |
| **Layer** | Core |
| **Knowledge Risk** | MEDIUM — typed `Dictionary[K, V]` (4.4+) and `ProjectSettings.get_global_class_list()` must be confirmed on 4.7.2 including exported Android builds |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `current-best-practices.md`, `deprecated-apis.md`, `breaking-changes.md` |
| **Post-Cutoff APIs Used** | Typed Dictionary (4.4); `@abstract` (4.5) optional for base classes |
| **Verification Required** | `get_global_class_list()` returns `class_name` scripts in an exported Android build. Verified 2026-10-09 on 4.7.2: typed `Dictionary[StringName, Variant]` works (also as `@export`); JSON output must be converted with `typed.assign(parsed)` (direct assignment fails at runtime). |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (tick, events), ADR-0002 (board write API), ADR-0005 (JSON data, validator), ADR-0006 (rule RNG streams) |
| **Enables** | Twist Library, Level-Specific Mechanics, Obstacles, Status Effects, Items, Buffs, Perks, Skills, Physics Mode, campaign variety |
| **Blocks** | Every twist/mechanic story (meadow_03 onward) |
| **Ordering Note** | The knob registry is needed from the first playable (meadow_01 reads base knobs through it); hooks and slots follow |

## Context

### Problem Statement

The game's promise is variety on constant blocks: wind, gravity flips (all 6 directions), invisible blocks, side arrivals, row/colour/colour-connect clears, cascade vs slice, trim top-out, conveyors, and 15+ minigames. The Rule-Twist GDD defines rules with layers, scopes, lifetimes, modifiers, hooks and vetoes. If each mechanic edits core systems, they collide and every new idea touches the core.

### Constraints

- Rule behaviours are GDScript only (user decision Q5).
- Player-made levels are untrusted JSON: they may name rules and parameters, never code (ADR-0005).
- Framework budget ≤ 0.5 ms/frame on the reference phone with 2 twists, 1 mechanic, 4 items/buffs (GDD).
- Determinism for the same seed and command log on one device (ADR-0001).

### Requirements

- GDD F1 effective values, F2 priority, F3 budget, F4 lifetimes, rule 7 (running timers keep their value), rule 10 (`max_hook_depth`), rule 11 (veto wins on tie), rule 14 (deferred board writes), rules 13/edge cases (mask/down-axis only during Resolving).
- New mechanics of a new **kind** (not just a new number) must plug in without core edits.

## Decision

### 1. Plugin registry (how code is found)

- `PluginRegistry` builds, once at startup, a map `kind → (plugin_id → Script)` from `ProjectSettings.get_global_class_list()`: every `class_name` script whose base chain reaches a plugin base class is registered under its `const PLUGIN_ID: StringName`.
- Plugin base classes (the only extension points core code knows):

| Base class | Kind | Examples |
|---|---|---|
| `RuleBehaviour` | rule behaviours | wind, drift, spawned objects, invisible, conveyor, bomb, burning |
| `ClearDetector` | slot `clear.detector` | layer (default), row, colour, colour_connect |
| `CollapsePolicy` | slot `clear.collapse` | slice (default), cascade, none |
| `ArrivalStyle` | slot `spawn.arrival` | top (default), side_then_fall, side_travel |
| `GoalEvaluator` | slot `goal.type` | clear_n, height, shape, survive, timed |
| `TopOutPolicy` | slot `goal.top_out` | warnings (default), trim, lose |
| `BoardKind` | slot `board.kind` | grid (default), physics (Alpha) |
| `LayoutKind` | `layout.kind` (level data, fixed at start) | single (default), islands, lanes, track; places and links the boards of ADR-0002 section 7 |
| `PieceRouter` | slot `spawn.router` | which board/lane the next piece enters: active (default), player_choice, round_robin, track_follow |
| `StandingFn` | minigame/round data | item-roll standing per minigame (ADR-0009) |
| `ControlVerb` | slot `control.verb` | what the player's input does: piece (default: move/rotate/drop the falling piece), swap, tap_pop, pull_replace, chisel, tube_move, board_slide, tray_place. Turns touch gestures into `SimCommand`s and applies them through `RuleApi` |

- Duplicate `PLUGIN_ID` within a kind is a startup error (and a test failure).
- If `get_global_class_list()` proves unreliable in exports, fallback: a generated `res://assets/data/plugins.json` written by a tool script and checked by a test. Same registry interface.

### 2. Rule data (how values are found)

- Each rule is a JSON file `res://assets/data/rules/<rule_id>.json` (internal, trusted): `rule_id`, `layer`, `icon`, `name`, `params` schema (`type`, `min`, `max`, `default` per param), `modifiers` (knob operations), `vetoes`, optional `behaviour` (a `RuleBehaviour` plugin id), `lifetime`, `incompatible_with`.
- **Mechanic atoms** (`design/gdd/mechanics-module.md`, ~90+ atoms in the slots Board/Layout, Arrival, Control Verb, Placement, Clear, Collapse, Goal, Fail, Scoring, Interaction, Events, Special pieces) map onto this ADR with no new concept: a slot atom is a plugin of that slot's base class; Placement, Scoring, Interaction, Events and Special-piece atoms are `RuleBehaviour`s (scoring needs no slot) or content types (ADR-0002). Each atom carries **compatibility tags** in its JSON/plugin metadata: `requires` and `provides` from a tag vocabulary (`grid`/`phys`, `fall`/`nofall`, `clr`/`noclr`, `col`, `rect`, `turn`/`rt`, …) kept in `res://assets/data/atom_tags.json`. The validator (ADR-0005) rejects a level or generated mix where an atom's `requires` is not provided by the chosen board kind, layout and slots, or where two atoms carry conflicting tags (the pairs list in `atom_tags.json`). `incompatible_with` stays for one-off exceptions.
- **Shared-board atoms are parked**: minigames are always competitive (one board per player). Nothing here prevents adding them later.
- A rule that only changes numbers or forbids actions needs **no code** — modifiers and vetoes are data.
- Levels (ADR-0005) reference rules by `rule_id` with parameter values; the validator checks them against the schema.

### 3. Knob registry

- Knob definitions are data: `res://assets/data/knobs/<system>.json`, one per owning core system: `id` (`fall.lock_delay_ms`), `type` (`scalar`, `count`, `flag`, `choice`, `structure`, `slot`), `default`, `min`, `max`, `allows_zero`, `rule_adjustable`, `choices` (for choice/slot).
- **Fixed point:** `scalar` knobs are stored as integer milli-units (1000 = 1.0). JSON may write decimals; the loader converts once with `roundi(x * 1000)`. F1 multiplies as `v = v * m / 1000` per multiplier, in priority order, so results are integer and identical everywhere.
- Per board, `KnobRegistry` resolves: level override → base; then active rule modifiers per GDD F1 (highest-priority `set`, then Π multipliers or Σ adds, then clamp). Clamps are logged.
- Effective values are cached and recomputed only when a rule starts, ends or changes. Reads are dictionary lookups.
- Timers copy the value when they start (ADR-0001), satisfying GDD rule 7.
- Core code reads knobs by id; it never holds a hardcoded tuning number.

### 4. Strategy slots

- A **slot** is a knob of type `slot`; its value is a plugin id of the matching base class. `RuleRuntime.slot(&"clear.detector") -> ClearDetector` returns the instance.
- Levels set a slot's base value; rules may `set` it (normal F2 priority: a level mechanic beats a twist).
- A slot change takes effect at the next Resolving (same rule as mask/down-axis changes), so a strategy is never swapped mid-step. `board.kind` is fixed at level start.
- Strategies are `RefCounted`, receive the same `RuleApi` facade, read their params from knobs, and keep no hidden global state.

### 5. Hook pipeline

- Hooks are `StringName`s. Core hooks (GDD rule 8): `on_level_start`, `on_spawn`, `on_tick`, `on_fall_step`, `on_lock`, `on_clear`, `on_resolve_end`, `on_top_out`, `on_goal_check`. Added for flexibility: `on_command` (before a player command), `on_piece_enter` (arrival finished), `on_enter` (a piece locks into a cell holding non-solid content, before it is displaced; ADR-0002), `on_attack_received` (multiplayer).
- Anyone (a strategy, a new system) may call `runtime.run_hook(name, ctx)` with a new hook name; adding a hook needs no framework edit.
- Each `RuleBehaviour` lists `subscribed_hooks()`. The runtime keeps, per hook, subscribers sorted **ascending** by F2 key `(layer_rank, activated_tick, rule_id)` so the highest-priority rule writes last and wins. The list is rebuilt only when rules start or end.
- Dispatch: `behaviour.handle(hook, ctx, api)` — one typed method, no string `call()`.
- Depth counter: a hook run from inside a hook increments depth; beyond `rules.max_hook_depth` (knob, default 4) the call is dropped and a `rule_chain_dropped` event logged.

### 6. Vetoes

- `api.can(action: StringName, requester_rank: int, ctx) -> VetoResult`. A data veto (`{"action": "clear.layer", "when": {...}}`) or a behaviour's `veto(action, ctx)` applies if its rule's priority ≥ requester's (tie: veto wins). The result names the vetoing rule so the HUD can show its icon (`rule_blocked` event).
- Action names are dotted StringNames (`rotate.tilt`, `clear.layer`, `spawn.piece`, `board.write`); new actions need no framework edit.

### 7. RuleApi facade

The only object behaviours and strategies get. Board content writes (`set_cell`, `clear_cell`, `move_cells`), `request_mask`/`request_down_axis`/`request_slot` (queued to Resolving), piece `try_translate`/`place_nearest_up`/`replace_shape`/`set_travel_dir`, queue `inject_front`/`add_to_next_bag`, goals `add_condition`, `emit(kind, data)` for visuals/audio, `knob(id)`, `param(name)`, and `rng()` (the rule's own stream, ADR-0006). Writes from `on_tick`/`on_fall_step` are buffered and applied at end of tick in priority order (GDD rule 14). No behaviour holds a reference to `BoardSim` internals.

### 8. Rule instances and lifetimes

`RuleInstance {def, params, scope, layer_rank, activated_tick, state (Pending/Active/Suspended/Expired), remaining_ms, remaining_pieces}`. The runtime ticks lifetimes per GDD F4, suspends duration clocks in pause/warning/Resolving, and emits `rule_started`/`rule_ended`.

### 9. Minigames

Minigames are separate scenes (user decision Q2), found through `assets/data/minigames/<id>.json` (`scene`, `min_players`, `standing` types, weights). They may create their own `RuleRuntime` and `BoardSim`, or none. The framework does not constrain them.

### Architecture

```
 assets/data/knobs/*.json   assets/data/rules/*.json      level.json (ADR-0005)
            │                        │                          │
            ▼                        ▼                          ▼
       KnobRegistry ◀──modifiers── RuleRuntime ◀──rule refs + params
            ▲                  │       │         │
     knob(id) reads            │  hooks/vetoes   │ slots
            │                  ▼       ▼         ▼
   Core systems (BoardSim) ── run_hook ──▶ RuleBehaviour / ClearDetector /
                                           CollapsePolicy / ArrivalStyle /
                                           GoalEvaluator / TopOutPolicy / BoardKind
                                                 │ only via RuleApi
                                                 ▼
                                   BoardState, Piece, Spawner, Goals, rng
           PluginRegistry (global class list, PLUGIN_ID) ── maps ids → scripts
```

### Key Interfaces

```gdscript
@abstract class_name ControlVerb extends RefCounted
## Touch gestures in, SimCommands out; applies them through RuleApi on the tick.
@abstract func commands_for(gesture: Dictionary, api: RuleApi) -> Array[SimCommand]
@abstract func apply(cmd: SimCommand, api: RuleApi) -> void
func tags() -> PackedStringArray: return []     # compatibility tags (requires/provides)
```

```gdscript
@abstract class_name RuleBehaviour extends RefCounted
func subscribed_hooks() -> Array[StringName]: return []
func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void: pass
func veto(action: StringName, ctx: HookContext, api: RuleApi) -> bool: return false

@abstract class_name ClearDetector extends RefCounted
@abstract func find_clears(board: BoardState, api: RuleApi) -> Array[ClearGroup]

@abstract class_name ArrivalStyle extends RefCounted
@abstract func plan_arrival(shape: ShapeDef, board: BoardState, api: RuleApi) -> ArrivalPlan
# ArrivalPlan: spawn cells, orientation, travel_dir (any of 6), when to switch to board down

class_name RuleRuntime extends RefCounted
func activate(def_id: StringName, params: Dictionary, scope: int) -> RuleInstance
func expire(inst: RuleInstance) -> void
func knob(id: StringName) -> Variant
func slot(id: StringName) -> RefCounted
func run_hook(hook: StringName, ctx: HookContext) -> void
func can(action: StringName, requester_rank: int, ctx: HookContext) -> VetoResult
```

### Implementation Guidelines

- Every plugin script: `class_name`, `const PLUGIN_ID := &"..."`, extends exactly one plugin base. No other registration step.
- Each plugin gets its own test in `tests/unit/rules/` (or `tests/unit/gameplay/`), driving it through a fake `RuleApi`.
- No `randi()`/`randf()`/`Time` in plugins; use `api.rng()` and `api.now_ms()`.
- Profile with 2 twists + 1 mechanic + 4 buffs; if over 0.5 ms, cache per-hook subscriber arrays harder before considering C++.

## Alternatives Considered

### Alternative 1: Godot signals as hooks
- **Cons**: Connection order is not priority order; no veto return; re-entrancy hard to bound.
- **Rejection Reason**: GDD F2 and veto rules need explicit ordering.

### Alternative 2: Branches in core (`if twist == WIND`)
- **Rejection Reason**: Every mechanic touches core; violates the modular principle.

### Alternative 3: Rules only (no strategy slots)
- **Cons**: Colour clears or side travel expressed as hooks fighting the default logic.
- **Rejection Reason**: Swapping the whole sub-behaviour is simpler and clearer.

### Alternative 4: Rule data as `.tres` with embedded scripts
- **Rejection Reason**: Same file type as untrusted content risks; JSON + code registry keeps data and code apart (ADR-0005).

### Alternative 5: Hand-maintained registry file listing every plugin
- **Cons**: One more file to edit per plugin; merge conflicts.
- **Rejection Reason**: Kept only as fallback if the global class list fails in exports.

## Consequences

### Positive
- New twist with only number changes = one JSON file + icon. New behaviour = one script + one JSON. New clear rule / arrival / goal / top-out = one script.

### Negative
- Indirection: debugging needs good logging (`rule_started`, `rule_blocked`, clamp logs).

### Neutral
- Knob ids become a shared vocabulary across GDDs; the "rule-adjustable knob list" open question in the GDD is answered by the knob JSON files.

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Global class list missing in Android export | Low | High | Fallback generated `plugins.json`; verify on first Android export |
| Framework over 0.5 ms budget | Medium | Medium | Cached sorted subscribers; profile; C++ path for hot strategies (ADR-0008) |
| Two slots conflict (e.g. physics board + colour clear) | Medium | Low | `incompatible_with` and per-slot compatibility in validator |
| Behaviour mutates state outside `RuleApi` | Medium | High | Code review; behaviours never receive `BoardSim` |

## Performance Implications

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| CPU (frame time) | — | ~0.1–0.3 ms typical | 0.5 ms (GDD) |
| Memory | — | < 1 MB | 2 MB |
| Load Time | — | registry build + JSON parse | < 100 ms |

## Migration Plan

None — new code.

**Rollback plan**: Slots and hooks are independent; either can be removed without losing the knob registry.

## Validation Criteria

- [ ] GDD acceptance criteria 1–17 and 19 as unit tests in `tests/unit/rules/`.
- [ ] Adding a test-only `ClearDetector` plugin in `tests/` makes it selectable by id with no other edit.
- [ ] Stack test: wind + spawned objects + conveyor (meadow_10) runs ≤ 0.5 ms per frame on the reference phone.
- [ ] `get_global_class_list()` finds plugins in an Android export.

## GDD Requirements Addressed

| GDD Document | System | Requirement | How This ADR Satisfies It |
|-------------|--------|-------------|--------------------------|
| `design/gdd/rule-twist-framework.md` | Rule-Twist | Rules 1–17, F1–F4 | Knob registry, hook pipeline, vetoes, lifetimes |
| `design/gdd/rule-twist-framework.md` | Rule-Twist | Open question: rule-adjustable knob list | `assets/data/knobs/*.json` with `rule_adjustable` |
| `design/gdd/rule-twist-framework.md` | Rule-Twist | Open question: scripted actions language/sandbox | GDScript `RuleBehaviour` through `RuleApi`; data cannot name code |
| `design/gdd/level-specific-mechanics.md` | Level Mechanics | M1–M4 contradict base rules at layer 4 | Data sets/vetoes + `on_resolve_end` behaviour (conveyor) |
| `design/gdd/layer-clearing.md` | Layer Clearing | `clear_enabled`, slice vs cascade | `clear.detector`, `clear.collapse` slots |
| `design/gdd/level-goals-fail-states.md` | Goals | Per-level top-out, goal types | `goal.type`, `goal.top_out` slots (trim per round-2 decision) |
| `design/gdd/twist-library.md` | Twist Library | Wind, gravity flip, invisible, spawned objects | Behaviours + `request_down_axis` (6 directions) |
| `design/gdd/physics-mode.md` | Physics Mode | Replaces Movement, Fall, Clearing for a level | `board.kind` slot |
