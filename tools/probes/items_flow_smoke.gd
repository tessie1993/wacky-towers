extends SceneTree
func _initialize() -> void:
	var fixture: Node = load("res://tests/unit/mechanics/items_integration_test.gd").new()
	var level: LevelData = fixture._level()
	var sim := BoardSim.new(level, 912, WtContent.new().load_catalog())
	for command: Variant in [null, SimCommand.make(SimEvents.CMD_RECEIVE_ITEM,[{"effect_id":"junk_rain","owner":8,"token":"8:1"}]), SimCommand.make(SimEvents.CMD_HARD_DROP)]:
		if command != null: sim.queue_command(command)
		var events: Array[SimEvent] = sim.step()
		var event_data: Array = []
		for e: SimEvent in events: event_data.append({"kind":e.kind,"data":e.data})
		print(JSON.stringify({"phase":sim.get_phase(),"piece":sim.get_piece()!=null,"knobs":sim.knobs().snapshot(),"structural":sim._structural,"rules":sim._rules.size(),"events":event_data}))
	fixture.free()
	quit()
