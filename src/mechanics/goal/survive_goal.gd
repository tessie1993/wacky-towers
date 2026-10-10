class_name SurviveGoal extends GoalEvaluator
## Uses the playing clock, excluding countdown, pause and result screens.

const PLUGIN_ID := &"survive"
var _target_ms: int = 150000


func configure(goal: Dictionary) -> void:
	_target_ms = maxi(1, int(goal.get("t_ms", 150000)))


func evaluate(state: GoalState, _api: RuleApi) -> int:
	return WON if state.level_ms >= _target_ms else RUNNING


func progress(state: GoalState) -> Dictionary:
	return {"done": mini(state.level_ms, _target_ms), "target": _target_ms, "unit": "ms"}
