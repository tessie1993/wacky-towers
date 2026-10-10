class_name CameraRig extends Node3D
## Orthographic diorama camera: 12 yaw snaps around the board centre (Camera GDD). Math lives in CameraMath.
signal yaw_changed(k: int)

const YAW_TO_ROT_DEG := 90.0  # rotation.y = yaw - 90 puts camera basis.x at (sin t, 0, cos t) (CH-023 R vector)

@export var base_deg: int = CameraMath.DEFAULT_BASE_DEG   # values come from knobs/view.json at APP-001
@export var step_deg: int = CameraMath.DEFAULT_STEP_DEG
@export var elevation_deg: float = 30.0                    # Camera GDD F2 default
@export var margin: float = 0.5                            # Camera GDD F2 default
@export var turn_anim_ms: int = 150                        # Camera GDD F4 default; 0 = instant cut
@export var distance: float = 100.0                        # camera stand-off; orthographic, so only clipping depends on it

var _k: int = 0
var _tween: Tween
@onready var _pcam: PhantomCamera3D = $PhantomCamera


func _ready() -> void:
	var res := Camera3DResource.new()
	res.projection = Camera3DResource.ProjectionType.ORTHOGONAL
	_pcam.camera_3d_resource = res
	_place_camera()
	rotation.y = _target_rot()


## Frames the whole board for every yaw: centres the rig, sizes the ortho camera. Usage: rig.frame_board(Vector3i(6, 14, 6))
func frame_board(board_size: Vector3i) -> void:
	position = Vector3(board_size) * 0.5
	var vs: Vector2 = get_viewport().get_visible_rect().size
	var cam: Camera3D = $Camera
	cam.size = CameraMath.ortho_size(board_size, elevation_deg, vs.x / vs.y, margin)
	_pcam.size = cam.size  # the host copies the pcam's resource onto the Camera3D
	_place_camera()


## Turns the view by step (+-1) snaps; mapping changes at once, the picture tweens. Usage: rig.rotate_view(1)
func rotate_view(step: int) -> void:
	# TODO(VEW-004 rule 9a): skip non-side-on snaps when the down axis is ±x/±z
	_k = posmod(_k + step, CameraMath.STEPS)
	yaw_changed.emit(_k)
	if _tween:
		_tween.kill()
	var target: float = _target_rot()
	if turn_anim_ms <= 0:
		rotation.y = target
		return
	target = rotation.y + wrapf(target - rotation.y, -PI, PI)
	_tween = create_tween()
	_tween.tween_property(self, "rotation:y", target, turn_anim_ms / 1000.0)


## Current logical yaw snap 0..11. Usage: rig.get_yaw_index()
func get_yaw_index() -> int:
	return _k


## World axis a screen direction means at the current snap. Usage: rig.screen_dir_to_world(Vector2i(1, 0))
func screen_dir_to_world(screen_dir: Vector2i) -> Vector3i:
	return CameraMath.screen_dir_to_world(_k, screen_dir, base_deg, step_deg)


## World axis for a rotation gesture: &"spin" -> up, &"tilt"/&"roll" view-relative, else ZERO. Usage: rig.world_axis_for(&"tilt")
func world_axis_for(screen_axis: StringName) -> Vector3i:
	if screen_axis == &"spin":
		return Vector3i(0, 1, 0)
	return CameraMath.view_axes(_k, base_deg, step_deg).get(String(screen_axis), Vector3i.ZERO)


func _target_rot() -> float:
	return deg_to_rad(CameraMath.yaw_degrees(_k, base_deg, step_deg) - YAW_TO_ROT_DEG)


func _place_camera() -> void:
	var e: float = deg_to_rad(elevation_deg)
	_pcam.position = Vector3(0, distance * sin(e), distance * cos(e))
	_pcam.rotation = Vector3(-e, 0, 0)
	_pcam.near = 0.05
	_pcam.far = 2.0 * distance
