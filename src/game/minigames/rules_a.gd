class_name WtMinigameRulesA extends RefCounted
## Distinct fit, memory, colour, timing, sorting, catching, rhythm, magnet and volley verbs.
func start(s: WtMinigameSession) -> void:
	match s.id:
		&"mg01":
			s.set_frame(Vector3i(4, 4, 4))
			s.state = {"passes": 0, "streak": 0, "stunned_until": 0, "tight_next": false}
			_wall(s)
		&"mg02":
			s.state = {"model_index": 0, "smudge_next": 0}
			_model(s)
		&"mg03":
			s.set_board({"width": 5, "depth": 5, "h_play": 12}, {}, {"clear.detector": "colour_connect", "clear.collapse": "cascade", "spawn.colour_count": 4, "clear.pop_min": 4, "clear.pop_min_pieces": 1})
			s.state = {"chain": 0, "grey": [], "pending_grey": 0}
		&"mg04":
			s.set_frame(Vector3i(4, 40, 4))
			s.state = {"perfect_streak": 0, "direction": 1, "shield": false, "slide_at": 0}
			_slider(s)
		&"mg09":
			s.state = {"serial": 0, "streak": 0, "jam_until": 0, "gold_serial": 0, "next_ms": 0, "gold_due": 10000}
			s.view = {"bins": PackedInt32Array([1, 2, 3]), "kind": "chute"}
			_sort_piece(s)
		&"mg15":
			s.set_frame(Vector3i(7, 40, 7))
			s.state = {"tray": Vector2i(2, 2), "catches": 0, "slippery_until": 0}
			_sky(s)
		&"mg16":
			s.state = {"beat": 0, "notes": [], "combo": 0, "offbeat_until": 0}
			_notes(s)
		&"mg17":
			s.state = {"docked": 0, "polarity": 1, "reversed_until": 0}
			_maze(s)
		&"mg18":
			s.state = {"serial": 0, "waiting": false}
			_volley_ball(s)
		_: s.finish(&"invalid")

