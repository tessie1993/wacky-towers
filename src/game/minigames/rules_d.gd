class_name WtMinigameRulesD extends RefCounted
## Wave-2 party rounds MG30-MG36 (mirror, tally, whack, pull, spin, plinko, dig).
## Rule data lives in `s.state`; `s.view` carries everything the UI draws.
## Intent args follow the host convention: dict values in insertion order, so
## `{"axis":1,"dir":-1}` arrives as `[1, -1]`; a leading Dictionary is tolerated too.
## Design: design/gdd/party-minigames-wave2.md
const MIRROR_SIZE: int = 5
const WHACK_HOLES: int = 9
const TOWER_SLOTS: int = 3
const DIG_SIZE: int = 6

## Starts the round: seeds the first challenge of the minigame `s.id`.
func start(s: WtMinigameSession) -> void:
	s.state.clear()
	s.view.clear()
	match s.id:
		&"mg30":
			s.state.merge({"cursor": Vector2i(2, 2), "patterns": 0, "flip_next": false, "pattern": [], "painted": {}, "axis": &"v"}, true)
			_mirror_new(s)
		&"mg31":
			s.state.merge({"fast_next": false}, true)
			_tally_new(s)
		&"mg32":
			s.state.merge({"pops": {}, "next_spawn": 600, "decoys": 0, "good_hits": 0}, true)
			_whack_view(s)
		&"mg33": _pull_start(s)
		&"mg34":
			s.state.merge({"locked_axis": -1, "locked_until": 0, "puzzles": 0}, true)
			_spin_new(s)
		&"mg35": _plinko_start(s)
		&"mg36":
			s.state.merge({"cursor": Vector2i(DIG_SIZE / 2, DIG_SIZE / 2), "treasures": 0}, true)
			_dig_new(s)
		_: s.finish(&"invalid")

## Per-frame update (timers, schedules, views).
func tick(s: WtMinigameSession, _events: Array[SimEvent]) -> void:
	match s.id:
		&"mg31": _tally_tick(s)
		&"mg32": _whack_tick(s)
		&"mg33": _pull_tick(s)
		&"mg34": _spin_view(s)
		&"mg35": _plinko_tick(s)

## Handles one command; returns true when consumed.
func command(s: WtMinigameSession, cmd: SimCommand) -> bool:
	if cmd.kind == &"mg_authority":
		_authority(s, cmd.args[0] if not cmd.args.is_empty() and cmd.args[0] is Dictionary else {})
		return true
	match s.id:
		&"mg30":
			if cmd.kind == &"mg_move": _mirror_move(s, _direction(cmd.args)); return true
			if cmd.kind == &"mg_paint": _mirror_paint(s); return true
			if cmd.kind == &"mg_submit": _mirror_submit(s); return true
		&"mg31":
			if cmd.kind == &"mg_answer": _tally_answer(s, int(_arg(cmd, 0, "index", -1))); return true
		&"mg32":
			if cmd.kind == &"mg_whack": _whack_hit(s, int(_arg(cmd, 0, "index", -1))); return true
		&"mg33":
			if cmd.kind == &"mg_move": _pull_move(s, _direction(cmd.args)); return true
			if cmd.kind == &"mg_pull":
				# Bare `mg_pull` pulls the bar under the cursor; `[layer, slot]` pulls directly.
				if cmd.args.is_empty(): _pull(s, int(s.state.cursor.y), int(s.state.cursor.x))
				else: _pull(s, int(_arg(cmd, 0, "layer", -1)), int(_arg(cmd, 1, "slot", -1)))
				return true
		&"mg34":
			if cmd.kind == &"mg_rotate": _spin_rotate(s, int(_arg(cmd, 0, "axis", 0)), int(_arg(cmd, 1, "dir", 1))); return true
			if cmd.kind == &"mg_submit": _spin_submit(s); return true
		&"mg35":
			if cmd.kind == &"mg_aim": _plinko_aim(s, int(_arg(cmd, 0, "dir", 0))); return true
			if cmd.kind == &"mg_bowl": _plinko_drop(s); return true
		&"mg36":
			if cmd.kind == &"mg_move": _dig_move(s, _direction(cmd.args)); return true
			if cmd.kind == &"mg_dig": _dig(s); return true
	return false

