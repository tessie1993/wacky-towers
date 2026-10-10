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

## Delta ops (ADR-0002 §5). Delta is a flat PackedInt32Array of [op, a, b] triples.
enum Op { SET, REMOVE, MOVE, STATUS, OVERLAY, LAYOUT }

## Causes carried in REMOVE's b slot (ADR-0002 §5).
enum Cause { CLEAR, DISPLACED, DAMAGE, MASKED, TRIM, RESCUE }

const _CONTENT_BITS := F_OCCUPIED | F_SOLID | F_FILLS_LAYER

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
var _spawn_anchor: Vector2i
var _h_play: int
var _active_count: int = 0
var _layer_order: PackedInt32Array = PackedInt32Array()
var _layer_start: PackedInt32Array = PackedInt32Array()
var _layer_active: PackedInt32Array = PackedInt32Array()
var _layer_filled: PackedInt32Array = PackedInt32Array()
var _layer_solid: PackedInt32Array = PackedInt32Array()
var _delta: PackedInt32Array = PackedInt32Array()
var _touched: Dictionary = {} # cell index -> true; written since the last take_delta()
var _status: Dictionary = {} # cell index -> {status_id, counter, rule_id}; moves with the block (ADR-0002 §2)
var _overlay: Dictionary = {} # cell index -> {type_id, data}; stays with the cell
var _floor_layer: int = 0


## Allocates the board from a validated spec: expands the mask over every layer and writes starting contents.
## Usage: BoardState.new(result.spec, types)
func _init(spec: BoardSpec, types: ContentTypes) -> void:
	_types = types
	_spec_down = spec.down
	_size = spec.size
	_h_play = spec.h_play
	_spawn_anchor = spec.spawn_anchor
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
		var status: Dictionary = entry.get("status", {})
		if not status.is_empty():
			_status[i] = status.duplicate(true)
			_flags[i] |= F_HAS_STATUS
			if status.has("fills_layer"):
				_flags[i] = (_flags[i] | F_FILLS_LAYER) if status["fills_layer"] else (_flags[i] & ~F_FILLS_LAYER)
			if status.get("static_geometry", false) and (_flags[i] & F_ACTIVE):
				_flags[i] &= ~F_ACTIVE
				_active_count -= 1
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


## Cells written since the last take_delta(), unordered, no duplicates. Rules start their searches here.
## Usage: for i in b.touched()
func touched() -> PackedInt32Array:
	return PackedInt32Array(_touched.keys())


## Returns the change record [op, a, b, ...] since the last call and clears it (and touched()).
## Usage: var d := b.take_delta()
func take_delta() -> PackedInt32Array:
	var out: PackedInt32Array = _delta
	_delta = PackedInt32Array()
	_touched.clear()
	return out


## Writes CELL-slot content at i. Existing content is removed first with Cause.DISPLACED (ADR-0002 §3).
## Inactive cells and OVERLAY kinds are caller bugs and are rejected with an error.
## Setup / Resolving only. Usage: b.place(b.index(c), kind, hue, piece_uid)
func place(i: int, kind: int, hue: int, piece_uid: int) -> void:
	if not is_active(i) or _types.slot(kind) != ContentTypes.SLOT_CELL or kind == ContentTypes.KIND_EMPTY:
		push_error("BoardState.place: cell %d inactive or kind %d not placeable" % [i, kind])
		return
	if (_flags[i] & F_OCCUPIED) != 0:
		if not can_remove(i, Cause.DISPLACED):
			return
		remove(i, Cause.DISPLACED)
	_put(i, layer_of(i), kind, hue, piece_uid, _content_flags(kind))
	_log(Op.SET, i, 0)


