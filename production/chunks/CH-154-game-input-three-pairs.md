# CH-154 GameInput: 3 rotation pairs, enabled_axes, cancel_all

**MB task:** MB-015 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-153 (same agent)
**Files:** edit `src/game/input/game_input.gd`

## API
```gdscript
# signal rotate_piece(axis: StringName, dir: int)   # axis is now InputAxes.SPIN | TILT | ROLL; dir = +1 right, -1 left
var enabled_axes: Array[StringName] = InputAxes.ALL.duplicate()
func disable() -> void        ## also releases a held soft drop (emits soft_drop(false) once)
func cancel_all() -> void     ## clears RepeatTimer, held soft drop, toggle state; Input.flush_buffered_events()
func set_enabled_axes(axes: Array[StringName]) -> void   ## BoardController sets this from control.rotation_axes_enabled
```

## Behaviour
- Wire the 6 renamed/new actions to `try_rotate(InputAxes.X, +-1)`; delete `&"horizontal"`/`&"vertical"` literals.
- A disabled axis emits nothing (existing `try_rotate` rule). `enabled_axes` default is all three.
- `cancel_all()` is the only stop-input call other systems use (ADR-0010 pause, ADR-0012 §7.5). It does NOT disable the context.
- Repeat delay/interval stay the two exports until knob wiring (`control.repeat_delay_ms`, `control.repeat_interval_ms`); mark `# ponytail: exports until knob wiring`.
- Keep `RepeatTimer` and `Gestures` unchanged. One intent vocabulary: ADR-0012 names win over README-batch4 (`rotate_requested`).

## How the integrator sees it working
Run `src/dev/input_probe.tscn` in the editor (`project_run`). Press Q, R, Z: the probe/log prints `rotate_piece spin -1`, `tilt -1`, `roll -1`; E/F/X give +1. Call `set_enabled_axes([&"spin"])` from the probe and press R: nothing printed. Hold soft drop then call `cancel_all()`: one `soft_drop false` line.

**Out of scope: context switching (CH-155), touch buttons.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
