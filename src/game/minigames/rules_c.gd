class_name WtMinigameRulesC extends RefCounted
## Wave-2 party rounds MG22-MG29 (aim, recall, react, estimate, spot, pair, dodge, slide).
## Stateless dispatcher: all mutable round data lives in `s.state` / `s.view`.
## Command args follow the host convention: dict VALUES in insertion order, so
## `cmd.args[0]` is normally the scalar; a Dictionary is tolerated too.

const LANE_COLS: int = 5
const LANE_ROWS: int = 9
const PIN_LAYOUT: Array = [[2], [1, 3], [0, 2, 4], [0, 1, 3, 4]]
const PIN_FIRST_ROW: int = 6
const SIMON_PADS: int = 4
const SLIDE_SIZE: int = 3
## Which round each send effect belongs to; foreign effects are ignored.
const EFFECT_OWNER: Dictionary = {&"greased_lane": &"mg22", &"scramble": &"mg23", &"short_peek": &"mg25", &"extra_decoy": &"mg26",
	&"shuffle_pair": &"mg27", &"extra_rain": &"mg28", &"nudge": &"mg29"}

## Round setup (called once through RuleRuntime).
func start(s: WtMinigameSession) -> void:
	s.state = {}
	s.view = {}
	match s.id:
		&"mg22": _bowl_start(s)
		&"mg23": _simon_start(s)
		&"mg24": _qd_start(s)
		&"mg25": _count_start(s)
		&"mg26": _odd_start(s)
		&"mg27": _pairs_start(s)
		&"mg28": _dodge_start(s)
		&"mg29": _slide_start(s)
		_: s.finish(&"invalid")

## Per-tick update (called after commands and incoming attacks).
func tick(s: WtMinigameSession, _events: Array[SimEvent]) -> void:
	match s.id:
		&"mg22": _bowl_tick(s)
		&"mg23": _simon_tick(s)
		&"mg24":
			_qd_sync(s)
			_qd_view(s)
		&"mg25": _count_tick(s)
		&"mg26": _odd_view(s)
		&"mg27": _pairs_tick(s)
		&"mg28": _dodge_tick(s)
		&"mg29": _slide_view(s)

## Handles a player intent. Returns true when consumed.
func command(s: WtMinigameSession, cmd: SimCommand) -> bool:
	if cmd.kind == &"mg_authority":
		var data: Dictionary = cmd.args[0] if not cmd.args.is_empty() and cmd.args[0] is Dictionary else {}
		if s.id == &"mg24" and StringName(data.get("kind", "")) == &"quick_drop_awarded" and int(data.get("winner", -1)) == s.player_id:
			s.add_score(int(s.params.get("shared_bonus", 3)))
			s.emit(&"mg_quick_drop_bonus", {})
		return true
	match s.id:
		&"mg22": _bowl_command(s, cmd)
		&"mg23":
			if cmd.kind == &"mg_pad": _simon_pad(s, _int_arg(cmd, "pad", -1))
		&"mg24":
			if cmd.kind == &"mg_tap": _qd_tap(s)
		&"mg25":
			if cmd.kind == &"mg_answer": _count_answer(s, _int_arg(cmd, "index", -1))
		&"mg26":
			if cmd.kind == &"mg_pick": _odd_pick(s, _int_arg(cmd, "index", -1))
		&"mg27":
			if cmd.kind == &"mg_flip": _pairs_flip(s, _int_arg(cmd, "index", -1))
		&"mg28":
			if cmd.kind == &"mg_step": _dodge_step(s, _int_arg(cmd, "dir", 0))
		&"mg29":
			if cmd.kind == &"mg_slide": _slide_move(s, _arg(cmd, "dir", Vector2i.ZERO))
	return true

## Effects land here after the telegraph delay (only while playing).
func attack(s: WtMinigameSession, effect: StringName, data: Dictionary) -> void:
	if EFFECT_OWNER.get(effect, &"") != s.id: return
	match effect:
		&"greased_lane":
			s.state.greased_until = s.now_ms() + int(data.get("duration_ms", s.params.get("greased_ms", 8000)))
			s.view["greased_until_ms"] = s.state.greased_until
		&"scramble":
			s.state.scramble_next = true
		&"short_peek":
			s.state.peek_next = true
		&"extra_decoy":
			s.state.decoy_next = true
		&"shuffle_pair": _pairs_shuffle(s)
		&"extra_rain": _dodge_extra_rain(s, int(data.get("count", s.params.get("extra_rain", 3))))
		&"nudge": _slide_nudge(s, int(data.get("count", s.params.get("nudge_moves", 3))))

# ---------------------------------------------------------------- helpers

static func _arg(cmd: SimCommand, key: String, default: Variant) -> Variant:
	if cmd.args.is_empty(): return default
	var first: Variant = cmd.args[0]
	if first is Dictionary: return (first as Dictionary).get(key, default)
	return first

