class_name BoardSim extends RefCounted
## One player's play space, advanced one fixed tick at a time through detached manual Beehave nodes.
## No SceneTree processing, signals, wall-clock Time or global RNG affects simulation (ADR-0001).
## Covers countdown, spawn, gravity, soft/hard drop, move, rotate, grace, lock delay and the lock write
## Includes the ordered lock/clear/structure/goal/top-out sequence (ADR-0011).
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

enum Phase { COUNTDOWN, WAITING, FALLING, RESTING, GRACE, RESOLVING, ENDED, SELECTING }

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
var _ability_api: RuleApi
var _spawner: Spawner
var _arrival: ArrivalStyle
var _goal_plugin: GoalEvaluator
var _top_out_plugin: TopOutPolicy
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
var _detector: ClearDetector
var _collapse: CollapsePolicy
var _rules: Array[Dictionary] = []
var _pending_rule_definitions: Array[Dictionary] = []
var _rules_update_pending: bool = false
var _shape_pool_pending: bool = false
var _down_reset_pending: bool = false
var _pending_shape_pool: PackedStringArray = PackedStringArray()
var _slot_ids: Dictionary = {}
var _runtime_modifiers: Dictionary = {}
var _item_context: Dictionary = {"players": 1, "rank": 1, "mode": "solo", "owner": 0}
var _structural: Array[Dictionary] = []
var _score: ScoreKeeper
var _result: LevelResult
var _level_ticks: int = 0
var _started: bool = false
var _pending_outcome: int = GoalState.RESULT_RUNNING
var _resolve_ms: int = 0
var _warning_until: int = NO_DEADLINE
var _held_shape: StringName = &""
var _hold_used: bool = false
var _piece_flags: Dictionary = {}
var _abilities: RefCounted
var _colour_rng: RandomNumberGenerator
var _last_colour: int = 0
var _queued_hues: Array[int] = []
var _held_hue: int = 0
var _held_flags: Dictionary = {}
var _clear_combo_started: bool = false
var _clear_round_count: int = 0
var _colour_generated: int = 0
var _flicks_left: int = 0
var _undo_enabled: bool = false
var _undo_history: Array[Dictionary] = []
var _turn_checkpoint: Dictionary = {}
var _initial_checkpoint: Dictionary = {}
var _runtime: RuleRuntime


func _init(level: LevelData, round_seed: int, catalog: GameCatalog) -> void:
	_level = level.duplicate_runtime()
	_seed = round_seed
	_catalog = catalog
	_runtime = RuleRuntime.new()
	if level.boards.is_empty() or catalog.content == null or catalog.shapes == null or catalog.knob_defs == null:
		return
	_board = BoardState.new(level.boards[0], catalog.content)
	_knobs = KnobRegistry.new(catalog.knob_defs, level.knobs, true)
	_api = RuleApi.new(_board, _knobs)
	_api.configure(catalog, round_seed, &"base")
	_api.bind_goal(_goal_state, _level.goal)
	_ability_api = RuleApi.new(_board, _knobs)
	_ability_api.configure(catalog, round_seed, &"ability")
	_ability_api.bind_goal(_goal_state, _level.goal)
	_init_rules()
	_spawner = Spawner.new(level.pieces, _knobs.int_value(&"spawn.queue_lookahead"), round_seed, _knobs.snapshot())
	_api.bind_spawner(_spawner)
	_ability_api.bind_spawner(_spawner)
	for rule: Dictionary in _rules:
		(rule["api"] as RuleApi).bind_spawner(_spawner)
	for rule: Dictionary in level.rules:
		if String(rule.get("id", "")).trim_suffix("*") == "undo_reset":
			_undo_enabled = true
	_refresh_slots()
	_goal_state.warnings_left = _knobs.int_value(&"goal.warnings_max")
	_score = ScoreKeeper.new(_knobs.snapshot())
	_colour_rng = Seeds.make_rng(_seed, ["colour"])
	for id: String in _spawner.peek(_knobs.int_value(&"spawn.queue_lookahead")):
		_queued_hues.append(_roll_colour(_catalog.shapes.get_shape(StringName(id))))
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
	if _api != null:
		_api.set_time(now_ms())
		_ability_api.set_time(now_ms())
	if _rules_update_pending and _board != null:
		_runtime.execute(self, &"_replace_twists")
	if _down_reset_pending and _phase == Phase.RESOLVING:
		_runtime.execute(self, &"_apply_down_reset")
	if _shape_pool_pending and _phase in [Phase.COUNTDOWN, Phase.WAITING, Phase.RESOLVING, Phase.SELECTING]:
		_runtime.execute(self, &"_apply_shape_pool")
	if _board != null and not _started:
		_started = true
		for rule: Dictionary in _rules:
			_emit(SimEvents.RULE_STARTED, {"id": rule["id"]})
		_run_hook(&"on_level_start", {}, true)
		_apply_structural()
		if _goal_plugin != null:
			_runtime.execute(_goal_plugin, &"begin", [_goal_state, _api])
			_collect_api(_api, true)
		if _undo_enabled:
			_initial_checkpoint = _capture_checkpoint()
	if _board != null and _phase not in [Phase.COUNTDOWN, Phase.ENDED] and now_ms() >= _warning_until and _pending_outcome == GoalState.RESULT_RUNNING:
		_level_ticks += 1
		_goal_state.level_ms = ms_at(_level_ticks)
	_runtime.execute(self, &"_tick_pipeline")
	if _board != null:
		_flush_rule_writes()
		_collect_api(_api, true)
		_collect_api(_ability_api, true, 2)
		_emit_delta()
	if _abilities != null and _abilities.has_method("observe"):
		_runtime.execute(_abilities, &"observe", [_events])
	return _events.duplicate()


func _tick_pipeline() -> void:
	_apply_commands()
	_run_tick_hooks()
	_travel_step()
	_lock_step()
	_resolve_step()
	_goal_step()


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

func get_piece_uid() -> int:
	return _piece_uid if _piece != null else 0


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
	return _piece.cells_at(_piece.orient, _piece.pivot + _travel_dir * _board.cast(_piece.cells(), _travel_dir))


## Goal counters for UI/strategies. Example: sim.goal_state().layers_cleared.
func goal_state() -> GoalState:
	return _goal_state

func goal_progress() -> Dictionary:
	return _goal_plugin.progress(_goal_state) if _goal_plugin != null else {}

## Null until the run ends. Example: if sim.result() != null: show_result(sim.result()).
func result() -> LevelResult:
	return _result

func elapsed_ms() -> int:
	return _goal_state.level_ms

func knobs() -> KnobRegistry:
	return _knobs

func get_knobs() -> KnobRegistry:
	return _knobs

func get_api() -> RuleApi:
	return _api

func get_ability_api() -> RuleApi:
	return _ability_api

func held_shape() -> StringName:
	return _held_shape

func kit_choices() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if _spawner == null or not _spawner.is_kit():
		return result
	var counts: Dictionary = {}
	for id: String in _spawner.kit_remaining():
		counts[id] = int(counts.get(id, 0)) + 1
	for id: String in counts:
		result.append({"shape_id": StringName(id), "remaining": counts[id]})
	return result

func selection_remaining() -> int:
	return _spawner.kit_remaining().size() if _spawner != null and _spawner.is_kit() else 0

func capabilities() -> Dictionary:
	var verb: StringName = StringName(_knobs.value(&"control.verb")) if _knobs != null else &""
	return {"kit": _spawner != null and _spawner.is_kit(), "undo": _undo_enabled,
		"reset": _undo_enabled, "choose_down": verb == &"choose_down" and _piece != null,
		"ice_flick": verb in [&"ice_flick", &"curling_flick"] and _phase == Phase.RESTING and _flicks_left > 0,
		"flicks_left": _flicks_left, "undo_available": not _undo_history.is_empty()}

## Inject a pure ability controller. Example: sim.bind_abilities(WtAbilities.new()).
func bind_abilities(controller: RefCounted) -> void:
	_abilities = controller

func bind_item_context(context: Dictionary) -> void:
	_item_context.merge(context, true)
	if _api != null: _api.bind_item_context(_item_context)
	if _ability_api != null: _ability_api.bind_item_context(_item_context)
	for rule: Dictionary in _rules:
		(rule["api"] as RuleApi).bind_item_context(_item_context)


## Replace only the twist layer at the next fixed-tick boundary. Core/perks/mechanics retain state.
func set_rule_definitions(rules: Array) -> void:
	_pending_rule_definitions.clear()
	for entry: Variant in rules:
		if entry is Dictionary:
			_pending_rule_definitions.append(entry.duplicate(true))
	_rules_update_pending = true

