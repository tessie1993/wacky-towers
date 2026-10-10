class_name BoardSim extends RefCounted
## One player's play space, advanced one fixed tick at a time. Pure: no nodes, signals, Time, global RNG (ADR-0001).
## Covers countdown, spawn, gravity, soft/hard drop, move, rotate, grace, lock delay and the lock write
## (Fall, Drop & Lock GDD rules 1-14) and the per-lock resolve P3, S2-S10 (rule 15): lock veto, hooks, clears,
## goal check, top-out (rescue/lose), warning phase, level end, score and stars (CH-068).
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
const REASON_TOP_OUT := &"top_out"
const REASON_NO_GOAL_PLUGIN := &"no_goal_plugin"
const REASON_NO_TOP_OUT_PLUGIN := &"no_top_out_plugin"
## Rule action asked at P3, and the hooks this sim fires (ADR-0004 / ADR-0011).
const ACTION_LOCK := &"piece.lock"
const HOOK_ON_LOCK := &"on_lock"
const HOOK_ON_RESOLVE_END := &"on_resolve_end"
const HOOK_ON_GOAL_CHECK := &"on_goal_check"
const HOOK_ON_TOP_OUT := &"on_top_out"
## Hook order within a step: content, then twists, then the mechanic (Fall, Drop & Lock rule 15 S4b).
const LAYER_RANK := {&"content": 0, &"mascot": 1, &"twist": 2, &"mechanic": 3}
## Content id used for locked cubes (assets/data/content/blocks.json).
const BLOCK_CONTENT_ID := &"block"
const NO_DEADLINE := -1

## WARNING (rescue wipe window, clock paused) is appended last so existing values stay stable.
enum Phase { COUNTDOWN, WAITING, FALLING, RESTING, GRACE, RESOLVING, ENDED, WARNING }
## Result of the S7 top-out outcome.
enum TopOut { LOST, CONTINUE, WARNED }

## Set before the first step (PlaySession reads the profile once at level start; ADR-0013): scales star times.
var relaxed_timing: bool = false

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
var _goal_plugin: GoalEvaluator ## goal.type plugin
var _top_out_plugin: TopOutPolicy ## goal.top_out plugin
var _detector: ClearDetector ## clear.detector plugin
var _collapse: CollapsePolicy ## clear.collapse plugin
var _rules: Array[Dictionary] = [] ## {rule: RuleBehaviour, api: RuleApi, hooks: Array[StringName]}, hook order
var _score: ScoreKeeper
var _result: LevelResult
var _init_error: StringName = &"" ## setup problem found in _init, reported as LEVEL_FAILED on the first step
var _goal_state: GoalState = GoalState.new()
var _playing_ticks: int = 0 ## level clock source (Level Goals rule 13)
var _warnings_used: int = 0
var _resolve_ms: int = 0 ## t_resolve of the lock being resolved (Layer Clearing F2)
var _resolve_deadline: int = 0 ## end of RESOLVING / WARNING
var _spawn_retried: bool = false ## one spawn retry after a rescue (rule 15 S10)
var _hard_drop_cells: int = 0 ## cells hard-dropped by the current piece (score)
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
		_goal_plugin = catalog.plugins.create(&"GoalEvaluator", _knobs.value(&"goal.type")) as GoalEvaluator
		_top_out_plugin = catalog.plugins.create(&"TopOutPolicy", _knobs.value(&"goal.top_out")) as TopOutPolicy
		_detector = catalog.plugins.create(&"ClearDetector", _knobs.value(&"clear.detector")) as ClearDetector
		_collapse = catalog.plugins.create(&"CollapsePolicy", _knobs.value(&"clear.collapse")) as CollapsePolicy
		_build_rules()
	if _arrival == null:
		push_error("BoardSim: no ArrivalStyle plugin for knob spawn.arrival")
	if _goal_plugin == null:
		push_error("BoardSim: no GoalEvaluator plugin for knob goal.type")
		_init_error = REASON_NO_GOAL_PLUGIN
	elif _top_out_plugin == null:
		push_error("BoardSim: no TopOutPolicy plugin for knob goal.top_out (trim is not built yet)")
		_init_error = REASON_NO_TOP_OUT_PLUGIN
	if _goal_plugin != null:
		_goal_plugin.configure(level.goal)
	_goal_state.warnings_left = _knobs.int_value(&"goal.warnings_max")
	_score = ScoreKeeper.new({
		ScoreKeeper.KNOB_CLEAR_BASE: _knobs.int_value(&"goal.clear_base"),
		ScoreKeeper.KNOB_COMBO_BONUS: _knobs.int_value(&"goal.combo_bonus"),
		ScoreKeeper.KNOB_CHAIN_BONUS: _knobs.int_value(&"goal.chain_bonus"),
		ScoreKeeper.KNOB_DROP_POINTS: _knobs.int_value(&"goal.drop_points"),
		ScoreKeeper.KNOB_PLACE_POINTS: _knobs.int_value(&"goal.place_points"),
	})
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
	if _init_error != &"" and _phase != Phase.ENDED: # missing goal / top-out plugin: fail loudly, not silently
		_end(LevelResult.OUTCOME_LOST, _init_error)
		return _events.duplicate()
	_tick_clock()
	_apply_commands()
	_run_tick_hooks()
	_travel_step()
	_lock_step()
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


