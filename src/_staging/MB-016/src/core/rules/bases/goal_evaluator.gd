@abstract
class_name GoalEvaluator extends RefCounted
## Decides win/lose from GoalState; one plugin per goal type (clear_n, height, shape, survive). Plugins declare const PLUGIN_ID: StringName.

const RUNNING := GoalState.RESULT_RUNNING
const WON := GoalState.RESULT_WON
const LOST := GoalState.RESULT_LOST


## Reads the level's goal section (targets, n, ...). Usage: `ev.configure(level.goal)`.
@abstract func configure(goal: Dictionary) -> void


## Returns RUNNING, WON or LOST. Usage: `if ev.evaluate(state, api) == GoalEvaluator.WON: ...`.
@abstract func evaluate(state: GoalState, api: RuleApi) -> int


## HUD data, e.g. {"done": 2, "target": 3}. Usage: `hud.show(ev.progress(state))`.
func progress(_state: GoalState) -> Dictionary:
	return {}


## Compatibility tags (ADR-0004 atoms). Usage: `ev.tags().is_empty()`.
func tags() -> PackedStringArray:
	return PackedStringArray()


## Extra checks this plugin needs on a level. Default: none.
func validate(_level: LevelData, _catalog: GameCatalog) -> Array[ValidationIssue]:
	return []
