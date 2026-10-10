extends GdUnitTestSuite
## Tests for ShapeBank (CH-028, ADR-0003).


func _bank(ids: Array[StringName]) -> ShapeBank:
	var bank: ShapeBank = ShapeBank.new()
	for id: StringName in ids:
		var def: ShapeDef = ShapeDef.new()
		def.shape_id = id
		bank.shapes.append(def)
	return bank


func test_empty_bank() -> void:
	var bank: ShapeBank = _bank([])
	assert_object(bank.get_shape(&"i")).is_null()
	assert_bool(bank.has_shape(&"i")).is_false()
	assert_bool(bank.ids().is_empty()).is_true()


func test_lookup_returns_same_instance() -> void:
	var bank: ShapeBank = _bank([&"i", &"o"])
	assert_bool(is_same(bank.get_shape(&"o"), bank.shapes[1])).is_true()


func test_unknown_is_null() -> void:
	var bank: ShapeBank = _bank([&"i", &"o"])
	assert_object(bank.get_shape(&"zz")).is_null()


func test_duplicate_first_wins() -> void:
	var bank: ShapeBank = _bank([&"i", &"i"])
	assert_bool(is_same(bank.get_shape(&"i"), bank.shapes[0])).is_true()


func test_ids_in_bank_order() -> void:
	var bank: ShapeBank = _bank([&"t", &"i", &"o"])
	assert_array(bank.ids()).is_equal(PackedStringArray(["t", "i", "o"]))
