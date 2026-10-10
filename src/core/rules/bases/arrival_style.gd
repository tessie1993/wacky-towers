@abstract
class_name ArrivalStyle extends RefCounted
## Plans where and how a new piece arrives (ADR-0004). Plugins declare const PLUGIN_ID: StringName.

## Returns the arrival plan for `shape`. Usage: `var p := style.plan_arrival(shape, board, api)`.
@abstract func plan_arrival(shape: ShapeDef, board: BoardState, api: RuleApi) -> ArrivalPlan


## Compatibility tags (ADR-0004 atoms). Usage: `style.tags().is_empty()`.
func tags() -> PackedStringArray:
	return PackedStringArray()
