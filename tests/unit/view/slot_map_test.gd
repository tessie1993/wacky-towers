extends GdUnitTestSuite

const CELL_COUNT: int = 10
const OP_COUNT: int = 200
const OP_CELLS: int = 50


func _filled_map() -> SlotMap:
	var m: SlotMap = SlotMap.new()
	m.reset(CELL_COUNT)
	m.add(3)
	m.add(7)
	m.add(5)
	return m


func test_add_dense() -> void:
	var m: SlotMap = SlotMap.new()
	m.reset(CELL_COUNT)
	assert_int(m.add(3)).is_equal(0)
	assert_int(m.add(7)).is_equal(1)
	assert_int(m.add(5)).is_equal(2)
	assert_int(m.filled()).is_equal(3)
	assert_int(m.add(7)).is_equal(-1)
	assert_int(m.filled()).is_equal(3)


func test_remove_swaps_last() -> void:
	var m: SlotMap = _filled_map()
	assert_that(m.remove(3)).is_equal(Vector2i(0, 2))
	assert_int(m.slot_of(5)).is_equal(0)
	assert_int(m.cell_at(0)).is_equal(5)
	assert_int(m.slot_of(3)).is_equal(-1)
	assert_int(m.filled()).is_equal(2)


func test_remove_last() -> void:
	var m: SlotMap = _filled_map()
	assert_that(m.remove(5)).is_equal(Vector2i(2, 2))
	assert_int(m.filled()).is_equal(2)


func test_remove_absent_noop() -> void:
	var m: SlotMap = _filled_map()
	assert_that(m.remove(9)).is_equal(Vector2i(-1, -1))
	assert_int(m.filled()).is_equal(3)


func test_move_rekeys() -> void:
	var m: SlotMap = _filled_map()
	var old_slot: int = m.slot_of(7)
	assert_int(m.move(7, 8)).is_equal(old_slot)
	assert_int(m.slot_of(8)).is_equal(old_slot)
	assert_int(m.slot_of(7)).is_equal(-1)
	assert_int(m.cell_at(old_slot)).is_equal(8)
	assert_int(m.move(7, 1)).is_equal(-1)
	assert_int(m.move(3, 5)).is_equal(-1)


func test_inverse_holds() -> void:
	var m: SlotMap = SlotMap.new()
	m.reset(OP_CELLS)
	for i: int in OP_COUNT:
		var c: int = (i * 7 + 3) % OP_CELLS
		var d: int = (i * 11 + 5) % OP_CELLS
		match i % 3:
			0:
				m.add(c)
			1:
				m.remove(d)
			_:
				m.move(c, d)
		for s: int in m.filled():
			assert_int(m.slot_of(m.cell_at(s))).is_equal(s)


func test_reset_clears() -> void:
	var m: SlotMap = _filled_map()
	m.reset(4)
	assert_int(m.filled()).is_equal(0)
	assert_int(m.slot_of(3)).is_equal(-1)
	assert_int(m.add(3)).is_equal(0)
