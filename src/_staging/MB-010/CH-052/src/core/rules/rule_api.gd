class_name RuleApi extends RefCounted
## The only object plugins see (ADR-0004 section 7). READ SUBSET (CH-052): queries only, no writes.
## Writes (set_cell, request_*, emit, rng) arrive with CH-091. Built by the sim per board; injected, never global.
## Usage: var api := RuleApi.new(board, knobs, rule_def.params); if api.is_free(c): ...

var _board: BoardState
var _knobs: KnobRegistry
var _params: Dictionary
var _piece: ActivePiece


## Binds the facade to one board state, its effective knobs and the calling rule params.
## Defaults let tests build an unbound facade (tests/unit/rules/rule_value_types_test.gd calls RuleApi.new()).
func _init(p_board: BoardState = null, p_knobs: KnobRegistry = null, p_params: Dictionary = {}) -> void:
	_board = p_board
	_knobs = p_knobs
	_params = p_params


## The sim sets the current falling piece (or null) so plugins can read it.
func bind_piece(p_piece: ActivePiece) -> void:
	_piece = p_piece


## Board size in cells.
func board_size() -> Vector3i:
	return _board.size()


## True if the cell is in bounds, active and not solid.
func is_free(c: Vector3i) -> bool:
	return _board.is_free(c)


## True if every cell is free.
func can_place(cells: Array[Vector3i]) -> bool:
	return _board.can_place(cells)


## Free steps the cells can move along unit dir before blocking.
func cast(cells: Array[Vector3i], dir: Vector3i) -> int:
	return _board.cast(cells, dir)


## True if the cell is in bounds and part of the play mask.
func is_active(c: Vector3i) -> bool:
	return _board.in_bounds(c) and _board.is_active(_board.index(c))


## Content kind id at the cell (0 = empty, also out of bounds).
func kind_at(c: Vector3i) -> int:
	return _board.get_kind(_board.index(c)) if _board.in_bounds(c) else 0


## Colour id at the cell (0 = none, also out of bounds).
func color_at(c: Vector3i) -> int:
	return _board.get_color(_board.index(c)) if _board.in_bounds(c) else 0


## Unit vector gravity points along.
func down_vector() -> Vector3i:
	return _board.down_vector()


## Number of layers along the down axis.
func layer_count() -> int:
	return _board.layer_count()


## Layer index (0 = floor end) of an in-bounds cell.
func layer_of(c: Vector3i) -> int:
	return _board.layer_of(_board.index(c))


## True if layer k has no empty active cell.
func layer_full(k: int) -> bool:
	return _board.layer_full(k)


## Indices of all full layers.
func full_layers() -> PackedInt32Array:
	return _board.full_layers()


## Highest layer holding solid content; -1 when empty.
func stack_height() -> int:
	return _board.stack_height()


## True if solid content sits at or above the height limit.
func over_limit() -> bool:
	return _board.over_limit()


## World cells of the falling piece; empty when none.
func piece_cells() -> Array[Vector3i]:
	if _piece != null:
		return _piece.cells()
	var none: Array[Vector3i] = []
	return none


## Effective knob value (null if unknown). Scalars are milli-units (ADR-0004 section 3).
func knob(id: StringName) -> Variant:
	return _knobs.value(id)


## Effective knob as int (0 if unknown or not a number).
func knob_int(id: StringName) -> int:
	return _knobs.int_value(id)


## Effective knob as bool (false if unknown or not a bool).
func knob_flag(id: StringName) -> bool:
	return _knobs.flag(id)


## This rule own param by name; fallback if absent.
func param(param_name: StringName, fallback: Variant = null) -> Variant:
	return _params.get(String(param_name), _params.get(param_name, fallback))
