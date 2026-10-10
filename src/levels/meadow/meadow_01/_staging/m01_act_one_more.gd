class_name M01ActOneMore extends ActionLeaf
## Emit the one-more banner once.


func tick(actor: Node, bb: Blackboard) -> int:
	var ev := actor as Meadow01Events
	bb.set_value("one_more_done", true)
	ev.banner.emit("One more!")
	return SUCCESS
