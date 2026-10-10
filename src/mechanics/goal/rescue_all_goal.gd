class_name RescueAllGoal extends GoalEvaluator
## Frosted critters are freed when their final frosting tile is removed by a legal peel.
const PLUGIN_ID := &"rescue_all"
var _content: StringName = &"frosting"
var _target: int = 0
func configure(goal: Dictionary) -> void:
	_content = StringName(goal.get("content", "frosting"))
	_target = int(goal.get("n", 0))
func begin(_state: GoalState, api: RuleApi) -> void:
	if _target <= 0: _target = _remaining(api)
func _remaining(api: RuleApi) -> int:
	var result: int = 0
	var kinds: Array[int] = [api.kind_of(_content)]
	if _content == &"frosting": kinds.append(api.kind_of(&"frosting_three"))
	for cell: Vector3i in MechanicsCells.all(api):
		if api.kind_at(cell) != 0 and kinds.has(api.kind_at(cell)): result += 1
	return result
func evaluate(state: GoalState, api: RuleApi) -> int:
	var remaining: int = _remaining(api)
	state.metrics["rescued"] = maxi(0, _target - remaining)
	return WON if _target > 0 and remaining == 0 else RUNNING
func progress(state: GoalState) -> Dictionary:
	return {"done": mini(_target, int(state.metrics.get("rescued",0))), "target": _target, "unit": "rescues"}
func snapshot() -> Dictionary:
	return {"target": _target, "content": _content}
func restore(data: Dictionary) -> void:
	_target = int(data.get("target", 0))
	_content = StringName(data.get("content", "frosting"))