## Applies a landed send (after the telegraph warning).
func attack(s: WtMinigameSession, effect: StringName, data: Dictionary) -> void:
	match effect:
		&"flip_axis":
			s.state.flip_next = true
		&"fast_parade":
			s.state.fast_next = true
		&"decoy_bombs":
			s.state.decoys = int(s.state.decoys) + int(data.get("count", s.params.get("decoy_count", 4)))
		&"wobble_tower":
			s.state.wobble_until = s.now_ms() + int(data.get("duration_ms", s.params.get("wobble_ms", 5000)))
			_pull_view(s)
		&"sticky_axis":
			s.state.locked_axis = s.attack_rng.randi_range(0, 2)
			s.state.locked_until = s.now_ms() + int(data.get("duration_ms", s.params.get("sticky_ms", 8000)))
			_spin_view(s)
		&"mud":
			_dig_mud(s, int(data.get("count", s.params.get("mud_count", 3))))

# ---------------------------------------------------------------- helpers

## Reads argument `index` (or `key` of a leading Dictionary).
static func _arg(cmd: SimCommand, index: int, key: String, fallback: Variant = null) -> Variant:
	if not cmd.args.is_empty() and cmd.args[0] is Dictionary: return (cmd.args[0] as Dictionary).get(key, fallback)
	if index < cmd.args.size(): return cmd.args[index]
	return fallback

## Grid step (x, row) from a Vector3i / Vector2i / Dictionary{direction} / Array argument.
static func _direction(args: Array) -> Vector2i:
	if args.is_empty(): return Vector2i.ZERO
	var raw: Variant = args[0]
	if raw is Dictionary: raw = (raw as Dictionary).get("direction", Vector2i.ZERO)
	if raw is Vector3i: return Vector2i((raw as Vector3i).x, (raw as Vector3i).z)
	if raw is Vector2i: return raw
	if raw is Array and (raw as Array).size() >= 2: return Vector2i(int((raw as Array)[0]), int((raw as Array)[1]))
	return Vector2i.ZERO

func _pool(s: WtMinigameSession) -> PackedStringArray:
	return s.shape_pool()

func _pick_shape(s: WtMinigameSession) -> ShapeDef:
	var pool: PackedStringArray = _pool(s)
	return s.catalog.shapes.get_shape(StringName(pool[s.rng.randi_range(0, pool.size() - 1)]))

## Sorted key of a shape orientation, translation-normalised (symmetric orientations match).
static func orient_key(shape: ShapeDef, o: int) -> String:
	var low: Vector3i = shape.min_corner(o)
	var cells: Array[Vector3i] = []
	for v: Vector3i in shape.offsets(o): cells.append(v - low)
	cells.sort()
	var key: String = ""
	for v: Vector3i in cells: key += "%d,%d,%d;" % [v.x, v.y, v.z]
	return key

## Minimum quarter-turns (BFS over the 24 orientations) from `start` to any orientation equal to `target`.
static func spin_par(shape: ShapeDef, start: int, target: int) -> int:
	var goal: String = orient_key(shape, target)
	var dist: PackedInt32Array = PackedInt32Array()
	dist.resize(Orientations.COUNT)
	dist.fill(-1)
	dist[start] = 0
	var queue: Array[int] = [start]
	var head: int = 0
	while head < queue.size():
		var o: int = queue[head]
		head += 1
		if orient_key(shape, o) == goal: return dist[o]
		for axis: int in 3:
			for dir: int in [-1, 1]:
				var n: int = Orientations.turn(o, axis as Orientations.Axis, dir)
				if dist[n] < 0:
					dist[n] = dist[o] + 1
					queue.append(n)
	return 0

# ---------------------------------------------------------------- MG30 Mirror Mirror

func _mirror_new(s: WtMinigameSession) -> void:
	var count: int = mini(int(s.params.get("max_cells", 12)), int(s.params.get("start_cells", 6)) + int(s.state.patterns))
	var free: Array[Vector2i] = []
	for y: int in MIRROR_SIZE:
		for x: int in MIRROR_SIZE: free.append(Vector2i(x, y))
	var pattern: Array[Vector2i] = []
	for _i: int in count:
		var at: int = s.rng.randi_range(0, free.size() - 1)
		pattern.append(free[at])
		free.remove_at(at)
	s.state.pattern = pattern
	s.state.painted = {}
	s.state.axis = &"h" if bool(s.state.flip_next) else &"v"
	s.state.flip_next = false
	_mirror_view(s)