## Changes generated sets at a safe phase boundary while preserving already-generated pieces.
func set_shape_pool(ids: PackedStringArray) -> bool:
	if ids.is_empty() or ids.size() > 8 or _spawner == null or _spawner.is_kit(): return false
	for id: String in ids:
		if _catalog.shapes.get_shape(StringName(id)) == null: return false
	_pending_shape_pool = ids.duplicate()
	_shape_pool_pending = true
	return true

func _apply_shape_pool() -> void:
	_shape_pool_pending = false
	if _spawner.set_shape_pool(_pending_shape_pool):
		_level.pieces["shapes"] = _pending_shape_pool.duplicate()
	_pending_shape_pool.clear()

## Stable deterministic gameplay fingerprint. Example: assert(a.state_hash() == b.state_hash()).
func state_hash() -> int:
	var rule_states: Array[Dictionary] = []
	for rule: Dictionary in _rules:
		var behaviour: RuleBehaviour = rule["behaviour"]
		var api: RuleApi = rule["api"]
		rule_states.append({"id": rule["id"], "rank": rule["rank"], "start_tick": rule["start_tick"],
			"start_lock": rule["start_lock"], "start_ms": rule.get("start_ms", 0), "state": behaviour.snapshot() if behaviour != null else {}, "api": api.snapshot()})
	var commands: Array[Dictionary] = []
	for command: SimCommand in _queue:
		commands.append({"kind": command.kind, "args": command.args, "tick": command.tick})
	var piece_state: Dictionary = {} if _piece == null else {"shape": _piece.shape.shape_id, "pivot": _piece.pivot,
		"orient": _piece.orient, "hue": _piece.hue_id, "up_kicks": _piece.up_kicks_used, "last_axis": _piece.last_axis,
		"last_sign": _piece.last_sign, "last_kick": _piece.last_kick}
	return Seeds.fnv1a(var_to_bytes({"tick": _tick, "phase": _phase, "board": _board.snapshot() if _board != null else {},
		"piece": piece_state, "spawn": _spawner.snapshot() if _spawner != null else {}, "rules": rule_states,
		"seed": _seed, "level": _level.id, "goal": _level.goal, "runtime": _runtime.snapshot(),
		"metrics": _goal_state.metrics, "goal_plugin": _goal_plugin.snapshot() if _goal_plugin != null else {},
		"layers": _goal_state.layers_cleared, "locks": _goal_state.locks, "goal_result": _goal_state.result,
		"clock": _level_ticks, "warnings": _goal_state.warnings_left,
		"score": _score.snapshot() if _score != null else {}, "held": _held_shape, "held_flags": _held_flags, "flags": _piece_flags,
		"commands": commands, "structure": _structural, "knobs": _knobs.snapshot() if _knobs != null else {},
		"pending_rules": _pending_rule_definitions, "rules_update_pending": _rules_update_pending,
		"pending_pool": _pending_shape_pool, "shape_pool_pending": _shape_pool_pending, "down_reset_pending": _down_reset_pending,
		"runtime_modifiers": _runtime_modifiers, "item_context": _item_context,
		"base_api": _api.snapshot() if _api != null else {}, "ability_api": _ability_api.snapshot() if _ability_api != null else {}, "uid": _piece_uid, "next_uid": _next_uid,
		"hold_used": _hold_used, "soft_drop": _soft_drop, "travel_dir": _travel_dir, "resets": _resets_left,
		"flicks": _flicks_left, "undo_history": _history_hashes(), "turn_checkpoint": _turn_checkpoint.get("hash", 0),
		"lowest": _lowest_layer, "countdown": _countdown_deadline, "warning_until": _warning_until,
		"pending_outcome": _pending_outcome, "trimmed": _goal_state.cells_trimmed, "warnings_used": _goal_state.warnings_used,
		"fall_clock": _fall_clock_ms, "lock": _lock_deadline, "grace": _grace_deadline, "entry": _entry_deadline,
		"abilities": _abilities.call("snapshot") if _abilities != null and _abilities.has_method("snapshot") else {},
		"colours": _queued_hues, "colour_rng": _colour_rng.state if _colour_rng != null else 0, "last_colour": _last_colour, "held_hue": _held_hue, "colour_generated": _colour_generated}))


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
		elif _phase == Phase.RESOLVING and cmd.kind in [SimEvents.CMD_RECEIVE_ITEM, SimEvents.CMD_USE_ITEM]:
			cmd.tick = _tick + 1
			rest.append(cmd)
		else:
			_apply_command(cmd)
	_queue = rest


func _apply_command(cmd: SimCommand) -> void:
	_api.set_time(now_ms())
	if cmd.kind == SimEvents.CMD_UNDO and _undo_enabled:
		if not _undo_history.is_empty():
			_restore_checkpoint(_undo_history.pop_back(), false)
		return
	if cmd.kind == SimEvents.CMD_RESET and _undo_enabled:
		if not _initial_checkpoint.is_empty():
			_undo_history.clear()
			_restore_checkpoint(_initial_checkpoint, true)
		return
	if cmd.kind == SimEvents.CMD_PICK_SHAPE:
		if _phase == Phase.SELECTING and not cmd.args.is_empty():
			var argument: Variant = cmd.args[0]
			_cmd_pick_shape(StringName(argument.get("shape_id", "") if argument is Dictionary else argument))
		return
	if cmd.kind == CMD_COUNTDOWN_RESTART:
		if _phase == Phase.COUNTDOWN:
			_countdown_deadline = now_ms() + _knobs.int_value(&"goal.countdown_ms")
		return
	var actual_item: bool = cmd.kind == SimEvents.CMD_RECEIVE_ITEM or (cmd.kind == SimEvents.CMD_USE_ITEM and not cmd.args.is_empty() and (cmd.args[0] is int or cmd.args[0] is Dictionary))
	if actual_item and _phase not in [Phase.COUNTDOWN, Phase.ENDED]:
		_run_hook(&"on_command", {"kind": cmd.kind, "args": cmd.args}, true)
		return
	if _abilities != null and cmd.kind in [SimEvents.CMD_USE_SKILL, SimEvents.CMD_USE_ITEM] and _phase not in [Phase.COUNTDOWN, Phase.ENDED, Phase.RESOLVING]:
		_runtime.execute(_abilities, &"command", [cmd, _ability_api])
		_collect_api(_ability_api, true, 2)
		return
	if _piece == null: # COUNTDOWN / WAITING / RESOLVING / ENDED: ignored, the controller buffers
		return
	_run_hook(&"on_command", {"kind": cmd.kind, "args": cmd.args}, true)
	if _veto(cmd.kind, {"kind": cmd.kind, "args": cmd.args}):
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
		SimEvents.CMD_HOLD:
			_cmd_hold()
		SimEvents.CMD_CHOOSE_DOWN, SimEvents.CMD_FLICK:
			if not cmd.args.is_empty():
				var argument: Variant = cmd.args[0]
				var direction: Variant = argument.get("direction", Vector3i.ZERO) if argument is Dictionary else argument
				if direction is Vector3i:
					if cmd.kind == SimEvents.CMD_CHOOSE_DOWN:
						_cmd_choose_down(direction)
					else:
						_cmd_flick(direction)
		SimEvents.CMD_TAP:
			if _piece_flags.get(&"intangible", false):
				_piece_flags[&"intangible"] = false
				_api.place_nearest_up()
				_after_change()


func _cmd_move(dir: Vector3i) -> void:
	if dir == Vector3i.ZERO or (dir.x * _board.down_vector().x + dir.y * _board.down_vector().y + dir.z * _board.down_vector().z) != 0 or absi(dir.x) + absi(dir.y) + absi(dir.z) != 1:
		return
	var r: Dictionary = _translate(dir)
	if r["result"] == Movement.Result.OK:
		_emit(SimEvents.PIECE_MOVED, {"uid": _piece_uid, "origin": _piece.pivot, "cause": CAUSE_MOVE})
		_after_change()
	else:
		_emit(SimEvents.PIECE_BLOCKED, {"uid": _piece_uid, "kind": KIND_MOVE, "reason": r["reason"]})

func _cmd_pick_shape(id: StringName) -> void:
	if _catalog.shapes.get_shape(id) == null or not _spawner.kit_remaining().has(String(id)):
		return
	if _undo_enabled:
		_turn_checkpoint = _capture_checkpoint()
	if not _spawner.choose(id):
		return
	_spawn(id, _roll_colour(_catalog.shapes.get_shape(id), false), true)
	_emit(SimEvents.KIT_CHANGED, {"choices": kit_choices(), "remaining": selection_remaining()})

func _cmd_choose_down(direction: Vector3i) -> void:
	if not capabilities()["choose_down"] or absi(direction.x) + absi(direction.y) + absi(direction.z) != 1:
		return
	var token: String = "down" if direction == _board.down_vector() else _direction_token(direction)
	var allowed: Variant = _knobs.value(&"control.travel_dirs")
	if allowed is Array and not allowed.has(token):
		return
	if direction != _board.down_vector() and Vector3(direction).dot(Vector3(_board.down_vector())) != 0:
		return
	_travel_dir = direction
	_grace_deadline = NO_DEADLINE
	_stop_rest()
	_after_change()
	_emit(SimEvents.COMMAND_APPLIED, {"kind": SimEvents.CMD_CHOOSE_DOWN, "direction": direction})

