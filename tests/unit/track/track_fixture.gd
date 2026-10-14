class_name TrackFixture extends RefCounted
## Shared builders for the G8 track tests: a small valid 10 s track and boards to run it on.
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")


static func dict(events: Array = [], checkpoints: Array = [], over: Dictionary = {}) -> Dictionary:
	var d: Dictionary = {"schema": 2, "id": "t", "tick_ms": 50, "time_limit_ms": 12000, "restart_penalty_ms": 1000,
		"preview_window_mm": 4000, "preview_min_lead_ms": 2000, "on_loss": "checkpoint",
		"segments": [{"id": "s", "length_mm": 10000, "speed_mm_s": 1000, "fall_pct": 100}],
		"events": events, "checkpoints": checkpoints,
		"lean": {"danger_pm": 550, "limit_pm": 800, "relax_pm_per_s": 60, "spill_cells": 2, "spill_relief_pm": 300, "hysteresis_pm": 80},
		"cargo": {"height_layers": 1, "min_support_cells": 5, "level_tolerance_layers": 1, "wobble_pm": 300, "slip_pm": 650,
			"rise_pm_per_s": 140, "recover_pm_per_s": 220, "lean_stress_pm_per_s": 160, "drop_stress_pm_per_layer": 200,
			"top_out_stress_pm_per_s": 300},
		"effects": {"bump": {"impulse_pm_per_force": 120, "cargo_stress_pm_per_force": 90},
			"cloud_bump": {"impulse_pm_per_force": 70, "cargo_stress_pm_per_force": 160},
			"crosswind": {"impulse_pm_per_layer_strength": 30, "cargo_stress_pm_per_strength": 100},
			"gust": {"impulse_pm_per_100_layer_cells": 60, "cargo_stress_pm_per_strength": 80},
			"updraft": {"lift_pct": 10, "height_pct_per_layer": 12, "mass_pct_per_cell": 1}, "arch": {}}}
	d.merge(over, true)
	return d


static func def(events: Array = [], checkpoints: Array = [], over: Dictionary = {}) -> TrackDef:
	return TrackDef.from_dict(dict(events, checkpoints, over))


## columns: Vector2i(x, z) -> height; solid stacks from the floor on a 4x4x10 board.
static func board(columns: Dictionary = {}) -> BoardState:
	var b: BoardState = F.board(4, 4, 10)
	for col: Vector2i in columns:
		for y: int in int(columns[col]):
			b.place(b.index(Vector3i(col.x, y, col.y)), 1, 0, 1)
	return b


## A flat 3x3 block of `layers` layers around (1,1): a stable seat.
static func flat(layers: int) -> Dictionary:
	var cols: Dictionary = {}
	for z: int in 3:
		for x: int in 3:
			cols[Vector2i(x, z)] = layers
	return cols


static func count(b: BoardState) -> int:
	var n: int = 0
	for y: int in 10:
		for z: int in 4:
			for x: int in 4:
				n += 1 if b.get_kind(b.index(Vector3i(x, y, z))) != 0 else 0
	return n


## Steps `ms` of play in dt chunks, flushing writes after each step; returns every record.
static func run(runner: TrackRunner, api: RuleApi, ms: int, dt: int = 50) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for _i: int in ms / dt:
		out.append_array(runner.step(dt, api))
		api.flush_writes()
	for _j: int in 20:  # drain time a board-changing tick carried over
		out.append_array(runner.step(0, api))
		api.flush_writes()
	return out


static func kinds(records: Array[Dictionary]) -> Array:
	return records.map(func(r: Dictionary) -> StringName: return r["kind"])
