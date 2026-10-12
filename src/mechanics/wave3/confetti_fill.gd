class_name ConfettiFillRule extends RuleBehaviour
## W12: a multi-layer clear fires confetti that fills up to N covered holes.
const PLUGIN_ID := &"confetti_fill"
var _base: int = 0
var _latest: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_lock", &"on_clear", &"on_resolve_end"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	match hook:
		&"on_lock":
			_base = int(ctx.data.get("clear_count", 0))
			_latest = _base
		&"on_clear":
			_latest = maxi(_latest, int(ctx.data.get("clear_count", 0)))
		&"on_resolve_end":
			var layers: int = maxi(int(ctx.data.get("cleared", 0)), _latest - _base)
			_base = _latest
			if layers >= maxi(1, int(api.param(&"min_layers", 2))):
				_fill(api)


func _fill(api: RuleApi) -> void:
	var down: Vector3i = api.down_vector()
	var holes: Array[Vector3i] = []
	for c: Vector3i in MechanicsCells.all(api):
		if api.kind_at(c) != 0:
			continue
		var above: Vector3i = c - down
		while api.is_active(above):
			if api.kind_at(above) != 0:
				holes.append(c)
				break
			above -= down
	var kind: int = api.kind_of(&"block")
	var filled: Array[Vector3i] = []
	for c: Vector3i in holes:
		if filled.size() >= maxi(0, int(api.param(&"max_fill", 3))):
			break
		api.set_cell(c, kind, 0)
		api.set_status(c, {"confetti": true, "rule_id": PLUGIN_ID})
		filled.append(c)
	if not filled.is_empty():
		api.emit(&"confetti", {"cells": filled})


func snapshot() -> Dictionary:
	return {"base": _base, "latest": _latest}
