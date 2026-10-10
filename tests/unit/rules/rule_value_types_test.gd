extends GdUnitTestSuite
## Tests for the RUL-001 value types (CH-019).


func test_defaults() -> void:
	var h: HookContext = HookContext.new()
	assert_that(h.hook).is_equal(&"")
	assert_that(h.data).is_equal({})
	assert_int(h.depth).is_equal(0)
	var v: VetoResult = VetoResult.new()
	assert_bool(v.vetoed).is_false()
	assert_that(v.rule_id).is_equal(&"")
	var g: ClearGroup = ClearGroup.new()
	assert_int(g.cells.size()).is_equal(0)
	assert_int(g.counts_as_layers).is_equal(0)
	var a: ArrivalPlan = ArrivalPlan.new()
	assert_that(a.origin).is_equal(Vector3i.ZERO)
	assert_int(a.orient).is_equal(0)
	assert_that(a.travel_dir).is_equal(Vector3i.ZERO)
	assert_bool(a.blocked).is_false()


func test_fields_are_typed() -> void:
	var h: HookContext = HookContext.new()
	h.depth = 3
	assert_int(h.depth).is_equal(3)
	var g: ClearGroup = ClearGroup.new()
	g.cells = PackedInt32Array([1, 2])
	assert_that(g.cells).is_equal(PackedInt32Array([1, 2]))
	var a: ArrivalPlan = ArrivalPlan.new()
	a.travel_dir = Vector3i(0, -1, 0)
	assert_that(a.travel_dir).is_equal(Vector3i(0, -1, 0))


func test_rule_api_stub_instantiates() -> void:
	assert_object(RuleApi.new()).is_not_null()
