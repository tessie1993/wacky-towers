class_name FpGame extends RefCounted
## First-playable pure simulation: gravity, lock delay, spin with kicks, clears, win/lose.

enum State { PLAYING, WON, LOST }

const LOCK_DELAY_MS: int = 500
const MAX_LOCK_RESETS: int = 15
const SOFT_DROP_MULT: float = 20.0
const SPAWN_ROOM: int = 4
const KICKS: Array[Vector3i] = [
	Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1),
	Vector3i(0, 1, 0),
]

signal changed
signal piece_locked(cells: Array[Vector3i], colour: int)
signal layers_cleared(ys: PackedInt32Array)
signal finished(state: int, stars: int)

var board: FpBoard
var state: State = State.PLAYING
var active_cells: Array[Vector3i] = []
var active_shape: String = ""
var ghost_cells: Array[Vector3i] = []
var next_shapes: PackedStringArray = PackedStringArray()
var layers_cleared_total: int = 0
var goal_n: int = 4
var elapsed_ms: int = 0

var _level: Dictionary
var _seed: int = 0
var _bag: FpBag
var _w: int = 4
var _d: int = 4
var _h_play: int = 8
var _g0: float = 0.6
var _t2: int = 145000
var _t3: int = 105000
var _offsets: Array[Vector3i] = []
var _origin: Vector3i = Vector3i.ZERO
var _pivot_idx: int = 0  # index into _offsets of the pivot cube (rotation order is preserved)
var _soft: bool = false
var _fall_acc_ms: float = 0.0
var _lock_ms: int = 0
var _lock_resets: int = 0


func _init(level: Dictionary, rng_seed: int) -> void:
	_level = level
	_seed = rng_seed
	var b: Dictionary = level.get("board", {})
	_w = int(b.get("width", 4))
	_d = int(b.get("depth", 4))
	_h_play = int(b.get("h_play", 8))
	var knobs: Dictionary = level.get("knobs", {})
	_g0 = float(knobs.get("fall.g0", 0.6))
	var goal: Dictionary = level.get("goal", {})
	goal_n = int(goal.get("n", 4))
	var st: Dictionary = level.get("stars", {})
	_t2 = int(st.get("t2", 145000))
	_t3 = int(st.get("t3", 105000))
	_reset()


## Resets the whole run (same level and seed) and spawns the first piece.
func restart() -> void:
	_reset()
	changed.emit()


## Shifts the active piece by (dx, dz). Returns true if it moved.
func move(dx: int, dz: int) -> bool:
	if state != State.PLAYING or active_cells.is_empty():
		return false
	var new_origin: Vector3i = _origin + Vector3i(dx, 0, dz)
	if not board.can_place(_world(_offsets, new_origin)):
		return false
	_origin = new_origin
	_after_successful_move()
	return true


## Spins the active piece (+1 right, -1 left) about world Y. Returns true if it changed.
func spin(dir: int) -> bool:
	return rotate(1, -dir)


## Turns the active piece 90 degrees about world axis (0=X, 1=Y, 2=Z), pivot cube fixed,
## kicks +-x, +-z, then +y. Returns true if it changed.
func rotate(axis: int, dir: int) -> bool:
	if state != State.PLAYING or active_cells.is_empty():
		return false
	var new_offsets: Array[Vector3i] = FpPieces.rotate(_offsets, axis, dir, _pivot_idx)
	if _same_set(new_offsets, _offsets):
		return false
	for k: Vector3i in KICKS:
		var o: Vector3i = _origin + k
		if board.can_place(_world(new_offsets, o)):
			_offsets = new_offsets
			_origin = o
			_after_successful_move()
			return true
	return false


## Enables or disables soft drop (fall speed x20).
func set_soft_drop(on: bool) -> void:
	_soft = on


## Drops the active piece to the ghost position and locks it at once.
func hard_drop() -> void:
	if state != State.PLAYING or active_cells.is_empty():
		return
	_origin = _drop_origin()
	_lock_piece()
	changed.emit()


