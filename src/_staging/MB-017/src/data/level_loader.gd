class_name LevelLoader extends RefCounted
## Reads a level file and builds LevelData with fixed-point knobs and int piece weights (ADR-0005).
## Minimal: no rule budget or plugin validate() (that is the later LevelValidator).
## Usage: var r: LoadResult = LevelLoader.load_level("res://src/levels/meadow/meadow_01/meadow_01.json", catalog)

const MAX_LEVEL_BYTES := 65536 # ADR-0005 untrusted level file cap (tunable)
const KEYS_TOP: Array[String] = ["schema", "id", "biome", "tier", "name", "board", "pieces", "knobs", "goal", "rules", "stars", "story", "seed"]
const KEYS_REQUIRED: Array[String] = ["id", "board", "goal"]
const BAG_MAX_KNOB := &"spawn.bag_max_size"
const _LIMIT_FIELDS: Array[String] = ["min_side", "max_side", "min_height", "max_height", "max_cells", "max_errors", "min_active_per_layer"]


## Reads and parses a level file. Usage: LevelLoader.load_level(path, catalog)
static func load_level(path: String, catalog: GameCatalog) -> LoadResult:
	var read: Dictionary = JsonReader.read_file(path, MAX_LEVEL_BYTES)
	if not read["ok"]:
		var r: LoadResult = LoadResult.new()
		r.issues.append(ValidationIssue.error(StringName(path.get_file().get_basename()), "", &"read_failed", read["error"]))
		return r
	return parse_level(read["data"], catalog)


## Parses an already-decoded level dictionary. Usage: LevelLoader.parse_level({"id": "x", ...}, catalog)
static func parse_level(raw: Dictionary, catalog: GameCatalog) -> LoadResult:
	var result: LoadResult = LoadResult.new()
	var issues: Array[ValidationIssue] = result.issues
	var id: StringName = StringName(str(raw.get("id", "")))
	for key: Variant in raw:
		if not (str(key) in KEYS_TOP):
			issues.append(ValidationIssue.warn(id, str(key), &"unknown_key", "unknown top-level key"))
	for key: String in KEYS_REQUIRED:
		if not raw.has(key):
			issues.append(ValidationIssue.error(id, key, &"missing", "required"))
	if _has_error(issues):
		return result
	var level: LevelData = LevelData.new()
	level.id = id
	level.biome = StringName(str(raw.get("biome", "")))
	level.name_key = str(raw.get("name", ""))
	level.level_hash = JSON.stringify(raw, "", true).sha256_text()
	var tier: Variant = JsonNum.whole_int(raw.get("tier", 0))
	var schema: Variant = JsonNum.whole_int(raw.get("schema", 1))
	var seed_v: Variant = JsonNum.whole_int(raw.get("seed", LevelData.NO_SEED))
	if tier == null or schema == null or seed_v == null:
		issues.append(ValidationIssue.error(id, "tier/schema/seed", &"not_whole", "must be whole numbers"))
	else:
		level.tier = tier
		level.schema = schema
		level.seed = seed_v
	var pieces_raw: Dictionary = _dict(raw, "pieces", id, issues)
	var knobs_raw: Dictionary = _dict(raw, "knobs", id, issues)
	level.goal = _dict(raw, "goal", id, issues)
	level.story = _dict(raw, "story", id, issues)
	level.knobs = _parse_knobs(knobs_raw, catalog, id, issues)
	var bag_max: int = _bag_max(level.knobs, catalog)
	var clearance: int = _parse_pieces(pieces_raw, level, bag_max, catalog, id, issues)
	_parse_board(raw.get("board"), clearance, level, catalog, id, issues)
	_parse_rules_stars(raw, level, id, issues)
	if not _has_error(issues):
		result.level = level
	return result


static func _has_error(issues: Array[ValidationIssue]) -> bool:
	for i: ValidationIssue in issues:
		if i.is_error():
			return true
	return false


## raw[key] as a Dictionary ({} when absent); a wrong type is an error.
static func _dict(raw: Dictionary, key: String, id: StringName, issues: Array[ValidationIssue]) -> Dictionary:
	var v: Variant = raw.get(key, {})
	if v is Dictionary:
		return v
	issues.append(ValidationIssue.error(id, key, &"wrong_type", "must be an object"))
	return {}


static func _parse_knobs(knobs_raw: Dictionary, catalog: GameCatalog, id: StringName, issues: Array[ValidationIssue]) -> Dictionary[StringName, Variant]:
	var out: Dictionary[StringName, Variant] = {}
	for key: Variant in knobs_raw:
		var kid: StringName = StringName(str(key))
		var field: String = "knobs." + str(key)
		if not catalog.knob_defs.has(kid):
			issues.append(ValidationIssue.error(id, field, &"unknown_knob", "unknown knob '%s'" % str(key)))
			continue
		var v: Variant = catalog.knob_defs.coerce(kid, knobs_raw[key])
		if v == null:
			issues.append(ValidationIssue.error(id, field, &"bad_knob_value", catalog.knob_defs.last_error()))
			continue
		out[kid] = v
	return out


## Level override of spawn.bag_max_size, else the catalog default.
static func _bag_max(knobs: Dictionary[StringName, Variant], catalog: GameCatalog) -> int:
	if knobs.has(BAG_MAX_KNOB):
		return knobs[BAG_MAX_KNOB]
	return catalog.knob_defs.def(BAG_MAX_KNOB).get("default", 32)


