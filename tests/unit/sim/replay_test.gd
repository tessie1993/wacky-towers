extends GdUnitTestSuite
## SIM-001 replay tests (CH-036).

const TICKS := 20


func _live(replay: Replay, level: LevelData, catalog: GameCatalog) -> Array[SimEvent]:
	var s: BoardSim = BoardSim.new(level, replay.round_seed, catalog)
	var plan: Array = [[0, SimEvents.CMD_MOVE], [3, SimEvents.CMD_ROTATE], [3, SimEvents.CMD_MOVE], [10, SimEvents.CMD_HARD_DROP]]
	var out: Array[SimEvent] = []
	for t in TICKS:
		for p in plan:
			if p[0] == t:
				var c: SimCommand = SimCommand.make(p[1], [Vector3i(1, 0, 0)])
				s.queue_command(c)
				replay.record(c)
		out.append_array(s.step())
	return out


func _replay() -> Replay:
	var r: Replay = Replay.new()
	r.round_seed = 7
	return r


func test_same_log_same_events() -> void:
	var level: LevelData = LevelData.new()
	var cat: GameCatalog = GameCatalog.new()
	var r: Replay = _replay()
	var live: Array[SimEvent] = _live(r, level, cat)
	var re: Array[SimEvent] = Replay.run(level, cat, r, TICKS)
	assert_int(re.size()).is_equal(live.size())
	assert_int(live.size()).is_equal(4)
	for i in live.size():
		assert_bool(live[i].equals(re[i])).is_true()


func test_run_twice_identical() -> void:
	var level: LevelData = LevelData.new()
	var cat: GameCatalog = GameCatalog.new()
	var r: Replay = _replay()
	_live(r, level, cat)
	var a: Array[SimEvent] = Replay.run(level, cat, r, TICKS)
	var b: Array[SimEvent] = Replay.run(level, cat, r, TICKS)
	assert_int(a.size()).is_equal(b.size())
	for i in a.size():
		assert_bool(a[i].equals(b[i])).is_true()


func test_log_not_mutated() -> void:
	var level: LevelData = LevelData.new()
	var cat: GameCatalog = GameCatalog.new()
	var r: Replay = _replay()
	_live(r, level, cat)
	var before: Array[int] = []
	for c in r.commands:
		before.append(c.tick)
	Replay.run(level, cat, r, TICKS)
	for i in r.commands.size():
		assert_int(r.commands[i].tick).is_equal(before[i])
