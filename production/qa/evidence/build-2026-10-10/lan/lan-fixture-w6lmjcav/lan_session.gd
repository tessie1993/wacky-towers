class_name WtLanSession extends Node
## Host-authoritative LAN tournament transport. Add under the same /root/Main/Lan
## path on every peer. Example: lan.host("Cloud", 7777, 5); lan.start_round(config).
## Every simulation advances only from frame_received; no local client prediction.

signal lobby_changed(snapshot: Dictionary)
signal round_started(config: Dictionary)
signal round_finished(data: Dictionary)
signal frame_received(tick: int, commands: Array)
signal paused_changed(value: bool)
signal disconnected(reason: String)

const PROTOCOL_VERSION: int = 1
const MAX_PLAYERS: int = 4
const MAX_NAME_LENGTH: int = 48
const MAX_CONFIG_BYTES: int = 131072
const MAX_COMMANDS_PER_PLAYER_FRAME: int = 16
const MAX_COMMANDS_PER_SECOND: int = 180
const SIMPLE_COMMANDS: Array[StringName] = [&"cmd_soft_drop_on", &"cmd_soft_drop_off", &"cmd_hard_drop", &"cmd_hold", &"cmd_tap", &"cmd_use_skill"]

var hosting: bool = false
var active: bool = false
var paused: bool = false
var rounds: int = 5
var port: int = 7777
var in_round: bool = false
var _peer: ENetMultiplayerPeer
var _player_name: String = "Player"
var _players: Dictionary = {}
var _pending: Array = []
var _per_frame: Dictionary = {}
var _rates: Dictionary = {}
var _tick: int = 0
var _last_received_tick: int = 0
var _current_config: Dictionary = {}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	set_multiplayer_authority(1)


func _exit_tree() -> void:
	leave()


## Opens a four-player UDP lobby. Example: lan.host("Lana", 7777, 5).
func host(player_name: String, game_port: int = 7777, round_count: int = 5) -> Error:
	if not _valid_port(game_port) or round_count < 1 or round_count > 20:
		return ERR_INVALID_PARAMETER
	leave()
	_peer = ENetMultiplayerPeer.new()
	var error: Error = _peer.create_server(game_port, MAX_PLAYERS - 1, 1)
	if error != OK:
		_peer = null
		return error
	multiplayer.multiplayer_peer = _peer
	hosting = true
	active = true
	port = game_port
	rounds = round_count
	_player_name = _clean_name(player_name)
	_players[1] = _player_name
	_publish_lobby()
	return OK


## Connects to the host's LAN address. Example: lan.join("192.168.1.5", "Glim", 7777).
func join(address: String, player_name: String, game_port: int = 7777) -> Error:
	if not _valid_port(game_port) or address.strip_edges().is_empty() or address.length() > 253:
		return ERR_INVALID_PARAMETER
	leave()
	_peer = ENetMultiplayerPeer.new()
	var error: Error = _peer.create_client(address.strip_edges(), game_port, 1)
	if error != OK:
		_peer = null
		return error
	_player_name = _clean_name(player_name)
	port = game_port
	active = true
	multiplayer.multiplayer_peer = _peer
	lobby_changed.emit(snapshot())
	return OK


## Closes the transport and clears all round/lobby state. Example: lan.leave().
func leave() -> void:
	var was_active: bool = active
	if _peer != null:
		_peer.close()
		_peer = null
	if is_inside_tree():
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	hosting = false
	active = false
	paused = false
	in_round = false
	_players.clear()
	_pending.clear()
	_per_frame.clear()
	_rates.clear()
	_current_config.clear()
	_tick = 0
	_last_received_tick = 0
	if was_active and is_inside_tree():
		lobby_changed.emit(snapshot())


## Returns whether this device owns the tournament. Example: if lan.is_host(): lan.broadcast_tick().
func is_host() -> bool:
	return active and hosting


## Returns the ENet identity, or zero while disconnected. Example: sims[lan.local_id()].
func local_id() -> int:
	return multiplayer.get_unique_id() if active and is_inside_tree() else 0


