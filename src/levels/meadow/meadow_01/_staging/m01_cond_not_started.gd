class_name M01CondNotStarted extends ConditionLeaf
## True until the intro banner has fired.


func tick(_actor: Node, bb: Blackboard) -> int:
	return FAILURE if bb.get_value("banner_done", false) else SUCCESS
