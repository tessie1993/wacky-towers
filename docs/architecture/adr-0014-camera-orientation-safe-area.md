# ADR-0014: Camera Rig, Orientation and Safe Area

## Status

Accepted (2026-10-10, accepted by user)

## Date

2026-10-10

## Last Verified

2026-10-10

## Decision Makers

Tessa (user), godot-specialist (engine validation)

## Summary

Each board gets one `BoardCameraRig`: an orthographic `Camera3D` driven by `phantom_camera` (`PhantomCameraHost` + one `PhantomCamera3D`). **Free orbit + snap (user decision 2026-10-10):** the player drags the camera freely around the board, and on release it settles with a tween to the nearest of the 12 snaps of 30°. Snap buttons step one snap at a time, and the four corner views (90° apart) are quick shortcuts. The settled snap `k` lives in a pure `ViewSnap` object, and the screen→world direction map comes from the settled `k`, never from the drag or the animated yaw. Auto (ACC-21) is an optional extra. Reduced motion follows the OS through `DisplayServer.accessibility_should_reduce_animation()` unless the player overrides it. One `ScreenLayout` node watches the viewport, works out portrait or landscape, applies `DisplayServer` safe-area insets and asks `AppFlow` to pause when the orientation flips mid-level. The camera never feeds the sim. A snap that gameplay depends on reaches the sim only as a recorded command (ADR-0001).

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Rendering / Platform (camera, window, display) |
| **Layer** | View + Game (`src/view/camera/`, `src/game/`) |
| **Knowledge Risk** | MEDIUM: `Camera3D`, `DisplayServer` orientation and safe area, and window stretch are stable since 4.0, but none of them is in `docs/engine-reference/godot/`. `DisplayServer.accessibility_*` is 4.5+ (AccessKit era) and post-cutoff. phantom_camera 0.11.0.3 is third-party GDScript with no stated 4.7 compatibility |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md` (4.6: new projects default to stretch `canvas_items` + `expand`), `current-best-practices.md` (Accessibility 4.5+), `modules/ui.md`, `modules/rendering.md`; `addons/phantom_camera/plugin.cfg` (0.11.0.3), `phantom_camera_3d.gd`, `phantom_camera_host.gd`, `resources/camera_3d_resource.gd`, `resources/phantom_camera_noise_3d.gd`; `project.godot` |
| **Post-Cutoff APIs Used** | `DisplayServer.accessibility_should_reduce_animation()`, `DisplayServer.accessibility_should_increase_contrast()` (ACC-36, optional) |
| **Verification Required** | (1) On Android: does `accessibility_should_reduce_animation()` return `true` when Developer options → "Remove animations" (or Accessibility → "Remove animations") is on? If not, the setting falls back to the in-game toggle only. (2) On Android, does `get_display_safe_area()` cover the display cutout and both system bars, and is it given in the same pixel space as `Window.size`? (3) Do the gesture-navigation side strips show up in the safe area? Godot has no gesture-inset API, so a `gesture_margin_dp` knob is planned (§5). (4) Do `screen_set_orientation(SCREEN_SENSOR_PORTRAIT / SCREEN_SENSOR_LANDSCAPE)` at runtime and `display/window/handheld/orientation = SCREEN_SENSOR` in the export work together? (5) How many `size_changed` signals does one physical rotation send, and in what order relative to `NOTIFICATION_WM_SIZE_CHANGED`? (6) Does phantom_camera 0.11.0.3 load in a 4.7.2 headless run, a release build and an Android export without errors? **Verified headless on 4.7.2 (2026-10-10):** `DisplayServer.get_display_safe_area`, `get_display_cutouts`, `screen_get_orientation`, `screen_set_orientation`, `screen_get_scale`, `window_set_min_size`, `accessibility_should_reduce_animation`, `accessibility_should_increase_contrast`; constants `SCREEN_SENSOR`, `SCREEN_PORTRAIT`, `SCREEN_LANDSCAPE`, `SCREEN_SENSOR_PORTRAIT`; `Window.min_size`; `Camera3D.PROJECTION_ORTHOGONAL`; settings `display/window/handheld/orientation`, `display/window/size/resizable` (default `true`), `display/window/stretch/scale_mode` (default `fractional`) |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Accepted): the sim never reads views, and commands are the only input. ADR-0010 (accepted by user 2026-10-10): `AppFlow.request_pause(&"rotate")`, `SceneTree.paused` freezes the rig. ADR-0007: `OcclusionAid` reads the camera's forward vector, and the outline width follows the ortho size |
| **Enables** | ADR-0012 input pipeline (direction map, `rotate_view`, orbit drag), ADR-0016 UI architecture (orientation and safe insets, board rect contract), HUD preview (TR-hud-002), Game Feel shake (TR-game-feel-vfx-004) |
| **Coordinates With** | ADR-0013 (persists camera mode, invert, orbit sensitivity, reduced-motion override, orientation lock), ADR-0009 (one rig per board, shared-tablet landscape lock) |
| **Blocks** | Meadow MVP play scene camera; ACC-70 both-orientation playthrough; meadow_02 (third rotation pair, which reads the direction map) |
| **Ordering Note** | `ViewSnap` and `OrthoFraming` are pure and can be built and tested before phantom_camera is wired in. The `view_snap` sim command (§6) must exist before SE05 angle gems (TR-mechanics-module-012) are built |

## Context

### Problem Statement

The camera GDD gives the framing math, the 12 snaps and the pause-on-rotate rule. Nobody owns the engine side: which node turns the view, where the logical snap lives so input mapping switches in the same frame, how the Auto / Swipe / Snap modes (ACC-20–23) and reduced motion (ACC-40) reach the camera, how the window stretches for portrait and landscape on phones and resizable PC windows, and how safe-area and cutout insets reach the UI (ACC-72, TR-hud-003). `phantom_camera` is already installed and its `PhantomCameraManager` autoload is registered, but no ADR says what it is used for. A visual rig must never become a hidden input to the sim: replays and versus depend on that.

### Constraints

- ADR-0001: the sim is pure and fixed-tick and never reads a node. A camera snap can matter to gameplay only as a command.
- Orthographic view, fixed elevation and fixed size per level and orientation (camera GDD rules 1–4). The camera never zooms or drifts in play.
- Android and PC/Steam ship together (decision sheet). Phones in both orientations, PC windows of any size, gamepad and keyboard as well as touch.
- Flagship phones, Mobile renderer. No per-frame camera work while idle.
- Values are data: turn time, orbit sensitivity and margins are knobs (ADR-0004). Player choices are settings (ADR-0013).
- GDScript only (ADR-0008).

### Requirements

- 12 snaps, `yaw = (yaw_offset + 30° × k) mod 360°`. The corner views k = 0, 3, 6, 9 are 90° apart. A turn takes `turn_anim_ms` per step and is logically instant.
- When a turn is pressed mid-turn, the camera retargets from the logical `k` with no queue. A pause mid-turn completes the turn instantly.
- Under sideways gravity only the side-on snaps are allowed (GDD rule 9a).
- Free orbit + snap (user decision 2026-10-10): a drag orbits freely, and release settles to the nearest allowed snap. Snap buttons and the four corner shortcuts are always available. Auto is optional. Invert and orbit sensitivity are separate settings. This replaces the GDD's "board-drag orbit, off by default" (rule 8), which the GDD owner should update.
- Reduced motion: a snap is an instant cut with no settle tween, there is no shake or punch, and skits have no camera moves. It follows the OS.
- Portrait and landscape everywhere. A flip mid-level pauses, re-lays out and reframes, and keeps `k`. A flip in menus only re-lays out.
- All UI stays inside the safe area, and nothing essential sits in the gesture strip.

## Decision

### 1. Rig: one per board, phantom_camera for host, lens and noise

```
PlaySession / World
 └ BoardCameraRig (Node3D, PAUSABLE)            src/view/camera/board_camera_rig.gd
     ├ YawPivot (Node3D, at board footprint centre)   ← the only thing a turn rotates
     │   └ ElevArm (Node3D, pitch = −elev)
     │       └ CameraAnchor (Marker3D, back along +Z by cam_distance)
     ├ BoardPcam (PhantomCamera3D)  follow GLUED → CameraAnchor · look_at MIMIC → CameraAnchor
     │     camera_3d_resource: projection ORTHOGONAL, keep_aspect KEEP_HEIGHT, size, h_offset, v_offset
     ├ ShakeEmitter (PhantomCameraNoiseEmitter3D)  positional_noise = true, rotational_noise = false
     └ Camera3D
         └ PhantomCameraHost (host_layers = this board's bit)
```

- **The turn is a tween on `YawPivot.rotation.y`**, made by the rig (`create_tween()`, so it is bound to the rig and stops on pause). It runs from the current animated angle to the target angle along the shortest arc. The camera then moves on a true circle at a fixed elevation, and retargeting mid-turn is free: kill the tween and start a new one from where the pivot is. Phantom tweens between PCams were rejected for turns because they move along a chord and are tuned for camera handoffs, not orbits.
- **What phantom_camera is used for:** the host, which owns the `Camera3D`; the lens resource (ortho size and offsets); `PhantomCameraNoiseEmitter3D` for shake and punch, with positional noise only, so shake stays translation-only (TR-game-feel-vfx-004); `host_layers`, so each board's pcams drive only that board's camera (ADR-0009); and priority handoffs to `SkitPcam` nodes in a level's `.tscn` for intro and payoff skits. The skit tween time is 0 under reduced motion (ACC-42).
- `PhantomCameraHost.interpolation_mode = IDLE`. The pivot tween runs in idle time, and the board view is not physics-interpolated.
- **Framing applied through the lens, not a SubViewport.** The camera covers the whole viewport. `size = ortho_h × viewport_h_px / board_rect.size.y`, and `h_offset` / `v_offset` shift the view so the board's footprint centre lands at the centre of the board rect. Nothing extra is rendered and no render target is needed on mobile. Split-screen rendering is ADR-0009's call.
- `PhantomCameraManager` (addon autoload) stays in release exports, because it is runtime code. It is not one of the dev or AI autoloads that are stripped.
- The rig does nothing per frame while idle. Only phantom's host `_process` runs, which is addon cost and is counted in the profile (verification 6).

### 2. Logical snap and direction map: pure, instant, owned by `ViewSnap`

- `ViewSnap` (RefCounted, `src/view/camera/view_snap.gd`) holds `k`, `yaw_offset` and an `allowed` 12-bit mask. `step(dir)` moves to the next allowed snap. `nearest_allowed()` handles gravity changes. `yaw_deg()` implements F1, and `direction_map()` implements F3 with the corner tie rule (GDD rule 11).
- `rotate_view(dir)` and `snap_to_corner(c)`: `ViewSnap` first, then emit `view_changed(k, map)` in the same frame (TR-camera-rotate-view-002), then start or retarget the settle tween. Input (ADR-0012) and the HUD preview (TR-hud-002) read `view_changed`, never the pivot's angle.
- **During a free drag `k` does not change.** The direction map stays on the last settled snap until release. On release `ViewSnap.k = nearest_allowed_to(yaw)` and `view_changed` fires, and only then does the tween settle the pivot. Moves made while dragging therefore use the snap the drag started from.
- `allowed` comes from the board's down axis: all 12 for ±y, the side-on 8 for ground axes at `side_on_min_deg` (GDD rule 9a). The GDD calls this knob `side_on_min_deg` and TR-level-specific-mechanics-007 calls it `side_view_min_deg`. This ADR uses the GDD name, and the registry wording should be aligned.
- `OrthoFraming` (static functions, `src/view/camera/ortho_framing.gd`) implements F2 for a footprint, a `board_height`, the elevation, the margin and the board rect size. It returns `ortho_h` and the cube edge in px, and is unit-tested against GDD AC 5–6. Level validation calls the same function for the ≥ 20 px floor (Board F5).

### 3. Camera control modes (ACC-20–23)

Free orbit + snap is the base scheme (user decision 2026-10-10). The ways of turning:

| Control | Turns the view by | Notes |
|---|---|---|
| **Free orbit** (always on) | Board drag (touch, mouse drag, gamepad right stick). `YawPivot` follows the drag freely at `orbit_px_per_step` (40–160, default 80) px per 30°. `k` stays unchanged while dragging. On release `k` = the nearest allowed snap, `view_changed` fires and the settle tween runs over `settle_ms` (knob, default 150) | Under sideways gravity, release settles to the nearest *allowed* snap |
| **Snap step** | View ◀/▶ actions (touch button, keys, gamepad shoulders; mapped in ADR-0012), hold-repeat with Touch F3 timings | One allowed snap per press |
| **Corner shortcuts** | Four actions, one per corner view (k = 0, 3, 6, 9) | A jump to a corner that is not allowed under sideways gravity goes to the nearest allowed snap |
| **Auto** (optional setting, ACC-21) | At most one automatic turn per piece: (a) to the nearest allowed snap when gravity changes; (b) when every ghost cube is occluded from the current snap, to the nearest snap from which some ghost cube is visible | Never during a drag. The visibility test reuses ADR-0007's `OcclusionAid` DDA and runs only when the ghost changes. Ties go clockwise. No turn if no snap shows the ghost |

- The free drag must start outside the touch control zones. Board-area ownership comes from Touch Controls (TR-touch-controls-003, ADR-0012).

- **Invert** (ACC-22) flips the sign of button steps and of drag direction.
- An automatic turn is an ordinary `rotate_view`: the map switches at once, and Touch Controls ends any active drag (GDD edge case).
- Mode, invert and sensitivity are player settings (ADR-0013). The rig receives them as a `CameraPrefs` value object at `PlaySession.start` and on change. It never reads a settings autoload (testability).

### 4. Reduced motion (ACC-40, TR-game-feel-vfx-005)

- Setting `reduced_motion: &"system" | &"on" | &"off"`, default `&"system"` (decision sheet: follows the OS; ADR-0013 persists it).
- Effective value: `on` → true, `off` → false, `system` → `DisplayServer.accessibility_should_reduce_animation()`. It is read at boot and again on `NOTIFICATION_APPLICATION_FOCUS_IN`, because the player may change the OS setting while the game is in the background. It is published as one `MotionPrefs.reduced: bool` to the camera, VFX, HUD and movement.
- Camera effects: snap without the settle tween. Steps, corner shortcuts and drag release are instant cuts to the snap, and `view_changed` timing is unchanged. The free drag itself still follows the finger, because the player drives that motion. The shake emitter is off and the skit pcam tween time is 0. Fades still run, because they are not motion (GDD edge case).
- If verification 1 fails on Android, `system` behaves like `off` there, and the first-run picker (ACC-02) remains the way in.

### 5. Window, orientation and safe area

**Project settings** (`project.godot`):

| Setting | Value | Why |
|---|---|---|
| `display/window/stretch/mode` | `canvas_items` (already set) | UI scales crisply; the 3D view renders at native resolution |
| `display/window/stretch/aspect` | `expand` (already set) | No letterbox in either orientation; the extra space goes to the longer axis |
| `display/window/size/viewport_width` / `viewport_height` | `1170` / `1170` (square base) | The short side is 1 170 canvas units in both orientations (reference phone 2532 × 1170), so one UI scale serves both; starting default |
| `display/window/stretch/scale_mode` | `fractional` (engine default) | PC windows of any size |
| `display/window/handheld/orientation` | `SCREEN_SENSOR` | Both orientations by default (ACC-70) |
| `display/window/size/resizable` | `true` (engine default) | PC |
| Android export preset | immersive mode on | Hides the system bars; the safe area still applies (verification 2) |

**`ScreenLayout`** (Node under `Main`, `PROCESS_MODE_ALWAYS`, `src/game/screen_layout.gd`) is the single place that reads display geometry:

- It connects `get_viewport().size_changed` in `_ready()`. Changes are merged into one `_relayout()` per frame with `call_deferred` and a dirty flag, because one rotation or a PC window drag sends several signals (verification 5).
- `orientation = PORTRAIT if size.y > size.x else LANDSCAPE`. A square counts as landscape.
- **Safe insets.** On `OS.has_feature("mobile")` it takes `DisplayServer.get_display_safe_area()` (screen pixels), subtracts the window rect, and converts to canvas units with the viewport's final transform (`get_viewport().get_final_transform().affine_inverse()`). Then it adds `gesture_margin_dp` (knob, default 16 dp, converted with `DisplayServer.screen_get_scale()`) on the left, right and bottom edges for essential controls (ACC-72). On PC the insets are zero, because the desktop safe area describes the screen, not the window.
- `get_display_cutouts()` is used only by the debug overlay and by a layout assertion: the board rect never intersects a cutout. Safe insets are the authority.
- It emits `layout_changed(orientation, safe_insets: Rect2, viewport_size: Vector2)`. ADR-0016 screens apply the insets as root margins and swap the portrait and landscape anchor presets (UX P7). The HUD returns the board rect for the current orientation, which the rig turns into ortho size and offsets.
- **Flip during Play:** when `orientation` changes and `PlaySession` is in a sim phase, `ScreenLayout` calls `AppFlow.request_pause(&"rotate")` **before** emitting `layout_changed`. The rig finishes any running turn instantly (§7), and then the layout, controls and framing are recomputed. `k` is kept (TR-camera-rotate-view-006). During `RESULTS` or in menus it only re-lays out. A resize that does not flip (PC drag, foldable) reframes live and does not pause.
- **Orientation lock** (ACC-71, setting Auto / Portrait / Landscape) → `DisplayServer.screen_set_orientation(SCREEN_SENSOR / SCREEN_SENSOR_PORTRAIT / SCREEN_SENSOR_LANDSCAPE)` at boot and on change. A shared-tablet versus session forces `SCREEN_SENSOR_LANDSCAPE` and restores the setting afterwards (TR-local-multiplayer-setup-007).

**PC window:** `get_window().min_size` is set at boot to `pc_min_window` (knob, default 960 × 540 px), the smallest size at which the board still passes the 20 px cube floor and the HUD fits at 100% scale. Fullscreen / windowed (F11, Alt+Enter, settings) uses `DisplayServer.window_set_mode`. Each size change reframes immediately. A tall, narrow PC window gets the portrait layout, under the same rule as phones.

### 6. The camera never affects the sim (ADR-0001)

- Input turns screen directions into **world** directions with the map that is current when the command is built, and sends world-space `SimCommand`s. The sim and replays never see the camera.
- When gameplay does depend on the snap (SE05 angle gems, TR-mechanics-module-012), the controller sends `SimCommand(&"view_snap", {k})` on every `view_changed` during Play, that is, on each settle and never during a free drag. The sim keeps its own `view_k`, and the replay records it like any other input. The sim never reads `ViewSnap` or the rig.
- Gravity changes flow from the sim to the view (`SimEvent`). The rig reacts by narrowing `allowed` and, if needed, turning. It never sends gravity back.
- Shake and punch offset only the rendered camera. They never move `YawPivot`, change `k` or alter framing (GDD AC 4, 25).
- Nothing in `src/core/` may import anything from `src/view/camera/`. The layering test enforces this.

### 7. Pause and freeze

- The rig is `PROCESS_MODE_PAUSABLE`, so tweens, noise and phantom stop with `SceneTree.paused` (ADR-0010).
- `PlaySession` calls `rig.freeze()` from its pause handler before the tree pauses. `freeze()` kills the turn tween, sets `YawPivot` to the target yaw and stops the shake (GDD AC 15). While frozen, `rotate_view` and orbit input are ignored. `unfreeze()` runs on resume and on the next level's Framing.

### Key Interfaces

```gdscript
# src/view/camera
class_name ViewSnap extends RefCounted          ## pure; unit-tested
func _init(yaw_offset_deg: float = 45.0) -> void
var k: int                                      ## 0..11
func step(dir: int) -> int                      ## next allowed snap; returns new k
func set_allowed_for_down_axis(down: Vector3i, side_on_min_deg: float) -> void
func nearest_allowed() -> int
func yaw_deg() -> float                         ## F1
func direction_map() -> Dictionary              ## {&"left": Vector3i, &"right", &"up", &"down"}; F3 + tie rule

class_name OrthoFraming extends RefCounted      ## static, pure
static func ortho_h(footprint: Vector2i, board_height: int, elev_deg: float, margin: float, rect_aspect: float) -> float
static func cube_edge_px(ortho_h: float, elev_deg: float, rect_h_px: float) -> float

class_name BoardCameraRig extends Node3D
signal view_changed(k: int, map: Dictionary)
func setup(board: BoardDims, level_pose: CameraPose, prefs: CameraPrefs, motion: MotionPrefs) -> void
func apply_board_rect(rect_px: Rect2, viewport_px: Vector2) -> void   ## size + h/v offset
func rotate_view(dir: int) -> void
func snap_to_corner(corner: int) -> void                              ## 0..3 → k = 0, 3, 6, 9
func orbit_drag(delta_px: float) -> void                              ## free yaw; k unchanged
func orbit_release() -> void                                          ## k = nearest allowed; view_changed; settle
func on_down_axis_changed(down: Vector3i) -> void
func on_ghost_changed(ghost_cells: PackedVector3Array) -> void        ## Auto mode only
func shake(strength: float, duration_ms: int) -> void                 ## no-op under reduced motion
func freeze() -> void
func unfreeze() -> void
func forward_board_space() -> Vector3                                 ## for OcclusionAid (ADR-0007)

# src/game
class_name ScreenLayout extends Node
enum Orientation { LANDSCAPE, PORTRAIT }
signal layout_changed(orientation: int, safe_insets: Rect2, viewport_size: Vector2)
func current_orientation() -> int
func safe_insets() -> Rect2                    ## canvas units; position = left/top, size = right/bottom margins
func apply_orientation_lock(lock: StringName) -> void   ## &"auto" | &"portrait" | &"landscape"

class_name MotionPrefs extends RefCounted
var reduced: bool
static func resolve(setting: StringName) -> MotionPrefs  ## &"system" | &"on" | &"off"
```

### Implementation Guidelines

- `view_changed` must be emitted before the tween starts, in the same frame as the press.
- The sim must never read the rig, `ViewSnap` or `ScreenLayout`. The snap reaches the sim only as `view_snap`.
- Never zoom or change elevation in play. Only `apply_board_rect` changes `size` and the offsets, and only on load or on a layout change.
- Shake must use `positional_noise` only. `rotational_noise` stays `false`.
- `ScreenLayout` is the only reader of `get_display_safe_area`, `get_display_cutouts` and `screen_set_orientation`. Screens use its signal and never call `DisplayServer` themselves.
- Every pause caused by rotation goes through `AppFlow.request_pause(&"rotate")`.
- Never connect `size_changed` outside `_ready()`. Merge changes into one relayout per frame.
- Knobs (`turn_anim_ms`, `settle_ms`, `orbit_px_per_step` default, `gesture_margin_dp`, `pc_min_window`, `cam_distance`, `side_on_min_deg`) go into `assets/data/knobs/*.json` (ADR-0004). Player choices (camera mode, invert, sensitivity, reduced motion, orientation lock) go into settings (ADR-0013).

## Alternatives Considered

### Alternative 1: 12 PhantomCamera3D nodes, one per snap, switched by priority
- **Pros**: Pure phantom usage; the tween is configured in the inspector.
- **Cons**: Phantom tweens interpolate position along a chord, not around the orbit. Retargeting mid-tween fights the host's tween state. 12 pcams per board, twice for split-screen.
- **Rejection Reason**: The pivot tween is simpler and gives an exact arc and free retargeting.

### Alternative 2: Plain `Camera3D` without phantom_camera
- **Pros**: No addon, no extra autoload, nothing to check for compatibility.
- **Cons**: Shake noise, skit camera handoffs and per-board host layers would all have to be written by hand.
- **Rejection Reason**: The user chose phantom_camera. It is kept thin, so this alternative is also the fallback if verification 6 fails: the pivot, `ViewSnap` and `OrthoFraming` are unchanged.

### Alternative 3: Render the board into a SubViewport sized to the board rect
- **Pros**: The framing math matches the rect exactly. It is easy to split.
- **Cons**: An extra render target and copy on mobile. MSAA and outline settings are duplicated per viewport.
- **Rejection Reason**: The lens `size` and `h_offset`/`v_offset` give the same result for free. Split-screen can still choose a SubViewport (ADR-0009).

### Alternative 4: Lock orientation per platform (landscape only)
- **Rejection Reason**: Contradicts ACC-70 and the user's decision on both orientations.

### Alternative 5: Read the animated yaw for input mapping
- **Rejection Reason**: The mapping would lag the turn by up to 150 ms and differ between frames. GDD rule 6 requires it to be logically instant.

## Consequences

### Positive
- The direction map is a pure function of `k`, unit-tested and the same on every device.
- The camera cannot desync a replay or a versus match: gameplay sees only commands.
- There is one place for display geometry. Screens, HUD and camera agree on orientation and insets.
- PC and phone share one layout rule: the aspect decides, not the platform.

### Negative
- phantom_camera adds an autoload, `PhantomCameraManager`, and a host `_process` per board, and nobody has stated that it supports 4.7.
- Two signals (`layout_changed`, then the board rect from the HUD) must arrive in order before the rig reframes. A wrong order shows one badly framed frame (mitigated: the rig reframes on the board-rect callback only).
- `view_snap` adds one command kind to `BoardSim` (ADR-0001 interface) for snap-dependent mechanics.

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| `accessibility_should_reduce_animation()` ignores Android "Remove animations" | Medium | Medium | Verification 1; the in-game toggle plus the first-run offer (ACC-02) |
| Android safe area misses gesture strips | Medium | Medium | `gesture_margin_dp` knob; device test with gesture nav (ACC-72) |
| One rotation sends several `size_changed` signals, causing a double pause or relayout | Medium | Low | Merged deferred relayout; pause only when `orientation` flips; `request_pause` is idempotent while paused |
| phantom_camera breaks on a Godot point release | Medium | Medium | Thin usage; Alternative 2 is a mechanical swap |
| A PC window made very narrow falls under the 20 px cube floor | Low | Low | `pc_min_window`; the layout reflows to portrait |
| An Auto mode turn surprises players | Low | Medium | At most one per piece, only on the two triggers, never during a drag; Auto is opt-in |

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| camera-rotate-view.md (TR-camera-rotate-view-001) | One ortho size per level and orientation, fits all 12 yaws, recomputed on orientation change | `OrthoFraming` (F2) + `apply_board_rect` on every `layout_changed` |
| camera-rotate-view.md (TR-camera-rotate-view-002) | Yaw plus screen→world map, switched instantly while the turn animates | `ViewSnap`; `view_changed` before the tween |
| camera-rotate-view.md (TR-camera-rotate-view-006) | Turning mid-level pauses, re-lays out, reframes, keeps `k` | `ScreenLayout` → `request_pause(&"rotate")` → relayout; `ViewSnap.k` untouched |
| camera-rotate-view.md (TR-camera-rotate-view-003/-004/-005) | Occlusion aid | Owned by ADR-0007; this ADR supplies `forward_board_space()` and `view_changed` |
| camera-rotate-view.md rules 6–9a, edge cases, AC 10–16, 20a, 25–26 | Retarget, hold-repeat, orbit snap, side-on snaps, pause completes the turn, reduced motion | §2, §3, §4, §7 |
| level-specific-mechanics.md (TR-level-specific-mechanics-007) | Sideways down axis restricts snaps | `ViewSnap.set_allowed_for_down_axis` |
| movement-rotation.md (TR-movement-rotation-003) | View-relative spin/tilt/roll mapping from the camera snap | `direction_map()` from `k`; input builds world-space commands |
| mechanics-module.md (TR-mechanics-module-012) | Gameplay depends on the camera snap | `SimCommand(&"view_snap")`, recorded in the replay |
| hud.md (TR-hud-002) | Preview from the current yaw, re-rendered within one frame | `view_changed(k, …)` |
| hud.md (TR-hud-003) | Safe-area layout; never overlaps the board rect | `ScreenLayout.safe_insets()`; the board rect is outside the HUD; cutout assertion |
| game-feel-vfx.md (TR-game-feel-vfx-004) | Translation-only camera shake | `PhantomCameraNoiseEmitter3D` with positional noise only |
| game-feel-vfx.md (TR-game-feel-vfx-005) | One global reduced-motion flag; timing unchanged | `MotionPrefs`; turn time 0, `k` timing unchanged |
| touch-controls.md (TR-touch-controls-007) | Reduced-motion setting persists | The setting is defined here (`system`/`on`/`off`); ADR-0013 persists it |
| local-multiplayer-setup.md (TR-local-multiplayer-setup-007) | Per-board cameras; shared-tablet landscape lock | One rig per board on its own `host_layers`; forced `SCREEN_SENSOR_LANDSCAPE` |
| accessibility-requirements.md ACC-20, 21, 22, 23 (no TR ids yet) | Camera modes incl. Auto; invert; orbit sensitivity | §3 |
| accessibility-requirements.md ACC-40, 42 (no TR ids yet) | Reduced motion follows the OS; no camera moves in skits | §4; skit pcam tween 0 |
| accessibility-requirements.md ACC-70, 71, 72 (no TR ids yet) | Both orientations; orientation lock; safe area and gesture strip | §5 |
| ux/interaction-patterns.md P7 | Layout switches on `size_changed`; safe area applied as root margins | `ScreenLayout.layout_changed`; screens apply the insets (ADR-0016) |

## Performance Implications
- **CPU**: idle rig ≈ phantom host `_process` only. A turn is one tween. Auto mode's ghost check reuses ADR-0007's DDA (≤ 0.5 ms) only when the ghost changes. Relayout runs at most once per frame, and only on resize.
- **GPU**: no extra viewport. Framing uses the lens.
- **Memory**: negligible (one rig per board).
- **Load Time**: framing is computed at level load, in microseconds.

## Migration Plan

No camera code exists yet beyond the first-playable prototype. Changes to existing files (not made by this ADR):
- `project.godot`: `viewport_width`/`viewport_height` = 1170/1170, `display/window/handheld/orientation = SCREEN_SENSOR`. The stretch mode and aspect are already correct.
- Android export preset: immersive mode on. The orientation comes from the project setting.
- `docs/architecture/tr-registry.yaml`: point TR-camera-rotate-view-001/-002/-006, TR-hud-003 and TR-game-feel-vfx-004 at ADR-0014. Append TR ids for ACC-20–23, 40, 70–72. Align `side_view_min_deg` → `side_on_min_deg` in TR-level-specific-mechanics-007.
- ADR-0001 interface: add the `&"view_snap"` command kind (only when the first snap-dependent mechanic lands).
- ADR-0010: `PlaySession`'s pause handler calls `rig.freeze()` before `tree.paused`. `request_pause` must be a no-op when already paused.
- `architecture.md` §3: add ADR-0014.
- `design/gdd/camera-rotate-view.md` (owner: GDD author): rule 8 and AC 14 change from "drag orbit, off by default" to free orbit + snap, always on; add corner shortcuts and `settle_ms`.

**Rollback plan**: drop phantom_camera (Alternative 2). Put a plain `Camera3D` on `CameraAnchor` and do shake with a translation tween. `ViewSnap`, `OrthoFraming` and `ScreenLayout` are unchanged.

## Validation Criteria

- [ ] [U] `ViewSnap`: F1 yaws for k = 0, 4, 11 (45°, 165°, 15°); `step` wraps mod 12; down axis −x visits only the 8 side-on snaps; `nearest_allowed` from a disallowed snap (GDD AC 2, 3, 10, 20a).
- [ ] [U] `ViewSnap.direction_map`: four distinct world directions at every yaw; yaw 75° → right = +x; corner tie rule at k = 0, 3, 6, 9 (GDD AC 17–19).
- [ ] [U] `OrthoFraming`: 8 × 8 × 16, elev 30°, margin 0.5 → W_screen ≈ 11.3, `ortho_h` 20.0–20.5; cube edge for the landscape and portrait profiles (GDD AC 5).
- [ ] [U] `MotionPrefs.resolve`: `on`/`off` ignore the OS; `system` follows an injected OS reader.
- [ ] [I] `BoardCameraRig` headless: `view_changed` fires in the same frame as `rotate_view`; a press in the opposite direction mid-turn retargets with no skipped step; `freeze()` mid-turn lands on the target yaw; under reduced motion the pivot reaches the target in the same frame (GDD AC 11, 12, 15, 26).
- [ ] [I] Free orbit: during a drag `view_changed` and `view_snap` never fire and the map stays on the start snap; on release they fire exactly once with the nearest allowed snap; under reduced motion the pivot is on the snap in the release frame. Each corner shortcut lands on k = 0/3/6/9 (or the nearest allowed snap).
- [ ] [I] Sampled every frame during turns and shakes, elevation, `size` and `YawPivot` are unchanged by shake; shake offsets are translation only (GDD AC 4, 25).
- [ ] [I] Replay of a recorded session with view turns gives an identical board hash whether the rig exists or not (camera never affects the sim).
- [ ] [I] `ScreenLayout`: a simulated 2532 × 1170 → 1170 × 2532 resize during Play calls `request_pause(&"rotate")` once, emits `layout_changed` once, and keeps `k` (GDD AC 20b). The same resize in a menu does not pause.
- [ ] [M] Reference phone with gesture navigation: every Meadow screen in both orientations has no control inside the safe-area insets or gesture margin; screenshots of each in `production/qa/evidence/` (ACC-70, 72).
- [ ] [M] Android "Remove animations" on, setting `system`: view turns are instant cuts and there is no shake (verification 1).
- [ ] [M] Orientation lock Portrait: physically turning the phone does nothing (ACC-71).
- [ ] [M] PC: resizing the window from 1920 × 1080 down to the minimum and to a tall, narrow shape keeps the whole board in frame at all allowed snaps; the narrow shape uses the portrait layout; screenshots retained.
- [ ] [M] Auto mode: a stack that hides the ghost turns the camera once to a snap where the ghost is visible, and no more than once per piece (ACC-21).

## Related
- ADR-0001 (depends on: commands only; `view_snap` addition), ADR-0004 (knobs), ADR-0007 (occlusion consumes the camera forward vector; outline width from ortho size), ADR-0009 (one rig per board, landscape lock), ADR-0010 (rotate pause, `SceneTree.paused`), ADR-0012 (input reads `view_changed`), ADR-0013 (camera and motion settings), ADR-0016 (screens apply insets and P/L presets; HUD board rect)
- `design/gdd/camera-rotate-view.md`, `design/accessibility-requirements.md` §3, §5, §8, `design/gdd/ux/interaction-patterns.md` P7, `design/gdd/board-grid.md` F5
- `addons/phantom_camera/` (0.11.0.3)
