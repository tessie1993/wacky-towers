extends SceneTree
## Runs the actual Main scene and routes real UI/gameplay intents over ENet.
## tools/qa/verify_main_lan.py compares every board's hashes across four processes.

const MainScene = preload("res://src/app/main.tscn")
const FinishAck = preload("res://tools/probes/lan_finish_ack.gd")
const TARGET_TICK: int = 540
var main: Node
var lan: WtLanSession
var role: String = ""
var requested_character: String = "c1"
var requested_perk: String = "breeze_brake"
var frame_count: int = 0
var rounds_started: int = 0
var elapsed: float = 0.0
var finished: bool = false
var failed: bool = false
var config_seen: Dictionary = {}
var checkpoints: Array = []
var command_counts: Dictionary = {}
var orientations: Dictionary = {}
var output_path: String = ""
var finish_ack: Node
var acknowledged: Dictionary = {}


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	role = _argument(args, "--role", "Host")
	output_path = _argument(args, "--output", "")
	requested_character = {"Host": "c1", "ClientA": "c2", "ClientB": "c3", "ClientC": "c4"}.get(role, "c1")
	requested_perk = {"Host": "breeze_brake", "ClientA": "gentle_landing", "ClientB": "solid_footing", "ClientC": "long_look"}.get(role, "breeze_brake")
	main = MainScene.instantiate()
	root.add_child(main)
	# A fresh real profile store uses isolated in-memory persistence; networking,
	# scene composition, input routing, abilities, and simulations remain real.
	var store: WtProfileStore = WtProfileStore.new(MemorySaveIO.new())
	if store.create(role) < 0 or not store.set_setting("character", requested_character):
		_fail("Could not create the isolated QA profile")
		return
	# Exercise the real owned-perk path. Tournament history unlocks party shop
	# rows, and real purchases plus equip validation build the handshake claim.
	for i: int in 15: store.record_tournament(false, 10)
	if not store.purchase(requested_perk).get("ok", false) or not store.equip_perks(requested_character, [requested_perk], "tournament"):
		_fail("Could not purchase/equip the isolated QA tournament perk")
		return
	main.set("_store", store)
	lan = main.get("_lan") as WtLanSession
	finish_ack = FinishAck.new()
	finish_ack.name = "QaFinishAck"
	main.add_child(finish_ack)
	finish_ack.completed.connect(func(identity: int) -> void: acknowledged[identity] = true)
	lan.lobby_changed.connect(_on_lobby)
	lan.round_started.connect(_on_round)
	lan.frame_received.connect(_on_frame)
	lan.round_finished.connect(_on_finish)
	lan.disconnected.connect(func(reason: String) -> void:
		if not finished:
			_fail("Unexpected Main disconnect: " + reason))
	var port: int = int(_argument(args, "--port", "24680"))
	if args.has("--host"):
		main.call("_on_intent", &"host_lan", {"name": role, "port": port, "rounds": 3})
	else:
		main.call("_on_intent", &"join_lan", {"address": _argument(args, "--join", "127.0.0.1"), "name": role, "port": port})
	if not lan.active:
		_fail("Main host/join intent did not open a network session")


func _process(delta: float) -> bool:
	if failed: return false
	elapsed += delta
	if elapsed > 80.0 and not finished:
		_fail("Main LAN timed out; frames=" + str(frame_count))
	return false


func _on_lobby(snapshot: Dictionary) -> void:
	if role == "Host" and rounds_started == 0 and snapshot.get("players", []).size() == 4:
		main.call("_on_intent", &"start_lan", {})


func _on_round(config: Dictionary) -> void:
	rounds_started += 1
	config_seen = config.duplicate(true)
	if rounds_started != 1 or config.get("players", []).size() != 4 or not config.get("seed") is int:
		_fail("Invalid integrated round configuration")
		return
	var ids: Array = []
	var names: Array = []
	for player: Dictionary in config.get("players", []):
		if int(player.id) <= 0 or int(player.id) in ids:
			_fail("Duplicate or invalid authoritative player identity")
			return
		ids.append(int(player.id))
		names.append(String(player.name))
		var expected_char: String = {"Host":"c1", "ClientA":"c2", "ClientB":"c3", "ClientC":"c4"}.get(String(player.name), "")
		var expected_perk: String = {"Host":"breeze_brake", "ClientA":"gentle_landing", "ClientB":"solid_footing", "ClientC":"long_look"}.get(String(player.name), "")
		if player.get("character") != expected_char or player.get("perks") != [expected_perk] or player.get("loadout", {}) != config.get("loadouts", {}).get(int(player.id), {}):
			_fail("A character or equipped perk was lost in the authoritative round config")
			return
	for expected: String in ["Host", "ClientA", "ClientB", "ClientC"]:
		if expected not in names:
			_fail("Missing real player: " + expected)
			return
	var simulations: Dictionary = main.get("_network_sims")
	if simulations.size() != 4 or String(main.get("_mode")) != "lan":
		var parsed: LoadResult = LevelLoader.parse_level(config.get("raw_level", {}), main.get("_catalog"))
		for issue: ValidationIssue in parsed.issues:
			print("MAIN_LAN_LEVEL_ISSUE ", issue)
		_fail("Main did not instantiate one authoritative BoardSim for each player")
		return
	for identity: int in ids:
		if not simulations.has(identity):
			_fail("Main omitted a player's simulation")
			return
		var controller: WtAbilities = simulations[identity].get("_abilities") as WtAbilities
		if controller == null or controller.snapshot().character != config.loadouts[identity].ability_character:
			_fail("A player's BoardSim received another character's ability controller")
			return
	print("MAIN_LAN_CONFIG ", JSON.stringify({"role": role, "seed": config.seed, "players": config.players, "rounds": config.rounds, "tournament_mode": config.tournament.mode, "requested_character": requested_character}))


