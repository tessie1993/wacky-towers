class_name EventCardRule extends RuleBehaviour
## EV15: one telegraphed gadget at a time; all randomness uses this rule's stream.
const PLUGIN_ID := &"event_card"
var _locks: int = 0
var _deck: Array[int] = []
var _card: Dictionary = {}
var _cell: Vector3i = Vector3i(-1,-1,-1)
var _gust_due: int = 0
var _slide: bool = false
var _direction: Vector3i = Vector3i.RIGHT
func subscribed_hooks() -> Array[StringName]:
	return [&"on_resolve_end",&"on_spawn",&"on_tick",&"on_land"]
func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var every: int = maxi(2,int(api.param(&"event_card_locks",6)))
	if hook == &"on_resolve_end":
		_locks += 1
		if _locks % every == every-1: _draw(api)
		elif _locks % every == 0 and not _card.is_empty():
			match String(_card.get("event","")):
				"gust":
					_gust_due = -1
					api.emit(&"gust_warning",{"message":"Party horn — wind on the next piece!","direction":_direction})
				"drop":
					if api.is_free(_cell):
						api.set_cell(_cell,api.kind_of(&"starter"))
						api.emit(&"gadget_drop",{"cell":_cell,"card":_card.card})
				"slide": _slide = true
			api.emit(&"gadget_card",_card.duplicate(true))
			_card.clear()
	elif hook == &"on_spawn" and _gust_due == -1:
		var config: Dictionary = api.param(&"gust",{})
		_gust_due = api.now_ms()+int(config.get("wind_warn_ms",1000))
	elif hook == &"on_tick" and _gust_due > 0 and api.now_ms() >= _gust_due:
		_gust_due = 0
		var config: Dictionary = api.param(&"gust",{})
		for i: int in clampi(int(config.get("wind_strength",1)),1,3): api.try_translate(_direction)
		api.emit(&"gust",{"direction":_direction,"strength":1})
	elif hook == &"on_land" and _slide:
		_slide = false
		var config: Dictionary = api.param(&"slide",{})
		var moved: int = 0
		for i: int in clampi(int(config.get("slide_cells",1)),1,2):
			if int(api.try_translate(Vector3i(0,0,1)).get("result",1)) != Movement.Result.OK: break
			moved += 1
		api.emit(&"ice_slide",{"direction":Vector3i(0,0,1),"cells":moved})
func _draw(api: RuleApi) -> void:
	var pool: Array = api.param(&"pool",[])
	if pool.is_empty(): return
	if _deck.is_empty():
		for i: int in pool.size(): _deck.append(i)
	var index: int = api.rng().randi_range(0,_deck.size()-1)
	_card = pool[_deck.pop_at(index)].duplicate(true)
	var directions: Array[Vector3i] = [Vector3i.LEFT,Vector3i.RIGHT,Vector3i(0,0,-1),Vector3i(0,0,1)]
	_direction = directions[api.rng().randi_range(0,3)]
	_cell = Vector3i(-1,-1,-1)
	if _card.get("event","") == "drop":
		var options: Array[Vector3i] = []
		for cell: Vector3i in MechanicsCells.all(api):
			if api.layer_of(cell) < api.limit_layer() and api.is_free(cell) and (not api.is_active(cell+api.down_vector()) or not api.is_free(cell+api.down_vector())): options.append(cell)
		if not options.is_empty(): _cell = options[api.rng().randi_range(0,options.size()-1)]
	api.emit(&"gadget_warning",{"card":_card.get("card",""),"event":_card.get("event",""),"cell":_cell,"locks_left":1})
func snapshot() -> Dictionary:
	return {"locks":_locks,"deck":_deck.duplicate(),"card":_card.duplicate(true),"cell":_cell,"gust_due":_gust_due,"slide":_slide,"direction":_direction}
