extends GdUnitTestSuite


func test_make_command() -> void:
	var c: SimCommand = SimCommand.make(SimEvents.CMD_MOVE, [Vector3i(1, 0, 0)], 5)
	assert_int(c.tick).is_equal(5)
	assert_str(String(c.kind)).is_equal("cmd_move")
	assert_array(c.args).is_equal([Vector3i(1, 0, 0)])
	var d: SimCommand = SimCommand.make(SimEvents.CMD_HOLD)
	assert_int(d.tick).is_equal(0)
	assert_array(d.args).is_empty()


func test_make_event_and_equals() -> void:
	var a: SimEvent = SimEvent.make(3, SimEvents.PIECE_LOCKED, {"cells": 4})
	var b: SimEvent = SimEvent.make(3, SimEvents.PIECE_LOCKED, {"cells": 4})
	assert_bool(a.equals(b)).is_true()
	assert_bool(a.equals(SimEvent.make(4, SimEvents.PIECE_LOCKED, {"cells": 4}))).is_false()
	assert_bool(a.equals(SimEvent.make(3, SimEvents.PIECE_MOVED, {"cells": 4}))).is_false()
	assert_bool(a.equals(SimEvent.make(3, SimEvents.PIECE_LOCKED, {"cells": 5}))).is_false()


func test_vocabulary_values_unique() -> void:
	var map: Dictionary = SimEvents.new().get_script().get_script_constant_map()
	var seen: Dictionary = {}
	assert_int(map.size()).is_greater_equal(26)
	for key: String in map:
		var v: Variant = map[key]
		assert_int(typeof(v)).is_equal(TYPE_STRING_NAME)
		assert_bool(seen.has(v)).is_false()
		seen[v] = true
	assert_str(String(SimEvents.PIECE_LOCKED)).is_equal("piece_locked")
