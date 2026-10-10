extends "res://minigames/arcade_pack/models/round_base.gd"
## MG1 solo practice: rotate and align a toy parcel through a seeded gate.
## A gate is ALWAYS generated from the current parcel, never an arbitrary mask.
## Gameplay uses integer cells. Rendering is a separate snapshot of these cells.

const SHAPES: Dictionary = {
	"elbow": [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(0, 1, 0)],
	"tee": [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(1, 1, 0)],
	"step": [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(1, 1, 0), Vector3i(2, 1, 0)],
	"corner": [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 1, 0), Vector3i(0, 0, 1)],
	"stair": [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(1, 1, 0), Vector3i(1, 1, 1), Vector3i(2, 1, 1)],
	"arch": [Vector3i(0, 0, 0), Vector3i(0, 1, 0), Vector3i(1, 1, 0), Vector3i(2, 1, 0), Vector3i(2, 0, 0)]
}

var piece: Array = []
var offset: Vector2i = Vector2i.ZERO
var hole: Array = []
var hole_core: Array = []
var axis: String = "z"
var wall_age: float = 0.0
var wall_duration: float = 8.0
var passes: int = 0
var misses: int = 0
var streak: int = 0
var gates: int = 0
var focus_charges: int = 0
var focus_remaining: float = 0.0
var stun_remaining: float = 0.0
var shape_id: String = "elbow"
var _seen_axes: Dictionary = {}


func _reset() -> void:
	passes = 0
	misses = 0
	streak = 0
	gates = 0
	focus_charges = int(config.get("focus_charges", 0))
	focus_remaining = 0.0
	stun_remaining = 0.0
	_seen_axes.clear()
	_next_gate()
	message = str(config.get("opening_hint", "Rotate the parcel, then align it with the opening."))


func act(action: String) -> void:
	if finished or stun_remaining > 0.0:
		return
	match action:
		"left":
			_move(Vector2i(-1, 0))
		"right":
			_move(Vector2i(1, 0))
		"up":
			_move(Vector2i(0, 1))
		"down":
			_move(Vector2i(0, -1))
		"rotate_y", "rotate_x":
			piece = rotate_cells(piece, "y" if action == "rotate_y" else "x")
			_clamp_offset()
			message = "Parcel turned. Compare its outline to the opening."
		"primary":
			_resolve_gate(true)
		"undo":
			if focus_charges > 0 and focus_remaining <= 0.0:
				focus_charges -= 1
				focus_remaining = maxf(0.0, float(config.get("focus_seconds", 2.5)))
				message = "Comet's focus slows this gate. Keep turning and aligning!"


func _step(delta: float) -> void:
	# Consume every timer boundary, including multiple gates in one large update.
	# Base.advance has already added delta to elapsed; resolve at the actual event.
	var remaining: float = delta
	var end_elapsed: float = elapsed
	while remaining > 0.000001 and not finished:
		if stun_remaining > 0.0:
			var stunned_step: float = minf(remaining, stun_remaining)
			stun_remaining = maxf(0.0, stun_remaining - stunned_step)
			remaining -= stunned_step
			continue
		var rate: float = clampf(float(config.get("focus_rate", 0.35)), 0.05, 1.0) if focus_remaining > 0.0 else 1.0
		var to_gate: float = maxf(0.0, wall_duration - wall_age) / rate
		var tick: float = minf(remaining, to_gate)
		if focus_remaining > 0.0:
			tick = minf(tick, focus_remaining)
		wall_age += tick * rate
		focus_remaining = maxf(0.0, focus_remaining - tick)
		remaining = maxf(0.0, remaining - tick)
		if wall_age >= wall_duration - 0.000001:
			elapsed = end_elapsed - remaining
			_resolve_gate(false)
			if not finished:
				elapsed = end_elapsed
		elif tick <= 0.000001:
			break


func _move(direction: Vector2i) -> void:
	offset += direction
	_clamp_offset()
	message = "Parcel aligned. Space sends it through the gate."


