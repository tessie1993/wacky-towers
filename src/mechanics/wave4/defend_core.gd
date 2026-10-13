class_name DefendCoreRule extends RuleBehaviour
## Wave 4 defender levels (brief rule `defend_core`; telegraph conventions from
## design/gdd/minigame-mechanics-wave4.md §2/§A5). A core tile group (`core`, [x, z] list, default the 2×2 board
## centre) sits on layer 0. Every `attack_every_ms` a projectile, announced `warn_ms` earlier, enters at a seeded
## edge column (api.rng(), so it follows the round seed) and travels inward along that lane: the first column with
## cubes loses its top cube (armour); reaching an empty core column deals `core_damage`. At hp 0 the run fails via
## `api.request_fail(&"core_destroyed")`. The level goal still decides the win.
## HUD events: `defend {hp, next_ms, column}` on every schedule/hit, `defend_core {cells, hp}` at start,
## `defend_warning {column, dir, due_ms}`, `defend_hit {column, tile, cell, result, hp}` (result armour/core/fizzle),
## `defend_core_lost {}`.
const PLUGIN_ID := &"defend_core"
const NO_CELL := Vector3i(-1, -1, -1)
var _hp: int = -1
var _due: int = -1
var _warned: bool = false
var _column: Vector2i = Vector2i(-1, -1)
var _lost: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_tick"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if _lost:
		return
	if hook == &"on_level_start" or _hp < 0:
		_hp = maxi(1, int(api.param(&"core_hp", 3)))
		api.emit(&"defend_core", {"cells": core_tiles(api), "hp": _hp})
		_schedule(api)
		return
	if _due < 0:
		return
	var now: int = api.time_ms()
	if not _warned and now >= _due - maxi(0, int(api.param(&"warn_ms", 2000))):
		_warned = true
		api.emit(&"defend_warning", {"column": _column, "dir": lane_dir(api, _column), "due_ms": _due})
	if now >= _due:
		_fire(api)
		if not _lost:
			_schedule(api)


## Core tiles from the `core` param, or the 2×2 board centre when it is empty.
static func core_tiles(api: RuleApi) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = Wave3Cells.tiles(api.param(&"core", []))
	if not tiles.is_empty():
		return tiles
	var size: Vector3i = api.board_size()
	var x0: int = maxi(0, (size.x - 2) / 2)
	var z0: int = maxi(0, (size.z - 2) / 2)
	for dx: int in 2:
		for dz: int in 2:
			if x0 + dx < size.x and z0 + dz < size.z:
				tiles.append(Vector2i(x0 + dx, z0 + dz))
	return tiles


## Active floor tiles on the board rim, canonical order.
static func edge_tiles(api: RuleApi) -> Array[Vector2i]:
	var size: Vector3i = api.board_size()
	var result: Array[Vector2i] = []
	for t: Vector2i in Wave3Cells.floor_tiles(api):
		if t.x == 0 or t.x == size.x - 1 or t.y == 0 or t.y == size.z - 1:
			result.append(t)
	return result


## Inward step for a projectile entering at an edge tile (x edges first, as corners need a single answer).
static func lane_dir(api: RuleApi, tile: Vector2i) -> Vector2i:
	var size: Vector3i = api.board_size()
	if tile.x == 0:
		return Vector2i(1, 0)
	if tile.x == size.x - 1:
		return Vector2i(-1, 0)
	if tile.y == 0:
		return Vector2i(0, 1)
	return Vector2i(0, -1)


## Highest occupied cell of a column, or NO_CELL.
static func top_cell(api: RuleApi, tile: Vector2i) -> Vector3i:
	var cells: Array[Vector3i] = Wave3Cells.column(api, tile)
	for k: int in range(cells.size() - 1, -1, -1):
		if api.is_active(cells[k]) and api.kind_at(cells[k]) != 0:
			return cells[k]
	return NO_CELL


func _schedule(api: RuleApi) -> void:
	var tiles: Array[Vector2i] = edge_tiles(api)
	_warned = false
	if tiles.is_empty():
		_due = -1
		_column = Vector2i(-1, -1)
		return
	_column = tiles[0] if tiles.size() == 1 else tiles[api.rng().randi_range(0, tiles.size() - 1)]
	_due = api.time_ms() + maxi(1, int(api.param(&"attack_every_ms", 12000)))
	api.emit(&"defend", {"hp": _hp, "next_ms": _due, "column": _column})


func _fire(api: RuleApi) -> void:
	var core: Array[Vector2i] = core_tiles(api)
	var dir: Vector2i = lane_dir(api, _column)
	var size: Vector3i = api.board_size()
	var tile: Vector2i = _column
	while tile.x >= 0 and tile.x < size.x and tile.y >= 0 and tile.y < size.z:
		var top: Vector3i = top_cell(api, tile)
		if top != NO_CELL:
			api.remove_cell(top, BoardState.Cause.DAMAGE)
			api.emit(&"defend_hit", {"column": _column, "tile": tile, "cell": top, "result": &"armour", "hp": _hp})
			return
		if core.has(tile):
			_hp = maxi(0, _hp - maxi(1, int(api.param(&"core_damage", 1))))
			api.emit(&"defend_hit", {"column": _column, "tile": tile, "cell": NO_CELL, "result": &"core", "hp": _hp})
			if _hp == 0:
				_lost = true
				_due = -1
				api.emit(&"defend", {"hp": 0, "next_ms": -1, "column": _column})
				api.emit(&"defend_core_lost", {})
				api.request_fail(&"core_destroyed")
			return
		tile += dir
	api.emit(&"defend_hit", {"column": _column, "tile": tile, "cell": NO_CELL, "result": &"fizzle", "hp": _hp})


func snapshot() -> Dictionary:
	return {"hp": _hp, "due": _due, "warned": _warned, "column": _column, "lost": _lost}
