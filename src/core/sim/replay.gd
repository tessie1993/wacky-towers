class_name Replay extends RefCounted
## A recorded round: level hash, seed and every command with its tick (ADR-0001).
## Usage: replay.record(cmd) after BoardSim.queue_command(cmd); Replay.run(level, catalog, replay, ticks).

var level_hash: String = ""
var round_seed: int = 0
var commands: Array[SimCommand] = []


## Appends a copy of the command (tick already stamped by BoardSim.queue_command).
func record(cmd: SimCommand) -> void:
	commands.append(_copy(cmd))


## Re-simulates the log on a fresh BoardSim and returns all events in order. Example: Replay.run(level, catalog, r, 20).
static func run(level: LevelData, catalog: GameCatalog, replay: Replay, ticks: int) -> Array[SimEvent]:
	var sim: BoardSim = BoardSim.new(level, replay.round_seed, catalog)
	for c in replay.commands:
		sim.queue_command(_copy(c))
	var out: Array[SimEvent] = []
	for i in ticks:
		out.append_array(sim.step())
	return out


static func _copy(c: SimCommand) -> SimCommand:
	return SimCommand.make(c.kind, c.args.duplicate(true), c.tick)
