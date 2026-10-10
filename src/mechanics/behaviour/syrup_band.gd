class_name SyrupBandRule extends RuleBehaviour
## EV25: slow above authored rows, glide once on landing, then lock.
const PLUGIN_ID := &"syrup_band"
var _glided: bool = false
var _gravity_scale: int = -1
var _preview: String = ""


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_spawn", &"on_tick", &"on_land"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		api.emit(&"syrup_band", {"rows": api.param(&"band_rows", [1, 2]), "direction": _direction(api)})
		return
	if hook == &"on_spawn":
		_glided = false
		_preview = ""
	if hook == &"on_spawn" or hook == &"on_tick":
		var cells: Array[Vector3i] = api.piece_cells()
		if cells.is_empty():
			return
		var scale_value: int = int(roundf(clampf(float(api.param(&"syrup_slow", 0.5)), 0.1, 1.0) * 1000.0)) if _over_band(cells, api) else 1000
		if scale_value != _gravity_scale:
			_gravity_scale = scale_value
			api.request_slot(&"fall.gravity_scale", scale_value)
		var predicted: Array[Vector3i] = _landing(cells, api)
		var key: String = str(predicted)
		if key != _preview:
			_preview = key
			api.emit(&"syrup_preview", {"cells": predicted, "glides": _over_band(predicted, api)})
		return
	if _glided or not _over_band(api.piece_cells(), api):
		return
	_glided = true
	var moved: int = 0
	for _step: int in clampi(int(api.param(&"syrup_glide", 2)), 0, 2):
		var result: Dictionary = api.try_translate(_direction(api))
		if int(result.get("result", Movement.Result.BLOCKED)) != Movement.Result.OK:
			break
		moved += 1
	api.set_piece_flag(&"lock_now", true)
	api.emit(&"syrup_glide", {"direction": _direction(api), "steps": moved, "cells": api.piece_cells()})


func _over_band(cells: Array[Vector3i], api: RuleApi) -> bool:
	var rows: Array = api.param(&"band_rows", [1, 2])
	for cell: Vector3i in cells:
		if rows.has(cell.z):
			return true
	return false


func _direction(api: RuleApi) -> Vector3i:
	return MechanicsCells.direction(String(api.param(&"syrup_dir", "+x")))


func _landing(cells: Array[Vector3i], api: RuleApi) -> Array[Vector3i]:
	var result: Array[Vector3i] = MechanicsCells.translated(cells, api.down_vector() * api.cast(cells, api.down_vector()))
	if _glided or not _over_band(result, api):
		return result
	for _step: int in clampi(int(api.param(&"syrup_glide", 2)), 0, 2):
		var next: Array[Vector3i] = MechanicsCells.translated(result, _direction(api))
		if not api.can_place(next):
			break
		result = next
	return result


func snapshot() -> Dictionary:
	return {"glided": _glided, "gravity_scale": _gravity_scale, "preview": _preview}