## Score so far. Example: sim.score().
func score() -> int:
	return _score.total() if _score != null else 0


## Running goal counters (layers_cleared, warnings_left, level_ms, locks). Example: sim.goal_state().layers_cleared.
func goal_state() -> GoalState:
	return _goal_state


## The final result once the level ended, else null. Example: sim.result().stars.
func result() -> LevelResult:
	return _result


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
@warning_ignore("integer_division")
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


func _cmd_rotate(cmd: SimCommand, axis: int, dir: int) -> void:
	var r: Dictionary = Movement.try_rotate(_piece, _board, axis as Orientations.Axis, dir, _rotate_opts())
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
		_hard_drop_cells += d
		_piece.pivot += _board.down_vector() * d
		_emit(SimEvents.PIECE_MOVED, {"uid": _piece_uid, "origin": _piece.pivot, "cause": CAUSE_DROP})
		_track_lowest()
	_lock_deadline = NO_DEADLINE
	_grace_deadline = now_ms() + _knobs.int_value(&"fall.hard_drop_grace_ms")
	_set_phase(Phase.GRACE)


# --- tick steps ------------------------------------------------------------------------------------

# Level clock: only ticks in Playing count, not Countdown, Warning or the result (Level Goals rule 13).
@warning_ignore("integer_division")
func _tick_clock() -> void:
	if _board == null or _phase == Phase.COUNTDOWN or _phase == Phase.WARNING or _phase == Phase.ENDED:
		return
	_playing_ticks += 1
	_goal_state.level_ms = _playing_ticks * MS_PER_SECOND / SIM_HZ


## RUL-003 fills this (on_tick, writes buffered to end of tick).
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
	elif (_phase == Phase.RESOLVING or _phase == Phase.WARNING) and now >= _resolve_deadline:
		_entry_deadline = now + _knobs.int_value(&"fall.entry_delay_ms") # Waiting starts when Resolving ends (rule 16)
		_set_phase(Phase.WAITING)
		if now >= _entry_deadline:
			_spawn()
	elif _phase == Phase.WAITING and now >= _entry_deadline:
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
	# fall.soft_drop_locks: soft drop on the ground skips the rest of the lock delay (fall-drop-lock rule 4, default off).
	if _phase == Phase.RESTING and (now >= _lock_deadline or (_soft_drop and _knobs.flag(&"fall.soft_drop_locks"))):
		_lock(LOCK_DELAY)
	elif _phase == Phase.GRACE and now >= _grace_deadline:
		_lock(LOCK_HARD_DROP) # grace is cancelled the moment the piece is unsupported, so here it rests