## Reflection of the shown pattern across the active axis (vertical line = x mirrored).
static func mirror_target(pattern: Array, axis: StringName) -> Dictionary:
	var out: Dictionary = {}
	for p: Vector2i in pattern:
		out[Vector2i(MIRROR_SIZE - 1 - p.x, p.y) if axis == &"v" else Vector2i(p.x, MIRROR_SIZE - 1 - p.y)] = true
	return out

func _mirror_move(s: WtMinigameSession, dir: Vector2i) -> void:
	if absi(dir.x) + absi(dir.y) != 1: return
	var cursor: Vector2i = s.state.cursor + dir
	s.state.cursor = Vector2i(clampi(cursor.x, 0, MIRROR_SIZE - 1), clampi(cursor.y, 0, MIRROR_SIZE - 1))
	_mirror_view(s)

func _mirror_paint(s: WtMinigameSession) -> void:
	var painted: Dictionary = s.state.painted
	var cursor: Vector2i = s.state.cursor
	if painted.has(cursor): painted.erase(cursor)
	else: painted[cursor] = true
	_mirror_view(s)

func _mirror_submit(s: WtMinigameSession) -> void:
	var target: Dictionary = mirror_target(s.state.pattern, s.state.axis)
	var painted: Dictionary = s.state.painted
	var inter: int = 0
	for key: Variant in painted:
		if target.has(key): inter += 1
	var union: int = painted.size() + target.size() - inter
	var score: int = (20 * inter + union) / (2 * union) if union > 0 else 0
	s.add_score(score)
	if inter * 1000 >= roundi(float(s.params.get("flip_accuracy", 0.9)) * 1000.0) * union:
		s.charge_send(&"flip_axis", {}, int(s.params.get("flip_charge", 2)))
	s.emit(&"mg_mirror_scored", {"accuracy_milli": inter * 1000 / maxi(1, union), "score": score})
	s.state.patterns = int(s.state.patterns) + 1
	_mirror_new(s)

func _mirror_view(s: WtMinigameSession) -> void:
	s.view = {"kind": "mirror", "size": MIRROR_SIZE, "pattern": (s.state.pattern as Array).duplicate(), "painted": (s.state.painted as Dictionary).keys(),
		"cursor": s.state.cursor, "axis": s.state.axis, "patterns": s.state.patterns, "flip_pending": s.state.flip_next,
		"hint": "Paint the reflection across the %s line" % ("centre" if s.state.axis == &"v" else "horizontal")}

# ---------------------------------------------------------------- MG31 Colour Count

func _tally_new(s: WtMinigameSession) -> void:
	var lo: int = int(s.params.get("parade_min", 12))
	var hi: int = maxi(lo, int(s.params.get("parade_max", 20)))
	var n: int = s.rng.randi_range(lo, hi)
	var pool: PackedStringArray = _pool(s)
	var items: Array[Dictionary] = []
	for _i: int in n: items.append({"shape": pool[s.rng.randi_range(0, pool.size() - 1)], "hue": s.rng.randi_range(0, 3)})
	var target: int = int(items[s.rng.randi_range(0, n - 1)].hue)
	var count: int = 0
	for item: Dictionary in items:
		if int(item.hue) == target: count += 1
	var ms: int = int(s.params.get("parade_ms", 450))
	if bool(s.state.fast_next):
		ms = maxi(int(s.params.get("parade_min_ms", 250)), ms - int(s.params.get("fast_cut_ms", 150)))
		s.state.fast_next = false
	# Distractors: distinct, non-answer values >= 1 within +-1..4.
	var cands: Array[int] = []
	for off: int in [-4, -3, -2, -1, 1, 2, 3, 4]:
		if count + off >= 1: cands.append(count + off)
	var choices: Array[int] = []
	for _d: int in 3:
		var at: int = s.rng.randi_range(0, cands.size() - 1)
		choices.append(cands[at])
		cands.remove_at(at)
	var answer_index: int = s.rng.randi_range(0, choices.size())
	choices.insert(answer_index, count)
	s.state.merge({"items": items, "target_hue": target, "count": count, "parade_ms": ms, "started": s.now_ms(), "tally_phase": &"parade",
		"choices": choices, "answer_index": answer_index}, true)
	_tally_view(s)

