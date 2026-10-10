class_name BoardSim extends RefCounted
## One player's play space, advanced one fixed tick at a time. Pure: no nodes, signals, Time, global RNG (ADR-0001).
## Covers countdown, spawn, gravity, soft/hard drop, move, rotate, grace, lock delay and the lock write
## (Fall, Drop & Lock GDD rules 1-14). Clears, goal and top-out (S2-S10) are CH-068.
## Usage: var sim := BoardSim.new(level, seed, catalog); sim.queue_command(cmd); var events := sim.step()
## A level with no boards (or an empty catalog) runs as the bare clock: every command is echoed as COMMAND_APPLIED.

## Fixed ticks per second (ADR-0001 tunable default).
const SIM_HZ := 60
const MS_PER_SECOND := 1000
## Knob scalars are milli-units (ADR-0004 section 3): 1000 = 1.0.
const MILLI := 1000
## Interval in ms = MILLI_PER_SECOND_SQ / g_milli (cells per second in milli-units).
const MILLI_PER_SECOND_SQ := 1_000_000
const MS_PER_MINUTE := 60_000
## Sim-local command: restarts the countdown (ADR-0010 section 1). Not in SimEvents because it is not player input.
const CMD_COUNTDOWN_RESTART := &"countdown_restart"
## PIECE_MOVED causes.
const CAUSE_FALL := &"fall"
const CAUSE_MOVE := &"move"
const CAUSE_DROP := &"drop"
## PIECE_LOCKED causes (GDD rule 14).
const LOCK_DELAY := &"delay"
const LOCK_HARD_DROP := &"hard_drop"
const LOCK_COMMIT := &"commit"
## PIECE_BLOCKED kinds, COMMAND_APPLIED result.
const KIND_MOVE := &"move"
const KIND_ROTATE := &"rotate"
const RESULT_DISABLED := &"disabled"
const REASON_SPAWN_BLOCKED := &"spawn_blocked"
## Content id used for locked cubes (assets/data/content/blocks.json).
const BLOCK_CONTENT_ID := &"block"
const NO_DEADLINE := -1

enum Phase { COUNTDOWN, WAITING, FALLING, RESTING, GRACE, RESOLVING, ENDED }

var _level: LevelData
var _seed: int
var _catalog: GameCatalog
var _tick: int = 0
var _phase: Phase = Phase.COUNTDOWN
var _queue: Array[SimCommand] = []
# ponytail: one reused array per ADR-0001 guideline; step() returns a copy.
var _events: Array[SimEvent] = []

# Gameplay state; stays null when the level has no board (bare clock).
var _board: BoardState
var _knobs: KnobRegistry
var _api: RuleApi
var _spawner: Spawner
var _arrival: ArrivalStyle
var _goal_plugin: RefCounted ## goal.type plugin; used by CH-068
var _top_out_plugin: RefCounted ## goal.top_out plugin; used by CH-068
var _goal_state: GoalState = GoalState.new()
var _piece: ActivePiece
var _piece_uid: int = 0 ## uid of the current piece
var _next_uid: int = 1
var _travel_dir: Vector3i = Vector3i.ZERO
var _soft_drop: bool = false
var _countdown_deadline: int = 0
var _play_start_ms: int = 0
var _fall_clock_ms: int = 0 ## time of the last fall step (gravity clock, rule 1a)
var _lock_deadline: int = NO_DEADLINE
var _grace_deadline: int = NO_DEADLINE
var _entry_deadline: int = NO_DEADLINE
var _resets_left: int = 0
var _lowest_layer: int = 0


func _init(level: LevelData, round_seed: int, catalog: GameCatalog) -> void:
	_level = level
	_seed = round_seed
	_catalog = catalog
	if level.boards.is_empty() or catalog.content == null or catalog.shapes == null or catalog.knob_defs == null:
		return
	_board = BoardState.new(level.boards[0], catalog.content)
	_knobs = KnobRegistry.new(catalog.knob_defs, level.knobs)
	_api = RuleApi.new(_board, _knobs)
	_spawner = Spawner.new(level.pieces, _knobs.int_value(&"spawn.queue_lookahead"), round_seed)
	if catalog.plugins != null:
		_arrival = catalog.plugins.create(&"ArrivalStyle", _knobs.value(&"spawn.arrival")) as ArrivalStyle
		_goal_plugin = catalog.plugins.create(&"GoalEvaluator", _knobs.value(&"goal.type"))
		_top_out_plugin = catalog.plugins.create(&"TopOutPolicy", _knobs.value(&"goal.top_out"))
	if _arrival == null:
		push_error("BoardSim: no ArrivalStyle plugin for knob spawn.arrival")
	_countdown_deadline = _knobs.int_value(&"goal.countdown_ms")


