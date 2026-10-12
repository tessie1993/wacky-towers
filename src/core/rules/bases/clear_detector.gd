@abstract
class_name ClearDetector extends RefCounted
## Finds groups of cells to clear (ADR-0004). Plugins declare const PLUGIN_ID: StringName.

## Returns the clear groups on `board`. Usage: `for g in det.find_clears(board, api): ...`.
@abstract func find_clears(board: BoardState, api: RuleApi) -> Array[ClearGroup]


## Compatibility tags (ADR-0004 atoms). Usage: `det.tags().is_empty()`.
func tags() -> PackedStringArray:
	return PackedStringArray()


## Extra checks this plugin needs on a level (e.g. "conveyor needs an unmasked board"). Default: none.
## Usage: override and return `ValidationIssue.error(...)` entries.
func validate(_level: LevelData, _catalog: GameCatalog) -> Array[ValidationIssue]:
	return []
