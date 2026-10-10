class_name FpBag
extends RefCounted
## Seeded piece queue: opening set in order, then 7-bag style shuffles of the shape list.

var _shapes: PackedStringArray
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _queue: Array[String] = []


func _init(shapes: PackedStringArray, opening: PackedStringArray, rng_seed: int) -> void:
	_shapes = shapes
	_rng.seed = rng_seed
	for s: String in opening:
		_queue.append(s)


## Pop and return the next shape id ("" if the shape list is empty).
func next() -> String:
	_fill(1)
	if _queue.is_empty():
		return ""
	return _queue.pop_front()


## The next n shape ids without consuming them.
func peek(n: int) -> PackedStringArray:
	_fill(n)
	var out: PackedStringArray = PackedStringArray()
	for i: int in mini(n, _queue.size()):
		out.append(_queue[i])
	return out


func _fill(n: int) -> void:
	if _shapes.is_empty():
		return
	while _queue.size() < n:
		var bag: Array[String] = []
		for s: String in _shapes:
			bag.append(s)
		for i: int in range(bag.size() - 1, 0, -1):
			var j: int = _rng.randi_range(0, i)
			var tmp: String = bag[i]
			bag[i] = bag[j]
			bag[j] = tmp
		_queue.append_array(bag)
