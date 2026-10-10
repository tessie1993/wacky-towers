class_name WtMinigameRound extends RefCounted
## Host-side tournament minigame round: one WtMinigameSession per player, fixed-60 Hz stepping,
## send routing, shared-moment authority and practice bots. Pure logic; the app only renders.
## Design: design/gdd/tournament-minigames.md (contract), design/gdd/party-minigames-wave2.md.

## Template ids the integer session driver cannot host (MG5 is a native Jolt scene).
const UNSUPPORTED: PackedStringArray = ["mg05"]
## Ticks between standings broadcasts and between bot decisions.
const STANDINGS_EVERY := 30
const BOT_EVERY := 18

var template: Dictionary = {}
var sessions: Array[WtMinigameSession] = []
var names: PackedStringArray = PackedStringArray()
var bots: Array[bool] = []
var _bot_rng: RandomNumberGenerator
var _tick: int = 0
var _awarded: Dictionary = {}
var _last_volley_sender: Dictionary = {}
var _hot_serial: int = 0
var _local_events: Array[SimEvent] = []

## True when `template` can run through WtMinigameSession.
static func supports(row: Dictionary) -> bool:
	return str(row.get("category", "")) == "minigame" and not UNSUPPORTED.has(str(row.get("id", "")))

## Builds every player's session. `players` rows: {"name", "is_bot"}; index 0 is the local player.
func setup(row: Dictionary, seed: int, catalog: GameCatalog, players: Array) -> bool:
	template = row.duplicate(true)
	sessions.clear()
	names.clear()
	bots.clear()
	_awarded.clear()
	_last_volley_sender.clear()
	_tick = 0
	_hot_serial = 0
	_bot_rng = Seeds.make_rng(seed, ["minigame_round_bots", str(row.get("id", ""))])
	if not supports(row): return false
	for index: int in players.size():
		var player: Dictionary = players[index] if players[index] is Dictionary else {"name": str(players[index])}
		var session: WtMinigameSession = WtMinigameSession.new()
		if not session.setup(template, seed, catalog, index): return false
		sessions.append(session)
		names.append(str(player.get("name", "Builder %d" % (index + 1))))
		bots.append(index > 0 or bool(player.get("is_bot", false)))
	_broadcast_standings()
	return not sessions.is_empty()

## Queues a command for one player's session (local input or a bot).
func queue(player: int, kind: StringName, args: Array = []) -> void:
	if player < 0 or player >= sessions.size(): return
	sessions[player].queue_command(SimCommand.make(kind, args, sessions[player].get_tick() + 1))

## Converts a UI intent dictionary into session command args (values in insertion order).
static func intent_args(args: Dictionary) -> Array:
	var output: Array = []
	for key: Variant in args.keys(): output.append(args[key])
	return output

## Advances every session one tick; returns the local player's events.
func step() -> Array[SimEvent]:
	_tick += 1
	_local_events.clear()
	if _tick % STANDINGS_EVERY == 0: _broadcast_standings()
	for index: int in sessions.size():
		if bots[index] and _tick % BOT_EVERY == (index * 5) % BOT_EVERY: _bot_act(index)
		for event: SimEvent in sessions[index].step():
			if index == 0: _local_events.append(event)
			match event.kind:
				&"mg_send_request": _route_send(index, event.data)
				&"mg_shared_request": _resolve_shared(index, event.data)
	return _local_events.duplicate()

## True once every session has finished (each finishes itself at its time cap).
func finished() -> bool:
	for session: WtMinigameSession in sessions:
		if session.get_phase() != &"finished": return false
	return not sessions.is_empty()

## Ends every unfinished session now (pause-menu quit or app time cap).
func force_finish() -> void:
	for session: WtMinigameSession in sessions:
		if session.get_phase() != &"finished": session.finish(&"time_cap")

