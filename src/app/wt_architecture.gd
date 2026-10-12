class_name WtArchitecture extends Node
## Native Orchestrator graphs own guarded application-domain dispatch and lifecycle.
## BoardSim remains the deterministic gameplay owner; this bridge contains no rules.
signal state_changed(snapshot: Dictionary)
signal intent_dispatched(domain: StringName, intent: StringName)
signal intent_rejected(intent: StringName, reason: String)
const GRAPH_PATH: String = "res://src/app/architecture.torch"
const PLAY_INTENTS: Array[StringName] = [&"move", &"rotate", &"drop", &"soft", &"hold", &"use_skill", &"use_item", &"tap", &"view"]
const PUZZLE_INTENTS: Array[StringName] = [&"pick_shape", &"choose_down", &"flick", &"undo", &"reset"]
var _host: Node
var _graph: Node
var _state: StringName = &"idle"
var _revision: int = 0
var _history: Array[Dictionary] = []
var _domain_counts: Dictionary = {}
var _rejected: int = 0
var _save_revision: int = 0
var _last_event: StringName = &"boot"
var _reason: String = ""

func setup(host: Node) -> void:
	_host = host
	var graph_script: Script = load(GRAPH_PATH)
	assert(graph_script != null, "Orchestrator architecture graph must be installed")
	_graph = Node.new()
	_graph.name = "ApplicationArchitectureGraph"
	_graph.set_script(graph_script)
	add_child(_graph)
	lifecycle(&"boot")

func dispatch(intent: StringName, data: Dictionary = {}) -> void:
	assert(_graph != null, "Call WtArchitecture.setup before dispatch")
	_graph.call("dispatch", intent, data, self)

func lifecycle(event: StringName, data: Dictionary = {}) -> void:
	if _graph != null: _graph.call("transition", event, data, self)

## This is the graph's guard predicate. State comes from the application, not a shadow sim.
func allows(intent: StringName, data: Dictionary) -> bool:
	_reason = ""
	if String(intent).length() > 64 or data.size() > 64:
		_reason = "malformed_intent"
		return false
	var context: Dictionary = _context()
	if intent in PLAY_INTENTS and (not context.get("has_session", false) or context.get("paused", true) or context.get("result", false)):
		_reason = "session_not_playing"
	elif intent in PUZZLE_INTENTS and (not context.get("has_session", false) or context.get("result", false) or context.get("mode", "") == "lan"):
		_reason = "puzzle_tools_unavailable"
	elif intent in [&"pause", &"resume", &"retry", &"open_tools"] and not context.get("has_session", false):
		_reason = "session_missing"
	elif intent in [&"open_level", &"start_level", &"start_arcade", &"start_tournament", &"buy_item", &"toggle_perk", &"select_potion"] and not context.get("has_profile", false):
		_reason = "profile_missing"
	elif intent == &"start_lan" and (not context.get("lan_active", false) or not context.get("lan_host", false)):
		_reason = "party_host_required"
	elif intent == &"next" and not context.get("result", false):
		_reason = "result_missing"
	return _reason.is_empty()

func reject(intent: StringName, _data: Dictionary) -> void:
	_rejected += 1
	intent_rejected.emit(intent, _reason if not _reason.is_empty() else "unknown_intent")

func route_profile(intent: StringName, data: Dictionary) -> void:
	_execute(&"profile", intent, data)
func route_progression(intent: StringName, data: Dictionary) -> void:
	_execute(&"progression", intent, data)
func route_session(intent: StringName, data: Dictionary) -> void:
	_execute(&"session", intent, data)
func route_modes(intent: StringName, data: Dictionary) -> void:
	_execute(&"modes", intent, data)
func route_lan(intent: StringName, data: Dictionary) -> void:
	_execute(&"lan", intent, data)
func route_preferences(intent: StringName, data: Dictionary) -> void:
	_execute(&"preferences", intent, data)
func route_presentation(intent: StringName, data: Dictionary) -> void:
	_execute(&"presentation", intent, data)

func _execute(domain: StringName, intent: StringName, data: Dictionary) -> void:
	_domain_counts[domain] = int(_domain_counts.get(domain, 0)) + 1
	_host.call("_execute_intent", intent, data)
	intent_dispatched.emit(domain, intent)

## The graph supplies the next state. Save commits record a transaction without leaving play.
func apply_transition(state: StringName, event: StringName, data: Dictionary) -> void:
	if state == &"saved": _save_revision += 1
	else: _state = state
	_last_event = event
	_revision += 1
	_history.append({"revision": _revision, "event": event, "state": _state, "data": data.duplicate(true)})
	if _history.size() > 64: _history.pop_front()
	state_changed.emit(snapshot())

func snapshot() -> Dictionary:
	return {"state": _state, "revision": _revision, "last_event": _last_event,
		"save_revision": _save_revision, "domains": _domain_counts.duplicate(), "rejected": _rejected,
		"context": _context(), "history": _history.duplicate(true)}

func _context() -> Dictionary:
	if _host == null: return {}
	if _host.has_method("_architecture_context"): return _host.call("_architecture_context")
	var store: Variant = _host.get("_store")
	var lan: Variant = _host.get("_lan")
	var ui: Variant = _host.get("_ui")
	return {"has_profile": store != null and store.active_profile() != null,
		"has_session": _host.get("_sim") != null, "paused": bool(_host.get("_paused")),
		"result": bool(_host.get("_result_shown")), "mode": String(_host.get("_mode")),
		"level_id": String(_host.get("_level_id")), "screen": String(ui.current_screen) if ui != null else "",
		"lan_active": lan != null and bool(lan.active), "lan_host": lan != null and lan.is_host()}
