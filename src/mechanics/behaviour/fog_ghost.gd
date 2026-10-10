class_name FogGhostRule extends RuleBehaviour
## The sim owns collision and deep-hole placement; this rule owns solidification.
const PLUGIN_ID := &"fog_ghost"
var _intangible: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_command", &"on_land"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_spawn":
		var tags_value: Variant = ctx.data.get("tags", PackedStringArray())
		_intangible = tags_value.has("fog_ghost")
		api.set_piece_flag(&"intangible", _intangible)
		if _intangible:
			api.emit(&"fog_ghost_spawn", {})
	elif _intangible and hook == &"on_command":
		var command: StringName = StringName(String(ctx.data.get("kind", ctx.data.get("command", ""))))
		if command in [&"hard_drop", &"cmd_hard_drop", &"pick_cell", &"tap", &"cmd_tap", &"solidify"]:
			_solidify(api, true, command not in [&"hard_drop", &"cmd_hard_drop"])
	elif _intangible and hook == &"on_land":
		_solidify(api, false)


func _solidify(api: RuleApi, tapped: bool, lock_now: bool = true) -> void:
	_intangible = false
	api.set_piece_flag(&"intangible", false)
	api.place_nearest_up()
	api.set_piece_flag(&"lock_now", lock_now)
	api.emit(&"fog_ghost_solidified", {"tapped": tapped})


func snapshot() -> Dictionary:
	return {"intangible": _intangible}