static func _int_arg(cmd: SimCommand, key: String, default: int) -> int:
	var value: Variant = _arg(cmd, key, default)
	if value is int or value is float: return int(value)
	return default

func _pool(s: WtMinigameSession) -> Array[ShapeDef]:
	var out: Array[ShapeDef] = []
	for id: String in s.shape_pool():
		var shape: ShapeDef = s.catalog.shapes.get_shape(StringName(id))
		if shape != null and not out.has(shape): out.append(shape)
	if out.is_empty():
		for shape: ShapeDef in s.catalog.shapes.shapes:
			if shape.cube_count >= 3 and shape.cube_count <= 5 and out.size() < 8: out.append(shape)
	return out

## Offsets of `shape` in orientation `orient`, shifted so the minimum corner is the origin.
static func shape_cells(shape: ShapeDef, orient: int) -> Array[Vector3i]:
	return normalise(shape.offsets(orient))

## Shifts cells so the minimum corner is the origin.
static func normalise(cells: Array[Vector3i]) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	if cells.is_empty(): return out
	var low: Vector3i = cells[0]
	for cell: Vector3i in cells: low = Vector3i(mini(low.x, cell.x), mini(low.y, cell.y), mini(low.z, cell.z))
	for cell: Vector3i in cells: out.append(cell - low)
	return out

## Rotation-invariant-free canonical text of a cell set (normalised, sorted).
static func canonical_key(cells: Array[Vector3i]) -> String:
	var list: Array[Vector3i] = normalise(cells)
	list.sort_custom(func(a: Vector3i, b: Vector3i) -> bool:
		if a.y != b.y: return a.y < b.y
		if a.z != b.z: return a.z < b.z
		return a.x < b.x)
	var parts: PackedStringArray = PackedStringArray()
	for cell: Vector3i in list: parts.append("%d.%d.%d" % [cell.x, cell.y, cell.z])
	return ",".join(parts)

## Applies the cube rotation `orient` (0-23) to cells and normalises.
static func rotate_cells(cells: Array[Vector3i], orient: int) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	for cell: Vector3i in cells: out.append(Orientations.apply(orient, cell))
	return normalise(out)

## Mirror image (x reflected) of cells, normalised.
static func mirror_cells(cells: Array[Vector3i]) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	for cell: Vector3i in cells: out.append(Vector3i(-cell.x, cell.y, cell.z))
	return normalise(out)

## True when the mirror image of the shape is not any of its 24 rotations.
static func is_chiral(shape: ShapeDef) -> bool:
	var base: Array[Vector3i] = shape.offsets(0)
	var mirrored: String = canonical_key(mirror_cells(base))
	for orient: int in Orientations.COUNT:
		if canonical_key(rotate_cells(base, orient)) == mirrored: return false
	return true

## True when `cells` equals some rotation of `reference`.
static func is_rotation_of(cells: Array[Vector3i], reference: Array[Vector3i]) -> bool:
	var key: String = canonical_key(cells)
	for orient: int in Orientations.COUNT:
		if canonical_key(rotate_cells(reference, orient)) == key: return true
	return false

# ---------------------------------------------------------------- MG22 bowling

func _rack() -> Array:
	var pins: Array = []
	for index: int in PIN_LAYOUT.size():
		for col: int in PIN_LAYOUT[index]: pins.append(Vector2i(col, PIN_FIRST_ROW + index))
	return pins

func _bowl_start(s: WtMinigameSession) -> void:
	s.state = {"pins": _rack(), "ball_no": 1, "col": 2, "curve": 0, "w": 1, "ball_shape": "", "ball_hue": 0, "roll": {}, "greased_until": 0,
		"frame": 0, "first_down": 0, "last_knocked": 0, "strikes": 0}
	_bowl_next_ball(s)
	_bowl_view(s)

func _bowl_next_ball(s: WtMinigameSession) -> void:
	var shape: ShapeDef = s.next_shape()
	var width: int = 1
	if shape != null:
		var cells: Array[Vector3i] = shape_cells(shape, shape.spawn_orient)
		for cell: Vector3i in cells: width = maxi(width, cell.x + 1)
		s.state.ball_shape = String(shape.shape_id)
		s.state.ball_hue = shape.hue_id
	s.state.w = mini(3, width)
	s.state.col = clampi(int(s.state.col), 0, LANE_COLS - int(s.state.w))
	s.state.curve = 0

func _bowl_command(s: WtMinigameSession, cmd: SimCommand) -> void:
	if not (s.state.roll as Dictionary).is_empty(): return
	match cmd.kind:
		&"mg_aim":
			var dir: int = signi(_int_arg(cmd, "dir", 0))
			s.state.col = clampi(int(s.state.col) + dir, 0, LANE_COLS - int(s.state.w))
		&"mg_spin":
			var spin: int = signi(_int_arg(cmd, "dir", 0))
			s.state.curve = clampi(int(s.state.curve) + spin, -1, 1)
		&"mg_bowl":
			var forced: int = 1 if s.now_ms() < int(s.state.greased_until) else 0
			s.state.roll = {"row": 1, "col0": int(s.state.col), "curve": int(s.state.curve) + forced, "next_ms": s.now_ms(), "knocked": 0}
			s.emit(&"mg_bowl_release", {"col": s.state.col, "curve": s.state.curve, "forced": forced})
	_bowl_view(s)