func _tally_tick(s: WtMinigameSession) -> void:
	if s.state.tally_phase == &"parade" and s.now_ms() - int(s.state.started) >= (s.state.items as Array).size() * int(s.state.parade_ms):
		s.state.tally_phase = &"ask"
	_tally_view(s)

func _tally_answer(s: WtMinigameSession, index: int) -> void:
	if s.state.tally_phase != &"ask": return
	if index < 0 or index >= (s.state.choices as Array).size(): return
	if index == int(s.state.answer_index):
		s.add_score(int(s.params.get("correct_points", 3)))
		s.charge_send(&"fast_parade", {}, int(s.params.get("fast_charge", 2)))
	_tally_new(s)

func _tally_view(s: WtMinigameSession) -> void:
	var items: Array = s.state.items
	var showing: bool = s.state.tally_phase == &"parade"
	var shown: int = (s.now_ms() - int(s.state.started)) / maxi(1, int(s.state.parade_ms))
	var current: Dictionary = (items[shown] as Dictionary).duplicate() if showing and shown < items.size() else {}
	s.view = {"kind": "tally", "phase": s.state.tally_phase, "target_hue": s.state.target_hue, "current": current, "shown": shown, "total": items.size(),
		"parade_ms": s.state.parade_ms, "choices": [] if showing else (s.state.choices as Array).duplicate(), "hint": "Count the target colour"}

# ---------------------------------------------------------------- MG32 Whack-a-Block

func _pop_ms(s: WtMinigameSession) -> int:
	var start: int = int(s.params.get("pop_ms", 900))
	var low: int = int(s.params.get("pop_min_ms", 550))
	return start - (start - low) * mini(s.now_ms(), 60000) / 60000

func _whack_tick(s: WtMinigameSession) -> void:
	var pops: Dictionary = s.state.pops
	for hole: int in pops.keys():
		if s.now_ms() >= int((pops[hole] as Dictionary).until): pops.erase(hole)
	if s.now_ms() >= int(s.state.next_spawn):
		var ms: int = _pop_ms(s)
		var hole: int = s.rng.randi_range(0, WHACK_HOLES - 1)
		var roll: int = s.rng.randi_range(0, 999)
		var bomb_t: int = roundi(float(s.params.get("bomb_chance", 0.125)) * 1000.0)
		var gold_t: int = bomb_t + roundi(float(s.params.get("golden_chance", 0.1)) * 1000.0)
		var kind: StringName = &"bomb" if roll < bomb_t else (&"golden" if roll < gold_t else &"block")
		var disguised_until: int = 0
		if int(s.state.decoys) > 0:
			s.state.decoys = int(s.state.decoys) - 1
			kind = &"bomb"
			disguised_until = s.now_ms() + int(s.params.get("disguise_ms", 300))
		for _i: int in WHACK_HOLES:
			if not pops.has(hole): break
			hole = (hole + 1) % WHACK_HOLES
		if not pops.has(hole): pops[hole] = {"kind": kind, "until": s.now_ms() + ms, "disguised_until": disguised_until}
		s.state.next_spawn = s.now_ms() + ms * 2 / 3
	_whack_view(s)

func _whack_hit(s: WtMinigameSession, index: int) -> void:
	var pops: Dictionary = s.state.pops
	if not pops.has(index): return
	var pop: Dictionary = pops[index]
	pops.erase(index)
	match StringName(pop.kind):
		&"bomb": s.add_score(-int(s.params.get("bomb_penalty", 2)))
		&"golden", &"block":
			s.add_score(int(s.params.get("golden_points", 3)) if pop.kind == &"golden" else int(s.params.get("block_points", 1)))
			s.state.good_hits = int(s.state.good_hits) + 1
			s.charge_send(&"decoy_bombs", {"count": int(s.params.get("decoy_count", 4))}, int(s.params.get("decoy_charge", 8)))
	_whack_view(s)

