class_name BoardState extends RefCounted
## The board: one source of truth for what is where (ADR-0002). Packed per-cell storage plus index math.
## Usage: var b := BoardState.new(spec, types); b.get_kind(b.index(Vector3i(1, 0, 2)))

## Gravity directions (ADR-0002 §1); default Y_NEG.
enum Down { X_NEG, X_POS, Y_NEG, Y_POS, Z_NEG, Z_POS }

## Spec tokens, same order as Down (ADR-0002 §6 check 5).
const DOWN_TOKENS: Array[String] = ["-x", "+x", "-y", "+y", "-z", "+z"]

## Flag bits in _flags (ADR-0002 §2).
const F_ACTIVE := 1
const F_OCCUPIED := 2
const F_SOLID := 4
const F_FILLS_LAYER := 8
const F_HAS_STATUS := 16
const F_HAS_OVERLAY := 32
const F_HAS_EXTRA := 64

const _DOWN_VECTORS: Array[Vector3i] = [
	Vector3i(-1, 0, 0), Vector3i(1, 0, 0),
	Vector3i(0, -1, 0), Vector3i(0, 1, 0),
	Vector3i(0, 0, -1), Vector3i(0, 0, 1),
]

var _flags: PackedByteArray = PackedByteArray()
var _kind: PackedByteArray = PackedByteArray()
var _color: PackedByteArray = PackedByteArray()
var _piece: PackedInt32Array = PackedInt32Array()
var _types: ContentTypes
var _spec_down: int
var _size: Vector3i
var _h_play: int
var _active_count: int = 0
var _layer_order: PackedInt32Array = PackedInt32Array()
var _layer_start: PackedInt32Array = PackedInt32Array()
var _layer_active: PackedInt32Array = PackedInt32Array()
var _layer_filled: PackedInt32Array = PackedInt32Array()
var _layer_solid: PackedInt32Array = PackedInt32Array()


## Allocates the board from a validated spec: expands the mask over every layer and writes starting contents.
## Usage: BoardState.new(result.spec, types)
func _init(spec: BoardSpec, types: ContentTypes) -> void:
	_types = types
	_spec_down = spec.down
	_size = spec.size
	_h_play = spec.h_play
	var n: int = _size.x * _size.y * _size.z
	_flags.resize(n)
	_kind.resize(n)
	_color.resize(n)
	_piece.resize(n)
	var footprint: int = _size.x * _size.z
	for i: int in n:
		if spec.mask.is_empty() or spec.mask[i % footprint] == 1:
			_flags[i] = F_ACTIVE
			_active_count += 1
	for entry: Dictionary in spec.contents:
		var kind: int = entry["kind"]
		if types.slot(kind) == ContentTypes.SLOT_OVERLAY:
			continue # ponytail: overlay contents land with BRD-003 set_overlay; no overlay types in Meadow yet
		var i: int = index(entry["cell"])
		_kind[i] = kind
		_color[i] = types.hue(kind)
		var f: int = _flags[i] | F_OCCUPIED
		if types.is_solid(kind):
			f |= F_SOLID
		if types.fills_layer(kind):
			f |= F_FILLS_LAYER
		_flags[i] = f
	_rebuild_layout()


## Board dimensions (W, H, D). Usage: b.size().y
func size() -> Vector3i:
	return _size


## Playable height (size().y minus spawn clearance).
func h_play() -> int:
	return _h_play


## Flat index of a cell: x + W * (z + D * y). Caller must ensure in_bounds.
func index(c: Vector3i) -> int:
	return c.x + _size.x * (c.z + _size.z * c.y)


## Inverse of index(). Usage: b.cell(45)
func cell(i: int) -> Vector3i:
	return Vector3i(i % _size.x, i / (_size.x * _size.z), (i / _size.x) % _size.z)


