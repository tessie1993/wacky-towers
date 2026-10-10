extends SceneTree
## Real ENet probe used by tools/qa/verify_lan.py in an isolated temporary project.
## Four independent Godot processes exchange reliable lobby/round/frame/pause RPCs.

const LanScript = preload("res://src/net/lan_session.gd")
var lan: Node
var role: String = ""
var scenario: String = "normal"
var start_time_ms: int = 0
var frame_count: int = 0
var stream_hash: int = 0
var commands_seen: Array = []
var pauses_seen: Array = []
var started: bool = false
var paused_at: int = 0
var elapsed: float = 0.0
var finished: bool = false
var remote_pause_requested: bool = false
var remote_resume_scheduled: bool = false
var requested_character: String = "c1"
var requested_perks: Array = []


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	role = args[0]
	requested_character = {"host": "c1", "ClientA": "c2", "ClientB": "c3", "ClientC": "c4"}.get(role, "c1")
	requested_perks = {"host": ["breeze_brake"], "ClientA": ["gentle_landing"], "ClientB": ["solid_footing"], "ClientC": ["long_look"]}.get(role, [])
	scenario = args[2] if args.size() > 2 else "normal"
	start_time_ms = Time.get_ticks_msec()
	var main: Node = Node.new()
	main.name = "Main"
	root.add_child(main)
	lan = LanScript.new()
	lan.name = "Lan"
	main.add_child(lan)
	lan.lobby_changed.connect(_lobby_changed)
	lan.round_started.connect(_round_started)
	lan.frame_received.connect(_frame)
	lan.paused_changed.connect(_on_paused)
	lan.round_finished.connect(_finished)
	lan.disconnected.connect(func(reason: String) -> void:
		if not finished:
			_fail("Unexpected disconnect: " + reason))
	var error: Error
	# Supplied effects/edge are deliberately forged. The authority must rebuild
	# canonical effects from the shipped catalog before any peer receives them.
	var loadout: Dictionary = {"character": requested_character, "perks": requested_perks,
		"owned_perks": requested_perks, "effects": {"gravity_scale": 0.001}, "edge_milli": -1000}
	if role == "host":
		error = lan.host("Host", int(args[1]), 5, loadout)
	else:
		error = lan.join("127.0.0.1", role, int(args[1]), loadout)
	if error != OK:
		_fail("ENet open failed: " + str(error))


func _process(delta: float) -> bool:
	elapsed += delta
	if elapsed > 12.0 and not finished:
		_fail("Timed out waiting for a real ENet exchange")
	if role == "host" and started and not finished:
		if scenario == "normal" and frame_count == 45 and paused_at == 0:
			lan.set_paused(true)
			paused_at = Time.get_ticks_msec()
		if paused_at > 0 and lan.paused:
			lan.broadcast_tick()
			if frame_count != 45:
				_fail("Paused simulation advanced")
			if Time.get_ticks_msec() - paused_at >= 300:
				lan.set_paused(false)
		else:
			lan.broadcast_tick()
		if scenario == "normal" and frame_count >= 100:
			var ids: Array = []
			for command: Dictionary in commands_seen:
				if command["peer_id"] not in ids:
					ids.append(command["peer_id"])
			if ids.size() != 4 or commands_seen.size() != 4:
				_fail("Inputs missing or invalid oversized inputs accepted: " + str(commands_seen))
			lan.finish_round({"frames": frame_count, "stream_hash": stream_hash, "commands": commands_seen})
	return false


func _lobby_changed(data: Dictionary) -> void:
	if role != "host" or started or data["players"].size() != 4:
		return
	var names: Array = []
	for player: Dictionary in data["players"]:
		names.append(player["name"])
		if not player.get("loadout") is Dictionary or player.loadout.edge_milli <= 0:
			_fail("Canonical loadout missing from lobby")
	for required: String in ["Host", "ClientA", "ClientB", "ClientC"]:
		if required not in names:
			_fail("Player registration missing: " + required)
	var error: Error = lan.start_round({"seed": 81723, "level": "meadow_01"})
	if error != OK:
		_fail("Round could not start")


