extends Node3D
## Application composition root. Owns navigation, fixed-tick sessions and save transactions.
## BoardSim owns gameplay; GameUi and WtStage receive snapshots and events.
const DEFAULT_LEVEL: StringName = &"meadow_01"
const PREVIEW_COUNT: int = 3
const PRACTICE_TIME_CAP_MS: int = 240000
var _content: WtContent
var _store: WtProfileStore
var _modes: WtModes
var _catalog: GameCatalog
var _ui: GameUi
var _stage: WtStage
var _sim: BoardSim
var _level: LevelData
var _input: WtPlayerInput = WtPlayerInput.new()
var _mode: StringName = &"campaign"
var _paused: bool = true
var _return_screen: String = "title"
var _selected_biome: StringName = &"meadow"
var _level_id: StringName = DEFAULT_LEVEL
var _result_shown: bool = false
var _bots: Array[WtBotPlayer] = []
var _rivals: Array[BoardSim] = []
var _abilities: WtAbilities
var _tick_counter: int = 0
var _smoke: bool = false
var _lan: WtLanSession
var _network_sims: Dictionary = {}
var _network_state: Dictionary = {}
var _official_stage: LevelStage
var _pending_item: String = ""
var _warning: String = ""
var _hint: String = ""
var _wobble: Dictionary = {}
var _preview_level: bool = false
var _story_phase: String = ""
var _pending_results: Dictionary = {}
var _architecture: WtArchitecture
var _physics: WtPhysicsChallenge
var _physics_variant: String = "tower_race"
var _practice_loadouts: Array[Dictionary] = []
var _selected_item_slot: int = 0
var _arcade: WtArcadeDirector

func _ready() -> void:
	WtPlayerInput.install_actions()
	_content = WtContent.new()
	_catalog = _content.load_catalog()
	_store = WtProfileStore.new()
	_modes = WtModes.new(_content)
	_architecture = WtArchitecture.new()
	_architecture.name = "Architecture"
	add_child(_architecture)
	_architecture.setup(self)
	_ui = GameUi.new()
	add_child(_ui)
	_ui.intent.connect(_on_intent)
	_lan = WtLanSession.new()
	_lan.name = "Lan"
	add_child(_lan)
	_lan.lobby_changed.connect(_show_lobby)
	_lan.round_started.connect(_on_network_round)
	_lan.frame_received.connect(_on_network_frame)
	_lan.round_finished.connect(_on_network_finished)
	_lan.paused_changed.connect(_on_network_pause)
	_lan.disconnected.connect(_on_network_disconnect)
	_apply_preferences()
	_input.setup(get_tree(),_settings())
	_smoke = OS.get_cmdline_user_args().has("--smoke-game")
	if _smoke:
		if _store.active_profile() == null: _store.create("QA Builder")
		_start_level(DEFAULT_LEVEL)
	else:
		_show_title()
	get_tree().auto_accept_quit = false

func _physics_process(_delta: float) -> void:
	if _paused or _sim == null: return
	_tick_counter += 1
	for action: Dictionary in _input.poll(BoardSim.ms_at(_tick_counter)):
		_on_intent(action.id, action)
	if _smoke and _tick_counter % 60 == 0:
		_sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
	if _mode == &"lan":
		if _lan.is_host(): _lan.broadcast_tick()
		return
	var events: Array[SimEvent] = _sim.step()
	if _arcade != null:
		var changes: Dictionary = _arcade.update(_sim)
		if changes.has("warning"): _warning = String(changes.warning)
	_route_events(events)
	_stage.sync(events)
	for i: int in _rivals.size():
		_bots[i].update(_rivals[i])
		_rivals[i].step()
	_refresh_hud()
	if not _result_shown:
		if _mode == &"tournament":
			_check_round()
		elif _sim.get_phase() == BoardSim.Phase.ENDED:
			_finish_level()
	if _smoke and _tick_counter >= 900:
		print("WT_SMOKE: ticks=", _sim.get_tick(), " phase=", _sim.get_phase(), " locks=", _sim.goal_state().locks)
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if _physics != null: return
	if event.is_action_pressed(&"wt_pause"):
		if _sim != null and not _result_shown:
			_on_intent(&"resume" if _paused and _ui.current_screen == "pause" else &"pause", {})
		else: _on_intent(&"back", {})
		get_viewport().set_input_as_handled()
		return
	if _paused or _sim == null: return
	if event is InputEventKey and event.echo: return
	var actions: Dictionary = {&"wt_hard_drop": &"drop", &"wt_restart": &"retry", &"wt_hold": &"hold",
		&"wt_skill": &"use_skill", &"wt_item": &"use_item"}
	for action: StringName in actions:
		if event.is_action_pressed(action):
			_on_intent(actions[action], {})
			get_viewport().set_input_as_handled()
			return
	for pair: Array in [[&"wt_rot_h_left", &"spin", -1], [&"wt_rot_h_right", &"spin", 1],
		[&"wt_rot_v_left", &"tilt", -1], [&"wt_rot_v_right", &"tilt", 1],
		[&"wt_rot_roll_left", &"roll", -1], [&"wt_rot_roll_right", &"roll", 1]]:
		if event.is_action_pressed(pair[0]):
			_on_intent(&"rotate", {"axis": pair[1], "direction": pair[2]})
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed(&"wt_view_left"): _on_intent(&"view", {"direction": -1})
	if event.is_action_pressed(&"wt_view_right"): _on_intent(&"view", {"direction": 1})

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if _sim != null and not _paused: _pause()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _ui != null: _ui.confirm_quit()

func _exit_tree() -> void:
	_input.dispose()

func _on_intent(id: StringName, args: Dictionary) -> void:
	_architecture.dispatch(id, args)

