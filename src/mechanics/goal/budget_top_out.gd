class_name BudgetTopOut extends TopOutPolicy
## Finite-puzzle physical overflow loses; exhaustion is checked by BoardSim after goals.
const PLUGIN_ID := &"budget"

func resolve_top_out(_board: BoardState, _state: GoalState, _api: RuleApi) -> int:
	return LOST
