class_name MascotCatchRule extends RuleBehaviour
## Pip undoes a bad lock before board writes; the caught placement is not a lock.
const PLUGIN_ID := &"mascot_catch"
var _remaining: int = 1


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	_remaining = maxi(0, int(api.param(&"catches", api.param(&"mascot_catches", 1))))


func veto(action: StringName, ctx: HookContext, api: RuleApi) -> bool:
	if action != &"piece.lock" or _remaining <= 0:
		return false
	if int(ctx.data.get("holes_added", 0)) <= 0 or bool(ctx.data.get("would_clear", false)) or bool(ctx.data.get("would_top_out", false)) or api.goal_would_meet(api.piece_cells()):
		return false
	if bool(api.param(&"happy_only", false)) and CandyCells.tidy(api) < 0.9:
		return false
	if not api.spawn_cells_free():
		return false
	_remaining -= 1
	api.request_catch(int(api.param(&"catch_ms", 300)))
	api.emit(&"mascot_catch", {"remaining": _remaining})
	return true


func snapshot() -> Dictionary:
	return {"remaining": _remaining}
