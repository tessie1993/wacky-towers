class_name M01ActBanner extends ActionLeaf
## Emit the intro banner once.


func tick(actor: Node, bb: Blackboard) -> int:
	var ev := actor as Meadow01Events
	bb.set_value("banner_done", true)
	ev.banner.emit("Clear %d layers!" % int(bb.get_value("goal_n", 0)))
	return SUCCESS
