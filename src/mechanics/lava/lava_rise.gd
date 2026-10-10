class_name LavaRiseRule extends RuleBehaviour
## Campaign EV06: fixed danger line, progressively inactive bottom planes, no collapse.
const PLUGIN_ID := &"lava_rise"
var _due: int = -1
var _melted: int = 0
var _warned: bool = false
var _pending: bool = false
var _cooled: bool = false

func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_tick", &"on_resolve_end"]

func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var maximum: int = clampi(int(api.param(&"melt_max", 3)), 0, maxi(0, api.limit_layer() - 1))
	if _cooled or maximum == 0: return
	if _due < 0:
		_due = api.now_ms() + maxi(0, roundi(float(api.param(&"first_s", api.param(&"melt_every_s", 35))) * 1000))
	var warning: int = maxi(0, int(api.param(&"melt_warn_ms", 3000)))
	if not _warned and api.now_ms() >= _due - warning:
		_warned = true
		api.emit(&"lava_warning", {"layer": _melted, "due_ms": _due, "warning_ms": warning})
		api.emit(&"warning", {"message": "Lava rises soon — finish the lowest layer!"})
	if api.now_ms() >= _due: _pending = true
	if hook != &"on_resolve_end" or not _pending: return
	var lost: Array[Vector3i] = []
	for cell: Vector3i in MechanicsCells.occupied(api):
		if api.layer_of(cell) == _melted: lost.append(cell)
	_melted += 1
	api.request_floor(_melted)
	api.emit(&"lava_rise", {"floor_layer": _melted, "lost_cells": lost, "rises_remaining": maximum - _melted})
	_pending = false
	_warned = false
	if _melted >= maximum:
		_cooled = true
		api.emit(&"lava_cooled", {"floor_layer": _melted})
	else:
		_due = api.now_ms() + maxi(1000, roundi(float(api.param(&"melt_every_s", 35)) * 1000))

func snapshot() -> Dictionary:
	return {"due": _due, "melted": _melted, "warned": _warned, "pending": _pending, "cooled": _cooled}