func _cmd_flick(direction: Vector3i) -> void:
	if not capabilities()["ice_flick"] or _phase != Phase.RESTING or _flicks_left <= 0:
		return
	if absi(direction.x) + absi(direction.y) + absi(direction.z) != 1 or Vector3(direction).dot(Vector3(_board.down_vector())) != 0:
		return
	var allowed: Variant = _knobs.value(&"control.flick_dirs")
	if allowed is Array and not allowed.has(_direction_token(direction)):
		return
	var distance: int = _board.cast(_piece.cells(), direction)
	if distance <= 0:
		return
	_flicks_left -= 1
	for _cell: int in distance:
		_piece.pivot += direction
		var drop: int = _board.cast(_piece.cells(), _board.down_vector())
		if drop > 0:
			_piece.pivot += _board.down_vector() * drop
			break
	_piece.clear_undo()
	_emit(SimEvents.PIECE_MOVED, {"uid": _piece_uid, "origin": _piece.pivot, "cause": &"flick"})
	_after_change()

func _direction_token(direction: Vector3i) -> String:
	if direction.x != 0:
		return "+x" if direction.x > 0 else "-x"
	if direction.y != 0:
		return "+y" if direction.y > 0 else "-y"
	return "+z" if direction.z > 0 else "-z"

## Undo restores the previous turn's board/inventory/state while its level clock continues.
func _capture_checkpoint() -> Dictionary:
	var names: PackedStringArray = PackedStringArray(["_phase", "_piece_uid", "_next_uid", "_travel_dir", "_soft_drop",
		"_countdown_deadline", "_play_start_ms", "_fall_clock_ms", "_lock_deadline", "_grace_deadline", "_entry_deadline",
		"_resets_left", "_lowest_layer", "_level_ticks", "_started", "_pending_outcome", "_resolve_ms", "_warning_until",
		"_held_shape", "_hold_used", "_piece_flags", "_last_colour", "_queued_hues", "_held_hue", "_held_flags", "_colour_generated",
		"_clear_combo_started", "_clear_round_count", "_flicks_left", "_structural", "_pending_rule_definitions", "_rules_update_pending", "_runtime_modifiers", "_pending_shape_pool", "_shape_pool_pending", "_down_reset_pending"])
	var fields: Dictionary = {}
	for name: String in names:
		fields[name] = get(name)
	var counters: Dictionary = {}
	for name: String in ["layers_cleared", "cells_trimmed", "warnings_left", "level_ms", "locks", "result", "warnings_used", "score", "metrics"]:
		counters[name] = _goal_state.get(name)
	var rules: Array[Dictionary] = []
	for rule: Dictionary in _rules:
		rules.append({"api": (rule["api"] as RuleApi).snapshot(), "behaviour": (rule["behaviour"] as RuleBehaviour).snapshot() if rule["behaviour"] != null else {}})
	var data: Dictionary = {"fields": fields, "board": _board.snapshot(), "spawner": _spawner.snapshot(),
		"knobs": _knobs.snapshot(), "score": _score.snapshot(), "counters": counters, "rules": rules,
		"api": _api.snapshot(), "ability_api": _ability_api.snapshot(), "goal": _level.goal, "goal_state": _goal_plugin.snapshot() if _goal_plugin != null else {},
		"colour_rng": _colour_rng.state, "time": now_ms(), "runtime": _runtime.snapshot(),
		"abilities": _abilities.call("snapshot") if _abilities != null and _abilities.has_method("snapshot") else {}}
	if _piece != null:
		data["piece"] = {"shape": _piece.shape.shape_id, "pivot": _piece.pivot, "orient": _piece.orient, "hue": _piece.hue_id,
			"up_kicks": _piece.up_kicks_used, "axis": _piece.last_axis, "sign": _piece.last_sign, "kick": _piece.last_kick}
	data = data.duplicate(true)
	data["hash"] = Seeds.fnv1a(var_to_bytes(data))
	data["rule_entries"] = _rules.duplicate()
	return data

func _history_hashes() -> PackedInt64Array:
	var hashes: PackedInt64Array = PackedInt64Array()
	for turn: Dictionary in _undo_history:
		hashes.append(int(turn.get("hash", 0)))
	return hashes

func _restore_checkpoint(checkpoint: Dictionary, reset_clock: bool) -> void:
	var state: Dictionary = checkpoint.duplicate(true)
	var level_ticks: int = _level_ticks
	var offset: int = now_ms() - int(state["time"])
	for name: String in state["fields"]:
		set(name, state["fields"][name])
	for name: String in ["_countdown_deadline", "_fall_clock_ms", "_lock_deadline", "_grace_deadline", "_entry_deadline", "_warning_until"]:
		if int(get(name)) != NO_DEADLINE:
			set(name, int(get(name)) + offset)
	_board.restore(state["board"])
	_spawner.restore(state["spawner"])
	_level.pieces["shapes"] = _spawner.shape_pool()
	_knobs.restore(state["knobs"])
	_score.restore(state["score"])
	for name: String in state["counters"]:
		_goal_state.set(name, state["counters"][name])
	_level_ticks = 0 if reset_clock else level_ticks
	_goal_state.level_ms = ms_at(_level_ticks)
	_level.goal = state["goal"]
	_rules.assign(state["rule_entries"])
	for index: int in _rules.size():
		(_rules[index]["api"] as RuleApi).restore(state["rules"][index]["api"])
		(_rules[index]["api"] as RuleApi).bind_goal(_goal_state, _level.goal)
		var behaviour: RuleBehaviour = _rules[index]["behaviour"]
		if behaviour != null:
			behaviour.restore(state["rules"][index]["behaviour"])
			behaviour.rebase_time(offset)
	_refresh_slots()
	if _goal_plugin != null:
		_goal_plugin.restore(state.get("goal_state", {}))
	_api.restore(state["api"])
	_api.bind_goal(_goal_state, _level.goal)
	_ability_api.restore(state.get("ability_api", {}))
	_ability_api.bind_goal(_goal_state, _level.goal)
	_ability_api.set_time(now_ms())
	_colour_rng.state = state["colour_rng"]
	_runtime.restore(state.get("runtime", {}))
	_result = null
	if state.has("piece"):
		var saved: Dictionary = state["piece"]
		_piece = ActivePiece.new(_catalog.shapes.get_shape(saved["shape"]), saved["pivot"], saved["orient"])
		_piece.hue_id = saved["hue"]
		_piece.up_kicks_used = saved["up_kicks"]
		_piece.last_axis = saved["axis"]
		_piece.last_sign = saved["sign"]
		_piece.last_kick = saved["kick"]
	else:
		_piece = null
	_bind_piece(_piece)
	if _abilities != null and _abilities.has_method("restore"):
		_abilities.call("restore", state.get("abilities", {}), offset)
	_turn_checkpoint = {}
	_emit(SimEvents.TURN_RESTORED, {"reset": reset_clock, "locks": _goal_state.locks})
	_emit(SimEvents.KIT_CHANGED, {"choices": kit_choices(), "remaining": selection_remaining()})
	_emit(SimEvents.PHASE_CHANGED, {"phase": _phase, "from": Phase.ENDED})
	_emit(SimEvents.GOAL_PROGRESS, goal_progress())
	if _phase == Phase.WAITING:
		_spawn()


func _cmd_rotate(cmd: SimCommand, axis: int, sign: int) -> void:
	if axis < 0 or axis > 2 or sign not in [-1, 1]:
		return
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
	if enabled is Array:
		var down: Vector3i = _board.down_vector()
		var ground: Array[int] = []
		var spin_axis: int = 0
		for axis: int in 3:
			if down[axis] != 0:
				spin_axis = axis
			else:
				ground.append(axis)
		for token: Variant in enabled:
			match String(token):
				"spin": axes.append(spin_axis)
				"tilt": axes.append(ground[0])
				"roll": axes.append(ground[1])
				"x": axes.append(Orientations.Axis.X)
				"y": axes.append(Orientations.Axis.Y)
				"z": axes.append(Orientations.Axis.Z)
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
	if _piece_flags.get(&"intangible", false):
		_piece_flags[&"intangible"] = false
		if not _api.place_nearest_up():
			return
	if _phase == Phase.GRACE:
		_lock(LOCK_COMMIT)
		return
	var d: int = _board.cast(_piece.cells(), _travel_dir)
	_score.on_drop(d, true)
	if d > 0:
		_piece.pivot += _travel_dir * d
		_emit(SimEvents.PIECE_MOVED, {"uid": _piece_uid, "origin": _piece.pivot, "cause": CAUSE_DROP})
		_track_lowest()
	_lock_deadline = NO_DEADLINE
	_grace_deadline = now_ms() + _knobs.int_value(&"fall.hard_drop_grace_ms")
	_set_phase(Phase.GRACE)


