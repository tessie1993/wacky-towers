class_name WtMinigameSession extends RefCounted
## Fixed 60 Hz tournament round. All gameplay hooks execute through native manual Beehave.
## Native MG5 deliberately uses WtCraneTower instead of this integer grid driver.
var template: Dictionary = {}
var params: Dictionary = {}
var catalog: GameCatalog
var player_id: int = 0
var id: StringName
var rng: RandomNumberGenerator
var attack_rng: RandomNumberGenerator
var sim: BoardSim
var state: Dictionary = {}
var view: Dictionary = {}
var points: int = 0
var progress: int = 0
var active: ActivePiece
var frame: BoardState
var spawner: Spawner
var _seed: int = 0
var _tick: int = 0
var _duration: int = 60000
var _phase: StringName = &"playing"
var _rules: RefCounted
var _runtime: RuleRuntime = RuleRuntime.new()
var _commands: Array[SimCommand] = []
var _events: Array[SimEvent] = []
var _attacks: Array[Dictionary] = []
var _seen_tokens: Dictionary = {}
var _send: Dictionary = {"ready": false, "charge": 0, "needed": 1, "effect": &"", "data": {}, "target": -1}
var _send_serial: int = 0
var _standings: Array[Dictionary] = []
var _players: int = 1
var _rank: int = 1
var _result: Dictionary = {}
var _ghost_send_at: int = 0

func setup(descriptor: Dictionary, seed: int, game_catalog: GameCatalog, owner: int = 0) -> bool:
	template = descriptor.duplicate(true)
	params = template.get("params", {}).duplicate(true)
	catalog = game_catalog
	player_id = owner
	id = StringName(template.get("id", "mg01"))
	if id == &"mg05" or catalog == null or catalog.shapes == null: return false
	_seed = seed
	_tick = 0
	_duration = maxi(1, int(template.get("duration_ms", 60000)))
	_phase = &"playing"
	points = 0
	progress = 0
	state = {}
	view = {}
	sim = null
	frame = null
	active = null
	_commands.clear()
	_attacks.clear()
	_seen_tokens.clear()
	_result.clear()
	_send = {"ready": false, "charge": 0, "needed": 1, "effect": &"", "data": {}, "target": -1}
	rng = Seeds.make_rng(seed, ["minigame", id, "challenges"])
	attack_rng = Seeds.make_rng(seed, ["minigame", id, "incoming", owner])
	spawner = Spawner.new({"shapes": shape_pool()}, 4, seed)
	var script_path: String = str(template.get("rules_script", "")) if template.has("rules_script") else "res://src/game/minigames/rules_b.gd" if id in [&"mg06", &"mg07", &"mg08", &"mg10", &"mg11", &"mg12", &"mg13", &"mg14", &"mg19", &"mg20", &"mg21"] else "res://src/game/minigames/rules_a.gd"
	if not ResourceLoader.exists(script_path): return false
	_rules = load(script_path).new()
	_runtime.execute(_rules, &"start", [self])
	return _rules != null

func queue_command(command: SimCommand) -> void:
	var tick: int = maxi(_tick + 1, command.tick)
	_commands.append(SimCommand.make(command.kind, command.args.duplicate(true), tick))

func step() -> Array[SimEvent]:
	_events.clear()
	_tick += 1
	_runtime.execute(self, &"_advance")
	return _events.duplicate()

func _advance() -> void:
	var remaining: Array[SimCommand] = []
	for command: SimCommand in _commands:
		if command.tick > _tick:
			remaining.append(command)
		else:
			_dispatch(command)
	_commands = remaining
	if _phase == &"finished": return
	var pending: Array[Dictionary] = []
	for attack: Dictionary in _attacks:
		if now_ms() >= int(attack.due):
			if _phase == &"playing":
				_runtime.execute(_rules, &"attack", [self, StringName(attack.effect), attack.data])
				emit(&"mg_attack_applied", attack)
			else: emit(&"mg_attack_missed", attack)
		else: pending.append(attack)
	_attacks = pending
	if _phase == &"ghost":
		if now_ms() >= _ghost_send_at:
			charge_send(StringName(state.get("ghost_effect", "pump")))
			_ghost_send_at = now_ms() + int(params.get("ghost_send_ms", 15000))
	else:
		var board_events: Array[SimEvent] = sim.step() if sim != null else []
		for event: SimEvent in board_events:
			var data: Dictionary = event.data.duplicate(true)
			data["player_id"] = player_id
			_events.append(SimEvent.make(_tick, event.kind, data))
		_runtime.execute(_rules, &"tick", [self, board_events])
	if now_ms() >= _duration and _phase != &"finished": finish(&"lost" if _phase == &"ghost" else &"time_cap")

