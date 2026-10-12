## Pure auto-repeat (DAS/ARR) helper for held directional input.
## Fires once on press, then after [member delay] once every [member interval].
class_name RepeatTimer
extends RefCounted

## Seconds held before repeating starts.
var delay: float
## Seconds between repeats once repeating.
var interval: float

## Float slack so exact-boundary frames fire (0.1 ms).
const EPSILON: float = 0.0001

var _dir: Vector2i = Vector2i.ZERO
var _t: float = 0.0


func _init(delay_s: float = 0.17, interval_s: float = 0.05) -> void:
	delay = delay_s
	interval = maxf(interval_s, 0.001)


## Feeds this frame's held direction; returns how many moves to emit (0..n).
## A changed direction counts as a fresh press.
func update(dir: Vector2i, delta: float) -> int:
	if dir == Vector2i.ZERO:
		_dir = dir
		return 0
	if dir != _dir:
		_dir = dir
		_t = -delay
		return 1
	_t += delta
	var n: int = 0
	while _t >= -EPSILON:
		n += 1
		_t -= interval
	return n
