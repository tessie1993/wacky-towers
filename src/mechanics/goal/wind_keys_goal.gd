class_name WindKeysGoal extends GoalEvaluator
## Wall keys require both exact adjacent cell and rotated stamped face; wound holes persist.
const PLUGIN_ID := &"wind_keys"
var _target: int = 4
var _holes: Array = []
var _wound: Dictionary = {}
func configure(goal: Dictionary) -> void:
	_target = maxi(1, int(goal.get("keys_needed",4)))
	_holes = goal.get("keyholes",[]).duplicate(true)
	_wound.clear()
func on_lock(piece: ActivePiece, state: GoalState, api: RuleApi) -> void:
	var stamp: Variant = api.piece_flag(&"key_stamp", {})
	if not stamp is Dictionary or stamp.is_empty(): return
	var local_cell: Vector3i = stamp.get("cell", Vector3i.ZERO)
	var local_face: Vector3i = stamp.get("face", Vector3i.LEFT)
	var cell: Vector3i = piece.pivot + Orientations.apply(piece.orient, local_cell)
	var face: Vector3i = Orientations.apply(piece.orient, local_face)
	var size: Vector3i = api.board_size()
	for i: int in _holes.size():
		if _wound.has(i): continue
		var hole: Dictionary = _holes[i]
		var normal: Vector3i = MechanicsCells.direction(String(hole.get("wall","-x")))
		var target: Vector3i = Vector3i.ZERO
		target.y = int(hole.get("y",1))
		if normal.x != 0:
			target.x = 0 if normal.x < 0 else size.x-1
			target.z = int(hole.get("row",0))
		else:
			target.z = 0 if normal.z < 0 else size.z-1
			target.x = int(hole.get("row",0))
		if cell == target and face == normal:
			_wound[i] = true
			state.metrics["keys_wound"] = _wound.size()
			api.emit(&"key_wound", {"index":i,"cell":target,"normal":normal})
func evaluate(state: GoalState, _api: RuleApi) -> int:
	return WON if int(state.metrics.get("keys_wound",0)) >= _target else RUNNING
func progress(state: GoalState) -> Dictionary:
	return {"done":mini(_target,int(state.metrics.get("keys_wound",0))),"target":_target,"unit":"keys","wound":_wound.keys(),"keyholes":_holes.duplicate(true)}
func snapshot() -> Dictionary:
	return {"wound":_wound.duplicate(true)}
func restore(data: Dictionary) -> void:
	_wound = data.get("wound",{}).duplicate(true)
