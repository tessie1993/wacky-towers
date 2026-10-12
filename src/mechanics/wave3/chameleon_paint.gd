class_name ChameleonPaintRule extends RuleBehaviour
## W3: a locked piece takes the majority colour of the locked cubes it touches.
const PLUGIN_ID := &"chameleon_paint"
const _FACES: Array[Vector3i] = [Vector3i.RIGHT, Vector3i.LEFT, Vector3i.UP, Vector3i.DOWN, Vector3i.BACK, Vector3i.FORWARD]


func subscribed_hooks() -> Array[StringName]:
	return [&"on_lock"]


func handle(_hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var cells: Array[Vector3i] = []
	cells.assign(ctx.data.get("cells", []))
	if cells.is_empty():
		return
	var votes: Dictionary = {}
	for c: Vector3i in cells:
		for face: Vector3i in _FACES:
			var n: Vector3i = c + face
			if cells.has(n) or not api.is_active(n) or api.kind_at(n) == 0:
				continue
			var colour: int = api.color_at(n)
			if colour > 0:
				votes[colour] = int(votes.get(colour, 0)) + 1
	var best: int = 0
	var best_votes: int = 0
	var colours: Array = votes.keys()
	colours.sort()
	for colour: int in colours:
		if int(votes[colour]) > best_votes:
			best = colour
			best_votes = int(votes[colour])
	if best_votes < maxi(1, int(api.param(&"min_neighbours", 2))) or best == api.color_at(cells[0]):
		return
	for c: Vector3i in cells:
		var record: Dictionary = api.record_at(c)
		api.set_cell(c, api.kind_at(c), best, int(record.get("piece_instance_id", ctx.data.get("uid", 0))))
		var status: Dictionary = record.get("status", {})
		if not status.is_empty():
			api.set_status(c, status)
	api.emit(&"chameleon", {"hue": best, "cells": cells})


func snapshot() -> Dictionary:
	return {}
