class_name TrackRunner extends RefCounted
## Deterministic moving-platform sim (gap G8, docs/architecture/moving-platform.md). Pure logic: no nodes, no wall
## clock, no dice. No clock, three tries: a topple that outlasts the dwell, a lost cargo or a missed ring costs a heart
## and returns the platform to the last post; at 0 hearts the run fails. Reaching the end finishes it, and the stack
## height there decides the stars. Position is integer micrometres (mm/s * ms), rates accumulate in milli-permille.
## Usage: var r := TrackRunner.new(def); r.begin(api); var out: Array[Dictionary] = r.step(50, api).

## Emitted record kinds (also forwarded to api.emit). Each record has "kind", "tick".
const EV_STARTED := &"track_started"
const EV_PROGRESS := &"track_progress"
const EV_EVENT := &"track_event"
const EV_CHECKPOINT := &"track_checkpoint"
const EV_LEAN_WARNING := &"track_lean_warning"
const EV_TOPPLE_WARNING := &"track_topple_warning"
const EV_TOPPLE := &"track_topple"
const EV_HEART_LOST := &"track_heart_lost"
const EV_RING := &"track_ring"
const EV_CARGO_STATE := &"track_cargo_state"
const EV_CARGO_LOST := &"track_cargo_lost"
const EV_RESTART := &"track_restart"
const EV_FINISHED := &"track_finished"
## Goal metric names (read by TrackRaceGoal and the HUD).
const METRIC_PROGRESS_PM := &"track_progress_pm"
const METRIC_FINISHED := &"track_finished"
const METRIC_FAILED := &"track_failed"
const METRIC_LEAN_PM := &"track_lean_pm"
const METRIC_LEAN_DANGER_PM := &"track_lean_danger_pm"
const METRIC_CARGO_STATE := &"track_cargo_state"
const METRIC_CARGO_STRESS_PM := &"track_cargo_stress_pm"
const METRIC_HEARTS := &"track_hearts"
const METRIC_ALTITUDE_PM := &"track_altitude_pm"
const METRIC_FINISH_HEIGHT := &"track_finish_height"
const METRIC_STARS := &"track_stars"
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
var _next_event: int = 0
var _next_cp: int = 0
var _next_ring: int = 0
var _cp_mm: int = 0
var _cp_id: StringName = &""
var _hearts_left: int = 0
var _finished: bool = false
var _failed: bool = false
var _fail_reason: StringName = &""
var _barrier: bool = false
var _alt_u: int = 0  # altitude, milli-permille
var _lift_rate: int = 0  # permille per second while an updraft is active
var _lift_until_tick: int = -1
var _impulse_u: Vector2i = Vector2i.ZERO  # milli-permille
var _lean: Vector2i = Vector2i.ZERO
var _lean_warned: bool = false
var _over_ms: int = 0
var _stress_u: int = 0  # milli-permille
var _cargo_state: int = CARGO_STABLE
var _cargo_cause: StringName = &""
var _prev_seat_h: int = 0
var _seat: Dictionary = {"x": 0, "z": 0, "h": 0, "support": 9}
var _best_pm: int = 0
var _fall_sent: int = -1
var _finish_height: int = 0
var _stars: int = 0


## Creates a runner. `def` must be valid.
func _init(def: TrackDef) -> void:
	assert(def != null and def.is_valid(), "TrackRunner needs a valid TrackDef")
	_def = def
	_hearts_left = def.hearts
	_alt_u = int(def.altitude.get("start_pm", 0)) * 1000


## Announces the track and sets the first fall speed. Call once from on_level_start.
func begin(api: RuleApi) -> void:
	announce(api)
	_set_fall(api)
	_publish(api)


## Emits track_started again (also after a rule restore) so a view that lost the track can re-attach.
func announce(api: RuleApi) -> void:
	var out: Array[Dictionary] = []
	_record(api, out, EV_STARTED, {"track": _def.id, "length_mm": _def.length_mm(), "hearts": _hearts_left,
		"at_mm": position_mm()})


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
			_finish(api, out)
			break
		if _acc_ms < _def.tick_ms:
			break
		_acc_ms -= _def.tick_ms
		_tick_once(api, out)
	_publish(api)
	if _pos_um != before:
		api.emit(EV_PROGRESS, {"at_mm": position_mm(), "lean_pm": lean_pm(), "hearts": _hearts_left, "altitude_pm": altitude_pm()})
	return out