func _clamp_offset() -> void:
	var bounds: Vector2i = projection_size(piece, axis)
	var size: int = int(config.get("frame_size", 5))
	offset.x = clampi(offset.x, 0, maxi(0, size - bounds.x))
	offset.y = clampi(offset.y, 0, maxi(0, size - bounds.y))


func _next_gate() -> void:
	var axes: Array = config.get("wall_axes", ["z"])
	if axes.is_empty():
		axes = ["z"]
	axis = str(axes[gates % axes.size()])
	if axis != "x":
		axis = "z"
	var pool: Array = config.get("shape_pool", ["elbow", "tee", "step"])
	if pool.is_empty():
		pool = ["elbow"]
	shape_id = str(pool[rng.randi_range(0, pool.size() - 1)])
	if not SHAPES.has(shape_id):
		shape_id = "elbow"
	piece = SHAPES[shape_id].duplicate()
	# Target rotations are hidden. Only the actual empty wall cells are rendered.
	var target: Array = piece.duplicate()
	var y_turns: int = rng.randi_range(0, clampi(int(config.get("target_turns_y", 3)), 0, 3))
	var x_turns: int = rng.randi_range(0, clampi(int(config.get("target_turns_x", 3)), 0, 3))
	for _turn in range(y_turns):
		target = rotate_cells(target, "y")
	for _turn in range(x_turns):
		target = rotate_cells(target, "x")
	if bool(config.get("random_initial_orientation", false)):
		var initial_rotations: Array = orientations(piece)
		piece = initial_rotations[rng.randi_range(0, initial_rotations.size() - 1)].duplicate()
	var size: int = int(config.get("frame_size", 5))
	var bounds: Vector2i = projection_size(target, axis)
	var target_offset: Vector2i = Vector2i(rng.randi_range(0, maxi(0, size - bounds.x)), rng.randi_range(0, maxi(0, size - bounds.y)))
	hole_core = project_cells(target, axis, target_offset)
	hole = hole_core.duplicate()
	var slack_step: int = int(config.get("slack_step_every", 0))
	var slack: int = int(config.get("hole_slack", 0))
	if slack_step > 0:
		slack = maxi(0, slack - gates / slack_step)
	var candidates: Array = []
	for u in range(size):
		for v in range(size):
			var cell: Vector2i = Vector2i(u, v)
			if not hole.has(cell):
				candidates.append(cell)
	for _extra in range(mini(slack, candidates.size())):
		var chosen: int = rng.randi_range(0, candidates.size() - 1)
		hole.append(candidates[chosen])
		candidates.remove_at(chosen)
	var player_bounds: Vector2i = projection_size(piece, axis)
	offset = Vector2i(maxi(0, (size - player_bounds.x) / 2), maxi(0, (size - player_bounds.y) / 2))
	wall_duration = maxf(float(config.get("wall_interval_min", 3.0)), float(config.get("wall_interval", 8.0)) - gates * float(config.get("wall_ramp", 0.0)))
	if not _seen_axes.has(axis):
		wall_duration = maxf(wall_duration, float(config.get("axis_intro_interval", wall_duration)))
		_seen_axes[axis] = true
	wall_duration = maxf(0.1, wall_duration)
	wall_age = 0.0
	focus_remaining = 0.0