func _dispatch(command: SimCommand) -> void:
	if command.kind == &"mg_standings":
		var data: Dictionary = command.args[0] if not command.args.is_empty() and command.args[0] is Dictionary else {}
		_standings.clear()
		for standing: Dictionary in data.get("standings", []): _standings.append(standing.duplicate(true))
		_players = clampi(int(data.get("players", _standings.size())), 1, 4)
		_rank = clampi(int(data.get("rank", 1)), 1, _players)
		if sim != null: sim.bind_item_context({"players": _players, "rank": _rank, "mode": "tournament", "owner": player_id})
		return
	if command.kind == &"mg_receive_attack":
		if not command.args.is_empty() and command.args[0] is Dictionary: _receive(command.args[0])
		return
	if command.kind == &"mg_target":
		if not command.args.is_empty(): _send.target = int(command.args[0])
		return
	if command.kind == &"mg_send":
		if bool(_send.ready): request_send(StringName(_send.effect), _send.data)
		return
	if _phase == &"finished": return
	if _phase == &"ghost" and command.kind != &"mg_authority": return
	var consumed: bool = bool(_runtime.execute(_rules, &"command", [self, command]))
	if consumed or sim == null: return
	match command.kind:
		&"mg_move": grid_command(SimEvents.CMD_MOVE, command.args)
		&"mg_rotate": grid_command(SimEvents.CMD_ROTATE, command.args)
		&"mg_drop": grid_command(SimEvents.CMD_HARD_DROP)
		&"mg_hold": grid_command(SimEvents.CMD_HOLD)
		SimEvents.CMD_USE_ITEM, SimEvents.CMD_RECEIVE_ITEM: grid_command(command.kind, command.args)

func _receive(data: Dictionary) -> void:
	var token: String = str(data.get("token", ""))
	if token.is_empty() or _seen_tokens.has(token): return
	_seen_tokens[token] = true
	if _phase != &"playing":
		emit(&"mg_attack_missed", data)
		return
	var attack: Dictionary = data.duplicate(true)
	attack["due"] = now_ms() + clampi(int(data.get("warn_ms", params.get("attack_warn_ms", 1000))), 500, 2000)
	attack["data"] = data.get("data", {}).duplicate(true)
	attack["effect"] = StringName(data.get("effect", ""))
	if _rules.has_method("preview_attack"):
		attack["data"] = _runtime.execute(_rules, &"preview_attack", [self, attack["effect"], attack["data"]])
	_attacks.append(attack)
	emit(&"mg_attack_warning", attack)

func now_ms() -> int:
	return (_tick * 1000) / 60

func elapsed_ms() -> int: return now_ms()
func get_tick() -> int: return _tick
func get_phase() -> StringName: return _phase
func score() -> int: return points
func bind_context(context: Dictionary) -> void:
	_players = clampi(int(context.get("players", 1)), 1, 4)
	_rank = clampi(int(context.get("rank", 1)), 1, _players)
	_standings.clear()
	for target: Dictionary in context.get("targets", context.get("standings", [])):
		var entry: Dictionary = target.duplicate(true)
		entry["player_id"] = int(entry.get("player_id", entry.get("owner", entry.get("id", -1))))
		_standings.append(entry)
	if sim != null: sim.bind_item_context({"players": _players, "rank": _rank, "mode": "tournament", "owner": player_id})

func rank() -> int: return _rank
func players() -> int: return _players
func result() -> Dictionary: return _result.duplicate(true)

func emit(kind: StringName, data: Dictionary = {}) -> void:
	var payload: Dictionary = data.duplicate(true)
	if not payload.has("player_id"): payload["player_id"] = player_id
	_events.append(SimEvent.make(_tick, kind, payload))

func add_score(amount: int) -> void:
	points = maxi(0, points + amount)
	emit(&"mg_score", {"score": points, "delta": amount})

func finish(status: StringName = &"won") -> void:
	if _phase == &"finished": return
	_phase = &"finished"
	_result = {"status": status, "score": points, "progress_milli": progress, "standing": standing(), "elapsed_ms": now_ms(), "player_id": player_id, "ghost": bool(state.get("eliminated", false))}
	emit(&"mg_finished", _result)

