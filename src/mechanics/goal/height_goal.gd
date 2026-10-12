class_name HeightGoal extends GoalEvaluator
## Reach the ribbon with the required fraction of active cells filled.

const PLUGIN_ID := &"height"
var _height: int = 1
var _coverage: int = -1
var _done: int = 0
var _target: int = 1


func configure(goal: Dictionary) -> void:
	_height = maxi(1, int(goal.get("h_target", goal.get("height", 1))))
	if goal.has("coverage"):
		_coverage = int(roundf(float(goal["coverage"]) * 1000.0))


func evaluate(_state: GoalState, api: RuleApi) -> int:
	var coverage: int = _coverage
	if coverage < 0:
		coverage = api.knob_int(&"goal.height_coverage")
	if coverage <= 0:
		coverage = 600
	var active: int = 0
	_done = 0
	var size: Vector3i = api.board_size()
	for y: int in size.y:
		for z: int in size.z:
			for x: int in size.x:
				var c := Vector3i(x, y, z)
				if api.is_active(c) and api.layer_of(c) == _height - 1:
					active += 1
					if api.fills_layer_at(c):
						_done += 1
	_target = maxi(1, int(ceil(float(active * coverage) / 1000.0)))
	return WON if active > 0 and _done >= _target else RUNNING


func progress(_state: GoalState) -> Dictionary:
	return {"done": mini(_done, _target), "target": _target, "height": _height}
