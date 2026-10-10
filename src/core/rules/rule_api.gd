class_name RuleApi extends RefCounted
## Single-threaded plugin facade (ADR-0004/0011). Content writes queue until the hook boundary;
## structure requests wait for S4a. Plugins never receive BoardSim. Example: api.set_cell(c, api.kind_of(&"block"), 2).

var _board: BoardState
var _knobs: KnobRegistry
var _params: Dictionary
var _piece: ActivePiece
var _catalog: GameCatalog
var _time: int = 0
var _rng: RandomNumberGenerator = Seeds.make_rng(0, ["rule"])
var _writes: Array[Dictionary] = []
var _requests: Array[Dictionary] = []
var _emitted: Array[Dictionary] = []
var _piece_flags: Dictionary = {}
var _dirty: bool = false
var _goal_config: Dictionary = {}
var _goal_state: GoalState
var _spawner: Spawner
var _preview_hues: Array[int] = []
var _stack_writes_allowed: bool = true
var _rule_id: StringName = &"base"
var _item_context: Dictionary = {"players": 1, "rank": 1, "mode": "solo", "owner": 0}
var _modifier_probe: Callable
var _active_rules: PackedStringArray = PackedStringArray()
var _piece_uid: int = 0

func _init(p_board: BoardState = null, p_knobs: KnobRegistry = null, p_params: Dictionary = {}) -> void:
	_board = p_board
	_knobs = p_knobs
	_params = p_params

## Bind immutable catalog and a dedicated deterministic rule stream. Example: api.configure(catalog, seed, id).
func configure(catalog: GameCatalog, seed: int, id: StringName) -> void:
	_catalog = catalog
	_rule_id = id
	_rng = Seeds.make_rng(seed, ["rule", id])

func rule_id() -> StringName:
	return _rule_id

func bind_item_context(context: Dictionary) -> void:
	_item_context = context.duplicate(true)

func item_context() -> Dictionary:
	return _item_context.duplicate(true)

func bind_modifier_probe(probe: Callable, active_rules: PackedStringArray) -> void:
	_modifier_probe = probe
	_active_rules = active_rules

func modifiers_would_change(modifiers: Array[Dictionary]) -> bool:
	return bool(_modifier_probe.call(modifiers)) if _modifier_probe.is_valid() else true

func rule_active(id: StringName) -> bool:
	return _active_rules.has(String(id))

func bind_piece_uid(uid: int) -> void:
	_piece_uid = uid

func get_piece_uid() -> int:
	return _piece_uid

## Values follow RuleDef JSON units: scalars are decimals, counts integers, choices strings.
func request_modifiers(owner: StringName, modifiers: Array[Dictionary]) -> void:
	_requests.append({"op": &"modifiers", "effect": owner, "modifiers": modifiers.duplicate(true)})

func clear_modifiers(owner: StringName) -> void:
	request_modifiers(owner, [])

func request_score(points: int) -> void:
	_requests.append({"op": &"score", "points": points})

func request_post_clear_damage(cells: Array[Vector3i], hits: int = 1) -> void:
	_requests.append({"op": &"damage", "cells": cells.duplicate(), "hits": maxi(1, hits)})

## Simulation binding, called before every hook. Example: api.bind_piece(sim.get_piece()).
func bind_piece(p_piece: ActivePiece) -> void:
	_piece = p_piece

func set_time(ms: int) -> void:
	_time = ms

func now_ms() -> int:
	return _time

func time_ms() -> int:
	return _time

func bind_spawner(spawner: Spawner) -> void:
	_spawner = spawner

## Actual upcoming queue ids, without advancing any stream. Example: api.preview_ids(3).
func preview_ids(n: int = 3) -> PackedStringArray:
	return _spawner.peek(n) if _spawner != null else PackedStringArray()

func shape_pool() -> PackedStringArray:
	return _spawner.shape_pool() if _spawner != null else PackedStringArray()

func stream_preview_ids(n: int = 3) -> PackedStringArray:
	return _spawner.stream_preview_ids(n) if _spawner != null else PackedStringArray()

func queued_preview(n: int = 3) -> PackedStringArray:
	return preview_ids(n)

func bind_goal(state: GoalState, goal: Dictionary) -> void:
	_goal_state = state
	_goal_config = goal

func goal_config() -> Dictionary:
	return _goal_config.duplicate(true)

func goal_metric(name: StringName, value: int) -> void:
	if _goal_state != null:
		_goal_state.metrics[name] = value

func goal_counter(name: StringName) -> int:
	return int(_goal_state.metrics.get(name, _goal_state.metrics.get(String(name), 0))) if _goal_state != null else 0

func add_goal_counter(name: StringName, amount: int = 1) -> void:
	goal_metric(name, goal_counter(name) + amount)

