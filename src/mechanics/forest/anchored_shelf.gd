class_name AnchoredShelfRule extends RuleBehaviour
## BL17 immutable deck cells retain chambers beneath and openings above.
const PLUGIN_ID := &"anchored_shelf"

func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start"]

func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var kind: int = api.kind_of(&"shelf")
	if kind < 1: return
	var cells: Array[Vector3i] = MechanicsCells.occupied(api, kind)
	for raw: Variant in api.param(&"cells", []):
		if raw is Array and raw.size() == 3:
			var cell := Vector3i(int(raw[0]), int(raw[1]), int(raw[2]))
			if api.kind_at(cell) == kind or api.is_free(cell):
				if api.is_free(cell): api.set_cell(cell, kind)
				if not cells.has(cell): cells.append(cell)
	for cell: Vector3i in cells:
		var status: Dictionary = api.record_at(cell).get("status", {}).duplicate(true)
		status.merge({"fixed": true, "static_geometry": true, "anchored": true, "clear_protected": true, "fills_layer": false, "shelf": true}, true)
		api.set_status(cell, status)
