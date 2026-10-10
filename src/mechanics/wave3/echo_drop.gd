class_name EchoDropRule extends RuleBehaviour
## W9: every N locks the last locked piece's shape is echoed as the next piece.
const PLUGIN_ID := &"echo_drop"
var _locks: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_lock"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_locks = 0
		return
	_locks += 1
	if _locks < maxi(1, int(api.param(&"every", 4))):
		return
	_locks = 0
	var shape_id: StringName = StringName(String(ctx.data.get("shape_id", "")))
	if shape_id == &"":
		return
	api.inject_front(PackedStringArray([String(shape_id)]))
	api.emit(&"echo", {"shape_id": shape_id})


func snapshot() -> Dictionary:
	return {"locks": _locks}
