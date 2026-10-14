class_name TrackEffects extends RefCounted
## Reads the stack and turns track events into lean impulses, cargo stress and lift (gap G8). Deterministic and
## dice-free. The only board write is clear_all() for a restart. Only boards whose down direction is -y are supported (layer == y).
## Writes queue until the hook boundary, so this class keeps an overlay of its own pending removals.
## Usage: var fx := TrackEffects.new(api, def); var lean: Vector2i = fx.com_pm().

var _api: RuleApi
var _def: TrackDef
var _overlay: Dictionary = {}  # Vector3i -> bool occupied, our own pending writes


## Binds the facade and the track tuning. Both are required.
func _init(api: RuleApi, def: TrackDef) -> void:
	assert(api != null and def != null, "TrackEffects needs api and def")
	_api = api
	_def = def


## Applies event `e` and returns {"impulse": Vector2i, "stress_pm": int, "gap_layers": int, "lift_pm_per_s": int};
## keys appear only for kinds that use them. Impulses are normalised for the board (crosswind by height, gust by
## height times fill of the footprint) and capped by the kind's impulse_cap_pm. Nothing here changes the board:
## the arch is a pure height gate (the runner charges the heart) and the platform topples as a whole.
func apply(e: Dictionary) -> Dictionary:
	var cfg: Dictionary = _def.effects[String(e["kind"])] as Dictionary
	var layers: int = stack_layers()
	var size: Vector3i = _api.board_size()
	var cap: int = int(cfg.get("impulse_cap_pm", 0))
	match e["kind"]:
		TrackDef.KIND_BUMP:
			var amp: int = mini(cap, int(cfg["impulse_pm_per_force"]) * int(e["force"]))
			return {"impulse": _toward_heavy(e, amp), "stress_pm": int(cfg["cargo_stress_pm_per_force"]) * int(e["force"])}
		TrackDef.KIND_CLOUD_BUMP:
			var amp: int = mini(cap, int(cfg["impulse_pm_per_force"]) * int(e["force"]))
			return {"impulse": TrackDef.DIRS[String(e["dir"])] * amp, "stress_pm": int(cfg["cargo_stress_pm_per_force"]) * int(e["force"])}
		TrackDef.KIND_CROSSWIND:
			var amp: int = mini(cap, int(cfg["impulse_pm_per_layer_strength"]) * layers * int(e["strength"]))
			return {"impulse": TrackDef.DIRS[String(e["dir"])] * amp, "stress_pm": int(cfg["cargo_stress_pm_per_strength"]) * int(e["strength"])}
		TrackDef.KIND_GUST:
			var amp: int = mini(cap, int(cfg["impulse_pm_per_layer_fill"]) * int(e["strength"]) * layers * cell_count() / maxi(1, size.x * size.z))
			return {"impulse": TrackDef.DIRS[String(e["dir"])] * amp, "stress_pm": int(cfg["cargo_stress_pm_per_strength"]) * int(e["strength"])}
		TrackDef.KIND_UPDRAFT:
			return {"lift_pm_per_s": int(cfg["lift_pm_per_s"]) * lightness_pct() / 100}
		TrackDef.KIND_ARCH:
			return {"gap_layers": int(e["gap_layers"])}
	return {}


## How light the build is for the kite, 100 for an empty deck down to min_lightness_pct at heavy_cells or more.
func lightness_pct() -> int:
	var cfg: Dictionary = _def.effects.get("updraft", {}) as Dictionary
	if cfg.is_empty():
		return 100
	var lightness: int = 100 - cell_count() * 100 / maxi(1, int(cfg["heavy_cells"]))
	return clampi(lightness, int(cfg["min_lightness_pct"]), 100)


## Surface height per column: Vector2i(x, z) -> highest occupied layer + 1 (0 when empty), for active columns.
func heights() -> Dictionary:
	var out: Dictionary = {}
	var size: Vector3i = _api.board_size()
	for z: int in size.z:
		for x: int in size.x:
			var top: int = 0
			for y: int in range(size.y - 1, -1, -1):
				if _occupied(Vector3i(x, y, z)):
					top = y + 1
					break
			out[Vector2i(x, z)] = top
	return out


## Number of occupied cells.
func cell_count() -> int:
	return _cells().size()