## Track distance covered, in mm.
func position_mm() -> int:
	return _pos_um / 1000


## Progress 0..1000 along the track (current position, which can go back after a restart).
func progress_pm() -> int:
	return _pos_um / maxi(1, _def.length_mm())


## True once the platform reached the end of the track.
func is_finished() -> bool:
	return _finished


## True once the run failed (no hearts left).
func is_failed() -> bool:
	return _failed


## Why the run failed: &"no_hearts", or &"" while running.
func fail_reason() -> StringName:
	return _fail_reason


## Tries left.
func hearts_left() -> int:
	return _hearts_left


## Attempts so far, 1 on the first run.
func attempts() -> int:
	return _def.hearts - _hearts_left + 1


## Id of the last post passed ("" before the first).
func checkpoint_id() -> StringName:
	return _cp_id


## Sim ticks advanced so far.
func tick_count() -> int:
	return _tick


## Stars awarded at the finish (0 until then).
func stars() -> int:
	return _stars


## Stack height in layers when the platform finished (0 until then).
func finish_height() -> int:
	return _finish_height


## Kite altitude 0..1000 (0 on tracks without altitude).
func altitude_pm() -> int:
	return _alt_u / 1000


## Lean magnitude for the HUD meter, 0..1000.
func lean_pm() -> int:
	return mini(1000, maxi(absi(_lean.x), absi(_lean.y)))


## Lean for the HUD: {"x","z" signed permille, "pm" 0..1000, "danger_pm", "limit_pm"}.
func lean_state() -> Dictionary:
	return {"x": _lean.x, "z": _lean.y, "pm": lean_pm(), "danger_pm": int(_def.lean["danger_pm"]), "limit_pm": int(_def.lean["limit_pm"])}


## Cargo for the view: {"state" (CARGO_*), "name", "cause", "stress_pm", "x", "z", "h" (seat layers), "support"}.
func cargo_state() -> Dictionary:
	return {"state": _cargo_state, "name": CARGO_NAMES[_cargo_state], "cause": _cargo_cause, "stress_pm": _stress_u / 1000,
		"x": _seat["x"], "z": _seat["z"], "h": _seat["h"], "support": _seat["support"]}


## Current platform speed in mm per second (the segment speed).
func speed_mm_s() -> int:
	return _def.speed_at_mm(position_mm())


## The preview strip feed for the track ahead (TrackDef.preview) with the current stack folded in: gust safe
## heights, an "updraft_active" row while a lift runs, and for rings the altitude now and projected at the ring.
func preview(api: RuleApi) -> Array[Dictionary]:
	var size: Vector3i = api.board_size()
	var fx := TrackEffects.new(api, _def)
	var rows: Array[Dictionary] = _def.preview(position_mm(), -1, size.x * size.z, fx.cell_count())
	for row: Dictionary in rows:
		if row["kind"] == &"ring":
			row["altitude_now_pm"] = altitude_pm()
			row["altitude_projected_pm"] = _project_altitude(int(row["at_mm"]), fx)
	if _tick <= _lift_until_tick:
		rows.push_front({"kind": &"updraft_active", "remaining_ms": (_lift_until_tick - _tick + 1) * _def.tick_ms,
			"lift_pm_per_s": _lift_rate, "ahead_mm": 0, "ahead_ms": 0, "severity": 1, "at_mm": position_mm()})
	return rows


## Plain-data copy of the runner state, for replay and rollback.
func snapshot() -> Dictionary:
	return {"pos_um": _pos_um, "acc_ms": _acc_ms, "tick": _tick, "next_event": _next_event, "next_cp": _next_cp,
		"next_ring": _next_ring, "cp_mm": _cp_mm, "cp_id": _cp_id, "hearts": _hearts_left, "finished": _finished,
		"failed": _failed, "fail_reason": _fail_reason, "alt_u": _alt_u, "lift_rate": _lift_rate,
		"lift_until": _lift_until_tick, "impulse_u": _impulse_u, "lean": _lean, "lean_warned": _lean_warned,
		"over_ms": _over_ms, "stress_u": _stress_u, "cargo_state": _cargo_state, "cargo_cause": _cargo_cause,
		"prev_seat_h": _prev_seat_h, "seat": _seat.duplicate(), "best_pm": _best_pm, "fall_sent": _fall_sent,
		"finish_height": _finish_height, "stars": _stars}