## Clears CELL-slot content at i; no-op on an empty cell. Usage: b.remove(i, BoardState.Cause.CLEAR)
func remove(i: int, cause: int, force: bool = false) -> void:
	if i < 0 or i >= _kind.size():
		return
	var can_force: bool = force and not bool(_status.get(i, {}).get("fixed", false)) and not bool(_status.get(i, {}).get("locked", false))
	if (_flags[i] & F_OCCUPIED) == 0 or (not can_remove(i, cause) and not can_force):
		return
	if cause == Cause.DAMAGE:
		var status: Dictionary = _status.get(i, {})
		var health_key: String = "hits_left" if status.has("hits_left") else "hp"
		if int(status.get(health_key, 1)) > 1:
			status = status.duplicate(true)
			status[health_key] = int(status[health_key]) - 1
			set_status(i, status)
			return
	_take(i, layer_of(i))
	if _status.erase(i): # status belongs to the block
		_flags[i] &= ~F_HAS_STATUS
	_log(Op.REMOVE, i, cause)
	if cause == Cause.CLEAR and _overlay.has(i):
		set_overlay(i, {}) # ADR-0002 §3: overlays go when their cell is cleared


## Sets or clears (empty rec) the status of the block at i: rec = {status_id, counter, rule_id}.
## No-op on an empty cell when setting. Usage: b.set_status(i, {"status_id": 3, "counter": 2, "rule_id": &"ice"})
func set_status(i: int, rec: Dictionary) -> void:
	if rec.is_empty():
		if not _status.has(i):
			return
		_status.erase(i)
		_flags[i] &= ~F_HAS_STATUS
		_update_fill_status(i, {})
		_log(Op.STATUS, i, 0)
		return
	if (_flags[i] & F_OCCUPIED) == 0:
		return
	_status[i] = rec.duplicate(true)
	_flags[i] |= F_HAS_STATUS
	_update_fill_status(i, rec)
	if rec.get("static_geometry", false) and (_flags[i] & F_ACTIVE):
		_flags[i] &= ~F_ACTIVE
		_active_count -= 1
		_rebuild_layout()
		_log(Op.LAYOUT, 0, 0)
	_log(Op.STATUS, i, int(rec.get("status_id", 0)))


## Sets or clears (empty rec) the overlay of active cell i: rec = {type_id, data}.
## Usage: b.set_overlay(i, {"type_id": kind, "data": {}})
func set_overlay(i: int, rec: Dictionary) -> void:
	if rec.is_empty():
		if not _overlay.has(i):
			return
		_overlay.erase(i)
		_flags[i] &= ~F_HAS_OVERLAY
		_log(Op.OVERLAY, i, 0)
		return
	if not is_active(i):
		return
	_overlay[i] = rec
	_flags[i] |= F_HAS_OVERLAY
	_log(Op.OVERLAY, i, int(rec.get("type_id", 0)))


## Block record at i: {shape_id, piece_instance_id, owner, tags, status}; {} on an empty cell.
## Usage: b.get_record(i)["status"]
func get_record(i: int) -> Dictionary:
	if (_flags[i] & F_OCCUPIED) == 0:
		return {}
	# ponytail: no per-piece table yet (shape_id/owner/tags defaults); add pieces[uid] when owners/tags land (ADR-0009)
	return {"shape_id": &"", "piece_instance_id": _piece[i], "owner": 0, "tags": PackedStringArray(),
		"kind": _kind[i], "color": _color[i], "status": _status.get(i, {})}


## Changes gravity and rebuilds the layer ordering and counters. Setup / Resolving only.
## Usage: b.set_down(BoardState.Down.X_NEG)
func set_down(d: Down) -> void:
	if d == _spec_down:
		return
	_spec_down = d
	_rebuild_layout()
	_log(Op.LAYOUT, 0, 0)


## Turns a footprint column (all heights) on or off; content in a column turned off is removed (MASKED).
## Setup / Resolving only. Usage: b.set_active(2, 3, false)
func set_active(x: int, z: int, on: bool) -> void:
	if x < 0 or z < 0 or x >= _size.x or z >= _size.z:
		return
	var changed: bool = false
	for y: int in _size.y:
		var i: int = index(Vector3i(x, y, z))
		if is_active(i) == on:
			continue
		changed = true
		if not on:
			remove(i, Cause.MASKED)
			set_overlay(i, {})
			_flags[i] &= ~F_ACTIVE
			_active_count -= 1
		else:
			_flags[i] |= F_ACTIVE
			_active_count += 1
	if changed:
		_rebuild_layout()
		_log(Op.LAYOUT, 0, 0)