## Height of the tallest column, in layers.
func stack_layers() -> int:
	var tallest: int = 0
	for h: Variant in heights().values():
		tallest = maxi(tallest, int(h))
	return tallest


## Centre of mass against the platform centre, per axis in permille of the half-width (signed, integer).
## An empty stack is (0, 0). A block on the very edge cell reads (W-1)/W * 1000.
func com_pm() -> Vector2i:
	var cells: Array[Vector3i] = _cells()
	if cells.is_empty():
		return Vector2i.ZERO
	var size: Vector3i = _api.board_size()
	var sx: int = 0
	var sz: int = 0
	for c: Vector3i in cells:
		sx += 2 * c.x + 1 - size.x
		sz += 2 * c.z + 1 - size.z
	return Vector2i(sx * 1000 / (cells.size() * size.x), sz * 1000 / (cells.size() * size.z))


## Where the cargo sits: on the highest column. Ties go to the best supported seat, then the one nearest the
## centre, then lowest z, then lowest x. Returns {"x", "z", "h" (layers), "support" (of 9 footprint columns)}.
## `h` is 0 and support 9 on an empty deck.
func seat() -> Dictionary:
	var hs: Dictionary = heights()
	var size: Vector3i = _api.board_size()
	var best: Dictionary = {"x": size.x / 2, "z": size.z / 2, "h": 0, "support": 9}
	var best_key: Array[int] = [-1, 0, 0, 0, 0]
	for z: int in size.z:
		for x: int in size.x:
			var h: int = int(hs[Vector2i(x, z)])
			var sup: int = _support(hs, x, z, h)
			var centre: int = absi(2 * x + 1 - size.x) + absi(2 * z + 1 - size.z)
			var key: Array[int] = [h, sup, -centre, -z, -x]
			if _key_greater(key, best_key):
				best_key = key
				best = {"x": x, "z": z, "h": h, "support": sup}
	return best


## True when the seat meets the cargo's minimum support (a wide enough, level enough top).
func seat_is_stable(s: Dictionary) -> bool:
	return int(s["support"]) >= int(_def.cargo["min_support_cells"])


## Wipes the whole board in write order (after anything already queued) and forgets the overlay.
func clear_all() -> void:
	_api.request_wipe(BoardState.Cause.CLEAR)
	_overlay.clear()
	for c: Vector3i in _all_cells():
		_overlay[c] = false


## Bump direction: pushes the existing heavy side further; a centred stack takes the event's dir if it has one.
func _toward_heavy(e: Dictionary, amp: int) -> Vector2i:
	var com: Vector2i = com_pm()
	if com == Vector2i.ZERO:
		return (TrackDef.DIRS[String(e["dir"])] * amp) if e.has("dir") else Vector2i.ZERO
	if absi(com.x) >= absi(com.y):
		return Vector2i(signi(com.x) * amp, 0)
	return Vector2i(0, signi(com.y) * amp)


func _support(hs: Dictionary, x: int, z: int, h: int) -> int:
	var n: int = 0
	var tol: int = int(_def.cargo["level_tolerance_layers"])
	for dz: int in range(-1, 2):
		for dx: int in range(-1, 2):
			var col := Vector2i(x + dx, z + dz)
			if hs.has(col) and int(hs[col]) >= h - tol:
				n += 1
	return n


func _key_greater(a: Array[int], b: Array[int]) -> bool:
	for i: int in a.size():
		if a[i] != b[i]:
			return a[i] > b[i]
	return false


func _occupied(c: Vector3i) -> bool:
	if _overlay.has(c):
		return bool(_overlay[c])
	return _in_bounds(c) and _api.kind_at(c) != 0


func _in_bounds(c: Vector3i) -> bool:
	var size: Vector3i = _api.board_size()
	return c.x >= 0 and c.y >= 0 and c.z >= 0 and c.x < size.x and c.y < size.y and c.z < size.z


func _all_cells() -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	var size: Vector3i = _api.board_size()
	for y: int in size.y:
		for z: int in size.z:
			for x: int in size.x:
				out.append(Vector3i(x, y, z))
	return out


func _cells() -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	for c: Vector3i in _all_cells():
		if _occupied(c):
			out.append(c)
	return out


func _drop(c: Vector3i, cause: int) -> void:
	_api.clear_cell(c, cause)
	_overlay[c] = false