func tick(s: WtMinigameSession, events: Array[SimEvent]) -> void:
	match s.id:
		&"mg01":
			if s.now_ms() >= int(s.state.wall_due):
				var projected: Array[Vector2i] = projection(s.active.cells(), int(s.state.wall_axis))
				var fits: bool = subset(projected, s.state.hole)
				if fits:
					var perfect: bool = same_cells(projected, s.state.hole_core)
					s.add_score(2 if perfect else 1)
					s.state.passes = int(s.state.passes) + 1
					s.state.streak = int(s.state.streak) + 1
					s.charge_send(&"tight_wall", {}, int(s.params.get("tight_charge", 3)))
					s.emit(&"mg_wall_passed", {"perfect": perfect})
				else:
					s.state.streak = 0
					s._send.charge = 0
					s.state.stunned_until = s.now_ms() + 1000
					s.emit(&"mg_wall_bonk")
				_wall(s)
		&"mg02":
			s.view.model = s.state.model.duplicate() if s.now_ms() < int(s.state.show_until) else []
			for event: SimEvent in events:
				if event.kind == SimEvents.PIECE_LOCKED:
					s.state.model_locks = int(s.state.model_locks) + 1
					if int(s.state.model_locks) >= s.state.model_pieces.size():
						var accuracy: int = accuracy_milli(s.board_cells(), s.state.model)
						var elapsed: int = maxi(0, s.now_ms() - int(s.state.show_until))
						var bonus: int = maxi(0, 50 - elapsed * 50 / 30000)
						s.add_score((accuracy + 5) / 10 + bonus)
						s.emit(&"mg_model_scored", {"accuracy_milli": accuracy, "speed_bonus": bonus})
						s.charge_send(&"smudge", {"amount": 1500})
						_model(s)
		&"mg03":
			for event: SimEvent in events:
				if event.kind == SimEvents.PIECE_LOCKED:
					s.state.chain = 0
					_grey_drop(s)
				elif event.kind == SimEvents.LAYERS_CLEARED:
					s.state.chain = int(s.state.chain) + 1
					s.add_score(maxi(1, event.data.get("cells", []).size()))
					var positions: Array[Vector3i] = []
					for index: int in event.data.get("cells", []): positions.append(s.sim.board().cell(index))
					_grey_clear(s, positions)
					if int(s.state.chain) >= 2: s.request_send(&"grey_garbage", {"count": int(s.state.chain) - 1})
		&"mg04":
			var speed: int = 2000 + mini(2000, s.now_ms() * 2000 / maxi(1, int(s.template.get("duration_ms", 60000))))
			var delay: int = 1000000 / speed
			if s.now_ms() >= int(s.state.slide_at):
				s.active.pivot.x += int(s.state.direction)
				if s.active.pivot.x > 5: s.active.pivot.x = -s.active.shape.bbox(s.active.orient).x
				if s.active.pivot.x < -5: s.active.pivot.x = 4
				s.state.slide_at = s.now_ms() + delay
			s.view.slide_cells = s.active.cells()
			s.view.height = s.top_height()
			s.progress = mini(1000, s.top_height() * 100)
		&"mg09":
			if s.now_ms() >= int(s.state.next_ms):
				if not bool(s.state.get("sorted", true)):
					s.state.streak = 0
					s.state.jam_until = s.now_ms() + 1000
				_sort_piece(s)
			s.view.jam_until = s.state.jam_until
		&"mg15":
			if s.now_ms() >= int(s.state.drop_start) and s.now_ms() >= int(s.state.fall_at):
				s.state.fall_at = s.now_ms() + 100
				if _sky_supported(s): _catch(s)
				else: s.active.pivot.y -= 1
			s.view.sky_cells = s.active.cells()
			s.view.tray = s.state.tray
			s.view.height = s.top_height()
		&"mg16":
			_notes(s)
			for note: Dictionary in s.state.notes:
				if not bool(note.hit) and not bool(note.missed) and s.now_ms() > int(note.at) + int(s.params.get("hit_window_ms", 180)):
					note.missed = true
					s.state.combo = 0
					s.emit(&"mg_rhythm_miss", {"lane": note.lane})
			s.view.notes = s.state.notes.duplicate(true)
			s.view.combo = s.state.combo
			s.view.offbeat_until = s.state.offbeat_until
		&"mg17": _maze_view(s)
		&"mg18":
			if not bool(s.state.waiting) and s.now_ms() > int(s.state.return_end):
				s.state.waiting = true
				s.emit(&"mg_volley_miss", {"serial": s.state.serial})
				s.request_shared(&"volley_point", {"loser": s.player_id, "serial": s.state.serial, "amount": 1})
				if s.players() == 1: _volley_ball(s)
			s.view.waiting = s.state.waiting

