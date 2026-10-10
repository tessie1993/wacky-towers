class_name SliceCollapse extends CollapsePolicy
## `slice` collapse: cleared layers vanish and everything above drops by the cleared layers beneath it
## (Layer Clearing rules 7-8 / F1, CH-161). Never chains; emits nothing (BoardState records the delta).

const PLUGIN_ID := &"slice"


## Removes every cell of the cleared groups (cause CLEAR) and shifts the layers above down.
## Usage: `SliceCollapse.new().collapse(board, groups, api)`.
func collapse(board: BoardState, cleared: Array[ClearGroup], _api: RuleApi) -> void:
	var layers: PackedInt32Array = PackedInt32Array()
	for g: ClearGroup in cleared:
		if not g.cells.is_empty():
			layers.append(board.layer_of(g.cells[0]))
	# shift_layers empties each listed layer with Cause.CLEAR, then drops the rest.
	board.shift_layers(layers)
