class_name MysteryPieceRule extends RuleBehaviour
## W6: every Nth spawned piece is a "?" whose real shape is revealed only at spawn.
const PLUGIN_ID := &"mystery_piece"
const _MAX_PREVIEW := 16
var _spawns: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_spawn"]


func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_spawns = 0
		return
	var every: int = maxi(1, int(api.param(&"every", 4)))
	_spawns += 1
	if _spawns % every == 0:
		var current: String = String(ctx.data.get("shape_id", ""))
		var pool: Array[String] = []
		for id: Variant in api.param(&"pool", api.shape_pool()):
			pool.append(String(id))
		var options: Array[String] = pool.filter(func(id: String) -> bool: return id != current)
		if options.is_empty():
			options = pool
		if not options.is_empty():
			var pick: String = options[0] if options.size() == 1 else options[api.rng().randi_range(0, options.size() - 1)]
			if api.replace_shape(StringName(pick)):
				api.set_piece_flag(&"mystery", true)
				api.emit(&"mystery_reveal", {"shape_id": StringName(pick)})
	# Queue index (0 = next to spawn) of the next mystery piece.
	var index: int = every - 1 - (_spawns % every)
	if index < api.preview_ids(_MAX_PREVIEW).size():
		api.emit(&"mystery_preview", {"index": index})


func snapshot() -> Dictionary:
	return {"spawns": _spawns}
