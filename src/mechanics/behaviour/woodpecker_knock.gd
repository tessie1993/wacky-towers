class_name WoodpeckerKnockRule extends RuleBehaviour
## Outline unsupported cubes at warning time; pop that fixed subset in Resolving.
const PLUGIN_ID := &"woodpecker_knock"
var _due: int = -1
var _warned: bool = false
var _pending: bool = false
var _targets: Array[Vector3i] = []
var _identities: Dictionary = {}


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_tick", &"on_resolve_end"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var now: int = api.time_ms()
	if hook == &"on_spawn" and _due < 0:
		_schedule(api)
	if _due < 0:
		return
	if not _warned and now >= _due - int(api.param(&"knock_warn_ms", 1500)):
		_warned = true
		_targets.clear()
		_identities.clear()
		for c: Vector3i in MechanicsCells.occupied(api):
			if _removable(api, c) and api.is_free(c + api.down_vector()):
				_targets.append(c)
		_targets.sort_custom(func(a: Vector3i, b: Vector3i) -> bool:
			return api.layer_of(a) > api.layer_of(b) if api.layer_of(a) != api.layer_of(b) else (a.x < b.x if a.x != b.x else a.z < b.z))
		_targets.resize(mini(_targets.size(), maxi(1, int(api.param(&"knock_pop_max", 4)))))
		for cell: Vector3i in _targets:
			_identities[cell] = int(api.record_at(cell).get("piece_instance_id", 0))
		api.emit(&"woodpecker_warning", {"cells": _targets.duplicate(), "due_ms": _due})
	if now >= _due:
		_pending = true
	if hook == &"on_resolve_end" and _pending:
		for c: Vector3i in _targets:
			if _removable(api, c) and int(api.record_at(c).get("piece_instance_id", 0)) == int(_identities.get(c, -1)):
				api.remove_cell(c, BoardState.Cause.DISPLACED)
		api.emit(&"woodpecker_knock", {"cells": _targets.duplicate()})
		_targets.clear()
		_pending = false
		_schedule(api)


func _removable(api: RuleApi, cell: Vector3i) -> bool:
	var kind: int = api.kind_at(cell)
	var status: Dictionary = api.record_at(cell).get("status", {})
	return kind in [api.kind_of(&"block"), api.kind_of(&"starter")] and not bool(status.get("vined", false)) and not bool(status.get("locked", false)) and not bool(status.get("anchored", false))


func _schedule(api: RuleApi) -> void:
	var jitter: int = maxi(0, int(api.param(&"knock_jitter_ms", 3000)))
	_due = api.time_ms() + maxi(1000, int(api.param(&"knock_interval_ms", 13000)) + (api.rng().randi_range(-jitter, jitter) if jitter > 0 else 0))
	_warned = false


func snapshot() -> Dictionary:
	return {"due": _due, "warned": _warned, "pending": _pending, "targets": _targets.duplicate(), "identities": _identities.duplicate(true)}