func become_ghost() -> void:
	if _phase != &"playing": return
	_phase = &"ghost"
	state["eliminated"] = true
	state["alive_ms"] = int(state.get("alive_ms", now_ms()))
	_ghost_send_at = now_ms() + int(params.get("ghost_send_ms", 15000))
	emit(&"mg_ghost", {"standing": standing()})

func standing() -> int:
	match StringName(template.get("standing_metric", "score")):
		&"race_progress": return progress
		&"height": return top_height()
		&"alive_time": return int(state.get("alive_ms", now_ms()))
		_: return points

func progress_snapshot() -> Dictionary:
	return {"done": progress, "target": 1000, "score": points, "standing": standing(), "metric": template.get("standing_metric", "score")}

func charge_needed(base: int) -> int:
	var comeback: int = roundi(float(params.get("k_cb", 0.5)) * 1000)
	var scale: int = 1000 + comeback * (_rank - 1) / maxi(1, _players - 1)
	return maxi(1, (base * 1000 + scale / 2) / scale)

func charge_send(effect: StringName, data: Dictionary = {}, base_charge: int = 1) -> void:
	_send.charge = int(_send.charge) + 1
	_send.needed = charge_needed(base_charge)
	_send.effect = effect
	_send.data = data.duplicate(true)
	if int(_send.charge) >= int(_send.needed) and not bool(_send.ready):
		_send.ready = true
		emit(&"mg_send_charged", _send)

func request_send(effect: StringName, data: Dictionary = {}) -> void:
	var target: int = _target()
	if target < 0:
		emit(&"mg_send_missed", {"effect": effect, "reason": "no_target"})
		return
	_send_serial += 1
	var payload: Dictionary = data.duplicate(true)
	if _players >= 3 and _rank == 1:
		var scale: int = roundi(float(params.get("leader_send_scale", 0.5)) * 1000)
		for key: String in ["duration_ms", "amount", "count"]:
			if payload.has(key): payload[key] = maxi(1, int(payload[key]) * scale / 1000)
	var event: Dictionary = {"token": "%s:%d:%d" % [id, player_id, _send_serial], "effect": effect, "data": payload,
		"sender": player_id, "target": target, "warn_ms": int(params.get("attack_warn_ms", 1000))}
	_send.charge = 0
	_send.ready = false
	_send.target = -1
	emit(&"mg_send_request", event)

func _target() -> int:
	var candidates: Array[Dictionary] = []
	for entry: Dictionary in _standings:
		if int(entry.get("player_id", -1)) != player_id and not bool(entry.get("out", false)): candidates.append(entry)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("standing", 0)) != int(b.get("standing", 0)): return int(a.get("standing", 0)) > int(b.get("standing", 0))
		if int(a.get("score", 0)) != int(b.get("score", 0)): return int(a.get("score", 0)) > int(b.get("score", 0))
		return int(a.player_id) < int(b.player_id))
	for entry: Dictionary in candidates:
		if int(entry.player_id) == int(_send.target): return int(_send.target)
	if not candidates.is_empty(): return int(candidates[0].player_id)
	if _players > 1: return (player_id + 1) % _players
	return -1

func request_shared(kind: StringName, data: Dictionary = {}) -> void:
	emit(&"mg_shared_request", {"kind": kind, "data": data.duplicate(true), "player_id": player_id, "tick": _tick})

func shape_pool() -> PackedStringArray:
	var pool: PackedStringArray = PackedStringArray(template.get("piece_pool", []))
	if pool.is_empty():
		for shape: ShapeDef in catalog.shapes.shapes:
			if shape.cube_count >= 3 and shape.cube_count <= 4 and pool.size() < 8: pool.append(String(shape.shape_id))
	if pool.is_empty() and not catalog.shapes.shapes.is_empty(): pool.append(String(catalog.shapes.shapes[0].shape_id))
	return pool

func next_shape() -> ShapeDef:
	return catalog.shapes.get_shape(spawner.next())

func set_board(raw_board: Dictionary, pieces: Dictionary = {}, knobs: Dictionary = {}, goal: Dictionary = {}, rules: Array = []) -> void:
	var defaults: Dictionary = {"goal.countdown_ms": 0, "fall.entry_delay_ms": 0, "fall.hard_drop_grace_ms": 0,
		"fall.g0": 1.0, "fall.lock_delay_ms": 350, "clear.detector": "layer", "goal.top_out": "trim", "spawn.preview_count": 3}
	defaults.merge(knobs, true)
	var piece_data: Dictionary = {"shapes": shape_pool(), "opening_count": 0}
	piece_data.merge(pieces, true)
	var source: Dictionary = {"schema": 1, "id": String(id), "biome": "meadow", "tier": 1, "seed": _seed,
		"board": raw_board.duplicate(true), "pieces": piece_data, "knobs": defaults, "goal": goal if not goal.is_empty() else {"type": "endless"}, "rules": rules}
	var loaded: LoadResult = LevelLoader.parse_level(source, catalog)
	if not loaded.ok():
		emit(&"mg_setup_error", {"issues": str(loaded.issues)})
		finish(&"invalid")
		return
	sim = BoardSim.new(loaded.level, _seed, catalog)
	sim.bind_item_context({"players": _players, "rank": _rank, "mode": "tournament", "owner": player_id})
	frame = null
	active = null

