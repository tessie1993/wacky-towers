class_name EndlessGoal extends GoalEvaluator
## Arcade ends only through top-out, a time limit, or player exit.
const PLUGIN_ID := &"endless"


func configure(_goal: Dictionary) -> void:
	pass


func evaluate(_state: GoalState, _api: RuleApi) -> int:
	return RUNNING


func progress(state: GoalState) -> Dictionary:
	return {"done": state.layers_cleared, "target": 0, "unit": "layers", "endless": true}
