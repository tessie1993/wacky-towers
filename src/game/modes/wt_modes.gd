class_name WtModes extends RefCounted
## Tournament selection and standings are transport-independent; applications execute the descriptor.
const LEGACY_MODES: Dictionary={"height_race":"build_race","gust_race":"clear_race","conveyor_race":"clear_race","ice_race":"clear_race","fog_race":"clear_race"}
var _content: WtContent
var _config: Dictionary={}
var _economy: Dictionary={}
var _state: Dictionary={}
var _lobby_completed: int=0
var _round_pool: Array=[]
var _legacy_presets: Dictionary={}
var _library: Array=[]
var _twist_pool: Array=[]
var _randomizer: WtTournamentRandomizer
var last_error: String=""

func _init(content: WtContent=null) -> void:
 _content=content
 _config=_read("res://assets/data/meta/modes.json")
 _economy=_read("res://assets/data/meta/economy.json")
 _library=_read("res://assets/data/tournament/templates.json").get("templates",[])
 _twist_pool=[{"id":"gust","params":{}},{"id":"fog","params":{}},{"id":"ice_slide","params":{}},{"id":"wobble","params":{}},{"id":"stopwatch","params":{}}]
 _randomizer=WtTournamentRandomizer.new(_library,_twist_pool,_content.catalog if _content!=null else null,_read("res://assets/data/tournament/randomizer.json"))

func round_modes() -> Array:
 return _library.map(func(row:Dictionary)->String:return String(row.id))

func round_cards() -> Array:
 return _library.duplicate(true)

## Canonical ids are weighted once. Legacy race names are presets, never duplicate categories.
func set_round_pool(ids: Array) -> bool:
 if ids.is_empty():return false
 var accepted: Array=[];var presets: Dictionary={};var canonical: Array=round_modes()
 for id: Variant in ids:
  var value: String=String(id)
  if not canonical.has(value) and not LEGACY_MODES.has(value):return false
  var mapped: String=String(LEGACY_MODES.get(value,value))
  if not accepted.has(mapped):accepted.append(mapped)
 for id: Variant in ids:
  var value: String=String(id)
  if LEGACY_MODES.has(value):
   var mapped: String=String(LEGACY_MODES[value])
   if not ids.has(mapped) and not presets.has(mapped):presets[mapped]=value
 _round_pool=accepted;_legacy_presets=presets
 return true

## Host supplies the encountered compatible twist pool, retaining its authored parameters.
func set_tournament_twists(rows: Array) -> bool:
 var settings: Dictionary=_read("res://assets/data/tournament/randomizer.json")
 if not _randomizer.configure(_library,rows,settings):
  last_error="invalid_twist_pool";return false
 _twist_pool=rows.duplicate(true)
 return true

## Makes an endless Arcade level with the selected skin; star currency is never paid by Arcade.
func arcade_level(biome: String = "meadow", seed: int = -1) -> LevelData:
	var cfg: Dictionary = _config.arcade
	var source: Dictionary = _base("arcade_" + biome, biome, seed)
	source.board = {"width": cfg.width, "depth": cfg.depth, "h_play": cfg.h_play}
	source.pieces = {"shapes": cfg.standard_shapes}
	source.goal = {"type": "endless"}
	source.rules = [item_rule()]
	source.knobs.merge({"fall.g0": cfg.g0, "fall.ramp_per_clear": cfg.ramp_per_clear, "fall.g_max": cfg.g_max, "goal.warnings_max": cfg.warnings_max}, true)
	return _parse(source)

## Deterministic compatible twist draw; only encountered supported twist ids enter the pool.
func arcade_twists(layers: int, pool: Array, seed: int) -> Array:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = Seeds.derive(seed, ["arcade_twists", layers / int(_config.arcade.twist_rotation_layers)])
	var choices: Array = pool.duplicate()
	var out: Array = []
	var count: int = mini(choices.size(), 1 if layers < int(_config.arcade.two_twists_after) else 2)
	while out.size() < count and not choices.is_empty():
		var candidate: Variant = choices.pop_at(rng.randi_range(0, choices.size() - 1))
		var definition: RuleDef = _content.catalog.rule_defs.get(StringName(str(candidate))) if _content != null else null
		if definition == null or definition.layer != &"twist":
			continue
		var compatible: bool = true
		for old: String in out:
			var prior: RuleDef = _content.catalog.rule_defs.get(StringName(old))
			if definition.incompatible_with.has(old) or (prior != null and prior.incompatible_with.has(str(candidate))): compatible = false
		if compatible: out.append(candidate)
	return out

