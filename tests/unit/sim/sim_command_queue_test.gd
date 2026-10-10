extends GdUnitTestSuite
## SIM-001 command queue tests (CH-035).


func _sim() -> BoardSim:
	return BoardSim.new(LevelData.new(), 1, GameCatalog.new())


func test_command_applies_next_tick() -> void:
	var s: BoardSim = _sim()
	s.queue_command(SimCommand.make(SimEvents.CMD_MOVE, [Vector3i(1, 0, 0)]))
	var ev: Array[SimEvent] = s.step()
	assert_int(ev.size()).is_equal(1)
	assert_str(ev[0].kind).is_equal(SimEvents.COMMAND_APPLIED)
	assert_int(ev[0].tick).is_equal(1)


func test_arrival_order_kept() -> void:
	var s: BoardSim = _sim()
	var kinds: Array[StringName] = [SimEvents.CMD_MOVE, SimEvents.CMD_ROTATE, SimEvents.CMD_HARD_DROP]
	for k in kinds:
		s.queue_command(SimCommand.make(k))
	var ev: Array[SimEvent] = s.step()
	assert_int(ev.size()).is_equal(3)
	for i in 3:
		assert_str(ev[i].data["kind"]).is_equal(kinds[i])


func test_future_tick_waits() -> void:
	var s: BoardSim = _sim()
	s.queue_command(SimCommand.make(SimEvents.CMD_MOVE, [], 5))
	for i in 4:
		assert_int(s.step().size()).is_equal(0)
	var ev: Array[SimEvent] = s.step()
	assert_int(ev.size()).is_equal(1)
	assert_int(ev[0].tick).is_equal(5)


func test_step_returns_copy() -> void:
	var s: BoardSim = _sim()
	s.queue_command(SimCommand.make(SimEvents.CMD_MOVE))
	var first: Array[SimEvent] = s.step()
	s.step()
	assert_int(first.size()).is_equal(1)
