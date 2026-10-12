class_name MirrorRule extends RuleBehaviour
## Reflections fill free mirrored cells; overflow splashes without warning.
const PLUGIN_ID := &"mirror"


func subscribed_hooks() -> Array[StringName]:
	return [&"on_lock"]


func handle(_hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var axis: int = 0 if String(api.param(&"mirror_axis", "x")) == "x" else 2
	var size: Vector3i = api.board_size()
	var twins: Array[Vector3i] = []
	for c: Vector3i in ctx.data.get("cells", []):
		var twin: Vector3i = c
		twin[axis] = size[axis] - 1 - c[axis]
		if api.is_free(twin) and api.layer_of(twin) < api.layer_count() - 4:
			api.set_cell(twin, api.kind_at(c), api.color_at(c), int(ctx.data.get("uid", 0)))
			twins.append(twin)
	api.emit(&"mirror_twins", {"cells": twins, "axis": axis})
