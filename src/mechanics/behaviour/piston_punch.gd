class_name PistonPunchRule extends RuleBehaviour
## A piston shifts the occupied prefix into its first empty cell; full rows jam.
const PLUGIN_ID := &"piston_punch"
var _locks: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_resolve_end"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	_locks += 1
	var every: int = maxi(2, int(api.param(&"piston_locks", 4)))
	if _locks % every == every - 1:
		api.emit(&"piston_warning", {"locks_left": 1})
	if _locks % every != 0:
		return
	var pistons: Array = api.param(&"pistons", [{"wall": "west", "row": 1, "y": 0}])
	var size: Vector3i = api.board_size()
	for piston: Dictionary in pistons:
		var wall: String = String(piston.get("wall", "west"))
		var row: int = int(piston.get("row", 1))
		var y: int = int(piston.get("y", 0))
		var inward := Vector3i.ZERO
		var edge := Vector3i.ZERO
		match wall:
			"west", "-x":
				inward = Vector3i.RIGHT
				edge = Vector3i(0, y, row)
			"east", "+x":
				inward = Vector3i.LEFT
				edge = Vector3i(size.x - 1, y, row)
			"north", "-z":
				inward = Vector3i(0, 0, 1)
				edge = Vector3i(row, y, 0)
			"south", "+z":
				inward = Vector3i(0, 0, -1)
				edge = Vector3i(row, y, size.z - 1)
			_:
				api.emit(&"piston_jam", {"wall": wall, "row": row, "reason": "unknown_wall"})
				continue
		var from: Array[Vector3i] = []
		var to: Array[Vector3i] = []
		var cursor: Vector3i = edge
		while api.is_active(cursor) and api.kind_at(cursor) != 0:
			from.append(cursor)
			to.append(cursor + inward)
			cursor += inward
		if from.is_empty() or not api.is_free(cursor):
			api.emit(&"piston_jam", {"wall": wall, "row": piston.get("row", 1), "y": edge.y})
			continue
		api.move_cells(from, to)
		api.emit(&"piston_push", {"wall": wall, "row": piston.get("row", 1), "cells": from.size()})


func snapshot() -> Dictionary:
	return {"locks": _locks}
