class_name OutOfPiecesTopOut extends TopOutPolicy
## Finite-puzzle physical overflow loses; exhaustion is checked by BoardSim after goals.
const PLUGIN_ID := &"out_of_pieces"

func resolve_top_out(_board: BoardState, _state: GoalState, _api: RuleApi) -> int:
	return LOST
