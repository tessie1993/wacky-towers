class_name WtBlockToppers extends RefCounted
## Small decorative toppers (sprout, heart, coral, spike, leaf, crystal, gear, star, ticket, dome)
## on SOME exposed block tops, drawn as one MultiMesh per board (art bible section 6, ref 15).
## Kind and rate come from biome_looks.json biomes.<id>.block.topper / topper_rate.
## Meshes are procedural with vertex colours (alpha < 1 = emissive part); shader
## spatial_block_topper.gdshader. Usage:
##   var node := WtBlockToppers.build_for_cells(&"meadow", WtBlockToppers.exposed_tops(board), -1.0)

const SHADER_PATH := "res://src/view/shaders/spatial_block_topper.gdshader"
## Toppers sit this far above the cube centre (cube top = 0.5, minus a little sink into the cap).
const SEAT_Y := 0.47
## Uniform topper scale (meshes are authored ~0.3 tall; ref 13 toppers are ~0.45 of a cube).
const SCALE := 1.5

static var _meshes: Dictionary = {}


## Topper kind for a biome ("" = none).
static func kind_for(biome: StringName) -> StringName:
	return StringName(str(WtBlockMaterials.look(biome).get("block", {}).get("topper", "")))


## Share of exposed tops that get a topper (biome data).
static func rate_for(biome: StringName) -> float:
	return float(WtBlockMaterials.look(biome).get("block", {}).get("topper_rate", 0.0))


## Deterministic pick: true when this cell carries a topper at the given rate.
static func picks(cell: Vector3, rate: float) -> bool:
	var h: float = fposmod(sin(cell.x * 12.9898 + cell.y * 78.233 + cell.z * 37.719) * 43758.5453, 1.0)
	return h < rate


## World-space centres of filled normal cubes whose up neighbour is free (gravity -Y only).
static func exposed_tops(board: BoardState) -> Array[Vector3]:
	var out: Array[Vector3] = []
	if board == null or board.down_vector() != Vector3i(0, -1, 0):
		return out
	var size: Vector3i = board.size()
	for i: int in size.x * size.y * size.z:
		if not board.is_active(i):
			continue
		var kind: int = board.get_kind(i)
		if kind == ContentTypes.KIND_EMPTY or kind >= 3:
			continue
		var c: Vector3i = board.cell(i)
		var above := c + Vector3i.UP
		if board.in_bounds(above) and board.get_kind(board.index(above)) != ContentTypes.KIND_EMPTY:
			continue
		out.append(BoardGeom.cell_center(c, size))
	return out


## Builds the topper MultiMeshInstance3D for these cube centres; rate < 0 uses the biome rate.
## Returns null when the biome has no topper or nothing was picked.
static func build_for_cells(biome: StringName, centres: Array[Vector3], rate: float = -1.0) -> MultiMeshInstance3D:
	var kind: StringName = kind_for(biome)
	if kind == &"":
		return null
	var r: float = rate_for(biome) if rate < 0.0 else rate
	var chosen: Array[Vector3] = []
	for c: Vector3 in centres:
		if picks(c, r):
			chosen.append(c)
	if chosen.is_empty():
		return null
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh(kind)
	mm.instance_count = chosen.size()
	for i: int in chosen.size():
		var c: Vector3 = chosen[i]
		var yaw: float = fposmod(c.x * 1.7 + c.z * 2.3, TAU) * 0.25 - 0.4
		var off := Vector3(fposmod(c.x * 0.37 + c.z * 0.11, 0.2) - 0.1, SEAT_Y, fposmod(c.z * 0.29, 0.2) - 0.1)
		mm.set_instance_transform(i, Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * SCALE), c + off))
	var node := MultiMeshInstance3D.new()
	node.name = "BlockToppers"
	node.multimesh = mm
	var mat := ShaderMaterial.new()
	mat.shader = load(SHADER_PATH) as Shader
	node.material_override = mat
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node


## Cached topper mesh by kind (origin at the seat, +Y up, ~0.3 units tall).
static func mesh(kind: StringName) -> ArrayMesh:
	if not _meshes.has(kind):
		_meshes[kind] = _build(kind)
	return _meshes[kind]