## Players are real participant records; bots and network transport are separate application features.
func start_tournament(players: Array,rounds: int=3,seed: int=1,modes: Array=[],options: Dictionary={}) -> Dictionary:
 if not modes.is_empty() and not set_round_pool(modes):return {"ok":false,"error":"invalid_round_pool"}
 if players.size()<2 or players.size()>4 or not _config.tournament.lengths.has(rounds):return {"ok":false,"error":"invalid_tournament_configuration"}
 if not _randomizer.errors.is_empty():return {"ok":false,"error":"invalid_template_library","errors":Array(_randomizer.errors)}
 var rows: Array=[];var ids: Dictionary={}
 for index: int in players.size():
  var source: Dictionary=players[index] if players[index] is Dictionary else {"name":String(players[index])}
  var id: String=String(source.get("id",index))
  if id.is_empty() or ids.has(id):return {"ok":false,"error":"duplicate_player"}
  ids[id]=true
  rows.append({"id":id,"index":index,"name":String(source.get("name","Builder %d"%(index+1))),"character":String(source.get("character","c1")),"wins":0,"score":0,"layers":0,"streak":0,"active":true})
 _state={"ok":true,"phase":"round_pick","rounds":rounds,"majority":rounds/2+1,"round_index":0,"seed":seed,"players":rows,"history":[],"sudden_death":false,"contenders":[],"winners":[],"mode":"","draw":{},"reroll_used_players":[],"round_reroll_used":false,"items_enabled":bool(options.get("items_enabled",true))}
 return tournament_snapshot()

func standings() -> Array:
 var rows: Array=_state.get("players",[]).duplicate(true)
 rows.sort_custom(func(a:Dictionary,b:Dictionary)->bool:return a.wins>b.wins or (a.wins==b.wins and (a.score>b.score or (a.score==b.score and a.get("index",0)<b.get("index",0)))))
 return rows

func tournament_snapshot() -> Dictionary:
 var snapshot: Dictionary=_state.duplicate(true)
 snapshot.standings=standings();snapshot.round_cards=round_cards();snapshot.selected_modes=(_round_pool if not _round_pool.is_empty() else round_modes()).duplicate()
 return snapshot

## Showing the same card twice never draws twice. Only completed rounds enter no-repeat history.
func draw_next_round() -> Dictionary:
 if not _state.get("ok",false) or _state.get("phase")=="finished":return {"ok":false,"error":"tournament_not_running"}
 if _state.phase in ["round_show","round_play"]:return current_round()
 var pick: Dictionary
 if _state.sudden_death:
  var template: Dictionary=_randomizer.template("clear_race")
  template.level.goal={"type":"clear_n","n":int(_config.tournament.sudden_death_layers)}
  template.level.rules=[];template.items_enabled=false;template.item_whitelist=[];template.twist_limit=0
  template.name="Sudden Death";template.rule="Clear one layer to decide the tournament."
  pick={"ok":true,"template":template,"template_id":"clear_race","mode":"clear_race","category":"versus","round_index":int(_state.round_index)+1,"round_seed":WtTournamentRandomizer.round_seed(int(_state.seed),int(_state.round_index)),"twists":[],"reroll_nonce":0}
 else:
  pick=_randomizer.draw(int(_state.seed),int(_state.round_index),_state.history,_round_pool)
 if not pick.get("ok",false):return pick
 _state.round_reroll_used=false;_state.draw=pick;_state.phase="round_show"
 _state.mode=String(_legacy_presets.get(String(pick.mode),pick.mode)) if not _state.sudden_death else "clear_race"
 return current_round()

