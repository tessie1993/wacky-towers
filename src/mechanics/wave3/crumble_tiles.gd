class_name CrumbleTilesRule extends RuleBehaviour
## W2: cracked floor tiles break after N locks touch them; the column above drops one cell.
const PLUGIN_ID := &"crumble_tiles"
var _tiles: Array[Vector2i] = []
var _counts: Dictionary = {}
var _spent: Array[Vector2i] = []


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_lock"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_counts.clear()
		_spent.clear()
		_tiles.clear()
		var declared: Array[Vector2i] = Wave3Cells.tiles(api.param(&"tiles", []))
		if declared.is_empty():
			declared = Wave3Cells.pick_floor_tiles(api, 2)
		for tile: Vector2i in declared:
			if api.is_active(Wave3Cells.base_cell(api, tile)) and not _tiles.has(tile):
				_tiles.append(tile)
		api.emit(&"crumble_tiles_state", {"tiles": _tiles.duplicate()})
		return
	var after: int = maxi(1, int(api.param(&"crumble_after", 3)))
	var cells: Array = ctx.data.get("cells", [])
	for tile: Vector2i in _tiles:
		if _spent.has(tile) or not cells.has(Wave3Cells.base_cell(api, tile)):
			continue
		var count: int = int(_counts.get(tile, 0)) + 1
		_counts[tile] = count
		var base: Vector3i = Wave3Cells.base_cell(api, tile)
		if count >= after:
			Wave3Cells.sink_column(api, tile, BoardState.Cause.DAMAGE)
			_spent.append(tile)
			api.emit(&"tile_crumbled", {"cell": base})
		elif count == after - 1:
			api.emit(&"tile_cracking", {"cell": base, "locks_left": 1})


func snapshot() -> Dictionary:
	return {"tiles": _tiles.duplicate(), "counts": _counts.duplicate(), "spent": _spent.duplicate()}
