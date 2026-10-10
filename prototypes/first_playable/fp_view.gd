class_name FpView extends Node3D
## First-playable 3D view: slate floor + grid, back-wall column guides, light, ortho camera,
## MultiMesh cubes with dark outlines, ghost and landing-column marks.

const CUBE_GLB: String = "res://assets/models/blocks/candy_toy/blk_candy_toy_cube.glb"
const ELEVATION_DEG: float = 35.0
const MARGIN: float = 1.0
const CAM_DISTANCE: float = 60.0
## Saturated, distinct hues per shape colour index (i, o, t, l, s).
const PALETTE: Array[Color] = [
	Color(0.10, 0.70, 0.92), # i - cyan
	Color(0.98, 0.78, 0.08), # o - yellow
	Color(0.62, 0.36, 0.86), # t - purple
	Color(0.96, 0.46, 0.12), # l - orange
	Color(0.24, 0.78, 0.34), # s - green
]
const SETTLED_SHADE: float = 0.78         # settled blocks darker than the active piece
const GHOST_ALPHA: float = 0.35
const OUTLINE_GROW: float = 0.035
const OUTLINE_COLOUR: Color = Color(0.10, 0.12, 0.17)
const FLOOR_COLOUR: Color = Color(0.231, 0.290, 0.353)   # #3B4A5A slate
const GRID_COLOUR: Color = Color(0.80, 0.88, 0.95, 0.40)
const WALL_COLOUR: Color = Color(0.70, 0.80, 0.92, 0.10)
const WALL_LINE_COLOUR: Color = Color(0.85, 0.92, 1.0, 0.28)
const COLUMN_MARK_COLOUR: Color = Color(1.0, 1.0, 1.0, 0.30)

## Camera snap 0..3 (yaw = 45 + 90 * view_k degrees).
var view_k: int = 0

var _game: FpGame
var _camera: Camera3D
var _settled: MultiMeshInstance3D
var _active: MultiMeshInstance3D
var _ghost: MultiMeshInstance3D
var _marks: MultiMeshInstance3D
var _walls: Array[Node3D] = []
var _wall_normals: Array[Vector3] = []
var _cube_mesh: Mesh
var _cube_xform: Transform3D = Transform3D.IDENTITY
var _yaw_deg: float = 45.0
var _target_yaw_deg: float = 45.0
var _centre: Vector3 = Vector3.ZERO
var _tween: Tween


## Builds the whole scene for the given game and connects its changed signal.
func setup(game: FpGame) -> void:
	_game = game
	var size: Vector3i = game.board.size
	_centre = Vector3(0.0, size.y * 0.5, 0.0)
	_load_cube_mesh()
	_build_environment()
	_build_grid(size)
	_build_walls(size)
	_build_camera(size)
	_settled = _make_multimesh(_cube_mesh, false, true)
	_active = _make_multimesh(_cube_mesh, false, true)
	_ghost = _make_multimesh(_cube_mesh, true, true)
	var mark: PlaneMesh = PlaneMesh.new()
	mark.size = Vector2(0.86, 0.86)
	_marks = _make_multimesh(mark, true, false)
	_apply_camera()
	game.changed.connect(_redraw)
	_redraw()


## Rotates the view by 90 degrees (dir = +1 or -1) over 0.2 s.
func rotate_view(dir: int) -> void:
	if dir == 0:
		return
	var step: int = 1 if dir > 0 else -1
	view_k = posmod(view_k + step, 4)
	_target_yaw_deg += 90.0 * step
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_yaw, _yaw_deg, _target_yaw_deg, 0.2)


func _set_yaw(yaw: float) -> void:
	_yaw_deg = yaw
	_apply_camera()


func _apply_camera() -> void:
	if _camera == null:
		return
	_camera.rotation_degrees = Vector3(-ELEVATION_DEG, _yaw_deg, 0.0)
	_camera.position = _centre + _camera.basis * Vector3(0.0, 0.0, CAM_DISTANCE)
	# Show only the walls on the far side (outward normal pointing away from the camera).
	var to_cam: Vector3 = _camera.basis.z
	for i in range(_walls.size()):
		_walls[i].visible = _wall_normals[i].dot(to_cam) < 0.0


func _load_cube_mesh() -> void:
	var scene: PackedScene = load(CUBE_GLB) as PackedScene
	if scene != null:
		var root: Node = scene.instantiate()
		var mi: MeshInstance3D = _find_mesh_instance(root)
		if mi != null and mi.mesh != null:
			_cube_mesh = mi.mesh
		root.free()
	if _cube_mesh == null:
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3.ONE
		_cube_mesh = box
		return
	var aabb: AABB = _cube_mesh.get_aabb()
	var longest: float = maxf(aabb.size.x, maxf(aabb.size.y, aabb.size.z))
	var s: float = 1.0 / longest if longest > 0.0001 else 1.0
	# Scale to 1 unit and recentre on the origin so cell centres line up.
	_cube_xform = Transform3D(Basis.from_scale(Vector3(s, s, s)), -aabb.get_center() * s)


