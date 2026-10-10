class_name TestOnlyDetector extends ClearDetector
## Test fixture: proves a detector is found by id with no core edit (ADR-0004 validation item).

const PLUGIN_ID: StringName = &"test_only"


func find_clears(_board: BoardState, _api: RuleApi) -> Array[ClearGroup]:
	var g := ClearGroup.new()
	g.cells = PackedInt32Array([7])
	g.counts_as_layers = 1
	return [g]
