class_name SimCommand extends RefCounted
## One player input for one tick (ADR-0001). Usage: SimCommand.make(SimEvents.CMD_HOLD, [], 12).

var tick: int = 0
var kind: StringName = &""
var args: Array = []


## Builds a command. Usage: SimCommand.make(SimEvents.CMD_MOVE, [Vector3i(1, 0, 0)], 5).
static func make(p_kind: StringName, p_args: Array = [], p_tick: int = 0) -> SimCommand:
	var c: SimCommand = SimCommand.new()
	c.kind = p_kind
	c.args = p_args
	c.tick = p_tick
	return c