# --- tick steps ------------------------------------------------------------------------------------

func _run_tick_hooks() -> void:
	if _board == null:
		return
	if _abilities != null and _phase not in [Phase.COUNTDOWN, Phase.ENDED]:
		_runtime.execute(_abilities, &"step", [_ability_api, now_ms()])
		_collect_api(_ability_api, false, 2)
	if _phase in [Phase.COUNTDOWN, Phase.RESOLVING, Phase.ENDED] or now_ms() < _warning_until:
		return
	var before_origin: Vector3i = _piece.pivot if _piece != null else Vector3i.ZERO
	var before_orient: int = _piece.orient if _piece != null else 0
	_run_hook(&"on_tick", {}, false)
	if _piece != null and (_piece.pivot != before_origin or _piece.orient != before_orient):
		_after_change()
	_expire_rules()


# Countdown end, entry delay end (spawn) and gravity.
func _travel_step() -> void:
	if _board == null:
		return
	var now: int = now_ms()
	if _phase == Phase.COUNTDOWN and now >= _countdown_deadline:
		_play_start_ms = now
		_spawn()

	if _phase != Phase.FALLING or now < _warning_until:
		return
	var interval: int = _fall_interval_ms()
	if interval == 0 or now - _fall_clock_ms < interval:
		return
	_fall_clock_ms = now
	var r: Dictionary = _translate(_travel_dir)
	if r["result"] == Movement.Result.OK:
		_emit(SimEvents.PIECE_MOVED, {"uid": _piece_uid, "origin": _piece.pivot, "cause": CAUSE_FALL})
		_run_hook(&"on_fall_step", {"cells": _piece.cells()}, false)
		_after_change()
	else:
		_start_rest() # a blocked fall step means resting (rule 3)


# Lock delay and grace expiry (rules 7, 9, 13).
func _lock_step() -> void:
	if _board == null or _piece == null:
		return
	if _piece_flags.get(&"lock_paused", false):
		if _lock_deadline != NO_DEADLINE:
			_lock_deadline += now_ms() - ms_at(_tick - 1)
		if _grace_deadline != NO_DEADLINE:
			_grace_deadline += now_ms() - ms_at(_tick - 1)
		return
	var now: int = now_ms()
	if _soft_drop and _knobs.flag(&"fall.soft_drop_locks") and _is_supported():
		_lock(LOCK_DELAY)
	elif _piece_flags.get(&"lock_now", false):
		_piece_flags[&"lock_now"] = false
		_lock(LOCK_COMMIT)
	elif _phase == Phase.RESTING and now >= _lock_deadline:
		_lock(LOCK_DELAY)
	elif _phase == Phase.GRACE and now >= _grace_deadline:
		_lock(LOCK_HARD_DROP) # grace is cancelled the moment the piece is unsupported, so here it rests


func _resolve_step() -> void:
	if _board == null or _phase != Phase.RESOLVING or now_ms() < _entry_deadline:
		return
	if _pending_outcome != GoalState.RESULT_RUNNING:
		_finish(_pending_outcome)
	elif _knobs.value(&"goal.type") == &"survive" and _goal_plugin != null and int(_runtime.execute(_goal_plugin, &"evaluate", [_goal_state, _api])) == GoalState.RESULT_WON:
		_finish(GoalState.RESULT_WON)
	elif _timed_out():
		_finish(GoalState.RESULT_LOST, &"time_limit")
	else:
		_set_phase(Phase.WAITING)
		_spawn()


func _goal_step() -> void:
	if _board == null or _goal_plugin == null or _phase in [Phase.COUNTDOWN, Phase.RESOLVING, Phase.ENDED]:
		return
	if _knobs.value(&"goal.type") == &"survive" and int(_runtime.execute(_goal_plugin, &"evaluate", [_goal_state, _api])) == GoalState.RESULT_WON:
		_finish(GoalState.RESULT_WON)
	elif _timed_out():
		_finish(GoalState.RESULT_LOST, &"time_limit")


# --- spawn -----------------------------------------------------------------------------------------

func _spawn(forced_shape: StringName = &"", forced_hue: int = -1, selected: bool = false, held_flags: Dictionary = {}) -> void:
	var budget: int = int(_level.goal.get("piece_budget", 0))
	if budget > 0 and _goal_state.locks >= budget:
		_finish(GoalState.RESULT_LOST, &"out_of_pieces")
		return
	if forced_shape == &"" and _held_shape != &"" and not _knobs.flag(&"spawn.hold_enabled"):
		_spawner.inject_front(PackedStringArray([String(_held_shape)]), [{"piece_flags": _held_flags}])
		_queued_hues.push_front(_held_hue)
		_held_shape = &""
		_held_flags = {}
	if _spawner.is_kit() and forced_shape == &"":
		if selection_remaining() == 0:
			_finish(GoalState.RESULT_LOST, &"out_of_pieces")
		else:
			_set_phase(Phase.SELECTING)
			_emit(SimEvents.KIT_CHANGED, {"choices": kit_choices(), "remaining": selection_remaining()})
		return
	if _undo_enabled and forced_shape == &"":
		_turn_checkpoint = _capture_checkpoint()
	var next_ids: PackedStringArray = _spawner.peek(1)
	var shape_id: StringName = forced_shape if forced_shape != &"" else (StringName(next_ids[0]) if not next_ids.is_empty() else &"")
	var shape: ShapeDef = _catalog.shapes.get_shape(shape_id)
	if shape == null:
		_finish(GoalState.RESULT_LOST, &"out_of_pieces")
		return
	var plan: ArrivalPlan = _runtime.execute(_arrival, &"plan_arrival", [shape, _board, _api]) as ArrivalPlan if shape != null and _arrival != null else null
	if plan == null or plan.blocked:
		if not _handle_top_out(REASON_SPAWN_BLOCKED):
			_finish(GoalState.RESULT_LOST)
			return
		plan = _runtime.execute(_arrival, &"plan_arrival", [shape, _board, _api]) as ArrivalPlan if shape != null and _arrival != null else null
		if plan == null or plan.blocked:
			_finish(GoalState.RESULT_LOST)
			return
	if forced_shape == &"":
		_spawner.next()
	_piece = ActivePiece.new(shape, plan.origin, plan.orient)
	if forced_hue >= 0:
		_piece.hue_id = forced_hue
	elif not _queued_hues.is_empty():
		_piece.hue_id = _queued_hues.pop_front()
		var upcoming: PackedStringArray = _spawner.peek(_knobs.int_value(&"spawn.queue_lookahead"))
		if upcoming.size() > _queued_hues.size():
			_queued_hues.append(_roll_colour(_catalog.shapes.get_shape(StringName(upcoming[-1]))))
	_piece_uid = _next_uid
	_next_uid += 1
	_travel_dir = plan.travel_dir
	_bind_piece(_piece)
	if not _knobs.flag(&"fall.soft_drop_carry"):
		_soft_drop = false
	_hold_used = false
	_piece_flags.clear()
	var bag: Dictionary = _spawner.last_bag_info() if forced_shape == &"" or selected else {"id": -1, "size": 0, "index": -1, "injected": true}
	_piece_flags.merge(bag.get("piece_flags", held_flags), true)
	_piece_flags[&"bag_index"] = int(bag.get("id", -1))
	_piece_flags[&"bag_position"] = int(bag.get("index", -1))
	_piece_flags[&"bag_size"] = int(bag.get("size", 0))
	_piece_flags[&"stream_index"] = int(bag.get("stream_index", -1))
	_piece_flags[&"injected"] = bool(bag.get("injected", false))
	if bag.has("tags"):
		_piece_flags[&"tags"] = bag["tags"]
	if _goal_plugin != null:
		_runtime.execute(_goal_plugin, &"on_spawn", [_piece, _goal_state, _api])
		_collect_api(_api, true)
	_fall_clock_ms = now_ms() # rule 1a
	_lock_deadline = NO_DEADLINE
	_grace_deadline = NO_DEADLINE
	_resets_left = _knobs.int_value(&"fall.lock_resets_max")
	_lowest_layer = _piece_lowest_layer()
	_flicks_left = _knobs.int_value(&"control.flick_per_piece")
	_emit(SimEvents.PIECE_SPAWNED, {"uid": _piece_uid, "shape_id": shape.shape_id, "orient": _piece.orient, "origin": _piece.pivot,
		"hue_id": _piece.hue_id, "injected": bool(_piece_flags.get(&"injected", false))})
	_set_phase(Phase.FALLING)
	_run_hook(&"on_spawn", {"uid": _piece_uid, "shape_id": shape.shape_id, "cells": _piece.cells()}, true)
	_run_hook(&"on_piece_enter", {"cells": _piece.cells()}, true)
	if _is_supported():
		_start_rest()


