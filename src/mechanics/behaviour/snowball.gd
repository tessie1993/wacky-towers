class_name SnowballRule extends RuleBehaviour
## Rolling living columns retain their identity through stack moves and clears.
const PLUGIN_ID := &"snowball"
var _locks: int = 0
var _next_id: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_resolve_end", &"on_clear"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var kind: int = api.kind_of(&"snowball")
	if kind < 1:
		return
	if hook == &"on_clear":
		if int(ctx.data.get("kind", 0)) == kind:
			api.emit(&"snowball_puff", {"cell": ctx.data.get("cell", Vector3i.ZERO)})
		return
	if hook == &"on_level_start":
		for c: Vector3i in MechanicsCells.occupied(api, kind):
			api.set_status(c, {"status_id": 41, "counter": 1, "rule_id": PLUGIN_ID, "ball_id": _next_id, "parked": false})
			_next_id += 1
		return
	_locks += 1
	var groups: Dictionary = {}
	for c: Vector3i in MechanicsCells.occupied(api, kind):
		var status: Dictionary = api.record_at(c).get("status", {})
		var id: int = int(status.get("ball_id", -1))
		if id < 0:
			continue
		var cells: Array = groups.get_or_add(id, [])
		cells.append(c)
	var every: int = maxi(1, int(api.param(&"roll_locks", 2)))
	var direction_value: Vector3i = MechanicsCells.direction(String(api.param(&"slope_dir", "-x")))
	var ids: Array = groups.keys()
	ids.sort()
	for id: int in ids:
		var cells: Array[Vector3i] = []
		for c: Vector3i in groups[id]:
			cells.append(c)
		var status: Dictionary = api.record_at(cells[0]).get("status", {})
		if bool(status.get("parked", false)):
			continue
		if _locks % every == every - 1:
			api.emit(&"snowball_warning", {"ball_id": id, "direction": direction_value, "locks_left": 1})
		if _locks % every != 0:
			continue
		var bottom: Vector3i = cells[0]
		for c: Vector3i in cells:
			if api.layer_of(c) < api.layer_of(bottom):
				bottom = c
		var next_base: Vector3i = bottom + direction_value
		var next_surface: int = -1
		var in_footprint: bool = api.is_active(next_base)
		if in_footprint:
			for layer: int in api.layer_count():
				var ray: Vector3i = next_base - api.down_vector() * (layer - api.layer_of(next_base))
				if api.is_active(ray) and api.kind_at(ray) != 0 and not cells.has(ray):
					next_surface = maxi(next_surface, layer)
		var change: int = next_surface + 1 - api.layer_of(bottom)
		var targets: Array[Vector3i] = MechanicsCells.translated(cells, direction_value - api.down_vector() * change)
		if not in_footprint or absi(change) > 1 or not MechanicsCells.group_free(api, targets, cells):
			for c: Vector3i in cells:
				var parked: Dictionary = api.record_at(c).get("status", {}).duplicate()
				parked["parked"] = true
				api.set_status(c, parked)
			api.emit(&"snowball_parked", {"ball_id": id})
			continue
		api.move_cells(cells, targets)
		var tip: Vector3i = targets[0]
		for c: Vector3i in targets:
			if api.layer_of(c) > api.layer_of(tip):
				tip = c
		var above: Vector3i = tip - api.down_vector()
		if cells.size() < clampi(int(api.param(&"snow_max", 3)), 1, 4) and api.is_free(above) and not targets.has(above):
			api.set_cell(above, kind)
			api.set_status(above, {"status_id": 41, "counter": cells.size() + 1, "rule_id": PLUGIN_ID, "ball_id": id, "parked": false})
		api.emit(&"snowball_roll", {"ball_id": id, "direction": direction_value, "cells": targets})
	var respawn: int = maxi(0, int(api.param(&"respawn_locks", 8)))
	if respawn > 0 and _locks % respawn == 0 and groups.size() < int(api.param(&"balls_max", 2)):
		_spawn(api, kind, direction_value)


func _spawn(api: RuleApi, kind: int, slope: Vector3i) -> void:
	var candidates: Array[Vector3i] = []
	var axis: int = 0 if slope.x != 0 else 2
	var high_end: int = api.board_size()[axis] - 1 if slope[axis] < 0 else 0
	for c: Vector3i in MechanicsCells.all(api):
		if c[axis] == high_end and api.is_free(c) and api.layer_of(c) < api.limit_layer() and (api.layer_of(c) == 0 or api.kind_at(c + api.down_vector()) != 0):
			candidates.append(c)
	if candidates.is_empty():
		return
	var cell: Vector3i = MechanicsCells.pick(api, candidates)
	api.set_cell(cell, kind)
	api.set_status(cell, {"status_id": 41, "counter": 1, "rule_id": PLUGIN_ID, "ball_id": _next_id, "parked": false})
	api.emit(&"snowball_spawn", {"ball_id": _next_id, "cell": cell})
	_next_id += 1


func snapshot() -> Dictionary:
	return {"locks": _locks, "next_id": _next_id}
