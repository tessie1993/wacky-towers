class_name StarCoinsRule extends RuleBehaviour
## W8: coins float in empty cells (state only); covering one with a lock collects it.
const PLUGIN_ID := &"star_coins"
var _coins: Array[Vector3i] = []
var _pending: Array[int] = []
var _round_key: int = -1


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_lock", &"on_clear", &"on_resolve_end", &"on_tick"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	match hook:
		&"on_level_start":
			_start(api)
		&"on_clear":
			var key: int = int(ctx.data.get("clear_count", 0))
			if key != _round_key:
				_flush(api)
				_round_key = key
			var layer: int = int(ctx.data.get("layer", -1))
			if not _pending.has(layer):
				_pending.append(layer)
		&"on_lock":
			_flush(api)
			var cells: Array = ctx.data.get("cells", [])
			var hit: Array[Vector3i] = []
			for coin: Vector3i in _coins:
				if cells.has(coin):
					hit.append(coin)
			for coin: Vector3i in hit:
				_coins.erase(coin)
				_collect(api, coin)
			if not hit.is_empty():
				api.emit(&"coins_state", {"cells": _coins.duplicate()})
		_:
			_flush(api)


func _start(api: RuleApi) -> void:
	_coins.clear()
	_pending.clear()
	_round_key = -1
	var candidates: Array[Vector3i] = []
	var first: int = maxi(0, int(api.param(&"min_layer", 1)))
	var last: int = api.limit_layer() - 2
	for c: Vector3i in MechanicsCells.all(api):
		var layer: int = api.layer_of(c)
		if layer >= first and layer <= last and api.kind_at(c) == 0:
			candidates.append(c)
	var wanted: int = maxi(0, int(api.param(&"coins", 5)))
	while _coins.size() < wanted and not candidates.is_empty():
		var at: int = 0 if candidates.size() == 1 else api.rng().randi_range(0, candidates.size() - 1)
		_coins.append(candidates[at])
		candidates.remove_at(at)
	api.emit(&"coins_state", {"cells": _coins.duplicate()})


## Apply the layer shift for the clear round(s) seen since the last flush.
func _flush(api: RuleApi) -> void:
	if _pending.is_empty():
		return
	var down: Vector3i = api.down_vector()
	var kept: Array[Vector3i] = []
	var collected: Array[Vector3i] = []
	for coin: Vector3i in _coins:
		var layer: int = api.layer_of(coin)
		if _pending.has(layer):
			collected.append(coin)
			continue
		var below: int = 0
		for cleared: int in _pending:
			if cleared < layer:
				below += 1
		kept.append(coin + down * below)
	_pending.clear()
	_coins = kept
	for coin: Vector3i in collected:
		_collect(api, coin)
	api.emit(&"coins_state", {"cells": _coins.duplicate()})


func _collect(api: RuleApi, coin: Vector3i) -> void:
	api.request_score(int(api.param(&"score", 50)))
	api.add_goal_counter(StringName(String(api.param(&"goal_counter", "coins"))))
	api.emit(&"coin_collected", {"cell": coin, "remaining": _coins.size()})


func snapshot() -> Dictionary:
	return {"coins": _coins.duplicate(), "pending": _pending.duplicate(), "round_key": _round_key}