func _whack_view(s: WtMinigameSession) -> void:
	var shown: Array[Dictionary] = []
	var pops: Dictionary = s.state.pops
	var holes: Array = pops.keys()
	holes.sort()
	for hole: int in holes:
		var pop: Dictionary = pops[hole]
		var disguised: bool = s.now_ms() < int(pop.disguised_until)
		shown.append({"index": hole, "kind": &"block" if disguised else pop.kind, "disguised": disguised, "until": pop.until})
	s.view = {"kind": "whack", "pops": shown, "holes": WHACK_HOLES, "decoys": s.state.decoys, "hint": "Tap blocks - leave the bombs"}

# ---------------------------------------------------------------- MG33 Tower Pull

func _pull_start(s: WtMinigameSession) -> void:
	s.state.merge({"cursor": Vector2i(1, 0), "layers": [], "rebuild_until": 0, "wobble_until": 0, "pulls": 0, "topples": 0}, true)
	_pull_rebuild(s)

func _pull_rebuild(s: WtMinigameSession) -> void:
	var layers: Array = []
	for _l: int in int(s.params.get("layers", 9)): layers.append([true, true, true])
	s.state.layers = layers
	s.state.rebuild_until = 0
	_pull_view(s)

## Layer stability (F2): normal = centre or both edges; wobble = centre with an edge, or both edges.
static func layer_stable(bars: Array, wobble: bool) -> bool:
	var left: bool = bool(bars[0])
	var centre: bool = bool(bars[1])
	var right: bool = bool(bars[2])
	if wobble: return (centre and (left or right)) or (left and right)
	return centre or (left and right)

func _pull_move(s: WtMinigameSession, dir: Vector2i) -> void:
	if absi(dir.x) + absi(dir.y) != 1: return
	var cursor: Vector2i = s.state.cursor + Vector2i(dir.x, -dir.y)
	s.state.cursor = Vector2i(clampi(cursor.x, 0, TOWER_SLOTS - 1), clampi(cursor.y, 0, (s.state.layers as Array).size() - 1))
	_pull_view(s)

func _pull_tick(s: WtMinigameSession) -> void:
	if int(s.state.rebuild_until) > 0 and s.now_ms() >= int(s.state.rebuild_until): _pull_rebuild(s)
	else: _pull_view(s)

func _pull(s: WtMinigameSession, layer: int, slot: int) -> void:
	if int(s.state.rebuild_until) > 0: return
	var layers: Array = s.state.layers
	if layer < 0 or layer > layers.size() - 3 or slot < 0 or slot >= TOWER_SLOTS: return
	var bars: Array = layers[layer]
	if not bool(bars[slot]): return
	bars[slot] = false
	if not layer_stable(bars, s.now_ms() < int(s.state.wobble_until)):
		s.add_score(-int(s.params.get("topple_penalty", 5)))
		s.state.topples = int(s.state.topples) + 1
		s.state.rebuild_until = s.now_ms() + int(s.params.get("rebuild_ms", 2500))
		s.emit(&"mg_tower_toppled", {"layer": layer, "slot": slot})
		_pull_view(s)
		return
	# Place the bar on top, completing the top layer before starting a new one.
	var top: Array = layers[layers.size() - 1]
	if top.all(func(b: Variant) -> bool: return bool(b)): layers.append([true, false, false])
	else:
		for i: int in TOWER_SLOTS:
			if not bool(top[i]):
				top[i] = true
				break
	s.state.pulls = int(s.state.pulls) + 1
	s.add_score(2 if layer < int(s.params.get("deep_bonus_layers", 3)) else 1)
	s.charge_send(&"wobble_tower", {"duration_ms": int(s.params.get("wobble_ms", 5000))}, int(s.params.get("wobble_charge", 4)))
	_pull_view(s)

func _pull_view(s: WtMinigameSession) -> void:
	s.view = {"kind": "pull", "layers": (s.state.layers as Array).duplicate(true), "rebuilding": int(s.state.rebuild_until) > 0,
		"rebuild_until": s.state.rebuild_until, "wobble_until": s.state.wobble_until, "wobbling": s.now_ms() < int(s.state.wobble_until),
		"cursor": s.state.cursor, "pulls": s.state.pulls, "topples": s.state.topples, "hint": "Pull a bar - keep every layer standing"}

# ---------------------------------------------------------------- MG34 Spin Match