# --- gravity (F1) ----------------------------------------------------------------------------------

# Fall speed in milli-cells/s with the ramp and gravity scale applied; 0 = does not fall.
func _gravity_milli() -> int:
	var elapsed: int = _goal_state.level_ms
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
	if _piece == null:
		return false
	if _piece_flags.get(&"intangible", false):
		for c: Vector3i in _piece.cells():
			var below: Vector3i = c + _board.down_vector()
			if not _board.in_bounds(below) or not _board.is_active(_board.index(below)):
				return true
		return false
	return _board.cast(_piece.cells(), _travel_dir) == 0


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
	_run_hook(&"on_land", {"cells": _piece.cells(), "uid": _piece_uid}, true)
	if not _is_supported():
		_stop_rest()
		return
	_lock_deadline = now_ms() + _knobs.int_value(&"fall.lock_delay_ms")
	_set_phase(Phase.RESTING)


func _stop_rest() -> void:
	_lock_deadline = NO_DEADLINE
	_fall_clock_ms = now_ms()
	_set_phase(Phase.FALLING)


# --- lock (S1) -------------------------------------------------------------------------------------

# Commit P3/S1-S10 synchronously; resolving visuals delay the next arrival.
func _lock(cause: StringName) -> void:
	if _piece == null:
		return
	var cells: Array[Vector3i] = _piece.cells()
	var holes: int = _count_holes(cells)
	var context: Dictionary = {"cells": cells, "uid": _piece_uid, "holes_added": holes,
		"would_clear": _api.would_clear(cells), "would_top_out": _api.would_top_out(cells), "cause": cause,
		"injected": bool(_piece_flags.get(&"injected", false))}
	if _veto(&"piece.lock", context):
		_collect_api(_api, true)
		_lock_deadline = now_ms() + _knobs.int_value(&"fall.lock_delay_ms")
		_grace_deadline = NO_DEADLINE
		if _piece != null:
			_set_phase(Phase.FALLING if not _is_supported() else Phase.RESTING)
		return
	if _undo_enabled and not _turn_checkpoint.is_empty():
		_undo_history.append(_turn_checkpoint)
		_turn_checkpoint = {}
	_set_phase(Phase.RESOLVING)
	var kind: int = _catalog.content.kind_of(BLOCK_CONTENT_ID)
	for c: Vector3i in cells:
		if _board.get_kind(_board.index(c)) != 0:
			_run_hook(&"on_enter", {"cell": c, "kind": _board.get_kind(_board.index(c)), "record": _board.get_record(_board.index(c))}, true)
		_board.place(_board.index(c), kind, _piece.hue_id, _piece_uid)
	_emit(SimEvents.PIECE_LOCKED, context)
	_goal_state.locks += 1
	_score.on_place(cells.size())
	if _goal_plugin != null:
		_runtime.execute(_goal_plugin, &"on_lock", [_piece, _goal_state, _api])
		_collect_api(_api, true)
	if _abilities != null and _abilities.has_method("on_lock"):
		_runtime.execute(_abilities, &"on_lock", [_ability_api, cells])
		_collect_api(_ability_api, true, 2)
	_run_hook(&"on_lock", context, true)
	_piece = null
	_bind_piece(null)
	_lock_deadline = NO_DEADLINE
	_grace_deadline = NO_DEADLINE
	if not _knobs.flag(&"fall.soft_drop_carry"):
		_soft_drop = false
	_resolve_ms = 0
	_clear_combo_started = false
	_clear_round_count = 0
	var layers: int = _clear_pass(false)
	_apply_structural()
	var wrote: bool = _run_hook(&"on_resolve_end", {"locks": _goal_state.locks, "cleared": layers}, true)
	if wrote:
		layers += _clear_pass(true)
	if layers == 0:
		_score.reset_combo()
	_goal_state.score = _score.total()
	_run_hook(&"on_goal_check", {}, true)
	var outcome: int = int(_runtime.execute(_goal_plugin, &"evaluate", [_goal_state, _api])) if _goal_plugin != null else GoalState.RESULT_RUNNING
	_emit(SimEvents.GOAL_PROGRESS, goal_progress())
	if outcome == GoalState.RESULT_WON:
		_pending_outcome = outcome
	elif _board.over_limit() and not _handle_top_out(&"over_limit"):
		_pending_outcome = GoalState.RESULT_LOST
	_entry_deadline = maxi(now_ms() + _resolve_ms + _knobs.int_value(&"fall.entry_delay_ms"), _warning_until)
	_emit(SimEvents.RESOLVE_STARTED, {"duration_ms": _resolve_ms, "entry_ms": _knobs.int_value(&"fall.entry_delay_ms"), "layers": layers})
	_emit_delta()


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
	if p == _phase:
		return
	var from: Phase = _phase
	_phase = p
	_emit(SimEvents.PHASE_CHANGED, {"phase": p, "from": from})


func _emit(kind: StringName, data: Dictionary) -> void:
	_events.append(SimEvent.make(_tick, kind, data))


# Rule lifecycle and deterministic F2 dispatch (ADR-0004/0011).
func _init_rules() -> void:
	for entry: Dictionary in _level.rules:
		var rule: Dictionary = _create_rule(entry)
		if not rule.is_empty():
			_rules.append(rule)
	_sort_rules()
	_rebuild_modifiers()


func _create_rule(entry: Dictionary, force_twist: bool = false) -> Dictionary:
	var ranks: Dictionary = {&"base": 0, &"perk": 1, &"mascot": 1, &"item_buff": 2, &"content": 2, &"twist": 3, &"mechanic": 4}
	var id: StringName = StringName(entry.get("id", entry.get("rule_id", "")))
	var definition: RuleDef = _catalog.rule_defs.get(id)
	if definition == null:
		return {}
	var params: Dictionary = {}
	for key: Variant in definition.params:
		var schema: Variant = definition.params[key]
		if schema is Dictionary and schema.has("default"):
			params[key] = schema["default"]
		elif not schema is Dictionary:
			params[key] = schema
	params.merge(entry.get("params", {}), true)
	var api: RuleApi = RuleApi.new(_board, _knobs, params)
	api.configure(_catalog, _seed, id)
	api.bind_goal(_goal_state, _level.goal)
	api.bind_spawner(_spawner)
	api.bind_item_context(_item_context)
	api.bind_piece_uid(_piece_uid)
	api.bind_piece(_piece)
	api.bind_piece_flags(_piece_flags)
	api.bind_preview_hues(_queued_hues)
	var behaviour: RuleBehaviour = _catalog.plugins.create(&"RuleBehaviour", definition.behaviour) as RuleBehaviour if _catalog.plugins != null and definition.behaviour != &"" else null
	var layer: StringName = &"twist" if force_twist else StringName(entry.get("layer", definition.layer))
	return {"id": id, "def": definition, "rank": ranks.get(layer, 0), "behaviour": behaviour, "api": api,
		"start_tick": _tick, "start_ms": _goal_state.level_ms, "start_lock": _goal_state.locks}


func _sort_rules() -> void:
	_rules.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["rank"] != b["rank"]: return int(a["rank"]) < int(b["rank"])
		if a["start_tick"] != b["start_tick"]: return int(a["start_tick"]) < int(b["start_tick"])
		return String(a["id"]) < String(b["id"]))


func _replace_twists() -> void:
	_rules_update_pending = false
	var removed: Array[StringName] = []
	var removed_flip: bool = false
	for index: int in range(_rules.size() - 1, -1, -1):
		if int(_rules[index]["rank"]) != 3:
			continue
		var id: StringName = _rules[index]["id"]
		removed_flip = removed_flip or (_rules[index]["def"] as RuleDef).behaviour in [&"flip", &"topsy_tumble"]
		removed.append(id)
		_rules.remove_at(index)
		if _started: _emit(SimEvents.RULE_ENDED, {"id": id})
	_structural = _structural.filter(func(request: Dictionary) -> bool: return not removed.has(request.get("owner", &"")))
	for key: StringName in _runtime_modifiers.keys():
		if removed.has(_runtime_modifiers[key].get("rule_id", &"")):
			_runtime_modifiers.erase(key)
	var added: Array[Dictionary] = []
	for entry: Dictionary in _pending_rule_definitions:
		var rule: Dictionary = _create_rule(entry, true)
		if not rule.is_empty():
			_rules.append(rule)
			added.append(rule)
	_pending_rule_definitions.clear()
	var has_flip: bool = false
	for rule: Dictionary in _rules:
		if (rule["def"] as RuleDef).behaviour in [&"flip", &"topsy_tumble"]: has_flip = true
	if has_flip: _down_reset_pending = false
	elif removed_flip and _board.down_vector() != BoardState.down_vector_of(_level.boards[0].down): _down_reset_pending = true
	_sort_rules()
	_rebuild_modifiers()
	_refresh_slots(false)
	if _started:
		for rule: Dictionary in added:
			_emit(SimEvents.RULE_STARTED, {"id": rule["id"]})
			var behaviour: RuleBehaviour = rule["behaviour"]
			if behaviour != null and behaviour.subscribed_hooks().has(&"on_level_start"):
				var api: RuleApi = rule["api"]
				api.set_time(now_ms())
				_runtime.execute(behaviour, &"handle", [&"on_level_start", _context(&"on_level_start", {}), api])
				_collect_api(api, true, int(rule["rank"]))