func _execute_intent(id: StringName, args: Dictionary) -> void:
	match id:
		&"play", &"continue", &"open_map":
			if _store.active_profile() == null: _show_profiles()
			else: _show_map()
		&"open_profiles": _show_profiles()
		&"create_profile":
			var slot: int = _store.create(String(args.get("name", "Builder")), String(args.get("color", "sky")), String(args.get("badge", "cloud")))
			if slot >= 0: _show_map()
			else: _ui.show_toast(tr("Choose a unique name (1–12 letters), or use an existing profile."))
		&"select_profile":
			if _store.select(int(args.get("slot", 0))): _show_map()
		&"rename_profile":
			if _store.has_method("rename"): _store.call("rename", int(args.get("slot", 0)), String(args.get("name", "")))
			_show_profiles()
		&"delete_profile":
			if _store.has_method("delete"): _store.call("delete", int(args.get("slot", 0)))
			_show_profiles()
		&"select_biome":
			_selected_biome = StringName(args.get("biome_id", "meadow"))
			_show_map()
		&"open_level": _show_intro(StringName(args.get("level_id", DEFAULT_LEVEL)))
		&"start_level": _start_level(StringName(args.get("level_id", _level_id)))
		&"story_done":
			if String(args.get("story_key", "")) != String(_level_id) + "_" + _story_phase: return
			if _story_phase == "pre" and _sim != null:
				_story_phase = ""
				_paused = false
				_store.set_playing(true)
				_input.reset()
				_architecture.lifecycle(&"session_countdown" if _sim.get_phase() == BoardSim.Phase.COUNTDOWN else &"session_begin")
				_ui.show_hud(_hud_snapshot())
				_stage.set_board_area(_ui.board_area())
			elif _story_phase == "post":
				_story_phase = ""
				_ui.show_results(_pending_results)
		&"open_tools": _show_tools()
		&"pick_shape", &"choose_down", &"flick", &"undo", &"reset":
			_puzzle_intent(id, args)
		&"pause":
			if _mode == &"lan": _lan.set_paused(true)
			else: _pause()
		&"resume":
			if _mode == &"lan":
				_lan.set_paused(false)
				return
			if _sim != null and not _result_shown:
				_paused = false
				_architecture.lifecycle(&"session_resume")
				_store.set_playing(true)
				_input.reset()
				_ui.show_hud(_hud_snapshot())
		&"retry":
			if _mode == &"campaign": _start_level(_level_id)
			elif _mode == &"arcade": _start_arcade(_selected_biome)
			else: _start_round()
		&"next":
			if _mode == &"lan": _start_lan_round()
			elif _mode == &"tournament": _start_round()
			else:
				var next_id: StringName = _next_level()
				if next_id != &"": _show_intro(next_id)
				else: _show_map()
		&"to_map":
			if _lan.active: _lan.leave()
			_network_state.clear()
			_show_map()
		&"open_settings":
			if _mode == &"lan" and _lan.in_round: _lan.set_paused(true)
			_return_screen = _ui.current_screen
			_paused = true
			_store.set_playing(false)
			_ui.show_settings({"prefs": _ui_settings(), "in_play": _sim != null})
		&"set_pref":
			_save_preference(String(args.get("key", "")), args.get("value"))
			if _stage != null: _stage.apply_settings(_settings())
		&"open_shop": _show_shop()
		&"buy_item":
			var purchase: Dictionary = _store.purchase(StringName(args.get("item_id", "")))
			_show_shop()
			_ui.show_toast(tr("Added to your loadout!") if purchase.get("ok", false) else String(purchase.get("error", "Not enough points.")))
		&"select_character":
			var character: String = String(args.get("character_id", "c1"))
			if _store.characters().has(character):
				_store.set_setting("character", character)
				_store.equip_perks(character, [])
			_show_shop()
		&"toggle_perk":
			var ids: Array = _store.get_setting("equipped_perks", []).duplicate()
			var item: String = String(args.get("item_id", ""))
			if ids.has(item): ids.erase(item)
			else: ids.append(item)
			if not _store.equip_perks(String(_store.get_setting("character", "c1")), ids): _ui.show_toast("Choose up to two owned perks for this character, within the 15% cap.")
			_show_shop()
		&"select_item_slot": _selected_item_slot = clampi(int(args.get("slot", 0)), 0, 2)
		&"select_potion":
			_store.set_setting("selected_potion", String(args.get("item_id", "")))
			_show_shop()
		&"undo_purchase":
			_store.undo_purchase()
			_show_shop()
		&"open_arcade":
			_paused = true
			_ui.show_arcade({"best": _arcade_best(), "skins": _unlocked_biomes()})
		&"open_minigames":
			_paused = true
			_store.set_playing(false)
			_input.reset()
			var error: Error = get_tree().change_scene_to_file("res://minigames/arcade_pack/arcade_hub.tscn")
			if error != OK: _ui.show_toast("Toy-Box Trials could not be opened: " + error_string(error))
		&"start_arcade": _start_arcade(StringName(args.get("skin", "meadow")))
		&"open_tournament":
			_clear_session()
			_paused = true
			_ui.show_tournament(_party_menu_snapshot())
		&"open_physics": _show_physics()
		&"start_physics": _start_physics(String(args.get("variant", _physics_variant)))
		&"host_lan", &"join_lan":
			var request: Dictionary = _party_loadout(args)
			var checked: Dictionary = _lan.validate_loadout(request)
			if not checked.get("ok", false):
				_ui.show_toast(String(checked.get("reason", "Choose a valid party loadout.")))
				return
			_clear_session()
			var error: Error
			if id == &"host_lan":
				error = _lan.host(String(args.get("name", _profile_name())), int(args.get("port", 24680)), int(args.get("rounds", 3)), request)
			else:
				error = _lan.join(String(args.get("address", "127.0.0.1")), String(args.get("name", _profile_name())), int(args.get("port", 24680)), request)
			if error != OK: _ui.show_toast("Could not open this party: " + error_string(error))
		&"start_lan": _start_lan_round()
		&"leave_lan":
			_lan.leave()
			_network_state.clear()
			_architecture.lifecycle(&"party_leave")
			_clear_session()
			_ui.show_tournament(_party_menu_snapshot())
		&"start_tournament":
			var players: Array = args.get("players", [{"name": _profile_name()}, {"name": "Pip", "is_bot": true}])
			if not _prepare_practice_loadouts(players): return
			var configured: Dictionary = _modes.start_tournament(players, int(args.get("rounds", 3)), 20261010, args.get("modes", []))
			if not configured.get("ok", false):
				_ui.show_toast("Choose two to four players and a valid round pool.")
				return
			_mode = &"tournament"
			_start_round()
		&"move", &"rotate", &"drop", &"soft", &"hold", &"use_skill", &"use_item", &"tap": _play_intent(id, args)
		&"view":
			if _stage != null and not _paused: _stage.rotate_view(int(args.get("direction", 1)))
		&"back": _back()
		&"quit": get_tree().quit()

func _show_title() -> void:
	_clear_session()
	_architecture.lifecycle(&"boot")
	_paused = true
	_ui.show_title({"has_profile": _store.active_profile() != null, "profile_name": _profile_name(),
		"stars": _total_stars(), "wallet": _wallet()})

func _show_profiles() -> void:
	_architecture.lifecycle(&"profile")
	_paused = true
	var p: Variant = _store.active_profile()
	_ui.show_profiles({"profiles": _store.list_profiles(), "active_slot": int(p.get("slot", -1)) if p != null else -1})

func _show_map() -> void:
	_store.close_shop()
	_paused = true
	_mode = &"campaign"
	_clear_session()
	var levels: Array[Dictionary] = []
	for meta: Dictionary in _content.all_levels():
		if StringName(meta.get("biome", "")) != _selected_biome: continue
		var row: Dictionary = meta.duplicate(true)
		var raw: Dictionary = _content.raw_level(StringName(meta.id))
		row["number"] = meta.get("tier", 1)
		row["unlocked"] = _is_unlocked(StringName(meta.id))
		row["stars"] = _saved_stars(StringName(meta.id))
		row["preview"] = not meta.get("blocking_gameplay", []).is_empty()
		row["goal"] = ("Design preview · " if row.preview else "") + _goal_text(raw.get("goal", {}))
		row["twists"] = _rule_labels(raw.get("rules", []))
		levels.append(row)
	_architecture.lifecycle(&"map", {"biome": _selected_biome})
	_ui.show_map({"profile_name": _profile_name(), "stars": _total_stars(), "wallet": _wallet(),
		"levels": levels, "biomes": _biome_snapshots(), "selected_biome": _selected_biome})