func _bowl_tick(s: WtMinigameSession) -> void:
	var roll: Dictionary = s.state.roll
	if not roll.is_empty() and s.now_ms() >= int(roll.next_ms):
		var row: int = int(roll.row)
		var width: int = int(s.state.w)
		var col: int = int(roll.col0)
		if row > int(s.params.get("curve_row", 4)): col += int(roll.curve)
		col = clampi(col, 0, LANE_COLS - width)
		roll["lane_col"] = col
		var knocked: Array = []
		for pin: Vector2i in s.state.pins:
			if pin.y == row and pin.x >= col and pin.x < col + width:
				knocked.append(pin)
				var behind: Vector2i = Vector2i(pin.x, row + 1)
				if (s.state.pins as Array).has(behind) and not knocked.has(behind): knocked.append(behind)
		if not knocked.is_empty():
			var remaining: Array = []
			for pin: Vector2i in s.state.pins:
				if not knocked.has(pin): remaining.append(pin)
			s.state.pins = remaining
			roll["knocked"] = int(roll.knocked) + knocked.size()
		roll["row"] = row + 1
		roll["next_ms"] = int(roll.next_ms) + int(s.params.get("roll_step_ms", 120))
		s.state.roll = roll
		if row >= LANE_ROWS: _bowl_end(s)
	_bowl_view(s)

func _bowl_end(s: WtMinigameSession) -> void:
	var count: int = int((s.state.roll as Dictionary).knocked)
	var pins_left: int = (s.state.pins as Array).size()
	var charged: bool = false
	s.state.roll = {}
	s.state.last_knocked = count
	if int(s.state.ball_no) == 1:
		if pins_left == 0:
			s.add_score(int(s.params.get("strike_points", 20)))
			s.state.strikes = int(s.state.strikes) + 1
			charged = true
			s.emit(&"mg_strike", {})
			_bowl_new_frame(s)
		else:
			if count > 0: s.add_score(count)
			s.state.first_down = count
			s.state.ball_no = 2
	else:
		if pins_left == 0:
			s.add_score(int(s.params.get("spare_points", 15)))
			charged = true
			s.emit(&"mg_spare", {})
		elif count > 0: s.add_score(count)
		_bowl_new_frame(s)
	if charged:
		s.charge_send(&"greased_lane", {"duration_ms": int(s.params.get("greased_ms", 8000))}, int(s.params.get("greased_charge", 2)))
	_bowl_next_ball(s)

func _bowl_new_frame(s: WtMinigameSession) -> void:
	s.state.pins = _rack()
	s.state.ball_no = 1
	s.state.frame = int(s.state.frame) + 1
	s.state.first_down = 0

func _bowl_view(s: WtMinigameSession) -> void:
	var roll: Dictionary = s.state.roll
	s.view = {"kind": "bowling", "cols": LANE_COLS, "rows": LANE_ROWS, "pins": (s.state.pins as Array).duplicate(),
		"ball": {"col": roll.get("lane_col", roll.get("col0", s.state.col)) if not roll.is_empty() else s.state.col, "row": int(roll.row) - 1 if not roll.is_empty() else 0,
			"w": s.state.w, "shape": s.state.ball_shape, "hue": s.state.ball_hue, "curve": s.state.curve},
		"rolling": not roll.is_empty(), "ball_no": s.state.ball_no, "frame": s.state.frame, "last_knocked": s.state.last_knocked,
		"greased_until_ms": s.state.greased_until}

# ---------------------------------------------------------------- MG23 simon

func _simon_start(s: WtMinigameSession) -> void:
	var ids: Array = []
	for shape: ShapeDef in _pool(s): ids.append(String(shape.shape_id))
	Seeds.shuffle(s.rng, ids)
	var pads: Array = []
	for index: int in SIMON_PADS: pads.append(ids[index % ids.size()] if not ids.is_empty() else "")
	s.state = {"pads": pads, "positions": [0, 1, 2, 3], "swapped": false, "scramble_next": false, "seq": [], "len": int(s.params.get("start_len", 3)),
		"show_start": 0, "input_idx": 0, "showing": true}
	_simon_new(s, int(s.state.len), 500)

func _simon_new(s: WtMinigameSession, length: int, begin_ms: int) -> void:
	var seq: Array = []
	for _i: int in length: seq.append(s.rng.randi_range(0, SIMON_PADS - 1))
	s.state.seq = seq
	s.state.len = length
	s.state.input_idx = 0
	s.state.showing = true
	s.state.show_start = begin_ms
	s.state.positions = [0, 1, 2, 3]
	s.state.swapped = false
	if bool(s.state.scramble_next):
		s.state.scramble_next = false
		var a: int = s.attack_rng.randi_range(0, SIMON_PADS - 1)
		var b: int = (a + 1 + s.attack_rng.randi_range(0, SIMON_PADS - 2)) % SIMON_PADS
		var positions: Array = s.state.positions
		var held: int = positions[a]
		positions[a] = positions[b]
		positions[b] = held
		s.state.positions = positions
		s.state.swapped = true
	_simon_view(s)

