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


## Rotation- and translation-invariant key for a cube set; mirror images differ (ADR-0003).
## Usage: `ShapeDef.canonical_key([Vector3i(0, 0, 0), Vector3i(1, 0, 0)])`.
## Deviation: takes Array[Vector3i] because Godot 4.7.2 has no PackedVector3iArray.
static func canonical_key(offsets: Array[Vector3i]) -> String:
	var best: String = ""
	for o: int in range(Orientations.COUNT):
		var s: String = _serialise(_normalise(_rotated(offsets, o)))
		if o == 0 or s < best:
			best = s
	return best


## Builds a ShapeDef with all geometry fields filled from pivot-relative offsets (ADR-0003, Piece Set rules 9-10).
## Precondition: offsets contain (0,0,0), are face-connected, no duplicates.
## Usage: `var d: ShapeDef = ShapeDef.build(&"i", offsets)`. Deviation: Array[Vector3i], no PackedVector3iArray in 4.7.2.
static func build(id: StringName, offsets: Array[Vector3i]) -> ShapeDef:
	var d: ShapeDef = ShapeDef.new()
	d.shape_id = id
	d.cube_count = offsets.size()
	d.distinct_of.resize(Orientations.COUNT)
	var keys: Array[String] = []  # one per distinct class, index = class id
	var best_y: int = 0
	for o: int in range(Orientations.COUNT):
		var r: Array[Vector3i] = _rotated(offsets, o)
		var lo: Vector3i = r[0]
		var hi: Vector3i = r[0]
		for v: Vector3i in r:
			lo = Vector3i(mini(lo.x, v.x), mini(lo.y, v.y), mini(lo.z, v.z))
			hi = Vector3i(maxi(hi.x, v.x), maxi(hi.y, v.y), maxi(hi.z, v.z))
		var bb: Vector3i = hi - lo + Vector3i.ONE
		d.offsets_by_orient.append(r)
		d.min_by_orient.append(lo)
		d.bbox_by_orient.append(bb)
		var key: String = _serialise(_normalise(r))
		var cls: int = keys.find(key)
		if cls < 0:
			cls = keys.size()
			keys.append(key)
		d.distinct_of[o] = cls
		if o == 0 or bb.y < best_y:  # strict < keeps the lowest o on ties
			best_y = bb.y
			d.spawn_orient = o
	d.distinct_count = keys.size()
	return d


static func _rotated(offsets: Array[Vector3i], o: int) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	for v: Vector3i in offsets:
		out.append(Orientations.apply(o, v))
	return out


static func _normalise(offsets: Array[Vector3i]) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	if offsets.is_empty():
		return out
	var lo: Vector3i = offsets[0]
	for v: Vector3i in offsets:
		lo = Vector3i(mini(lo.x, v.x), mini(lo.y, v.y), mini(lo.z, v.z))
	for v: Vector3i in offsets:
		out.append(v - lo)
	out.sort()
	return out


static func _serialise(normalised: Array[Vector3i]) -> String:
	var s: String = ""
	for v: Vector3i in normalised:
		s += "%d,%d,%d;" % [v.x, v.y, v.z]
	return s
