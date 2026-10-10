class_name TopArrival extends ArrivalStyle
## `top` arrival: piece spawns centred above the play height, falling along the board's down vector (CH-059).

const PLUGIN_ID := &"top"


## Plan for `shape`: centred on the footprint, top touching the ceiling, blocked if the cells are not free.
## Even sizes round toward -x/-z. Masked-board tie rule (G7) is a later chunk. Usage: `style.plan_arrival(shape, board, api)`.
@warning_ignore("integer_division")
func plan_arrival(shape: ShapeDef, _board: BoardState, api: RuleApi) -> ArrivalPlan:
	var plan: ArrivalPlan = ArrivalPlan.new()
	var o: int = shape.spawn_orient
	var size: Vector3i = api.board_size()
	var box: Vector3i = shape.bbox(o)
	var lo: Vector3i = shape.min_corner(o)
	plan.orient = o
	plan.travel_dir = api.down_vector()
	# Target min corner of the bbox, then shift by -lo because offsets are pivot-relative.
	plan.origin = Vector3i((size.x - box.x) / 2, size.y - box.y, (size.z - box.z) / 2) - lo
	var cells: Array[Vector3i] = []
	for off: Vector3i in shape.offsets(o):
		cells.append(plan.origin + off)
	plan.blocked = not api.can_place(cells)
	return plan
