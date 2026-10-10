class_name MushroomPopupRule extends RuleBehaviour
## Announces the selected empty surface one lock before the mushroom appears.
const PLUGIN_ID := &"mushroom_popup"
var _locks: int = 0
var _pending := Vector3i(-1, -1, -1)
var _marked: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_resolve_end"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	_locks += 1
	var every: int = maxi(2, int(api.param(&"spawn_every_locks", 5)))
	var mushroom: int = api.kind_of(StringName(String(api.param(&"object_kind", "mushroom"))))
	if mushroom < 1:
		return
	if _marked and _locks % every == 0:
		if api.is_free(_pending):
			api.set_cell(_pending, mushroom)
			api.emit(&"mushroom_popup", {"cell": _pending})
		else:
			api.emit(&"mushroom_cancelled", {"cell": _pending})
		_marked = false
	if _locks % every == every - 1 and MechanicsCells.occupied(api, mushroom).size() < int(api.param(&"objects_max", 4)):
		var candidates: Array[Vector3i] = []
		var down: Vector3i = api.down_vector()
		for c: Vector3i in MechanicsCells.all(api):
			if api.is_free(c) and api.layer_of(c) < api.layer_count() - 4 and (not api.is_active(c + down) or api.kind_at(c + down) != 0):
				candidates.append(c)
		if not candidates.is_empty():
			if String(api.param(&"place_mode", "random")) == "lowest":
				var lowest: int = api.layer_of(candidates[0])
				candidates = candidates.filter(func(cell: Vector3i) -> bool: return api.layer_of(cell) == lowest)
			_pending = MechanicsCells.pick(api, candidates)
			_marked = true
			api.emit(&"mushroom_warning", {"cell": _pending, "locks_left": 1})


func snapshot() -> Dictionary:
	return {"locks": _locks, "pending": _pending, "marked": _marked}