## Moves CELL content from one cell to another (displacing whatever is at the target). No-op if from is empty
## or to is inactive. Usage: b.move(from_i, to_i)
func move(from: int, to: int, force: bool = false) -> void:
	if from == to or (_flags[from] & F_OCCUPIED) == 0 or not is_active(to) or not can_move(from, force):
		return
	if (_flags[to] & F_OCCUPIED) != 0:
		if not can_remove(to, Cause.DISPLACED):
			return
		remove(to, Cause.DISPLACED)
	_relocate(from, layer_of(from), to, layer_of(to))
	_log(Op.MOVE, from, to)


## Slice collapse (Layer Clearing F1): empties every layer in cleared (REMOVE/CLEAR per cell), then drops each
## higher layer by the number of cleared layers beneath it (MOVE per cell). Order of cleared and duplicates
## do not matter; out-of-range layers are ignored. Setup / Resolving only. Usage: b.shift_layers(b.full_layers())
func shift_layers(cleared: PackedInt32Array) -> void:
	var is_cleared: PackedByteArray = PackedByteArray()
	is_cleared.resize(layer_count())
	var any: bool = false
	for k: int in cleared:
		if k >= 0 and k < is_cleared.size():
			is_cleared[k] = 1
			any = true
	if not any:
		return
	for k: int in is_cleared.size():
		if is_cleared[k] == 1:
			for i: int in layer_cells(k):
				remove(i, Cause.CLEAR)
	var below: int = 0 # cleared layers beneath k
	for k: int in is_cleared.size():
		if is_cleared[k] == 1:
			below += 1
			continue
		if below == 0:
			continue
		# Same position j in a layer is the same footprint cell: layer_cells is ascending within a layer.
		var src: PackedInt32Array = layer_cells(k)
		var dst: PackedInt32Array = layer_cells(k - below)
		for j: int in src.size():
			if (_flags[src[j]] & F_OCCUPIED) == 0:
				continue
			if not can_move(src[j]):
				continue
			var chamber_bottom: int = -1
			for below_layer: int in k:
				var below_cell: int = layer_cells(below_layer)[j]
				if get_kind(below_cell) != 0 and not can_move(below_cell):
					chamber_bottom = below_layer
			var distance: int = 0
			for clear_layer: int in range(chamber_bottom + 1, k):
				if is_cleared[clear_layer]:
					distance += 1
			if distance == 0:
				continue
			dst = layer_cells(k - distance)
			if not is_active(dst[j]):
				remove(src[j], Cause.MASKED)
				continue
			if get_kind(dst[j]) != 0:
				continue
			_relocate(src[j], k, dst[j], k - distance)
			_log(Op.MOVE, src[j], dst[j])


func _content_flags(kind: int) -> int:
	var f: int = F_OCCUPIED
	if _types.is_solid(kind):
		f |= F_SOLID
	if _types.fills_layer(kind):
		f |= F_FILLS_LAYER
	return f


## Raw write of content into an empty cell in layer k, keeping layer counters in step.
func _put(i: int, k: int, kind: int, hue: int, piece_uid: int, content_flags: int) -> void:
	_kind[i] = kind
	_color[i] = hue
	_piece[i] = piece_uid
	_flags[i] = (_flags[i] & ~_CONTENT_BITS) | content_flags
	if content_flags & F_FILLS_LAYER and _flags[i] & F_ACTIVE:
		_layer_filled[k] += 1
	if content_flags & F_SOLID:
		_layer_solid[k] += 1


## Raw clear of occupied cell i in layer k, keeping layer counters in step.
func _take(i: int, k: int) -> void:
	var f: int = _flags[i]
	if f & F_FILLS_LAYER and f & F_ACTIVE:
		_layer_filled[k] -= 1
	if f & F_SOLID:
		_layer_solid[k] -= 1
	_kind[i] = 0
	_color[i] = 0
	_piece[i] = 0
	_flags[i] = f & ~_CONTENT_BITS


