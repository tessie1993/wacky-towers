class_name KitArrival extends ArrivalStyle
## Kit inventory is selected by semantic command; each chosen piece uses legal top arrival.
const PLUGIN_ID := &"kit_box"

func plan_arrival(shape: ShapeDef, board: BoardState, api: RuleApi) -> ArrivalPlan:
	return TopArrival.new().plan_arrival(shape, board, api)
