@abstract
class_name TopOutPolicy extends RefCounted
## What happens when the stack is over the limit after clears (Level Goals rule 10a: rescue, trim, lose). Plugins declare const PLUGIN_ID: StringName.

const CONTINUE := GoalState.RESULT_RUNNING
const LOST := GoalState.RESULT_LOST


## Returns CONTINUE or LOST; may mutate `board` (trim) and `state` (warnings). Usage: `policy.resolve_top_out(board, state, api)`.
@abstract func resolve_top_out(board: BoardState, state: GoalState, api: RuleApi) -> int


## Compatibility tags (ADR-0004 atoms). Usage: `policy.tags().is_empty()`.
func tags() -> PackedStringArray:
	return PackedStringArray()


## Extra checks this plugin needs on a level. Default: none.
func validate(_level: LevelData, _catalog: GameCatalog) -> Array[ValidationIssue]:
	return []
