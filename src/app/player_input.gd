class_name WtPlayerInput extends RefCounted
## Native GUIDE contexts feed semantic wt_* actions; touch keeps its UI intents.
## Movement repeats use simulation time, while discrete GUIDE presses are buffered
## as InputEventActions for the application's existing _unhandled_input router.
const REPEAT_DELAY_MS: int = 170
const REPEAT_MS: int = 50
const GAMEPAD_DEADZONE: float = 0.45
var _held: Vector2i = Vector2i.ZERO
var _repeat_at: int = 0
var _soft: bool = false
const OWNED_ACTIONS: Array[StringName] = [&"wt_move_left", &"wt_move_right", &"wt_move_up", &"wt_move_down",
	&"wt_soft_drop", &"wt_hard_drop", &"wt_rot_h_left", &"wt_rot_h_right", &"wt_rot_v_left", &"wt_rot_v_right",
	&"wt_rot_roll_left", &"wt_rot_roll_right", &"wt_view_left", &"wt_view_right", &"wt_pause", &"wt_restart", &"wt_hold", &"wt_skill", &"wt_item"]
const HELD_ACTIONS: Array[StringName] = [&"wt_move_left", &"wt_move_right", &"wt_move_up", &"wt_move_down", &"wt_soft_drop"]
const REMAP_ALIASES := {"move_left":"wt_move_left", "move_right":"wt_move_right", "move_up":"wt_move_up", "move_down":"wt_move_down",
	"rot_spin_left":"wt_rot_h_left", "rot_spin_right":"wt_rot_h_right", "rot_tilt_left":"wt_rot_v_left", "rot_tilt_right":"wt_rot_v_right",
	"rot_roll_left":"wt_rot_roll_left", "rot_roll_right":"wt_rot_roll_right", "hard_drop":"wt_hard_drop", "soft_drop":"wt_soft_drop",
	"view_l":"wt_view_left", "view_r":"wt_view_right", "pause":"wt_pause", "hold":"wt_hold", "skill":"wt_skill", "item":"wt_item"}
var _guide: Node
var _play_context: GUIDEMappingContext
var _navigation_context: GUIDEMappingContext
var _actions: Dictionary[StringName, GUIDEAction] = {}
var _bindings: Dictionary = {}
var _stick: GUIDEAction
var _active: bool = false

## Capture the repository's bindings, then let GUIDE own their hardware events.
## Removing owned raw bindings prevents duplicate keyboard/gamepad commands.
func setup(tree: SceneTree, prefs: Dictionary = {}) -> bool:
	if _guide != null:
		refresh_bindings(prefs)
		return true
	_guide = tree.root.get_node_or_null("GUIDE")
	if _guide == null: return false
	for action: StringName in OWNED_ACTIONS:
		if not InputMap.has_action(action): InputMap.add_action(action)
		_bindings[action] = InputMap.action_get_events(action).duplicate()
	refresh_bindings(prefs)
	return true

## Rebuild native GUIDE mappings after saved key remaps. Accept canonical wt_*
## names and the UI's semantic aliases; gamepad bindings remain available.
func refresh_bindings(prefs: Dictionary = {}) -> void:
	if _guide == null: return
	var was_active := _active
	if _play_context != null: _guide.disable_mapping_context(_play_context)
	if _navigation_context != null: _guide.disable_mapping_context(_navigation_context)
	for action: StringName in OWNED_ACTIONS:
		var live: Array[InputEvent] = InputMap.action_get_events(action)
		if not live.is_empty():
			var merged: Array[InputEvent] = []
			for old: InputEvent in _bindings.get(action, []):
				if not old is InputEventKey: merged.append(old)
			for event: InputEvent in live:
				if event is InputEventKey: merged.append(event)
			_bindings[action] = merged
		InputMap.action_erase_events(action)
	for key: String in prefs:
		if not key.begins_with("key_"): continue
		var alias := key.trim_prefix("key_")
		var action := StringName(str(REMAP_ALIASES.get(alias, alias)))
		if action not in OWNED_ACTIONS: continue
		var code := OS.find_keycode_from_string(str(prefs[key]))
		if code == KEY_NONE: continue
		var remapped: Array[InputEvent] = []
		for old: InputEvent in _bindings.get(action, []):
			if not old is InputEventKey: remapped.append(old)
		var event := InputEventKey.new()
		event.physical_keycode = code
		remapped.append(event)
		_bindings[action] = remapped
	_actions.clear()
	_play_context = GUIDEMappingContext.new()
	_play_context.display_name = "Wacky Towers · Play"
	_navigation_context = GUIDEMappingContext.new()
	_navigation_context.display_name = "Wacky Towers · Back / Pause"
	for name: StringName in OWNED_ACTIONS:
		var action := GUIDEAction.new()
		action.name = name
		action.display_name = str(name).trim_prefix("wt_").replace("_", " ").capitalize()
		action.display_category = "Wacky Towers"
		action.is_remappable = true
		action.emit_as_godot_actions = true
		_actions[name] = action
		var mapping := GUIDEActionMapping.new()
		mapping.action = action
		for event: InputEvent in _bindings.get(name, []):
			var input: GUIDEInput = _native_input(event, name)
			if input == null: continue
			var input_mapping := GUIDEInputMapping.new()
			input_mapping.input = input
			input_mapping.is_remappable = event is InputEventKey
			if name not in HELD_ACTIONS: input_mapping.triggers.append(GUIDETriggerPressed.new())
			mapping.input_mappings.append(input_mapping)
		if name == &"wt_pause": _navigation_context.mappings.append(mapping)
		else: _play_context.mappings.append(mapping)
	_build_stick()
	_guide.enable_mapping_context(_navigation_context, false, -10)
	_active = false
	set_active(was_active)

