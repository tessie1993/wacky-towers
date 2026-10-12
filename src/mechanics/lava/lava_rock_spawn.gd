class_name LavaRockSpawnRule extends RuleBehaviour
## EV04 creates a real vent or a two-hit rock; warnings never overwrite an occupied mark.
const PLUGIN_ID := &"lava_rock_spawn"
const FACES: Array[Vector3i] = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i(0, 0, -1), Vector3i(0, 0, 1)]
var _locks: int = 0
var _marked: bool = false
var _target := Vector3i(-1, -1, -1)
var _hit_stamps: Dictionary = {}

func subscribed_hooks() -> Array[StringName]:
	return [&"on_clear", &"on_resolve_end"]

func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_clear":
		_hit_adjacent(ctx, api)
		return
	_locks += 1
	var every: int = maxi(2, int(api.param(&"every_locks", api.param(&"spawn_every_locks", 5))))
	var maximum: int = maxi(0, int(api.param(&"objects_max", 3)))
	var object: String = String(api.param(&"object", "SP19"))
	var kind: int = api.kind_of(StringName(String(api.param(&"object_kind", "bounce_pad" if object == "SP35" else "rock"))))
	if kind < 1 or maximum == 0: return
	if _marked and _locks % every == 0:
		if api.is_free(_target) and _count(api, kind, object) < maximum:
			api.set_cell(_target, kind)
			if object != "SP35":
				api.set_status(_target, {"status_id": 62, "rule_id": PLUGIN_ID, "rock": true, "clear_protected": true, "fills_layer": false, "hits_left": clampi(int(api.param(&"hard_hits", 2)), 1, 8)})
			api.emit(&"geyser_pop", {"cell": _target, "object": object})
		else: api.emit(&"geyser_cancelled", {"cell": _target})
		_marked = false
	if _locks % every != every - 1 or _count(api, kind, object) >= maximum: return
	var candidates: Array[Vector3i] = []
	for cell: Vector3i in MechanicsCells.all(api):
		if api.layer_of(cell) < api.limit_layer() and api.is_free(cell) and (not api.is_active(cell + api.down_vector()) or api.kind_at(cell + api.down_vector()) != 0): candidates.append(cell)
	if candidates.is_empty(): return
	_target = MechanicsCells.pick(api, candidates)
	_marked = true
	api.emit(&"geyser_warning", {"cell": _target, "locks_left": 1, "object": object})

func _count(api: RuleApi, kind: int, object: String) -> int:
	var count: int = 0
	for cell: Vector3i in MechanicsCells.occupied(api, kind):
		var status: Dictionary = api.record_at(cell).get("status", {})
		if object == "SP35" or (bool(status.get("rock", false)) and not bool(status.get("anchored", false))): count += 1
	return count

func _hit_adjacent(ctx: HookContext, api: RuleApi) -> void:
	var origin: Vector3i = ctx.data.get("cell", Vector3i(-1, -1, -1))
	var stamp: int = int(ctx.data.get("clear_count", 0))
	for direction: Vector3i in FACES:
		var cell: Vector3i = origin + direction
		if not api.is_active(cell) or int(_hit_stamps.get(cell, -1)) == stamp: continue
		var status: Dictionary = api.record_at(cell).get("status", {}).duplicate(true)
		if not bool(status.get("rock", false)): continue
		_hit_stamps[cell] = stamp
		var left: int = maxi(0, int(status.get("hits_left", 2)) - 1)
		if left == 0:
			api.remove_cell(cell, BoardState.Cause.DAMAGE)
			api.emit(&"rock_broken", {"cell": cell})
		else:
			status["hits_left"] = left
			api.set_status(cell, status)
			api.emit(&"rock_cracked", {"cell": cell, "hits_left": left})

func snapshot() -> Dictionary:
	return {"locks": _locks, "marked": _marked, "target": _target, "hit_stamps": _hit_stamps.duplicate(true)}