func _spin_new(s: WtMinigameSession) -> void:
	var shape: ShapeDef = _pick_shape(s)
	var start: int = s.rng.randi_range(0, Orientations.COUNT - 1)
	var target: int = s.rng.randi_range(0, Orientations.COUNT - 1)
	for _try: int in 40:
		if orient_key(shape, start) != orient_key(shape, target) and shape.distinct_count > 1: break
		if shape.distinct_count <= 1: shape = _pick_shape(s)
		start = s.rng.randi_range(0, Orientations.COUNT - 1)
		target = s.rng.randi_range(0, Orientations.COUNT - 1)
	s.state.merge({"shape": shape.shape_id, "orient": start, "target": target, "par": spin_par(shape, start, target), "turns": 0}, true)
	_spin_view(s)

func _spin_shape(s: WtMinigameSession) -> ShapeDef:
	return s.catalog.shapes.get_shape(StringName(s.state.shape))

func _spin_rotate(s: WtMinigameSession, axis: int, dir: int) -> void:
	axis = clampi(axis, 0, 2)
	if axis == int(s.state.locked_axis) and s.now_ms() < int(s.state.locked_until): return
	s.state.orient = Orientations.turn(int(s.state.orient), axis as Orientations.Axis, 1 if dir >= 0 else -1)
	s.state.turns = int(s.state.turns) + 1
	_spin_view(s)

func _spin_submit(s: WtMinigameSession) -> void:
	var shape: ShapeDef = _spin_shape(s)
	var turns: int = int(s.state.turns)
	var par: int = int(s.state.par)
	if orient_key(shape, int(s.state.orient)) == orient_key(shape, int(s.state.target)):
		s.add_score(maxi(1, int(s.params.get("par_bonus", 6)) - maxi(0, turns - par)))
		if turns <= par: s.charge_send(&"sticky_axis", {"duration_ms": int(s.params.get("sticky_ms", 8000))}, int(s.params.get("sticky_charge", 3)))
	s.state.puzzles = int(s.state.puzzles) + 1
	_spin_new(s)

func _spin_view(s: WtMinigameSession) -> void:
	if not s.state.has("shape"): return
	var shape: ShapeDef = _spin_shape(s)
	var locked: bool = s.now_ms() < int(s.state.locked_until)
	s.view = {"kind": "spin", "shape_id": s.state.shape, "orient": s.state.orient, "target_orient": s.state.target, "turns": s.state.turns, "par": s.state.par,
		"cells": _normal_cells(shape, int(s.state.orient)), "target_cells": _normal_cells(shape, int(s.state.target)),
		"locked_axis": int(s.state.locked_axis) if locked else -1, "locked_until": s.state.locked_until, "hint": "Turn your block to match the target"}

func _normal_cells(shape: ShapeDef, o: int) -> Array[Vector3i]:
	var low: Vector3i = shape.min_corner(o)
	var out: Array[Vector3i] = []
	for v: Vector3i in shape.offsets(o): out.append(v - low)
	return out

# ---------------------------------------------------------------- MG35 Plinko Drop

func _plinko_start(s: WtMinigameSession) -> void:
	var cols: int = int(s.params.get("columns", 7))
	s.state.merge({"aim": cols / 2, "drop": {}, "cooldown_until": 0, "pattern_serial": -1, "pattern": [], "claimed": {}, "awarded": {}, "last_bucket": -1}, true)
	_plinko_pattern(s, 0)
	_plinko_view(s)

## Peg deflections [row][column] = -1 (left) or +1 (right), same for everyone for a serial.
func _plinko_pattern(s: WtMinigameSession, serial: int) -> void:
	var cols: int = int(s.params.get("columns", 7))
	var shared: RandomNumberGenerator = Seeds.make_rng(s.rng.seed, ["plinko", serial])
	var pattern: Array = []
	for _r: int in int(s.params.get("rows", 6)):
		var row: Array = []
		for _c: int in cols: row.append(-1 if shared.randi_range(0, 1) == 0 else 1)
		pattern.append(row)
	s.state.pattern = pattern
	s.state.pattern_serial = serial

func _jackpot_serial(s: WtMinigameSession) -> int:
	return s.now_ms() / maxi(1, int(s.params.get("jackpot_ms", 15000)))