## Queues a command; live input (tick <= now) applies next tick, future ticks (replay) are kept. Example: sim.queue_command(SimCommand.make(SimEvents.CMD_MOVE)).
func queue_command(cmd: SimCommand) -> void:
	if cmd.tick <= _tick:
		cmd.tick = _tick + 1
	_queue.append(cmd)


## Advances exactly one tick and returns that tick's events. Example: var ev := sim.step().
func step() -> Array[SimEvent]:
	_tick += 1
	_events.clear()
	_apply_commands()
	_run_tick_hooks()
	_travel_step()
	_lock_step()
	_resolve_step()
	_goal_step()
	return _events.duplicate()


## Ticks stepped so far.
func get_tick() -> int:
	return _tick


## Sim time in ms, integer division. Example: after 30 steps -> 500.
func now_ms() -> int:
	return ms_at(_tick)


## Current phase.
func get_phase() -> Phase:
	return _phase


## The falling piece, or null when none. Example: sim.get_piece().pivot.
func get_piece() -> ActivePiece:
	return _piece


## The board, or null for a bare-clock sim. Example: sim.board().stack_height().
func board() -> BoardState:
	return _board


## Next n shape ids from the queue, head first (at most the lookahead). Example: sim.preview(3).
func preview(n: int) -> Array[StringName]:
	var out: Array[StringName] = []
	if _spawner == null:
		return out
	for id: String in _spawner.peek(n):
		out.append(StringName(id))
	return out


## Cells the piece would occupy after a hard drop (its own cells when resting); [] when no piece.
func ghost_cells() -> Array[Vector3i]:
	if _piece == null:
		var none: Array[Vector3i] = []
		return none
	return _piece.cells_at(_piece.orient, _piece.pivot + _board.down_vector() * Movement.drop_distance(_piece, _board))


## Time in ms at a given tick. Example: BoardSim.ms_at(61) == 1016.
static func ms_at(tick: int) -> int:
	return (tick * MS_PER_SECOND) / SIM_HZ


# --- commands (P0) ---------------------------------------------------------------------------------

func _apply_commands() -> void:
	var rest: Array[SimCommand] = []
	for cmd in _queue:
		if cmd.tick != _tick:
			rest.append(cmd)
		elif _board == null:
			_emit(SimEvents.COMMAND_APPLIED, {"kind": cmd.kind, "args": cmd.args})
		else:
			_apply_command(cmd)
	_queue = rest


func _apply_command(cmd: SimCommand) -> void:
	if cmd.kind == CMD_COUNTDOWN_RESTART:
		if _phase == Phase.COUNTDOWN:
			_countdown_deadline = now_ms() + _knobs.int_value(&"goal.countdown_ms")
		return
	if _piece == null: # COUNTDOWN / WAITING / RESOLVING / ENDED: ignored, the controller buffers
		return
	match cmd.kind:
		SimEvents.CMD_MOVE:
			if cmd.args.size() > 0 and cmd.args[0] is Vector3i:
				_cmd_move(cmd.args[0])
		SimEvents.CMD_ROTATE:
			if cmd.args.size() > 1:
				_cmd_rotate(cmd, int(cmd.args[0]), int(cmd.args[1]))
		SimEvents.CMD_SOFT_DROP_ON:
			_soft_drop = true
		SimEvents.CMD_SOFT_DROP_OFF:
			_soft_drop = false
		SimEvents.CMD_HARD_DROP:
			_cmd_hard_drop()


func _cmd_move(dir: Vector3i) -> void:
	var r: Dictionary = Movement.try_translate(_piece, _board, dir)
	if r["result"] == Movement.Result.OK:
		_emit(SimEvents.PIECE_MOVED, {"uid": _piece_uid, "origin": _piece.pivot, "cause": CAUSE_MOVE})
		_after_change()
	else:
		_emit(SimEvents.PIECE_BLOCKED, {"uid": _piece_uid, "kind": KIND_MOVE, "reason": r["reason"]})


func _cmd_rotate(cmd: SimCommand, axis: int, sign: int) -> void:
	var r: Dictionary = Movement.try_rotate(_piece, _board, axis as Orientations.Axis, sign, _rotate_opts())
	match r["result"]:
		Movement.Result.OK:
			_emit(SimEvents.PIECE_ROTATED, {"uid": _piece_uid, "orient": _piece.orient, "origin": _piece.pivot,
					"kicked": r["kicked"], "offset": r["offset"]})
			_after_change()
		Movement.Result.DISABLED:
			_emit(SimEvents.COMMAND_APPLIED, {"kind": cmd.kind, "args": cmd.args, "result": RESULT_DISABLED})
		_:
			_emit(SimEvents.PIECE_BLOCKED, {"uid": _piece_uid, "kind": KIND_ROTATE, "reason": r["reason"]})


