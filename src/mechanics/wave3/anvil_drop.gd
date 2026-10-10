class_name AnvilDropRule extends RuleBehaviour
## W4: every Nth piece is an anvil; on lock it crushes the gaps beneath its columns.
const PLUGIN_ID := &"anvil_drop"
var _spawns: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_spawn", &"on_lock"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_spawns = 0
	elif hook == &"on_spawn":
		# Held or injected pieces keep their own flags and never count a second spawn.
		if bool(api.piece_flag(&"anvil", false)) or bool(api.piece_flag(&"injected", false)):
			return
		_spawns += 1
		if _spawns % maxi(1, int(api.param(&"every", 6))) == 0:
			api.set_piece_flag(&"anvil", true)
			api.emit(&"anvil_spawned", {"uid": ctx.data.get("uid", 0)})
	elif hook == &"on_lock" and bool(api.piece_flag(&"anvil", false)):
		_crush(ctx, api)


func _crush(ctx: HookContext, api: RuleApi) -> void:
	var down: Vector3i = api.down_vector()
	var lowest: Dictionary = {}
	for c: Vector3i in ctx.data.get("cells", []):
		var key: Vector3i = Wave3Cells.flat_key(api, c)
		if not lowest.has(key) or api.layer_of(c) < api.layer_of(lowest[key]):
			lowest[key] = c
	var keys: Array = lowest.keys()
	keys.sort_custom(Wave3Cells.key_less)
	var src: Array[Vector3i] = []
	var dst: Array[Vector3i] = []
	var max_crush: int = maxi(0, int(api.param(&"max_crush", 3)))
	for key: Vector3i in keys:
		var anvil_cell: Vector3i = lowest[key]
		var gap: int = 0
		var probe: Vector3i = anvil_cell + down
		while api.is_active(probe) and api.kind_at(probe) == 0:
			gap += 1
			probe += down
		var moved: int = mini(max_crush, gap)
		if moved <= 0:
			continue
		var run: Vector3i = anvil_cell
		while api.is_active(run) and api.kind_at(run) != 0:
			src.append(run)
			dst.append(run + down * moved)
			run -= down
	if not src.is_empty():
		api.move_cells(src, dst)
	api.emit(&"anvil_crush", {"cells_moved": src.size()})


func snapshot() -> Dictionary:
	return {"spawns": _spawns}
