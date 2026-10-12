class_name RuleActionLeaf extends ActionLeaf
## Executes one deterministic simulation operation through the actual Beehave leaf API.
func tick(_actor: Node, blackboard: Blackboard) -> int:
	var target: Object = blackboard.get_value(&"target")
	var method: StringName = blackboard.get_value(&"method", &"")
	var arguments: Array = blackboard.get_value(&"arguments", [])
	if target == null or not target.has_method(method):
		blackboard.set_value(&"result", null)
		return FAILURE
	var result: Variant = target.callv(method, arguments)
	blackboard.set_value(&"result", result)
	return SUCCESS
