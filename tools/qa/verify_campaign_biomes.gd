extends SceneTree
## Ordered real-engine campaign evidence. Passing smoke checks never claims a full human playthrough.
const OUTPUT := "res://production/qa/evidence/full-build/biome-level-verification.json"
const HOOKS := [&"on_level_start",&"on_spawn",&"on_piece_enter",&"on_tick",&"on_command",&"on_fall_step",&"on_land",&"on_lock",&"on_enter",&"on_clear",&"on_resolve_end",&"on_goal_check",&"on_top_out"]
var _content := WtContent.new()
var _catalog: GameCatalog
var _proofs: Dictionary = {}
func _initialize()->void:call_deferred("_run")
func _run()->void:
	_catalog=_content.load_catalog()
	var proofs: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/campaign/puzzle_proofs.json"))
	for proof: Dictionary in proofs.proofs:_proofs[proof.id]=proof
	var report: Dictionary={"schema":1,"date":"2026-10-10","engine":Engine.get_version_info().string,"seed":1729,"scope":"Ordered parse, plugin and hook contracts, real scene instantiation, legal first spawn, three actual locks and special-control reachability. Finite shape puzzles additionally replay constructive geometry through BoardSim. This is not a human playtest or a proof of all campaign objectives.","catalog_errors":Array(_content.errors),"levels":[],"biomes":[],"failures":[]}
	for biome: String in _content.biome_order:
		var main_rows: Array=[];var bonus_rows: Array=[]
		for entry: Dictionary in _content.all_levels():
			if String(entry.biome)!=biome:continue
			var row: Dictionary=await _verify(entry)
			report.levels.append(row)
			if int(entry.tier)<=10:main_rows.append(row)
			else:bonus_rows.append(row)
			if not row.failures.is_empty():report.failures.append({"id":row.id,"failures":row.failures})
			report.biomes.append({"id":biome,"mains":main_rows.size(),"extras":bonus_rows.size(),"smoke_passed":main_rows.filter(func(r:Dictionary)->bool:return r.smoke_status=="PASS").size(),"finite_puzzles_won":(main_rows+bonus_rows).filter(func(r:Dictionary)->bool:return r.get("puzzle",{}).get("status","")=="WIN").size()})
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://production/qa/evidence/full-build"))
	var file:=FileAccess.open(OUTPUT,FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
	print("CAMPAIGN_REPORT levels=",report.levels.size()," failures=",report.failures.size()," path=",OUTPUT)
	quit(0 if report.failures.is_empty() and _content.errors.is_empty() else 1)
func _verify(entry: Dictionary)->Dictionary:
	var row: Dictionary={"id":entry.id,"biome":entry.biome,"tier":entry.tier,"scene":entry.scene,"failures":[],"smoke_status":"FAIL"}
	var level: LevelData=_content.level(entry.id)
	row.parse_status="PASS" if level!=null else "FAIL"
	if level==null:row.failures.append("loader: "+str(_content.last_issues));return row
	row.goal=level.goal.duplicate(true);row.knob_overrides=level.knobs.duplicate(true);row.rule_hooks=[]
	for rule: Dictionary in level.rules:
		var def: RuleDef=_catalog.rule_defs.get(StringName(rule.id))
		var plugin: RuleBehaviour=_catalog.plugins.create(&"RuleBehaviour",def.behaviour) if def!=null else null
		if plugin==null:row.failures.append("missing rule plugin: "+String(rule.id));continue
		var hooks: Array[StringName]=plugin.subscribed_hooks();row.rule_hooks.append({"id":rule.id,"hooks":Array(hooks)})
		for hook: StringName in hooks:
			if not HOOKS.has(hook):row.failures.append("unknown hook: "+String(hook))
	if _catalog.plugins.create(&"GoalEvaluator",StringName(level.goal.type))==null:row.failures.append("missing goal plugin")
	var sim:=BoardSim.new(level,1729,_catalog)
	row.physical_size=[sim.board().size().x,sim.board().size().y,sim.board().size().z];row.danger_limit=sim.board().limit_layer();row.active_clear_plane=sim.board().active_in_layer(0)
	var scene: PackedScene=load(entry.scene) as PackedScene
	var descriptor: Node=scene.instantiate() if scene!=null else null
	row.scene_instantiated=descriptor!=null
	var world: WtStage=descriptor.get_node_or_null("World") as WtStage if descriptor!=null else null
	row.embedded_world=world!=null
	if descriptor==null:row.failures.append("presentation scene failed to instantiate")
	if world==null:row.failures.append("presentation scene lacks embedded WtStage World")
	if descriptor!=null:root.add_child(descriptor)
	if world!=null:world.setup(sim,StringName(entry.biome),{"master_volume":0.0,"music_volume":0.0,"sfx_volume":0.0,"goal":level.goal,"reduced_motion":true})
	for tick: int in 360:
		if sim.get_piece()!=null or sim.result()!=null:break
		if sim.get_phase()==BoardSim.Phase.SELECTING:
			var choices: Array[Dictionary]=sim.kit_choices()
			if not choices.is_empty():sim.queue_command(SimCommand.make(SimEvents.CMD_PICK_SHAPE,[choices[0].shape_id]))
		var events: Array[SimEvent]=sim.step()
		if world!=null:world.sync(events)
	row.legal_spawn=sim.get_piece()!=null and sim.board().can_place(sim.get_piece().cells())
	if not row.legal_spawn:row.failures.append("no legal first spawn")
	row.capabilities=sim.capabilities()
	var choose_expected: bool=String(sim.knobs().value(&"control.verb"))=="choose_down"
	row.choose_down_reachable=not choose_expected or bool(sim.capabilities().choose_down)
	if choose_expected and sim.get_piece()!=null:
		sim.queue_command(SimCommand.make(SimEvents.CMD_CHOOSE_DOWN,[Vector3i.RIGHT]));sim.step()
		row.choose_down_reachable=sim._travel_dir==Vector3i.RIGHT
		if not row.choose_down_reachable:row.failures.append("choose_down command inaccessible")
	var flick_expected: bool=String(sim.knobs().value(&"control.verb")) in ["curling_flick","ice_flick"]
	row.ice_flick_reachable=not flick_expected
	for lock_no: int in 3:
		if sim.result()!=null:break
		for tick: int in 300:
			if sim.get_piece()!=null:break
			if sim.get_phase()==BoardSim.Phase.SELECTING and not sim.kit_choices().is_empty():sim.queue_command(SimCommand.make(SimEvents.CMD_PICK_SHAPE,[sim.kit_choices()[0].shape_id]))
			sim.step()
		if sim.get_piece()==null:break
		sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP));sim.step()
		if flick_expected and sim.capabilities().ice_flick:
			row.ice_flick_reachable=true
			sim.queue_command(SimCommand.make(SimEvents.CMD_FLICK,[Vector3i(0,0,1)]));sim.step()
		sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP));sim.step()
		for tick: int in 240:
			if sim.get_phase() not in [BoardSim.Phase.GRACE,BoardSim.Phase.RESTING,BoardSim.Phase.RESOLVING]:break
			sim.step()
	row.locks=sim.goal_state().locks;row.result_after_smoke=sim.goal_state().result;row.level_ms=sim.goal_state().level_ms
	if row.locks<1:row.failures.append("no actual completed lock")
	if flick_expected and not row.ice_flick_reachable:row.failures.append("ice_flick landing action inaccessible")
	if _proofs.has(entry.id):row.puzzle=_replay(level,_proofs[entry.id])
	if row.get("puzzle",{}).get("status","")=="FAIL":row.failures.append("constructive packing did not win in BoardSim")
	if descriptor!=null:descriptor.queue_free();await process_frame
	row.smoke_status="PASS" if row.failures.is_empty() else "FAIL"
	row.completion_status="FINITE_PUZZLE_PROVED" if row.get("puzzle",{}).get("status","")=="WIN" else "FULL_PLAYTHROUGH_NOT_ASSESSED"
	print("LEVEL ",entry.id," ",row.smoke_status," locks=",row.locks," embeddedWorld=",row.embedded_world)
	return row