func command(s: WtMinigameSession, cmd: SimCommand) -> bool:
	if cmd.kind == &"mg_authority":
		var data: Dictionary = cmd.args[0] if not cmd.args.is_empty() else {}
		if s.id == &"mg09" and StringName(data.get("kind", "")) == &"gold_gem_awarded":
			if int(data.get("winner", -1)) == s.player_id: s.add_score(3)
			elif int(data.get("leader", -1)) == s.player_id: s.add_score(-mini(3, s.points))
			return true
		if s.id == &"mg18" and StringName(data.get("kind", "")) == &"volley_point":
			if int(data.get("winner", -1)) == s.player_id: s.add_score(int(data.get("amount", 1)))
			return true
	match s.id:
		&"mg01":
			if s.now_ms() < int(s.state.stunned_until): return true
			if cmd.kind == &"mg_rotate" and cmd.args.size() >= 2:
				var axis: int = clampi(int(cmd.args[0]), 0, 2)
				var sign_value: int = 1 if int(cmd.args[1]) >= 0 else -1
				Movement.try_rotate(s.active, s.frame, axis as Orientations.Axis, sign_value, {"max_up_kicks": 0})
			elif cmd.kind == &"mg_move" and not cmd.args.is_empty(): Movement.try_translate(s.active, s.frame, cmd.args[0])
			s.view.piece_cells = s.active.cells()
			return true
		&"mg02": return s.now_ms() < int(s.state.show_until)
		&"mg04":
			if cmd.kind == &"mg_drop": _release(s)
			return true
		&"mg09":
			if cmd.kind == &"mg_sort" and not cmd.args.is_empty() and not bool(s.state.sorted) and s.now_ms() >= int(s.state.jam_until):
				var bin: int = int(cmd.args[0])
				if bin < 0 or bin > 2: return true
				s.state.sorted = true
				if int(s.view.bins[bin]) == int(s.state.colour):
					s.state.streak = int(s.state.streak) + 1
					s.add_score(1 + (1 if int(s.state.streak) % 5 == 0 else 0))
					if bool(s.state.golden): s.request_shared(&"gold_gem_claim", {"serial": s.state.gold_serial, "player": s.player_id})
				else:
					s.state.streak = 0
					s.state.jam_until = s.now_ms() + 1000
					s.emit(&"mg_sort_jam")
			return true
		&"mg15":
			if cmd.kind == &"mg_move" and not cmd.args.is_empty(): _tray_move(s, cmd.args[0])
			return true
		&"mg16":
			if cmd.kind == &"mg_rhythm_hit" and not cmd.args.is_empty(): _rhythm_hit(s, int(cmd.args[0]))
			return true
		&"mg17":
			if cmd.kind == &"mg_magnet_move" and not cmd.args.is_empty(): _magnet_move(s, cmd.args[0])
			elif cmd.kind == &"mg_polarity": s.state.polarity = -int(s.state.polarity)
			elif cmd.kind == &"mg_reset":
				s.state.cursor = s.state.path[0]
				s.state.block = s.state.path[0]
			_maze_view(s)
			return true
		&"mg18":
			if cmd.kind == &"mg_volley" and not bool(s.state.waiting) and s.now_ms() >= int(s.state.return_start) and s.now_ms() <= int(s.state.return_end):
				s.state.waiting = true
				s.add_score(1)
				s.request_send(&"volley_ball", {"shape_id": s.state.shape_id, "serial": s.state.serial, "flight_ms": int(s.params.get("flight_ms", 2400))})
				if s.players() == 1: _volley_ball(s)
			return true
	return false

func attack(s: WtMinigameSession, effect: StringName, data: Dictionary) -> void:
	match effect:
		&"tight_wall":
			s.state.tight_next = true
			s.state.hole = s.state.hole_core.duplicate()
			s.state.wall_due = maxi(s.now_ms() + 250, int(s.state.wall_due) - 1000)
			s.view.hole = s.state.hole.duplicate()
			s.view.wall_due = s.state.wall_due
		&"smudge": s.state.smudge_next = int(data.get("amount", 1500))
		&"grey_garbage": s.state.pending_grey = int(s.state.pending_grey) + int(data.get("count", 1))
		&"steal_slab":
			if bool(s.state.shield):
				s.state.shield = false
				s.emit(&"mg_shield_broken")
			else:
				var height: int = s.top_height()
				for cell: Vector3i in s.board_cells():
					if cell.y == height - 1: s.frame.remove(s.frame.index(cell), BoardState.Cause.DAMAGE)
		&"slippery_tray": s.state.slippery_until = s.now_ms() + int(data.get("duration_ms", 6000))
		&"offbeat": s.state.offbeat_until = s.now_ms() + int(data.get("duration_ms", 5000))
		&"polarity_reverse": s.state.reversed_until = s.now_ms() + int(data.get("duration_ms", 5000))
		&"volley_ball": _volley_ball(s, data)