## Restores a snapshot taken by snapshot().
func restore(s: Dictionary) -> void:
	_pos_um = int(s["pos_um"])
	_acc_ms = int(s["acc_ms"])
	_tick = int(s["tick"])
	_next_event = int(s["next_event"])
	_next_cp = int(s["next_cp"])
	_next_ring = int(s["next_ring"])
	_cp_mm = int(s["cp_mm"])
	_cp_id = s["cp_id"]
	_hearts_left = int(s["hearts"])
	_finished = bool(s["finished"])
	_failed = bool(s["failed"])
	_fail_reason = s["fail_reason"]
	_alt_u = int(s["alt_u"])
	_lift_rate = int(s["lift_rate"])
	_lift_until_tick = int(s["lift_until"])
	_impulse_u = s["impulse_u"]
	_lean = s["lean"]
	_lean_warned = bool(s["lean_warned"])
	_over_ms = int(s["over_ms"])
	_stress_u = int(s["stress_u"])
	_cargo_state = int(s["cargo_state"])
	_cargo_cause = s["cargo_cause"]
	_prev_seat_h = int(s["prev_seat_h"])
	_seat = (s["seat"] as Dictionary).duplicate()
	_best_pm = int(s["best_pm"])
	_fall_sent = int(s["fall_sent"])
	_finish_height = int(s["finish_height"])
	_stars = int(s["stars"])


# --- tick ---------------------------------------------------------------------------------------------

func _tick_once(api: RuleApi, out: Array[Dictionary]) -> void:
	_tick += 1
	_pos_um = mini(_pos_um + speed_mm_s() * _def.tick_ms, _def.length_mm() * 1000)
	_set_fall(api)
	var relax: int = int(_def.lean["relax_pm_per_s"]) * _def.tick_ms
	_impulse_u = Vector2i(_toward_zero(_impulse_u.x, relax), _toward_zero(_impulse_u.y, relax))
	_move_altitude()
	var fx := TrackEffects.new(api, _def)
	var lean_total: Vector2i = _eval_lean(api, fx, out)
	if _barrier or _failed:
		return
	_eval_cargo(api, fx, out, lean_total)


func _move_altitude() -> void:
	if _def.altitude.is_empty():
		return
	var rate: int = (_lift_rate if _tick <= _lift_until_tick else 0) - int(_def.altitude["sink_pm_per_s"])
	_alt_u = clampi(_alt_u + rate * _def.tick_ms, 0, 1000000)


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
		if _over_ms == 0:
			_record(api, out, EV_TOPPLE_WARNING, {"dwell_ms": int(_def.lean["dwell_ms"]), "lean_pm": mini(mag, 1000)})
		_over_ms += _def.tick_ms
		if _over_ms >= int(_def.lean["dwell_ms"]):
			_record(api, out, EV_TOPPLE, {"lean_pm": mini(mag, 1000), "x": _lean.x, "z": _lean.y})
			_lose_heart(api, out, &"topple")
	else:
		_over_ms = 0
	return _lean


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
	if cause != &"":
		_cargo_cause = cause
	_update_cargo_state(api, out)


## Stress never skips a warning stage: the stress itself is kept whole (a huge hit is not thrown away), but the
## state climbs at most one stage per tick: stable -> wobble -> slip -> lost, each on its own tick.
func _update_cargo_state(api: RuleApi, out: Array[Dictionary]) -> void:
	var pm: int = _stress_u / 1000
	var target: int = CARGO_STABLE
	if pm >= 1000:  # full scale of the stress meter
		target = CARGO_LOST
	elif pm >= int(_def.cargo["slip_pm"]):
		target = CARGO_SLIP
	elif pm >= int(_def.cargo["wobble_pm"]):
		target = CARGO_WOBBLE
	target = mini(target, _cargo_state + 1)
	if target == CARGO_LOST:
		_record(api, out, EV_CARGO_LOST, {"cause": _cargo_cause, "at_mm": position_mm(), "hearts_left": _hearts_left})
		_cargo_state = CARGO_LOST
		_lose_heart(api, out, &"cargo_lost")
		return
	if target != _cargo_state:
		_cargo_state = target
		if target == CARGO_STABLE:
			_cargo_cause = &""
		_record(api, out, EV_CARGO_STATE, cargo_state())


# --- events -------------------------------------------------------------------------------------------

