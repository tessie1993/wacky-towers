class_name M01CondJustCleared extends ConditionLeaf
## True when layers were cleared this tick.


func tick(_actor: Node, bb: Blackboard) -> int:
	return SUCCESS if int(bb.get_value("just_cleared", 0)) > 0 else FAILURE
