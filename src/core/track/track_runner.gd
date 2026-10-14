class_name TrackRunner extends RefCounted
## Deterministic moving-platform sim (gap G8, docs/architecture/moving-platform.md). Pure logic: no nodes, no wall clock.
## Advances along a TrackDef in fixed ticks, fires scheduled events, and applies them to the stack through
## TrackEffects and the RuleApi. Same def + seed + dt sequence gives the same result on every machine.
## Position is held in micrometres (mm/s * ms), so there is no float drift.
## Usage: var r := TrackRunner.new(def, seed); var out: Array[Dictionary] = r.step(50, api).

## Emitted record kinds (also forwarded to api.emit). Each record has "kind", "tick", "at_mm".
const EV_EVENT := &"track_event"
const EV_CHECKPOINT := &"track_checkpoint"
const EV_CARGO_LOST := &"track_cargo_lost"
const EV_RESTART := &"track_restart"
const EV_FINISHED := &"track_finished"
## Goal metric names written for goal evaluators.
const METRIC_PROGRESS_PM := &"track_progress_pm"
const METRIC_FINISHED := &"track_finished"

var _def: TrackDef
var _rng: RandomNumberGenerator
var _pos_um: int = 0
var _acc_ms: int = 0
var _tick: int = 0
var _next_event: int = 0
var _next_cp: int = 0
var _cp_mm: int = 0
var _cp_id: StringName = &""
var _attempts: int = 1
var _finished: bool = false
var _failed: bool = false
var _barrier: bool = false
var _lift_pct: int = 0
var _lift_until_tick: int = -1
var _cargo_seat: int = 0


## Creates a runner. `def` must be valid; `seed` feeds the track's own stream (Seeds.make_rng).
func _init(def: TrackDef, seed: int) -> void:
	assert(def != null and def.is_valid(), "TrackRunner needs a valid TrackDef")
	_def = def
	_rng = Seeds.make_rng(seed, ["track", String(def.id)])


## Advances the platform by dt_ms of play time and returns the records emitted, in order.
## Board writes queue on `api`; a board-changing event ends the step early (the rest is carried to the next
## step) so the next event never reads cells that are still queued. Call once per sim tick.
func step(dt_ms: int, api: RuleApi) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if _finished or _failed:
		return out
	_barrier = false
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
		_tick += 1
		_pos_um = mini(_pos_um + _speed_mm_s(api) * _def.tick_ms, _def.length_mm() * 1000)
	api.goal_metric(METRIC_PROGRESS_PM, progress_pm())
	return out


## Track distance covered, in mm.
func position_mm() -> int:
	return _pos_um / 1000


## Progress 0..1000 along the track.
func progress_pm() -> int:
	return _pos_um / maxi(1, _def.length_mm())


## True once the platform reached the end with the cargo aboard.
func is_finished() -> bool:
	return _finished


## True once a loss ended the run (on_loss == fail).
func is_failed() -> bool:
	return _failed


## Attempts so far; 1 on the first run, +1 per return to a post.
func attempts() -> int:
	return _attempts


## Id of the last post passed ("" before the first).
func checkpoint_id() -> StringName:
	return _cp_id


## Sim ticks advanced so far.
func tick_count() -> int:
	return _tick


## Current platform speed in mm per second, including any updraft lift.
func speed_mm_s(api: RuleApi) -> int:
	return _speed_mm_s(api)


## The preview strip feed for the track ahead of the platform (see TrackDef.preview).
func preview() -> Array[Dictionary]:
	return _def.preview(position_mm())


## Plain-data copy of the runner state, for replay and rollback. Usage: runner.restore(runner.snapshot()).
func snapshot() -> Dictionary:
	return {"pos_um": _pos_um, "acc_ms": _acc_ms, "tick": _tick, "next_event": _next_event, "next_cp": _next_cp,
		"cp_mm": _cp_mm, "cp_id": _cp_id, "attempts": _attempts, "finished": _finished, "failed": _failed,
		"lift_pct": _lift_pct, "lift_until": _lift_until_tick, "seat": _cargo_seat, "rng_state": _rng.state}