## Advances gravity, lock timer and elapsed time by delta_ms.
func tick(delta_ms: int) -> void:
	if state != State.PLAYING or active_cells.is_empty():
		return
	elapsed_ms += delta_ms
	if _resting():
		_lock_ms += delta_ms
		if _lock_ms >= LOCK_DELAY_MS:
			_lock_piece()
	else:
		var rate: float = _g0 * (SOFT_DROP_MULT if _soft else 1.0)
		if rate > 0.0:
			_fall_acc_ms += float(delta_ms)
			if _fall_acc_ms >= 1000.0 / rate:
				_fall_acc_ms = 0.0
				_origin += Vector3i(0, -1, 0)
				if _resting():
					_lock_ms = 0
	_refresh_view_cells()
	changed.emit()


## Star rating from elapsed time: 3 if <= t3, 2 if <= t2, else 1.
func stars() -> int:
	if elapsed_ms <= _t3:
		return 3
	if elapsed_ms <= _t2:
		return 2
	return 1


func _reset() -> void:
	board = FpBoard.new(_w, _d, _h_play + SPAWN_ROOM)
	var p: Dictionary = _level.get("pieces", {})
	var shapes: PackedStringArray = PackedStringArray()
	for s: Variant in p.get("shapes", ["i", "o", "t", "l", "s"]):
		shapes.append(String(s))
	var opening: PackedStringArray = PackedStringArray()
	for s: Variant in p.get("opening_set", []):
		opening.append(String(s))
	_bag = FpBag.new(shapes, opening, _seed)
	state = State.PLAYING
	layers_cleared_total = 0
	elapsed_ms = 0
	_soft = false
	active_cells = []
	ghost_cells = []
	active_shape = ""
	_spawn()


func _spawn() -> void:
	active_shape = _bag.next()
	_offsets = FpPieces.cells(active_shape)
	var max_x: int = 0
	var max_z: int = 0
	for c: Vector3i in _offsets:
		max_x = maxi(max_x, c.x)
		max_z = maxi(max_z, c.z)
	var bw: int = max_x + 1
	var bd: int = max_z + 1
	_pivot_idx = maxi(_offsets.find(FpPieces.pivot(_offsets)), 0)
	_origin = Vector3i((_w - bw) / 2, _h_play, (_d - bd) / 2)
	_fall_acc_ms = 0.0
	_lock_ms = 0
	_lock_resets = 0
	next_shapes = _bag.peek(3)
	var cells: Array[Vector3i] = _world(_offsets, _origin)
	if not board.can_place(cells):
		_refresh_view_cells()
		_finish(State.LOST)
		return
	_refresh_view_cells()


func _lock_piece() -> void:
	var cells: Array[Vector3i] = _world(_offsets, _origin)
	var colour: int = int(FpPieces.COLOURS.get(active_shape, 0))
	board.lock(cells, colour)
	active_cells = []
	ghost_cells = []
	piece_locked.emit(cells, colour)
	var ys: PackedInt32Array = board.clear_full_layers()
	if ys.size() > 0:
		layers_cleared_total += ys.size()
		layers_cleared.emit(ys)
	if layers_cleared_total >= goal_n:
		_finish(State.WON)
		return
	_spawn()


func _finish(s: State) -> void:
	state = s
	if s != State.PLAYING:
		if s == State.WON:
			active_cells = []
			ghost_cells = []
	changed.emit()
	finished.emit(int(s), stars() if s == State.WON else 0)


func _after_successful_move() -> void:
	if _resting() or _lock_ms > 0:
		if _lock_resets < MAX_LOCK_RESETS:
			_lock_resets += 1
			_lock_ms = 0
	_refresh_view_cells()
	changed.emit()


func _resting() -> bool:
	return not board.can_place(_world(_offsets, _origin + Vector3i(0, -1, 0)))


func _drop_origin() -> Vector3i:
	var o: Vector3i = _origin
	while board.can_place(_world(_offsets, o + Vector3i(0, -1, 0))):
		o += Vector3i(0, -1, 0)
	return o


func _refresh_view_cells() -> void:
	if state == State.PLAYING and not _offsets.is_empty():
		active_cells = _world(_offsets, _origin)
		ghost_cells = _world(_offsets, _drop_origin())
	elif state == State.LOST:
		ghost_cells = []


func _world(offsets: Array[Vector3i], origin: Vector3i) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	for c: Vector3i in offsets:
		out.append(c + origin)
	return out


func _same_set(a: Array[Vector3i], b: Array[Vector3i]) -> bool:
	if a.size() != b.size():
		return false
	for c: Vector3i in a:
		if not b.has(c):
			return false
	return true
