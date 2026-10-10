class_name SimCommand extends RefCounted
## One player input for one tick (ADR-0001). Plain data; kinds live in SimEvents.

## Tick this command applies to.
var tick: int = 0
## Command kind, one of the SimEvents.CMD_* constants.
var kind: StringName = &""
## Kind-specific arguments.
var args: Array = []


## Builds a command. Example: SimCommand.make(SimEvents.CMD_MOVE, [Vector3i(1, 0, 0)], 5).
static func make(p_kind: StringName, p_args: Array = [], p_tick: int = 0) -> SimCommand:
	var c: SimCommand = SimCommand.new()
	c.kind = p_kind
	c.args = p_args
	c.tick = p_tick
	return c
