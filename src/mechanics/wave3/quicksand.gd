class_name QuicksandRule extends RuleBehaviour
## W13: quicksand tiles swallow the bottom cube of their column every N locks.
const PLUGIN_ID := &"quicksand"
var _tiles: Array[Vector2i] = []
var _locks: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_lock"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_locks = 0
		_tiles.clear()
		var declared: Array[Vector2i] = Wave3Cells.tiles(api.param(&"tiles", []))
		if declared.is_empty():
			declared = Wave3Cells.pick_floor_tiles(api, 1)
		for tile: Vector2i in declared:
			if api.is_active(Wave3Cells.base_cell(api, tile)) and not _tiles.has(tile):
				_tiles.append(tile)
		api.emit(&"quicksand_state", {"tiles": _tiles.duplicate()})
		return
	var every: int = maxi(1, int(api.param(&"sink_every", 4)))
	_locks += 1
	if _locks < every:
		if _locks == every - 1:
			api.emit(&"quicksand_warning", {"tiles": _tiles.duplicate(), "locks_left": 1})
		return
	_locks = 0
	var sunk: Array[Vector2i] = []
	for tile: Vector2i in _tiles:
		if Wave3Cells.sink_column(api, tile, BoardState.Cause.DISPLACED):
			sunk.append(tile)
	if not sunk.is_empty():
		api.emit(&"quicksand_sink", {"tiles": sunk})


func snapshot() -> Dictionary:
	return {"tiles": _tiles.duplicate(), "locks": _locks}
