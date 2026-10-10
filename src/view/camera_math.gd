class_name CameraMath extends RefCounted
## Pure camera math: 12 yaw snaps, screen->world direction map, view-relative rotation axes (Camera GDD F1, F3).

const STEPS := 12                    # Camera GDD rule 2
const DEFAULT_BASE_DEG := 45         # Camera GDD F1 yaw_offset default (corner views at k = 0, 3, 6, 9)
const DEFAULT_STEP_DEG := 30
const FULL_TURN := 360
const SECTOR_HALF := 45              # Camera GDD rule 11: sector (c - 45, c + 45]

## World directions with their on-screen angle offset: angle = offset - yaw (CH-023 convention).
const _WORLD_DIRS: Array[Vector3i] = [Vector3i(1, 0, 0), Vector3i(0, 0, -1), Vector3i(-1, 0, 0), Vector3i(0, 0, 1)]
const _ANGLE_OFFSETS: Array[int] = [90, 180, 270, 0]


static func _yaw_int(k: int, base_deg: int, step_deg: int) -> int:
	return posmod(base_deg + step_deg * posmod(k, STEPS), FULL_TURN)


## Yaw in degrees for snap k (wraps mod 12). Usage: yaw_degrees(4, 45, 30) -> 165.0
static func yaw_degrees(k: int, base_deg: int, step_deg: int) -> float:
	return float(_yaw_int(k, base_deg, step_deg))


## World direction (+-x or +-z) that screen_dir (pixels, y down) means at snap k; ZERO for non-cardinal input.
## Usage: screen_dir_to_world(1, Vector2i(1, 0), 45, 30) -> Vector3i(1, 0, 0)
static func screen_dir_to_world(k: int, screen_dir: Vector2i, base_deg: int, step_deg: int) -> Vector3i:
	var c: int
	match screen_dir:
		Vector2i(1, 0): c = 0
		Vector2i(0, -1): c = 90
		Vector2i(-1, 0): c = 180
		Vector2i(0, 1): c = 270
		_: return Vector3i.ZERO
	var yaw: int = _yaw_int(k, base_deg, step_deg)
	for i in range(_WORLD_DIRS.size()):
		var d: int = posmod(_ANGLE_OFFSETS[i] - yaw - c, FULL_TURN)
		if d <= SECTOR_HALF or d > FULL_TURN - SECTOR_HALF:
			return _WORLD_DIRS[i]
	return Vector3i.ZERO


## {"tilt": world dir that appears screen-right, "roll": world dir that appears screen-up}.
## Usage: view_axes(1, 45, 30)["tilt"] -> Vector3i(1, 0, 0)
static func view_axes(k: int, base_deg: int, step_deg: int) -> Dictionary:
	return {
		"tilt": screen_dir_to_world(k, Vector2i(1, 0), base_deg, step_deg),
		"roll": screen_dir_to_world(k, Vector2i(0, -1), base_deg, step_deg),
	}


## Camera3D.size (vertical extent, KEEP_HEIGHT) that fits the whole board at every one of the 12 yaws (Camera GDD F2).
## board_size = (W, board_height, D); aspect = board screen area width / height (must be > 0); margin in cells.
## Usage: ortho_size(Vector3i(6, 14, 6), 30.0, 1.69, 0.5) -> ~16.87
static func ortho_size(board_size: Vector3i, elevation_deg: float, aspect: float, margin: float) -> float:
	var ws: float = 0.0
	for k in range(STEPS):
		var yaw: float = deg_to_rad(yaw_degrees(k, DEFAULT_BASE_DEG, DEFAULT_STEP_DEG))
		ws = maxf(ws, board_size.x * absf(cos(yaw)) + board_size.z * absf(sin(yaw)))
	var elev: float = deg_to_rad(elevation_deg)
	var hs: float = ws * sin(elev) + board_size.y * cos(elev)
	return maxf(hs + margin, (ws + margin) / aspect)