func _apply_down_reset() -> void:
	if _abilities != null and _abilities.has_method("veto") and bool(_runtime.execute(_abilities, &"veto", [&"stack.shift", 3])):
		return
	_down_reset_pending = false
	_board.set_down(_level.boards[0].down)
	_board.settle_cells()
	_emit(&"gravity_flip", {"mode": "axis", "reset": true})


func _modifier_list(candidate: Array[Dictionary] = [], candidate_rule: StringName = &"") -> Array[Dictionary]:
	var groups: Array[Dictionary] = []
	var candidate_rank: int = 2
	for rule: Dictionary in _rules:
		var definition: RuleDef = rule["def"]
		var own: Array[Dictionary] = []
		for modifier: Dictionary in definition.modifiers:
			var m: Dictionary = modifier.duplicate(true)
			var value: Variant = m.get("value")
			if value is String and String(value).begins_with("$param."):
				m["value"] = (rule["api"] as RuleApi).param(StringName(String(value).trim_prefix("$param.")))
			own.append(m)
		groups.append({"rank": rule["rank"], "tick": rule["start_tick"], "id": rule["id"], "modifiers": own})
		if rule["id"] == candidate_rule: candidate_rank = int(rule["rank"])
	for key: Variant in _runtime_modifiers:
		var dynamic: Dictionary = _runtime_modifiers[key]
		groups.append({"rank": dynamic["rank"], "tick": dynamic["tick"], "id": key, "modifiers": dynamic["modifiers"]})
	if not candidate.is_empty():
		groups.append({"rank": candidate_rank, "tick": _tick, "id": String(candidate_rule) + ":~probe", "modifiers": candidate})
	groups.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["rank"] != b["rank"]: return int(a["rank"]) < int(b["rank"])
		if a["tick"] != b["tick"]: return int(a["tick"]) < int(b["tick"])
		return String(a["id"]) < String(b["id"]))
	var modifiers: Array[Dictionary] = []
	for group: Dictionary in groups:
		modifiers.append_array(group["modifiers"])
	return modifiers


func _modifiers_would_change(candidate: Array[Dictionary], rule_id: StringName) -> bool:
	return _knobs.preview_modifiers(_modifier_list(candidate, rule_id)) != _knobs.snapshot()


func _rebuild_modifiers() -> void:
	for clamp: Dictionary in _knobs.apply_modifiers(_modifier_list()):
		_emit(SimEvents.KNOB_CLAMPED, clamp)
	var ids: PackedStringArray = PackedStringArray()
	for rule: Dictionary in _rules:
		ids.append(String(rule["id"]))
	for rule: Dictionary in _rules:
		(rule["api"] as RuleApi).bind_modifier_probe(Callable(self, &"_modifiers_would_change").bind(rule["id"]), ids)
	_api.bind_modifier_probe(Callable(self, &"_modifiers_would_change").bind(&"base"), ids)
	_ability_api.bind_modifier_probe(Callable(self, &"_modifiers_would_change").bind(&"ability"), ids)
	if _spawner != null:
		_spawner.configure(_knobs.snapshot())


func _refresh_slots(force: bool = true) -> void:
	if _catalog.plugins == null:
		return
	var slot_ids: Dictionary = {&"spawn.arrival": &"ArrivalStyle", &"clear.detector": &"ClearDetector",
		&"clear.collapse": &"CollapsePolicy", &"goal.type": &"GoalEvaluator", &"goal.top_out": &"TopOutPolicy"}
	for id: StringName in slot_ids:
		var value: StringName = StringName(_knobs.value(id))
		if not force and _slot_ids.get(id) == value:
			continue
		_slot_ids[id] = value
		var plugin: RefCounted = _catalog.plugins.create(slot_ids[id], value)
		match id:
			&"spawn.arrival": _arrival = plugin as ArrivalStyle
			&"clear.detector": _detector = plugin as ClearDetector
			&"clear.collapse": _collapse = plugin as CollapsePolicy
			&"goal.type":
				_goal_plugin = plugin as GoalEvaluator
				if _goal_plugin != null: _goal_plugin.configure(_level.goal)
			&"goal.top_out": _top_out_plugin = plugin as TopOutPolicy


func _context(hook: StringName, data: Dictionary) -> HookContext:
	var ctx: HookContext = HookContext.new()
	ctx.hook = hook
	ctx.data = {"tick": _tick, "time_ms": now_ms(), "level_ms": _goal_state.level_ms,
		"lock_count": _goal_state.locks, "clear_count": _goal_state.layers_cleared,
		"bag_id": _piece_flags.get(&"bag_index", -1), "bag_size": _piece_flags.get(&"bag_size", 0), "bag_pos": _piece_flags.get(&"bag_position", -1),
		"tags": _piece_flags.get(&"tags", _level.pieces.get("tags", PackedStringArray())), "shape_id": _piece.shape.shape_id if _piece != null else &""}
	ctx.data.merge(data, true)
	return ctx


# Tick and clear writes defer; lock and S4b flush per handler so higher-ranked rules observe lower-ranked writes.
func _run_hook(hook: StringName, data: Dictionary, flush: bool) -> bool:
	var dirty: bool = false
	var ctx: HookContext = _context(hook, data)
	for rule: Dictionary in _rules:
		var behaviour: RuleBehaviour = rule["behaviour"]
		if behaviour == null or not behaviour.subscribed_hooks().has(hook):
			continue
		var api: RuleApi = rule["api"]
		api.bind_piece(_piece)
		api.set_time(now_ms())
		api.bind_stack_permission(not (_abilities != null and _abilities.has_method("veto") and bool(_runtime.execute(_abilities, &"veto", [&"stack.shift", int(rule["rank"])]))))
		_runtime.execute(behaviour, &"handle", [hook, ctx, api])
		dirty = _collect_api(api, flush, int(rule["rank"])) or dirty
	return dirty


func _veto(action: StringName, data: Dictionary) -> bool:
	var ctx: HookContext = _context(&"veto", data)
	for rule: Dictionary in _rules:
		var definition: RuleDef = rule["def"]
		var api: RuleApi = rule["api"]
		api.bind_piece(_piece)
		api.set_time(now_ms())
		var vetoed: bool = false
		for veto: Dictionary in definition.vetoes:
			if StringName(veto.get("action", "")) == action and veto.get("when", {}) == {}:
				vetoed = true
		var behaviour: RuleBehaviour = rule["behaviour"]
		if behaviour != null:
			vetoed = bool(_runtime.execute(behaviour, &"veto", [action, ctx, api])) or vetoed
		_collect_api(api, true, int(rule["rank"]))
		if vetoed:
			_emit(SimEvents.RULE_BLOCKED, {"id": rule["id"], "action": action})
			return true
	return false


func _collect_api(api: RuleApi, flush: bool, rank: int = 4) -> bool:
	var protected: bool = _abilities != null and _abilities.has_method("veto") and bool(_runtime.execute(_abilities, &"veto", [&"stack.shift", rank]))
	var dirty: bool = api.flush_writes(protected) if flush else false
	for event: Dictionary in api.take_events():
		var data: Dictionary = event["data"]
		if not data.has("uid") and _piece != null:
			data["uid"] = _piece_uid
		_emit(event["kind"], data)
	for request: Dictionary in api.take_requests():
		request["rank"] = rank
		request["owner"] = api.rule_id()
		match request["op"]:
			&"score":
				if _score != null:
					_score.award(int(request["points"]))
					_goal_state.score = _score.total()
			&"modifiers":
				var key: StringName = StringName("%s:%s" % [api.rule_id(), request["effect"]])
				if request["modifiers"].is_empty():
					_runtime_modifiers.erase(key)
				else:
					_runtime_modifiers[key] = {"rule_id": api.rule_id(), "rank": rank, "tick": _tick, "modifiers": request["modifiers"]}
				_rebuild_modifiers()
				_refresh_slots(false)
			&"travel": _travel_dir = request["direction"]
			&"queue": _inject_queue(request["ids"])
			&"replace_preview": _replace_preview(request["ids"])
			&"replace_stream_preview": _replace_stream_preview(request["ids"])
			&"piece_flag": _piece_flags[request["flag"]] = request["value"]
			&"piece_hue":
				if _piece != null:
					_piece.hue_id = int(request["hue"])
			&"preview_hue":
				var index: int = int(request["index"])
				if index >= 0 and index < _queued_hues.size():
					_queued_hues[index] = int(request["hue"])
			&"catch":
				if _piece != null and _arrival != null:
					var origin: Vector3i = _spawn_origin(_piece.shape, _piece.orient)
					if _board.can_place(_piece.cells_at(_piece.orient, origin)):
						_piece.pivot = origin
						_fall_clock_ms = now_ms() + int(request["hold_ms"])
						_set_phase(Phase.FALLING)
						_emit(SimEvents.PIECE_MOVED, {"uid": _piece_uid, "origin": _piece.pivot, "cause": &"catch"})
			&"slot":
				var id: StringName = request["id"]
				if _catalog.knob_defs.def(id).get("type") == KnobDefs.T_SLOT:
					_structural.append(request)
				else:
					_knobs.set_effective(id, request["value"])
					if id == &"spawn.randomizer": _spawner.configure(_knobs.snapshot())
			_: _structural.append(request)
	return dirty


