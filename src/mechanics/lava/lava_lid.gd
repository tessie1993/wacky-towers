class_name LavaLidRule extends RuleBehaviour
## EV06 lid variant: bounded soft ceiling pressure, relieved and cancelled by clears.
const PLUGIN_ID := &"lava_lid"
var _base: int = -1
var _height: int = -1
var _clears: int = 0
var _due: int = -1
var _warned: bool = false
var _pending: bool = false

func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_tick", &"on_clear", &"on_resolve_end"]

func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if _base < 0:
		_base = api.limit_layer()
		_height = _base
		_due = api.now_ms() + maxi(0, roundi(float(api.param(&"lid_first_s", 60)) * 1000))
	if hook == &"on_clear":
		var total: int = int(ctx.data.get("clear_count", _clears))
		var added: int = maxi(0, total - _clears)
		_clears = maxi(_clears, total)
		if added > 0:
			_height = mini(_base, _height + added * maxi(0, int(api.param(&"lid_push_per_clear", 1))))
			api.request_height_limit(_height)
			api.emit(&"lid_lifted", {"height": _height, "layers_cleared": added})
			if _warned or _pending:
				api.emit(&"lid_cancelled", {"height": _height})
				_schedule(api)
			return
	if not _warned and api.now_ms() >= _due - maxi(0, int(api.param(&"lid_warn_ms", 3000))):
		_warned = true
		api.emit(&"lid_warning", {"height": _height, "due_ms": _due})
		api.emit(&"warning", {"message": "Moon's pillow lowers soon — clear to lift it!"})
	if api.now_ms() >= _due: _pending = true
	if hook != &"on_resolve_end" or not _pending: return
	var maximum: int = clampi(int(api.param(&"lid_max", 2)), 0, maxi(0, _base - 1))
	var next_height: int = maxi(_base - maximum, _height - 1)
	var removed: Array[Vector3i] = []
	if next_height < _height:
		for cell: Vector3i in MechanicsCells.occupied(api):
			var status: Dictionary = api.record_at(cell).get("status", {})
			if api.layer_of(cell) >= next_height and not bool(status.get("vined", false)) and not bool(status.get("anchored", false)):
				api.remove_cell(cell, BoardState.Cause.TRIM)
				removed.append(cell)
		_height = next_height
		api.request_height_limit(_height)
		api.emit(&"lid_lowered", {"height": _height, "trimmed_cells": removed})
	_schedule(api)

func _schedule(api: RuleApi) -> void:
	_due = api.now_ms() + maxi(1000, roundi(float(api.param(&"lid_every_s", 40)) * 1000))
	_warned = false
	_pending = false

func snapshot() -> Dictionary:
	return {"base": _base, "height": _height, "clears": _clears, "due": _due, "warned": _warned, "pending": _pending}
