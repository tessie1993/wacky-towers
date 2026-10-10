class_name QuakeRule extends RuleBehaviour
## EV12 outlines one fixed, capped unsupported cohort; never chains into a cleanup.
const PLUGIN_ID := &"quake"
var _due: int = -1
var _clears: int = 0
var _warned: bool = false
var _pending: bool = false
var _targets: Array[Dictionary] = []

func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_spawn", &"on_tick", &"on_clear", &"on_resolve_end"]

func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_clear":
		_clears = maxi(_clears, int(ctx.data.get("clear_count", _clears)))
	if _clears < maxi(0, int(api.param(&"active_after_clears", 0))): return
	if _due < 0: _schedule(api, true)
	if not _warned and api.now_ms() >= _due - maxi(0, int(api.param(&"quake_warn_ms", 2000))):
		_warned = true
		var candidates: Array[Vector3i] = []
		for cell: Vector3i in MechanicsCells.occupied(api):
			if _removable(api, cell) and api.is_free(cell + api.down_vector()): candidates.append(cell)
		candidates.sort_custom(func(a: Vector3i, b: Vector3i) -> bool:
			return api.layer_of(a) > api.layer_of(b) if api.layer_of(a) != api.layer_of(b) else (a.x < b.x if a.x != b.x else (a.z < b.z if a.z != b.z else a.y < b.y)))
		_targets.clear()
		for index: int in mini(candidates.size(), maxi(0, int(api.param(&"quake_max_cubes", 6)))):
			var cell: Vector3i = candidates[index]
			_targets.append({"cell": cell, "uid": int(api.record_at(cell).get("piece_instance_id", 0)), "kind": api.kind_at(cell)})
		api.emit(&"quake_warning", {"cells": _cells(), "due_ms": _due})
		api.emit(&"warning", {"message": "Rumble coming — dotted overhangs may pop!"})
	if api.now_ms() >= _due: _pending = true
	if hook != &"on_resolve_end" or not _pending: return
	var removed: Array[Vector3i] = []
	for target: Dictionary in _targets:
		var cell: Vector3i = target.cell
		if _removable(api, cell) and api.kind_at(cell) == int(target.kind) and int(api.record_at(cell).get("piece_instance_id", 0)) == int(target.uid):
			api.remove_cell(cell, BoardState.Cause.DISPLACED)
			removed.append(cell)
	api.emit(&"quake", {"cells": removed})
	_targets.clear()
	_pending = false
	_schedule(api, false)

func _removable(api: RuleApi, cell: Vector3i) -> bool:
	var kind: int = api.kind_at(cell)
	var status: Dictionary = api.record_at(cell).get("status", {})
	return kind in [api.kind_of(&"block"), api.kind_of(&"starter")] and not bool(status.get("vined", false)) and not bool(status.get("locked", false)) and not bool(status.get("fixed", false))

func _schedule(api: RuleApi, first: bool) -> void:
	var interval: int = maxi(1000, roundi(float(api.param(&"quake_every_s", 30)) * 1000))
	var delay: int = maxi(0, roundi(float(api.param(&"first_s", interval / 1000.0)) * 1000)) if first else interval
	_due = api.now_ms() + delay
	_warned = false

func _cells() -> Array[Vector3i]:
	var cells: Array[Vector3i] = []
	for target: Dictionary in _targets: cells.append(target.cell)
	return cells

func snapshot() -> Dictionary:
	return {"due": _due, "clears": _clears, "warned": _warned, "pending": _pending, "targets": _targets.duplicate(true)}
