class_name RockObstacleRule extends RuleBehaviour
## BL18 rock is permanent solid geometry excluded from the live clear denominator.
const PLUGIN_ID := &"rock_obstacle"

func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start"]

func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var kind: int = api.kind_of(&"rock")
	if kind < 1: return
	for cell: Vector3i in MechanicsCells.occupied(api, kind):
		var status: Dictionary = api.record_at(cell).get("status", {}).duplicate(true)
		status.merge({"fixed": true, "static_geometry": true, "anchored": true, "clear_protected": true, "fills_layer": false, "rock_geometry": true}, true)
		api.set_status(cell, status)