func _find_mesh_instance(n: Node) -> MeshInstance3D:
	if n is MeshInstance3D:
		return n as MeshInstance3D
	for child: Node in n.get_children():
		var found: MeshInstance3D = _find_mesh_instance(child)
		if found != null:
			return found
	return null


func _build_environment() -> void:
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.74, 0.88, 0.97)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.80, 0.86, 1.0)
	env.ambient_light_energy = 0.35
	var we: WorldEnvironment = WorldEnvironment.new()
	we.environment = env
	add_child(we)
	# Key light steep from above: tops bright, sides darker.
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-62.0, 25.0, 0.0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)


func _unshaded(colour: Color) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = colour
	if colour.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m


func _build_grid(size: Vector3i) -> void:
	var w: float = float(size.x)
	var d: float = float(size.z)
	var h: float = float(size.y)
	var x0: float = -w * 0.5
	var z0: float = -d * 0.5

	# Slate board floor just above the platform top (y = 0).
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(w, d)
	var floor_mat: StandardMaterial3D = StandardMaterial3D.new()
	floor_mat.albedo_color = FLOOR_COLOUR
	floor_mat.roughness = 1.0
	plane.material = floor_mat
	var floor_mi: MeshInstance3D = MeshInstance3D.new()
	floor_mi.mesh = plane
	floor_mi.position = Vector3(0.0, 0.002, 0.0)
	add_child(floor_mi)

	var im: ImmediateMesh = ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	for i in range(size.x + 1):
		im.surface_add_vertex(Vector3(x0 + i, 0.0, z0))
		im.surface_add_vertex(Vector3(x0 + i, 0.0, z0 + d))
	for j in range(size.z + 1):
		im.surface_add_vertex(Vector3(x0, 0.0, z0 + j))
		im.surface_add_vertex(Vector3(x0 + w, 0.0, z0 + j))
	im.surface_end()
	var lines: MeshInstance3D = MeshInstance3D.new()
	lines.mesh = im
	lines.material_override = _unshaded(GRID_COLOUR)
	lines.position = Vector3(0.0, 0.006, 0.0)
	add_child(lines)

	# Faint top rim so the board volume reads.
	var rim: ImmediateMesh = ImmediateMesh.new()
	rim.surface_begin(Mesh.PRIMITIVE_LINES)
	var corners: Array[Vector3] = [
		Vector3(x0, h, z0), Vector3(x0 + w, h, z0), Vector3(x0 + w, h, z0 + d), Vector3(x0, h, z0 + d),
	]
	for k in range(4):
		rim.surface_add_vertex(corners[k])
		rim.surface_add_vertex(corners[(k + 1) % 4])
	rim.surface_end()
	var rim_mi: MeshInstance3D = MeshInstance3D.new()
	rim_mi.mesh = rim
	rim_mi.material_override = _unshaded(WALL_LINE_COLOUR)
	add_child(rim_mi)


## Four translucent walls with vertical column lines; _apply_camera shows the two far ones.
func _build_walls(size: Vector3i) -> void:
	var w: float = float(size.x)
	var d: float = float(size.z)
	var h: float = float(size.y)
	# [normal, centre, plane size, column count, column axis]
	var specs: Array = [
		[Vector3(0, 0, -1), Vector3(0, h * 0.5, -d * 0.5), Vector2(w, h), size.x, Vector3(1, 0, 0)],
		[Vector3(0, 0, 1), Vector3(0, h * 0.5, d * 0.5), Vector2(w, h), size.x, Vector3(1, 0, 0)],
		[Vector3(-1, 0, 0), Vector3(-w * 0.5, h * 0.5, 0), Vector2(d, h), size.z, Vector3(0, 0, 1)],
		[Vector3(1, 0, 0), Vector3(w * 0.5, h * 0.5, 0), Vector2(d, h), size.z, Vector3(0, 0, 1)],
	]
	for sp: Array in specs:
		var normal: Vector3 = sp[0]
		var centre: Vector3 = sp[1]
		var psize: Vector2 = sp[2]
		var cols: int = sp[3]
		var along: Vector3 = sp[4]
		var holder: Node3D = Node3D.new()  # quad + lines toggle together
		add_child(holder)
		var wall: MeshInstance3D = MeshInstance3D.new()
		var quad: QuadMesh = QuadMesh.new()
		quad.size = psize
		wall.mesh = quad
		var wm: StandardMaterial3D = _unshaded(WALL_COLOUR)
		wm.cull_mode = BaseMaterial3D.CULL_DISABLED
		wall.material_override = wm
		wall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		wall.position = centre
		wall.basis = Basis.looking_at(normal, Vector3.UP)  # quad faces along its local +Z
		holder.add_child(wall)
		# Column guides (vertical lines at every cell edge) + horizontal lines every 2 layers.
		var im: ImmediateMesh = ImmediateMesh.new()
		im.surface_begin(Mesh.PRIMITIVE_LINES)
		var half: float = cols * 0.5
		for c in range(cols + 1):
			var p: Vector3 = Vector3(centre.x, 0.0, centre.z) + along * (c - half)
			im.surface_add_vertex(p)
			im.surface_add_vertex(p + Vector3(0, h, 0))
		for y in range(2, int(h), 2):
			var a: Vector3 = Vector3(centre.x, y, centre.z) - along * half
			im.surface_add_vertex(a)
			im.surface_add_vertex(a + along * cols)
		im.surface_end()
		var lines: MeshInstance3D = MeshInstance3D.new()
		lines.mesh = im
		lines.material_override = _unshaded(WALL_LINE_COLOUR)
		holder.add_child(lines)  # line verts are in board space; holder is at identity
		_walls.append(holder)
		_wall_normals.append(normal)


