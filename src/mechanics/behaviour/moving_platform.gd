class_name MovingPlatformRule extends RuleBehaviour
## Rule plugin that rides the board along a track (gap G8). Param "track" = track id under assets/data/tracks/.
## The rule only wires the pure TrackRunner to the hook pipeline; all logic lives in src/core/track.
## It emits track_started on level start (the stage attaches the track view from it) and track_* records after.
const PLUGIN_ID := &"moving_platform"
const TRACK_DIR := "res://assets/data/tracks/"

var _runner: TrackRunner
var _track_id: String = ""
var _last_ms: int = -1


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_tick"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_start(String(api.param(&"track", "")), api)
	elif _runner != null:
		var now: int = api.level_ms()
		var dt: int = 0 if _last_ms < 0 else maxi(0, now - _last_ms)
		_last_ms = now
		_runner.step(dt, api)


## The live runner, for the HUD and tests; null until on_level_start succeeded.
func runner() -> TrackRunner:
	return _runner


## Loads a track by id and returns the def, or null (with push_error) when it is missing or invalid.
static func load_track(track_id: String) -> TrackDef:
	var def: TrackDef = TrackDef.load_file(TRACK_DIR + track_id + ".json")
	if not def.is_valid():
		push_error("moving_platform: bad track '%s': %s" % [track_id, ", ".join(def.errors)])
		return null
	return def


func snapshot() -> Dictionary:
	return {"track": _track_id, "last_ms": _last_ms, "runner": _runner.snapshot() if _runner != null else {}}


func restore(state: Dictionary) -> void:
	_track_id = String(state.get("track", ""))
	_last_ms = int(state.get("last_ms", -1))
	var saved: Dictionary = state.get("runner", {}) as Dictionary
	if _track_id == "" or saved.is_empty():
		_runner = null
		return
	var def: TrackDef = load_track(_track_id)
	if def == null:
		_runner = null
		return
	_runner = TrackRunner.new(def)
	_runner.restore(saved)


func _start(track_id: String, api: RuleApi) -> void:
	var def: TrackDef = load_track(track_id)
	if def == null:
		return
	_track_id = track_id
	_runner = TrackRunner.new(def)
	_last_ms = -1
	_runner.begin(api)
