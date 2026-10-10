class_name BoardStage extends Node3D
## Readability set dressing (RND-06/08): meadow-green floor under active cells, floor grid, faint grid on the two
## back walls, dashed red danger line at h_play with "!" at two ends. 6 nodes. Node origin = board anchor (BoardGeom).
## Usage: stage.build(board.size(), board.h_play(), spec.mask)

const DASH_ON: float = 0.5 ## Dash length per 1-unit boundary edge (the rest is gap).
const DANGER_Y_LIFT: float = 0.02
const DANGER_IDLE_ALPHA: float = 0.55
const PULSE_HZ: float = 2.0

@export var floor_color: Color = Color(0.45, 0.70, 0.36) # ponytail: meadow green placeholder; art direction may retint
@export var grid_color: Color = Color(0.10, 0.25, 0.12, 0.9)
@export var wall_grid_color: Color = Color(0.10, 0.25, 0.12, 0.3)
@export var danger_color: Color = Color(1.0, 0.12, 0.08)
@export var slab_depth: float = 0.3
@export var danger_width: float = 0.1

## Set from MotionPrefs.reduced: the danger line then stays static.
var reduced_motion: bool = false

var _danger_mat: StandardMaterial3D
var _danger_on: bool = false
var _t: float = 0.0


func _ready() -> void:
	set_process(_danger_on and not reduced_motion) # build()/set_danger() may have run before entering the tree


func _process(delta: float) -> void:
	_t += delta
	_set_danger_alpha(0.75 + 0.25 * sin(_t * TAU * PULSE_HZ))


## Builds floor, grids, danger line. mask = W*D bytes (1 = active, index x + W*z); empty = all active.
## Usage: stage.build(Vector3i(4, 12, 4), 8, PackedByteArray())
func build(board_size: Vector3i, h_play: int, mask: PackedByteArray) -> void:
	for c: Node in get_children():
		remove_child(c)
		c.queue_free()
	var w: int = board_size.x
	var d: int = board_size.z
	var on := PackedByteArray()
	on.resize(w * d)
	for i: int in w * d:
		on[i] = 1 if mask.is_empty() else mask[i]
	_add_mesh("Floor", _floor_mesh(w, d, on), _flat_material(floor_color, false, true))
	_add_mesh("FloorGrid", _floor_grid(w, d, on), _flat_material(Color.WHITE, true, false))
	_add_mesh("WallGrid", _wall_grid(w, board_size.y, d), _flat_material(Color.WHITE, true, false))
	_build_danger(w, d, on, h_play)
	set_danger(_danger_on)


## Intensifies the danger line (pulses unless reduced_motion). Usage: stage.set_danger(board.over_limit())
func set_danger(on: bool) -> void:
	_danger_on = on
	_set_danger_alpha(1.0 if on else DANGER_IDLE_ALPHA)
	set_process(on and not reduced_motion)


func _set_danger_alpha(a: float) -> void:
	if _danger_mat != null:
		_danger_mat.albedo_color = Color(danger_color, a)


func _add_mesh(node_name: String, mesh: Mesh, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


func _flat_material(c: Color, vertex_colors: bool, shaded: bool) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if not shaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if vertex_colors:
		m.vertex_color_use_as_albedo = true
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m


func _is_on(x: int, z: int, w: int, d: int, on: PackedByteArray) -> bool:
	return x >= 0 and z >= 0 and x < w and z < d and on[x + w * z] == 1


## Floor slab: top quad per active cell at y = 0, side quads only on the footprint boundary.
func _floor_mesh(w: int, d: int, on: PackedByteArray) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var y0: float = -slab_depth
	for z: int in d:
		for x: int in w:
			if not _is_on(x, z, w, d, on):
				continue
			var x0: float = x - w / 2.0
			var z0: float = z - d / 2.0
			var x1: float = x0 + 1.0
			var z1: float = z0 + 1.0
			_quad(st, Vector3(x0, 0, z0), Vector3(x1, 0, z0), Vector3(x1, 0, z1), Vector3(x0, 0, z1), Vector3.UP)
			if not _is_on(x - 1, z, w, d, on):
				_quad(st, Vector3(x0, 0, z0), Vector3(x0, 0, z1), Vector3(x0, y0, z1), Vector3(x0, y0, z0), Vector3.LEFT)
			if not _is_on(x + 1, z, w, d, on):
				_quad(st, Vector3(x1, 0, z1), Vector3(x1, 0, z0), Vector3(x1, y0, z0), Vector3(x1, y0, z1), Vector3.RIGHT)
			if not _is_on(x, z - 1, w, d, on):
				_quad(st, Vector3(x1, 0, z0), Vector3(x0, 0, z0), Vector3(x0, y0, z0), Vector3(x1, y0, z0), Vector3.FORWARD)
			if not _is_on(x, z + 1, w, d, on):
				_quad(st, Vector3(x0, 0, z1), Vector3(x1, 0, z1), Vector3(x1, y0, z1), Vector3(x0, y0, z1), Vector3.BACK)
	return st.commit()


func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, e: Vector3, n: Vector3) -> void:
	st.set_normal(n)
	for v: Vector3 in [a, b, c, a, c, e]:
		st.add_vertex(v)