## Restores a snapshot taken by snapshot().
func restore(s: Dictionary) -> void:
	_pos_um = int(s["pos_um"])
	_acc_ms = int(s["acc_ms"])
	_tick = int(s["tick"])
	_next_event = int(s["next_event"])
	_next_cp = int(s["next_cp"])
	_cp_mm = int(s["cp_mm"])
	_cp_id = s["cp_id"]
	_attempts = int(s["attempts"])
	_finished = bool(s["finished"])
	_failed = bool(s["failed"])
	_lift_pct = int(s["lift_pct"])
	_lift_until_tick = int(s["lift_until"])
	_cargo_seat = int(s["seat"])
	_rng.state = int(s["rng_state"])


func _speed_mm_s(api: RuleApi) -> int:
	var base: int = _def.speed_at_mm(position_mm())
	if _tick > _lift_until_tick:
		return base
	var per_layer: int = int((_def.effects.get("updraft", {}) as Dictionary).get("height_pct_per_layer", 0))
	var pct: int = 100 + _lift_pct + per_layer * (api.stack_height() + 1)
	return base * pct / 100


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
	_record(api, out, EV_CHECKPOINT, {"id": _cp_id, "at_mm": _cp_mm})


func _fire_event(api: RuleApi, out: Array[Dictionary]) -> void:
	var e: Dictionary = _def.events[_next_event]
	_next_event += 1
	var fx := TrackEffects.new(api, _rng, _def)
	var has_cargo: bool = not _def.cargo.is_empty()
	var cx: int = int(_def.cargo.get("x", 0))
	var cz: int = int(_def.cargo.get("z", 0))
	var seat_before: int = fx.column_height(cx, cz) if has_cargo else 0
	var res: Dictionary = fx.apply(e)
	if res.has("lift_pct"):
		_lift_pct = int(res["lift_pct"])
		_lift_until_tick = _tick + int(e.get("duration_ms", 0)) / _def.tick_ms
	var data: Dictionary = res.duplicate()
	data["event"] = e["kind"]
	data["at_mm"] = e["at_mm"]
	_record(api, out, EV_EVENT, data)
	_barrier = _barrier or bool(res["mutated"])
	if has_cargo:
		_cargo_seat = fx.column_height(cx, cz)
		if _cargo_lost(e, seat_before, _cargo_seat):
			_lose_cargo(api, out, StringName(e["kind"]))


func _cargo_lost(e: Dictionary, before: int, after: int) -> bool:
	if e["kind"] == TrackDef.KIND_ARCH:
		return after + int(_def.cargo.get("height_layers", 1)) > int(e.get("gap_layers", 0))
	return before - after > int(_def.cargo.get("max_drop_layers", 1 << 20))


func _lose_cargo(api: RuleApi, out: Array[Dictionary], cause: StringName) -> void:
	_barrier = true
	_record(api, out, EV_CARGO_LOST, {"cause": cause, "at_mm": position_mm(), "attempt": _attempts})
	if _def.on_loss == &"fail":
		_failed = true
		api.request_fail(&"cargo_lost")
		return
	_restart_from_checkpoint(api, out)


## Returns to the last post: every block giggles away, the track and the cargo reset.
func _restart_from_checkpoint(api: RuleApi, out: Array[Dictionary]) -> void:
	var size: Vector3i = api.board_size()
	for y: int in size.y:
		for z: int in size.z:
			for x: int in size.x:
				if api.kind_at(Vector3i(x, y, z)) != 0:
					api.clear_cell(Vector3i(x, y, z), BoardState.Cause.CLEAR)
	_pos_um = _cp_mm * 1000
	_acc_ms = 0
	_attempts += 1
	_lift_until_tick = -1
	_cargo_seat = 0
	_next_event = 0
	while _next_event < _def.events.size() and int(_def.events[_next_event]["at_mm"]) < _cp_mm:
		_next_event += 1
	_next_cp = 0
	while _next_cp < _def.checkpoints.size() and int(_def.checkpoints[_next_cp]["at_mm"]) <= _cp_mm:
		_next_cp += 1
	_record(api, out, EV_RESTART, {"at_mm": _cp_mm, "attempt": _attempts})


func _finish(api: RuleApi, out: Array[Dictionary]) -> void:
	_finished = true
	api.goal_metric(METRIC_FINISHED, 1)
	_record(api, out, EV_FINISHED, {"at_mm": position_mm(), "attempts": _attempts})


func _record(api: RuleApi, out: Array[Dictionary], kind: StringName, data: Dictionary) -> void:
	var rec: Dictionary = data.duplicate()
	rec["kind"] = kind
	rec["tick"] = _tick
	out.append(rec)
	api.emit(kind, rec)
