# CH-023 CameraMath: yaw, screen-to-world mapping, tilt/roll axes

**Story:** VEW-004
**Goal:** pure integer math for the 12 view snaps and which world direction each screen direction means (Camera GDD rules 2, 10, 11, F1, F3; Movement & Rotation rule 9).
**Depends:** none
**Parallel-safe with:** every batch-2 ticket except CH-024, CH-025
**Files:** `src/view/camera_math.gd` (new), `tests/unit/view/camera_math_test.gd` (new)

## API (implementation-plan §1.2)

```gdscript
class_name CameraMath extends RefCounted
## Pure camera math: 12 yaw snaps, screen->world direction map, view-relative rotation axes (Camera GDD F1, F3).

const STEPS := 12                    # Camera GDD rule 2
const DEFAULT_BASE_DEG := 45         # Camera GDD F1 yaw_offset default (corner views at k = 0, 3, 6, 9)
const DEFAULT_STEP_DEG := 30

static func yaw_degrees(k: int, base_deg: int, step_deg: int) -> float
	## (base + step * posmod(k, 12)) mod 360, e.g. k = 4 -> 165.0
static func screen_dir_to_world(k: int, screen_dir: Vector2i, base_deg: int, step_deg: int) -> Vector3i
	## screen_dir in screen pixels (y down): (1,0) right, (-1,0) left, (0,-1) up, (0,1) down. Returns ±x or ±z; ZERO for any other input.
static func view_axes(k: int, base_deg: int, step_deg: int) -> Dictionary
	## {"tilt": world dir that appears screen-right, "roll": world dir that appears screen-up}
```

## The convention (contract — CameraRig CH-025 places the camera to match it)

At yaw θ the camera's screen-right vector on the ground is `R = (sin θ, 0, cos θ)` and screen-up (away from the viewer)
is `F = (cos θ, 0, −sin θ)`. So a ground direction's on-screen angle (degrees, counter-clockwise from screen-right,
screen-up = +90) is an **integer**:

| world dir | angle |
|---|---|
| +x | 90 − θ |
| −z | 180 − θ |
| −x | 270 − θ |
| +z | −θ |

(all `posmod(…, 360)`). Screen directions sit at right 0, up 90, left 180, down 270. A world dir belongs to screen dir `c`
when `d = posmod(angle − c, 360)` satisfies `d <= 45 or d > 315` — the half-open sector `(c − 45, c + 45]`.
This makes every mapping one-to-one and reproduces the corner tie rule (GDD rule 11: right = up-right, left = down-left,
up = up-left, down = down-right) with no float compare. Elevation is ignored on purpose: the vertical squash does
not change any assignment for the 12 snaps, and ignoring it keeps ties exact.

## Tests to write first

Let `RIGHT = [+x, −z, −x, +z]`, `UP = [−z, −x, +z, +x]` (as Vector3i), base 45, step 30.
1. `test_yaw_degrees` — k 0 -> 45.0, k 4 -> 165.0 (GDD F1 example), k 11 -> 15.0, k 12 -> 45.0, k −1 -> 15.0.
2. `test_mapping_all_12_snaps` — for k in 0..11: right == `RIGHT[k / 3]`, up == `UP[k / 3]`, left == −right, down == −up.
3. `test_yaw_75_right_is_plus_x` — GDD F3 example: k 1 -> right `+x`.
4. `test_corner_tie_rule_k0` — k 0: right `+x` (appears up-right), left `−x`, up `−z`, down `+z`.
5. `test_mapping_is_one_to_one` — for every k the 4 results are distinct and none is ZERO.
6. `test_bad_screen_dir_is_zero` — `(0,0)`, `(1,1)`, `(2,0)` -> `Vector3i.ZERO`.
7. `test_view_axes` — k 1 (yaw 75°): tilt `+x`, roll `−z` (Movement & Rotation AC 12a: tilt on x, roll on z); k 3: tilt `−z`, roll `−x`.

## Run
`-a res://tests/unit/view` (README).

## Done when
README "Done when" + 7 tests green. No Node, no float trig in the mapping.
