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


## pieces = {shapes: PackedStringArray, weights: Dictionary (id -> int copies or float weight,
## missing = 1), opening_set: PackedStringArray, opening_count: int}; lookahead >= 1.
func _init(pieces: Dictionary, lookahead: int, round_seed: int) -> void:
	_seed = round_seed
	_lookahead = maxi(1, lookahead)
	_shapes = pieces.get("shapes", PackedStringArray())
	_copies = weights_to_copies(_shapes, pieces.get("weights", {}))
	_opening_set = pieces.get("opening_set", PackedStringArray())
	_opening_left = maxi(0, int(pieces.get("opening_count", 0))) if not _opening_set.is_empty() else 0
	while _queue.size() < _lookahead:
		_queue.append(_generate())


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
	var head: StringName = _queue.pop_front()
	_queue.append(_generate())
	_drawn += 1
	return head


## First min(n, lookahead) upcoming ids, head first. Does not consume.
func peek(n: int) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for i: int in mini(maxi(n, 0), _queue.size()):
		out.append(String(_queue[i]))
	return out


## Number of pieces handed out by next().
func drawn_count() -> int:
	return _drawn


func _generate() -> StringName:
	if _opening_left > 0:
		if _open_buf.is_empty():
			for id: String in _opening_set:
				_open_buf.append(StringName(id))
			Seeds.shuffle(Seeds.make_rng(_seed, ["spawn_open", _open_part]), _open_buf)
			_open_part += 1
		_opening_left -= 1
		return _open_buf.pop_back()
	if _bag_buf.is_empty():
		for id: String in _shapes:
			for c: int in int(_copies.get(id, 0)):
				_bag_buf.append(StringName(id))
		if _bag_buf.is_empty():
			push_error("Spawner: empty bag (no shapes with weight > 0)")
			return &""
		Seeds.shuffle(Seeds.make_rng(_seed, ["spawn_bag", _bag_index]), _bag_buf)
		_bag_index += 1
	return _bag_buf.pop_back()
