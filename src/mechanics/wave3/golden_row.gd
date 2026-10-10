class_name GoldenRowRule extends RuleBehaviour
## W15: one layer glows gold; clearing it pays a bonus, then gold moves up a layer.
const PLUGIN_ID := &"golden_row"
var _gold: int = 0
var _paid_key: int = -1


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_clear"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_gold = maxi(0, int(api.param(&"start_layer", 1)))
		_paid_key = -1
		api.emit(&"gold_layer", {"layer": _gold})
		return
	# One payout per clear round, judged on the layers as they were before collapse.
	var key: int = int(ctx.data.get("clear_count", 0))
	if key == _paid_key or int(ctx.data.get("layer", -1)) != _gold:
		return
	_paid_key = key
	api.request_score(int(api.param(&"bonus", 200)))
	api.add_goal_counter(StringName(String(api.param(&"goal_counter", "gold"))))
	api.emit(&"gold_cleared", {"layer": _gold})
	_gold += 1
	if _gold > api.limit_layer() - 2:
		_gold = maxi(0, int(api.param(&"start_layer", 1)))
	api.emit(&"gold_layer", {"layer": _gold})


func snapshot() -> Dictionary:
	return {"gold": _gold, "paid_key": _paid_key}
