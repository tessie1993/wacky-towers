class_name IceSlideRule extends RuleBehaviour
## One world-anchored slide when a piece touches down; blocked steps stop it.
const PLUGIN_ID := &"ice_slide"
var _slid: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_land"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_spawn":
		_slid = false
		return
	if _slid or int(ctx.data.get("clear_count", 0)) < int(api.param(&"start_after_clears", 0)):
		return
	_slid = true
	var direction_value: Vector3i = MechanicsCells.direction(String(api.param(&"slide_dir", "+x")))
	var moved: int = 0
	for _step: int in clampi(int(api.param(&"slide_cells", 1)), 1, 2):
		var result: Dictionary = api.try_translate(direction_value)
		if int(result.get("result", Movement.Result.BLOCKED)) != Movement.Result.OK:
			break
		moved += 1
	api.emit(&"ice_slide", {"direction": direction_value, "cells": moved})


func snapshot() -> Dictionary:
	return {"slid": _slid}
