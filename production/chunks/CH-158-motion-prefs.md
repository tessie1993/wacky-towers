# CH-158 MotionPrefs (reduced-motion value object)

**MB task:** MB-019 · **Model:** Haiku · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** none
**Files:** new `src/view/camera/motion_prefs.gd`

## API
```gdscript
class_name MotionPrefs extends RefCounted
enum Mode { SYSTEM, ON, OFF }
var mode: Mode = Mode.SYSTEM
var reduced: bool = false                       ## effective value, read by camera, VFX, HUD
func refresh() -> void                          ## recompute `reduced`: ON -> true, OFF -> false, SYSTEM -> DisplayServer.accessibility_should_reduce_animation()
func set_mode(m: Mode) -> void                  ## sets and refreshes
```

## Behaviour
- Settings later feed `set_mode`; the owner calls `refresh()` at boot and on `NOTIFICATION_APPLICATION_FOCUS_IN` (ADR-0014 §4). Never reads a settings autoload.
- On platforms where the DisplayServer call is unsupported SYSTEM behaves as OFF.

## How the integrator sees it working
Editor script eval: new MotionPrefs, `set_mode(ON)` -> `reduced == true`; `set_mode(OFF)` -> false; SYSTEM prints the OS value (false on a default PC). `logs_read` shows no error.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