func _resolve_gate(manual: bool) -> void:
	if finished:
		return
	var result: Dictionary = fit_projection(project_cells(piece, axis, offset), hole, hole_core)
	if bool(result["pass"]):
		passes += 1
		streak += 1
		var perfect: bool = bool(result["perfect"])
		score += 2 if perfect else 1
		var rhythm_window: float = maxf(0.0, float(config.get("rhythm_window", 0.0)))
		var on_beat: bool = manual and rhythm_window > 0.0 and wall_duration - wall_age <= rhythm_window
		if on_beat:
			score += int(config.get("rhythm_bonus", 1))
		message = ("Perfect parcel!" if perfect else "Parcel delivered!") + (" Right on the beat!" if on_beat else "")
		var charge: int = maxi(1, int(config.get("tight_charge", 3)))
		if streak % charge == 0:
			# Adapter intent only: no opponent or networking exists in solo practice.
			interaction_requested.emit({"mode": "wall", "effect": "tight_wall", "streak": streak, "gate": gates, "source": "solo_practice"})
		if passes >= maxi(1, int(config.get("pass_target", 5))):
			complete(true, str(config.get("win_text", "Every parcel made it through. Lovely delivery!")))
			return
	else:
		misses += 1
		streak = 0
		message = "Bonk! The parcel stays safe. Align its outline with the next opening."
		if misses >= maxi(1, int(config.get("miss_limit", 3))):
			complete(false, str(config.get("fail_text", "The gates have closed. Try the delivery route again!")))
			return
		stun_remaining = maxf(0.0, float(config.get("stun_seconds", 1.0)))
	gates += 1
	_next_gate()


func snapshot() -> Dictionary:
	var blocks: Array = []
	var markers: Array = []
	var tiles: Array = []
	var size: int = int(config.get("frame_size", 5))
	var centre: float = (size - 1) * 0.5
	var depth: float = 0.0
	for cell in piece:
		depth = maxf(depth, float(cell.x if axis == "x" else cell.z))
	for cell in piece:
		var position: Vector3
		if axis == "x":
			position = Vector3(float(cell.x) - depth * 0.5, float(cell.y + offset.y) + 0.5, float(cell.z + offset.x) - centre)
		else:
			position = Vector3(float(cell.x + offset.x) - centre, float(cell.y + offset.y) + 0.5, float(cell.z) - depth * 0.5)
		blocks.append({"position": position, "colour": gates % 6, "kind": "solid"})
	# The wall moves behind the toy, leaving a real, visible hole (no target cubes).
	var wall_depth: float = -3.3 + clampf(wall_age / wall_duration, 0.0, 1.0) * 1.5
	for u in range(size):
		for v in range(size):
			if hole.has(Vector2i(u, v)):
				continue
			var position: Vector3 = Vector3(wall_depth, float(v) + 0.5, float(u) - centre) if axis == "x" else Vector3(float(u) - centre, float(v) + 0.5, wall_depth)
			var tile_size: Vector3 = Vector3(0.18, 0.96, 0.96) if axis == "x" else Vector3(0.96, 0.96, 0.18)
			tiles.append({"position": position, "size": tile_size, "colour": 4, "kind": "wall"})
	markers.append_array(tiles)
	# Thin rails keep an empty boundary readable, including holes on frame edges.
	var rail_a: Vector3 = Vector3(wall_depth, size * 0.5, -centre - 0.65) if axis == "x" else Vector3(-centre - 0.65, size * 0.5, wall_depth)
	var rail_b: Vector3 = Vector3(wall_depth, size * 0.5, centre + 0.65) if axis == "x" else Vector3(centre + 0.65, size * 0.5, wall_depth)
	var vertical_size: Vector3 = Vector3(0.25, size + 0.35, 0.25)
	markers.append({"position": rail_a, "size": vertical_size, "colour": 4, "kind": "wall"})
	markers.append({"position": rail_b, "size": vertical_size, "colour": 4, "kind": "wall"})
	var horizontal_size: Vector3 = Vector3(0.25, 0.25, size + 0.55) if axis == "x" else Vector3(size + 0.55, 0.25, 0.25)
	for y in [-0.15, float(size) + 0.15]:
		markers.append({"position": Vector3(wall_depth, y, 0.0) if axis == "x" else Vector3(0.0, y, wall_depth), "size": horizontal_size, "colour": 4, "kind": "wall"})
	var time_left: float = maxf(0.0, wall_duration - wall_age)
	var axis_name: String = "SIDE" if axis == "x" else "FRONT"
	var status: String = message
	if not finished:
		status += "\n%s gate · %.1f s" % [axis_name, time_left]
		var rhythm_window: float = float(config.get("rhythm_window", 0.0))
		if rhythm_window > 0.0:
			status += " · SEND ON THE BEAT!" if time_left <= rhythm_window else " · Beat in %.1f s" % (time_left - rhythm_window)
		if int(config.get("focus_charges", 0)) > 0:
			status += " · Focus %d%s" % [focus_charges, " (active)" if focus_remaining > 0.0 else " (U)"]
		if stun_remaining > 0.0:
			status += " · Recovering"
	return {"blocks": blocks, "markers": markers, "wall_tiles": tiles, "status": status,
		"progress": clampf(float(passes) / maxi(1, int(config.get("pass_target", 5))), 0.0, 1.0),
		"metric": "Delivered %d/%d · Bonks %d/%d · Score %d" % [passes, int(config.get("pass_target", 5)), misses, int(config.get("miss_limit", 3)), score],
		"camera_target": Vector3(0.0, size * 0.45, -0.5), "camera_size": size + 5.0,
		"wall_axis": axis, "wall_time_left": time_left, "focus_charges": focus_charges,
		"focus_active": focus_remaining > 0.0, "beat_active": float(config.get("rhythm_window", 0.0)) > 0.0 and time_left <= float(config.get("rhythm_window", 0.0))}


