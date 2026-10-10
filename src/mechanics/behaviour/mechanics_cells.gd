class_name MechanicsCells extends RefCounted
## Canonical enumeration and rigid group movement shared by pure rule behaviours.


static func all(api: RuleApi) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	var size: Vector3i = api.board_size()
	for layer: int in api.layer_count():
		for x: int in size.x:
			for z: int in size.z:
				for y: int in size.y:
					var c := Vector3i(x, y, z)
					if api.is_active(c) and api.layer_of(c) == layer:
						result.append(c)
	return result


static func occupied(api: RuleApi, kind: int = -1) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	for c: Vector3i in all(api):
		var at: int = api.kind_at(c)
		if at != 0 and (kind < 0 or at == kind):
			result.append(c)
	return result


static func owned(api: RuleApi, uid: int) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	for c: Vector3i in occupied(api):
		if int(api.record_at(c).get("piece_instance_id", -1)) == uid:
			result.append(c)
	return result


static func direction(token: String, fallback := Vector3i(1, 0, 0)) -> Vector3i:
	var down: int = BoardState.down_from_token(token)
	return BoardState.down_vector_of(down) if down >= 0 else fallback


static func translated(cells: Array[Vector3i], offset: Vector3i) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	for c: Vector3i in cells:
		result.append(c + offset)
	return result


static func group_free(api: RuleApi, targets: Array[Vector3i], own: Array[Vector3i]) -> bool:
	for c: Vector3i in targets:
		if not api.is_active(c) or (api.kind_at(c) != 0 and not own.has(c)):
			return false
	return true


static func rigid_distance(api: RuleApi, cells: Array[Vector3i], direction_value: Vector3i) -> int:
	return rigid_distance_virtual(api, cells, direction_value, cells)


static func rigid_distance_virtual(api: RuleApi, cells: Array[Vector3i], direction_value: Vector3i, vacated: Array[Vector3i], extra: Array[Vector3i] = []) -> int:
	var distance: int = 0
	var cap: int = api.board_size().x + api.board_size().y + api.board_size().z
	while distance < cap:
		var free: bool = true
		for c: Vector3i in translated(cells, direction_value * (distance + 1)):
			if not api.is_active(c) or extra.has(c) or (api.kind_at(c) != 0 and not vacated.has(c)):
				free = false
				break
		if not free:
			break
		distance += 1
	return distance


static func drop(api: RuleApi, cells: Array[Vector3i]) -> int:
	var distance: int = rigid_distance(api, cells, api.down_vector())
	if distance > 0:
		api.move_cells(cells, translated(cells, api.down_vector() * distance))
	return distance


static func pick(api: RuleApi, candidates: Array[Vector3i]) -> Vector3i:
	return candidates[0] if candidates.size() == 1 else candidates[api.rng().randi_range(0, candidates.size() - 1)]