func _show_intro(id: StringName) -> void:
	if not _is_unlocked(id):
		_ui.show_toast(tr("Finish the previous level to open this one."))
		return
	_paused = true
	_level_id = id
	var raw: Dictionary = _content.raw_level(id)
	var stars: Dictionary = raw.get("stars", {})
	var blocked: Array = raw.get("metadata", {}).get("blocking_gameplay", [])
	var detail: String = "Place blocks, watch the ghost, and turn the view for a clearer angle. Puzzle tools show this level's special controls."
	if not blocked.is_empty(): detail = "Design preview: " + "; ".join(blocked) + ". This playable subset grants no stars."
	_architecture.lifecycle(&"intro", {"level_id": id})
	_ui.show_intro({"level_id": id, "name": _level_name(id), "number": raw.get("tier", 1),
		"goal": _goal_text(raw.get("goal", {})), "goal_detail": detail,
		"twists": _rule_labels(raw.get("rules", [])), "star_targets": [_format_ms(int(stars.get("t3", 0))), _format_ms(int(stars.get("t2", 0)))],
		"character_name": _character_name(), "mode": "Campaign"})

func _start_level(id: StringName) -> void:
	if not _smoke and not _is_unlocked(id): return
	_mode = &"campaign"
	_level_id = id
	var raw: Dictionary = _content.raw_level(id)
	_preview_level = not raw.get("metadata", {}).get("blocking_gameplay", []).is_empty()
	var level: LevelData = LevelLoader.parse_level(raw, _catalog).level
	if level == null:
		_ui.show_toast(tr("This level could not be loaded. Check the content validation report."))
		return
	_begin_session(level)

func _start_arcade(biome: StringName) -> void:
	_selected_biome = biome
	_mode = &"arcade"
	_level_id = &"arcade"
	_begin_session(_modes.arcade_level(biome, 20261010))

func _start_round() -> void:
	_mode = &"tournament"
	var level: LevelData = _modes.next_round_level()
	if level == null:
		_result_shown = true
		_architecture.lifecycle(&"session_end", {"mode": "tournament"})
		_ui.show_results({"won": true, "level_name": "Tournament complete", "mode": "tournament", "standings": _modes.standings(), "next_available": false})
		return
	var source: Dictionary = _round_source(level)
	_begin_session(level)
	var players: Array = _modes.tournament_snapshot().get("players", [])
	for i: int in range(1, players.size()):
		var rival_level: LevelData = LevelLoader.parse_level(source, _catalog).level
		var loadout: Dictionary = _practice_loadouts[i] if i < _practice_loadouts.size() else {"ability_character":"cloud", "effects":{}}
		_apply_character_loadout(rival_level, StringName(loadout.ability_character), loadout.effects)
		var rival: BoardSim = BoardSim.new(rival_level, rival_level.seed, _catalog)
		var abilities: WtAbilities = WtAbilities.new()
		abilities.setup(rival_level, _catalog, rival.get_api(), StringName(loadout.ability_character), &"tournament")
		abilities.set_charge_perks(loadout.effects)
		rival.bind_abilities(abilities)
		_rivals.append(rival)
		_bots.append(WtBotPlayer.new())

func _begin_session(level: LevelData) -> void:
	_clear_session()
	_level = level
	if _mode == &"campaign": _store.record_encounter(String(level.id))
	if bool(_store.get_setting("relaxed_timing", false)):
		_level.stars = _level.stars.duplicate(true)
		for key: String in ["t2", "t3"]:
			if _level.stars.has(key): _level.stars[key] = int(_level.stars[key]) * 3 / 2
	_apply_loadout(level)
	_sim = BoardSim.new(level, level.seed if level.seed != LevelData.NO_SEED else 20261010, _catalog)
	_abilities = WtAbilities.new()
	_abilities.setup(level, _catalog, _sim.get_api(), _ability_character(), (&"tournament" if _mode == &"lan" else _mode))
	_abilities.set_charge_perks(_session_effects())
	_sim.bind_abilities(_abilities)
	if _mode == &"arcade":
		_arcade = WtArcadeDirector.new()
		_arcade.setup(_content, _modes, _store.progress(), level.seed)
	if _mode == &"campaign":
		for meta: Dictionary in _content.all_levels():
			if StringName(meta.id) == level.id and ResourceLoader.exists(String(meta.scene)):
				_official_stage = load(String(meta.scene)).instantiate()
				add_child(_official_stage)
				break
	_stage = _official_stage.get_node_or_null("World") as WtStage if _official_stage != null else null
	if _stage == null:
		_stage = WtStage.new()
		add_child(_stage)
	_stage.setup(_sim, level.biome, _settings())
	_stage.apply_cosmetics(_store.progress().get("cosmetics", {}))
	_stage.set_story_context({"level_id":level.id,"character":_ability_character(),"keepsakes":_store.progress().get("keepsakes",[]),"mizzle_redeemed":_saved_stars(&"celestial_10")>0})
	if _stage.has_signal("secret_tapped"): _stage.connect("secret_tapped", _on_secret_tapped)
	_stage.set_goal(level.goal)
	_stage.set_board_area(Rect2(0.22, 0.08, 0.60, 0.66))
	_input.reset()
	_result_shown = false
	_store.set_playing(true)
	_tick_counter = 0
	_paused = false
	_architecture.lifecycle(&"session_countdown" if _sim.get_phase() == BoardSim.Phase.COUNTDOWN else &"session_begin", {"mode": _mode, "level_id": level.id})
	_ui.show_hud(_hud_snapshot())
	_stage.set_board_area(_ui.board_area())
	if _mode == &"campaign" and not _smoke:
		var story: Dictionary = WtStoryData.snapshot(level.id, "pre", _saved_stars(level.id)>0)
		if not story.get("beats", []).is_empty():
			_story_phase = "pre"
			_paused = true
			_store.set_playing(false)
			_architecture.lifecycle(&"intro", {"level_id":level.id, "story":"pre"})
			story["skippable"] = true
			_ui.show_story(story)

