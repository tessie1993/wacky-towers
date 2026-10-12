extends "res://minigames/arcade_pack/models/round_base.gd"
## MG4 practice: alternating slide gates, overlap trim and three-perfect streaks.
## U / E spends a magnet charge and locks only while inside the snap window.

const OVERLAP_EPSILON: float = 0.000001

var slabs: Array[Dictionary] = []
var active_center: Vector3 = Vector3.ZERO
var active_size: Vector3 = Vector3.ONE
var slide_axis: int = 0
var magnet_charges: int = 0
var perfect_streak: int = 0
var perfect_count: int = 0
var last_trim: float = 0.0
var last_assisted: bool = false
var motion_direction: float = 1.0
var motion_speed: float = 2.0
var motion_extent: float = 2.8
var motion_phase: float = 0.0
var rhythm_phase: float = 0.0
var slab_spawn_time: float = 0.0
var spawn_origin: Vector3 = Vector3.ZERO


func _reset() -> void:
	slabs.clear()
	magnet_charges = maxi(0, int(config.get("magnet_charges", 2)))
	perfect_streak = 0
	perfect_count = 0
	last_trim = 0.0
	last_assisted = false
	var width: float = clampf(float(config.get("base_width", 4.0)), 1.0, 4.0)
	slabs.append({"position": Vector3(0.0, 0.5, 0.0),
		"size": Vector3(width, 1.0, width), "colour": 2, "kind": "solid"})
	message = "Time the slide. Space: lock. U / E: magnet within the snap window."
	_spawn_slab()


func _step(_delta: float) -> void:
	_update_motion()


func act(action: String) -> void:
	if finished:
		return
	if action == "primary":
		_lock_slab(false)
	elif action == "undo" or action == "rotate_y":
		if magnet_charges <= 0:
			message = "No magnet charges left. Space still locks the slab."
			return
		var top: Vector3 = slabs.back()["position"]
		var snap_range: float = maxf(0.0, float(config.get("magnet_range", 0.8)))
		if absf(active_center[slide_axis] - top[slide_axis]) > snap_range:
			message = "Move closer to the landing guide before using the magnet."
			return
		magnet_charges -= 1
		_lock_slab(true)


func _spawn_slab() -> void:
	var top: Dictionary = slabs.back()
	slide_axis = 0 if score % 2 == 0 else 2
	active_size = top["size"]
	spawn_origin = top["position"] + Vector3.UP
	active_center = spawn_origin
	slab_spawn_time = elapsed
	motion_direction = -1.0 if rng.randi_range(0, 1) == 0 else 1.0
	motion_phase = rng.randf_range(0.0, TAU)
	rhythm_phase = rng.randf_range(0.0, TAU)
	motion_extent = maxf(0.5, float(config.get("motion_extent", 2.8)))
	var ramp: float = float(score) / float(maxi(1, _target_height() - 1))
	motion_speed = lerpf(maxf(0.2, float(config.get("speed_start", 2.0))),
		maxf(0.2, float(config.get("speed_max", 4.0))), clampf(ramp, 0.0, 1.0))
	_update_motion()


func _update_motion() -> void:
	# Integrate the speed waves analytically from spawn time. Frame subdivision
	# cannot change a slab's travel, including across any number of reflections.
	var age: float = maxf(0.0, elapsed - slab_spawn_time)
	var travelled: float = motion_speed * age
	var wind: float = clampf(float(config.get("wind_amplitude", 0.0)),
		0.0, motion_speed * 0.45)
	var wind_rate: float = TAU / maxf(0.1, float(config.get("wind_period", 3.6)))
	travelled += wind / wind_rate * (cos(motion_phase) - cos(wind_rate * age + motion_phase))
	var rhythm: float = clampf(float(config.get("rhythm_amplitude", 0.0)), 0.0, 0.35)
	var rhythm_rate: float = TAU / maxf(0.1, float(config.get("rhythm_period", 2.4)))
	travelled += motion_speed * rhythm / rhythm_rate * (
		sin(rhythm_rate * age + rhythm_phase) - sin(rhythm_phase))
	var cycle: float = fposmod(travelled, motion_extent * 4.0)
	var offset: float = motion_extent - cycle if cycle <= motion_extent * 2.0 else (
		cycle - motion_extent * 3.0)
	active_center = spawn_origin
	active_center[slide_axis] += motion_direction * offset


