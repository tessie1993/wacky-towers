class_name AngleGemRule extends RuleBehaviour
## Secret collection is an explicit tap command at the supplied secret id.
const PLUGIN_ID := &"angle_gem"
var _collected: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_command"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var id: String = String(api.param(&"id", api.param(&"secret_id", "angle_gem")))
	if hook == &"on_level_start":
		api.emit(&"secret_placed", {"id": id, "angle": api.param(&"angle", "low"), "location": api.param(&"location", "under_island"), "cell": api.param(&"cell", []), "skin": api.param(&"skin", "gem"), "view_snap": api.param(&"view_snap", 0), "where": api.param(&"where", "under_island")})
	elif not _collected and ctx.data.get("kind") == SimEvents.CMD_TAP:
		var raw_args: Variant = ctx.data.get("args", [])
		var args: Dictionary = raw_args[0] if raw_args is Array and not raw_args.is_empty() and raw_args[0] is Dictionary else raw_args if raw_args is Dictionary else {}
		if String(args.get("secret_id", "")) == id:
			_collected = true
			api.emit(&"secret_collected", {"id": id, "kind": "angle_gem"})


func snapshot() -> Dictionary:
	return {"collected": _collected}
