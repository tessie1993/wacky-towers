class_name BouncePadRule extends RuleBehaviour
## A pad bounces one landing per piece, then behaves as ordinary support.
const PLUGIN_ID := &"bounce_pad"
var _bounced: bool = false
var _last_move := Vector3i.ZERO


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_command", &"on_land"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_spawn":
		_bounced = false
		_last_move = Vector3i.ZERO
		return
	if hook == &"on_command":
		if ctx.data.get("kind") == SimEvents.CMD_MOVE:
			var args: Dictionary = ctx.data.get("args", {})
			var raw: Variant = args.get("dir", args.get("direction", Vector3i.ZERO))
			if raw is Vector3i:
				_last_move = raw
		return
	if _bounced:
		return
	var pad: int = api.kind_of(&"bounce_pad")
	var on_pad: bool = false
	for c: Vector3i in api.piece_cells():
		on_pad = on_pad or api.kind_at(c + api.down_vector()) == pad
	if not on_pad:
		return
	_bounced = true
	var rise: int = 0
	for _step: int in clampi(int(api.param(&"bounce_h", 2)), 1, 4):
		if int(api.try_translate(-api.down_vector()).get("result", Movement.Result.BLOCKED)) != Movement.Result.OK:
			break
		rise += 1
	var direction_value: Vector3i = _last_move if String(api.param(&"dir_mode", "last_move")) == "last_move" else MechanicsCells.direction(String(api.param(&"bounce_dir", "+x")))
	if direction_value != Vector3i.ZERO:
		api.try_translate(direction_value)
	api.emit(&"bounce_pad", {"rise": rise, "direction": direction_value})


func snapshot() -> Dictionary:
	return {"bounced": _bounced, "last_move": _last_move}
