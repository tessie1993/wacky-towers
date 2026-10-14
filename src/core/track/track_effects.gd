class_name TrackEffects extends RefCounted
## Applies one track event to the stack through the RuleApi write facade (gap G8).
## Writes queue until the hook boundary, so this class keeps a local overlay of its own pending changes and
## reads through it; two events in one tick would otherwise see stale cells. Only boards whose down
## direction is -y are supported (the cart and the basket are both upright): layer == y.
## Usage: var fx := TrackEffects.new(api, rng, def); var result: Dictionary = fx.apply(event).

var _api: RuleApi
var _rng: RandomNumberGenerator
var _def: TrackDef
var _overlay: Dictionary = {}  # Vector3i -> bool occupied, our own pending writes


## Binds the facade, the track's seeded stream and the track tuning. All three are required.
func _init(api: RuleApi, rng: RandomNumberGenerator, def: TrackDef) -> void:
	assert(api != null and rng != null and def != null, "TrackEffects needs api, rng and def")
	_api = api
	_rng = rng
	_def = def


## Applies event `e` and returns {"mutated": bool, "removed": int, "moved": int, "gap_layers": int, "lift_pct": int}.
## Keys other than "mutated" appear only for kinds that use them.
func apply(e: Dictionary) -> Dictionary:
	var kind: StringName = e["kind"]
	var cfg: Dictionary = _def.effects.get(String(kind), {}) as Dictionary
	match kind:
		TrackDef.KIND_BUMP, TrackDef.KIND_CLOUD_BUMP:
			return _bump(e, cfg)
		TrackDef.KIND_ARCH:
			return _arch(e, cfg)
		TrackDef.KIND_CROSSWIND:
			return _crosswind(e, cfg)
		TrackDef.KIND_UPDRAFT:
			return {"mutated": false, "lift_pct": int(cfg.get("lift_pct", 0))}
	return {"mutated": false}


## Contiguous occupied cells in column (x, z) from the floor up, through pending changes. The cargo's seat height.
func column_height(x: int, z: int) -> int:
	var h: int = 0
	while h < _api.board_size().y and _occupied(Vector3i(x, h, z)):
		h += 1
	return h


## True when c is occupied now or by our pending writes.
func _occupied(c: Vector3i) -> bool:
	if _overlay.has(c):
		return bool(_overlay[c])
	return _in_bounds(c) and _api.kind_at(c) != 0


func _in_bounds(c: Vector3i) -> bool:
	var size: Vector3i = _api.board_size()
	return c.x >= 0 and c.y >= 0 and c.z >= 0 and c.x < size.x and c.y < size.y and c.z < size.z


func _cells() -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	var size: Vector3i = _api.board_size()
	for y: int in size.y:
		for z: int in size.z:
			for x: int in size.x:
				var c := Vector3i(x, y, z)
				if _occupied(c):
					out.append(c)
	return out


func _loose(c: Vector3i) -> bool:
	return c.y > 0 and not _occupied(c + Vector3i(0, -1, 0))


func _drop(c: Vector3i, cause: int) -> void:
	_api.clear_cell(c, cause)
	_overlay[c] = false


func _bump(e: Dictionary, cfg: Dictionary) -> Dictionary:
	var force: int = maxi(1, int(e.get("force", 1)))
	var removed: int = 0
	for c: Vector3i in _cells():
		var pct: int = 0
		if _loose(c):
			pct += int(cfg.get("loose_pct_per_force", 0)) * force
		if c.y >= int(cfg.get("tall_layer", 1 << 20)):
			pct += int(cfg.get("tall_pct_per_force", 0)) * force
		if pct > 0 and _rng.randi_range(0, 99) < mini(pct, 100):
			_drop(c, BoardState.Cause.DISPLACED)
			removed += 1
	return {"mutated": removed > 0, "removed": removed}


func _arch(e: Dictionary, _cfg: Dictionary) -> Dictionary:
	var gap: int = int(e.get("gap_layers", 0))
	var removed: int = 0
	for c: Vector3i in _cells():
		if c.y >= gap:
			_drop(c, BoardState.Cause.TRIM)
			removed += 1
	return {"mutated": removed > 0, "removed": removed, "gap_layers": gap}


func _crosswind(e: Dictionary, cfg: Dictionary) -> Dictionary:
	var dir: Vector3i = _direction(String(e.get("dir", "+x")))
	var cells: Array[Vector3i] = _cells()
	# Leeward cells first so a slide never lands on a cell that has not moved yet.
	cells.sort_custom(func(a: Vector3i, b: Vector3i) -> bool: return a.x * dir.x + a.z * dir.z > b.x * dir.x + b.z * dir.z)
	var moved: int = 0
	var removed: int = 0
	for c: Vector3i in cells:
		if not _loose(c) or _rng.randi_range(0, 99) >= int(cfg.get("slide_pct", 0)):
			continue
		var dst: Vector3i = c + dir
		if not _in_bounds(dst):
			if bool(cfg.get("blow_off_edge", false)):
				_drop(c, BoardState.Cause.DISPLACED)
				removed += 1
		elif _api.is_active(dst) and not _occupied(dst):
			_api.move_cell(c, dst)
			_overlay[c] = false
			_overlay[dst] = true
			moved += 1
	return {"mutated": moved + removed > 0, "moved": moved, "removed": removed}


func _direction(token: String) -> Vector3i:
	match token:
		"-x": return Vector3i(-1, 0, 0)
		"+z": return Vector3i(0, 0, 1)
		"-z": return Vector3i(0, 0, -1)
	return Vector3i(1, 0, 0)