func request_goal(config: Dictionary) -> void:
	_requests.append({"op": &"goal", "config": config.duplicate(true)})

func request_piece_hue(hue: int) -> void:
	_requests.append({"op": &"piece_hue", "hue": hue})

func request_preview_hue(index: int, hue: int) -> void:
	_requests.append({"op": &"preview_hue", "index": index, "hue": hue})

func piece_orientation() -> int:
	return _piece.orient if _piece != null else 0

func piece_hue() -> int:
	return _piece.hue_id if _piece != null else 0

func get_piece_pivot() -> Vector3i:
	return _piece.pivot if _piece != null else Vector3i.ZERO

func spawn_bag_info() -> Dictionary:
	return _spawner.last_bag_info() if _spawner != null else {}

func request_height_limit(height: int) -> void:
	_requests.append({"op": &"height", "height": height})

func stack_writes_allowed() -> bool:
	return _stack_writes_allowed

func bind_stack_permission(allowed: bool) -> void:
	_stack_writes_allowed = allowed

func bind_preview_hues(hues: Array[int]) -> void:
	_preview_hues = hues

func preview_hues(n: int = 3) -> PackedInt32Array:
	return PackedInt32Array(_preview_hues.slice(0, maxi(0, n)))

func request_floor(layer: int) -> void:
	_requests.append({"op": &"floor", "layer": layer})

func request_junk_layers(n: int, seed: int = -1) -> void:
	_requests.append({"op": &"junk", "layers": maxi(0, n), "seed": _rng.randi() if seed < 0 else seed})

func bind_piece_flags(flags: Dictionary) -> void:
	_piece_flags = flags

func piece_flag(name: StringName, fallback: Variant = null) -> Variant:
	return _piece_flags.get(name, _piece_flags.get(String(name), fallback))

func spawn_anchor() -> Vector2i:
	return _board.spawn_anchor()

func limit_layer() -> int:
	return _board.limit_layer()

func board_size() -> Vector3i:
	return _board.size()

func is_free(c: Vector3i) -> bool:
	return _board.is_free(c)

func can_place(cells: Array[Vector3i]) -> bool:
	return _board.can_place(cells)

func cast(cells: Array[Vector3i], dir: Vector3i) -> int:
	return _board.cast(cells, dir)

func is_active(c: Vector3i) -> bool:
	return _board.in_bounds(c) and _board.is_active(_board.index(c))

func kind_at(c: Vector3i) -> int:
	return _board.get_kind(_board.index(c)) if _board.in_bounds(c) else 0

func color_at(c: Vector3i) -> int:
	return _board.get_color(_board.index(c)) if _board.in_bounds(c) else 0

func kind_of(id: StringName) -> int:
	return _catalog.content.kind_of(id) if _catalog != null else 0

func fills_layer_at(c: Vector3i) -> bool:
	return _board.fills_layer_at(c)

func record_at(c: Vector3i) -> Dictionary:
	return _board.get_record(_board.index(c)) if _board.in_bounds(c) else {}

func down_vector() -> Vector3i:
	return _board.down_vector()

func layer_count() -> int:
	return _board.layer_count()

func layer_of(c: Vector3i) -> int:
	return _board.layer_of(_board.index(c))

func layer_full(k: int) -> bool:
	return k >= 0 and k < _board.layer_count() and _board.layer_full(k)

func full_layers() -> PackedInt32Array:
	return _board.full_layers()

func stack_height() -> int:
	return _board.stack_height()

func over_limit() -> bool:
	return _board.over_limit()

## Immutable current shape resource for geometric ability queries. Example: WtPerfectFit.search(api.get_piece_shape()).
func get_piece_shape() -> ShapeDef:
	return _piece.shape if _piece != null else null

func piece_cells() -> Array[Vector3i]:
	var none: Array[Vector3i] = []
	return _piece.cells() if _piece != null else none

func knob(id: StringName) -> Variant:
	return _knobs.value(id) if _knobs != null else null

func knob_int(id: StringName) -> int:
	return _knobs.int_value(id) if _knobs != null else 0

func knob_flag(id: StringName) -> bool:
	return _knobs.flag(id) if _knobs != null else false

func param(param_name: StringName, fallback: Variant = null) -> Variant:
	return _params.get(String(param_name), _params.get(param_name, fallback))

## Each behaviour owns one stream. Example: var direction := api.rng().randi_range(0, 3).
func rng() -> RandomNumberGenerator:
	return _rng

## Queue content mutations; writes flush in rule priority order after a hook. Example: api.set_cell(c, 1, 3).
func set_cell(c: Vector3i, kind: int, color: int = 0, uid: int = 0) -> void:
	_writes.append({"op": &"set", "cell": c, "kind": kind, "color": color, "uid": uid})