## Result rows in the shape WtModes.record_round expects.
func results() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for index: int in sessions.size():
		var session: WtMinigameSession = sessions[index]
		var result: Dictionary = session.result()
		var status: StringName = StringName(result.get("status", &""))
		rows.append({"id": str(index), "player": index, "index": index, "won": status == &"won",
			"ms": int(result.get("elapsed_ms", session.now_ms())), "standing_value": session.standing(),
			"progress": session.progress, "score": session.score(), "height": session.top_height(), "layers": 0,
			"alive": not bool(session.state.get("eliminated", false)), "alive_time": int(session.state.get("alive_ms", session.now_ms())), "active": true})
	return rows

## Local player's snapshot plus opponent rows for the minigame UI.
func local_snapshot() -> Dictionary:
	if sessions.is_empty(): return {}
	var data: Dictionary = sessions[0].snapshot()
	data["name"] = str(template.get("name", ""))
	data["rule"] = str(template.get("rule", ""))
	var opponents: Array = []
	for index: int in range(1, sessions.size()):
		opponents.append({"id": index, "name": names[index], "standing": sessions[index].standing(), "score": sessions[index].score(),
			"active": sessions[index].get_phase() == &"playing"})
	data["opponents"] = opponents
	for attack: Dictionary in data.get("attacks", []):
		var sender: int = int(attack.get("sender", -1))
		if sender >= 0 and sender < names.size(): attack["sender_name"] = names[sender]
	return data

func _standings() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for index: int in sessions.size():
		rows.append({"player_id": index, "standing": sessions[index].standing(), "score": sessions[index].score(),
			"out": sessions[index].get_phase() != &"playing"})
	return rows

func _ranked() -> Array[Dictionary]:
	var rows: Array[Dictionary] = _standings()
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.standing) != int(b.standing): return int(a.standing) > int(b.standing)
		if int(a.score) != int(b.score): return int(a.score) > int(b.score)
		return int(a.player_id) < int(b.player_id))
	return rows

func _leader() -> int:
	var ranked: Array[Dictionary] = _ranked()
	return int(ranked[0].player_id) if not ranked.is_empty() else -1

func _broadcast_standings() -> void:
	var ranked: Array[Dictionary] = _ranked()
	for index: int in sessions.size():
		var rank: int = 1
		for position: int in ranked.size():
			if int(ranked[position].player_id) == index: rank = position + 1
		sessions[index].queue_command(SimCommand.make(&"mg_standings", [{"standings": _standings(), "players": sessions.size(), "rank": rank}], sessions[index].get_tick() + 1))

func _route_send(sender: int, data: Dictionary) -> void:
	var target: int = int(data.get("target", -1))
	if target < 0 or target >= sessions.size() or target == sender: return
	var payload: Dictionary = data.duplicate(true)
	payload["sender_name"] = names[sender]
	payload["sender_colour"] = ["d67965", "6f9fc0", "8fb36b", "c79b4d"][sender % 4]
	if StringName(payload.get("effect", "")) == &"volley_ball": _last_volley_sender[target] = sender
	sessions[target].queue_command(SimCommand.make(&"mg_receive_attack", [payload], sessions[target].get_tick() + 1))

func _broadcast_authority(data: Dictionary) -> void:
	for session: WtMinigameSession in sessions:
		session.queue_command(SimCommand.make(&"mg_authority", [data.duplicate(true)], session.get_tick() + 1))

