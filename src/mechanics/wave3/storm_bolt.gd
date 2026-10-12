class_name StormBoltRule extends RuleBehaviour
## W11: a telegraphed lightning bolt zaps the top cube of a seeded column.
const PLUGIN_ID := &"storm_bolt"
var _due: int = -1
var _warned: bool = false
var _column: Vector3i = Vector3i(-1, -1, -1)


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_tick"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_schedule(api)
		return
	if _due < 0:
		return
	var now: int = api.time_ms()
	if not _warned and now >= _due - maxi(0, int(api.param(&"bolt_warn_ms", 1500))):
		_warned = true
		var columns: Array[Vector3i] = _occupied_columns(api)
		if columns.is_empty():
			_schedule(api)
			return
		_column = columns[0] if columns.size() == 1 else columns[api.rng().randi_range(0, columns.size() - 1)]
		api.emit(&"bolt_warning", {"column": _column, "due_ms": _due})
	if now >= _due and _warned:
		var top: Vector3i = _top_cell(api, _column)
		if top.x < 0:
			api.emit(&"bolt_fizzle", {"column": _column})
		else:
			api.remove_cell(top, BoardState.Cause.DAMAGE)
			api.emit(&"bolt_strike", {"cell": top})
		_schedule(api)


func _schedule(api: RuleApi) -> void:
	var jitter: int = maxi(0, int(api.param(&"bolt_jitter_ms", 2000)))
	var delta: int = api.rng().randi_range(-jitter, jitter) if jitter > 0 else 0
	_due = api.time_ms() + maxi(1000, int(api.param(&"bolt_interval_ms", 9000)) + delta)
	_warned = false
	_column = Vector3i(-1, -1, -1)


func _occupied_columns(api: RuleApi) -> Array[Vector3i]:
	var seen: Dictionary = {}
	for c: Vector3i in MechanicsCells.occupied(api):
		seen[Wave3Cells.flat_key(api, c)] = true
	var keys: Array = seen.keys()
	keys.sort_custom(Wave3Cells.key_less)
	var result: Array[Vector3i] = []
	result.assign(keys)
	return result


## Highest occupied cell of a column, or (-1, -1, -1) when empty.
func _top_cell(api: RuleApi, key: Vector3i) -> Vector3i:
	var best := Vector3i(-1, -1, -1)
	var best_layer: int = -1
	for c: Vector3i in MechanicsCells.occupied(api):
		if Wave3Cells.flat_key(api, c) == key and api.layer_of(c) > best_layer:
			best = c
			best_layer = api.layer_of(c)
	return best


func snapshot() -> Dictionary:
	return {"due": _due, "warned": _warned, "column": _column}