func clear_cell(c: Vector3i, cause: int = BoardState.Cause.CLEAR) -> void:
	_writes.append({"op": &"remove", "cell": c, "cause": cause})

func remove_cell(c: Vector3i, cause: int = BoardState.Cause.CLEAR) -> void:
	clear_cell(c, cause)

func move_cell(src: Vector3i, dst: Vector3i, force: bool = false) -> void:
	_writes.append({"op": &"move", "cell": src, "to": dst, "force": force})

## Simultaneous batch move preserves cycles and each block's status. Example: api.move_cells(old_cells, shifted_cells).
func move_cells(src: Array[Vector3i], dst: Array[Vector3i], force: bool = false) -> void:
	_writes.append({"op": &"batch", "src": src.duplicate(), "dst": dst.duplicate(), "force": force})

func set_status(c: Vector3i, rec: Dictionary) -> void:
	_writes.append({"op": &"status", "cell": c, "record": rec.duplicate(true)})

func request_mask(x: int, z: int, on: bool) -> void:
	_requests.append({"op": &"mask", "x": x, "z": z, "on": on})

func request_down_axis(direction: int) -> void:
	_requests.append({"op": &"down", "direction": direction})

func request_flip(direction: int) -> void:
	request_down_axis(direction)

func request_stack_flip() -> void:
	_requests.append({"op": &"stack_flip"})

func request_slot(id: StringName, value: Variant) -> void:
	_requests.append({"op": &"slot", "id": id, "value": value})

func request_settle() -> void:
	_requests.append({"op": &"settle"})

## Rule-controlled translation reports collision synchronously. Example: api.try_translate(Vector3i.RIGHT).
func try_translate(dir: Vector3i) -> Dictionary:
	if _piece == null:
		return {"result": Movement.Result.BLOCKED, "reason": &"no_piece"}
	var result: Dictionary = Movement.try_translate(_piece, _board, dir)
	if result["result"] == Movement.Result.OK:
		emit(SimEvents.PIECE_MOVED, {"origin": _piece.pivot, "cause": &"rule"})
	return result

func request_move_piece(dir: Vector3i) -> Dictionary:
	return try_translate(dir)

func place_nearest_up() -> bool:
	if _piece == null:
		return false
	for n: int in _board.layer_count():
		var pivot: Vector3i = _piece.pivot - _board.down_vector() * n
		if _board.can_place(_piece.cells_at(_piece.orient, pivot)):
			_piece.pivot = pivot
			return true
	return false

func replace_shape(shape_id: StringName) -> bool:
	if _piece == null or _catalog == null:
		return false
	var shape: ShapeDef = _catalog.shapes.get_shape(shape_id)
	if shape == null:
		return false
	var before: ShapeDef = _piece.shape
	var before_orient: int = _piece.orient
	_piece.shape = shape
	_piece.orient = shape.spawn_orient
	if not _board.can_place(_piece.cells()) and not place_nearest_up():
		_piece.shape = before
		_piece.orient = before_orient
		return false
	_piece.clear_undo()
	return true

func set_travel_dir(dir: Vector3i) -> void:
	_requests.append({"op": &"travel", "direction": dir})

func inject_front(ids: PackedStringArray) -> void:
	_requests.append({"op": &"queue", "ids": ids})

## Replace upcoming shapes without consuming bag RNG. Example: api.replace_preview(new_ids).
func replace_preview(ids: PackedStringArray) -> void:
	_requests.append({"op": &"replace_preview", "ids": ids})

func replace_stream_preview(ids: PackedStringArray) -> void:
	_requests.append({"op": &"replace_stream_preview", "ids": ids.duplicate()})

func set_piece_flag(flag: StringName, value: Variant = true) -> void:
	_piece_flags[flag] = value
	_requests.append({"op": &"piece_flag", "flag": flag, "value": value})

func return_piece_to_spawn(hold_ms: int = 0) -> void:
	_requests.append({"op": &"catch", "hold_ms": hold_ms})

func request_catch(hold_ms: int = 0) -> void:
	return_piece_to_spawn(hold_ms)

## Deterministic presentation event. Example: api.emit(&"gust_telegraph", {"dir": direction}).
func emit(kind: StringName, data: Dictionary = {}) -> void:
	_emitted.append({"kind": kind, "data": data.duplicate(true)})

func would_clear(cells: Array[Vector3i]) -> bool:
	if not knob_flag(&"clear.enabled"):
		return false
	for k: int in _board.layer_count():
		var missing: int = 0
		for i: int in _board.layer_cells(k):
			var c: Vector3i = _board.cell(i)
			if _board.is_active(i) and not _board.fills_layer_at(c) and not cells.has(c):
				missing += 1
		if missing == 0 and _board.active_in_layer(k) > 0:
			return true
	return false

