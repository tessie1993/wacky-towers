# CH-159 BoardCameraRig: free orbit, settle tween, view_changed, freeze

**MB task:** MB-019 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-156, CH-157, CH-158; MB-006 verdict (phantom_camera or plain Camera3D)
**Files:** new `src/view/camera/board_camera_rig.gd` + `src/view/camera/board_camera_rig.tscn`; demo `src/dev/camera_rig_demo.tscn`; replaces `src/view/camera_rig.gd` (delete when nothing references it; keep `camera_math.gd`)

## API
```gdscript
class_name BoardCameraRig extends Node3D
signal view_changed(k: int, direction_map: Dictionary)   ## same frame as the logical change
signal feedback_requested(cue: StringName)              ## &"SFX_CAM_SETTLE" when a settle ends (ADR-0014 §3)
var snap: ViewSnap
func setup(board_size: Vector3i, motion: MotionPrefs) -> void   ## frames the board (OrthoFraming), k = 0
func set_board_rect(rect: Rect2) -> void        ## HUD board rect; reframes via lens size/offset
func rotate_view(dir: int) -> void              ## ViewSnap.step then tween
func snap_to_corner(c: int) -> void
func orbit_drag(delta_px: float) -> void        ## free orbit; k unchanged
func orbit_release() -> void                    ## ViewSnap.settle(current yaw), emit view_changed, tween
func freeze() -> void                           ## kill tween, set yaw to target, ignore input
func unfreeze() -> void
```

## Behaviour
- Tree: YawPivot (Node3D) -> ElevArm (pitch = -elevation) -> CameraAnchor; orthographic `Camera3D` (KEEP_HEIGHT). If MB-006 passed, wrap with `PhantomCameraHost` + one `PhantomCamera3D` (lens only, no noise yet); if it failed, plain Camera3D under the arm. Public API identical either way.
- Turn = tween on `YawPivot.rotation.y`, shortest arc, `view.turn_anim_ms` (default 150), created with `create_tween()`; retarget mid-turn = kill + restart from the current angle, no queue. Settle after a drag uses `view.settle_ms` (150).
- `view_changed` fires immediately on step/corner/release, never during a drag. Reduced motion (`motion.reduced`): cut to the target, no tween, no settle cue.
- Orbit sensitivity: 80 px per 30 deg default (constant with `# ponytail: knob control.orbit_px_per_step later`).
- Idle cost: no `_process` work when nothing moves.

## How the integrator sees it working
Run `src/dev/camera_rig_demo.tscn` (a lit 4x4 floor with a coloured corner marker). `input_simulate` keys 1/2 call `rotate_view(-1/+1)`, keys 3..6 call `snap_to_corner`: `editor_screenshot` at 4 corner snaps into `production/qa/evidence/MB-019/` shows the marker moving round the board 90 deg each time. Mouse drag orbits freely, release settles on a 30 deg step and `logs_read` shows one `view_changed` line per settle. Toggle reduced motion: turns become instant cuts.

**Out of scope: shake/noise, Auto camera mode, ScreenLayout, safe area.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