## Raw move of content between cells (target must be empty). No delta entry.
func _relocate(from: int, kf: int, to: int, kt: int) -> void:
	_put(to, kt, _kind[from], _color[from], _piece[from], _flags[from] & _CONTENT_BITS)
	_take(from, kf)
	if _status.has(from): # status moves with the block (ADR-0002 §7 Block Status Effects)
		_status[to] = _status[from]
		_status.erase(from)
		_flags[from] &= ~F_HAS_STATUS
		_flags[to] |= F_HAS_STATUS


func _log(op: int, a: int, b: int) -> void:
	_delta.append(op)
	_delta.append(a)
	_delta.append(b)
	if op == Op.LAYOUT:
		return
	_touched[a] = true
	if op == Op.MOVE:
		_touched[b] = true


## True when the cell currently contributes to a full layer. Example: b.fills_layer_at(c).
func fills_layer_at(c: Vector3i) -> bool:
	return in_bounds(c) and (_flags[index(c)] & F_FILLS_LAYER) != 0

## Overlay record, independent of the block. Example: b.get_overlay(b.index(c)).
func get_overlay(i: int) -> Dictionary:
	return _overlay.get(i, {})

## Simultaneous content relocation, preserving block status and allowing cycles. Example: b.move_batch(old, new).
func move_batch(src: Array[Vector3i], dst: Array[Vector3i], force: bool = false) -> void:
	if src.size() != dst.size():
		return
	var records: Array[Dictionary] = []
	for c: Vector3i in src:
		if not in_bounds(c):
			records.append({})
			continue
		var i: int = index(c)
		if not can_move(i, force):
			return
		records.append({"kind": _kind[i], "color": _color[i], "piece": _piece[i], "status": _status.get(i, {}).duplicate(true)})
	for c: Vector3i in dst:
		if in_bounds(c) and get_kind(index(c)) != 0 and not src.has(c) and not can_remove(index(c), Cause.DISPLACED):
			return
	for c: Vector3i in src:
		if in_bounds(c):
			remove(index(c), Cause.DISPLACED, force)
	for n: int in dst.size():
		var rec: Dictionary = records[n]
		var c: Vector3i = dst[n]
		if rec.is_empty() or rec["kind"] == 0 or not in_bounds(c) or not is_active(index(c)):
			continue
		place(index(c), rec["kind"], rec["color"], rec["piece"])
		set_status(index(c), rec["status"])

## Silent rescue removal followed by slice shift; returns cubes removed. Example: b.wipe_bottom(3).
func wipe_bottom(k: int) -> int:
	k = clampi(k, 0, layer_count())
	var removed: int = 0
	for layer: int in k:
		for i: int in layer_cells(layer):
			if get_kind(i) != 0:
				removed += 1
			remove(i, Cause.RESCUE)
			set_overlay(i, {})
	var layers: PackedInt32Array = PackedInt32Array()
	for layer: int in k:
		layers.append(layer)
	shift_layers(layers)
	return removed

## Inverts each occupied column through its stack height then removes empty layers (EV03). Example: b.flip_stack().
func flip_stack() -> void:
	var height: int = stack_height()
	if height < 0:
		return
	var src: Array[Vector3i] = []
	var dst: Array[Vector3i] = []
	for k: int in range(height + 1):
		var from_layer: PackedInt32Array = layer_cells(k)
		var to_layer: PackedInt32Array = layer_cells(height - k)
		for j: int in from_layer.size():
			if get_kind(from_layer[j]) != 0:
				src.append(cell(from_layer[j]))
				dst.append(cell(to_layer[j]))
	move_batch(src, dst)
	var empty: PackedInt32Array = PackedInt32Array()
	for k: int in range(height + 1):
		if _layer_solid[k] == 0:
			empty.append(k)
	shift_layers(empty)

## Gravity settlement of individual blocks, bottom first. Example: b.settle_cells().
func settle_cells() -> void:
	var down: Vector3i = down_vector()
	for k: int in layer_count():
		for i: int in layer_cells(k):
			if get_kind(i) == 0 or not can_move(i):
				continue
			var c: Vector3i = cell(i)
			var distance: int = 0
			while is_free(c + down * (distance + 1)):
				distance += 1
			if distance > 0:
				move(i, index(c + down * distance))