func _on_frame(tick: int, commands: Array) -> void:
	if failed or finished: return
	if tick != frame_count + 1:
		_fail("Main missed or duplicated a delivered frame")
		return
	frame_count = tick
	if tick % 60 == 0: print("MAIN_LAN_PROGRESS ", role, " tick=", tick, " elapsed=", elapsed)
	for command: Dictionary in commands:
		var key: String = str(command.peer_id) + ":" + String(command.kind)
		command_counts[key] = int(command_counts.get(key, 0)) + 1
	# Move after the initial countdown, then exercise all three rotation pairs.
	# ClientA also rotates the view, proving its camera-relative input becomes an
	# authoritative board-space command instead of changing another replica's view.
	if tick == 220 and role == "ClientA": main.call("_on_intent", &"view", {"direction": 1})
	if tick == 230: main.call("_on_intent", &"move", {"screen": Vector2i(1, 0)})
	if tick == 235: main.call("_on_intent", &"rotate", {"axis": "spin", "direction": 1})
	if tick == 237: main.call("_on_intent", &"rotate", {"axis": "tilt", "direction": 1})
	if tick == 239: main.call("_on_intent", &"rotate", {"axis": "roll", "direction": -1})
	# Remote input is admitted at its actual arrival tick. Observe each real
	# active piece after rotation rather than assuming every packet arrived by255.
	for identity: int in main.get("_network_sims"):
		var simulation: BoardSim = main.get("_network_sims")[identity]
		var piece: ActivePiece = simulation.get_piece()
		if piece != null and piece.orient > 0:
			orientations[str(identity)] = piece.orient
	if tick == 260: main.call("_on_intent", &"drop", {})
	if tick == 420: main.call("_on_intent", &"use_skill", {})
	if tick % 30 == 0:
		checkpoints.append({"tick": tick, "hashes": _hashes()})
	if role == "Host" and tick == TARGET_TICK:
		lan.finish_round({"qa_finished": true, "frames": tick, "tournament": main.get("_network_state"), "hashes": _hashes()})


func _on_finish(data: Dictionary) -> void:
	if failed or finished: return
	if not data.get("qa_finished", false) or frame_count != TARGET_TICK:
		_fail("The integrated round ended before its QA checkpoint")
		return
	finished = true
	var simulations: Dictionary = main.get("_network_sims")
	for identity: int in simulations:
		var prefix: String = str(identity) + ":"
		if int(command_counts.get(prefix + "cmd_move", 0)) != 1 or int(command_counts.get(prefix + "cmd_rotate", 0)) != 3 or int(command_counts.get(prefix + "cmd_hard_drop", 0)) != 1 or int(command_counts.get(prefix + "cmd_use_skill", 0)) != 1:
			_fail("Missing real gameplay commands for player " + str(identity))
		var simulation: BoardSim = simulations[identity]
		if simulation.goal_state().locks < 1:
			_fail("The actual hard-drop intent did not lock a piece")
		if int(orientations.get(str(identity), -1)) <= 0:
			_fail("The actual rotation inputs did not turn the active piece")
	var hashes: Dictionary = _hashes()
	var distinct: Array = []
	for value: Variant in hashes.values():
		if value not in distinct: distinct.append(value)
	if distinct.size() != 4:
		_fail("Four different characters/perks unexpectedly produced identical player states")
	if hashes != data.get("hashes", {}):
		_fail("Main's board hashes differ from the host at the same authoritative tick")
	if failed: return
	var report: Dictionary = {"role": role, "frames": frame_count, "seed": config_seen.seed, "players": config_seen.players, "mode": config_seen.tournament.mode, "requested_character": requested_character,
		"effective_character": String(main.get("_abilities").get("_character")), "requested_perk":requested_perk,
		"loadouts":config_seen.loadouts, "hashes": hashes, "checkpoints": checkpoints, "orientations": orientations, "commands": command_counts}
	if not output_path.is_empty():
		var file: FileAccess = FileAccess.open(output_path, FileAccess.WRITE)
		if file == null:
			_fail("Could not save integrated evidence")
			return
		file.store_string(JSON.stringify(report, "\t") + "\n")
		file.close()
	if not failed:
		print("MAIN_LAN_PASS ", JSON.stringify({"role": role, "frames": frame_count, "hashes": hashes, "effective_character": report.effective_character}))
	# Reliable transport delivery still needs the host alive. The test's own
	# admitted-peer acknowledgement prevents process teardown dropping final RPCs.
	if role == "Host":
		var deadline: int = Time.get_ticks_msec() + 30000
		while acknowledged.size() < 3 and Time.get_ticks_msec() < deadline:
			await create_timer(0.02).timeout
		if acknowledged.size() != 3:
			_fail("Clients did not acknowledge the final authoritative snapshot")
	else:
		finish_ack.complete.rpc_id(1)
		await create_timer(0.5).timeout
	lan.leave()
	quit(1 if failed else 0)


func _hashes() -> Dictionary:
	var hashes: Dictionary = {}
	var simulations: Dictionary = main.get("_network_sims")
	var ids: Array = simulations.keys()
	ids.sort()
	for identity: int in ids:
		hashes[str(identity)] = simulations[identity].state_hash()
	return hashes


func _argument(args: PackedStringArray, key: String, fallback: String) -> String:
	var index: int = args.find(key)
	return args[index + 1] if index >= 0 and index + 1 < args.size() else fallback


func _fail(reason: String) -> void:
	if failed: return
	failed = true
	push_error("MAIN_LAN_FAIL " + role + ": " + reason)
	quit(1)
