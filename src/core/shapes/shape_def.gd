class_name ShapeDef extends Resource
## One piece shape: cube offsets about the pivot for all 24 orientations (ADR-0003).

@export var shape_id: StringName = &""
@export var display_name: String = ""
@export var family: StringName = &""
@export var hue_id: int = 0  # palette index; 0 = none
@export var motif: StringName = &""
@export var tags: PackedStringArray = PackedStringArray()
@export var cube_count: int = 0
@export var offsets_by_orient: Array = []  # of Array[Vector3i]; Godot has no nested typed arrays
@export var bbox_by_orient: Array[Vector3i] = []
@export var min_by_orient: Array[Vector3i] = []  # ADR-0003: spawn centring
@export var distinct_of: PackedInt32Array = PackedInt32Array()
@export var distinct_count: int = 0
@export var spawn_orient: int = 0


## Same string for any rotation or translation of the shape; mirror images differ.
## Usage: `ShapeDef.canonical_key(offsets)`. Empty offsets give "".
static func canonical_key(offsets: Array[Vector3i]) -> String:
	if offsets.is_empty():
		return ""
	var best: String = ""
	for o: int in range(Orientations.COUNT):
		var s: String = _serialise(_normalise(_rotated(offsets, o)))
		if o == 0 or s < best:
			best = s
	return best


static func _rotated(offsets: Array[Vector3i], o: int) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	for v: Vector3i in offsets:
		out.append(Orientations.apply(o, v))
	return out


static func _normalise(offsets: Array[Vector3i]) -> Array[Vector3i]:
	var out: Array[Vector3i] = offsets.duplicate()
	if out.is_empty():
		return out
	var lo: Vector3i = out[0]
	for v: Vector3i in out:
		lo = Vector3i(mini(lo.x, v.x), mini(lo.y, v.y), mini(lo.z, v.z))
	for i: int in range(out.size()):
		out[i] -= lo
	out.sort()
	return out


static func _serialise(normalised: Array[Vector3i]) -> String:
	var s: String = ""
	for v: Vector3i in normalised:
		s += "%d,%d,%d;" % [v.x, v.y, v.z]
	return s


## Cube offsets for orientation `o`; empty if out of range. Usage: `def.offsets(3)`.
func offsets(o: int) -> Array[Vector3i]:
	if o < 0 or o >= offsets_by_orient.size():
		var empty: Array[Vector3i] = []
		return empty
	var r: Array[Vector3i] = offsets_by_orient[o]
	return r


## Bounding-box size for orientation `o`; ZERO if out of range. Usage: `def.bbox(0)`.
func bbox(o: int) -> Vector3i:
	if o < 0 or o >= bbox_by_orient.size():
		return Vector3i.ZERO
	return bbox_by_orient[o]


## Min corner of the offsets for orientation `o`; ZERO if out of range. Usage: `def.min_corner(0)`.
func min_corner(o: int) -> Vector3i:
	if o < 0 or o >= min_by_orient.size():
		return Vector3i.ZERO
	return min_by_orient[o]
