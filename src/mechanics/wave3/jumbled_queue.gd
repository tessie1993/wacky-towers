class_name JumbledQueueRule extends RuleBehaviour
## W5: every N locks the preview queue is shuffled, telegraphed one lock ahead.
const PLUGIN_ID := &"jumbled_queue"
const _MAX_PREVIEW := 16
var _locks: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_lock"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_locks = 0
		return
	var every: int = maxi(2, int(api.param(&"every", 5)))
	_locks += 1
	var ids: PackedStringArray = api.preview_ids(_MAX_PREVIEW)
	if _locks >= every:
		_locks = 0
		if ids.size() >= 2:
			var shuffled: PackedStringArray = ids.duplicate()
			for i: int in range(shuffled.size() - 1, 0, -1):
				var j: int = api.rng().randi_range(0, i)
				var tmp: String = shuffled[i]
				shuffled[i] = shuffled[j]
				shuffled[j] = tmp
			if shuffled == ids:
				shuffled = ids.slice(1)
				shuffled.append(ids[0])
			api.replace_preview(shuffled)
			api.emit(&"queue_jumbled", {"ids": shuffled})
	elif _locks == every - 1 and ids.size() >= 2:
		api.emit(&"queue_jumble_warning", {"locks_left": 1})


func snapshot() -> Dictionary:
	return {"locks": _locks}