## Fills level.pieces; returns the spawn clearance (longest shape extent, floor 1).
static func _parse_pieces(p: Dictionary, level: LevelData, bag_max: int, catalog: GameCatalog, id: StringName, issues: Array[ValidationIssue]) -> int:
	var shapes: PackedStringArray = _shape_ids(p.get("shapes", []), "pieces.shapes", catalog, id, issues)
	var opening: PackedStringArray = _shape_ids(p.get("opening_set", []), "pieces.opening_set", catalog, id, issues)
	var count: Variant = JsonNum.whole_int(p.get("opening_count", opening.size()))
	if count == null:
		issues.append(ValidationIssue.error(id, "pieces.opening_count", &"not_whole", "must be a whole number"))
		count = 0
	var raw_w: Variant = p.get("weights", {})
	var weights: Dictionary[StringName, int] = {}
	if raw_w is Dictionary:
		weights = _weights_to_copies(shapes, raw_w, bag_max, id, issues)
	else:
		issues.append(ValidationIssue.error(id, "pieces.weights", &"wrong_type", "must be an object"))
	level.pieces = {"shapes": shapes, "weights": weights, "opening_set": opening, "opening_count": count}
	var longest: int = 1
	for s: String in shapes:
		var def: ShapeDef = catalog.shapes.get_shape(StringName(s))
		if def != null:
			var b: Vector3i = def.bbox(def.spawn_orient)
			longest = maxi(longest, maxi(b.x, maxi(b.y, b.z)))
	return longest


static func _shape_ids(raw: Variant, field: String, catalog: GameCatalog, id: StringName, issues: Array[ValidationIssue]) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	if not (raw is Array):
		issues.append(ValidationIssue.error(id, field, &"wrong_type", "must be an array of shape ids"))
		return out
	for i: int in (raw as Array).size():
		var sid: String = str(raw[i])
		if not catalog.shapes.has_shape(StringName(sid)):
			issues.append(ValidationIssue.error(id, "%s[%d]" % [field, i], &"unknown_shape", "unknown shape '%s'" % sid))
		out.append(sid)
	return out


## Spawner GDD F1 (G3): smallest positive weight = 1 copy, others rounded; 0 = never; total capped at bag_max.
static func _weights_to_copies(shapes: PackedStringArray, raw_w: Dictionary, bag_max: int, id: StringName, issues: Array[ValidationIssue]) -> Dictionary[StringName, int]:
	var out: Dictionary[StringName, int] = {}
	var w_min: float = INF
	var ws: Dictionary = {}
	for s: String in shapes:
		var w: Variant = raw_w.get(s, 1)
		if not (typeof(w) == TYPE_INT or typeof(w) == TYPE_FLOAT) or not is_finite(float(w)) or float(w) < 0.0:
			issues.append(ValidationIssue.error(id, "pieces.weights." + s, &"bad_weight", "must be a number >= 0"))
			continue
		ws[s] = float(w)
		if float(w) > 0.0:
			w_min = minf(w_min, float(w))
	var total: int = 0
	for s: String in ws:
		var copies: int = 0 if ws[s] <= 0.0 else maxi(1, roundi(ws[s] / w_min))
		out[StringName(s)] = copies
		total += copies
	if total > bag_max:
		# ponytail: proportional shrink keeping >=1 copy; may still exceed the cap if shapes > bag_max.
		for k: StringName in out:
			if out[k] > 0:
				out[k] = maxi(1, out[k] * bag_max / total)
	return out


static func _parse_board(raw: Variant, clearance: int, level: LevelData, catalog: GameCatalog, id: StringName, issues: Array[ValidationIssue]) -> void:
	if not (raw is Dictionary):
		issues.append(ValidationIssue.error(id, "board", &"wrong_type", "must be an object"))
		return
	var limits: BoardLimits = BoardLimits.new()  # per-level copy; the catalog limits stay untouched
	for f: String in _LIMIT_FIELDS:
		limits.set(f, catalog.limits.get(f))
	limits.spawn_clearance = clearance
	var r: BoardSpecResult = BoardSpec.parse(raw, limits, catalog.content)
	for msg: String in r.errors:
		var cut: int = msg.find(": ")
		var field: String = msg.substr(0, cut) if cut >= 0 else "board"
		issues.append(ValidationIssue.error(id, field, &"board", msg.substr(cut + 2) if cut >= 0 else msg))
	if r.spec != null:
		level.boards.append(r.spec)


static func _parse_rules_stars(raw: Dictionary, level: LevelData, id: StringName, issues: Array[ValidationIssue]) -> void:
	var rules: Variant = raw.get("rules", [])
	if rules is Array:
		for i: int in (rules as Array).size():
			var entry: Variant = rules[i]
			if entry is Dictionary and (entry as Dictionary).has("id"):
				level.rules.append(entry)
			else:
				issues.append(ValidationIssue.error(id, "rules[%d]" % i, &"wrong_type", "must be an object with an id"))
	else:
		issues.append(ValidationIssue.error(id, "rules", &"wrong_type", "must be an array"))
	var stars: Variant = raw.get("stars", {})
	if not (stars is Dictionary):
		issues.append(ValidationIssue.error(id, "stars", &"wrong_type", "must be an object"))
		return
	for k: Variant in stars:
		var v: Variant = JsonNum.whole_int(stars[k])
		if v == null:
			issues.append(ValidationIssue.error(id, "stars." + str(k), &"not_whole", "must be a whole number"))
		else:
			level.stars[str(k)] = v