## Fires the earliest due checkpoint, event or ring (in that order on a tie). True when something fired.
func _fire_due(api: RuleApi, out: Array[Dictionary]) -> bool:
	var cp_at: int = int(_def.checkpoints[_next_cp]["at_mm"]) * 1000 if _next_cp < _def.checkpoints.size() else -1
	var ev_at: int = int(_def.events[_next_event]["at_mm"]) * 1000 if _next_event < _def.events.size() else -1
	var ring_at: int = int(_def.rings[_next_ring]["at_mm"]) * 1000 if _next_ring < _def.rings.size() else -1
	var cp_due: bool = cp_at >= 0 and cp_at <= _pos_um
	var ev_due: bool = ev_at >= 0 and ev_at <= _pos_um
	var ring_due: bool = ring_at >= 0 and ring_at <= _pos_um
	if cp_due and (not ev_due or cp_at <= ev_at) and (not ring_due or cp_at <= ring_at):
		_pass_checkpoint(api, out)
		return true
	if ev_due and (not ring_due or ev_at <= ring_at):
		_fire_event(api, out)
		return true
	if ring_due:
		_pass_ring(api, out)
		return true
	return false


func _pass_checkpoint(api: RuleApi, out: Array[Dictionary]) -> void:
	var cp: Dictionary = _def.checkpoints[_next_cp]
	_next_cp += 1
	_cp_mm = int(cp["at_mm"])
	_cp_id = StringName(String(cp.get("id", "")))
	_record(api, out, EV_CHECKPOINT, {"id": _cp_id, "at_mm": _cp_mm})


func _pass_ring(api: RuleApi, out: Array[Dictionary]) -> void:
	var ring: Dictionary = _def.rings[_next_ring]
	_next_ring += 1
	var alt: int = altitude_pm()
	var hit: bool = alt >= int(ring["min_pm"]) and alt <= int(ring["max_pm"])
	_record(api, out, EV_RING, {"id": ring.get("id", ""), "hit": hit, "altitude_pm": alt, "min_pm": ring["min_pm"],
		"max_pm": ring["max_pm"], "at_mm": ring["at_mm"]})
	if not hit:
		_lose_heart(api, out, &"ring_missed")


func _fire_event(api: RuleApi, out: Array[Dictionary]) -> void:
	var e: Dictionary = _def.events[_next_event]
	_next_event += 1
	var fx := TrackEffects.new(api, _def)
	var seat_before: Dictionary = fx.seat()
	var res: Dictionary = fx.apply(e)
	if res.has("lift_pm_per_s"):
		_lift_rate = int(res["lift_pm_per_s"])
		_lift_until_tick = _tick + int(e["duration_ms"]) / _def.tick_ms
	if res.has("impulse"):
		_impulse_u += (res["impulse"] as Vector2i) * 1000
	if int(res.get("stress_pm", 0)) > 0:
		_stress_u += int(res["stress_pm"]) * 1000
		_cargo_cause = e["kind"]
	var data: Dictionary = res.duplicate()
	data["event"] = e["kind"]
	data["at_mm"] = e["at_mm"]
	_record(api, out, EV_EVENT, data)
	if e["kind"] == TrackDef.KIND_ARCH and int(seat_before["h"]) + int(_def.cargo["height_layers"]) > int(e["gap_layers"]):
		_cargo_cause = &"arch"
		_record(api, out, EV_CARGO_LOST, {"cause": &"arch", "at_mm": position_mm(), "hearts_left": _hearts_left})
		_lose_heart(api, out, &"arch")


# --- hearts, restart, end -----------------------------------------------------------------------------

## A loss: topple, lost cargo, missed ring or arch. Costs a heart; at 0 the run fails, else back to the last post.
func _lose_heart(api: RuleApi, out: Array[Dictionary], cause: StringName) -> void:
	_barrier = true
	_hearts_left -= 1
	_record(api, out, EV_HEART_LOST, {"cause": cause, "hearts_left": _hearts_left, "at_mm": position_mm()})
	if _hearts_left <= 0:
		_failed = true
		_fail_reason = &"no_hearts"
		api.request_fail(&"no_hearts")
		return
	_restart_from_checkpoint(api, out)


