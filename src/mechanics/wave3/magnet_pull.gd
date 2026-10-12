class_name MagnetPullRule extends RuleBehaviour
## W1: a magnet column tugs the falling piece one cell toward it on a telegraphed timer.
const PLUGIN_ID := &"magnet_pull"
var _due: int = -1
var _warned: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_spawn", &"on_tick"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_due = -1
		_warned = false
	elif hook == &"on_spawn":
		if _due < 0:
			_schedule(api)
	elif hook == &"on_tick" and _due >= 0:
		var now: int = api.time_ms()
		if not _warned and now >= _due - maxi(0, int(api.param(&"pull_warn_ms", 600))):
			_warned = true
			var warn_dir: Vector3i = _direction(api)
			if warn_dir != Vector3i.ZERO:
				api.emit(&"magnet_warning", {"dir": warn_dir, "due_ms": _due})
		if now >= _due:
			var pull_dir: Vector3i = _direction(api)
			if pull_dir != Vector3i.ZERO:
				var result: Dictionary = api.request_move_piece(pull_dir)
				if result.get("result") == Movement.Result.OK:
					api.emit(&"magnet_pull", {"dir": pull_dir})
			_schedule(api)


func _schedule(api: RuleApi) -> void:
	_due = api.time_ms() + maxi(500, int(api.param(&"pull_interval_ms", 2500)))
	_warned = false


## Unit step toward the magnet column; zero when aligned or no piece is falling.
func _direction(api: RuleApi) -> Vector3i:
	var cells: Array[Vector3i] = api.piece_cells()
	if cells.is_empty():
		return Vector3i.ZERO
	var size: Vector3i = api.board_size()
	var col: Array = api.param(&"magnet_col", [size.x - 1, size.z / 2])
	var magnet := Vector2i(int(col[0]), int(col[1]))
	var lo := Vector2i(cells[0].x, cells[0].z)
	var hi := lo
	for c: Vector3i in cells:
		lo = Vector2i(mini(lo.x, c.x), mini(lo.y, c.z))
		hi = Vector2i(maxi(hi.x, c.x), maxi(hi.y, c.z))
	var axis: String = String(api.param(&"pull_axis", "x"))
	if axis == "x" or axis == "both":
		if magnet.x < lo.x:
			return Vector3i(-1, 0, 0)
		if magnet.x > hi.x:
			return Vector3i(1, 0, 0)
	if axis == "z" or axis == "both":
		if magnet.y < lo.y:
			return Vector3i(0, 0, -1)
		if magnet.y > hi.y:
			return Vector3i(0, 0, 1)
	return Vector3i.ZERO


func snapshot() -> Dictionary:
	return {"due": _due, "warned": _warned}
