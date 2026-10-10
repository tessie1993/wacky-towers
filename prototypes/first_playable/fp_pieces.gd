class_name FpPieces
extends RefCounted
## Static flat-tetromino data (XZ plane, y = 0, min corner at origin) plus spin maths.

const SHAPES: Dictionary = {
	"i": [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(3, 0, 0)],
	"o": [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(1, 0, 1)],
	"t": [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(1, 0, 1)],
	"l": [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(2, 0, 1)],
	"s": [Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(1, 0, 1), Vector3i(2, 0, 1)],
}

const COLOURS: Dictionary = { "i": 0, "o": 1, "t": 2, "l": 3, "s": 4 }


## Offsets of a shape id as a fresh typed array ([] for unknown ids).
static func cells(shape: String) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	if not SHAPES.has(shape):
		return out
	for c: Vector3i in SHAPES[shape]:
		out.append(c)
	return out


## Cube nearest the bbox centre (ties: lowest x, then lowest z).
static func pivot(offsets: Array[Vector3i]) -> Vector3i:
	if offsets.is_empty():
		return Vector3i.ZERO
	var lo: Vector3i = offsets[0]
	var hi: Vector3i = offsets[0]
	for c: Vector3i in offsets:
		lo = Vector3i(mini(lo.x, c.x), mini(lo.y, c.y), mini(lo.z, c.z))
		hi = Vector3i(maxi(hi.x, c.x), maxi(hi.y, c.y), maxi(hi.z, c.z))
	var centre: Vector3 = Vector3(lo + hi) * 0.5
	var best: Vector3i = offsets[0]
	var best_d: float = INF
	for c: Vector3i in offsets:
		var d: float = Vector3(c).distance_squared_to(centre)
		var better: bool = d < best_d - 0.0001
		var tied: bool = absf(d - best_d) <= 0.0001 and (c.x < best.x or (c.x == best.x and c.z < best.z))
		if better or tied:
			best = c
			best_d = d
	return best


## Turn 90 degrees about a world axis (0=X, 1=Y, 2=Z; dir +1 = CCW seen from +axis) around the
## pivot cube, which stays fixed. pivot_idx < 0 = use pivot(offsets). Uses Orientations (ADR-0003).
static func rotate(offsets: Array[Vector3i], axis: int, dir: int, pivot_idx: int = -1) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	if offsets.is_empty():
		return out
	var p: Vector3i = offsets[pivot_idx] if pivot_idx >= 0 else pivot(offsets)
	var o: int = Orientations.turn(0, axis as Orientations.Axis, dir)
	for c: Vector3i in offsets:
		out.append(p + Orientations.apply(o, c - p))
	return out


## Yaw spin: +1 = spin right (clockwise seen from above) = rotate(Y, -1).
static func spin(offsets: Array[Vector3i], dir: int, pivot_idx: int = -1) -> Array[Vector3i]:
	return rotate(offsets, 1, -dir, pivot_idx)
