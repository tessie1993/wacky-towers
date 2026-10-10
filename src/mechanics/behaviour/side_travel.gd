class_name SideTravelRule extends RuleBehaviour
## World down is a ground axis, so movement/drop/clear all follow sideways gravity.
const PLUGIN_ID := &"side_travel"


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var token: String = String(api.param(&"travel_dir", "-x"))
	var down: int = BoardState.down_from_token(token)
	if down >= 0:
		api.request_down_axis(down)
		api.request_slot(&"spawn.arrival", &"side_travel")
		api.emit(&"side_travel_started", {"direction": BoardState.down_vector_of(down), "side_view_min_deg": int(api.param(&"side_view_min_deg", 45))})
