class_name DandelionPuffRule extends RuleBehaviour
## Spawn draws one cut seed; rotations keep the same deterministic choice.
const PLUGIN_ID := &"dandelion_puff"
var _special: bool = false
var _cut_seed: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_lock"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_spawn":
		var tags_value: Variant = ctx.data.get("tags", PackedStringArray())
		_special = tags_value.has("dandelion_puff") or tags_value.has("puff")
		if _special:
			_cut_seed = api.rng().randi()
			api.emit(&"puff_seam", {"seed": _cut_seed})
		return
	if not _special:
		return
	var cells: Array[Vector3i] = []
	for c: Vector3i in ctx.data.get("cells", []):
		cells.append(c)
	var cut: Dictionary = choose_cut(cells, api.down_vector(), _cut_seed)
	if cut.is_empty():
		api.emit(&"puff_poof", {})
		return
	var a: Array[Vector3i] = []
	var b: Array[Vector3i] = []
	for c: Vector3i in cells:
		if c[int(cut["axis"])] <= int(cut["plane"]):
			a.append(c)
		else:
			b.append(c)
	var layer_a: int = 2147483647
	var layer_b: int = 2147483647
	for c: Vector3i in a:
		layer_a = mini(layer_a, api.layer_of(c))
	for c: Vector3i in b:
		layer_b = mini(layer_b, api.layer_of(c))
	var first: Array[Vector3i] = a if layer_a <= layer_b else b
	var second: Array[Vector3i] = b if layer_a <= layer_b else a
	var first_distance: int = MechanicsCells.rigid_distance_virtual(api, first, api.down_vector(), first)
	var first_final: Array[Vector3i] = MechanicsCells.translated(first, api.down_vector() * first_distance)
	var second_distance: int = MechanicsCells.rigid_distance_virtual(api, second, api.down_vector(), cells, first_final)
	var second_final: Array[Vector3i] = MechanicsCells.translated(second, api.down_vector() * second_distance)
	var from: Array[Vector3i] = []
	var to: Array[Vector3i] = []
	from.append_array(first)
	from.append_array(second)
	to.append_array(first_final)
	to.append_array(second_final)
	api.move_cells(from, to)
	var moved: int = first_distance + second_distance
	api.emit(&"puff_split", {"axis": cut["axis"], "plane": cut["plane"], "half_a": a, "half_b": b, "moved": moved})


static func choose_cut(cells: Array[Vector3i], down: Vector3i, cut_seed: int) -> Dictionary:
	var candidates: Array[Dictionary] = []
	var best_balance: int = 2147483647
	for axis: int in [0, 2, 1]:
		if down[axis] != 0 or cells.is_empty():
			continue
		var lo: int = cells[0][axis]
		var hi: int = lo
		for c: Vector3i in cells:
			lo = mini(lo, c[axis])
			hi = maxi(hi, c[axis])
		for plane: int in range(lo, hi):
			var a_count: int = 0
			for c: Vector3i in cells:
				if c[axis] <= plane:
					a_count += 1
			var balance: int = absi(cells.size() - 2 * a_count)
			if a_count == 0 or a_count == cells.size() or balance > best_balance:
				continue
			if balance < best_balance:
				candidates.clear()
				best_balance = balance
			candidates.append({"axis": axis, "plane": plane})
	return {} if candidates.is_empty() else candidates[posmod(cut_seed, candidates.size())]


func snapshot() -> Dictionary:
	return {"special": _special, "cut_seed": _cut_seed}