func _simon_tick(s: WtMinigameSession) -> void:
	var step: int = int(s.params.get("flash_ms", 600)) + int(s.params.get("gap_ms", 200))
	if bool(s.state.showing) and s.now_ms() >= int(s.state.show_start) + int((s.state.seq as Array).size()) * step:
		s.state.showing = false
	_simon_view(s)

func _simon_pad(s: WtMinigameSession, pad: int) -> void:
	if bool(s.state.showing) or pad < 0 or pad >= SIMON_PADS: return
	var seq: Array = s.state.seq
	if int(seq[int(s.state.input_idx)]) == pad:
		s.state.input_idx = int(s.state.input_idx) + 1
		if int(s.state.input_idx) >= seq.size():
			s.add_score(seq.size())
			s.charge_send(&"scramble", {}, int(s.params.get("scramble_charge", 2)))
			_simon_new(s, seq.size() + 1, s.now_ms() + 500)
	else:
		s.emit(&"mg_simon_miss", {"len": seq.size()})
		_simon_new(s, maxi(int(s.params.get("start_len", 3)), seq.size() - 1), s.now_ms() + 500)
	_simon_view(s)

func _simon_view(s: WtMinigameSession) -> void:
	var step: int = int(s.params.get("flash_ms", 600)) + int(s.params.get("gap_ms", 200))
	var flash: int = -1
	var elapsed: int = s.now_ms() - int(s.state.show_start)
	if bool(s.state.showing) and elapsed >= 0:
		var index: int = elapsed / step
		if index < (s.state.seq as Array).size() and elapsed % step < int(s.params.get("flash_ms", 600)): flash = int(s.state.seq[index])
	s.view = {"kind": "sequence", "pads": (s.state.pads as Array).duplicate(), "positions": (s.state.positions as Array).duplicate(),
		"swapped": s.state.swapped, "flash": flash, "showing": s.state.showing, "length": (s.state.seq as Array).size(), "input_index": s.state.input_idx}

# ---------------------------------------------------------------- MG24 quick drop

func _qd_start(s: WtMinigameSession) -> void:
	s.state = {"phase": "wait", "signal_at": 0, "gap_at": 0, "end_at": 0, "fake": false, "serial": 0, "last_reaction": -1, "last_points": 0, "false_start_until": 0}
	_qd_new(s, 0)
	_qd_view(s)

func _qd_new(s: WtMinigameSession, from_ms: int) -> void:
	var wait: int = s.rng.randi_range(int(s.params.get("wait_min_ms", 1500)), int(s.params.get("wait_max_ms", 4500)))
	var fake_roll: float = s.rng.randf()
	s.state.phase = "wait"
	s.state.fake = from_ms >= 4000 and fake_roll < float(s.params.get("fake_chance", 0.3))
	s.state.signal_at = from_ms + wait
	s.state.serial = int(s.state.serial) + 1

func _qd_sync(s: WtMinigameSession) -> void:
	var now: int = s.now_ms()
	if s.state.phase == "wait" and now >= int(s.state.signal_at):
		s.state.phase = "amber" if bool(s.state.fake) else "green"
		s.state.end_at = int(s.state.signal_at) + int(s.params.get("timeout_ms", 1500))
	if (s.state.phase == "green" or s.state.phase == "amber") and now >= int(s.state.end_at):
		s.state.phase = "gap"
		s.state.gap_at = int(s.state.end_at) + int(s.params.get("gap_ms", 1200))
	if s.state.phase == "gap" and now >= int(s.state.gap_at):
		_qd_new(s, int(s.state.gap_at))
		_qd_sync(s)

func _qd_tap(s: WtMinigameSession) -> void:
	_qd_sync(s)
	var now: int = s.now_ms()
	match String(s.state.phase):
		"green":
			var reaction: int = now - int(s.state.signal_at)
			var points: int = maxi(1, 10 - reaction / 50)
			s.add_score(points)
			s.state.last_reaction = reaction
			s.state.last_points = points
			s.state.phase = "gap"
			s.state.gap_at = now + int(s.params.get("gap_ms", 1200))
			s.request_shared(&"quick_drop_claim", {"serial": s.state.serial, "reaction_ms": reaction, "player": s.player_id})
		"wait", "amber":
			s.add_score(-int(s.params.get("false_start_penalty", 2)))
			s.state.last_points = -int(s.params.get("false_start_penalty", 2))
			s.state.false_start_until = now + 800
			s.state.phase = "gap"
			s.state.gap_at = now + int(s.params.get("gap_ms", 1200))
			s.emit(&"mg_false_start", {})
	_qd_view(s)

