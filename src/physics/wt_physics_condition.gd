class_name WtPhysicsCondition extends ConditionLeaf
## State guard in the live Beehave physics challenge tree.
var phase: StringName
func tick(actor: Node, _blackboard: Blackboard) -> int:
	var challenge:=actor as WtPhysicsChallenge
	return SUCCESS if challenge!=null and challenge.behaviour_phase()==phase else FAILURE
