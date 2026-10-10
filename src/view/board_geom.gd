class_name BoardGeom extends RefCounted
## Board-anchor-space maths. Anchor = footprint centre at floor level (audit default).


## Centre of cell c in anchor space. size is the board footprint (x = W, z = D); float division.
## Usage: node.position = BoardGeom.cell_center(Vector3i(2, 0, 1), Vector3i(4, 12, 4))
static func cell_center(c: Vector3i, size: Vector3i) -> Vector3:
	return Vector3(c.x - size.x / 2.0 + 0.5, c.y + 0.5, c.z - size.z / 2.0 + 0.5)


## Basis equal to Orientations rotation o: basis * Vector3(v) == Vector3(Orientations.apply(o, v)).
## Usage: node.basis = BoardGeom.orient_basis(5)
static func orient_basis(o: int) -> Basis:
	var m: Array[Vector3i] = Orientations.matrix(o) # rows
	# Basis(x, y, z) takes columns, so build from rows then transpose.
	return Basis(Vector3(m[0]), Vector3(m[1]), Vector3(m[2])).transposed()


## Transform for a piece scene root so its source pivot lands on the origin cell centre (layout doc 7).
## Usage: root.transform = BoardGeom.piece_root_transform(origin, o, pivot, size)
static func piece_root_transform(origin: Vector3i, o: int, source_pivot: Vector3, size: Vector3i) -> Transform3D:
	var b: Basis = orient_basis(o)
	return Transform3D(b, cell_center(origin, size) - b * source_pivot)
