extends SceneTree
## Run-and-observe driver for meadow_01 beats: boots the real app (--smoke-game), then feeds the exact sim events the
## rules emit to the stage and saves 720x1280 PNGs. Usage: xvfb-run godot --path . --resolution 720x1280 -s res://tools/qa/capture_meadow_01.gd -- --smoke-game
const OUT := "res://production/qa/evidence/meadow_01/"
var main: Node


func _initialize() -> void:
	main = load("res://src/app/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _frames(n: int) -> void:
	for i: int in n: await process_frame


func _shot(name: String) -> void:
	await _frames(3)
	await RenderingServer.frame_post_draw
	var img: Image = root.get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	print("SHOT ", name, " ", img.get_size())


func _grip(step: int, stage_id: String, rects: Array) -> void:
	var stage: Node = main.get("_stage")
	var sim: BoardSim = main.get("_sim")
	for r: Array in rects:
		for x: int in range(r[0], r[1] + 1):
			for z: int in range(r[2], r[3] + 1): sim.get_api().request_mask(x, z, true)
	sim.get_api().flush_writes()
	stage.sync([SimEvent.make(0, SimEvents.LAYERS_CLEARED, {"indices": [0]}), SimEvent.make(0, &"grip_released", {"grip": step, "stage": stage_id, "of": 3, "sky_step": step}),
		SimEvent.make(0, SimEvents.CELLS_CHANGED, {})])
	main.set("_grips_released", step)


func _run() -> void:
	main.set("_smoke", false)
	await _frames(200)
	var stage: Node = main.get("_stage")
	_grip(1, "left_roots", [[0, 1, 2, 5]])
	await _frames(45)
	await _shot("02-stage1")
	_grip(2, "right_stones", [[6, 7, 2, 5]])
	await _frames(45)
	await _shot("03-stage2")
	stage.sync([SimEvent.make(0, SimEvents.RESCUE_WIPED, {"k": 3, "n_cubes": 9})])
	await _frames(30)
	await _shot("05-rescue")
	await _frames(5)
	_grip(3, "rim", [[0, 7, 0, 1], [0, 7, 6, 7]])
	stage.sync([SimEvent.make(0, SimEvents.GOAL_REACHED, {})])
	await _frames(45)
	await _shot("04-win")
	stage.sync([SimEvent.make(0, SimEvents.LEVEL_FAILED, {})])
	await _frames(20)
	await _shot("06-lose")
	quit()
