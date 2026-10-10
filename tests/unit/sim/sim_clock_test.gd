extends GdUnitTestSuite
## SIM-001 clock tests (CH-035).


func _sim() -> BoardSim:
	return BoardSim.new(LevelData.new(), 1, GameCatalog.new())


func test_ms_at() -> void:
	var ticks: Array[int] = [0, 1, 2, 29, 30, 60, 61]
	var want: Array[int] = [0, 16, 33, 483, 500, 1000, 1016]
	for i in ticks.size():
		assert_int(BoardSim.ms_at(ticks[i])).is_equal(want[i])


func test_sixty_ticks_is_one_second() -> void:
	var s: BoardSim = _sim()
	for i in 60:
		s.step()
	assert_int(s.get_tick()).is_equal(60)
	assert_int(s.now_ms()).is_equal(1000)


func test_deadline_500_fires_on_tick_30() -> void:
	var s: BoardSim = _sim()
	while s.now_ms() < 500:
		s.step()
	assert_int(s.get_tick()).is_equal(30)


func test_starts_in_countdown() -> void:
	assert_int(_sim().get_phase()).is_equal(BoardSim.Phase.COUNTDOWN)
