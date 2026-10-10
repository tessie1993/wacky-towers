extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var content := WtContent.new()
	var catalog := content.load_catalog()
	var level := content.level("ice_10")
	var sequences: Array = []
	for seed: int in [42,1729,1,2,3,4,5,6]:
		var spawner := Spawner.new(level.pieces,1,seed)
		var seq: Array = []
		for i: int in 32:seq.append(String(spawner.next()))
		sequences.append({"seed":seed,"shapes":seq})
	var file := FileAccess.open("res://production/qa/evidence/full-build/ice10-sequences.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"sequences":sequences},"\t"));file.close()
	var path := "res://assets/data/campaign/ice_sideways_witness.json"
	if FileAccess.file_exists(path):
		var proof: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		var sim := BoardSim.new(level,int(proof.seed),catalog)
		var placements: Array = []
		for placement: Dictionary in proof.placements:
			for tick: int in 600:
				if sim.get_piece()!=null or sim.result()!=null:break
				sim.step()
			var piece := sim.get_piece()
			if piece==null:break
			if String(piece.shape.shape_id)!=String(placement.shape):
				print("BAD_SEQUENCE ",piece.shape.shape_id," ",placement.shape);break
			piece.orient=int(placement.orient)
			var at: Array = placement.pivot
			piece.pivot=Vector3i(int(at[1]),int(at[0]),int(at[2]))
			var low: int=999
			for c: Vector3i in piece.cells():low=mini(low,c.x)
			piece.pivot.x+=sim.board().limit_layer()-low
			var locks: int=sim.goal_state().locks
			sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
			for tick: int in 300:
				sim.step()
				if sim.goal_state().locks>locks and sim.get_phase()!=BoardSim.Phase.RESOLVING:break
			placements.append({"shape":placement.shape,"locks":sim.goal_state().locks,"clears":sim.goal_state().layers_cleared,"warnings":sim.goal_state().warnings_used})
			print("SIDEWAYS ",placements[-1].shape," locks=",sim.goal_state().locks," clears=",sim.goal_state().layers_cleared)
		for tick: int in 180:
			if sim.result()!=null:break
			sim.step()
		var result: Dictionary = {"status":"WIN" if sim.goal_state().result==GoalState.RESULT_WON else "FAIL","seed":proof.seed,"locks":sim.goal_state().locks,"clears":sim.goal_state().layers_cleared,"warnings":sim.goal_state().warnings_used,"level_ms":sim.goal_state().level_ms,"stars":sim.result().stars if sim.result()!=null else 0,"placements":placements,"fixture":"constructive legal sky poses; actual unmodified source bag, gravity, hard drops, gust, slide, clears and goal evaluation; human input time not measured"}
		file=FileAccess.open("res://production/qa/evidence/full-build/ice10-sideways-witness.json",FileAccess.WRITE);file.store_string(JSON.stringify(result,"\t"));file.close()
		print("SIDEWAYS_RESULT ",result.status," clears=",result.clears)
	quit()