func _jackpot_active(s: WtMinigameSession) -> bool:
	var serial: int = _jackpot_serial(s)
	return serial >= 1 and s.now_ms() - serial * int(s.params.get("jackpot_ms", 15000)) < int(s.params.get("jackpot_window_ms", 4000))

func _plinko_aim(s: WtMinigameSession, dir: int) -> void:
	s.state.aim = clampi(int(s.state.aim) + signi(dir), 0, int(s.params.get("columns", 7)) - 1)
	_plinko_view(s)

func _plinko_drop(s: WtMinigameSession) -> void:
	if not (s.state.drop as Dictionary).is_empty() or s.now_ms() < int(s.state.cooldown_until): return
	var cols: int = int(s.params.get("columns", 7))
	var pattern: Array = (s.state.pattern as Array).duplicate(true)
	var col: int = int(s.state.aim)
	var path: Array[int] = []
	for row: Array in pattern:
		col = clampi(col + int(row[col]), 0, cols - 1)
		path.append(col)
	var step: int = int(s.params.get("drop_step_ms", 180))
	s.state.drop = {"col": int(s.state.aim), "row": -1, "path": path, "next": s.now_ms() + step, "start": int(s.state.aim)}
	s.state.cooldown_until = s.now_ms() + int(s.params.get("drop_cooldown_ms", 1200))
	_plinko_view(s)

func _plinko_tick(s: WtMinigameSession) -> void:
	var serial: int = _jackpot_serial(s)
	if serial != int(s.state.pattern_serial) and (s.state.drop as Dictionary).is_empty(): _plinko_pattern(s, serial)
	var drop: Dictionary = s.state.drop
	var step: int = int(s.params.get("drop_step_ms", 180))
	while not drop.is_empty() and s.now_ms() >= int(drop.next):
		drop.row = int(drop.row) + 1
		drop.next = int(drop.next) + step
		var path: Array = drop.path
		if int(drop.row) < path.size(): drop.col = int(path[int(drop.row)])
		else:
			_plinko_land(s, int(drop.col))
			s.state.drop = {}
			drop = s.state.drop
	_plinko_view(s)

func _plinko_land(s: WtMinigameSession, col: int) -> void:
	var buckets: Array = s.params.get("buckets", [1, 3, 5, 10, 5, 3, 1])
	var value: int = int(buckets[col])
	var top: bool = value == int((buckets.max() as int))
	var serial: int = _jackpot_serial(s)
	var jackpot: bool = top and _jackpot_active(s)
	s.state.last_bucket = col
	s.add_score(value * 2 if jackpot else value)
	s.emit(&"mg_plinko_landed", {"bucket": col, "value": value, "jackpot": jackpot})
	if jackpot and not (s.state.claimed as Dictionary).has(serial):
		s.state.claimed[serial] = true
		if s.players() <= 1: _award_jackpot(s, serial)
		else: s.request_shared(&"plinko_jackpot_claim", {"serial": serial, "player": s.player_id})

func _award_jackpot(s: WtMinigameSession, serial: int) -> void:
	if (s.state.awarded as Dictionary).has(serial): return
	s.state.awarded[serial] = true
	s.add_score(int(s.params.get("jackpot_bonus", 5)))

func _plinko_view(s: WtMinigameSession) -> void:
	var interval: int = int(s.params.get("jackpot_ms", 15000))
	var drop: Dictionary = s.state.drop
	s.view = {"kind": "plinko", "columns": s.params.get("columns", 7), "rows": s.params.get("rows", 6), "buckets": (s.params.get("buckets", [1, 3, 5, 10, 5, 3, 1]) as Array).duplicate(),
		"pattern": (s.state.pattern as Array).duplicate(true), "aim": s.state.aim, "drop": drop.duplicate(true), "cooldown_until": s.state.cooldown_until,
		"jackpot_active": _jackpot_active(s), "jackpot_next_ms": (_jackpot_serial(s) + 1) * interval, "last_bucket": s.state.last_bucket,
		"hint": "Pick a column and drop - the jackpot makes the 10 bucket worth double"}

# ---------------------------------------------------------------- MG36 Treasure Dig

