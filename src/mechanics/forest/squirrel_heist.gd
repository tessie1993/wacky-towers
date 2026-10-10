class_name SquirrelHeistRule extends RuleBehaviour
## EV25 targets an accessible cube in the fullest unfinished layer; clear/cover cancels.
const PLUGIN_ID := &"squirrel_heist"
var _locks: int = 0
var _due_lock: int = -1
var _target := Vector3i(-1, -1, -1)
var _uid: int = -1
var _kind: int = 0
var _marked: bool = false

func subscribed_hooks() -> Array[StringName]:
	return [&"on_clear", &"on_resolve_end"]

func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_clear":
		if _marked and int(ctx.data.get("layer", -1)) == api.layer_of(_target): _cancel(api, "layer_cleared")
		return
	_locks += 1
	var every: int = clampi(int(api.param(&"heist_every_locks", 6)), 3, 12)
	var warning: int = clampi(int(api.param(&"heist_warn_locks", 1)), 1, every - 1)
	if _marked and _locks >= _due_lock:
		var count: int = 0
		for cell: Vector3i in MechanicsCells.occupied(api):
			if api.layer_of(cell) == api.layer_of(_target): count += 1
		if count > 1 and api.kind_at(_target) == _kind and int(api.record_at(_target).get("piece_instance_id", -1)) == _uid and _exposed(api, _target):
			api.remove_cell(_target, BoardState.Cause.DISPLACED)
			api.emit(&"squirrel_heist", {"cell": _target})
			_marked = false
		else: _cancel(api, "target_covered_or_changed")
	if _locks % every != every - warning: return
	var minimum: int = clampi(roundi(float(api.param(&"heist_min_fill", 0.5)) * 1000), 0, 1000)
	var best: Array[Vector3i] = []
	var best_filled: int = -1
	var best_active: int = 1
	var all: Array[Vector3i] = MechanicsCells.all(api)
	for layer: int in range(1, api.limit_layer()):
		var active: int = 0
		var filled: int = 0
		var candidates: Array[Vector3i] = []
		for cell: Vector3i in all:
			if api.layer_of(cell) != layer: continue
			active += 1
			if api.fills_layer_at(cell): filled += 1
			var status: Dictionary = api.record_at(cell).get("status", {})
			if api.kind_at(cell) in [api.kind_of(&"block"), api.kind_of(&"starter")] and not bool(status.get("locked", false)) and not bool(status.get("fixed", false)) and _exposed(api, cell): candidates.append(cell)
		if active < 1 or filled < 2 or filled == active or filled * 1000 < active * minimum or candidates.is_empty(): continue
		if best_filled < 0 or filled * best_active > best_filled * active:
			best = candidates
			best_filled = filled
			best_active = active
	if best.is_empty():
		api.emit(&"squirrel_nap", {})
		return
	_target = MechanicsCells.pick(api, best)
	_kind = api.kind_at(_target)
	_uid = int(api.record_at(_target).get("piece_instance_id", 0))
	_due_lock = _locks + warning
	_marked = true
	api.emit(&"heist_warning", {"cell": _target, "locks_left": warning, "due_lock": _due_lock})
	api.emit(&"warning", {"message": "Squirrel raid — clear or cover the marked cube!"})

func _exposed(api: RuleApi, cell: Vector3i) -> bool:
	var above: Vector3i = cell - api.down_vector()
	while api.is_active(above):
		if not api.is_free(above): return false
		above -= api.down_vector()
	return true

func _cancel(api: RuleApi, reason: String) -> void:
	api.emit(&"heist_cancelled", {"cell": _target, "reason": reason})
	_marked = false

func snapshot() -> Dictionary:
	return {"locks": _locks, "due_lock": _due_lock, "target": _target, "uid": _uid, "kind": _kind, "marked": _marked}
