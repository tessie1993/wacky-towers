class_name Wave3Cells extends RefCounted
## Shared pure helpers for the wave-3 rules: tile parsing, seeded floor picks and column sinking.
## Tiles are [x, z] ground coordinates; the base cell of a tile is its layer-0 cell.
## Usage: var tiles: Array[Vector2i] = Wave3Cells.tiles(api.param(&"tiles", []))


## Parse a JSON list of [x, z] pairs into Vector2i tiles. Usage: Wave3Cells.tiles([[0, 1]]).
static func tiles(raw: Variant) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if raw is Array:
		for entry: Variant in raw:
			if entry is Array and entry.size() >= 2:
				result.append(Vector2i(int(entry[0]), int(entry[1])))
			elif entry is Vector2i:
				result.append(entry)
	return result


## Layer-0 cell of a ground tile for the current gravity axis. Usage: Wave3Cells.base_cell(api, Vector2i(1, 2)).
static func base_cell(api: RuleApi, tile: Vector2i) -> Vector3i:
	var size: Vector3i = api.board_size()
	var down: Vector3i = api.down_vector()
	var c := Vector3i(tile.x, 0, tile.y)
	if down.y == 0:
		# Horizontal gravity: ground tile coordinates map to the two non-gravity axes.
		c = Vector3i(0, tile.x, tile.y) if down.x != 0 else Vector3i(tile.x, tile.y, 0)
	if down.x > 0 or down.y > 0 or down.z > 0:
		c += Vector3i(size.x - 1 if down.x > 0 else 0, size.y - 1 if down.y > 0 else 0, size.z - 1 if down.z > 0 else 0)
	return c


## All cells of a column from the floor upward (inactive cells included only if inside the box).
static func column(api: RuleApi, tile: Vector2i) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	var base: Vector3i = base_cell(api, tile)
	var up: Vector3i = -api.down_vector()
	for k: int in api.layer_count():
		result.append(base + up * k)
	return result


## Active, in-footprint floor tiles in canonical (x, then z) order.
static func floor_tiles(api: RuleApi) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var size: Vector3i = api.board_size()
	for x: int in size.x:
		for z: int in size.z:
			if api.is_active(base_cell(api, Vector2i(x, z))):
				result.append(Vector2i(x, z))
	return result


## Seeded distinct floor tiles drawn without replacement from api.rng().
static func pick_floor_tiles(api: RuleApi, count: int) -> Array[Vector2i]:
	var pool: Array[Vector2i] = floor_tiles(api)
	var picked: Array[Vector2i] = []
	while picked.size() < count and not pool.is_empty():
		var at: int = 0 if pool.size() == 1 else api.rng().randi_range(0, pool.size() - 1)
		picked.append(pool[at])
		pool.remove_at(at)
	return picked


## Remove the floor cube of a tile and slide the rest of the column down one cell. False if no floor cube.
static func sink_column(api: RuleApi, tile: Vector2i, cause: int) -> bool:
	var cells: Array[Vector3i] = column(api, tile)
	if cells.is_empty() or not api.is_active(cells[0]) or api.kind_at(cells[0]) == 0:
		return false
	api.remove_cell(cells[0], cause)
	var src: Array[Vector3i] = []
	var dst: Array[Vector3i] = []
	for k: int in range(1, cells.size()):
		if api.is_active(cells[k]) and api.kind_at(cells[k]) != 0:
			src.append(cells[k])
			dst.append(cells[k - 1])
	if not src.is_empty():
		api.move_cells(src, dst)
	return true


## Ground coordinates (the gravity axis zeroed) used as a column key.
static func flat_key(api: RuleApi, c: Vector3i) -> Vector3i:
	var down: Vector3i = api.down_vector()
	return Vector3i(0 if down.x != 0 else c.x, 0 if down.y != 0 else c.y, 0 if down.z != 0 else c.z)


## Strict canonical ordering of flat keys. Usage: keys.sort_custom(Wave3Cells.key_less).
static func key_less(a: Vector3i, b: Vector3i) -> bool:
	if a.x != b.x:
		return a.x < b.x
	if a.y != b.y:
		return a.y < b.y
	return a.z < b.z
