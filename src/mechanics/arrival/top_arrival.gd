class_name TopArrival extends ArrivalStyle
## Bounding-box centre follows the level anchor; the lowest cube begins at the danger line.

const PLUGIN_ID := &"top"


@warning_ignore("integer_division")
func plan_arrival(shape: ShapeDef, board: BoardState, api: RuleApi) -> ArrivalPlan:
	var plan := ArrivalPlan.new()
	var orientation: int = shape.spawn_orient
	var size: Vector3i = api.board_size()
	var down: Vector3i = api.down_vector()
	var down_axis: int = 1 if down.y != 0 else (0 if down.x != 0 else 2)
	# The flattest face is perpendicular to current gravity, including sideways arrivals.
	var best_extent: int = shape.bbox(orientation)[down_axis]
	var long_axis: int = 0 if down_axis != 0 else 2
	var best_long: int = shape.bbox(orientation)[long_axis]
	for candidate: int in Orientations.COUNT:
		var extent: int = shape.bbox(candidate)[down_axis]
		var long_extent: int = shape.bbox(candidate)[long_axis]
		if extent < best_extent or (extent == best_extent and long_extent > best_long):
			orientation = candidate
			best_extent = extent
			best_long = long_extent
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
