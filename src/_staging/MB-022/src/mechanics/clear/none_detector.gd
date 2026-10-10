class_name NoneDetector extends ClearDetector
## `none` clear detector: clearing is off (height/shape levels, CH-060).

const PLUGIN_ID := &"none"


## Always empty. Usage: `NoneDetector.new().find_clears(board, api)`.
func find_clears(_board: BoardState, _api: RuleApi) -> Array[ClearGroup]:
	return []
