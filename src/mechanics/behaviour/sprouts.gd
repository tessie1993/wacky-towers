class_name SproutsRule extends RuleBehaviour
## Growth metadata belongs to the root cube, and follows collapse/belt/flip moves.
const PLUGIN_ID := &"sprouts"
var _locks: int = 0
var _next_id: int = 0
var _growth: Dictionary = {}


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_resolve_end"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var kind: int = api.kind_of(&"sprout")
	if kind < 1:
		return
	var every: int = maxi(1, int(api.param(&"grow_locks", 4)))
	var limit: int = int(api.param(&"grow_max", 1))
	var groups: Dictionary = {}
	for c: Vector3i in MechanicsCells.occupied(api, kind):
		var rec: Dictionary = api.record_at(c)
		var status: Dictionary = rec.get("status", {})
		if hook == &"on_level_start":
			api.set_status(c, {"status_id": 22, "counter": 0, "rule_id": PLUGIN_ID, "sprout_id": _next_id})
			_growth[_next_id] = 0
			_next_id += 1
			continue
		if StringName(String(status.get("rule_id", ""))) != PLUGIN_ID:
			continue
		var id: int = int(status.get("sprout_id", -1))
		var cells: Array = groups.get_or_add(id, [])
		cells.append(c)
	if hook == &"on_level_start":
		return
	_locks += 1
	var ids: Array = groups.keys()
	ids.sort()
	for id: int in ids:
		var tip: Vector3i = groups[id][0]
		for c: Vector3i in groups[id]:
			if api.layer_of(c) > api.layer_of(tip):
				tip = c
		var above: Vector3i = tip - api.down_vector()
		var growth: int = int(_growth.get(id, 0))
		var can_grow: bool = (limit == 0 or growth < limit) and api.is_free(above)
		if _locks % every == every - 1:
			api.emit(&"sprout_bud", {"cell": tip, "capped": not can_grow})
		if _locks % every == 0 and can_grow:
			growth += 1
			_growth[id] = growth
			api.set_cell(above, kind)
			api.set_status(above, {"status_id": 22, "counter": growth, "rule_id": PLUGIN_ID, "sprout_id": id})
			api.emit(&"sprout_grown", {"root": tip, "cell": above, "growth": growth})


func snapshot() -> Dictionary:
	return {"locks": _locks, "next_id": _next_id, "growth": _growth.duplicate()}
