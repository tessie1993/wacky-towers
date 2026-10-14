class_name TrackRunner extends RefCounted
## Deterministic moving-platform sim (gap G8, docs/architecture/moving-platform.md). Pure logic: no nodes, no wall
## clock, no dice. "Survive to the finish": reach the end of the track before the time limit with the cargo intact.
## Each fixed tick it moves along the TrackDef, fires scheduled events, tracks the lean (stack centre of mass plus
## decaying impulses; past the limit the heavy side spills), and runs the cargo state machine (stable, wobble, slip,
## lost). Position is integer micrometres (mm/s * ms), rates are accumulated in milli-permille, so there is no drift.
## Usage: var r := TrackRunner.new(def); r.begin(api); var out: Array[Dictionary] = r.step(50, api).

## Emitted record kinds (also forwarded to api.emit). Each record has "kind", "tick".
const EV_STARTED := &"track_started"
const EV_PROGRESS := &"track_progress"
const EV_EVENT := &"track_event"
const EV_CHECKPOINT := &"track_checkpoint"
const EV_LEAN_WARNING := &"track_lean_warning"
const EV_TOPPLE := &"track_topple"
const EV_CARGO_STATE := &"track_cargo_state"
const EV_CARGO_LOST := &"track_cargo_lost"
const EV_RESTART := &"track_restart"
const EV_TIME_UP := &"track_time_up"
const EV_FINISHED := &"track_finished"
## Goal metric names (read by TrackRaceGoal and the HUD).
const METRIC_PROGRESS_PM := &"track_progress_pm"
const METRIC_FINISHED := &"track_finished"
const METRIC_FAILED := &"track_failed"
const METRIC_LEAN_PM := &"track_lean_pm"
const METRIC_LEAN_DANGER_PM := &"track_lean_danger_pm"
const METRIC_CARGO_STATE := &"track_cargo_state"
const METRIC_CARGO_STRESS_PM := &"track_cargo_stress_pm"
const METRIC_TIME_LEFT_MS := &"track_time_left_ms"
const METRIC_FALL_PCT := &"track_fall_pct"
## Cargo states, in order of danger.
const CARGO_STABLE := 0
const CARGO_WOBBLE := 1
const CARGO_SLIP := 2
const CARGO_LOST := 3
const CARGO_NAMES: Array[StringName] = [&"stable", &"wobble", &"slip", &"lost"]

var _def: TrackDef
var _pos_um: int = 0
var _acc_ms: int = 0
var _tick: int = 0
var _elapsed_ms: int = 0
var _next_event: int = 0
var _next_cp: int = 0
var _cp_mm: int = 0
var _cp_id: StringName = &""
var _cp_elapsed_ms: int = 0
var _attempts: int = 1
var _finished: bool = false
var _failed: bool = false
var _fail_reason: StringName = &""
var _barrier: bool = false
var _lift_pct: int = 0
var _lift_until_tick: int = -1
var _impulse_u: Vector2i = Vector2i.ZERO  # milli-permille
var _lean: Vector2i = Vector2i.ZERO
var _lean_warned: bool = false
var _stress_u: int = 0  # milli-permille
var _cargo_state: int = CARGO_STABLE
var _prev_seat_h: int = 0
var _seat: Dictionary = {"x": 0, "z": 0, "h": 0, "support": 9}
var _best_pm: int = 0
var _fall_sent: int = -1


## Creates a runner. `def` must be valid.
func _init(def: TrackDef) -> void:
	assert(def != null and def.is_valid(), "TrackRunner needs a valid TrackDef")
	_def = def


## Announces the track and sets the first fall speed. Call once from on_level_start.
func begin(api: RuleApi) -> void:
	var out: Array[Dictionary] = []
	_record(api, out, EV_STARTED, {"track": _def.id, "length_mm": _def.length_mm(), "time_limit_ms": _def.time_limit_ms})
	_set_fall(api)
	_publish(api)


