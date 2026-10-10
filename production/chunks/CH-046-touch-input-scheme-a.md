# CH-046 TouchInput Scheme A (all 3 axes)

**Story:** INP-002 · **Model:** Sonnet · **Wave:** W2 · **Mode:** direct (one scene, one writer; contract = intent signals)
**Goal:** on-screen Twin Pads for touch (mouse-clickable in the editor) that emit the intent contract. Every rotation axis has buttons;
disabled axes are hidden, not greyed (Touch GDD rule 9).
**Depends:** CH-042 · **Parallel-safe with:** W2
**Before starting:** read `production/chunks/README-plugins.md` (if it exists). If a PLG GUIDE ticket routes on-screen buttons through GUIDE
actions, emit through that instead of the signals below; if unclear: `blocked (GUIDE touch route)`.
**Files:** new `src/game/input/touch_input.gd`, `src/game/input/touch_input.tscn`.

## API (intent contract, README-batch4)
```gdscript
class_name TouchInput extends Control
## Scheme A on-screen controls. Emits screen-relative intents; never touches the sim.
signal move_requested(screen_dir: Vector2i)
signal rotate_requested(screen_axis: StringName, dir: int)   # +1 = spin right / tilt away / roll right
signal soft_drop_changed(on: bool)
signal hard_drop_requested()
signal rotate_view_requested(step: int)
func configure(tap_ms: int) -> void                    ## control.tap_ms
func set_enabled_axes(axes: PackedStringArray) -> void ## hides Spin*/Tilt*/Roll* buttons not listed
func set_active(on: bool) -> void                      ## false: emits nothing (Disabled/Waiting/Paused)
```

## Scene (node names are the contract for GP-4)
`TouchInput` (full rect, `mouse_filter = PASS`) → `DPad/{Left,Right,Up,Down}` (bottom-left, each >= 56 px), `Rotate/{SpinLeft,SpinRight,
TiltAway,TiltToward,RollLeft,RollRight}` (bottom-right diamond, roll arcs above), `Drop` (centre-bottom, 64 px, audit B8), `View/{Left,Right}`
(top-right, 56 px). Greybox `Button`s with arrow text. Disabled axes: `visible = false`.

## Behaviour
- D-pad: press -> `move_requested` (Up = (0,-1)). No repeat here (CH-095).
- Rotate buttons: press -> `rotate_requested(axis, ±1)` once (`control.rotate_repeat` false).
- Drop: `_on_drop_down()` starts a one-shot `Timer` of tap_ms; `_on_drop_timeout()` -> `soft_drop_changed(true)`; `_on_drop_up()` ->
  before timeout `hard_drop_requested()`, after `soft_drop_changed(false)`.
- View buttons -> `rotate_view_requested(-1 / +1)`.

## Expected results (no tests)
User rule 2026-10-10: NO TESTS. Do not write test files. These are the expected results: the integrator checks them in the editor (godot-ai script eval or a scratch script, read with `logs_read`) after moving the file in.
1. `test_dpad_dirs` — press Left/Up -> (-1,0) / (0,-1).
2. `test_rotation_buttons_all_axes` — each of 6 buttons emits its (axis, dir).
3. `test_disabled_axes_hidden` — `set_enabled_axes(["spin"])`: Tilt*/Roll* not visible, Spin* visible.
4. `test_drop_tap_vs_hold` — down+up before timeout -> hard drop only; down, timeout, up -> soft on then off, no hard drop.
5. `test_inactive_emits_nothing`.
No orphans (exit 101 is a fail).

## Run
Integrator: move staged files in, rescan, `logs_read` must show no parse errors or class-name clashes, then check the cases above. No gdUnit run.

**Out of scope:** Scheme B (CH-098), portrait/mirror (CH-099), repeat/buffer (CH-095), pause button (HUD).
