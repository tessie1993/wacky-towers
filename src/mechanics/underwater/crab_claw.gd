class_name CrabClawRule extends RuleBehaviour
## EV16 warns a column, steals only its top cube, and cancels on any warning-time clear.
const PLUGIN_ID := &"crab_claw"
var _clears: int = 0
var _due: int = -1
var _warned: bool = false
var _pending: bool = false
var _has_target: bool = false
var _column := Vector3i.ZERO

func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_tick", &"on_clear", &"on_resolve_end"]

func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_clear":
		_clears = maxi(_clears, int(ctx.data.get("clear_count", _clears)))
		if _warned and String(api.param(&"counter", "clear")) == "clear":
			api.emit(&"claw_cancelled", {"column": _column, "reason": "clear"})
			_pending = false
			_has_target = false
			_schedule(api)
	if _clears < maxi(0, int(api.param(&"claw_start_layers", 2))): return
	if _due < 0: _schedule(api)
	if not _warned and api.now_ms() >= _due - maxi(0, int(api.param(&"claw_warn_ms", 2000))):
		_warned = true
		var candidates: Array[Vector3i] = _tops(api)
		if not candidates.is_empty():
			var target: Vector3i = MechanicsCells.pick(api, candidates)
			_column = _column_of(target, api.down_vector())
			_has_target = true
			api.emit(&"claw_warning", {"column": _column, "cell": target, "due_ms": _due})
			api.emit(&"warning", {"message": "Crab's claw — clear a layer to cancel!"})
		else: api.emit(&"claw_nap", {})
	if api.now_ms() >= _due: _pending = true
	if hook != &"on_resolve_end" or not _pending: return
	if _has_target and clampi(int(api.param(&"claw_grab", 1)), 0, 1) == 1:
		for cell: Vector3i in _tops(api):
			if _column_of(cell, api.down_vector()) == _column:
				api.remove_cell(cell, BoardState.Cause.DISPLACED)
				api.emit(&"crab_claw", {"column": _column, "cell": cell})
				break
	_pending = false
	_has_target = false
	_schedule(api)

func _tops(api: RuleApi) -> Array[Vector3i]:
	var counts: Dictionary = {}
	var tops: Dictionary = {}
	var result: Array[Vector3i] = []
	var down: Vector3i = api.down_vector()
	var falling: Array[Vector3i] = api.piece_cells()
	for cell: Vector3i in MechanicsCells.occupied(api):
		var key: Vector3i = _column_of(cell, down)
		counts[key] = int(counts.get(key, 0)) + 1
		if not tops.has(key) or api.layer_of(cell) > api.layer_of(tops[key]): tops[key] = cell
	var keys: Array = tops.keys()
	keys.sort_custom(func(a: Vector3i, b: Vector3i) -> bool: return a.x < b.x if a.x != b.x else (a.z < b.z if a.z != b.z else a.y < b.y))
	for key: Vector3i in keys:
		var cell: Vector3i = tops[key]
		if int(counts[key]) < 2 or api.layer_of(cell) < 1: continue
		if not api.kind_at(cell) in [api.kind_of(&"block"), api.kind_of(&"starter")]: continue
		var status: Dictionary = api.record_at(cell).get("status", {})
		if bool(status.get("locked", false)) or bool(status.get("fixed", false)): continue
		var guarded: bool = false
		for piece_cell: Vector3i in falling:
			if _column_of(piece_cell, down) == key: guarded = true
		if not guarded: result.append(cell)
	return result

func _column_of(cell: Vector3i, down: Vector3i) -> Vector3i:
	return Vector3i(0 if down.x != 0 else cell.x, 0 if down.y != 0 else cell.y, 0 if down.z != 0 else cell.z)

func _schedule(api: RuleApi) -> void:
	var jitter: int = maxi(0, int(api.param(&"claw_jitter_ms", 4000)))
	_due = api.now_ms() + maxi(1000, int(api.param(&"claw_every_ms", 20000)) + (api.rng().randi_range(-jitter, jitter) if jitter > 0 else 0))
	_warned = false

func snapshot() -> Dictionary:
	return {"clears": _clears, "due": _due, "warned": _warned, "pending": _pending, "has_target": _has_target, "column": _column}
