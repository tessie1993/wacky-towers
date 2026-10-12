class_name MascotHintRule extends RuleBehaviour
## The helper points at a legal supported destination without altering player input.
const PLUGIN_ID := &"mascot_hint"


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var cells: Array[Vector3i] = api.piece_cells()
	if cells.is_empty():
		return
	var down: Vector3i = api.down_vector()
	var ground: Array[int] = []
	for axis: int in 3:
		if down[axis] == 0:
			ground.append(axis)
	var best: Array[Vector3i] = []
	var best_score: int = -2147483647
	var size: Vector3i = api.board_size()
	for a: int in range(-size[ground[0]], size[ground[0]] + 1):
		for b: int in range(-size[ground[1]], size[ground[1]] + 1):
			var offset := Vector3i.ZERO
			offset[ground[0]] = a
			offset[ground[1]] = b
			var shifted: Array[Vector3i] = MechanicsCells.translated(cells, offset)
			if not api.can_place(shifted):
				continue
			var depth: int = api.cast(shifted, down)
			var landed: Array[Vector3i] = MechanicsCells.translated(shifted, down * depth)
			var value: int = depth * 10 - api.new_covered_holes(landed) * 100 + (10000 if api.would_clear(landed) else 0)
			if value > best_score:
				best_score = value
				best = landed
	if not best.is_empty():
		api.emit(&"mascot_hint", {"cells": best, "score": best_score})