# --- spawn -----------------------------------------------------------------------------------------

func _spawn() -> void:
	var shape: ShapeDef = _catalog.shapes.get_shape(_spawner.next())
	var plan: ArrivalPlan = _arrival.plan_arrival(shape, _board, _api) if shape != null and _arrival != null else null
	if plan == null or plan.blocked:
		_piece = null
		_resolve_ms = 0
		if plan == null or _spawn_retried:
			_end(LevelResult.OUTCOME_LOST, REASON_SPAWN_BLOCKED)
			return
		var outcome: TopOut = _top_out(REASON_SPAWN_BLOCKED) # a blocked spawn is a top-out (S10 -> S7)
		if outcome != TopOut.LOST:
			_spawn_retried = true # after a rescue spawn() is called again once
			_begin_wait(outcome == TopOut.WARNED)
		return
	_spawn_retried = false
	_hard_drop_cells = 0
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
@warning_ignore("integer_division")
func _gravity_milli() -> int:
	var elapsed: int = now_ms() - _play_start_ms
	var g: int = _knobs.int_value(&"fall.g0") + _knobs.int_value(&"fall.ramp_per_clear") * _goal_state.layers_cleared \
			+ _knobs.int_value(&"fall.ramp_per_min") * elapsed / MS_PER_MINUTE
	g = mini(g, _knobs.int_value(&"fall.g_max"))
	return g * _knobs.int_value(&"fall.gravity_scale") / MILLI


# Ms between fall steps for the current speed (soft drop included); 0 = never.
@warning_ignore("integer_division")
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

# P3 veto, S1 write, then the resolve sequence S2-S10 (Fall, Drop & Lock rule 15).
func _lock(cause: StringName) -> void:
	if _lock_vetoed():
		return
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
	_spawn_retried = false
	_set_phase(Phase.RESOLVING)
	var points: int = _score.on_place(cells.size()) + _score.on_drop(_hard_drop_cells, true)
	_resolve_lock(points)


# P3: a rule may veto the lock. ponytail: no return_piece_to_spawn yet (needs RuleApi writes, CH-091);
# a veto just restarts the lock delay. Nothing is written, counted or scored.
func _lock_vetoed() -> bool:
	for e: Dictionary in _rules:
		var ctx: HookContext = HookContext.new()
		ctx.hook = ACTION_LOCK
		if (e["rule"] as RuleBehaviour).veto(ACTION_LOCK, ctx, e["api"] as RuleApi):
			_emit(SimEvents.RULE_BLOCKED, {"action": ACTION_LOCK})
			_grace_deadline = NO_DEADLINE
			_start_rest()
			return true
	return false


# S2-S10 on the lock tick; `points` are the place/drop points already scored for this lock.
func _resolve_lock(points: int) -> void:
	_resolve_ms = 0
	_run_hook(HOOK_ON_LOCK, {"uid": _piece_uid}) # S2
	_flush_delta()
	var cleared: int = _clear_round() # S3
	# S4a: queued request_down_axis / request_mask / request_slot changes apply here. ponytail: RuleApi has no
	# requests yet (CH-091/092), so there is nothing to apply.
	_run_hook(HOOK_ON_RESOLVE_END, {}) # S4b
	if not _board.touched().is_empty(): # S4c: an S4b subscriber wrote, clear once more (no new S4b)
		_flush_delta()
		cleared += _clear_round()
	_flush_delta()
	# ponytail: slice never chains, so one on_clear per lock (round 1) keeps the combo at one step per clearing lock.
	if cleared > 0:
		points += _score.on_clear(cleared, 1, _active_per_layer())
	else:
		_score.reset_combo()
	_emit(SimEvents.SCORE_CHANGED, {"score": _score.total(), "points": points, "combo": _score.combo()})
	_run_hook(HOOK_ON_GOAL_CHECK, {}) # S5
	if cleared > 0:
		_emit(SimEvents.GOAL_PROGRESS, _goal_plugin.progress(_goal_state))
	if _goal_plugin.evaluate(_goal_state, _api) == GoalEvaluator.WON:
		_end(LevelResult.OUTCOME_WON)
		return
	var warned: bool = false
	if _board.over_limit(): # S6
		var outcome: TopOut = _top_out(REASON_TOP_OUT) # S7
		if outcome == TopOut.LOST:
			return
		warned = outcome == TopOut.WARNED
	if _resolve_ms > 0:
		_emit(SimEvents.RESOLVE_STARTED, {"t_resolve_ms": _resolve_ms})
	_begin_wait(warned) # S8-S9; S10 spawn follows in _travel_step