## Returns to the last post: every block giggles away (a queued wipe, so it also catches blocks moved by writes
## that are still queued), the falling piece goes back to spawn, and the lean, stress, altitude and lift reset.
func _restart_from_checkpoint(api: RuleApi, out: Array[Dictionary]) -> void:
	TrackEffects.new(api, _def).clear_all()
	api.return_piece_to_spawn()
	_pos_um = _cp_mm * 1000
	_lift_until_tick = -1
	_lift_rate = 0
	_alt_u = int(_def.altitude.get("start_pm", 0)) * 1000
	_impulse_u = Vector2i.ZERO
	_lean = Vector2i.ZERO
	_lean_warned = false
	_over_ms = 0
	_stress_u = 0
	_cargo_state = CARGO_STABLE
	_cargo_cause = &""
	_prev_seat_h = 0
	_seat = {"x": 0, "z": 0, "h": 0, "support": 9}
	_next_event = _first_at_or_after(_def.events, _cp_mm, false)
	_next_ring = _first_at_or_after(_def.rings, _cp_mm, false)
	_next_cp = _first_at_or_after(_def.checkpoints, _cp_mm, true)
	_fall_sent = -1
	_set_fall(api)
	_record(api, out, EV_RESTART, {"at_mm": _cp_mm, "hearts_left": _hearts_left})


func _first_at_or_after(rows: Array[Dictionary], mm: int, strictly_after: bool) -> int:
	var i: int = 0
	while i < rows.size() and (int(rows[i]["at_mm"]) <= mm if strictly_after else int(rows[i]["at_mm"]) < mm):
		i += 1
	return i


func _finish(api: RuleApi, out: Array[Dictionary]) -> void:
	_finished = true
	_finish_height = TrackEffects.new(api, _def).stack_layers()
	var lost: int = _def.hearts - _hearts_left
	_stars = _def.stars_for(_finish_height, lost)
	_record(api, out, EV_FINISHED, {"at_mm": position_mm(), "height": _finish_height, "stars": _stars,
		"hearts_left": _hearts_left, "hearts_lost": lost})


# --- helpers ------------------------------------------------------------------------------------------

## Altitude the kite will have at track distance `to_mm`, at base speeds, counting the lift now running and the
## scheduled updrafts (a newer updraft replaces an older one, as in the sim) at the current build's lightness.
func _project_altitude(to_mm: int, fx: TrackEffects) -> int:
	if _def.altitude.is_empty():
		return 0
	var total_ms: int = _def.time_between_ms(position_mm(), to_mm)
	var windows: Array[Vector3i] = []  # start_ms, end_ms, rate
	if _tick <= _lift_until_tick:
		windows.append(Vector3i(0, (_lift_until_tick - _tick + 1) * _def.tick_ms, _lift_rate))
	var cfg: Dictionary = _def.effects.get("updraft", {}) as Dictionary
	for e: Dictionary in _def.events:
		if e["kind"] == TrackDef.KIND_UPDRAFT and int(e["at_mm"]) >= position_mm() and int(e["at_mm"]) < to_mm and not cfg.is_empty():
			var start: int = _def.time_between_ms(position_mm(), int(e["at_mm"]))
			windows.append(Vector3i(start, start + int(e["duration_ms"]), int(cfg["lift_pm_per_s"]) * fx.lightness_pct() / 100))
	var alt: int = altitude_pm()
	var sink: int = int(_def.altitude["sink_pm_per_s"])
	var t: int = 0
	while t < total_ms:
		var rate: int = 0
		for w: Vector3i in windows:
			if t >= w.x and t < w.y:
				rate = w.z
		alt = clampi(alt + (rate - sink) * 100 / 1000, 0, 1000)
		t += 100
	return alt


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
	api.goal_metric(METRIC_HEARTS, _hearts_left)
	api.goal_metric(METRIC_ALTITUDE_PM, altitude_pm())
	api.goal_metric(METRIC_FINISH_HEIGHT, _finish_height)
	api.goal_metric(METRIC_STARS, _stars)
	api.goal_metric(METRIC_FALL_PCT, maxi(0, _fall_sent))


func _toward_zero(v: int, amount: int) -> int:
	return maxi(0, v - amount) if v > 0 else mini(0, v + amount)


func _record(api: RuleApi, out: Array[Dictionary], kind: StringName, data: Dictionary) -> void:
	var rec: Dictionary = data.duplicate()
	rec["kind"] = kind
	rec["tick"] = _tick
	out.append(rec)
	api.emit(kind, rec)
