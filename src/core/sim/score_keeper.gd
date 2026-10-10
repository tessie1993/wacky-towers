class_name ScoreKeeper extends RefCounted
## In-level score (Scoring & Stars F2/F3). Integer math only; pure. Rescue wipes never reach it.

const CAP := 9_999_999
const MILLI := 1000
## Reference layer size of the F2 board-size scaling (8 x 8).
const REF_ACTIVE_CELLS := 64
const KNOB_CLEAR_BASE := &"goal.clear_base"
const KNOB_COMBO_BONUS := &"goal.combo_bonus"
const KNOB_CHAIN_BONUS := &"goal.chain_bonus"
const KNOB_DROP_POINTS := &"goal.drop_points"
const KNOB_PLACE_POINTS := &"goal.place_points"

var _clear_base: int
var _combo_bonus: int
var _chain_bonus_milli: int
var _drop_points: int
var _place_points: int
var _total: int = 0
var _combo: int = 0

func restore(state: Dictionary) -> void:
	_total = int(state.get("total", 0))
	_combo = int(state.get("combo", 0))


## `knobs` maps the goal.* ids (clear_base, combo_bonus, chain_bonus in milli, drop_points, place_points) to ints;
## missing ids use the GDD defaults (100, 50, 500, 2, 1). Usage: `ScoreKeeper.new({&"goal.clear_base": 100})`.
func _init(knobs: Dictionary) -> void:
	_clear_base = _knob(knobs, KNOB_CLEAR_BASE, 100)
	_combo_bonus = _knob(knobs, KNOB_COMBO_BONUS, 50)
	_chain_bonus_milli = _knob(knobs, KNOB_CHAIN_BONUS, 500)
	_drop_points = _knob(knobs, KNOB_DROP_POINTS, 2)
	_place_points = _knob(knobs, KNOB_PLACE_POINTS, 1)


## place_points per locked cube; returns points added. Usage: `keeper.on_place(4)`.
func on_place(cubes: int = 1) -> int:
	return _add(_place_points * cubes)


## drop_points per cell, hard drops only; returns points added. Usage: `keeper.on_drop(9, true)`.
func on_drop(cells: int, hard: bool) -> int:
	return _add(_drop_points * cells) if hard else 0


## F2 + combo: clear_base x n(n+1)/2 x A/64 x (1 + chain_bonus x (round-1)), plus combo_bonus x (k-1) for the
## k-th consecutive clearing lock. `active_cells` is A (Board F1). Returns points added; 0 layers scores nothing.
## Call once per lock (combo counts calls). Usage: `keeper.on_clear(2, 1, 36)` -> 169 on the first clear of a 6x6.
func on_clear(layers: int, chain_round: int, active_cells: int = REF_ACTIVE_CELLS, new_lock: bool = true) -> int:
	if layers <= 0:
		return 0
	if new_lock:
		_combo += 1
	var tri: int = layers * (layers + 1) / 2
	var den: int = REF_ACTIVE_CELLS * MILLI
	var num: int = _clear_base * tri * active_cells * (MILLI + _chain_bonus_milli * (maxi(chain_round, 1) - 1))
	return _add((num + den / 2) / den + (_combo_bonus * (_combo - 1) if new_lock else 0))


## Score so far. Usage: `keeper.total()`.
func total() -> int:
	return _total

func award(points: int) -> int:
	return _add(maxi(0, points))


## Consecutive clearing locks so far (0 = idle). Usage: `keeper.combo()`.
func combo() -> int:
	return _combo


## A lock that cleared nothing, or a warning, ends the combo. Usage: `keeper.reset_combo()`.
func reset_combo() -> void:
	_combo = 0


func _add(points: int) -> int:
	var before: int = _total
	_total = mini(_total + points, CAP)
	return _total - before


static func _knob(knobs: Dictionary, id: StringName, fallback: int) -> int:
	var v: Variant = knobs.get(id, knobs.get(String(id)))
	return v if typeof(v) == TYPE_INT else fallback


## Mutable score state for deterministic replay validation. Example: keeper.snapshot().
func snapshot() -> Dictionary:
	return {"total": _total, "combo": _combo}
