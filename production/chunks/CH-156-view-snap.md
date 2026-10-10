# CH-156 ViewSnap (settled snap k, allowed mask, direction + rotation-axis map)

**MB task:** MB-019 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-023 (CameraMath)
**Files:** new `src/view/camera/view_snap.gd`

## API
```gdscript
class_name ViewSnap extends RefCounted
## Logical camera snap, pure (ADR-0014 §2). The sim never sees it; input reads it.
func _init(yaw_offset_deg: int = 45, step_deg: int = 30) -> void   ## knobs view.yaw_offset_deg; step is 30 (12 snaps)
var k: int = 0                                  ## settled snap 0..11
func set_allowed(mask: int) -> void             ## 12-bit mask; all 12 for +-y gravity, side-on 8 for ground axes (Camera rule 9a)
func step(dir: int) -> bool                     ## next allowed snap in dir (+1/-1, wraps); false if none
func snap_to_corner(c: int) -> bool             ## c 0..3 -> k = 0,3,6,9, or nearest allowed
func nearest_allowed(yaw_deg: float) -> int     ## nearest allowed snap to a free-orbit yaw
func settle(yaw_deg: float) -> void             ## k = nearest_allowed(yaw_deg) (drag release)
func yaw_deg() -> float                         ## CameraMath.yaw_degrees(k, ...)
func direction_map() -> Dictionary              ## {Vector2i screen_dir: Vector3i world_dir} for the 4 screen directions
func rotation_for(screen_axis: StringName, dir: int) -> Vector2i   ## (Orientations.Axis int, sign): InputAxes spin/tilt/roll -> world axis + sign
```

## Behaviour
- Wrap `CameraMath` (yaw, `screen_dir_to_world`, `view_axes`); do not duplicate its math.
- `rotation_for` follows Movement GDD rule 9: spin = world Y; tilt = the horizontal world axis (X or Z) whose screen projection is closest to screen-horizontal, tie at corner snaps goes to the axis that appears up-right; roll = the other. Sign: +1 = spin right, tilt away from the viewer, roll right (README-batch4 contract). Derive from `CameraMath.view_axes(k, ...)`; the existing `CameraRig.world_axis_for` is the starting point.
- Free drag never changes `k`; only `settle()` / `step()` / `snap_to_corner()` do.
- Unallowed state: if `allowed == 0` treat as all allowed (guard, never loop).

## How the integrator sees it working
Editor script eval: `var v := ViewSnap.new(); print(v.k, v.yaw_deg(), v.direction_map())`. Expect k 0, yaw 45, map up -> (0,0,-1)-ish per CameraMath. `v.step(1)` x3 then `v.k == 3`; `v.step(1)` 12 times returns to the same k. `set_allowed(0b111111110000)`; `v.step(1)` never lands on k 0..3. Print `rotation_for(&"spin", 1)` = (1, +-1) i.e. axis Y.

**Out of scope: tween, nodes, phantom_camera.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
