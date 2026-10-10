extends GdUnitTestSuite
## Tests for KnobRegistry base values (CH-014, ADR-0004 §3).


func _defs() -> KnobDefs:
	return KnobDefs.from_tables([{"knobs": [
		{"id": "fall.g0", "type": "scalar", "default": 0.6, "min": 0.1, "max": 3.0, "rule_adjustable": true},
		{"id": "fall.lock_delay_ms", "type": "count", "default": 500.0, "min": 100.0, "max": 2000.0, "allows_zero": false},
		{"id": "fall.hard_drop", "type": "flag", "default": true},
		{"id": "goal.top_out", "type": "slot", "default": "rescue", "choices": ["rescue", "trim", "lose"]},
		{"id": "view.occlusion", "type": "choice", "default": "fade", "choices": ["fade", "cutaway", "ghost"]},
	]}])


func _make(overrides: Dictionary[StringName, Variant]) -> KnobRegistry:
	return KnobRegistry.new(_defs(), overrides)


func test_defaults_without_overrides() -> void:
	var reg: KnobRegistry = _make({})
	assert_that(reg.value(&"fall.g0")).is_equal(600)
	assert_int(reg.int_value(&"fall.lock_delay_ms")).is_equal(500)
	assert_bool(reg.flag(&"fall.hard_drop")).is_true()
	assert_that(reg.value(&"goal.top_out")).is_equal(&"rescue")


func test_level_override_beats_default() -> void:
	var reg: KnobRegistry = _make({&"fall.g0": 0.9, &"goal.top_out": "trim"})
	assert_that(reg.value(&"fall.g0")).is_equal(900)
	assert_that(reg.value(&"goal.top_out")).is_equal(&"trim")
	assert_array(reg.errors()).is_empty()


func test_bad_override_keeps_default() -> void:
	var reg: KnobRegistry = _make({&"fall.g0": 9.0})
	assert_that(reg.value(&"fall.g0")).is_equal(600)
	assert_int(reg.errors().size()).is_equal(1)
	assert_str(reg.errors()[0]).contains("fall.g0")
	assert_str(reg.errors()[0]).contains("outside")


func test_unknown_override_is_error() -> void:
	var reg: KnobRegistry = _make({&"fall.nope": 1})
	assert_int(reg.errors().size()).is_equal(1)
	assert_str(reg.errors()[0]).contains("unknown knob")


func test_unknown_reads_are_neutral() -> void:
	var reg: KnobRegistry = _make({})
	assert_that(reg.value(&"x")).is_null()
	assert_int(reg.int_value(&"x")).is_equal(0)
	assert_bool(reg.flag(&"x")).is_false()
