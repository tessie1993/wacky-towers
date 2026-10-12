class_name RainbowPieceRule extends RuleBehaviour
## Wildcard status belongs to the locked cubes and follows every content move.
const PLUGIN_ID := &"rainbow_piece"
var _special: bool = false


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_lock"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_spawn":
		_special = ctx.data.get("tags", PackedStringArray()).has("rainbow")
		if _special:
			api.emit(&"rainbow_piece", {"cells": api.piece_cells()})
		return
	if not _special:
		return
	for c: Vector3i in ctx.data.get("cells", []):
		api.set_status(c, {"status_id": 27, "counter": 0, "rule_id": PLUGIN_ID, "rainbow": true})


func snapshot() -> Dictionary:
	return {"special": _special}
