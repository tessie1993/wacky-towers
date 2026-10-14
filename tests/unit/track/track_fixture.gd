class_name TrackFixture extends RefCounted
## Shared builders for the G8 track tests. The fixture track reuses the shipped tracks' lean, cargo, star and effect
## tuning and runs on the real meadow_03 board size (8x8x10), so the tests exercise the numbers that ship.
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const DIR := "res://assets/data/tracks/"
const W := 8
const D := 8
const H := 10


static func shipped(id: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(DIR + id + ".json")) as Dictionary


static func dict(events: Array = [], checkpoints: Array = [], over: Dictionary = {}) -> Dictionary:
	var brook: Dictionary = shipped("meadow_brook_run")
	var kite: Dictionary = shipped("meadow_kite_day")
	var effects: Dictionary = (kite["effects"] as Dictionary).duplicate(true)
	effects.merge((brook["effects"] as Dictionary).duplicate(true), true)
	var d: Dictionary = {"schema": 3, "id": "t", "tick_ms": 50, "hearts": 3, "preview_window_mm": 4000, "preview_min_lead_ms": 2000,
		"segments": [{"id": "s", "length_mm": 10000, "speed_mm_s": 1000, "fall_pct": 100}],
		"events": events, "checkpoints": checkpoints, "lean": brook["lean"], "cargo": brook["cargo"], "stars": brook["stars"],
		"altitude": kite["altitude"], "effects": effects}
	d.merge(over, true)
	return d


static func def(events: Array = [], checkpoints: Array = [], over: Dictionary = {}) -> TrackDef:
	return TrackDef.from_dict(dict(events, checkpoints, over))


## columns: Vector2i(x, z) -> height; solid stacks from the floor on an 8x8x10 board.
static func board(columns: Dictionary = {}) -> BoardState:
	var b: BoardState = F.board(W, D, H)
	for col: Vector2i in columns:
		for y: int in int(columns[col]):
			b.place(b.index(Vector3i(col.x, y, col.y)), 1, 0, 1)
	return b


## A centred plateau of size x size columns (even size keeps the centre of mass at zero), `layers` high.
static func plateau(layers: int, size: int = 4) -> Dictionary:
	var cols: Dictionary = {}
	var start: int = (W - size) / 2
	for z: int in range(start, start + size):
		for x: int in range(start, start + size):
			cols[Vector2i(x, z)] = layers
	return cols


static func count(b: BoardState) -> int:
	var n: int = 0
	for y: int in H:
		for z: int in D:
			for x: int in W:
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


static func of_kind(records: Array[Dictionary], kind: StringName) -> Array[Dictionary]:
	return records.filter(func(r: Dictionary) -> bool: return r["kind"] == kind)
