class_name BoardSim extends RefCounted
## One player's play space, advanced one fixed tick at a time. Pure: no nodes, signals, Time, global RNG (ADR-0001).
## Usage: var sim := BoardSim.new(level, seed, catalog); sim.queue_command(cmd); var events := sim.step()

## Fixed ticks per second (ADR-0001 tunable default).
const SIM_HZ := 60
const MS_PER_SECOND := 1000

enum Phase { COUNTDOWN, WAITING, FALLING, RESTING, GRACE, RESOLVING, ENDED }

var _level: LevelData
var _seed: int
var _catalog: GameCatalog
var _tick: int = 0
var _phase: Phase = Phase.COUNTDOWN
var _queue: Array[SimCommand] = []
# ponytail: one reused array per ADR-0001 guideline; step() returns a copy.
var _events: Array[SimEvent] = []


func _init(level: LevelData, round_seed: int, catalog: GameCatalog) -> void:
	_level = level
	_seed = round_seed
	_catalog = catalog


## Queues a command; live input (tick <= now) applies next tick, future ticks (replay) are kept. Example: sim.queue_command(SimCommand.make(SimEvents.CMD_MOVE)).
func queue_command(cmd: SimCommand) -> void:
	if cmd.tick <= _tick:
		cmd.tick = _tick + 1
	_queue.append(cmd)


## Advances exactly one tick and returns that tick's events. Example: var ev := sim.step().
func step() -> Array[SimEvent]:
	_tick += 1
	_events.clear()
	_apply_commands()
	_run_tick_hooks()
	_travel_step()
	_lock_step()
	_resolve_step()
	_goal_step()
	return _events.duplicate()


## Ticks stepped so far.
func get_tick() -> int:
	return _tick


## Sim time in ms, integer division. Example: after 30 steps -> 500.
func now_ms() -> int:
	return ms_at(_tick)


## Current phase.
func get_phase() -> Phase:
	return _phase


## Time in ms at a given tick. Example: BoardSim.ms_at(61) == 1016.
static func ms_at(tick: int) -> int:
	return (tick * MS_PER_SECOND) / SIM_HZ


func _apply_commands() -> void:
	var rest: Array[SimCommand] = []
	for cmd in _queue:
		if cmd.tick == _tick:
			_emit(SimEvents.COMMAND_APPLIED, {"kind": cmd.kind, "args": cmd.args})
		else:
			rest.append(cmd)
	_queue = rest


## RUL-003 fills this.
func _run_tick_hooks() -> void:
	pass


## SIM-003 fills this.
func _travel_step() -> void:
	pass


## SIM-004 fills this.
func _lock_step() -> void:
	pass


## SIM-005 fills this.
func _resolve_step() -> void:
	pass


## SIM-006 fills this.
func _goal_step() -> void:
	pass


func _emit(kind: StringName, data: Dictionary) -> void:
	_events.append(SimEvent.make(_tick, kind, data))