func _native_input(event: InputEvent, name: StringName) -> GUIDEInput:
	if event is InputEventKey:
		var key := GUIDEInputKey.new()
		key.key = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
		key.shift = event.shift_pressed
		key.control = event.ctrl_pressed
		key.alt = event.alt_pressed
		key.meta = event.meta_pressed
		return key
	if event is InputEventJoypadButton:
		var button := GUIDEInputJoyButton.new()
		button.button = event.button_index
		return button
	if event is InputEventJoypadMotion:
		if name in HELD_ACTIONS and name != &"wt_soft_drop": return null
		var direction := GUIDEInputJoyDirection.new()
		direction.axis = event.axis
		direction.direction = GUIDEInputJoyDirection.Direction.POSITIVE if event.axis_value > 0 else GUIDEInputJoyDirection.Direction.NEGATIVE
		direction.actuation_threshold = GAMEPAD_DEADZONE
		return direction
	return null

func _build_stick() -> void:
	_stick = GUIDEAction.new()
	_stick.name = &"wt_guide_move_stick"
	_stick.action_value_type = GUIDEAction.GUIDEActionValueType.AXIS_2D
	var mapping := GUIDEActionMapping.new()
	mapping.action = _stick
	var input_mapping := GUIDEInputMapping.new()
	input_mapping.input = GUIDEInputJoyAxis2D.new()
	var deadzone := GUIDEModifierDeadzone.new()
	deadzone.lower_threshold = GAMEPAD_DEADZONE
	input_mapping.modifiers.append(deadzone)
	var trigger := GUIDETriggerDown.new()
	trigger.actuation_threshold = 0.0
	input_mapping.triggers.append(trigger)
	mapping.input_mappings.append(input_mapping)
	_play_context.mappings.append(mapping)

## Navigation stays available while the gameplay context is disabled.
func set_active(active: bool) -> void:
	if _active == active: return
	_active = active
	if _guide == null: return
	if active: _guide.enable_mapping_context(_play_context, false, 0)
	else:
		_guide.disable_mapping_context(_play_context)
		_clear_hardware_state()

func _clear_hardware_state() -> void:
	# Public injection releases GUIDE's shadow key state even if a subsequent
	# key-up is consumed by a menu's LineEdit instead of reaching its tracker.
	for name: StringName in OWNED_ACTIONS:
		if name == &"wt_pause": continue
		for binding: InputEvent in _bindings.get(name, []):
			if binding is InputEventKey:
				var release := InputEventKey.new()
				release.physical_keycode = binding.physical_keycode if binding.physical_keycode != 0 else binding.keycode
				_guide.inject_input(release)
		Input.action_release(name)

## Remove only this adapter's contexts and restore its captured raw bindings.
func dispose() -> void:
	if is_instance_valid(_guide):
		if _play_context != null: _guide.disable_mapping_context(_play_context)
		if _navigation_context != null: _guide.disable_mapping_context(_navigation_context)
	for action: StringName in _bindings:
		InputMap.action_erase_events(action)
		for event: InputEvent in _bindings[action]: InputMap.action_add_event(action, event)
	_guide = null
	_actions.clear()
	_bindings.clear()
	_active = false

func backend_snapshot() -> Dictionary:
	return {"backend": "GUIDE" if _guide != null else "InputMap", "active": _active,
		"play_mappings": _play_context.mappings.size() if _play_context != null else 0,
		"navigation_mappings": _navigation_context.mappings.size() if _navigation_context != null else 0}

## Releases transient input when entering menus, changing focus or pausing.
func reset() -> void:
	_held = Vector2i.ZERO
	_repeat_at = 0
	_soft = false
	set_active(false)

