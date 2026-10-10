extends GdUnitTestSuite

const BLOCKS_JSON := "res://assets/data/content/blocks.json"


func _entries() -> Array:
	return [
		{"id": "block", "kind_id": 1.0, "glyph": "", "slot": "cell", "solid": true, "fills_layer": true, "hue": 0.0, "mesh": ""},
		{"id": "starter", "kind_id": 2.0, "glyph": "#", "slot": "cell", "solid": true, "fills_layer": true, "hue": 0.0, "mesh": ""},
	]


func test_lookups_for_block_and_starter() -> void:
	var t: ContentTypes = ContentTypes.from_entries(_entries())
	assert_int(t.kind_of_glyph("#")).is_equal(2)
	assert_int(t.kind_of(&"block")).is_equal(1)
	assert_that(t.id_of(2)).is_equal(&"starter")
	assert_bool(t.is_solid(2)).is_true()
	assert_bool(t.fills_layer(1)).is_true()
	assert_int(t.slot(2)).is_equal(ContentTypes.SLOT_CELL)
	assert_bool(t.errors.is_empty()).is_true()


func test_unknown_lookups_are_neutral() -> void:
	var t: ContentTypes = ContentTypes.from_entries(_entries())
	assert_int(t.kind_of_glyph("x")).is_equal(-1)
	assert_int(t.kind_of_glyph(".")).is_equal(-1)
	assert_that(t.id_of(99)).is_equal(&"")
	assert_bool(t.is_solid(99)).is_false()
	assert_bool(t.fills_layer(99)).is_false()
	assert_int(t.slot(99)).is_equal(-1)
	assert_int(t.hue(99)).is_equal(0)
	assert_int(t.kind_of(&"nope")).is_equal(-1)


func test_glyphs_is_legal_string() -> void:
	assert_str(ContentTypes.from_entries(_entries()).glyphs()).is_equal("#")


func test_solid_overlay_rejected() -> void:
	var e: Array = _entries()
	e.append({"id": "moss", "kind_id": 3, "glyph": "o", "slot": "overlay", "solid": true, "fills_layer": false, "hue": 0, "mesh": ""})
	var t: ContentTypes = ContentTypes.from_entries(e)
	assert_int(t.errors.size()).is_equal(1)
	assert_str(t.errors[0]).contains("content[2]")
	assert_str(t.errors[0]).contains("overlay")
	assert_int(t.kind_of(&"moss")).is_equal(-1)


func test_duplicate_kind_and_glyph_rejected() -> void:
	var e: Array = _entries()
	e.append({"id": "a", "kind_id": 2, "glyph": "a", "slot": "cell", "solid": true, "fills_layer": true, "hue": 0, "mesh": ""})
	var t: ContentTypes = ContentTypes.from_entries(e)
	assert_int(t.errors.size()).is_equal(1)
	assert_int(t.kind_of(&"a")).is_equal(-1)
	e = _entries()
	e.append({"id": "b", "kind_id": 3, "glyph": "#", "slot": "cell", "solid": true, "fills_layer": true, "hue": 0, "mesh": ""})
	t = ContentTypes.from_entries(e)
	assert_int(t.errors.size()).is_equal(1)
	assert_int(t.kind_of(&"b")).is_equal(-1)


func test_bad_kind_id_rejected() -> void:
	for bad: Variant in [0, 256, 2.5, "2"]:
		var e: Array = _entries()
		e.append({"id": "z", "kind_id": bad, "glyph": "z", "slot": "cell", "solid": true, "fills_layer": true, "hue": 0, "mesh": ""})
		var t: ContentTypes = ContentTypes.from_entries(e)
		assert_int(t.errors.size()).override_failure_message("kind_id %s" % str(bad)).is_equal(1)
		assert_int(t.kind_of(&"z")).is_equal(-1)


func test_blocks_json_is_valid_and_loads() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(BLOCKS_JSON))
	assert_bool(parsed is Dictionary).is_true()
	var t: ContentTypes = ContentTypes.from_entries((parsed as Dictionary)["types"])
	assert_bool(t.errors.is_empty()).is_true()
	assert_int(t.kind_of_glyph("#")).is_equal(2)