static func projection(cells: Array, axis: int) -> Array[Vector2i]:
	var output: Array[Vector2i] = []
	for cell: Vector3i in cells:
		var p: Vector2i = Vector2i(cell.y, cell.z) if axis == 0 else Vector2i(cell.x, cell.z) if axis == 1 else Vector2i(cell.x, cell.y)
		if p not in output: output.append(p)
	return output

static func subset(cells: Array, target: Array) -> bool:
	for cell: Variant in cells:
		if cell not in target: return false
	return true

static func same_cells(a: Array, b: Array) -> bool: return a.size() == b.size() and subset(a, b)

static func accuracy_milli(built: Array, model: Array) -> int:
	var intersection: int = 0
	for cell: Variant in built:
		if cell in model: intersection += 1
	return intersection * 1000 / maxi(1, built.size() + model.size() - intersection)

func _wall(s: WtMinigameSession) -> void:
	var shape: ShapeDef = s.next_shape()
	var axis: int = s.rng.randi_range(0, 2)
	var hidden: int = s.rng.randi_range(0, 23)
	var pivot: Vector3i = (Vector3i(4, 4, 4) - shape.bbox(hidden)) / 2 - shape.min_corner(hidden)
	var target: ActivePiece = ActivePiece.new(shape, pivot, hidden)
	var hole: Array[Vector2i] = projection(target.cells(), axis)
	s.active = ActivePiece.new(shape, (Vector3i(4, 4, 4) - shape.bbox(shape.spawn_orient)) / 2 - shape.min_corner(shape.spawn_orient))
	var elapsed: int = s.now_ms()
	var duration: int = maxi(1, int(s.template.get("duration_ms", 90000)))
	var slack: int = maxi(0, 2 - elapsed * 3 / duration)
	if bool(s.state.tight_next): slack = 0
	var core: Array[Vector2i] = hole.duplicate()
	var free: Array[Vector2i] = []
	for y: int in 4:
		for x: int in 4:
			if Vector2i(x, y) not in hole: free.append(Vector2i(x, y))
	for index: int in mini(slack, free.size()):
		var chosen: int = s.rng.randi_range(0, free.size() - 1)
		hole.append(free.pop_at(chosen))
	var interval: int = 6000 - mini(3000, elapsed * 3000 / duration)
	s.state.merge({"hole": hole, "hole_core": core, "wall_axis": axis, "wall_due": elapsed + interval - (1000 if bool(s.state.tight_next) else 0), "solution_orient": hidden, "solution_pivot": pivot}, true)
	s.state.tight_next = false
	s.view = {"kind": "projection", "hole": hole.duplicate(), "hole_core": core.duplicate(), "wall_axis": axis, "wall_due": s.state.wall_due, "piece_cells": s.active.cells(), "size": Vector2i(4, 4)}
	s.emit(&"mg_wall_started", {"axis": axis, "due": s.state.wall_due})

