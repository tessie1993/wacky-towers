class_name WtTitleIsland extends SubViewportContainer
## Title-screen diorama: the real floating island (WtIslandBuilder: slab, strata, hanging
## dressing, rim props, empty 8x8 stone grid) lit by the cookbook rig and AgX preset
## (design/art/style-techniques.md §2), on a transparent background, turning slowly.

## Biome look used for the island.
@export var biome: StringName = &"meadow"
## Degrees per second of the idle turn (0 when reduced motion is on).
@export var turn_speed: float = 6.0

var _pivot: Node3D


func _ready() -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var viewport := SubViewport.new()
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_2X
	add_child(viewport)
	_pivot = Node3D.new()
	viewport.add_child(_pivot)
	var board := Vector3i(8, 1, 8)
	var builder := WtIslandBuilder.new(biome)
	builder.motion = 0.0 if turn_speed == 0.0 else 1.0
	builder.build_island(_pivot, board, func(_x: int, _z: int) -> bool: return true)
	builder.build_dressing(_pivot, board)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 19.0
	camera.position = Vector3(20, 15, 20)
	viewport.add_child(camera)
	camera.look_at(Vector3(0, -2.4, 0), Vector3.UP)
	# Rig is fixed to the camera (yaw 45), so the light stays upper-left while the island turns.
	builder.add_light_rig(viewport, 45.0)
	var environment := builder.make_environment()
	environment.background_mode = Environment.BG_CLEAR_COLOR
	var world := WorldEnvironment.new()
	world.environment = environment
	viewport.add_child(world)
	_pivot.rotation_degrees.y = 0.0


func _process(delta: float) -> void:
	if _pivot != null:
		_pivot.rotation_degrees.y += turn_speed * delta
		# Tall rim props only on the far sides (relative to the fixed camera at yaw 45).
		WtIslandBuilder.update_facing(_pivot, 45.0 - _pivot.rotation_degrees.y)