func set_frame(size: Vector3i) -> void:
	var spec: BoardSpec = BoardSpec.new()
	spec.size = size
	spec.h_play = size.y
	spec.down = BoardState.Down.Y_NEG
	spec.spawn_anchor = Vector2i(size.x / 2, size.z / 2)
	spec.mask.resize(size.x * size.z)
	spec.mask.fill(1)
	frame = BoardState.new(spec, catalog.content)
	sim = null

func grid_command(kind: StringName, arguments: Array = []) -> void:
	if sim != null: sim.queue_command(SimCommand.make(kind, arguments))

func inject_piece(shape_id: StringName, delay: int = 0) -> void:
	if sim == null: return
	if delay <= 0:
		sim.get_api().inject_front(PackedStringArray([String(shape_id)]))
		sim._collect_api(sim.get_api(), true)
	else:
		var queue: Array[StringName] = sim._spawner._queue
		var index: int = mini(delay, queue.size())
		queue.insert(index, shape_id)
		sim._spawner._queue_info.insert(index, {"injected": true, "id": -1, "size": 0, "index": -1, "stream_index": -1})
		sim._queued_hues.insert(index, catalog.shapes.get_shape(shape_id).hue_id)

func board_state() -> BoardState:
	return sim.board() if sim != null else frame

func board_cells() -> Array[Vector3i]:
	var output: Array[Vector3i] = []
	var board: BoardState = board_state()
	if board == null: return output
	var size: Vector3i = board.size()
	for y: int in size.y:
		for z: int in size.z:
			for x: int in size.x:
				var cell: Vector3i = Vector3i(x, y, z)
				if board.get_kind(board.index(cell)) != 0: output.append(cell)
	return output

func top_height() -> int:
	var height: int = 0
	for cell: Vector3i in board_cells(): height = maxi(height, cell.y + 1)
	return height

func snapshot() -> Dictionary:
	var board: BoardState = board_state()
	var cells: Array[Dictionary] = []
	if board != null:
		for cell: Vector3i in board_cells():
			var index: int = board.index(cell)
			cells.append({"cell": cell, "kind": board.get_kind(index), "hue": board.get_color(index), "status": board.get_record(index).get("status", {}).duplicate(true)})
	var piece: ActivePiece = sim.get_piece() if sim != null else active
	var piece_view: Dictionary = {} if piece == null else {"shape_id": piece.shape.shape_id, "orient": piece.orient, "pivot": piece.pivot, "cells": piece.cells(), "hue": piece.hue_id}
	return {"id": id, "minigame_id": template.get("minigame_id", ""), "phase": _phase, "tick": _tick, "elapsed_ms": now_ms(), "duration_ms": _duration,
		"score": points, "progress_milli": progress, "standing_metric": template.get("standing_metric", "score"), "standing": standing(),
		"board": {"size": board.size() if board != null else Vector3i.ZERO, "down": board.down_vector() if board != null else Vector3i.DOWN, "cells": cells},
		"piece": piece_view, "preview": sim.preview(3) if sim != null else spawner.peek(3), "state": state.duplicate(true), "view": view.duplicate(true),
		"send": _send.duplicate(true), "attacks": _attacks.duplicate(true), "ghost": _phase == &"ghost", "result": result()}

func state_hash() -> int:
	var commands: Array[Dictionary] = []
	for command: SimCommand in _commands: commands.append({"kind": command.kind, "tick": command.tick, "args": command.args})
	return Seeds.fnv1a(var_to_bytes({"snapshot": snapshot(), "rng": rng.state, "attack_rng": attack_rng.state, "spawn": spawner.snapshot(),
		"sim": sim.state_hash() if sim != null else 0, "frame": frame.snapshot() if frame != null else {}, "commands": commands,
		"seen": _seen_tokens, "serial": _send_serial, "standings": _standings, "rank": _rank, "players": _players, "runtime": _runtime.snapshot()}))
