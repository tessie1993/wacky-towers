class_name WtPhysicsCondition extends ConditionLeaf
## State guard in the live Beehave physics challenge tree.
var phase: StringName
func tick(actor: Node, _blackboard: Blackboard) -> int:
	return SUCCESS if actor.behaviour_phase()==phase else FAILURE