static func _build(kind: StringName) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	match kind:
		&"sprout":
			_prim(st, _cyl(0.018, 0.026, 0.16), Transform3D(Basis(), Vector3(0, 0.08, 0)), Color("4f9a2e"))
			for s: float in [-1.0, 1.0]:
				_prim(st, _sphere(0.5), Transform3D(Basis(Vector3.BACK, s * 0.5).scaled(Vector3(0.17, 0.045, 0.1)), Vector3(s * 0.08, 0.17, 0)), Color("7cc84a"))
		&"heart":
			var b := Basis(Vector3.BACK, 0.0)
			_prim(st, _sphere(0.5), Transform3D(b.scaled(Vector3(0.12, 0.12, 0.09)), Vector3(-0.045, 0.15, 0)), Color("ff4f86"))
			_prim(st, _sphere(0.5), Transform3D(b.scaled(Vector3(0.12, 0.12, 0.09)), Vector3(0.045, 0.15, 0)), Color("ff4f86"))
			_prim(st, _cyl(0.0, 0.095, 0.13, 12), Transform3D(Basis(Vector3.BACK, PI).scaled(Vector3(1, 1, 0.75)), Vector3(0, 0.08, 0)), Color("f23f78"))
			_prim(st, _cyl(0.05, 0.06, 0.03), Transform3D(Basis(), Vector3(0, 0.015, 0)), Color("fff1f4"))
		&"coral":
			for k: int in 5:
				var a: float = TAU * k / 5.0
				var tilt := Basis(Vector3(cos(a), 0, sin(a)).cross(Vector3.UP).normalized(), 0.0 if k == 0 else 0.7)
				var h: float = 0.2 if k == 0 else 0.14
				_prim(st, _cyl(0.022, 0.03, h), Transform3D(tilt, tilt * Vector3(0, h * 0.5, 0)), Color("a85ee0"))
				_prim(st, _sphere(0.032), Transform3D(Basis(), tilt * Vector3(0, h, 0)), Color("d79cff", 0.75))
		&"spike":
			_prim(st, _cyl(0.0, 0.12, 0.26, 6), Transform3D(Basis(), Vector3(0, 0.12, 0)), Color("3a3133"))
			_prim(st, _cyl(0.0, 0.06, 0.15, 5), Transform3D(Basis(Vector3.BACK, 0.4), Vector3(0.08, 0.06, 0.03)), Color("453a3b"))
			_prim(st, _cyl(0.0, 0.05, 0.12, 5), Transform3D(Basis(Vector3.BACK, -0.45), Vector3(-0.08, 0.05, -0.02)), Color("453a3b"))
			_prim(st, _cyl(0.09, 0.12, 0.02, 6), Transform3D(Basis(), Vector3(0, 0.005, 0)), Color("ff7a1a", 0.3))
		&"leaf":
			_prim(st, _cyl(0.012, 0.016, 0.08), Transform3D(Basis(), Vector3(0, 0.04, 0)), Color("6a4a2a"))
			_prim(st, _sphere(0.5), Transform3D(Basis(Vector3.BACK, -0.6).scaled(Vector3(0.24, 0.05, 0.12)), Vector3(0.07, 0.13, 0)), Color("7cbf3c"))
		&"crystal":
			var tints := [Color("9a5ee8"), Color("7f45d0"), Color("b47cf6"), Color("8a50dc")]
			for k: int in 4:
				var a: float = TAU * k / 3.0 + 0.3
				var bb := Basis(Vector3(cos(a), 0, sin(a)).cross(Vector3.UP).normalized(), 0.0 if k == 0 else 0.55)
				var h: float = 0.2 if k == 0 else 0.13
				var w: float = 0.05 if k == 0 else 0.04
				_prim(st, _cyl(w, w, h, 6), Transform3D(bb, bb * Vector3(0, h * 0.5, 0)), Color(tints[k], 0.85))
				_prim(st, _cyl(0.0, w, w * 1.6, 6), Transform3D(bb, bb * Vector3(0, h + w * 0.8, 0)), Color(tints[k].lightened(0.25), 0.8))
		&"gear":
			var up := Basis(Vector3.RIGHT, PI * 0.5)
			_prim(st, _cyl(0.1, 0.1, 0.04, 16), Transform3D(up, Vector3(0, 0.15, 0)), Color("d8a548"))
			for k: int in 8:
				var a: float = TAU * k / 8.0
				_prim(st, BoxMesh.new(), Transform3D(Basis(Vector3.BACK, a).scaled(Vector3(0.05, 0.05, 0.04)), Vector3(cos(a + PI * 0.5) * 0.115, 0.15 + sin(a + PI * 0.5) * 0.115, 0)), Color("c8923a"))
			_prim(st, _cyl(0.035, 0.035, 0.06, 10), Transform3D(up, Vector3(0, 0.15, 0)), Color("8a5f22"))
			_prim(st, BoxMesh.new(), Transform3D(Basis().scaled(Vector3(0.05, 0.06, 0.04)), Vector3(0, 0.03, 0)), Color("8a5f22"))
		&"snowflake":
			for k: int in 3:
				var a: float = PI * k / 3.0
				_prim(st, BoxMesh.new(), Transform3D(Basis(Vector3.UP, a).scaled(Vector3(0.3, 0.03, 0.045)), Vector3(0, 0.05, 0)), Color("f4fbff", 0.8))
			_prim(st, _cyl(0.05, 0.05, 0.04, 6), Transform3D(Basis(), Vector3(0, 0.05, 0)), Color("c8ecff", 0.85))
		&"chip":
			_prim(st, BoxMesh.new(), Transform3D(Basis().scaled(Vector3(0.24, 0.05, 0.24)), Vector3(0, 0.025, 0)), Color("1c1a4a"))
			_prim(st, BoxMesh.new(), Transform3D(Basis().scaled(Vector3(0.14, 0.02, 0.14)), Vector3(0, 0.055, 0)), Color("3ff2e0", 0.5))
			for k: int in 4:
				var a: float = PI * 0.5 * k
				_prim(st, BoxMesh.new(), Transform3D(Basis().scaled(Vector3(0.05, 0.02, 0.02)), Vector3(cos(a) * 0.14, 0.03, sin(a) * 0.14)), Color("3ff2e0", 0.5))
		&"rope":
			var tor := TorusMesh.new()
			tor.inner_radius = 0.07
			tor.outer_radius = 0.12
			tor.rings = 12
			tor.ring_segments = 6
			_prim(st, tor, Transform3D(Basis(), Vector3(0, 0.03, 0)), Color("d8bc82"))
			_prim(st, tor, Transform3D(Basis().scaled(Vector3(0.8, 1, 0.8)), Vector3(0, 0.07, 0)), Color("b8985a"))
			_prim(st, _cyl(0.02, 0.02, 0.03), Transform3D(Basis(), Vector3(0.1, 0.1, 0)), Color("c8923a"))
		&"star":
			_star(st, 0.13, 0.055, 0.05, Transform3D(Basis(), Vector3(0, 0.14, 0)), Color("ffe9a8", 0.75))
		&"ticket":
			_prim(st, BoxMesh.new(), Transform3D(Basis(Vector3.RIGHT, -0.25).scaled(Vector3(0.26, 0.15, 0.045)), Vector3(0, 0.09, 0)), Color("e8344e"))
			_star(st, 0.045, 0.02, 0.012, Transform3D(Basis(Vector3.RIGHT, -0.25), Vector3(0, 0.095, 0.03)), Color("ffd24a"))
		&"dome":
			_prim(st, _cyl(0.07, 0.08, 0.04, 14), Transform3D(Basis(), Vector3(0, 0.02, 0)), Color("b8862e"))
			_prim(st, _sphere(0.5), Transform3D(Basis().scaled(Vector3(0.15, 0.17, 0.15)), Vector3(0, 0.1, 0)), Color("e3b04a"))
			_prim(st, _cyl(0.0, 0.03, 0.09, 10), Transform3D(Basis(), Vector3(0, 0.22, 0)), Color("e3b04a"))
			_prim(st, _sphere(0.018), Transform3D(Basis(), Vector3(0, 0.27, 0)), Color("f6d27a"))
		_:
			_prim(st, _sphere(0.06), Transform3D(Basis(), Vector3(0, 0.06, 0)), Color.WHITE)
	return st.commit()