func _model(s: WtMinigameSession) -> void:
	var pool: Array[ShapeDef] = []
	for shape: ShapeDef in s.catalog.shapes.shapes:
		if shape.cube_count >= 2 and shape.cube_count <= 4: pool.append(shape)
	if pool.is_empty(): pool.append(s.catalog.shapes.shapes[0])
	var spec: BoardSpec = BoardSpec.new()
	spec.size = Vector3i(4, 8, 4)
	spec.h_play = 4
	spec.down = BoardState.Down.Y_NEG
	spec.spawn_anchor = Vector2i(2, 2)
	spec.mask.resize(16)
	spec.mask.fill(1)
	var board: BoardState = BoardState.new(spec, s.catalog.content)
	var model: Array[Vector3i] = []
	var pieces: PackedStringArray = PackedStringArray()
	var count: int = s.rng.randi_range(2, 4)
	for index: int in count:
		var shape: ShapeDef = pool[s.rng.randi_range(0, pool.size() - 1)]
		var orient: int = shape.spawn_orient
		var box: Vector3i = shape.bbox(orient)
		var pivot: Vector3i = Vector3i(s.rng.randi_range(0, maxi(0, 4 - box.x)), 6, s.rng.randi_range(0, maxi(0, 4 - box.z))) - shape.min_corner(orient)
		var piece: ActivePiece = ActivePiece.new(shape, pivot, orient)
		piece.pivot.y -= Movement.drop_distance(piece, board)
		var cells: Array[Vector3i] = piece.cells()
		var within: bool = true
		for cell: Vector3i in cells:
			if cell.y >= 4: within = false
		if not within or model.size() + cells.size() > 14: continue
		for cell: Vector3i in cells:
			board.place(board.index(cell), s.catalog.content.kind_of(&"block"), shape.hue_id, index + 1)
			model.append(cell)
		pieces.append(String(shape.shape_id))
	if pieces.is_empty():
		pieces.append(String(pool[0].shape_id))
		for cell: Vector3i in pool[0].offsets(pool[0].spawn_orient): model.append(cell - pool[0].min_corner(pool[0].spawn_orient))
	var show: int = maxi(2000, int(s.params.get("show_ms", 5000)) - int(s.state.smudge_next))
	s.state.merge({"model": model, "model_pieces": pieces, "model_locks": 0, "model_index": int(s.state.model_index) + 1, "show_until": s.now_ms() + show, "smudge_next": 0}, true)
	s.set_board({"width": 4, "depth": 4, "h_play": 4}, {"shapes": pieces, "fixed_list": pieces}, {"fall.g0": 0.0, "goal.top_out": "out_of_pieces", "clear.enabled": false})
	s.view = {"kind": "memory", "model": model.duplicate(), "show_until": s.state.show_until, "model_index": s.state.model_index, "size": Vector2i(4, 4)}

func _grey_drop(s: WtMinigameSession) -> void:
	var board: BoardState = s.sim.board()
	for count: int in int(s.state.pending_grey):
		var free: Array[Vector3i] = []
		for z: int in 5:
			for x: int in 5:
				var y: int = 0
				while y < board.size().y and board.get_kind(board.index(Vector3i(x, y, z))) != 0: y += 1
				if y < board.limit_layer(): free.append(Vector3i(x, y, z))
		if free.is_empty(): break
		var cell: Vector3i = free[s.attack_rng.randi_range(0, free.size() - 1)]
		board.place(board.index(cell), s.catalog.content.kind_of(&"block"), 0, -1)
		board.set_status(board.index(cell), {"grey": true})
		s.state.grey.append(cell)
	s.state.pending_grey = 0

func _grey_clear(s: WtMinigameSession, cleared: Array) -> void:
	var keep: Array = []
	for grey: Vector3i in s.state.grey:
		var hit: bool = false
		for cell: Vector3i in cleared:
			var delta: Vector3i = grey - cell
			if absi(delta.x) + absi(delta.y) + absi(delta.z) == 1: hit = true
		if hit: s.sim.board().remove(s.sim.board().index(grey), BoardState.Cause.DAMAGE)
		else: keep.append(grey)
	s.state.grey = keep

func _slider(s: WtMinigameSession) -> void:
	var shape: ShapeDef = s.next_shape()
	var orient: int = shape.spawn_orient
	var box: Vector3i = shape.bbox(orient)
	var x: int = -box.x if int(s.state.direction) > 0 else 4
	s.active = ActivePiece.new(shape, Vector3i(x, s.top_height() + 3, maxi(0, (4 - box.z) / 2)) - shape.min_corner(orient), orient)
	s.state.slide_at = s.now_ms() + 500
	s.view = {"kind": "timing", "slide_cells": s.active.cells(), "perfect_streak": s.state.perfect_streak, "shield": s.state.shield, "height": s.top_height()}

