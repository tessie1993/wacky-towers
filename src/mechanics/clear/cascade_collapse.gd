class_name CascadeCollapse extends CollapsePolicy
## Removes the detected cells, then each unsupported cube drops to its floor.
const PLUGIN_ID := &"cascade"


func collapse(board: BoardState, cleared: Array[ClearGroup], _api: RuleApi) -> void:
	for group: ClearGroup in cleared:
		for i: int in group.cells:
			board.remove(i, BoardState.Cause.CLEAR)
	board.settle_cells()