func _round_started(config: Dictionary) -> void:
	if config["seed"] != 81723 or config["players"].size() != 4 or config["rounds"] != 5:
		_fail("Round configuration differs")
	var expected: Dictionary = {"Host": ["c1", "breeze_brake", {"gravity_scale": 0.92}],
		"ClientA": ["c2", "gentle_landing", {"drop_grace_scale": 1.5}],
		"ClientB": ["c3", "solid_footing", {"lock_resets_add": 3.0}],
		"ClientC": ["c4", "long_look", {"preview_add": 1.0}]}
	for player: Dictionary in config.players:
		var required: Array = expected[player.name]
		var canonical: Dictionary = config.loadouts[int(player.id)]
		if player.character != required[0] or player.perks != [required[1]] or canonical.effects != required[2] or canonical != player.loadout:
			_fail("Host did not canonicalize character/perk data: " + str(player))
	var local: Dictionary = lan.player_loadout()
	if local.character != requested_character or local.perks != requested_perks:
		_fail("Local identity resolved another player's loadout")
	local.effects["gravity_scale"] = -9000
	if lan.player_loadout().effects.get("gravity_scale", 1.0) == -9000:
		_fail("Public loadout accessor exposed mutable shared state")
	started = true
	if role == "host":
		lan.submit(&"cmd_hard_drop", [])
	else:
		lan.submit(&"cmd_move", [Vector3i.LEFT])
		# Bypass the public validator to prove the host rejects a malformed remote payload.
		lan.rpc_id(1, "_request_input", LanScript.PROTOCOL_VERSION, &"cmd_move", [Vector3i(999, 0, 0)])
		lan.rpc_id(1, "_request_input", LanScript.PROTOCOL_VERSION, &"cmd_move", [Vector3i.LEFT, 1])


func _frame(tick: int, commands: Array) -> void:
	if tick != frame_count + 1:
		_fail("Missing or duplicate frame")
	frame_count = tick
	stream_hash = int((stream_hash * 31 + hash(var_to_bytes([tick, commands]))) & 0x7fffffff)
	for command: Dictionary in commands:
		if command["peer_id"] <= 0 or command["kind"] not in ["cmd_move", "cmd_hard_drop"]:
			_fail("Unverified board identity or command")
		commands_seen.append(command)
	if scenario == "normal" and role == "ClientA" and tick == 25 and not remote_pause_requested:
		remote_pause_requested = true
		lan.set_paused(true)
	if scenario == "disconnect" and role == "ClientC" and tick == 45:
		finished = true
		lan.leave()
		print("LAN_PROBE_PASS ", JSON.stringify({"role": role, "scenario": scenario, "frames": frame_count, "left_round": true}))
		quit(0)


func _finished(data: Dictionary) -> void:
	finished = true
	if scenario == "disconnect":
		if not data.get("aborted", false) or frame_count < 45 or pauses_seen != [true] or lan.in_round:
			_fail("A departing peer did not abort the active round on every remaining device")
		print("LAN_PROBE_PASS ", JSON.stringify({"role": role, "scenario": scenario, "frames": frame_count, "aborted": true}))
		await create_timer(0.25).timeout
		lan.leave()
		quit(0)
		return
	if frame_count != data["frames"] or stream_hash != data["stream_hash"] or pauses_seen != [true, false, true, false]:
		_fail("Frame stream or pause differs from host")
	if commands_seen.size() != 4 or lan.in_round:
		_fail("Wrong command count or round not ended")
	var peer: ENetMultiplayerPeer = lan.get("_peer") as ENetMultiplayerPeer
	var sent_bytes: int = int(peer.host.pop_statistic(ENetConnection.HOST_TOTAL_SENT_DATA))
	var received_bytes: int = int(peer.host.pop_statistic(ENetConnection.HOST_TOTAL_RECEIVED_DATA))
	print("LAN_PROBE_PASS ", JSON.stringify({"role": role, "frames": frame_count, "stream_hash": stream_hash, "commands": commands_seen.size(), "paused": pauses_seen, "elapsed_ms": Time.get_ticks_msec() - start_time_ms, "sent_bytes": sent_bytes, "received_bytes": received_bytes}))
	await create_timer(0.25).timeout
	lan.leave()
	quit(0)


func _on_paused(value: bool) -> void:
	pauses_seen.append(value)
	if scenario == "normal" and role == "ClientA" and value and not remote_resume_scheduled:
		remote_resume_scheduled = true
		await create_timer(0.15).timeout
		lan.set_paused(false)


func _fail(reason: String) -> void:
	push_error("LAN_PROBE_FAIL " + role + ": " + reason)
	quit(1)