func _dig_new(s: WtMinigameSession) -> void:
	var cells: Array[Vector2i] = []
	for _try: int in 60:
		var shape: ShapeDef = _pick_shape(s)
		var o: int = s.rng.randi_range(0, Orientations.COUNT - 1)
		var footprint: Dictionary = {}
		for v: Vector3i in shape.offsets(o): footprint[Vector2i(v.x, v.z)] = true
		var keys: Array = footprint.keys()
		var low: Vector2i = keys[0]
		var high: Vector2i = keys[0]
		for k: Vector2i in keys:
			low = Vector2i(mini(low.x, k.x), mini(low.y, k.y))
			high = Vector2i(maxi(high.x, k.x), maxi(high.y, k.y))
		if keys.size() < 3 or keys.size() > 5 or high.x - low.x >= DIG_SIZE or high.y - low.y >= DIG_SIZE: continue
		var shift: Vector2i = Vector2i(s.rng.randi_range(0, DIG_SIZE - 1 - (high.x - low.x)), s.rng.randi_range(0, DIG_SIZE - 1 - (high.y - low.y))) - low
		keys.sort()
		for k: Vector2i in keys: cells.append(k + shift)
		s.state.treasure_shape = shape.shape_id
		break
	if cells.is_empty():
		cells = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
		s.state.treasure_shape = &"tri_straight"
	s.state.treasure = cells
	s.state.revealed = {}
	s.state.misses = {}
	s.state.miss_count = 0
	_dig_view(s)

func _dig_move(s: WtMinigameSession, dir: Vector2i) -> void:
	if absi(dir.x) + absi(dir.y) != 1: return
	var cursor: Vector2i = s.state.cursor + dir
	s.state.cursor = Vector2i(clampi(cursor.x, 0, DIG_SIZE - 1), clampi(cursor.y, 0, DIG_SIZE - 1))
	_dig_view(s)

func _dig(s: WtMinigameSession) -> void:
	var cell: Vector2i = s.state.cursor
	var revealed: Dictionary = s.state.revealed
	var misses: Dictionary = s.state.misses
	if revealed.has(cell) or misses.has(cell): return
	if (s.state.treasure as Array).has(cell):
		revealed[cell] = true
		if revealed.size() == (s.state.treasure as Array).size():
			s.add_score(maxi(int(s.params.get("min_reward", 2)), int(s.params.get("max_reward", 12)) - int(s.state.miss_count)))
			s.state.treasures = int(s.state.treasures) + 1
			s.charge_send(&"mud", {"count": int(s.params.get("mud_count", 3))}, int(s.params.get("mud_charge", 2)))
			s.emit(&"mg_treasure_found", {"misses": s.state.miss_count})
			_dig_new(s)
			return
	else:
		s.state.miss_count = int(s.state.miss_count) + 1
		misses[cell] = _dig_distance(s, cell)
	_dig_view(s)

func _dig_distance(s: WtMinigameSession, cell: Vector2i) -> int:
	var best: int = 1000
	for t: Vector2i in s.state.treasure:
		if (s.state.revealed as Dictionary).has(t): continue
		best = mini(best, absi(t.x - cell.x) + absi(t.y - cell.y))
	return best

func _dig_mud(s: WtMinigameSession, count: int) -> void:
	var misses: Dictionary = s.state.misses
	var keys: Array = misses.keys()
	keys.sort()
	for _i: int in mini(count, keys.size()):
		var at: int = s.attack_rng.randi_range(0, keys.size() - 1)
		misses.erase(keys[at])
		keys.remove_at(at)
	_dig_view(s)

func _dig_view(s: WtMinigameSession) -> void:
	s.view = {"kind": "dig", "size": DIG_SIZE, "cursor": s.state.cursor, "revealed": (s.state.revealed as Dictionary).keys(), "misses": (s.state.misses as Dictionary).duplicate(),
		"treasure_size": (s.state.treasure as Array).size(), "miss_count": s.state.miss_count, "treasures": s.state.treasures,
		"hint": "Dig - the number is the distance to the nearest buried cube"}

# ---------------------------------------------------------------- authority

func _authority(s: WtMinigameSession, data: Dictionary) -> void:
	if s.id == &"mg35" and StringName(data.get("kind", "")) == &"plinko_jackpot_awarded":
		if int(data.get("winner", -1)) == s.player_id and int(data.get("serial", 0)) >= 1: _award_jackpot(s, int(data.get("serial", 0)))
