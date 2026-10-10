class_name MillBeltRule extends RuleBehaviour
## Simultaneous movement preserves every cube, including wraparound destinations.
const PLUGIN_ID := &"mill_belt"
var _locks: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_resolve_end"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	_locks += 1
	var every: int = maxi(1, int(api.param(&"conveyor_every", 2)))
	if _locks % every == every - 1:
		api.emit(&"conveyor_warning", {"locks_left": 1})
	if _locks % every != 0:
		return
	var direction_value: Vector3i = MechanicsCells.direction(String(api.param(&"conveyor_dir", api.param(&"dir", "+x"))))
	var size: Vector3i = api.board_size()
	var wrap: bool = bool(api.param(&"conveyor_wrap", true))
	var from: Array[Vector3i] = []
	var to: Array[Vector3i] = []
	for c: Vector3i in MechanicsCells.occupied(api):
		var target: Vector3i = c + direction_value
		if wrap:
			target = Vector3i(posmod(target.x, size.x), posmod(target.y, size.y), posmod(target.z, size.z))
		if api.is_active(target):
			from.append(c)
			to.append(target)
		else:
			api.remove_cell(c, BoardState.Cause.TRIM)
	api.move_cells(from, to)
	api.emit(&"conveyor_shift", {"direction": direction_value, "wrap": wrap, "cells": from.size()})


func snapshot() -> Dictionary:
	return {"locks": _locks}