func _clear_session() -> void:
	_stop_physics()
	_store.set_playing(false)
	if _store.has_method("commit_inventory"): _store.call("commit_inventory")
	if _architecture != null:
		_architecture.lifecycle(&"save_commit")
		_architecture.lifecycle(&"session_clear")
	if _official_stage != null:
		_official_stage.queue_free()
		_official_stage = null
	_pending_item = ""
	_selected_item_slot = 0
	_story_phase = ""
	_pending_results.clear()
	_warning = ""
	_hint = ""
	_wobble.clear()
	_network_sims.clear()
	if _stage != null:
		_stage.queue_free()
		_stage = null
	_sim = null
	_abilities = null
	_arcade = null
	_rivals.clear()
	_bots.clear()
	_input.reset()

func _play_intent(id: StringName, args: Dictionary) -> void:
	if _sim == null or _paused: return
	var cmd: SimCommand
	match id:
		&"move":
			var screen: Vector2i = args.get("screen", Vector2i.ZERO)
			if screen == Vector2i.ZERO:
				var delta: Vector3i = args.get("delta", Vector3i.ZERO)
				screen = Vector2i(delta.x, delta.z)
			cmd = SimCommand.make(SimEvents.CMD_MOVE, [_stage.get_move_vector(screen)])
		&"rotate":
			var axis_name: StringName = StringName(args.get("axis", "spin"))
			var rotation: Vector2i = _stage.rotation_for(axis_name, int(args.get("direction", 1)))
			cmd = SimCommand.make(SimEvents.CMD_ROTATE, [rotation.x, rotation.y])
		&"drop": cmd = SimCommand.make(SimEvents.CMD_HARD_DROP)
		&"soft": cmd = SimCommand.make(SimEvents.CMD_SOFT_DROP_ON if bool(args.get("active", true)) else SimEvents.CMD_SOFT_DROP_OFF)
		&"hold": cmd = SimCommand.make(SimEvents.CMD_HOLD)
		&"use_skill": cmd = SimCommand.make(SimEvents.CMD_USE_SKILL)
		&"use_item":
			if _mode in [&"tournament", &"lan"]:
				cmd = SimCommand.make(SimEvents.CMD_USE_ITEM, [{"slot": clampi(int(args.get("slot", _selected_item_slot)), 0, 2)}])
			var potion: String = String(_store.get_setting("selected_potion", ""))
			var stock: int = int(_store.progress().get("inventory", {}).get("potions", {}).get(potion, 0))
			if _mode in [&"campaign", &"arcade"] and _pending_item.is_empty() and stock > 0:
				_pending_item = potion
				cmd = SimCommand.make(SimEvents.CMD_USE_ITEM, [potion])
		&"tap": cmd = SimCommand.make(SimEvents.CMD_TAP, [{"secret_id": args.secret_id}] if args.has("secret_id") else [])
	if cmd != null:
		if _mode == &"lan":
			if not _lan.is_host(): _stage.predict(cmd)
			_lan.submit(cmd.kind, cmd.args)
		else: _sim.queue_command(cmd)

func _pause() -> void:
	if _sim == null or _result_shown: return
	_paused = true
	_architecture.lifecycle(&"session_pause")
	_store.set_playing(false)
	_input.reset()
	_sim.queue_command(SimCommand.make(SimEvents.CMD_SOFT_DROP_OFF))
	_ui.show_pause({"level_name": _level_name(_level_id), "mode": _mode})

func _show_tools() -> void:
	if _sim == null or _result_shown or _mode == &"lan": return
	_paused = true
	_store.set_playing(false)
	_input.reset()
	_sim.queue_command(SimCommand.make(SimEvents.CMD_SOFT_DROP_OFF))
	_ui.show_tools({"capabilities":_sim.capabilities(),"kit_choices":_sim.kit_choices(),
		"selection_remaining":_sim.selection_remaining(),"allowed_down":_puzzle_directions(&"control.travel_dirs"),
		"allowed_flick":_puzzle_directions(&"control.flick_dirs")})

func _puzzle_directions(knob: StringName) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	var tokens: Variant = _sim.knobs().value(knob)
	if tokens is Array:
		for token: Variant in tokens:
			var direction: Vector3i = _sim.board().down_vector() if String(token)=="down" else MechanicsCells.direction(String(token))
			if direction != Vector3i.ZERO: result.append(direction)
	return result

func _puzzle_intent(id: StringName, args: Dictionary) -> void:
	if _sim == null or _result_shown or _mode == &"lan": return
	var kinds: Dictionary = {&"pick_shape":SimEvents.CMD_PICK_SHAPE,&"choose_down":SimEvents.CMD_CHOOSE_DOWN,
		&"flick":SimEvents.CMD_FLICK,&"undo":SimEvents.CMD_UNDO,&"reset":SimEvents.CMD_RESET}
	var command_args: Array = [StringName(args.get("shape_id", ""))] if id == &"pick_shape" else [args.get("direction",Vector3i.ZERO)] if id in [&"choose_down",&"flick"] else []
	_sim.queue_command(SimCommand.make(kinds[id],command_args))
	_paused = false
	_store.set_playing(true)
	_input.reset()
	_ui.show_hud(_hud_snapshot())

func _back() -> void:
	if _mode == &"physics":
		if _physics != null: _return_from_physics()
		else: _show_title()
		return
	if _ui.handle_back(): return
	if _ui.current_screen == "settings" and _sim != null:
		_ui.show_pause({"level_name": _level_name(_level_id)})
	elif _ui.current_screen in ["intro", "shop", "arcade", "tournament"]:
		if _store.active_profile() == null: _show_title()
		else: _show_map()
	elif _ui.current_screen == "title": _ui.confirm_quit()
	else: _show_title()

func _finish_level() -> void:
	_result_shown = true
	_paused = true
	var result: LevelResult = _sim.result()
	if result == null: return
	_architecture.lifecycle(&"session_end", {"mode": _mode, "won": result.is_won()})
	var earned: Dictionary = {}
	var replay: bool = _saved_stars(_level_id) > 0
	_store.set_playing(false)
	if _store.has_method("commit_inventory"): _store.call("commit_inventory")
	if _mode == &"campaign" and result.is_won() and not _preview_level:
		earned = _store.record_result(_level_id, result.stars, result.level_ms, result.score, _level.level_hash)
	elif _mode == &"arcade" and _store.has_method("record_arcade"):
		_store.record_arcade(String(_selected_biome), result.score, result.layers_cleared, result.level_ms)
	_pending_results = {"won": result.is_won(), "stars": result.stars, "score": result.score, "time": _format_ms(result.level_ms),
		"level_id": _level_id, "level_name": _level_name(_level_id) if _mode == &"campaign" else "Arcade run",
		"next_available": _mode == &"campaign" and result.is_won() and _next_level() != &"",
		"message": "Design preview: omitted mechanics remain in the coverage report; this run grants no stars." if _preview_level and _mode == &"campaign" else "+%d points" % int(earned.get("award", 0)) if result.is_won() else "Every attempt teaches you something. Try a new angle!", "mode": _mode}
	if _mode == &"campaign" and result.is_won() and not _preview_level:
		var story: Dictionary = WtStoryData.snapshot(_level_id,"post",replay)
		if not story.get("beats",[]).is_empty():
			_story_phase = "post"
			_ui.show_story(story)
			return
	_ui.show_results(_pending_results)

