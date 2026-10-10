extends GdUnitTestSuite
## Tests for RuleDef (CH-033).


func test_defaults() -> void:
	var d: RuleDef = RuleDef.new()
	assert_str(String(d.id)).is_empty()
	assert_str(String(d.layer)).is_empty()
	assert_str(String(d.behaviour)).is_empty()
	assert_int(d.params.size()).is_equal(0)
	assert_int(d.modifiers.size()).is_equal(0)
	assert_int(d.vetoes.size()).is_equal(0)
	assert_int(d.lifetime.size()).is_equal(0)
	assert_int(d.incompatible_with.size()).is_equal(0)
	assert_int(d.tags_requires.size()).is_equal(0)
	assert_int(d.tags_provides.size()).is_equal(0)


func test_budget_layers() -> void:
	var cases: Dictionary = {&"twist": true, &"mechanic": true, &"content": false, &"mascot": false}
	for layer: StringName in cases:
		var d: RuleDef = RuleDef.new()
		d.layer = layer
		assert_bool(d.counts_toward_budget()).is_equal(cases[layer])
