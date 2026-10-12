# CH-153 InputAxes + spin/tilt/roll GUIDE actions

**MB task:** MB-015 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** MB-005 (GUIDE verified)
**Files:** new `src/game/input/input_axes.gd`; rename `src/game/input/actions/rot_h_*.tres` -> `rot_spin_left/right.tres`, `rot_v_*.tres` -> `rot_tilt_left/right.tres` (keep `.uid`, update refs); new `rot_roll_left.tres`, `rot_roll_right.tres`; edit `src/game/input/contexts/play_keyboard.tres` -> save as `play.tres` (ADR-0012 §2) with the new bindings

## API
```gdscript
class_name InputAxes extends RefCounted
## Axis ids shared by input, camera and sim command building (ADR-0012 §3). Player-facing names Turn/Flip/Roll are UI text only.
const SPIN := &"spin"
const TILT := &"tilt"
const ROLL := &"roll"
const ALL: Array[StringName] = [SPIN, TILT, ROLL]
```

## Behaviour
- Data only plus the constants. Defaults (ADR-0012 §3, final keys confirmed at first playable): keyboard Q/E = spin, R/F = tilt (unchanged), roll = a free single-key pair (propose `Z`/`X`); gamepad shoulders = spin, triggers = tilt (unchanged), roll = `JOY_BUTTON_X` / `JOY_BUTTON_Y`. View stays on right stick X (existing view_l/view_r bindings untouched).
- No chords (ACC-16).
- Old file names must not remain; grep `rot_h_`/`rot_v_` finds nothing in `src/` after this chunk (CH-154 updates `game_input.gd`; do this chunk and CH-154 as ONE agent, in order).

## How the integrator sees it working
Editor: open `play.tres`, the mapping list shows 6 rotation actions named rot_spin_*, rot_tilt_*, rot_roll_*. `logs_read` after a rescan shows no missing-resource errors.

**Out of scope: TouchInput roll buttons (CH-046), remap UI.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
