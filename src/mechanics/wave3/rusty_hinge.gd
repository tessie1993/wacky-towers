class_name RustyHingeRule extends RuleBehaviour
## W10: each piece may rotate only a limited number of times; holding keeps the count.
const PLUGIN_ID := &"rusty_hinge"
const _FLAG := &"hinge_turns_left"
var _turns_left: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	# A held piece carries its remaining turns in its piece flags.
	var carried: Variant = api.piece_flag(_FLAG)
	_turns_left = int(carried) if carried != null else maxi(0, int(api.param(&"max_turns", 2)))
	api.set_piece_flag(_FLAG, _turns_left)


func veto(action: StringName, _ctx: HookContext, api: RuleApi) -> bool:
	if action != SimEvents.CMD_ROTATE:
		return false
	if _turns_left <= 0:
		api.emit(&"hinge_stuck", {})
		return true
	_turns_left -= 1
	api.set_piece_flag(_FLAG, _turns_left)
	return false


func snapshot() -> Dictionary:
	return {"turns_left": _turns_left}
