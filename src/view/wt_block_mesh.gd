class_name WtBlockMesh extends RefCounted
## Procedural chunky "toy" cube: a unit cube (edge 1.0, centred on the origin) with rounded
## edges and corners and smooth normals. 300 triangles versus 1728 for the candy_toy GLB.
## Used by the block shader (spatial_block_biome.gdshader), which reads VERTEX/NORMAL in
## object space, so it works with both this mesh and the GLB cube.
## Usage: var mesh: ArrayMesh = WtBlockMesh.cube()   # cached, shared

## Bevel radius in cube units. Matches the look of the reference toy cubes.
const BEVEL := 0.11
## Normalised offsets inside the bevel where extra rings are placed (0 = flat face, 1 = 45 deg).
const RING_STEPS: Array[float] = [1.0, 0.42]

static var _cached: ArrayMesh = null


## Returns the shared rounded-cube mesh (built once).
static func cube() -> ArrayMesh:
	if _cached == null:
		_cached = build(BEVEL)
	return _cached


## Builds a rounded cube. Per face a 5x5 quad grid: bevel, half-bevel, flat middle, half-bevel, bevel.
static func build(bevel: float) -> ArrayMesh:
	var half: float = 0.5 - bevel
	# Grid stops along one face axis, in "cube surface" coordinates (-0.5 .. 0.5).
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
			var n: int = stops.size()
			var pts: Array[Vector3] = []
			var nrm: Array[Vector3] = []
			for j: int in n:
				for i: int in n:
					var c: Vector3 = a * (0.5 * sign_f) + u * stops[i] + v * stops[j]
					var inner: Vector3 = c.clamp(Vector3.ONE * -half, Vector3.ONE * half)
					var dir: Vector3 = (c - inner).normalized()
					pts.append(inner + dir * bevel)
					nrm.append(dir)
			for j: int in n - 1:
				for i: int in n - 1:
					var i00: int = j * n + i
					var i10: int = i00 + 1
					var i01: int = i00 + n
					var i11: int = i01 + 1
					# Godot front faces are clockwise; u x v = a for every cyclic axis triple, so the
					# +a face needs the clockwise order and the -a face the mirrored one.
					var order: Array[int] = [i00, i11, i10, i00, i01, i11]
					if sign_f < 0.0:
						order = [i00, i10, i11, i00, i11, i01]
					for k: int in order:
						st.set_normal(nrm[k])
						st.add_vertex(pts[k])
	return st.commit()
