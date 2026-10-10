extends GdUnitTestSuite
## Tests for RuleDef (CH-033, ADR-0004).


func test_defaults() -> void:
	var r: RuleDef = RuleDef.new()
	assert_str(String(r.id)).is_empty()
	assert_str(String(r.behaviour)).is_empty()
	assert_array(r.modifiers).is_empty()
	assert_array(r.vetoes).is_empty()
	assert_dict(r.params).is_empty()
	assert_dict(r.lifetime).is_empty()
	assert_int(r.incompatible_with.size()).is_equal(0)
	assert_int(r.tags_requires.size()).is_equal(0)
	assert_int(r.tags_provides.size()).is_equal(0)


func test_budget_layers() -> void:
	var r: RuleDef = RuleDef.new()
	r.layer = &"twist"
	assert_bool(r.counts_toward_budget()).is_true()
	r.layer = &"mechanic"
	assert_bool(r.counts_toward_budget()).is_true()
	r.layer = &"content"
	assert_bool(r.counts_toward_budget()).is_false()
	r.layer = &"mascot"
	assert_bool(r.counts_toward_budget()).is_false()
