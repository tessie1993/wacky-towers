extends GdUnitTestSuite
## Tests for KnobDefs (CH-012, ADR-0004 §3).


func _table() -> Dictionary:
	return {"knobs": [
		{"id": "fall.g0", "type": "scalar", "default": 0.6, "min": 0.1, "max": 3.0, "rule_adjustable": true},
		{"id": "fall.lock_delay_ms", "type": "count", "default": 500.0, "min": 100.0, "max": 2000.0, "allows_zero": false},
		{"id": "fall.hard_drop", "type": "flag", "default": true},
		{"id": "goal.top_out", "type": "slot", "default": "rescue", "choices": ["rescue", "trim", "lose"]},
		{"id": "view.occlusion", "type": "choice", "default": "fade", "choices": ["fade", "cutaway", "ghost"]},
	]}


func test_valid_table_loads() -> void:
	var defs: KnobDefs = KnobDefs.from_tables([_table()])
	assert_array(defs.errors()).is_empty()
	var expected: Array[StringName] = [&"fall.g0", &"fall.hard_drop", &"fall.lock_delay_ms", &"goal.top_out", &"view.occlusion"]
	assert_array(defs.ids()).is_equal(expected)
	assert_bool(defs.has(&"fall.g0")).is_true()


func test_scalar_is_fixed_point() -> void:
	var d: Dictionary = KnobDefs.from_tables([_table()]).def(&"fall.g0")
	assert_int(d["default"]).is_equal(600)
	assert_int(d["min"]).is_equal(100)
	assert_int(d["max"]).is_equal(3000)
	assert_bool(d["rule_adjustable"]).is_true()


func test_count_and_defaults() -> void:
	var d: Dictionary = KnobDefs.from_tables([_table()]).def(&"fall.lock_delay_ms")
	assert_int(typeof(d["default"])).is_equal(TYPE_INT)
	assert_int(d["default"]).is_equal(500)
	assert_bool(d["allows_zero"]).is_false()
	assert_bool(d["rule_adjustable"]).is_false()


func test_slot_choices() -> void:
	var d: Dictionary = KnobDefs.from_tables([_table()]).def(&"goal.top_out")
	var expected: Array[StringName] = [&"rescue", &"trim", &"lose"]
	assert_array(d["choices"]).is_equal(expected)
	assert_that(d["default"]).is_equal(&"rescue")


func test_bad_entries_rejected() -> void:
	var table: Dictionary = {"knobs": [
		{"id": "a.ok", "type": "flag", "default": true},
		{"id": "a.ok", "type": "flag", "default": false},
		{"id": "b.type", "type": "float", "default": 1.0},
		{"id": "c.range", "type": "scalar", "default": 5.0, "min": 0.0, "max": 3.0},
		{"id": "d.count", "type": "count", "default": 2.5, "min": 0.0, "max": 10.0},
		{"id": "e.choice", "type": "choice", "default": "x", "choices": ["a", "b"]},
		{"id": "f.key", "type": "flag", "default": true, "mn": 1},
		{"id": "g.zero", "type": "count", "default": 0.0, "min": 0.0, "max": 5.0, "allows_zero": false},
	]}
	var defs: KnobDefs = KnobDefs.from_tables([table])
	assert_int(defs.errors().size()).is_equal(7)
	for id: StringName in [&"b.type", &"c.range", &"d.count", &"e.choice", &"f.key", &"g.zero"]:
		assert_bool(defs.has(id)).is_false()
	assert_bool(defs.def(&"a.ok")["default"]).is_true()


func test_unknown_def_is_empty() -> void:
	var defs: KnobDefs = KnobDefs.from_tables([_table()])
	assert_dict(defs.def(&"nope")).is_empty()
	assert_bool(defs.has(&"nope")).is_false()