# One clear round with the level's detector and collapse (S3 / S4c). Returns layers cleared and adds t_resolve.
func _clear_round() -> int:
	if _detector == null or _collapse == null or not _knobs.flag(&"clear.enabled"):
		return 0
	var groups: Array[ClearGroup] = _detector.find_clears(_board, _api)
	if groups.is_empty():
		return 0
	var n: int = 0
	var cubes: int = 0
	var top_cleared: int = -1
	var layers: PackedInt32Array = PackedInt32Array()
	for g: ClearGroup in groups:
		n += g.counts_as_layers
		cubes += g.cells.size()
		if not g.cells.is_empty():
			var k: int = _board.layer_of(g.cells[0])
			layers.append(k)
			top_cleared = maxi(top_cleared, k)
	var settles: bool = _board.stack_height() > top_cleared
	_collapse.collapse(_board, groups, _api)
	_goal_state.layers_cleared += n
	_resolve_ms += _resolve_time(n, settles)
	_emit(SimEvents.LAYERS_CLEARED, {"layers": layers, "n_layers": n, "n_cubes": cubes, "rounds": 1})
	_flush_delta()
	return n


# Layer Clearing F2: anim + (n-1) x stagger + settle (settle only if something sits above), capped at resolve_max_ms.
func _resolve_time(n: int, settles: bool) -> int:
	var t: int = _knobs.int_value(&"clear.anim_ms") + (n - 1) * _knobs.int_value(&"clear.stagger_ms")
	if settles:
		t += _knobs.int_value(&"clear.settle_ms")
	return mini(t, _knobs.int_value(&"clear.resolve_max_ms"))


# S7: on_top_out hooks, then the goal.top_out policy. rescue spends a warning and wipes (WARNED); lose/no warning ends.
func _top_out(reason: StringName) -> TopOut:
	_run_hook(HOOK_ON_TOP_OUT, {})
	var before: int = _goal_state.warnings_left
	var r: int = _top_out_plugin.resolve_top_out(_board, _goal_state, _api)
	_flush_delta() # the wipe's board changes
	if r == TopOutPolicy.LOST:
		_end(LevelResult.OUTCOME_LOST, reason)
		return TopOut.LOST
	if _goal_state.warnings_left < before:
		_warnings_used += before - _goal_state.warnings_left
		_score.reset_combo() # a warning ends the combo (Scoring & Stars)
		_emit(SimEvents.TOP_OUT_WARNING, {"warnings_left": _goal_state.warnings_left, "t_warning_ms": _knobs.int_value(&"goal.warning_ms")})
		return TopOut.WARNED
	return TopOut.CONTINUE


# Resolving (or the Warning window, clock paused) until the deadline, then Waiting and spawn.
func _begin_wait(warned: bool) -> void:
	var target: Phase = Phase.WARNING if warned else Phase.RESOLVING
	_resolve_deadline = now_ms() + _resolve_ms + (_knobs.int_value(&"goal.warning_ms") if warned else 0)
	if _phase != target:
		_set_phase(target)