func _lock_slab(assisted: bool) -> void:
	var top: Dictionary = slabs.back()
	var top_center: Vector3 = top["position"]
	var top_size: Vector3 = top["size"]
	var distance: float = absf(active_center[slide_axis] - top_center[slide_axis])
	var perfect: bool = distance <= maxf(0.0, float(config.get("perfect_tolerance", 0.13)))
	if assisted or perfect:
		active_center.x = top_center.x
		active_center.z = top_center.z
	var fit: Dictionary = _overlap(active_center, active_size, top_center, top_size)
	if fit.is_empty():
		perfect_streak = 0
		last_trim = active_size[slide_axis]
		complete(false, "Miss! The slab slipped past the tower. Try again!")
		return
	var retained_size: Vector3 = fit["size"]
	last_trim = maxf(0.0, active_size[slide_axis] - retained_size[slide_axis])
	last_assisted = assisted
	score += 1
	slabs.append({"position": fit["position"], "size": retained_size,
		"colour": score % 6, "kind": "solid"})
	if perfect and not assisted:
		perfect_count += 1
		perfect_streak += 1
		message = "Perfect! %d in a row." % perfect_streak
		if perfect_streak % 3 == 0:
			interaction_requested.emit({"mode": "stack", "kind": "perfect_streak",
				"requested_effect": "steal_slab", "height": score,
				"streak": perfect_streak, "level_id": str(config.get("id", ""))})
	elif assisted:
		perfect_streak = 0
		message = "Magnet lock! %d charges left." % magnet_charges
	else:
		perfect_streak = 0
		message = "Trimmed %.2f cells. Keep the next slab centred." % last_trim
	if score >= _target_height():
		complete(true, "Tower complete! %d perfect locks." % perfect_count)
		return
	_spawn_slab()


## Rectangle intersection; a touching edge supplies no support. Y comes from
## the moving slab, while retained X/Z centre shifts toward supported material.
func _overlap(center: Vector3, size: Vector3,
		support_center: Vector3, support_size: Vector3) -> Dictionary:
	var low_x: float = maxf(center.x - size.x * 0.5, support_center.x - support_size.x * 0.5)
	var high_x: float = minf(center.x + size.x * 0.5, support_center.x + support_size.x * 0.5)
	var low_z: float = maxf(center.z - size.z * 0.5, support_center.z - support_size.z * 0.5)
	var high_z: float = minf(center.z + size.z * 0.5, support_center.z + support_size.z * 0.5)
	if high_x - low_x <= OVERLAP_EPSILON or high_z - low_z <= OVERLAP_EPSILON:
		return {}
	return {"position": Vector3((low_x + high_x) * 0.5, center.y, (low_z + high_z) * 0.5),
		"size": Vector3(high_x - low_x, size.y, high_z - low_z)}


func _target_height() -> int:
	return maxi(1, int(config.get("target_height", 8)))


func snapshot() -> Dictionary:
	var blocks: Array = slabs.duplicate(true)
	var markers: Array = []
	if not finished:
		blocks.append({"position": active_center, "size": active_size,
			"colour": (score + 1) % 6, "kind": "active"})
		markers.append({"position": spawn_origin, "size": active_size,
			"colour": 3, "kind": "ghost"})
		# This smaller guide shows exactly where the magnet becomes available.
		var guide: Vector3 = Vector3(0.06, 0.08, 0.06)
		guide[slide_axis] = float(config.get("magnet_range", 0.8)) * 2.0
		markers.append({"position": spawn_origin + Vector3(0.0, 0.55, 0.0),
			"size": guide, "colour": 3, "kind": "target"})
	return {"blocks": blocks, "markers": markers, "status": message,
		"progress": clampf(float(score) / float(_target_height()), 0.0, 1.0),
		"metric": "Height %d / %d · Magnet %d" % [score, _target_height(), magnet_charges],
		"camera_target": Vector3(0.0, maxf(2.0, float(score + 1) * 0.5), 0.0),
		"camera_size": maxf(11.0, float(score) + 7.0)}