static func _sphere(radius: float) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0
	m.radial_segments = 12
	m.rings = 6
	return m


static func _cyl(top: float, bottom: float, height: float, sides: int = 8) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.top_radius = top
	m.bottom_radius = bottom
	m.height = height
	m.radial_segments = sides
	m.rings = 1
	return m


## Appends a primitive mesh's triangles, transformed, with one vertex colour.
static func _prim(st: SurfaceTool, prim: PrimitiveMesh, xf: Transform3D, color: Color) -> void:
	var arr: Array = prim.get_mesh_arrays()
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var norms: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
	var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
	var nb: Basis = xf.basis.inverse().transposed()
	for k: int in idx:
		st.set_color(color)
		st.set_normal((nb * norms[k]).normalized())
		st.add_vertex(xf * verts[k])


## Extruded five-point star standing upright (faces +Z / -Z).
static func _star(st: SurfaceTool, outer: float, inner: float, depth: float, xf: Transform3D, color: Color) -> void:
	var pts: Array[Vector3] = []
	for k: int in 10:
		var a: float = PI * 0.5 + TAU * k / 10.0
		var r: float = outer if k % 2 == 0 else inner
		pts.append(Vector3(cos(a) * r, sin(a) * r, 0))
	var nb: Basis = xf.basis.inverse().transposed()
	var front := Vector3(0, 0, depth * 0.5)
	var back := Vector3(0, 0, -depth * 0.5)
	for k: int in 10:
		var a: Vector3 = pts[k]
		var b: Vector3 = pts[(k + 1) % 10]
		# Puffy faces: centre pushed out so the star reads as a soft pillow.
		for tri: Array in [[front * 1.8, b + front, a + front, Vector3.BACK], [back * 1.8, a + back, b + back, Vector3.FORWARD]]:
			for v: int in 3:
				st.set_color(color)
				var n: Vector3 = (tri[3] as Vector3 + (tri[v] as Vector3) * Vector3(2.0, 2.0, 0.0)).normalized()
				st.set_normal((nb * n).normalized())
				st.add_vertex(xf * (tri[v] as Vector3))
		var side_n: Vector3 = (b - a).cross(Vector3.BACK).normalized()
		for v: Vector3 in [a + front, b + front, b + back, a + front, b + back, a + back]:
			st.set_color(color)
			st.set_normal((nb * side_n).normalized())
			st.add_vertex(xf * v)
