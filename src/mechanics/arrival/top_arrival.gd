class_name TopArrival extends ArrivalStyle
## Bounding-box centre follows the level anchor; the lowest cube begins at the danger line.

const PLUGIN_ID := &"top"


@warning_ignore("integer_division")
func plan_arrival(shape: ShapeDef, board: BoardState, api: RuleApi) -> ArrivalPlan:
	# Primary choice is unchanged: the flattest face against gravity, ties to the longest ground extent.
	# Spawn safety: if that plan cannot be placed (an I4 on a 3-deep board has no room along z), fall back to the
	# next-best orientation that can; if none can, return the primary plan blocked and the sim's spawn safety takes over.
	var down: Vector3i = api.down_vector()
	var down_axis: int = 1 if down.y != 0 else (0 if down.x != 0 else 2)
	var long_axis: int = 0 if down_axis != 0 else 2
	var orientation: int = shape.spawn_orient
	var best_extent: int = shape.bbox(orientation)[down_axis]
	var best_long: int = shape.bbox(orientation)[long_axis]
	var ranked: Array[Vector3i] = [] # (orientation, extent, long extent)
	for candidate: int in Orientations.COUNT:
		var box: Vector3i = shape.bbox(candidate)
		var extent: int = box[down_axis]
		var long_extent: int = box[long_axis]
		ranked.append(Vector3i(candidate, extent, long_extent))
		if extent < best_extent or (extent == best_extent and long_extent > best_long):
			orientation = candidate
			best_extent = extent
			best_long = long_extent
	var primary: ArrivalPlan = _plan_for(shape, orientation, board, api)
	if not primary.blocked:
		return primary
	ranked.sort_custom(func(a: Vector3i, b: Vector3i) -> bool:
		if a.y != b.y:
			return a.y < b.y
		if a.z != b.z:
			return a.z > b.z
		return a.x < b.x)
	for candidate: Vector3i in ranked:
		if candidate.x == orientation:
			continue
		var alt: ArrivalPlan = _plan_for(shape, candidate.x, board, api)
		if not alt.blocked:
			return alt
	return primary


@warning_ignore("integer_division")
func _plan_for(shape: ShapeDef, orientation: int, board: BoardState, api: RuleApi) -> ArrivalPlan:
	var plan := ArrivalPlan.new()
	var size: Vector3i = api.board_size()
	var down: Vector3i = api.down_vector()
	var down_axis: int = 1 if down.y != 0 else (0 if down.x != 0 else 2)
	var box: Vector3i = shape.bbox(orientation)
	var lo: Vector3i = shape.min_corner(orientation)
	var anchor: Vector2i = board.spawn_anchor()
	var target := Vector3i(anchor.x - (box.x - 1) / 2, (size.y - box.y) / 2, anchor.y - (box.z - 1) / 2)
	var limit: int = board.limit_layer()
	target[down_axis] = limit if down[down_axis] < 0 else size[down_axis] - limit - box[down_axis]
	# Even-width pieces cannot centre exactly on an integer cell anchor. Keep the
	# closest grounded origin inside the board rather than clipping an I4 spawn.
	for axis: int in 3:
		if axis != down_axis and box[axis] <= size[axis]:
			target[axis] = clampi(target[axis], 0, size[axis] - box[axis])
	plan.orient = orientation
	plan.travel_dir = down
	plan.origin = target - lo
	var cells: Array[Vector3i] = []
	for offset: Vector3i in shape.offsets(orientation):
		cells.append(plan.origin + offset)
	plan.blocked = not api.can_place(cells)
	return plan
