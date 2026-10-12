class_name GummyCollapse extends CollapsePolicy
## Authored short slot name for the same rigid colour-blob cascade.
const PLUGIN_ID := &"gummy"


func collapse(board: BoardState, cleared: Array[ClearGroup], api: RuleApi) -> void:
	GummyCascadeCollapse.new().collapse(board, cleared, api)