## Thin lines around every active cell; shared edges are drawn once.
func _floor_grid(w: int, d: int, on: PackedByteArray) -> ImmediateMesh:
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_set_color(grid_color)
	var y: float = 0.01
	for z: int in d:
		for x: int in w:
			if not _is_on(x, z, w, d, on):
				continue
			var x0: float = x - w / 2.0
			var z0: float = z - d / 2.0
			_line(im, Vector3(x0, y, z0), Vector3(x0 + 1, y, z0))
			_line(im, Vector3(x0, y, z0), Vector3(x0, y, z0 + 1))
			if not _is_on(x + 1, z, w, d, on):
				_line(im, Vector3(x0 + 1, y, z0), Vector3(x0 + 1, y, z0 + 1))
			if not _is_on(x, z + 1, w, d, on):
				_line(im, Vector3(x0, y, z0 + 1), Vector3(x0 + 1, y, z0 + 1))
	im.surface_end()
	return im


## Back walls = the two far from the camera at the default yaw (CameraMath: camera on the -x/+z side): x = +W/2 and z = -D/2.
func _wall_grid(w: int, h: int, d: int) -> ImmediateMesh:
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_set_color(wall_grid_color)
	var xw: float = w / 2.0
	var zw: float = -d / 2.0
	for k: int in d + 1:
		_line(im, Vector3(xw, 0, zw + k), Vector3(xw, h, zw + k))
	for k: int in w + 1:
		_line(im, Vector3(-xw + k, 0, zw), Vector3(-xw + k, h, zw))
	for k: int in h + 1:
		_line(im, Vector3(xw, k, zw), Vector3(xw, k, -zw))
		_line(im, Vector3(-xw, k, zw), Vector3(xw, k, zw))
	im.surface_end()
	return im


func _line(im: ImmediateMesh, a: Vector3, b: Vector3) -> void:
	im.surface_add_vertex(a)
	im.surface_add_vertex(b)


## Dashes (flat ribbons; 1 px lines would vanish) along the footprint boundary at y = h_play, plus "!" at two ends.
func _build_danger(w: int, d: int, on: PackedByteArray, h_play: int) -> void:
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	var y: float = h_play + DANGER_Y_LIFT
	var lo_pt: Vector3 = Vector3.ZERO
	var hi_pt: Vector3 = Vector3.ZERO
	var lo_k: float = INF
	var hi_k: float = -INF
	for z: int in d:
		for x: int in w:
			if not _is_on(x, z, w, d, on):
				continue
			var x0: float = x - w / 2.0
			var z0: float = z - d / 2.0
			var starts: Array[Vector3] = []
			var dirs: Array[Vector3] = []
			if not _is_on(x, z - 1, w, d, on):
				starts.append(Vector3(x0, y, z0))
				dirs.append(Vector3.RIGHT)
			if not _is_on(x, z + 1, w, d, on):
				starts.append(Vector3(x0, y, z0 + 1))
				dirs.append(Vector3.RIGHT)
			if not _is_on(x - 1, z, w, d, on):
				starts.append(Vector3(x0, y, z0))
				dirs.append(Vector3.BACK)
			if not _is_on(x + 1, z, w, d, on):
				starts.append(Vector3(x0 + 1, y, z0))
				dirs.append(Vector3.BACK)
			for e: int in starts.size():
				_ribbon(im, starts[e], dirs[e], DASH_ON)
				var mid: Vector3 = starts[e] + dirs[e] * 0.5
				if mid.x + mid.z < lo_k:
					lo_k = mid.x + mid.z
					lo_pt = mid
				if mid.x + mid.z > hi_k:
					hi_k = mid.x + mid.z
					hi_pt = mid
	im.surface_end()
	_danger_mat = StandardMaterial3D.new()
	_danger_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_danger_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_danger_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_add_mesh("DangerLine", im, _danger_mat)
	if lo_k < INF:
		_add_bang("DangerBangA", lo_pt)
		_add_bang("DangerBangB", hi_pt)


func _ribbon(im: ImmediateMesh, s: Vector3, dir: Vector3, length: float) -> void:
	var p: Vector3 = Vector3(-dir.z, 0.0, dir.x) * (danger_width * 0.5)
	var e: Vector3 = s + dir * length
	for v: Vector3 in [s - p, s + p, e + p, s - p, e + p, e - p]:
		im.surface_add_vertex(v)


func _add_bang(node_name: String, at: Vector3) -> void:
	var l := Label3D.new()
	l.name = node_name
	l.text = "!"
	l.font_size = 96
	l.pixel_size = 0.01
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.modulate = danger_color
	l.outline_modulate = Color(0.1, 0.0, 0.0)
	l.outline_size = 16
	l.no_depth_test = true
	l.position = at + Vector3(0, 0.7, 0)
	add_child(l)