func new_covered_holes(cells: Array[Vector3i]) -> int:
	var holes: int = 0
	for c: Vector3i in cells:
		var below: Vector3i = c + _board.down_vector()
		if _board.is_free(below) and not cells.has(below):
			holes += 1
	return holes

func would_top_out(cells: Array[Vector3i]) -> bool:
	for c: Vector3i in cells:
		if _board.in_bounds(c) and layer_of(c) >= _board.limit_layer():
			return true
	return false

func goal_would_meet(cells: Array[Vector3i]) -> bool:
	match String(knob(&"goal.type")):
		"clear_n":
			var added: int = 0
			if knob_flag(&"clear.enabled"):
				for k: int in layer_count():
					var complete: bool = _board.active_in_layer(k) > 0
					for i: int in _board.layer_cells(k):
						var c: Vector3i = _board.cell(i)
						if _board.is_active(i) and not fills_layer_at(c) and not cells.has(c):
							complete = false
					if complete:
						added += 1
			return (_goal_state.layers_cleared if _goal_state != null else 0) + added >= int(_goal_config.get("n", 1))
		"height":
			var target: int = int(_goal_config.get("h_target", _goal_config.get("height", 1))) - 1
			if target < 0 or target >= layer_count():
				return false
			var filled: int = 0
			for i: int in _board.layer_cells(target):
				var c: Vector3i = _board.cell(i)
				if fills_layer_at(c) or (is_active(c) and cells.has(c)):
					filled += 1
			var coverage: int = int(roundf(float(_goal_config.get("coverage", knob_int(&"goal.height_coverage") / 1000.0)) * 1000))
			return filled * 1000 >= _board.active_in_layer(target) * coverage
		"shape":
			var target: Dictionary = _goal_config.get("target_shape", {}).get("layers", {})
			for key: Variant in target:
				var rows: Array = target[key]
				for z: int in rows.size():
					for x: int in String(rows[z]).length():
						var c := Vector3i(x, int(key), z)
						if String(rows[z])[x] in ["+", "#"] and not fills_layer_at(c) and not cells.has(c):
							return false
			return not target.is_empty()
	return false

func spawn_cells_free() -> bool:
	for k: int in range(_board.limit_layer(), _board.layer_count()):
		for i: int in _board.layer_cells(k):
			if not _board.is_free(_board.cell(i)):
				return false
	return true

## Engine-only write flush; does not consume touched/delta. Example: api.flush_writes().
func flush_writes(protect_stack: bool = false) -> bool:
	var changed: bool = false
	var deferred: Array[Dictionary] = []
	for write: Dictionary in _writes:
		var op: StringName = write["op"]
		var replaces: bool = op == &"set" and _board.in_bounds(write["cell"]) and kind_at(write["cell"]) != 0
		if protect_stack and (op in [&"remove", &"move", &"batch"] or replaces):
			deferred.append(write)
			continue
		changed = true
		if write["op"] == &"batch":
			_board.move_batch(write["src"], write["dst"], bool(write.get("force", false)))
			continue
		var c: Vector3i = write.get("cell", Vector3i.ZERO)
		if not _board.in_bounds(c):
			continue
		var i: int = _board.index(c)
		match write["op"]:
			&"set":
				if _board.is_active(i):
					_board.place(i, write["kind"], write["color"], write["uid"])
			&"remove": _board.remove(i, write["cause"])
			&"status": _board.set_status(i, write["record"])
			&"move":
				if _board.in_bounds(write["to"]):
					_board.move(i, _board.index(write["to"]), bool(write.get("force", false)))
	_writes = deferred
	_dirty = _dirty or changed
	return changed

func take_requests() -> Array[Dictionary]:
	var result: Array[Dictionary] = _requests.duplicate()
	_requests.clear()
	return result

func take_events() -> Array[Dictionary]:
	var result: Array[Dictionary] = _emitted.duplicate()
	_emitted.clear()
	return result

func rng_state() -> int:
	return _rng.state


## Engine replay snapshot includes pending mutations, not only the rule RNG. Example: api.snapshot().
func snapshot() -> Dictionary:
	return {"rng": _rng.state, "params": _params, "writes": _writes, "requests": _requests, "events": _emitted,
		"piece_flags": _piece_flags, "time_ms": _time}

func restore(state: Dictionary) -> void:
	_rng.state = state["rng"]
	_writes.assign(state.get("writes", []))
	_requests.assign(state.get("requests", []))
	_emitted.assign(state.get("events", []))
	_piece_flags = state.get("piece_flags", {}).duplicate(true)
	_time = int(state.get("time_ms", 0))
