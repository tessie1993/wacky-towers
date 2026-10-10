class_name WtTournamentRandomizer extends RefCounted
## Pure, reusable round-template selection. Transport and playing a round belong to the caller.
const ITEMS: Array = ["slow_time","bomb","helper_drop","preview_peek","junk_rain","fog","speed_up","spin_lock"]
const STANDING: Array = ["race_progress","score","height","alive_time"]
const HOOKS: Array = ["send","steal","shared","item"]
const SLOT_KEYS: Array = ["board_kind","spawn_entry","clear_detector","collapse","top_out_check","goal_evaluator"]
const SLOT_VALUES: Dictionary = {
 "board_kind":["grid","physics","none"],
 "spawn_entry":["none","top","frame","slide_in","crane","chute","sky_lanes","rhythm","magnet","volley","island","paint","balance"],
 "clear_detector":["none","layer","colour_connect","mono_layer"],
 "collapse":["none","slice","cascade","stack_trim","physics"],
 "top_out_check":["none","lose","trim","drops"],
 "goal_evaluator":["clear_n","height","shape","last_standing","score_timer","height_timer","height_race","path","fill_race","clear_race","puzzle_race","dock_race"]}
var errors: PackedStringArray = PackedStringArray()
var _templates: Array[Dictionary] = []
var _twists: Array[Dictionary] = []
var _catalog: GameCatalog
var _settings: Dictionary = {}

func _init(templates: Array = [], twists: Array = [], catalog: GameCatalog = null, settings: Dictionary = {}) -> void:
 _catalog=catalog
 configure(templates,twists,settings)

func configure(templates: Array,twists: Array = [],settings: Dictionary = {}) -> bool:
 errors.clear();_templates.clear();_twists.clear();_settings=settings.duplicate(true)
 var seen: Dictionary = {}
 for value: Variant in templates:
  if not value is Dictionary:
   errors.append("template must be an object");continue
  var problems: PackedStringArray = validate_template(value)
  errors.append_array(problems)
  var id: String = String(value.get("id",""))
  if seen.has(id):errors.append("duplicate template "+id)
  seen[id]=true
  if problems.is_empty():_templates.append(value.duplicate(true))
 for value: Variant in twists:
  var row: Dictionary = value.duplicate(true) if value is Dictionary else {"id":String(value),"params":{}}
  var id: StringName=StringName(String(row.get("id","")))
  if id==&"":errors.append("twist needs an id");continue
  if _catalog!=null:
   var definition: RuleDef=_catalog.rule_defs.get(id)
   if definition==null or definition.layer!=&"twist":errors.append("unknown twist "+String(id));continue
  if _twists.any(func(old:Dictionary)->bool:return String(old.id)==String(id)):continue
  row.id=String(id);row.params=row.get("params",{}).duplicate(true)
  _twists.append(row)
 return errors.is_empty()

func templates() -> Array[Dictionary]:
 return _templates.duplicate(true)

func template(id: String) -> Dictionary:
 for row: Dictionary in _templates:
  if String(row.id)==id:return row.duplicate(true)
 return {}

