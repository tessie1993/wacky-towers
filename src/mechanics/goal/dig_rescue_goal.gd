class_name DigRescueGoal extends GoalEvaluator
## A buried mole is rescued by clearing its layer; damage and trims cannot rescue it.
const PLUGIN_ID := &"dig_rescue"
var _target: int = 3
func configure(goal: Dictionary) -> void:
	_target = maxi(1, int(goal.get("critters_needed", 3)))
func on_clear(cell: Vector3i, record: Dictionary, state: GoalState, api: RuleApi) -> void:
	if int(record.get("kind",0)) == api.kind_of(&"mole"):
		state.metrics["rescued"] = int(state.metrics.get("rescued",0)) + 1
		api.emit(&"critter_rescued", {"cell": cell, "kind": "mole"})
func evaluate(state: GoalState, _api: RuleApi) -> int:
	return WON if int(state.metrics.get("rescued",0)) >= _target else RUNNING
func progress(state: GoalState) -> Dictionary:
	return {"done": mini(_target, int(state.metrics.get("rescued",0))), "target": _target, "unit": "critters"}
