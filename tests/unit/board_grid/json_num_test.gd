extends GdUnitTestSuite
## Tests for JsonNum (CH-037, DAT-001): the one whole-number rule for JSON values.


func test_accepts_whole() -> void:
	assert_that(JsonNum.whole_int(0)).is_equal(0)
	assert_that(JsonNum.whole_int(4.0)).is_equal(4)
	assert_that(JsonNum.whole_int(-3)).is_equal(-3)
	assert_that(JsonNum.whole_int(-2.0)).is_equal(-2)
	assert_that(JsonNum.whole_int(2147483647.0)).is_equal(2147483647)


func test_rejects() -> void:
	var bad: Array = [4.5, "4", true, null, NAN, INF, 2147483648.0, -2147483649.0]
	for v: Variant in bad:
		assert_that(JsonNum.whole_int(v)).is_null()