func _qd_view(s: WtMinigameSession) -> void:
	s.view = {"kind": "signal", "signal": s.state.phase, "serial": s.state.serial, "last_reaction_ms": s.state.last_reaction,
		"last_points": s.state.last_points, "false_start": s.now_ms() < int(s.state.false_start_until)}

# ---------------------------------------------------------------- MG25 cube count

func _count_start(s: WtMinigameSession) -> void:
	s.state = {"cells": [], "hues": [], "count": 0, "choices": [], "answer": 0, "show_until": 0, "answer_start": 0, "showing": true, "peek_next": false, "towers": 0}
	_count_new(s, 0)
	_count_view(s)

func _count_new(s: WtMinigameSession, begin_ms: int) -> void:
	var pool: Array[ShapeDef] = _pool(s)
	var cells: Array[Vector3i] = []
	var hues: Array = []
	for _attempt: int in 40:
		cells = []
		hues = []
		var pieces: int = s.rng.randi_range(2, 5)
		for _p: int in pieces:
			var shape: ShapeDef = pool[s.rng.randi_range(0, pool.size() - 1)]
			var piece: Array[Vector3i] = shape_cells(shape, s.rng.randi_range(0, Orientations.COUNT - 1))
			var extent: Vector3i = Vector3i.ZERO
			for cell: Vector3i in piece: extent = Vector3i(maxi(extent.x, cell.x), maxi(extent.y, cell.y), maxi(extent.z, cell.z))
			var x0: int = s.rng.randi_range(0, maxi(0, 3 - extent.x))
			var z0: int = s.rng.randi_range(0, maxi(0, 3 - extent.z))
			if extent.x > 3 or extent.z > 3: continue
			var y: int = 8
			while y > 0 and not _count_collides(cells, piece, Vector3i(x0, y - 1, z0)): y -= 1
			if _count_collides(cells, piece, Vector3i(x0, y, z0)) or y + extent.y >= 8: continue
			for cell: Vector3i in piece:
				cells.append(cell + Vector3i(x0, y, z0))
				hues.append(shape.hue_id)
		if cells.size() >= 6 and cells.size() <= 20: break
	s.state.cells = cells
	s.state.hues = hues
	s.state.count = cells.size()
	var candidates: Array = []
	for delta: int in [-4, -3, -2, -1, 1, 2, 3, 4]:
		if cells.size() + delta >= 1: candidates.append(cells.size() + delta)
	Seeds.shuffle(s.rng, candidates)
	var choices: Array = candidates.slice(0, 3)
	var slot: int = s.rng.randi_range(0, 3)
	choices.insert(slot, cells.size())
	s.state.choices = choices
	s.state.answer = slot
	var show: int = int(s.params.get("show_ms", 3000))
	if bool(s.state.peek_next):
		s.state.peek_next = false
		show = maxi(int(s.params.get("show_min_ms", 1200)), show - int(s.params.get("peek_cut_ms", 1200)))
	s.state.show_until = begin_ms + show
	s.state.showing = true
	s.state.towers = int(s.state.towers) + 1

func _count_collides(cells: Array[Vector3i], piece: Array[Vector3i], offset: Vector3i) -> bool:
	for cell: Vector3i in piece:
		var at: Vector3i = cell + offset
		if at.y < 0 or cells.has(at): return true
	return false

func _count_tick(s: WtMinigameSession) -> void:
	if bool(s.state.showing) and s.now_ms() >= int(s.state.show_until):
		s.state.showing = false
		s.state.answer_start = int(s.state.show_until)
	_count_view(s)

func _count_answer(s: WtMinigameSession, index: int) -> void:
	if bool(s.state.showing) or index < 0 or index > 3: return
	if index == int(s.state.answer):
		var points: int = int(s.params.get("correct_points", 3))
		if s.now_ms() - int(s.state.answer_start) <= int(s.params.get("fast_ms", 2000)): points += int(s.params.get("fast_bonus", 2))
		s.add_score(points)
		s.charge_send(&"short_peek", {}, int(s.params.get("peek_charge", 2)))
		s.emit(&"mg_count_correct", {"points": points})
	else:
		s.emit(&"mg_count_wrong", {"count": s.state.count})
	_count_new(s, s.now_ms() + 500)
	_count_view(s)

func _count_view(s: WtMinigameSession) -> void:
	var showing: bool = bool(s.state.showing)
	s.view = {"kind": "count", "showing": showing, "cells": (s.state.cells as Array).duplicate() if showing else [], "hues": (s.state.hues as Array).duplicate() if showing else [],
		"show_until": s.state.show_until, "choices": [] if showing else (s.state.choices as Array).duplicate(), "tower": s.state.towers}

# ---------------------------------------------------------------- MG26 odd block out

