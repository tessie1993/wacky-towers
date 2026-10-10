extends GdUnitTestSuite

const SCENE := "res://src/levels/meadow/meadow_01/meadow_01_events.tscn"

var _ev: Meadow01Events
var _log: Array = []


func before_test() -> void:
	_log = []
	_ev = (load(SCENE) as PackedScene).instantiate() as Meadow01Events
	add_child(_ev)
	_ev.banner.connect(func(t: String) -> void: _log.append(["banner", t]))
	_ev.cheer.connect(func(c: int) -> void: _log.append(["cheer", c]))
	_ev.level_finished.connect(func(s: StringName) -> void: _log.append(["done", s]))


func after_test() -> void:
	_ev.queue_free()


func _t(cleared: int, just: int, state: StringName = &"playing") -> void:
	_ev.tick_game({"layers_cleared": cleared, "goal_n": 4, "state": state, "just_cleared": just, "elapsed_ms": 0})


func test_intro_banner_fires_once() -> void:
	_t(0, 0)
	_t(0, 0)
	assert_array(_log).is_equal([["banner", "Clear 4 layers!"]])


func test_cheer_per_clear_with_count() -> void:
	_t(0, 0)
	_t(1, 1)
	_t(1, 0)
	_t(2, 2)
	assert_array(_log).is_equal([["banner", "Clear 4 layers!"], ["cheer", 1], ["cheer", 2]])


func test_one_more_once_in_order_after_cheer() -> void:
	_t(0, 0)
	_t(3, 1)
	_t(3, 0)
	_t(3, 0)
	assert_array(_log).is_equal([["banner", "Clear 4 layers!"], ["cheer", 1], ["banner", "One more!"]])


func test_finished_once_with_state() -> void:
	_t(0, 0)
	_t(4, 1, &"won")
	_t(4, 0, &"won")
	assert_array(_log).is_equal([["banner", "Clear 4 layers!"], ["cheer", 1], ["done", &"won"]])


func test_lost_emits_finished() -> void:
	_t(1, 0, &"lost")
	_t(1, 0, &"lost")
	assert_array(_log).is_equal([["banner", "Clear 4 layers!"], ["done", &"lost"]])
