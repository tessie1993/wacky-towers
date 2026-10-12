class_name MechanicsFixture extends RefCounted
## Rules run against the real write facade; tests explicitly flush hook boundaries.


static func types() -> ContentTypes:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/content/blocks.json"))
	return ContentTypes.from_entries(data["types"])


static func board(width: int = 4, depth: int = 4, height: int = 6, down: int = BoardState.Down.Y_NEG) -> BoardState:
	return BoardState.new(BoardFixtures.spec(width, depth, height, down), types())


static func api(board_value: BoardState, params: Dictionary = {}, seed: int = 42) -> RuleApi:
	var knobs := KnobRegistry.new(KnobDefs.from_tables([]), {})
	var facade := RuleApi.new(board_value, knobs, params)
	var catalog := GameCatalog.new()
	catalog.content = types()
	facade.configure(catalog, seed, &"mechanics_test")
	return facade


static func api_with_knobs(board_value: BoardState, overrides: Dictionary[StringName, Variant] = {}) -> RuleApi:
	var tables: Array = []
	for file: String in DirAccess.get_files_at("res://assets/data/knobs"):
		if file.ends_with(".json"):
			tables.append(JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/knobs/" + file)))
	var defs := KnobDefs.from_tables(tables)
	var knobs := KnobRegistry.new(defs, overrides)
	var facade := RuleApi.new(board_value, knobs)
	var catalog := GameCatalog.new()
	catalog.content = types()
	facade.configure(catalog, 42, &"mechanics_test")
	return facade


static func context(data: Dictionary = {}) -> HookContext:
	var ctx := HookContext.new()
	ctx.data = data
	return ctx


static func write(board_value: BoardState, cells: Array[Vector3i], uid: int = 1, kind: int = 1) -> void:
	for c: Vector3i in cells:
		board_value.place(board_value.index(c), kind, 1, uid)


static func handle(rule: RuleBehaviour, hook: StringName, facade: RuleApi, data: Dictionary = {}) -> void:
	rule.handle(hook, context(data), facade)
	facade.flush_writes()