## Returns semantic presses and repeats. Keyboard directions are screen-relative.
func poll(now_ms: int) -> Array[Dictionary]:
	if _guide != null and not _active: set_active(true)
	var out: Array[Dictionary] = []
	var direction: Vector2i = Vector2i.ZERO
	if _pressed(&"wt_move_left"): direction.x -= 1
	if _pressed(&"wt_move_right"): direction.x += 1
	if _pressed(&"wt_move_up"): direction.y -= 1
	if _pressed(&"wt_move_down"): direction.y += 1
	if direction == Vector2i.ZERO and _guide != null:
		var stick := _stick.value_axis_2d
		if not stick.is_zero_approx():
			direction = Vector2i(int(signf(stick.x)), 0) if absf(stick.x) >= absf(stick.y) else Vector2i(0, int(signf(stick.y)))
	if direction.x != 0 and direction.y != 0: direction.y = 0
	if direction != _held:
		_held = direction
		_repeat_at = now_ms + REPEAT_DELAY_MS
		if direction != Vector2i.ZERO: out.append({"id": &"move", "screen": direction})
	elif direction != Vector2i.ZERO and now_ms >= _repeat_at:
		_repeat_at = now_ms + REPEAT_MS
		out.append({"id": &"move", "screen": direction})
	var soft: bool = _pressed(&"wt_soft_drop")
	if soft != _soft:
		_soft = soft
		out.append({"id": &"soft", "active": soft})
	return out

func _pressed(action: StringName) -> bool:
	return _actions[action].is_triggered() if _guide != null else Input.is_action_pressed(action)

## Ensures roll, pause, hold, skill and gamepad actions exist on clean projects.
static func install_actions() -> void:
	var extra: Dictionary = {&"wt_rot_roll_left": KEY_T, &"wt_rot_roll_right": KEY_G,
		&"wt_pause": KEY_ESCAPE, &"wt_hold": KEY_H, &"wt_skill": KEY_X, &"wt_item": KEY_V}
	for action: StringName in extra:
		if not InputMap.has_action(action): InputMap.add_action(action)
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = extra[action]
		if not InputMap.action_has_event(action, event): InputMap.action_add_event(action, event)
	var buttons: Dictionary = {&"wt_hard_drop": JOY_BUTTON_A, &"wt_pause": JOY_BUTTON_START,
		&"wt_rot_h_left": JOY_BUTTON_LEFT_SHOULDER, &"wt_rot_h_right": JOY_BUTTON_RIGHT_SHOULDER,
		&"wt_rot_v_left": JOY_BUTTON_X, &"wt_rot_v_right": JOY_BUTTON_Y,
		&"wt_soft_drop": JOY_BUTTON_B, &"wt_hold": JOY_BUTTON_BACK,
		&"wt_rot_roll_left": JOY_BUTTON_LEFT_STICK, &"wt_rot_roll_right": JOY_BUTTON_RIGHT_STICK,
		&"wt_skill": JOY_BUTTON_TOUCHPAD,
		&"wt_move_left": JOY_BUTTON_DPAD_LEFT, &"wt_move_right": JOY_BUTTON_DPAD_RIGHT,
		&"wt_move_up": JOY_BUTTON_DPAD_UP, &"wt_move_down": JOY_BUTTON_DPAD_DOWN}
	for action: StringName in buttons:
		var event: InputEventJoypadButton = InputEventJoypadButton.new()
		event.button_index = buttons[action]
		if not InputMap.action_has_event(action, event): InputMap.action_add_event(action, event)
	for pair: Array in [[&"wt_move_left", JOY_AXIS_LEFT_X, -1.0], [&"wt_move_right", JOY_AXIS_LEFT_X, 1.0],
		[&"wt_move_up", JOY_AXIS_LEFT_Y, -1.0], [&"wt_move_down", JOY_AXIS_LEFT_Y, 1.0]]:
		var event: InputEventJoypadMotion = InputEventJoypadMotion.new()
		event.axis = pair[1]
		event.axis_value = pair[2]
		if not InputMap.action_has_event(pair[0], event): InputMap.action_add_event(pair[0], event)
	for pair: Array in [[&"wt_view_left", JOY_AXIS_RIGHT_X, -1.0], [&"wt_view_right", JOY_AXIS_RIGHT_X, 1.0], [&"wt_skill", JOY_AXIS_TRIGGER_LEFT, 1.0], [&"wt_item", JOY_AXIS_TRIGGER_RIGHT, 1.0]]:
		var event := InputEventJoypadMotion.new()
		event.axis = pair[1]
		event.axis_value = pair[2]
		if not InputMap.action_has_event(pair[0], event): InputMap.action_add_event(pair[0], event)
