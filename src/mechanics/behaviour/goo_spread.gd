class_name GooSpreadRule extends RuleBehaviour
## Clear-to-cancel spread: each goo chooses one free face neighbour after a quiet lock.
const PLUGIN_ID := &"goo_spread"
var _cleared: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_clear", &"on_resolve_end"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_clear":
		_cleared = true
		return
	if _cleared and bool(api.param(&"cancel_on_clear", true)):
		_cleared = false
		api.emit(&"goo_cancelled", {})
		return
	_cleared = false
	var kind: int = api.kind_of(&"goo")
	if kind < 1:
		return
	var candidates: Array[Vector3i] = []
	for c: Vector3i in MechanicsCells.occupied(api, kind):
		for direction_value: Vector3i in [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i(0, 0, -1), Vector3i(0, 0, 1)]:
			var target: Vector3i = c + direction_value
			if api.is_free(target) and api.layer_of(target) < api.limit_layer() and not candidates.has(target):
				candidates.append(target)
	for _cell: int in mini(maxi(1, int(api.param(&"per_lock", 1))), candidates.size()):
		var target: Vector3i = MechanicsCells.pick(api, candidates)
		candidates.erase(target)
		api.set_cell(target, kind)
		api.emit(&"goo_spread", {"cell": target})


func snapshot() -> Dictionary:
	return {"cleared": _cleared}
