class_name WtTrackFollower extends Node3D
## View component for the moving platform (gap G8): placeholder plank track plus event posts that scroll past a
## board which stays at the origin, so the existing camera "follows" with no camera change. Art comes later.
## It reads TrackDef and a progress value; it never touches the sim. Usage: f.setup(def); f.set_progress(mm).

const PLANK_WIDTH := 3.0
const PLANK_THICK := 0.12
const POST_SIZE := Vector3(0.4, 1.2, 0.4)
const POST_COLOURS: Dictionary = {
	&"bump": Color(0.85, 0.6, 0.3), &"cloud_bump": Color(0.9, 0.9, 1.0), &"arch": Color(0.3, 0.7, 0.35),
	&"crosswind": Color(0.6, 0.85, 1.0), &"updraft": Color(1.0, 0.95, 0.5)}
const CHECKPOINT_COLOUR := Color(0.95, 0.3, 0.4)
const PLANK_COLOUR := Color(0.62, 0.45, 0.28)

var _def: TrackDef
var _mm: int = 0


## Builds the placeholder geometry from the track. `def` must be valid.
func setup(def: TrackDef) -> void:
	assert(def != null and def.is_valid(), "WtTrackFollower needs a valid TrackDef")
	_def = def
	for child: Node in get_children():
		child.queue_free()
	_build_planks()
	for e: Dictionary in def.events:
		_post(def.path_point(int(e["at_mm"])), POST_COLOURS.get(e["kind"], Color.WHITE))
	for cp: Dictionary in def.checkpoints:
		_post(def.path_point(int(cp["at_mm"])), CHECKPOINT_COLOUR)
	set_progress(0)


## Moves the track under the board for platform distance `mm` and turns it to the path heading.
func set_progress(mm: int) -> void:
	_mm = mm
	var heading: Vector3 = _def.path_heading(mm)
	var yaw: float = atan2(heading.x, -heading.z)
	var basis := Basis(Vector3.UP, -yaw)
	transform = Transform3D(basis, -(basis * _def.path_point(mm)))


## Last distance given to set_progress.
func progress_mm() -> int:
	return _mm


func _build_planks() -> void:
	for i: int in range(1, _def.path.size()):
		var a: Vector3 = _def.path[i - 1]
		var b: Vector3 = _def.path[i]
		var mesh := BoxMesh.new()
		mesh.size = Vector3(PLANK_WIDTH, PLANK_THICK, a.distance_to(b))
		var node := MeshInstance3D.new()
		node.mesh = mesh
		node.material_override = _material(PLANK_COLOUR)
		add_child(node)
		node.position = (a + b) * 0.5 - Vector3(0, PLANK_THICK * 0.5, 0)
		if a != b:
			node.look_at(b + Vector3(0, -PLANK_THICK * 0.5, 0), Vector3.UP)


func _post(at: Vector3, colour: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = POST_SIZE
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = _material(colour)
	add_child(node)
	node.position = at + Vector3(PLANK_WIDTH * 0.5 + 0.4, POST_SIZE.y * 0.5, 0)


func _material(colour: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = colour
	return m
