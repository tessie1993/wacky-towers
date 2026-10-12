class_name Movement extends RefCounted
## Pure collision authority for the falling piece (Movement & Rotation GDD rules 2-13, 17). Never writes the board.
## Moves and rotations mutate only the ActivePiece they are given, and only on success.
## Usage: var r: Dictionary = Movement.try_translate(piece, board, Vector3i(1, 0, 0))

enum Result { OK, BLOCKED, DISABLED }

const R_NONE: StringName = &""
const R_OUT: StringName = &"out_of_bounds"
const R_INACTIVE: StringName = &"inactive"
const R_OCCUPIED: StringName = &"occupied"

## Default for control.max_up_kicks_per_piece (GDD rule 12).
const DEFAULT_MAX_UP_KICKS: int = 2
const ALL_AXES: Array[int] = [Orientations.Axis.X, Orientations.Axis.Y, Orientations.Axis.Z]


## Shifts the piece by delta if every target cell passes can_place. Returns {result, reason}.
## On BLOCKED nothing changes and reason is that of the first failing cell, in cell order.
static func try_translate(p: ActivePiece, board: BoardState, delta: Vector3i) -> Dictionary:
	var moved: Array[Vector3i] = p.cells_at(p.orient, p.pivot + delta)
	var reason: StringName = first_block_reason(board, moved)
	if reason != R_NONE:
		return {"result": Result.BLOCKED, "reason": reason}
	p.pivot += delta
	return {"result": Result.OK, "reason": R_NONE}


## Free cells the piece can fall along its board's down direction (0 if blocked now). Usage: Movement.drop_distance(p, b)
static func drop_distance(p: ActivePiece, board: BoardState) -> int:
	return board.cast(p.cells(), board.down_vector())


## GDD F4: true if any cube has the floor or solid content directly below it (along down). Overlay and holes never support.
static func is_resting(p: ActivePiece, board: BoardState) -> bool:
	var down: Vector3i = board.down_vector()
	for c: Vector3i in p.cells():
		var below: Vector3i = c + down
		if not board.in_bounds(below):
			return true
		if board.is_active(board.index(below)) and not board.is_free(below):
			return true
	return false


## Why a single cell fails can_place: out_of_bounds, inactive, occupied; R_NONE if it passes.
static func blocked_reason(board: BoardState, cell: Vector3i) -> StringName:
	if not board.in_bounds(cell):
		return R_OUT
	if not board.is_active(board.index(cell)):
		return R_INACTIVE
	if not board.is_free(cell):
		return R_OCCUPIED
	return R_NONE


## Reason of the first failing cell in order, R_NONE if all pass.
static func first_block_reason(board: BoardState, cells: Array[Vector3i]) -> StringName:
	for c: Vector3i in cells:
		var r: StringName = blocked_reason(board, c)
		if r != R_NONE:
			return r
	return R_NONE


## Turns the piece 90 degrees about a world axis through the pivot (sign +1/-1), kicking if needed (GDD rules 9-13, F2).
## opts (all optional): enabled_axes (Array of Orientations.Axis ints, default all), max_up_kicks_per_piece (2), plus the
## KickTable opts kick_enabled, kick_off_axis, kick_wide_min_extent, kick_order.
## Returns {result, reason, kicked, offset}. DISABLED/BLOCKED leave the piece and its undo record untouched.
## Success goes through ActivePiece.apply_rotation (records the undo record; the restore itself is CH-094).
static func try_rotate(p: ActivePiece, board: BoardState, axis: Orientations.Axis, sign: int, opts: Dictionary) -> Dictionary:
	var enabled: Array = opts.get("enabled_axes", ALL_AXES)
	if not enabled.has(int(axis)):
		return _rot(Result.DISABLED, R_NONE, false, Vector3i.ZERO)
	var new_orient: int = Orientations.turn(p.orient, axis, sign)
	var in_place: Array[Vector3i] = p.cells_at(new_orient, p.pivot)
	var reason: StringName = first_block_reason(board, in_place)
	if reason == R_NONE:
		p.apply_rotation(axis, sign)
		return _rot(Result.OK, R_NONE, false, Vector3i.ZERO)

	var down: Vector3i = board.down_vector()
	var max_up: int = int(opts.get("max_up_kicks_per_piece", DEFAULT_MAX_UP_KICKS))
	var cands: Array[Vector3i] = KickTable.candidates(axis, down, _footprint_center(board, down), p.pivot,
			_longest_extent(p), opts)
	for i: int in range(1, cands.size()): # [0] is the in-place test above
		var off: Vector3i = cands[i]
		var up: bool = KickTable.is_up_kick(off, down)
		if up and not p.can_up_kick(max_up):
			continue
		if KickTable.is_wide(off) and not board.can_place(p.cells_at(new_orient, p.pivot + off / 2)):
			continue # a wide kick needs its 1-cell step free too, so the piece never leaps a wall
		if board.can_place(p.cells_at(new_orient, p.pivot + off)):
			if up:
				p.spend_up_kick()
			p.apply_rotation(axis, sign, off)
			return _rot(Result.OK, R_NONE, true, off)
	return _rot(Result.BLOCKED, reason, false, Vector3i.ZERO)


static func _rot(result: Result, reason: StringName, kicked: bool, offset: Vector3i) -> Dictionary:
	return {"result": result, "reason": reason, "kicked": kicked, "offset": offset}


# Longest side of the piece's current bounding box.
static func _longest_extent(p: ActivePiece) -> int:
	var b: Vector3i = p.shape.bbox(p.orient)
	return maxi(b.x, maxi(b.y, b.z))


# Centre of the full footprint in the two ground coordinates (non-down axes, x/y/z order).
# ponytail: ignores a masked footprint; use the active-cell centroid if masked boards need centre-biased kicks.
static func _footprint_center(board: BoardState, down: Vector3i) -> Vector2:
	var s: Vector3i = board.size()
	var v: Array[float] = []
	for a: int in 3:
		if down[a] == 0:
			v.append((s[a] - 1) / 2.0)
	return Vector2(v[0], v[1])
