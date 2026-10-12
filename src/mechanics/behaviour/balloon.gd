class_name BalloonRule extends RuleBehaviour
## EV10: actual dealt-bag selection, half gravity, one safe bob; drop cancels the bob.
const PLUGIN_ID := &"balloon"
var _bag: int = -999
var _selected: Array[int] = []
var _active: bool = false
var _base: int = 1000
var _due: int = 0
var _warned: bool = false
var _spawn_layer: int = 0
var _soft: bool = false
func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_command", &"on_tick", &"on_lock"]
func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_spawn":
		_restore(api)
		_soft = false
		var bag: int = int(api.piece_flag(&"bag_index", -1))
		var position: int = int(api.piece_flag(&"bag_position", -1))
		var size: int = int(api.piece_flag(&"bag_size", 8))
		if bool(api.piece_flag(&"injected", false)) or bag < 0: return
		if bag != _bag:
			_bag = bag
			_selected.clear()
			var remaining: Array[int] = []
			for i: int in size: remaining.append(i)
			for i: int in mini(size, int(api.param(&"balloon_per_bag", 1))): _selected.append(remaining.pop_at(api.rng().randi_range(0,remaining.size()-1)))
		_active = _selected.has(position)
		if not _active: return
		_base = api.knob_int(&"fall.gravity_scale")
		api.request_slot(&"fall.gravity_scale", _base * roundi(float(api.param(&"balloon_g_mult",0.5))*1000) / 1000)
		_due = api.now_ms() + int(api.param(&"balloon_drift_ms",3000))
		_warned = false
		_spawn_layer = api.layer_of(api.get_piece_pivot())
		api.set_piece_flag(&"balloon", true)
		api.emit(&"balloon_spawn", {"due_ms":_due})
	elif hook == &"on_command" and _active:
		var kind: StringName = StringName(ctx.data.get("kind", ""))
		if kind == SimEvents.CMD_HARD_DROP:
			_due = 0
			_restore(api)
		elif kind == SimEvents.CMD_SOFT_DROP_ON:
			_soft = true
			api.request_slot(&"fall.gravity_scale", _base)
		elif kind == SimEvents.CMD_SOFT_DROP_OFF:
			_soft = false
			api.request_slot(&"fall.gravity_scale", _base * roundi(float(api.param(&"balloon_g_mult",0.5))*1000) / 1000)
	elif hook == &"on_tick" and _active and _due > 0:
		if not _warned and api.now_ms() >= _due-500:
			_warned = true
			api.emit(&"balloon_warning", {"due_ms":_due})
		if api.now_ms() >= _due:
			_due = 0
			if not _soft and api.layer_of(api.get_piece_pivot()) < _spawn_layer:
				var moved: Dictionary = api.try_translate(-api.down_vector())
				api.emit(&"balloon_bob", {"moved": int(moved.get("result",1))==Movement.Result.OK})
	elif hook == &"on_lock": _restore(api)
func _restore(api: RuleApi) -> void:
	if _active: api.request_slot(&"fall.gravity_scale", _base)
	_active = false
	_due = 0
func snapshot() -> Dictionary:
	return {"bag":_bag,"selected":_selected.duplicate(),"active":_active,"base":_base,"due":_due,"warned":_warned,"spawn_layer":_spawn_layer,"soft":_soft}