func _release(s: WtMinigameSession) -> void:
	var cells: Array[Vector3i] = s.active.cells()
	var drop: int = 100000
	for cell: Vector3i in cells:
		if cell.x < 0 or cell.x >= 4 or cell.z < 0 or cell.z >= 4: continue
		var d: int = 0
		while cell.y - d > 0 and s.frame.get_kind(s.frame.index(cell - Vector3i(0, d + 1, 0))) == 0: d += 1
		drop = mini(drop, d)
	var trimmed: int = 0
	if drop == 100000: trimmed = cells.size()
	else:
		cells.sort_custom(func(a: Vector3i, b: Vector3i) -> bool: return a.y < b.y)
		for original: Vector3i in cells:
			var cell: Vector3i = original - Vector3i(0, drop, 0)
			if cell.x < 0 or cell.x >= 4 or cell.z < 0 or cell.z >= 4 or cell.y >= 40:
				trimmed += 1
			elif cell.y == 0 or s.frame.get_kind(s.frame.index(cell + Vector3i.DOWN)) != 0:
				s.frame.place(s.frame.index(cell), s.catalog.content.kind_of(&"block"), s.active.hue_id, s.spawner.drawn_count())
			else: trimmed += 1
	if trimmed == 0:
		s.state.perfect_streak = int(s.state.perfect_streak) + 1
		if int(s.state.perfect_streak) >= s.charge_needed(3):
			s.state.perfect_streak = 0
			if s.rank() == 1: s.state.shield = true
			else:
				s.request_send(&"steal_slab")
				var height: int = s.top_height()
				if height < 40:
					for z: int in 4:
						for x: int in 4: s.frame.place(s.frame.index(Vector3i(x, height, z)), s.catalog.content.kind_of(&"block"), 1, -1)
	else: s.state.perfect_streak = 0
	s.emit(&"mg_slab_locked", {"trimmed": trimmed, "perfect": trimmed == 0})
	s.state.direction = -int(s.state.direction)
	_slider(s)

func _sort_piece(s: WtMinigameSession) -> void:
	var shape: ShapeDef = s.next_shape()
	s.state.serial = int(s.state.serial) + 1
	s.state.colour = s.rng.randi_range(1, 3)
	s.state.sorted = false
	s.state.golden = s.now_ms() >= int(s.state.gold_due)
	if bool(s.state.golden):
		s.state.gold_serial = int(s.state.gold_serial) + 1
		var gold_rng: RandomNumberGenerator = Seeds.make_rng(s._seed, ["minigame", "gold", s.state.gold_serial])
		s.state.gold_due = s.now_ms() + gold_rng.randi_range(8000, 12000)
		s.emit(&"mg_golden_piece", {"serial": s.state.gold_serial})
	var duration: int = maxi(1, int(s.template.get("duration_ms", 60000)))
	s.state.next_ms = s.now_ms() + maxi(450, 1600 - s.now_ms() * 1150 / duration)
	s.view.merge({"chute_shape": shape.shape_id, "chute_colour": s.state.colour, "golden": s.state.golden, "due_ms": s.state.next_ms, "serial": s.state.serial}, true)

func _sky(s: WtMinigameSession) -> void:
	var shape: ShapeDef = s.next_shape()
	var orient: int = shape.spawn_orient
	var box: Vector3i = shape.bbox(orient)
	var lane: Vector2i = Vector2i(s.rng.randi_range(0, maxi(0, 7 - box.x)), s.rng.randi_range(0, maxi(0, 7 - box.z)))
	s.active = ActivePiece.new(shape, Vector3i(lane.x, mini(36, maxi(8, s.top_height() + 5)), lane.y) - shape.min_corner(orient), orient)
	s.state.merge({"lane": lane, "drop_start": s.now_ms() + 1000, "fall_at": s.now_ms() + 1000}, true)
	var landing: Array[Vector3i] = []
	var drop: int = Movement.drop_distance(s.active, s.frame)
	for cell: Vector3i in s.active.cells(): landing.append(cell + Vector3i.DOWN * drop)
	s.view = {"kind": "tray", "tray": s.state.tray, "tray_size": 3, "lane": lane, "sky_cells": s.active.cells(), "landing_cells": landing, "drop_due": s.state.drop_start, "height": s.top_height()}