func _replay(level: LevelData,proof: Dictionary)->Dictionary:
	var sim:=BoardSim.new(level,42,_catalog)
	for placement: Dictionary in proof.placements:
		for tick: int in 240:
			if sim.get_piece()!=null or sim.get_phase() in [BoardSim.Phase.SELECTING,BoardSim.Phase.ENDED]:break
			sim.step()
		if sim.get_phase()==BoardSim.Phase.SELECTING:sim.queue_command(SimCommand.make(SimEvents.CMD_PICK_SHAPE,[StringName(placement.shape)]));sim.step()
		var piece: ActivePiece=sim.get_piece()
		if piece==null:return {"status":"FAIL","reason":"missing piece"}
		piece.orient=int(placement.orient);var at: Array=placement.pivot;piece.pivot=Vector3i(int(at[0]),int(at[1]),int(at[2]))
		var bottom: int=999
		for c: Vector3i in piece.cells():bottom=mini(bottom,c.y)
		piece.pivot.y+=sim.board().limit_layer()-bottom
		var locks: int=sim.goal_state().locks
		sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
		for tick: int in 180:
			sim.step()
			if sim.goal_state().locks>locks and sim.get_phase()!=BoardSim.Phase.RESOLVING:break
	for tick: int in 180:
		if sim.result()!=null:break
		sim.step()
	return {"status":"WIN" if sim.goal_state().result==GoalState.RESULT_WON else "FAIL","locks":sim.goal_state().locks,"trimmed":sim.goal_state().cells_trimmed,"level_ms":sim.goal_state().level_ms,"stars":sim.result().stars if sim.result()!=null else 0,"state_hash":sim.state_hash(),"fixture":"solver sets a legal sky pose; actual hard-drop, lock, rule writes, kit consumption and goal evaluation are simulated"}
