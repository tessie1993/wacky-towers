# CH-058 BoardController: fixed tick, intents to SimCommands, pending list

**MB task:** MB-032 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-154 (GameInput), CH-159 (rig), CH-035/064 (BoardSim)
**Files:** new `src/game/play/board_controller.gd` (`class_name BoardController extends Node`)

## API
```gdscript
class_name BoardController extends Node            ## PROCESS_MODE_PAUSABLE
signal events_emitted(events: Array[SimEvent])
signal level_finished(result: LevelResult)
var stepping: bool = false
func setup(sim: BoardSim, input: GameInput, rig: BoardCameraRig) -> void   ## connects the GameInput signals; sets input.set_enabled_axes from the level
func push_command(cmd: SimCommand) -> void          ## append to pending, never merge
func clear_pending() -> void
```

## Behaviour
- ADR-0012 §7 / ADR-0010: signals append to `_pending`; `_physics_process` (60 Hz) drains in order, stamps `tick = sim.get_tick()+1`, calls `sim.queue_command`, then `sim.step()` and emits `events_emitted`. Only when `stepping`. Never `await`.
- Resolution: `move(screen_dir)` -> `rig.snap.direction_map()[screen_dir]` -> `CMD_MOVE`; `rotate_piece(axis, dir)` -> `rig.snap.rotation_for(axis, dir)` -> `CMD_ROTATE`; soft drop on/off, hard drop. `view_rotate` goes to the rig directly, not the sim.
- Waiting buffer (100 ms = ceil(`control.input_buffer_ms`*60/1000) ticks): while `sim.get_phase()` is COUNTDOWN/WAITING keep ONE move-or-rotate slot `{cmd, press_tick}`; apply on the spawn tick if fresh, else drop. Hard drop and hold are discarded in Waiting.
- Pause hook: `pause()` calls `input.cancel_all()`, `clear_pending()`, `stepping=false`.

## How the integrator sees it working
Demo `src/dev/controller_demo.tscn` (sim + rig + piece/board views from CH-056/057): `project_run`, `input_simulate` keys: arrow moves the piece in screen directions at 2 different camera snaps (screen-left always moves screen-left), Q rotates, space hard-drops. `logs_read` shows commands stamped with increasing ticks. Press a move during the entry delay: the piece moves 1 cell right after spawn.

**Out of scope: PlaySession phases, HUD wiring, tick interpolation.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