func _check_round() -> void:
	var ended: bool = _sim.get_phase() == BoardSim.Phase.ENDED
	var winner: bool = ended and _sim.result() != null and _sim.result().is_won()
	for rival: BoardSim in _rivals:
		if rival.get_phase() == BoardSim.Phase.ENDED and rival.result() != null and rival.result().is_won(): winner = true
	if not winner and _sim.elapsed_ms() < PRACTICE_TIME_CAP_MS:
		var all_ended: bool = ended
		for rival: BoardSim in _rivals: all_ended = all_ended and rival.get_phase() == BoardSim.Phase.ENDED
		if not all_ended: return
	var results: Array[Dictionary] = [_round_result(_sim, 0)]
	for i: int in _rivals.size(): results.append(_round_result(_rivals[i], i + 1))
	var round_end: Dictionary = _modes.record_round(results)
	_result_shown = true
	_paused = true
	_architecture.lifecycle(&"session_end", {"mode": "tournament"})
	_ui.show_results({"won": winner and _sim.result() != null and _sim.result().is_won(), "level_name": "Round complete",
		"score": _sim.score(), "time": _format_ms(_sim.elapsed_ms()), "stars": 0,
		"next_available": round_end.get("phase", "") != "finished", "standings": _modes.standings(), "mode": "tournament", "message": String(round_end.get("message", "Fresh boards. Fresh chances."))})

func _round_result(sim: BoardSim, index: int) -> Dictionary:
	var r: LevelResult = sim.result()
	return {"id": str(index), "player": index, "index": index, "won": r != null and r.is_won(), "out": r != null and not r.is_won(),
		"progress": sim.goal_state().layers_cleared, "score": sim.score(), "ms": sim.elapsed_ms(), "layers": sim.goal_state().layers_cleared, "active": true}

func _refresh_hud() -> void:
	if _architecture.snapshot().state == &"countdown" and _sim.get_phase() != BoardSim.Phase.COUNTDOWN:
		_architecture.lifecycle(&"session_begin", {"mode": _mode})
	_ui.update_hud(_hud_snapshot())
	if _story_phase != "":
		_ui.hide_countdown()
		return
	if _sim.get_phase() == BoardSim.Phase.SELECTING and _ui.current_screen != "tools":
		_show_tools()
		return
	if _sim.get_phase() == BoardSim.Phase.COUNTDOWN:
		var left: int = maxi(1, ceili(float(_sim.knobs().int_value(&"goal.countdown_ms") - _sim.now_ms()) / 1000.0))
		_ui.show_countdown(str(left))
	else: _ui.hide_countdown()

func _hud_snapshot() -> Dictionary:
	if _sim == null: return {}
	var goal: Dictionary = _level.goal
	var goal_progress: Dictionary = _sim.progress_snapshot()
	var progress: int = int(goal_progress.get("done",0))
	var target: int = int(goal_progress.get("target",1))
	if goal_progress.get("unit","") == "ms":
		progress /= 1000
		target /= 1000
	var next_ids: Array[StringName] = _sim.preview(clampi(_sim.knobs().int_value(&"spawn.preview_count"), 1, PREVIEW_COUNT))
	return {"level_name": _level_name(_level_id) if _mode == &"campaign" else "Arcade" if _mode == &"arcade" else "Party practice",
		"goal": _goal_text(goal), "progress": progress, "target": target, "score": _sim.score(), "time": _format_ms(_sim.elapsed_ms()),
		"next_piece": ", ".join(next_ids), "twists": _rule_labels(_arcade.snapshot().rules if _arcade != null else _level.rules),
		"danger": _sim.board().stack_height() >= _sim.board().limit_layer() - 2,
		"can_tilt": _level.knobs.get(&"control.rotation_axes_enabled", []).has("tilt"),
		"can_roll": _level.knobs.get(&"control.rotation_axes_enabled", []).has("roll"),
		"round": int(_modes.tournament_snapshot().get("round_index", 0) + 1) if _mode == &"tournament" else 0,
		"standings": _modes.standings() if _mode == &"tournament" else [],
		"skill_ready": _abilities.ready() if _abilities != null else false, "skill_charge": _abilities.charge if _abilities != null else 0,
		"skill_name": {"cloud": "Calm Skies", "lana": "Stitch", "boulder": "Smash", "glim": "Redraw"}.get(String(_ability_character()), "Calm Skies"),
		"held_shape": String(_sim.held_shape()) if _sim.knobs().flag(&"spawn.hold_enabled") else "Disabled",
		"selected_potion": String(_store.get_setting("selected_potion", "")) if _mode in [&"campaign", &"arcade"] else "",
		"potion_count": int(_store.progress().get("inventory", {}).get("potions", {}).get(String(_store.get_setting("selected_potion", "")), 0)) if _mode in [&"campaign", &"arcade"] else 0,
		"warning": _warning, "hint": _hint, "wobble": _wobble}

func _show_shop() -> void:
	_paused = true
	_store.set_playing(false)
	var rows: Array = _store.shop_snapshot()
	var items: Array[Dictionary] = []
	for row: Dictionary in rows:
		var item: Dictionary = row.duplicate(true)
		item["name"] = row.get("text", row.get("name_key", row.id))
		var effect: Variant = row.get("effect", {})
		item["description"] = " · ".join(effect.keys()) if effect is Dictionary else String(effect).replace("_", " ").capitalize()
		if row.get("kind","") == "cosmetic": item["description"] = String(row.get("biome","meadow")).capitalize()+" · "+String(row.id).get_slice("_",1).capitalize()
		item["price"] = int(row.get("price", {}).get("amount", 0))
		item["locked"] = not bool(row.get("unlocked", false))
		item["equipped"] = _store.get_setting("equipped_perks", []).has(String(row.id))
		item["selected"] = String(_store.get_setting("selected_potion", "")) == String(row.id)
		items.append(item)
	var chars: Array[Dictionary] = []
	var available: Array = _store.characters()
	var selected: String = String(_store.get_setting("character", "c1"))
	for pair: Array in [["c1", "Cloud Wizard"], ["c2", "Lana"], ["c3", "Boulder"], ["c4", "Glim"]]:
		chars.append({"id": pair[0], "name": pair[1], "selected": selected == pair[0], "unlocked": available.has(pair[0])})
	_ui.show_shop({"wallet": _wallet(), "items": items, "characters": chars, "can_undo": true})

func _settings() -> Dictionary:
	return _store.settings()

func _ui_settings() -> Dictionary:
	var prefs: Dictionary = _settings()
	for key: String in ["music_volume", "sfx_volume", "ui_volume", "button_scale"]:
		prefs[key] = float(prefs.get(key, 0.8 if key.ends_with("volume") else 1.0)) * 100.0
	return prefs

