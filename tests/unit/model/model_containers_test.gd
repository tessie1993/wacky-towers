extends GdUnitTestSuite


func test_level_defaults() -> void:
	var l: LevelData = LevelData.new()
	assert_str(String(l.layout_kind)).is_equal("single")
	assert_int(l.seed).is_equal(LevelData.NO_SEED)
	assert_bool(l.boards.is_empty()).is_true()


func test_level_typed_fields() -> void:
	var l: LevelData = LevelData.new()
	var b: BoardSpec = BoardSpec.new()
	l.boards.append(b)
	l.knobs[&"fall.g0"] = 600
	assert_object(l.boards[0]).is_same(b)
	assert_int(l.knobs[&"fall.g0"]).is_equal(600)


func test_catalog_holds_parts() -> void:
	var c: GameCatalog = GameCatalog.new()
	var s: ShapeBank = ShapeBank.new()
	var lim: BoardLimits = BoardLimits.new()
	c.shapes = s
	c.limits = lim
	assert_object(c.shapes).is_same(s)
	assert_object(c.limits).is_same(lim)
