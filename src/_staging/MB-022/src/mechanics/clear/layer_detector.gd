class_name LayerDetector extends ClearDetector
## `layer` clear detector: every full layer is one clear group (Layer Clearing rule 4, CH-060). Never writes the board.

const PLUGIN_ID := &"layer"


## One group per full layer, bottom-up (ascending layer index); cells are the occupied cells of that layer.
## Usage: `LayerDetector.new().find_clears(board, api)`.
func find_clears(board: BoardState, _api: RuleApi) -> Array[ClearGroup]:
	var out: Array[ClearGroup] = []
	for k: int in board.full_layers():
		var g: ClearGroup = ClearGroup.new()
		for i: int in board.layer_cells(k):
			if board.get_kind(i) != 0:
				g.cells.append(i)
		g.counts_as_layers = 1
		out.append(g)
	return out
