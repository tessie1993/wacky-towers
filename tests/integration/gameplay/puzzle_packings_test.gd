extends GdUnitTestSuite
## Replays solver geometry through actual BoardSim locks, mirror writes, goals and finite inventories.
## The fixture sets the legal sky pose; it does not certify a timed human input sequence.
func test_fifteen_finite_puzzles_win_with_solver_packings() -> void:
	var content := WtContent.new();var catalog := content.load_catalog()
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/campaign/puzzle_proofs.json"))
	assert_int(data.proofs.size()).is_equal(15)
	for proof: Dictionary in data.proofs:
		assert_str(proof.status).is_equal("SOLVED")
		var level: LevelData = content.level(proof.id)
		assert_object(level).is_not_null()
		if level == null:continue
		var sim := BoardSim.new(level,42,catalog)
		for placement: Dictionary in proof.placements:
			for tick: int in 240:
				if sim.get_piece()!=null or sim.get_phase()==BoardSim.Phase.SELECTING or sim.get_phase()==BoardSim.Phase.ENDED:break
				sim.step()
			if sim.get_phase()==BoardSim.Phase.SELECTING:
				sim.queue_command(SimCommand.make(SimEvents.CMD_PICK_SHAPE,[StringName(placement.shape)]));sim.step()
			var piece: ActivePiece = sim.get_piece()
			assert_object(piece).is_not_null()
			if piece==null:break
			assert_str(String(piece.shape.shape_id)).is_equal(placement.shape)
			piece.orient=int(placement.orient)
			var raw: Array = placement.pivot
			piece.pivot=Vector3i(int(raw[0]),int(raw[1]),int(raw[2]))
			var bottom: int = 999
			for c: Vector3i in piece.cells():bottom=mini(bottom,c.y)
			piece.pivot.y+=sim.board().limit_layer()-bottom
			for c: Vector3i in piece.cells():assert_bool(sim.board().is_free(c)).is_true()
			var locks: int = sim.goal_state().locks
			sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
			for tick: int in 180:
				sim.step()
				if sim.goal_state().locks>locks and sim.get_phase()!=BoardSim.Phase.RESOLVING:break
			assert_int(sim.goal_state().locks).is_equal(locks+1)
		for tick: int in 180:
			if sim.get_phase()==BoardSim.Phase.ENDED:break
			sim.step()
		print("PACKING ",proof.id," result=",sim.goal_state().result," locks=",sim.goal_state().locks," goal=",sim.progress_snapshot())
		assert_int(sim.goal_state().result).is_equal(GoalState.RESULT_WON)
		assert_int(sim.goal_state().cells_trimmed).is_equal(0)
