extends SceneTree
## Engine-dispatched hardware events verify real GUIDE contexts and action emissions.
const PLAYER := preload("res://src/app/player_input.gd")
class _Watch extends Node:
    var seen: Array[StringName] = []
    func _unhandled_input(event: InputEvent) -> void:
        if event is InputEventAction and event.pressed:
            seen.append(event.action)
var failures: Array[String] = []
func _initialize() -> void: call_deferred("_run")
func _check(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)
        push_error(message)
func _frames() -> void:
    for i in 4: await process_frame
func _key(code: Key, pressed: bool, echo: bool = false) -> void:
    var event := InputEventKey.new()
    event.physical_keycode = code
    event.keycode = code
    event.pressed = pressed
    event.echo = echo
    Input.parse_input_event(event)
func _joy(device: int, button: JoyButton, pressed: bool) -> void:
    var event := InputEventJoypadButton.new()
    event.device = device
    event.button_index = button
    event.pressed = pressed
    Input.parse_input_event(event)
func _axis(device: int, axis: JoyAxis, value: float) -> void:
    var event := InputEventJoypadMotion.new()
    event.device = device
    event.axis = axis
    event.axis_value = value
    Input.parse_input_event(event)
func _run() -> void:
    var watch := _Watch.new()
    root.add_child(watch)
    await _frames()
    PLAYER.install_actions()
    var adapter := PLAYER.new()
    _check(adapter.setup(self), "GUIDE autoload missing")
    adapter.set_active(true)
    _check(adapter.backend_snapshot().backend == "GUIDE", "Expected actual GUIDE backend")
    _check(adapter.backend_snapshot().play_mappings >= 19, "Play mappings missing")
    _check(InputMap.action_get_events(&"wt_hard_drop").is_empty(), "Raw binding must not duplicate GUIDE emissions")
    _key(KEY_W, true)
    await _frames()
    var first := adapter.poll(10)
    _check(first.size() == 1 and first[0].id == &"move" and first[0].screen == Vector2i(0,-1), "W must move away once")
    _check(adapter.poll(100).is_empty(), "Move repeat fired before170ms")
    _check(adapter.poll(180).size() == 1, "Held move must repeat after170ms")
    _key(KEY_W, false)
    await _frames()
    _check(adapter.poll(190).is_empty(), "Released direction must stop")
    _key(KEY_SHIFT, true)
    await _frames()
    var soft := adapter.poll(200)
    _check(soft.size() == 1 and soft[0].id == &"soft" and soft[0].active, "Soft drop press missing")
    _key(KEY_SHIFT, false)
    await _frames()
    soft = adapter.poll(230)
    _check(soft.size() == 1 and not soft[0].active, "Soft drop release missing")
    _key(KEY_SPACE, true)
    await _frames()
    _key(KEY_SPACE, true, true)
    await _frames()
    _check(watch.seen.count(&"wt_hard_drop") == 1, "Held/echo drop must fire once")
    _key(KEY_SPACE, false)
    await _frames()
    adapter.refresh_bindings({"key_wt_hard_drop":"K"})
    _key(KEY_SPACE, true)
    await _frames()
    _check(watch.seen.count(&"wt_hard_drop") == 1, "Old binding survived remap")
    _key(KEY_SPACE, false)
    _key(KEY_K, true)
    await _frames()
    _check(watch.seen.count(&"wt_hard_drop") == 2, "RemappedK must trigger drop")
    _key(KEY_K, false)
    await _frames()
    adapter.reset()
    _key(KEY_K, true)
    await _frames()
    _check(watch.seen.count(&"wt_hard_drop") == 2, "Menu must block gameplay actions")
    _key(KEY_ESCAPE, true)
    await _frames()
    _check(watch.seen.count(&"wt_pause") == 1, "Pause/Back context must work in menus")
    _key(KEY_ESCAPE, false)
    _key(KEY_K, false)
    await _frames()
    adapter.set_active(true)
    # GUIDE exposes this same virtual device API to its gamepad UI widgets.
    var guide: Node = root.get_node("GUIDE")
    var state: GUIDEInputState = guide.get("_input_state")
    var device: int = state.connect_virtual_stick(77)
    _axis(device, JOY_AXIS_LEFT_X, .2)
    _axis(device, JOY_AXIS_LEFT_Y, .2)
    await _frames()
    _check(adapter.poll(300).is_empty(), "Stick drift must stay inside radial deadzone")
    _axis(device, JOY_AXIS_LEFT_X, .35)
    _axis(device, JOY_AXIS_LEFT_Y, .35)
    await _frames()
    var diagonal := adapter.poll(310)
    _check(diagonal.size() == 1 and diagonal[0].screen == Vector2i(1,0), "Radial threshold must accept diagonal above.45; x wins tie")
    _axis(device, JOY_AXIS_LEFT_X, 0)
    _axis(device, JOY_AXIS_LEFT_Y, 0)
    _joy(device, JOY_BUTTON_A, true)
    await _frames()
    _check(watch.seen.count(&"wt_hard_drop") == 3, "GamepadA must feed GUIDE drop")
    await _frames()
    _check(watch.seen.count(&"wt_hard_drop") == 3, "Held gamepadA must fire once")
    _joy(device, JOY_BUTTON_A, false)
    await _frames()
    adapter.reset()
    _joy(device, JOY_BUTTON_START, true)
    await _frames()
    _check(watch.seen.count(&"wt_pause") == 2, "GamepadStart must work in menu context")
    _joy(device, JOY_BUTTON_START, false)
    await _frames()
    state.disconnect_virtual_stick(device)
    adapter.dispose()
    _check(not InputMap.action_get_events(&"wt_hard_drop").is_empty(), "Dispose must restore captured bindings")
    watch.queue_free()
    await process_frame
    print("WT_GUIDE_INPUT: ", "PASS" if failures.is_empty() else "FAIL", " failures=", failures.size())
    quit(0 if failures.is_empty() else 1)
