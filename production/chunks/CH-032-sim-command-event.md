# CH-032 SimCommand, SimEvent, SimEvents vocabulary

**Story:** SIM-001
**Goal:** the plain data that goes into and out of the sim (ADR-0001 "Commands in, events out").
**Depends:** none
**Parallel-safe with:** CH-026 … CH-031, CH-033, CH-034
**Files (new):** `src/core/model/sim_command.gd`, `src/core/model/sim_event.gd`, `src/core/sim/sim_events.gd`, `tests/unit/sim/sim_types_test.gd`

> Gap decision 5 (2026-10-10): `SimCommand` and `SimEvent` are plain value types in `src/core/model/` so `core/rules` and plugins can use them; `SimEvents` (vocabulary) stays in `core/sim`. If you already wrote them under `src/core/sim/`, move them (keep the `.uid` files with them).

## API

```gdscript
class_name SimCommand extends RefCounted
## One player input for one tick (ADR-0001).
var tick: int = 0
var kind: StringName = &""
var args: Array = []
static func make(kind: StringName, args: Array = [], tick: int = 0) -> SimCommand

class_name SimEvent extends RefCounted
## One thing that happened in the sim; plain data for view, audio, net (ADR-0001).
var tick: int = 0
var kind: StringName = &""
var data: Dictionary = {}
static func make(tick: int, kind: StringName, data: Dictionary = {}) -> SimEvent
func equals(other: SimEvent) -> bool      ## same tick, kind and data (data compared with ==); used by replay tests

class_name SimEvents extends RefCounted
## The one vocabulary of event and command kinds. Never write a kind string literal elsewhere.
```

`SimEvents` constants (all `const X := &"x"`):
- commands: `CMD_MOVE`, `CMD_ROTATE`, `CMD_SOFT_DROP_ON`, `CMD_SOFT_DROP_OFF`, `CMD_HARD_DROP`, `CMD_HOLD`, `CMD_TAP`
- events: `PHASE_CHANGED`, `COMMAND_APPLIED`, `PIECE_SPAWNED`, `PIECE_MOVED`, `PIECE_ROTATED`, `PIECE_BLOCKED`, `PIECE_LOCKED`,
  `CELLS_CHANGED`, `LAYERS_CLEARED`, `TOP_OUT_WARNING`, `CELLS_TRIMMED`, `GOAL_PROGRESS`, `GOAL_REACHED`, `LEVEL_FAILED`,
  `RULE_STARTED`, `RULE_ENDED`, `RULE_BLOCKED`, `CHAIN_DROPPED`, `KNOB_CLAMPED`
  (value = the lower-case name, e.g. `PIECE_LOCKED := &"piece_locked"`). Later stories append; never rename.

## Tests to write first (`sim_types_test.gd`)

1. `test_make_command` — `SimCommand.make(SimEvents.CMD_MOVE, [Vector3i(1,0,0)], 5)`: fields set.
2. `test_make_event_and_equals` — two `make(3, SimEvents.PIECE_LOCKED, {"cells": 4})` are `equals`; different tick / kind / data -> not.
3. `test_vocabulary_values_unique` — all constants of `SimEvents` (via `get_script_constant_map()`) are distinct StringNames.

## Run
`-a res://tests/unit/sim` (README).

## Done when
README "Done when" + 3 tests green.
