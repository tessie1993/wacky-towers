class_name WtBlockMesh extends RefCounted
## Procedural chunky "toy" cube (ref 13): a unit cube (edge 1.0, centred on the origin) with a fat
## 9% bevel (4 segments per rounded edge) and weighted normals (flat faces keep the face normal, only
## the bevel ring carries the rounded normal, so big faces never shade as pillows).
##
## One surface, ONE draw call, two tri groups told apart by UV2 (x = shell flag, y = shell row):
##   body  (UV2.x = 0)  the rounded cube, 300 tris.
##   shell (UV2.x = 1)  a cap skirt laid exactly ON the body surface (top plate + a band round the four
##                      upper sides). With any other material it is invisible (coincident, same
##                      normals). spatial_block_biome.gdshader displaces it into a grass / icing / frost
##                      cap with a real overhang and drips (UV2.y > 0 = rows that slide down the side)
##                      and collapses it to nothing on pieces or biomes that carry no cap.
## 574 tris with a cap, 300 effective without. The mesh stays inside the unit AABB, so
## ArtSet.cube_scale() is still 1.0.
## Usage: var mesh: ArrayMesh = WtBlockMesh.cube()   # cached, shared

## Bevel radius in cube units (9%, inside the 8-10% window of the art research). The block shader
## carries the same constant (BEVEL); keep them equal.
const BEVEL := 0.09
## Normalised offsets inside the bevel where extra rings are placed (0 = flat face, 1 = 45 deg).
const RING_STEPS: Array[float] = [1.0, 0.45]
## Extra shell columns across the flat part of a side face.
const SHELL_FLAT_STOPS: Array[float] = [-0.14, 0.14]
## Shell rows that slide down the side in the shader (UV2.y), top to bottom.
const SHELL_SLIDE_ROWS: Array[float] = [0.5, 1.0]

static var _cached: ArrayMesh = null


## Returns the shared rounded-cube mesh (built once).
static func cube() -> ArrayMesh:
	if _cached == null:
		_cached = build(BEVEL)
	return _cached


## Builds a rounded cube with the cap-shell tris. Body: per face a 5x5 quad grid (two bevel rings,
## flat middle, two bevel rings).
static func build(bevel: float) -> ArrayMesh:
	var half: float = 0.5 - bevel
	var stops: Array[float] = []
	for s: float in RING_STEPS:
		stops.append(-half - bevel * s)
	stops.append(-half)
	stops.append(half)
	for i: int in range(RING_STEPS.size() - 1, -1, -1):
		stops.append(half + bevel * RING_STEPS[i])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var axes: Array[Vector3] = [Vector3.RIGHT, Vector3.UP, Vector3.BACK]
	for axis: int in 3:
		for sign_f: float in [1.0, -1.0]:
			var a: Vector3 = axes[axis]
			var u: Vector3 = axes[(axis + 1) % 3]
			var v: Vector3 = axes[(axis + 2) % 3]
			_grid(st, a * (0.5 * sign_f), u, v, stops, stops, bevel, a * sign_f, Vector2.ZERO, null)
	# Shell, top plate: the +Y face again (shell flag 1, slide row 0).
	_grid(st, Vector3.UP * 0.5, Vector3.BACK, Vector3.RIGHT, stops, stops, bevel, Vector3.UP, Vector2(1.0, 0.0), null)
	# Shell, upper skirt on the four sides. Columns run round the face (corner rings included); rows go
	# top (45 deg) -> flat start, then the rows the shader slides down the side.
	var cols: Array[float] = []
	for s: float in RING_STEPS:
		cols.append(-half - bevel * s)
	cols.append(-half)
	for c: float in SHELL_FLAT_STOPS:
		cols.append(c)
	cols.append(half)
	for i: int in range(RING_STEPS.size() - 1, -1, -1):
		cols.append(half + bevel * RING_STEPS[i])
	# Row list, bottom-up so the +Y direction of the grid is the cube's up: [v stop, UV2.y].
	var rows: Array[Vector2] = []
	for k: int in range(SHELL_SLIDE_ROWS.size() - 1, -1, -1):
		rows.append(Vector2(-0.05 - 0.05 * float(k), SHELL_SLIDE_ROWS[k]))
	rows.append(Vector2(half, 0.0))
	for i: int in range(RING_STEPS.size() - 1, -1, -1):
		rows.append(Vector2(half + bevel * RING_STEPS[i], 0.0))
	for out_dir: Vector3 in [Vector3.RIGHT, Vector3.LEFT, Vector3.BACK, Vector3.FORWARD]:
		var h: Vector3 = Vector3.UP.cross(out_dir)   # horizontal tangent of this face
		_grid(st, out_dir * 0.5, h, Vector3.UP, cols, [], bevel, out_dir, Vector2(1.0, 0.0), rows)
	st.index()
	var mesh: ArrayMesh = st.commit()
	return mesh


## Adds one quad grid on the rounded-cube surface. `centre` = face centre, (u, v) = grid axes, stops_u /
## stops_v = box-surface coordinates (clamped + pushed out by the bevel radius to round the edges).
## `rows` (optional) replaces stops_v with [v stop, UV2.y] entries, bottom-up. `shell` = (flag, row).
static func _grid(st: SurfaceTool, centre: Vector3, u: Vector3, v: Vector3, stops_u: Array[float], stops_v: Array[float],
		bevel: float, out_dir: Vector3, shell: Vector2, rows: Variant) -> void:
	var half: float = 0.5 - bevel
	var vs: Array[float] = []
	var vt: Array[float] = []
	if rows != null:
		for r: Vector2 in (rows as Array[Vector2]):
			vs.append(r.x)
			vt.append(r.y)
	else:
		vs = stops_v
		for _i: int in vs.size():
			vt.append(shell.y)
	var nu: int = stops_u.size()
	var nv: int = vs.size()
	var pts: Array[Vector3] = []
	var nrm: Array[Vector3] = []
	var uv2: Array[Vector2] = []
	for j: int in nv:
		for i: int in nu:
			var c: Vector3 = centre + u * stops_u[i] + v * vs[j]
			var inner: Vector3 = c.clamp(Vector3.ONE * -half, Vector3.ONE * half)
			var dir: Vector3 = (c - inner).normalized()
			pts.append(inner + dir * bevel)
			nrm.append(dir)
			uv2.append(Vector2(shell.x, vt[j]))
	# Godot front faces are clockwise. For a grid whose u x v points along the outward normal, the
	# clockwise order is (00, 11, 10, 00, 01, 11); otherwise it is mirrored.
	var flip: bool = u.cross(v).dot(out_dir) < 0.0
	for j: int in nv - 1:
		for i: int in nu - 1:
			var i00: int = j * nu + i
			var i10: int = i00 + 1
			var i01: int = i00 + nu
			var i11: int = i01 + 1
			var order: Array[int] = [i00, i11, i10, i00, i01, i11]
			if flip:
				order = [i00, i10, i11, i00, i11, i01]
			for k: int in order:
				st.set_normal(nrm[k])
				st.set_uv2(uv2[k])
				st.add_vertex(pts[k])
