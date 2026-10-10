class_name HatchingEggsRule extends RuleBehaviour
## Hatch ages are lock counters stored on the egg, and move with its cube.
const PLUGIN_ID := &"hatching_eggs"


func subscribed_hooks() -> Array[StringName]:
	return [&"on_resolve_end", &"on_clear"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var egg: int = api.kind_of(&"egg")
	if hook == &"on_clear":
		if int(ctx.data.get("kind", 0)) == egg:
			api.emit(&"egg_clear_bonus", {"cell": ctx.data.get("cell", Vector3i.ZERO), "points": int(api.param(&"egg_bonus", 25))})
		return
	var chick: int = api.kind_of(&"chick")
	if egg < 1 or chick < 1:
		return
	var every: int = maxi(1, int(api.param(&"hatch_locks", 6)))
	for c: Vector3i in MechanicsCells.occupied(api, egg):
		var status: Dictionary = api.record_at(c).get("status", {})
		var age: int = int(status.get("counter", 0)) + 1
		if age < every:
			api.set_status(c, {"status_id": 21, "counter": age, "rule_id": PLUGIN_ID})
			if age == every - 1:
				api.emit(&"egg_hatch_warning", {"cell": c, "locks_left": 1})
			continue
		var target: Vector3i = c
		var lowest: int = api.layer_of(c)
		var selected: bool = false
		for dir: Vector3i in [Vector3i.RIGHT, Vector3i.LEFT, Vector3i(0, 0, 1), Vector3i(0, 0, -1), Vector3i.UP, Vector3i.DOWN, Vector3i.ZERO]:
			if dir != Vector3i.ZERO and dir[0] * api.down_vector()[0] + dir[1] * api.down_vector()[1] + dir[2] * api.down_vector()[2] != 0:
				continue
			var neighbour: Vector3i = c + dir
			if not api.is_active(neighbour) or (neighbour != c and not api.is_free(neighbour)):
				continue
			var one: Array[Vector3i] = [neighbour]
			var vacated: Array[Vector3i] = [c]
			var distance: int = MechanicsCells.rigid_distance_virtual(api, one, api.down_vector(), vacated)
			var landing: Vector3i = neighbour + api.down_vector() * distance
			if not selected or api.layer_of(landing) < lowest:
				selected = true
				target = landing
				lowest = api.layer_of(landing)
		api.remove_cell(c, BoardState.Cause.DISPLACED)
		api.set_cell(target, chick)
		api.emit(&"egg_hatched", {"cell": c, "target": target})