## Advances by dt_ms of play time and returns the records emitted, in order. Board writes queue on `api`; a
## board-changing tick ends the step early (the rest carries to the next step) so nothing reads queued cells.
func step(dt_ms: int, api: RuleApi) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if _finished or _failed:
		return out
	_barrier = false
	var before: int = _pos_um
	_acc_ms += maxi(0, dt_ms)
	while not _barrier and not _finished and not _failed:
		if _fire_due(api, out):
			continue
		if _pos_um >= _def.length_mm() * 1000:
			_end_of_track(api, out)
			break
		if _elapsed_ms >= _def.time_limit_ms:
			_time_up(api, out)
			break
		if _acc_ms < _def.tick_ms:
			break
		_acc_ms -= _def.tick_ms
		_tick_once(api, out)
	_publish(api)
	if _pos_um != before:
		api.emit(EV_PROGRESS, {"at_mm": position_mm(), "lean_pm": lean_pm(), "time_left_ms": time_left_ms()})
	return out


## Track distance covered, in mm.
func position_mm() -> int:
	return _pos_um / 1000


## Progress 0..1000 along the track (current position, which can go back after a restart).
func progress_pm() -> int:
	return _pos_um / maxi(1, _def.length_mm())


## True once the platform reached the end in time with the cargo aboard.
func is_finished() -> bool:
	return _finished


## True once the run ended in a loss (time up, or cargo lost with on_loss = fail).
func is_failed() -> bool:
	return _failed


## Why the run failed: &"time_up", &"cargo_lost" or &"" while running.
func fail_reason() -> StringName:
	return _fail_reason


## Attempts so far; 1 on the first run, +1 per return to a post.
func attempts() -> int:
	return _attempts


## Id of the last post passed ("" before the first).
func checkpoint_id() -> StringName:
	return _cp_id


## Sim ticks advanced so far.
func tick_count() -> int:
	return _tick


## Play time used, in ms (includes restart penalties).
func elapsed_ms() -> int:
	return _elapsed_ms


## Play time left before the limit, in ms (never negative).
func time_left_ms() -> int:
	return maxi(0, _def.time_limit_ms - _elapsed_ms)


## Lean magnitude for the HUD meter, 0..1000.
func lean_pm() -> int:
	return mini(1000, maxi(absi(_lean.x), absi(_lean.y)))


## Lean for the HUD: {"x","z" signed permille, "pm" 0..1000, "danger_pm", "limit_pm"}.
func lean_state() -> Dictionary:
	return {"x": _lean.x, "z": _lean.y, "pm": lean_pm(), "danger_pm": int(_def.lean["danger_pm"]), "limit_pm": int(_def.lean["limit_pm"])}


## Cargo for the view: {"state" (CARGO_*), "name", "stress_pm", "x", "z", "h" (seat layers), "support"}.
func cargo_state() -> Dictionary:
	return {"state": _cargo_state, "name": CARGO_NAMES[_cargo_state], "stress_pm": _stress_u / 1000,
		"x": _seat["x"], "z": _seat["z"], "h": _seat["h"], "support": _seat["support"]}


## Current platform speed in mm per second, including any updraft lift.
func speed_mm_s() -> int:
	var base: int = _def.speed_at_mm(position_mm())
	return base * (100 + _lift_pct) / 100 if _tick <= _lift_until_tick else base


## The preview strip feed for the track ahead (see TrackDef.preview).
func preview() -> Array[Dictionary]:
	return _def.preview(position_mm())


## Plain-data copy of the runner state, for replay and rollback.
func snapshot() -> Dictionary:
	return {"pos_um": _pos_um, "acc_ms": _acc_ms, "tick": _tick, "elapsed": _elapsed_ms, "next_event": _next_event,
		"next_cp": _next_cp, "cp_mm": _cp_mm, "cp_id": _cp_id, "cp_elapsed": _cp_elapsed_ms, "attempts": _attempts,
		"finished": _finished, "failed": _failed, "fail_reason": _fail_reason, "lift_pct": _lift_pct,
		"lift_until": _lift_until_tick, "impulse_u": _impulse_u, "lean": _lean, "lean_warned": _lean_warned,
		"stress_u": _stress_u, "cargo_state": _cargo_state, "prev_seat_h": _prev_seat_h, "seat": _seat.duplicate(),
		"best_pm": _best_pm, "fall_sent": _fall_sent}


