@abstract
class_name ControlVerb extends RefCounted
## Turns touch gestures into SimCommands and applies them through RuleApi on the tick (ADR-0004). Plugins declare const PLUGIN_ID: StringName.
## Gesture dictionary (input -> verb):
## {kind: &"move"|&"rotate"|&"soft_drop"|&"hard_drop"|&"hold"|&"tap", dir: Vector3i (world, move),
##  axis: int (Orientations.Axis), sign: int (rotate; world axis already resolved by the camera),
##  on: bool (soft_drop), cell: Vector3i (tap)}


## Commands for one gesture. Usage: `var cmds := verb.commands_for({"kind": &"move", "dir": Vector3i.RIGHT}, api)`.
@abstract func commands_for(gesture: Dictionary, api: RuleApi) -> Array[SimCommand]


## Applies one command on the tick. Usage: `verb.apply(cmd, api)`.
@abstract func apply(cmd: SimCommand, api: RuleApi) -> void


## Compatibility tags (ADR-0004 atoms). Usage: `verb.tags().is_empty()`.
func tags() -> PackedStringArray:
	return PackedStringArray()


## Extra checks this plugin needs on a level. Default: none.
func validate(_level: LevelData, _catalog: GameCatalog) -> Array[ValidationIssue]:
	return []