func current_round() -> Dictionary:
 var draw: Dictionary=_state.get("draw",{}).duplicate(true)
 if draw.is_empty():return {"ok":false,"error":"no_round_drawn"}
 draw.phase=_state.phase
 draw.reroll_eligible=[] if _state.sudden_death else WtTournamentRandomizer.eligible_rerolls(_state.players,_state.reroll_used_players,bool(_state.round_reroll_used))
 draw.items_enabled=bool(_state.items_enabled) and bool(draw.template.items_enabled)
 draw.time_cap_ms=mini(int(draw.template.duration_ms),int(_config.tournament.round_time_cap_ms))
 draw.contenders=_state.contenders.duplicate();draw.sudden_death=_state.sudden_death
 if _legacy_presets.has(String(draw.mode)) and not _state.sudden_death:draw.legacy_preset=String(_legacy_presets[String(draw.mode)])
 return draw

## One trailing-player spend per tournament, first accepted spend only per round; rejection costs nothing.
func reroll_round(player_id: String) -> Dictionary:
 if _state.get("phase")!="round_show":return {"ok":false,"error":"reroll_window_closed"}
 var current: Dictionary=current_round()
 if not current.reroll_eligible.has(player_id):return {"ok":false,"error":"not_eligible"}
 var pick: Dictionary=_randomizer.draw(int(_state.seed),int(_state.round_index),_state.history,_round_pool,String(current.template_id),1)
 if not pick.get("ok",false):return pick
 _state.reroll_used_players.append(player_id);_state.round_reroll_used=true;_state.draw=pick
 _state.mode=String(_legacy_presets.get(String(pick.mode),pick.mode))
 return current_round()

func lock_round() -> Dictionary:
 if _state.get("phase")!="round_show":return {"ok":false,"error":"round_not_showing"}
 _state.phase="round_play"
 return current_round()

## BoardSim source for the four versus modes. Custom minigames use the complete descriptor directly.
func round_level(descriptor: Dictionary={}) -> LevelData:
 var draw: Dictionary=current_round() if descriptor.is_empty() else descriptor
 if not draw.get("ok",false) or draw.get("category")!="versus":return null
 var source: Dictionary=draw.template.level.duplicate(true)
 source.id="round_%d"%int(draw.round_index);source.seed=int(draw.round_seed)
 var rules: Array=source.get("rules",[])
 var preset: String=String(draw.get("legacy_preset",""))
 if preset=="height_race":source.goal.h_target=6
 var fixed: Dictionary={}
 match preset:
  "gust_race":fixed={"id":"gust","params":{"wind_dir":"+x","wind_interval_ms":7000,"wind_strength":1}}
  "conveyor_race":fixed={"id":"mill_belt","params":{"conveyor_dir":"+x","conveyor_every":3,"conveyor_wrap":true}}
  "ice_race":fixed={"id":"ice_slide","params":{}}
  "fog_race":fixed={"id":"fog","params":{}}
 if not fixed.is_empty():rules.append(fixed)
 var seen: Dictionary={};var twists: int=0
 for row: Dictionary in rules:
  seen[String(row.id)]=true
  if _content!=null and _content.catalog.rule_defs.has(StringName(row.id)) and _content.catalog.rule_defs[StringName(row.id)].layer==&"twist":twists+=1
 for row: Dictionary in draw.get("twists",[]):
  if not seen.has(String(row.id)) and twists<2:rules.append({"id":row.id,"params":row.params.duplicate(true)});seen[String(row.id)]=true;twists+=1
 if bool(draw.get("items_enabled",false)):
  var item: Dictionary=item_rule()
  item.params.table=item.params.table.filter(func(row:Dictionary)->bool:return draw.template.item_whitelist.has(String(row.id)))
  rules.append(item)
 source.rules=rules
 return _parse(source)

## Compatibility entry point for callers that still execute BoardSim-only rounds.
func next_round_level() -> LevelData:
 var draw: Dictionary=draw_next_round()
 if not draw.get("ok",false):return null
 if _state.phase=="round_show":draw=lock_round()
 return round_level(draw)

