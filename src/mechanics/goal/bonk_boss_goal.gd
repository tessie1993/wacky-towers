class_name BonkBossGoal extends GoalEvaluator
## Boss damage is a separate counter: damage never becomes clear-layer credit.
const PLUGIN_ID := &"bonk_boss"
var _target: int = 4
func configure(goal: Dictionary) -> void:
	_target = maxi(1, int(goal.get("bonks_needed", 4)))
func evaluate(state: GoalState, _api: RuleApi) -> int:
	return WON if int(state.metrics.get("bonks", 0)) >= _target else RUNNING
func progress(state: GoalState) -> Dictionary:
	return {"done": mini(_target, int(state.metrics.get("bonks", 0))), "target": _target, "unit": "bonks"}
