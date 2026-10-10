class_name Spawner extends RefCounted
## Next-piece sequence from LevelData.pieces. Pure; randomness only via Seeds (ADR-0006).
## Usage: var sp := Spawner.new(level.pieces, 3, round_seed); var id: StringName = sp.next()

var _shapes: PackedStringArray
var _copies: Dictionary = {}  ## id -> int copies per bag
var _opening_set: PackedStringArray
var _opening_left: int = 0
var _open_part: int = 0
var _open_buf: Array[StringName] = []
var _bag_buf: Array[StringName] = []
var _bag_index: int = 0
var _seed: int
var _lookahead: int
var _queue: Array[StringName] = []
var _drawn: int = 0
var _fixed_list: PackedStringArray = PackedStringArray()
var _fixed_index: int = 0
var _fixed_mode: bool = false
var _kit: PackedStringArray = PackedStringArray()
var _kit_mode: bool = false
var _queue_info: Array[Dictionary] = []
var _generated_info: Dictionary = {}
var _last_dealt_info: Dictionary = {}
var _bag_size: int = 0
var _fixed_tags: Array = []
var _mode: StringName = &"bag"
var _history_len: int = 4
var _history_tries: int = 4
var _history: Array[StringName] = []
var _random_rng: RandomNumberGenerator
var _weights: PackedInt32Array = PackedInt32Array()
var _generated_count: int = 0


## pieces = {shapes: PackedStringArray, weights: Dictionary (id -> int copies or float weight,
## missing = 1), opening_set: PackedStringArray, opening_count: int}; lookahead >= 1.
func _init(pieces: Dictionary, lookahead: int, round_seed: int, settings: Dictionary = {}) -> void:
	_seed = round_seed
	_random_rng = Seeds.make_rng(round_seed, ["spawn_random"])
	configure(settings)
	_kit = PackedStringArray(pieces.get("kit", []))
	_kit_mode = not _kit.is_empty()
	_fixed_mode = pieces.has("fixed_list") and not pieces["fixed_list"].is_empty()
	_fixed_list = PackedStringArray(pieces.get("fixed_list", []))
	_fixed_tags = pieces.get("fixed_tags", [])
	_lookahead = maxi(1, lookahead)
	_shapes = pieces.get("shapes", PackedStringArray())
	_copies = weights_to_copies(_shapes, pieces.get("weights", {}))
	for id: String in _shapes:
		_weights.append(maxi(0, roundi(_weight(pieces.get("weights", {}), id) * 100000)))
	_opening_set = pieces.get("opening_set", PackedStringArray())
	_opening_left = maxi(0, int(pieces.get("opening_count", 0))) if not _opening_set.is_empty() else 0
	while not _kit_mode and _queue.size() < _lookahead:
		_queue.append(_generate())
		_queue_info.append(_generated_info.duplicate())


## Spawner GDD F1 (G3): copies_i = max(1, round(w_i / w_min)) over positive weights; weight <= 0 = never.
## Applied to int and float weights alike (JSON numbers arrive as floats, so int/float cannot be told apart).
## Weight keys may be String or StringName (LevelData uses StringName). Returns {id: int copies}.
## No bag_max_size scaling here (ponytail: add when a level needs it).
static func weights_to_copies(shapes: PackedStringArray, weights: Dictionary) -> Dictionary:
	var w_min: float = INF
	for id: String in shapes:
		var w: float = _weight(weights, id)
		if w > 0.0:
			w_min = minf(w_min, w)
	var out: Dictionary = {}
	for id: String in shapes:
		var w: float = _weight(weights, id)
		out[id] = maxi(1, roundi(w / w_min)) if w > 0.0 else 0
	return out


static func _weight(weights: Dictionary, id: String) -> float:
	return float(weights.get(StringName(id), weights.get(id, 1)))


## Pops the head of the queue and tops it up to lookahead. Returns &"" if no piece can be dealt.
func next() -> StringName:
	if _kit_mode or _queue.is_empty():
		return &""
	var head: StringName = _queue.pop_front()
	_last_dealt_info = _queue_info.pop_front()
	if _queue.size() < _lookahead:
		_queue.append(_generate())
		_queue_info.append(_generated_info.duplicate())
	_drawn += 1
	return head


## First min(n, lookahead) upcoming ids, head first. Does not consume.
func peek(n: int) -> PackedStringArray:
	if _kit_mode:
		return _kit.slice(0, maxi(0, n))
	var out: PackedStringArray = PackedStringArray()
	for i: int in mini(maxi(n, 0), _queue.size()):
		if _queue[i] != &"":
			out.append(String(_queue[i]))
	return out


## Number of pieces handed out by next().
func drawn_count() -> int:
	return _drawn


func _generate() -> StringName:
	_generated_info = {"id": -1, "size": 0, "index": _generated_count, "stream_index": _generated_count}
	var id: StringName = _generate_entry()
	if id != &"":
		_history.append(id)
		if _history.size() > 8:
			_history.pop_front()
		_generated_count += 1
	return id


