class_name EmberRule extends RuleBehaviour
## A tagged ember melts a bounded shaft below its bottom-facing cubes.
const PLUGIN_ID := &"ember"
var _special: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_lock"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_spawn":
		_special = ctx.data.get("tags", PackedStringArray()).has("ember")
		return
	if not _special:
		return
	var cells: Array[Vector3i] = []
	for c: Vector3i in ctx.data.get("cells", []):
		cells.append(c)
	var removed: Array[Vector3i] = []
	for c: Vector3i in cells:
		if cells.has(c + api.down_vector()):
			continue
		for depth: int in range(1, clampi(int(api.param(&"drill_depth", 1)), 1, 3) + 1):
			var target: Vector3i = c + api.down_vector() * depth
			if api.kind_at(target) != 0 and not removed.has(target):
				removed.append(target)
				api.remove_cell(target, BoardState.Cause.DAMAGE)
	api.request_settle()
	api.emit(&"ember_melt", {"cells": removed})


func snapshot() -> Dictionary:
	return {"special": _special}
