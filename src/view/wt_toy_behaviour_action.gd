class_name WtToyBehaviourAction extends ActionLeaf
## Installed Beehave owns both event reactions and ambient toy poses.
var reacting: bool = false
func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.behaviour_step(actor.get_physics_process_delta_time())
	blackboard.set_value("pose", actor.behaviour_pose())
	blackboard.set_value("actor_id", str(actor.actor_id))
	return RUNNING if reacting and actor.behaviour_pending() else SUCCESS
