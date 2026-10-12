class_name UndoResetRule extends RuleBehaviour
## Activates BoardSim turn snapshots and semantic undo/reset commands on authored puzzles.
const PLUGIN_ID := &"undo_reset"

func tags() -> PackedStringArray:
	return PackedStringArray(["turn"])
