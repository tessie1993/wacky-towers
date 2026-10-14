class_name MovingPlatformRule extends RuleBehaviour
## Rule plugin that rides the board along a track (gap G8). Params: "track" = track id under assets/data/tracks/.
## The rule only wires the pure TrackRunner to the hook pipeline; all logic lives in src/core/track.
const PLUGIN_ID := &"moving_platform"
const TRACK_DIR := "res://assets/data/tracks/"

var _runner: TrackRunner
var _last_ms: int = -1


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_tick"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_start(api)
	elif _runner != null:
		var now: int = api.level_ms()
		var dt: int = 0 if _last_ms < 0 else maxi(0, now - _last_ms)
		_last_ms = now
		_runner.step(dt, api)


## The live runner, for the view hook and tests; null until on_level_start succeeded.
func runner() -> TrackRunner:
	return _runner


func _start(api: RuleApi) -> void:
	var track_id: String = String(api.param(&"track", ""))
	var def: TrackDef = TrackDef.load_file(TRACK_DIR + track_id + ".json")
	if not def.is_valid():
		push_error("moving_platform: bad track '%s': %s" % [track_id, ", ".join(def.errors)])
		return
	_runner = TrackRunner.new(def, api.rng().randi())
	_last_ms = -1


func snapshot() -> Dictionary:
	return _runner.snapshot() if _runner != null else {}
