class_name Meadow01Events extends Node
## Meadow 01 level events: a beehave tree, ticked once per game tick, that only emits signals.
## No rule maths, no board access. The game fills the blackboard via tick_game().

signal banner(text: String)
signal cheer(count: int)
signal level_finished(state: StringName)

@onready var _tree: BeehaveTree = $Tree


## bb_values keys: layers_cleared, goal_n, state, just_cleared, elapsed_ms.
func tick_game(bb_values: Dictionary) -> void:
	for key: Variant in bb_values:
		_tree.blackboard.set_value(key, bb_values[key])
	_tree.tick()
