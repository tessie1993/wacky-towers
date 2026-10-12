from pathlib import Path
import json
p=Path('src/app/main.gd');s=p.read_text()
def sub(old,new):
 global s
 if s.count(old)!=1:raise RuntimeError(f'anchor count {s.count(old)}: {old[:80]}')
 s=s.replace(old,new)
def func(name,new):
 global s
 start=s.index('func '+name+'(');end=s.find('\nfunc ',start+1)
 if end<0:end=len(s)
 s=s[:start]+new.rstrip()+'\n'+s[end:]
sub('var _pending_results: Dictionary = {}','''var _pending_results: Dictionary = {}
var _architecture: WtArchitecture
var _physics: WtPhysicsChallenge
var _physics_variant: String = "tower_race"
var _practice_loadouts: Array[Dictionary] = []
var _selected_item_slot: int = 0''')
sub('\t_modes = WtModes.new(_content)\n','''\t_modes = WtModes.new(_content)
\t_architecture = WtArchitecture.new()
\t_architecture.name = "Architecture"
\tadd_child(_architecture)
\t_architecture.setup(self)
''')
sub('func _on_intent(id: StringName, args: Dictionary) -> void:\n\tmatch id:', '''func _on_intent(id: StringName, args: Dictionary) -> void:
\t_architecture.dispatch(id, args)

func _execute_intent(id: StringName, args: Dictionary) -> void:
\tmatch id:''')
sub('func _unhandled_input(event: InputEvent) -> void:\n','''func _unhandled_input(event: InputEvent) -> void:
\tif _physics != null: return
''')
sub('\t\t\t\t_paused = false\n\t\t\t\t_store.set_playing(true)','\t\t\t\t_paused = false\n\t\t\t\t_architecture.lifecycle(&"session_resume")\n\t\t\t\t_store.set_playing(true)')
sub('''\t\t&"open_tournament":
\t\t\t_paused = true
\t\t\t_ui.show_tournament({"profile_name": _profile_name(), "rounds": 3, "players": [{"name": _profile_name()}, {"name": "Pip", "is_bot": true}],
\t\t\t\t"modes": _modes.round_modes(), "items_supported": false})''','''\t\t&"open_tournament":
\t\t\t_clear_session()
\t\t\t_paused = true
\t\t\t_ui.show_tournament(_party_menu_snapshot())
\t\t&"open_physics": _show_physics()
\t\t&"start_physics": _start_physics(String(args.get("variant", _physics_variant)))''')
sub('''\t\t&"host_lan":
\t\t\tvar error: Error = _lan.host(String(args.get("name", _profile_name())), int(args.get("port", 24680)), int(args.get("rounds", 3)))
\t\t\tif error != OK: _ui.show_toast("Could not host this party: " + error_string(error))
\t\t\telse: _ui.show_toast("LAN parties currently use Cloud Wizard for every player; skills are once per round.")
\t\t&"join_lan":
\t\t\tvar error: Error = _lan.join(String(args.get("address", "127.0.0.1")), String(args.get("name", _profile_name())), int(args.get("port", 24680)))
\t\t\tif error != OK: _ui.show_toast("Could not join this party: " + error_string(error))''','''\t\t&"host_lan", &"join_lan":
\t\t\tvar request: Dictionary = _party_loadout(args)
\t\t\tvar checked: Dictionary = _lan.validate_loadout(request)
\t\t\tif not checked.get("ok", false):
\t\t\t\t_ui.show_toast(String(checked.get("reason", "Choose a valid party loadout.")))
\t\t\t\treturn
\t\t\t_clear_session()
\t\t\tvar error: Error
\t\t\tif id == &"host_lan":
\t\t\t\terror = _lan.host(String(args.get("name", _profile_name())), int(args.get("port", 24680)), int(args.get("rounds", 3)), request)
\t\t\telse:
\t\t\t\terror = _lan.join(String(args.get("address", "127.0.0.1")), String(args.get("name", _profile_name())), int(args.get("port", 24680)), request)
\t\t\tif error != OK: _ui.show_toast("Could not open this party: " + error_string(error))''')
sub('''\t\t\t_ui.show_tournament({"profile_name": _profile_name(), "network_status": "offline"})
\t\t&"start_tournament":''','''\t\t\t_architecture.lifecycle(&"party_leave")
\t\t\t_clear_session()
\t\t\t_ui.show_tournament(_party_menu_snapshot())
\t\t&"start_tournament":''')
sub('''\t\t\t_modes.start_tournament(players, int(args.get("rounds", 3)), 20261010, args.get("modes", []))
\t\t\t_mode = &"tournament"''','''\t\t\tif not _prepare_practice_loadouts(players): return
\t\t\tvar configured: Dictionary = _modes.start_tournament(players, int(args.get("rounds", 3)), 20261010, args.get("modes", []))
\t\t\tif not configured.get("ok", false):
\t\t\t\t_ui.show_toast("Choose two to four players and a valid round pool.")
\t\t\t\treturn
\t\t\t_mode = &"tournament"''')
sub('\t\t&"select_potion":','\t\t&"select_item_slot": _selected_item_slot = clampi(int(args.get("slot", 0)), 0, 2)\n\t\t&"select_potion":')
sub('func _show_title() -> void:\n\t_paused = true','func _show_title() -> void:\n\t_clear_session()\n\t_architecture.lifecycle(&"boot")\n\t_paused = true')
sub('func _show_profiles() -> void:\n\t_paused = true','func _show_profiles() -> void:\n\t_architecture.lifecycle(&"profile")\n\t_paused = true')
sub('\t_ui.show_map({"profile_name":','\t_architecture.lifecycle(&"map", {"biome": _selected_biome})\n\t_ui.show_map({"profile_name":')
sub('\t_ui.show_intro({"level_id":','\t_architecture.lifecycle(&"intro", {"level_id": id})\n\t_ui.show_intro({"level_id":')
func('_start_round','''func _start_round() -> void:
\t_mode = &"tournament"
\tvar level: LevelData = _modes.next_round_level()
\tif level == null:
\t\t_result_shown = true
\t\t_architecture.lifecycle(&"session_end", {"mode": "tournament"})
\t\t_ui.show_results({"won": true, "level_name": "Tournament complete", "mode": "tournament", "standings": _modes.standings(), "next_available": false})
\t\treturn
\tvar source: Dictionary = _round_source(level)
\t_begin_session(level)
\tvar players: Array = _modes.tournament_snapshot().get("players", [])
\tfor i: int in range(1, players.size()):
\t\tvar rival_level: LevelData = LevelLoader.parse_level(source, _catalog).level
\t\tvar loadout: Dictionary = _practice_loadouts[i] if i < _practice_loadouts.size() else {"ability_character":"cloud", "effects":{}}
\t\t_apply_character_loadout(rival_level, StringName(loadout.ability_character), loadout.effects)
\t\tvar rival: BoardSim = BoardSim.new(rival_level, rival_level.seed, _catalog)
\t\tvar abilities: WtAbilities = WtAbilities.new()
\t\tabilities.setup(rival_level, _catalog, rival.get_api(), StringName(loadout.ability_character), &"tournament")
\t\tabilities.set_charge_perks(loadout.effects)
\t\trival.bind_abilities(abilities)
\t\t_rivals.append(rival)
\t\t_bots.append(WtBotPlayer.new())''')
sub('_abilities.set_charge_perks(_perk_effects() if _mode in [&"campaign", &"arcade", &"tournament"] else {})','_abilities.set_charge_perks(_session_effects())')
sub('''\t_stage = WtStage.new()
\tadd_child(_stage)
\t_stage.setup(_sim, level.biome, _settings())''','''\t_stage = _official_stage.get_node_or_null("World") as WtStage if _official_stage != null else null
\tif _stage == null:
\t\t_stage = WtStage.new()
\t\tadd_child(_stage)
\t_stage.setup(_sim, level.biome, _settings())
\t_stage.apply_cosmetics(_store.progress().get("cosmetics", {}))''')
sub('\t_paused = false\n\t_ui.show_hud(_hud_snapshot())\n\t_stage.set_board_area(_ui.board_area())','\t_paused = false\n\t_architecture.lifecycle(&"session_countdown" if _sim.get_phase() == BoardSim.Phase.COUNTDOWN else &"session_begin", {"mode": _mode, "level_id": level.id})\n\t_ui.show_hud(_hud_snapshot())\n\t_stage.set_board_area(_ui.board_area())')
sub('func _clear_session() -> void:\n\t_store.set_playing(false)','func _clear_session() -> void:\n\t_stop_physics()\n\t_store.set_playing(false)')
sub('\tif _store.has_method("commit_inventory"): _store.call("commit_inventory")\n\tif _official_stage','\tif _store.has_method("commit_inventory"): _store.call("commit_inventory")\n\tif _architecture != null:\n\t\t_architecture.lifecycle(&"save_commit")\n\t\t_architecture.lifecycle(&"session_clear")\n\tif _official_stage')
sub('\t_pending_item = ""\n\t_story_phase = ""','\t_pending_item = ""\n\t_selected_item_slot = 0\n\t_story_phase = ""')
sub('''\t\t&"use_item":
\t\t\tvar potion: String''','''\t\t&"use_item":
\t\t\tif _mode in [&"tournament", &"lan"]:
\t\t\t\tcmd = SimCommand.make(SimEvents.CMD_USE_ITEM, [{"slot": clampi(int(args.get("slot", _selected_item_slot)), 0, 2)}])
\t\t\tvar potion: String''')
sub('\t_paused = true\n\t_store.set_playing(false)\n\t_input.reset()\n\t_sim.queue_command(SimCommand.make(SimEvents.CMD_SOFT_DROP_OFF))\n\t_ui.show_pause','\t_paused = true\n\t_architecture.lifecycle(&"session_pause")\n\t_store.set_playing(false)\n\t_input.reset()\n\t_sim.queue_command(SimCommand.make(SimEvents.CMD_SOFT_DROP_OFF))\n\t_ui.show_pause')
sub('func _back() -> void:\n\tif _ui.handle_back(): return','func _back() -> void:\n\tif _mode == &"physics":\n\t\tif _physics != null: _return_from_physics()\n\t\telse: _show_title()\n\t\treturn\n\tif _ui.handle_back(): return')
sub('\tvar result: LevelResult = _sim.result()\n\tif result == null: return','\tvar result: LevelResult = _sim.result()\n\tif result == null: return\n\t_architecture.lifecycle(&"session_end", {"mode": _mode, "won": result.is_won()})')
sub('\t_ui.show_results({"won": winner and _sim.result()','\t_architecture.lifecycle(&"session_end", {"mode": "tournament"})\n\t_ui.show_results({"won": winner and _sim.result()')
sub('''func _refresh_hud() -> void:
\t_ui.update_hud(_hud_snapshot())''','''func _refresh_hud() -> void:
\tif _architecture.snapshot().state == &"countdown" and _sim.get_phase() != BoardSim.Phase.COUNTDOWN:
\t\t_architecture.lifecycle(&"session_begin", {"mode": _mode})
\t_ui.update_hud(_hud_snapshot())''')
func('_ability_character','''func _ability_character() -> StringName:
\tif _mode == &"lan": return StringName(_lan.player_loadout().get("ability_character", "cloud"))
\tif _mode == &"tournament" and not _practice_loadouts.is_empty(): return StringName(_practice_loadouts[0].ability_character)
\treturn {"c1": &"cloud", "c2": &"lana", "c3": &"boulder", "c4": &"glim"}.get(String(_store.get_setting("character", "c1")), &"cloud")''')
sub('\t_ui.show_tournament({"rounds": snapshot.get("rounds", 3), "profile_name": _profile_name(),','\t_architecture.lifecycle(&"party_lobby", {"players": snapshot.get("players", []).size()})\n\tvar data: Dictionary = _party_menu_snapshot()\n\tdata.merge({"rounds": snapshot.get("rounds", 3), "profile_name": _profile_name(),')
sub('"address": address + ":" + str(_lan.port)})','"address": address + ":" + str(_lan.port)}, true)\n\t_ui.show_tournament(data)')
sub('players.append({"id": str(player.id), "name": player.name, "character": "c1"})','players.append({"id": str(player.id), "name": player.name, "character": player.character})')
func('_on_network_round','''func _on_network_round(config: Dictionary) -> void:
\tvar source: Dictionary = config.get("raw_level", {})
\tvar parsed: LoadResult = LevelLoader.parse_level(source, _catalog)
\tif parsed.level == null:
\t\t_ui.show_toast("The host's round definition could not be loaded.")
\t\t_lan.leave()
\t\treturn
\t_mode = &"lan"
\t_network_state = config.get("tournament", {})
\t_begin_session(parsed.level)
\t_network_sims.clear()
\t_network_sims[_lan.local_id()] = _sim
\tfor player: Dictionary in config.get("players", []):
\t\tvar identity: int = int(player.id)
\t\tif identity == _lan.local_id(): continue
\t\t# Reparse the immutable source: each character's signature and perks are private.
\t\tvar remote_level: LevelData = LevelLoader.parse_level(source, _catalog).level
\t\tvar loadout: Dictionary = _lan.player_loadout(identity)
\t\t_apply_character_loadout(remote_level, StringName(loadout.ability_character), loadout.effects)
\t\tvar remote: BoardSim = BoardSim.new(remote_level, int(config.seed), _catalog)
\t\tvar abilities: WtAbilities = WtAbilities.new()
\t\tabilities.setup(remote_level, _catalog, remote.get_api(), StringName(loadout.ability_character), &"tournament")
\t\tabilities.set_charge_perks(loadout.effects)
\t\tremote.bind_abilities(abilities)
\t\t_network_sims[identity] = remote
\t_architecture.lifecycle(&"party_round", {"players": _network_sims.size(), "seed": config.seed})''')
sub('\t_network_state = data.get("tournament", _network_state)','\t_architecture.lifecycle(&"session_end", {"mode":"lan", "aborted":data.get("aborted",false)})\n\t_network_state = data.get("tournament", _network_state)')
sub('func _on_network_pause(value: bool) -> void:\n\t_paused = value','func _on_network_pause(value: bool) -> void:\n\t_paused = value\n\t_architecture.lifecycle(&"session_pause" if value else &"session_resume")')
sub('\t_ui.show_tournament({"profile_name": _profile_name(), "network_status": "offline"})','\t_architecture.lifecycle(&"party_leave", {"reason":reason})\n\t_ui.show_tournament(_party_menu_snapshot())')
sub('func _apply_loadout(level: LevelData) -> void:\n\tvar knobs:', 'func _apply_loadout(level: LevelData) -> void:\n\t_apply_character_loadout(level, _ability_character(), _session_effects())\n\nfunc _apply_character_loadout(level: LevelData, character: StringName, effects: Dictionary) -> void:\n\tvar knobs:')
sub('\tmatch _ability_character():','\tmatch character:')
sub('\tvar effects: Dictionary = _perk_effects() if _mode in [&"campaign", &"arcade", &"tournament"] else {}\n','')
s+='''
func _session_effects() -> Dictionary:
\tif _mode == &"lan": return _lan.player_loadout().get("effects", {})
\tif _mode == &"tournament" and not _practice_loadouts.is_empty(): return _practice_loadouts[0].effects
\treturn _perk_effects() if _mode in [&"campaign", &"arcade"] else {}

func _party_loadout(args: Dictionary = {}) -> Dictionary:
\tvar character: String = String(args.get("character", args.get("character_id", _store.get_setting("character", "c1"))))
\tvar owned: Array[String] = []
\tvar equipped: Array[String] = []
\tvar current: Array = _store.get_setting("equipped_perks", [])
\tfor row: Dictionary in _store.shop_snapshot():
\t\tif row.get("kind", "") != "perk" or not row.get("owned", false): continue
\t\towned.append(String(row.id))
\t\tif current.has(String(row.id)) and String(row.get("character", "")) == character: equipped.append(String(row.id))
\treturn {"character":character, "perks":args.get("perks", equipped), "owned_perks":owned}

func _party_menu_snapshot() -> Dictionary:
\tvar rows: Array[Dictionary] = []
\tfor item: Dictionary in _store.shop_snapshot():
\t\tif item.get("kind", "") != "perk" or not item.get("owned", false): continue
\t\tvar row: Dictionary = item.duplicate(true)
\t\trow["name"] = row.get("text", row.id)
\t\trow["equipped"] = _store.get_setting("equipped_perks", []).has(String(row.id))
\t\trows.append(row)
\treturn {"profile_name": _profile_name(), "rounds":3, "players":[{"name":_profile_name(), "character":_store.get_setting("character","c1")}, {"name":"Pip", "is_bot":true, "character":"c2"}],
\t\t"character":_store.get_setting("character","c1"), "party_perks":rows, "modes":_modes.round_modes(), "items_supported":false, "network_status":"offline"}

func _prepare_practice_loadouts(players: Array) -> bool:
\tvar loadouts: Array[Dictionary] = []
\tfor i: int in players.size():
\t\tif not players[i] is Dictionary: return false
\t\tvar request: Dictionary = _party_loadout(players[i]) if i == 0 else {"character":players[i].get("character_id",players[i].get("character","c1")), "perks":[], "owned_perks":[]}
\t\tvar checked: Dictionary = _lan.validate_loadout(request)
\t\tif not checked.get("ok",false):
\t\t\t_ui.show_toast(String(checked.get("reason","Choose a valid party loadout.")))
\t\t\treturn false
\t\tloadouts.append(checked.loadout)
\t\tplayers[i]["character"] = checked.loadout.character
\t_practice_loadouts = loadouts
\treturn true

func _architecture_context() -> Dictionary:
\treturn {"has_profile":_store != null and _store.active_profile() != null, "has_session":_sim != null or _physics != null,
\t\t"paused":_paused, "result":_result_shown, "mode":String(_mode), "level_id":String(_level_id), "screen":_ui.current_screen if _ui != null else "",
\t\t"lan_active":_lan != null and _lan.active, "lan_host":_lan != null and _lan.is_host()}

func _show_physics() -> void:
\tif _lan.active: _lan.leave()
\t_clear_session()
\t_mode = &"physics"
\t_paused = true
\t_ui.show()
\t_ui.show_physics({"selected_variant":_physics_variant})
\t_architecture.lifecycle(&"intro", {"mode":"physics"})

func _start_physics(variant: String) -> void:
\tif not WtPhysicsChallenge.VARIANTS.has(variant): return
\t_clear_session()
\t_mode = &"physics"
\t_physics_variant = variant
\t# Jolt owns native movement; dispose GUIDE's navigation as well as play context.
\t_input.dispose()
\t_physics = load("res://src/physics/wt_physics_challenge.tscn").instantiate() as WtPhysicsChallenge
\t_physics.setup({"variant":variant,"settings":_settings(),"seed":917})
\t_physics.return_requested.connect(_return_from_physics)
\t_physics.finished.connect(_on_physics_finished)
\t_ui.hide()
\t_paused = false
\t_result_shown = false
\t_store.set_playing(true)
\tadd_child(_physics)
\t_architecture.lifecycle(&"session_begin", {"mode":"physics","variant":variant})

func _on_physics_finished(result: Dictionary) -> void:
\t_result_shown = true
\t_store.set_playing(false)
\t_architecture.lifecycle(&"session_end", {"mode":"physics", "result":result})

func _return_from_physics() -> void:
\t_stop_physics()
\t_store.set_playing(false)
\t_paused = true
\t_result_shown = false
\t_ui.show()
\t_ui.show_physics({"selected_variant":_physics_variant})
\t_architecture.lifecycle(&"intro", {"mode":"physics"})

func _stop_physics() -> void:
\tif _physics == null: return
\t_physics.queue_free()
\t_physics = null
\t_input.setup(get_tree(), _settings())
\t_ui.show()
'''
out=Path('tools/godot-ai/jobs/engine-main-integration-1.json');tmp=out.with_suffix('.tmp')
tmp.write_text(json.dumps({'id':out.stem,'actions':[{'tool':'script_create','arguments':{'path':'res://src/app/main.gd','content':s}}]},indent=2));tmp.replace(out)
print(f'Queued {out}, Main {len(s)} bytes')