## First claim per (kind, serial) wins; specific kinds keep the authority names rules_a/b expect.
func _resolve_shared(player: int, request: Dictionary) -> void:
	var kind: String = str(request.get("kind", ""))
	var data: Dictionary = request.get("data", {})
	var serial: int = int(data.get("serial", data.get("puzzle", 0)))
	var key: String = "%s:%d" % [kind, serial]
	match kind:
		"hot_start":
			if _awarded.has(key): return
			_awarded[key] = true
			_hot_serial += 1
			var first: int = _bot_rng.randi_range(0, sessions.size() - 1)
			_broadcast_authority({"kind": "hot_holder", "serial": _hot_serial, "next_owner": first})
		"hot_pass", "hot_explode":
			if serial != _hot_serial or _awarded.has(key): return
			_awarded[key] = true
			_hot_serial += 1
			var next_owner: int = _leader()
			if kind == "hot_pass" and next_owner == player:
				var ranked: Array[Dictionary] = _ranked()
				next_owner = int(ranked[1].player_id) if ranked.size() > 1 else player
			_broadcast_authority({"kind": "hot_holder" if kind == "hot_pass" else "hot_exploded", "serial": _hot_serial, "next_owner": next_owner})
		"shadow_solved":
			if _awarded.has(key): return
			_awarded[key] = true
			_broadcast_authority({"kind": "shadow_next", "puzzle": serial, "winner": player})
		"volley_point":
			if _awarded.has(key + ":%d" % player): return
			_awarded[key + ":%d" % player] = true
			_broadcast_authority({"kind": "volley_point", "winner": int(_last_volley_sender.get(player, -1)), "serial": serial, "amount": int(data.get("amount", 1))})
		_:
			if _awarded.has(key): return
			_awarded[key] = true
			var awarded: Dictionary = data.duplicate(true)
			awarded["kind"] = kind.trim_suffix("_claim") + "_awarded"
			awarded["winner"] = player
			awarded["leader"] = _leader()
			awarded["serial"] = serial
			_broadcast_authority(awarded)

## Practice bot: presses one of the template's controls with plausible arguments.
func _bot_act(index: int) -> void:
	var session: WtMinigameSession = sessions[index]
	if session.get_phase() == &"finished": return
	if bool(session.snapshot().get("send", {}).get("ready", false)) or session.get_phase() == &"ghost":
		queue(index, &"mg_send")
		return
	var controls: Array = template.get("controls", [])
	if controls.is_empty(): return
	var control: String = str(controls[_bot_rng.randi_range(0, controls.size() - 1)])
	var r: RandomNumberGenerator = _bot_rng
	var dirs3: Array[Vector3i] = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i(0, 0, -1), Vector3i(0, 0, 1)]
	var dirs2: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	match control:
		"send": queue(index, &"mg_send")
		"move", "tray_move", "mg_move": queue(index, &"mg_move", [dirs3[r.randi_range(0, 3)]])
		"rotate", "mg_rotate": queue(index, &"mg_rotate", [r.randi_range(0, 2), 1 if r.randi_range(0, 1) == 1 else -1])
		"hard_drop", "release": queue(index, &"mg_drop")
		"hold": queue(index, &"mg_hold")
		"sort": queue(index, &"mg_sort", [r.randi_range(0, 2)])
		"gift_choose": queue(index, &"mg_gift_choose", [r.randi_range(0, 1)])
		"mg_magnet_move": queue(index, &"mg_magnet_move", [dirs2[r.randi_range(0, 3)]])
		"mg_slide": queue(index, &"mg_slide", [dirs2[r.randi_range(0, 3)]])
		"mg_rhythm_hit": queue(index, &"mg_rhythm_hit", [r.randi_range(0, 3)])
		"mg_aim", "mg_spin", "mg_step": queue(index, StringName(control), [1 if r.randi_range(0, 1) == 1 else -1])
		"mg_pan": queue(index, &"mg_pan", ["left" if r.randi_range(0, 1) == 0 else "right"])
		"mg_pad", "mg_pick", "mg_answer", "mg_choose": queue(index, StringName(control), [r.randi_range(0, 3)])
		"mg_flip", "mg_whack": queue(index, StringName(control), [r.randi_range(0, 15 if control == "mg_flip" else 8)])
		"mg_pull": queue(index, &"mg_pull", [r.randi_range(0, 6), r.randi_range(0, 2)])
		_: queue(index, StringName(control))
