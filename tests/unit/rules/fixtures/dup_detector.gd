extends ClearDetector
## Test fixture: deliberately duplicates TestOnlyDetector's PLUGIN_ID. No class_name on purpose.

const PLUGIN_ID: StringName = &"test_only"


func find_clears(_board: BoardState, _api: RuleApi) -> Array[ClearGroup]:
	return []
