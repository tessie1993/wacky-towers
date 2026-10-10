class_name M01ActCheer extends ActionLeaf
## Pip cheers for the layers cleared this tick.


func tick(actor: Node, bb: Blackboard) -> int:
	var ev := actor as Meadow01Events
	ev.cheer.emit(int(bb.get_value("just_cleared", 0)))
	return SUCCESS
