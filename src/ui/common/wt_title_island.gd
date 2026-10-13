class_name WtTitleIsland extends SubViewportContainer
## Title-screen diorama: the real floating meadow island (WtIslandBuilder) with an
## empty 8x8 stone grid, rendered on a transparent background and turning slowly.

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
	builder.build_island(_pivot, board, func(_x: int, _z: int) -> bool: return true)
	builder.build_dressing(_pivot, board)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 17.0
	camera.position = Vector3(20, 15, 20)
	viewport.add_child(camera)
	camera.look_at(Vector3(0, -1.6, 0), Vector3.UP)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-50, -35, 0)
	key.light_energy = 0.95
	key.light_color = Color("fff4dc")
	viewport.add_child(key)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_CLEAR_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("ece4ff")
	environment.ambient_light_energy = 0.5
	var world := WorldEnvironment.new()
	world.environment = environment
	viewport.add_child(world)
	_pivot.rotation_degrees.y = 45.0


func _process(delta: float) -> void:
	if _pivot != null:
		_pivot.rotation_degrees.y += turn_speed * delta
