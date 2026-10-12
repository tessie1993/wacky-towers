class_name TrimTopOut extends TopOutPolicy
## Overflow in build and shape levels removes only cubes above the danger line.

const PLUGIN_ID := &"trim"


func resolve_top_out(board: BoardState, state: GoalState, _api: RuleApi) -> int:
	for layer: int in range(board.limit_layer(), board.layer_count()):
		for i: int in board.layer_cells(layer):
			if board.get_kind(i) != ContentTypes.KIND_EMPTY and board.can_remove(i, BoardState.Cause.TRIM):
				state.cells_trimmed += 1
				board.remove(i, BoardState.Cause.TRIM)
	return CONTINUE
