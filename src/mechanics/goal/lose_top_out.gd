class_name LoseTopOut extends TopOutPolicy
## `lose` top-out: the first top-out loses; warnings and rescue_margin are inert (Level Goals rule 10c, CH-162).

const PLUGIN_ID := &"lose"


## Always LOST. Usage: `policy.resolve_top_out(board, state, api)`.
func resolve_top_out(_board: BoardState, _state: GoalState, _api: RuleApi) -> int:
	return LOST