## Restores a snapshot taken by snapshot().
func restore(s: Dictionary) -> void:
	_pos_um = int(s["pos_um"])
	_acc_ms = int(s["acc_ms"])
	_tick = int(s["tick"])
	_elapsed_ms = int(s["elapsed"])
	_next_event = int(s["next_event"])
	_next_cp = int(s["next_cp"])
	_cp_mm = int(s["cp_mm"])
	_cp_id = s["cp_id"]
	_cp_elapsed_ms = int(s["cp_elapsed"])
	_attempts = int(s["attempts"])
	_finished = bool(s["finished"])
	_failed = bool(s["failed"])
	_fail_reason = s["fail_reason"]
	_lift_pct = int(s["lift_pct"])
	_lift_until_tick = int(s["lift_until"])
	_impulse_u = s["impulse_u"]
	_lean = s["lean"]
	_lean_warned = bool(s["lean_warned"])
	_stress_u = int(s["stress_u"])
	_cargo_state = int(s["cargo_state"])
	_prev_seat_h = int(s["prev_seat_h"])
	_seat = (s["seat"] as Dictionary).duplicate()
	_best_pm = int(s["best_pm"])
	_fall_sent = int(s["fall_sent"])


# --- tick ---------------------------------------------------------------------------------------------

func _tick_once(api: RuleApi, out: Array[Dictionary]) -> void:
	_tick += 1
	_elapsed_ms += _def.tick_ms
	var end_um: int = _def.length_mm() * 1000
	_pos_um = mini(_pos_um + speed_mm_s() * _def.tick_ms, end_um)
	_set_fall(api)
	var relax: int = int(_def.lean["relax_pm_per_s"]) * _def.tick_ms
	_impulse_u = Vector2i(_toward_zero(_impulse_u.x, relax), _toward_zero(_impulse_u.y, relax))
	var fx := TrackEffects.new(api, _def)
	var lean_total: Vector2i = _eval_lean(api, fx, out)
	_eval_cargo(api, fx, out, lean_total)


func _eval_lean(api: RuleApi, fx: TrackEffects, out: Array[Dictionary]) -> Vector2i:
	_lean = fx.com_pm() + _impulse_u / 1000
	var mag: int = maxi(absi(_lean.x), absi(_lean.y))
	var danger: int = int(_def.lean["danger_pm"])
	if mag >= danger and not _lean_warned:
		_lean_warned = true
		_record(api, out, EV_LEAN_WARNING, {"lean_pm": mini(mag, 1000), "x": _lean.x, "z": _lean.y})
	elif mag < danger - int(_def.lean["hysteresis_pm"]):
		_lean_warned = false
	if mag >= int(_def.lean["limit_pm"]):
		var removed: int = fx.spill(_lean)
		if removed > 0:
			_relieve_impulse()
			_barrier = true
			_record(api, out, EV_TOPPLE, {"removed": removed, "lean_pm": mini(mag, 1000), "x": _lean.x, "z": _lean.y})
	return _lean


func _relieve_impulse() -> void:
	var relief: int = int(_def.lean["spill_relief_pm"]) * 1000
	_impulse_u = Vector2i(_toward_zero(_impulse_u.x, relief), _toward_zero(_impulse_u.y, relief))