func _save_preference(key: String, value: Variant) -> void:
	if key.ends_with("_volume") or key == "button_scale": value = float(value) / 100.0
	if not _store.set_setting(key, value):
		_ui.show_toast("This preference could not be saved.")
	_apply_preferences()

func _apply_preferences() -> void:
	var prefs: Dictionary = _settings()
	Engine.max_fps = int(prefs.get("frame_cap", 60))
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if bool(prefs.get("vsync", true)) else DisplayServer.VSYNC_DISABLED)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if prefs.get("window_mode", "windowed") == "fullscreen" else DisplayServer.WINDOW_MODE_WINDOWED)
	for key: String in prefs:
		if key.begins_with("key_"):
			var action: StringName = StringName(key.trim_prefix("key_"))
			if InputMap.has_action(action):
				for event: InputEvent in InputMap.action_get_events(action):
					if event is InputEventKey: InputMap.action_erase_event(action, event)
				var event: InputEventKey = InputEventKey.new()
				event.physical_keycode = OS.find_keycode_from_string(str(prefs[key]))
				InputMap.action_add_event(action, event)
	if _ui.has_method("apply_prefs"): _ui.apply_prefs(_settings())
	if _stage != null: _stage.set_board_area(_ui.board_area())
	_input.refresh_bindings(_settings())

func _is_unlocked(id: StringName) -> bool:
	if _smoke: return true
	for meta: Dictionary in _content.all_levels():
		if StringName(meta.id) == id: return _store.level_open(meta)
	return false

func _ability_character() -> StringName:
	if _mode == &"lan": return StringName(_lan.player_loadout().get("ability_character", "cloud"))
	if _mode == &"tournament" and not _practice_loadouts.is_empty(): return StringName(_practice_loadouts[0].ability_character)
	return {"c1": &"cloud", "c2": &"lana", "c3": &"boulder", "c4": &"glim"}.get(String(_store.get_setting("character", "c1")), &"cloud")

func _unlocked_biomes() -> Array[String]:
	var out: Array[String] = []
	for row: Dictionary in _biome_snapshots():
		if bool(row.unlocked): out.append(String(row.id))
	return out

func _next_level() -> StringName:
	var all: Array[Dictionary] = _content.all_levels()
	for i: int in range(all.size() - 1):
		if StringName(all[i].id) == _level_id and _is_unlocked(StringName(all[i + 1].id)): return StringName(all[i + 1].id)
	return &""

func _level_name(id: StringName) -> String:
	for meta: Dictionary in _content.all_levels():
		if StringName(meta.id) == id: return String(meta.get("name", String(id).capitalize()))
	return String(id).capitalize()

func _profile_name() -> String:
	var p: Variant = _store.active_profile()
	return String(p.get("name", "Builder")) if p != null else "Builder"

func _wallet() -> int:
	return _store.wallet_balance()

func _total_stars() -> int:
	var p: Dictionary = _store.progress()
	if p.has("stars"): return int(p.stars)
	var total: int = 0
	for v: Variant in p.get("levels", {}).values():
		if v is Dictionary: total += int(v.get("stars", 0))
	return total

func _saved_stars(id: StringName) -> int:
	return int(_store.progress().get("levels", {}).get(String(id), {}).get("stars", 0))

func _character_name() -> String:
	return {"cloud": "Cloud Wizard", "lana": "Lana", "boulder": "Boulder", "glim": "Glim"}.get(String(_ability_character()), "Cloud Wizard")

func _biome_snapshots() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var seen: Dictionary = {}
	for meta: Dictionary in _content.all_levels():
		var id: String = String(meta.get("biome", "meadow"))
		if seen.has(id): continue
		seen[id] = true
		out.append({"id": id, "name": id.capitalize(), "stars": _store.biome_stars(id), "unlocked": _store.biome_open(id)})
	return out

func _rule_labels(rules: Array) -> Array[String]:
	var out: Array[String] = []
	for value: Variant in rules:
		var id: String = String(value.get("id", "")) if value is Dictionary else String(value)
		if id != "spin_only": out.append(id.replace("_", " ").capitalize())
	return out

func _goal_text(goal: Dictionary) -> String:
	match String(goal.get("type", "clear_n")):
		"height": return "Build a %d-layer tower" % int(goal.get("h_target", goal.get("h", goal.get("height", goal.get("target", 6)))))
		"survive": return "Keep building and survive"
		"shape": return "Fill the marked flower bed"
		"bonk_boss": return "Bonk the boss %d times" % int(goal.get("bonks_needed",4))
		"rescue_all": return "Free every frosted critter"
		"dig_rescue": return "Rescue %d buried critters" % int(goal.get("critters_needed",3))
		"wind_keys": return "Wind %d wall keys" % int(goal.get("keys_needed",4))
		"frosted_tier": return "Clear the frosted tier"
		"endless": return "Keep building — beat your best score"
		_: return "Clear %d full layers" % int(goal.get("n", 4))

static func _format_ms(ms: int) -> String:
	if ms <= 0: return "—"
	return "%d:%02d" % [ms / 60000, (ms / 1000) % 60]

# LAN orchestration. The host feeds all devices the same ordered command stream;
# only this device's board is rendered, with immediate presentation-only prediction.
func _show_lobby(snapshot: Dictionary) -> void:
	if _lan.in_round: return
	_paused = true
	var addresses: PackedStringArray = IP.get_local_addresses()
	var address: String = "127.0.0.1"
	for candidate: String in addresses:
		if candidate.begins_with("192.168.") or candidate.begins_with("10.") or candidate.begins_with("172."):
			address = candidate
			break
	_architecture.lifecycle(&"party_lobby", {"players": snapshot.get("players", []).size()})
	var data: Dictionary = _party_menu_snapshot()
	data.merge({"rounds": snapshot.get("rounds", 3), "profile_name": _profile_name(),
		"network_status": "hosting" if _lan.hosting else "connected" if snapshot.get("connected", false) else "connecting",
		"network_players": snapshot.get("players", []), "host": _lan.hosting, "address": address + ":" + str(_lan.port)}, true)
	_ui.show_tournament(data)

func _start_lan_round() -> void:
	if not _lan.is_host(): return
	if not _network_state.get("ok", false):
		var players: Array = []
		for player: Dictionary in _lan.snapshot().players:
			players.append({"id": str(player.id), "name": player.name, "character": player.character})
		_network_state = _modes.start_tournament(players, _lan.rounds, 20261010)
	var level: LevelData = _modes.next_round_level()
	if level == null: return
	_network_state = _modes.tournament_snapshot()
	var source: Dictionary = _round_source(level)
	_lan.start_round({"seed": level.seed, "raw_level": source, "tournament": _network_state})

