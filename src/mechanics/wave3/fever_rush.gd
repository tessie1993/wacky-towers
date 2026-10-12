class_name FeverRushRule extends RuleBehaviour
## W14: quick consecutive clears build Fever; at full Fever scores gain a bonus and gravity slows.
const PLUGIN_ID := &"fever_rush"
var _combo: int = 0
var _last_clear_ms: int = -1
var _fever: bool = false
var _fever_end: int = -1
var _seen_total: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_lock", &"on_clear", &"on_tick"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var now: int = api.time_ms()
	match hook:
		&"on_level_start":
			_combo = 0
			_last_clear_ms = -1
			_fever = false
			_fever_end = -1
			_seen_total = 0
			api.clear_modifiers(PLUGIN_ID)
		&"on_lock":
			_seen_total = int(ctx.data.get("clear_count", _seen_total))
		&"on_clear":
			var total: int = int(ctx.data.get("clear_count", 0))
			if total <= _seen_total:
				return
			var layers: int = total - _seen_total
			_seen_total = total
			_on_clear_event(api, now, layers)
		&"on_tick":
			if _fever and now >= _fever_end:
				_fever = false
				_combo = 0
				api.clear_modifiers(PLUGIN_ID)
				api.emit(&"fever_end", {})
				api.emit(&"fever_meter", {"combo": _combo, "needed": _needed(api)})
			elif not _fever and _combo > 0 and now - _last_clear_ms > int(api.param(&"window_ms", 6000)):
				_combo = 0
				api.emit(&"fever_meter", {"combo": _combo, "needed": _needed(api)})


func _on_clear_event(api: RuleApi, now: int, layers: int) -> void:
	if _last_clear_ms >= 0 and now - _last_clear_ms <= int(api.param(&"window_ms", 6000)):
		_combo += 1
	else:
		_combo = 1
	_last_clear_ms = now
	if not _fever and _combo >= _needed(api):
		_fever = true
		_fever_end = now + maxi(1, int(api.param(&"fever_ms", 8000)))
		var modifiers: Array[Dictionary] = [{"knob": "fall.gravity_scale", "op": "mul", "value": float(api.param(&"gravity_scale", 0.6))}]
		api.request_modifiers(PLUGIN_ID, modifiers)
		api.emit(&"fever_start", {})
	if _fever:
		api.request_score(int(api.param(&"bonus", 100)) * layers)
	api.emit(&"fever_meter", {"combo": _combo, "needed": _needed(api)})


func _needed(api: RuleApi) -> int:
	return maxi(1, int(api.param(&"clears_needed", 3)))


func snapshot() -> Dictionary:
	return {"combo": _combo, "last_clear_ms": _last_clear_ms, "fever": _fever, "fever_end": _fever_end, "seen_total": _seen_total}