## Contract validation applies to non-BoardSim minigames too; it never treats them as level scripts.
func validate_template(row: Dictionary) -> PackedStringArray:
 var result: PackedStringArray=PackedStringArray()
 var id: String=String(row.get("id",""))
 for key: String in ["id","mode","category","name","rule","icon","standing_metric"]:
  if not row.get(key) is String or String(row.get(key,"")).is_empty():result.append(id+": missing "+key)
 if not ["versus","minigame"].has(row.get("category")):result.append(id+": bad category")
 if not STANDING.has(row.get("standing_metric")):result.append(id+": bad standing_metric")
 var duration: Variant=JsonNum.whole_int(row.get("duration_ms"))
 if duration==null or duration<30000 or duration>240000:result.append(id+": duration outside30..240s")
 var weight: Variant=row.get("weight",1)
 if not (weight is int or weight is float) or not is_finite(float(weight)) or float(weight)<=0.0:result.append(id+": weight must be positive")
 var slots: Variant=row.get("slots")
 if not slots is Dictionary:
  result.append(id+": missing slots")
 else:
  for key: String in SLOT_KEYS:
   if not SLOT_VALUES[key].has(slots.get(key)):result.append(id+": unsupported slot "+key)
 var interactions: Variant=row.get("interaction_hook")
 if not interactions is Array or interactions.is_empty():result.append(id+": missing interaction_hook")
 else:
  for hook: Variant in interactions:
   if not HOOKS.has(hook):result.append(id+": unknown interaction "+str(hook))
 var items: Variant=row.get("item_whitelist")
 if not items is Array:result.append(id+": missing item_whitelist")
 else:
  var seen: Dictionary={}
  for item: Variant in items:
   if not ITEMS.has(item) or seen.has(item):result.append(id+": invalid item whitelist")
   seen[item]=true
  if bool(row.get("items_enabled",false)) and items.is_empty():result.append(id+": enabled items need a whitelist")
 if bool(row.get("items_enabled",false)) and (not row.get("item_trigger") is String or String(row.get("item_trigger","none"))=="none"):result.append(id+": enabled items need a trigger")
 var limit: Variant=JsonNum.whole_int(row.get("twist_limit",0))
 if limit==null or limit<0 or limit>(1 if row.get("category")=="minigame" else 2):result.append(id+": bad twist_limit")
 var pool: Variant=row.get("piece_pool")
 if not pool is Array or pool.is_empty() or pool.size()>10:result.append(id+": piece pool needs1..10shapes")
 elif _catalog!=null:
  for shape: Variant in pool:
   if not _catalog.shapes.has_shape(StringName(str(shape))):result.append(id+": unknown shape "+str(shape))
 var board: Variant=row.get("board")
 if not board is Dictionary:result.append(id+": missing board")
 else:
  for key: String in ["width","depth","h_play"]:
   var value: Variant=JsonNum.whole_int(board.get(key))
   if value==null or value<1 or value>32:result.append(id+": invalid board "+key)
 if row.get("category")=="minigame" and (not row.get("minigame_id") is String or String(row.get("minigame_id","")).is_empty()):result.append(id+": missing minigame_id")
 if row.get("category")=="versus" and not row.get("level") is Dictionary:result.append(id+": missing versus level")
 return result

## round_index is zero based. History contains only completed rounds; a rejected card stays excluded.
func draw(seed: int, round_index: int, history: Array = [], enabled: Array = [], rejected_id: String = "", reroll_nonce: int = 0) -> Dictionary:
 if not errors.is_empty():return {"ok":false,"error":"invalid_template_library","errors":Array(errors)}
 var candidates: Array[Dictionary]=[]
 for row: Dictionary in _templates:
  if (enabled.is_empty() or enabled.has(String(row.id))) and String(row.id)!=rejected_id and bool(row.get("available",true)):candidates.append(row)
 if candidates.is_empty():return {"ok":false,"error":"no_eligible_templates"}
 var modes: Dictionary={}
 for row: Dictionary in candidates:modes[String(row.mode)]=true
 var previous: String=String(history[-1].get("mode","")) if not history.is_empty() else ""
 if modes.size()>1 and not previous.is_empty():
  candidates=candidates.filter(func(row:Dictionary)->bool:return String(row.mode)!=previous)
 var versus: Array[Dictionary]=[];var minigames: Array[Dictionary]=[]
 for row: Dictionary in candidates:
  if row.category=="minigame":minigames.append(row)
  else:versus.append(row)
 var recent: Dictionary={}
 var no_repeat: int=clampi(int(_settings.get("mg_no_repeat_rounds",3)),0,10)
 for index: int in range(maxi(0,history.size()-no_repeat),history.size()):
  var played: Dictionary=history[index]
  recent[String(played.get("template_id",played.get("mode","")))]=true
 var fresh: Array[Dictionary]=minigames.filter(func(row:Dictionary)->bool:return not recent.has(String(row.id)))
 if fresh.is_empty() and not minigames.is_empty():
  var oldest: int=2147483647
  for row: Dictionary in minigames:
   var last: int=-1
   for index: int in history.size():
    if String(history[index].get("template_id",history[index].get("mode","")))==String(row.id):last=index
   if last<oldest:oldest=last;fresh=[row]
   elif last==oldest:fresh.append(row)
 minigames=fresh
 var rng:=Seeds.make_rng(seed,["tournament_pick",round_index,reroll_nonce])
 var share: float=clampf(float(_settings.get("minigame_share",0.4)),0.0,1.0)
 var category: String="minigame" if rng.randf()<share else "versus"
 if minigames.is_empty():category="versus"
 elif versus.is_empty():category="minigame"
 var pool: Array[Dictionary]=minigames if category=="minigame" else versus
 if pool.is_empty():return {"ok":false,"error":"no_eligible_templates"}
 var weights:=PackedInt32Array()
 for row: Dictionary in pool:weights.append(maxi(1,roundi(float(row.get("weight",1))*100000)))
 var chosen: Dictionary=pool[Seeds.weighted_pick(rng,weights)].duplicate(true)
 var twists: Array[Dictionary]=_draw_twists(chosen,seed,round_index,reroll_nonce)
 return {"ok":true,"template":chosen,"template_id":chosen.id,"mode":chosen.mode,"category":category,"round_index":round_index+1,"round_seed":round_seed(seed,round_index),"twists":twists,"reroll_nonce":reroll_nonce}