func _generate_entry() -> StringName:
	if _fixed_mode:
		if _fixed_index >= _fixed_list.size():
			return &""
		var id: StringName = StringName(_fixed_list[_fixed_index])
		_generated_info["index"] = _fixed_index
		if _fixed_index < _fixed_tags.size():
			_generated_info["tags"] = PackedStringArray(_fixed_tags[_fixed_index])
		_fixed_index += 1
		return id
	if _opening_left > 0:
		if _open_buf.is_empty():
			for id: String in _opening_set:
				_open_buf.append(StringName(id))
			Seeds.shuffle(Seeds.make_rng(_seed, ["spawn_open", _open_part]), _open_buf)
			_open_part += 1
		_opening_left -= 1
		return _open_buf.pop_back()
	if _mode != &"bag":
		var h_eff: int = mini(_history_len, maxi(0, _positive_shape_count() - 1))
		var recent: Array[StringName] = _history.slice(maxi(0, _history.size() - h_eff))
		for attempt: int in _history_tries if _mode == &"history" else 1:
			var selected: int = Seeds.weighted_pick(_random_rng, _weights)
			if selected < 0:
				return &""
			var picked: StringName = StringName(_shapes[selected])
			if not recent.has(picked) or attempt == _history_tries - 1 or _mode == &"random":
				return picked
	if _bag_buf.is_empty():
		for id: String in _shapes:
			for c: int in int(_copies.get(id, 0)):
				_bag_buf.append(StringName(id))
		if _bag_buf.is_empty():
			push_error("Spawner: empty bag (no shapes with weight > 0)")
			return &""
		Seeds.shuffle(Seeds.make_rng(_seed, ["spawn_bag", _bag_index]), _bag_buf)
		_bag_index += 1
		_bag_size = _bag_buf.size()
	_generated_info.merge({"id": _bag_index - 1, "size": _bag_size, "index": _bag_size - _bag_buf.size()}, true)
	return _bag_buf.pop_back()


## New randomizer settings affect future generation; the visible queue remains unchanged.
func configure(settings: Dictionary) -> void:
	var mode: StringName = StringName(settings.get(&"spawn.randomizer", settings.get("randomizer", "bag")))
	_mode = mode if mode in [&"bag", &"history", &"random"] else &"bag"
	_history_len = clampi(int(settings.get(&"spawn.history_len", settings.get("history_len", 4))), 0, 8)
	_history_tries = clampi(int(settings.get(&"spawn.history_tries", settings.get("history_tries", 4))), 1, 8)


func _positive_shape_count() -> int:
	var count: int = 0
	for weight: int in _weights:
		if weight > 0:
			count += 1
	return count

## Adds predetermined pieces ahead of the preview. Example: sp.inject_front(PackedStringArray(["cube"]))
func inject_front(ids: PackedStringArray, metadata: Array[Dictionary] = []) -> void:
	for i: int in range(ids.size() - 1, -1, -1):
		_queue.push_front(StringName(ids[i]))
		var info: Dictionary = metadata[i].duplicate(true) if i < metadata.size() else {}
		info.merge({"id": -1, "size": 0, "index": -1, "stream_index": -1, "injected": true}, true)
		_queue_info.push_front(info)

## Stable queue/RNG counters for deterministic replay checking. Example: sp.snapshot().
func snapshot() -> Dictionary:
	return {"queue": _queue, "bag": _bag_buf, "bag_index": _bag_index,
		"opening_left": _opening_left, "open_part": _open_part, "open_buf": _open_buf, "drawn": _drawn, "fixed_index": _fixed_index,
		"kit": _kit, "queue_info": _queue_info, "last_dealt_info": _last_dealt_info, "bag_size": _bag_size,
		"mode": _mode, "history": _history, "history_len": _history_len, "history_tries": _history_tries,
		"random_rng": _random_rng.state, "generated_count": _generated_count}

func restore(state: Dictionary) -> void:
	_queue.assign(state["queue"])
	_bag_buf.assign(state["bag"])
	_bag_index = state["bag_index"]
	_opening_left = state["opening_left"]
	_open_part = state["open_part"]
	_open_buf.assign(state["open_buf"])
	_drawn = state["drawn"]
	_fixed_index = state["fixed_index"]
	_kit = state.get("kit", PackedStringArray()).duplicate()
	_queue_info.assign(state.get("queue_info", []))
	_last_dealt_info = state.get("last_dealt_info", {}).duplicate()
	_bag_size = int(state.get("bag_size", 0))
	_mode = StringName(state.get("mode", "bag"))
	_history.assign(state.get("history", []))
	_history_len = int(state.get("history_len", 4))
	_history_tries = int(state.get("history_tries", 4))
	_random_rng.state = state.get("random_rng", _random_rng.state)
	_generated_count = int(state.get("generated_count", 0))

func is_kit() -> bool:
	return _kit_mode

func kit_remaining() -> PackedStringArray:
	return _kit.duplicate()

func choose(id: StringName) -> bool:
	var index: int = _kit.find(String(id))
	if not _kit_mode or index < 0:
		return false
	_kit.remove_at(index)
	_last_dealt_info = {"id": -1, "size": 0, "index": _drawn, "kit": true}
	_drawn += 1
	return true

func last_bag_info() -> Dictionary:
	return _last_dealt_info.duplicate()


## Replace queued entries in place; generator counters and future bag remain unchanged. Example: sp.replace_preview(ids).
func replace_preview(ids: PackedStringArray) -> void:
	for i: int in mini(ids.size(), _queue.size()):
		_queue[i] = StringName(ids[i])
