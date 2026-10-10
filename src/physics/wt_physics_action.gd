class_name WtPhysicsAction extends ActionLeaf
## One challenge-state action; Godot/Jolt remains owner of rigid-body integration.
var phase: StringName
func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.physics_behaviour(phase,actor.get_physics_process_delta_time())
	blackboard.set_value("phase",str(phase))
	blackboard.set_value("variant",actor.variant)
	return SUCCESS
