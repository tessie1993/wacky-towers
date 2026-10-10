# MB-015 manifest (CH-153/154/155) -- ADR-0012 input migration
Paths relative to MB-015/ mirror final res:// paths.

| Final path | Action |
|---|---|
| src/game/input/input_axes.gd | new |
| src/game/input/input_context_router.gd | new |
| src/game/input/game_input.gd | replace |
| src/game/input/actions/rot_spin_left/right.tres, rot_tilt_left/right.tres, rot_roll_left/right.tres | new |
| src/game/input/actions/ui_up/down/left/right/accept/cancel/focus_next/focus_prev.tres | new (emit_as_godot_actions = true) |
| src/game/input/contexts/play.tres | new (= play_keyboard.tres + renames + roll pair; keeps its uid) |
| src/game/input/contexts/play_paused.tres, menu.tres, remap_capture.tres | new |
| src/game/input/actions/rot_h_left/right.tres, rot_v_left/right.tres | DELETE |
| src/game/input/contexts/play_keyboard.tres | DELETE (replaced by play.tres; delete first, uid moves) |

Defaults: spin Q/E + LB/RB, tilt R/F + triggers, roll T/G + joy X/Y (NOT Z/X: Z is already view_l, C view_r).
Paused: Esc/P/Start = pause (resume), Backspace/Select = restart, B = ui_cancel (Esc not double-bound to avoid same-context conflict).

## Seeing it work
- Open play.tres: 13 mappings incl. 6 rot_spin/tilt/roll. logs_read after rescan: no missing resources. grep rot_h_/rot_v_ in src/: only gestures.gd literal axes remain (unchanged per ticket; TouchInput still emits &"horizontal"/&"vertical", fixed in CH-046).
- input_probe: press Q/R/T -> `rotate_piece spin/tilt/roll -1`; E/F/G -> +1. set_enabled_axes([&"spin"]) then R prints nothing. Hold S (soft drop) then cancel_all(): one `soft_drop false`.
- Add InputContextRouter node to input_probe.tscn, assign to GameInput.router. set_screen(PLAY_PAUSED): Q/E silent, Esc prints pause_pressed. set_screen(MENU): arrows move focus on a Button.

## Review
- game_input.gd: gameplay intents (rotate, move, soft drop on, hard drop, view) now gated by `_gameplay_allowed()` = enabled and tree not paused (null-safe outside tree); pause/restart and soft-drop release still pass.
- input_context_router.gd: added `apply_remapping_config()` doing disable contexts -> GUIDE.set_remapping_config -> reassert (re-enable).
- remap_capture.tres: removed 3 unused ext_resources.
- Verified: all ext_resource/sub_resource ids resolve, GUIDE script uids match addons/guide .uid files, play.tres keeps uid://b6vyqpyr5d0dj, signals/names match input_probe.gd.
- Unresolved (outside staging): live tests/unit/game_input/game_input_test.gd uses &"horizontal"/&"vertical" and tests/unit/game/gestures_test.gd expects those axes; update to spin/tilt on integration. Live rot_h_*/rot_v_*/play_keyboard.tres must be deleted (play_keyboard first, uid moves).
