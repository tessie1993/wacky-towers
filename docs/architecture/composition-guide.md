# Composition guide for Wacky Towers

User, 2026-10-14: "help the agents make good architecture" (`/godot-composition`). This guide applies
`.claude/skills/godot-composition/SKILL.md` to this project. Every agent follows it, and the Godot
builder checks patches against it.

## Rules

1. **One script, one job.** Orchestrators wire components and hold no game logic.
2. **Signals go up, calls go down.** A component never reaches into its parent; there is no
   `get_parent()` in new code.
3. **Inject dependencies.** Use typed `@export`, `%UniqueName`, or `setup(...)` / `_init(...)`
   arguments. No absolute paths and no `$A/B/C` chains.
4. **Data is not a Node.** Logic packets and configs are `RefCounted` or `Resource` objects, read
   from `assets/data/*.json`. A Node is only for things that live in the tree: transform,
   `_process`, signals.
5. **Fail fast.** Components validate their dependencies in `_ready()` or `setup()` with
   `push_error` and `assert`.
6. **Add a feature by adding a component.** Never subclass to add behaviour, and keep inheritance
   to 2 levels or fewer.

## The layer cake

```
PRESENTATION  src/ui (GameUi, screens), src/view (WtStage and its view components)
LOGIC         src/core (BoardSim, Spawner, rule runtimes, GoalEvaluator, modules)
DATA          assets/data/*.json, level JSONs, Resources and RefCounted configs
INFRA         src/app/main.gd (app orchestrator), audio port, save, net
```

The presentation layer reads snapshots and events. It never mutates `BoardSim`. Logic emits events,
such as the sim events added on 2026-10-14 (combo, near-miss, danger, clear layers).

## WtStage is an orchestrator

`src/view/wt_stage.gd` should only **build and wire** view components and forward sim events to them.
Each concern is its own component class (RefCounted builder or Node3D), with `setup()` and
`build()` and no knowledge of WtStage:

| Component | Job | Status |
|---|---|---|
| `WtIslandBuilder` | slab, tiles and rim from the board mask | exists |
| `WtPropScatter` | dressing on the island top | exists |
| `WtWorldBackdrop` | sky, clouds, far islands, sea, fog | sandbox (awaiting user preview) |
| `WtLevelLook` | per-level time, weather, set piece, camera | exists |
| `WtPostProcess`, `WtSparkleFx` | post FX, bursts | exist |
| `WtSceneTerrain` *(new)* | terrain modules around the board: chasm, cliff, water, deck, shaft | phase 6 |
| `WtSetPieceActor` *(new)* | landmark that acts (catapult fires, kraken grabs); driven by sim events | phase 6 |
| `WtCastActor` *(new)* | hero, Wizard, NPC or villain on stage with idle, cheer, react and work states (component FSM) | phase 6 |
| `WtHudMeter` *(new, ui)* | themed meters (Heat, Fort HP, Altitude, Balance) from snapshot keys | phase 6 |

Event flow: `BoardSim` events go to `WtStage.on_sim_event(e)`, which fans out to the components that
subscribed by event id. Actors react; they never query the sim directly.

## Logic-side components for the campaign redo

- **Goal phases:** `GoalSequence` (RefCounted) holds an ordered list of `GoalEvaluator`s plus
  reveal and ending events. It drives the twist, reveal, guest and story endings from the
  level JSON `goal.phases[]`. It emits `goal_phase_changed`, `objective_revealed` and
  `level_ending(kind)`.
- **Bosses:** `BossComponent` (RefCounted) holds HP, phases (`active_after_clears`) and the
  damaging action from the handbook's closed list. The view's `WtSetPieceActor` listens to its events.
- **Minigame phases:** a `ModulePhaseRunner` hosts existing modules (span walker, bridge dash) as
  phases inside a level.
- **Headline objective:** a pure function from the level JSON plus goal state to the story text for the
  HUD. No "Clear N layers" strings.

## Refactors (from the Anara audit, production/qa/godot-analyst-2026-10-14.md)

- **`src/ui/game_ui.gd`** (2,600 lines): split into one class per screen under `src/ui/screens/`,
  each with `show(data)` and the existing `intent` signal re-emitted. `GameUi` becomes the screen
  router. Screen ownership stays with the UI agent.
- **`src/app/main.gd`** `_execute_intent` (cyclomatic 43): use a handler table
  (`Dictionary[StringName, Callable]`) plus mode controllers (Campaign, Tournament, Physics, Minigame).
  Stop rebuilding the HUD snapshot every tick; rebuild it on a sim event or when it is dirty.
- **Snapshots:** typed Resources, or typed Dictionaries at serialization boundaries only.
- **Remove** the `src/_staging` trees (with user approval).

## Patch checklist (the builder reviews against this)

- [ ] New behaviour is a new component, not a subclass and not a bigger orchestrator.
- [ ] No `get_parent()`, absolute paths or `$` chains. Dependencies are injected and validated.
- [ ] Data comes from JSON or Resources, and there are no magic numbers.
- [ ] Static typing everywhere. No `:=` from a Variant. StringName keys.
- [ ] No per-instance `material.duplicate()`, no `load()` in hot paths, no `_process` polling
      where an event would do.
- [ ] Public functions have `##` doc comments.
- [ ] `tools/build/check.sh` prints CHECK PASS.