func _sky_supported(s: WtMinigameSession) -> bool:
	for cell: Vector3i in s.active.cells():
		if cell.y <= 0: return true
		if s.frame.get_kind(s.frame.index(cell + Vector3i.DOWN)) != 0: return true
	return false

func _catch(s: WtMinigameSession) -> void:
	var tray: Vector2i = s.state.tray
	var caught: int = 0
	var cells: Array[Vector3i] = s.active.cells()
	cells.sort_custom(func(a: Vector3i, b: Vector3i) -> bool: return a.y < b.y)
	for cell: Vector3i in cells:
		var on_tray: bool = cell.x >= tray.x and cell.x < tray.x + 3 and cell.z >= tray.y and cell.z < tray.y + 3
		if (cell.y == 0 and on_tray) or (cell.y > 0 and s.frame.get_kind(s.frame.index(cell + Vector3i.DOWN)) != 0):
			s.frame.place(s.frame.index(cell), s.catalog.content.kind_of(&"block"), s.active.hue_id, s.spawner.drawn_count())
			caught += 1
	if caught > 0:
		s.state.catches = int(s.state.catches) + 1
		s.charge_send(&"slippery_tray", {"duration_ms": 6000}, 5)
		s.emit(&"mg_piece_caught", {"cells": caught, "trimmed": cells.size() - caught})
	else: s.emit(&"mg_piece_missed")
	_sky(s)

func _tray_move(s: WtMinigameSession, direction: Vector3i) -> void:
	if direction.y != 0 or absi(direction.x) + absi(direction.z) != 1: return
	var stride: int = 2 if s.now_ms() < int(s.state.slippery_until) else 1
	var old: Vector2i = s.state.tray
	var next: Vector2i = Vector2i(clampi(old.x + direction.x * stride, 0, 4), clampi(old.y + direction.z * stride, 0, 4))
	var delta: Vector3i = Vector3i(next.x - old.x, 0, next.y - old.y)
	var sources: Array[Vector3i] = s.board_cells()
	var targets: Array[Vector3i] = []
	for cell: Vector3i in sources: targets.append(cell + delta)
	if not sources.is_empty(): s.frame.move_batch(sources, targets, true)
	s.state.tray = next
	s.emit(&"mg_tray_moved", {"tray": next, "stride": stride})

func _notes(s: WtMinigameSession) -> void:
	var interval: int = 60000 / maxi(1, int(s.params.get("bpm", 120)))
	var notes: Array = s.state.notes
	while int(s.state.beat) * interval < s.now_ms() + 2000:
		s.state.beat = int(s.state.beat) + 1
		notes.append({"lane": s.rng.randi_range(0, int(s.params.get("lane_count", 4)) - 1), "at": int(s.state.beat) * interval, "hit": false, "missed": false, "serial": s.state.beat})
	while not notes.is_empty() and int(notes[0].at) < s.now_ms() - 1000: notes.pop_front()
	s.view = {"kind": "rhythm", "notes": notes.duplicate(true), "lane_count": int(s.params.get("lane_count", 4)), "hit_window_ms": int(s.params.get("hit_window_ms", 180)), "combo": s.state.combo, "offbeat_until": s.state.offbeat_until}

