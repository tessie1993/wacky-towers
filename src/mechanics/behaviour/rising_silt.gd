class_name RisingSiltRule extends RuleBehaviour
## Reachable open columns remain gaps; a blocked rise waits for the next clear.
const PLUGIN_ID := &"rising_silt"
var _locks: int = 0
var _pending: bool = false
var _wait_clear: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_clear", &"on_resolve_end"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_clear":
		_wait_clear = false
		return
	_locks += 1
	var every: int = maxi(1, int(api.param(&"silt_every_locks", 10)))
	if _locks % every == every - int(api.param(&"silt_warn_locks", 1)):
		api.emit(&"silt_warning", {"locks_left": int(api.param(&"silt_warn_locks", 1))})
	_pending = _pending or _locks % every == 0
	if not _pending or _wait_clear:
		return
	var down: Vector3i = api.down_vector()
	var candidates: Array[Vector3i] = []
	var floor: Array[Vector3i] = []
	for c: Vector3i in MechanicsCells.all(api):
		if api.layer_of(c) != 0:
			continue
		floor.append(c)
		if api.is_free(c):
			var ray: Array[Vector3i] = [c]
			if api.cast(ray, -down) >= api.layer_count() - 1:
				candidates.append(c)
	if candidates.is_empty():
		_wait_clear = true
		api.emit(&"silt_skipped", {"reason": "no_reachable_gap"})
		return
	var gaps: Array[Vector3i] = []
	for _gap: int in mini(maxi(1, int(api.param(&"silt_gaps", 3))), candidates.size()):
		var chosen: Vector3i = MechanicsCells.pick(api, candidates)
		gaps.append(chosen)
		candidates.erase(chosen)
	var from: Array[Vector3i] = []
	var to: Array[Vector3i] = []
	for c: Vector3i in MechanicsCells.occupied(api):
		var target: Vector3i = c - down
		if api.is_active(target):
			from.append(c)
			to.append(target)
		else:
			api.remove_cell(c, BoardState.Cause.TRIM)
	api.move_cells(from, to)
	var kind: int = api.kind_of(&"starter")
	for c: Vector3i in floor:
		if not gaps.has(c):
			api.set_cell(c, kind)
	_pending = false
	api.emit(&"silt_rise", {"gaps": gaps, "cells": floor.size() - gaps.size()})


func snapshot() -> Dictionary:
	return {"locks": _locks, "pending": _pending, "wait_clear": _wait_clear}