static func round_seed(seed: int, round_index: int) -> int:
 return Seeds.derive(seed,["round",round_index])

static func eligible_rerolls(players: Array,used: Array,round_used: bool) -> Array:
 var result: Array=[]
 if round_used or players.size()<2:return result
 var least: int=2147483647;var most: int=-1
 for row: Dictionary in players:
  if not bool(row.get("active",true)):continue
  least=mini(least,int(row.get("wins",0)));most=maxi(most,int(row.get("wins",0)))
 if most<=least:return result
 for row: Dictionary in players:
  var id: String=String(row.id)
  if bool(row.get("active",true)) and int(row.get("wins",0))==least and not used.has(id):result.append(id)
 return result

func _draw_twists(row: Dictionary,seed: int,round_index: int,nonce: int) -> Array[Dictionary]:
 var count: int=int(row.get("twist_limit",0))
 if row.category=="versus":count=mini(count,0 if round_index==0 else 1 if round_index<3 else 2)
 var pool: Array[Dictionary]=_twists.duplicate(true);var out: Array[Dictionary]=[]
 var rng:=Seeds.make_rng(seed,["tournament_twists",round_index,nonce])
 while out.size()<count and not pool.is_empty():
  var twist: Dictionary=pool.pop_at(rng.randi_range(0,pool.size()-1))
  if _compatible(twist,row,out):out.append({"id":twist.id,"params":twist.params.duplicate(true)})
 return out

func _compatible(twist: Dictionary,row: Dictionary,selected: Array[Dictionary]) -> bool:
 var id: String=String(twist.id)
 if row.get("twist_blacklist",[]).has(id):return false
 for key: Variant in twist.get("required_slots",{}):
  if row.slots.get(key)!=twist.required_slots[key]:return false
 var mechanic_ids: Array=row.get("mechanics",[]).duplicate()
 for rule: Dictionary in row.get("level",{}).get("rules",[]):mechanic_ids.append(String(rule.id))
 for old: Variant in mechanic_ids:
  if twist.get("incompatible_with",[]).has(old):return false
  if _catalog!=null:
   var definition: RuleDef=_catalog.rule_defs.get(StringName(id))
   var prior: RuleDef=_catalog.rule_defs.get(StringName(str(old)))
   if definition!=null and definition.incompatible_with.has(str(old)):return false
   if prior!=null and prior.incompatible_with.has(id):return false
 for old: Dictionary in selected:
  if old.id==id or twist.get("incompatible_with",[]).has(old.id) or old.get("incompatible_with",[]).has(id):return false
  if _catalog!=null:
   var definition: RuleDef=_catalog.rule_defs.get(StringName(id))
   var prior: RuleDef=_catalog.rule_defs.get(StringName(String(old.id)))
   if definition!=null and definition.incompatible_with.has(String(old.id)):return false
   if prior!=null and prior.incompatible_with.has(id):return false
 return true