func _build_camera(size: Vector3i) -> void:
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	var vp: Vector2 = Vector2(1152.0, 648.0)
	if is_inside_tree():
		vp = get_viewport().get_visible_rect().size
	var aspect: float = vp.x / maxf(vp.y, 1.0)
	_camera.size = CameraMath.ortho_size(size, ELEVATION_DEG, aspect, MARGIN)
	_camera.near = 0.5
	_camera.far = 200.0
	add_child(_camera)
	_camera.current = true


func _make_multimesh(mesh: Mesh, translucent: bool, outline: bool) -> MultiMeshInstance3D:
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true # must be set before instance_count
	mm.mesh = mesh
	mm.instance_count = 0
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	if translucent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if outline:
		# Inverted-hull outline: slightly grown dark copy drawn back faces only.
		var ol: StandardMaterial3D = _unshaded(OUTLINE_COLOUR if not translucent else Color(OUTLINE_COLOUR, 0.6))
		ol.cull_mode = BaseMaterial3D.CULL_FRONT
		ol.grow = true
		ol.grow_amount = OUTLINE_GROW
		mat.next_pass = ol
	var inst: MultiMeshInstance3D = MultiMeshInstance3D.new()
	inst.multimesh = mm
	inst.material_override = mat
	if translucent:
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(inst)
	return inst


func _cell_pos(c: Vector3i) -> Vector3:
	var s: Vector3i = _game.board.size
	return Vector3(c.x - s.x / 2.0 + 0.5, c.y + 0.5, c.z - s.z / 2.0 + 0.5)


func _colour_of(idx: int, shade: float, alpha: float) -> Color:
	var col: Color = PALETTE[posmod(idx, PALETTE.size())] * shade
	col.a = alpha
	return col


func _fill(inst: MultiMeshInstance3D, xforms: Array[Transform3D], colours: Array[Color]) -> void:
	var mm: MultiMesh = inst.multimesh
	mm.instance_count = xforms.size()
	for i in range(xforms.size()):
		mm.set_instance_transform(i, xforms[i])
		mm.set_instance_color(i, colours[i])


func _fill_cubes(inst: MultiMeshInstance3D, cells: Array[Vector3i], colour_idx: Array[int], shade: float, alpha: float) -> void:
	var xf: Array[Transform3D] = []
	var cols: Array[Color] = []
	for i in range(cells.size()):
		xf.append(Transform3D(Basis(), _cell_pos(cells[i])) * _cube_xform)
		cols.append(_colour_of(colour_idx[i], shade, alpha))
	_fill(inst, xf, cols)


func _redraw() -> void:
	if _game == null:
		return
	var s_cells: Array[Vector3i] = []
	var s_cols: Array[int] = []
	var filled: Dictionary = _game.board.filled_cells()
	for key: Variant in filled.keys():
		s_cells.append(key as Vector3i)
		s_cols.append(int(filled[key]))
	_fill_cubes(_settled, s_cells, s_cols, SETTLED_SHADE, 1.0)

	var a_idx: int = int(FpPieces.COLOURS.get(_game.active_shape, 0))
	var a_cols: Array[int] = []
	a_cols.resize(_game.active_cells.size())
	a_cols.fill(a_idx)
	_fill_cubes(_active, _game.active_cells, a_cols, 1.0, 1.0)

	var g_cols: Array[int] = []
	g_cols.resize(_game.ghost_cells.size())
	g_cols.fill(a_idx)
	_fill_cubes(_ghost, _game.ghost_cells, g_cols, 1.0, GHOST_ALPHA)

	# Landing-column marks on the floor under every column the active piece occupies.
	var seen: Dictionary = {}
	var m_xf: Array[Transform3D] = []
	var m_cols: Array[Color] = []
	for c: Vector3i in _game.active_cells:
		var col: Vector2i = Vector2i(c.x, c.z)
		if seen.has(col):
			continue
		seen[col] = true
		var p: Vector3 = _cell_pos(Vector3i(c.x, 0, c.z))
		m_xf.append(Transform3D(Basis(), Vector3(p.x, 0.012, p.z)))
		m_cols.append(COLUMN_MARK_COLOUR)
	_fill(_marks, m_xf, m_cols)
