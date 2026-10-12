class_name WtContent extends RefCounted
## Trusted catalog loading and official campaign index. All level JSON still passes the untrusted loader.

var catalog: GameCatalog
var last_issues: Array[ValidationIssue] = []
var errors: PackedStringArray = PackedStringArray()
var _entries: Array[Dictionary] = []
var _raw: Dictionary = {}
var _levels: Dictionary = {}
var biome_order: Array = []

## Builds trusted shape/content/knob/rule/plugin tables and discovers the explicit campaign manifest.
func load_catalog() -> GameCatalog:
	catalog = GameCatalog.new()
	catalog.shapes = load("res://assets/data/shapes/shape_bank.tres") as ShapeBank
	catalog.content = ContentTypes.from_entries(_json("res://assets/data/content/blocks.json").get("types", []))
	var tables: Array = []
	for path: String in _json_files("res://assets/data/knobs"):
		tables.append(_json(path))
	catalog.knob_defs = KnobDefs.from_tables(tables)
	errors.append_array(catalog.knob_defs.errors())
	errors.append_array(catalog.content.errors)
	catalog.plugins = PluginRegistry.new(ProjectSettings.get_global_class_list())
	errors.append_array(catalog.plugins.errors())
	var limits: Dictionary = {}
	for field: String in ["min_side", "max_side", "min_height", "max_height", "max_cells", "max_errors", "min_active_per_layer", "spawn_clearance"]:
		limits[field] = catalog.knob_defs.def(StringName("board." + field)).get("default", BoardLimits.new().get(field))
	catalog.limits = BoardLimits.from_dict(limits)
	var colors: Dictionary = _json("res://assets/data/palettes/meadow.json").get("colors", {})
	for i: int in colors.size():
		catalog.palette.append(Color(str(colors.get(str(i), "#ffffff"))))
	for path: String in _json_files("res://assets/data/rules"):
		var source: Dictionary = _json(path)
		if not source.has("id"):
			continue
		var rule: RuleDef = RuleDef.new()
		rule.id = StringName(str(source.id))
		rule.layer = StringName(str(source.get("layer", "twist")))
		rule.icon = str(source.get("icon", "sparkle"))
		rule.name_key = str(source.get("name_key", "RULE_" + str(rule.id).to_upper()))
		rule.behaviour = StringName(str(source.get("behaviour", rule.id)))
		rule.params = source.get("params", {})
		rule.lifetime = source.get("lifetime", {})
		rule.tags_requires = PackedStringArray(source.get("tags_requires", []))
		rule.tags_provides = PackedStringArray(source.get("tags_provides", []))
		for modifier: Dictionary in source.get("modifiers", []): rule.modifiers.append(modifier)
		for veto: Dictionary in source.get("vetoes", []): rule.vetoes.append(veto)
		rule.incompatible_with = PackedStringArray(source.get("incompatible_with", []))
		catalog.rule_defs[rule.id] = rule
	var manifest: Dictionary = _json("res://assets/data/campaign/catalog.json")
	biome_order = manifest.get("biomes", [])
	_entries.clear()
	for entry: Dictionary in manifest.get("levels", []):
		_entries.append(entry)
	return catalog

## Returns sorted official metadata; id, biome, tier, display text, JSON and presentation scene.
func all_levels() -> Array[Dictionary]:
	return _entries.duplicate(true)

## Loads and caches one validated level; null indicates last_issues contains a refusal reason.
func level(id: String) -> LevelData:
	if catalog == null:
		load_catalog()
	if _levels.has(id):
		return _levels[id]
	for entry: Dictionary in _entries:
		if str(entry.id) == id:
			var raw: Dictionary = _json(str(entry.json))
			_raw[id] = raw
			var result: LoadResult = LevelLoader.parse_level(raw, catalog)
			last_issues = result.issues
			if result.ok():
				_levels[id] = result.level
			return result.level
	last_issues = [ValidationIssue.error(StringName(id), "id", &"missing_level", "level is not in campaign manifest")]
	return null

## Source JSON, including source design intent and production coverage metadata.
func raw_level(id: String) -> Dictionary:
	if not _raw.has(id):
		level(id)
	return _raw.get(id, {}).duplicate(true)

## Entry metadata by id, or an empty dictionary.
func metadata(id: String) -> Dictionary:
	for entry: Dictionary in _entries:
		if str(entry.id) == id:
			return entry.duplicate(true)
	return {}

func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("missing data file: " + path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		errors.append("invalid JSON object: " + path)
		return {}
	return parsed

func _json_files(folder: String) -> PackedStringArray:
	var files: PackedStringArray = PackedStringArray()
	var dir: DirAccess = DirAccess.open(folder)
	if dir == null:
		return files
	for file: String in dir.get_files():
		if file.ends_with(".json"):
			files.append(folder.path_join(file))
	files.sort()
	return files
