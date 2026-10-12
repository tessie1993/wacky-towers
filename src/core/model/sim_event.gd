class_name SimEvent extends RefCounted
## One thing that happened in the sim; plain data for view, audio, net (ADR-0001).

## Tick the event happened on.
var tick: int = 0
## Event kind, one of the SimEvents constants.
var kind: StringName = &""
## Kind-specific payload.
var data: Dictionary = {}


## Builds an event. Usage: SimEvent.make(3, SimEvents.PIECE_LOCKED, {"cells": 4}).
static func make(p_tick: int, p_kind: StringName, p_data: Dictionary = {}) -> SimEvent:
	var e: SimEvent = SimEvent.new()
	e.tick = p_tick
	e.kind = p_kind
	e.data = p_data
	return e


## True when tick, kind and data (compared with ==) all match. Usage: a.equals(b).
func equals(other: SimEvent) -> bool:
	return other != null and tick == other.tick and kind == other.kind and data == other.data
