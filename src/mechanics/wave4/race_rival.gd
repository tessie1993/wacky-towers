class_name RaceRivalRule extends RuleBehaviour
## Wave 4 race levels (design/gdd/minigame-mechanics-wave4.md, race module; brief rule `race_rival`).
## A ghost rival fills a hidden progress bar at `rival_rate` %/s toward the level goal's target. The player must meet
## the goal first: if the rival reaches 100 % while the goal is still running, the run fails via `api.request_fail`.
## Progress is integer micro-percent so replays stay deterministic. A player tie goes to the player, because the
## goal's WON outcome is committed before the sim consumes a fail request.
## HUD events: `race_progress {player, rival}` every `progress_emit_ms`, `race_rival_warning {rival, player}` once at
## `rival_warn_pct`, then `race_won {player, rival}` or `race_rival_finished {player, rival}`.
const PLUGIN_ID := &"race_rival"
## 1 % in micro-percent.
const PER_PERCENT := 1_000_000
## 100 % in micro-percent.
const FULL := 100 * PER_PERCENT
var _rival: int = -1
var _last_ms: int = 0
var _next_emit_ms: int = 0
var _warned: bool = false
var _done: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_tick"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if _done:
		return
	var now: int = api.level_ms()
	if hook == &"on_level_start" or _rival < 0:
		_rival = mini(FULL, _rate(api) * maxi(0, int(api.param(&"rival_head_start_ms", 0))))
		_last_ms = now
		_next_emit_ms = now
		_warned = false
	var player: int = player_percent(api.goal_progress())
	if player >= 100:
		_done = true
		_emit_progress(api, player)
		api.emit(&"race_won", {"player": player, "rival": _rival / PER_PERCENT})
		return
	var elapsed: int = maxi(0, now - _last_ms)
	_last_ms = now
	_rival = mini(FULL, _rival + step(_rate(api), elapsed, _rival, player,
		float(api.param(&"rubber_band", 0.0)), int(api.param(&"rubber_gap_pct", 25))))
	var rival_pct: int = _rival / PER_PERCENT
	if not _warned and rival_pct >= int(api.param(&"rival_warn_pct", 80)):
		_warned = true
		api.emit(&"race_rival_warning", {"rival": rival_pct, "player": player})
	if now >= _next_emit_ms or _rival >= FULL:
		_emit_progress(api, player)
		_next_emit_ms = now + maxi(1, int(api.param(&"progress_emit_ms", 1000)))
	if _rival >= FULL:
		_done = true
		api.emit(&"race_rival_finished", {"player": player, "rival": 100})
		api.request_fail(&"rival_finished")


## Rival gain in micro-percent for `elapsed_ms`. `rate` is micro-percent per ms. Rubber band: when the rival leads
## the player by `gap_pct` or more, speed is cut by `rubber_band` (0-1); smaller leads cut it proportionally.
static func step(rate: int, elapsed_ms: int, rival: int, player_pct: int, rubber_band: float, gap_pct: int) -> int:
	var span: int = maxi(1, gap_pct) * PER_PERCENT
	var gap: int = clampi(rival - player_pct * PER_PERCENT, 0, span)
	var slow_pm: int = clampi(roundi(rubber_band * 1000.0), 0, 1000) * gap / span
	return rate * elapsed_ms * (1000 - slow_pm) / 1000


## Player share (0-100) of a goal progress dict {"done", "target"}; 0 when the goal has no numeric target.
static func player_percent(progress: Dictionary) -> int:
	var target: int = int(progress.get("target", 0))
	if target <= 0:
		return 0
	return clampi(int(progress.get("done", 0)) * 100 / target, 0, 100)


# rival_rate is %/s; %/s * 1e6 micro / 1000 ms = rate * 1000 micro-percent per ms.
func _rate(api: RuleApi) -> int:
	return maxi(0, roundi(float(api.param(&"rival_rate", 1.0)) * 1000.0))


func _emit_progress(api: RuleApi, player: int) -> void:
	api.emit(&"race_progress", {"player": player, "rival": _rival / PER_PERCENT})


func snapshot() -> Dictionary:
	return {"rival": _rival, "last_ms": _last_ms, "next_emit_ms": _next_emit_ms, "warned": _warned, "done": _done}
