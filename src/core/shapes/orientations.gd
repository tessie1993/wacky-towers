class_name Orientations extends RefCounted
## The 24 proper rotations of a cube as integer 3x3 matrices (ADR-0003).
## Usage: `var o2: int = Orientations.turn(0, Orientations.Axis.Y, 1)`.

const COUNT := 24 # ADR-0003: proper rotations only (mirrors are different shapes)
enum Axis { X, Y, Z } ## World axis of a turn.

# Generator rows. ADR-0003 "Orientation math". +90 deg = CCW looking from +axis to origin.
const GEN_X: Array[Vector3i] = [Vector3i(1, 0, 0), Vector3i(0, 0, -1), Vector3i(0, 1, 0)] # (x,-z,y)
const GEN_Y: Array[Vector3i] = [Vector3i(0, 0, 1), Vector3i(0, 1, 0), Vector3i(-1, 0, 0)] # (z,y,-x)
const GEN_Z: Array[Vector3i] = [Vector3i(0, -1, 0), Vector3i(1, 0, 0), Vector3i(0, 0, 1)] # (-y,x,z)

static var _rows: Array[Vector3i] = [] # flat: rows of o at 3*o .. 3*o+2
static var _turn: PackedInt32Array = PackedInt32Array() # index (o*3+axis)*2 + (0 if dir>0 else 1)


## Orientation index after turning o 90 degrees about a world axis. dir is +1 or -1; o in 0..23.
static func turn(o: int, axis: Axis, dir: int) -> int:
	_ensure()
	return _turn[(o * 3 + axis) * 2 + (0 if dir > 0 else 1)]


## v rotated by orientation o (o in 0..23).
static func apply(o: int, v: Vector3i) -> Vector3i:
	_ensure()
	var a: Vector3i = _rows[3 * o]
	var b: Vector3i = _rows[3 * o + 1]
	var c: Vector3i = _rows[3 * o + 2]
	return Vector3i(
		a.x * v.x + a.y * v.y + a.z * v.z,
		b.x * v.x + b.y * v.y + b.z * v.z,
		c.x * v.x + c.y * v.y + c.z * v.z)


## The 3 rows of orientation o (a copy). Tests and tools only.
static func matrix(o: int) -> Array[Vector3i]:
	_ensure()
	return [_rows[3 * o], _rows[3 * o + 1], _rows[3 * o + 2]]


static func _ensure() -> void:
	if not _rows.is_empty():
		return
	var gens: Array = [GEN_X, GEN_Y, GEN_Z]
	var list: Array = [[Vector3i(1, 0, 0), Vector3i(0, 1, 0), Vector3i(0, 0, 1)]]
	var head: int = 0
	while head < list.size():
		for g: Array in gens:
			var n: Array[Vector3i] = _mul(g, list[head])
			if _index_of(list, n) < 0:
				list.append(n)
		head += 1
	assert(list.size() == COUNT)
	for m: Array in list:
		_rows.append_array(m)
	_turn.resize(COUNT * 3 * 2)
	for o: int in range(COUNT):
		for a: int in range(3):
			_turn[(o * 3 + a) * 2] = _index_of(list, _mul(gens[a], list[o]))
			_turn[(o * 3 + a) * 2 + 1] = _index_of(list, _mul(_transpose(gens[a]), list[o]))


static func _mul(a: Array, b: Array) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	for i: int in range(3):
		var r: Vector3i = a[i]
		out.append(r.x * b[0] + r.y * b[1] + r.z * b[2])
	return out


static func _transpose(m: Array) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	for i: int in range(3):
		out.append(Vector3i(m[0][i], m[1][i], m[2][i]))
	return out


static func _index_of(list: Array, m: Array) -> int:
	for i: int in range(list.size()):
		if list[i][0] == m[0] and list[i][1] == m[1] and list[i][2] == m[2]:
			return i
	return -1