# Level over: freeze, report the result (Level Goals rule 14). Events: GOAL_REACHED or LEVEL_FAILED, then LEVEL_RESULT.
func _end(outcome: StringName, reason: StringName = &"") -> void:
	_piece = null
	_api.bind_piece(null)
	_lock_deadline = NO_DEADLINE
	_grace_deadline = NO_DEADLINE
	_result = LevelResult.new()
	_result.outcome = outcome
	_result.level_ms = _goal_state.level_ms
	_result.layers_cleared = _goal_state.layers_cleared
	_result.warnings_used = _warnings_used
	_result.pieces_placed = _goal_state.locks
	_result.score = _score.total()
	var scale: int = _knobs.int_value(&"relaxed_time_scale") # 0 (not registered yet) -> StarRater default
	_result.stars = StarRater.rate(_level.stars, _result, relaxed_timing, scale)
	_goal_state.result = GoalState.RESULT_WON if _result.is_won() else GoalState.RESULT_LOST
	if _result.is_won():
		_emit(SimEvents.GOAL_REACHED, {"level_ms": _result.level_ms})
	else:
		_emit(SimEvents.LEVEL_FAILED, {"reason": reason})
	_emit(SimEvents.LEVEL_RESULT, {"outcome": outcome, "level_ms": _result.level_ms, "layers_cleared": _result.layers_cleared,
			"warnings_used": _result.warnings_used, "pieces_placed": _result.pieces_placed, "score": _result.score,
			"stars": _result.stars})
	_set_phase(Phase.ENDED)


# Rules with behaviour, ordered content, twists, mechanic (stable by level order).
func _build_rules() -> void:
	var entries: Array[Dictionary] = []
	for i: int in _level.rules.size():
		var def: RuleDef = _catalog.rule_defs.get(StringName(_level.rules[i].get("id", "")))
		if def == null or def.behaviour == &"":
			continue
		var rule: RuleBehaviour = _catalog.plugins.create(&"RuleBehaviour", def.behaviour) as RuleBehaviour
		if rule == null:
			continue
		var params: Dictionary = _level.rules[i].get("params", {})
		entries.append({"rule": rule, "api": RuleApi.new(_board, _knobs, params), "hooks": rule.subscribed_hooks(),
				"order": int(LAYER_RANK.get(def.layer, 0)) * 1000 + i})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["order"] < b["order"])
	_rules = entries


func _run_hook(hook: StringName, data: Dictionary) -> void:
	for e: Dictionary in _rules:
		if (e["hooks"] as Array).has(hook):
			var ctx: HookContext = HookContext.new()
			ctx.hook = hook
			ctx.data = data
			(e["rule"] as RuleBehaviour).handle(hook, ctx, e["api"] as RuleApi)


func _flush_delta() -> void:
	var d: PackedInt32Array = _board.take_delta()
	if not d.is_empty():
		_emit(SimEvents.CELLS_CHANGED, {"delta": d})


# Active cells per layer (Board F1 "A") for the clear score scale.
@warning_ignore("integer_division")
func _active_per_layer() -> int:
	return _board.active_cell_count() / maxi(1, _board.layer_count())


# New covered holes this lock makes (K3, computed before the write): an empty cell under a cube, not part of the
# piece, with no solid content above it in its column. Floor and inactive cells are never holes.
func _count_holes(cells: Array[Vector3i]) -> int:
	var down: Vector3i = _board.down_vector()
	var n: int = 0
	for c: Vector3i in cells:
		var below: Vector3i = c + down
		if not _board.is_free(below) or cells.has(below):
			continue
		var covered: bool = false
		var p: Vector3i = below - down
		while _board.in_bounds(p):
			if _board.is_active(_board.index(p)) and not _board.is_free(p):
				covered = true
				break
			p -= down
		if not covered:
			n += 1
	return n


func _set_phase(p: Phase) -> void:
	var from: Phase = _phase
	_phase = p
	_emit(SimEvents.PHASE_CHANGED, {"phase": p, "from": from})


func _emit(kind: StringName, data: Dictionary) -> void:
	_events.append(SimEvent.make(_tick, kind, data))
