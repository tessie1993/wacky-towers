# CH-025 CameraRig: 12 snaps, framing, tweened turns

**Story:** VEW-004
**Goal:** the node that frames the board orthographically and turns the view in 30° snaps; mapping switches instantly, the picture tweens (Camera GDD rules 1–7).
**Depends:** CH-024
**Parallel-safe with:** every batch-2 ticket except CH-023, CH-024
**Files (new):** `src/view/camera_rig.gd`, `src/view/camera_rig.tscn`, `src/dev/camera_rig_preview.tscn`,
`tests/unit/view/camera_rig_test.gd`, evidence `production/qa/evidence/VEW-004-yaw-k0.png`, `-k3.png`, `-k4.png`

## API (implementation-plan §1.2, minus `pick_cell`)

```gdscript
class_name CameraRig extends Node3D
## Orthographic diorama camera: 12 yaw snaps around the board centre (Camera GDD). Math lives in CameraMath.
signal yaw_changed(k: int)

@export var base_deg: int = CameraMath.DEFAULT_BASE_DEG   # values come from knobs/view.json at APP-001
@export var step_deg: int = CameraMath.DEFAULT_STEP_DEG
@export var elevation_deg: float = 30.0                    # Camera GDD F2 default
@export var margin: float = 0.5                            # Camera GDD F2 default
@export var turn_anim_ms: int = 150                        # Camera GDD F4 default; 0 = instant cut
@export var distance: float = 100.0                        # camera stand-off; orthographic, so only clipping depends on it

func frame_board(board_size: Vector3i) -> void
func rotate_view(step: int) -> void                         ## ±1; logical k changes at once, picture tweens
func get_yaw_index() -> int
func screen_dir_to_world(screen_dir: Vector2i) -> Vector3i
func world_axis_for(screen_axis: StringName) -> Vector3i    ## &"spin" -> (0,1,0); &"tilt"/&"roll" from CameraMath.view_axes; else ZERO
```

`pick_cell` is deferred until `BoardView` exists (VEW-001). Do not stub it.

## Scene and placement (must match CH-023's convention)

- `camera_rig.tscn`: root `CameraRig` (Node3D) -> child `Camera3D` named `Camera`, `projection = PROJECTION_ORTHOGONAL`, `current = true`.
- `frame_board(s)`: rig `position = Vector3(s.x, s.y, s.z) * 0.5` (board centre; cell (x,y,z) spans [x, x+1]);
  `Camera.size = CameraMath.ortho_size(s, elevation_deg, aspect, margin)` where `aspect = viewport width / height`
  (the HUD board rectangle replaces this at APP-001); camera local position `(0, distance·sin(elev), distance·cos(elev))`,
  `rotation.x = −elev`; `near`/`far` cover `2 × distance`.
- Rig yaw: `rotation.y = deg_to_rad(yaw − 90)` — this makes the camera basis.x equal `(sin θ, 0, cos θ)`, the R vector of CH-023.
- `rotate_view(step)`: `k = posmod(k + step, 12)`; emit `yaw_changed(k)`; kill any running tween; tween `rotation.y` from its
  current value to the new target by the **short way** (target adjusted by ±TAU so |delta| <= PI) over `turn_anim_ms / 1000.0`;
  `turn_anim_ms == 0` sets it instantly. Pressing during a turn re-targets from the logical k (GDD edge case).
- Sideways-gravity snap restriction (GDD rule 9a) is not needed in Meadow: add one comment
  `# TODO(VEW-004 rule 9a): skip non-side-on snaps when the down axis is ±x/±z` in `rotate_view`.

## Tests to write first (`camera_rig_test.gd`; instantiate the .tscn with `auto_free`, add to the test scene tree)

1. `test_starts_at_k0` — `get_yaw_index() == 0`.
2. `test_rotate_wraps` — `rotate_view(-1)` -> 11; `rotate_view(1)` twice from 11 -> 1.
3. `test_yaw_changed_emitted` — monitor signals; `rotate_view(1)` emits `yaw_changed(1)`.
4. `test_mapping_switches_instantly` — `turn_anim_ms = 150`, k 2 -> `rotate_view(1)` and **in the same frame**
   `screen_dir_to_world(Vector2i(1, 0)) == Vector3i(0, 0, -1)`.
5. `test_world_axis_for` — `&"spin"` -> `(0,1,0)`; at k 1 `&"tilt"` -> `(1,0,0)`; `&"bogus"` -> ZERO.
6. `test_frame_board_sets_ortho_size` — `frame_board(Vector3i(6,14,6))`: `Camera.size == CameraMath.ortho_size(...)` with the viewport aspect; rig position `(3,7,3)`.
7. `test_instant_cut_when_anim_zero` — `turn_anim_ms = 0`, `rotate_view(1)` -> `rotation.y` == `deg_to_rad(75 − 90)` immediately.

## Evidence (coding standard: a parse check is not a run)

`src/dev/camera_rig_preview.tscn`: a `CameraRig` instance framing a `6×14×6` placeholder (`CSGBox3D` size (6,14,6) at (3,7,3)
plus a small red `CSGBox3D` at the +x end so orientation is visible) and a `DirectionalLight3D`. Run it (Godot AI MCP or editor),
capture k = 0, 3, 4 to the three PNGs above. If you cannot capture screenshots, mark the ticket `blocked (needs screenshot run)` after the tests are green.

## Run
`-a res://tests/unit/view` (README).

## Done when
README "Done when" + 7 tests green + 3 screenshots on disk, each showing the whole box with margin.
