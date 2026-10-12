class_name PestRule extends RuleBehaviour
## Pests eat only ordinary piece/starter cubes; adjacent clears shoo them once.
const PLUGIN_ID := &"pest"
var _locks: int = 0
var _shooed: Dictionary = {}
var _late_spawned: bool = false
var _escaped: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_clear", &"on_resolve_end"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var kind: int = api.kind_of(&"pest")
	if kind < 1:
		return
	var directions: Array[Vector3i] = [Vector3i.RIGHT, Vector3i.LEFT, Vector3i.UP, Vector3i.DOWN, Vector3i(0, 0, 1), Vector3i(0, 0, -1)]
	if hook == &"on_clear":
		var cleared: Vector3i = ctx.data.get("cell", Vector3i.ZERO)
		var around: Array[Vector3i] = [cleared]
		for direction_value: Vector3i in directions:
			around.append(cleared + direction_value)
		for c: Vector3i in around:
			if api.kind_at(c) == kind and not _shooed.has(c):
				_shooed[c] = true
				api.remove_cell(c, BoardState.Cause.CLEAR)
				api.emit(&"pest_shooed", {"cell": c, "points": int(api.param(&"ant_shoo_bonus", 50))})
		return
	_locks += 1
	_shooed.clear()
	var every: int = maxi(1, int(api.param(&"ant_every_locks", 3)))
	var pests: Array[Vector3i] = MechanicsCells.occupied(api, kind)
	var claims: Dictionary = {}
	var virtual_kinds: Dictionary = {}
	for id: int in pests.size():
		var c: Vector3i = pests[id]
		var status: Dictionary = api.record_at(c).get("status", {}).duplicate(true)
		var bonus: int = clampi(int(status.get("extra_acts", 0)), 0, 1)
		if (_locks + id) % every != 0 and bonus == 0:
			continue
		status.erase("extra_acts")
		api.set_status(c, status)
		for _act: int in 1 + bonus:
			var candidates: Array[Vector3i] = []
			for direction_value: Vector3i in directions:
				var target: Vector3i = c + direction_value
				var at: int = int(virtual_kinds.get(target, api.kind_at(target)))
				if (at == api.kind_of(&"block") or at == api.kind_of(&"starter")) and api.layer_of(target) < api.limit_layer() and not claims.has(target):
					candidates.append(target)
			if candidates.is_empty():
				var hungry: int = int(status.get("counter", 0)) + 1
				if hungry >= int(api.param(&"ant_starve_acts", 3)):
					api.remove_cell(c, BoardState.Cause.DISPLACED)
					virtual_kinds[c] = 0
					api.emit(&"pest_starved", {"cell": c})
				else:
					status.merge({"status_id": 31, "counter": hungry, "rule_id": PLUGIN_ID}, true)
					api.set_status(c, status)
				break
			var target: Vector3i = MechanicsCells.pick(api, candidates)
			claims[target] = true
			virtual_kinds[c] = 0
			virtual_kinds[target] = kind
			api.remove_cell(target, BoardState.Cause.DAMAGE)
			api.move_cell(c, target)
			status.merge({"status_id": 31, "counter": 0, "rule_id": PLUGIN_ID}, true)
			api.set_status(target, status)
			api.emit(&"pest_ate", {"cell": c, "target": target})
			c = target
			if bool(api.param(&"rim_escape", false)) and _is_rim(c, api):
				api.remove_cell(c, BoardState.Cause.DISPLACED)
				virtual_kinds[c] = 0
				_escaped += 1
				api.goal_metric(&"worms_escaped", _escaped)
				api.emit(&"pest_escaped", {"cell": c, "with_cube": true, "count": _escaped})
				break
	var late_s: int = int(api.param(&"late_spawn_s", 0))
	if not _late_spawned and late_s > 0 and api.time_ms() >= late_s * 1000:
		_late_spawned = true
		var candidates: Array[Vector3i] = []
		for c: Vector3i in MechanicsCells.all(api):
			if api.layer_of(c) == 0 and api.is_free(c):
				candidates.append(c)
		if not candidates.is_empty():
			var target: Vector3i = MechanicsCells.pick(api, candidates)
			api.set_cell(target, kind)
			api.emit(&"pest_spawn", {"cell": target})


func _is_rim(c: Vector3i, api: RuleApi) -> bool:
	return c.x == 0 or c.z == 0 or c.x == api.board_size().x - 1 or c.z == api.board_size().z - 1


func snapshot() -> Dictionary:
	return {"locks": _locks, "late_spawned": _late_spawned, "shooed": _shooed.duplicate(), "escaped": _escaped}
