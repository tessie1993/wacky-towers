class_name BubbleRule extends RuleBehaviour
## A tagged bubble piece rises rigidly to the next occupied surface or ceiling.
const PLUGIN_ID := &"bubble"
var _special: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_lock"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_spawn":
		_special = ctx.data.get("tags", PackedStringArray()).has("bubble")
		return
	if not _special:
		return
	var cells: Array[Vector3i] = []
	for c: Vector3i in ctx.data.get("cells", []):
		cells.append(c)
	var up: Vector3i = -api.down_vector()
	var distance: int = MechanicsCells.rigid_distance(api, cells, up)
	var targets: Array[Vector3i] = MechanicsCells.translated(cells, up * distance)
	var surface: bool = false
	for c: Vector3i in targets:
		if api.layer_of(c) >= api.layer_count() - 4:
			surface = true
	if surface:
		for c: Vector3i in cells:
			api.remove_cell(c, BoardState.Cause.DISPLACED)
		api.emit(&"bubble_pop", {"cells": targets})
	else:
		api.move_cells(cells, targets)
		api.emit(&"bubble_rise", {"distance": distance, "cells": targets})


func snapshot() -> Dictionary:
	return {"special": _special}
