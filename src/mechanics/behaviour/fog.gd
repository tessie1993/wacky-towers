class_name FogRule extends RuleBehaviour
## Per-lock fade and deterministic ghost-footprint lantern light; collision remains untouched.
##
## Performance contract (review D1, tools/qa/perf/fog_tick_timing.gd): the board scan and the alpha table are
## recomputed only when something that feeds them changed: a lock, a clear, a board mutation (BoardState.revision),
## the lantern footprint moving, or the clock crossing a fade boundary. A quiet tick is a handful of integer compares.
const PLUGIN_ID := &"fog"
var _started: int = -1
var _reveal_until: int = -1
var _alpha_milli: int = 1000
var _locked_at: Dictionary = {}
var _clear_count: int = 0
var _visibility_key: String = ""

# Cached derived state (not part of the snapshot: it is rebuilt from the board and clock).
var _dirty: bool = true
var _seen_revision: int = -1
var _cells: Array[Vector3i] = []
var _uids: PackedInt32Array = PackedInt32Array()
var _ghost: Array[Vector3i] = []
var _ghost_valid: bool = false
## Earliest clock value (ms) at which a cached alpha can change on its own; NO_DEADLINE when the table is stable.
var _next_change_ms: int = NO_DEADLINE
var _last_alphas: PackedFloat32Array = PackedFloat32Array()
var _emitted_once: bool = false

const NO_DEADLINE := -1

func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_tick", &"on_lock", &"on_clear"]

func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var now: int = api.time_ms()
	if hook == &"on_lock":
		_locked_at[int(ctx.data.get("uid", api.get_piece_uid()))] = now
		_dirty = true
	elif hook == &"on_clear":
		_clear_count = int(ctx.data.get("clear_count", _clear_count + 1))
		_reveal_until = now + maxi(1, int(api.param(&"reveal_ms", 600)))
		_dirty = true
	elif hook == &"on_spawn":
		_dirty = true
	if _clear_count < int(api.param(&"active_after_clears", 0)):
		return
	if _started < 0:
		_started = now
		_dirty = true
	var radius: int = maxi(0, int(api.param(&"lantern_radius", 0)))
	if radius > 0 and _refresh_ghost(api):
		_dirty = true
	var revision: int = api.board_revision()
	if revision != _seen_revision:
		_dirty = true
	elif not _dirty and (_next_change_ms == NO_DEADLINE or now < _next_change_ms):
		return
	if revision != _seen_revision:
		_rebuild_cells(api)
		_seen_revision = revision
	_dirty = false
	_recompute(api, now, radius)

## Recomputes the lantern footprint; returns true when it moved since the last call.
func _refresh_ghost(api: RuleApi) -> bool:
	var ghost: Array[Vector3i] = []
	var piece: Array[Vector3i] = api.piece_cells()
	if not piece.is_empty():
		var shift: Vector3i = api.down_vector() * api.cast(piece, api.down_vector())
		for cell: Vector3i in piece:
			ghost.append(cell + shift)
		if api.rule_active(&"mirror"):
			var axis: int = 2 if str(api.param(&"mirror_axis", "x")) == "z" else 0
			var size: Vector3i = api.board_size()
			for cell: Vector3i in ghost.duplicate():
				var twin: Vector3i = cell
				twin[axis] = size[axis] - 1 - cell[axis]
				ghost.append(twin)
	var moved: bool = not _ghost_valid or ghost != _ghost
	_ghost = ghost
	_ghost_valid = true
	return moved

func _rebuild_cells(api: RuleApi) -> void:
	_cells = MechanicsCells.occupied(api)
	_uids.resize(_cells.size())
	for i: int in _cells.size():
		_uids[i] = int(api.record_at(_cells[i]).get("piece_instance_id", 0))

func _recompute(api: RuleApi, now: int, radius: int) -> void:
	var visible_ms: int = maxi(0, int(api.param(&"visible_ms", 5000)))
	var fade_ms: int = maxi(1, int(api.param(&"fade_ms", 1000)))
	var minimum: float = clampf(float(api.param(&"invisible_alpha", 0.1)), 0.0, 1.0)
	var revealing: bool = now < _reveal_until
	var next_change: int = _reveal_until if revealing else NO_DEADLINE
	var alphas: Array[Dictionary] = []
	var packed: PackedFloat32Array = PackedFloat32Array()
	var lantern: Array[Vector3i] = []
	var empty_fade: float = clampf(float(now - _started - visible_ms) / float(fade_ms), 0.0, 1.0)
	var dimmest: float = (1.0 if revealing else lerpf(1.0, minimum, empty_fade)) if _cells.is_empty() else 1.0
	if _cells.is_empty():
		next_change = _min_deadline(next_change, _fade_deadline(now, _started, visible_ms, fade_ms))
	for i: int in _cells.size():
		var cell: Vector3i = _cells[i]
		var born: int = int(_locked_at.get(_uids[i], _started))
		var fade: float = clampf(float(now - born - visible_ms) / float(fade_ms), 0.0, 1.0)
		var alpha: float = 1.0 if revealing else lerpf(1.0, minimum, fade)
		if not revealing:
			next_change = _min_deadline(next_change, _fade_deadline(now, born, visible_ms, fade_ms))
		for target: Vector3i in _ghost:
			if maxi(absi(cell.x - target.x), absi(cell.z - target.z)) <= radius:
				alpha = 1.0
				lantern.append(cell)
				break
		dimmest = minf(dimmest, alpha)
		alphas.append({"cell": cell, "alpha": alpha})
		packed.append(alpha)
	_next_change_ms = next_change
	_alpha_milli = int(roundf(dimmest * 1000.0))
	if _emitted_once and packed == _last_alphas and _visibility_key.begins_with("%d:" % _seen_revision):
		return
	_emitted_once = true
	_last_alphas = packed
	_visibility_key = "%d:%d" % [_seen_revision, packed.to_byte_array().hex_encode().hash()]
	api.emit(&"fog_visibility", {"alpha_milli": _alpha_milli, "alpha": dimmest, "cell_alphas": alphas, "lantern_cells": lantern})

## Next clock value at which a fade that is not yet finished changes alpha: the fade start, or every tick while fading.
func _fade_deadline(now: int, born: int, visible_ms: int, fade_ms: int) -> int:
	var start: int = born + visible_ms
	if now < start:
		return start
	if now < start + fade_ms:
		return now + 1
	return NO_DEADLINE

func _min_deadline(a: int, b: int) -> int:
	if a == NO_DEADLINE:
		return b
	if b == NO_DEADLINE:
		return a
	return mini(a, b)

func snapshot() -> Dictionary:
	return {"started": _started, "reveal_until": _reveal_until, "alpha_milli": _alpha_milli,
		"locked_at": _locked_at.duplicate(true), "clear_count": _clear_count, "visibility_key": _visibility_key}
