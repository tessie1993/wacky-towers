class_name M01CondFinished extends ConditionLeaf
## True once when state is won or lost.


func tick(_actor: Node, bb: Blackboard) -> int:
	if bb.get_value("finished_done", false):
		return FAILURE
	var s: StringName = bb.get_value("state", &"playing")
	return SUCCESS if s == &"won" or s == &"lost" else FAILURE
