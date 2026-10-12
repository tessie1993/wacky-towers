extends GdUnitTestSuite
const Architecture := preload("res://src/app/wt_architecture.gd")
class App extends Node:
	var calls: Array[Dictionary] = []
	var context: Dictionary = {"has_profile":true,"has_session":true,"paused":false,"result":false,"mode":"campaign","lan_active":true,"lan_host":true}
	func _architecture_context() -> Dictionary: return context.duplicate()
	func _execute_intent(intent: StringName, data: Dictionary) -> void: calls.append({"intent":intent,"data":data.duplicate(true)})

func _architecture(app: App) -> WtArchitecture:
	var architecture := Architecture.new()
	app.add_child(architecture)
	architecture.setup(app)
	return architecture

func test_native_graph_routes_all_seven_domains_and_carries_payload() -> void:
	var app: App = auto_free(App.new())
	var architecture := _architecture(app)
	for intent: StringName in [&"create_profile", &"start_level", &"move", &"start_tournament", &"host_lan", &"set_pref", &"back"]:
		architecture.dispatch(intent, {"trace": 7})
	assert_int(app.calls.size()).is_equal(7)
	assert_int(architecture.snapshot().domains.size()).is_equal(7)
	assert_int(architecture.snapshot().rejected).is_equal(0)
	for call: Dictionary in app.calls: assert_int(call.data.trace).is_equal(7)

func test_native_graph_rejects_unknown_and_stale_gameplay_before_application_calls() -> void:
	var app: App = auto_free(App.new())
	var architecture := _architecture(app)
	architecture.dispatch(&"unknown_architecture_action")
	app.context.paused = true
	architecture.dispatch(&"drop")
	app.context.paused = false
	app.context.result = true
	architecture.dispatch(&"rotate", {"axis":"roll"})
	app.context.result = false
	app.context.has_session = false
	architecture.dispatch(&"resume")
	app.context.has_profile = false
	architecture.dispatch(&"start_level")
	app.context.lan_host = false
	architecture.dispatch(&"start_lan")
	assert_int(app.calls.size()).is_equal(0)
	assert_int(architecture.snapshot().rejected).is_equal(6)

func test_native_lifecycle_graph_transitions_and_save_commit_retains_session_state() -> void:
	var app: App = auto_free(App.new())
	var architecture := _architecture(app)
	for pair: Array in [[&"profile", &"profile"],[&"map", &"map"],[&"session_countdown", &"countdown"],[&"session_begin", &"playing"],[&"session_pause", &"paused"],[&"session_resume", &"playing"],[&"session_end", &"result"],[&"party_lobby", &"party"],[&"party_round", &"playing"],[&"party_leave", &"idle"]]:
		architecture.lifecycle(pair[0], {"level_id":"meadow_01"})
		assert_str(String(architecture.snapshot().state)).is_equal(String(pair[1]))
	architecture.lifecycle(&"session_begin")
	architecture.lifecycle(&"save_commit")
	var snapshot: Dictionary = architecture.snapshot()
	assert_str(String(snapshot.state)).is_equal("playing")
	assert_int(snapshot.save_revision).is_equal(1)
	assert_str(String(snapshot.last_event)).is_equal("save_commit")

func test_native_graph_handles_new_modes_and_inventory_slot_intents() -> void:
	var app: App = auto_free(App.new())
	var architecture := _architecture(app)
	architecture.dispatch(&"open_physics")
	architecture.dispatch(&"start_physics", {"level_id":"meadow_01"})
	architecture.dispatch(&"select_item_slot", {"slot":1})
	assert_int(app.calls.size()).is_equal(3)
	assert_int(architecture.snapshot().domains[&"modes"]).is_equal(2)
	assert_int(architecture.snapshot().domains[&"progression"]).is_equal(1)

func test_lifecycle_history_is_bounded_and_snapshot_does_not_expose_mutable_state() -> void:
	var app: App = auto_free(App.new())
	var architecture := _architecture(app)
	for tick: int in 100: architecture.lifecycle(&"session_begin", {"tick":tick})
	var snapshot: Dictionary = architecture.snapshot()
	assert_int(snapshot.history.size()).is_equal(64)
	snapshot.history[0].data.tick = -100
	assert_int(architecture.snapshot().history[0].data.tick).is_greater_equal(0)
