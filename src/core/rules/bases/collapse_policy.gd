@abstract
class_name CollapsePolicy extends RefCounted
## Decides how the board settles after clears (ADR-0004). Plugins declare const PLUGIN_ID: StringName.

## Mutates `board` after `cleared` groups are removed. Usage: `policy.collapse(board, groups, api)`.
@abstract func collapse(board: BoardState, cleared: Array[ClearGroup], api: RuleApi) -> void


## Compatibility tags (ADR-0004 atoms). Usage: `policy.tags().is_empty()`.
func tags() -> PackedStringArray:
	return PackedStringArray()
