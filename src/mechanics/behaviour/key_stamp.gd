class_name KeyStampRule extends RuleBehaviour
## GO29 two pieces per actual bag carry a reproducible key cube and local face.
const PLUGIN_ID := &"key_stamp"
var _bag: int = -999
var _selected: Array[int] = []
func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn"]
func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var bag: int = int(api.piece_flag(&"bag_index",-1))
	var position: int = int(api.piece_flag(&"bag_position",-1))
	var size: int = int(api.piece_flag(&"bag_size",8))
	if bool(api.piece_flag(&"injected",false)) or bag < 0: return
	if bag != _bag:
		_bag = bag
		_selected.clear()
		var remaining: Array[int] = []
		for i: int in size: remaining.append(i)
		for i: int in mini(size,maxi(1,int(api.param(&"key_per_bag",2)))): _selected.append(remaining.pop_at(api.rng().randi_range(0,remaining.size()-1)))
	if not _selected.has(position): return
	var shape: ShapeDef = api.get_piece_shape()
	if shape == null: return
	var cells: Array[Vector3i] = shape.offsets(0)
	var faces: Array[Vector3i] = [Vector3i.LEFT,Vector3i.RIGHT,Vector3i.UP,Vector3i.DOWN,Vector3i(0,0,-1),Vector3i(0,0,1)]
	var visible: Array[Dictionary] = []
	for cell: Vector3i in cells:
		for face: Vector3i in faces:
			if not cells.has(cell+face): visible.append({"cell":cell,"face":face})
	if visible.is_empty(): return
	var stamp: Dictionary = visible[api.rng().randi_range(0,visible.size()-1)]
	api.set_piece_flag(&"key_stamp",stamp)
	api.emit(&"key_stamp",stamp)
func snapshot() -> Dictionary:
	return {"bag":_bag,"selected":_selected.duplicate()}