func _on_network_round(config: Dictionary) -> void:
	var source: Dictionary = config.get("raw_level", {})
	var parsed: LoadResult = LevelLoader.parse_level(source, _catalog)
	if parsed.level == null:
		_ui.show_toast("The host's round definition could not be loaded.")
		_lan.leave()
		return
	_mode = &"lan"
	_network_state = config.get("tournament", {})
	_begin_session(parsed.level)
	_network_sims.clear()
	_network_sims[_lan.local_id()] = _sim
	for player: Dictionary in config.get("players", []):
		var identity: int = int(player.id)
		if identity == _lan.local_id(): continue
		# Reparse the immutable source: each character's signature and perks are private.
		var remote_level: LevelData = LevelLoader.parse_level(source, _catalog).level
		var loadout: Dictionary = _lan.player_loadout(identity)
		_apply_character_loadout(remote_level, StringName(loadout.ability_character), loadout.effects)
		var remote: BoardSim = BoardSim.new(remote_level, int(config.seed), _catalog)
		var abilities: WtAbilities = WtAbilities.new()
		abilities.setup(remote_level, _catalog, remote.get_api(), StringName(loadout.ability_character), &"tournament")
		abilities.set_charge_perks(loadout.effects)
		remote.bind_abilities(abilities)
		_network_sims[identity] = remote
	_architecture.lifecycle(&"party_round", {"players": _network_sims.size(), "seed": config.seed})

func _on_network_frame(_tick: int, commands: Array) -> void:
	if _mode != &"lan" or _network_sims.is_empty(): return
	for row: Dictionary in commands:
		var identity: int = int(row.get("peer_id", 0))
		if _network_sims.has(identity):
			_network_sims[identity].queue_command(SimCommand.make(StringName(row.kind), row.get("args", [])))
	var ids: Array = _network_sims.keys()
	ids.sort()
	for identity: int in ids:
		var simulation: BoardSim = _network_sims[identity]
		var events: Array[SimEvent] = simulation.step()
		if identity == _lan.local_id():
			_route_events(events)
			_stage.sync(events)
	_refresh_hud()
	if _lan.is_host(): _check_network_round()

func _check_network_round() -> void:
	if _result_shown or not _lan.in_round: return
	var won: bool = false
	var all_ended: bool = true
	var results: Array = []
	for identity: int in _network_sims:
		var simulation: BoardSim = _network_sims[identity]
		var result: LevelResult = simulation.result()
		won = won or result != null and result.is_won()
		all_ended = all_ended and simulation.get_phase() == BoardSim.Phase.ENDED
		results.append({"id": str(identity), "won": result != null and result.is_won(), "ms": simulation.elapsed_ms(),
			"score": simulation.score(), "progress": float(simulation.progress_snapshot().get("done", 0)),
			"layers": simulation.goal_state().layers_cleared, "active": true})
	if not won and not all_ended and _sim.elapsed_ms() < PRACTICE_TIME_CAP_MS: return
	_network_state = _modes.record_round(results)
	_lan.finish_round({"tournament": _network_state, "results": results, "aborted": false})

func _on_network_finished(data: Dictionary) -> void:
	_result_shown = true
	_paused = true
	_store.set_playing(false)
	_architecture.lifecycle(&"session_end", {"mode":"lan", "aborted":data.get("aborted",false)})
	_network_state = data.get("tournament", _network_state)
	var ended: bool = _network_state.get("phase", "") == "finished"
	var won: bool = _network_state.get("winners", []).has(str(_lan.local_id()))
	if ended and not bool(data.get("aborted", false)):
		var awards: Dictionary = _network_state.get("awards", {})
		_store.record_tournament(won, int(awards.get("win", 0) if won else awards.get("finish", 0)))
	_ui.show_results({"won": won, "level_name": "Party complete" if ended else "Round complete", "mode": "lan",
		"next_available": _lan.is_host() and not ended and not data.get("aborted", false),
		"standings": _network_state.get("standings", []), "message": String(data.get("reason", "Every round starts fresh.")),
		"score": _sim.score() if _sim != null else 0, "time": _format_ms(_sim.elapsed_ms()) if _sim != null else "—"})

func _on_network_pause(value: bool) -> void:
	_paused = value
	_architecture.lifecycle(&"session_pause" if value else &"session_resume")
	_store.set_playing(not value)
	_input.reset()
	if value: _ui.show_pause({"level_name": "LAN party", "mode": "lan"})
	elif _sim != null: _ui.show_hud(_hud_snapshot())

func _on_network_disconnect(reason: String) -> void:
	_paused = true
	_result_shown = true
	_store.set_playing(false)
	_ui.show_toast(reason)
	_architecture.lifecycle(&"party_leave", {"reason":reason})
	_ui.show_tournament(_party_menu_snapshot())

func _round_source(level: LevelData) -> Dictionary:
	var board: BoardSpec = level.boards[0]
	var knobs: Dictionary = {}
	for id: StringName in level.knobs:
		var value: Variant = level.knobs[id]
		var definition: Dictionary = _catalog.knob_defs.def(id)
		if definition.get("type", "") == "scalar": value = float(value) / 1000.0
		elif value is StringName: value = String(value)
		knobs[String(id)] = value
	var source: Dictionary = {"schema": 1, "id": String(level.id), "biome": String(level.biome), "tier": 1, "name": "Party round",
		"board": {"width": board.size.x, "depth": board.size.z, "h_play": board.h_play, "down_axis": BoardState.DOWN_TOKENS[board.down]},
		"pieces": level.pieces, "knobs": knobs, "goal": level.goal, "rules": level.rules, "stars": level.stars, "seed": level.seed}

	var normalized: Dictionary = JSON.parse_string(JSON.stringify(source))
	normalized["seed"] = level.seed
	return normalized

func _on_secret_tapped(id: StringName) -> void:
	_play_intent(&"tap", {"secret_id": id})

func _route_events(events: Array[SimEvent]) -> void:
	for event: SimEvent in events:
		match event.kind:
			&"item_used":
				var id: String = String(event.data.get("id", ""))
				if id == _pending_item:
					_store.consume_potion(id)
					_pending_item = ""
			&"item_no_effect":
				_pending_item = ""
				_ui.show_toast("No effect — potion kept.")
			&"skill_no_effect": _ui.show_toast("No effect — skill charge kept.")
			&"wobble_meter", &"wobble_changed": _wobble = event.data.duplicate()
			&"warning", &"rule_warning", &"gust_warning", &"flip_warning", &"conveyor_warning", &"mushroom_warning": _warning = String(event.data.get("message", event.data.get("text", "Watch the next twist!")))
			&"placement_hint", &"mascot_hint": _hint = "A safe landing is marked on the board."
			SimEvents.PIECE_SPAWNED: _hint = ""

func _arcade_best() -> int:
	var best: int = 0
	for row: Dictionary in _store.progress().get("arcade", {}).values(): best = maxi(best, int(row.get("best_score", 0)))
	return best

func _perk_effects() -> Dictionary:
	var effects: Dictionary = {}
	var selected: Array = _store.get_setting("equipped_perks", [])
	for item: Dictionary in _store.shop_snapshot():
		if selected.has(String(item.id)) and item.get("character", "") == _store.get_setting("character", "c1") and item.get("owned", false) and item.effect is Dictionary:
			effects.merge(item.effect, true)
	return effects