## Returns a stable, sorted lobby representation. Example: ui.show_lobby(lan.snapshot()).
func snapshot() -> Dictionary:
	var players: Array = []
	var identities: Array = _players.keys()
	identities.sort()
	for identity: int in identities:
		players.append({"id": identity, "name": String(_players[identity])})
	return {"version": PROTOCOL_VERSION, "hosting": hosting, "host": hosting,
		"active": active, "connected": active and not _players.is_empty(), "players": players,
		"rounds": rounds, "port": port, "local_peer_id": local_id(), "in_round": in_round, "paused": paused}


## Host broadcasts the immutable round seed and level. Example: lan.start_round({"seed": 42, "raw_level": raw}).
func start_round(config: Dictionary) -> Error:
	if not is_host() or _players.size() < 2:
		return ERR_UNAVAILABLE
	if not config.get("seed") is int or var_to_bytes(config).size() > MAX_CONFIG_BYTES:
		return ERR_INVALID_PARAMETER
	var authoritative: Dictionary = config.duplicate(true)
	authoritative["version"] = PROTOCOL_VERSION
	authoritative["players"] = snapshot()["players"]
	authoritative["rounds"] = rounds
	_round.rpc(authoritative)
	return OK


## Host broadcasts final standings/results. Example: lan.finish_round({"winner": 1}).
func finish_round(data: Dictionary) -> Error:
	if not is_host() or not in_round:
		return ERR_UNAVAILABLE
	if var_to_bytes(data).size() > MAX_CONFIG_BYTES:
		return ERR_INVALID_PARAMETER
	_finish.rpc(PROTOCOL_VERSION, data)
	return OK


## Requests a command for this device's board; the host determines the board identity.
## Example: lan.submit(&"cmd_move", [Vector3i.LEFT]).
func submit(kind: StringName, args: Array = []) -> void:
	if not active or not in_round or paused or not _valid_command(kind, args):
		return
	if hosting:
		_enqueue(1, kind, args)
	elif _peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		_request_input.rpc_id(1, PROTOCOL_VERSION, kind, args)


## Host drains inputs and broadcasts one tick; call exactly at the simulation's 60 Hz.
## Example: lan.broadcast_tick() from the host's physics process.
func broadcast_tick() -> void:
	if not is_host() or not in_round or paused:
		return
	_tick += 1
	var commands: Array = _pending.duplicate(true)
	_pending.clear()
	_per_frame.clear()
	_frame.rpc(PROTOCOL_VERSION, _tick, commands)


## Any admitted player requests a shared pause; the host broadcasts the decision.
## Example: lan.set_paused(true).
func set_paused(value: bool) -> void:
	if not active or not in_round:
		return
	if hosting:
		_pause.rpc(PROTOCOL_VERSION, value)
	elif _players.has(local_id()) and _peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		_request_pause.rpc_id(1, PROTOCOL_VERSION, value)


@rpc("any_peer", "call_remote", "reliable", 0)
func _request_pause(version: int, value: bool) -> void:
	if not is_host() or not in_round or version != PROTOCOL_VERSION:
		return
	var sender: int = multiplayer.get_remote_sender_id()
	if sender > 1 and _players.has(sender):
		_pause.rpc(PROTOCOL_VERSION, value)


@rpc("any_peer", "call_remote", "reliable", 0)
func _register(version: int, player_name: String) -> void:
	if not is_host():
		return
	var sender: int = multiplayer.get_remote_sender_id()
	if sender <= 1:
		return
	if version != PROTOCOL_VERSION or in_round or player_name.length() > MAX_NAME_LENGTH:
		_reject.rpc_id(sender, "This lobby uses different game data or has already started.")
		return
	_players[sender] = _clean_name(player_name)
	_publish_lobby()


@rpc("authority", "call_local", "reliable", 0)
func _lobby(data: Dictionary) -> void:
	if int(data.get("version", -1)) != PROTOCOL_VERSION:
		return
	_players.clear()
	for player: Dictionary in data.get("players", []):
		_players[int(player["id"])] = String(player["name"])
	rounds = int(data.get("rounds", rounds))
	lobby_changed.emit(snapshot())


@rpc("authority", "call_local", "reliable", 0)
func _round(config: Dictionary) -> void:
	if int(config.get("version", -1)) != PROTOCOL_VERSION:
		return
	_current_config = config.duplicate(true)
	in_round = true
	paused = false
	_tick = 0
	_last_received_tick = 0
	_pending.clear()
	_per_frame.clear()
	_rates.clear()
	round_started.emit(_current_config.duplicate(true))


