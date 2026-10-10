class_name StopwatchRule extends RuleBehaviour
## Freeze pauses gravity and lock delay, then a telegraphed catch-up resumes it.
const PLUGIN_ID := &"stopwatch"
var _due: int = -1
var _until: int = -1
var _phase: StringName = &"normal"
var _warned: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_tick"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var now: int = api.time_ms()
	if hook == &"on_spawn" and _due < 0:
		_schedule(api)
	if hook != &"on_tick" or _due < 0:
		return
	if _phase == &"normal":
		if not _warned and now >= _due - int(api.param(&"stop_warn_ms", 1000)):
			_warned = true
			api.emit(&"stopwatch_warning", {"due_ms": _due})
		if now >= _due:
			if api.piece_cells().is_empty():
				_schedule(api)
				return
			_phase = &"stopped"
			_until = now + int(api.param(&"stop_ms", 2500))
			api.request_slot(&"fall.gravity_scale", 0)
			api.set_piece_flag(&"lock_paused", true)
			api.emit(&"stopwatch_stop", {"until_ms": _until})
	elif now >= _until and _phase == &"stopped":
		_phase = &"catchup"
		_until = now + int(api.param(&"catchup_ms", 2500))
		api.set_piece_flag(&"lock_paused", false)
		api.request_slot(&"fall.gravity_scale", int(roundf(float(api.param(&"catchup_scale", 1.6)) * 1000.0)))
		api.emit(&"stopwatch_catchup", {"until_ms": _until})
	elif now >= _until and _phase == &"catchup":
		api.request_slot(&"fall.gravity_scale", 1000)
		_phase = &"normal"
		_schedule(api)
		api.emit(&"stopwatch_resume", {})


func _schedule(api: RuleApi) -> void:
	var jitter: int = maxi(0, int(api.param(&"stop_jitter_ms", 3000)))
	_due = api.time_ms() + maxi(1000, int(api.param(&"stop_every_ms", 14000)) + (api.rng().randi_range(-jitter, jitter) if jitter > 0 else 0))
	_warned = false


func snapshot() -> Dictionary:
	return {"due": _due, "until": _until, "phase": _phase, "warned": _warned}
