class_name BakeOvenGoal extends GoalEvaluator
## Stage one is a transition objective; reaching the oven line must never finish the level.
const PLUGIN_ID := &"bake_oven"
var _height := HeightGoal.new()
func configure(goal: Dictionary) -> void:_height.configure(goal)
func evaluate(state: GoalState,api: RuleApi) -> int:
	_height.evaluate(state,api)
	return RUNNING
func progress(state: GoalState) -> Dictionary:
	var info: Dictionary = _height.progress(state);info["stage"]=1;return info