func _flush_rule_writes() -> bool:
	var dirty: bool = false
	for rule: Dictionary in _rules:
		var protected: bool = _abilities != null and _abilities.has_method("veto") and bool(_runtime.execute(_abilities, &"veto", [&"stack.shift", int(rule["rank"])]))
		dirty = (rule["api"] as RuleApi).flush_writes(protected) or dirty
	return dirty


func _bind_piece(piece: ActivePiece) -> void:
	_api.bind_piece(piece)
	_api.bind_piece_uid(_piece_uid)
	_ability_api.bind_piece(piece)
	_ability_api.bind_piece_uid(_piece_uid)
	_ability_api.bind_piece_flags(_piece_flags)
	_ability_api.bind_preview_hues(_queued_hues)
	_api.bind_piece_flags(_piece_flags)
	_api.bind_preview_hues(_queued_hues)
	for rule: Dictionary in _rules:
		(rule["api"] as RuleApi).bind_piece(piece)
		(rule["api"] as RuleApi).bind_piece_uid(_piece_uid)
		(rule["api"] as RuleApi).bind_piece_flags(_piece_flags)
		(rule["api"] as RuleApi).bind_preview_hues(_queued_hues)


func _expire_rules() -> void:
	var changed: bool = false
	for i: int in range(_rules.size() - 1, -1, -1):
		var rule: Dictionary = _rules[i]
		var definition: RuleDef = rule["def"]
		var lifetime: Dictionary = definition.lifetime
		var expired: bool = false
		if lifetime.get("kind") == "ms":
			expired = _goal_state.level_ms - int(rule.get("start_ms", 0)) >= int(lifetime.get("value", lifetime.get("ms", 0)))
		elif lifetime.get("kind") == "locks":
			expired = _goal_state.locks - int(rule.get("start_lock", 0)) >= int(lifetime.get("value", lifetime.get("locks", 0)))
		if expired:
			if definition.behaviour in [&"flip", &"topsy_tumble"] and _board.down_vector() != BoardState.down_vector_of(_level.boards[0].down):
				_down_reset_pending = true
			for key: Variant in _runtime_modifiers.keys():
				if _runtime_modifiers[key]["rule_id"] == rule["id"]: _runtime_modifiers.erase(key)
			_emit(SimEvents.RULE_ENDED, {"id": rule["id"]})
			_rules.remove_at(i)
			changed = true
	if changed:
		_rebuild_modifiers()
		_refresh_slots(false)


func _apply_structural() -> void:
	if _down_reset_pending: _runtime.execute(self, &"_apply_down_reset")
	if _shape_pool_pending: _runtime.execute(self, &"_apply_shape_pool")
	var order: Array[StringName] = [&"damage", &"stack_flip", &"down", &"mask", &"floor", &"height", &"junk", &"goal", &"slot", &"settle"]
	var deferred: Array[Dictionary] = []
	var settle: bool = false
	for kind: StringName in order:
		for request: Dictionary in _structural:
			if request["op"] != kind:
				continue
			if kind != &"slot" and _abilities != null and _abilities.has_method("veto") and bool(_runtime.execute(_abilities, &"veto", [&"stack.shift", int(request.get("rank", 4))])):
				deferred.append(request)
				continue
			match kind:
				&"damage":
					for cell: Vector3i in request["cells"]:
						if not _board.in_bounds(cell): continue
						for hit: int in int(request["hits"]):
							var index: int = _board.index(cell)
							var record: Dictionary = _board.get_record(index).duplicate(true)
							_board.remove(index, BoardState.Cause.DAMAGE)
							if not record.is_empty() and _board.get_kind(index) == 0:
								_emit(SimEvents.CUBE_CLEARED, {"cell": cell, "index": index, "record": record, "cause": BoardState.Cause.DAMAGE, "layer": _board.layer_of(index)})
				&"stack_flip": _board.flip_stack()
				&"down":
					var direction: int = request["direction"]
					if direction >= 0 and direction < BoardState.DOWN_TOKENS.size():
						_board.set_down(direction as BoardState.Down)
						settle = true
				&"mask":
					_board.set_active(request["x"], request["z"], request["on"])
					settle = true
				&"floor": _board.set_floor(int(request["layer"]))
				&"height": _board.set_height_limit(int(request["height"]))
				&"junk": _board.raise_junk(int(request["layers"]), _catalog.content.kind_of(&"block"), int(request.get("seed", 0)))
				&"goal":
					_level.goal = request["config"].duplicate(true)
					_knobs.set_slot(&"goal.type", StringName(_level.goal.get("type", "clear_n")))
					_refresh_slots()
					_api.bind_goal(_goal_state, _level.goal)
					_ability_api.bind_goal(_goal_state, _level.goal)
					for rule: Dictionary in _rules:
						(rule["api"] as RuleApi).bind_goal(_goal_state, _level.goal)
					if _goal_plugin != null:
						_runtime.execute(_goal_plugin, &"begin", [_goal_state, _api])
				&"slot":
					if _knobs.set_slot(request["id"], request["value"]):
						_refresh_slots()
				&"settle": _board.settle_cells()
	if settle:
		_board.settle_cells()
	_structural = deferred


func _clear_pass(single_round: bool) -> int:
	if not _knobs.flag(&"clear.enabled") or _detector == null:
		return 0
	var total: int = 0
	var rounds: int = 1 if single_round or _knobs.value(&"clear.collapse") == &"slice" else _knobs.int_value(&"clear.chain_max")
	for round_no: int in range(1, rounds + 1):
		var groups: Array[ClearGroup] = []
		groups.assign(_runtime.execute(_detector, &"find_clears", [_board, _api]))
		if groups.is_empty() or _veto(&"clear.layer", {}):
			break
		var cells: Array[int] = []
		var layer_ids: PackedInt32Array = PackedInt32Array()
		var layers: int = 0
		for group: ClearGroup in groups:
			layers += group.counts_as_layers
			for i: int in group.cells:
				if not cells.has(i):
					cells.append(i)
				var layer: int = _board.layer_of(i)
				if not layer_ids.has(layer):
					layer_ids.append(layer)
		cells.sort_custom(func(a: int, b: int) -> bool:
			return _board.layer_of(a) < _board.layer_of(b) if _board.layer_of(a) != _board.layer_of(b) else a < b)
		for i: int in cells:
			_run_hook(&"on_clear", {"cell": _board.cell(i), "index": i, "layer": _board.layer_of(i), "kind": _board.get_kind(i),
				"record": _board.get_record(i), "chain_round": round_no, "clear_count": _goal_state.layers_cleared + layers}, false)
		# Unlock/peel hooks see one unchanged candidate set, then their statuses apply
		# together before clear guards decide which original blocks can be removed.
		_flush_rule_writes()
		_collect_api(_api, true)
		var removed: int = 0
		for i: int in cells:
			if _board.get_kind(i) == 0 or not _board.can_remove(i, BoardState.Cause.CLEAR):
				continue
			if _goal_plugin != null:
				_runtime.execute(_goal_plugin, &"on_clear", [_board.cell(i), _board.get_record(i), _goal_state, _api])
			_emit(SimEvents.CUBE_CLEARED, {"cell": _board.cell(i), "index": i, "record": _board.get_record(i).duplicate(true), "cause": BoardState.Cause.CLEAR, "layer": _board.layer_of(i)})
			_board.remove(i, BoardState.Cause.CLEAR)
			removed += 1
		if removed == 0:
			break
		if _collapse != null:
			_runtime.execute(_collapse, &"collapse", [_board, groups, _api])
		_flush_rule_writes()
		_collect_api(_api, true)
		_goal_state.layers_cleared += layers
		total += layers
		var active: int = _board.active_in_layer(0)
		_clear_round_count += 1
		_score.on_clear(layers, _clear_round_count, active, not _clear_combo_started)
		_clear_combo_started = true
		layer_ids.sort()
		_emit(SimEvents.LAYERS_CLEARED, {"indices": layer_ids, "layers": layer_ids, "n_layers": layers, "chain_round": round_no, "cells": PackedInt32Array(cells)})
		_resolve_ms += mini(_knobs.int_value(&"clear.resolve_max_ms"), _knobs.int_value(&"clear.anim_ms") + maxi(0, layers - 1) * _knobs.int_value(&"clear.stagger_ms") + _knobs.int_value(&"clear.settle_ms"))
	return total