func _odd_start(s: WtMinigameSession) -> void:
	var chiral: Array = []
	for shape: ShapeDef in _pool(s):
		if is_chiral(shape): chiral.append(shape)
	if chiral.is_empty():
		for shape: ShapeDef in s.catalog.shapes.shapes:
			if shape.cube_count >= 3 and shape.cube_count <= 5 and is_chiral(shape): chiral.append(shape)
	if chiral.is_empty():
		s.emit(&"mg_setup_error", {"issues": "no chiral shapes"})
		s.finish(&"invalid")
		return
	s.state = {"chiral": chiral.map(func(shape: ShapeDef) -> String: return String(shape.shape_id)), "odd": 0, "copies": [], "shape": "", "puzzles": 0, "lock_until": 0, "decoy_next": false}
	_odd_new(s)

func _odd_new(s: WtMinigameSession) -> void:
	var ids: Array = s.state.chiral
	var shape: ShapeDef = s.catalog.shapes.get_shape(StringName(ids[s.rng.randi_range(0, ids.size() - 1)]))
	var count: int = int(s.params.get("copies", 4))
	if int(s.state.puzzles) >= int(s.params.get("late_after", 4)): count = int(s.params.get("copies_late", 5))
	if bool(s.state.decoy_next):
		s.state.decoy_next = false
		count = int(s.params.get("decoy_copies", 6))
	var odd: int = s.rng.randi_range(0, count - 1)
	var base: Array[Vector3i] = shape.offsets(0)
	var copies: Array = []
	for index: int in count:
		var source: Array[Vector3i] = mirror_cells(base) if index == odd else normalise(base)
		copies.append({"cells": rotate_cells(source, s.rng.randi_range(0, Orientations.COUNT - 1)), "hue": shape.hue_id})
	s.state.copies = copies
	s.state.odd = odd
	s.state.shape = String(shape.shape_id)
	_odd_view(s)

func _odd_pick(s: WtMinigameSession, index: int) -> void:
	if s.now_ms() < int(s.state.lock_until) or index < 0 or index >= (s.state.copies as Array).size(): return
	if index == int(s.state.odd):
		s.add_score(2)
		s.state.puzzles = int(s.state.puzzles) + 1
		s.charge_send(&"extra_decoy", {}, int(s.params.get("decoy_charge", 3)))
		_odd_new(s)
	else:
		s.state.lock_until = s.now_ms() + int(s.params.get("pick_lock_ms", 1000))
		s.emit(&"mg_odd_wrong", {})
	_odd_view(s)

func _odd_view(s: WtMinigameSession) -> void:
	s.view = {"kind": "odd", "copies": (s.state.copies as Array).duplicate(true), "shape": s.state.shape, "puzzle": s.state.puzzles,
		"lock_until_ms": s.state.lock_until}

# ---------------------------------------------------------------- MG27 toy pairs

func _pairs_start(s: WtMinigameSession) -> void:
	var ids: Array = []
	for shape: ShapeDef in _pool(s): ids.append(String(shape.shape_id))
	s.state = {"faces": [], "up": [], "matched": [], "face_shapes": [], "first": -1, "second": -1, "mismatch_due": 0, "grids": 0, "swap_cells": [], "swap_until": 0, "shape_ids": ids}
	_pairs_deal(s)
	_pairs_view(s)

func _pairs_deal(s: WtMinigameSession) -> void:
	var total: int = int(s.params.get("grid_w", 4)) * int(s.params.get("grid_h", 4))
	var faces: Array = []
	for index: int in total / 2:
		faces.append(index)
		faces.append(index)
	Seeds.shuffle(s.rng, faces)
	var ids: Array = s.state.shape_ids
	var face_shapes: Array = []
	for index: int in total / 2: face_shapes.append({"shape": ids[index % ids.size()] if not ids.is_empty() else "", "hue": index % 4})
	s.state.faces = faces
	s.state.face_shapes = face_shapes
	s.state.up = []
	s.state.matched = []
	for _i: int in total:
		s.state.up.append(false)
		s.state.matched.append(false)
	s.state.first = -1
	s.state.second = -1
	s.state.mismatch_due = 0
	s.state.grids = int(s.state.grids) + 1

func _pairs_flip(s: WtMinigameSession, index: int) -> void:
	if int(s.state.mismatch_due) > 0 or index < 0 or index >= (s.state.faces as Array).size(): return
	if bool(s.state.up[index]) or bool(s.state.matched[index]): return
	s.state.up[index] = true
	if int(s.state.first) < 0:
		s.state.first = index
	else:
		s.state.second = index
		var first: int = int(s.state.first)
		if int(s.state.faces[first]) == int(s.state.faces[index]):
			s.state.matched[first] = true
			s.state.matched[index] = true
			s.state.up[first] = false
			s.state.up[index] = false
			s.state.first = -1
			s.state.second = -1
			s.add_score(int(s.params.get("match_points", 2)))
			s.charge_send(&"shuffle_pair", {}, int(s.params.get("shuffle_charge", 3)))
			if not (s.state.matched as Array).has(false):
				s.add_score(int(s.params.get("clear_bonus", 5)))
				_pairs_deal(s)
		else:
			s.state.mismatch_due = s.now_ms() + int(s.params.get("mismatch_ms", 800))
	_pairs_view(s)