func _apply_loadout(level: LevelData) -> void:
	_apply_character_loadout(level, _ability_character(), _session_effects())

func _apply_character_loadout(level: LevelData, character: StringName, effects: Dictionary) -> void:
	var knobs: Dictionary = level.knobs
	var lock: int = int(knobs.get(&"fall.lock_delay_ms", _catalog.knob_defs.def(&"fall.lock_delay_ms").get("default", 500)))
	var gravity: int = int(knobs.get(&"fall.gravity_scale", 1000))
	var resets: int = int(knobs.get(&"fall.lock_resets_max", 15))
	var warnings: int = int(knobs.get(&"goal.warnings_max", 1))
	match character:
		&"cloud":
			lock = lock * 1200 / 1000
			knobs[&"fall.ramp_per_clear"] = int(knobs.get(&"fall.ramp_per_clear", 50)) * 1150 / 1000
		&"lana":
			lock = lock * 850 / 1000
			warnings += 1
		&"boulder":
			gravity = gravity * 1100 / 1000
			resets += 4
		&"glim":
			lock = lock * 850 / 1000
			knobs[&"spawn.hold_enabled"] = true
	lock = lock * roundi(float(effects.get("lock_delay_scale", 1.0)) * 1000) / 1000
	gravity = gravity * roundi(float(effects.get("gravity_scale", 1.0)) * 1000) / 1000
	warnings += int(effects.get("warnings_add", 0))
	resets += int(effects.get("lock_resets_add", 0))
	knobs[&"fall.lock_delay_ms"] = lock
	knobs[&"fall.gravity_scale"] = gravity
	knobs[&"fall.lock_resets_max"] = resets
	knobs[&"goal.warnings_max"] = warnings
	knobs[&"fall.hard_drop_grace_ms"] = int(knobs.get(&"fall.hard_drop_grace_ms", 100)) * roundi(float(effects.get("drop_grace_scale", 1.0)) * 1000) / 1000
	knobs[&"spawn.preview_count"] = mini(3, int(knobs.get(&"spawn.preview_count", 1)) + int(effects.get("preview_add", 0)))
	if effects.has("randomizer"): knobs[&"spawn.randomizer"] = StringName(effects.randomizer)

func _session_effects() -> Dictionary:
	if _mode == &"lan": return _lan.player_loadout().get("effects", {})
	if _mode == &"tournament" and not _practice_loadouts.is_empty(): return _practice_loadouts[0].effects
	return _perk_effects() if _mode in [&"campaign", &"arcade"] else {}

func _party_loadout(args: Dictionary = {}) -> Dictionary:
	var character: String = String(args.get("character", args.get("character_id", _store.get_setting("character", "c1"))))
	var owned: Array[String] = []
	var equipped: Array[String] = []
	var current: Array = _store.get_setting("equipped_perks", [])
	for row: Dictionary in _store.shop_snapshot():
		if row.get("kind", "") != "perk" or not row.get("owned", false): continue
		owned.append(String(row.id))
		if current.has(String(row.id)) and String(row.get("character", "")) == character: equipped.append(String(row.id))
	return {"character":character, "perks":args.get("perks", equipped), "owned_perks":owned}

func _party_menu_snapshot() -> Dictionary:
	var rows: Array[Dictionary] = []
	for item: Dictionary in _store.shop_snapshot():
		if item.get("kind", "") != "perk" or not item.get("owned", false): continue
		var row: Dictionary = item.duplicate(true)
		row["name"] = row.get("text", row.id)
		row["equipped"] = _store.get_setting("equipped_perks", []).has(String(row.id))
		rows.append(row)
	return {"profile_name": _profile_name(), "rounds":3, "players":[{"name":_profile_name(), "character":_store.get_setting("character","c1")}, {"name":"Pip", "is_bot":true, "character":"c2"}],
		"character":_store.get_setting("character","c1"), "party_perks":rows, "modes":_modes.round_modes(), "items_supported":false, "network_status":"offline"}

func _prepare_practice_loadouts(players: Array) -> bool:
	var loadouts: Array[Dictionary] = []
	for i: int in players.size():
		if not players[i] is Dictionary: return false
		var request: Dictionary = _party_loadout(players[i]) if i == 0 else {"character":players[i].get("character_id",players[i].get("character","c1")), "perks":[], "owned_perks":[]}
		var checked: Dictionary = _lan.validate_loadout(request)
		if not checked.get("ok",false):
			_ui.show_toast(String(checked.get("reason","Choose a valid party loadout.")))
			return false
		loadouts.append(checked.loadout)
		players[i]["character"] = checked.loadout.character
	_practice_loadouts = loadouts
	return true

func _architecture_context() -> Dictionary:
	return {"has_profile":_store != null and _store.active_profile() != null, "has_session":_sim != null or _physics != null,
		"paused":_paused, "result":_result_shown, "mode":String(_mode), "level_id":String(_level_id), "screen":_ui.current_screen if _ui != null else "",
		"lan_active":_lan != null and _lan.active, "lan_host":_lan != null and _lan.is_host()}

func _show_physics() -> void:
	if _lan.active: _lan.leave()
	_clear_session()
	_mode = &"physics"
	_paused = true
	_ui.show()
	_ui.show_physics({"selected_variant":_physics_variant})
	_architecture.lifecycle(&"intro", {"mode":"physics"})

func _start_physics(variant: String) -> void:
	if not WtPhysicsChallenge.VARIANTS.has(variant): return
	_clear_session()
	_mode = &"physics"
	_physics_variant = variant
	# Jolt owns native movement; dispose GUIDE's navigation as well as play context.
	_input.dispose()
	_physics = load("res://src/physics/wt_physics_challenge.tscn").instantiate() as WtPhysicsChallenge
	_physics.setup({"variant":variant,"settings":_settings(),"seed":917})
	_physics.return_requested.connect(_return_from_physics)
	_physics.finished.connect(_on_physics_finished)
	_ui.hide()
	_paused = false
	_result_shown = false
	_store.set_playing(true)
	add_child(_physics)
	_architecture.lifecycle(&"session_begin", {"mode":"physics","variant":variant})

func _on_physics_finished(result: Dictionary) -> void:
	_result_shown = true
	_store.set_playing(false)
	_architecture.lifecycle(&"session_end", {"mode":"physics", "result":result})

func _return_from_physics() -> void:
	_stop_physics()
	_store.set_playing(false)
	_paused = true
	_result_shown = false
	_ui.show()
	_ui.show_physics({"selected_variant":_physics_variant})
	_architecture.lifecycle(&"intro", {"mode":"physics"})

func _stop_physics() -> void:
	if _physics == null: return
	_physics.queue_free()
	_physics = null
	_input.setup(get_tree(), _settings())
	_ui.show()