static func normalize_cells(cells: Array) -> Array:
	if cells.is_empty():
		return []
	var minimum: Vector3i = cells[0]
	for cell in cells:
		minimum.x = mini(minimum.x, cell.x)
		minimum.y = mini(minimum.y, cell.y)
		minimum.z = mini(minimum.z, cell.z)
	var result: Array = []
	for cell in cells:
		result.append(cell - minimum)
	return result


static func rotate_cells(cells: Array, rotation_axis: String) -> Array:
	var result: Array = []
	for cell in cells:
		result.append(Vector3i(cell.x, -cell.z, cell.y) if rotation_axis == "x" else Vector3i(cell.z, cell.y, -cell.x))
	return normalize_cells(result)


static func cell_key(cells: Array) -> String:
	var keys: Array[String] = []
	for cell in normalize_cells(cells):
		keys.append("%d,%d,%d" % [cell.x, cell.y, cell.z])
	keys.sort()
	return "|".join(keys)


static func orientations(cells: Array) -> Array:
	var result: Array = [normalize_cells(cells)]
	var seen: Dictionary = {cell_key(cells): true}
	var index: int = 0
	while index < result.size():
		for rotation_axis in ["x", "y"]:
			var next: Array = rotate_cells(result[index], rotation_axis)
			var key: String = cell_key(next)
			if not seen.has(key):
				seen[key] = true
				result.append(next)
		index += 1
	return result


static func project_cells(cells: Array, wall_axis: String, translation: Vector2i = Vector2i.ZERO) -> Array:
	var result: Array = []
	for cell in cells:
		var projected: Vector2i = Vector2i(cell.z if wall_axis == "x" else cell.x, cell.y) + translation
		if not result.has(projected):
			result.append(projected)
	return result


static func projection_size(cells: Array, wall_axis: String) -> Vector2i:
	var result: Vector2i = Vector2i.ZERO
	for cell in project_cells(cells, wall_axis):
		result.x = maxi(result.x, cell.x + 1)
		result.y = maxi(result.y, cell.y + 1)
	return result


static func fit_projection(projection: Array, opening: Array, core: Array) -> Dictionary:
	if projection.is_empty():
		return {"pass": false, "perfect": false}
	for cell in projection:
		if not opening.has(cell):
			return {"pass": false, "perfect": false}
	var perfect: bool = projection.size() == core.size()
	if perfect:
		for cell in core:
			if not projection.has(cell):
				perfect = false
				break
	return {"pass": true, "perfect": perfect}
