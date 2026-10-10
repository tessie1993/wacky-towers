class_name TurntableRule extends RuleBehaviour
## Quarter-turns a square stack as one simultaneous permutation.
const PLUGIN_ID := &"turntable"
var _locks: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_resolve_end"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	_locks += 1
	var every: int = maxi(1, int(api.param(&"turn_locks", api.param(&"rotate_every_locks", 3))))
	if _locks % every == every - 1:
		api.emit(&"turntable_warning", {"locks_left": 1})
	if _locks % every != 0:
		return
	var size: Vector3i = api.board_size()
	if size.x != size.z:
		api.emit(&"turntable_blocked", {"reason": "square_footprint_required"})
		return
	var clockwise: bool = bool(api.param(&"clockwise", true))
	var from: Array[Vector3i] = MechanicsCells.occupied(api)
	var to: Array[Vector3i] = []
	for c: Vector3i in from:
		var target := Vector3i(size.x - 1 - c.z, c.y, c.x) if clockwise else Vector3i(c.z, c.y, size.z - 1 - c.x)
		if not api.is_active(target):
			api.emit(&"turntable_blocked", {"reason": "symmetric_mask_required"})
			return
		to.append(target)
	api.move_cells(from, to)
	api.emit(&"turntable_turn", {"clockwise": clockwise, "cells": from.size()})


func snapshot() -> Dictionary:
	return {"locks": _locks}
