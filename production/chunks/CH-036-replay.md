# CH-036 Replay: same command log -> same events

**Story:** SIM-001
**Goal:** input replay for debugging and the determinism guarantee (ADR-0001 "The node side": `{level_hash, round_seed, commands[]}`).
**Depends:** CH-035
**Parallel-safe with:** CH-026 … CH-031
**Files (new):** `src/core/sim/replay.gd`, `tests/unit/sim/replay_test.gd`

## API

```gdscript
class_name Replay extends RefCounted
## A recorded round: level hash, seed and every command with its tick (ADR-0001).
var level_hash: String = ""
var round_seed: int = 0
var commands: Array[SimCommand] = []

func record(cmd: SimCommand) -> void        ## append a copy (tick already stamped by BoardSim.queue_command)
static func run(level: LevelData, catalog: GameCatalog, replay: Replay, ticks: int) -> Array[SimEvent]
	## fresh BoardSim(level, replay.round_seed, catalog); queue copies of all commands; step `ticks` times; all events in order
```

Copy commands (`SimCommand.make(c.kind, c.args.duplicate(true), c.tick)`) so replaying never mutates the log.

## Tests to write first (`replay_test.gd`)

1. `test_same_log_same_events` — live: a sim; at ticks 0, 3, 3, 10 queue move/rotate/move/hard_drop (call `queue_command` then `replay.record(cmd)`),
   step 20 times collecting events. `Replay.run(level, catalog, replay, 20)` -> same count and every pair `equals`.
2. `test_run_twice_identical` — two runs of the same replay give identical event lists.
3. `test_log_not_mutated` — after `run`, every `replay.commands[i].tick` is unchanged.

## Run
`-a res://tests/unit/sim` (README).

## Done when
README "Done when" + 3 tests green. SIM-001 complete.