## True if c lies inside the board box.
func in_bounds(c: Vector3i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.z >= 0 and c.x < _size.x and c.y < _size.y and c.z < _size.z


## True if the cell is part of the footprint. Out-of-range i is a caller bug (unchecked, hot path).
func is_active(i: int) -> bool:
	return (_flags[i] & F_ACTIVE) != 0


## Content kind at i (0 = empty). Out-of-range i is a caller bug (unchecked).
func get_kind(i: int) -> int:
	return _kind[i]


## Colour/hue id at i (0 = none). Out-of-range i is a caller bug (unchecked).
func get_color(i: int) -> int:
	return _color[i]


## Number of active cells (cached at _init).
func active_cell_count() -> int:
	return _active_count


## Maps a token to a Down value; -1 if not an exact member of DOWN_TOKENS. Usage: down_from_token("-y").
static func down_from_token(token: String) -> int:
	return DOWN_TOKENS.find(token)


## Unit gravity vector for a Down value; Vector3i.ZERO if d is invalid. Usage: down_vector_of(Down.Y_NEG).
static func down_vector_of(d: int) -> Vector3i:
	if d < 0 or d >= _DOWN_VECTORS.size():
		return Vector3i.ZERO
	return _DOWN_VECTORS[d]


## Current gravity direction (a BoardState.Down value). Usage: b.get_down()
func get_down() -> int:
	return _spec_down


## Unit gravity vector of this board. Usage: b.down_vector()
func down_vector() -> Vector3i:
	return _DOWN_VECTORS[_spec_down]


## Extent along the down axis: Y -> H, X -> W, Z -> D. Usage: b.layer_count()
func layer_count() -> int:
	return _layer_start.size() - 1


## Layer of cell index i; layer 0 is the floor end (ADR-0002 §1). Usage: b.layer_of(b.index(c))
func layer_of(i: int) -> int:
	var c: Vector3i = cell(i)
	match _spec_down:
		Down.X_NEG: return c.x
		Down.X_POS: return _size.x - 1 - c.x
		Down.Y_NEG: return c.y
		Down.Y_POS: return _size.y - 1 - c.y
		Down.Z_NEG: return c.z
		_: return _size.z - 1 - c.z


## Cell indices of layer k, ascending. Usage: for i in b.layer_cells(0)
func layer_cells(k: int) -> PackedInt32Array:
	return _layer_order.slice(_layer_start[k], _layer_start[k + 1])


## Active cells in layer k. Usage: b.active_in_layer(0)
func active_in_layer(k: int) -> int:
	return _layer_active[k]


## Active cells in layer k that fill the layer. Usage: b.filled_in_layer(0)
func filled_in_layer(k: int) -> int:
	return _layer_filled[k]


## True if layer k has active cells and all of them are filled. Usage: b.layer_full(0)
func layer_full(k: int) -> bool:
	return _layer_active[k] > 0 and _layer_filled[k] == _layer_active[k]


## Ascending list of full layers. Usage: b.full_layers()
func full_layers() -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	for k: int in layer_count():
		if layer_full(k):
			out.append(k)
	return out


## Recomputes the cached layer ordering and counters (O(N)). Called by _init; BRD-003 mutators call it too.
func _rebuild_layout() -> void:
	var n: int = _flags.size()
	var extent: int = _size.y
	if _spec_down == Down.X_NEG or _spec_down == Down.X_POS:
		extent = _size.x
	elif _spec_down == Down.Z_NEG or _spec_down == Down.Z_POS:
		extent = _size.z
	var per_layer: int = n / extent
	_layer_start.resize(extent + 1)
	for k: int in extent + 1:
		_layer_start[k] = k * per_layer
	_layer_order.resize(n)
	_layer_active.resize(extent)
	_layer_filled.resize(extent)
	_layer_solid.resize(extent)
	_layer_active.fill(0)
	_layer_filled.fill(0)
	_layer_solid.fill(0)
	var fill: PackedInt32Array = PackedInt32Array()
	fill.resize(extent)
	fill.fill(0)
	for i: int in n:
		var k: int = layer_of(i)
		_layer_order[k * per_layer + fill[k]] = i
		fill[k] += 1
		var f: int = _flags[i]
		if f & F_ACTIVE:
			_layer_active[k] += 1
			if f & F_FILLS_LAYER:
				_layer_filled[k] += 1
		if f & F_SOLID:
			_layer_solid[k] += 1


## True if c is in bounds, active and not solid. Usage: b.is_free(Vector3i(0, 0, 0))
func is_free(c: Vector3i) -> bool:
	if not in_bounds(c):
		return false
	return (_flags[index(c)] & (F_ACTIVE | F_SOLID)) == F_ACTIVE


## True if every cell is_free (ADR-0002 §3: only ACTIVE and SOLID matter). Usage: b.can_place(piece_cells)
func can_place(cells: Array[Vector3i]) -> bool:
	for c: Vector3i in cells:
		if not is_free(c):
			return false
	return true


## Free steps the cells can move along unit dir before blocking; 0 if blocked now. Usage: b.cast(cells, Vector3i(0, -1, 0))
func cast(cells: Array[Vector3i], dir: Vector3i) -> int:
	var cap: int = maxi(_size.x, maxi(_size.y, _size.z))
	for c: Vector3i in cells:
		if not is_free(c):
			return 0
	var s: int = 0
	while s < cap:
		var off: Vector3i = dir * (s + 1)
		for c: Vector3i in cells:
			if not is_free(c + off):
				return s
		s += 1
	return s


## Highest layer holding solid content; -1 when empty. Usage: b.stack_height()
func stack_height() -> int:
	for k: int in range(layer_count() - 1, -1, -1):
		if _layer_solid[k] > 0:
			return k
	return -1


## First layer that counts as over the height limit: layer_count() - C, C = size().y - h_play()
## (ADR-0002 Open Item 1 default; = h_play for +-y).
func limit_layer() -> int:
	return layer_count() - (_size.y - _h_play)


## True if any solid content sits at layer >= limit_layer(). Usage: if b.over_limit(): top_out()
func over_limit() -> bool:
	return stack_height() >= limit_layer()