func _pairs_tick(s: WtMinigameSession) -> void:
	if int(s.state.mismatch_due) > 0 and s.now_ms() >= int(s.state.mismatch_due):
		for index: int in [int(s.state.first), int(s.state.second)]:
			if index >= 0: s.state.up[index] = false
		s.state.first = -1
		s.state.second = -1
		s.state.mismatch_due = 0
	_pairs_view(s)

func _pairs_shuffle(s: WtMinigameSession) -> void:
	var down: Array = []
	for index: int in (s.state.faces as Array).size():
		if not bool(s.state.up[index]) and not bool(s.state.matched[index]): down.append(index)
	if down.size() < 2: return
	var a: int = s.attack_rng.randi_range(0, down.size() - 1)
	var b: int = (a + 1 + s.attack_rng.randi_range(0, down.size() - 2)) % down.size()
	var ia: int = down[a]
	var ib: int = down[b]
	var held: int = s.state.faces[ia]
	s.state.faces[ia] = s.state.faces[ib]
	s.state.faces[ib] = held
	s.state.swap_cells = [ia, ib]
	s.state.swap_until = s.now_ms() + 1000
	_pairs_view(s)

func _pairs_view(s: WtMinigameSession) -> void:
	var shown: Array = []
	for index: int in (s.state.faces as Array).size():
		var visible: bool = bool(s.state.up[index]) or bool(s.state.matched[index])
		shown.append(int(s.state.faces[index]) if visible else -1)
	s.view = {"kind": "pairs", "cols": int(s.params.get("grid_w", 4)), "rows": int(s.params.get("grid_h", 4)), "faces": shown, "matched": (s.state.matched as Array).duplicate(),
		"face_shapes": (s.state.face_shapes as Array).duplicate(true), "swap_cells": s.state.swap_cells if s.now_ms() < int(s.state.swap_until) else [], "grid": s.state.grids}

# ---------------------------------------------------------------- MG28 dodge

func _dodge_start(s: WtMinigameSession) -> void:
	s.state = {"lane": int(s.params.get("lanes", 5)) / 2, "hearts": int(s.params.get("hearts", 3)), "drops": [], "spawned": 0, "next_spawn": 1000,
		"next_point": int(s.params.get("survive_point_ms", 10000)), "alive_ms": 0, "ghost_effect": "extra_rain"}
	_dodge_view(s)

func _dodge_step(s: WtMinigameSession, dir: int) -> void:
	s.state.lane = clampi(int(s.state.lane) + signi(dir), 0, int(s.params.get("lanes", 5)) - 1)
	_dodge_view(s)

func _dodge_tick(s: WtMinigameSession) -> void:
	var now: int = s.now_ms()
	var lanes: int = int(s.params.get("lanes", 5))
	s.state.alive_ms = now
	if now >= int(s.state.next_spawn):
		var lane: int = s.rng.randi_range(0, lanes - 1)
		var wide_roll: float = s.rng.randf()
		var width: int = 2 if now >= int(s.params.get("wide_after_ms", 30000)) and wide_roll < 0.35 else 1
		lane = mini(lane, lanes - width)
		s.state.drops.append({"lane": lane, "width": width, "impact": now + int(s.params.get("shadow_ms", 900)), "spawn": now})
		s.state.spawned = int(s.state.spawned) + 1
		var interval: int = maxi(int(s.params.get("rain_min_ms", 450)), int(s.params.get("rain_start_ms", 1100)) - int(s.params.get("rain_step_ms", 40)) * int(s.state.spawned))
		s.state.next_spawn = now + interval
	var pending: Array = []
	for drop: Dictionary in s.state.drops:
		if now < int(drop.impact):
			pending.append(drop)
			continue
		var low: int = int(drop.lane)
		var high: int = low + int(drop.width) - 1
		var lane_now: int = int(s.state.lane)
		if lane_now >= low and lane_now <= high:
			s.state.hearts = int(s.state.hearts) - 1
			s.emit(&"mg_dodge_hit", {"hearts": s.state.hearts})
		elif lane_now == low - 1 or lane_now == high + 1:
			s.charge_send(&"extra_rain", {"count": int(s.params.get("extra_rain", 3))}, int(s.params.get("rain_charge", 3)))
	s.state.drops = pending
	while now >= int(s.state.next_point) and int(s.state.hearts) > 0:
		s.add_score(1)
		s.state.next_point = int(s.state.next_point) + int(s.params.get("survive_point_ms", 10000))
	_dodge_view(s)
	if int(s.state.hearts) <= 0:
		s.state.hearts = 0
		s.state.alive_ms = now
		s.become_ghost()

