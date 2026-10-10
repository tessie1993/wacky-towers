class_name VinesRule extends RuleBehaviour
## SP12 selects an exact quota from each actual dealt bag, then protects direct neighbours.
const PLUGIN_ID := &"vines"
const FACES: Array[Vector3i] = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i(0, 0, -1), Vector3i(0, 0, 1)]
var _bag: int = -2
var _slots: Array[int] = []
var _special: bool = false

func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_lock"]

func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_spawn":
		var id: int = int(ctx.data.get("bag_id", -1))
		var size: int = maxi(0, int(ctx.data.get("bag_size", 0)))
		if id >= 0 and id != _bag:
			_bag = id
			_slots.clear()
			var candidates: Array[int] = []
			for position: int in size: candidates.append(position)
			for _pick: int in mini(clampi(int(api.param(&"vine_per_bag", 1)), 0, 2), size):
				var chosen: int = 0 if candidates.size() == 1 else api.rng().randi_range(0, candidates.size() - 1)
				_slots.append(candidates[chosen])
				candidates.remove_at(chosen)
			_slots.sort()
		_special = id >= 0 and _slots.has(int(ctx.data.get("bag_pos", -1)))
		api.set_piece_flag(&"vined", _special)
		if _special: api.emit(&"vine_piece", {"cells": api.piece_cells(), "bag_id": id})
		return
	if not _special: return
	var protected: Array[Vector3i] = []
	for cell: Vector3i in ctx.data.get("cells", []):
		if api.kind_at(cell) != 0 and not protected.has(cell): protected.append(cell)
		for direction: Vector3i in FACES:
			var neighbour: Vector3i = cell + direction
			if api.is_active(neighbour) and api.kind_at(neighbour) != 0 and not protected.has(neighbour): protected.append(neighbour)
	for cell: Vector3i in protected:
		var status: Dictionary = api.record_at(cell).get("status", {}).duplicate(true)
		status["vined"] = true
		api.set_status(cell, status)
	api.emit(&"vines_bound", {"cells": protected})

func snapshot() -> Dictionary:
	return {"bag": _bag, "slots": _slots.duplicate(), "special": _special}