# Movement options from knobs. MVP: any non-empty control.rotation_axes_enabled enables all 3 world axes
# (the controller maps spin/tilt/roll to world axes).
func _rotate_opts() -> Dictionary:
	var axes: Array[int] = []
	var enabled: Variant = _knobs.value(&"control.rotation_axes_enabled")
	if enabled is Array and not (enabled as Array).is_empty():
		axes = Movement.ALL_AXES
	return {
		"enabled_axes": axes,
		"max_up_kicks_per_piece": _knobs.int_value(&"control.max_up_kicks_per_piece"),
		"kick_enabled": _knobs.flag(&"control.kick_enabled"),
		"kick_off_axis": _knobs.flag(&"control.kick_off_axis"),
		"kick_wide_min_extent": _knobs.int_value(&"control.kick_wide_min_extent"),
		"kick_order": _knobs.value(&"control.kick_order"),
	}


# Hard drop (rules 6-8): ignored without a piece (handled by caller); a second one in grace commits.
func _cmd_hard_drop() -> void:
	if _phase == Phase.GRACE:
		_lock(LOCK_COMMIT)
		return
	var d: int = Movement.drop_distance(_piece, _board)
	if d > 0:
		_piece.pivot += _board.down_vector() * d
		_emit(SimEvents.PIECE_MOVED, {"uid": _piece_uid, "origin": _piece.pivot, "cause": CAUSE_DROP})
		_track_lowest()
	_lock_deadline = NO_DEADLINE
	_grace_deadline = now_ms() + _knobs.int_value(&"fall.hard_drop_grace_ms")
	_set_phase(Phase.GRACE)


# --- tick steps ------------------------------------------------------------------------------------

## RUL-003 fills this.
func _run_tick_hooks() -> void:
	pass


# Countdown end, entry delay end (spawn) and gravity.
func _travel_step() -> void:
	if _board == null:
		return
	var now: int = now_ms()
	if _phase == Phase.COUNTDOWN and now >= _countdown_deadline:
		_play_start_ms = now
		_spawn()
	elif _phase == Phase.RESOLVING and now >= _entry_deadline:
		# ponytail: CH-068 replaces this with the S2-S10 resolve sequence.
		_set_phase(Phase.WAITING)
		_spawn()
	if _phase != Phase.FALLING:
		return
	var interval: int = _fall_interval_ms()
	if interval == 0 or now - _fall_clock_ms < interval:
		return
	_fall_clock_ms = now
	var r: Dictionary = Movement.try_translate(_piece, _board, _travel_dir)
	if r["result"] == Movement.Result.OK:
		_emit(SimEvents.PIECE_MOVED, {"uid": _piece_uid, "origin": _piece.pivot, "cause": CAUSE_FALL})
		_after_change()
	else:
		_start_rest() # a blocked fall step means resting (rule 3)


# Lock delay and grace expiry (rules 7, 9, 13).
func _lock_step() -> void:
	if _board == null or _piece == null:
		return
	var now: int = now_ms()
	if _phase == Phase.RESTING and now >= _lock_deadline:
		_lock(LOCK_DELAY)
	elif _phase == Phase.GRACE and now >= _grace_deadline:
		_lock(LOCK_HARD_DROP) # grace is cancelled the moment the piece is unsupported, so here it rests


## SIM-005 fills this.
func _resolve_step() -> void:
	pass


## SIM-006 fills this.
func _goal_step() -> void:
	pass


# --- spawn -----------------------------------------------------------------------------------------

func _spawn() -> void:
	var shape: ShapeDef = _catalog.shapes.get_shape(_spawner.next())
	var plan: ArrivalPlan = _arrival.plan_arrival(shape, _board, _api) if shape != null and _arrival != null else null
	if plan == null or plan.blocked:
		# ponytail: CH-068 routes this through the top-out outcome (rescue/trim/lose).
		_emit(SimEvents.LEVEL_FAILED, {"reason": REASON_SPAWN_BLOCKED})
		_piece = null
		_set_phase(Phase.ENDED)
		return
	_piece = ActivePiece.new(shape, plan.origin, plan.orient)
	_piece_uid = _next_uid
	_next_uid += 1
	_travel_dir = plan.travel_dir
	_api.bind_piece(_piece)
	_soft_drop = false # rule 5 (soft_drop_carry is false by default; the knob is honoured at lock)
	_fall_clock_ms = now_ms() # rule 1a
	_lock_deadline = NO_DEADLINE
	_grace_deadline = NO_DEADLINE
	_resets_left = _knobs.int_value(&"fall.lock_resets_max")
	_lowest_layer = _piece_lowest_layer()
	_emit(SimEvents.PIECE_SPAWNED, {"uid": _piece_uid, "shape_id": shape.shape_id, "orient": _piece.orient, "origin": _piece.pivot})
	_set_phase(Phase.FALLING)
	if _is_supported():
		_start_rest()


# --- gravity (F1) ----------------------------------------------------------------------------------