func _dodge_extra_rain(s: WtMinigameSession, count: int) -> void:
	var lanes: int = int(s.params.get("lanes", 5))
	for index: int in count:
		var lane: int = s.attack_rng.randi_range(0, lanes - 1)
		s.state.drops.append({"lane": lane, "width": 1, "impact": s.now_ms() + int(s.params.get("shadow_ms", 900)) + index * 350, "spawn": s.now_ms()})
	_dodge_view(s)

func _dodge_view(s: WtMinigameSession) -> void:
	s.view = {"kind": "dodge", "lanes": int(s.params.get("lanes", 5)), "lane": s.state.lane, "hearts": s.state.hearts, "drops": (s.state.drops as Array).duplicate(true),
		"shadow_ms": int(s.params.get("shadow_ms", 900))}

# ---------------------------------------------------------------- MG29 slide shuffle

func _slide_start(s: WtMinigameSession) -> void:
	s.state = {"tiles": [], "empty": 8, "prev_empty": -1, "puzzles": 0, "placed": {}}
	s.progress = 0
	_slide_scramble(s)
	_slide_view(s)

static func slide_solved() -> Array:
	return [1, 2, 3, 4, 5, 6, 7, 8, 0]

static func _slide_neighbours(index: int) -> Array:
	var out: Array = []
	var x: int = index % SLIDE_SIZE
	var y: int = index / SLIDE_SIZE
	if x > 0: out.append(index - 1)
	if x < SLIDE_SIZE - 1: out.append(index + 1)
	if y > 0: out.append(index - SLIDE_SIZE)
	if y < SLIDE_SIZE - 1: out.append(index + SLIDE_SIZE)
	return out

func _slide_random_move(s: WtMinigameSession, rng: RandomNumberGenerator) -> void:
	var options: Array = _slide_neighbours(int(s.state.empty))
	options.erase(int(s.state.prev_empty))
	var target: int = options[rng.randi_range(0, options.size() - 1)]
	_slide_swap(s, target)

func _slide_swap(s: WtMinigameSession, target: int) -> void:
	var empty: int = int(s.state.empty)
	s.state.tiles[empty] = s.state.tiles[target]
	s.state.tiles[target] = 0
	s.state.prev_empty = empty
	s.state.empty = target

func _slide_scramble(s: WtMinigameSession) -> void:
	s.state.tiles = slide_solved()
	s.state.empty = 8
	s.state.prev_empty = -1
	for _i: int in int(s.params.get("scramble_moves", 30)): _slide_random_move(s, s.rng)
	while s.state.tiles == slide_solved(): _slide_random_move(s, s.rng)
	var placed: Dictionary = {}
	for index: int in 8:
		if int(s.state.tiles[index]) == index + 1: placed[index] = true
	s.state.placed = placed

## Number of tiles (1-8) sitting on their solved cell.
static func slide_correct(tiles: Array) -> int:
	var total: int = 0
	for index: int in 8:
		if int(tiles[index]) == index + 1: total += 1
	return total

func _slide_move(s: WtMinigameSession, direction: Variant) -> void:
	var dx: int = 0
	var dy: int = 0
	if direction is Vector2i or direction is Vector2:
		dx = signi(int(direction.x))
		dy = signi(int(direction.y))
	elif direction is Vector3i:
		dx = signi((direction as Vector3i).x)
		dy = signi((direction as Vector3i).z)
	if absi(dx) + absi(dy) != 1: return
	var empty: int = int(s.state.empty)
	var sx: int = empty % SLIDE_SIZE - dx
	var sy: int = empty / SLIDE_SIZE - dy
	if sx < 0 or sy < 0 or sx >= SLIDE_SIZE or sy >= SLIDE_SIZE: return
	_slide_swap(s, sy * SLIDE_SIZE + sx)
	for index: int in 8:
		if int(s.state.tiles[index]) == index + 1 and not (s.state.placed as Dictionary).has(index):
			s.state.placed[index] = true
			s.charge_send(&"nudge", {"count": int(s.params.get("nudge_moves", 3))}, int(s.params.get("nudge_charge", 5)))
	if s.state.tiles == slide_solved():
		s.state.puzzles = int(s.state.puzzles) + 1
		s.emit(&"mg_slide_solved", {"puzzles": s.state.puzzles})
		if int(s.state.puzzles) >= int(s.params.get("puzzles_target", 2)):
			s.progress = 1000
			_slide_view(s)
			s.finish(&"won")
			return
		_slide_scramble(s)
	_slide_view(s)

func _slide_nudge(s: WtMinigameSession, count: int) -> void:
	for _i: int in count: _slide_random_move(s, s.attack_rng)
	_slide_view(s)

func _slide_view(s: WtMinigameSession) -> void:
	var tiles: Array = s.state.tiles
	s.progress = 1000 * slide_correct(tiles) / 8
	s.view = {"kind": "slide", "tiles": tiles.duplicate(), "size": SLIDE_SIZE, "correct": slide_correct(tiles), "puzzles": s.state.puzzles,
		"target": int(s.params.get("puzzles_target", 2))}
