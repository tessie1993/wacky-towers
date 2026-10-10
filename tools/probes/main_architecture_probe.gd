extends SceneTree
## Real Main graph, authored stage, story, physics and return-flow smoke.
const MainScene = preload("res://src/app/main.tscn")
var main: Node
var failed: bool = false
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	main = MainScene.instantiate()
	root.add_child(main)
	var store := WtProfileStore.new(MemorySaveIO.new())
	_check(store.create("Architect") >= 0, "QA profile")
	main.set("_store", store)
	main.call("_on_intent", &"start_level", {"level_id":"meadow_01"})
	await process_frame
	var stage: WtStage = main.get("_stage")
	var authored: LevelStage = main.get("_official_stage")
	_check(authored != null and stage == authored.get_node("World"), "Main reuses authored World")
	_check(store.progress().get("encountered_levels",[]).has("meadow_01"), "Campaign encounter persisted")
	if String(main.get("_story_phase")) == "pre":
		_check(bool(main.get("_paused")), "Pre-story pauses gameplay")
		main.call("_on_intent", &"story_done", {"story_key":"meadow_01_pre"})
		_check(not bool(main.get("_paused")), "Story dismissal resumes countdown")
	var architecture: WtArchitecture = main.get("_architecture")
	_check(architecture.snapshot().domains.get(&"progression",0) >= 1, "Native graph routes progression")
	main.call("_on_intent", &"open_physics", {})
	_check(main.get("_sim") == null and main.get("_ui").current_screen == "physics", "Physics picker clears grid session")
	for variant: String in ["tower_race","bridge_builder","seesaw","meteor_shower"]:
		main.call("_on_intent", &"start_physics", {"variant":variant})
		var challenge: WtPhysicsChallenge = main.get("_physics")
		_check(challenge != null and challenge.variant == variant and bool(challenge.get("_built")), "Selected physics builds "+variant)
		_check(not main.get("_ui").visible and main.get("_sim") == null, "Physics owns HUD without BoardSim")
		for i: int in 3: await physics_frame
		challenge.return_requested.emit()
		await process_frame
		_check(main.get("_physics") == null and main.get("_ui").visible and main.get("_ui").current_screen == "physics", "Return restores picker")
	main.call("_on_intent", &"start_level", {"level_id":"meadow_01"})
	_check(main.get("_sim") != null and main.get("_stage") == main.get("_official_stage").get_node("World"), "Campaign starts after physics")
	_check(architecture.snapshot().domains.get(&"modes",0) >= 5, "Native graph routes mode lifecycle")
	main.call("_clear_session")
	main.queue_free()
	await process_frame
	print("MAIN_ARCHITECTURE_PASS" if not failed else "MAIN_ARCHITECTURE_FAIL")
	quit(1 if failed else 0)
func _check(value: bool, message: String) -> void:
	if not value:
		failed = true
		push_error("MAIN_ARCHITECTURE_FAIL "+message)
	else: print("MAIN_ARCHITECTURE_CHECK "+message)
