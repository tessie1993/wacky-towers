# MB-026 manifest (CH-046) -- Touch Scheme A on GUIDEVirtualButton
Paths relative to MB-026/ mirror final res:// paths. Depends on MB-015 (InputAxes, play.tres joy bindings): integrate MB-015 first.

| Final path | Action |
|---|---|
| src/game/input/touch_input.gd | replace (still a CanvasLayer; touch_input.tscn unchanged) |
| src/game/input/gestures.gd | replace (AXIS_HORIZONTAL/VERTICAL become AXIS_SPIN/AXIS_TILT = &"spin"/&"tilt") |
| assets/data/controls/touch_layouts.json | new (presets buttons / gestures / one_hand x landscape / portrait) |

## Seeing it work
- Run src/dev/input_probe.tscn with a TouchInput child. 16 round buttons appear; mouse clicks drive them.
- Click Turn / Flip / Roll left and right: probe prints `rotate_piece spin|tilt|roll -1/+1`.
- `set_enabled_axes([&"spin"])`: Flip and Roll buttons vanish and stop reacting; all three again: they return.
- `configure(&"buttons", false, 0.75)` then `2.0`: radius 30 px (75%, above the 28 px floor) and 80 px; drawn circle equals hit area. Scale below 70% would clamp to 28 px.
- `configure(&"one_hand", false, 1.0)`: one right-corner cluster; `&"one_hand_left"` or mirror=true flips x. `&"gestures"`: only roll/soft/drop/view/pause/restart.
- Resize the window to portrait: portrait block loads.
- `Gestures.classify(...)` flick results carry axis `&"spin"` / `&"tilt"`.

## Risks
- Hidden buttons use process_mode DISABLED so GUIDEVirtualButton._input stops. `_release()` and `_finger_positions` are GUIDE-private members (no public API in 0.14).
- Scale limits are exports plus configure() args until knobs control.button_scale_* exist. The 8 dp gap is not enforced; at 200% buttons may overlap, needs a device pass.
- Gestures preset only keeps the buttons; GestureZone (drag/flick zones) is a separate ticket. Touch remap (button_action) not included.
- Tilt L/R = PADDLE1/2, Roll = X/Y per MB-015 play.tres (V5 verified indices).

## Review
- touch_input.gd: process_mode = ALWAYS moved to `_init()` (set before children/entering tree); `radius_px` param renamed scale -> scale_factor (shadowed CanvasLayer.scale).
- Verified against addons/guide: `GUIDEVirtualButton._release()` and `_finger_positions: Dictionary` exist (private, no public release API in the addon); `draw_debug`, `button_radius`, `button_index`, `GUIDEVirtualJoyBase.InputMode.MOUSE_AND_TOUCH` exist. PADDLE1-4/X/Y/shoulder indices match MB-015 play.tres. Hidden buttons are released before DISABLED, so no stuck presses.
- gestures.gd uses InputAxes (MB-015 dependency, integrate first); touch_layouts.json parses and covers all 16 slots in buttons/one_hand.
- Unresolved: live tests/unit/game/gestures_test.gd still expects &"horizontal"/&"vertical"; update on integration.
