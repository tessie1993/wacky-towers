extends GdUnitTestSuite
## meadow_01 feedback beats: each sim event reaches its presentation consumer (WtLevelBeats).
## Spec: design/levels/meadow/meadow_01.md sections 2 and 5.
const LEVEL := "res://src/levels/meadow/meadow_01/meadow_01.json"


func _beats() -> WtLevelBeats:
	var look: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LEVEL))["look"]
	var b := WtLevelBeats.new()
	b.setup(WtLevelBeats.read("meadow_01"), look["sky"], Vector3i(8, 12, 8), {})
	return b


func _fx(b: WtLevelBeats, name: StringName) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for e: Dictionary in b.log:
		if e.fx == name: out.append(e)
	return out


func _cue_ids(b: WtLevelBeats) -> Array:
	return _fx(b, &"cue").map(func(e: Dictionary) -> Variant: return e.args[0])


func test_sky_steps_dawn_gold_sunset_and_camera_widens() -> void:
	var b := _beats()
	b.start()
	for step: int in [1, 2, 3]:
		b.handle(SimEvent.make(1, &"grip_released", {"grip": step, "stage": "left_roots", "of": 3, "sky_step": step}))
	var grades: Array = _fx(b, &"sky").map(func(e: Dictionary) -> Variant: return e.args[0])
	assert_array(grades).is_equal(["dawn", "golden", "golden", "dusk"])
	var cams: Array = _fx(b, &"camera").map(func(e: Dictionary) -> Variant: return e.args[0])
	assert_array(cams).is_equal(["high_three_quarter", "pit_6_wide", "pit_8_wide", "stump_win"])
	for c: String in cams:
		assert_bool(WtLevelLook.presets()["camera"].has(c)).override_failure_message(c).is_true()


func test_release_layers_glow_shake_and_groan() -> void:
	var b := _beats()
	b.handle(SimEvent.make(1, &"grip_released", {"grip": 1, "stage": "left_roots", "of": 3, "sky_step": 1}))
	assert_float(float(_fx(b, &"shake")[0].args[1])).is_equal(0.3)
	assert_int(_fx(b, &"glow").size()).is_equal(1)
	assert_array(_cue_ids(b)).contains([&"SFX_M01_STUMP_GROAN", &"SFX_M01_ROOT_TWANG"])
	b.handle(SimEvent.make(2, SimEvents.LAYERS_CLEARED, {"indices": [2]}))
	assert_int(_fx(b, &"ring").size()).is_equal(1)


func test_rescue_swoops_cloud_with_whoosh_and_giggle() -> void:
	var b := _beats()
	b.handle(SimEvent.make(1, SimEvents.RESCUE_WIPED, {"k": 3, "n_cubes": 9}))
	assert_int(_fx(b, &"swoop").size()).is_equal(1)
	assert_array(_cue_ids(b)).contains([&"SFX_UI_WHOOSH", &"SFX_M01_CLOUD_GIGGLE"])
	assert_int(_fx(b, &"sky").size()).is_equal(0)  # a rescue never steps the sky


func test_win_locks_input_bell_green_glow() -> void:
	var b := _beats()
	b.handle(SimEvent.make(1, SimEvents.GOAL_REACHED, {}))
	assert_int(_fx(b, &"lock_input").size()).is_equal(1)
	assert_array(_cue_ids(b)).contains([&"SFX_M01_BELL"])
	assert_str(_fx(b, &"glow")[0].args[0].to_html(false)).is_equal("4cc04a")
	assert_int(_fx(b, &"ring").size()).is_equal(3)


func test_lock_hum_and_ring_ripple() -> void:
	var b := _beats()
	b.handle(SimEvent.make(1, SimEvents.PIECE_LOCKED, {"cells": [Vector3i(2, 0, 2)]}))
	assert_array(_cue_ids(b)).contains([&"SFX_M01_LOCK_HUM"])
	assert_int(_fx(b, &"ring").size()).is_equal(1)


func test_hooks_are_called_and_cues_exist_in_cue_table() -> void:
	var b := _beats()
	var seen: Array = []
	b.setup(b.cfg, b.sky_list, b.board_size, {&"cue": func(id: StringName) -> void: seen.append(id)})
	b.handle(SimEvent.make(1, SimEvents.GOAL_REACHED, {}))
	assert_array(seen).is_equal([&"SFX_M01_BELL"])
	var cues: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/audio/cues.json"))["cues"]
	for id: String in ["SFX_M01_BELL", "SFX_M01_STUMP_GROAN", "SFX_M01_LOCK_HUM", "SFX_M01_CLOUD_GIGGLE", "SFX_UI_WHOOSH"]:
		assert_bool(cues.has(id)).override_failure_message(id).is_true()
