extends GdUnitTestSuite
## meadow_01 build deviations: no-number Stump Grip meter data, hidden rule chip, strings, rescue.layers, neat stars.
const PATH := "res://src/levels/meadow/meadow_01/meadow_01.json"
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")


func _raw() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(PATH))


func _result(won: bool, rescues: int, pieces: int) -> LevelResult:
	var r := LevelResult.new()
	r.outcome = LevelResult.OUTCOME_WON if won else LevelResult.OUTCOME_LOST
	r.warnings_used = rescues
	r.pieces_placed = pieces
	return r


func test_hud_meter_is_data_driven_knots_and_rule_chip_hidden() -> void:
	var hud: Dictionary = _raw()["hud"]
	assert_str(hud["meter"]["source"]).is_equal("stump_grip")
	assert_int(int(hud["meter"]["pips"])).is_equal(3)
	assert_bool(bool(hud["hide_rules"])).is_true()
	assert_array(hud["show"]).is_equal(["pause", "goal", "next", "meter"])


func test_strings_exist_in_localisation_csv() -> void:
	var csv := FileAccess.get_file_as_string("res://assets/i18n/strings.csv")
	for key: String in ["LVL_MEADOW_01_TITLE,Stump Day", "LVL_MEADOW_01_OBJECTIVE,Free the Hearth Stump.", "HUD_METER_STUMP_GRIP,", "LVL_MEADOW_01_BANNER_BEFORE,", "LVL_MEADOW_01_BANNER_AFTER,"]:
		assert_bool(csv.contains(key)).override_failure_message(key).is_true()
	var story: Dictionary = _raw()["story"]
	assert_int(int(story["banner_before_ms"])).is_equal(2000)
	assert_int(int(story["banner_after_delay_ms"])).is_equal(3000)


func test_catalog_title_is_stump_day() -> void:
	var cat: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/campaign/catalog.json"))
	for lv: Dictionary in cat["levels"]:
		if lv["id"] == "meadow_01":
			assert_str(lv["name"]).is_equal("Stump Day")


func test_rescue_layers_knob_wipes_exactly_three_and_releases_no_grip() -> void:
	assert_int(int(_raw()["knobs"]["rescue.layers"])).is_equal(3)
	var board: BoardState = F.board(4, 4, 8)
	var cubes: Array[Vector3i] = []
	for y: int in 9:
		cubes.append(Vector3i(0, y, 0))
	F.write(board, cubes)
	var state := GoalState.new()
	state.warnings_left = 1
	var api: RuleApi = F.api_with_knobs(board, {&"rescue.layers": 3})
	var before := board.stack_height()
	RescueTopOut.new(2).resolve_top_out(board, state, api)
	# The F3 formula would wipe a different count here; the rescue.layers knob fixes it at 3.
	assert_int(before - board.stack_height()).is_equal(3)
	assert_int(state.layers_cleared).is_equal(0)
	var released := false
	for r: Dictionary in api.take_requests():
		if r["op"] == &"mask": released = true
	assert_bool(released).is_false()


func test_neat_stars() -> void:
	var stars: Dictionary = _raw()["stars"]
	assert_int(StarRater.rate(stars, _result(true, 0, 22), false)).is_equal(3)
	assert_int(StarRater.rate(stars, _result(true, 0, 23), false)).is_equal(2)
	assert_int(StarRater.rate(stars, _result(true, 1, 40), false)).is_equal(2)
	assert_int(StarRater.rate(stars, _result(true, 2, 40), false)).is_equal(1)
	assert_int(StarRater.rate(stars, _result(true, 2, 28), false)).is_equal(2)
	assert_int(StarRater.rate(stars, _result(false, 0, 10), false)).is_equal(0)