@rpc("any_peer", "call_remote", "reliable", 0)
func _request_input(version: int, kind: StringName, args: Array) -> void:
	if not is_host() or not in_round or paused or version != PROTOCOL_VERSION:
		return
	var sender: int = multiplayer.get_remote_sender_id()
	if sender <= 1 or not _players.has(sender) or not _valid_command(kind, args):
		return
	_enqueue(sender, kind, args)


@rpc("authority", "call_local", "reliable", 0)
func _frame(version: int, tick: int, commands: Array) -> void:
	if version != PROTOCOL_VERSION or not in_round or tick != _last_received_tick + 1:
		return
	_last_received_tick = tick
	frame_received.emit(tick, commands)


@rpc("authority", "call_local", "reliable", 0)
func _pause(version: int, value: bool) -> void:
	if version != PROTOCOL_VERSION or paused == value:
		return
	paused = value
	_pending.clear()
	_per_frame.clear()
	paused_changed.emit(value)


@rpc("authority", "call_local", "reliable", 0)
func _finish(version: int, data: Dictionary) -> void:
	if version != PROTOCOL_VERSION:
		return
	in_round = false
	paused = false
	_pending.clear()
	_per_frame.clear()
	round_finished.emit(data.duplicate(true))


@rpc("authority", "call_remote", "reliable", 0)
func _reject(reason: String) -> void:
	leave()
	disconnected.emit(reason)


func _enqueue(identity: int, kind: StringName, args: Array) -> void:
	if int(_per_frame.get(identity, 0)) >= MAX_COMMANDS_PER_PLAYER_FRAME:
		return
	var now: int = Time.get_ticks_msec()
	var rate: Dictionary = _rates.get(identity, {"start": now, "count": 0})
	if now - int(rate["start"]) >= 1000:
		rate = {"start": now, "count": 0}
	if int(rate["count"]) >= MAX_COMMANDS_PER_SECOND:
		return
	rate["count"] = int(rate["count"]) + 1
	_rates[identity] = rate
	_per_frame[identity] = int(_per_frame.get(identity, 0)) + 1
	_pending.append({"peer_id": identity, "kind": String(kind), "args": args.duplicate(true)})


func _valid_command(kind: StringName, args: Array) -> bool:
	if kind in SIMPLE_COMMANDS:
		return args.is_empty()
	if kind == &"cmd_move":
		if args.size() != 1 or not args[0] is Vector3i:
			return false
		var direction: Vector3i = args[0]
		return absi(direction.x) + absi(direction.y) + absi(direction.z) == 1
	if kind == &"cmd_rotate":
		return args.size() == 2 and args[0] is int and args[1] is int and int(args[0]) in [0, 1, 2] and int(args[1]) in [-1, 1]
	if kind == &"cmd_use_item":
		return args.size() == 1 and (args[0] is String or args[0] is StringName) and String(args[0]).length() <= 64
	return false


func _publish_lobby() -> void:
	if is_host():
		_lobby.rpc(snapshot())


func _on_peer_connected(_identity: int) -> void:
	pass # Registration arrives reliably after the client's connected_to_server signal.


func _on_connected() -> void:
	_register.rpc_id(1, PROTOCOL_VERSION, _player_name)


func _on_peer_disconnected(identity: int) -> void:
	if not is_host():
		return
	_players.erase(identity)
	_rates.erase(identity)
	if in_round:
		set_paused(true)
		_finish.rpc(PROTOCOL_VERSION, {"aborted": true, "reason": "A player disconnected; return to the lobby to start another round."})
	_publish_lobby()


func _on_connection_failed() -> void:
	leave()
	disconnected.emit("Could not connect. Check the host address, port, and Wi-Fi network.")


func _on_server_disconnected() -> void:
	leave()
	disconnected.emit("The host disconnected. Host or join a new lobby to continue.")


func _valid_port(value: int) -> bool:
	return value >= 1024 and value <= 65535


func _clean_name(value: String) -> String:
	var cleaned: String = value.strip_edges().replace("\n", " ").replace("\r", " ").substr(0, MAX_NAME_LENGTH)
	return cleaned if not cleaned.is_empty() else "Player"
