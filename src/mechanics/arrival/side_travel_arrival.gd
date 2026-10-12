class_name SideTravelArrival extends ArrivalStyle
const PLUGIN_ID := &"side_travel"


func plan_arrival(shape: ShapeDef, board: BoardState, api: RuleApi) -> ArrivalPlan:
	return TopArrival.new().plan_arrival(shape, board, api)
