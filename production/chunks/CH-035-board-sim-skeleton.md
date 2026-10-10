# CH-035 BoardSim skeleton: clock, phases, command queue, step pipeline

**Story:** SIM-001
**Goal:** the deterministic tick loop with no gameplay yet (ADR-0001 "The clock", "Commands in, events out"). Later SIM stories fill the named steps.
**Depends:** CH-032, CH-034
**Parallel-safe with:** CH-026 … CH-031, CH-033
**Files (new):** `src/core/sim/board_sim.gd`, `tests/unit/sim/sim_clock_test.gd`, `tests/unit/sim/sim_command_queue_test.gd`

## API (subset of plan §1.2; the rest arrives with SIM-003+)

```gdscript
class_name BoardSim extends RefCounted
## One player's play space, advanced one fixed tick at a time. Pure: no nodes, signals, Time, global RNG (ADR-0001).
const SIM_HZ := 60                         # ADR-0001 tunable default
enum Phase { COUNTDOWN, WAITING, FALLING, RESTING, GRACE, RESOLVING, ENDED }

func _init(level: LevelData, round_seed: int, catalog: GameCatalog) -> void
func queue_command(cmd: SimCommand) -> void
func step() -> Array[SimEvent]             ## advances exactly one tick
func get_tick() -> int
func now_ms() -> int                       ## (tick * 1000) / SIM_HZ, integer division
func get_phase() -> Phase
static func ms_at(tick: int) -> int        ## same formula, for tests and deadlines
```

## Behaviour

- `_init`: store the three inputs; `_tick = 0`; `_phase = Phase.COUNTDOWN`. Do **not** read boards/knobs yet.
- `queue_command(cmd)`: if `cmd.tick <= _tick` stamp `cmd.tick = _tick + 1` (live input applies next tick); a future tick (replay) is kept. Append to `_queue`.
- `step()`: `_tick += 1`; `_events.clear()` (reuse one array, `ponytail:` per ADR-0001 guideline) — but return a **copy** (`_events.duplicate()`);
  then call, in this order, private steps that are empty for now, each with a one-line `##` naming its future story:
  `_apply_commands()` (this ticket), `_run_tick_hooks()` (RUL-003), `_travel_step()` (SIM-003), `_lock_step()` (SIM-004),
  `_resolve_step()` (SIM-005), `_goal_step()` (SIM-006).
- `_apply_commands()`: take every queued cmd with `tick == _tick`, in arrival order, remove them from the queue, and for each emit
  `SimEvent.make(_tick, SimEvents.COMMAND_APPLIED, {"kind": cmd.kind, "args": cmd.args})`. (Later stories dispatch on kind before this event.)
- `_emit(kind, data)` private helper appends to `_events`.

## Tests to write first

`sim_clock_test.gd` (build with `BoardSim.new(LevelData.new(), 1, GameCatalog.new())`):
1. `test_ms_at` — ticks 0, 1, 2, 29, 30, 60, 61 -> 0, 16, 33, 483, 500, 1000, 1016.
2. `test_sixty_ticks_is_one_second` — 60 steps -> `get_tick() == 60`, `now_ms() == 1000`.
3. `test_deadline_500_fires_on_tick_30` — step until `now_ms() >= 500`; the tick is 30.
4. `test_starts_in_countdown` — `get_phase() == Phase.COUNTDOWN`.

`sim_command_queue_test.gd`:
5. `test_command_applies_next_tick` — queue a move at tick 0 -> the first `step()` returns one COMMAND_APPLIED event with `tick == 1`.
6. `test_arrival_order_kept` — queue move, rotate, hard_drop before a step -> the three events in that order.
7. `test_future_tick_waits` — `SimCommand.make(CMD_MOVE, [], 5)` -> applied on the step that makes tick 5, not before.
8. `test_step_returns_copy` — events from step 1 unchanged after step 2.

## Run
`-a res://tests/unit/sim` (README).

## Done when
README "Done when" + 8 tests green; no `Node`, `Time`, `OS`, `await` in the file.
