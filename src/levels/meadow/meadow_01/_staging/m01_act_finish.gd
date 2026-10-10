class_name M01ActFinish extends ActionLeaf
## Emit level_finished once.


func tick(actor: Node, bb: Blackboard) -> int:
	var ev := actor as Meadow01Events
	bb.set_value("finished_done", true)
	ev.level_finished.emit(bb.get_value("state", &"playing") as StringName)
	return SUCCESS