func _rhythm_hit(s: WtMinigameSession, lane: int) -> void:
	for note: Dictionary in s.state.notes:
		if int(note.lane) == lane and not bool(note.hit) and not bool(note.missed) and absi(s.now_ms() - int(note.at)) <= int(s.params.get("hit_window_ms", 180)):
			note.hit = true
			s.state.combo = int(s.state.combo) + 1
			s.add_score(1 + (1 if int(s.state.combo) % 4 == 0 else 0))
			s.charge_send(&"offbeat", {"duration_ms": 5000}, 8)
			s.emit(&"mg_rhythm_hit", {"lane": lane, "combo": s.state.combo})
			return
	s.state.combo = 0
	s.emit(&"mg_rhythm_miss", {"lane": lane})

func _maze(s: WtMinigameSession) -> void:
	var path: Array[Vector2i] = []
	var reflect: bool = s.rng.randi_range(0, 1) == 1
	var rotate: bool = s.rng.randi_range(0, 1) == 1
	for y: int in 4:
		for index: int in 4:
			var x: int = index if y % 2 == 0 else 3 - index
			var cell: Vector2i = Vector2i(3 - x if reflect else x, y)
			path.append(Vector2i(cell.y, cell.x) if rotate else cell)
	var edges: Array = []
	for index: int in path.size() - 1: edges.append([path[index], path[index + 1]])
	s.state.merge({"path": path, "edges": edges, "cursor": path[0], "block": path[0], "dock": path[15], "shape_id": s.next_shape().shape_id}, true)
	_maze_view(s)

func _maze_view(s: WtMinigameSession) -> void:
	s.view = {"kind": "magnet", "size": Vector2i(4, 4), "path": s.state.path.duplicate(), "edges": s.state.edges.duplicate(true), "cursor": s.state.cursor, "block": s.state.block, "dock": s.state.dock, "shape_id": s.state.shape_id, "polarity": int(s.state.polarity) * (-1 if s.now_ms() < int(s.state.reversed_until) else 1), "reversed_until": s.state.reversed_until, "docked": s.state.docked}

func _magnet_move(s: WtMinigameSession, direction: Vector2i) -> void:
	if absi(direction.x) + absi(direction.y) != 1: return
	var cursor: Vector2i = s.state.cursor
	var next: Vector2i = cursor + direction
	var valid: bool = false
	for edge: Array in s.state.edges:
		if (edge[0] == cursor and edge[1] == next) or (edge[1] == cursor and edge[0] == next): valid = true
	if not valid: return
	s.state.cursor = next
	var block: Vector2i = s.state.block
	var polarity: int = int(s.state.polarity) * (-1 if s.now_ms() < int(s.state.reversed_until) else 1)
	if polarity == 1 and block == cursor: s.state.block = next
	elif polarity == -1 and block == next:
		var pushed: Vector2i = block + direction
		for edge: Array in s.state.edges:
			if (edge[0] == block and edge[1] == pushed) or (edge[1] == block and edge[0] == pushed): s.state.block = pushed
	if s.state.block == s.state.dock:
		s.state.docked = int(s.state.docked) + 1
		s.progress = mini(1000, int(s.state.docked) * 500)
		s.charge_send(&"polarity_reverse", {"duration_ms": 5000})
		s.emit(&"mg_magnet_docked", {"docked": s.state.docked})
		if int(s.state.docked) >= 2: s.finish()
		else: _maze(s)

func _volley_ball(s: WtMinigameSession, data: Dictionary = {}) -> void:
	s.state.serial = int(s.state.serial) + 1
	s.state.shape_id = StringName(data.get("shape_id", s.next_shape().shape_id))
	s.state.waiting = false
	var center: int = s.now_ms() + int(data.get("flight_ms", s.params.get("flight_ms", 2400)))
	var window: int = int(s.params.get("return_window_ms", 400))
	s.state.return_start = center - window / 2
	s.state.return_end = center + window / 2
	s.view = {"kind": "volley", "shape_id": s.state.shape_id, "serial": s.state.serial, "flight_start": s.now_ms(), "return_start": s.state.return_start, "return_end": s.state.return_end, "waiting": false}
	s.emit(&"mg_volley_ball", s.view)