func _eval_cargo(api: RuleApi, fx: TrackEffects, out: Array[Dictionary], lean_total: Vector2i) -> void:
	_seat = fx.seat()
	var cfg: Dictionary = _def.cargo
	var stable: bool = fx.seat_is_stable(_seat)
	var leaning: bool = maxi(absi(lean_total.x), absi(lean_total.y)) >= int(_def.lean["danger_pm"])
	var rate: int = int(cfg["rise_pm_per_s"]) if not stable else -int(cfg["recover_pm_per_s"])
	var cause: StringName = &"seat" if not stable else &""
	if leaning:
		rate += int(cfg["lean_stress_pm_per_s"])
		cause = cause if cause != &"" else &"lean"
	if api.over_limit():
		rate += int(cfg["top_out_stress_pm_per_s"])
		cause = cause if cause != &"" else &"top_out"
	_stress_u += rate * _def.tick_ms
	if int(_seat["h"]) < _prev_seat_h:
		_stress_u += (_prev_seat_h - int(_seat["h"])) * int(cfg["drop_stress_pm_per_layer"]) * 1000
		cause = &"drop"
	_prev_seat_h = int(_seat["h"])
	_stress_u = maxi(0, _stress_u)
	_update_cargo_state(api, out, cause)


func _update_cargo_state(api: RuleApi, out: Array[Dictionary], cause: StringName) -> void:
	var pm: int = _stress_u / 1000
	if pm >= 1000:
		_lose_cargo(api, out, cause if cause != &"" else &"stress")
		return
	var state: int = CARGO_STABLE
	if pm >= int(_def.cargo["slip_pm"]):
		state = CARGO_SLIP
	elif pm >= int(_def.cargo["wobble_pm"]):
		state = CARGO_WOBBLE
	if state != _cargo_state:
		_cargo_state = state
		_record(api, out, EV_CARGO_STATE, cargo_state())


# --- events -------------------------------------------------------------------------------------------

## Fires the earliest due checkpoint or event (checkpoint first on a tie). True when something fired.
func _fire_due(api: RuleApi, out: Array[Dictionary]) -> bool:
	var cp_at: int = int(_def.checkpoints[_next_cp]["at_mm"]) * 1000 if _next_cp < _def.checkpoints.size() else -1
	var ev_at: int = int(_def.events[_next_event]["at_mm"]) * 1000 if _next_event < _def.events.size() else -1
	var cp_due: bool = cp_at >= 0 and cp_at <= _pos_um
	var ev_due: bool = ev_at >= 0 and ev_at <= _pos_um
	if cp_due and (not ev_due or cp_at <= ev_at):
		_pass_checkpoint(api, out)
		return true
	if ev_due:
		_fire_event(api, out)
		return true
	return false


func _pass_checkpoint(api: RuleApi, out: Array[Dictionary]) -> void:
	var cp: Dictionary = _def.checkpoints[_next_cp]
	_next_cp += 1
	_cp_mm = int(cp["at_mm"])
	_cp_id = StringName(String(cp.get("id", "")))
	_cp_elapsed_ms = _elapsed_ms
	_record(api, out, EV_CHECKPOINT, {"id": _cp_id, "at_mm": _cp_mm})


func _fire_event(api: RuleApi, out: Array[Dictionary]) -> void:
	var e: Dictionary = _def.events[_next_event]
	_next_event += 1
	var fx := TrackEffects.new(api, _def)
	var seat_before: Dictionary = fx.seat()
	var res: Dictionary = fx.apply(e)
	if res.has("lift_pct"):
		_lift_pct = int(res["lift_pct"])
		_lift_until_tick = _tick + int(e["duration_ms"]) / _def.tick_ms
	if res.has("impulse"):
		_impulse_u += (res["impulse"] as Vector2i) * 1000
	_stress_u += int(res.get("stress_pm", 0)) * 1000
	var data: Dictionary = res.duplicate()
	data["event"] = e["kind"]
	data["at_mm"] = e["at_mm"]
	_record(api, out, EV_EVENT, data)
	_barrier = _barrier or bool(res["mutated"])
	if e["kind"] == TrackDef.KIND_ARCH and int(seat_before["h"]) + int(_def.cargo["height_layers"]) > int(e["gap_layers"]):
		_lose_cargo(api, out, &"arch")


# --- loss, restart, end -------------------------------------------------------------------------------