# Fall speed in milli-cells/s with the ramp and gravity scale applied; 0 = does not fall.
func _gravity_milli() -> int:
	var elapsed: int = now_ms() - _play_start_ms
	var g: int = _knobs.int_value(&"fall.g0") + _knobs.int_value(&"fall.ramp_per_clear") * _goal_state.layers_cleared \
			+ _knobs.int_value(&"fall.ramp_per_min") * elapsed / MS_PER_MINUTE
	g = mini(g, _knobs.int_value(&"fall.g_max"))
	return g * _knobs.int_value(&"fall.gravity_scale") / MILLI


# Ms between fall steps for the current speed (soft drop included); 0 = never.
func _fall_interval_ms() -> int:
	var g: int = _gravity_milli()
	if _soft_drop:
		g = clampi(g * _knobs.int_value(&"fall.soft_drop_factor") / MILLI,
				_knobs.int_value(&"fall.soft_drop_min"), _knobs.int_value(&"fall.soft_drop_max"))
	return MILLI_PER_SECOND_SQ / g if g > 0 else 0


# --- support, lock timer, resets (rules 9-12) --------------------------------------------------------

# True if the piece cannot fall one more cell (same test the fall step uses).
func _is_supported() -> bool:
	return Movement.drop_distance(_piece, _board) == 0


# Lowest layer (0 = floor end) among the piece cubes along the board's down axis.
func _piece_lowest_layer() -> int:
	var low: int = _board.layer_count()
	for c: Vector3i in _piece.cells():
		low = mini(low, _board.layer_of(_board.index(c)))
	return low


# Rule 11: reaching a lower layer than ever before restores the resets.
func _track_lowest() -> void:
	var low: int = _piece_lowest_layer()
	if low < _lowest_layer:
		_lowest_layer = low
		_resets_left = _knobs.int_value(&"fall.lock_resets_max")


# After any successful fall step, move or rotate: lowest-layer bookkeeping, then rest/reset handling.
func _after_change() -> void:
	_track_lowest()
	var supported: bool = _is_supported()
	match _phase:
		Phase.FALLING:
			if supported:
				_start_rest()
		Phase.RESTING:
			if not supported:
				_stop_rest()
			elif _resets_left > 0: # rule 10: a successful move/rotate while resting restarts the timer
				_resets_left -= 1
				_lock_deadline = now_ms() + _knobs.int_value(&"fall.lock_delay_ms")
		Phase.GRACE:
			if not supported: # rule 7: unsupported -> grace cancelled, falls normally
				_grace_deadline = NO_DEADLINE
				_stop_rest()


func _start_rest() -> void:
	_lock_deadline = now_ms() + _knobs.int_value(&"fall.lock_delay_ms")
	_set_phase(Phase.RESTING)


func _stop_rest() -> void:
	_lock_deadline = NO_DEADLINE
	_fall_clock_ms = now_ms()
	_set_phase(Phase.FALLING)


# --- lock (S1) -------------------------------------------------------------------------------------

# Writes the piece to the board. ponytail: P3 veto, S2 on_lock and S3-S10 are CH-068; entry delay then spawn stands in.
func _lock(cause: StringName) -> void:
	var cells: Array[Vector3i] = _piece.cells()
	var holes: int = _count_holes(cells)
	var kind: int = _catalog.content.kind_of(BLOCK_CONTENT_ID)
	for c: Vector3i in cells:
		_board.place(_board.index(c), kind, _piece.shape.hue_id, _piece_uid)
	_emit(SimEvents.PIECE_LOCKED, {"uid": _piece_uid, "cells": cells, "cause": cause, "holes_added": holes})
	_emit(SimEvents.CELLS_CHANGED, {"delta": _board.take_delta()})
	_goal_state.locks += 1
	_piece = null
	_api.bind_piece(null)
	_lock_deadline = NO_DEADLINE
	_grace_deadline = NO_DEADLINE
	if not _knobs.flag(&"fall.soft_drop_carry"):
		_soft_drop = false
	_entry_deadline = now_ms() + _knobs.int_value(&"fall.entry_delay_ms")
	_set_phase(Phase.RESOLVING)


# Empty cells directly under the locked cubes along down (not counting the piece's own cells).
func _count_holes(cells: Array[Vector3i]) -> int:
	var down: Vector3i = _board.down_vector()
	var n: int = 0
	for c: Vector3i in cells:
		var below: Vector3i = c + down
		if _board.is_free(below) and not cells.has(below):
			n += 1
	return n


func _set_phase(p: Phase) -> void:
	var from: Phase = _phase
	_phase = p
	_emit(SimEvents.PHASE_CHANGED, {"phase": p, "from": from})


func _emit(kind: StringName, data: Dictionary) -> void:
	_events.append(SimEvent.make(_tick, kind, data))
