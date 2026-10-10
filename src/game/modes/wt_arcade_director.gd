class_name WtArcadeDirector extends RefCounted
## Fixed-clock Arcade rule scheduling, executed through the same manual Beehave driver as BoardSim.
var _content: WtContent
var _modes: WtModes
var _runtime: RuleRuntime = RuleRuntime.new()
var _seed: int
var _pool: Array[Dictionary] = []
var _specials: PackedStringArray = PackedStringArray()
var _shapes: PackedStringArray = PackedStringArray()
var _active: Array[Dictionary] = []
var _pending: Array[Dictionary] = []
var _pending_at: int = -1
var _last_bucket: int = -1
var _last_signature: String = ""
var _repeats: int = 0
var _special_index: int = 0
var _config: Dictionary = {}

func setup(content: WtContent, modes: WtModes, progress: Dictionary, seed: int) -> void:
	_content = content
	_modes = modes
	_seed = seed
	_config = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/meta/modes.json")).arcade
	_pool = modes.encountered_arcade_rules(progress)
	_specials = modes.encountered_arcade_specials(progress)
	_shapes = PackedStringArray(_config.standard_shapes)

func update(simulation: BoardSim) -> Dictionary:
	return _runtime.execute(self, &"_update", [simulation])

func _update(simulation: BoardSim) -> Dictionary:
	var output: Dictionary = {}
	if simulation == null or simulation.get_phase() in [BoardSim.Phase.COUNTDOWN, BoardSim.Phase.ENDED]:
		return output
	var layers: int = simulation.goal_state().layers_cleared
	var bucket: int = layers / maxi(1, int(_config.get("twist_rotation_layers", 5)))
	if bucket > _last_bucket:
		_last_bucket = bucket
		_pending = _draw(layers, bucket)
		_pending_at = simulation.now_ms() + int(_config.get("announce_ms", 2000))
		var labels: PackedStringArray = PackedStringArray()
		for row: Dictionary in _pending: labels.append(String(row.id).replace("_", " ").capitalize())
		output.warning = "Next twist: " + ", ".join(labels)
	if _pending_at >= 0 and simulation.now_ms() >= _pending_at and simulation.get_phase() == BoardSim.Phase.RESOLVING:
		_active = _pending.duplicate(true)
		simulation.set_rule_definitions(_active)
		_pending_at = -1
		output.twists_changed = _active.duplicate(true)
		if layers >= int(_config.get("specials_after_layers", 10)) and not _specials.is_empty():
			var shape: String = _specials[_special_index % _specials.size()]
			_special_index += 1
			if not _shapes.has(shape):
				while _shapes.size() >= 8: _shapes.remove_at(0)
				_shapes.append(shape)
				simulation.set_shape_pool(_shapes)
				output.specials_changed = _shapes.duplicate()
	return output

func _draw(layers: int, bucket: int) -> Array[Dictionary]:
	var ids: Array = []
	for row: Dictionary in _pool: ids.append(String(row.id))
	var draw: Array = _modes.arcade_twists(layers, ids, _seed)
	var signature: String = _signature(draw)
	# A single available set is allowed to persist. With alternatives, a third repeat is redrawn.
	if signature == _last_signature and _repeats >= 2 and _pool.size() > draw.size():
		for attempt: int in range(1, 17):
			var alternate: Array = _modes.arcade_twists(layers, ids, Seeds.derive(_seed, ["arcade_redraw", bucket, attempt]))
			if _signature(alternate) != signature:
				draw = alternate
				signature = _signature(draw)
				break
	_repeats = _repeats + 1 if signature == _last_signature else 1
	_last_signature = signature
	var rules: Array[Dictionary] = []
	for id: String in draw:
		for row: Dictionary in _pool:
			if String(row.id) == id:
				rules.append(row.duplicate(true))
				break
	return rules

func _signature(ids: Array) -> String:
	var sorted: Array = ids.duplicate()
	sorted.sort()
	return ",".join(sorted)

func snapshot() -> Dictionary:
	return {"rules": _active.duplicate(true), "pending": _pending.duplicate(true), "pending_at": _pending_at,
		"bucket": _last_bucket, "shapes": _shapes.duplicate(), "special_index": _special_index,
		"runtime": _runtime.snapshot()}
