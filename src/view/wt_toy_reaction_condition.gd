class_name WtToyReactionCondition extends ConditionLeaf
## Presentation branch guard. Rules and collision never pass through this leaf.
func tick(actor: Node, _blackboard: Blackboard) -> int:
	return SUCCESS if actor.behaviour_pending() else FAILURE
