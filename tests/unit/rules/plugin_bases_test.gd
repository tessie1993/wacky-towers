extends GdUnitTestSuite
## CH-021: abstract plugin bases.

class _B extends RuleBehaviour:
	pass


func test_bases_are_abstract() -> void:
	for f: String in ["rule_behaviour", "clear_detector", "collapse_policy", "arrival_style"]:
		var script: GDScript = load("res://src/core/rules/bases/%s.gd" % f)
		assert_bool(script.is_abstract()).is_true()


func test_fixture_detector_works() -> void:
	assert_that(TestOnlyDetector.new().find_clears(null, null)[0].cells).is_equal(PackedInt32Array([7]))


func test_default_tags_empty() -> void:
	assert_bool(TestOnlyDetector.new().tags().is_empty()).is_true()


func test_rule_behaviour_defaults() -> void:
	var b := _B.new()
	assert_bool(b.subscribed_hooks().is_empty()).is_true()
	assert_bool(b.veto(&"x", HookContext.new(), null)).is_false()
