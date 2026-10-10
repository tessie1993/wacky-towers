class_name LockedCubeRule extends RuleBehaviour
## SP30 unlocks only cubes face-adjacent to an actual clear, before clear writes flush.
const PLUGIN_ID := &"locked_cube"
const FACES: Array[Vector3i] = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i(0, 0, -1), Vector3i(0, 0, 1)]
var _unlocked: Array[Vector3i] = []

func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_clear", &"on_resolve_end"]

func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		var kind: int = api.kind_of(&"locked_cube")
		if kind > 0:
			for cell: Vector3i in MechanicsCells.occupied(api, kind):
				var status: Dictionary = api.record_at(cell).get("status", {}).duplicate(true)
				status["locked"] = true
				api.set_status(cell, status)
		return
	if hook == &"on_resolve_end":
		_unlocked.clear()
		return
	var origin: Vector3i = ctx.data.get("cell", Vector3i(-1, -1, -1))
	for direction: Vector3i in FACES:
		var cell: Vector3i = origin + direction
		if not api.is_active(cell) or _unlocked.has(cell): continue
		var status: Dictionary = api.record_at(cell).get("status", {}).duplicate(true)
		if not bool(status.get("locked", false)) or bool(status.get("anchored", false)) or bool(status.get("fixed", false)): continue
		status["locked"] = false
		api.set_status(cell, status)
		_unlocked.append(cell)
		api.emit(&"cube_unlocked", {"cell": cell})

func snapshot() -> Dictionary:
	return {"unlocked_this_resolution": _unlocked.duplicate()}
