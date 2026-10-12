class_name RuleRuntime extends RefCounted
## Detached manual Beehave driver. No SceneTree processing participates in simulation.
const ActionScript = preload("res://src/core/rules/runtime/rule_action_leaf.gd")
var tree: BeehaveTree
var blackboard: Blackboard
var _actor: Node
var _executions: int = 0
var _failures: int = 0

func _init() -> void:
	_actor = Node.new()
	_actor.name = "SimulationActor"
	blackboard = Blackboard.new()
	tree = BeehaveTree.new()
	tree.process_thread = BeehaveTree.ProcessThread.MANUAL
	tree.actor = _actor
	tree.blackboard = blackboard
	tree.tick_rate = 1
	tree.add_child(ActionScript.new())
	_actor.add_child(blackboard)
	_actor.add_child(tree)
	_actor.process_mode = Node.PROCESS_MODE_DISABLED

func execute(target: Object, method: StringName, arguments: Array = []) -> Variant:
	# Nested simulation operations preserve the outer leaf's blackboard frame.
	var frame: Dictionary = {}
	for key: StringName in [&"target", &"method", &"arguments", &"result"]:
		frame[key] = blackboard.get_value(key)
	blackboard.set_value(&"target", target)
	blackboard.set_value(&"method", method)
	blackboard.set_value(&"arguments", arguments)
	blackboard.set_value(&"result", null)
	_executions += 1
	var status: int = tree.tick()
	if status == BeehaveTree.FAILURE:
		_failures += 1
	var result: Variant = blackboard.get_value(&"result")
	for key: StringName in frame:
		blackboard.set_value(key, frame[key])
	return result

func snapshot() -> Dictionary:
	return {"executions": _executions, "failures": _failures, "status": tree.status, "last_tick": tree.last_tick}

func restore(state: Dictionary) -> void:
	_executions = int(state.get("executions", 0))
	_failures = int(state.get("failures", 0))
	tree.status = int(state.get("status", -1))
	tree.last_tick = int(state.get("last_tick", -1))

func dispose() -> void:
	if is_instance_valid(_actor):
		_actor.free()
		_actor = null
		tree = null
		blackboard = null

func _notification(what: int) -> void:
	# RefCounted reaches zero before PREDELETE; calling another method on self
	# would try to resurrect it. Free the detached owned tree directly instead.
	if what == NOTIFICATION_PREDELETE and is_instance_valid(_actor):
		_actor.free()