func _lose_cargo(api: RuleApi, out: Array[Dictionary], cause: StringName) -> void:
	_barrier = true
	_cargo_state = CARGO_LOST
	_record(api, out, EV_CARGO_LOST, {"cause": cause, "at_mm": position_mm(), "attempt": _attempts})
	if _def.on_loss == &"fail":
		_failed = true
		_fail_reason = &"cargo_lost"
		api.request_fail(&"cargo_lost")
		return
	_restart_from_checkpoint(api, out)


## Returns to the last post: every block giggles away (a queued wipe, so it also catches blocks moved by writes
## that are still queued), the falling piece goes back to spawn, and the clock takes the restart penalty.
func _restart_from_checkpoint(api: RuleApi, out: Array[Dictionary]) -> void:
	TrackEffects.new(api, _def).clear_all()
	api.return_piece_to_spawn()
	_pos_um = _cp_mm * 1000
	_attempts += 1
	_elapsed_ms = _cp_elapsed_ms + _def.restart_penalty_ms
	_lift_until_tick = -1
	_impulse_u = Vector2i.ZERO
	_lean = Vector2i.ZERO
	_lean_warned = false
	_stress_u = 0
	_cargo_state = CARGO_STABLE
	_prev_seat_h = 0
	_seat = {"x": 0, "z": 0, "h": 0, "support": 9}
	_next_event = 0
	while _next_event < _def.events.size() and int(_def.events[_next_event]["at_mm"]) < _cp_mm:
		_next_event += 1
	_next_cp = 0
	while _next_cp < _def.checkpoints.size() and int(_def.checkpoints[_next_cp]["at_mm"]) <= _cp_mm:
		_next_cp += 1
	_fall_sent = -1
	_set_fall(api)
	_record(api, out, EV_RESTART, {"at_mm": _cp_mm, "attempt": _attempts, "time_left_ms": time_left_ms()})


func _end_of_track(api: RuleApi, out: Array[Dictionary]) -> void:
	if _elapsed_ms > _def.time_limit_ms:
		_time_up(api, out)
		return
	_finished = true
	_record(api, out, EV_FINISHED, {"at_mm": position_mm(), "attempts": _attempts, "time_left_ms": time_left_ms()})


func _time_up(api: RuleApi, out: Array[Dictionary]) -> void:
	_failed = true
	_fail_reason = &"time_up"
	api.request_fail(&"time_up")
	_record(api, out, EV_TIME_UP, {"at_mm": position_mm(), "attempts": _attempts})


# --- helpers ------------------------------------------------------------------------------------------

func _set_fall(api: RuleApi) -> void:
	var pct: int = _def.fall_pct_at(position_mm())
	if pct != _fall_sent:
		_fall_sent = pct
		api.request_slot(&"fall.gravity_scale", pct * 10)


func _publish(api: RuleApi) -> void:
	_best_pm = maxi(_best_pm, progress_pm())
	api.goal_metric(METRIC_PROGRESS_PM, _best_pm)
	api.goal_metric(METRIC_FINISHED, 1 if _finished else 0)
	api.goal_metric(METRIC_FAILED, 1 if _failed else 0)
	api.goal_metric(METRIC_LEAN_PM, lean_pm())
	api.goal_metric(METRIC_LEAN_DANGER_PM, int(_def.lean["danger_pm"]))
	api.goal_metric(METRIC_CARGO_STATE, _cargo_state)
	api.goal_metric(METRIC_CARGO_STRESS_PM, _stress_u / 1000)
	api.goal_metric(METRIC_TIME_LEFT_MS, time_left_ms())
	api.goal_metric(METRIC_FALL_PCT, maxi(0, _fall_sent))


func _toward_zero(v: int, amount: int) -> int:
	return maxi(0, v - amount) if v > 0 else mini(0, v + amount)


func _record(api: RuleApi, out: Array[Dictionary], kind: StringName, data: Dictionary) -> void:
	var rec: Dictionary = data.duplicate()
	rec["kind"] = kind
	rec["tick"] = _tick
	out.append(rec)
	api.emit(kind, rec)
