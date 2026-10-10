class_name LevelValidator extends RefCounted
## Semantic validation after bounded JSON and BoardSpec parsing; safe for official and shared levels.

## Returns every semantic issue without mutating a level or touching storage.
static func validate(level: LevelData, catalog: GameCatalog) -> Array[ValidationIssue]:
	var issues: Array[ValidationIssue] = []
	var id: StringName = level.id
	if str(id).is_empty() or str(id).length() > 64 or str(id).contains("/") or str(id).contains(".."):
		issues.append(ValidationIssue.error(id, "id", &"invalid_id", "id must be a nonempty safe identifier, at most 64 characters"))
	if level.biome == &"" or level.tier < 1 or level.tier > 99:
		issues.append(ValidationIssue.error(id, "biome/tier", &"invalid_identity", "biome required and tier outside 1..99"))
	var shapes: PackedStringArray = level.pieces.get("shapes", PackedStringArray())
	if shapes.is_empty() or shapes.size() > 16:
		issues.append(ValidationIssue.error(id, "pieces.shapes", &"pool_size", "pool must contain 1..16 shapes"))
	if shapes.size() > 8:
		issues.append(ValidationIssue.warn(id, "pieces.shapes", &"author_pool_exception", "authored pool exceeds the eight-shape tuning guideline"))
	var seen: Dictionary = {}
	for shape_id: String in shapes:
		if seen.has(shape_id):
			issues.append(ValidationIssue.error(id, "pieces.shapes", &"duplicate", "shape ids must be unique"))
		seen[shape_id] = true
		var shape: ShapeDef = catalog.shapes.get_shape(StringName(shape_id))
		if shape != null and not level.boards.is_empty():
			var bounds: Vector3i = shape.bbox(shape.spawn_orient)
			var board: BoardSpec = level.boards[0]
			if bounds.x > board.size.x or bounds.z > board.size.z:
				issues.append(ValidationIssue.error(id, "pieces.shapes", &"shape_fit", "%s spawn orientation does not fit" % shape_id))
	var weights: Dictionary = level.pieces.get("weights", {})
	var positive: int = 0
	for value: Variant in weights.values():
		positive += int(value)
	if positive == 0:
		issues.append(ValidationIssue.error(id, "pieces.weights", &"empty_bag", "at least one shape needs positive weight"))
	if positive > int(catalog.knob_defs.def(&"spawn.bag_max_size").get("default", 32)):
		issues.append(ValidationIssue.error(id, "pieces.weights", &"bag_cap", "normalized bag exceeds cap"))
	var goal: String = str(level.goal.get("type", ""))
	if goal not in ["clear_n", "height", "shape", "survive", "endless", "rescue_all", "bonk_boss", "dig_rescue", "wind_keys", "bake_oven"]:
		issues.append(ValidationIssue.error(id, "goal.type", &"unknown_goal", "unsupported goal '%s'" % goal))
	if goal == "clear_n" and (JsonNum.whole_int(level.goal.get("n")) == null or int(level.goal.get("n", 0)) < 1):
		issues.append(ValidationIssue.error(id, "goal.n", &"goal_target", "clear count must be a positive integer"))
	var required_counts: Dictionary = {"bonk_boss":"bonks_needed", "dig_rescue":"critters_needed", "wind_keys":"keys_needed", "survive":"t_ms", "height":"h_target", "bake_oven":"h_target"}
	if required_counts.has(goal):
		var key: String = required_counts[goal]
		var count: Variant = JsonNum.whole_int(level.goal.get(key))
		if count == null or count < 1:
			issues.append(ValidationIssue.error(id, "goal."+key, &"goal_target", "target must be a positive integer"))
	if goal == "rescue_all" and catalog.content.kind_of(StringName(str(level.goal.get("content", "")))) == 0:
		issues.append(ValidationIssue.error(id, "goal.content", &"unknown_content", "rescue content type must exist"))
	if level.goal.has("piece_budget"):
		var budget: Variant = JsonNum.whole_int(level.goal.piece_budget)
		if budget == null or budget < 1 or budget > 256:
			issues.append(ValidationIssue.error(id, "goal.piece_budget", &"budget", "piece budget outside 1..256"))
	if goal == "shape" and not level.boards.is_empty():
		var board: BoardSpec = level.boards[0]
		var target: Variant = level.goal.get("target_shape", {})
		if not target is Dictionary:
			issues.append(ValidationIssue.error(id, "goal.target_shape", &"wrong_type", "target must be an object"))
			target = {}
		var parsed: Dictionary = AsciiGrid.parse_layers({"layers": target.get("layers", {})}, Vector3i(board.size.x, board.h_play, board.size.z), "+#PVM" if target.get("colours", false) else "+#", "goal.target_shape")
		for message: String in parsed.errors:
			issues.append(ValidationIssue.error(id, "goal.target_shape", &"target", message))
		for cell: Dictionary in parsed.cells:
			var position: Vector3i = cell.cell
			if board.mask[position.x + board.size.x * position.z] == 0:
				issues.append(ValidationIssue.error(id, "goal.target_shape", &"masked_target", "target occupies a masked cell"))
		if parsed.cells.is_empty():
			issues.append(ValidationIssue.error(id, "goal.target_shape", &"empty_target", "target must include at least one cell"))
	var twists: int = 0
	var mechanics: int = 0
	var selected: Dictionary = {}
	for entry: Dictionary in level.rules:
		var rule_id: StringName = StringName(str(entry.get("id", "")))
		var definition: RuleDef = catalog.rule_defs.get(rule_id)
		if definition == null:
			issues.append(ValidationIssue.error(id, "rules", &"unknown_rule", "unsupported rule '%s'" % rule_id))
			continue
		if selected.has(rule_id):
			issues.append(ValidationIssue.error(id, "rules", &"duplicate_rule", "duplicate rule '%s'" % rule_id))
		selected[rule_id] = true
		twists += 1 if definition.layer == &"twist" else 0
		mechanics += 1 if definition.layer == &"mechanic" else 0
		if definition.icon.is_empty():
			issues.append(ValidationIssue.error(id, "rules", &"missing_icon", "rule needs a visible icon"))
		var params: Variant = entry.get("params", {})
		if not params is Dictionary:
			issues.append(ValidationIssue.error(id, "rules.params", &"wrong_type", "params must be an object"))
			continue
		if not definition.params.is_empty():
			for key: Variant in params:
				var field: String = "rules.%s.params.%s" % [rule_id, key]
				if not definition.params.has(key):
					issues.append(ValidationIssue.error(id, field, &"unknown_parameter", "unknown parameter"))
					continue
				var schema: Dictionary = definition.params[key]
				var value: Variant = params[key]
				var type: String = str(schema.get("type", ""))
				var valid: bool = true
				match type:
					"number": valid = (value is int or value is float) and is_finite(float(value)) and absf(float(value)) <= 1000000000
					"flag": valid = value is bool
					"string": valid = value is String and value.length() <= 128
					"structure": valid = value is Dictionary or value is Array
				if valid and type == "number":
					valid = (not schema.has("min") or float(value) >= float(schema.min)) and (not schema.has("max") or float(value) <= float(schema.max))
				if valid and schema.has("choices"):
					valid = schema.choices.has(value)
				if not valid:
					issues.append(ValidationIssue.error(id, field, &"parameter_type", "invalid %s parameter" % type))
		for other: String in definition.incompatible_with:
			for candidate: Dictionary in level.rules:
				if str(candidate.id) == other:
					issues.append(ValidationIssue.error(id, "rules", &"incompatible", "%s conflicts with %s" % [rule_id, other]))
	if twists > (3 if level.tier == 10 else 2) or mechanics > 1:
		issues.append(ValidationIssue.error(id, "rules", &"rule_budget", "maximum two twists (three in finale) and one mechanic"))
	if level.stars.has("t3") and level.stars.has("t2"):
		if int(level.stars.t3) < 0 or int(level.stars.t3) > int(level.stars.t2):
			issues.append(ValidationIssue.error(id, "stars", &"star_order", "0 <= t3 <= t2 required"))
	if level.stars.has("s3") and level.stars.has("s2") and int(level.stars.s3) < int(level.stars.s2):
		issues.append(ValidationIssue.error(id, "stars", &"star_order", "s3 >= s2 required"))
	return issues