func _handle_top_out(reason: StringName) -> bool:
	_run_hook(&"on_top_out", {"reason": reason}, true)
	if _top_out_plugin == null:
		return false
	var before: int = _goal_state.warnings_left
	var trimmed: int = _goal_state.cells_trimmed
	var status: int = int(_runtime.execute(_top_out_plugin, &"resolve_top_out", [_board, _goal_state, _api]))
	_collect_api(_api, true)
	if _goal_state.warnings_left < before:
		_goal_state.warnings_used += before - _goal_state.warnings_left
		_score.reset_combo()
		_warning_until = now_ms() + _knobs.int_value(&"goal.warning_ms")
		_emit(SimEvents.TOP_OUT_WARNING, {"warnings_left": _goal_state.warnings_left, "warnings_used": _goal_state.warnings_used})
	if _goal_state.cells_trimmed > trimmed:
		_emit(SimEvents.CELLS_TRIMMED, {"count": _goal_state.cells_trimmed - trimmed})
	return status != GoalState.RESULT_LOST


func _finish(outcome: int, reason: StringName = &"") -> void:
	if _phase == Phase.ENDED:
		return
	_goal_state.result = outcome
	_piece = null
	_bind_piece(null)
	_result = LevelResult.new()
	_result.outcome = LevelResult.OUTCOME_WON if outcome == GoalState.RESULT_WON else LevelResult.OUTCOME_LOST
	_result.level_ms = _goal_state.level_ms
	_result.layers_cleared = _goal_state.layers_cleared
	_result.warnings_used = _goal_state.warnings_used
	_result.pieces_placed = _goal_state.locks
	_result.score = _score.total()
	_result.cells_trimmed = _goal_state.cells_trimmed
	_result.metrics = _goal_state.metrics.duplicate(true)
	_result.stars = StarRater.rate(_level.stars, _result, bool(_level.story.get("relaxed", false)))
	var data: Dictionary = {"outcome": _result.outcome, "level_ms": _result.level_ms, "layers_cleared": _result.layers_cleared,
		"warnings_used": _result.warnings_used, "pieces_placed": _result.pieces_placed, "score": _result.score,
		"stars": _result.stars, "cells_trimmed": _result.cells_trimmed, "metrics": _result.metrics, "reason": reason}
	_emit(SimEvents.GOAL_REACHED if outcome == GoalState.RESULT_WON else SimEvents.LEVEL_FAILED, data)
	_emit(SimEvents.LEVEL_RESULT, data)
	_set_phase(Phase.ENDED)


func _emit_delta() -> void:
	var delta: PackedInt32Array = _board.take_delta()
	if not delta.is_empty():
		_emit(SimEvents.CELLS_CHANGED, {"delta": delta})


func _cmd_hold() -> void:
	if not _knobs.flag(&"spawn.hold_enabled") or _hold_used or _piece == null:
		return
	var shape: StringName = _piece.shape.shape_id
	var held: StringName = _held_shape
	var held_hue: int = _held_hue
	var held_flags: Dictionary = _held_flags.duplicate(true)
	var ids: PackedStringArray = _spawner.peek(1)
	var candidate: StringName = held if held != &"" else (StringName(ids[0]) if not ids.is_empty() else &"")
	var incoming: ShapeDef = _catalog.shapes.get_shape(candidate)
	var plan: ArrivalPlan = _runtime.execute(_arrival, &"plan_arrival", [incoming, _board, _api]) as ArrivalPlan if incoming != null and _arrival != null else null
	if plan == null or plan.blocked:
		return
	_held_shape = shape
	_held_hue = _piece.hue_id
	_held_flags = _piece_flags.duplicate(true)
	_held_flags.erase(&"lock_now")
	_held_flags.erase(&"lock_paused")
	_piece = null
	_bind_piece(null)
	_spawn(held, held_hue if held != &"" else -1, false, held_flags)
	_hold_used = true


func _translate(direction: Vector3i) -> Dictionary:
	if not _piece_flags.get(&"intangible", false):
		return Movement.try_translate(_piece, _board, direction)
	for c: Vector3i in _piece.cells_at(_piece.orient, _piece.pivot + direction):
		if not _board.in_bounds(c) or not _board.is_active(_board.index(c)):
			return {"result": Movement.Result.BLOCKED, "reason": Movement.R_OUT}
	_piece.pivot += direction
	return {"result": Movement.Result.OK, "reason": Movement.R_NONE}

## Current score. Example: hud.set_score(sim.score()).
func score() -> int:
	return _score.total() if _score != null else 0

func progress_snapshot() -> Dictionary:
	return goal_progress()


## Colour keys of the shown queue, including rolled Candy flavours. Example: sim.preview_hues(3).
func preview_hues(n: int) -> PackedInt32Array:
	return PackedInt32Array(_queued_hues.slice(0, mini(n, _queued_hues.size())))

func _roll_colour(shape: ShapeDef, use_fixed: bool = true) -> int:
	var fixed: Variant = _level.pieces.get("fixed_hues", [])
	if use_fixed:
		var fixed_index: int = _colour_generated
		_colour_generated += 1
		if fixed is Array or fixed is PackedInt32Array:
			if fixed_index < fixed.size():
				return int(fixed[fixed_index])
	var count: int = _knobs.int_value(&"spawn.colour_count")
	if count <= 0:
		return shape.hue_id if shape != null else 0
	if _last_colour > 0 and _colour_rng.randi_range(0, 999) < _knobs.int_value(&"spawn.colour_streak"):
		return _last_colour
	var config: Variant = _knobs.value(&"spawn.colour_weights")
	var weights: PackedInt32Array = PackedInt32Array()
	var flavour_keys: Array[String] = ["P", "V", "M", "B", "C", "D", "E", "F", "G", "H"]
	for i: int in count:
		var weight: float = 1.0
		if config is Dictionary:
			weight = float(config.get(str(i + 1), config.get(flavour_keys[i], 1.0)))
		weights.append(maxi(0, roundi(weight * 1000)))
	var picked: int = Seeds.weighted_pick(_colour_rng, weights)
	_last_colour = picked + 1 if picked >= 0 else 1
	return _last_colour

func _inject_queue(ids: PackedStringArray) -> void:
	_spawner.inject_front(ids)
	for i: int in range(ids.size() - 1, -1, -1):
		_queued_hues.push_front(_roll_colour(_catalog.shapes.get_shape(StringName(ids[i])), false))


func _spawn_origin(shape: ShapeDef, orient: int) -> Vector3i:
	var down: Vector3i = _board.down_vector()
	var size: Vector3i = _board.size()
	var lo: Vector3i = shape.min_corner(orient)
	var box: Vector3i = shape.bbox(orient)
	var anchor: Vector2i = _board.spawn_anchor()
	var ground_index: int = 0
	var origin: Vector3i = Vector3i.ZERO
	for axis: int in 3:
		if down[axis] < 0:
			origin[axis] = _board.limit_layer() - lo[axis]
		elif down[axis] > 0:
			origin[axis] = size[axis] - 1 - _board.limit_layer() - lo[axis] - box[axis] + 1
		else:
			origin[axis] = anchor[ground_index] - (box[axis] - 1) / 2 - lo[axis]
			ground_index += 1
	return origin


func _replace_preview(ids: PackedStringArray) -> void:
	_spawner.replace_preview(ids)
	for i: int in mini(ids.size(), _queued_hues.size()):
		_queued_hues[i] = _roll_colour(_catalog.shapes.get_shape(StringName(ids[i])), false)

func _replace_stream_preview(ids: PackedStringArray) -> void:
	var positions: PackedInt32Array = _spawner.stream_preview_positions(ids.size())
	_spawner.replace_stream_preview(ids)
	for index: int in positions.size():
		if positions[index] < _queued_hues.size():
			_queued_hues[positions[index]] = _roll_colour(_catalog.shapes.get_shape(StringName(ids[index])), false)

func _timed_out() -> bool:
	var limit: int = int(_level.goal.get("time_limit_ms", _knobs.int_value(&"goal.time_limit_ms")))
	return limit > 0 and _goal_state.level_ms >= limit