## Rows: id,won,ms,standing_value (or progress),score,layers,alive,active.
func record_round(results: Array) -> Dictionary:
 if _state.get("phase")!="round_play":return {"ok":false,"error":"round_not_playing"}
 var eligible: Array=[];var seen: Dictionary={};var players: Dictionary={}
 for player: Dictionary in _state.players:players[String(player.id)]=player
 for result: Dictionary in results:
  var id: String=String(result.get("id",""))
  if not players.has(id) or seen.has(id):return {"ok":false,"error":"invalid_result_player"}
  seen[id]=true
  if bool(result.get("active",true)) and (not _state.sudden_death or _state.contenders.has(id)):eligible.append(result)
 if eligible.is_empty():return {"ok":false,"error":"no_results"}
 var template: Dictionary=_state.draw.template
 var goal: String=String(template.slots.goal_evaluator)
 var timed: bool=goal in ["score_timer","height_timer","last_standing"]
 var earliest: int=2147483647
 if not timed:
  for row: Dictionary in eligible:
   if bool(row.get("won",false)):earliest=mini(earliest,maxi(0,int(row.get("ms",0))))
 var best: float=-INF;var best_secondary: float=-INF;var winners: Array=[]
 var living: Array=eligible.filter(func(row:Dictionary)->bool:return bool(row.get("alive",true)))
 if goal=="last_standing" and living.size()==1:
  winners=[String(living[0].id)]
 elif earliest!=2147483647:
  for row: Dictionary in eligible:
   if bool(row.get("won",false)) and maxi(0,int(row.get("ms",0)))==earliest:winners.append(String(row.id))
 else:
  for row: Dictionary in eligible:
   var metric: float=_metric(row,String(template.standing_metric))
   var secondary: float=_metric(row,String(template.get("standing_tiebreak","score")))
   if metric>best or (is_equal_approx(metric,best) and secondary>best_secondary):best=metric;best_secondary=secondary;winners=[String(row.id)]
   elif is_equal_approx(metric,best) and is_equal_approx(secondary,best_secondary):winners.append(String(row.id))
 for player: Dictionary in _state.players:
  var won: bool=winners.has(String(player.id));player.wins+=1 if won else 0;player.streak=player.streak+1 if won else 0
  for row: Dictionary in results:
   if String(row.id)==String(player.id):player.score+=int(row.get("score",0));player.layers+=int(row.get("layers",0));player.active=bool(row.get("active",true))
 _state.history.append({"template_id":_state.draw.template_id,"mode":_state.draw.mode,"category":_state.draw.category,"round_seed":_state.draw.round_seed,"twists":_state.draw.twists.duplicate(true),"winners":winners,"results":results.duplicate(true)})
 _state.round_index+=1
 var majority: Array=[]
 for player: Dictionary in _state.players:
  if int(player.wins)>=int(_state.majority):majority.append(String(player.id))
 if _state.sudden_death and winners.size()==1:_finish(winners)
 elif not _state.sudden_death and majority.size()==1:_finish(majority)
 elif majority.size()>1:_state.sudden_death=true;_state.contenders=majority;_state.phase="round_pick"
 elif int(_state.round_index)>=int(_state.rounds):
  var sorted: Array=standings();var leaders: Array=[]
  for row: Dictionary in sorted:
   if row.wins==sorted[0].wins:leaders.append(String(row.id))
  if leaders.size()==1:_finish(leaders)
  else:_state.sudden_death=true;_state.contenders=leaders;_state.phase="round_pick"
 else:_state.phase="round_pick"
 return tournament_snapshot()

func _metric(row: Dictionary,metric: String) -> float:
 var value: Variant
 if row.has("standing_value") and metric==String(_state.draw.template.standing_metric):value=row.standing_value
 else:
  match metric:
   "race_progress":value=row.get("progress",row.get("layers",0))
   "height":value=row.get("height",row.get("progress",0))
   "alive_time":value=row.get("alive_time",row.get("ms",0))
   _:value=row.get("score",0)
 return float(value) if (value is int or value is float) and is_finite(float(value)) else 0.0

func abort_tournament() -> Dictionary:
 _state.phase="finished";_state.winners=[];_state.aborted=true
 _state.awards=tournament_awards(int(_state.get("rounds",3)),_state.get("players",[]).size(),_lobby_completed);_state.awards.win=0
 if int(_state.get("round_index",0))<int(_state.get("majority",2)):_state.awards.finish=0
 return tournament_snapshot()

