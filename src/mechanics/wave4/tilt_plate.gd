class_name TiltPlateRule extends RuleBehaviour
## Wave 4 A2 balance levels (design/gdd/minigame-mechanics-wave4.md §A2 `tilt_plate`, simplified brief).
## The board is a plate on a pivot. After every lock (at on_resolve_end, so clears are already collapsed, edge
## case c) the tilt τ of the locked cubes' centre of mass is recomputed with the GDD formula in permille:
## τ = 1000·max(|M_x|/(N·(W−1)), |M_z|/(N·(D−1))). Fixed kinds (`fixed_kinds`, rocks) are bolted to the plate and
## excluded (edge case d). τ ≥ warn_at·slip_threshold warns; τ ≥ slip_threshold for `slip_after_resolves`
## resolves makes the `slip_count` top-most cubes of the heavy half slide off the rim (removed, Cause.TRIM).
## The heavy-side tie-break (x wins) matches WobbleRule.heavier_side.
## This grid rule is the deterministic fallback used by bots and versus. Balance levels are set to use real (Jolt)
## physics, so the `physics` param (default false) is reserved for that path. A Jolt presentation and physics path
## is a planned follow-up and is NOT implemented: setting `physics` to true currently changes nothing.
## HUD events: `balance {tilt, tilt_permille, dir, threshold, warn}` every resolve, `balance_warning {tilt, dir}`,
## `tilt_danger {resolves_left}`, `tilt_popoff {cells, dir, tilt}`.
const PLUGIN_ID := &"tilt_plate"
var _tau: int = 0
var _dir: Vector3i = Vector3i.ZERO
var _warned: bool = false
var _danger: int = 0


func subscribed_hooks() -> Array[StringName]:
	return [&"on_resolve_end"]


func handle(_hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	var cells: Array[Vector3i] = weighted_cells(api, api.param(&"fixed_kinds", ["rock"]))
	var tilt: Dictionary = measure(api.board_size(), cells)
	_tau = int(tilt["tau"])
	_dir = tilt["dir"]
	var slip_at: int = roundi(float(api.param(&"slip_threshold", 0.6)) * 1000.0)
	var warn_at: int = roundi(float(api.param(&"warn_at", 0.7)) * float(slip_at))
	var shown: float = float(_tau) / 1000.0
	api.emit(&"balance", {"tilt": shown, "tilt_permille": _tau, "dir": _dir, "threshold": float(slip_at) / 1000.0, "warn": _tau >= warn_at})
	if _tau < warn_at:
		_warned = false
		_danger = 0
		return
	if not _warned:
		_warned = true
		api.emit(&"balance_warning", {"tilt": shown, "dir": _dir})
	if _tau < slip_at:
		_danger = 0
		return
	_danger += 1
	var needed: int = maxi(1, int(api.param(&"slip_after_resolves", 1)))
	if _danger < needed:
		api.emit(&"tilt_danger", {"resolves_left": needed - _danger})
		return
	_danger = 0
	var removed: Array[Vector3i] = slip_cells(api, cells, _dir, maxi(0, int(api.param(&"slip_count", 1))))
	for c: Vector3i in removed:
		api.remove_cell(c, BoardState.Cause.TRIM)
	api.emit(&"tilt_popoff", {"cells": removed, "dir": _dir, "tilt": shown})


## Occupied cubes that weigh on the plate (kinds listed in `fixed` are excluded). Usage: weighted_cells(api, ["rock"]).
static func weighted_cells(api: RuleApi, fixed: Variant) -> Array[Vector3i]:
	var fixed_kinds: Array[int] = []
	if fixed is Array:
		for id: Variant in fixed:
			var k: int = api.kind_of(StringName(str(id)))
			if k > 0:
				fixed_kinds.append(k)
	var result: Array[Vector3i] = []
	for c: Vector3i in MechanicsCells.occupied(api):
		if not fixed_kinds.has(api.kind_at(c)):
			result.append(c)
	return result


## {"tau": permille 0-1000, "dir": unit heavy direction on x or z}. Empty → τ 0; a 1-wide axis has no term.
static func measure(size: Vector3i, cells: Array[Vector3i]) -> Dictionary:
	var n: int = cells.size()
	if n == 0:
		return {"tau": 0, "dir": Vector3i.ZERO}
	var mx: int = 0
	var mz: int = 0
	for c: Vector3i in cells:
		mx += 2 * c.x - (size.x - 1)
		mz += 2 * c.z - (size.z - 1)
	var tx: int = absi(mx) * 1000 / (n * (size.x - 1)) if size.x > 1 else 0
	var tz: int = absi(mz) * 1000 / (n * (size.z - 1)) if size.z > 1 else 0
	var tau: int = maxi(tx, tz)
	if tau == 0:
		return {"tau": 0, "dir": Vector3i.ZERO}
	return {"tau": tau, "dir": Vector3i(signi(mx), 0, 0) if tx >= tz else Vector3i(0, 0, signi(mz))}


## The `count` top-most cubes of the heavy half (highest layer, then outermost, then canonical order).
## Picking from the top never leaves a floating cube behind.
static func slip_cells(api: RuleApi, cells: Array[Vector3i], dir: Vector3i, count: int) -> Array[Vector3i]:
	var size: Vector3i = api.board_size()
	var heavy: Array[Vector3i] = []
	for c: Vector3i in cells:
		if (2 * c.x - (size.x - 1)) * dir.x + (2 * c.z - (size.z - 1)) * dir.z > 0:
			heavy.append(c)
	var picked: Array[Vector3i] = []
	while picked.size() < count and not heavy.is_empty():
		var best: int = 0
		for i: int in range(1, heavy.size()):
			if _before(api, dir, heavy[i], heavy[best]):
				best = i
		picked.append(heavy[best])
		heavy.remove_at(best)
	return picked


static func _before(api: RuleApi, dir: Vector3i, a: Vector3i, b: Vector3i) -> bool:
	var la: int = api.layer_of(a)
	var lb: int = api.layer_of(b)
	if la != lb:
		return la > lb
	var oa: int = a.x * dir.x + a.z * dir.z
	var ob: int = b.x * dir.x + b.z * dir.z
	if oa != ob:
		return oa > ob
	return Wave3Cells.key_less(a, b)


func snapshot() -> Dictionary:
	return {"tau": _tau, "dir": _dir, "warned": _warned, "danger": _danger}
