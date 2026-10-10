class_name ColourTargetGoal extends GoalEvaluator
## Explicit alias for flavour-aware target coverage, used by remix schemas.
const PLUGIN_ID := &"colour_target"
var _shape_goal := ShapeGoal.new()


func configure(goal: Dictionary) -> void:
	_shape_goal.configure(goal)


func evaluate(state: GoalState, api: RuleApi) -> int:
	return _shape_goal.evaluate(state, api)


func progress(state: GoalState) -> Dictionary:
	return _shape_goal.progress(state)
