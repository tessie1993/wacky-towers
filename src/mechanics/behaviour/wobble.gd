class_name WobbleRule extends RuleBehaviour
## Grid sway: unsupported cubes charge a meter, then the latest piece slips.
const PLUGIN_ID := &"wobble"
var _meter: int = 0
var _uid: int = -1


func subscribed_hooks() -> Array[StringName]:
	return [&"on_lock", &"on_resolve_end"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_lock":
		_uid = int(ctx.data.get("uid", -1))
		var cells: Array[Vector3i] = []
		for c: Vector3i in ctx.data.get("cells", []):
			cells.append(c)
		var overhangs: int = 0
		for c: Vector3i in cells:
			var below: Vector3i = c + api.down_vector()
			if api.is_active(below) and api.kind_at(below) == 0 and not cells.has(below):
				overhangs += 1
		_meter = _meter + overhangs if overhangs > 0 else maxi(0, _meter - int(api.param(&"wobble_decay", 1)))
		api.emit(&"wobble_meter", {"value": _meter, "target": int(api.param(&"wobble_max", 6)), "overhangs": overhangs})
		return
	if _meter < int(api.param(&"wobble_max", 6)):
		return
	_meter = 0
	var cells: Array[Vector3i] = MechanicsCells.owned(api, _uid)
	if cells.is_empty():
		return
	var direction_value: Vector3i = heavier_side(api, MechanicsCells.occupied(api))
	if direction_value == Vector3i.ZERO:
		direction_value = heavier_side(api, cells)
	if direction_value == Vector3i.ZERO:
		return
	var targets: Array[Vector3i] = MechanicsCells.translated(cells, direction_value * int(api.param(&"slip_cells", 1)))
	for c: Vector3i in targets:
		if not api.is_active(c):
			for source: Vector3i in cells:
				api.remove_cell(source, BoardState.Cause.TRIM)
			api.emit(&"wobble_popoff", {"uid": _uid, "cells": cells.size()})
			return
	if not MechanicsCells.group_free(api, targets, cells):
		api.emit(&"wobble_hold", {"uid": _uid})
		return
	var distance: int = MechanicsCells.rigid_distance_virtual(api, targets, api.down_vector(), cells)
	api.move_cells(cells, MechanicsCells.translated(targets, api.down_vector() * distance))
	api.emit(&"wobble_slip", {"uid": _uid, "direction": direction_value, "distance": distance})


static func heavier_side(api: RuleApi, cells: Array[Vector3i]) -> Vector3i:
	var size: Vector3i = api.board_size()
	var x_moment: int = 0
	var z_moment: int = 0
	for c: Vector3i in cells:
		x_moment += 2 * c.x - (size.x - 1)
		z_moment += 2 * c.z - (size.z - 1)
	if x_moment == 0 and z_moment == 0:
		return Vector3i.ZERO
	return Vector3i(signi(x_moment), 0, 0) if absi(x_moment) >= absi(z_moment) else Vector3i(0, 0, signi(z_moment))


func snapshot() -> Dictionary:
	return {"meter": _meter, "uid": _uid}