func tournament_awards(rounds: int,players: int,completed: int=0) -> Dictionary:
 var majority: int=rounds/2+1
 var base: int=roundi(float(_economy.get("tw_per_M",1))*majority*(1.0+float(_economy.get("tw_player_step",0.25))*(players-2)))
 var finish: int=maxi(int(_economy.get("finish_min",1)),roundi(float(_economy.get("finish_frac",.3))*base))
 var multiplier: float=maxf(float(_economy.get("lobby_floor",.4)),1.0-float(_economy.get("lobby_step",.15))*completed)
 return {"win":floori(base*multiplier),"finish":floori(finish*maxf(0,1.0-float(_economy.get("finish_step",.5))*completed))}

func close_lobby() -> void:
 _lobby_completed=0

func _finish(winners: Array) -> void:
 _state.winners=winners;_state.phase="finished";_state.awards=tournament_awards(int(_state.rounds),_state.players.size(),_lobby_completed);_lobby_completed+=1

func _base(id: String,biome: String,seed: int) -> Dictionary:
 return {"schema":1,"id":id,"biome":biome,"tier":1,"name":"MODE_"+id.to_upper(),"board":{"width":6,"depth":6,"h_play":12},"pieces":{"shapes":_config.arcade.standard_shapes},"knobs":{"fall.g0":1.0,"goal.top_out":"rescue","goal.warnings_max":1},"rules":[],"stars":{},"seed":seed}

func _parse(source: Dictionary) -> LevelData:
 if _content==null:return null
 var result: LoadResult=LevelLoader.parse_level(source,_content.catalog)
 _content.last_issues=result.issues
 return result.level

func _read(path: String) -> Dictionary:
 var parsed: Variant=JSON.parse_string(FileAccess.get_file_as_string(path))
 return parsed if parsed is Dictionary else {}

## An encounter survives losses; old saves also contribute successfully completed levels.
func _encountered_levels(progress: Dictionary) -> Array:
	var ids: Array = progress.get("encountered_levels", []).duplicate()
	for id: Variant in progress.get("levels", {}).keys():
		if int(progress.levels[id].get("stars", 0)) > 0 and not ids.has(str(id)): ids.append(str(id))
	return ids

## Returns trusted twist rows, retaining authored parameter bundles and filtering out level mechanics.
func encountered_arcade_rules(progress: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if _content == null: return result
	var encounters: Array = _encountered_levels(progress)
	var seen: Dictionary = {}
	for entry: Dictionary in _content.all_levels():
		if not encounters.has(str(entry.id)): continue
		for row: Dictionary in _content.raw_level(str(entry.id)).get("rules", []):
			var id: StringName = StringName(str(row.get("id", "")).trim_suffix("*"))
			var definition: RuleDef = _content.catalog.rule_defs.get(id)
			if definition == null or definition.layer != &"twist" or seen.has(id): continue
			seen[id] = true
			result.append({"id": String(id), "params": row.get("params", {}).duplicate(true)})
	# The meadow Wind card is the introductory Arcade twist even on a fresh profile.
	if result.is_empty() and _content.catalog.rule_defs.has(&"gust"):
		result.append({"id": "gust", "params": {"wind_dir": "+x", "wind_interval_ms": 7000, "wind_strength": 1}})
	return result

## Specials are unlocked by an encounter with their piece set; standard shapes are excluded.
func encountered_arcade_specials(progress: Dictionary) -> PackedStringArray:
	var result := PackedStringArray()
	if _content == null: return result
	var encounters: Array = _encountered_levels(progress)
	var standard: Array = _config.arcade.standard_shapes
	for entry: Dictionary in _content.all_levels():
		if not encounters.has(str(entry.id)): continue
		var pieces: Dictionary = _content.raw_level(str(entry.id)).get("pieces", {})
		for shape: Variant in pieces.get("shapes", []):
			var id: String = str(shape)
			if not standard.has(id) and not result.has(id) and _content.catalog.shapes.has_shape(StringName(id)):
				result.append(id)
	return result

## The trusted item table is loaded from data for real tuning, including standing bias.
func item_rule(extra_slots: int = 0) -> Dictionary:
	return {"id": "items", "params": {"enabled": true, "extra_slots": clampi(extra_slots, 0, 2),
		"table": _read("res://assets/data/items/starter.json").get("items", [])}}