## Stable board contents for replay diagnostics. Example: var hash_data := b.snapshot().
func snapshot() -> Dictionary:
	return {"kind": _kind, "color": _color, "piece": _piece, "flags": _flags,
		"status": _status, "overlay": _overlay, "down": _spec_down, "floor": _floor_layer, "h_play": _h_play}

func restore(state: Dictionary) -> void:
	_kind = state["kind"].duplicate()
	_color = state["color"].duplicate()
	_piece = state["piece"].duplicate()
	_flags = state["flags"].duplicate()
	_status = state["status"].duplicate(true)
	_overlay = state["overlay"].duplicate(true)
	_spec_down = state["down"]
	_floor_layer = int(state.get("floor", 0))
	_h_play = int(state.get("h_play", _h_play))
	_active_count = 0
	for flags: int in _flags:
		if flags & F_ACTIVE:
			_active_count += 1
	_rebuild_layout()
	_delta.clear()
	_touched.clear()
	_log(Op.LAYOUT, 0, 0)
	for i: int in _kind.size():
		_log(Op.SET, i, 0)

func can_move(i: int, force: bool = false) -> bool:
	var status: Dictionary = _status.get(i, {})
	return not bool(status.get("fixed", false)) and not bool(status.get("locked", false)) and (force or not bool(status.get("anchored", false)))

func can_remove(i: int, cause: int) -> bool:
	var status: Dictionary = _status.get(i, {})
	if cause == Cause.MASKED:
		return true
	if bool(status.get("fixed", false)):
		return false
	if bool(status.get("anchored", false)) and cause != Cause.DAMAGE:
		return false
	if bool(status.get("locked", false)) and cause == Cause.DISPLACED:
		return false
	if cause == Cause.CLEAR and (bool(status.get("clear_protected", false)) or bool(status.get("locked", false))):
		return false
	if bool(status.get("vined", false)) and cause == Cause.TRIM:
		return false
	return true

func _update_fill_status(i: int, status: Dictionary) -> void:
	if get_kind(i) == 0:
		return
	var previous: bool = bool(_flags[i] & F_FILLS_LAYER)
	var fills: bool = bool(status.get("fills_layer", _types.fills_layer(_kind[i])))
	if previous == fills:
		return
	_flags[i] = (_flags[i] | F_FILLS_LAYER) if fills else (_flags[i] & ~F_FILLS_LAYER)
	if _flags[i] & F_ACTIVE:
		_layer_filled[layer_of(i)] += 1 if fills else -1

## Structural floor loss is silent and never shifts the surviving stack.
func set_floor(layer: int) -> void:
	var target: int = clampi(layer, _floor_layer, layer_count() - 1)
	for k: int in range(_floor_layer, target):
		for i: int in layer_cells(k):
			remove(i, Cause.MASKED)
			if _flags[i] & F_ACTIVE:
				_flags[i] &= ~F_ACTIVE
				_active_count -= 1
	_floor_layer = target
	_rebuild_layout()
	_log(Op.LAYOUT, 0, 0)

func floor_layer() -> int:
	return _floor_layer

func set_height_limit(height: int) -> void:
	_h_play = clampi(height, 1, _size.y)
	_log(Op.LAYOUT, 0, 0)

func raise_junk(layers: int, kind: int) -> void:
	var count: int = clampi(layers, 0, layer_count())
	for k: int in range(layer_count() - 1, -1, -1):
		for i: int in layer_cells(k):
			if get_kind(i) == 0 or not can_move(i):
				continue
			var c: Vector3i = cell(i) - down_vector() * count
			if not in_bounds(c):
				remove(i, Cause.DISPLACED)
			elif is_active(index(c)) and get_kind(index(c)) == 0:
				move(i, index(c))
	for k: int in range(_floor_layer, mini(_floor_layer + count, layer_count())):
		for i: int in layer_cells(k):
			if is_active(i) and get_kind(i) == 0:
				place(i, kind, 0, 0)


## Authored footprint spawn anchor. Example: b.spawn_anchor().x.
func spawn_anchor() -> Vector2i:
	return _spawn_anchor
