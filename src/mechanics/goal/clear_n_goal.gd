class_name ClearNGoal extends GoalEvaluator
## `clear_n` goal: win after n layers cleared by Layer Clearing (Level Goals rule 2, CH-061).

const PLUGIN_ID := &"clear_n"

var _n: int = 1


## Reads goal["n"] (whole number >= 1; anything else is left to validate()). Usage: `ev.configure({"n": 4})`.
func configure(goal: Dictionary) -> void:
	var n: Variant = JsonNum.whole_int(goal.get("n"))
	_n = int(n) if n != null and int(n) >= 1 else 1


## WON when state.layers_cleared >= n, else RUNNING. Usage: `ev.evaluate(state, api)`.
func evaluate(state: GoalState, _api: RuleApi) -> int:
	return WON if state.layers_cleared >= _n else RUNNING


## HUD data {"done": min(layers_cleared, n), "target": n}.
func progress(state: GoalState) -> Dictionary:
	return {"done": mini(state.layers_cleared, _n), "target": _n}


## Error when goal.n is missing, not a whole number, or < 1.
func validate(level: LevelData, _catalog: GameCatalog) -> Array[ValidationIssue]:
	var out: Array[ValidationIssue] = []
	var n: Variant = JsonNum.whole_int(level.goal.get("n"))
	if n == null or n < 1:
		out.append(ValidationIssue.error(level.id, "goal.n", &"out_of_range", "clear_n needs a whole number n >= 1"))
	return out
