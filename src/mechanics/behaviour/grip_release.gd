class_name GripReleaseRule extends RuleBehaviour
## meadow_01 "Stump Day" (design/levels/meadow/meadow_01.md section 3): each cleared layer lets one grip go.
## A grip switches its masked cage columns ON in every layer at once (request_mask), speeds the fall by
## ramp_per_release_mult (capped by ramp_cap_mult) and emits `grip_released` for the view (sky step, meter).
## Only layer clears count: a rescue wipe never fires on_clear, so it never releases a grip.
## All numbers come from the level's rule params: stages (rects of columns), ramp_*.
const PLUGIN_ID := &"grip_release"
var _released: int = 0
var _seen: Dictionary = {}


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_lock", &"on_clear", &"on_resolve_end"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	match hook:
		&"on_level_start":
			_released = 0
			_seen.clear()
			api.clear_modifiers(PLUGIN_ID)
		&"on_lock", &"on_resolve_end":
			_seen.clear()
		&"on_clear":
			# on_clear fires per cell; one grip per cleared layer (keyed by round and layer).
			var key: String = "%s:%s" % [ctx.data.get("chain_round", 1), ctx.data.get("layer", 0)]
			if _seen.has(key):
				return
			_seen[key] = true
			_release(api)


func _release(api: RuleApi) -> void:
	var stages: Array = api.param(&"stages", [])
	if _released >= stages.size():
		return
	var stage: Dictionary = stages[_released]
	for rect: Dictionary in stage.get("rects", []):
		var xs: Array = rect.get("x", [0, 0])
		var zs: Array = rect.get("z", [0, 0])
		for x: int in range(int(xs[0]), int(xs[1]) + 1):
			for z: int in range(int(zs[0]), int(zs[1]) + 1):
				api.request_mask(x, z, true)
	_released += 1
	var mult: float = float(api.param(&"ramp_per_release_mult", 1.0))
	var cap: float = float(api.param(&"ramp_cap_mult", 3.0))
	api.request_modifiers(PLUGIN_ID, [{"knob": "fall.gravity_scale", "op": "mul", "value": minf(cap, pow(mult, _released))}])
	api.emit(&"grip_released", {"grip": _released, "stage": String(stage.get("id", "")), "of": stages.size(), "sky_step": _released})


func snapshot() -> Dictionary:
	return {"released": _released, "seen": _seen.duplicate()}
