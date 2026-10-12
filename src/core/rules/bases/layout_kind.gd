@abstract
class_name LayoutKind extends RefCounted
## Places, links and validates the boards of a level (ADR-0002 section 7). Meadow uses `single` only. Plugins declare const PLUGIN_ID: StringName.


## Where a piece leaving `board_id` through `face` continues: {board_id, cells}, or {} for a wall.
## Usage: `var next := layout.map_exit(0, cells, Vector3i.RIGHT)`.
@abstract func map_exit(board_id: int, cells: Array[Vector3i], face: Vector3i) -> Dictionary


## Compatibility tags (ADR-0004 atoms). Usage: `layout.tags().is_empty()`.
func tags() -> PackedStringArray:
	return PackedStringArray()


## Extra checks this plugin needs on a level. Default: none.
func validate(_level: LevelData, _catalog: GameCatalog) -> Array[ValidationIssue]:
	return []
