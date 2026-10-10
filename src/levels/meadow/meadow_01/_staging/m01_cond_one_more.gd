class_name M01CondOneMore extends ConditionLeaf
## True once when exactly one layer remains.


func tick(_actor: Node, bb: Blackboard) -> int:
	var goal := int(bb.get_value("goal_n", 0))
	if bb.get_value("one_more_done", false) or goal < 1:
		return FAILURE
	return SUCCESS if int(bb.get_value("layers_cleared", 0)) == goal - 1 else FAILURE
